# frozen_string_literal: true

require 'minitest/test_task'

Minitest::TestTask.create(:test) do |t|
  t.libs << 'lib'
  t.warning = false
  t.test_globs = ['test/run_tests.rb']
end

task default: :test
