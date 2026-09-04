module update_report

import ruby

// Translated from Homebrew/brew `cmd/update_report/reporter_hub.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct ReporterHub {
pub mut:
	reporters []Reporter
	report    ReporterReport
}

pub struct ReporterHubDumpContext {
pub:
	auto_update               bool
	auto_update_quiet         bool
	no_update_report_new      bool
	no_install_from_api       bool
	any_casks_installed       bool
	running_on_linux          bool
	auto_update_skip_outdated bool
	installed_formulae        []string
	installed_casks           []string
	outdated_formulae         []string
	outdated_casks            []string
	formula_descriptions      map[string]string
	cask_descriptions         map[string]string
}

fn reporter_hub_merge(mut destination []string, source []string) {
	destination << source
}

pub fn (mut hub ReporterHub) add(mut reporter Reporter, auto_update bool) {
	hub.reporters << reporter
	report := reporter.report(auto_update)
	reporter_hub_merge(mut hub.report.added_formulae, report.added_formulae)
	reporter_hub_merge(mut hub.report.added_casks, report.added_casks)
	reporter_hub_merge(mut hub.report.deleted_formulae, report.deleted_formulae)
	reporter_hub_merge(mut hub.report.deleted_casks, report.deleted_casks)
	reporter_hub_merge(mut hub.report.modified_formulae, report.modified_formulae)
	reporter_hub_merge(mut hub.report.modified_casks, report.modified_casks)
	hub.report.renamed_formulae << report.renamed_formulae
	hub.report.renamed_casks << report.renamed_casks
	reporter_hub_merge(mut hub.report.tap_migrations, report.tap_migrations)
}

pub fn (hub ReporterHub) empty() bool {
	return hub.report.added_formulae.len == 0 && hub.report.added_casks.len == 0 && hub.report.deleted_formulae.len == 0 && hub.report.deleted_casks.len == 0 && hub.report.modified_formulae.len == 0 && hub.report.modified_casks.len == 0 && hub.report.renamed_formulae.len == 0 && hub.report.renamed_casks.len == 0 && hub.report.tap_migrations.len == 0
}

pub fn reporter_hub_select(report ReporterReport, key string) ![]string {
	return match key {
		'A' { report.added_formulae.clone() }
		'AC' { report.added_casks.clone() }
		'D' { report.deleted_formulae.clone() }
		'DC' { report.deleted_casks.clone() }
		'M' { report.modified_formulae.clone() }
		'MC' { report.modified_casks.clone() }
		'T' { report.tap_migrations.clone() }
		'R', 'RC' {
			return error('key ${key} contains rename pairs')
		}
		else {
			return error('Unsupported key ${key}')
		}
	}
}

pub fn reporter_hub_select_renames(report ReporterReport, key string) ![]ReporterRename {
	return match key {
		'R' { report.renamed_formulae.clone() }
		'RC' { report.renamed_casks.clone() }
		else {
			return error('Unsupported rename key ${key}')
		}
	}
}

pub fn reporter_hub_installed(formula string, installed_formulae []string) bool {
	return reporter_name_from_full_name(formula) in installed_formulae
}

pub fn reporter_hub_cask_installed(cask string, installed_casks []string) bool {
	return reporter_name_from_full_name(cask) in installed_casks
}

pub fn reporter_hub_description(formula string, context ReporterHubDumpContext) ?string {
	if context.no_install_from_api && formula.contains('/') {
		return none
	}
	description := context.formula_descriptions[formula] or {
		context.formula_descriptions[reporter_name_from_full_name(formula)] or { return none }
	}
	return if description.trim_space() == '' { none } else { description }
}

pub fn reporter_hub_cask_description(cask string, context ReporterHubDumpContext) ?string {
	if context.no_install_from_api && cask.contains('/') {
		return none
	}
	description := context.cask_descriptions[cask] or { return none }
	return if description.trim_space() == '' { none } else { description }
}

pub fn reporter_hub_output_report(title string, entries []string) string {
	if entries.len == 0 {
		return ''
	}
	mut sorted := entries.clone()
	sorted.sort()
	return '==> ${title}\n${sorted.join('\n')}\n'
}

pub fn reporter_hub_dump_new_formula_report(report ReporterReport,
	context ReporterHubDumpContext) string {
	mut formulae := report.added_formulae.filter(!reporter_hub_installed(it, context.installed_formulae))
	formulae.sort()
	if formulae.len == 0 {
		return ''
	}
	display_descriptions := !context.no_install_from_api || formulae.len <= 100
	mut lines := ['==> New Formulae']
	for formula in formulae {
		if display_descriptions {
			if description := reporter_hub_description(formula, context) {
				lines << '${formula}: ${description}'
				continue
			}
		}
		lines << formula
	}
	return lines.join('\n') + '\n'
}

pub fn reporter_hub_dump_new_cask_report(report ReporterReport,
	context ReporterHubDumpContext) string {
	if !context.any_casks_installed {
		return ''
	}
	mut casks := report.added_casks.filter(!reporter_hub_cask_installed(it, context.installed_casks))
	casks.sort()
	if casks.len == 0 {
		return ''
	}
	display_descriptions := !context.no_install_from_api || casks.len <= 100
	mut lines := ['==> New Casks']
	for cask in casks {
		token := reporter_name_from_full_name(cask)
		if display_descriptions {
			if description := reporter_hub_cask_description(cask, context) {
				lines << '${token}: ${description}'
				continue
			}
		}
		lines << token
	}
	return lines.join('\n') + '\n'
}

pub fn reporter_hub_dump_deleted_formula_report(report ReporterReport,
	context ReporterHubDumpContext) string {
	formulae := report.deleted_formulae.filter(reporter_hub_installed(it, context.installed_formulae))
	return reporter_hub_output_report('Deleted Installed Formulae', formulae)
}

pub fn reporter_hub_dump_deleted_cask_report(report ReporterReport,
	context ReporterHubDumpContext) string {
	if context.running_on_linux {
		return ''
	}
	casks := report.deleted_casks.filter(reporter_hub_cask_installed(it, context.installed_casks)).map(reporter_name_from_full_name(it))
	return reporter_hub_output_report('Deleted Installed Casks', casks)
}

fn reporter_hub_plural(noun string, count int) string {
	return if count == 1 {
		noun
	} else if noun == 'formula' { 'formulae' } else { '${noun}s' }
}

pub fn (hub ReporterHub) dump(context ReporterHubDumpContext) string {
	if context.auto_update && context.auto_update_quiet {
		return ''
	}
	mut output := ''
	if !context.no_update_report_new {
		output += reporter_hub_dump_new_formula_report(hub.report, context)
		output += reporter_hub_dump_new_cask_report(hub.report, context)
	}
	output += reporter_hub_dump_deleted_formula_report(hub.report, context)
	output += reporter_hub_dump_deleted_cask_report(hub.report, context)
	if !context.auto_update {
		output += reporter_hub_output_report('Outdated Formulae', context.outdated_formulae)
		output += reporter_hub_output_report('Outdated Casks', context.outdated_casks)
	}
	formula_count := context.outdated_formulae.len
	cask_count := context.outdated_casks.len
	if formula_count + cask_count == 0 {
		return output
	}
	mut message := ''
	if formula_count > 0 {
		message = '${formula_count} outdated ${reporter_hub_plural('formula', formula_count)}'
	}
	if cask_count > 0 {
		if message != '' {
			message += ' and '
		}
		message += '${cask_count} outdated ${reporter_hub_plural('cask', cask_count)}'
	}
	if context.auto_update && context.auto_update_skip_outdated {
		return output
	}
	output += '\nYou have ${message} installed.\n'
	if context.auto_update {
		return output
	}
	pronoun := if formula_count + cask_count == 1 { 'it' } else { 'them' }
	return output + 'You can upgrade ${pronoun} with brew upgrade\nor list ${pronoun} with brew outdated.\n'
}

fn reporter_hub_value(hub ReporterHub) ruby.Value {
	return ruby.Value{
		type_name: 'ReporterHub'
		repr: '${hub.reporters.len} reporter(s)'
		attributes: {
			'reporter_count': hub.reporters.len.str()
			'empty':          hub.empty().str()
		}
		map_data: {
			'reporters': ruby.array_value(hub.reporters.map(reporter_to_value(it)))
			'report':    reporter_report_to_value(hub.report)
		}
	}
}

fn reporter_hub_from_value(value ruby.Value) ReporterHub {
	mut reporters := []Reporter{}
	if reporter_values := value.map_data['reporters'] {
		for reporter_value in reporter_values.array_data {
			reporters << reporter_from_value(reporter_value)
		}
	}
	return ReporterHub{
		reporters: reporters
		report: if report_value := value.map_data['report'] {
			reporter_report_from_value(report_value)} else {
			ReporterReport{}}
	}
}

fn reporter_hub_context_from_value(value ruby.Value) ReporterHubDumpContext {
	return ReporterHubDumpContext{
		auto_update: (value.attributes['auto_update'] or { 'false' }) == 'true'
		auto_update_quiet: (value.attributes['auto_update_quiet'] or { 'false' }) == 'true'
		no_update_report_new: (value.attributes['no_update_report_new'] or { 'false' }) == 'true'
		no_install_from_api: (value.attributes['no_install_from_api'] or { 'false' }) == 'true'
		any_casks_installed: (value.attributes['any_casks_installed'] or { 'false' }) == 'true'
		running_on_linux: (value.attributes['running_on_linux'] or { 'false' }) == 'true'
		auto_update_skip_outdated: (value.attributes['auto_update_skip_outdated'] or { 'false' }) == 'true'
		installed_formulae: (value.map_data['installed_formulae'] or { ruby.string_array_value([]) }).string_array_data
		installed_casks: (value.map_data['installed_casks'] or { ruby.string_array_value([]) }).string_array_data
		outdated_formulae: (value.map_data['outdated_formulae'] or { ruby.string_array_value([]) }).string_array_data
		outdated_casks: (value.map_data['outdated_casks'] or { ruby.string_array_value([]) }).string_array_data
		formula_descriptions: value.attributes.clone()
		cask_descriptions: value.attributes.clone()
	}
}

// Ruby attr_reader `attr_reader :reporters` at line 8.
pub fn ruby_reporter_hub_l8_d1_reporters(args ...ruby.Value) ruby.Value {
	hub := if args.len > 0 { reporter_hub_from_value(args[0]) } else { ReporterHub{} }
	return ruby.array_value(hub.reporters.map(reporter_to_value(it)))
}

// Ruby method `initialize` at line 11.
pub fn ruby_reporter_hub_l11_d2_initialize(args ...ruby.Value) ruby.Value {
	return reporter_hub_value(ReporterHub{})
}

// Ruby method `select_formula_or_cask(key)` at line 17.
pub fn ruby_reporter_hub_l17_d3_select_formula_or_cask(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'hub and key are required')
	}
	key := args[1].as_string()
	hub := reporter_hub_from_value(args[0])
	if key in ['R', 'RC'] {
		renames := reporter_hub_select_renames(hub.report, key) or {
			return ruby.object_value('RuntimeError', err.msg())
		}
		return ruby.array_value(renames.map(ruby.structured_value('Rename', '${it.old_name} -> ${it.new_name}', {
			'old_name': it.old_name
			'new_name': it.new_name
		})))
	}
	selected := reporter_hub_select(hub.report, key) or {
		return ruby.object_value('RuntimeError', err.msg())
	}
	return ruby.string_array_value(selected)
}

// Ruby method `renamed_formulae` at line 24.
pub fn ruby_reporter_hub_l24_d4_renamed_formulae(args ...ruby.Value) ruby.Value {
	hub := if args.len > 0 { reporter_hub_from_value(args[0]) } else { ReporterHub{} }
	return ruby.array_value(hub.report.renamed_formulae.map(ruby.structured_value('Rename', '${it.old_name} -> ${it.new_name}', {
		'old_name': it.old_name
		'new_name': it.new_name
	})))
}

// Ruby method `add(reporter, auto_update: false)` at line 29.
pub fn ruby_reporter_hub_l29_d5_add(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return reporter_hub_value(ReporterHub{})
	}
	mut hub := if args.len > 1 { reporter_hub_from_value(args[0]) } else { ReporterHub{} }
	mut reporter := reporter_from_value(args[args.len - 1])
	hub.add(mut reporter, args.len > 2 && args[2].bool_data)
	return reporter_hub_value(hub)
}

// Ruby method `empty?` at line 36.
pub fn ruby_reporter_hub_l36_d6_empty(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len == 0 || reporter_hub_from_value(args[0]).empty())
}

// Ruby method `dump(auto_update: false)` at line 41.
pub fn ruby_reporter_hub_l41_d7_dump(args ...ruby.Value) ruby.Value {
	hub := if args.len > 0 { reporter_hub_from_value(args[0]) } else { ReporterHub{} }
	context := if args.len > 1 {
		reporter_hub_context_from_value(args[1])
	} else {
		ReporterHubDumpContext{}
	}
	return ruby.string_value(hub.dump(context))
}

// Ruby method `dump_new_formula_report` at line 103.
pub fn ruby_reporter_hub_l103_d8_dump_new_formula_report(args ...ruby.Value) ruby.Value {
	hub := if args.len > 0 { reporter_hub_from_value(args[0]) } else { ReporterHub{} }
	context := if args.len > 1 {
		reporter_hub_context_from_value(args[1])
	} else {
		ReporterHubDumpContext{}
	}
	return ruby.string_value(reporter_hub_dump_new_formula_report(hub.report, context))
}

// Ruby method `dump_new_cask_report` at line 123.
pub fn ruby_reporter_hub_l123_d9_dump_new_cask_report(args ...ruby.Value) ruby.Value {
	hub := if args.len > 0 { reporter_hub_from_value(args[0]) } else { ReporterHub{} }
	context := if args.len > 1 {
		reporter_hub_context_from_value(args[1])
	} else {
		ReporterHubDumpContext{}
	}
	return ruby.string_value(reporter_hub_dump_new_cask_report(hub.report, context))
}

// Ruby method `dump_deleted_formula_report` at line 146.
pub fn ruby_reporter_hub_l146_d10_dump_deleted_formula_report(args ...ruby.Value) ruby.Value {
	hub := if args.len > 0 { reporter_hub_from_value(args[0]) } else { ReporterHub{} }
	context := if args.len > 1 {
		reporter_hub_context_from_value(args[1])
	} else {
		ReporterHubDumpContext{}
	}
	return ruby.string_value(reporter_hub_dump_deleted_formula_report(hub.report, context))
}

// Ruby method `dump_deleted_cask_report` at line 155.
pub fn ruby_reporter_hub_l155_d11_dump_deleted_cask_report(args ...ruby.Value) ruby.Value {
	hub := if args.len > 0 { reporter_hub_from_value(args[0]) } else { ReporterHub{} }
	context := if args.len > 1 {
		reporter_hub_context_from_value(args[1])
	} else {
		ReporterHubDumpContext{}
	}
	return ruby.string_value(reporter_hub_dump_deleted_cask_report(hub.report, context))
}

// Ruby method `output_dump_formula_or_cask_report(title, formulae_or_casks)` at line 167.
pub fn ruby_reporter_hub_l167_d12_output_dump_formula_or_cask_report(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.string_value('')
	}
	return ruby.string_value(reporter_hub_output_report(args[0].as_string(), args[1].string_array_data))
}

// Ruby method `installed?(formula)` at line 174.
pub fn ruby_reporter_hub_l174_d13_installed(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 1 && reporter_hub_installed(args[0].as_string(), args[1].string_array_data))
}

// Ruby method `cask_installed?(cask)` at line 179.
pub fn ruby_reporter_hub_l179_d14_cask_installed(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 1 && reporter_hub_cask_installed(args[0].as_string(), args[1].string_array_data))
}

// Ruby method `description(formula)` at line 184.
pub fn ruby_reporter_hub_l184_d15_description(args ...ruby.Value) ruby.Value {
	if args.len > 1 {
		if description := args[1].attributes[args[0].as_string()] {
			return ruby.string_value(description)
		}
	}
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `cask_description(cask)` at line 200.
pub fn ruby_reporter_hub_l200_d16_cask_description(args ...ruby.Value) ruby.Value {
	if args.len > 1 {
		if description := args[1].attributes[args[0].as_string()] {
			return ruby.string_value(description)
		}
	}
	return ruby.object_value('NilClass', 'nil')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: class ReporterHub
// 5:   include Utils::Output::Mixin
// 6:
// 7:   sig { returns(T::Array[Reporter]) }
// 8:   attr_reader :reporters
// 9:
// 10:   sig { void }
// 11:   def initialize
// 12:     @hash = T.let({}, T::Hash[Symbol, T.any(T::Array[String], T::Array[[String, String]])])
// 13:     @reporters = T.let([], T::Array[Reporter])
// 14:   end
// 15:
// 16:   sig { params(key: Symbol).returns(T.any(T::Array[String], T::Array[[String, String]])) }
// 17:   def select_formula_or_cask(key)
// 18:     raise "Unsupported key #{key}" unless [:A, :AC, :D, :DC, :M, :MC, :R, :RC, :T].include?(key)
// 19:
// 20:     @hash.fetch(key, [])
// 21:   end
// 22:
// 23:   sig { returns(T::Array[[String, String]]) }
// 24:   def renamed_formulae
// 25:     T.cast(@hash.fetch(:R, []), T::Array[[String, String]])
// 26:   end
// 27:
// 28:   sig { params(reporter: Reporter, auto_update: T::Boolean).void }
// 29:   def add(reporter, auto_update: false)
// 30:     @reporters << reporter
// 31:     report = reporter.report(auto_update:).reject { |_k, v| v.empty? }
// 32:     @hash.update(report) { |_key, oldval, newval| oldval + newval }
// 33:   end
// 34:
// 35:   sig { returns(T::Boolean) }
// 36:   def empty?
// 37:     @hash.empty?
// 38:   end
// 39:
// 40:   sig { params(auto_update: T::Boolean).void }
// 41:   def dump(auto_update: false)
// 42:     return if auto_update && Homebrew::EnvConfig.auto_update_quiet?
// 43:
// 44:     unless Homebrew::EnvConfig.no_update_report_new?
// 45:       dump_new_formula_report
// 46:       dump_new_cask_report
// 47:     end
// 48:
// 49:     dump_deleted_formula_report
// 50:     dump_deleted_cask_report
// 51:
// 52:     outdated_formulae = Formula.installed.select(&:outdated?).map(&:name)
// 53:     outdated_casks = Cask::Caskroom.casks.select(&:outdated?).map(&:token)
// 54:     unless auto_update
// 55:       output_dump_formula_or_cask_report "Outdated Formulae", outdated_formulae
// 56:       output_dump_formula_or_cask_report "Outdated Casks", outdated_casks
// 57:     end
// 58:     return if outdated_formulae.blank? && outdated_casks.blank?
// 59:
// 60:     outdated_formulae = outdated_formulae.count
// 61:     outdated_casks = outdated_casks.count
// 62:
// 63:     update_pronoun = if (outdated_formulae + outdated_casks) == 1
// 64:       "it"
// 65:     else
// 66:       "them"
// 67:     end
// 68:
// 69:     msg = ""
// 70:
// 71:     if outdated_formulae.positive?
// 72:       noun = Utils.pluralize("formula", outdated_formulae)
// 73:       msg += "#{Tty.bold}#{outdated_formulae}#{Tty.reset} outdated #{noun}"
// 74:     end
// 75:
// 76:     if outdated_casks.positive?
// 77:       msg += " and " if msg.present?
// 78:       msg += "#{Tty.bold}#{outdated_casks}#{Tty.reset} outdated #{Utils.pluralize("cask", outdated_casks)}"
// 79:     end
// 80:
// 81:     return if msg.blank?
// 82:
// 83:     # When auto-updating before a zero-argument `brew upgrade` or `brew outdated`,
// 84:     # that command lists the outdated packages itself so don't duplicate it here.
// 85:     # Two-way sync: `auto-update` in `Library/Homebrew/brew.sh`.
// 86:     return if auto_update && ENV["HOMEBREW_AUTO_UPDATE_SKIP_OUTDATED"].present?
// 87:
// 88:     puts
// 89:     puts "You have #{msg} installed."
// 90:     # If we're auto-updating, don't need to suggest commands that we're perhaps
// 91:     # already running.
// 92:     return if auto_update
// 93:
// 94:     puts <<~EOS
// 95:       You can upgrade #{update_pronoun} with #{Tty.bold}brew upgrade#{Tty.reset}
// 96:       or list #{update_pronoun} with #{Tty.bold}brew outdated#{Tty.reset}.
// 97:     EOS
// 98:   end
// 99:
// 100:   private
// 101:
// 102:   sig { void }
// 103:   def dump_new_formula_report
// 104:     formulae = T.cast(select_formula_or_cask(:A), T::Array[String]).sort.reject { |name| installed?(name) }
// 105:     return if formulae.blank?
// 106:
// 107:     ohai "New Formulae"
// 108:     should_display_descriptions = if Homebrew::EnvConfig.no_install_from_api?
// 109:       formulae.size <= 100
// 110:     else
// 111:       true
// 112:     end
// 113:     formulae.each do |formula|
// 114:       if should_display_descriptions && (desc = description(formula))
// 115:         puts "#{formula}: #{desc}"
// 116:       else
// 117:         puts formula
// 118:       end
// 119:     end
// 120:   end
// 121:
// 122:   sig { void }
// 123:   def dump_new_cask_report
// 124:     return unless Cask::Caskroom.any_casks_installed?
// 125:
// 126:     casks = T.cast(select_formula_or_cask(:AC), T::Array[String]).sort.reject { |name| cask_installed?(name) }
// 127:     return if casks.blank?
// 128:
// 129:     ohai "New Casks"
// 130:     should_display_descriptions = if Homebrew::EnvConfig.no_install_from_api?
// 131:       casks.size <= 100
// 132:     else
// 133:       true
// 134:     end
// 135:     casks.each do |cask|
// 136:       cask_token = Utils.name_from_full_name(cask)
// 137:       if should_display_descriptions && (desc = cask_description(cask))
// 138:         puts "#{cask_token}: #{desc}"
// 139:       else
// 140:         puts cask_token
// 141:       end
// 142:     end
// 143:   end
// 144:
// 145:   sig { void }
// 146:   def dump_deleted_formula_report
// 147:     formulae = T.cast(select_formula_or_cask(:D), T::Array[String]).sort.filter_map do |name|
// 148:       pretty_uninstalled(name) if installed?(name)
// 149:     end
// 150:
// 151:     output_dump_formula_or_cask_report "Deleted Installed Formulae", formulae
// 152:   end
// 153:
// 154:   sig { void }
// 155:   def dump_deleted_cask_report
// 156:     return if Homebrew::SimulateSystem.simulating_or_running_on_linux?
// 157:
// 158:     casks = T.cast(select_formula_or_cask(:DC), T::Array[String]).sort.filter_map do |name|
// 159:       name = Utils.name_from_full_name(name)
// 160:       pretty_uninstalled(name) if cask_installed?(name)
// 161:     end
// 162:
// 163:     output_dump_formula_or_cask_report "Deleted Installed Casks", casks
// 164:   end
// 165:
// 166:   sig { params(title: String, formulae_or_casks: T::Array[String]).void }
// 167:   def output_dump_formula_or_cask_report(title, formulae_or_casks)
// 168:     return if formulae_or_casks.blank?
// 169:
// 170:     ohai title, Formatter.columns(formulae_or_casks.sort)
// 171:   end
// 172:
// 173:   sig { params(formula: String).returns(T::Boolean) }
// 174:   def installed?(formula)
// 175:     (HOMEBREW_CELLAR/Utils.name_from_full_name(formula)).directory?
// 176:   end
// 177:
// 178:   sig { params(cask: String).returns(T::Boolean) }
// 179:   def cask_installed?(cask)
// 180:     (Cask::Caskroom.path/cask).directory?
// 181:   end
// 182:
// 183:   sig { params(formula: String).returns(T.nilable(String)) }
// 184:   def description(formula)
// 185:     if Homebrew::EnvConfig.no_install_from_api?
// 186:       # Skip non-homebrew/core formulae for security.
// 187:       return if formula.include?("/")
// 188:
// 189:       begin
// 190:         Formula[formula].desc&.presence
// 191:       rescue FormulaUnavailableError
// 192:         nil
// 193:       end
// 194:     else
// 195:       Homebrew::API::Internal.formula_hash(formula)&.fetch("desc", nil)&.presence
// 196:     end
// 197:   end
// 198:
// 199:   sig { params(cask: String).returns(T.nilable(String)) }
// 200:   def cask_description(cask)
// 201:     if Homebrew::EnvConfig.no_install_from_api?
// 202:       # Skip non-homebrew/cask formulae for security.
// 203:       return if cask.include?("/")
// 204:
// 205:       begin
// 206:         Cask::CaskLoader.load(cask).desc&.presence
// 207:       rescue Cask::CaskError
// 208:         nil
// 209:       end
// 210:     else
// 211:       Homebrew::API::Internal.cask_hash(cask)&.fetch("desc", nil)&.presence
// 212:     end
// 213:   end
// 214: end
