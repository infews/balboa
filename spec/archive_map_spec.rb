RSpec.describe Balboa::ArchiveMap do
  let(:map) { Balboa::ArchiveMap.new(source_files, archive_root) }

  let(:source_files) { [file_1, file_2, file_3] }
  let(:archive_root) { "archives" }

  let(:file_1) { File.join("foo", "bar", "baz.txt") }
  let(:file_2) { File.join("foo", "bar", "quux.txt") }
  let(:file_3) { File.join("foo", "bar", "zipp.jpg") }
  let(:not_present) { "not_present_file.txt" }

  describe "#archive_root" do
    it "is available" do
      expect(map.archive_root).to eq(archive_root)
    end
  end

  describe "Enumerable behavior" do
    describe "#each" do
      it "delegates to the underlying collection of entries" do
        map.each do |entry|
          expect(entry).to be_a(Balboa::ArchiveMapEntry)
        end
      end
    end

    describe "#length" do
      it "delegates to the underlying collection of entries" do
        expect(map.length).to eq(3)
      end
    end

    describe "#delete" do
      it "delegates to the underlying collection of entries" do
        map.delete(file_2)

        expect(map.length).to eq(2)

        map.delete(not_present)

        expect(map.length).to eq(2)
      end
    end

    describe "#find" do
      it "delegates to the underlying collection of entries" do
        entry = map.find(file_3)
        expect(entry.source).to eq(file_3)
      end
    end

    describe "#include?" do
      it "delegates to the underlying collection of entries" do
        expect(map).to include(file_1)
        expect(map).to include(file_2)
        expect(map).to include(file_3)
        expect(map).to_not include(not_present)
      end
    end
  end
end
