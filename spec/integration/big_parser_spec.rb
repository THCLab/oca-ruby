require 'odca/big_parser'
require 'odca/hashlink_generator'
require 'json'

RSpec.describe Odca::BigParser do
  let(:topic)  { described_class.new(filename) }

  let(:filename) { File.join(SPEC_ROOT, 'shared/example.csv') }

  describe '#call' do
    context 'when valid CSV file is provided' do
      before(:each) do
        topic.call
      end

      let(:audit_overview_schema_base) do
        JSON.load(File.open(File.join(
          LIB_ROOT, 'output', 'AuditOverview.json'
        )))
      end

      it 'generates valid output' do
        expect(audit_overview_schema_base).to include(
          'attributes',
          "@context"=>"https://odca.tech/v1",
          "name"=>"AuditOverview",
          "type"=>"spec/schame_base/1.0",
          'pii_attributes' => include('auditReportNumber', 'auditReportOwner')
        )
      end

      context 'when Label Overlay is provided' do
        let(:label_overlays) do
          Dir[File.join(
            LIB_ROOT, 'output', schema_base_dir, 'LabelOverlay*.json'
          )].map do |path|
            JSON.load(File.open(path))
          end
        end

        context 'for all schema bases' do
          let(:schema_base_dir) { '*' }

          it 'generates valid overlays output' do
            label_overlays.each do |overlay|
              expect(overlay).to include(
                'attr_labels', 'attr_categories', 'category_labels',
                'category_attributes', 'schema_base',
                '@context' => 'https://odca.tech/overlays/v1',
                'type' => 'spec/overlay/label/1.0',
                'language' => 'en_US'
              )
            end
          end
        end

        context 'for Audit Overview schema base' do
          let(:schema_base_dir) { 'AuditOverview' }

          it 'all attributes occur in attr_labels' do
            overlay = label_overlays.first

            expect(overlay['attr_labels'].keys).to include(
              *audit_overview_schema_base['attributes'].keys
            )
          end

          it 'schema_base is filled correctly' do
            overlay = label_overlays.first

            expect(overlay['schema_base']).to eql(
              "hl:#{Odca::HashlinkGenerator
                .call(audit_overview_schema_base)}"
            )
          end
        end
      end

      context 'when Format Overlay is provided' do
        let(:format_overlays) do
          Dir[File.join(
            LIB_ROOT, 'output', schema_base_dir, 'FormatOverlay*.json'
          )].map do |path|
            JSON.load(File.open(path))
          end
        end

        context 'for all schema bases' do
          let(:schema_base_dir) { '*' }

          it 'generates valid overlays output' do
            format_overlays.each do |overlay|
              expect(overlay).to include(
                'attr_formats', 'schema_base',
                '@context' => 'https://odca.tech/overlays/v1',
                'type' => 'spec/overlay/format/1.0'
              )
            end
          end
        end

        context 'for Audit Overview schema base' do
          let(:schema_base_dir) { 'AuditOverview' }
          let(:overlay) { format_overlays.first }

          it 'attr_formats occur in attributes' do
            expect(audit_overview_schema_base['attributes'].keys)
              .to include(*overlay['attr_formats'].keys)
          end

          it 'schema_base is filled correctly' do
            expect(overlay['schema_base']).to eql(
              "hl:#{Odca::HashlinkGenerator
                .call(audit_overview_schema_base)}"
            )
          end
        end
      end

      context 'when Encode Overlay is provided' do
        let(:encode_overlays) do
          Dir[File.join(
            LIB_ROOT, 'output', schema_base_dir, 'EncodeOverlay*.json'
          )].map do |path|
            JSON.load(File.open(path))
          end
        end

        context 'for all schema bases' do
          let(:schema_base_dir) { '*' }

          it 'generates valid overlays output' do
            encode_overlays.each do |overlay|
              expect(overlay).to include(
                'attr_encoding', 'default_encoding', 'schema_base',
                '@context' => 'https://odca.tech/overlays/v1',
                'type' => 'spec/overlay/encode/1.0'
              )
            end
          end
        end

        context 'for Audit Overview schema base' do
          let(:schema_base_dir) { 'AuditOverview' }
          let(:overlay) { encode_overlays.first }

          it 'attr_encodings occur in attributes' do
            expect(audit_overview_schema_base['attributes'].keys)
              .to include(*overlay['attr_encoding'].keys)
          end

          it 'schema_base is filled correctly' do
            expect(overlay['schema_base']).to eql(
              "hl:#{Odca::HashlinkGenerator
                .call(audit_overview_schema_base)}"
            )
          end
        end
      end

      context 'when Entry Overlay is provided' do
        let(:entry_overlays) do
          Dir[File.join(
            LIB_ROOT, 'output', schema_base_dir, 'EntryOverlay*.json'
          )].map do |path|
            JSON.load(File.open(path))
          end
        end

        context 'for all schema bases' do
          let(:schema_base_dir) { '*' }

          it 'generates valid overlays output' do
            entry_overlays.each do |overlay|
              expect(overlay).to include(
                'attr_entries', 'schema_base',
                '@context' => 'https://odca.tech/overlays/v1',
                'type' => 'spec/overlay/entry/1.0',
                'language' => 'en_US'
              )
            end
          end
        end

        context 'for Audit Overview schema base' do
          let(:schema_base_dir) { 'AuditOverview' }
          let(:overlay) { entry_overlays.first }

          it 'attr_entries occur in attributes' do
            expect(audit_overview_schema_base['attributes'].keys)
              .to include(*overlay['attr_entries'].keys)
          end

          it 'attr_entries is filled' do
            entry = if overlay['role'] == 'Supplier'
                      overlay['attr_entries']['siteCountry']
                    elsif overlay['role'] == 'Auditor'
                      overlay['attr_entries']['auditType']
                    end

            expect(entry).not_to be_empty
          end

          it 'schema_base is filled correctly' do
            expect(overlay['schema_base']).to eql(
              "hl:#{Odca::HashlinkGenerator
                .call(audit_overview_schema_base)}"
            )
          end
        end
      end
    end
  end
end
