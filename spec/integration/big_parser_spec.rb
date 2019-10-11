require 'odca/big_parser'
require "json"

RSpec.describe Odca::BigParser do
  let(:topic)  { described_class.new(filename) }

  let(:filename) { File.join(SPEC_ROOT, 'shared/example.csv') }

  describe '#call' do
    context 'when valid CSV file is provided' do
      it 'generates valid output' do
        topic.call

        audit_overview_schema_base = JSON.load(
          File.open(File.join(LIB_ROOT, 'output', 'AuditOverview.json'))
        )

        expect(audit_overview_schema_base).to include(
          'attributes',
          "@context"=>"https://odca.tech/v1",
          "name"=>"AuditOverview",
          "type"=>"spec/schame_base/1.0",
          'pii_attributes' => include('auditReportNumber', 'auditReportOwner')
        )
      end
    end
  end
end
