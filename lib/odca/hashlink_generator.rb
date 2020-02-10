require 'hashlink'
require 'json'

module Odca
  class HashlinkGenerator
    def self.call(schema)
      Hashlink.encode(data: JSON.pretty_generate(schema)).split(':')[1]
    end
  end
end
