module cmd

import homebrew.cli

// Translated from Homebrew/brew `cmd/uninstall.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum UninstallItemKind {
	keg
	cask
	unavailable
}

pub enum UninstallCaskMetadata {
	trusted_source
	json
	legacy_ruby
	recorded_artifacts
}

pub struct UninstallItem {
pub:
	kind               UninstallItemKind
	name               string
	full_name          string
	rack               string
	tap                ?string
	tap_trusted        bool
	installed          bool = true
	pinned             bool
	dependency_blocked bool
	dependent_error    ?string
	uninstall_error    ?string
	zap_error          ?string
	metadata           UninstallCaskMetadata = .trusted_source
	untrusted          bool
	load_error         ?string
}

pub struct UninstallOptions {
pub:
	named               []string
	force               bool
	zap                 bool
	ignore_dependencies bool
	formula             bool
	cask                bool
	verbose             bool
	no_autoremove       bool
	autoremove_env_set  bool
	require_tap_trust   bool
}

pub struct UninstallResult {
pub:
	stdout             string
	stderr             string
	failed             bool
	removed_kegs       []string
	removed_casks      []string
	untrusted_items    []string
	uninstall_racks    map[string][]string
	autoremove_ran     bool
	dependent_checked  bool
	used_recorded_data []string
	actions            []string
}

pub fn new_uninstall_parser() cli.Parser {
	mut parser := cli.new_parser('uninstall')
	parser.add_switch(['-f', '--force'], cli.OptionConfig{})
	parser.add_switch(['--zap'], cli.OptionConfig{})
	parser.add_switch(['--ignore-dependencies'], cli.OptionConfig{})
	parser.add_switch(['--formula', '--formulae'], cli.OptionConfig{})
	parser.add_switch(['--cask', '--casks'], cli.OptionConfig{})
	parser.add_conflicts(['--formula', '--cask'])
	parser.add_conflicts(['--formula', '--zap'])
	parser.set_named_args(['installed_formula', 'installed_cask'], 1, none)
	return parser
}

pub fn parse_uninstall_arguments(arguments []string) !UninstallOptions {
	mut parser := new_uninstall_parser()
	parsed := parser.parse(arguments, false)!
	return UninstallOptions{
		named: parsed.named.values.clone()
		force: parsed.has('force')
		zap: parsed.has('zap')
		ignore_dependencies: parsed.has('ignore_dependencies')
		formula: parsed.has('formula')
		cask: parsed.has('cask')
	}
}

fn uninstall_item_name(item UninstallItem) string {
	return if item.full_name != '' { item.full_name } else { item.name }
}

fn uninstall_tap_from_name(name string) ?string {
	parts := name.split('/')
	if parts.len < 3 {
		return none
	}
	return '${parts[0]}/${parts[1]}'
}

fn uninstall_unique(values []string) []string {
	mut result := []string{}
	for value in values {
		if value !in result {
			result << value
		}
	}
	return result
}

pub fn run_uninstall(items []UninstallItem, options UninstallOptions) UninstallResult {
	mut unavailable := []UninstallItem{}
	mut kegs := []UninstallItem{}
	mut casks := []UninstallItem{}
	for item in items {
		match item.kind {
			.unavailable { unavailable << item }
			.keg { kegs << item }
			.cask { casks << item }
		}
	}
	if kegs.len == 0 && casks.len == 0 && unavailable.len == 0 {
		return UninstallResult{}
	}
	mut stdout := []string{}
	mut stderr := []string{}
	mut actions := []string{}
	mut removed_kegs := []string{}
	mut removed_casks := []string{}
	mut untrusted_items := []string{}
	mut recorded_data := []string{}
	mut racks := map[string][]string{}
	mut failed := false

	for keg in kegs {
		name := uninstall_item_name(keg)
		rack := if keg.rack != '' { keg.rack } else { keg.name }
		racks[rack] << name
		if keg.pinned && !options.force {
			stderr << 'Error: ${name} is pinned. Unpin it before uninstalling.'
			failed = true
			continue
		}
		if keg.dependency_blocked && !options.ignore_dependencies {
			stderr << 'Error: Refusing to uninstall ${name} because it is required by another installed formula.'
			failed = true
			continue
		}
		stdout << 'Uninstalling ${name}'
		removed_kegs << name
		actions << 'uninstall_keg:${name}:force=${options.force}:ignore_dependencies=${options.ignore_dependencies}'
	}

	mut dependent_checked := false
	if !options.ignore_dependencies {
		dependent_checked = true
		for cask in casks {
			if message := cask.dependent_error {
				stderr << 'Error: ${message}'
				failed = true
			}
		}
	}
	// The Ruby command stops before cask removal when keg or dependent checks
	// have already marked the command as failed.
	if failed {
		return UninstallResult{
			stdout: if stdout.len > 0 { '${stdout.join('\n')}\n' } else { '' }
			stderr: if stderr.len > 0 { '${stderr.join('\n')}\n' } else { '' }
			failed: true
			removed_kegs: removed_kegs
			uninstall_racks: racks
			dependent_checked: dependent_checked
			actions: actions
		}
	}

	mut cask_errors := []string{}
	for cask in casks {
		name := uninstall_item_name(cask)
		if options.require_tap_trust && cask.untrusted {
			if cask.metadata in [.legacy_ruby, .recorded_artifacts] {
				stderr << 'Warning: Skipping loading untrusted Cask ${name}; uninstalling recorded artifacts only'
				recorded_data << name
			} else if cask.metadata == .json {
				recorded_data << name
			}
		}
		if options.zap {
			actions << 'zap_cask:${name}:force=${options.force}:verbose=${options.verbose}'
			if !cask.installed && !options.force {
				cask_errors << 'Cask ${name} is not installed.'
				continue
			}
			if cask.pinned && !options.force {
				actions << 'skip_pinned_cask:${name}'
				continue
			}
			if message := cask.zap_error {
				cask_errors << message
				continue
			}
			stdout << 'Zapping Cask ${cask.name}'
		} else {
			actions << 'uninstall_cask:${name}:force=${options.force}:verbose=${options.verbose}'
			if message := cask.uninstall_error {
				cask_errors << message
				continue
			}
			stdout << 'Uninstalling Cask ${cask.name}'
		}
		removed_casks << name
	}
	if cask_errors.len == 1 {
		stderr << 'Error: ${cask_errors[0]}'
		failed = true
	} else if cask_errors.len > 1 {
		stderr << 'Error: Multiple Cask errors:\n${cask_errors.join('\n')}'
		failed = true
	}

	mut trust_candidates := []string{}
	for item in kegs {
		if tap := item.tap {
			trust_candidates << 'formula|${tap}/${item.name}|${item.tap_trusted}'
		}
	}
	for cask in casks {
		name := uninstall_item_name(cask)
		if _ := uninstall_tap_from_name(name) {
			trust_candidates << 'cask|${name}|${cask.tap_trusted}'
		}
	}
	for candidate in uninstall_unique(trust_candidates) {
		parts := candidate.split('|')
		if parts.len == 3 && parts[2] != 'true' {
			untrusted_items << '${parts[0]}:${parts[1]}'
			actions << 'untrust:${parts[0]}:${parts[1]}'
		}
	}

	if options.autoremove_env_set {
		stderr << 'Warning: `\$HOMEBREW_AUTOREMOVE` is now a no-op as it is the default behaviour. Set `HOMEBREW_NO_AUTOREMOVE=1` to disable it.'
	}
	autoremove_ran := !options.no_autoremove
	if autoremove_ran {
		actions << 'cleanup_autoremove'
	}
	if !options.force {
		for error_item in unavailable {
			stderr << 'Error: ${uninstall_item_name(error_item)} is unavailable.'
			failed = true
		}
	}
	return UninstallResult{
		stdout: if stdout.len > 0 { '${stdout.join('\n')}\n' } else { '' }
		stderr: if stderr.len > 0 { '${stderr.join('\n')}\n' } else { '' }
		failed: failed
		removed_kegs: removed_kegs
		removed_casks: removed_casks
		untrusted_items: untrusted_items
		uninstall_racks: racks
		autoremove_ran: autoremove_ran
		dependent_checked: dependent_checked
		used_recorded_data: recorded_data
		actions: actions
	}
}

// Ruby method `run` at line 44.
pub fn ruby_uninstall_l44_d1_run(items []UninstallItem,
	options UninstallOptions) UninstallResult {
	return run_uninstall(items, options)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "keg"
// 6: require "formula"
// 7: require "diagnostic"
// 8: require "migrator"
// 9: require "cask/cask_loader"
// 10: require "cask/exceptions"
// 11: require "cask/installer"
// 12: require "cask/uninstall"
// 13: require "uninstall"
// 14: require "trust"
// 15:
// 16: module Homebrew
// 17:   module Cmd
// 18:     class UninstallCmd < AbstractCommand
// 19:       cmd_args do
// 20:         description <<~EOS
// 21:           Uninstall a <formula> or <cask>.
// 22:         EOS
// 23:         switch "-f", "--force",
// 24:                description: "Delete all installed versions of <formula>. Uninstall even if <cask> is not " \
// 25:                             "installed, overwrite existing files and ignore errors when removing files."
// 26:         switch "--zap",
// 27:                description: "Remove all files associated with a <cask>. " \
// 28:                             "*May remove files which are shared between applications.*"
// 29:         switch "--ignore-dependencies",
// 30:                description: "Don't fail uninstall, even if <formula> is a dependency of any installed " \
// 31:                             "formulae."
// 32:         switch "--formula", "--formulae",
// 33:                description: "Treat all named arguments as formulae."
// 34:         switch "--cask", "--casks",
// 35:                description: "Treat all named arguments as casks."
// 36:
// 37:         conflicts "--formula", "--cask"
// 38:         conflicts "--formula", "--zap"
// 39:
// 40:         named_args [:installed_formula, :installed_cask], min: 1
// 41:       end
// 42:
// 43:       sig { override.void }
// 44:       def run
// 45:         method = args.force? ? :kegs : :default_kegs
// 46:         results = args.named.to_formulae_and_casks_and_unavailable(method:)
// 47:
// 48:         unavailable_errors = T.let([], T::Array[T.any(FormulaOrCaskUnavailableError, NoSuchKegError)])
// 49:         all_kegs = T.let([], T::Array[Keg])
// 50:         casks = T.let([], T::Array[Cask::Cask])
// 51:         trusted_items_to_remove = T.let([], T::Array[[Symbol, String]])
// 52:
// 53:         results.each do |item|
// 54:           case item
// 55:           when FormulaOrCaskUnavailableError, NoSuchKegError
// 56:             unavailable_errors << item
// 57:           when Cask::Cask
// 58:             casks << item
// 59:             trusted_items_to_remove << [:cask, item.full_name]
// 60:           when Keg
// 61:             all_kegs << item
// 62:             single_keg_tap = item.tab.tap
// 63:             trusted_items_to_remove << [:formula, "#{single_keg_tap.name}/#{item.name}"] if single_keg_tap
// 64:           when Array
// 65:             all_kegs += item
// 66:             item.each do |keg|
// 67:               array_keg_tap = keg.tab.tap
// 68:               trusted_items_to_remove << [:formula, "#{array_keg_tap.name}/#{keg.name}"] if array_keg_tap
// 69:             end
// 70:           end
// 71:         end
// 72:
// 73:         return if all_kegs.blank? && casks.blank? && unavailable_errors.blank?
// 74:
// 75:         kegs_by_rack = all_kegs.group_by(&:rack)
// 76:
// 77:         Uninstall.uninstall_kegs(
// 78:           kegs_by_rack,
// 79:           casks:,
// 80:           force:               args.force?,
// 81:           ignore_dependencies: args.ignore_dependencies?,
// 82:           named_args:          args.named,
// 83:         )
// 84:
// 85:         Cask::Uninstall.check_dependent_casks(*casks, named_args: args.named) unless args.ignore_dependencies?
// 86:
// 87:         return if Homebrew.failed?
// 88:
// 89:         begin
// 90:           if args.zap?
// 91:             caught_exceptions = []
// 92:
// 93:             casks.each do |cask|
// 94:               odebug "Zapping Cask #{cask}"
// 95:
// 96:               raise Cask::CaskNotInstalledError, cask if !cask.installed? && !args.force?
// 97:
// 98:               next unless Cask::Uninstall.unpin_for_removal?(cask, force: args.force?)
// 99:
// 100:               Cask::Installer.new(cask, verbose: args.verbose?, force: args.force?).zap
// 101:             rescue => e
// 102:               caught_exceptions << e
// 103:               next
// 104:             end
// 105:
// 106:             if caught_exceptions.count > 1
// 107:               raise Cask::MultipleCaskErrors, caught_exceptions
// 108:             elsif caught_exceptions.one?
// 109:               raise caught_exceptions.fetch(0)
// 110:             end
// 111:           else
// 112:             Cask::Uninstall.uninstall_casks(
// 113:               *casks,
// 114:               verbose: args.verbose?,
// 115:               force:   args.force?,
// 116:             )
// 117:           end
// 118:         rescue => e
// 119:           ofail e
// 120:         end
// 121:
// 122:         trusted_items_to_remove.uniq.each do |type, name|
// 123:           next unless (tap_name = Utils.tap_from_full_name(name))
// 124:           next if Homebrew::Trust.trusted?(:tap, tap_name)
// 125:
// 126:           Homebrew::Trust.untrust!(type, name)
// 127:         end
// 128:
// 129:         if ENV["HOMEBREW_AUTOREMOVE"].present?
// 130:           opoo "`$HOMEBREW_AUTOREMOVE` is now a no-op as it is the default behaviour. " \
// 131:                "Set `HOMEBREW_NO_AUTOREMOVE=1` to disable it."
// 132:         end
// 133:         Cleanup.autoremove unless Homebrew::EnvConfig.no_autoremove?
// 134:
// 135:         unavailable_errors.each { |e| ofail e } unless args.force?
// 136:       end
// 137:     end
// 138:   end
// 139: end
