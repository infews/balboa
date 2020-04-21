module Balboa
  class CopyMapper
    def copy_map_for(sources, &block)
      sources.each_with_object({included: [], excluded: []}) do |full_path_to_source_file, map|
        new_name = yield full_path_to_source_file
        map[:included] << {
          original_full_path: full_path_to_source_file,
          destination_directory: directory_for(new_name),
          new_name: new_name,
        }
      rescue
        map[:excluded] << full_path_to_source_file
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
