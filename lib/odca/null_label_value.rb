module Odca
  class NullLabelValue
    def [](_)
      ''
    end

    def nil?
      true
    end
  end
end
