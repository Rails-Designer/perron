class Content::Posts::CategoriesController < ApplicationController
  def show
    render plain: "Category: #{params[:id]}"
  end
end
