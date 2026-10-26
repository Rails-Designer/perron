class Content::Resource::Library < ActiveResource::Base
  self.site = "https://api.github.com/"
  self.headers["Authorization"] = "Bearer #{Rails.application.credentials.github.api_token}"

  def self.all
    %w[components snippets templates].flat_map { get_resources_for it }
  end

  private

  def self.get_resources_for(directory)
    find(:all, from: "/repos/Rails-Designer/perron-library/contents/#{directory}", params: { per_page: 100 })
      .reject { it.name == ".keep" }
      .map do |item|
        item.tap do |resource|
          resource.content = fetch(resource.path, filename: "template.md")
          resource.template = fetch(resource.path, filename: "template.rb")

          images_uri = URI("https://api.github.com/repos/Rails-Designer/perron-library/contents/#{resource.path}/images")
          images = Net::HTTP::Get.new(images_uri)
          images["Authorization"] = headers["Authorization"]
          response = Net::HTTP.start(images_uri.hostname, images_uri.port, use_ssl: true) { it.request images }

          resource.images = if response.code == "200"
            JSON.parse(response.body)
              .select { it["type"] == "file" }.map { |file| { name: file["name"], content: fetch(file["path"]) } }
          else
            []
          end

          save resource.path, resource.template, resource.images
        end
      end
  end

  def self.fetch(path, filename: nil)
    uri = URI(
      [ "https://api.github.com/repos/Rails-Designer/perron-library/contents/", path, filename ].compact_blank.join("/")
    )
    file = Net::HTTP::Get.new(uri)

    file["Authorization"] = headers["Authorization"]

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { it.request file }
    return unless response.code == "200"

    Base64.decode64(JSON.parse(response.body)["content"]).force_encoding("UTF-8")
  end

  def self.save(path, template, images)
    folder_name = path.split("/").last
    base_path = Rails.root.join("app", "content", "resources", folder_name)

    FileUtils.mkdir_p(base_path)
    File.write(base_path.join("template.rb"), template.gsub("<%", "<%%"))

    return if images.empty?

    images_path = base_path.join("images")
    FileUtils.mkdir_p(images_path)

    images.each { File.write(images_path.join(it[:name]), it[:content]) }
  end
end
