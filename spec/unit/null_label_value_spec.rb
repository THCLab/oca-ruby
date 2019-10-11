require 'odca/null_label_value'

RSpec.describe Odca::NullLabelValue do
  subject { described_class.new }

  describe '#[]' do
    it 'returns empty string' do
      expect(subject[anything]).to be_kind_of(String).and be_empty
    end
  end
end
