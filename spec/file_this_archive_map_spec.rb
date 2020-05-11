RSpec.describe Balboa::FileThisArchiveMap do
  let(:map) { Balboa::FileThisArchiveMap.new(source_files, archive_root) }

  let(:source_files) { [file_this_path_1, file_this_path_2, file_this_path_3] }
  let(:archive_root) { "archives" }

  let(:file_this_path_1) { File.join("foo", "bar", "Allstate Automobile 904150241 Statements 2018-07-12.pdf") }
  let(:file_this_path_2) { File.join("foo", "bar", "Allstate Automobile 904150241 Statements 2018-08-12.pdf") }
  let(:file_this_path_3) { File.join("foo", "bar", "Allstate Automobile 904150241 Statements 2019-01-11.pdf") }
  let(:not_present) { "not_present_file.txt" }

  describe "#remove_failed_matches" do
    let(:poorly_named) { File.join("foo", "bar", "poorly_named.pdf") }
    let(:not_a_pdf) { File.join("foo", "bar", "not_a_pdf.txt") }
    let(:source_files) { [file_this_path_1, poorly_named, not_a_pdf] }

    let!(:excluded) { map.remove_failed_matches }

    it "removes non PDFs" do
      expect(map).to_not include(not_a_pdf)
      expect(excluded).to include(not_a_pdf)
    end

    it "removes files that don't match the FileThis naming conventions" do
      expect(map).to_not include(poorly_named)
      expect(excluded).to include(poorly_named)
    end
  end

  describe "#name_destination_files" do
    before do
      map.name_destination_files
    end
    it "renames all the files to the archive format" do
      expect(map.length).to eq(3)
      expect(map).to include(file_this_path_1)
      expect(map).to include(file_this_path_2)
      expect(map).to include(file_this_path_3)

      expect(map.entry_for(file_this_path_1).destination_basename).to eq("2018.07.12.Allstate.Automobile.904150241.Statements.pdf")
    end
  end

  describe "#remove_files_already_in_the_archive" do
    let(:archived_file_this_path_1) { File.join(archive_root, "2018", "07.Jul", "2018.07.12.Allstate.Automobile.904150241.Statements.pdf") }
    let(:archived_file_this_path_2) { File.join(archive_root, "2018", "08.Aug", "2018.08.12.Allstate.Automobile.904150241.Statements.pdf") }
    let(:archived_file_this_path_3) { File.join(archive_root, "2019", "01.Jan", "2019.01.11.Allstate.Automobile.904150241.Statements.pdf") }

    before do
      allow(File).to receive(:exist?).with(archived_file_this_path_1).and_return(false)
      allow(File).to receive(:exist?).with(archived_file_this_path_2).and_return(false)
      allow(File).to receive(:exist?).with(archived_file_this_path_3).and_return(true)

      map.name_destination_files
      map.remove_files_already_in_the_archive
    end

    it "removes any file that already exists from the map" do
      expect(map).to include(file_this_path_1)
      expect(map).to include(file_this_path_2)
      expect(map).to_not include(file_this_path_3)
    end
  end
end
