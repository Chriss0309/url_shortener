class Visit < ApplicationRecord
    belongs_to :link

    validates :ip_address, presence: true   # @attr [String] ip_address The IP address of the visitor
    validates :user_agent, presence: true   # @attr [String] user_agent The user agent string of the visitor's browser

    before_create :set_geolocation

    private

    def set_geolocation
        result = Geocoder.search(ip_address).first
        if result
            self.country = result.country
            self.city = result.city
        end
    rescue StandardError => e
        Rails.logger.error("Error setting geolocation: #{e.message}")
    end
    
end
