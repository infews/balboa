RSpec.describe Balboa::ArchiveMapEntry do
  let(:entry) { Balboa::ArchiveMapEntry.new(source) }
  let(:source) { "foo/bar/a_file.txt" }

  describe "#source" do
    it "available" do
      expect(entry.source).to eq("foo/bar/a_file.txt")
    end
  end

  describe "equality" do
    it "is based on value of source" do
      equal_entry = Balboa::ArchiveMapEntry.new("foo/bar/a_file.txt")
      expect(entry == equal_entry).to eq(true)

      unequal_entry = Balboa::ArchiveMapEntry.new("baz/quux.jpg")
      expect(entry == unequal_entry).to eq(false)
    end
  end

  describe "#destination" do
    it "returns a constructed path to the file" do
      entry.destination_basename = "2019.01.01.foo_bar.txt"

      expect(entry.destination).to eq(File.join(entry.destination_path, entry.destination_basename))
    end
  end

  describe "#destination_basename" do
    it "is an available accessor" do
      expect(entry.destination_basename).to be_nil
      entry.destination_basename = "renamed_file.txt"
      expect(entry.destination_basename).to eq("renamed_file.txt")
    end
  end

  describe "#destination_path" do
    context "when there is no destination basename" do
      it "is nil" do
        expect(entry.destination_path).to be_nil
      end
    end

    context "when the destination basename does not match the naming convention" do
      it "is nil" do
        entry.destination_basename = "renamed_file.txt"

        expect(entry.destination_path).to be_nil
      end
    end

    context "when the destination basename does match the naming convention" do
      it "is the correct year/month directory tree" do
        entry.destination_basename = "2019.01.01.foo_bar.txt"

        expect(entry.destination_path).to eq(File.join("2019", "01.Jan"))
      end
    end
  end
end
