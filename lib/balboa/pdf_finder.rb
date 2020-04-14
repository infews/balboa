module Balboa
  class PDFFinder
    def find(glob)
      glob.each_with_object([]) do |filename, pdfs|
        pdfs << filename if filename =~ /.*\.pdf$/
      end
    end
  end
end
