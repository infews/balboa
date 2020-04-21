module Balboa
  class NoDateInFilenameError < StandardError; end

  class FileThisArchiver
    FILETHIS_REGEX = /^(?<doc>.*)(?<year>\d{4})-(?<month>\d{2})-(?<date>\d{2})(?<other>.*)\.pdf/
    attr_reader :source_files, :file_map

    def initialize(source_files, archive_root)
      @source_files = source_files
      @file_map = {}
    end

    def remove_failed_matches
      @source_files, excluded = @source_files.partition { |source_file|
        File.basename(source_file).match(FILETHIS_REGEX)
      }
      excluded
    end

    def name_destination_files
      @source_files.each_with_object(@file_map) do |source_file, map|
        map[source_file] = new_name_for(source_file)
      end
    end

    def new_name_for(source_file)
      match = File.basename(source_file).match(FILETHIS_REGEX)
      raise NoDateInFilenameError.new if match.nil?

      year = match[:year]
      month = match[:month]
      date = match[:date]
      doc = match[:doc]
      other = match[:other]

      name = doc.strip.tr(" ", ".").to_s
      name += ".#{other.strip}" unless other.empty?

      "#{year}.#{month}.#{date}.#{name}.pdf"
    end

    # Extractables Below

    def update_file_map(updates)
      @file_map.merge!(updates)
    end

    def destination_directory_for(filename)
      match = filename.match(/^(?<year>\d{4})\.(?<month>\d{2}).*/)

      year = match[:year]
      month = MONTH_DIRNAMES[match[:month].to_i - 1]

      "#{year}/#{month}"
    end
  end
end
