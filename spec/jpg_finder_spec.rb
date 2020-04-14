RSpec.describe Balboa::JPGFinder do
  let(:finder) { Balboa::JPGFinder.new }

  describe "#find" do
    context "when there are no files" do
      let(:glob) { [] }
      it "returns an empty array if no JPEG files are found" do
        expect(finder.find(glob)).to eq([])
      end
    end

    context "when there are files" do
      let(:glob) {
        [
          "tmp/zip/IMG_3.jpg",
          "tmp/zip/IMG_4.JPG",
          "tmp/zip/up/two.JPEG",
          "tmp/a.pdf",
          "tmp/zip/bar.text",
          "tmp/zip/up/one.jpeg",
        ]
      }
      it "returns all JPEG files found in the supplied path" do
        expect(finder.find(glob).sort).to eq(["tmp/zip/IMG_3.jpg", "tmp/zip/IMG_4.JPG", "tmp/zip/up/one.jpeg", "tmp/zip/up/two.JPEG"].sort)
      end
    end
  end
end
