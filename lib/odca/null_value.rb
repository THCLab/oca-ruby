module Odca
  class NullValue
    %i[to_s to_str].each do |method|
      define_method method do
        ''
      end
    end

    def empty?
      true
    end

    def nil?
      true
    end
  end
end
