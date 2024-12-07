require 'net/http'
require 'json'

class LinksController < ApplicationController
    before_action :set_link, only: [:show, :stats]

    def new
        @link = Link.new
    end

    def create
        @link = Link.new(link_params)

        if verify_turnstile && @link.save
            redirect_to @link, notice: "Short URL created successfully!"
        else
            @link.errors.add(:base, 'Please verify you are human') unless verify_turnstile
            render :new, status: :unprocessable_entity
        end
    end

    def show
        uri = URI.parse(@link.target_url)
        if uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
            render :show
        else
            redirect_to root_path, alert: "Invalid URL format"
        end
    rescue URI::InvalidURIError
        redirect_to root_path, alert: "Invalid URL format"
    end

    def stats
        @visits = @link.visits.order(created_at: :desc)
    end

    def redirect
        @link = Link.find_by!(short_path: params[:short_path])

        #Record the visit
        @link.visits.create!(
            ip_address: request.remote_ip,
            user_agent: request.user_agent,
            referer: request.referer
        )

        redirect_to @link.target_url, allow_other_host: true
    end

    private

    def set_link
        @link = Link.find(params[:id])
    end

    def link_params
        params.require(:link).permit(:target_url)
    end

    def verify_turnstile
        token = params['cf-turnstile-response']
        
        uri = URI('https://challenges.cloudflare.com/turnstile/v0/siteverify')
        response = Net::HTTP.post_form(uri, {
            'secret' => ENV['TURNSTILE_SECRET_KEY'],
            'response' => token,
            'remoteip' => request.remote_ip
        })
        
        JSON.parse(response.body)['success']
    end

end
