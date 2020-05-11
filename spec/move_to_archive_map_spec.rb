RSpec.describe Balboa::MoveToArchiveMap do
  let(:map) { Balboa::MoveToArchiveMap.new(source_files, archive_root) }

  let(:source_files) { [file_path_1, not_a_match, file_path_2] }

  let(:file_path_1) { File.join("foo", "bar", "2018.01.04.a.file.pdf") }
  let(:file_path_2) { File.join("foo", "2017.12.17.another.file.txt") }
  let(:not_a_match) { File.join("foo", "bar", "not_this_one") }

  let(:archive_root) { "archives" }

  describe "#remove_failed_matches" do
    let!(:excluded) { map.remove_failed_matches }

    it "removes files that are not pre-pended with a date" do
      expect(map.length).to eq(2)
      expect(map).not_to include(not_a_match)
      expect(excluded).to include(not_a_match)
    end
  end

  describe "#determine_destinations" do
    context "after determining destinations" do
      before do
        map.remove_failed_matches
        map.determine_destinations
      end
      it "fills out the file_map with the correct destinations" do
        expect(map.length).to eq(2)
        expect(map.entry_for(file_path_1).destination)
          .to eq(File.join("2018", "01.Jan", "2018.01.04.a.file.pdf"))
        expect(map.entry_for(file_path_2).destination)
          .to eq(File.join("2017", "12.Dec", "2017.12.17.another.file.txt"))
      end
    end
  end
end
