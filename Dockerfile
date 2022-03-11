FROM ruby:alpine

RUN apk update && apk add build-base sqlite sqlite-dev tzdata nodejs yarn make gcc bash git

ENV INSTALL_PATH /thh

# Create a directory for the app code
RUN mkdir -p $INSTALL_PATH/app

WORKDIR $INSTALL_PATH

COPY Gemfile* ./
COPY create_base_app.sh ./

RUN chmod +x create_base_app.sh
RUN gem update --system
RUN gem install bundler
RUN bundle install

RUN yarn install --check-files

WORKDIR $INSTALL_PATH/app

CMD ["bundle", "exec", "rails", "s"]
