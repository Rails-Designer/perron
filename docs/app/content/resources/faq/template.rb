gem "perron" unless File.read("Gemfile").include?("perron")
gem "tailwindcss-rails" unless File.read("Gemfile").include?("tailwindcss-rails")

after_bundle do
  unless File.exist?("config/initializers/perron.rb")
    rails_command "perron:install"
  end

  unless File.exist?("app/assets/tailwind/application.css")
    rails_command "tailwindcss:install"
  end

create_file "app/views/shared/_faq.html.erb", <<~ERB
<%%# locals: (collection: [], icon_base_css: "size-4 text-gray-800") %%>
<dl class="grid divide-y divide-gray-200">
  <%% collection.each do |item| %%>
    <details class="px-1 py-2 group/details">
      <%%= tag.summary id: item.question.parameterize, class: "flex items-center justify-between gap-x-2 w-full select-none [&::-webkit-details-marker]:hidden" do %%>
        <%%= tag.span item.question, class: "font-semibold text-gray-800" %%>

        <%%# heroicons / mini / plus; you can also use Rails Icons (https://github.com/Rails-Designer/rails_icons/) %%>
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true" data-slot="icon" class="<%%= class_names(icon_base_css, "group-open/details:hidden") %%>"><path d="M10.75 4.75a.75.75 0 0 0-1.5 0v4.5h-4.5a.75.75 0 0 0 0 1.5h4.5v4.5a.75.75 0 0 0 1.5 0v-4.5h4.5a.75.75 0 0 0 0-1.5h-4.5v-4.5Z"/></svg>

        <%%# heroicons / mini / minus; you can also use Rails Icons (https://github.com/Rails-Designer/rails_icons/) %%>
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true" data-slot="icon" class="<%%= class_names(icon_base_css, "hidden group-open/details:block") %%>"><path fill-rule="evenodd" d="M4 10a.75.75 0 0 1 .75-.75h10.5a.75.75 0 0 1 0 1.5H4.75A.75.75 0 0 1 4 10Z" clip-rule="evenodd"/></svg>
      <%% end %%>

      <%%= tag.div item.answer, class: "mt-1 font-normal text-gray-500" %%>
    </details>
  <%% end %%>
</dl>
ERB
end
