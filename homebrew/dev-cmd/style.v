module dev_cmd

import ruby
import os

// Translated from Homebrew/brew `dev-cmd/style.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct StyleCommandOptions {
pub:
	changed              bool
	named_paths          []string
	repository           string
	rev_parse_success    bool = true
	changed_files        []string
	fix                  bool
	todo                 bool
	reset_cache          bool
	debug                bool
	verbose              bool
	only_cops            []string
	only_cops_set        bool
	except_cops          []string
	except_cops_set      bool
	check_style_success  bool = true
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

pub fn style_command_input_boundary(input &StyleCommandInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::StyleCmd::Input', '', {
		'style_command_input_address': u64(voidptr(input)).str()
	})
}

fn style_command_input_from_value(value ruby.Value) &StyleCommandInput {
	address := value.attributes['style_command_input_address'] or {
		panic('invalid StyleCmd input')
	}
	return unsafe { &StyleCommandInput(voidptr(address.u64())) }
}

fn style_command_result_value(result StyleCommandResult) ruby.Value {
	return ruby.map_value({
		'bundler_groups': ruby.string_array_value(result.bundler_groups)
		'target': ruby.string_array_value(result.target)
		'fix': ruby.bool_value(result.fix)
		'todo': ruby.bool_value(result.todo)
		'reset_cache': ruby.bool_value(result.reset_cache)
		'debug': ruby.bool_value(result.debug)
		'verbose': ruby.bool_value(result.verbose)
		'only_cops': ruby.string_array_value(result.only_cops)
		'except_cops': ruby.string_array_value(result.except_cops)
		'style_checked': ruby.bool_value(result.style_checked)
		'warnings': ruby.string_array_value(result.warnings)
		'failed': ruby.bool_value(result.failed)
	})
}

// Ruby method `run` at line 52.
pub fn ruby_style_l52_d1_run(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'command input is required')
	}
	return style_command_result_value(run_style_command(style_command_input_from_value(args[0]).options) or {
		return ruby.object_value('UsageError', err.msg())
	})
}

// Ruby method `changed_ruby_or_shell_files` at line 94.
pub fn ruby_style_l94_d2_changed_ruby_or_shell_files(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'command input is required')
	}
	options := style_command_input_from_value(args[0]).options
	return ruby.string_array_value(changed_ruby_or_shell_files(options.repository,
		options.rev_parse_success, options.changed_files) or {
		return ruby.object_value('Error', err.msg())
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "json"
// 6: require "open3"
// 7: require "style"
// 8: require "utils/git"
// 9:
// 10: module Homebrew
// 11:   module DevCmd
// 12:     class StyleCmd < AbstractCommand
// 13:       cmd_args do
// 14:         description <<~EOS
// 15:           Check formulae or files for conformance to Homebrew style guidelines.
// 16:
// 17:           Lists of <file>, <tap> and <formula> may not be combined. If none are
// 18:           provided, `style` will run style checks on the whole Homebrew library,
// 19:           including core code and all formulae.
// 20:         EOS
// 21:         switch "--fix",
// 22:                description: "Fix style violations automatically using RuboCop's auto-correct feature."
// 23:         switch "--todo",
// 24:                depends_on:  "--fix",
// 25:                description: "Add `rubocop:todo` comments for RuboCop violations that remain after auto-correction. " \
// 26:                             "Requires `--fix`."
// 27:         switch "--display-cop-names",
// 28:                description: "Include the RuboCop cop name for each violation in the output.",
// 29:                hidden:      true
// 30:         switch "--reset-cache",
// 31:                description: "Reset the RuboCop cache."
// 32:         switch "--changed",
// 33:                description: "Check files that were changed from the `main` branch."
// 34:         switch "--formula", "--formulae",
// 35:                description: "Treat all named arguments as formulae."
// 36:         switch "--cask", "--casks",
// 37:                description: "Treat all named arguments as casks."
// 38:         comma_array "--only-cops",
// 39:                     description: "Specify a comma-separated <cops> list to check for violations of only the " \
// 40:                                  "listed RuboCop cops."
// 41:         comma_array "--except-cops",
// 42:                     description: "Specify a comma-separated <cops> list to skip checking for violations of the " \
// 43:                                  "listed RuboCop cops."
// 44:
// 45:         conflicts "--formula", "--cask"
// 46:         conflicts "--only-cops", "--except-cops"
// 47:
// 48:         named_args [:file, :tap, :formula, :cask], without_api: true
// 49:       end
// 50:
// 51:       sig { override.void }
// 52:       def run
// 53:         Homebrew.install_bundler_gems!(groups: ["style"])
// 54:
// 55:         if args.changed? && !args.no_named?
// 56:           raise UsageError, "`--changed` and named arguments are mutually exclusive!"
// 57:         end
// 58:
// 59:         target = if args.changed?
// 60:           changed_ruby_or_shell_files
// 61:         elsif args.no_named?
// 62:           nil
// 63:         else
// 64:           args.named.to_paths
// 65:         end
// 66:
// 67:         if target.blank? && args.changed?
// 68:           opoo "No style checks are available for the changed files!"
// 69:           return
// 70:         end
// 71:
// 72:         only_cops = args.only_cops
// 73:         except_cops = args.except_cops
// 74:
// 75:         options = {
// 76:           fix:         args.fix?,
// 77:           todo:        args.todo?,
// 78:           reset_cache: args.reset_cache?,
// 79:           debug:       args.debug?,
// 80:           verbose:     args.verbose?,
// 81:         }
// 82:         if only_cops
// 83:           options[:only_cops] = only_cops
// 84:         elsif except_cops
// 85:           options[:except_cops] = except_cops
// 86:         else
// 87:           options[:except_cops] = %w[FormulaAuditStrict]
// 88:         end
// 89:
// 90:         Homebrew.failed = !Style.check_style_and_print(target || [], **options)
// 91:       end
// 92:
// 93:       sig { returns(T::Array[Pathname]) }
// 94:       def changed_ruby_or_shell_files
// 95:         repository = Utils.popen_read("git", "rev-parse", "--show-toplevel").chomp
// 96:         odie "`brew style --changed` must be run inside a git repository!" unless $CHILD_STATUS.success?
// 97:
// 98:         Utils::Git.changed_files(repository).filter_map do |file|
// 99:           next if !file.end_with?(".rb", ".sh", ".yml", ".rbi") && file != "bin/brew"
// 100:
// 101:           Pathname(file).expand_path(repository)
// 102:         end.select(&:exist?)
// 103:       end
// 104:     end
// 105:   end
// 106: end
