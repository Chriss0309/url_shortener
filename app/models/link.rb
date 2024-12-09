# Represents a shortened URL link in the system
# @attr target_url [String] The original URL to redirect to
# @attr short_path [String] The unique shortened path identifier
# @attr title [String] The title of the target webpage
class Link < ApplicationRecord
    validates :target_url, presence: true, url: true
    validates :short_path, uniqueness: true, length: { maximum: 15 }, allow_nil: true

    has_many :visits, dependent: :destroy
    before_validation :fetch_title, on: :create
    before_create :generate_short_path

    private

    # Generates a unique short path for the link using base62 encoding
    def generate_short_path
        return if short_path.present?   # Skip if the path is already generated
        
        retries = 0
        begin
            # Use the current record's ID or calculate the next available ID
            self.short_path = encode_base62(id || self.class.maximum(:id).to_i + 1)
        rescue ActiveRecord::RecordNotUnique => e
            retries += 1
            retry if retries < 3    # Retry up to 3 times on collision
            raise e                   # Raise error if all retries fail
        end
    end

    # Encodes a number into a base62 string representation using alphanumeric characters (0-9, a-z, A-Z)
    def encode_base62(number, min_length: 4)
        chars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'   # Base62 character set
        base = chars.length
        result = ''

        while number > 0
            result = chars[number % base] + result
            number /= base
        end

        # Pad result with leading zeros to ensure the result meets the minimum length
        result = result.length < min_length ? result.rjust(min_length, '0') : result
    end

    # Fetches and sets the title of the target URL by making an HTTP request
    # and extracting the contents of the <title> tag
    # Handles various HTTP and parsing errors 
    def fetch_title
        return if target_url.blank? || Rails.env.test?  

        begin
            require 'nokogiri'
            require 'open-uri'

            # Mimic browser-like behavior with headers
            user_agent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
            
            # Open the URL safely with timeouts and headers
            doc = Nokogiri::HTML(URI.open(
                target_url,
                'User-Agent' => user_agent,
                'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
                'Accept-Language' => 'en-US,en;q=0.5'
            ))
            
            # Find the title tag and get its content
            title_tag = doc.at_css('title')
            self.title = title_tag.content.strip if title_tag
        rescue OpenURI::HTTPError => e
            Rails.logger.error("HTTP Error fetching title for #{target_url}: #{e.message}")
            nil
        end
    end

end
 