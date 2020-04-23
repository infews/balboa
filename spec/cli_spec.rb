RSpec.describe Balboa::CLI do
  let(:cli) { Balboa::CLI.new }
  let(:test_root_dir) { "spec_balboa_gem" }
  let(:filethis) { File.join(Dir.tmpdir, test_root_dir, "filethis") }
  let(:archive) { File.join(Dir.tmpdir, test_root_dir, "archive") }

  before do
    Rainbow.enabled = false
  end

  describe "#archive_filethis" do
    context "when then source directory doesn't exist" do
      let(:filethis) { "foo" }

      it "raises an error" do
        expect {
          cli.archive_filethis filethis, archive
        }.to raise_error(Balboa::NoSourceDirectoryError)
      end
    end

    context "when the archive root directory doesn't exist" do
      let(:archive) { "archive_not_present" }

      before do
        Dir.chdir(Dir.tmpdir) do
          FileUtils.mkdir_p File.join(test_root_dir, "filethis")
        end
      end

      it "raises an error" do
        expect {
          cli.archive_filethis filethis, archive
        }.to raise_error(Balboa::NoArchiveDirectoryError)
      end
    end

    context "when no PDFs are in the source directory" do
      before do
        Dir.chdir(Dir.tmpdir) do
          FileUtils.mkdir_p File.join(test_root_dir, "filethis")
          FileUtils.mkdir_p File.join(test_root_dir, "archive")
        end
      end

      it "ends and is helpful" do
        expect {
          cli.archive_filethis filethis, archive
        }.to output(/No PDFs found in #{filethis}\./).to_stdout
      end
    end

    context "integration (happy path)" do
      let(:matchable_file1) { "Allstate 2018-01-04.pdf" }
      let(:matchable_file2) { "Allstate 2018-02-04.pdf" }

      let(:unmatchable_file1) { "foo-bar.pdf" }
      let(:unmatchable_file2) { "baz-quux.pdf" }

      let(:renamed_file) { "2018.02.11.Comcast.pdf_1" }

      let(:archived_file1) { File.join(archive, "2018", "01.Jan", "2018.01.04.Allstate.pdf") }
      let(:archived_file2) { File.join(archive, "2018", "02.Feb", "2018.02.04.Allstate.pdf") }
      let(:present_file) { File.join(archive, "2018", "02.Feb", "2018.02.11.Comcast.pdf") }

      before do
        Dir.chdir(Dir.tmpdir) do
          # build a file this directory tree
          FileUtils.mkdir_p File.join(test_root_dir, "filethis", "Allstate 1")
          FileUtils.mkdir_p File.join(test_root_dir, "filethis", "Comcast")

          # build an archive directory tree (for holding the present file)
          FileUtils.mkdir_p File.join(test_root_dir, "archive", "2018", "02.Feb")

          Dir.chdir(test_root_dir) do
            # all the FileThis files
            Dir.chdir(filethis) do
              FileUtils.touch File.join("Allstate 1", matchable_file1)
              FileUtils.touch File.join("Allstate 1", matchable_file2)
              FileUtils.touch File.join("Comcast", unmatchable_file1)
              FileUtils.touch File.join("Comcast", unmatchable_file2)
            end

            # all the present files
            Dir.chdir(archive) do
              FileUtils.touch(present_file)
            end
          end
        end
      end

      after do
        FileUtils.rm_rf File.join(Dir.tmpdir, test_root_dir)
      end

      it "lists the source folder scanning" do
        expect {
          cli.archive_filethis filethis, archive
        }.to output(/Looking for FileThis PDFs in #{filethis} to rename and archive./).to_stdout
      end

      it "lists files that will be skipped because they can't be matched" do
        expect {
          cli.archive_filethis filethis, archive
        }.to output(/Skipping these files as they are not renameable:.*|baz-quux\.pdf|foo-bar\.pdf/).to_stdout
      end

      it "copies the files" do
        cli.archive_filethis filethis, archive
        expect(File).to exist(archived_file1)
        expect(File).to exist(archived_file2)
      end

      it "lists files that were copied" do
        expect {
          cli.archive_filethis filethis, archive
        }.to output(/Added 2 files to the archive:.*|archive\/2018\/01\.Jan\/2018\.01\.04\.Allstate\.pdf|archive\/2018\/02\.Feb\/2018\.02\.04\.Allstate\.pdf/).to_stdout
      end
    end
  end

  describe "make_archive_folders" do
    let(:archive) { File.join(Dir.tmpdir, test_root_dir, "archive") }

    before do
      Timecop.freeze(Time.local(1999))
      Dir.chdir(Dir.tmpdir) do
        FileUtils.mkdir_p test_root_dir
      end
    end

    after do
      Timecop.return
      FileUtils.rm_rf File.join(Dir.tmpdir, test_root_dir)
    end

    it "makes the year folder for the current year" do
      suppress_output do
        cli.make_archive_folders archive
      end

      expect(File.exist?(File.join(archive, "Personal", "1999"))).to eq(true)
    end

    it "makes the month folders under the year folder" do
      suppress_output do
        cli.make_archive_folders archive
      end

      expect(File.exist?(File.join(archive, "Personal", "1999", "01.Jan"))).to eq(true)
      expect(File.exist?(File.join(archive, "Personal", "1999", "02.Feb"))).to eq(true)
      expect(File.exist?(File.join(archive, "Personal", "1999", "03.Mar"))).to eq(true)
      expect(File.exist?(File.join(archive, "Personal", "1999", "04.Apr"))).to eq(true)
      expect(File.exist?(File.join(archive, "Personal", "1999", "05.May"))).to eq(true)
      expect(File.exist?(File.join(archive, "Personal", "1999", "06.Jun"))).to eq(true)
      expect(File.exist?(File.join(archive, "Personal", "1999", "07.Jul"))).to eq(true)
      expect(File.exist?(File.join(archive, "Personal", "1999", "08.Aug"))).to eq(true)
      expect(File.exist?(File.join(archive, "Personal", "1999", "09.Sep"))).to eq(true)
      expect(File.exist?(File.join(archive, "Personal", "1999", "10.Oct"))).to eq(true)
      expect(File.exist?(File.join(archive, "Personal", "1999", "11.Nov"))).to eq(true)
      expect(File.exist?(File.join(archive, "Personal", "1999", "12.Dec"))).to eq(true)
    end

    it "makes a tax folder" do
      suppress_output do
        cli.make_archive_folders archive
      end

      expect(File.exist?(File.join(archive, "Personal", "1999", "1999.Tax"))).to eq(true)
    end

    it "makes a media archve" do
      suppress_output do
        cli.make_archive_folders archive
      end

      expect(File.exist?(File.join(archive, "Personal", "1999", "1999.MediaArchive"))).to eq(true)
    end
  end
end
