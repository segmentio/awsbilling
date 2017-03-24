# awsdetailedbilling

Loads AWS detailed billing reports into a redshift cluster.

[![js-standard-style](https://cdn.rawgit.com/feross/standard/master/badge.svg)](https://github.com/feross/standard)


# Setup

Still a manual process for now:

1. Create a Redshift cluster.
2. Once the cluster is alive, connect with your favorite postgres client and create the `line_items` and `month_to_date` tables. The SQL for creating each are in the `sql/` subdirectory.


## Configuration:

Set these environment variables. Some of them may be overridden at runtime with command-line switches, run the relevant script with `--help` for more details.

- `SOURCE_BUCKET`: the S3 bucket where DBRs are deposited by Amazon.
- `STAGING_BUCKET`: the S3 bucket into which pre-processed DBRs are staged before importing to redshift.
- `AWS_KEY` *or* `SOURCE_AWS_KEY` and `STAGING_AWS_KEY`: the AWS access key ID credential for accessing S3. If the same credentials are used for both the source and staging buckets, you can just set `AWS_KEY`. If separate credentials are neccessary, you can specify `SOURCE_AWS_KEY` *and* `STAGING_AWS_KEY` instead.
- `AWS_SECRET` *or* `SOURCE_AWS_SECRET` and `STAGING_AWS_SECRET`: Same as `AWS_KEY`, but for your AWS access key secret.
- `REDSHIFT_URI`: a connection URI for redshift. Should include credentials, like the form `postgres://myUser:s0mep4ssword@hostname:port/dbname`
- `ROLLBAR_TOKEN`: a token for error reporting to Rollbar.
- `ROLLBAR_ENVIRONMENT`: an environment name for error reporting to Rollbar.

If you use `robo <realm> deploy` to deploy, REDSHIFT_URI, AWS_KEY, AWS_SECRET,
SOURCE_BUCKET and STAGING BUCKET will be set for you - they're set in the
Terraform configuration for the `billing-to-redshift` ECS role definition.

However, `robo deploy` isn't optimal since ECS will restart your container every
time the script exits, which can lead to the job being run multiple times. There
should be a better way to do this. For now, consider adding a sleep after your
query executes in `main.sh`, so ECS won't restart the job immediately, and you
have some time to kill it.

## Usage

There are two scripts: `import_finalized.js` and `import_month_to_date.js`. Both
are intended to be run on a daily schedule, preferably at night. Run duration is
largely dependent on the size of your DBRs; for large DBRs runs of a few hours
are common.

Invoke either with `--help` for invocation instructions.


#### `import_finalized.js`

This script imports "finalized" DBRs — specifically, the DBR for the previous month according to UTC.

The script first checks to see if there's a finalized DBR which hasn't been imported yet. If there is no new finalized DBR, the script terminates immediately. Once a month, when a new finalized DBR appears, the script will download, unzip, gzip, stage, and import the DBR into a temporary table named `staging_YYYY_MM`. Once that process is complete, it adds a `statement_month` column with the relevant month, copies the entire staging table into `line_items`, drops the staging table, and `VACUUM`s the line_items table.

#### `import_month_to_date.js`

This script imports "month-to-date" DBRs, which contain "estimated" billing data but are not 100% accurate. Upon every import, the current month's DBR is downloaded, unzipped, gzipped, and staged. The `month_to_date` table is emptied by means of [TRUNCATE](http://docs.aws.amazon.com/redshift/latest/dg/r_TRUNCATE.html) (eliminating the need for an interim VACUUM), and the staged DBR is imported, followed by a VACUUM.

### Usage tips

First build a Docker container and deploy it to Docker Hub. You may need valid
Docker Hub credentials; ask in the #eng-ops room to get credentials to push.

```bash
make build
```

Then deploy it via ECS. Note that main.sh sleeps until 3am by default. If you
want your script to run instantly, comment out those lines in main.sh before
running `make build`.

```
robo prod deploy megapool billing-to-redshift latest
```

If you run into problems, log into the ECS console, find the billing-to-redshift
task, and manually stop it.

## Meta

License: MIT. See LICENSE.txt.

Questions? Comments? Hit up tools@heroku.com.
