module dev_cmd

import os

// Translated from Homebrew/brew `dev-cmd/style.rb`.

pub struct StyleCommandOptions {
pub:
	changed             bool
	named_paths         []string
	repository          string
	rev_parse_success   bool = true
	changed_files       []string
	fix                 bool
	todo                bool
	reset_cache         bool
	debug               bool
	verbose             bool
	only_cops           []string
	only_cops_set       bool
	except_cops         []string
	except_cops_set     bool
	check_style_success bool = true
}

pub struct StyleCommandResult {
pub:
	bundler_groups []string
	target         []string
	fix            bool
	todo           bool
	reset_cache    bool
	debug          bool
	verbose        bool
	only_cops      []string
	except_cops    []string
	style_checked  bool
	warnings       []string
	failed         bool
}

pub fn changed_ruby_or_shell_files(repository string, rev_parse_success bool, changed_files []string) ![]string {
	if !rev_parse_success {
		return error('`brew style --changed` must be run inside a git repository!')
	}
	mut paths := []string{}
	for file in changed_files {
		if !file.ends_with('.rb') && !file.ends_with('.sh') && !file.ends_with('.yml')
			&& !file.ends_with('.rbi') && file != 'bin/brew' {
			continue
		}
		path := if os.is_abs_path(file) { file } else { os.join_path(repository, file) }
		if os.exists(path) {
			paths << os.real_path(path)
		}
	}
	return paths
}

pub fn run_style_command(options StyleCommandOptions) !StyleCommandResult {
	if options.changed && options.named_paths.len > 0 {
		return error('`--changed` and named arguments are mutually exclusive!')
	}
	target := if options.changed {
		changed_ruby_or_shell_files(options.repository, options.rev_parse_success, options.changed_files)!
	} else {
		options.named_paths.clone()
	}
	if options.changed && target.len == 0 {
		return StyleCommandResult{
			bundler_groups: ['style']
			target: target
			warnings: ['No style checks are available for the changed files!']
		}
	}
	only_cops := if options.only_cops_set { options.only_cops.clone() } else { []string{} }
	except_cops := if options.only_cops_set {
		[]string{}
	} else if options.except_cops_set {
		options.except_cops.clone()
	} else {
		['FormulaAuditStrict']
	}
	return StyleCommandResult{
		bundler_groups: ['style']
		target: target
		fix: options.fix
		todo: options.todo
		reset_cache: options.reset_cache
		debug: options.debug
		verbose: options.verbose
		only_cops: only_cops
		except_cops: except_cops
		style_checked: true
		failed: !options.check_style_success
	}
}

@[heap]
pub struct StyleCommandInput {
pub:
	options StyleCommandOptions
}
