class Link < ApplicationRecord
    validates :target_url, presence: true, url: true
    validates :short_path, uniqueness: true, length: { maximum: 15 }, allow_nil: true

    has_many :visits, dependent: :destroy

    before_validation :fetch_title, on: :create
    before_create :generate_short_path

    private

    def generate_short_path
        return if short_path.present?
        
        retries = 0
        begin
            self.short_path = encode_base62(id || self.class.maximum(:id).to_i + 1)
        rescue ActiveRecord::RecordNotUnique => e
            retries += 1
            retry if retries < 3
            raise e
        end
    end

    # Encodes a number into a base62 string representation using alphanumeric characters (0-9, a-z, A-Z)
    def encode_base62(number, min_length: 4)
        chars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
        base = chars.length
        result = ''

        while number > 0
            result = chars[number % base] + result
            number /= base
        end

        # Pad result with leading zeros to ensure min_length characters
        result = result.length < min_length ? result.rjust(min_length, '0') : result
    end

    # Fetches and sets the title of the target URL by making an HTTP request
    # and extracting the contents of the <title> tag
    def fetch_title
        return if target_url.blank?

        begin
            require 'nokogiri'
            require 'open-uri'

            # Configure headers to mimic a browser
            user_agent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
            
            # Open URL with headers
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
        rescue StandardError => e
            Rails.logger.error("Failed to fetch title for #{target_url}: #{e.message}")
            nil
        end
    end

end
