class Content::ResourcesController < Content::DocsController
  def index
    @metadata = {
      title: "Library",
      description: "Snippets, templates and UI components for your Perron-powered site."
    }
  end

  def show
    @resource = Content::Resource.find!(params[:id])
  end
end
