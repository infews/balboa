RSpec.describe Balboa::MoveArchiver do
  let(:archiver) { Balboa::MoveArchiver.new(source_files, archive_root) }
  let(:source_files) {
    ["foo/bar/2018.01.04.a.file.pdf",
     "foo/bar/not_this_one",
     "foo/2017.12.17.another.file.txt"]
  }
  let(:archive_root) { "archives" }

  describe "#source_files" do
    it "has a the source files added" do
      expect(archiver.source_files).to include("foo/bar/2018.01.04.a.file.pdf")
      expect(archiver.source_files).to include("foo/bar/not_this_one")
      expect(archiver.source_files).to include("foo/2017.12.17.another.file.txt")
    end
  end

  describe "#remove_failed_matches" do
    let!(:excluded) { archiver.remove_failed_matches }

    it "removes files that are not pre-pended with a date" do
      expect(archiver.source_files.length).to eq(2)
      expect(archiver.source_files).not_to include("foo/bar/not_this_one")
      expect(excluded).to include("foo/bar/not_this_one")
    end
  end

  describe "#determine_destinations" do
    context "before determining destinations" do
      it "returns an empty file_map" do
        expect(archiver.file_map).to eq({})
      end
    end

    context "after determining destinations" do
      before do
        archiver.remove_failed_matches
        archiver.determine_destinations
      end
      it "fills out the file_map with the correct destinations" do
        file_map = archiver.file_map
        expect(file_map.length).to eq(2)
        expect(file_map["foo/bar/2018.01.04.a.file.pdf"])
          .to eq("#{archive_root}/2018/01.Jan/2018.01.04.a.file.pdf")
      end
    end
  end

  # For extraction

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
      it "moves files according to the map" do
        archiver.update_file_map({src_file1 => archive_file1, src_file2 => archive_file2})
        archiver.archive

        expect(File).to_not exist(src_file1)
        expect(File).to_not exist(src_file2)
        expect(File).to exist(archive_file1)
        expect(File).to exist(archive_file2)
      end
    end

    it "errors if there are any nils in the map"

    after do
      FileUtils.remove_entry test_root_dir
    end
  end
end
