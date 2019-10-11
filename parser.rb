$LOAD_PATH.unshift(File.expand_path('lib', File.dirname(__FILE__)))
require 'bundler'
Bundler.require

filename = ARGV[0]
raise RuntimeError.new, 'Please provide input file as an argument' unless filename

require 'odca/big_parser'

Odca::BigParser.new(filename).call
