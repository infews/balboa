module Balboa
  class JPGFinder
    def find(glob)
      glob.each_with_object([]) do |filename, jpg|
        jpg << filename if filename =~ /.*(\.jpeg|\.jpg)$/i
      end
    end
  end
end
