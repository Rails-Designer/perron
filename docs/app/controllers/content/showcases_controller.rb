class Content::ShowcasesController < ApplicationController
  def index
    @metadata = {
      title: "Showcase",
      description: "SaaS pages that convert. Business sites with character. Engaging documentation. All of these are built with Perron."
    }

    @resources = Content::Showcase.all.recently_published
  end
end
