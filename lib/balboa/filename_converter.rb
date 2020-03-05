module Balboa
  class NoDateInFilenameError < StandardError; end

  MONTHS = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
  MONTH_MAP = {
    "01" => "Jan",
    "02" => "Feb",
    "03" => "Mar",
    "04" => "Apr",
    "05" => "May",
    "06" => "Jun",
    "07" => "Jul",
    "08" => "Aug",
    "09" => "Sep",
    "10" => "Oct",
    "11" => "Nov",
    "12" => "Dec",
  }

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

      @destination_directory = "#{year}/#{month_dirname(month)}"
    end

    private

    def month_dirname(month_number)
      [month_number, MONTH_MAP[month_number]].join(".")
    end
  end
end
