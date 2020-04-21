RSpec.describe Balboa::FileThisArchiver do
  let(:archiver) { Balboa::FileThisArchiver.new(source_files, archive_root) }
  let(:source_files) {
    ["foo/bar/Allstate Automobile 904150241 Statements 2018-07-12.pdf",
     "foo/bar/Allstate Automobile 904150241 Statements 2018-08-12.pdf",
     "foo/bar/Allstate Automobile 904150241 Statements 2019-01-11.pdf"]
  }
  let(:archive_root) { "archives" }

  describe "#source_files" do
    it "has a the source files added" do
      expect(archiver.source_files).to include("foo/bar/Allstate Automobile 904150241 Statements 2018-07-12.pdf")
      expect(archiver.source_files).to include("foo/bar/Allstate Automobile 904150241 Statements 2018-08-12.pdf")
      expect(archiver.source_files).to include("foo/bar/Allstate Automobile 904150241 Statements 2019-01-11.pdf")
    end
  end

  describe "#remove_failed_matches" do
    let(:source_files) {
      ["foo/bar/Allstate Automobile 904150241 Statements 2018-07-12.pdf",
       "foo/bar/poorly_named.pdf",
       "foo/bar/not_a_pdf.txt"]
    }
    let!(:excluded) { archiver.remove_failed_matches }

    it "removes non PDFs" do
      expect(archiver.source_files).not_to include("foo/bar/poorly_named.pdf")
      expect(excluded).to include("foo/bar/poorly_named.pdf")
    end

    it "removes files that don't match the FileThis naming conventions" do
      expect(archiver.source_files).not_to include("foo/bar/not_a_pdf.txt")
      expect(excluded).to include("foo/bar/not_a_pdf.txt")
    end
  end

  describe "#file_map" do
    context "before naming/renaming" do
      it "returns an empty hash if rename hasn't happened" do
        expect(archiver.file_map).to eq({})
      end
    end
    context "after naming/renameing" do
      before do
        archiver.name_destination_files
      end
      it "renames all the files to the archive format" do
        file_map = archiver.file_map
        expect(file_map.length).to eq(3)
        expect(file_map["foo/bar/Allstate Automobile 904150241 Statements 2018-07-12.pdf"]).to eq("2018.07.12.Allstate.Automobile.904150241.Statements.pdf")
      end
    end
  end

  describe "#new_name_for" do
    let(:full_path_to_file) { "filename without date.pdf" }
    it "raises and error" do
      expect {
        archiver.new_name_for(full_path_to_file)
      }.to raise_error(Balboa::NoDateInFilenameError)
    end
  end

  # For extraction

  describe "#update_file_map" do
    let(:source_files) { ["foo/bar/a 2018-07-12.pdf", "foo/bar/a 2018-08-12.pdf"] }
    before do
      archiver.name_destination_files
      archiver.update_file_map({"foo/bar/a 2018-08-12.pdf" => "something else"})
    end
    it "merges the input map with the current map" do
      file_map = archiver.file_map
      expect(file_map.length).to eq(2)
      expect(file_map["foo/bar/a 2018-07-12.pdf"]).to eq("2018.07.12.a.pdf")
      expect(file_map["foo/bar/a 2018-08-12.pdf"]).to eq("something else")
    end
  end

  describe "#destintation_directory_for" do
    it "calculates a destination directory based on an archive filename" do
      expect(archiver.destination_directory_for("2018.07.12.foobar.txt")).to eq("2018/07.Jul")
    end
  end

  describe "#archive" do
    it "errors if there are any nils in the map"
    it "archives files according to the map"
  end

  context "(integration)" do
    it "does it all "
  end
end
