module Balboa
  class CollisionResolver
    attr_reader :file_map

    def initialize(file_map)
      @file_map = file_map
    end

    def remove_files_without_collisions
      collisions, no_collisions = @file_map.partition { |source_path, destination_path|
        File.exist? destination_path
      }
      @file_map = collisions.to_h
      no_collisions.to_h
    end

    def rename_collisions
      @file_map = @file_map.each_with_object({}) { |(source_path, destination_path), new_map|
        new_path = destination_path
        if File.exist? destination_path
          new_path = non_colliding_name_for(destination_path)
        end
        new_map[source_path] = new_path
        new_map
      }
    end

    private

    def non_colliding_name_for(destination_path)
      index = 0
      new_name = destination_path

      while File.exist?(new_name)
        index += 1
        new_name = "#{destination_path}_#{index}"
      end

      new_name
    end
  end
end
