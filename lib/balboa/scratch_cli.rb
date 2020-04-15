def archive_filethis(source, archive_root)
  puts "Archiving files from #{source} to #{archive_root}"
  raise Error.new("Stopping: Archive root does not exist") unless File.exist?(archive_root)

  Dir.glob("#{source}/**/*.pdf") # odd bug, need to Dir.glob twice to get the files?
  pdfs = Dir.glob("#{source}/**/*.pdf").sort

  copy_map = FileThisMap.new.copy_map_for(pdfs, FileThisRenamer.new)

  copy_map.each do |entry|
    # entry[:original_full_path] = 'foo/bar/baz 2010-11-02.pdf'
    # entry[:destination_dir] = "2010/11.Nov"
    # entry[:new_name] = "2010.11.02.baz.pdf"

    destination_directory = File.join(archive_root, entry[:destination_directory])
    unless File.exist? destination_directory
      FileUtils.mkdir_p destination_directory
    end

    full_destination_path = File.join(destination_directory, entry[:new_name])
    if File.exist? full_destination_path
      puts "Skipping #{pdf_name} as #{entry[:new_name]} is already in the archive" if options[:versbose]
      next
    end

    puts Rainbow("Copying").green + " #{pdf_name} to " + Rainbow(File.join(converter.destination_directory, converter.filename).to_s).green
    FileUtils.cp(path_to_pdf, full_path_to_archived_file)

    # rescue there was a problem
  end

  puts Rainbow("Found #{pdfs.length} PDF files").cyan
  pdfs.each do |path_to_pdf|
    pdf_name = path_to_pdf.split("/").last
    converter = FileThisRenamer.new

    full_path_to_archived_file = File.join(archive_root, converter.destination_directory, converter.filename)

    puts Rainbow("Copying").green + " #{pdf_name} to " + Rainbow(File.join(converter.destination_directory, converter.filename).to_s).green
    FileUtils.cp(path_to_pdf, full_path_to_archived_file)
  rescue
    puts Rainbow("Skipping").red + " #{pdf_name}" + Rainbow(" as we don't know where to archive it").red
  end
end
