RSpec.describe Balboa::CollisionResolver do
  let(:resolver) { Balboa::CollisionResolver.new(current_file_map) }
  let(:current_file_map) {
    {"foo/bar/no_collision.txt" => "dest/2010.04.01.no_collision.txt",
     "foo/bar/collision.txt" => "dest/2010.04.03.collision.txt",
     "foo/bar/baz/another_no_collision.txt" => "dest/2010.04.05.no_collision.txt"}
  }

  describe "#file_map" do
    it "returns the current file_map" do
      expect(resolver.file_map).to eq(current_file_map)
    end
  end

  describe "#remove_files_without_collisions" do
    before do
      allow(File).to receive(:exist?).with("dest/2010.04.01.no_collision.txt").and_return(false)
      allow(File).to receive(:exist?).with("dest/2010.04.03.collision.txt").and_return(true)
      allow(File).to receive(:exist?).with("dest/2010.04.05.no_collision.txt").and_return(false)
    end

    it "removes the files which have a destination that does not exist" do
      no_collisions = resolver.remove_files_without_collisions

      expect(no_collisions).to eq({
        "foo/bar/no_collision.txt" => "dest/2010.04.01.no_collision.txt",
        "foo/bar/baz/another_no_collision.txt" => "dest/2010.04.05.no_collision.txt"
      })
      expect(resolver.file_map).to eq({"foo/bar/collision.txt" => "dest/2010.04.03.collision.txt"})
    end
  end

  describe "#rename_collisions" do
    context "when there is no collision with the rename" do
      context "when the destination path does not have an extension" do
        let(:current_file_map) {
          {"foo/bar/collision" => "dest/2010.04.03.collision"}
        }
        before do
          allow(File).to receive(:exist?).with("dest/2010.04.03.collision").and_return(true)
          allow(File).to receive(:exist?).with("dest/2010.04.03.collision_1").and_return(false)
          resolver.rename_collisions
        end

        it "updates the map with destinations that no longer collide" do
          expect(resolver.file_map).to eq({"foo/bar/collision" => "dest/2010.04.03.collision_1"})
        end
      end

      context "when the destination path has an extension" do
        let(:current_file_map) {
          {"foo/bar/collision.txt" => "dest/2010.04.03.collision.txt"}
        }
        before do
          allow(File).to receive(:exist?).with("dest/2010.04.03.collision.txt").and_return(true)
          allow(File).to receive(:exist?).with("dest/2010.04.03.collision.txt_1").and_return(false)
          resolver.rename_collisions
        end

        it "updates the map with destinations that no longer collide" do
          expect(resolver.file_map).to eq({"foo/bar/collision.txt" => "dest/2010.04.03.collision.txt_1"})
        end
      end

      context "when there are multiple collisions in the renaming" do
        let(:current_file_map) {
          {"foo/bar/collision.txt" => "dest/2010.04.03.collision.txt"}
        }
        before do
          allow(File).to receive(:exist?).with("dest/2010.04.03.collision.txt").and_return(true)
          allow(File).to receive(:exist?).with("dest/2010.04.03.collision.txt_1").and_return(true)
          allow(File).to receive(:exist?).with("dest/2010.04.03.collision.txt_2").and_return(true)
          allow(File).to receive(:exist?).with("dest/2010.04.03.collision.txt_3").and_return(false)
          resolver.rename_collisions
        end

        it "updates the map with destinations that no longer collide" do
          expect(resolver.file_map).to eq({"foo/bar/collision.txt" => "dest/2010.04.03.collision.txt_3"})
        end
      end
    end
  end
end

#
# foo.txt => foo_1.txt
# foo => foo_1
#
