class Content::PostsController < ApplicationController

  def show
    @resource = Content::Post.find(params[:id])
  end
end
