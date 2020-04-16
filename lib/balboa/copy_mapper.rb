module Balboa
  class CopyMapper
    # TODO: move this to a block form that yields the full path, return value goes into :new_name

    def copy_map_for(sources, renamer)
      sources.each_with_object({included: [], skipped: []}) do |full_path_to_source_file, map|
        filename = File.basename(full_path_to_source_file)
        new_name = renamer.new_name_for(filename)
        map[:included] << {
          original_full_path: full_path_to_source_file,
          destination_directory: directory_for(new_name),
          new_name: new_name,
        }
      rescue NoDateInFilenameError
        map[:skipped] << full_path_to_source_file
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
