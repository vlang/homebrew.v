module dev_cmd

import ruby
import os

// Translated from Homebrew/brew `dev-cmd/rubydoc.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct RubydocOptions {
pub:
	library_path string
	only_public  bool
	open         bool
}

pub struct RubydocPlan {
pub:
	bundler_groups []string
	working_dir    string
	output_dir     string
	command        []string
	browser_url    string
}

pub fn rubydoc_plan(options RubydocOptions) RubydocPlan {
	output_dir := os.join_path(options.library_path, 'doc')
	mut command := ['bundle', 'exec', 'yard', 'doc', '--fail-on-warning']
	if options.only_public {
		command << ['--hide-api', 'private', '--hide-api', 'internal']
	}
	command << ['--output', output_dir]
	return RubydocPlan{
		bundler_groups: ['doc']
		working_dir: options.library_path
		output_dir: output_dir
		command: command
		browser_url: if options.open { 'file://${output_dir}/index.html' } else { '' }
	}
}

fn rubydoc_plan_value(plan RubydocPlan) ruby.Value {
	return ruby.map_value({
		'bundler_groups': ruby.string_array_value(plan.bundler_groups)
		'working_dir':    ruby.string_value(plan.working_dir)
		'output_dir':     ruby.string_value(plan.output_dir)
		'command':        ruby.string_array_value(plan.command)
		'browser_url':    ruby.string_value(plan.browser_url)
	})
}

// Ruby method `run` at line 20.
pub fn ruby_rubydoc_l20_d1_run(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'library path is required')
	}
	return rubydoc_plan_value(rubydoc_plan(RubydocOptions{
		library_path: args[0].as_string()
		only_public: args.len > 1 && (args[1].as_bool() or { false })
		open: args.len > 2 && (args[2].as_bool() or { false })
	}))
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
