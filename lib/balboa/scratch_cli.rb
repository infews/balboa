def archive_filethis(source, archive_root)
  puts "Archiving files from #{source} to #{archive_root}"
  raise Error.new("Stopping: Archive root does not exist") unless File.exist?(archive_root)

  Dir.glob("#{source}/**/*.pdf") # odd bug, need to Dir.glob twice to get the files?
  pdfs = Dir.glob("#{source}/**/*.pdf").sort

  renamer = FileThisRenamer.new
  copy_map = FileThisMap.new.copy_map_for(pdfs) { |full_path_to_pdf|
    renamer.new_name_for(full_path_to_pdf)
  }

  copy_map[:included].each do |file|
    FileUtils.mkdir_p File.join(archive_root, file[:destination_directory])

    full_path_to_archived_file = File.join(archive_root, file[:destination_directory], file[:new_name])
    if File.exist? full_path_to_archived_file
      puts "Skipping #{pdf_name} as #{file[:new_name]} is already in the archive" if options[:versbose]
      next
    end

    puts Rainbow("Copying").green + " #{pdf_name} to " + Rainbow(File.join(converter.destination_directory, converter.filename).to_s).green
    FileUtils.cp(file, full_path_to_archived_file)

    # rescue there was a problem
  end

  copy_map[:skipped].each do |file|
    output
  end
end

# for each included file
#   if named the same and is the same, skip
#   if named the same and is *not* the same, copy with a different name
#   else copy
