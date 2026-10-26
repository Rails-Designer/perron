class Content::Articles::MarkdownController < ApplicationController
  layout false

  def show
    @article = Content::Article.find!(params[:id])

    render plain: "# #{@article.title}\n\n#{@article.content}"
  end
end
