RSpec.describe Balboa::FileThisRenamer do
  let(:renamer) { Balboa::FileThisRenamer.new }

  describe "#rename" do
    context "when the full date is present in the input" do
      let(:full_path_to_file) { "foo/bar/Allstate Automobile 904150241 Statements 2018-07-12.pdf" }

      it "builds a new filename, .-delimited and converted to MMMM.YY.DD.everything.els format" do
        expect(renamer.new_name_for(full_path_to_file)).to eq("2018.07.12.Allstate.Automobile.904150241.Statements.pdf")
      end
    end

    context "when FileThis adds text after the date because of collisions" do
      let(:full_path_to_file) {"biz/bam/Allstate Automobile 904150241 Statements 2018-07-12 4.pdf"}

      it "builds a new filename" do
        expect(renamer.new_name_for(full_path_to_file)).to eq("2018.07.12.Allstate.Automobile.904150241.Statements.4.pdf")
      end
    end

    context "when the file doesn't fit our expectations of re-namable" do
      let(:full_path_to_file) {"filename without date.pdf"}
      it "raises and error" do
        expect {
          renamer.new_name_for(full_path_to_file)
        }.to raise_error(Balboa::NoDateInFilenameError)
      end
    end
  end
end
