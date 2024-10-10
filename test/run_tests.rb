# frozen_string_literal: true

require 'English'
require 'open3'

test_files = Dir[File.join __dir__, '*.lox'].to_a
passed = 0
failed = 0
verbose = ARGV[0] == '--verbose'

puts 'Running tests:'

def run(file)
  values = []
  Open3.popen2e("bundle exec loxby \"#{file}\"") do |_stdin, stdout_and_stderr, wait_thr|
    values << stdout_and_stderr.read
    values << wait_thr.value
  end
  values
end

test_files.each do |test_file|
  if verbose
    puts '==='
    puts "Running #{File.basename test_file}:"
    puts "bundle exec loxby #{test_file}"
  end
  out, code = *run(test_file)

  if code.exitstatus.zero?
    if verbose
      puts 'Test passed!'
    else
      print '.'
    end
    passed += 1
  else
    if verbose
      puts 'Test failed:'
      puts '---'
      puts out
      puts '---'
    else
      print 'x'
    end
    failed += 1
  end
  puts "===\n\n" if verbose
end

puts
puts "#{passed}/#{passed + failed} Passed"
