require "fileutils"
require "rainbow/refinement"
require "thor"

using Rainbow

module Balboa
  class CLI < Thor
    desc "archive_filethis FILETHIS_DIR ARCHIVE", "copies all PDFs from FileThis to the archive"
    method_option verbose: :boolean, default: false

    def archive_filethis(source, archive_root)
      raise NoSourceDirectoryError.new("Source directory #{source} does not exist.") unless File.exist? source
      raise NoArchiveDirectoryError.new("Archive root #{archive_root} does not exist.") unless File.exist?(archive_root)

      pdfs = Dir.glob("#{source}/**/*.pdf").sort
      puts("No PDFs found in #{source}.".red) && return if pdfs.length == 0

      puts "Looking for FileThis PDFs in ".cyan + source.to_s + " to rename and archive...".cyan
      puts "Found #{pdfs.length} total PDFs.".cyan

      archive_map = FileThisArchiveMap.new(pdfs, archive_root)

      excluded = archive_map.remove_failed_matches

      if excluded.length > 0
        puts "Skipping these #{excluded.length} files as they are not renameable:".yellow
        excluded.each { |skip| puts skip }
      end

      archive_map.name_destination_files
      archive_map.remove_files_already_in_the_archive

      file_count = archive_map.length
      raise NoFilesToArchiveError.new if file_count == 0 # I'm sorry, but return wasn't working here

      puts "Archiving ".green + file_count.to_s + " files...".green
      archiver = CopyArchiver.new(archive_map)
      archiver.archive

      puts "Added #{file_count} files to the archive.".cyan
    rescue NoFilesToArchiveError
      puts "No new files found to archive.".yellow
    end
  end
end
