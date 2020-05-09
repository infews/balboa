module Balboa
  class NoDateInFilenameError < StandardError; end

  class Archiver
    attr_reader :source_files, :file_map

    def initialize(source_files, archive_root)
      @source_files = source_files
      @archive_root = archive_root
      @file_map = {}
    end

    def update_file_map(updates)
      @file_map.merge!(updates)
    end

    def destination_directory_for(filename)
      match = filename.match(/^(?<year>\d{4})\.(?<month>\d{2}).*/)

      year = match[:year]
      month = MONTH_DIRNAMES[match[:month].to_i - 1]

      File.join(year, month)
    end

    # By Default, #archive does a copy from source to destination
    def archive
      @file_map.each do |source, destination|
        FileUtils.mkdir_p(File.dirname(destination))
        FileUtils.cp(source, destination)
        puts "Added #{File.basename(destination)}"
      end
    end
  end
end
