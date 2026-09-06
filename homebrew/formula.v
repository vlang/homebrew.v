module homebrew

import ruby
import hash.fnv1a
import homebrew.api
import os
import time

// Translated from Homebrew/brew `formula.rb`.
pub struct FormulaConfig {
pub:
	reference                       api.PackageReference
	prefix                          string
	cellar                          string
	active_spec                     string
	alias_path                      string
	options                         Options
	deprecated_options              []DeprecatedOption
	compatibility_version           int
	has_compatibility_version       bool
	source_modified_time            i64
	has_source_modified_time        bool
	build                           BuildOptions
	follow_installed_alias          bool = true
	force_bottle                    bool
	pypi_package_name               string
	pypi_extra_packages             []string
	pypi_exclude_packages           []string
	pypi_dependencies               []string
	preserve_rpath                  bool
	homepage_browsed                string
	livecheck                       string
	livecheck_defined               bool
	autobump                        bool = true
	no_autobump_message             string
	service_block                   string
	network_access_allowed          map[string]bool = {
		'build':       true
		'test':        true
		'postinstall': true
	}
	loaded_from_internal_api        bool
	api_source                      string
	post_install_steps              []string
	post_install_steps_defined      bool
	on_system_blocks_exist          bool
	keg_only_reason                 string
	conflicts                       []string
	skip_clean_paths                []string
	link_overwrite_paths            []string
	pour_bottle_only_if             string
	pour_bottle_reason              string
	deprecation_date                string
	deprecation_replacement_formula string
	deprecation_replacement_cask    string
	disable_date                    string
	disable_replacement_formula     string
	disable_replacement_cask        string
	resources                       []string
	patches                         []string
	requirements                    []string
	compiler_failures               []string
	mirrors                         []string
	test_defined                    bool
}

pub struct Formula {
pub mut:
	reference                             api.PackageReference
	tap                                   string
	active_spec                           string
	alias_path                            string
	build                                 BuildOptions
	options_value                         Options
	deprecated_option_values              []DeprecatedOption
	compatibility_version                 int
	has_compatibility_version             bool
	source_modified_time                  i64
	has_source_modified_time              bool
	buildpath                             string
	testpath                              string
	local_bottle_path                     string
	active_log_type                       string
	follow_installed_alias                bool
	force_bottle                          bool
	pypi_package_name                     string
	pypi_extra_packages                   []string
	pypi_exclude_packages                 []string
	pypi_dependencies                     []string
	preserve_rpath_value                  bool
	homepage_browsed_value                string
	livecheck_value                       string
	livecheck_defined_value               bool
	autobump_value                        bool = true
	no_autobump_message_value             string
	service_block_value                   string
	network_access_allowed_value          map[string]bool
	loaded_from_internal_api_value        bool
	api_source_value                      string
	post_install_step_values              []string
	post_install_steps_defined_value      bool
	on_system_blocks_exist_value          bool
	keg_only_reason_value                 string
	conflict_values                       []string
	skip_clean_path_values                []string
	link_overwrite_path_values            []string
	pour_bottle_only_if_value             string
	pour_bottle_reason_value              string
	deprecation_date_value                string
	deprecation_replacement_formula_value string
	deprecation_replacement_cask_value    string
	disable_date_value                    string
	disable_replacement_formula_value     string
	disable_replacement_cask_value        string
	resource_values                       []string
	patch_values                          []string
	requirement_values                    []string
	compiler_failure_values               []string
	mirror_values                         []string
	test_defined_value                    bool
pub:
	prefix_root string
	cellar      string
}

fn formula_environment_prefix() string {
	return ruby.environment_value('HOMEBREW_PREFIX')
}

fn formula_environment_cellar(prefix string) string {
	cellar := ruby.environment_value('HOMEBREW_CELLAR')
	return if cellar == '' { ruby.join_path(prefix, 'Cellar') } else { cellar }
}

pub fn formula_from_reference(reference api.PackageReference, prefix string, cellar string) !Formula {
	return new_formula(FormulaConfig{
		reference: reference
		prefix: prefix
		cellar: cellar
	})
}

pub fn new_formula(config FormulaConfig) !Formula {
	if config.reference.kind != .formula {
		return error('Package reference `${config.reference.name}` is not a formula')
	}
	if config.reference.name == '' || config.reference.name.contains(' ') {
		return error('invalid formula name: ${config.reference.name}')
	}
	mut active_spec := config.active_spec.trim_left(':')
	if active_spec == '' {
		active_spec = if config.reference.stable_version != '' { 'stable' } else { 'head' }
	}
	if active_spec == 'stable' && config.reference.stable_version == '' {
		return error('${config.reference.full_name}: stable spec is not available')
	}
	if active_spec == 'head' && config.reference.head_version == '' {
		return error('${config.reference.full_name}: head spec is not available')
	}
	prefix := if config.prefix == '' { formula_environment_prefix() } else { config.prefix }
	cellar := if config.cellar == '' { formula_environment_cellar(prefix) } else { config.cellar }
	return Formula{
		reference: config.reference
		tap: config.reference.tap
		active_spec: active_spec
		alias_path: config.alias_path
		build: config.build
		options_value: config.options
		deprecated_option_values: config.deprecated_options.clone()
		compatibility_version: config.compatibility_version
		has_compatibility_version: config.has_compatibility_version
		source_modified_time: config.source_modified_time
		has_source_modified_time: config.has_source_modified_time
		follow_installed_alias: config.follow_installed_alias
		force_bottle: config.force_bottle
		pypi_package_name: config.pypi_package_name
		pypi_extra_packages: config.pypi_extra_packages.clone()
		pypi_exclude_packages: config.pypi_exclude_packages.clone()
		pypi_dependencies: config.pypi_dependencies.clone()
		preserve_rpath_value: config.preserve_rpath
		homepage_browsed_value: config.homepage_browsed
		livecheck_value: config.livecheck
		livecheck_defined_value: config.livecheck_defined
		autobump_value: config.autobump
		no_autobump_message_value: config.no_autobump_message
		service_block_value: config.service_block
		network_access_allowed_value: config.network_access_allowed.clone()
		loaded_from_internal_api_value: config.loaded_from_internal_api
		api_source_value: config.api_source
		post_install_step_values: config.post_install_steps.clone()
		post_install_steps_defined_value: config.post_install_steps_defined
		on_system_blocks_exist_value: config.on_system_blocks_exist
		keg_only_reason_value: config.keg_only_reason
		conflict_values: config.conflicts.clone()
		skip_clean_path_values: config.skip_clean_paths.clone()
		link_overwrite_path_values: config.link_overwrite_paths.clone()
		pour_bottle_only_if_value: config.pour_bottle_only_if
		pour_bottle_reason_value: config.pour_bottle_reason
		deprecation_date_value: config.deprecation_date
		deprecation_replacement_formula_value: config.deprecation_replacement_formula
		deprecation_replacement_cask_value: config.deprecation_replacement_cask
		disable_date_value: config.disable_date
		disable_replacement_formula_value: config.disable_replacement_formula
		disable_replacement_cask_value: config.disable_replacement_cask
		resource_values: config.resources.clone()
		patch_values: config.patches.clone()
		requirement_values: config.requirements.clone()
		compiler_failure_values: config.compiler_failures.clone()
		mirror_values: config.mirrors.clone()
		test_defined_value: config.test_defined
		prefix_root: prefix
		cellar: cellar
	}
}

pub fn (formula Formula) name() string {
	return formula.reference.name
}

pub fn (formula Formula) full_name() string {
	if formula.reference.full_name != '' {
		return formula.reference.full_name
	}
	return if formula.tap != '' && formula.tap != 'homebrew/core' {
		'${formula.tap}/${formula.name()}'
	} else {
		formula.name()
	}
}

pub fn (formula Formula) alias_name() string {
	if formula.reference.alias_name != '' {
		return formula.reference.alias_name
	}
	return if formula.alias_path == '' { '' } else { os.base(formula.alias_path) }
}

pub fn (formula Formula) full_alias_name() string {
	alias_name := formula.alias_name()
	if alias_name == '' {
		return ''
	}
	return formula.full_name_with_optional_tap(alias_name)
}

pub fn (formula Formula) full_name_with_optional_tap(name string) string {
	return if name == '' || formula.tap == '' || formula.tap == 'homebrew/core' {
		name
	} else {
		'${formula.tap}/${name}'
	}
}

pub fn (formula Formula) path() string {
	if formula.reference.local_path != '' {
		return formula.reference.local_path
	}
	return formula.reference.ruby_source_path
}

pub fn (formula Formula) specified_path() string {
	return if formula.alias_path != '' { formula.alias_path } else { formula.path() }
}

pub fn (formula Formula) specified_name() string {
	return if formula.alias_name() != '' { formula.alias_name() } else { formula.name() }
}

pub fn (formula Formula) full_specified_name() string {
	return if formula.full_alias_name() != '' {
		formula.full_alias_name()
	} else {
		formula.full_name()
	}
}

pub fn (formula Formula) version() !Version {
	value := if formula.active_spec == 'head' {
		formula.reference.head_version
	} else {
		formula.reference.stable_version
	}
	return new_version(value)
}

pub fn (formula Formula) stable_version() ?Version {
	if formula.reference.stable_version == '' {
		return none
	}
	return new_version(formula.reference.stable_version) or { return none }
}

pub fn (formula Formula) head_version() ?Version {
	if formula.reference.head_version == '' {
		return none
	}
	return new_version(formula.reference.head_version) or { return none }
}

pub fn (formula Formula) pkg_version() !PkgVersion {
	return new_pkg_version(formula.version()!, formula.reference.revision)
}

pub fn (formula Formula) stable() bool {
	return formula.active_spec == 'stable'
}

pub fn (formula Formula) head() bool {
	return formula.active_spec == 'head'
}

pub fn (formula Formula) spec() string {
	return formula.active_spec
}

pub fn (formula Formula) head_only() bool {
	return formula.reference.head_version != '' && formula.reference.stable_version == ''
}

pub fn (formula Formula) url() string {
	return formula.reference.source_url
}

pub fn (formula Formula) checksum() string {
	return formula.reference.source_checksum
}

pub fn (formula Formula) description() string {
	return formula.reference.description
}

pub fn (formula Formula) license() string {
	return formula.reference.license
}

pub fn (formula Formula) homepage() string {
	return formula.reference.homepage
}

pub fn (formula Formula) deps() []Dependency {
	mut dependencies := formula.reference.dependencies.map(new_dependency(it, []string{}))
	dependencies << formula.reference.build_dependencies.map(new_dependency(it, [
		':build',
	]))
	dependencies << formula.reference.test_dependencies.map(new_dependency(it, [
		':test',
	]))
	dependencies << formula.reference.recommended_dependencies.map(new_dependency(it, [
		':recommended',
	]))
	dependencies << formula.reference.optional_dependencies.map(new_dependency(it, [
		':optional',
	]))
	return dependencies
}

pub fn (formula Formula) options() Options {
	return formula.options_value
}

pub fn (formula Formula) deprecated_options() []DeprecatedOption {
	return formula.deprecated_option_values.clone()
}

pub fn (formula Formula) oldnames() []string {
	return formula.reference.oldnames.clone()
}

pub fn (formula Formula) aliases() []string {
	return formula.reference.aliases.clone()
}

pub fn (formula Formula) possible_names() []string {
	mut names := [formula.name()]
	for value in formula.oldnames() {
		if value != '' && value !in names { names << value }
	}
	for value in formula.aliases() {
		if value != '' && value !in names { names << value }
	}
	return names
}

pub fn (formula Formula) rack() string {
	return ruby.join_path(formula.cellar, formula.name())
}

pub fn (formula Formula) opt_prefix() string {
	return os.join_path(formula.prefix_root, 'opt', formula.name())
}

pub fn (formula Formula) versioned_prefix(version PkgVersion) string {
	return ruby.join_path(formula.rack(), version.to_s())
}

pub fn (formula Formula) prefix_for(version PkgVersion) string {
	versioned := formula.versioned_prefix(version)
	current := formula.pkg_version() or { return versioned }
	if version.equals(current) && ruby.is_dir(versioned) {
		if keg := new_keg_with_paths(versioned, formula.cellar, formula.prefix_root) {
			if keg.optlinked() {
				return formula.opt_prefix()
			}
		}
	}
	return versioned
}

pub fn (formula Formula) prefix() string {
	version := formula.pkg_version() or { return formula.rack() }
	return formula.prefix_for(version)
}

pub fn (formula Formula) installed_prefixes() []string {
	mut prefixes := []string{}
	for possible_name in formula.possible_names() {
		rack := ruby.join_path(formula.cellar, possible_name)
		for entry in ruby.list_dir(rack) or { continue } {
			path := ruby.join_path(rack, entry)
			if ruby.is_dir(path) {
				prefixes << path
			}
		}
	}
	return prefixes
}

pub fn (formula Formula) installed_kegs() []Keg {
	mut kegs := []Keg{}
	for path in formula.installed_prefixes() {
		if keg := new_keg_with_paths(path, formula.cellar, formula.prefix_root) {
			kegs << keg
		}
	}
	return kegs
}

pub fn (formula Formula) any_installed_keg() ?Keg {
	prefix := formula.any_installed_prefix() or { return none }
	return new_keg_with_paths(ruby.real_path(prefix), formula.cellar, formula.prefix_root) or {
		none
	}
}

pub fn (formula Formula) any_installed_prefix() ?string {
	if formula.optlinked() && ruby.path_exists(formula.opt_prefix()) {
		return formula.opt_prefix()
	}
	prefixes := formula.installed_prefixes()
	if prefixes.len == 0 {
		return none
	}
	return prefixes.last()
}

pub fn (formula Formula) any_installed_version() ?PkgVersion {
	keg := formula.any_installed_keg() or { return none }
	return keg.version() or { none }
}

pub fn (formula Formula) latest_installed_prefix() string {
	if formula.reference.head_version != '' {
		if head_version := formula.latest_head_version() {
			if !formula.head_version_outdated(head_version) {
				return formula.versioned_prefix(head_version)
			}
		}
	}
	current := formula.pkg_version() or { return formula.prefix() }
	stable_prefix := formula.versioned_prefix(current)
	if ruby.is_dir(stable_prefix) {
		return stable_prefix
	}
	if keg := formula.any_installed_keg() {
		return keg.path
	}
	return formula.prefix()
}

pub fn (formula Formula) latest_head_version() ?PkgVersion {
	mut found := false
	mut selected := new_pkg_version(null_version(), 0)
	mut selected_time := i64(0)
	for keg in formula.installed_kegs() {
		version := keg.version() or { continue }
		if !version.head() {
			continue
		}
		tab := keg.tab() or { empty_tab() }
		modified := tab.source_modified_time()
		if !found || modified > selected_time || (modified == selected_time && version.revision > selected.revision) {
			found = true
			selected = version
			selected_time = modified
		}
	}
	if !found {
		return none
	}
	return selected
}

pub fn (formula Formula) latest_head_prefix() ?string {
	version := formula.latest_head_version() or { return none }
	return formula.versioned_prefix(version)
}

pub fn (formula Formula) head_version_outdated(version PkgVersion) bool {
	tab := tab_for_keg(formula.versioned_prefix(version)) or { return true }
	if tab.version_scheme() < formula.reference.version_scheme {
		return true
	}
	if installed_stable := tab.stable_version() {
		if current_stable := formula.stable_version() {
			if installed_stable.compare_to(current_stable) < 0 {
				return true
			}
		}
	}
	return false
}

pub fn (formula Formula) latest_head_pkg_version() !PkgVersion {
	latest := formula.latest_head_version() or { return formula.pkg_version() }
	return if formula.head_version_outdated(latest) { formula.pkg_version() } else { latest }
}

pub fn (formula Formula) latest_version_installed() bool {
	path := formula.latest_installed_prefix()
	return ruby.is_dir(path) && (ruby.list_dir(path) or { []string{} }).len > 0
}

pub fn (formula Formula) any_version_installed() bool {
	return formula.installed_prefixes().any(ruby.is_file(ruby.join_path(it, tab_filename)))
}

pub fn (formula Formula) linked_keg() string {
	linked_directory := os.join_path(formula.prefix_root, 'var', 'homebrew', 'linked')
	for possible_name in formula.possible_names() {
		path := ruby.join_path(linked_directory, possible_name)
		if ruby.is_dir(path) {
			return path
		}
	}
	return ruby.join_path(linked_directory, formula.name())
}

pub fn (formula Formula) linked() bool {
	return ruby.path_exists(formula.linked_keg())
}

pub fn (formula Formula) optlinked() bool {
	return ruby.is_link(formula.opt_prefix())
}

pub fn (formula Formula) linked_version() ?PkgVersion {
	if !formula.linked() {
		return none
	}
	keg := keg_for_path(formula.linked_keg(), formula.cellar, formula.prefix_root) or {
		return none
	}
	return keg.version() or { return none }
}

pub fn (formula Formula) pin_path() string {
	return os.join_path(formula.prefix_root, 'var', 'homebrew', 'pinned', formula.name())
}

pub fn (formula Formula) pinned() bool {
	return ruby.is_link(formula.pin_path())
}

pub fn (formula Formula) pinnable() bool {
	return formula.installed_prefixes().len > 0
}

pub fn (formula Formula) pinned_version() ?PkgVersion {
	if !formula.pinned() {
		return none
	}
	keg := new_keg_with_paths(ruby.real_path(formula.pin_path()), formula.cellar, formula.prefix_root) or { return none }
	return keg.version() or { return none }
}

pub fn (formula Formula) pin() ! {
	keg := formula.any_installed_keg() or { return }
	make_relative_keg_symlink(formula.pin_path(), keg.path, false, false)!
}

pub fn (formula Formula) unpin() ! {
	if formula.pinned() { os.rm(formula.pin_path())! }
	parent := os.dir(formula.pin_path())
	if (ruby.list_dir(parent) or { []string{} }).len == 0 { os.rmdir(parent) or {} }
}

pub fn (formula Formula) outdated_kegs() []Keg {
	kegs := formula.installed_kegs()
	if kegs.len == 0 {
		return []Keg{}
	}
	current := formula.pkg_version() or { return []Keg{} }
	for keg in kegs {
		installed := keg.version() or { continue }
		if keg.version_scheme() == formula.reference.version_scheme && installed.compare_to(current) >= 0 && (keg.optlinked() || keg.linked() || formula.pinned()) {
			return []Keg{}
		}
	}
	mut outdated := kegs.clone()
	for index in 1 .. outdated.len {
		mut current_index := index
		for current_index > 0 && outdated[current_index].compare_scheme_and_version(outdated[current_index - 1]) < 0 {
			outdated[current_index], outdated[current_index - 1] = outdated[current_index - 1], outdated[current_index]
			current_index--
		}
	}
	return outdated
}

pub fn (formula Formula) outdated() bool {
	return formula.outdated_kegs().len > 0
}

pub fn (formula Formula) keg_only() bool {
	return formula.reference.keg_only
}

pub fn (formula Formula) deprecated() bool {
	return formula.reference.deprecated
}

pub fn (formula Formula) deprecation_reason() string {
	return formula.reference.deprecation_reason
}

pub fn (formula Formula) disabled() bool {
	return formula.reference.disabled
}

pub fn (formula Formula) disable_reason() string {
	return formula.reference.disable_reason
}

pub fn (formula Formula) loaded_from_api() bool {
	return formula.reference.loaded_from_api
}

pub fn (formula Formula) versioned_formula() bool {
	return formula.name().contains('@')
}

pub fn (formula Formula) unversioned_formula_name() string {
	if !formula.versioned_formula() {
		return ''
	}
	name := formula.name()
	at := name.index('@') or { return '' }
	if name.ends_with('-full') {
		return '${name[..at]}-full'
	}
	return name[..at]
}

pub fn (formula Formula) equal(other Formula) bool {
	return formula.name() == other.name() && formula.active_spec == other.active_spec
}

pub fn (formula Formula) hash_code() u64 {
	return fnv1a.sum64_string(formula.name())
}

pub fn (formula Formula) str() string {
	return formula.name()
}

pub fn (formula Formula) inspect() string {
	return '#<Formula ${formula.name()} (${formula.active_spec}) ${formula.path()}>'
}

fn formula_path_value(formula Formula, parts ...string) string {
	mut path := formula.prefix()
	for part in parts {
		path = ruby.join_path(path, part)
	}
	return path
}

fn formula_make_jobs() int {
	configured := os.getenv('HOMEBREW_MAKE_JOBS').int()
	return if configured > 0 { configured } else { 1 }
}

pub fn formula_std_cabal_v2_args(installdir ?string) []string {
	mut args := ['--jobs=${formula_make_jobs()}', '--max-backjumps=100000']
	if directory := installdir {
		args << '--install-method=copy'
		args << '--installdir=${directory}'
	}
	$if linux {
		$if arm64 || arm32 {
			// extend/os/linux/formula.rb adds PIE for GHC on Linux ARM.
			args << '--ghc-option=-pie'
		}
	}
	return args
}

pub fn formula_std_cargo_args(root string, path string, features []string) []string {
	mut args := ['--jobs', formula_make_jobs().str(), '--locked', '--root=${root}', '--path=${path}']
	if features.len > 0 {
		args << '--features=${features.join(',')}'
	}
	return args
}

pub fn formula_std_cmake_args(install_prefix string, install_libdir string,
	find_framework string) []string {
	return [
		'-DCMAKE_INSTALL_PREFIX=${install_prefix}',
		'-DCMAKE_INSTALL_LIBDIR=${install_libdir}',
		'-DCMAKE_BUILD_TYPE=Release',
		'-DCMAKE_FIND_FRAMEWORK=${find_framework}',
		'-DCMAKE_VERBOSE_MAKEFILE=ON',
		'-DCMAKE_PROJECT_TOP_LEVEL_INCLUDES=${ruby.join_path(ruby.environment_value('HOMEBREW_LIBRARY_PATH'), 'cmake/trap_fetchcontent_provider.cmake')}',
		'-Wno-dev',
		'-DBUILD_TESTING=OFF',
		'-DCCACHE_FOUND=OFF',
	]
}

pub fn formula_std_configure_args(prefix string, libdir string) []string {
	expanded_libdir := if os.is_abs_path(libdir) {
		libdir
	} else {
		ruby.join_path(prefix, libdir)
	}
	return ['--disable-debug', '--disable-dependency-tracking', '--prefix=${prefix}',
		'--libdir=${expanded_libdir}']
}

pub fn formula_std_go_args(output string, ldflags []string, gcflags []string, tags []string,
	debug_symbols bool) []string {
	mut final_ldflags := ldflags.clone()
	if !debug_symbols {
		final_ldflags.prepend('-w')
		final_ldflags.prepend('-s')
	}
	mut args := ['-trimpath', '-o=${output}']
	if tags.len > 0 { args << '-tags=${tags.join(',')}' }
	if final_ldflags.len > 0 { args << '-ldflags=${final_ldflags.join(' ')}' }
	if gcflags.len > 0 { args << '-gcflags=${gcflags.join(' ')}' }
	return args
}

pub fn formula_std_meson_args(prefix string, libdir string) []string {
	return ['--prefix=${prefix}', '--libdir=${libdir}', '--buildtype=release',
		'--wrap-mode=nofallback']
}

pub fn formula_std_npm_args(prefix ?string, ignore_scripts bool) []string {
	mut args := ['install', '--global', '--build-from-source']
	if directory := prefix { args << '--prefix=${directory}' }
	args << '--min-release-age=1'
	if ignore_scripts { args << '--ignore-scripts' }
	return args
}

pub fn formula_std_pip_args(prefix ?string, build_isolation bool) []string {
	mut args := ['--verbose', '--no-deps', '--no-binary=:all:', '--ignore-installed', '--no-compile',
		'--uploaded-prior-to=P1D']
	if directory := prefix { args << '--prefix=${directory}' }
	if !build_isolation { args << '--no-build-isolation' }
	return args
}

pub fn formula_std_swift_args() []string {
	mut args := ['--configuration', 'release', '--jobs', formula_make_jobs().str()]
	$if macos {
		args << '--disable-sandbox'
	}
	$if linux {
		args << '-Xswiftc'
		args << '-use-ld=ld'
	}
	return args
}

pub fn formula_std_zig_args(prefix string, release_mode string, cpu string) ![]string {
	if release_mode !in ['safe', 'fast', 'small'] {
		return error('Invalid Zig release mode: ${release_mode}')
	}
	selected_cpu := if cpu == '' { 'baseline' } else { cpu }
	capitalized := release_mode[..1].to_upper() + release_mode[1..]
	return ['--prefix', prefix, '--release=${release_mode}', '-Doptimize=Release${capitalized}',
		'--summary', 'all', '-Dcpu=${selected_cpu}']
}

pub fn formula_shared_library(name string, version string) string {
	if name == '*' && (version == '' || version == '*') {
		return '*.dylib'
	}
	infix := if version == '*' {
		'{,.*}'
	} else if version != '' { '.${version}' } else { '' }
	return '${name}${infix}.dylib'
}

pub fn formula_rpath(source string, target string, prefix string) !string {
	if !target.starts_with(prefix) {
		return error('rpath `target` should only be used for paths inside `\$HOMEBREW_PREFIX`!')
	}
	source_parts := ruby.absolute_path(source).trim('/').split('/')
	target_parts := ruby.absolute_path(target).trim('/').split('/')
	mut common := 0
	for common < source_parts.len && common < target_parts.len && source_parts[common] == target_parts[common] {
		common++
	}
	mut relative_parts := []string{}
	for _ in common .. source_parts.len {
		relative_parts << '..'
	}
	relative_parts << target_parts[common..]
	relative := if relative_parts.len == 0 { '.' } else { relative_parts.join('/') }
	return '@loader_path/${relative}'
}

const formula_boundary_separator = '\x1e'

fn formula_supported_network_phase(phase string) bool {
	return phase in ['build', 'test', 'postinstall']
}

fn formula_date_reached(date string) bool {
	parsed := time.parse_iso8601('${date}T00:00:00Z') or { panic('invalid date `${date}`') }
	now := time.now()
	return parsed.unix() <= now.unix()
}

fn formula_path_pattern_matches(pattern string, path string) bool {
	if pattern == path || path.starts_with('${pattern.trim_right('/')}/') {
		return true
	}
	if !pattern.contains('*') {
		return false
	}
	parts := pattern.split('*')
	mut offset := 0
	for index, part in parts {
		if part == '' {
			continue
		}
		position := path[offset..].index(part) or { return false }
		if index == 0 && position != 0 {
			return false
		}
		offset += position + part.len
	}
	return pattern.ends_with('*') || offset == path.len
}

fn formula_files_under(directory string) []string {
	if directory == '' || !ruby.is_dir(directory) {
		return []string{}
	}
	mut files := os.walk_ext(directory, '.rb', hidden: true)
	files.sort()
	return files
}

fn formula_names_from_files(files []string) []string {
	mut names := []string{}
	for path in files {
		name := os.base(path).trim_string_right('.rb')
		if name !in names { names << name }
	}
	names.sort()
	return names
}

fn formula_racks(cellar string) []string {
	mut racks := []string{}
	for entry in ruby.list_dir(cellar) or { return racks } {
		path := ruby.join_path(cellar, entry)
		if ruby.is_dir(path) && !ruby.is_link(path) && !entry.starts_with('.') && (ruby.list_dir(path) or { []string{} }).len > 0 {
			racks << path
		}
	}
	racks.sort()
	return racks
}

fn formula_edit_distance(left string, right string) int {
	mut previous := []int{len: right.len + 1, init: index}
	for left_index, left_byte in left.bytes() {
		mut current := []int{len: right.len + 1}
		current[0] = left_index + 1
		for right_index, right_byte in right.bytes() {
			cost := if left_byte == right_byte { 0 } else { 1 }
			current[right_index + 1] = int_min(current[right_index] + 1, int_min(previous[right_index + 1] + 1, previous[right_index] + cost))
		}
		previous = current.clone()
	}
	return previous.last()
}

fn formula_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn formula_unique_dependencies(dependencies []Dependency) []Dependency {
	mut seen := map[string]bool{}
	mut unique := []Dependency{}
	for dependency in dependencies {
		identity := '${dependency.name}\x1f${dependency.tags.map(it.boundary_string()).join('\x1e')}'
		if identity in seen {
			continue
		}
		seen[identity] = true
		unique << dependency
	}
	return unique
}

fn formula_declared_runtime_dependencies(formula Formula) []Dependency {
	mut result := []Dependency{}
	mut visited := map[string]bool{}
	mut pending := formula.deps().clone()
	for pending.len > 0 {
		dependency := pending[0]
		pending.delete(0)
		if dependency.name in visited || dependency.has_symbol_tag('build') || dependency.has_symbol_tag('test') || dependency.has_symbol_tag('optional') {
			continue
		}
		if dependency.has_symbol_tag('recommended') {
			if formula.build.any_args_or_options() {
				if formula.build.without(dependency.name) {
					continue
				}
			} else {
				continue
			}
		}
		visited[dependency.name] = true
		result << dependency
		resolved := dependency_to_formula(dependency, false, default_formulary_lookup_config()) or {
			continue
		}
		pending << resolved.deps()
	}
	return result
}

fn formula_runtime_dependencies(formula Formula, read_from_tab bool, undeclared bool) []Dependency {
	if read_from_tab && undeclared {
		if keg := formula.any_installed_keg() {
			if receipts := keg.runtime_dependencies() {
				return receipts.filter(it.full_name != '').map(new_dependency(it.full_name, []string{}))
			}
		}
	}
	declared := formula_declared_runtime_dependencies(formula)
	if !undeclared {
		return declared
	}
	// Linkage data is an installed-keg property. The translated Keg model exposes
	// the receipt linkage directly, so names absent from the declaration are the
	// undeclared runtime dependencies.
	if keg := formula.any_installed_keg() {
		if receipts := keg.runtime_dependencies() {
			mut combined := declared.clone()
			declared_names := declared.map(it.name)
			for receipt in receipts {
				if receipt.full_name != '' && receipt.full_name !in declared_names {
					combined << new_dependency(receipt.full_name, []string{})
				}
			}
			return formula_unique_dependencies(combined)
		}
	}
	return declared
}

fn formula_dependency_names(dependencies []Dependency, tag string, reject_tags []string) []string {
	mut names := []string{}
	for dependency in dependencies {
		if dependency.has_symbol_tag('implicit') || dependency.uses_from_macos_dependency() {
			continue
		}
		if tag != '' && !dependency.has_symbol_tag(tag) {
			continue
		}
		if reject_tags.any(dependency.has_symbol_tag(it)) {
			continue
		}
		if dependency.name !in names { names << dependency.name }
	}
	return names
}

fn formula_patch_attributes(encoded string) map[string]string {
	mut attributes := map[string]string{}
	if encoded.split(';').any(it.contains('=')) {
		for segment in encoded.split(';') {
			separator := segment.index('=') or { continue }
			key := segment[..separator].trim_space()
			if key == '' {
				continue
			}
			attributes[key] = segment[separator + 1..]
		}
		if 'strip' !in attributes {
			attributes['strip'] = 'p1'
		}
		return attributes
	}
	parts := encoded.split('\x1f')
	attributes['strip'] = if parts.len > 0 && parts[0] != '' { parts[0] } else { 'p1' }
	source := if parts.len > 1 { parts[1] } else { 'embedded' }
	if source == '' || source == 'embedded' || source.starts_with('embedded@') {
		attributes['data'] = 'true'
	} else if source.contains('://') {
		attributes['url'] = source
	} else {
		// A positional String source is a StringPatch (embedded patch data), not
		// a LocalPatch file. Local files are carried explicitly with `file=`.
		attributes['data'] = 'true'
	}
	return attributes
}

fn formula_patch_resolutions(attributes map[string]string) []string {
	if explicit_resolves := attributes['resolves'] {
		return explicit_resolves.split(',').map(it.trim_space()).filter(it != '')
	}
	mut sources := []string{}
	if url := attributes['url'] { sources << url }
	if apply := attributes['apply'] { sources << apply.split(',') }
	return extract_cves(sources)
}
