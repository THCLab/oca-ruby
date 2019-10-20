require 'odca/hashlink_generator'

RSpec.describe Odca::HashlinkGenerator do
  describe '.call' do
    context 'when hash is provided' do
      it 'generates hashlink string' do
        expect(described_class.call(test: 'test'))
          .to eql('9VhMK68B5BMrMZ4kDpiA7UQvheEvSCwkvi6vDcKcyKTb')
      end
    end
  end
end
