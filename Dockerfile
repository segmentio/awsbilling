FROM node:6

COPY . /src
WORKDIR /src

RUN npm install

CMD ["bash", "main.sh"]
