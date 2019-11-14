FROM node:10
ADD app.js /usr/src
ADD log.js /usr/src
ADD start.sh /usr/src
ADD package.json /usr/src
WORKDIR /usr/src
RUN npm install
EXPOSE 3000
CMD ["bash", "start.sh"]
