module Balboa
  class MoveToArchiver
    def initialize(archive_map)
      @archive_map = archive_map
    end

    def archive
      @archive_map.each do |entry|
        full_destination_path = File.join @archive_map.archive_root, entry.destination_path
        FileUtils.mkdir_p(full_destination_path)
        FileUtils.mv(entry.source, File.join(full_destination_path, entry.destination_basename))
        puts "Moved #{entry.destination_basename}"
      end
    end
  end
end
