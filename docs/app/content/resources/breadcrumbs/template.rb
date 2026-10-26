gem "perron" unless File.read("Gemfile").include?("perron")

after_bundle do
  unless File.exist?("config/initializers/perron.rb")
    rails_command "perron:install"
  end

  inject_into_class "app/controllers/application_controller.rb", "ApplicationController" do
    "  include Breadcrumbs\n"
  end

file "app/models/concerns/breadcrumbs.rb" do
<<~"_"
module Breadcrumbs
  extend ActiveSupport::Concern

  included do
    helper_method :breadcrumbs
  end

  def breadcrumbs = @breadcrumbs ||= []

  def set_breadcrumbs(*crumbs)
    @breadcrumbs = crumbs.map do |crumb|
      case crumb
      in [ String => name, path ] then Breadcrumb.new(name, path)
      in [ String => name ] then Breadcrumb.new(name)
      in Breadcrumb then crumb
      end
    end
  end

  private

  class Breadcrumb
    attr_reader :name, :path

    def initialize(name, path = nil)
      @name, @path = name, path
    end

    def link? = @path.present?
  end
end

_
end

file "app/views/shared/_breadcrumbs.html.erb" do
<<~"_"
<%%= tag.nav "aria-label": "Breadcrumb" do %%>
  <ol itemscope itemtype="https://schema.org/BreadcrumbList">
    <%% breadcrumbs.each.with_index(1) do |crumb, index| %%>
      <li itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
        <%% if crumb.link? %%>
          <%%= link_to crumb.name, crumb.path, class: "breadcrumb-link", itemprop: "item", "aria-current": (crumb == breadcrumbs.last ? "page" : nil) %%>

          <meta itemprop="name" content="<%%= crumb.name %%>">
        <%% else %%>
          <span itemprop="name" aria-current="page">
            <%%= crumb.name %%>
          </span>
        <%% end %%>
        <meta itemprop="position" content="<%%= index %%>">

        <%% unless crumb == breadcrumbs.last %%>
          <span aria-hidden="true">/</span>
        <%% end %%>
      </li>
    <%% end %%>
  </ol>
<%% end if breadcrumbs.any? %%>

_
end
end
