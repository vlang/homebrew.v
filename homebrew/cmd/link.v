module cmd

import brew_runtime
import homebrew.utils
import os

// Translated from Homebrew/brew `cmd/link.rb`.
// The original source is retained below until every stub has a typed V body.

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

pub type LinkCommandLinkAction = fn(LinkCommandKeg, LinkOperationOptions) !int

pub type LinkCommandConflictAction = fn(LinkCommandKeg, bool) !

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

pub fn link_command_keg_value(keg LinkCommandKeg) brew_runtime.Value {
	return brew_runtime.structured_value('Keg', link_command_keg_display(keg), {
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

fn link_command_keg_from_value(value brew_runtime.Value) LinkCommandKeg {
	return LinkCommandKeg{
		name: value.attributes['name'] or { value.as_string() }
		path: value.attributes['path'] or { value.as_string() }
		rack: value.attributes['rack'] or { '' }
		version_head: (value.attributes['version_head'] or { 'false' }).bool()
		linked: (value.attributes['linked'] or { 'false' }).bool()
		keg_only: (value.attributes['keg_only'] or { 'false' }).bool()
		formula_unavailable: (value.attributes['formula_unavailable'] or { 'false' }).bool()
		keg_only_reason: value.attributes['keg_only_reason'] or { '' }
		keg_only_text: value.attributes['keg_only_text'] or { '' }
		bin_directory: (value.attributes['bin_directory'] or { 'false' }).bool()
		sbin_directory: (value.attributes['sbin_directory'] or { 'false' }).bool()
		link_count: (value.attributes['link_count'] or { '1' }).int()
		link_error: value.attributes['link_error'] or { '' }
	}
}

pub fn link_command_options_value(options LinkCommandOptions) brew_runtime.Value {
	return brew_runtime.map_value({
		'overwrite':      brew_runtime.bool_value(options.overwrite)
		'dry_run':        brew_runtime.bool_value(options.dry_run)
		'verbose':        brew_runtime.bool_value(options.verbose)
		'force':          brew_runtime.bool_value(options.force)
		'head':           brew_runtime.bool_value(options.head)
		'developer':      brew_runtime.bool_value(options.developer)
		'prefix':         brew_runtime.string_value(options.prefix)
		'default_prefix': brew_runtime.string_value(options.default_prefix)
		'shell':          brew_runtime.string_value(options.shell)
		'profile':        brew_runtime.string_value(options.profile)
	})
}

fn link_command_options_from_value(value brew_runtime.Value) LinkCommandOptions {
	values := value.as_map() or { return LinkCommandOptions{} }
	return LinkCommandOptions{
		overwrite: if option := values['overwrite'] { option.bool_data } else { false }
		dry_run: if option := values['dry_run'] { option.bool_data } else { false }
		verbose: if option := values['verbose'] { option.bool_data } else { false }
		force: if option := values['force'] { option.bool_data } else { false }
		head: if option := values['head'] { option.bool_data } else { false }
		developer: if option := values['developer'] { option.bool_data } else { false }
		prefix: if option := values['prefix'] { option.as_string() } else { '' }
		default_prefix: if option := values['default_prefix'] { option.as_string() } else { '' }
		shell: if option := values['shell'] { option.as_string() } else { '' }
		profile: if option := values['profile'] { option.as_string() } else { '~/.profile' }
	}
}

pub fn link_command_result_value(result LinkCommandResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'stdout':            brew_runtime.string_value(result.stdout)
		'stderr':            brew_runtime.string_value(result.stderr)
		'selected_kegs':     brew_runtime.string_array_value(result.selected_kegs)
		'linked_kegs':       brew_runtime.string_array_value(result.linked_kegs)
		'conflicts_handled': brew_runtime.string_array_value(result.conflicts_handled)
		'operations':        brew_runtime.array_value(result.operations.map(brew_runtime.structured_value('LinkOperation', it.keg_name, {
			'name':      it.keg_name
			'overwrite': it.options.overwrite.str()
			'dry_run':   it.options.dry_run.str()
			'verbose':   it.options.verbose.str()
		})))
	})
}

// Ruby method `run` at line 31.
pub fn ruby_link_l31_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'link command input is required')
	}
	request := args[0].as_map() or {
		return brew_runtime.object_value('ArgumentError', err.msg())
	}
	keg_values := if value := request['kegs'] {
		value.as_array() or { []brew_runtime.Value{} }
	} else {
		[]brew_runtime.Value{}
	}
	options := if value := request['options'] {
		link_command_options_from_value(value)
	} else {
		LinkCommandOptions{}
	}
	result := run_link_command(keg_values.map(link_command_keg_from_value(it)), options, link_command_default_link, link_command_default_conflict) or {
		return brew_runtime.object_value('Keg::LinkError', err.msg())
	}
	return link_command_result_value(result)
}

// Ruby method `puts_keg_only_path_message(keg)` at line 132.
pub fn ruby_link_l132_d2_puts_keg_only_path_message(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'keg is required')
	}
	options := if args.len > 1 {
		link_command_options_from_value(args[1])
	} else {
		LinkCommandOptions{}
	}
	return brew_runtime.string_value(link_command_keg_only_path_message(link_command_keg_from_value(args[0]), options))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "caveats"
// 6: require "unlink"
// 7:
// 8: module Homebrew
// 9:   module Cmd
// 10:     class Link < AbstractCommand
// 11:       cmd_args do
// 12:         description <<~EOS
// 13:           Symlink all of <formula>'s installed files into Homebrew's prefix.
// 14:           This is done automatically when you install formulae but can be useful
// 15:           for manual installations.
// 16:         EOS
// 17:         switch "--overwrite",
// 18:                description: "Delete files that already exist in the prefix while linking."
// 19:         switch "-n", "--dry-run",
// 20:                description: "List files which would be linked or deleted by " \
// 21:                             "`brew link --overwrite` without actually linking or deleting any files."
// 22:         switch "-f", "--force",
// 23:                description: "Allow keg-only formulae to be linked."
// 24:         switch "--HEAD",
// 25:                description: "Link the HEAD version of the formula if it is installed."
// 26:
// 27:         named_args :installed_formula, min: 1
// 28:       end
// 29:
// 30:       sig { override.void }
// 31:       def run
// 32:         options = {
// 33:           overwrite: args.overwrite?,
// 34:           dry_run:   args.dry_run?,
// 35:           verbose:   args.verbose?,
// 36:         }
// 37:
// 38:         kegs = if args.HEAD?
// 39:           args.named.to_kegs.group_by(&:name).filter_map do |name, resolved_kegs|
// 40:             head_keg = resolved_kegs.find { |keg| keg.version.head? }
// 41:             next head_keg if head_keg.present?
// 42:
// 43:             opoo <<~EOS
// 44:               No HEAD keg installed for #{name}
// 45:               To install, run:
// 46:                 brew install --HEAD #{name}
// 47:             EOS
// 48:
// 49:             nil
// 50:           end
// 51:         else
// 52:           args.named.to_latest_kegs
// 53:         end
// 54:
// 55:         kegs.freeze.each do |keg|
// 56:           keg_only = Formulary.keg_only?(keg.rack)
// 57:           formula = begin
// 58:             keg.to_formula
// 59:           rescue FormulaUnavailableError
// 60:             # Not all kegs may belong to current formulae
// 61:             nil
// 62:           end
// 63:           versioned_keg_only_formula = formula.present? && formula.keg_only_reason&.versioned_formula?
// 64:
// 65:           if keg.linked?
// 66:             opoo "Already linked: #{keg}"
// 67:             name_and_flag = +""
// 68:             name_and_flag << "--HEAD " if args.HEAD?
// 69:             name_and_flag << "--force " if keg_only && !versioned_keg_only_formula
// 70:             name_and_flag << keg.name
// 71:             puts <<~EOS
// 72:               To relink, run:
// 73:                 brew unlink #{keg.name} && brew link #{name_and_flag}
// 74:             EOS
// 75:             next
// 76:           end
// 77:
// 78:           if args.dry_run?
// 79:             if args.overwrite?
// 80:               puts "Would remove:"
// 81:             else
// 82:               puts "Would link:"
// 83:             end
// 84:             keg.link(**options)
// 85:             puts_keg_only_path_message(keg) if keg_only && !versioned_keg_only_formula
// 86:             next
// 87:           end
// 88:
// 89:           if keg_only
// 90:             if HOMEBREW_PREFIX.to_s == HOMEBREW_DEFAULT_PREFIX && formula.present? &&
// 91:                formula.keg_only_reason.by_macos?
// 92:               caveats = Caveats.new(formula)
// 93:               opoo <<~EOS
// 94:                 Refusing to link macOS provided/shadowed software: #{keg.name}
// 95:                 #{T.must(caveats.keg_only_text(skip_reason: true)).strip}
// 96:               EOS
// 97:               next
// 98:             end
// 99:
// 100:             if !args.force? && (formula.nil? || !formula.keg_only_reason.versioned_formula?)
// 101:               opoo "#{keg.name} is keg-only and must be linked with `--force`."
// 102:               puts_keg_only_path_message(keg)
// 103:               next
// 104:             end
// 105:           end
// 106:
// 107:           Unlink.unlink_link_overwrite_formulae(formula, verbose: args.verbose?) if formula
// 108:
// 109:           keg.lock do
// 110:             print "Linking #{keg}... "
// 111:             puts if args.verbose?
// 112:
// 113:             begin
// 114:               n = keg.link(**options)
// 115:             rescue Keg::LinkError
// 116:               puts
// 117:               raise
// 118:             else
// 119:               puts "#{n} symlinks created."
// 120:             end
// 121:
// 122:             if keg_only && !versioned_keg_only_formula && !Homebrew::EnvConfig.developer?
// 123:               puts_keg_only_path_message(keg)
// 124:             end
// 125:           end
// 126:         end
// 127:       end
// 128:
// 129:       private
// 130:
// 131:       sig { params(keg: Keg).void }
// 132:       def puts_keg_only_path_message(keg)
// 133:         bin = keg/"bin"
// 134:         sbin = keg/"sbin"
// 135:         return if !bin.directory? && !sbin.directory?
// 136:
// 137:         opt = HOMEBREW_PREFIX/"opt/#{keg.name}"
// 138:         puts "\nIf you need to have this software first in your PATH instead consider running:"
// 139:         puts "  #{Utils::Shell.prepend_path_in_profile(opt/"bin")}"  if bin.directory?
// 140:         puts "  #{Utils::Shell.prepend_path_in_profile(opt/"sbin")}" if sbin.directory?
// 141:       end
// 142:     end
// 143:   end
// 144: end
