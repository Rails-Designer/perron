gem "perron" unless File.read("Gemfile").include?("perron")
gem "tailwindcss-rails" unless File.read("Gemfile").include?("tailwindcss-rails")

after_bundle do
  unless File.exist?("config/initializers/perron.rb")
    rails_command "perron:install"
  end

  unless File.exist?("app/assets/tailwind/application.css")
    rails_command "tailwindcss:install"
  end

  create_file "app/assets/tailwind//application.css", <<~'RUBY', force: true
@import "tailwindcss";

@layer utilities {
  .animate-zoom-in { animation: zoom-in 1.1s ease forwards; }
  .animate-fade-up { animation: fade-up 1s ease forwards; }
  .animate-fade-down { animation: fade-down 1s ease forwards; }

  .noise::after {
    content: "";
    position: absolute;
    inset: 0;
    opacity: .15;
    background-image: url("data:image/svg+xml,%%3Csvg viewBox='0 0 300 300' xmlns='http://www.w3.org/2000/svg'%%3E%%3Cfilter id='noise'%%3E%%3CfeTurbulence type='fractalNoise' baseFrequency='1.2' numOctaves='3' stitchTiles='stitch'/%%3E%%3C/filter%%3E%%3Crect width='100%%25' height='100%%25' filter='url(%%23noise)'/%%3E%%3C/svg%%3E");
    pointer-events: none;
    mask-image: linear-gradient(to bottom, black 0%%, black 40%%, transparent 100%%);
  }

  @keyframes zoom-in {
    0%% {
      opacity: 0;
      transform: scale(.97);
      filter: blur(5px);
    }

    100%% {
      opacity: 1;
      transform: scale(1);
      filter: blur(0);
    }
  }

  @keyframes fade-up {
    0%% {
      opacity: 0;
      transform: translateY(2.5rem);
    }

    100%% {
      opacity: 1;
      transform: translateY(0);
    }
  }

  @keyframes fade-down {
    0%% {
      opacity: 0;
      transform: translateY(-2.5rem);
    }

    100%% {
      opacity: 1;
      transform: translateY(0);
    }
  }
}


RUBY

create_file "app/content/data/features.yml", <<~'RUBY', force: true
- name: Automate The Tedious
  description: Transform complex tasks into one-click wonders. Let the robots handle the boring stuff.

- name: Stay Fresh Without Effort
  description: Set it and forget it. Real-time updates keep everything current while you focus on what matters.

- name: Make It Yours
  description: Personalization that goes beyond color schemes. Your brand, your rules, your way.

- name: Highlight What Matters
  description: Draw attention to what's important. Guide your audience with crystal-clear visual communication.

- name: Own Your Presence
  description: Your space, your domain. Present a professional image that's completely yours.

- name: Learn From The Journey
  description: Track progress, spot trends and celebrate how far you've come with comprehensive historical insights.


RUBY

create_file "app/content/pages//root.erb", <<~'RUBY', force: true
---
title: Simplicity meets power
dscription: Because great things happen when you have the right tools to bring your vision to life.
---

<div class="flex flex-col w-full bg-gradient-to-b from-blue-950 via-blue-500 to-white noise">
  <section class="w-full max-w-3xl mx-auto pt-8 px-3 pb-32 md:pt-48">
    <h1 class="text-4xl font-extrabold tracking-tight text-center text-balance text-white motion-safe:animate-zoom-in md:text-6xl">
      Simplicity meets power
    </h1>

    <p class="max-w-2xl mx-auto mt-4 text-2xl font-extralight text-center text-cyan-100 motion-safe:animate-zoom-in delay-200 md:text-3xl md:mt-8">
      Because great things happen when you have the right tools to bring your vision to life. No complexity, just clarity.
    </p>
  </section>

  <img src="https://placehold.co/1280x720/dbeafe/172554?text=Screenshot" alt="Preview of my great new SaaS" class="w-full max-w-5xl mx-auto rounded-2xl border-6 border-white/40 ring ring-offset-0 ring-white/60 motion-safe:animate-zoom-in delay-300" />
</div>

<%%= render partial: "shared/features", locals: { features: Content::Data::Features.all } %%>

<%%= render partial: "shared/email_form" %%>


RUBY

create_file "app/content/pages//success.erb", <<~'RUBY', force: true
---
title: You are on the list
---

<div class="relative flex flex-col w-full md:h-[80dvh] bg-gradient-to-b from-blue-950 via-blue-500 to-white noise">
  <section class="w-full max-w-3xl mx-auto pt-8 px-3 pb-32 md:pt-48">
    <h1 class="text-4xl font-extrabold tracking-tight text-center text-balance text-white animate-zoom-in md:text-6xl">
      Awesome. You are on the list!
    </h1>

    <p class="max-w-2xl mx-auto mt-4 text-2xl font-extralight text-center text-cyan-100 animate-zoom-in delay-200 md:text-3xl md:mt-8">
      Thanks for being interested in my new SaaS. You have been added to the list and I will be in touch soon.
    </p>
  </section>
</div>


RUBY

create_file "app/controllers/content//pages_controller.rb", <<~'RUBY', force: true
class Content::PagesController < ApplicationController
  def root
    @resource = Content::Page.root

    render :show
  end

  def show
    @resource = Content::Page.find(params[:id])
  end
end


RUBY

create_file "app/models/content//page.rb", <<~'RUBY', force: true
class Content::Page < Perron::Resource
end

RUBY

create_file "app/views/content//pages/show.html.erb", <<~'RUBY', force: true
<%%= @resource.content %%>


RUBY

create_file "app/views/layouts/application.html.erb", <<~'RUBY', force: true
<!DOCTYPE html>
<html>
  <head>
    <%%= meta_tags %%>
    <meta name="viewport" content="width=device-width,initial-scale=1">

    <%%= yield :head %%>

    <link rel="icon" href="/icon.png" type="image/png">
    <link rel="icon" href="/icon.svg" type="image/svg+xml">
    <link rel="apple-touch-icon" href="/icon.png">

    <%%= stylesheet_link_tag :app %%>
  </head>
  <body class="antialiased">
    <%%= yield %%>
  </body>
</html>


RUBY

create_file "app/views/shared//_email_form.html.erb", <<~'RUBY', force: true
<div class="fixed inset-x-0 bottom-4 z-10 flex items-center justify-center animate-fade-up md:bottom-12">
  <div class="w-full max-w-2xl px-3 lg:px-10">
    <div class="-mx-1.5 w-[calc(100%%+0.625rem)] rounded-2xl border border-gray-200/60 bg-white/60 p-1.5 backdrop-blur">
      <form action="<%%= page_path("success") %%>" name="email" class="relative flex items-center w-full p-2 overflow-hidden bg-white shadow-2xl rounded-xl outline outline-1 outline-gray-300/60">
        <div class="w-full">
          <label for="email" class="sr-only">Email</label>

          <input type="email" name="email" id="email" required placeholder="you@company.com" class="w-full px-2 text-sm font-light tracking-wide border-0 text-gray-800 placeholder:text-gray-400 focus:ring-0 focus-visible:outline-none">
        </div>

        <input type="submit" value="Subscribe" class="px-3.5 py-2 text-xs font-medium text-white cursor-pointer flex-shrink-0 bg-blue-600 rounded-md transition-colors duration-200 hover:bg-blue-500">
      </form>
    </div>
  </div>
</div>


RUBY

create_file "app/views/shared//_features.html.erb", <<~'RUBY', force: true
<%%# locals: (features:, container_css: "relative px-3 py-16 md:py-24 lg:py-40") -%%>
<%%= tag.section class: container_css do %%>
  <ul class="max-w-6xl mx-auto grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-8 md:gap-6 lg:gap-10">
    <%% features.each do |feature| %%>
      <li class="relative">
        <span class="absolute w-16 h-0.25 bg-blue-200 rounded-sm"></span>

        <div class="mt-3">
          <h3 class="inline font-medium tracking-tight text-gray-950 after:content-['—']">
            <%%= feature.name %%>
          </h3>

          <p class="inline ml-0.5 font-light text-gray-800">
            <%%= feature.description %%>
          </p>
        </div>
      </li>
    <%% end %%>
  </ul>
<%% end %%>


RUBY

create_file "config/routes.rb", <<~'RUBY', force: true
Rails.application.routes.draw do
  root to: "content/pages#root"
  resources :pages, module: :content, only: %%w[show]
end

RUBY
end
