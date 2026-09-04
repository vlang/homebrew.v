module cmd

import ruby
import homebrew.cmd as brew_cmd

// Translated from Homebrew/brew `test/cmd/--repository_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "prints Homebrew and Tap repositories" do` at line 7.
pub fn ruby_repository_spec_l7_d1_prints(args ...ruby.Value) ruby.Value {
	repository := if args.len > 0 { args[0].as_string() } else { '/homebrew' }
	library := if args.len > 1 { args[1].as_string() } else { '${repository}/Library' }
	mut lines := brew_cmd.repository_lines([]string{}, repository, library) or {
		return ruby.bool_value(false)
	}
	tap_lines := brew_cmd.repository_lines(['foo/bar', 'foo/homebrew-bar'], repository, library) or { return ruby.bool_value(false) }
	lines << tap_lines
	return ruby.bool_value(lines == [
		repository,
		'${library}/Taps/foo/homebrew-bar',
		'${library}/Taps/foo/homebrew-bar',
	])
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "open3"
// 5:
// 6: RSpec.describe "brew --repository", type: :system do
// 7:   it "prints Homebrew and Tap repositories" do
// 8:     stdout, stderr, status = Open3.capture3(
// 9:       {
// 10:         "HOMEBREW_LIBRARY"    => ENV.fetch("HOMEBREW_LIBRARY"),
// 11:         "HOMEBREW_REPOSITORY" => ENV.fetch("HOMEBREW_REPOSITORY"),
// 12:       },
// 13:       "/bin/bash", "-c", <<~SH,
// 14:         source "$1"
// 15:         homebrew---repository
// 16:         homebrew---repository foo/bar foo/homebrew-bar
// 17:       SH
// 18:       "bash", (HOMEBREW_LIBRARY_PATH/"cmd/--repository.sh").to_s
// 19:     )
// 20:
// 21:     expect(status).to be_success
// 22:     expect(stdout).to eq(<<~EOS)
// 23:       #{ENV.fetch("HOMEBREW_REPOSITORY")}
// 24:       #{ENV.fetch("HOMEBREW_LIBRARY")}/Taps/foo/homebrew-bar
// 25:       #{ENV.fetch("HOMEBREW_LIBRARY")}/Taps/foo/homebrew-bar
// 26:     EOS
// 27:     expect(stderr).to be_empty
// 28:   end
// 29: end
