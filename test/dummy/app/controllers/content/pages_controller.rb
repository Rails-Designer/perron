class Content::PagesController < ApplicationController
  def root
    @resource = Content::Page.root

    render :show
  end

  def show
    @resource = Content::Page.find(params[:id])
  end
end
