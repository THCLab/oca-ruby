LIB_ROOT = (Pathname(__FILE__) + Pathname('..') ).dirname
SPEC_ROOT =File.join(LIB_ROOT, 'spec')

# This is temporary until directory structure will be properly established
$LOAD_PATH.unshift(LIB_ROOT)

RSpec.configure do |conf|
  conf.disable_monkey_patching!
  conf.warnings = true

  conf.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
