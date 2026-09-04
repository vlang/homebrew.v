module homebrew

import ruby
import os

// Translated from Homebrew/brew `bundle.rb`.

pub struct BundleRuntimeConfig {
pub:
	prefix              string
	library             string
	brew_file           string
	npm_executable      string
	path                string
	no_install_from_api bool
	uid                 int
	euid                int
	user_home           string
}

pub struct BundleTabState {
pub:
	exists               bool
	installed_on_request bool
	writable             bool = true
}

pub struct BundleEntry {
pub:
	entry_type string
	name       string
}

@[heap]
pub struct BundleRuntime {
pub:
	config BundleRuntimeConfig
pub mut:
	upgrade_formulae        []string
	upgrade_formulae_loaded bool
	formula_versions        map[string]string
	formula_versions_loaded bool
	cask_installed          bool
	cask_installed_loaded   bool
	installed_formulae      []string
	tabs                    map[string]BundleTabState
	commands                [][]string
	command_environments    []map[string]string
	output                  []string
	brew_tab_updates        []string
	uid_exchange_count      int
	pkgconf_prepend_count   int
}

pub fn new_bundle_runtime(config BundleRuntimeConfig) &BundleRuntime {
	return &BundleRuntime{
		config: config
	}
}

pub fn (mut runtime BundleRuntime) set_upgrade_formulae(value ?string) {
	raw := value or { '' }
	runtime.upgrade_formulae = if raw == '' { [] } else { raw.split(',') }
	runtime.upgrade_formulae_loaded = true
}

pub fn (runtime &BundleRuntime) get_upgrade_formulae() []string {
	return if runtime.upgrade_formulae_loaded { runtime.upgrade_formulae.clone() } else { [] }
}

pub fn (mut runtime BundleRuntime) run_system(command string, arguments []string,
	verbose bool) bool {
	mut environment := map[string]string{}
	if runtime.config.npm_executable != '' && command == runtime.config.npm_executable {
		path := if runtime.config.path != '' { runtime.config.path } else { os.getenv('PATH') }
		node_bin := os.join_path(runtime.config.prefix, 'opt', 'node', 'bin')
		environment['PATH'] = '${path}:${node_bin}'
	}
	mut command_line := [command]
	command_line << arguments
	runtime.commands << command_line
	runtime.command_environments << environment.clone()
	result := if environment.len > 0 {
		ruby.run_command_with_environment(command, arguments, environment)
	} else {
		ruby.run_command(command, arguments)
	}
	if result.exit_code != 0 || verbose {
		runtime.output << result.output
	}
	return result.exit_code == 0
}

pub fn (mut runtime BundleRuntime) run_brew(arguments []string, verbose bool) bool {
	return runtime.run_system(runtime.config.brew_file, arguments, verbose)
}

pub fn (mut runtime BundleRuntime) is_cask_installed() bool {
	if !runtime.cask_installed_loaded {
		caskroom := os.join_path(runtime.config.prefix, 'Caskroom')
		cask_tap := os.join_path(runtime.config.library, 'Taps', 'homebrew', 'homebrew-cask')
		runtime.cask_installed = os.is_dir(caskroom)
			&& (os.is_dir(cask_tap) || !runtime.config.no_install_from_api)
		runtime.cask_installed_loaded = true
	}
	return runtime.cask_installed
}

pub fn (mut runtime BundleRuntime) exchange_uid_if_needed_value(block_result ruby.Value) ruby.Value {
	if runtime.config.euid != runtime.config.uid {
		// The Ruby process temporarily exchanges IDs around the block. V callers
		// keep process credentials unchanged and expose the exchange as state so
		// privileged launchers can perform it at their process boundary.
		runtime.uid_exchange_count++
	}
	return block_result
}

fn bundle_formula_environment_name(formula_name string) string {
	return formula_name.to_upper().replace('@', 'AT').replace('+', 'X').replace('-', '_')
}

pub fn (mut runtime BundleRuntime) formula_version_from_environment(formula_name string) ?string {
	if !runtime.formula_versions_loaded {
		prefix := 'HOMEBREW_BUNDLE_FORMULA_VERSION_'
		mut versions := map[string]string{}
		for key, value in os.environ() {
			if !key.starts_with(prefix) {
				continue
			}
			name := key[prefix.len..]
			if name == '' {
				continue
			}
			versions[name] = value
			os.unsetenv(key)
		}
		runtime.formula_versions = versions.clone()
		runtime.formula_versions_loaded = true
	}
	return runtime.formula_versions[bundle_formula_environment_name(formula_name)] or { none }
}

pub fn (mut runtime BundleRuntime) set_formula_versions_cache(versions ?map[string]string) {
	if values := versions {
		runtime.formula_versions = values.clone()
		runtime.formula_versions_loaded = true
	} else {
		runtime.formula_versions = map[string]string{}
		runtime.formula_versions_loaded = false
	}
}

pub fn (mut runtime BundleRuntime) prepend_pkgconf_path_if_needed() {
	// The cross-platform extension supplies the platform-specific path. Keep
	// this source-level hook observable while the base implementation is empty.
	runtime.pkgconf_prepend_count++
}

pub fn (mut runtime BundleRuntime) reset() {
	runtime.upgrade_formulae = []
	runtime.upgrade_formulae_loaded = false
	runtime.formula_versions = map[string]string{}
	runtime.formula_versions_loaded = false
	runtime.cask_installed = false
	runtime.cask_installed_loaded = false
}

pub fn (mut runtime BundleRuntime) mark_as_installed_on_request(entries []BundleEntry) {
	if entries.len == 0 || runtime.installed_formulae.len == 0 {
		return
	}
	mut use_brew_tab := false
	mut fallback := []string{}
	for entry in entries {
		if entry.entry_type != 'brew' || entry.name !in runtime.installed_formulae {
			continue
		}
		mut tab := runtime.tabs[entry.name] or { continue }
		if !tab.exists || tab.installed_on_request {
			continue
		}
		if use_brew_tab {
			fallback << entry.name
			continue
		}
		if tab.writable {
			tab = BundleTabState{
				...tab
				installed_on_request: true
			}
			runtime.tabs[entry.name] = tab
		} else {
			use_brew_tab = true
			fallback << entry.name
		}
	}
	if use_brew_tab {
		runtime.brew_tab_updates << fallback
		for name in fallback {
			if tab := runtime.tabs[name] {
				runtime.tabs[name] = BundleTabState{
					...tab
					installed_on_request: true
				}
			}
		}
	}
}

fn bundle_runtime_value(runtime &BundleRuntime) ruby.Value {
	return ruby.structured_value('Homebrew::Bundle', '', {
		'bundle_runtime_address': u64(voidptr(runtime)).str()
	})
}

pub fn bundle_runtime_boundary(runtime &BundleRuntime) ruby.Value {
	return bundle_runtime_value(runtime)
}

fn bundle_runtime_from_args(args []ruby.Value, method string) &BundleRuntime {
	if args.len == 0 || args[0].type_name != 'Homebrew::Bundle' {
		panic('Homebrew::Bundle.${method} requires a translated runtime')
	}
	address := args[0].attributes['bundle_runtime_address'] or {
		panic('Homebrew::Bundle runtime has no translated state')
	}
	return unsafe { &BundleRuntime(voidptr(address.u64())) }
}

fn bundle_string_map_value(values map[string]string) ruby.Value {
	mut mapped := map[string]ruby.Value{}
	for key, value in values {
		mapped[key] = ruby.string_value(value)
	}
	return ruby.map_value(mapped)
}

fn bundle_string_map_from_value(value ruby.Value) map[string]string {
	mut mapped := map[string]string{}
	for key, item in value.as_map() or { return mapped } {
		mapped[key] = item.as_string()
	}
	return mapped
}

pub fn bundle_entry_boundary(entry BundleEntry) ruby.Value {
	return ruby.map_value({
		'type': ruby.string_value(entry.entry_type)
		'name': ruby.string_value(entry.name)
	})
}

fn bundle_entry_from_value(value ruby.Value) BundleEntry {
	fields := value.map_data.clone()
	return BundleEntry{
		entry_type: (fields['type'] or { ruby.string_value('') }).as_string()
		name: (fields['name'] or { ruby.string_value('') }).as_string()
	}
}
