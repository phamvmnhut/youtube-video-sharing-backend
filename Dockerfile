FROM ruby:3.2.2-alpine AS build-env
ARG RAILS_ROOT=/app
ARG BUILD_PACKAGES="build-base curl-dev git"
ARG DEV_PACKAGES="postgresql-dev yaml-dev zlib-dev"
ARG RUBY_PACKAGES="tzdata"
ENV RAILS_ENV=production
ENV NODE_ENV=production
ENV BUNDLE_APP_CONFIG="$RAILS_ROOT/.bundle"
WORKDIR $RAILS_ROOT
# install packages
RUN apk update \
    && apk upgrade \
    && apk add --update --no-cache $BUILD_PACKAGES $DEV_PACKAGES $RUBY_PACKAGES
# install rubygem
COPY Gemfile Gemfile.lock $RAILS_ROOT/
RUN bundle config --global frozen 1 \
    && bundle install --without development:test:assets -j4 --retry 3 --path=vendor/bundle
    # Remove unneeded files (cached *.gem, *.o, *.c)
    # && rm -rf vendor/bundle/ruby/3.2.2/cache/*.gem \
    # && find vendor/bundle/ruby/3.2.2/gems/ -name "*.c" -delete \
    # && find vendor/bundle/ruby/3.2.2/gems/ -name "*.o" -delete
# RUN yarn install --production
COPY . .
# RUN bin/rails webpacker:compile
# RUN bin/rails assets:precompile
# Remove folders not needed in resulting image
# RUN rm -rf node_modules tmp/cache app/assets vendor/assets spec
############### Build step done ###############
FROM ruby:3.2.2-alpine
ARG RAILS_ROOT=/app
ARG PACKAGES="tzdata postgresql-client bash"
ENV RAILS_ENV=production
ENV BUNDLE_APP_CONFIG="$RAILS_ROOT/.bundle"
WORKDIR $RAILS_ROOT
# install packages
RUN apk update \
    && apk upgrade \
    && apk add --update --no-cache $PACKAGES
COPY --from=build-env $RAILS_ROOT $RAILS_ROOT

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000

# CMD ["rails", "server", "-b", "0.0.0.0"]