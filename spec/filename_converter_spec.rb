RSpec.describe Balboa::FilenameConverter do
  let(:existing_filename) { "Allstate Automobile 904150241 Statements 2018-07-12.pdf" }
  let(:converter) { Balboa::FilenameConverter.new(existing_filename) }

  describe "#filename" do

    context "when the input filename is unique and has a FileThis date in its name" do
      it "builds a new filename" do
        expect(converter.filename).to eq("2018.07.12.Allstate.Automobile.904150241.Statements.pdf")
      end
    end

    context "when FileThis adds text after the date because of collisions" do
      let(:existing_filename) {"Allstate Automobile 904150241 Statements 2018-07-12 4.pdf"}

      it "builds a new filenname" do
        expect(converter.filename).to eq("2018.07.12.Allstate.Automobile.904150241.Statements.4.pdf")
      end

    end
  end

  describe "#destination_directory" do
    context "when the full date is present" do
      it "returns a directory name with year and month" do
        expect(converter.destination_directory).to eq("2018/07.Jul")
      end
    end
  end
end
