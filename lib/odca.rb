require 'odca/version'
require 'odca/parser'
require 'odca/schema_base'
require 'odca/headful_overlay'
require 'odca/parentful_overlay'
Dir[File.expand_path('../odca/overlays/*.rb', __FILE__)].each do |file|
  require file
end

module Odca
  ROOT_PATH = File.expand_path('..', File.dirname(__FILE__))
end
