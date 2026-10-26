RailsIcons.configure do |config|
  config.default_library = "phosphor"
  config.default_variant = "regular" # Set a default variant for all libraries

  config.libraries.phosphor.exclude_variants = %w[bold fill light thin]

  common_phosphor_icons = %w[arrow-left arrow-right book-open caret-right clipboard-text clipboard cube info lightbulb list-dashes list magnifying-glass markdown-logo shield-warning star warning-circle warning pencil-circle]

  config.default_sprite_location = nil

  config.sprite = {
    phosphor: {
      regular: common_phosphor_icons,
      duotone: common_phosphor_icons + %w[browser code-simple puzzle-piece]
    }
  }

  # config.libraries.phosphor.duotone.default.css = "size-6"
  # config.libraries.phosphor.duotone.default.data = {}

  # config.libraries.phosphor.regular.default.css = "size-6"
  # config.libraries.phosphor.regular.default.data = {}
end
