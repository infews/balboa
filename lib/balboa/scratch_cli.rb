def move_to_archive(source, archive_root)
  files = Dir.glob("#{source}/**/*").sort
  archiver = MoveArchiver.new(files, archive_root)

  archiver.remove_failed_matches
  archiver.determine_destinations

  archiver.archive
end

def archive_images(source, archive_root)
  Dir.glob("#{source}/**/*.jpg") # odd bug, need to Dir.glob twice to get the files?
  images = Dir.glob("#{source}/**/*.jpg").sort

  exif_data = ExifTool.new(images)
  archiver = ImageArchiver.new(images, archive_root, exif_data)

  excluded = archiver.remove_failed_matches
  puts excluded # we don't know how to rename these

  archiver.name_destination_files

  collider = CollisionResolver.new(archiver.files)

  skipped = collider.remove_files_without_collisions
  puts skipped # these

  collider.rename_collisions
  archiver.update_files(collider.file_map)

  archiver.archive
  puts archiver.files
end
