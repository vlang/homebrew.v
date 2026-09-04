module dev_cmd

import ruby
import os

// Translated from Homebrew/brew `dev-cmd/ruby.rb`.
pub struct RubyCommandOptions {
pub:
	ruby_exec_args []string
	load_path      []string
	require_name   ?string
	code           ?string
	named          []string
}

pub fn build_ruby_command_exec_args(options RubyCommandOptions) []string {
	mut command := options.ruby_exec_args.clone()
	command << ['-I', options.load_path.join(os.path_delimiter), '-rglobal', '-rbrew_irb_helpers']
	if require_name := options.require_name {
		command << '-r${require_name}'
	}
	if code := options.code {
		command << '-e ${code}'
	}
	command << options.named
	return command
}
