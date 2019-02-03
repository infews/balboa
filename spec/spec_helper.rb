require "bundler/setup"
require "balboa"

require "fileutils"
require "timecop"
require "tmpdir"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# Temporarily redirects STDOUT and STDERR to /dev/null
# but does print exceptions should there occur any.
# Call as:
#   suppress_output { puts 'never printed' }
#
def suppress_output
  original_stderr = $stderr.clone
  original_stdout = $stdout.clone
  $stderr.reopen(File.new("/dev/null", "w"))
  $stdout.reopen(File.new("/dev/null", "w"))
  retval = yield
rescue => e
  $stdout.reopen(original_stdout)
  $stderr.reopen(original_stderr)
  raise e
ensure
  $stdout.reopen(original_stdout)
  $stderr.reopen(original_stderr)
  retval
end
