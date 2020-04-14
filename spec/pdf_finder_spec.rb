RSpec.describe Balboa::PDFFinder do
  let(:finder) { Balboa::PDFFinder.new }

  describe "#find" do
    context "when there are no files" do
      let(:glob) { [] }
      it "returns an empty array if no PDFs found" do
        expect(finder.find(glob)).to eq([])
      end
    end

    context "when there are files" do
      let(:glob) {
        [
          "/foo/bar/a.pdf",
          "/foo/bar/baz/b.pdf",
          "/foo/bar/baz/c.jpg",
          "/foo/bar/baz/d.text",
          "/foo/bar/baz/d.pdf",
        ]
      }
      it "returns all PDFs found in the supplied path" do
        expect(finder.find(glob)).to eq(["/foo/bar/a.pdf", "/foo/bar/baz/b.pdf", "/foo/bar/baz/d.pdf"])
      end
    end
  end
end
