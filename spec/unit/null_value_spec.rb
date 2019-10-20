require 'odca/null_value'

RSpec.describe Odca::NullValue do
  subject { described_class.new }

  describe '#to_s' do
    it 'returns empty string' do
      expect(subject.to_s).to be_kind_of(String).and be_empty
    end
  end

  describe '#empty?' do
    it 'returns true' do
      expect(subject.empty?).to be_truthy
    end
  end
end
