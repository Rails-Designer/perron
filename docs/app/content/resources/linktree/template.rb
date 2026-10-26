gem "importmap-rails" unless File.read("Gemfile").include?("importmap")
gem "perron" unless File.read("Gemfile").include?("perron")
gem "tailwindcss-rails" unless File.read("Gemfile").include?("tailwindcss-rails")

after_bundle do
  unless File.exist?("config/importmap.rb")
    rails_command "importmap:install"
  end

  unless File.exist?("config/initializers/perron.rb")
    rails_command "perron:install"
  end

  unless File.exist?("app/assets/tailwind/application.css")
    rails_command "tailwindcss:install"
  end


create_file "app/assets/tailwind//application.css", <<~'RUBY', force: true
@import "tailwindcss";
RUBY

create_file "app/content/data/links.yml", <<~'RUBY', force: true
- title: "Portfolio"
  url: "https://example.com"
- title: "Blog"
  url: "https://blog.example.com"
- title: "Shop"
  url: "https://shop.example.com"

RUBY

create_file "app/content/data/platforms.yml", <<~'RUBY', force: true
- url: "https://twitter.com/username"
- url: "https://github.com/username"
- url: "https://linkedin.com/in/username"

RUBY

create_file "app/content/pages//root.erb", <<~'RUBY', force: true
---
title: Cam VanOyster — Merging the greens with the emeralds.
---

<main class="max-w-md mx-auto px-6 py-12">
  <section>
    <img src="https://unsplash.com/photos/XHVpWcr5grQ/download?force=true&w=640" alt="" class="size-20 rounded-full mx-auto" />

    <h1 class="mt-4 text-base text-center text-white font-medium">
      Cam VanOyster
    </h1>

    <p class="mt-0.5 text-sm text-center font-light text-white/70">
      Merging the greens with the emeralds.
    </p>
  </section>

  <ul class="grid gap-y-3 mt-8">
    <%% Content::Data::Links.all.each do |link| %%>
      <li>
        <a href="<%%= link.url %%>" target="_blank" rel="noopener noreferrer" class="block w-full px-2 py-2 font-medium text-gray-800 text-center bg-white rounded-full transition hover:bg-white/70">
          <%%= link.title %%>
        </a>
      </li>
    <%% end %%>
  </ul>

  <ul class="mt-8 flex items-center justify-center gap-3">
    <%% Content::Data::Platforms.all.each do |platform| %%>
      <li>
        <a href="<%%= platform.url %%>" target="_blank" rel="noopener noreferrer" class="block p-0.5 size-8 text-gray-800 bg-white rounded-md hover:bg-white/70">
          <link-icon url="<%%= platform.url %%>" class="size-full"></link-icon>
        </a>
      </li>
    <%% end %%>
  </ul>
</main>

RUBY

create_file "app/controllers/content//pages_controller.rb", <<~'RUBY', force: true
class Content::PagesController < ApplicationController
  def root
    @resource = Content::Page.root

    render @resource.inline
  end
end

RUBY

create_file "app/javascript//application.js", <<~'RUBY', force: true
import "components/link-icon"

RUBY

create_file "app/javascript//components/link-icon.js", <<~'RUBY', force: true
class LinkIcon extends HTMLElement {
  static get observedAttributes() {
    return ["url"];
  }

  constructor() {
    super();

    this.attachShadow({ mode: "open" });
  }

  connectedCallback() {
    this.#render();
  }

  get url() {
    return this.#url;
  }

  set url(value) {
    this.setAttribute("url", value);
  }

  // private

  attributeChangedCallback(name, oldValue, newValue) {
    if (name === "url" && oldValue !== newValue) {
      this.#render();
    }
  }

  #url = "";
  #iconType = "default";

  #platformPatterns = {
    twitter: /twitter\.com|x\.com/i,
    facebook: /facebook\.com|fb\.com/i,
    instagram: /instagram\.com/i,
    linkedin: /linkedin\.com/i,
    github: /github\.com/i,
    youtube: /youtube\.com|youtu\.be/i,
    tiktok: /tiktok\.com/i,
    reddit: /reddit\.com/i,
    pinterest: /pinterest\.com/i,
    snapchat: /snapchat\.com/i,
    discord: /discord\.com|discord\.gg/i,
    medium: /medium\.com/i,
    stackoverflow: /stackoverflow\.com/i,
    dribbble: /dribbble\.com/i,
    behance: /behance\.net/i,
    whatsapp: /whatsapp\.com|wa\.me/i,
    telegram: /telegram\.org|t\.me/i,
    slack: /slack\.com/i
  };

  // all icons from https://phosphoricons.com/
  #icons = {
    default: "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 256 256' fill='currentColor'><path d='M165.66,90.34a8,8,0,0,1,0,11.32l-64,64a8,8,0,0,1-11.32-11.32l64-64A8,8,0,0,1,165.66,90.34ZM215.6,40.4a56,56,0,0,0-79.2,0L106.34,70.45a8,8,0,0,0,11.32,11.32l30.06-30a40,40,0,0,1,56.57,56.56l-30.07,30.06a8,8,0,0,0,11.31,11.32L215.6,119.6a56,56,0,0,0,0-79.2ZM138.34,174.22l-30.06,30.06a40,40,0,1,1-56.56-56.57l30.05-30.05a8,8,0,0,0-11.32-11.32L40.4,136.4a56,56,0,0,0,79.2,79.2l30.06-30.07a8,8,0,0,0-11.32-11.31Z'/></svg>",

    twitter: "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 256 256' fill='currentColor'><path d='M247.39,68.94A8,8,0,0,0,240,64H209.57A48.66,48.66,0,0,0,168.1,40a46.91,46.91,0,0,0-33.75,13.7A47.9,47.9,0,0,0,120,88v6.09C79.74,83.47,46.81,50.72,46.46,50.37a8,8,0,0,0-13.65,4.92c-4.31,47.79,9.57,79.77,22,98.18a110.93,110.93,0,0,0,21.88,24.2c-15.23,17.53-39.21,26.74-39.47,26.84a8,8,0,0,0-3.85,11.93c.75,1.12,3.75,5.05,11.08,8.72C53.51,229.7,65.48,232,80,232c70.67,0,129.72-54.42,135.75-124.44l29.91-29.9A8,8,0,0,0,247.39,68.94Zm-45,29.41a8,8,0,0,0-2.32,5.14C196,166.58,143.28,216,80,216c-10.56,0-18-1.4-23.22-3.08,11.51-6.25,27.56-17,37.88-32.48A8,8,0,0,0,92,169.08c-.47-.27-43.91-26.34-44-96,16,13,45.25,33.17,78.67,38.79A8,8,0,0,0,136,104V88a32,32,0,0,1,9.6-22.92A30.94,30.94,0,0,1,167.9,56c12.66.16,24.49,7.88,29.44,19.21A8,8,0,0,0,204.67,80h16Z'/></svg>",
    facebook: "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 256 256' fill='currentColor'><path d='M128,24A104,104,0,1,0,232,128,104.11,104.11,0,0,0,128,24Zm8,191.63V152h24a8,8,0,0,0,0-16H136V112a16,16,0,0,1,16-16h16a8,8,0,0,0,0-16H152a32,32,0,0,0-32,32v24H96a8,8,0,0,0,0,16h24v63.63a88,88,0,1,1,16,0Z'/></svg>",
    instagram: "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 256 256' fill='currentColor'><path d='M128,80a48,48,0,1,0,48,48A48.05,48.05,0,0,0,128,80Zm0,80a32,32,0,1,1,32-32A32,32,0,0,1,128,160ZM176,24H80A56.06,56.06,0,0,0,24,80v96a56.06,56.06,0,0,0,56,56h96a56.06,56.06,0,0,0,56-56V80A56.06,56.06,0,0,0,176,24Zm40,152a40,40,0,0,1-40,40H80a40,40,0,0,1-40-40V80A40,40,0,0,1,80,40h96a40,40,0,0,1,40,40ZM192,76a12,12,0,1,1-12-12A12,12,0,0,1,192,76Z'/></svg>",
    linkedin: "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 256 256' fill='currentColor'><path d='M216,24H40A16,16,0,0,0,24,40V216a16,16,0,0,0,16,16H216a16,16,0,0,0,16-16V40A16,16,0,0,0,216,24Zm0,192H40V40H216V216ZM96,112v64a8,8,0,0,1-16,0V112a8,8,0,0,1,16,0Zm88,28v36a8,8,0,0,1-16,0V140a20,20,0,0,0-40,0v36a8,8,0,0,1-16,0V112a8,8,0,0,1,15.79-1.78A36,36,0,0,1,184,140ZM100,84A12,12,0,1,1,88,72,12,12,0,0,1,100,84Z'/></svg>",
    github: "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 256 256' fill='currentColor'><path d='M208.31,75.68A59.78,59.78,0,0,0,202.93,28,8,8,0,0,0,196,24a59.75,59.75,0,0,0-48,24H124A59.75,59.75,0,0,0,76,24a8,8,0,0,0-6.93,4,59.78,59.78,0,0,0-5.38,47.68A58.14,58.14,0,0,0,56,104v8a56.06,56.06,0,0,0,48.44,55.47A39.8,39.8,0,0,0,96,192v8H72a24,24,0,0,1-24-24A40,40,0,0,0,8,136a8,8,0,0,0,0,16,24,24,0,0,1,24,24,40,40,0,0,0,40,40H96v16a8,8,0,0,0,16,0V192a24,24,0,0,1,48,0v40a8,8,0,0,0,16,0V192a39.8,39.8,0,0,0-8.44-24.53A56.06,56.06,0,0,0,216,112v-8A58.14,58.14,0,0,0,208.31,75.68ZM200,112a40,40,0,0,1-40,40H112a40,40,0,0,1-40-40v-8a41.74,41.74,0,0,1,6.9-22.48A8,8,0,0,0,80,73.83a43.81,43.81,0,0,1,.79-33.58,43.88,43.88,0,0,1,32.32,20.06A8,8,0,0,0,119.82,64h32.35a8,8,0,0,0,6.74-3.69,43.87,43.87,0,0,1,32.32-20.06A43.81,43.81,0,0,1,192,73.83a8.09,8.09,0,0,0,1,7.65A41.72,41.72,0,0,1,200,104Z'/></svg>",
    youtube: "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 256 256' fill='currentColor'><path d='M164.44,121.34l-48-32A8,8,0,0,0,104,96v64a8,8,0,0,0,12.44,6.66l48-32a8,8,0,0,0,0-13.32ZM120,145.05V111l25.58,17ZM234.33,69.52a24,24,0,0,0-14.49-16.4C185.56,39.88,131,40,128,40s-57.56-.12-91.84,13.12a24,24,0,0,0-14.49,16.4C19.08,79.5,16,97.74,16,128s3.08,48.5,5.67,58.48a24,24,0,0,0,14.49,16.41C69,215.56,120.4,216,127.34,216h1.32c6.94,0,58.37-.44,91.18-13.11a24,24,0,0,0,14.49-16.41c2.59-10,5.67-28.22,5.67-58.48S236.92,79.5,234.33,69.52Zm-15.49,113a8,8,0,0,1-4.77,5.49c-31.65,12.22-85.48,12-86,12H128c-.54,0-54.33.2-86-12a8,8,0,0,1-4.77-5.49C34.8,173.39,32,156.57,32,128s2.8-45.39,5.16-54.47A8,8,0,0,1,41.93,68c30.52-11.79,81.66-12,85.85-12h.27c.54,0,54.38-.18,86,12a8,8,0,0,1,4.77,5.49C221.2,82.61,224,99.43,224,128S221.2,173.39,218.84,182.47Z'/></svg>",
    tiktok: "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 256 256' fill='currentColor'><path d='M224,72a48.05,48.05,0,0,1-48-48,8,8,0,0,0-8-8H128a8,8,0,0,0-8,8V156a20,20,0,1,1-28.57-18.08A8,8,0,0,0,96,130.69V88a8,8,0,0,0-9.4-7.88C50.91,86.48,24,119.1,24,156a76,76,0,0,0,152,0V116.29A103.25,103.25,0,0,0,224,128a8,8,0,0,0,8-8V80A8,8,0,0,0,224,72Zm-8,39.64a87.19,87.19,0,0,1-43.33-16.15A8,8,0,0,0,160,102v54a60,60,0,0,1-120,0c0-25.9,16.64-49.13,40-57.6v27.67A36,36,0,1,0,136,156V32h24.5A64.14,64.14,0,0,0,216,87.5Z'/></svg>",
    reddit: "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 256 256' fill='currentColor'><path d='M248,104a32,32,0,0,0-52.94-24.19c-16.75-8.9-36.76-14.28-57.66-15.53l5.19-31.17,17.72,2.72a24,24,0,1,0,2.87-15.74l-26-4a8,8,0,0,0-9.11,6.59L121.2,64.16c-21.84.94-42.82,6.38-60.26,15.65a32,32,0,0,0-42.59,47.74A59,59,0,0,0,16,144c0,21.93,12,42.35,33.91,57.49C70.88,216,98.61,224,128,224s57.12-8,78.09-22.51C228,186.35,240,165.93,240,144a59,59,0,0,0-2.35-16.45A32.16,32.16,0,0,0,248,104ZM184,24a8,8,0,1,1-8,8A8,8,0,0,1,184,24Zm40.13,93.78a8,8,0,0,0-3.29,10A43.58,43.58,0,0,1,224,144c0,16.53-9.59,32.27-27,44.33C178.67,201,154.17,208,128,208s-50.67-7-69-19.67C41.59,176.27,32,160.53,32,144a43.75,43.75,0,0,1,3.14-16.17,8,8,0,0,0-3.27-10A16,16,0,1,1,52.94,94.59a8,8,0,0,0,10.45,2.23l.36-.22C81.45,85.9,104.25,80,128,80h0c23.73,0,46.53,5.9,64.23,16.6l.42.25a8,8,0,0,0,10.39-2.26,16,16,0,1,1,21.07,23.19ZM88,144a16,16,0,1,1,16-16A16,16,0,0,1,88,144Zm96-16a16,16,0,1,1-16-16A16,16,0,0,1,184,128Zm-16.93,44.25a8,8,0,0,1-3.32,10.82,76.18,76.18,0,0,1-71.5,0,8,8,0,1,1,7.5-14.14,60.18,60.18,0,0,0,56.5,0A8,8,0,0,1,167.07,172.25Z'/></svg>",
    pinterest: "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 256 256' fill='currentColor'><path d='M224,112c0,22.57-7.9,43.2-22.23,58.11C188.39,184,170.25,192,152,192c-17.88,0-29.82-5.86-37.43-12l-10.78,45.82A8,8,0,0,1,96,232a8.24,8.24,0,0,1-1.84-.21,8,8,0,0,1-6-9.62l32-136a8,8,0,0,1,15.58,3.66l-16.9,71.8C122,166,131.3,176,152,176c27.53,0,56-23.94,56-64A72,72,0,1,0,73.63,148a8,8,0,0,1-13.85,8A88,88,0,1,1,224,112Z'/></svg>",
    snapchat: "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 256 256' fill='currentColor'><path d='M247.83,182.28a8,8,0,0,0-5.13-5.9c-.39-.14-28.95-10.88-43-49.23l19.3-7.72A8,8,0,1,0,213,104.57l-17.82,7.13A149,149,0,0,1,192,80,64,64,0,0,0,64,80a151.24,151.24,0,0,1-3.18,31.75L43,104.57A8,8,0,1,0,37,119.43l19.37,7.75a94,94,0,0,1-17.74,30.2c-12.52,14.14-25.27,19-25.36,19a8,8,0,0,0-2.77,13.36c7.1,6.67,17.67,7.71,27.88,8.72,6.31.62,12.83,1.27,16.39,3.23,3.37,1.86,6.85,6.62,10.21,11.22,5.4,7.41,11.53,15.8,21.24,18.28,9.07,2.33,18.35-.83,26.54-3.62,5.55-1.89,10.8-3.68,15.21-3.68s9.66,1.79,15.21,3.68c6.2,2.11,13,4.43,19.9,4.43a26.35,26.35,0,0,0,6.64-.81h0c9.7-2.48,15.83-10.87,21.23-18.28,3.36-4.6,6.84-9.36,10.21-11.22,3.56-2,10.08-2.61,16.39-3.23,10.21-1,20.78-2.05,27.88-8.72A8,8,0,0,0,247.83,182.28Zm-31.82.26c-7.91.78-16.08,1.59-22.53,5.13s-11,9.79-15.41,15.81c-4,5.48-8.15,11.16-12.28,12.21-4.46,1.15-10.76-1-17.42-3.27s-13.31-4.53-20.37-4.53-13.83,2.3-20.37,4.53-13,4.42-17.42,3.27c-4.13-1.05-8.27-6.73-12.28-12.21-4.39-6-8.93-12.24-15.41-15.81S47.9,183.32,40,182.54c-1.55-.15-3.15-.31-4.74-.49a97.34,97.34,0,0,0,14.69-13.29c8.37-9.27,17.72-23.23,23.74-43.13l.06-.13a8.63,8.63,0,0,0,.46-1.61A158.47,158.47,0,0,0,80,80a48,48,0,0,1,96,0,158.42,158.42,0,0,0,5.8,43.92,8.63,8.63,0,0,0,.46,1.61l.06.13c6,19.9,15.37,33.86,23.74,43.13a97.34,97.34,0,0,0,14.69,13.29C219.16,182.23,217.57,182.39,216,182.54Z'/></svg>",
    discord: "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 256 256' fill='currentColor'><path d='M104,140a12,12,0,1,1-12-12A12,12,0,0,1,104,140Zm60-12a12,12,0,1,0,12,12A12,12,0,0,0,164,128Zm74.45,64.9-67,29.71a16.17,16.17,0,0,1-21.71-9.1l-8.11-22q-6.72.45-13.63.46t-13.63-.46l-8.11,22a16.18,16.18,0,0,1-21.71,9.1l-67-29.71a15.93,15.93,0,0,1-9.06-18.51L38,58A16.07,16.07,0,0,1,51,46.14l36.06-5.93a16.22,16.22,0,0,1,18.26,11.88l3.26,12.84Q118.11,64,128,64t19.4.93l3.26-12.84a16.21,16.21,0,0,1,18.26-11.88L205,46.14A16.07,16.07,0,0,1,218,58l29.53,116.38A15.93,15.93,0,0,1,238.45,192.9ZM232,178.28,202.47,62s0,0-.08,0L166.33,56a.17.17,0,0,0-.17,0l-2.83,11.14c5,.94,10,2.06,14.83,3.42A8,8,0,0,1,176,86.31a8.09,8.09,0,0,1-2.16-.3A172.25,172.25,0,0,0,128,80a172.25,172.25,0,0,0-45.84,6,8,8,0,1,1-4.32-15.4c4.82-1.36,9.78-2.48,14.82-3.42L89.83,56s0,0-.12,0h0L53.61,61.93a.17.17,0,0,0-.09,0L24,178.33,91,208a.23.23,0,0,0,.22,0L98,189.72a173.2,173.2,0,0,1-20.14-4.32A8,8,0,0,1,82.16,170,171.85,171.85,0,0,0,128,176a171.85,171.85,0,0,0,45.84-6,8,8,0,0,1,4.32,15.41A173.2,173.2,0,0,1,158,189.72L164.75,208a.22.22,0,0,0,.21,0Z'/></svg>",
    medium: "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 256 256' fill='currentColor'><path d='M72,64a64,64,0,1,0,64,64A64.07,64.07,0,0,0,72,64Zm0,112a48,48,0,1,1,48-48A48.05,48.05,0,0,1,72,176ZM184,64c-5.68,0-16.4,2.76-24.32,21.25C154.73,96.8,152,112,152,128s2.73,31.2,7.68,42.75C167.6,189.24,178.32,192,184,192s16.4-2.76,24.32-21.25C213.27,159.2,216,144,216,128s-2.73-31.2-7.68-42.75C200.4,66.76,189.68,64,184,64Zm0,112c-5.64,0-16-18.22-16-48s10.36-48,16-48,16,18.22,16,48S189.64,176,184,176ZM248,72V184a8,8,0,0,1-16,0V72a8,8,0,0,1,16,0Z'/></svg>",
    stackoverflow: "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 256 256' fill='currentColor'><path d='M216,152.09V216a8,8,0,0,1-8,8H48a8,8,0,0,1-8-8V152.09a8,8,0,0,1,16,0V208H200V152.09a8,8,0,0,1,16,0Zm-128,32h80a8,8,0,1,0,0-16H88a8,8,0,1,0,0,16Zm4.88-53,77.27,20.68a7.89,7.89,0,0,0,2.08.28,8,8,0,0,0,2.07-15.71L97,115.61A8,8,0,1,0,92.88,131Zm18.45-49.93,69.28,40a8,8,0,0,0,10.93-2.93,8,8,0,0,0-2.93-10.91L119.33,67.27a8,8,0,1,0-8,13.84Zm87.33,13A8,8,0,1,0,210,82.84l-56.57-56.5a8,8,0,0,0-11.32,11.3Z'/></svg>",
    dribbble: "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 256 256' fill='currentColor'><path d='M128,24A104,104,0,1,0,232,128,104.11,104.11,0,0,0,128,24Zm87.65,96.18Q211.83,120,208,120a168.58,168.58,0,0,0-43.94,5.84A166.52,166.52,0,0,0,150.61,96a168.32,168.32,0,0,0,38.2-31.55A87.78,87.78,0,0,1,215.65,120.18ZM176.28,54.46A151.75,151.75,0,0,1,142,82.52a169.22,169.22,0,0,0-38.63-39,88,88,0,0,1,73,10.94ZM85.65,50.88a153.13,153.13,0,0,1,42,39.18A151.82,151.82,0,0,1,64,104a154.19,154.19,0,0,1-20.28-1.35A88.39,88.39,0,0,1,85.65,50.88ZM40,128a87.73,87.73,0,0,1,.53-9.64A168.85,168.85,0,0,0,64,120a167.84,167.84,0,0,0,72.52-16.4,150.82,150.82,0,0,1,12.31,27.13,167.11,167.11,0,0,0-24.59,11.6,169.22,169.22,0,0,0-55.07,51.06A87.8,87.8,0,0,1,40,128Zm42,75a152.91,152.91,0,0,1,50.24-46.79,148.81,148.81,0,0,1,20.95-10,152.48,152.48,0,0,1,3.73,33.47,152.93,152.93,0,0,1-3.49,32.56A87.92,87.92,0,0,1,82,203Zm89.06,1.73a170,170,0,0,0,1.86-25,168.69,168.69,0,0,0-4.45-38.47A152.31,152.31,0,0,1,208,136q3.8,0,7.61.19A88.13,88.13,0,0,1,171.06,204.72Z'/></svg>",
    behance: "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 256 256' fill='currentColor'><path d='M160,80a8,8,0,0,1,8-8h64a8,8,0,0,1,0,16H168A8,8,0,0,1,160,80Zm-24,78a42,42,0,0,1-42,42H32a8,8,0,0,1-8-8V64a8,8,0,0,1,8-8H90a38,38,0,0,1,25.65,66A42,42,0,0,1,136,158ZM40,116H90a22,22,0,0,0,0-44H40Zm80,42a26,26,0,0,0-26-26H40v52H94A26,26,0,0,0,120,158Zm128-6a8,8,0,0,1-8,8H169a32,32,0,0,0,56.59,11.2,8,8,0,0,1,12.8,9.61A48,48,0,1,1,248,152Zm-17-8a32,32,0,0,0-62,0Z'/></svg>",
    whatsapp: "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 256 256' fill='currentColor'><path d='M187.58,144.84l-32-16a8,8,0,0,0-8,.5l-14.69,9.8a40.55,40.55,0,0,1-16-16l9.8-14.69a8,8,0,0,0,.5-8l-16-32A8,8,0,0,0,104,64a40,40,0,0,0-40,40,88.1,88.1,0,0,0,88,88,40,40,0,0,0,40-40A8,8,0,0,0,187.58,144.84ZM152,176a72.08,72.08,0,0,1-72-72A24,24,0,0,1,99.29,80.46l11.48,23L101,118a8,8,0,0,0-.73,7.51,56.47,56.47,0,0,0,30.15,30.15A8,8,0,0,0,138,155l14.61-9.74,23,11.48A24,24,0,0,1,152,176ZM128,24A104,104,0,0,0,36.18,176.88L24.83,210.93a16,16,0,0,0,20.24,20.24l34.05-11.35A104,104,0,1,0,128,24Zm0,192a87.87,87.87,0,0,1-44.06-11.81,8,8,0,0,0-6.54-.67L40,216,52.47,178.6a8,8,0,0,0-.66-6.54A88,88,0,1,1,128,216Z'/></svg>",
    telegram: "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 256 256' fill='currentColor'><path d='M228.88,26.19a9,9,0,0,0-9.16-1.57L17.06,103.93a14.22,14.22,0,0,0,2.43,27.21L72,141.45V200a15.92,15.92,0,0,0,10,14.83,15.91,15.91,0,0,0,17.51-3.73l25.32-26.26L165,220a15.88,15.88,0,0,0,10.51,4,16.3,16.3,0,0,0,5-.79,15.85,15.85,0,0,0,10.67-11.63L231.77,35A9,9,0,0,0,228.88,26.19Zm-61.14,36L78.15,126.35l-49.6-9.73ZM88,200V152.52l24.79,21.74Zm87.53,8L92.85,135.5l119-85.29Z'/></svg>",
    slack: "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 256 256' fill='currentColor'><path d='M221.13,128A32,32,0,0,0,184,76.31V56a32,32,0,0,0-56-21.13A32,32,0,0,0,76.31,72H56a32,32,0,0,0-21.13,56A32,32,0,0,0,72,179.69V200a32,32,0,0,0,56,21.13A32,32,0,0,0,179.69,184H200a32,32,0,0,0,21.13-56ZM72,152a16,16,0,1,1-16-16H72Zm48,48a16,16,0,0,1-32,0V152a16,16,0,0,1,16-16h16Zm0-80H56a16,16,0,0,1,0-32h48a16,16,0,0,1,16,16Zm0-48H104a16,16,0,1,1,16-16Zm16-16a16,16,0,0,1,32,0v48a16,16,0,0,1-16,16H136Zm16,160a16,16,0,0,1-16-16V184h16a16,16,0,0,1,0,32Zm48-48H152a16,16,0,0,1-16-16V136h64a16,16,0,0,1,0,32Zm0-48H184V104a16,16,0,1,1,16,16Z'/></svg>"
  };

  #render() {
    this.#url = this.getAttribute("url") || "";
    this.#iconType = this.#determineIconType();

    this.shadowRoot.innerHTML = `
      <style>
        :host {
          display: inline flex;
          width: 1.125rem;
          aspect-ratio: 1 / 1;
        }

        .icon {
          width: 100%%; height: 100%%;
          display: flex;
          align-items: center;
          justify-content: center;

          svg {
            width: 100%%;
            aspect-ratio: 1 / 1;
            fill: currentColor;
          }
        }
      </style>

      <div class="icon" data-icon-type="${this.#iconType}">
        ${this.#iconMarkup()}
      </div>
    `;
  }

  #determineIconType() {
    if (!this.#url) return "default";

    for (const [platform, pattern] of Object.entries(this.#platformPatterns)) {
      if (pattern.test(this.#url)) return platform;
    }

    return "default";
  }

  #iconMarkup() {
    return this.#icons[this.#iconType] || this.#icons.default;
  }
}

customElements.define("link-icon", LinkIcon);

RUBY

create_file "app/models/content//page.rb", <<~'RUBY', force: true
class Content::Page < Perron::Resource
end

RUBY

create_file "app/views/layouts/application.html.erb", <<~'RUBY', force: true
<!DOCTYPE html>
<html lang="en">
  <head>
    <%%= meta_tags %%>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">

    <%%= yield :head %%>

    <%%= stylesheet_link_tag :app %%>
    <%%= javascript_importmap_tags %%>
  </head>
  <body class="min-h-dvh bg-[url(https://unsplash.com/photos/my1e7zB6c9E/download?force=true&w=1920)] bg-cover bg-no-repeat">
    <%%= yield %%>
  </body>
</html>

RUBY

create_file "bin/importmap", <<~'RUBY', force: true
#!/usr/bin/env ruby

require_relative "../config/application"
require "importmap/commands"

RUBY

create_file "config/importmap.rb", <<~'RUBY', force: true
# Pin npm packages by running ./bin/importmap

pin "application"
pin_all_from "app/javascript/components", under: "components"

RUBY

create_file "config/routes.rb", <<~'RUBY', force: true
Rails.application.routes.draw do
  root to: "content/pages#root"
  resources :pages, module: :content, only: %%w[show]
end

RUBY
end
