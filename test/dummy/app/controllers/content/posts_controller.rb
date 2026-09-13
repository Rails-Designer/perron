class Content::PostsController < ApplicationController
  helper Perron::MarkdownHelper

  def index
    @resources = Content::Post.all
  end

  def show
    @resource = Content::Post.find!(params[:id])
  end
end
