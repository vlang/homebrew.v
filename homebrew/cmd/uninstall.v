module cmd

import homebrew.cli

// Translated from Homebrew/brew `cmd/uninstall.rb`.
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
