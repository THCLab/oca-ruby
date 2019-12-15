Gem::Specification.new do |s|
  s.name        = 'odca-ruby'
  s.version     = '0.2.0'
  s.date        = '2019-12-15'
  s.summary     = "Overlays Data Capture Architecture (ODCA) objects parser"
  s.description = "Parser for ODCA objects"
  s.authors     = ["Robert Mitwicki", "Marcin Olichwiruk", "Michał Pietrus"]
  s.email       = 'robert@thclab.online'
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
  s.homepage    =
    'https://odca.online'
  s.license       = 'MIT'
end
