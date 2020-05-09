module Balboa
  class FileThisArchiver < Archiver
    FILETHIS_REGEX = /^(?<doc>.*)(?<year>\d{4})-(?<month>\d{2})-(?<date>\d{2})(?<other>.*)\.pdf/

    def remove_failed_matches
      @source_files, excluded = @source_files.partition { |source_file|
        File.basename(source_file).match(FILETHIS_REGEX)
      }
      excluded
    end

    def name_destination_files
      @source_files.each_with_object(@file_map) do |source_file, map|
        map[source_file] = new_destination_path_for(source_file)
      end
    end

    def new_destination_path_for(source_file)
      match = File.basename(source_file).match(FILETHIS_REGEX)
      raise NoDateInFilenameError.new if match.nil?

      year = match[:year]
      month = match[:month]
      date = match[:date]
      doc = match[:doc]
      other = match[:other]

      rest_of_name = doc.strip.tr(" ", ".").to_s
      rest_of_name += ".#{other.strip}" unless other.empty?

      new_name = "#{year}.#{month}.#{date}.#{rest_of_name}.pdf"

      File.join @archive_root, destination_directory_for(new_name), new_name
    end

    def remove_files_already_in_the_archive
      @file_map.each do |source_path, destination_path|
        @file_map.delete(source_path) if File.exist?(destination_path)
      end
    end
  end
end
