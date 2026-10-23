FROM bash:5.2

RUN mkdir -p /home/cleaner
ENV HOME=/home/cleaner
WORKDIR /home/cleaner

COPY pi-clean.sh /usr/local/bin/pi-clean
COPY pi-tools.sh /usr/local/bin/pi-tools
COPY install-wiringpi.sh /usr/local/bin/install-wiringpi
RUN chmod +x /usr/local/bin/pi-clean /usr/local/bin/pi-tools /usr/local/bin/install-wiringpi

CMD ["/usr/local/bin/pi-clean"]
