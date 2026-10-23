FROM bash:5.2

RUN mkdir -p /home/cleaner
ENV HOME=/home/cleaner
WORKDIR /home/cleaner

COPY pi-clean.sh /usr/local/bin/pi-clean
RUN chmod +x /usr/local/bin/pi-clean

CMD ["/usr/local/bin/pi-clean"]
