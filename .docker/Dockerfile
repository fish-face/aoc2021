FROM nimlang/nim

RUN nimble -y install arraymancer npeg memo

ADD entrypoint.sh /entrypoint.sh

VOLUME /code
WORKDIR /code
ENTRYPOINT ["/entrypoint.sh"]