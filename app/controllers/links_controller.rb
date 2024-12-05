class LinksController < ApplicationController
    before_action :set_link, only: [:show, :stats]

    def new
        @link = Link.new
    end

    def create
        @link = Link.new(link_params)

        if @link.save
            redirect_to @link, notice: "Short URL created successfully!"
        else
            render :new
        end
    end

    def show
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

    
end
