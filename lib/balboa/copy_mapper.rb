module Balboa
  class CopyMapper
    def copy_map_for(sources, renamer)
      sources.each_with_object([]) do |source_file, map|
        new_name = renamer.new_name_for(source_file)
        next if new_name.nil?

        map << {
          original_full_path: source_file,
          destination_directory: directory_for(new_name),
          new_name: new_name,
        }
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
