FROM nginx:1.13
MAINTAINER Hermann Mayer <hermann.mayer@hausgold.de>

# Install all required packages
RUN apt-get update -yqqq && \
  apt-get install -y \
    avahi-daemon avahi-discover avahi-utils \
    libnss-mdns supervisor curl gnupg

# Install nodejs 16
RUN curl -sL https://deb.nodesource.com/setup_16.x \
  | bash - && apt-get install -y nodejs

# Install our own resolver
COPY resolver/* /opt/resolver/
RUN cd /opt/resolver && npm install

# Configure nginx as dynamic proxy
COPY config/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY config/nginx/502.html /usr/share/nginx/html/

# Copy avahi.sh and nginx.sh
COPY config/entrypoint config/avahi.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint /usr/local/bin/avahi.sh

# Configure supervisord
COPY config/supervisor/* /etc/supervisor/conf.d/
RUN mkdir -p /var/log/supervisor

# Define the command to run per default
CMD /usr/local/bin/entrypoint
