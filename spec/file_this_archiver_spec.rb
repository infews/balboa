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

  describe "#remove_files_already_in_the_archive" do
    before do
      allow(File).to receive(:exist?).with("#{archive_root}/2018/07.Jul/2018.07.12.Allstate.Automobile.904150241.Statements.pdf").and_return(false)
      allow(File).to receive(:exist?).with("#{archive_root}/2018/08.Aug/2018.08.12.Allstate.Automobile.904150241.Statements.pdf").and_return(false)
      allow(File).to receive(:exist?).with("#{archive_root}/2019/01.Jan/2019.01.11.Allstate.Automobile.904150241.Statements.pdf").and_return(true)
    end

    it "removes any file that already exists from the map" do
      archiver.name_destination_files
      archiver.remove_files_already_in_the_archive

      file_map = archiver.file_map
      expect(file_map.length).to eq(2)
      expect(file_map["foo/bar/Allstate Automobile 904150241 Statements 2018-07-12.pdf"]).to_not be_nil
      expect(file_map["foo/bar/Allstate Automobile 904150241 Statements 2018-08-12.pdf"]).to_not be_nil
      expect(file_map["foo/bar/Allstate Automobile 904150241 Statements 2019-01-11.pdf"]).to be_nil
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
        expect(file_map["foo/bar/Allstate Automobile 904150241 Statements 2018-07-12.pdf"])
          .to eq("#{archive_root}/2018/07.Jul/2018.07.12.Allstate.Automobile.904150241.Statements.pdf")
      end
    end
  end

  describe "#new_destination_path_for" do
    let(:full_path_to_file) { "filename without date.pdf" }
    it "raises and error" do
      expect {
        archiver.new_destination_path_for(full_path_to_file)
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
      expect(file_map["foo/bar/a 2018-07-12.pdf"]).to eq(File.join("archives", "2018", "07.Jul", "2018.07.12.a.pdf"))
      expect(file_map["foo/bar/a 2018-08-12.pdf"]).to eq("something else")
    end
  end

  describe "#destintation_directory_for" do
    it "calculates a destination directory based on an archive filename" do
      expect(archiver.destination_directory_for("2018.07.12.foobar.txt")).to eq("2018/07.Jul")
    end
  end

  describe "#archive" do
    let(:test_root_dir) { Dir.mktmpdir("spec_balboa_gem") }
    let(:src_file1) { File.join(test_root_dir, "src", "file1") }
    let(:src_file2) { File.join(test_root_dir, "src", "file2") }
    let(:archive_file1) { File.join(test_root_dir, "dst", "file1") }
    let(:archive_file2) { File.join(test_root_dir, "dst", "file2") }

    before do
      Dir.chdir(test_root_dir) do
        FileUtils.mkdir_p("src")
        FileUtils.touch(File.join("src", "file1"))
        FileUtils.touch(File.join("src", "file2"))

        FileUtils.mkdir_p(File.join("dst"))
      end
    end

    context "with a valid file map" do
      it "copies files according to the map" do
        archiver.update_file_map({src_file1 => archive_file1, src_file2 => archive_file2})
        archiver.archive

        expect(File).to exist(archive_file1)
        expect(File).to exist(archive_file2)
      end
    end

    it "errors if there are any nils in the map"

    after do
      FileUtils.remove_entry test_root_dir
    end
  end

  context "(integration)" do
    it "does it all "
  end
end
