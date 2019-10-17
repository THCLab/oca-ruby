$LOAD_PATH.unshift(File.expand_path('lib', File.dirname(__FILE__)))
require 'bundler'
Bundler.require

filename = ARGV[0]
raise RuntimeError.new, 'Please provide input file as an argument' unless filename

require 'odca/big_parser'

OUTPUT_DIR = 'output'.freeze
Odca::BigParser.new(filename, OUTPUT_DIR).call
