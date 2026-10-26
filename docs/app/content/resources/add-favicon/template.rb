gem "perron" unless File.read("Gemfile").include?("perron")

after_bundle do
  unless File.exist?("config/initializers/perron.rb")
    rails_command "perron:install"
  end

  APPLICATION_LAYOUT_PATH = Rails.root.join("app/views/layouts/application.html.erb")

def tool_installed?(tool)
  system("which #{tool} > /dev/null 2>&1")
end

{ "magick" => "ImageMagick", "inkscape" => "Inkscape", "svgo" => "SVGO" }.each do |command, name|
  abort "#{name} is required to continue." unless tool_installed?(command)
end

abort "icon.svg is not present in the root folder" unless File.exist?("icon.svg")

app_name = ask("What is the name of your Rails app?").presence || Rails.application.class.module_parent_name
is_pwa = yes?("Is this also a Progressive Web App (PWA)?")

say "Creating the favicon.ico"
run "inkscape ./icon.svg --export-width=32 --export-filename='./tmp.png' && magick ./tmp.png ./public/favicon.ico && rm ./tmp.png"

say "Creating the apple-touch-icon.png"
run "inkscape ./icon.svg --export-width=180 --export-filename='./public/apple-touch-icon.png'"

if is_pwa
  say "Creating the PWA PNG files"
  run "inkscape ./icon.svg --export-width=192 --export-filename='./public/icon-192.png'"
  run "inkscape ./icon.svg --export-width=512 --export-filename='./public/icon-512.png'"

  say "Creating the maskable icon (512x512 with padding for 409x409 safe zone; the appropriate padding for maskable icon requirements)"
  run "inkscape ./icon.svg --export-width=512 --export-filename='./public/icon-mask.png'"
end

say "Optimizing the SVG file"
run "npx svgo --multipass icon.svg"

if is_pwa
  say "Creating web app manifest"
  create_file "public/manifest.webmanifest", <<~JSON
  {
    "name": "#{app_name}",
    "icons": [
      { "src": "/icon-192.png", "type": "image/png", "sizes": "192x192" },
      { "src": "/icon-mask.png", "type": "image/png", "sizes": "512x512", "purpose": "maskable" },
      { "src": "/icon-512.png", "type": "image/png", "sizes": "512x512" }
    ]
  }
  JSON
end

say "Creating favicons partial"
favicons = <<~ERB
  <link rel="icon" href="/favicon.ico" sizes="32x32">
  <link rel="icon" href="/icon.svg" type="image/svg+xml">
  <link rel="apple-touch-icon" href="/apple-touch-icon.png">
ERB

if is_pwa
  favicons += <<~ERB.chomp
    <link rel="manifest" href="/manifest.webmanifest">
  ERB
end

create_file "app/views/shared/_favicons.html.erb", favicons

say "Moving the source icon.svg to the /public/ folder"
run "mv icon.svg public/"

say "Inserting the favicons partial within the application's layout <head>"
if APPLICATION_LAYOUT_PATH.exist?
  if File.read(APPLICATION_LAYOUT_PATH) =~ /<\/head>/
    insert_into_file APPLICATION_LAYOUT_PATH.to_s, <<~ERB.indent(4), before: /^\s*<\/head>/
<%%= render partial: "shared/favicons" %>
    ERB
  else
    say "The <head> tag is missing in your application layout", :red
    say %(        Add `<%%= render partial: "shared/favicons" %>` within the `<head>` of your layout.)
  end
else
  say "Default application.html.erb is missing!", :red
  say %(        Add `<%%= render partial: "shared/favicons" %>` within the `<head>` of your layout.)
end
end
