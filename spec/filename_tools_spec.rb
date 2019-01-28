RSpec.describe Balboa::FilenameTools do

  let(:file_this) {Balboa::FilenameTools.new}

  describe '#archive_filename_for' do
    context 'when the filename is unique' do
      it 'returns a filename in the Balboa format' do
        expect(file_this.archive_filename_for(
          'Allstate Automobile 904150241 Statements 2018-07-12.pdf'))
          .to eq('2018.07.12.Allstate.Automobile.904150241.Statements.pdf')
      end
    end

    context 'when the FileThis adds text after the date' do
      it 'returns a filename in the Balboa format' do
        expect(file_this.archive_filename_for(
          'Allstate Automobile 904150241 Statements 2018-07-12 4.pdf'))
          .to eq('2018.07.12.Allstate.Automobile.904150241.Statements.4.pdf')
      end
    end
  end

  describe '#month_directory_for' do
    context 'when given a filename with a full date' do
      it 'returns the directory path' do
        expect(file_this.month_directory_for('2019.01.12.FooBar.txt')).to eq('2019/01.Jan/')
        expect(file_this.month_directory_for('2014.05.23.FooBar.txt')).to eq('2014/05.May/')
        expect(file_this.month_directory_for('2198.11.01.FooBar.txt')).to eq('2198/11.Nov/')
      end
    end

    context 'when given a filename with a year' do
      it 'returns the directory path' do
        expect(file_this.month_directory_for('2198.SomeOther.file.txt')).to eq('2198/')
      end
    end

    context 'when given a filename without a recognizable date' do
      it 'fails appropriately' do
        expect{
          file_this.month_directory_for('NoDate.File.jpg')
        }.to raise_error(Balboa::NoDateInFilenameError)
      end

    end
  end

end
