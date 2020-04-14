module Balboa
  class NoDateInFilenameError < StandardError; end

  class FileThisRenamer
    def new_name_for(filename)
      match = filename.match(/(?<doc>.*)(?<year>\d{4})-(?<month>\d{2})-(?<date>\d{2})(?<other>.*)\.pdf/)
      raise NoDateInFilenameError unless match

      year = match[:year]
      month = match[:month]
      date = match[:date]
      doc = match[:doc]
      other = match[:other]

      name = doc.strip.tr(" ", ".").to_s
      name += ".#{other.strip}" unless other.empty?

      "#{year}.#{month}.#{date}.#{name}.pdf"
    end
  end
end
