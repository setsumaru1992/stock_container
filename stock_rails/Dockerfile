FROM ruby:2.5.3

CMD [ "/bin/bash" ]
ENV LANG C.UTF-8

RUN gem install bundler -v 2.1.2
COPY Gemfile Gemfile.lock ./

ARG appname=stock_rails
ARG apppath="/root/$appname"
WORKDIR $apppath

