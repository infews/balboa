module Balboa
  class CopyArchiver
    def initialize(archive_map)
      @archive_map = archive_map
    end

    def archive
      @archive_map.each do |entry|
        full_destination_path = File.join @archive_map.archive_root, entry.destination_path
        FileUtils.mkdir_p(full_destination_path)
        FileUtils.cp(entry.source, File.join(full_destination_path, entry.destination_basename))
        puts "...copying to #{full_destination_path}"
        puts "Added #{entry.destination_basename}"
      end
    end
  end
end
