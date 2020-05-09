require "fileutils"
require "rainbow/refinement"
require "thor"

using Rainbow

module Balboa
  class CLI < Thor
    desc "archive_filethis FILETHIS_DIR ARCHIVE", "copies all PDFs from FileThis to the archive"
    method_option verbose: :boolean, default: false

    def archive_images(source, archive_root)
      raise NoSourceDirectoryError.new("Source directory #{source} does not exist.") unless File.exist? source
      raise NoArchiveDirectoryError.new("Archive root #{archive_root} does not exist.") unless File.exist?(archive_root)

      images = Dir.glob("#{source}/**/*.{.jpg|.JPG|.jpeg|.JPEG|.heic|.HEIC}").sort
      puts("No images found in #{source}.".red) && return if images.length == 0

      puts "Looking for images in ".cyan + source.to_s + " to rename and archive...".cyan
      puts "Found #{images.length} total images.".cyan

      archiver = ImageArchiver.new(images, archive_root)
      exif_data = ExifTool.new(images)
      archiver.exif = exif_data

      excluded = archiver.remove_files_without_exif

      if excluded.length > 0
        puts "Skipping these #{excluded.length} files as they have no EXIF data".yellow
        excluded.each { |skip| puts skip }
      end

      archiver.build_file_map

      file_count = archiver.file_map.keys.length
      raise NoFilesToArchiveError.new if file_count == 0 # I'm sorry, but return wasn't working here

      puts "Archiving ".green + file_count.to_s + " images...".green
      archiver.archive

      puts "Added #{archiver.file_map.length} files to the archive.".cyan
    rescue NoFilesToArchiveError
      puts "No new files found to archive.".yellow
    end
  end
end
