module Perron
  class ConciergeController < ActionController::Base
    def show
      render :show
    end

    def run_command
      command = params[:command]

      return redirect_back fallback_location: root_path unless command.start_with?("bin/rails generate content")

      system(command)
      redirect_back fallback_location: root_path
    end
  end
end
