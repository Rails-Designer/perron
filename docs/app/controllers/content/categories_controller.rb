class Content::CategoriesController < Content::DocsController
  def show
    @type = Content::Resource::TYPES[params[:id]]
    @description = Content::Resource::DESCRIPTIONS[params[:id]]

    @metadata = {
      title: @type,
      description: @description
    }

    @resources = Content::Resource.by_type(params[:id]).sort_by(&:category).group_by(&:category)
  end
end
