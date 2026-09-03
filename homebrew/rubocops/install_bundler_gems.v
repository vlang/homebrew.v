module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/install_bundler_gems.rb`.
// The original source is retained below until every stub has a typed V body.
pub const install_bundler_gems_message = 'Only use `Homebrew.install_bundler_gems!` in dev-cmd.'

pub struct InstallBundlerGemsOffense {
pub:
	begin_pos int
	end_pos   int
	message   string
}

fn install_bundler_gems_allowed_path(file_path string) bool {
	if file_path.ends_with('/standalone/init.rb') || file_path.ends_with('/startup/bootsnap.rb') {
		return true
	}
	marker := '/dev-cmd/'
	index := file_path.last_index(marker) or { return false }
	return file_path.ends_with('.rb') && index + marker.len < file_path.len - '.rb'.len
}

pub fn audit_install_bundler_gems(source string, file_path string) ?InstallBundlerGemsOffense {
	if install_bundler_gems_allowed_path(file_path) {
		return none
	}
	call := 'Homebrew.install_bundler_gems!'
	begin_pos := source.index(call) or { return none }
	return InstallBundlerGemsOffense{
		begin_pos: begin_pos
		end_pos: begin_pos + call.len
		message: install_bundler_gems_message
	}
}

// Ruby method `on_send(node)` at line 13.
pub fn ruby_install_bundler_gems_l13_d1_on_send(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { 'Homebrew.install_bundler_gems!' }
	file_path := if args.len > 1 { args[1].as_string() } else { '/tmp/formula.rb' }
	offense := audit_install_bundler_gems(source, file_path) or {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return brew_runtime.map_value({
		'begin_pos': brew_runtime.int_value(offense.begin_pos)
		'end_pos':   brew_runtime.int_value(offense.end_pos)
		'message':   brew_runtime.string_value(offense.message)
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Homebrew
// 7:       # Enforces the use of `Homebrew.install_bundler_gems!` in dev-cmd.
// 8:       class InstallBundlerGems < Base
// 9:         MSG = "Only use `Homebrew.install_bundler_gems!` in dev-cmd."
// 10:         RESTRICT_ON_SEND = [:install_bundler_gems!].freeze
// 11:
// 12:         sig { params(node: RuboCop::AST::Node).void }
// 13:         def on_send(node)
// 14:           file_path = processed_source.file_path
// 15:           return if file_path.match?(%r{/(dev-cmd/.+|standalone/init|startup/bootsnap)\.rb\z})
// 16:
// 17:           add_offense(node)
// 18:         end
// 19:       end
// 20:     end
// 21:   end
// 22: end
