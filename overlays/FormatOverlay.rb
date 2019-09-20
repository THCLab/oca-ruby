class FormatOverlay < Overlay

  attr_reader :attr_formats

  def initialize(schema_base_id = "", issued_by = "")
    super(schema_base_id, issued_by)
    @type = "spec/overlay/format/1.0"
    @attr_formats = []
  end

  def as_json(options={})
    super.merge!(
      issued_by: @issued_by,
      attr_formats: @attr_formats.each_with_object({}) do |af, memo|
        memo[af.attr_name] = af.format
      end
    )
  end

  def add_format(format)
    return unless format.valid?
    attr_formats << format
  end

  def is_valid?
    !attr_formats.empty? && super
  end

  class Format
    attr_reader :attr_name, :format

    def initialize(attr_name, format)
      @attr_name = attr_name
      @format = format
    end

    def valid?
      !attr_name.to_s.strip.empty? && !format.to_s.strip.empty?
    end
  end
end
