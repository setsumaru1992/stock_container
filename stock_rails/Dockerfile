FROM ruby:2.5.3

CMD [ "/bin/bash" ]
ENV LANG C.UTF-8

ARG appname=stock_rails
ARG apppath="/root/$appname"
WORKDIR $apppath

RUN mkdir -p /var/opt/stock_container/chart_images

RUN gem install bundler -v 2.1.2
COPY Gemfile Gemfile.lock ./
RUN bundle install
