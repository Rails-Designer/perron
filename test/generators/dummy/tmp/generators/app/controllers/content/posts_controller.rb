class Content::PostsController < ApplicationController

  def index
    @resources = Content::Post.all
  end

  def show
    @resource = Content::Post.find(params[:id])
  end
end
