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
            # Make HTTP request to get the page content
            doc = HTTParty.get(target_url)
            # Extract title using regex - captures text between <title> tags
            match = doc.body.match(/<title>(.*?)<\/title>/)
            self.title = match[1] if match
        rescue StandardError => e
            # If anything goes wrong (network error,etc),
            # log it but allow the save to continue
            Rails.logger.error("Failed to fetch title for #{target_url}: #{e.message}")
        end
    end

end
