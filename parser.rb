$LOAD_PATH.unshift(File.expand_path("../", __FILE__))
require 'bundler'
Bundler.require

filename = ARGV[0]
raise RuntimeError.new, 'Please provide input file as an argument' unless filename

require 'big_parser'

BigParser.new(filename).call
