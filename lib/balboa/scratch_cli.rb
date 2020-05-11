def archive_filethis(source, archive_root)
  raise NoSourceDirectoryError.new("Source directory #{source} does not exist.") unless File.exist? source
  raise NoArchiveDirectoryError.new("Archive root #{archive_root} does not exist.") unless File.exist?(archive_root)

  pdfs = Dir.glob("#{source}/**/*.pdf").sort
  puts("No PDFs found in #{source}.".red) && return if pdfs.length == 0

  puts "Looking for FileThis PDFs in ".cyan + source.to_s + " to rename and archive...".cyan
  puts "Found #{pdfs.length} total PDFs.".cyan

  file_this_map = FileThisFileMap.new(pdfs, archive_root)

  excluded = file_this_map.remove_failed_matches

  if excluded.length > 0
    puts "Skipping these #{excluded.length} files as they are not renameable:".yellow
    excluded.each { |skip| puts skip }
  end

  file_this_map.rename_all_files
  file_this_map.remove_files_already_in_the_archive

  file_count = file_this_map.length
  raise NoFilesToArchiveError.new if file_count == 0 # I'm sorry, but return wasn't working here

  puts "Archiving ".green + file_count.to_s + " files...".green
  count = CopyArchiver.archive(file_map)

  puts "Added #{count} files to the archive.".cyan
rescue NoFilesToArchiveError
  puts "No new files found to archive.".yellow
end
