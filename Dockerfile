FROM node:4

COPY . /src
WORKDIR /src

RUN apt-get update && apt-get install -y unzip
RUN npm install

CMD ["bash", "main.sh"]
