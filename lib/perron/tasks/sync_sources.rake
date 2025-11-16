namespace :perron do
  desc "Sync source-backed resources"
  task :sync_sources, [:name] => :environment do |_, arguments|
    Rails.application.eager_load!

    resource_classes = arguments.name ? ["Content::#{arguments.name.classify}".constantize] : Perron::Resource.descendants

    resource_classes.compact.each do |resource_class|
      resource_class.generate_from_sources! if resource_class.source_backed?
    end
  end
end
