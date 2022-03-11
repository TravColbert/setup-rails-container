FROM ruby:alpine

RUN apk update && apk add build-base sqlite sqlite-dev tzdata nodejs yarn make gcc bash git

ENV INSTALL_PATH /thh

# Create a directory for the app code
RUN mkdir -p $INSTALL_PATH/app

# Switch to workdir
WORKDIR $INSTALL_PATH/app

COPY Gemfile* ./

RUN gem update --system
RUN gem install bundler
RUN bundle install

RUN yarn install --check-files

RUN gem install rails

# Copy the main application
# COPY . .

# CMD ["bundle", "exec", "rails", "s"]

# CMD bin/rails server -p $PORT

# CMD pwd && ls -la && which rails && which bash && which irb

CMD bash &