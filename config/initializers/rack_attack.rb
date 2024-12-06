class Rack::Attack
  # Configure Cache to keep track of request counts per IP 
  Rack::Attack.cache.store = Rails.cache

  ### Throttling ###
  
  # Rate limit URL creation to 10 requests per minute per IP 
  throttle('links/create/ip', limit: 10, period: 1.minute) do |req|
    req.ip if req.path == '/links' && req.post?
  end

  # Rate limit URL visits to 60 per minute per IP 
  throttle('links/visit/ip', limit: 60, period: 1.minute) do |req|
    req.ip if req.path =~ /^\/[A-Za-z0-9]{8}$/
  end

  # Rate limit stats viewing to 30 requests per minute per IP 
  throttle('links/stats/ip', limit: 30, period: 1.minute) do |req|
    req.ip if req.path =~ /\/links\/\d+\/stats$/
  end

  # Global rate limit to prevent scanning/crawling (300 reqs/5min per IP)
  throttle('req/ip', limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?('/assets/')
  end

  # Block suspicious user agents (bots, crawlers, etc.)
  blocklist('block_suspicious_uas') do |req|
    req.user_agent&.match?(/\b(curl|wget|scrapy|bot|spider)\b/i)
  end

  # Custom error message for throttled requests
  self.throttled_responder = lambda do |env|
    [429, {}, ["Too many requests. Please try again later.\n"]]
  end
end 