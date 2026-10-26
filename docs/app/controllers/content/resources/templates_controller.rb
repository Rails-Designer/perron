class Content::Resources::TemplatesController < ApplicationController
  layout false

  def show
    @resource = Content::Resource.find!(params[:resource_id])

    render plain: @resource.template
  end
end
