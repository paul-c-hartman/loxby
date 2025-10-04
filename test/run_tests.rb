# frozen_string_literal: true

require 'minitest/autorun'
require 'English'
require 'stringio'
require 'loxby'

puts 'Running tests:'

def run_lox_file(file)
  out = StringIO.new
  lox = Lox.new(out, out)
  lox.run_file file
  [out.string, 0]
rescue SystemExit => e
  [out.string, e.status]
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
