module cmd

import ruby

// Translated from Homebrew/brew `cmd/tab.rb`.
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
			.cask
		} else {
			.formula
		}
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
