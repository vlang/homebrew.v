module utils

// Translated from Homebrew/brew `utils/ruby_check_version_script.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: #!/usr/bin/env ruby
// 2: # typed: strict
// 3: # frozen_string_literal: true
// 4:
// 5: HOMEBREW_REQUIRED_RUBY_VERSION = ARGV.first.freeze
// 6: raise "No Ruby version passed!" if HOMEBREW_REQUIRED_RUBY_VERSION.to_s.empty?
// 7:
// 8: require "rubygems"
// 9:
// 10: ruby_version = Gem::Version.new(RUBY_VERSION)
// 11: homebrew_required_ruby_version = Gem::Version.new(HOMEBREW_REQUIRED_RUBY_VERSION)
// 12:
// 13: ruby_segments = ruby_version.canonical_segments
// 14: ruby_version_major = ruby_segments[0].to_i
// 15: ruby_version_minor = ruby_segments[1].to_i
// 16:
// 17: homebrew_required_ruby_segments = homebrew_required_ruby_version.canonical_segments
// 18: homebrew_required_ruby_version_major = homebrew_required_ruby_segments[0].to_i
// 19: homebrew_required_ruby_version_minor = homebrew_required_ruby_segments[1].to_i
// 20:
// 21: if (!ENV.fetch("HOMEBREW_DEVELOPER", "").empty? || !ENV.fetch("HOMEBREW_TESTS", "").empty?) &&
// 22:    !ENV.fetch("HOMEBREW_USE_RUBY_FROM_PATH", "").empty? &&
// 23:    ruby_version >= homebrew_required_ruby_version
// 24:   return
// 25: elsif ruby_version_major != homebrew_required_ruby_version_major ||
// 26:       ruby_version_minor != homebrew_required_ruby_version_minor
// 27:   abort
// 28: end
