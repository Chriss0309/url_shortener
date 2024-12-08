

# URL Shortener

A Ruby on Rails application that shortens URLs and provides visit analytics📈.

Live Demo: https://coingecko-url-shortener-bc1b0ea0ebce.herokuapp.com/

## Features
- URL shortening with base62 encoding
- Visit analytics with geolocation tracking
- Rate limiting and bot protection
- Page title fetching
- Human verification using Cloudflare Turnstile

## Prerequisites

- Ruby 3.3.6
- PostgreSQL
- Redis (optional, for rate limiting)
- Node.js (for Tailwind CSS)

## Installation

1. **Clone the repository**
```bash
git clone [repository-url]
cd url-shortener
```

2. **Install dependencies**
```bash
bundle install
```

3. **Setup database**
```bash
# Configure database credentials in config/database.yml
rails db:create
rails db:migrate
```

4. **Start the server**
```bash
bin/dev # Development with Tailwind CSS
# or
rails server
```

## Key Dependencies

```ruby
# Core
gem 'rails', '~> 8.0.0'
gem 'pg'
gem 'puma', '>= 5.0'

# Frontend
gem 'tailwindcss-rails'
gem 'turbo-rails'
gem 'stimulus-rails'

# Security & Performance
gem 'rack-attack'
gem 'redis', '>= 5.3.0'
gem 'turnstile'

# URL Processing
gem 'validate_url'
gem 'nokogiri'
gem 'geocoder'

# Development/Test
gem 'debug'
gem 'brakeman'
gem 'rubocop-rails-omakase'
```

## Development Tools

- **Brakeman**: Security vulnerability scanner
- **RuboCop**: Code style enforcement
- **Minitest**: Testing framework
- **WebMock**: HTTP request stubbing
- **Capybara**: System testing

## Deployment

The application is deployed on Heroku with:
- PostgreSQL for database
- Redis for rate limiting
- Cloudflare Turnstile for bot protection

```bash
# Deploy to Heroku
git push heroku main

# Setup database
heroku run rails db:migrate
```

## Testing

```bash
# Run all tests
rails test

# Run system tests
rails test:system
```

## Acknowledgments

- Cloudflare Turnstile for bot protection
- Tailwind CSS for styling
- Rails community for the amazing framework

