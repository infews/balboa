module Balboa
  class DestinationDirectory
    def directory_for(filename)
      match = filename.match(/^(?<year>\d{4})\.(?<month>\d{2}).(?<date>\d{2})(?<other>.*)/)
      year = match[:year]
      month = match[:month]

      "#{year}/#{MONTH_DIRNAMES[month.to_i - 1]}"
    end
  end
end
