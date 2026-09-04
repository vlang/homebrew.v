module cmd

import ruby
import homebrew.utils
import os

// Translated from Homebrew/brew `cmd/tap-info.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `run` at line 25.
pub fn ruby_tap_info_l25_d1_run(args ...ruby.Value) ruby.Value {
	context := if args.len > 0 { tap_info_context_from_value(args[0]) } else { TapInfoContext{} }
	return tap_info_result_value(tap_info_run(context))
}

// Ruby method `print_tap_info(taps)` at line 44.
pub fn ruby_tap_info_l44_d2_print_tap_info(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'print_tap_info requires taps')
	}
	taps := (args[0].as_array() or { [] }).map(tap_info_tap_from_value(it))
	context := if args.len > 1 { tap_info_context_from_value(args[1]) } else { TapInfoContext{} }
	return tap_info_result_value(tap_info_print_info(taps, context))
}

// Ruby method `print_tap_listings(tap)` at line 97.
pub fn ruby_tap_info_l97_d3_print_tap_listings(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'print_tap_listings requires a tap')
	}
	tap := tap_info_tap_from_value(args[0])
	context := if args.len > 1 { tap_info_context_from_value(args[1]) } else { TapInfoContext{} }
	return tap_info_result_value(tap_info_print_tap_listings(tap, context.installed_formulae, context.installed_casks, context.formulae, context.casks, context.tty, context.console_width))
}

// Ruby method `decorate_formula(tap, name, installed:)` at line 123.
pub fn ruby_tap_info_l123_d4_decorate_formula(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'decorate_formula requires tap and name')
	}
	installed := if args.len > 2 { args[2].as_bool() or { false } } else { false }
	mut formulae := map[string]TapInfoPackage{}
	if args.len > 3 {
		formulae[args[1].as_string()] = tap_info_package_from_value(args[3])
	}
	return ruby.string_value(tap_info_decorate_formula(tap_info_tap_from_value(args[0]), args[1].as_string(), installed, formulae, true))
}

// Ruby method `decorate_cask(tap, token, installed:)` at line 138.
pub fn ruby_tap_info_l138_d5_decorate_cask(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'decorate_cask requires tap and token')
	}
	installed := if args.len > 2 { args[2].as_bool() or { false } } else { false }
	mut casks := map[string]TapInfoPackage{}
	if args.len > 3 {
		casks[args[1].as_string()] = tap_info_package_from_value(args[3])
	}
	return ruby.string_value(tap_info_decorate_cask(tap_info_tap_from_value(args[0]), args[1].as_string(), installed, casks, true))
}

// Ruby method `print_tap_json(taps)` at line 153.
pub fn ruby_tap_info_l153_d6_print_tap_json(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_value(tap_info_print_json([]))
	}
	return ruby.string_value(tap_info_print_json((args[0].as_array() or { [] }).map(tap_info_tap_from_value(it))))
}

// Ruby method `print_section(tap, label, all, installed, min_width:, &block)` at line 175.
pub fn ruby_tap_info_l175_d7_print_section(args ...ruby.Value) ruby.Value {
	if args.len < 4 {
		return ruby.object_value('ArgumentError', 'print_section requires tap, label, all and installed')
	}
	all := (args[2].as_array() or { [] }).map(it.as_string())
	installed := (args[3].as_array() or { [] }).map(it.as_string())
	mut decorated := map[string]string{}
	for name in all {
		decorated[name] = name
	}
	min_width := if args.len > 4 { int(args[4].as_int() or { 0 }) } else { 0 }
	return tap_info_result_value(tap_info_print_section(tap_info_tap_from_value(args[0]), args[1].as_string(), all, installed, decorated, min_width, true, 80))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5:
// 6: module Homebrew
// 7:   module Cmd
// 8:     class TapInfo < AbstractCommand
// 9:       cmd_args do
// 10:         description <<~EOS
// 11:           Show detailed information about one or more <tap>s.
// 12:           If no <tap> names are provided, display brief statistics for all installed taps.
// 13:         EOS
// 14:         switch "--installed",
// 15:                description: "Show information on each installed tap."
// 16:         flag   "--json",
// 17:                description: "Print a JSON representation of <tap>. Currently the default and only accepted " \
// 18:                             "value for <version> is `v1`. See the docs for examples of using the JSON " \
// 19:                             "output: <https://docs.brew.sh/Querying-Brew>"
// 20:
// 21:         named_args :tap
// 22:       end
// 23:
// 24:       sig { override.void }
// 25:       def run
// 26:         require "tap"
// 27:
// 28:         taps = if args.installed?
// 29:           Tap
// 30:         else
// 31:           args.named.to_taps
// 32:         end
// 33:
// 34:         if args.json
// 35:           raise UsageError, "invalid JSON version: #{args.json}" unless ["v1", true].include? args.json
// 36:
// 37:           print_tap_json(taps.sort_by(&:to_s))
// 38:         else
// 39:           print_tap_info(taps.sort_by(&:to_s))
// 40:         end
// 41:       end
// 42:
// 43:       sig { params(taps: T::Array[Tap]).void }
// 44:       def print_tap_info(taps)
// 45:         if taps.none?
// 46:           # Tap#private? queries the GitHub API for each non-core tap.
// 47:           tap_stats = Utils.parallel_map(Tap.installed) do |tap|
// 48:             [tap.formula_files.size, tap.command_files.size, tap.private?]
// 49:           end
// 50:           tap_count = tap_stats.count
// 51:           formula_count = tap_stats.sum(&:first)
// 52:           command_count = tap_stats.sum { |_, command_files_count, _| command_files_count }
// 53:           private_count = tap_stats.count { |_, _, private_tap| private_tap }
// 54:           info = Utils.pluralize("tap", tap_count, include_count: true)
// 55:           info += ", #{private_count} private"
// 56:           info += ", #{Utils.pluralize("formula", formula_count, include_count: true)}"
// 57:           info += ", #{Utils.pluralize("command", command_count, include_count: true)}"
// 58:           info += ", #{HOMEBREW_TAP_DIRECTORY.dup.abv}" if HOMEBREW_TAP_DIRECTORY.directory?
// 59:           puts info
// 60:         else
// 61:           info = ""
// 62:           default_branches = %w[main master].freeze
// 63:
// 64:           taps.each_with_index do |tap, i|
// 65:             puts unless i.zero?
// 66:             info = "#{tap}: "
// 67:             if tap.installed?
// 68:               info += "Installed"
// 69:               if Homebrew::EnvConfig.require_tap_trust?
// 70:                 require "trust"
// 71:                 info += "\n#{Homebrew::Trust.trusted_tap?(tap) ? "Trusted" : "Untrusted"}"
// 72:               end
// 73:               info += if (contents = tap.contents).blank?
// 74:                 "\nNo commands/casks/formulae"
// 75:               else
// 76:                 "\n#{contents.join(", ")}"
// 77:               end
// 78:               info += "\nPrivate" if tap.private?
// 79:               info += "\n#{tap.path} (#{tap.path.abv})"
// 80:               info += "\nFrom: #{tap.remote.presence || "N/A"}"
// 81:               info += "\norigin: #{tap.remote}" if tap.remote != tap.default_remote
// 82:               info += "\nHEAD: #{tap.git_head || "(none)"}"
// 83:               info += "\nlast commit: #{tap.git_last_commit || "never"}"
// 84:               info += "\nbranch: #{tap.git_branch || "(none)"}" if default_branches.exclude?(tap.git_branch)
// 85:               puts info
// 86:               print_tap_listings(tap)
// 87:             else
// 88:               info += "Not installed"
// 89:               Homebrew.failed = true
// 90:               puts info
// 91:             end
// 92:           end
// 93:         end
// 94:       end
// 95:
// 96:       sig { params(tap: Tap).void }
// 97:       def print_tap_listings(tap)
// 98:         commands = tap.command_files
// 99:                       .map { |path| path.basename(path.extname).to_s.delete_prefix("brew-") }
// 100:                       .sort
// 101:         installed_formula_names = Formula.installed_formula_names.to_set
// 102:         installed_cask_tokens = Cask::Caskroom.tokens.to_set
// 103:         formula_names = tap.formula_names.map { |name| Utils.name_from_full_name(name) }.sort
// 104:         cask_tokens = tap.cask_tokens.map { |token| Utils.name_from_full_name(token) }.sort
// 105:         installed_formulae = formula_names.select { |name| installed_formula_names.include?(name) }
// 106:         installed_casks = cask_tokens.select { |token| installed_cask_tokens.include?(token) }
// 107:
// 108:         if commands.any?
// 109:           ohai "Commands"
// 110:           puts commands.join(", ")
// 111:         end
// 112:
// 113:         min_width = (formula_names + cask_tokens).map { |n| Tty.strip_ansi(pretty_uninstalled(n)).length }.max || 0
// 114:         print_section(tap, "Formulae", formula_names, installed_formulae, min_width:) do |name|
// 115:           decorate_formula(tap, name, installed: installed_formula_names.include?(name))
// 116:         end
// 117:         print_section(tap, "Casks", cask_tokens, installed_casks, min_width:) do |token|
// 118:           decorate_cask(tap, token, installed: installed_cask_tokens.include?(token))
// 119:         end
// 120:       end
// 121:
// 122:       sig { params(tap: Tap, name: String, installed: T::Boolean).returns(String) }
// 123:       def decorate_formula(tap, name, installed:)
// 124:         formula = Formulary.factory("#{tap.name}/#{name}")
// 125:         pretty_install_status(
// 126:           name,
// 127:           installed:,
// 128:           outdated:         installed && formula.outdated?,
// 129:           deprecated:       formula.deprecated?,
// 130:           disabled:         formula.disabled?,
// 131:           mark_uninstalled: false,
// 132:         )
// 133:       rescue
// 134:         pretty_install_status(name, installed:, mark_uninstalled: false)
// 135:       end
// 136:
// 137:       sig { params(tap: Tap, token: String, installed: T::Boolean).returns(String) }
// 138:       def decorate_cask(tap, token, installed:)
// 139:         cask = Cask::CaskLoader.load("#{tap.name}/#{token}")
// 140:         pretty_install_status(
// 141:           token,
// 142:           installed:,
// 143:           outdated:         installed && cask.outdated?,
// 144:           deprecated:       cask.deprecated?,
// 145:           disabled:         cask.disabled?,
// 146:           mark_uninstalled: false,
// 147:         )
// 148:       rescue
// 149:         pretty_install_status(token, installed:, mark_uninstalled: false)
// 150:       end
// 151:
// 152:       sig { params(taps: T::Array[Tap]).void }
// 153:       def print_tap_json(taps)
// 154:         # Tap#to_hash shells out to Git and queries the GitHub API.
// 155:         hashes = Utils.parallel_map(taps, &:to_hash)
// 156:
// 157:         puts JSON.pretty_generate(hashes)
// 158:       end
// 159:
// 160:       private
// 161:
// 162:       LISTING_LIMIT = 30
// 163:       private_constant :LISTING_LIMIT
// 164:
// 165:       sig {
// 166:         params(
// 167:           tap:       Tap,
// 168:           label:     String,
// 169:           all:       T::Array[String],
// 170:           installed: T::Array[String],
// 171:           min_width: Integer,
// 172:           block:     T.proc.params(name: String).returns(String),
// 173:         ).void
// 174:       }
// 175:       def print_section(tap, label, all, installed, min_width:, &block)
// 176:         return if all.none?
// 177:
// 178:         if all.size <= LISTING_LIMIT
// 179:           ohai label, Formatter.columns(all.map(&block), min_width:)
// 180:         elsif installed.any?
// 181:           ohai label
// 182:           opoo "Tap has more than #{LISTING_LIMIT} #{label.downcase}; showing only installed entries."
// 183:           puts Formatter.columns(installed.map(&block), min_width:)
// 184:         else
// 185:           ohai label
// 186:           opoo "Tap has more than #{LISTING_LIMIT} #{label.downcase} and none are installed."
// 187:           puts "See: #{tap.remote}" if tap.remote.present?
// 188:         end
// 189:       end
// 190:     end
// 191:   end
// 192: end
