RSpec.describe Balboa::ImageArchiver do
  let(:archiver) { Balboa::ImageArchiver.new(source_files, archive_root) }
  let(:source_files) { ["foo/bar/IMG_6118.JPEG", "foo/bar/IMG_6119.jpeg"] }
  let(:archive_root) { "archives" }
  let(:exif_tool) {
    dbl = double("ExifTool")
    allow(dbl).to receive(:result_for)
  }

  before do
    allow(exif_tool).to receive(:result_for).with("foo/bar/IMG_6118.JPEG").and_return({model: "Canon EOS 20D", date: Date.new(2019, 12, 16)})
    allow(exif_tool).to receive(:result_for).with("foo/bar/IMG_6119.jpeg").and_return({model: "Canon EOS 20D", date: Date.new(2019, 12, 16)})
    allow(exif_tool).to receive(:result_for).with("foo/bar/IMG_7000.jpeg").and_return(nil)
  end

  describe "#source_files" do
    it "has the source files added" do
      expect(archiver.source_files).to include("foo/bar/IMG_6118.JPEG")
      expect(archiver.source_files).to include("foo/bar/IMG_6119.jpeg")
    end
  end

  describe "#remove_files_without_exif" do
    let(:source_files) { ["foo/bar/IMG_6118.JPEG", "foo/bar/IMG_6119.jpeg", "foo/bar/IMG_7000.jpeg"] }

    it "removes files from the #source_files without corresponding EXIF data" do
      archiver.exif_tool = exif_tool
      excluded = archiver.remove_files_without_exif

      expect(archiver.source_files).to include("foo/bar/IMG_6118.JPEG")
      expect(archiver.source_files).to include("foo/bar/IMG_6119.jpeg")
      expect(archiver.source_files).to_not include("foo/bar/IMG_7000.jpeg")

      expect(excluded.length).to eq(1)
      expect(excluded).to include("foo/bar/IMG_7000.jpeg")
    end
  end

  describe "#file_map" do
    context "before mapping" do
      it "returns an empty hash if rename hasn't happened" do
        expect(archiver.file_map).to eq({})
      end
    end

    context "after mapping" do
      let(:source_files) { ["foo/bar/IMG_6118.JPEG", "foo/bar/IMG_6119.jpeg"] }

      it "builds a full destination path for supplied source files" do
        archiver.exif_tool = exif_tool
        archiver.build_file_map
        file_map = archiver.file_map

        expect(file_map.length).to eq(2)
        expect(file_map["foo/bar/IMG_6118.JPEG"]).to eq("#{archive_root}/2019/12.Dec/2019.12.16.CanonEOS20D.IMG_6118.JPEG")
        expect(file_map["foo/bar/IMG_6119.jpeg"]).to eq("#{archive_root}/2019/12.Dec/2019.12.16.CanonEOS20D.IMG_6119.jpeg")
      end
    end
  end

  describe "#more_descriptive_name_for" do
    let(:exif) { {model: "Canon EOS 20D", date: Date.new(2019, 12, 16)} }

    context "when the EXIF data returns a date and model" do
      it "prepends the date and model to a file named *.JPEG" do
        expect(archiver.more_descriptive_name_for("foo/bar/IMG_6118.JPEG", exif)).to eq("2019.12.16.CanonEOS20D.IMG_6118.JPEG")
      end

      it "prepends the date and model to a file named *.jpeg" do
        expect(archiver.more_descriptive_name_for("foo/bar/IMG_6119.jpeg", exif)).to eq("2019.12.16.CanonEOS20D.IMG_6119.jpeg")
      end

      it "prepends the date and model to a file named *.JPG" do
        expect(archiver.more_descriptive_name_for("foo/bar/IMG_6120.JPG", exif)).to eq("2019.12.16.CanonEOS20D.IMG_6120.JPG")
      end

      it "prepends the date and model to a file named *.jpg" do
        expect(archiver.more_descriptive_name_for("foo/bar/IMG_6118.jpg", exif)).to eq("2019.12.16.CanonEOS20D.IMG_6118.jpg")
      end

      it "prepends the date and model to a file named *.HEIC" do
        expect(archiver.more_descriptive_name_for("foo/bar/IMG_6118.HEIC", exif)).to eq("2019.12.16.CanonEOS20D.IMG_6118.HEIC")
      end

      it "prepends the date and model to a file named *.heic" do
        expect(archiver.more_descriptive_name_for("foo/bar/IMG_6118.heic", exif)).to eq("2019.12.16.CanonEOS20D.IMG_6118.heic")
      end
    end

    context "when the EXIF is not present for a file" do
      let(:exif) { nil }
    end

    context "when the EXIF does not include a date" do
      context "when the date is empty" do
        let(:exif) { {model: "Canon EOS 20D", date: ""} }

        it "uses an odd date as a flag" do
          expect(archiver.more_descriptive_name_for("foo/bar/IMG_6118.JPG", exif)).to eq("3001.01.01.CanonEOS20D.IMG_6118.JPG")
        end
      end
      context "when the date is nil" do
        let(:exif) { {model: "Canon EOS 20D"} }
        it "uses an odd date as a flag" do
          expect(archiver.more_descriptive_name_for("foo/bar/IMG_6118.JPG", exif)).to eq("3001.01.01.CanonEOS20D.IMG_6118.JPG")
        end
      end
    end

    context "when the EXIF does not include a model" do
      context "when the model is empty" do
        let(:exif) { {model: "", date: Date.new(2019, 12, 16)} }

        it "uses an odd date as a flag" do
          expect(archiver.more_descriptive_name_for("foo/bar/IMG_6118.JPG", exif)).to eq("2019.12.16.Unknown.IMG_6118.JPG")
        end
      end
      context "when the model is nil" do
        let(:exif) { {date: Date.new(2019, 12, 16)} }

        it "uses an odd date as a flag" do
          expect(archiver.more_descriptive_name_for("foo/bar/IMG_6118.JPG", exif)).to eq("2019.12.16.Unknown.IMG_6118.JPG")
        end
      end
    end
  end
end
