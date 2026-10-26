class Content::PagesController < ApplicationController
  def root
    @resource = Content::Page.root

    render @resource.inline
  end

  def show
    @resource = Content::Page.find(params[:id])

    render @resource.inline
  end
end
