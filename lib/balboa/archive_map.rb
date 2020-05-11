module Balboa
  class ArchiveMap
    include Enumerable

    attr_reader :archive_root

    def initialize(source_files, archive_root)
      @archive_root = archive_root
      @map_entries = source_files.collect { |file|
        ArchiveMapEntry.new(file)
      }
    end

    def length
      @map_entries.length
    end

    def each(&block)
      @map_entries.each(&block)
      self
    end

    def include?(source_file)
      !!@map_entries.find { |entry| entry.source == source_file }
    end

    def delete(source_file)
      found = @map_entries.find { |entry| entry.source == source_file }
      if found
        @map_entries.delete(found)
      end
      found
    end

    def entry_for(source_file)
      @map_entries.find { |entry| entry.source == source_file }
    end
  end
end
