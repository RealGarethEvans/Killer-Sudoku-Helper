FROM httpd:latest
COPY ./html-files/ /usr/local/apache2/htdocs/
COPY ./conf/httpd.conf /usr/local/apache2/conf/httpd.conf
RUN rm /usr/local/apache2/htdocs/index.html
RUN apt update
RUN apt install -y make libcgi-session-perl libwww-perl libpdf-api2-perl cpanminus libswitch-perl libwww-curl-perl imagemagick libpadwalker-perl
RUN cpanm PDF::TextBlock

