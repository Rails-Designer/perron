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

@layer base {
  a:not([class]) {
    @apply underline;

    &:hover {
      @apply no-underline;
    }
  }
}

@layer component {
  .content {
    @apply [&_*:not(h1,h2,h3,h4,h5,h6)+*:not(pre,code,li,blockquote>p,svg),blockquote+pre]:mt-5;
    @apply [&_h1+p,&_h2+p,&_h3+p,&_h4+p,&_h5+p,&_h6+p]:mt-1.5;
    @apply [&>p,&_li]:text-base [&>p,&_li]:md:text-lg [&>p]:text-gray-950;

    @apply [&_*+h2,&_*+h3]:mt-8;
    @apply [&_h2]:font-bold [&_h2]:text-2xl [&_h2]:text-gray-800;
    @apply [&_h3]:font-semibold [&_h3]:text-xl [&_h3]:text-gray-800;
    @apply [&_h4]:font-semibold [&_h4]:text-lg [&_h4]:text-gray-800;

    @apply [&_ul,&_ol]:mt-2 [&_ul]:list-disc [&_ul,&_ol]:list-outside [&_ul,&_ol]:ml-4.5;
    @apply [&_ol]:list-decimal;

    @apply [&_pre]:mt-1.25 [&_pre]:px-1.5 [&_pre]:py-2 [&_pre]:sm:px-3 [&_pre]:sm:py-4 [&_pre]:rounded-md [&_pre]:overflow-auto;
    @apply [&_code]:p-0.5 [&_code]:text-[0.8em] [&_code]:font-medium [&_code]:bg-gray-200/70 [&_code]:rounded-sm;
    @apply [&_pre>code]:text-base [&_pre>code]:font-normal [&_pre>code]:text-gray-700 [&_pre>code]:bg-transparent;

    @apply [&_strong]:font-semibold;

    @apply [&_table]:w-full [&_table]:text-left [&_table]:text-base;
    @apply [&_thead]:border-b [&_thead]:border-gray-200;
    @apply [&_th]:px-2 [&_th]:py-1.5 [&_th]:font-semibold [&_th]:text-gray-800;
    @apply [&_tbody_tr]:border-b [&_tbody_tr]:border-gray-100;
    @apply [&_tbody_tr:last-child]:border-0;
    @apply [&_td]:px-2 [&_td]:py-1.5 [&_td]:text-base [&_td]:sm:text-lg [&_td]:text-gray-800;

    @apply marker:text-gray-500;
  }
}


RUBY

create_file "app/content/data/social_links.yml", <<~'RUBY', force: true
- name: Social X
  url: "https://example.com"
- name: Social Y
  url: "https://example.com"
- name: Social Z
  url: "https://example.com"


RUBY

create_file "app/content/pages//about.erb", <<~'RUBY', force: true
---
nav_label: About
title: About me
description: description
---

<article class="max-w-4xl mx-auto mt-16 px-2">
  <h1 class="text-2xl font-sans font-bold text-gray-700 md:text-balance md:text-4xl md:tracking-tight">
    <%%= @resource.title %%>
  </h1>

  <p class="mt-5 text-lg text-gray-800 md:text-2xl max-w-prose md:mt-8">
    Minim ad et nostrud. Nisi culpa adipisicing nulla cupidatat eu adipisicing non occaecat tempor pariatur sint eiusmod ut pariatur. Et nisi occaecat id tempor qui ex reprehenderit ullamco ullamco duis ad. Amet aliquip velit non pariatur esse aliquip magna. Cillum Lorem proident dolor voluptate fugiat mollit mollit id fugiat dolor minim.
  </p>

  <p class="mt-5 text-lg text-gray-800 md:text-2xl max-w-prose md:mt-8">
    Est esse ipsum mollit ad sit esse duis commodo voluptate irure commodo proident dolor. Cupidatat officia excepteur Lorem non id ullamco. Pariatur sunt dolore eiusmod Lorem sunt deserunt excepteur veniam occaecat in magna. Exercitation mollit enim eu consectetur adipisicing labore adipisicing eu.
  </p>
</article>


RUBY

create_file "app/content/pages//contact.erb", <<~'RUBY', force: true
---
nav_label: Contact
title: Contact
description: description
---

<article class="max-w-4xl mx-auto mt-16 px-2">
  <h1 class="text-2xl font-sans font-bold text-gray-700 md:text-balance md:text-4xl md:tracking-tight">
    <%%= @resource.title %%>
  </h1>

  <p class="mt-5 text-lg text-gray-800 md:text-2xl max-w-prose md:mt-8">
    Want to say “hi”? Have a question? <%%= mail_to "me@example.com", "Send me an email" %%> or find me on a platform below.
  </p>

  <ul class="flex flex-col gap-y-1 mt-5 text-lg">
    <%%= render Content::Data::SocialLinks.all %%>
  </ul>
</article>


RUBY

create_file "app/content/pages//now.erb", <<~'RUBY', force: true
---
nav_label: Now
title: What am I doing now?
description: description
updated_at: 2025-01-01T00:00:00Z
doing:
  - Mastering Blender 3D's geometry nodes system
  - Writing a book on sustainable design practices
  - Learning Thai language (currently at B1 level)
  - Building a hydroponic garden in my apartment
---

<article class="max-w-4xl mx-auto mt-16 px-2">
  <h1 class="text-2xl font-sans font-bold text-gray-700 md:text-balance md:text-4xl md:tracking-tight">
    <%%= @resource.title %%>
  </h1>

  <p class="mt-5 text-lg text-gray-800 md:text-2xl max-w-prose md:mt-8">
    These things are keeping me busy day-to-day. Last updated on <%%= tag.time @resource.metadata.updated_at.strftime("%%Y/%%m/%%d"), datetime: @resource.metadata.updated_at %%>
  </p>

  <ul class="flex flex-col gap-y-2 mt-5 text-lg list-inside">
    <%%= safe_join @resource.metadata.doing.map { tag.li it, class: "list-disc" } %%>
  </ul>
</article>



RUBY

create_file "app/content/pages//root.erb", <<~'RUBY', force: true
---
title: Welcome to my blog
description: Welcome to this blog of mine. Here I write about things, stuff and everything.
---

<div class="max-w-4xl mx-auto mt-16 px-2 sm:mt-32">
  <p class="text-2xl font-normal text-gray-700 md:text-balance md:text-3xl md:tracking-tight">
    Hi, my name is Rails Designer. I help companies make their Rails app prettier, more maintainable and a joy to use.
  </p>

  <div class="grid grid-cols-6 gap-5 mt-8 text-lg text-gray-900 md:mt-16 md:gap-12">
    <p class="col-span-6 sm:col-span-3 first-letter:text-8xl first-letter:float-left first-letter:mr-2 first-letter:mt-2.5">
      Minim ad et nostrud. Nisi culpa adipisicing nulla cupidatat eu adipisicing non occaecat tempor pariatur sint eiusmod ut pariatur. Et nisi occaecat id tempor qui ex reprehenderit ullamco ullamco duis ad. Amet aliquip velit non pariatur esse aliquip magna. Cillum Lorem proident dolor voluptate fugiat mollit mollit id fugiat dolor minim.
    </p>

    <p class="col-span-6 sm:col-span-3">
      Est esse ipsum mollit ad sit esse duis commodo voluptate irure commodo proident dolor. Cupidatat officia excepteur Lorem non id ullamco. Pariatur sunt dolore eiusmod Lorem sunt deserunt excepteur veniam occaecat in magna. Exercitation mollit enim eu consectetur adipisicing labore adipisicing eu.
    </p>
  </div>

  <%%= render partial: "shared/latest_post" %%>
</div>


RUBY

create_file "app/content/posts//2025-10-01-my-first-post.md", <<~'RUBY', force: true
---
title: My first post on Perron
description: Hello world, from Perron!
---

Irure nulla pariatur anim mollit labore ad eu amet. Magna ut deserunt officia sunt occaecat reprehenderit veniam voluptate reprehenderit. Sit aliqua cupidatat ea labore consectetur anim amet laborum velit proident pariatur enim. Non mollit laborum dolor. Proident amet cupidatat proident nulla officia duis deserunt mollit dolor sit anim sint consectetur. Proident aliquip eiusmod laborum pariatur proident cupidatat velit minim amet occaecat nisi velit officia sint.

Aute fugiat aliquip eiusmod ullamco eu velit ad ad voluptate sunt. Mollit esse magna duis proident consectetur quis duis ipsum eu irure quis aute in veniam. Eu ea tempor nulla ea duis ad incididunt. Non ullamco et nostrud esse ipsum occaecat. Adipisicing sit amet ut sunt occaecat ad Lorem qui cillum. Labore laboris cillum laboris quis non commodo fugiat sit. Adipisicing officia elit sunt ullamco.

Laboris exercitation elit cupidatat aliqua excepteur ad laboris ipsum dolore est amet elit velit. Excepteur minim fugiat sit. Amet tempor voluptate fugiat. Veniam minim exercitation laboris excepteur qui ullamco mollit dolor. Lorem minim Lorem pariatur eiusmod quis nulla id magna ullamco laboris ipsum consectetur.

Dolor sunt eu mollit magna et id dolor exercitation. Ut voluptate veniam ullamco occaecat minim. Esse Lorem nostrud deserunt exercitation tempor officia amet. Commodo ullamco eiusmod culpa eiusmod velit.

Cillum non cupidatat minim sint adipisicing. Excepteur voluptate ullamco commodo eiusmod nulla aute cillum do sunt sunt non laborum est. Voluptate sint quis duis id aute excepteur sunt dolor minim do fugiat ea id irure consequat. Mollit proident exercitation anim duis velit tempor pariatur et deserunt reprehenderit sunt mollit elit exercitation ea. Amet et fugiat est consectetur enim. Amet incididunt deserunt amet dolor ex nostrud nostrud ex. Nulla eu anim id fugiat qui sit id aliquip veniam cupidatat nostrud velit elit.

Lorem non sunt sit proident nostrud veniam cupidatat voluptate ex aliqua Lorem minim eiusmod sit. Qui velit exercitation deserunt enim reprehenderit ad. Proident officia duis in velit aliqua voluptate in non cupidatat et quis nulla. Pariatur nostrud ea deserunt proident pariatur velit non occaecat ad quis est. Magna proident ex aliqua dolor esse Lorem labore ex irure do sunt aliquip. Sunt reprehenderit labore deserunt tempor. Cupidatat quis labore aute tempor consequat est ipsum in aliquip laborum. Cillum est dolor dolor aute nisi in laborum laboris.


RUBY

create_file "app/controllers/content//pages_controller.rb", <<~'RUBY', force: true
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


RUBY

create_file "app/controllers/content//posts_controller.rb", <<~'RUBY', force: true
class Content::PostsController < ApplicationController
  def index
    @resources = Content::Post.all
  end

  def show
    @resource = Content::Post.find(params[:id])
  end
end


RUBY

create_file "app/models/content//page.rb", <<~'RUBY', force: true
class Content::Page < Perron::Resource
  def inline(layout: "application", **options)
    { html: content, layout: layout }.merge(options)
  end

  delegate :title, :nav_label, to: :metadata
end


RUBY

create_file "app/models/content//post.rb", <<~'RUBY', force: true
class Content::Post < Perron::Resource
  configure do |config|
    config.feeds.rss.enabled = true
    # config.feeds.rss.title = "My RSS feed" # defaults to configured site_name
    # config.feeds.rss.description = "My RSS feed description" # defaults to configured site_description
  end

  delegate :title, to: :metadata
end


RUBY

create_file "app/views/content/pages/show.html.erb", <<~'RUBY', force: true
<article>
  <h1>
    <%%= @resource.filename %%>
  </h1>

  <%%= @resource.content %%>
</article>

RUBY

create_file "app/views/content//posts/_post.html.erb", <<~'RUBY', force: true
<%%# locals: (post:) %%>
<li>
  <%%= link_to post, class: "flex items-center justify-between text-lg text-gray-800 underline hover:text-gray-500 hover:no-underline" do %%>
    <%%= tag.span post.title %%>

    <%%= tag.time post.published_at.strftime("%%Y/%%m/%%d"), datetime: post.published_at, class: "text-base" %%>
  <%% end %%>
</li>


RUBY

create_file "app/views/content//posts/index.html.erb", <<~'RUBY', force: true
<div class="max-w-4xl mx-auto mt-8 px-2 md:mt-16">
  <h1 class="text-2xl font-sans font-bold text-gray-700 md:text-balance md:text-4xl md:tracking-tight">
    My writings
  </h1>

  <ul class="grid mt-8 gap-y-2">
    <%%= render @resources %%>
  </ul>
</div>


RUBY

create_file "app/views/content//posts/show.html.erb", <<~'RUBY', force: true
<article class="max-w-4xl mx-auto mt-8 px-2 md:mt-16">
  <%%= link_to "← View all my writings", posts_path, class: "text-sm font-sans font-normal text-gray-500 transition hover:text-gray-800" %%>

  <h1 class="mt-2 text-2xl font-sans font-bold text-gray-700 md:text-balance md:text-4xl md:tracking-tight">
    <%%= @resource.title %%>
  </h1>

  <p class="mt-6 flex items-center gap-x-4 empty:hidden">
    <%%= tag.span "Published at #{@resource.published_at.strftime("%%Y/%%m/%%d")}", class: "text-sm text-gray-500" if @resource.published_at.present? %%>

    <%%= tag.span "Scheduled", class: "inline-block px-2 py-0.5 font-sans text-xs font-medium text-orange-600 bg-orange-100 rounded-md" if @resource.scheduled? %%>
  </p>

  <div class="content my-5 md:my-8">
    <%%= markdownify @resource.content %%>
  </div>
</article>

<section id="comments" class="mt-8 max-w-4xl mx-auto">
  <chirp-form form-id="ADD_YOUR_CHIRP_FORM_ID_HERE" button-text="Add comment" class="grid gap-y-4 p-2">
    <header slot="header">
      <h2 class="text-lg font-bold tracking-tight text-slate-800 md:text-xl">
        Comments
      </h2>

      <p class="mt-0.5 text-base text-slate-600">
        What do you think? Got ideas or suggestions? Let me know below.
      </p>
    </header>
  </chirp-form>

  <p class="mt-2 px-2 text-xs text-slate-500">
    Comments are powered by <a href="https://chirpform.com/?ref=<%%= Rails.application.name %%>" rel="nofollow">Chirp Form</a></p>
  </p>

  <chirp-feed form-id="ADD_YOUR_CHIRP_FORM_ID_HERE" filter-url="current" class="grid gap-y-4 mt-4 py-4 border-t border-slate-100">
    <template type="style">
      .content + .content {
        padding-block-start: .875rem;
        border-top: 1px solid #f1f5f9;
      }

      .header {
        display: flex;
        justify-content: space-between;
      }

      .name {
        font-size: .875rem;
        font-weight: 500;
        color: #64748b;
      }

      .time {
        font-size: .75rem;
        color: #94a3b8
      }

      .comment {
        margin: 0;
        font-size: 1rem;
        color: #0f172a
      }
    </template>

    <template type="submission">
      <article class="content">
        <header class="header">
          <strong class="name">{{name}}</strong>

          <time class="time">{{created_at}}</time>
        </header>

        <p class="comment">{{comment}}</p>
      </article>
    </template>
  </chirp-feed>
</section>


RUBY

create_file "app/views/content//social_links/_social_link.html.erb", <<~'RUBY', force: true
<%%# locals: (social_link:) %%>
<li>
  <%%= link_to social_link.name, social_link.url, target: "_blank", class: "underline text-gray-700 hover:no-underline" %%>
</li>


RUBY

create_file "app/views/layouts/application.html.erb", <<~'RUBY', force: true
<!DOCTYPE html>
<html>
  <head>
    <%%= meta_tags %%>
    <meta name="viewport" content="width=device-width,initial-scale=1">

    <%%= feeds only: %%w[posts] %%>
    <%%= yield :head %%>

    <%%= stylesheet_link_tag :app %%>
    <script src="https://embed.chirpform.com/latest/chirpform.umd.js" defer></script>
  </head>

  <body class="font-serif antialiased">
    <%%= render partial: "shared/navigation", locals: { items: Content::Page.all.select(&:nav_label) } %%>

    <%%= yield %%>
  </body>
</html>


RUBY

create_file "app/views/shared//_latest_post.html.erb", <<~'RUBY', force: true
<%%# locals: (latest_post: Content::Post.last) %%>

<dl class="flex flex-col md:items-end gap-x-4 mt-8 font-sans text-base text-gray-900 md:flex-row md:mt-16 md:text-sm">
  <dt class="font-semibold tracking-tight text-gray-800">
    <hr class="h-px my-1 border-gray-400 md:border-gray-700">

    My last writing
  </dt>

  <dd>
    <%%= link_to latest_post.title, latest_post, class: "text-gray-500 transition hover:text-gray-800" %%>
  </dd>
</dl>


RUBY

create_file "app/views/shared//_navigation.html.erb", <<~'RUBY', force: true
<%%# locals: (items: []) %%>
<nav class="sticky top-0 flex items-center justify-between px-2 py-3 max-w-4xl mx-auto font-sans bg-white">
  <%%= link_to "", root_path, aria: {label: "Go to the homepage"}, class: "block w-14 h-3 bg-gray-800 rounded-xs transition hover:bg-gray-500" %%>

  <ul class="flex items-center gap-x-4 sm:gap-x-6">
    <%%= render partial: "shared/navigation/item", collection: items %%>
  </ul>
</nav>


RUBY

create_file "app/views/shared/navigation/_item.html.erb", <<~'RUBY', force: true
<li>
  <%%= link_to item.nav_label, item, class: class_names("block px-1 py-2 text-sm font-medium tracking-tight text-gray-800 border-b-2 transparent sm:text-base hover:border-gray-200", {"border-transparent": !current_page?(item), "border-gray-800 hover:border-gray-800": current_page?(item)}) %%>
</li>


RUBY

create_file "app/content/posts/%%Y-%%m-%%d-title.md.tt", <<~'MARKDOWN', force: true
---
title: <%%= @title %%>
published_at: <%%= Time.current %%>
description: TODO
---
MARKDOWN
end
