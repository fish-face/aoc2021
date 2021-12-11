FROM nimlang/nim

RUN nimble -y install arraymancer npeg

ADD entrypoint.sh /entrypoint.sh

VOLUME /code
WORKDIR /code
ENTRYPOINT ["/entrypoint.sh"]