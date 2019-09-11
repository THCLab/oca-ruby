$LOAD_PATH.unshift(File.expand_path("../", __FILE__))

require 'csv'
require 'odca.rb'
require 'json'
require 'pp'

filename = ARGV[0]
raise RuntimeError.new, 'Please provide input file as an argument' unless filename

records = CSV.read(filename, col_sep: ';')

schema_base = SchemaBase.new
# should be CID base on the content
schema_base.id = "11f1fdasfj081jd1982d9j"

format_overlay = FormatOverlay.new(schema_base.id)
label_overlay = LabelOverlay.new(schema_base.id)
encode_overlay = EncodeOverlay.new(schema_base.id)
entry_overlay_algo = EntryOverlay.new(schema_base.id)
entry_overlay_auditor = EntryOverlay.new(schema_base.id)
entry_overlay_supplier = EntryOverlay.new(schema_base.id)
information_overlay_algo = InformationOverlay.new(schema_base.id)
information_overlay_supplier = InformationOverlay.new(schema_base.id)
conditional_overlay = ConditionalOverlay.new(schema_base.id)
source_overlay_auditor = SourceOverlay.new(schema_base.id)
source_overlay_member = SourceOverlay.new(schema_base.id)
source_overlay_supplier = SourceOverlay.new(schema_base.id)

attrs = {}
pii = []
formats = {}
labels = {}
categories = []
category_labels = {}
encoding = {}
entries_algo = {}
entries_supplier = {}
entries_auditor = {}
information_algo = {}
information_supplier = {}
hidden_attributes = {}
required_attributes = {}
sources_auditor = {}
sources_member = {}
sources_supplier = {}

records.each do |row|
  # Iterate until schema base does not change
  if schema_base.name != row[0] and schema_base.name != nil
    objects = [schema_base, format_overlay, label_overlay, encode_overlay, entry_overlay_algo, 
    entry_overlay_auditor, entry_overlay_supplier, information_overlay_algo, information_overlay_supplier,
    conditional_overlay, source_overlay_auditor, source_overlay_member, source_overlay_supplier]

    objects.each { |obj|
      puts "Writing #{obj.class.name}"
      if obj.class.name == "SchemaBase" 
        puts "Create dir"
        Dir.mkdir "output/"+obj.name unless Dir.exist? "output/"+obj.name
        File.open("output/#{obj.name}.json","w") do |f|
          f.write(JSON.pretty_generate(obj))
        end
      else 
        File.open("output/#{schema_base.name}/#{obj.name}.json","w") do |f|
          f.write(JSON.pretty_generate(obj))
        end
      end
    }

  encode_overlay.name = "Encode Overlay"
  encode_overlay.description = "Encode used for #{row[0]}"
  encode_overlay.language = "en"
  encode_overlay.attr_encoding = encoding

    schema_base = SchemaBase.new
    # should be CID base on the content
    schema_base.id = "#{row[0]}fghajdks"
    format_overlay = FormatOverlay.new(schema_base.id)
    label_overlay = LabelOverlay.new(schema_base.id)
    encode_overlay = EncodeOverlay.new(schema_base.id)
    entry_overlay_algo = EntryOverlay.new(schema_base.id)
    entry_overlay_auditor = EntryOverlay.new(schema_base.id)
    entry_overlay_supplier = EntryOverlay.new(schema_base.id)
    information_overlay_algo = InformationOverlay.new(schema_base.id)
    information_overlay_supplier = InformationOverlay.new(schema_base.id)
    conditional_overlay = ConditionalOverlay.new(schema_base.id)
    source_overlay_auditor = SourceOverlay.new(schema_base.id)
    source_overlay_member = SourceOverlay.new(schema_base.id)
    source_overlay_supplier = SourceOverlay.new(schema_base.id)
  end
  schema_base.name = row[0]
  schema_base.description = row[0]
  attr_name = row[3]
  attr_type = row[4]
  attrs[attr_name] = attr_type
  # PII
  if row[5] == "Y"
    pii << attr_name
  end
  # Format overlay
  unless row[7].to_s.strip.empty?
    formats[attr_name] = row[7]
  end
  # Set labels for attributes
  labels[attr_name] = row[10].split("|")[-1].strip
  # TODO support for nested categories
  tmp = row[10].split("|")[0..-2]
  categories << tmp
  tmp.each do |c|
    h = c.strip.downcase.gsub(/\s+/, "_").to_sym
    category_labels[h] = c
  end



  schema_base.attributes = attrs
  schema_base.pii_attributes = pii
  format_overlay.formats = formats
  format_overlay.name = "Format overlay"
  format_overlay.description = "Formats used for #{row[0]}"
  label_overlay.name = "Label overlay"
  label_overlay.language = "en"
  label_overlay.description = "Labels for #{row[0]}"
  label_overlay.attr_labels = labels
  label_overlay.attr_categories = categories.flatten.uniq.map {|i|
    i.strip.downcase.gsub(/\s+/, "_").to_sym
  }
  label_overlay.category_labels = category_labels

  # Encoding overlay
  unless row[11].to_s.strip.empty?
    encoding[attr_name] = row[11]
  end

  encode_overlay.name = "Encode Overlay"
  encode_overlay.description = "Encode used for #{row[0]}"
  encode_overlay.language = "en"
  encode_overlay.attr_encoding = encoding

  # Entry overlay for Algorithm
  unless row[12].to_s.strip.empty?
    values = row[12][2..-3].split("|")
    entries_algo[attr_name] = values
  end
  entry_overlay_algo.name = "Entry Overlay"
  entry_overlay_algo.description = "#{row[0]} entries for Algorithm"
  entry_overlay_algo.default_values = entries_algo

  # Entry overlay for Supplier
  unless row[14].to_s.strip.empty?
    values = row[14][2..-3].split("|")
    entries_supplier[attr_name] = values
  end
  entry_overlay_supplier.name = "Entry Overlay"
  entry_overlay_supplier.description = "#{row[0]} entries for Supplier"
  entry_overlay_supplier.default_values = entries_supplier

  # Entry overlay for Auditor
  unless row[26].to_s.strip.empty?
    values = row[26][2..-3].split("|")
    entries_auditor[attr_name] = values
  end
  entry_overlay_auditor.name = "Entry Overlay"
  entry_overlay_auditor.description = "#{row[0]} entries for Auditor"
  entry_overlay_auditor.default_values = entries_auditor

  # Information overlay for Algorithm
  unless row[13].to_s.strip.empty?
    information_algo[attr_name] = row[13]
  end

  information_overlay_algo.name = "Information Overlay"
  information_overlay_algo.description = "#{row[0]} informations for Algorithm"
  information_overlay_algo.attr_information = information_algo

  # Information overlay for Supplier
  unless row[15].to_s.strip.empty?
    information_supplier[attr_name] = row[15]
  end

  information_overlay_supplier.name = "Information Overlay"
  information_overlay_supplier.description = "#{row[0]} informations for Supplier"
  information_overlay_supplier.attr_information = information_supplier

  # Conditional Overlay
  conditional_overlay.name = "Conditional Overlay"
  conditional_overlay.description = "#{row[0]} attribute conditions"

  unless row[8].to_s.strip.empty?
    hidden_attributes[attr_name] = row[8]
  end
  conditional_overlay.hidden_attributes = hidden_attributes
  conditional_overlay.required_attributes = required_attributes

  # sources overlay for auditor
  unless row[28].to_s.strip.empty?
    sources_auditor[attr_name] = row[28]
  end

  source_overlay_auditor.name = "Source overlay"
  source_overlay_auditor.description = "Auditor suorce overlay"
  source_overlay_auditor.sources = sources_auditor


end




