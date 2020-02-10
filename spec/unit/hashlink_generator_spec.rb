require 'odca/hashlink_generator'

RSpec.describe Odca::HashlinkGenerator do
  describe '.call' do
    context 'when hash is provided' do
      it 'generates hashlink string' do
        expect(described_class.call(test: 'test'))
          .to eql('zQmXFwVrE87rcG5PdUWgc24n5ZVniX7XH62ac7NLN9WmSxB')
      end
    end
  end
end
