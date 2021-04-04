#Download base image ubuntu:latest
FROM ubuntu:latest

# Image info
LABEL maintainer="pedrorito@me.com"
LABEL description="This is custom Docker Image based on Ubuntu to use AWS CLI"

# Configure tzdata automatically in apt install
ENV TZ=Europe/Lisbon
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Update Ubuntu Software repository
RUN apt update

# Install AWS CLI
RUN apt install -y nano curl jq cron awscli

WORKDIR /root

# Copy Update DNS script
COPY update_dns.sh .
RUN chmod 0744 ./update_dns.sh

# Add crontab file in the cron directory
ADD crontab /etc/cron.d/update-dns
RUN chmod 0644 /etc/cron.d/update-dns

# Run the command on container startup
COPY entrypoint.sh .
RUN chmod 0744 ./update_dns.sh
ENTRYPOINT ["sh", "entrypoint.sh"]
