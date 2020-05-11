module Balboa
  class ArchiveMapEntry
    attr_reader :source
    attr_accessor :destination_basename

    def initialize(source)
      @source = source
    end

    def destination_path
      return nil if @destination_basename.nil?

      match = File.basename(@destination_basename).match(/^(?<year>\d{4})\.(?<month>\d{2}).*/)

      return nil if match.nil?

      year = match[:year]
      month = MONTH_DIRNAMES[match[:month].to_i - 1]

      File.join(year, month)
    end

    def destination
      File.join(destination_path, destination_basename)
    end

    def ==(other)
      source == other.source
    end
  end
end
