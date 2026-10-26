class Content::LlmsController < ApplicationController
  def show
    render plain: Content::Llm.find!(params[:id]).content
  end
end
