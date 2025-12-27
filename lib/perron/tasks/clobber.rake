namespace :perron do
  desc "Remove compiled static output"
  task clobber: :environment do
    output_path = Rails.root.join(Perron.configuration.output)

    if Dir.exist?(output_path)
      FileUtils.rm_rf(output_path)

      puts "Removed #{output_path}"
    end
  end
end
