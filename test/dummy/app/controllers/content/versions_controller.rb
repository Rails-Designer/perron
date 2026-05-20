class Content::VersionsController < ApplicationController
  def show
    render json: {
      version: 1
    }
  end
end
