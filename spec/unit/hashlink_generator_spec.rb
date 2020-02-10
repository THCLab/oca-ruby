require 'odca/hashlink_generator'

RSpec.describe Odca::HashlinkGenerator do
  describe '.call' do
    context 'when hash is provided' do
      it 'generates hashlink string' do
        expect(described_class.call(test: 'test'))
          .to eql('zQmSYdoyHvTerJXoDPLNFia1EjenxbHtwS8KbWRutrrWdcF')
      end
    end
  end
end
