RSpec.describe Balboa::CopyMapper do
  let(:mapper) { Balboa::CopyMapper.new }
  let(:renamer) { double("Renamer") }
  let(:copy_map) {
    mapper.copy_map_for(sources) { |full_path| renamer.new_destination_path_for(full_path) }
  }

  describe "#copy_map_for" do
    context "when there are no renamable files" do
      let(:sources) { [] }
      it "returns an empty map" do
        expect(renamer).not_to receive(:new_destination_path_for)
        expect(copy_map).to eq({included: [], excluded: []})
      end
    end

    context "when it operates only files to be included" do
      let(:sources) { ["foo/bar/baz 2010-01-01.pdf", "foo/bar/baz 2011-02-01.pdf"] }

      before do
        expect(renamer).to receive(:new_destination_path_for).with("foo/bar/baz 2010-01-01.pdf").and_return("2010.01.01.baz.pdf")
        expect(renamer).to receive(:new_destination_path_for).with("foo/bar/baz 2011-02-01.pdf").and_return("2011.02.01.baz.pdf")
      end

      it "builds an included map with the correct format" do
        included = copy_map[:included]
        expect(included.length).to eq(2)

        entry = included.first
        expect(entry[:original_full_path]).to eq("foo/bar/baz 2010-01-01.pdf")
        expect(entry[:destination_directory]).to eq("2010/01.Jan")
        expect(entry[:new_name]).to eq("2010.01.01.baz.pdf")

        entry = included[1]
        expect(entry[:original_full_path]).to eq("foo/bar/baz 2011-02-01.pdf")
        expect(entry[:destination_directory]).to eq("2011/02.Feb")
        expect(entry[:new_name]).to eq("2011.02.01.baz.pdf")
      end

      it "builds an empty excluded map" do
        expect(copy_map[:excluded].length).to eq(0)
      end
    end

    context "when the sources list includes files that should be excluded" do
      let(:sources) { ["foo/bar/baz 2010-01-01.pdf", "foo/bar/skip_me"] }

      before do
        expect(renamer).to receive(:new_destination_path_for).with("foo/bar/baz 2010-01-01.pdf").and_return("2010.01.01.baz.pdf")
        expect(renamer).to receive(:new_destination_path_for).with("foo/bar/skip_me").and_raise(Balboa::NoDateInFilenameError)
      end

      it "includes files it knows how to rename" do
        included = copy_map[:included]
        expect(included.length).to eq(1)

        entry = included.first
        expect(entry[:original_full_path]).to eq("foo/bar/baz 2010-01-01.pdf")
        expect(entry[:destination_directory]).to eq("2010/01.Jan")
        expect(entry[:new_name]).to eq("2010.01.01.baz.pdf")
      end

      it "skips any entry that the renamer doesn't rename" do
        excluded = copy_map[:excluded]
        expect(excluded.length).to eq(1)

        entry = excluded.first
        expect(entry).to eq("foo/bar/skip_me")
      end
    end
  end
end
