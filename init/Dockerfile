FROM alpine
ADD init.sh /usr/src/init.sh
RUN apk add curl jq
CMD ["sh", "/usr/src/init.sh"]