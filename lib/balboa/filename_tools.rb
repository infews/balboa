module Balboa
  class NoDateInFilenameError < StandardError; end

  MONTH_MAP = {
    '01' => '01.Jan',
    '02' => '02.Feb',
    '03' => '03.Mar',
    '04' => '04.Apr',
    '05' => '05.May',
    '06' => '06.Jun',
    '07' => '07.Jul',
    '08' => '08.Aug',
    '09' => '09.Sep',
    '10' => '10.Oct',
    '11' => '11.Nov',
    '12' => '12.Dec'
  }

  class FilenameTools
    def archive_filename_for(filethis_name)
      md = filethis_name.match(/(?<doc>.*)(?<year>\d{4})-(?<month>\d{2})-(?<date>\d{2})(?<other>.*)\.pdf/)

      date = "#{md[:year]}.#{md[:month]}.#{md[:date]}"
      name = "#{md[:doc].strip.gsub(' ','.')}"
      name += ".#{md[:other].strip}" unless md[:other].empty?

      "#{date}.#{name}.pdf"
    end

    def month_directory_for(filename)
      year_match = filename.match(/(?<year>\d{4})\.(?<rest>.*)/)

      raise NoDateInFilenameError unless year_match

      directory_name = "#{year_match[:year]}/"

      month_match = year_match[:rest].match(/^(?<month>\d{2}).*/)
      directory_name += "#{MONTH_MAP[month_match[:month]]}/" if month_match && month_match[:month]

      directory_name
    end
  end
end
