# frozen_string_literal: true

require 'minitest/autorun'
require 'English'
require 'open3'

puts 'Running tests:'

def run_lox_file(file)
  values = []
  Open3.popen2e("bundle exec loxby \"#{file}\"") do |_stdin, stdout_and_stderr, wait_thr|
    values << stdout_and_stderr.read
    values << wait_thr.value
  end
  values
end

class LoxTest < Minitest::Test
  lox_tests = Dir[File.join __dir__, '*.lox'].to_a
  lox_tests.each do |test_file|
    test_name = File.basename(test_file, '.lox')
    define_method :"test_lox_#{test_name}" do
      out = run_lox_file(test_file)
      output, exit_code = *out
      assert_equal exit_code, 0, "Test output:\n\n================\n#{output}\n================\n\n"
    end
  end
end
