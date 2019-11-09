# Set up

FROM alpine:latest as build
WORKDIR /code
RUN apk add --update --no-cache --quiet wget gcc libc-dev automake autoconf \
    g++ pcre-dev zlib-dev make
RUN wget -q -O e2g.tar.gz https://github.com/e2guardian/e2guardian/archive/5.3.3.tar.gz
RUN tar xfz e2g.tar.gz
RUN cd /code/e2guardian-5.3.3/ && \ 
    ./autogen.sh && \
    ./configure --disable-dependency-tracking --quiet && \ 
    make -s && \ 
    make -s install

FROM alpine:latest as prod
COPY --from=build /usr/local /opt
COPY confd /etc/confd
COPY entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/entrypoint.sh
RUN echo "http://nl.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
    apk add --update --no-cache libgcc libstdc++ pcre openssl confd shadow tzdata 
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
