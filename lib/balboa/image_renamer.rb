module Balboa
  class NotAnImageFile < StandardError; end

  class ImageRenamer
    def new_name_for(full_path_to_file, exif)
      filename = File.basename(full_path_to_file)

      date = exif[:date]
      model = exif[:model].gsub(/\s+/, "")

      "#{date.strftime("%Y.%m.%d")}.#{model}.#{filename}"
    end
  end
end
