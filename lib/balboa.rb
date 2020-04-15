require "balboa/cli"
require "balboa/file_this_renamer"
require "balboa/copy_mapper"
require "balboa/destination_directory"
require "balboa/jpg_finder"
require "balboa/pdf_finder"
require "balboa/version"

module Balboa
  class Error < StandardError; end
  MONTH_DIRNAMES = [
    "01.Jan",
    "02.Feb",
    "03.Mar",
    "04.Apr",
    "05.May",
    "06.Jun",
    "07.Jul",
    "08.Aug",
    "09.Sep",
    "10.Oct",
    "11.Nov",
    "12.Dec",
  ]
end
