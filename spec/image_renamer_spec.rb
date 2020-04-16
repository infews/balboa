RSpec.describe Balboa::ImageRenamer do
  let(:renamer) { Balboa::ImageRenamer.new }
  describe "#rename" do
    let(:exif) { {model: "Canon EOS 20D", date: Date.new(2019, 12, 16)} }

    context "when the EXIF data returns a date and model" do
      it "prepends the date and model to a file named *.JPEG" do
        expect(renamer.new_name_for("foo/bar/IMG_6118.JPEG", exif)).to eq("2019.12.16.CanonEOS20D.IMG_6118.JPEG")
      end

      it "prepends the date and model to a file named *.jpeg" do
        expect(renamer.new_name_for("foo/bar/IMG_6118.jpeg", exif)).to eq("2019.12.16.CanonEOS20D.IMG_6118.jpeg")
      end

      it "prepends the date and model to a file named *.JPG" do
        expect(renamer.new_name_for("foo/bar/IMG_6118.JPG", exif)).to eq("2019.12.16.CanonEOS20D.IMG_6118.JPG")
      end

      it "prepends the date and model to a file named *.jpg" do
        expect(renamer.new_name_for("foo/bar/IMG_6118.jpg", exif)).to eq("2019.12.16.CanonEOS20D.IMG_6118.jpg")
      end

      it "prepends the date and model to a file named *.HEIC" do
        expect(renamer.new_name_for("foo/bar/IMG_6118.HEIC", exif)).to eq("2019.12.16.CanonEOS20D.IMG_6118.HEIC")
      end

      it "prepends the date and model to a file named *.heic" do
        expect(renamer.new_name_for("foo/bar/IMG_6118.heic", exif)).to eq("2019.12.16.CanonEOS20D.IMG_6118.heic")
      end
    end

    context "when the EXIF does not include a date" do
    end
  end
end
