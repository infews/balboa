module Balboa
  class NoDateInFilenameError < StandardError; end

  class FileThisRenamer
    def initialize
      @filethis_regex = /^(?<doc>.*)(?<year>\d{4})-(?<month>\d{2})-(?<date>\d{2})(?<other>.*)\.pdf/
    end

    def new_name_for(full_path_to_file)
      filename = File.basename(full_path_to_file)
      match = filename.match(@filethis_regex)
      raise NoDateInFilenameError.new if match.nil?

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
