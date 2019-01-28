module Balboa
  class FileThis
    def archive_filename_for(filethis_name)
      md = filethis_name.match(/(?<doc>.*)(?<year>\d{4})-(?<month>\d{2})-(?<date>\d{2})(?<other>.*)\.pdf/)

      date = "#{md[:year]}.#{md[:month]}.#{md[:date]}"
      name = "#{md[:doc].strip.gsub(' ','.')}"
      name += ".#{md[:other].strip}" unless md[:other].empty?

      "#{date}.#{name}.pdf"
    end
  end
end
