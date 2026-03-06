# Compose

A helper to fetch dynamically allocated ports with Docker Compose.

## Installation

Add the following to your Gemfile

```ruby
gem 'compose', git: 'https://github.com/kickstarter/rails-compose'
```

## Usage

Fetch the currently allocated port for a service:

```ruby
Compose.port(:redis, 6379)
# => 49811
```

Fetch the port and interpolate it into a template string:

```ruby
Compose.port(:redis, 6379, 'redis://localhost:%s/')
# => "redis://localhost:49811/"
```

Use in a Rails config YAML file:

```yaml
# ./config/redis.yml
---
development:
  host: localhost
  port: <%= Config.port(:redis, 6379) %>
  url: <%= Config.port(:redis, 6379, 'redis://localhost:%s/') %>
```
