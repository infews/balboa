module Balboa
  class NoDateInFilenameError < StandardError; end

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

  class FilenameTools
    def archive_filename_for(filethis_name)
      match = filethis_name.match(/(?<doc>.*)(?<year>\d{4})-(?<month>\d{2})-(?<date>\d{2})(?<other>.*)\.pdf/)
      raise NoDateInFilenameError unless match

      date = "#{match[:year]}.#{match[:month]}.#{match[:date]}"
      name = match[:doc].strip.tr(" ", ".").to_s
      name += ".#{match[:other].strip}" unless match[:other].empty?

      "#{date}.#{name}.pdf"
    end

    def directory_for(filename)
      year_match = filename.match(/(?<year>\d{4})\.(?<rest>.*)/)

      raise NoDateInFilenameError unless year_match

      directory_name = [year_match[:year]]
      month_match = year_match[:rest].match(/^(?<month>\d{2}).*/)

      directory_name << month_dirname(month_match[:month]) if month_match
      directory_name.join("/")
    end

    private

    def month_dirname(month_number)
      [month_number, MONTH_MAP[month_number]].join(".")
    end
  end
end
