module utils

// Translated from Homebrew/brew `utils/ruby_check_version_script.rb`.
// The original source is retained below until every stub has a typed V body.
fn ruby_version_segments(value string) ?[]int {
	if value == '' {
		return none
	}
	mut segments := []int{}
	for part in value.split('.') {
		mut digits := ''
		for character in part {
			if !character.is_digit() {
				break
			}
			digits += character.str()
		}
		if digits == '' {
			return none
		}
		segments << digits.int()
	}
	return segments
}

fn ruby_version_at_least(running []int, required []int) bool {
	length := if running.len > required.len { running.len } else { required.len }
	for index in 0 .. length {
		left := if index < running.len { running[index] } else { 0 }
		right := if index < required.len { required[index] } else { 0 }
		if left != right {
			return left > right
		}
	}
	return true
}

// check_ruby_version translates the complete top-level script body. `true`
// corresponds to a zero exit status and `false` to Ruby's `abort`/exception.
pub fn check_ruby_version(running_version string, required_version string,
	developer_or_tests bool, use_ruby_from_path bool) bool {
	running := ruby_version_segments(running_version) or { return false }
	required := ruby_version_segments(required_version) or { return false }
	if running.len < 2 || required.len < 2 {
		return false
	}
	if developer_or_tests && use_ruby_from_path && ruby_version_at_least(running, required) {
		return true
	}
	return running[0] == required[0] && running[1] == required[1]
}

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
