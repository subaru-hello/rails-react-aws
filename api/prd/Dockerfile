FROM ruby:3.0.0
RUN apt-get update -qq && \
    apt-get install -y build-essential \
                       libpq-dev \
                       nodejs

RUN mkdir /app
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN gem install bundler
RUN bundle install --without test development
ADD . /app
EXPOSE 3000
RUN chmod +x /app/entrypoint.sh

CMD ["/app/entrypoint.sh"]