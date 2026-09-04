module cmd

import ruby
import homebrew.utils
import os

// Translated from Homebrew/brew `cmd/tap-info.rb`.
pub struct TapInfoPackage {
pub:
	outdated   bool
	deprecated bool
	disabled   bool
	loadable   bool = true
}

pub struct TapInfoTap {
pub mut:
	name             string
	installed        bool
	contents         []string
	private_tap      bool
	path             string
	abbreviated_path string
	remote           string
	default_remote   string
	git_head         string
	git_last_commit  string
	git_branch       string
	formula_files    []string
	command_files    []string
	formula_names    []string
	cask_tokens      []string
	trusted          bool
	hash             map[string]string
}

pub struct TapInfoContext {
pub:
	installed             bool
	json_version          ?string
	named_taps            []TapInfoTap
	installed_taps        []TapInfoTap
	installed_formulae    []string
	installed_casks       []string
	formulae              map[string]TapInfoPackage
	casks                 map[string]TapInfoPackage
	require_tap_trust     bool
	tap_directory         string
	tap_directory_present bool
	tty                   bool = true
	console_width         int = 80
}

pub struct TapInfoResult {
pub mut:
	stdout      string
	stderr      string
	failed      bool
	usage_error string
}

fn tap_info_short_name(full_name string) string {
	parts := full_name.split('/')
	return if parts.len > 0 { parts.last() } else { full_name }
}

fn tap_info_sorted(values []string) []string {
	mut result := values.clone()
	result.sort()
	return result
}

fn tap_info_status(name string, installed bool, package ?TapInfoPackage, tty bool) string {
	state := package or { TapInfoPackage{ loadable: false } }
	return utils.pretty_install_status(name, utils.InstallStatusOptions{
		installed: installed
		outdated: installed && state.loadable && state.outdated
		deprecated: state.loadable && state.deprecated
		disabled: state.loadable && state.disabled
		mark_uninstalled: false
	}, utils.OutputOptions{
		tty: utils.TtyState{
			stream_is_tty: tty
		}
	})
}

pub fn tap_info_decorate_formula(tap TapInfoTap, name string, installed bool,
	formulae map[string]TapInfoPackage, tty bool) string {
	package := formulae['${tap.name}/${name}'] or { formulae[name] or { TapInfoPackage{ loadable: false } } }
	return tap_info_status(name, installed, package, tty)
}

pub fn tap_info_decorate_cask(tap TapInfoTap, token string, installed bool,
	casks map[string]TapInfoPackage, tty bool) string {
	package := casks['${tap.name}/${token}'] or { casks[token] or { TapInfoPackage{ loadable: false } } }
	return tap_info_status(token, installed, package, tty)
}

fn tap_info_header(label string) string {
	return '==> ${label}\n'
}

fn tap_info_print_section(tap TapInfoTap, label string, all []string, installed []string,
	decorated map[string]string, min_width int, tty bool, console_width int) TapInfoResult {
	if all.len == 0 {
		return TapInfoResult{}
	}
	mut result := TapInfoResult{
		stdout: tap_info_header(label)
	}
	if all.len <= 30 {
		result.stdout += utils.formatter_columns(all.map(decorated[it] or { it }), console_width, tty, 2, min_width)
	} else if installed.len > 0 {
		result.stderr = 'Warning: Tap has more than 30 ${label.to_lower()}; showing only installed entries.\n'
		result.stdout += utils.formatter_columns(installed.map(decorated[it] or { it }), console_width, tty, 2, min_width)
	} else {
		result.stderr = 'Warning: Tap has more than 30 ${label.to_lower()} and none are installed.\n'
		if tap.remote != '' {
			result.stdout += 'See: ${tap.remote}\n'
		}
	}
	return result
}

pub fn tap_info_print_tap_listings(tap TapInfoTap, installed_formulae []string,
	installed_casks []string, formulae map[string]TapInfoPackage, casks map[string]TapInfoPackage,
	tty bool, console_width int) TapInfoResult {
	mut result := TapInfoResult{}
	mut commands := tap.command_files.map(os.file_name(it).all_before_last('.').trim_string_left('brew-'))
	commands.sort()
	formula_names := tap_info_sorted(tap.formula_names.map(tap_info_short_name(it)))
	cask_tokens := tap_info_sorted(tap.cask_tokens.map(tap_info_short_name(it)))
	selected_formulae := formula_names.filter(it in installed_formulae)
	selected_casks := cask_tokens.filter(it in installed_casks)
	if commands.len > 0 {
		result.stdout += tap_info_header('Commands') + commands.join(', ') + '\n'
	}
	mut min_width := 0
	mut all_names := formula_names.clone()
	all_names << cask_tokens
	for name in all_names {
		if name.runes().len > min_width {
			min_width = name.runes().len
		}
	}
	mut decorated_formulae := map[string]string{}
	for name in formula_names {
		decorated_formulae[name] = tap_info_decorate_formula(tap, name, name in installed_formulae, formulae, tty)
	}
	formula_section := tap_info_print_section(tap, 'Formulae', formula_names, selected_formulae, decorated_formulae, min_width, tty, console_width)
	result.stdout += formula_section.stdout
	result.stderr += formula_section.stderr
	mut decorated_casks := map[string]string{}
	for token in cask_tokens {
		decorated_casks[token] = tap_info_decorate_cask(tap, token, token in installed_casks, casks, tty)
	}
	cask_section := tap_info_print_section(tap, 'Casks', cask_tokens, selected_casks, decorated_casks, min_width, tty, console_width)
	result.stdout += cask_section.stdout
	result.stderr += cask_section.stderr
	return result
}

fn tap_info_plural(stem string, count int) string {
	if stem == 'formula' {
		return '${count} ${if count == 1 { 'formula' } else { 'formulae' }}'
	}
	return '${count} ${stem}${if count == 1 { '' } else { 's' }}'
}

pub fn tap_info_print_info(taps []TapInfoTap, context TapInfoContext) TapInfoResult {
	if taps.len == 0 {
		stats := context.installed_taps
		mut formula_count := 0
		mut command_count := 0
		for tap in stats {
			formula_count += tap.formula_files.len
			command_count += tap.command_files.len
		}
		private_count := stats.filter(it.private_tap).len
		mut line := tap_info_plural('tap', stats.len) + ', ${private_count} private, ' + tap_info_plural('formula', formula_count) + ', ' + tap_info_plural('command', command_count)
		if context.tap_directory_present {
			line += ', ${context.tap_directory}'
		}
		return TapInfoResult{
			stdout: line + '\n'
		}
	}
	mut result := TapInfoResult{}
	for index, tap in taps {
		if index > 0 {
			result.stdout += '\n'
		}
		mut info := '${tap.name}: '
		if !tap.installed {
			result.stdout += info + 'Not installed\n'
			result.failed = true
			continue
		}
		info += 'Installed'
		if context.require_tap_trust {
			info += if tap.trusted { '\nTrusted' } else { '\nUntrusted' }
		}
		info += if tap.contents.len == 0 {
			'\nNo commands/casks/formulae'
		} else {
			'\n${tap.contents.join(', ')}'
		}
		if tap.private_tap {
			info += '\nPrivate'
		}
		abbreviated := if tap.abbreviated_path != '' { tap.abbreviated_path } else { tap.path }
		info += '\n${tap.path} (${abbreviated})'
		info += '\nFrom: ${if tap.remote != '' { tap.remote } else { 'N/A' }}'
		if tap.remote != tap.default_remote {
			info += '\norigin: ${tap.remote}'
		}
		info += '\nHEAD: ${if tap.git_head != '' { tap.git_head } else { '(none)' }}'
		info += '\nlast commit: ${if tap.git_last_commit != '' {
			tap.git_last_commit
		} else {
			'never'
		}}'
		if tap.git_branch !in ['main', 'master'] {
			info += '\nbranch: ${if tap.git_branch != '' { tap.git_branch } else { '(none)' }}'
		}
		result.stdout += info + '\n'
		listing := tap_info_print_tap_listings(tap, context.installed_formulae, context.installed_casks, context.formulae, context.casks, context.tty, context.console_width)
		result.stdout += listing.stdout
		result.stderr += listing.stderr
	}
	return result
}

fn tap_info_json_escape(value string) string {
	return value.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n')
}

pub fn tap_info_print_json(taps []TapInfoTap) string {
	mut objects := []string{cap: taps.len}
	for tap in taps {
		mut hash := tap.hash.clone()
		if hash.len == 0 {
			hash['name'] = tap.name
			hash['remote'] = tap.remote
		}
		mut keys := hash.keys()
		keys.sort()
		fields := keys.map('    "${tap_info_json_escape(it)}": "${tap_info_json_escape(hash[it])}"')
		objects << '  {\n${fields.join(',\n')}\n  }'
	}
	return '[\n${objects.join(',\n')}\n]\n'
}

pub fn tap_info_run(context TapInfoContext) TapInfoResult {
	mut taps := if context.installed {
		context.installed_taps.clone()
	} else {
		context.named_taps.clone()
	}
	taps.sort_with_compare(fn (a &TapInfoTap, b &TapInfoTap) int {
		return a.name.compare(b.name)
	})
	if version := context.json_version {
		if version !in ['v1', 'true'] {
			return TapInfoResult{
				usage_error: 'invalid JSON version: ${version}'
			}
		}
		return TapInfoResult{
			stdout: tap_info_print_json(taps)
		}
	}
	return tap_info_print_info(taps, context)
}

pub fn tap_info_tap_value(tap TapInfoTap) ruby.Value {
	mut hash := map[string]ruby.Value{}
	for key, value in tap.hash {
		hash[key] = ruby.string_value(value)
	}
	return ruby.Value{
		type_name: 'Tap'
		repr: tap.name
		attributes: {
			'name':             tap.name
			'installed':        tap.installed.str()
			'private':          tap.private_tap.str()
			'path':             tap.path
			'abbreviated_path': tap.abbreviated_path
			'remote':           tap.remote
			'default_remote':   tap.default_remote
			'git_head':         tap.git_head
			'git_last_commit':  tap.git_last_commit
			'git_branch':       tap.git_branch
			'trusted':          tap.trusted.str()
		}
		map_data: {
			'contents':      ruby.string_array_value(tap.contents)
			'formula_files': ruby.string_array_value(tap.formula_files)
			'command_files': ruby.string_array_value(tap.command_files)
			'formula_names': ruby.string_array_value(tap.formula_names)
			'cask_tokens':   ruby.string_array_value(tap.cask_tokens)
			'hash':          ruby.map_value(hash)
		}
	}
}

fn tap_info_string_array(value ruby.Value, key string) []string {
	return (value.map_data[key] or { ruby.array_value([]) }).as_array() or { [] }.map(it.as_string())
}

fn tap_info_tap_from_value(value ruby.Value) TapInfoTap {
	mut hash := map[string]string{}
	if hash_value := value.map_data['hash'] {
		for key, item in hash_value.map_data {
			hash[key] = item.as_string()
		}
	}
	return TapInfoTap{
		name: value.attribute('name') or { value.as_string() }
		installed: (value.attribute('installed') or { 'true' }) == 'true'
		contents: tap_info_string_array(value, 'contents')
		private_tap: (value.attribute('private') or { 'false' }) == 'true'
		path: value.attribute('path') or { '' }
		abbreviated_path: value.attribute('abbreviated_path') or { '' }
		remote: value.attribute('remote') or { '' }
		default_remote: value.attribute('default_remote') or { '' }
		git_head: value.attribute('git_head') or { '' }
		git_last_commit: value.attribute('git_last_commit') or { '' }
		git_branch: value.attribute('git_branch') or { '' }
		formula_files: tap_info_string_array(value, 'formula_files')
		command_files: tap_info_string_array(value, 'command_files')
		formula_names: tap_info_string_array(value, 'formula_names')
		cask_tokens: tap_info_string_array(value, 'cask_tokens')
		trusted: (value.attribute('trusted') or { 'false' }) == 'true'
		hash: hash
	}
}

fn tap_info_package_from_value(value ruby.Value) TapInfoPackage {
	return TapInfoPackage{
		outdated: (value.attribute('outdated') or { 'false' }) == 'true'
		deprecated: (value.attribute('deprecated') or { 'false' }) == 'true'
		disabled: (value.attribute('disabled') or { 'false' }) == 'true'
		loadable: (value.attribute('loadable') or { 'true' }) == 'true'
	}
}

fn tap_info_result_value(result TapInfoResult) ruby.Value {
	return ruby.Value{
		type_name: if result.usage_error != '' { 'UsageError' } else { 'TapInfoResult' }
		repr: result.stdout
		bool_data: result.failed
		attributes: {
			'stdout':      result.stdout
			'stderr':      result.stderr
			'failed':      result.failed.str()
			'usage_error': result.usage_error
		}
	}
}

fn tap_info_context_from_value(value ruby.Value) TapInfoContext {
	json_version := value.attribute('json_version') or { '' }
	console_width := (value.attribute('console_width') or { '80' }).int()
	mut formulae := map[string]TapInfoPackage{}
	for name, item in (value.map_data['formulae'] or { ruby.map_value({}) }).map_data {
		formulae[name] = tap_info_package_from_value(item)
	}
	mut casks := map[string]TapInfoPackage{}
	for name, item in (value.map_data['casks'] or { ruby.map_value({}) }).map_data {
		casks[name] = tap_info_package_from_value(item)
	}
	return TapInfoContext{
		installed: (value.attribute('installed') or { 'false' }) == 'true'
		json_version: if json_version != '' { ?string(json_version) } else { none }
		named_taps: ((value.map_data['named_taps'] or { ruby.array_value([]) }).as_array() or { [] }).map(tap_info_tap_from_value(it))
		installed_taps: ((value.map_data['installed_taps'] or { ruby.array_value([]) }).as_array() or { [] }).map(tap_info_tap_from_value(it))
		installed_formulae: tap_info_string_array(value, 'installed_formulae')
		installed_casks: tap_info_string_array(value, 'installed_casks')
		formulae: formulae
		casks: casks
		require_tap_trust: (value.attribute('require_tap_trust') or { 'false' }) == 'true'
		tap_directory: value.attribute('tap_directory') or { '' }
		tap_directory_present: (value.attribute('tap_directory_present') or { 'false' }) == 'true'
		tty: (value.attribute('tty') or { 'true' }) == 'true'
		console_width: console_width
	}
}
