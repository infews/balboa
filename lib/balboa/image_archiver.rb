module Balboa
  class NotAnImageFile < StandardError; end

  class ImageArchiver < Archiver
    attr_writer :exif_tool

    def remove_files_without_exif
      @source_files, excluded = @source_files.partition { |source_file| @exif_tool.result_for(source_file) }

      excluded
    end

    def build_file_map
      @source_files.each do |source_file|
        new_name = more_descriptive_name_for(source_file, @exif_tool.result_for(source_file).to_hash)
        @file_map[source_file] =
          File.join(@archive_root, destination_directory_for(new_name), new_name)
      end
    end

    def more_descriptive_name_for(full_path_to_file, exif)
      filename = File.basename(full_path_to_file)

      date = normalized_date_for(exif[:date])
      model = normalized_model_for(exif[:model])

      "#{date.strftime("%Y.%m.%d")}.#{model}.#{filename}"
    end

    private

    def normalized_model_for(exif_model)
      return "Unknown" if exif_model.nil? || exif_model.empty?

      exif_model.gsub(/\s+/, "")
    end

    def normalized_date_for(date)
      return date if date.is_a?(Date)

      Date.new(3001, 1, 1)
    end
  end
end
