RSpec.configure do |conf|
  conf.disable_monkey_patching!
  conf.warnings = true

  conf.expect_with :rspec do |c|
    c.syntax = :expect
  end

end
