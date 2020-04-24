RSpec.describe Balboa::CLI do
  let(:cli) { Balboa::CLI.new }
  let(:test_root_dir) { Dir.mktmpdir "spec_balboa_gem" }
  let(:filethis) { "filethis" }
  let(:filethis_dir) { File.join test_root_dir, filethis }
  let(:archive) { "archive" }
  let(:archive_dir) { File.join test_root_dir, archive }

  describe "#archive_filethis" do
    context "when then source directory doesn't exist" do
      let(:filethis) { "foo" }

      it "raises an error" do
        expect {
          cli.archive_filethis filethis_dir, archive_dir
        }.to raise_error(Balboa::NoSourceDirectoryError)
      end
    end

    context "when the archive root directory doesn't exist" do
      let(:archive) { "archive_not_present" }

      before do
        FileUtils.mkdir_p filethis_dir
      end

      it "raises an error" do
        expect {
          cli.archive_filethis filethis_dir, archive_dir
        }.to raise_error(Balboa::NoArchiveDirectoryError)
      end
    end

    context "when no PDFs are in the source directory" do
      before do
        FileUtils.mkdir_p filethis_dir
        FileUtils.mkdir_p archive_dir
      end

      it "does nothing and is helpful" do
        expect {
          cli.archive_filethis filethis_dir, archive_dir
        }.to output(/No PDFs found in/).to_stdout
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
        Dir.chdir(test_root_dir) do
          # build a filethis directory tree
          FileUtils.mkdir_p File.join(filethis, "Allstate 1")
          FileUtils.touch File.join(filethis, "Allstate 1", matchable_file1)
          FileUtils.touch File.join(filethis, "Allstate 1", matchable_file2)

          FileUtils.mkdir_p File.join(filethis, "Comcast")
          FileUtils.touch File.join(filethis, "Comcast", unmatchable_file1)
          FileUtils.touch File.join(filethis, "Comcast", unmatchable_file2)

          # build an archive directory tree (for holding the present file)
          FileUtils.mkdir_p File.join(archive, "2018", "02.Feb")
          FileUtils.touch present_file
        end
      end

      it "lists the source folder scanning" do
        expect {
          cli.archive_filethis filethis_dir, archive_dir
        }.to output(/Looking for FileThis PDFs in #{filethis_dir} to rename and archive.../).to_stdout
      end

      it "lists files that will be skipped because they can't be matched" do
        expect {
          cli.archive_filethis filethis_dir, archive_dir
        }.to output(/Skipping these files as they are not renameable:.*|baz-quux\.pdf|foo-bar\.pdf/).to_stdout
      end

      it "copies the files" do
        cli.archive_filethis filethis_dir, archive_dir

        Dir.chdir test_root_dir do
          expect(File).to exist(archived_file1)
          expect(File).to exist(archived_file2)
        end
      end

      it "lists files that were copied" do
        expect {
          cli.archive_filethis filethis_dir, archive_dir
        }.to output(/Added 2 files to the archive/).to_stdout
      end
    end
  end
  describe "#make_archive_folders" do
    let(:archive) { "archive" }

    before do
      Timecop.freeze(Time.local(1999))
      FileUtils.mkdir_p File.join(test_root_dir, archive)
      suppress_output do
        Dir.chdir test_root_dir do
          cli.make_archive_folders archive
        end
      end
    end

    after do
      Timecop.return
    end

    it "makes the year folder for the current year" do
      Dir.chdir File.join(test_root_dir, archive) do
        expect(File).to exist(File.join("Personal", "1999"))
      end
    end

    it "makes the month folders under the year folder" do
      Dir.chdir File.join(test_root_dir, archive, "Personal", "1999") do
        expect(File).to exist("01.Jan")
        expect(File).to exist("02.Feb")
        expect(File).to exist("03.Mar")
        expect(File).to exist("04.Apr")
        expect(File).to exist("05.May")
        expect(File).to exist("06.Jun")
        expect(File).to exist("07.Jul")
        expect(File).to exist("08.Aug")
        expect(File).to exist("09.Sep")
        expect(File).to exist("10.Oct")
        expect(File).to exist("11.Nov")
        expect(File).to exist("12.Dec")
      end
    end

    it "makes a tax folder" do
      Dir.chdir File.join(test_root_dir, archive, "Personal", "1999") do
        expect(File).to exist("1999.Tax")
      end
    end

    it "makes a media archve" do
      Dir.chdir File.join(test_root_dir, archive, "Personal", "1999") do
        expect(File).to exist("1999.MediaArchive")
      end
    end
  end

  after do
    FileUtils.remove_entry test_root_dir
  end
end
