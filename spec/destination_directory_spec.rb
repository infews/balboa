RSpec.describe Balboa::DestinationDirectory do
  let(:destination) { Balboa::DestinationDirectory.new }
  let(:filename) {"2018.07.12.Allstate.Automobile.904150241.Statements.pdf"}

  describe "#directory" do
    it "returns a directory name with year and month" do
      expect(destination.directory_for(filename)).to eq("2018/07.Jul")
    end
  end

  xit "handles error cases"
end
