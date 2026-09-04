module cmd

import ruby

// Translated from Homebrew/brew `cmd/tab.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum TabPackageKind {
	formula
	cask
}

pub struct TabPackageState {
pub:
	kind                  TabPackageKind
	name                  string
	any_version_installed bool
	tab_exists            bool
	installed_on_request  bool
}

pub struct TabUpdateResult {
pub:
	package     TabPackageState
	created_tab bool
	wrote_tab   bool
	message     string
}

pub struct TabCommandResult {
pub mut:
	packages []TabPackageState
	messages []string
}

fn tab_marking_description(installed_on_request bool) string {
	return if installed_on_request { 'installed on request' } else { 'not installed on request' }
}

pub fn update_tab_state(package TabPackageState, installed_on_request bool) !TabUpdateResult {
	created_tab := package.kind == .cask && !package.tab_exists
	if package.kind == .formula && !package.tab_exists {
		return error('Tab file for ${package.name} does not exist.')
	}
	marking := tab_marking_description(installed_on_request)
	if package.installed_on_request == installed_on_request {
		return TabUpdateResult{
			package: TabPackageState{
				...package
				tab_exists: package.tab_exists || created_tab
			}
			created_tab: created_tab
			wrote_tab: created_tab
			message: '${package.name} is already marked as ${marking}.'
		}
	}
	return TabUpdateResult{
		package: TabPackageState{
			...package
			tab_exists: true
			installed_on_request: installed_on_request
		}
		created_tab: created_tab
		wrote_tab: true
		message: '${package.name} is now marked as ${marking}.'
	}
}

fn tab_names_sentence(names []string) string {
	if names.len <= 1 {
		return if names.len == 0 { '' } else { names[0] }
	}
	if names.len == 2 {
		return '${names[0]} and ${names[1]}'
	}
	return '${names[..names.len - 1].join(', ')}, and ${names.last()}'
}

pub fn run_tab_command(packages []TabPackageState, marking ?bool) !TabCommandResult {
	mark_as_requested := marking or { return error('No marking option specified.') }
	not_installed := packages.filter(!it.any_version_installed).map(it.name)
	if not_installed.len > 0 {
		verb := if not_installed.len == 1 { 'is' } else { 'are' }
		return error('${tab_names_sentence(not_installed)} ${verb} not installed.')
	}
	mut result := TabCommandResult{}
	for package in packages {
		updated := update_tab_state(package, mark_as_requested)!
		result.packages << updated.package
		result.messages << updated.message
	}
	return result
}

pub fn tab_package_value(package TabPackageState) ruby.Value {
	return ruby.structured_value(if package.kind == .formula { 'Formula' } else { 'Cask' }, package.name, {
		'kind':                  package.kind.str()
		'name':                  package.name
		'any_version_installed': package.any_version_installed.str()
		'tab_exists':            package.tab_exists.str()
		'installed_on_request':  package.installed_on_request.str()
	})
}

fn tab_package_from_value(value ruby.Value) TabPackageState {
	return TabPackageState{
		kind: if (value.attribute('kind') or { value.type_name.to_lower() }) == 'cask' {
			.cask} else {
			.formula}
		name: value.attribute('name') or { value.as_string() }
		any_version_installed: (value.attribute('any_version_installed') or { 'false' }) == 'true'
		tab_exists: (value.attribute('tab_exists') or { 'false' }) == 'true'
		installed_on_request: (value.attribute('installed_on_request') or { 'false' }) == 'true'
	}
}

fn tab_command_result_value(result TabCommandResult) ruby.Value {
	return ruby.Value{
		type_name: 'TabCommandResult'
		repr: result.messages.join('\n')
		map_data: {
			'packages': ruby.array_value(result.packages.map(tab_package_value(it)))
			'messages': ruby.string_array_value(result.messages)
		}
	}
}

// Ruby method `run` at line 36.
pub fn ruby_tab_l36_d1_run(args ...ruby.Value) ruby.Value {
	package_values := if args.len > 0 {
		args[0].as_array() or { []ruby.Value{} }
	} else {
		[]ruby.Value{}
	}
	marking := if args.len > 1 && args[1].type_name == 'Bool' {
		?bool(args[1].bool_data)
	} else {
		none
	}
	result := run_tab_command(package_values.map(tab_package_from_value(it)), marking) or {
		return ruby.object_value(if err.msg() == 'No marking option specified.' {
			'UsageError'
		} else {
			'RuntimeError'
		}, err.msg())
	}
	return tab_command_result_value(result)
}

// Ruby method `update_tab(formula_or_cask, installed_on_request:)` at line 61.
pub fn ruby_tab_l61_d2_update_tab(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'update_tab requires a package and marking')
	}
	updated := update_tab_state(tab_package_from_value(args[0]), args[1].as_bool() or { false }) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	return ruby.Value{
		type_name: 'TabUpdateResult'
		repr: updated.message
		attributes: {
			'created_tab': updated.created_tab.str()
			'wrote_tab':   updated.wrote_tab.str()
		}
		map_data: {
			'package': tab_package_value(updated.package)
		}
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6: require "tab"
// 7:
// 8: module Homebrew
// 9:   module Cmd
// 10:     class TabCmd < AbstractCommand
// 11:       cmd_args do
// 12:         description <<~EOS
// 13:           Edit tab information for installed formulae or casks.
// 14:
// 15:           This can be useful when you want to control whether an installed
// 16:           formula should be removed by `brew autoremove`.
// 17:           To prevent removal, mark the formula as installed on request;
// 18:           to allow removal, mark the formula as not installed on request.
// 19:         EOS
// 20:         switch "--installed-on-request",
// 21:                description: "Mark <installed_formula> or <installed_cask> as installed on request."
// 22:         switch "--no-installed-on-request",
// 23:                description: "Mark <installed_formula> or <installed_cask> as not installed on request."
// 24:         switch "--formula", "--formulae",
// 25:                description: "Only mark formulae."
// 26:         switch "--cask", "--casks",
// 27:                description: "Only mark casks."
// 28:
// 29:         conflicts "--formula", "--cask"
// 30:         conflicts "--installed-on-request", "--no-installed-on-request"
// 31:
// 32:         named_args [:installed_formula, :installed_cask], min: 1
// 33:       end
// 34:
// 35:       sig { override.void }
// 36:       def run
// 37:         installed_on_request = if args.installed_on_request?
// 38:           true
// 39:         elsif args.no_installed_on_request?
// 40:           false
// 41:         end
// 42:         raise UsageError, "No marking option specified." if installed_on_request.nil?
// 43:
// 44:         formulae, casks = T.cast(args.named.to_formulae_to_casks, [T::Array[Formula], T::Array[Cask::Cask]])
// 45:         packages = formulae + casks
// 46:         not_installed = packages.reject(&:any_version_installed?)
// 47:         if not_installed.any?
// 48:           names = not_installed.map(&:to_s)
// 49:           is_or_are = (names.length == 1) ? "is" : "are"
// 50:           odie "#{names.to_sentence} #{is_or_are} not installed."
// 51:         end
// 52:
// 53:         packages.each do |formula_or_cask|
// 54:           update_tab formula_or_cask, installed_on_request:
// 55:         end
// 56:       end
// 57:
// 58:       private
// 59:
// 60:       sig { params(formula_or_cask: T.any(Formula, Cask::Cask), installed_on_request: T::Boolean).void }
// 61:       def update_tab(formula_or_cask, installed_on_request:)
// 62:         name, tab, created_tab = if formula_or_cask.is_a?(Formula)
// 63:           [formula_or_cask.name, Tab.for_formula(formula_or_cask), false]
// 64:         else
// 65:           cask = formula_or_cask
// 66:           cask_tab = cask.tab
// 67:           cask_tabfile = cask_tab.tabfile
// 68:           if cask_tabfile&.exist?
// 69:             [cask.token, cask_tab, false]
// 70:           else
// 71:             [cask.token, Cask::Tab.create(cask), true]
// 72:           end
// 73:         end
// 74:
// 75:         tabfile = tab.tabfile
// 76:         if !created_tab && !tabfile&.exist?
// 77:           raise ArgumentError,
// 78:                 "Tab file for #{name} does not exist."
// 79:         end
// 80:
// 81:         installed_on_request_str = "#{"not " unless installed_on_request}installed on request"
// 82:         if (tab.installed_on_request && installed_on_request) ||
// 83:            (!tab.installed_on_request && !installed_on_request)
// 84:           tab.write if created_tab
// 85:           ohai "#{name} is already marked as #{installed_on_request_str}."
// 86:           return
// 87:         end
// 88:
// 89:         tab.installed_on_request = installed_on_request
// 90:         tab.write
// 91:         ohai "#{name} is now marked as #{installed_on_request_str}."
// 92:       end
// 93:     end
// 94:   end
// 95: end
