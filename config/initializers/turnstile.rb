require 'turnstile'

# Don't override environment variables if they're already set
ENV['TURNSTILE_SITE_KEY'] ||= '0x4AAAAAAA1qYF0UJJJz-SR9'     # Development fallback
ENV['TURNSTILE_SECRET_KEY'] ||= '0x4AAAAAAA1qYNDvnhEylFz4SwwRnvBRGTc'  # Development fallback
  