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

      # Dir.glob("#{source}/**/*.pdf") # odd bug, need to Dir.glob twice to get the files?

      pdfs = Dir.glob("#{source}/**/*.pdf").sort
      puts("No PDFs found in #{source}.") && return if pdfs.length == 0

      puts("Looking for FileThis PDFs in #{source} to rename and archive...\n")

      archiver = FileThisArchiver.new(pdfs, archive_root)

      excluded = archiver.remove_failed_matches
      puts("Skipping these files as they are not renameable:\n")
      excluded.each { |skip| puts skip }

      archiver.name_destination_files

      archiver.archive

      puts("Added #{archiver.file_map.length} files to the archive:")
      archiver.file_map.values.each { |destination_file_path| puts destination_file_path }

      # puts Rainbow("Found #{pdfs.length} PDF files").cyan
      # pdfs.each do |path_to_pdf|
      #   pdf_name = path_to_pdf.split("/").last
      #   converter = FileThisRenamer.new
      #
      #   unless File.exist? File.join(archive_root, converter.destination_directory)
      #     puts Rainbow("Skipping").red + " #{pdf_name}" + Rainbow(" as the archive destination doesn't exist").red
      #     next
      #   end
      #
      #   full_path_to_archived_file = File.join(archive_root, converter.destination_directory, converter.filename)
      #
      #   if File.exist? full_path_to_archived_file
      #     puts "Skipping #{pdf_name} as #{converter.filename} is already in the archive" if options[:versbose]
      #     next
      #   end
      #
      #   puts Rainbow("Copying").green + " #{pdf_name} to " + Rainbow(File.join(converter.destination_directory, converter.filename).to_s).green
      #   FileUtils.cp(path_to_pdf, full_path_to_archived_file)
      # rescue
      #   puts Rainbow("Skipping").red + " #{pdf_name}" + Rainbow(" as we don't know where to archive it").red
      # end
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
