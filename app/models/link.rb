class Link < ApplicationRecord
    validates :target_url, presence: true, url: true
    validates :short_path, presence: true, uniqueness: true, length: { maximum: 15}

    has_many :visits, dependent: :destroy

    before_validation :fetch_title, on: :create
    after_create :generate_short_path

    private

    def generate_short_path
        # Generate short_path only after we have the database ID
        update_column(:short_path, encode_base62(id))
    end

    # Encodes a number into a base62 string representation
    # @return [String] A 6-character string containing only alphanumeric characters
    def encode_base62(number)
        chars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
        base = chars.length
        result = ''

        # Convert number to base62 by repeatedly dividing by base and prepending remainder's corresponding character
        while number > 0
            result = chars[number % base] + result
            number /= base
        end

        # Pad result with leading zeros to ensure 6 characters
        result.rjust(6, '0')
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
