module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/rubydoc.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 20.
pub fn ruby_rubydoc_l20_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5:
// 6: module Homebrew
// 7:   module DevCmd
// 8:     class Rubydoc < AbstractCommand
// 9:       cmd_args do
// 10:         description <<~EOS
// 11:           Generate Homebrew's RubyDoc documentation.
// 12:         EOS
// 13:         switch "--only-public",
// 14:                description: "Only generate public API documentation."
// 15:         switch "--open",
// 16:                description: "Open generated documentation in a browser."
// 17:       end
// 18:
// 19:       sig { override.void }
// 20:       def run
// 21:         Homebrew.install_bundler_gems!(groups: ["doc"])
// 22:
// 23:         HOMEBREW_LIBRARY_PATH.cd do |dir|
// 24:           no_api_args = if args.only_public?
// 25:             ["--hide-api", "private", "--hide-api", "internal"]
// 26:           else
// 27:             []
// 28:           end
// 29:
// 30:           output_dir = dir/"doc"
// 31:
// 32:           safe_system "bundle", "exec", "yard", "doc", "--fail-on-warning", *no_api_args, "--output", output_dir
// 33:
// 34:           exec_browser "file://#{output_dir}/index.html" if args.open?
// 35:         end
// 36:       end
// 37:     end
// 38:   end
// 39: end
