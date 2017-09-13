FROM node:8

COPY . /src
WORKDIR /src

RUN apt-get update && apt-get install -y unzip && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    curl -o- -L https://yarnpkg.com/install.sh | bash && \
    PATH="$HOME/.yarn/bin:$PATH" yarn install --ignore-engines

CMD ["bash", "main.sh"]
