# frozen_string_literal: true

require_relative 'lib/loxby/version'

Gem::Specification.new do |s|
  s.name = 'loxby'
  s.version = Lox::VERSION
  s.authors = ['Paul Hartman']
  s.email = ['real.paul.hartman@gmail.com']

  s.summary = 'A Lox interpreter written in Ruby'
  s.description = 'Loxby is written following the first ' \
  "half of Robert Nystrom's wonderful web-format book " \
  '[Crafting Interpreters](https://www.craftinginterpreters.com), ' \
  'adapting the Java code to modern Ruby. This project is ' \
  'intended to explore what elegant object-oriented code ' \
  'can look like and accomplish.'
  s.homepage = 'https://github.com/paul-c-hartman/loxby'
  s.license = 'MIT'
  s.required_ruby_version = Gem::Requirement.new('>= 3.1.0') # Shorthand hash syntax

  s.metadata['homepage_uri'] = s.homepage
  s.metadata['source_code_uri'] = s.homepage

  # Specify which files should be added to the gem when it is released.
  # `git ls-files -z` loads the files in the gem which git is tracking.
  s.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { _1.match %r{^(test|spec|features)/} } - %w[Gemfile Gemfile.lock.rubocop.yml]
  end
  s.bindir = 'bin'
  s.executables = %w[loxby]
  s.require_paths = %w[lib]
end
