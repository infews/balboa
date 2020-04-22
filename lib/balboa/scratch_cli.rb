def archive_filethis(source, archive_root)
  puts "Archiving files from #{source} to #{archive_root}"
  raise Error.new("Stopping: Archive root does not exist") unless File.exist?(archive_root)

  Dir.glob("#{source}/**/*.pdf") # odd bug, need to Dir.glob twice to get the files?
  pdfs = Dir.glob("#{source}/**/*.pdf").sort

  renamer = FileThisRenamer.new
  copy_map = FileThisMap.new.copy_map_for(pdfs) { |full_path_to_pdf|
    renamer.new_name_for(full_path_to_pdf)
  }

  collision_avoider = CollisionAvoider.new
  copy_map[:skipped] = copy_map[:included].each do |entry|
    entry[:new_name] = collision_avoider.non_colliding_name_for(entry)
  end

  copy_map[:included].each do |file|
    FileUtils.mkdir_p File.join(archive_root, file[:destination_directory])
    full_path_to_archived_file = File.join(archive_root, file[:destination_directory], file[:new_name])
    FileUtils.cp(file, full_path_to_archived_file)
  end

  if File.exist? full_path_to_archived_file
    puts "Skipping #{pdf_name} as #{file[:new_name]} is already in the archive" if options[:versbose]
    next
  end

  puts Rainbow("Copying").green + " #{pdf_name} to " + Rainbow(File.join(converter.destination_directory, converter.filename).to_s).green

  copy_map[:exluded].each do |file|
    output
  end

  # rescue there was a problem
end

# loop and parition into included and excluded
# loop included and map soruce => new names
# loop included/new names and partition into non-collisions and collisions
# loop collitions and partition into renames & skips
# loop collisions/renames and rename
# merge included/new names + collisions/new names
# loop new names and make dir, copy
# list skipped
# list excluded
# list copied

def archive_filethis_3(source, archive_root)
  Dir.glob("#{source}/**/*.pdf") # odd bug, need to Dir.glob twice to get the files?
  pdfs = Dir.glob("#{source}/**/*.pdf").sort

  renamer = FileThisRenamer.new
  # keepers, excluded = pdfs.partition do |pdf|
  #   renamer.can_rename?(pdf)
  # end

  keepers, excluded = renamer.split_matches(pdfs)

  puts excluded # we don't know how to rename these

  # renamed = keepers.each_with_object({}) do |pdf, map|
  #   map[pdf] = renamer.new_name_for(pdf)
  # end

  renamed = renamer.new_names_for(keepers)

  # collisions, files_to_archive = renamed.partition do |pdf_entry|
  #   File.exist? pdf_entry.value
  # end

  collider = Collider.new
  collisions, misses = collider.split_collisions_in(renamed)

  # skipped, collisions_to_rename = collisions.partition do |pdf_entry|
  #   # if file hash is the same, return
  # end

  skipped, collisions_to_rename = collider.split_for_renaming_from(collisions)

  puts skipped # these files are not different

  # files_to_archive = collisions_to_rename.each_with_object(files_to_archive) do |collision, files_to_archive|
  #   non_colliding_name = #
  #   files_to_archive[collision.key] => non_colliding_name
  # end

  collisions_to_rename = collider.rename(collisions_to_rename)

  files_to_archive = misses + collisions_to_rename

  files_to_archive.each do |file_entry|
    FileUtils.mkdir_p File.join(archive_root, destination_directory_for(file_entry.key))
    full_path_to_archived_file = File.join(archive_root, destination_directory_for(file_entry.key), file_entry.value)
    FileUtils.cp(file, full_path_to_archived_file)
  end

  puts files_to_archive
  # rescue there was a problem
end

def archive_filethis_4(source, archive_root)
  Dir.glob("#{source}/**/*.pdf") # odd bug, need to Dir.glob twice to get the files?
  pdfs = Dir.glob("#{source}/**/*.pdf").sort

  renamer = FileThisRenamer.new
  keepers, excluded = renamer.split_matches(pdfs)

  puts excluded # we don't know how to rename these

  renamed = renamer.new_names_for(keepers)

  collider = Collider.new
  collisions, misses = collider.split_collisions_in(renamed)

  skipped, collisions_to_rename = collider.split_for_renaming_from(collisions)

  puts skipped # these files are not different, so skip them

  collisions_to_rename = collider.rename(collisions_to_rename)

  files_to_archive = misses + collisions_to_rename

  files_to_archive.sort.each do |file_entry|
    FileUtils.mkdir_p File.join(archive_root, destination_directory_for(file_entry.key))
    full_path_to_archived_file = File.join(archive_root, destination_directory_for(file_entry.key), file_entry.value)
    FileUtils.cp(file, full_path_to_archived_file)
  end

  puts files_to_archive
  # rescue there was a problem
end

def archive_filethis_5(source, archive_root)
  Dir.glob("#{source}/**/*.pdf") # odd bug, need to Dir.glob twice to get the files?
  pdfs = Dir.glob("#{source}/**/*.pdf").sort

  archiver = FileThisArchiver.new(pdfs, archive_root)

  excluded = archiver.remove_failed_matches
  puts excluded # we don't know how to rename these

  archiver.name_destination_files

  collider = CollisionResolver.new(archiver.file_map)

  skipped = collider.remove_files_without_collisions
  puts skipped # these

  collider.rename_destination_files
  archiver.update_filemap(collider.file_map)

  archiver.archive
  puts archiver.file_map.values
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
