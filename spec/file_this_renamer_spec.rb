RSpec.describe Balboa::FileThisRenamer do
  let(:renamer) { Balboa::FileThisRenamer.new }

  describe "#rename" do
    context "when the full date is present in the input" do
      let(:existing_filename) { "Allstate Automobile 904150241 Statements 2018-07-12.pdf" }

      it "builds a new filename, .-delimited and converted to MMMM.YY.DD format" do
        expect(renamer.new_name_for(existing_filename)).to eq("2018.07.12.Allstate.Automobile.904150241.Statements.pdf")
      end
    end

    context "when FileThis adds text after the date because of collisions" do
      let(:existing_filename) {"Allstate Automobile 904150241 Statements 2018-07-12 4.pdf"}

      it "builds a new filename" do
        expect(renamer.new_name_for(existing_filename)).to eq("2018.07.12.Allstate.Automobile.904150241.Statements.4.pdf")
      end
    end
  end
end
