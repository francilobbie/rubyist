# syntax = docker/dockerfile:1

# Define the Ruby version
ARG RUBY_VERSION=3.1.2
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

# Set the working directory
WORKDIR /rails

# Set production environment
ENV RAILS_ENV="production"
ENV BUNDLE_PATH="/usr/local/bundle"
ENV PATH="$BUNDLE_PATH/bin:$PATH"

# Install dependencies in the build stage
FROM base as build

# Install required packages, including Node.js, Yarn, and esbuild
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    libpq-dev \
    libvips \
    pkg-config \
    curl && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install --global yarn && \
    npm install --global esbuild

# Create and set permissions for GEM_HOME
RUN mkdir -p "$BUNDLE_PATH" && chmod -R 777 "$BUNDLE_PATH"

# Copy package.json and yarn.lock
COPY package.json yarn.lock ./

# Install JavaScript dependencies
RUN yarn install

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install Ruby gems
RUN bundle config set without 'development:test' && \
    bundle install && \
    rm -rf ~/.bundle/ "$BUNDLE_PATH/ruby/*/cache" "$BUNDLE_PATH/ruby/*/bundler/gems/*/.git" && \
    bundle exec bootsnap precompile --gemfile

# Copy the application code
COPY . .

# Precompile assets
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Final runtime stage
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

WORKDIR /rails
ENV RAILS_ENV="production"
ENV BUNDLE_PATH="/usr/local/bundle"
ENV PATH="$BUNDLE_PATH/bin:$PATH"

# Install runtime dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    libvips \
    postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy built dependencies and application code
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Set the command to start the Rails server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
