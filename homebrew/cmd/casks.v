module cmd

// Translated from Homebrew/brew `cmd/casks.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct CaskListing {
pub:
	full_name string
	token     string
}

fn sorted_distinct_strings(values []string) []string {
	mut sorted := values.clone()
	sorted.sort()
	mut unique := []string{cap: sorted.len}
	for value in sorted {
		if unique.len == 0 || unique.last() != value {
			unique << value
		}
	}
	return unique
}

pub fn cask_lines(casks []CaskListing) []string {
	mut lines := []string{cap: casks.len * 2}
	for cask in casks {
		lines << cask.full_name
		lines << cask.token
	}
	return sorted_distinct_strings(lines)
}

// Ruby method `run` at line 15.
pub fn ruby_casks_l15_d1_run(casks []CaskListing) []string {
	return cask_lines(casks)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5:
// 6: module Homebrew
// 7:   module Cmd
// 8:     class Casks < AbstractCommand
// 9:       # Used when the Bash implementation falls back to Ruby for tap trust filtering.
// 10:       cmd_args do
// 11:         description "List all locally installable casks including short names."
// 12:       end
// 13:
// 14:       sig { override.void }
// 15:       def run
// 16:         require "cask/cask"
// 17:
// 18:         puts Cask::Cask.all(eval_all: true).flat_map { |cask| [cask.full_name, cask.token] }.uniq.sort
// 19:       end
// 20:     end
// 21:   end
// 22: end
