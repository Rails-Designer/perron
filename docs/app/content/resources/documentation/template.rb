gem "perron" unless File.read("Gemfile").include?("perron")
gem "tailwindcss-rails" unless File.read("Gemfile").include?("tailwindcss")

after_bundle do
  unless File.exist?("config/initializers/perron.rb")
    rails_command "perron:install"
  end

  unless File.exist?("app/assets/tailwind/application.css")
    rails_command "tailwindcss:install"
  end

  create_file "app/assets/tailwind//application.css", <<~'RUBY', force: true
@import "tailwindcss";


RUBY

create_file "app/content/articles//features.md", <<~'RUBY', force: true
---
section: advanced
position: 1
title: Advanced features
description: TODO
---

This article is about advanced features in, you guessed it, the advanced section.

Et incididunt excepteur fugiat. Sunt exercitation enim dolor officia. Reprehenderit irure adipisicing non laboris cillum reprehenderit aliqua minim in. Ipsum esse veniam quis deserunt deserunt cillum quis sint reprehenderit et eu. Cupidatat est id veniam.

Nisi consectetur culpa qui exercitation quis esse veniam. Non nostrud non irure reprehenderit esse. Ullamco deserunt sint non id. Reprehenderit nulla eiusmod ea ex laborum magna. Tempor ex consequat incididunt et quis laboris elit laboris fugiat. Aliqua mollit exercitation dolore id quis quis minim.

Reprehenderit velit veniam duis id id sunt ad culpa dolor non aliquip irure irure eu tempor. Minim duis Lorem tempor ullamco commodo adipisicing. Nulla ad sint sit velit voluptate. Tempor amet do veniam aliquip proident magna laboris non qui tempor do ut quis officia. Amet esse id nostrud in exercitation deserunt ea occaecat nostrud id. In ullamco culpa duis id ad adipisicing amet commodo ad.

Consectetur nulla voluptate aute occaecat non. Nisi et labore ut labore duis. Reprehenderit voluptate adipisicing fugiat consequat voluptate culpa et magna dolor mollit. Exercitation nostrud exercitation exercitation quis enim qui non labore ad laborum fugiat dolor aliquip velit. Duis dolore qui do fugiat sunt ad laboris minim magna ea. Eiusmod deserunt duis enim ex nostrud occaecat nulla id. Enim qui dolor tempor ullamco nostrud. Consectetur eiusmod culpa est eu nulla amet do eiusmod labore.


RUBY

create_file "app/content/articles//quickstart.md", <<~'RUBY', force: true
---
section: getting_started
position: 1
title: Quickstart
description: TODO
---

This article is a quickstart and in the Getting started section.

Aliqua Lorem pariatur labore ex aute elit pariatur magna consequat qui. Ut ex officia exercitation culpa amet proident aute elit anim officia officia. Elit adipisicing irure nostrud ex. Anim nostrud irure do laboris Lorem amet. Amet pariatur in excepteur. Mollit cupidatat exercitation culpa ad laboris elit irure non qui reprehenderit incididunt. Ea enim fugiat est. Mollit aliqua id elit velit minim veniam consequat occaecat officia commodo voluptate.

Ullamco proident velit veniam officia quis duis ipsum irure ullamco cillum. Consequat esse adipisicing quis in ipsum irure proident aliquip ullamco quis nostrud exercitation velit. Qui sit ipsum laborum consequat fugiat cupidatat ad amet mollit excepteur. Commodo laboris dolore occaecat culpa qui dolor fugiat commodo pariatur cupidatat laboris magna tempor. Aliqua do esse commodo anim cillum reprehenderit. Non amet eu ullamco velit sunt voluptate labore esse. Fugiat ipsum do duis ad deserunt anim non occaecat laborum elit dolor enim irure aliqua. Adipisicing cillum qui sunt pariatur veniam.

Dolor sunt excepteur incididunt aliquip non in enim et aliquip exercitation. Non commodo fugiat tempor magna ullamco. Minim laboris amet dolore voluptate quis veniam ipsum laboris. Adipisicing qui elit id.

Sint labore consectetur culpa. Nulla Lorem aliquip consectetur. Veniam ea in sit pariatur reprehenderit id minim id ad dolore. Eiusmod et commodo aliqua aliqua. Eu in eiusmod ex tempor consectetur nisi Lorem dolor nulla cupidatat. Sunt magna duis sint.


RUBY

create_file "app/content/data/quick_links.yml", <<~'RUBY', force: true
- title: Perron Docs
  description: Read the docs for Perron
  href: https://perron.railsdesigner.com
- title: Perron Library
  description: Components, snippets and templates (like this one) for Perron
  href: https://perron.railsdesigner.com/library/
- title: Rails Designer
  description: Creator of Perron
  href: https://railsdesigner.com


RUBY

create_file "app/controllers/content//articles_controller.rb", <<~'RUBY', force: true
class Content::ArticlesController < ApplicationController
  def index
    @metadata = {
      title: "Documentation",
      description: "Learn about how to get started and get the most out of this product."
    }

    @resources = Content::Article.all
  end

  def show
    @resource = Content::Article.find!(params[:id])
  end
end


RUBY

create_file "app/models/content//article/adjacency.rb", <<~'RUBY', force: true
module Content::Article::Adjacency
  extend ActiveSupport::Concern

  def next
    return if current_position&.>= ordered_articles.size - 1

    ordered_articles[current_position + 1]
  end

  def previous
    return unless current_position&.positive?

    ordered_articles[current_position - 1]
  end

  private

  def current_position = ordered_articles.find_index { it.id == id }

  def ordered_articles
    Content::Article.all.sort_by { [ Content::Article::SECTIONS.keys.index(it.section), it.position ] }
  end
end


RUBY

create_file "app/models/content//article.rb", <<~'RUBY', force: true
class Content::Article < Perron::Resource
  include Adjacency

  SECTIONS = {
    getting_started: "Getting started",
    advanced: "Advanced",
  }.with_indifferent_access

  def self.sections
    SECTIONS.map do |key, name|
      Section.new(
        key: key,
        name: name,
        resources: where(section: key).order(:position)
      )
    end
  end

  delegate :section, :position, :title, :description, to: :metadata

  validates :title, :description, presence: true
  validates :section, inclusion: { in: SECTIONS.keys }
  validates :position, numericality: { greater_than_or_equal_to: 1 }

  def article_section
    Section.new(
      key: metadata.section,
      name: SECTIONS[metadata.section],
      resources: self.class.where(section: metadata.section).order(:position)
    )
  end

  private

  Section = Data.define(:key, :name, :resources)
end


RUBY

create_file "app/views/content//articles/_adjacency.html.erb", <<~'RUBY', force: true
<%%# locals: (link_css: "flex flex-col my-1 px-3 py-1.5 border border-gray-100 rounded-md transition group/link hover:bg-gray-100 odd:justify-end", label_css: "block text-xs text-gray-600", text_css: "flex items-center gap-x-1 text-sm font-medium text-gray-800") %%>
<nav aria-label="Pagination" class="max-w-prose">
  <ul class="grid grid-cols-6 gap-4 w-full">
    <%%= tag.li class: "col-span-3" do %%>
      <%%= link_to @resource.previous, rel: "prev", class: link_css do %%>
        <%%= tag.span "Previous", class: label_css %%>

        <%%= tag.strong @resource.previous.title, class: text_css %%>
      <%% end %%>
    <%% end if @resource.previous %%>

    <%%= tag.li class: "only:col-start-4 col-span-3" do %%>
      <%%= link_to @resource.next, rel: "next", class: class_names(link_css, "items-end") do %%>
        <%%= tag.span "Next", class: label_css %%>

        <%%= tag.strong @resource.next.title, class: text_css %%>
      <%% end %%>
    <%% end if @resource.next %%>
  </ul>
</nav>


RUBY

create_file "app/views/content//articles/_navigation.html.erb", <<~'RUBY', force: true
<%%# locals: (top_level_items: [], sections: []) %%>
<nav id="nav" data-action="scrollTo#instant:mounted" data-target="current-item" class="hidden fixed top-0 bottom-0 right-auto w-(--nav-width) bg-white z-10 overflow-y-auto lg:block [&[open]]:block lg:top-10">
  <ul class="mt-4 px-2 grid gap-y-1 text-base overflow-y-auto md:px-4 lg:px-8 md:text-sm lg:mt-6 [--nav-vertical-spacing:1.25rem]">
    <%% top_level_items.each do |item| %%>
      <li>
        <%%= link_to safe_join([item[:label]]), item[:href], class: class_names("flex items-center gap-x-2 px-(--nav-vertical-spacing) py-2 font-bold text-gray-800 rounded-md group/link", {"bg-gray-100 [&_svg]:shadow-md": item[:current_page?]}) %%>
      </li>
    <%% end %%>

    <%%= render partial: "section", collection: sections, as: :section %%>
  </ul>
</nav>

<button
  data-action="removeAttribute#open"
  data-target="nav"
  class="hidden fixed inset-0 bg-gray-950/30 backdrop-blur-sm z-5 [nav[open]~&]:block lg:hidden"
>
</button>


RUBY

create_file "app/views/content//articles/_section.html.erb", <<~'RUBY', force: true
<%%# locals: (section:, resources: section.resources) %%>
<li class="mt-3">
  <%%= tag.p section.name, class: "px-(--nav-vertical-spacing) font-semibold text-gray-800" %%>

  <ul class="grid gap-y-1 mt-2">
    <%% resources.each do |article| %%>
      <%%= tag.li id: current_page?(article) ? "current-item" : nil do %%>
        <%%= link_to article.title, article, class: class_names("block px-(--nav-vertical-spacing) py-1.5 font-normal text-gray-800/80 rounded-lg transition hover:bg-gray-50", {"bg-gray-50 cursor-default": current_page?(article)}) %%>
      <%% end %%>
    <%% end %%>
  </ul>
</li>


RUBY

create_file "app/views/content//articles/_toggle_button.html.erb", <<~'RUBY', force: true
<%%# locals: (resource: nil, tail_css: "font-semibold text-gray-800") %%>
<div class="sticky top-10 px-2 flex items-center justify-between gap-x-2 w-full py-3 bg-white border-b border-gray-100 z-1 lg:hidden">
  <button data-action="toggleAttribute#open" data-target="nav" class="flex items-center gap-x-2.5 text-sm text-gray-700 truncate">
    <%%# phosphor / regular / list %%>
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" fill="currentColor" class="shrink-0 size-4 text-gray-800"><path d="M224,128a8,8,0,0,1-8,8H40a8,8,0,0,1,0-16H216A8,8,0,0,1,224,128ZM40,72H216a8,8,0,0,0,0-16H40a8,8,0,0,0,0,16ZM216,184H40a8,8,0,0,0,0,16H216a8,8,0,0,0,0-16Z"/></svg>

    <%%= tag.ul class: "flex items-center gap-x-1" do %%>
      <%%= tag.li @resource.article_section.name, class: "text-gray-600" %%>

      <%%# phosphor / regular / caret-right %%>
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" fill="currentColor" class="shrink-0 size-4 text-gray-500"><path d="M181.66,133.66l-80,80a8,8,0,0,1-11.32-11.32L164.69,128,90.34,53.66a8,8,0,0,1,11.32-11.32l80,80A8,8,0,0,1,181.66,133.66Z"/></svg>

      <%%= tag.li @resource.title, class: tail_css %%>
    <%% end if @resource.present? %%>

    <%%= tag.p "Documentation", class: tail_css if @resource.blank? %%>
  </button>
</div>


RUBY

create_file "app/views/content//articles/_top_bar.html.erb", <<~'RUBY', force: true
<nav class="sticky top-0 grid gap-2 items-center w-full h-10 px-2 py-1 bg-white border-b border-gray-100 z-5 isolate lg:grid-cols-[var(--nav-width)_1fr_auto] lg:px-4">
  <%%= link_to root_path, class: "group/icon flex items-center gap-x-2 lg:ml-9.5" do %%>
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" fill="currentColor" class="size-4.5 shrink-0 text-gray-500"><path d="M216,40H40A16,16,0,0,0,24,56V200a16,16,0,0,0,16,16H216a16,16,0,0,0,16-16V56A16,16,0,0,0,216,40Zm0,160H40V56H216V200ZM184,96a8,8,0,0,1-8,8H80a8,8,0,0,1,0-16h96A8,8,0,0,1,184,96Zm0,32a8,8,0,0,1-8,8H80a8,8,0,0,1,0-16h96A8,8,0,0,1,184,128Zm0,32a8,8,0,0,1-8,8H80a8,8,0,0,1,0-16h96A8,8,0,0,1,184,160Z"/></svg>

    <%%= tag.span "Perron", class: "text-sm font-extrabold tracking-tight text-gray-950" %%>
  <%% end %%>
</nav>


RUBY

create_file "app/views/content//articles/index.html.erb", <<~'RUBY', force: true
<article class="mt-4 mx-2 mt:mt-6 lg:mt-5">
  <h1 class="inline-block text-2xl font-bold text-gray-800 tracking-tight sm:text-3xl">
    Documentation
  </h1>

  <p class="mt-2 max-w-prose text-lg text-gray-800">
    Welcome to the documention of our product. Learn the ins- and outs of using it. From a quickstart to every advanced feature.
  </p>

  <ul class="grid grid-cols-6 gap-x-8 gap-y-4 max-w-4xl mt-8">
    <%%= render Content::Data::QuickLinks.all %%>
  </ul>
</article>


RUBY

create_file "app/views/content//articles/show.html.erb", <<~'RUBY', force: true
<article class="my-4 px-2 sm:my-4 lg:mb-7">
  <h1 class="mt-1 text-2xl font-bold text-gray-800 tracking-tight sm:text-3xl">
    <%%= @resource.title %%>
  </h1>

  <div class="grid grid-cols-12 gap-4">
    <div class="col-span-12 mt-4 pb-12 content max-w-prose lg:col-span-9">
      <%%= markdownify @resource.content %%>
    </div>
  </div>

  <%%= render "adjacency" %%>
</article>

RUBY

create_file "app/views/content//quick_links/_quick_link.html.erb", <<~'RUBY', force: true
<%%# locals: (quick_link:) %%>
<li class="col-span-6 sm:col-span-3">
  <%%= link_to quick_link.href, class: "group/link block h-full px-2 py-3 bg-radial-[at_25%%_25%%] from-gray-100 to-white to-75%% border border-white/70 ring ring-offset-0 ring-gray-200 rounded-lg transition hover:ring-gray-300 md:px-3 md:py-4" do %%>
    <%%= tag.h3 quick_link.title, class: "text-sm font-semibold tracking-tight text-gray-900 sm:text-base" %%>

    <%%= tag.p quick_link.description, class: "mt-0.5 text-sm text-gray-700 sm:text-base sm:text-gray-600" %%>
  <%% end %%>
</li>


RUBY

create_file "app/views/layouts/application.html.erb", <<~'RUBY', force: true
<!DOCTYPE html>
<html lang="en">
  <head>
    <%%= meta_tags %%>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">

    <%%= yield :head %%>

    <link rel="icon" href="/icon.png" type="image/png">
    <link rel="icon" href="/icon.svg" type="image/svg+xml">
    <link rel="apple-touch-icon" href="/icon.png">

    <%%= stylesheet_link_tag :app %%>
    <!-- Learn more on https://attractivejs.railsdesigner.com/ -->
    <script defer src="https://cdn.jsdelivr.net/npm/attractivejs@0.12.0"></script>
  </head>
  <body class="selection:bg-gray-300 selection:text-gray-800 antialiased scroll-smooth [--nav-width:18rem]">
    <%%= render "top_bar" %%>

    <main id="main" class="flex flex-row gap-12 w-full [--nav-width:18rem]">
      <%%= render partial: "navigation", locals: { top_level_items: [{label: "Home", href: root_path, current_page?: current_page?(controller: "articles")}], sections: Content::Article.sections } %%>

     <div class="relative grow flex-col w-full mx-auto lg:ml-(--nav-width) lg:px-6">
       <%%= render partial: "toggle_button", locals: { resource: @resource } %%>

        <%%= yield %%>
      </div>
    </main>
  </body>
</html>


RUBY

create_file "config/routes.rb", <<~'RUBY', force: true
Rails.application.routes.draw do
  resources :articles, module: :content, only: %%w[show]

  root to: "content/articles#index"
end


RUBY
end
