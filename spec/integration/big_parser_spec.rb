require 'odca/big_parser'
require 'odca/hashlink_generator'
require 'csv'
require 'json'

RSpec.describe Odca::BigParser do
  let(:topic)  { described_class.new(records, output_dir) }

  let(:filename) { File.join(SPEC_ROOT, 'shared/example.csv') }
  let(:records) { CSV.read(filename, col_sep: ';') }
  let(:output_dir) { 'spec/shared/output' }

  describe '#call' do
    context 'when valid CSV file is provided' do
      before(:each) do
        topic.call
      end

      after(:each) do
        %x(`rm -rf #{output_dir}`)
      end

      let(:audit_overview_schema_base) do
        JSON.load(File.open(File.join(
          LIB_ROOT, output_dir, 'AuditOverview.json'
        )))
      end

      let(:facility_background_schema_base) do
        JSON.load(File.open(File.join(
          LIB_ROOT, output_dir, 'FacilityBackground.json'
        )))
      end

      it 'generates valid output' do
        expect(audit_overview_schema_base).to include(
          'attributes',
          "@context"=>"https://odca.tech/v1",
          "name"=>"AuditOverview",
          "type"=>"spec/schema_base/1.0",
          'pii_attributes' => include('auditReportNumber', 'auditReportOwner')
        )
      end

      context 'when Label Overlay is provided' do
        let(:label_overlays) do
          Dir[File.join(
            LIB_ROOT, output_dir, schema_base_dir, 'LabelOverlay*.json'
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
            LIB_ROOT, output_dir, schema_base_dir, 'FormatOverlay*.json'
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
            LIB_ROOT, output_dir, schema_base_dir, 'EncodeOverlay*.json'
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
            LIB_ROOT, output_dir, schema_base_dir, 'EntryOverlay*.json'
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

      context 'when Inforation Overlay is provided' do
        let(:information_overlays) do
          Dir[File.join(
            LIB_ROOT, output_dir, schema_base_dir, 'InformationOverlay*.json'
          )].map do |path|
            JSON.load(File.open(path))
          end
        end

        context 'for all schema bases' do
          let(:schema_base_dir) { '*' }

          it 'generates valid overlays output' do
            information_overlays.each do |overlay|
              expect(overlay).to include(
                'attr_information', 'schema_base',
                '@context' => 'https://odca.tech/overlays/v1',
                'type' => 'spec/overlay/information/1.0',
                'language' => 'en_US'
              )
            end
          end
        end

        context 'for Audit Overview schema base' do
          let(:schema_base_dir) { 'AuditOverview' }
          let(:overlay) { information_overlays.first }

          it 'attr_information keys occur in attributes' do
            expect(audit_overview_schema_base['attributes'].keys)
              .to include(*overlay['attr_information'].keys)
          end

          it 'attr_information is filled' do
            attr_info = overlay['attr_information']
            info = if overlay['role'] == 'Supplier'
                     attr_info['siteName']
                   elsif overlay['role'] == 'Auditor'
                     if overlay['purpose'] == 'Evaluation'
                       attr_info['auditReportOwner']
                     elsif overlay['purpose'] == 'Additional Guidance'
                       attr_info['findingClassificationMethod']
                     end
                   end

            expect(info).not_to be_empty
          end

          it 'schema_base is filled correctly' do
            expect(overlay['schema_base']).to eql(
              "hl:#{Odca::HashlinkGenerator
                .call(audit_overview_schema_base)}"
            )
          end
        end
      end

      context 'when Source Overlay is provided' do
        let(:source_overlays) do
          Dir[File.join(
            LIB_ROOT, output_dir, schema_base_dir, 'SourceOverlay*.json'
          )].map do |path|
            JSON.load(File.open(path))
          end
        end

        context 'for all schema bases' do
          let(:schema_base_dir) { '*' }

          it 'generates valid overlays output' do
            source_overlays.each do |overlay|
              expect(overlay).to include(
                'attr_sources', 'schema_base',
                '@context' => 'https://odca.tech/overlays/v1',
                'type' => 'spec/overlay/source/1.0'
              )
            end
          end
        end

        context 'for FacilityBackground schema base' do
          let(:schema_base_dir) { 'FacilityBackground' }
          let(:overlay) { source_overlays.first }

          it 'attr_sources keys occur in attributes' do
            expect(facility_background_schema_base['attributes'].keys)
              .to include(*overlay['attr_sources'].keys)
          end

          it 'attr_sources is filled' do
            expect(overlay['attr_sources']).not_to be_empty
          end

          it 'schema_base is filled correctly' do
            expect(overlay['schema_base']).to eql(
              "hl:#{Odca::HashlinkGenerator
                .call(facility_background_schema_base)}"
            )
          end
        end
      end

      context 'when Review Overlay is provided' do
        let(:review_overlays) do
          Dir[File.join(
            LIB_ROOT, output_dir, schema_base_dir, 'ReviewOverlay*.json'
          )].map do |path|
            JSON.load(File.open(path))
          end
        end

        context 'for all schema bases' do
          let(:schema_base_dir) { '*' }

          it 'generates valid overlays output' do
            review_overlays.each do |overlay|
              expect(overlay).to include(
                'attr_comments', 'schema_base',
                '@context' => 'https://odca.tech/overlays/v1',
                'type' => 'spec/overlay/review/1.0',
                'language' => 'en_US'
              )
            end
          end
        end

        context 'for FacilityBackground schema base' do
          let(:schema_base_dir) { 'FacilityBackground' }
          let(:overlay) { review_overlays.first }

          it 'attr_comments keys occur in attributes' do
            expect(facility_background_schema_base['attributes'].keys)
              .to include(*overlay['attr_comments'].keys)
          end

          it 'attr_comments is filled' do
            expect(overlay['attr_comments']).not_to be_empty
          end

          it 'schema_base is filled correctly' do
            expect(overlay['schema_base']).to eql(
              "hl:#{Odca::HashlinkGenerator
                .call(facility_background_schema_base)}"
            )
          end
        end
      end
    end
  end
end
