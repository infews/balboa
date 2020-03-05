module Balboa
  class NoDateInFilenameError < StandardError; end

  class FilenameConverter

    attr_reader :filename, :destination_directory

    def initialize(filename)
      @filename = filename

      match = @filename.match(/(?<doc>.*)(?<year>\d{4})-(?<month>\d{2})-(?<date>\d{2})(?<other>.*)\.pdf/)
      raise NoDateInFilenameError unless match

      year = match[:year]
      month = match[:month]
      date = match[:date]
      doc = match[:doc]
      other = match[:other]

      name = doc.strip.tr(" ", ".").to_s
      name += ".#{other.strip}" unless other.empty?

      @filename = "#{year}.#{month}.#{date}.#{name}.pdf"

      @destination_directory = "#{year}/#{MONTH_DIRNAMES[month.to_i-1]}"
    end
  end
end
