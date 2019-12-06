# Set up

FROM alpine:latest as build
WORKDIR /code
RUN apk add --update --no-cache --quiet wget gcc libc-dev automake autoconf \
    g++ pcre-dev zlib-dev make openssl-dev
RUN wget -q -O e2g.tar.gz https://github.com/e2guardian/e2guardian/archive/5.3.3.tar.gz
RUN tar xfz e2g.tar.gz
RUN cd /code/e2guardian-5.3.3/ && \ 
    ./autogen.sh && \
    ./configure '--prefix=/opt' '--enable-clamd=yes' \
                '--with-proxyuser=e2guardian' '--with-proxygroup=e2guardian' \
                '--sysconfdir=${prefix}/etc' '--localstatedir=${prefix}/var' \
                '--enable-icap=yes' '--enable-commandline=yes' \
                '--enable-email=yes' '--enable-ntlm=yes' \
                '--mandir=${prefix}/share/man' '--infodir=${prefix}/share/info' \
                '--enable-pcre=yes' '--enable-sslmitm=yes' \
                --disable-dependency-tracking --quiet 'CPPFLAGS=-mno-sse2 -g -O2' && \
    make -s && \ 
    make -s install

FROM alpine:latest as prod
COPY --from=build /opt /opt
COPY confd /etc/confd
COPY entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/entrypoint.sh
RUN echo "http://nl.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
    apk add --update --no-cache libgcc libstdc++ pcre openssl confd shadow tzdata curl
RUN groupmod -g 1000 users && \
    useradd -u 1000 -U -d /opt/e2guardian -s /bin/false e2guardian && \
    usermod -G users e2guardian
RUN chown e2guardian:e2guardian /opt/var/log/e2guardian
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
