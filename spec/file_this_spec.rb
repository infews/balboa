RSpec.describe Balboa::FileThis do

  let(:file_this) {Balboa::FileThis.new}

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

end
