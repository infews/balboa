RSpec.describe Balboa::CopyArchiver do
  let(:test_root_dir) { Dir.mktmpdir "spec_balboa_gem_" }

  let(:archiver) { Balboa::CopyArchiver.new(map) }

  let(:path_1) { File.join("foo", "bar", "2019.01.01.file_1.txt") }
  let(:path_2) { File.join("foo", "bar", "2018.08.04.file_2.jpg") }
  let(:path_3) { File.join("foo", "file_3.pdf") }

  let(:archive_root) { "archive_root" }

  let(:map) { Balboa::ArchiveMap.new([path_1, path_2], archive_root) }

  before do
    Dir.chdir(test_root_dir) do
      FileUtils.mkdir_p File.join("foo", "bar")
      FileUtils.touch path_1
      FileUtils.touch path_2
      FileUtils.touch path_3

      FileUtils.mkdir_p "archive_root"
    end
  end

  after do
    FileUtils.remove_entry test_root_dir
  end

  describe "#archive" do
    before do
      map.each { |entry| entry.destination_basename = File.basename(entry.source) }

      Dir.chdir(test_root_dir) do
        archiver.archive
      end
    end

    it "copies the files to the destination directory" do
      Dir.chdir(test_root_dir) do
        expect(File).to exist(File.join(archive_root, "2019", "01.Jan", "2019.01.01.file_1.txt"))
        expect(File).to exist(File.join(archive_root, "2018", "08.Aug", "2018.08.04.file_2.jpg"))
        expect(Dir.glob(File.join(archive_root, "**", "file_3.pdf")))
      end
    end
  end
end
