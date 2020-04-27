require "fileutils"
require "rainbow/refinement"
require "thor"

using Rainbow

module Balboa
  class CLI < Thor
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
