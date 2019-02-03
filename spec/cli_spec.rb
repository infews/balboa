RSpec.describe Balboa::CLI do
  let(:cli) {Balboa::CLI.new}

  describe "archive_filethis" do
    context "with expected folders present" do
      let(:filethis) {File.join(Dir.tmpdir, "spec_balboa_gem", "filethis")}
      let(:archive) {File.join(Dir.tmpdir, "spec_balboa_gem", "archive")}
      let(:matchable_file1) {"Allstate 2018-01-04.pdf"}
      let(:matchable_file2) {"Allstate 2018-02-04.pdf"}
      let(:matchable_file3) {"Comcast 2018-01-11.pdf"}
      let(:matchable_file4) {"Comcast 2018-02-11.pdf"}
      let(:archived_file1) {File.join(archive, "2018", "01.Jan", "2018.01.04.Allstate.pdf")}
      let(:archived_file2) {File.join(archive, "2018", "02.Feb", "2018.02.04.Allstate.pdf")}
      let(:archived_file3) {File.join(archive, "2018", "01.Jan", "2018.01.04.Allstate.pdf")}
      let(:present_file) {File.join(archive, "2018", "02.Feb", "2018.02.11.Comcast.pdf")}
      let(:skipped_file) {"other.pdf"}
      let(:no_archive_year_file) {"Comcast 2019-01-45.pdf"}

      before do
        Dir.chdir(Dir.tmpdir) do
          FileUtils.mkdir_p File.join("spec_balboa_gem", "filethis", "Allstate 1")
          FileUtils.mkdir_p File.join("spec_balboa_gem", "filethis", "Comcast")
          FileUtils.mkdir_p File.join("spec_balboa_gem", "archive", "2018", "01.Jan")
          FileUtils.mkdir_p File.join("spec_balboa_gem", "archive", "2018", "02.Feb")
          Dir.chdir("spec_balboa_gem") do
            Dir.chdir(filethis) do
              FileUtils.touch File.join("Allstate 1", matchable_file1)
              FileUtils.touch File.join("Allstate 1", matchable_file2)
              FileUtils.touch File.join("Allstate 1", skipped_file)
              FileUtils.touch File.join("Comcast", matchable_file3)
              FileUtils.touch File.join("Comcast", matchable_file4)
              FileUtils.touch File.join("Comcast", no_archive_year_file)
            end
            Dir.chdir(archive) do
              FileUtils.touch present_file
            end
          end
        end
      end

      after do
        FileUtils.rm_rf File.join(Dir.tmpdir, "spec_balboa_gem")
      end

      it "lists the source folder scanning" do
        expect {
          cli.archive_filethis filethis, archive
        }.to output(/Archiving files from #{filethis} to #{archive}/).to_stdout
      end

      it "copies any PDF files with matching names to the right year/month directory in the archive " do
        suppress_output do
          cli.archive_filethis filethis, archive
        end

        expect(File.exist?(archived_file1)).to eq(true)
        expect(File.exist?(archived_file2)).to eq(true)
        expect(File.exist?(archived_file3)).to eq(true)
      end

      it "logs all source/filename and destination/filename when it copies" do
        expect {
          cli.archive_filethis filethis, archive
        }.to output(/Copying #{matchable_file1} to #{File.join("2018", "01.Jan", "2018.01.04.Allstate.pdf")}/).to_stdout
      end

      it "skips a file that is already present in the archive" do
        expect {
          cli.archive_filethis filethis, archive
        }.to output(/Skipping #{matchable_file4} as 2018.02.11.Comcast.pdf is already in the archive/).to_stdout
      end

      it "log filename if it doesn't match and continue" do
        expect {
          cli.archive_filethis filethis, archive
        }.to output(/Skipping #{skipped_file} as we don't know where to archive it/).to_stdout
      end

      it "log filename if the destination year folder doesn't exist" do
        expect {
          cli.archive_filethis filethis, archive
        }.to output(/Skipping #{no_archive_year_file} as the archive destination doesn't exist/).to_stdout
      end
    end
  end

  # copy_to_archive
  # help/instructions
  # option validations
  #   error if no destination folder
  # log & skip file if it doesn't match date scheme
  # when given a single file
  #   copies a file to the expected destination year/month folders
  #   errors when the year isn't present in the destination
  #   errors when the year/month isn't present in the destination
  # when given multiple files
  #   and all match
  #     copies multiples files to the expected destination year/month folders
  #     errors when the year isn't present in the destination
  #     errors when the year/month isn't present in the destination
  #   and some files don't match
  #     copies multiples files to the expected destination year/month folders
  #     skips/logs the file that does not match
  #     errors when the year isn't present in the destination
  #     errors when the year/month isn't present in the destination

  describe "make_archive_folders" do
    let(:archive) {File.join(Dir.tmpdir, "spec_balboa_gem", "archive")}

    before do
      Timecop.freeze(Time.local(1999))
      Dir.chdir(Dir.tmpdir) do
        FileUtils.mkdir_p "spec_balboa_gem"
      end
    end

    after do
      Timecop.return
      FileUtils.rm_rf File.join(Dir.tmpdir, "spec_balboa_gem")
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
  # make_annual_folders
  # help/instructions
  # option validations
  #   error if not given a directory
  #   log/error if file tree already exists
  # works
  #   makes a year folder based on the current year
  #   makes month folders under the year
  #   makes Tax folder under the year
end
