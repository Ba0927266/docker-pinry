# -----------------------------------------------------------------------------
# docker-pinry
#
# Builds a basic docker image that can run Pinry (http://getpinry.com) and serve
# all of it's assets, there are more optimal ways to do this but this is the
# most friendly and has everything contained in a single instance.
#
# Authors: Isaac Bythewood
# Updated: Mar 29th, 2016
# Require: Docker (http://www.docker.io/)
# -----------------------------------------------------------------------------


# Base system is the LTS version of Ubuntu.
FROM python:3.6-stretch

RUN groupadd -g 2300 tmpgroup && usermod -g tmpgroup www-data && groupdel www-data && groupadd -g 1000 www-data && usermod -g www-data www-data && usermod -u 1000 www-data && groupdel tmpgroup

RUN apt-get update
RUN apt-get -y install nginx nginx-extras

RUN mkdir -p /srv/www/; cd /srv/www/; git clone https://github.com/haoling/pinry.git
RUN mkdir /srv/www/pinry/logs; mkdir /data
RUN cd /srv/www/pinry && pip install pipenv && pipenv install --three --system
RUN pip install gunicorn supervisor
RUN chown -R www-data:www-data .

# Fix permissions
RUN chown -R www-data:www-data /srv/www


# Load in all of our config files.
ADD ./nginx/nginx.conf /etc/nginx/nginx.conf
ADD ./nginx/sites-enabled/default /etc/nginx/sites-enabled/default
ADD ./supervisor/supervisord.conf /etc/supervisor/supervisord.conf
ADD ./supervisor/conf.d/nginx.conf /etc/supervisor/conf.d/nginx.conf

# Fix permissions
ADD ./scripts/start /start
RUN chown -R www-data:www-data /data; chmod +x /start
RUN mkdir /var/log/supervisor /var/log/gunicorn

# 80 is for nginx web, /data contains static files and database /start runs it.
expose 80
volume ["/data"]
cmd    ["/start"]
