module cmd

import ruby
import homebrew.utils
import os

// Translated from Homebrew/brew `cmd/link.rb`.

// LinkCommandKeg is the command-side projection of the Keg and Formula methods
// queried by `brew link`.
pub struct LinkCommandKeg {
pub:
	name                string
	path                string
	rack                string
	version_head        bool
	linked              bool
	keg_only            bool
	formula_unavailable bool
	keg_only_reason     string
	keg_only_text       string
	bin_directory       bool
	sbin_directory      bool
	link_count          int = 1
	link_error          string
}

pub struct LinkOperationOptions {
pub:
	overwrite bool
	dry_run   bool
	verbose   bool
}

pub struct LinkCommandOptions {
pub:
	overwrite      bool
	dry_run        bool
	verbose        bool
	force          bool
	head           bool
	developer      bool
	prefix         string
	default_prefix string
	shell          string
	profile        string = '~/.profile'
}

pub struct LinkCommandOperation {
pub:
	keg_name string
	options  LinkOperationOptions
}

pub struct LinkCommandResult {
pub:
	stdout            string
	stderr            string
	selected_kegs     []string
	linked_kegs       []string
	conflicts_handled []string
	operations        []LinkCommandOperation
}

pub type LinkCommandLinkAction = fn (LinkCommandKeg, LinkOperationOptions) !int

pub type LinkCommandConflictAction = fn (LinkCommandKeg, bool) !

fn link_command_keg_display(keg LinkCommandKeg) string {
	return if keg.path != '' { keg.path } else { keg.name }
}

fn link_command_versioned_formula(keg LinkCommandKeg) bool {
	return !keg.formula_unavailable && keg.keg_only_reason == 'versioned_formula'
}

fn link_command_by_macos(keg LinkCommandKeg) bool {
	return !keg.formula_unavailable && keg.keg_only_reason in [
		'provided_by_macos',
		'shadowed_by_macos',
	]
}

fn link_command_warning(message string) string {
	return 'Warning: ${message}\n'
}

fn link_command_selected_kegs(kegs []LinkCommandKeg, head bool) ([]LinkCommandKeg, string) {
	if !head {
		return kegs.clone(), ''
	}
	mut names := []string{}
	for keg in kegs {
		if keg.name !in names {
			names << keg.name
		}
	}
	mut selected := []LinkCommandKeg{}
	mut stderr := ''
	for name in names {
		resolved := kegs.filter(it.name == name)
		head_kegs := resolved.filter(it.version_head)
		if head_kegs.len > 0 {
			selected << head_kegs[0]
			continue
		}
		stderr += link_command_warning('No HEAD keg installed for ${name}\nTo install, run:\n  brew install --HEAD ${name}')
	}
	return selected, stderr
}

// link_command_keg_only_path_message translates the private output helper. The
// shell and profile are explicit inputs so callers can preserve Homebrew's
// environment-dependent command while tests remain deterministic.
pub fn link_command_keg_only_path_message(keg LinkCommandKeg,
	options LinkCommandOptions) string {
	if !keg.bin_directory && !keg.sbin_directory {
		return ''
	}
	opt := os.join_path(options.prefix, 'opt', keg.name)
	mut output := '\nIf you need to have this software first in your PATH instead consider running:\n'
	if keg.bin_directory {
		if command := utils.shell_prepend_path_in_profile(os.join_path(opt, 'bin'), options.shell, options.profile) {
			output += '  ${command}\n'
		}
	}
	if keg.sbin_directory {
		if command := utils.shell_prepend_path_in_profile(os.join_path(opt, 'sbin'), options.shell, options.profile) {
			output += '  ${command}\n'
		}
	}
	return output
}

pub fn run_link_command(kegs []LinkCommandKeg, options LinkCommandOptions,
	link_action LinkCommandLinkAction, conflict_action LinkCommandConflictAction) !LinkCommandResult {
	operation_options := LinkOperationOptions{
		overwrite: options.overwrite
		dry_run: options.dry_run
		verbose: options.verbose
	}
	selected, selection_stderr := link_command_selected_kegs(kegs, options.head)
	mut stdout := ''
	mut stderr := selection_stderr
	mut linked_kegs := []string{}
	mut conflicts_handled := []string{}
	mut operations := []LinkCommandOperation{}
	for keg in selected {
		versioned_keg_only_formula := link_command_versioned_formula(keg)
		display := link_command_keg_display(keg)
		if keg.linked {
			stderr += link_command_warning('Already linked: ${display}')
			mut name_and_flag := ''
			if options.head {
				name_and_flag += '--HEAD '
			}
			if keg.keg_only && !versioned_keg_only_formula {
				name_and_flag += '--force '
			}
			name_and_flag += keg.name
			stdout += 'To relink, run:\n  brew unlink ${keg.name} && brew link ${name_and_flag}\n'
			continue
		}

		if options.dry_run {
			stdout += if options.overwrite { 'Would remove:\n' } else { 'Would link:\n' }
			operations << LinkCommandOperation{
				keg_name: keg.name
				options: operation_options
			}
			link_action(keg, operation_options)!
			if keg.keg_only && !versioned_keg_only_formula {
				stdout += link_command_keg_only_path_message(keg, options)
			}
			continue
		}

		if keg.keg_only {
			if options.prefix == options.default_prefix && link_command_by_macos(keg) {
				mut warning := 'Refusing to link macOS provided/shadowed software: ${keg.name}'
				if keg.keg_only_text.trim_space() != '' {
					warning += '\n${keg.keg_only_text.trim_space()}'
				}
				stderr += link_command_warning(warning)
				continue
			}

			if !options.force && (keg.formula_unavailable || !versioned_keg_only_formula) {
				stderr += link_command_warning('${keg.name} is keg-only and must be linked with `--force`.')
				stdout += link_command_keg_only_path_message(keg, options)
				continue
			}
		}

		if !keg.formula_unavailable {
			conflicts_handled << keg.name
			conflict_action(keg, options.verbose)!
		}

		stdout += 'Linking ${display}... '
		if options.verbose {
			stdout += '\n'
		}
		operations << LinkCommandOperation{
			keg_name: keg.name
			options: operation_options
		}
		count := link_action(keg, operation_options)!
		stdout += '${count} symlinks created.\n'
		linked_kegs << keg.name

		if keg.keg_only && !versioned_keg_only_formula && !options.developer {
			stdout += link_command_keg_only_path_message(keg, options)
		}
	}
	return LinkCommandResult{
		stdout: stdout
		stderr: stderr
		selected_kegs: selected.map(it.name)
		linked_kegs: linked_kegs
		conflicts_handled: conflicts_handled
		operations: operations
	}
}

fn link_command_default_link(keg LinkCommandKeg, _ LinkOperationOptions) !int {
	if keg.link_error != '' {
		return error(keg.link_error)
	}
	return keg.link_count
}

fn link_command_default_conflict(_ LinkCommandKeg, _ bool) ! {}

pub fn link_command_keg_value(keg LinkCommandKeg) ruby.Value {
	return ruby.structured_value('Keg', link_command_keg_display(keg), {
		'name':                keg.name
		'path':                keg.path
		'rack':                keg.rack
		'version_head':        keg.version_head.str()
		'linked':              keg.linked.str()
		'keg_only':            keg.keg_only.str()
		'formula_unavailable': keg.formula_unavailable.str()
		'keg_only_reason':     keg.keg_only_reason
		'keg_only_text':       keg.keg_only_text
		'bin_directory':       keg.bin_directory.str()
		'sbin_directory':      keg.sbin_directory.str()
		'link_count':          keg.link_count.str()
		'link_error':          keg.link_error
	})
}
