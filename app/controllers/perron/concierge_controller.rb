module Perron
  class ConciergeController < ActionController::Base
    COMMAND_ARGUMENTS = {
      "collection" => %w[bin/rails generate content Post],
      "new_content" => %w[bin/rails generate content Post --new]
    }.freeze

    def show
      render :show
    end

    def run_command
      return head :forbidden unless request.local?

      command_arguments = COMMAND_ARGUMENTS[params[:action_key]]

      return head :unprocessable_entity unless command_arguments

      execute_command(command_arguments)
      redirect_back fallback_location: root_path
    end

    private

    def execute_command(command_arguments)
      system(*command_arguments)
    end
  end
end
