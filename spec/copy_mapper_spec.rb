RSpec.describe Balboa::CopyMapper do
  let(:mapper) { Balboa::CopyMapper.new }
  let(:renamer) {instance_double("FileThisRenamer")}

  describe "#copy_map_for" do
    context "when there are no renamable files" do
      let(:sources) {[]}
      it "returns an empty map" do
        expect(renamer).not_to receive(:new_name_for)
        expect(mapper.copy_map_for(sources, renamer)).to eq([])
      end
    end

    context "when it operates on good data" do
      let(:sources) {["foo/bar/baz 2010-01-01.pdf", "foo/bar/baz 2011-02-01.pdf"]}
      it "builds a map with the correct format" do
        expect(renamer).to receive(:new_name_for).with("baz 2010-01-01.pdf").and_return("2010.01.01.baz.pdf")
        expect(renamer).to receive(:new_name_for).with("baz 2011-02-01.pdf").and_return("2011.02.01.baz.pdf")

        copy_map = mapper.copy_map_for(sources, renamer)
        expect(copy_map.length).to eq(2)

        entry = copy_map.first
        expect(entry[:original_full_path]).to eq("foo/bar/baz 2010-01-01.pdf")
        expect(entry[:destination_directory]).to eq("2010/01.Jan")
        expect(entry[:new_name]).to eq("2010.01.01.baz.pdf")

        entry = copy_map[1]
        expect(entry[:original_full_path]).to eq("foo/bar/baz 2011-02-01.pdf")
        expect(entry[:destination_directory]).to eq("2011/02.Feb")
        expect(entry[:new_name]).to eq("2011.02.01.baz.pdf")
      end
    end

    context "when the renamer fails" do
      let(:sources) {["foo/bar/baz 2010-01-01.pdf", "foo/bar/skip_me"]}

      it "skips any entry that the renamer doesn't rename" do
        expect(renamer).to receive(:new_name_for).with("baz 2010-01-01.pdf").and_return("2010.01.01.baz.pdf")
        expect(renamer).to receive(:new_name_for).with("skip_me").and_raise(Balboa::NoDateInFilenameError)

        copy_map = mapper.copy_map_for(sources, renamer)
        expect(copy_map.length).to eq(1)

        entry = copy_map.first
        expect(entry[:original_full_path]).to eq("foo/bar/baz 2010-01-01.pdf")
        expect(entry[:destination_directory]).to eq("2010/01.Jan")
        expect(entry[:new_name]).to eq("2010.01.01.baz.pdf")
      end
    end
  end
end

# :included => [], :skipped => []
