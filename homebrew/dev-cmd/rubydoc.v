module dev_cmd

import os

// Translated from Homebrew/brew `dev-cmd/rubydoc.rb`.
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
