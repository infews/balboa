require "fileutils"
require "rainbow"
require "thor"

module Balboa
  class CLI < Thor
    desc "archive_filethis FILETHIS_DIR ARCHIVE", "copies all PDFs from FileThis to the archive"
    method_option verbose: :boolean, default: false

    def archive_filethis(source, archive_root)
      raise NoSourceDirectoryError.new("Source directory #{source} does not exist.") unless File.exist? source
      raise NoArchiveDirectoryError.new("Archive root #{archive_root} does not exist.") unless File.exist?(archive_root)

      pdfs = Dir.glob("#{source}/**/*.pdf").sort
      puts(Rainbow("No PDFs found in #{source}.").red) && return if pdfs.length == 0

      puts Rainbow("Looking for FileThis PDFs in ").cyan + source.to_s + Rainbow(" to rename and archive...").cyan

      archiver = FileThisArchiver.new(pdfs, archive_root)

      excluded = archiver.remove_failed_matches

      if excluded.length
        puts Rainbow("Skipping these files as they are not renameable:\n").cyan
        excluded.each { |skip| puts skip }
      end

      archiver.name_destination_files
      archiver.remove_files_already_in_the_archive

      puts Rainbow("Archiving ") + archiver.file_map.length.to_s + Rainbow(" files...\n").cyan
      archiver.archive

      puts Rainbow("Added #{archiver.file_map.length} files to the archive:").cyan
      archiver.file_map.values.each { |destination_file_path| puts destination_file_path }
    end

    desc "make_archive_folders DIR", "makes standard year/month folders under DIR path"

    def make_archive_folders(archive_root)
      year = Time.now.year.to_s
      year_folder_path = File.join(archive_root, "Personal", year)
      puts "Creating #{year_folder_path}"
      FileUtils.mkdir_p(year_folder_path)

      dirs = MONTH_DIRNAMES
      dirs << "#{year}.Tax"
      dirs << "#{year}.MediaArchive"
      dirs.each do |dir|
        full_path = File.join year_folder_path, dir
        puts "Creating #{full_path}"
        FileUtils.mkdir_p(full_path)
      end
    end
  end
end
