FROM alpine:latest

RUN mkdir /app

RUN mkdir -p /etc/demo/

WORKDIR /app

ADD nomad-vault-demo /app/nomad-vault-demo

ADD index.html /app/index.html

CMD ["/app/nomad-vault-demo"]
