module Balboa
  class CopyMapper
    def copy_map_for(sources, renamer)
      sources.each_with_object([]) do |full_path_to_source_file, map|
        filename = File.basename(full_path_to_source_file)
        new_name = renamer.new_name_for(filename)
        map << {
          original_full_path: full_path_to_source_file,
          destination_directory: directory_for(new_name),
          new_name: new_name,
        }
      rescue NoDateInFilenameError
        next
      end
    end

    private

    def directory_for(filename)
      match = filename.match(/^(?<year>\d{4})\.(?<month>\d{2}).*/)

      year = match[:year]
      month = MONTH_DIRNAMES[match[:month].to_i - 1]

      "#{year}/#{month}"
    end
  end
end
