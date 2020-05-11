module Balboa
  class MoveToArchiveMap < ArchiveMap
    BALBOA_REGEX = /^(?<year>\d{4})\.(?<month>\d{2})\.(?<date>\d{2})/
    def remove_failed_matches
      @map_entries, cannot_match = @map_entries.partition { |entry|
        File.basename(entry.source).match(BALBOA_REGEX)
      }
      cannot_match.each_with_object([]) { |entry, results| results << entry.source }
    end

    def determine_destinations
      @map_entries.each do |entry|
        entry.destination_basename = File.basename(entry.source)
      end
    end
  end
end
