module tapioca

// Translated from Homebrew/brew `sorbet/tapioca/require.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # These should not be made constants or Tapioca will think they are part of a gem.
// 5: dependency_require_map = {
// 6:   "ruby-macho" => "macho",
// 7: }.freeze
// 8:
// 9: additional_requires_map = {
// 10:   "parser"        => ["parser/current"],
// 11:   "rubocop-rspec" => ["rubocop/rspec/expect_offense", "rubocop/rspec/cop_helper"],
// 12: }.freeze
// 13:
// 14: # Freeze lockfile
// 15: Bundler.settings.set_command_option(:frozen, "1")
// 16:
// 17: definition = Bundler.definition
// 18: definition.resolve.for(definition.current_dependencies).each do |spec|
// 19:   name = spec.name
// 20:
// 21:   # These sorbet gems do not contain any library files
// 22:   next if name == "sorbet"
// 23:   next if name == "sorbet-static"
// 24:   next if name == "sorbet-static-and-runtime"
// 25:
// 26:   name = dependency_require_map[name] if dependency_require_map.key?(name)
// 27:   require name
// 28:   additional_requires_map[name]&.each { require(it) }
// 29: rescue LoadError
// 30:   raise unless name.include?("-")
// 31:
// 32:   name = name.tr("-", "/")
// 33:   require name
// 34: end
