module Balboa
  class MoveArchiver < Archiver
    BALBOA_REGEX = /^(?<year>\d{4})\.(?<month>\d{2})\.(?<date>\d{2})/
    def remove_failed_matches
      @source_files, excluded = @source_files.partition { |source_file|
        File.basename(source_file).match(BALBOA_REGEX)
      }
      excluded
    end

    def determine_destinations
      @source_files.each do |source_file|
        file_basename = File.basename(source_file)
        @file_map[source_file] = File.join(@archive_root, destination_directory_for(file_basename), file_basename)
      end
    end

    def remove_files_already_in_the_archive
      @file_map.each do |source_path, destination_path|
        @file_map.delete(source_path) if File.exist?(destination_path)
      end
    end

    def archive
      @file_map.each do |source, destination|
        FileUtils.mkdir_p(File.dirname(destination))
        FileUtils.mv(source, destination)
        puts "Moved #{File.basename(destination)}"
      end
    end
  end
end
