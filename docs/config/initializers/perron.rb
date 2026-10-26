Perron.configure do |config|
  config.site_name = "Perron"

  config.live_reload = true
  config.search_scope = %w[articles resources]
  config.additional_routes += %w[search_path]

  # Set meta title suffix
  config.metadata.title_suffix = "Perron"
  config.metadata.title_separator = " | "
  config.metadata.author = "Rails Designer"

  config.markdown_options = {
    options: {
      parse: {
        smart: true
      },

      render: {
        unsafe: true
      }
    },

    plugins: {
      syntax_highlighter: {
        theme: "perron-syntax-theme",
        path: Rails.root.join("app", "themes").to_s
      }
    }
  }
end
