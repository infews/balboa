module Balboa
  class FileThisArchiveMap < ArchiveMap
    FILETHIS_REGEX = /^(?<doc>.*)(?<year>\d{4})-(?<month>\d{2})-(?<date>\d{2})(?<other>.*)\.pdf/

    def name_destination_files
      each do |entry|
        entry.destination_basename = archive_name_for(entry.source)
      end
    end

    def remove_failed_matches
      @map_entries, excluded = partition { |entry| File.basename(entry.source).match(FILETHIS_REGEX) }
      excluded.each_with_object([]) { |entry, results| results << entry.source }
    end

    def remove_files_already_in_the_archive
      each do |entry|
        delete(entry.source) if File.exist?(File.join(@archive_root, entry.destination_path, entry.destination_basename))
      end
    end

    def archive_name_for(source_file)
      match = File.basename(source_file).match(FILETHIS_REGEX)
      raise NoDateInFilenameError.new if match.nil?

      year = match[:year]
      month = match[:month]
      date = match[:date]
      doc = match[:doc]
      other = match[:other]

      rest_of_name = doc.strip.tr(" ", ".").to_s
      rest_of_name += ".#{other.strip}" unless other.empty?

      "#{year}.#{month}.#{date}.#{rest_of_name}.pdf"
    end
  end
end
