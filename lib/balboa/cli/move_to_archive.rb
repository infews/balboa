require "fileutils"
require "rainbow/refinement"
require "thor"

using Rainbow

module Balboa
  class CLI < Thor
    desc "move_to_archive SOURCE_DIR ARCHIVE", "Moves all Balboa-named files source dir to the archive"
    method_option verbose: :boolean, default: false

    def move_to_archive(source, archive_root)
      raise NoSourceDirectoryError.new("Source directory #{source} does not exist.") unless File.exist? source
      raise NoArchiveDirectoryError.new("Archive root #{archive_root} does not exist.") unless File.exist?(archive_root)

      files = Dir.glob("#{source}/**/*").sort
      puts("No files found in #{source}.".red) && return if files.length == 0

      puts "Looking for Balboa-convention-named files ".cyan + source.to_s + " to move to archive...".cyan
      puts "Found #{files.length} total files.".cyan

      archiver = MoveArchiver.new(files, archive_root)

      archiver.remove_failed_matches
      archiver.determine_destinations

      file_count = archiver.file_map.keys.length
      raise NoFilesToArchiveError.new if file_count == 0 # I'm sorry, but return wasn't working here

      puts "Archiving ".green + file_count.to_s + " files...".green
      archiver.archive

      puts "Moved #{archiver.file_map.length} files to the archive.".cyan
    rescue NoFilesToArchiveError
      puts "No files found to archive.".yellow
    end
  end
end
