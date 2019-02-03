require "rainbow"
require "thor"

module Balboa
  class CLI < Thor
    desc "archive_filethis FILETHIS_DIR ARCHIVE", "copies all PDFs from FileThis to the archive"
    def archive_filethis(source, archive_root)
      puts "Archiving files from #{source} to #{archive_root}"

      tools = FilenameTools.new

      Dir.glob("#{source}/**/*.pdf").each do |path_to_pdf|
        pdf_name = path_to_pdf.split("/").last
        archive_filename = tools.archive_filename_for(pdf_name)
        year_month_path = tools.directory_for(archive_filename)

        unless File.exist? File.join(archive_root, year_month_path)
          puts "Skipping #{pdf_name} as the archive destination doesn't exist"
          next
        end

        full_path_to_archived_file = File.join(archive_root, year_month_path, archive_filename)

        if File.exist? full_path_to_archived_file
          puts "Skipping #{pdf_name} as #{archive_filename} is already in the archive"
          next
        end

        puts "Copying #{pdf_name} to #{File.join(year_month_path, archive_filename)}"
        FileUtils.cp(path_to_pdf, full_path_to_archived_file)
      rescue
        puts "Skipping #{pdf_name} as we don't know where to archive it"
      end
    end
  end
end
