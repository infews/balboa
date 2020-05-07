require "balboa/cli"
require "balboa/archiver"
require "balboa/file_this_archiver"
require "balboa/move_archiver"
require "balboa/collision_resolver"
require "balboa/image_renamer"
require "balboa/version"

module Balboa
  class Error < StandardError; end
  class NoSourceDirectoryError < Error; end
  class NoArchiveDirectoryError < Error; end
  class NoFilesToArchiveError < Error; end

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
    "12.Dec"
  ]
end
