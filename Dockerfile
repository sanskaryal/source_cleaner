FROM bash:5.2

RUN mkdir -p /home/cleaner
ENV HOME=/home/cleaner
WORKDIR /home/cleaner

COPY pi-clean.sh /usr/local/bin/pi-clean
COPY project-clean.sh /usr/local/bin/project-clean
RUN chmod +x /usr/local/bin/pi-clean /usr/local/bin/project-clean

CMD ["/usr/local/bin/pi-clean"]
