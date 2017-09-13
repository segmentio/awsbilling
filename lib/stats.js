const { STATSD_HOST, STATSD_PORT } = require('./config')
const Stats = require('dog-statsy')

const stats = new Stats({
    host: STATSD_HOST,
    port: STATSD_PORT,
    prefix: 'billing-to-redshift'
})

module.exports = stats
