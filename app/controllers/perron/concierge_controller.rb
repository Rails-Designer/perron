module Perron
  class ConciergeController < ActionController::Base
    def show
      render :show
    end

    def run_command
      system(params[:command])

      redirect_back fallback_location: root_path
    end
  end
end
