module homebrew

import ruby
import homebrew.api
import homebrew.download_strategy

// Translated from Homebrew/brew `software_spec.rb`.
pub enum SoftwareSpecOwnerKind {
	formula
	cask
}

pub struct SoftwareSpecOwner {
pub:
	kind         SoftwareSpecOwnerKind
	name         string
	full_name    string
	tap          string
	force_bottle bool
}

pub enum SoftwareSpecRequirementKind {
	macos
	linux
	maximum_macos
	arch
	xcode
}

pub struct SoftwareSpecRequirement {
pub:
	kind       SoftwareSpecRequirementKind
	tags       []string
	comparator string
}

pub struct SoftwareSpecCompilerFailure {
pub:
	compiler          string
	version           Version
	exact_major_match bool
}

pub struct SoftwareSpec {
pub mut:
	name_value                             string
	full_name_value                        string
	owner_value                            SoftwareSpecOwner
	has_owner                              bool
	resource_value                         Resource
	resources_value                        map[string]Resource
	dependency_values                      []Dependency
	requirement_values                     []SoftwareSpecRequirement
	bottle_specification_value             BottleSpecification
	patch_values                           []ResourcePatch
	options_value                          Options
	flags                                  []string
	deprecated_flag_values                 []DeprecatedOption
	deprecated_option_values               []DeprecatedOption
	build_value                            BuildOptions
	compiler_failure_values                []SoftwareSpecCompilerFailure
	depends_on_macos_bare_set_top_level    bool
	depends_on_macos_version_set_top_level bool
	depends_on_maximum_macos_set_top_level bool
	depends_on_macos_set_in_block          bool
	depends_on_linux_set_top_level         bool
	frozen                                 bool
}

pub fn new_software_spec(flags []string) SoftwareSpec {
	options := new_options()
	return SoftwareSpec{
		resource_value: new_formula_resource('')
		resources_value: map[string]Resource{}
		bottle_specification_value: new_bottle_specification()
		options_value: options
		flags: flags.clone()
		build_value: new_build_options(new_options(...flags), options)
	}
}

pub fn (spec SoftwareSpec) duplicate() SoftwareSpec {
	mut resources := map[string]Resource{}
	for name, resource in spec.resources_value {
		resources[name] = resource.duplicate()
	}
	mut bottle_specification := spec.bottle_specification_value
	bottle_specification.collector = BottleTagCollector{
		tag_specs: spec.bottle_specification_value.collector.tag_specs.clone()
		order: spec.bottle_specification_value.collector.order.clone()
	}
	bottle_specification.root_url_specs = spec.bottle_specification_value.root_url_specs.clone()
	return SoftwareSpec{
		...spec
		resource_value: spec.resource_value.duplicate()
		resources_value: resources
		dependency_values: spec.dependency_values.clone()
		requirement_values: spec.requirement_values.clone()
		bottle_specification_value: bottle_specification
		patch_values: spec.patch_values.clone()
		options_value: spec.options_value.duplicate()
		flags: spec.flags.clone()
		deprecated_flag_values: spec.deprecated_flag_values.clone()
		deprecated_option_values: spec.deprecated_option_values.clone()
		build_value: new_build_options(spec.build_value.args.duplicate(), spec.build_value.options.duplicate())
		compiler_failure_values: spec.compiler_failure_values.clone()
		frozen: false
	}
}

pub fn (mut spec SoftwareSpec) freeze() {
	spec.options_value.freeze()
	spec.frozen = true
}

pub fn (spec SoftwareSpec) name() ?string {
	return if spec.name_value == '' { none } else { spec.name_value }
}

pub fn (spec SoftwareSpec) full_name() ?string {
	return if spec.full_name_value == '' { none } else { spec.full_name_value }
}

pub fn (spec SoftwareSpec) owner() ?SoftwareSpecOwner {
	return if spec.has_owner { spec.owner_value } else { none }
}

pub fn (spec SoftwareSpec) build() BuildOptions {
	return spec.build_value
}

pub fn (spec SoftwareSpec) resources() map[string]Resource {
	return spec.resources_value.clone()
}

pub fn (spec SoftwareSpec) patches() []ResourcePatch {
	return spec.patch_values.clone()
}

pub fn (spec SoftwareSpec) options() Options {
	return spec.options_value
}

pub fn (spec SoftwareSpec) deprecated_flags() []DeprecatedOption {
	return spec.deprecated_flag_values.clone()
}

pub fn (spec SoftwareSpec) deprecated_options() []DeprecatedOption {
	return spec.deprecated_option_values.clone()
}

pub fn (spec SoftwareSpec) bottle_specification() BottleSpecification {
	return spec.bottle_specification_value
}

pub fn (spec SoftwareSpec) compiler_failures() []SoftwareSpecCompilerFailure {
	return spec.compiler_failure_values.clone()
}

pub fn (mut spec SoftwareSpec) refresh_build() {
	spec.build_value = new_build_options(new_options(...spec.flags), spec.options_value)
}

pub fn (mut spec SoftwareSpec) set_owner(owner SoftwareSpecOwner) {
	spec.name_value = owner.name
	spec.full_name_value = owner.full_name
	spec.owner_value = owner
	spec.has_owner = true
	spec.bottle_specification_value.tap = owner.tap
	spec.bottle_specification_value.has_tap = owner.tap != ''
	owner_name := if owner.full_name == '' { owner.name } else { owner.full_name }
	spec.resource_value.set_owner(owner_name)
	main_version := spec.resource_value.version()
	mut resources := map[string]Resource{}
	for name, stored_resource in spec.resources_value {
		mut resource := stored_resource
		resource.set_owner(owner_name)
		if _ := resource.version() {
		} else if version := main_version {
			resource.set_version(if version.head() { 'HEAD' } else { version.to_s() }) or {
				panic(err)
			}
		}
		resources[name] = resource
	}
	spec.resources_value = resources.clone()
	for mut patch in spec.patch_values {
		patch.owner_name = owner_name
	}
}

fn software_spec_implicit_dependency(name string, tags []string) Dependency {
	mut all_tags := tags.clone()
	all_tags << ':implicit'
	return new_dependency(name, all_tags)
}

fn software_spec_command_missing(name string) bool {
	ruby.find_executable(name) or { return true }
	return false
}

fn software_spec_archive_dependency(url string, tags []string) ?Dependency {
	clean_url := url.all_before('?')
	$if macos {
		if clean_url.ends_with('.lha') || clean_url.ends_with('.lzh') {
			return software_spec_implicit_dependency('lha', tags)
		}
		if clean_url.ends_with('.lz') {
			return software_spec_implicit_dependency('lzip', tags)
		}
		if clean_url.ends_with('.rar') {
			return software_spec_implicit_dependency('libarchive', tags)
		}
		if clean_url.ends_with('.7z') {
			return software_spec_implicit_dependency('p7zip', tags)
		}
		return none
	} $else {
		if clean_url.ends_with('.xz') && software_spec_command_missing('xz') {
			return software_spec_implicit_dependency('xz', tags)
		}
		if clean_url.ends_with('.zst') && software_spec_command_missing('zstd') {
			return software_spec_implicit_dependency('zstd', tags)
		}
		if clean_url.ends_with('.zip') && software_spec_command_missing('unzip') {
			return software_spec_implicit_dependency('unzip', tags)
		}
		if clean_url.ends_with('.bz2') && software_spec_command_missing('bzip2') {
			return software_spec_implicit_dependency('bzip2', tags)
		}
		if (clean_url.ends_with('.lha') || clean_url.ends_with('.lzh')) && software_spec_command_missing('lha') {
			return software_spec_implicit_dependency('lha', tags)
		}
		if clean_url.ends_with('.lz') && software_spec_command_missing('lzip') {
			return software_spec_implicit_dependency('lzip', tags)
		}
		if clean_url.ends_with('.rar') && software_spec_command_missing('bsdtar') {
			return software_spec_implicit_dependency('libarchive', tags)
		}
		if clean_url.ends_with('.7z') && software_spec_command_missing('7z') {
			return software_spec_implicit_dependency('p7zip', tags)
		}
		return none
	}
}

fn (mut spec SoftwareSpec) collect_resource_dependencies(resource Resource) {
	mut tags := [':build', ':test']
	strategy := resource.download_strategy() or { return }
	url := resource.url() or { return }
	match strategy {
		.homebrew_curl {
			spec.dependency_values << software_spec_implicit_dependency('curl', tags)
			if dependency := software_spec_archive_dependency(url, tags) {
				spec.dependency_values << dependency
			}
		}
		.no_unzip_curl {}
		.curl, .curl_apache_mirror, .curl_github_packages, .curl_post, .pypi {
			if dependency := software_spec_archive_dependency(url, tags) {
				spec.dependency_values << dependency
			}
		}
		.github_git, .git {
			$if !macos {
				if software_spec_command_missing('git') {
					spec.dependency_values << software_spec_implicit_dependency('git', tags)
				}
			}
		}
		.subversion {
			$if macos {
				spec.dependency_values << software_spec_implicit_dependency('subversion', tags)
			} $else {
				if software_spec_command_missing('svn') {
					spec.dependency_values << software_spec_implicit_dependency('subversion', tags)
				}
			}
		}
		.cvs {
			if software_spec_command_missing('cvs') {
				spec.dependency_values << software_spec_implicit_dependency('cvs', tags)
			}
		}
		.mercurial {
			spec.dependency_values << software_spec_implicit_dependency('mercurial', tags)
		}
		.fossil {
			spec.dependency_values << software_spec_implicit_dependency('fossil', tags)
		}
		.bazaar {
			spec.dependency_values << software_spec_implicit_dependency('breezy', tags)
		}
	}
}

pub fn (mut spec SoftwareSpec) set_url(value string, source_specs map[string]string) !string {
	url := spec.resource_value.set_url(value, source_specs)!
	spec.collect_resource_dependencies(spec.resource_value)
	return url
}

pub fn (spec SoftwareSpec) url() ?string {
	return spec.resource_value.url()
}

pub fn (mut spec SoftwareSpec) set_version(value string) !Version {
	return spec.resource_value.set_version(value)
}

pub fn (spec SoftwareSpec) version() ?Version {
	return spec.resource_value.version()
}

pub fn (mut spec SoftwareSpec) sha256(value string) Checksum {
	return spec.resource_value.sha256(value)
}

pub fn (spec SoftwareSpec) checksum() ?Checksum {
	return if spec.resource_value.has_checksum { spec.resource_value.checksum } else { none }
}

pub fn (mut spec SoftwareSpec) mirror(value string) []string {
	return spec.resource_value.mirror(value)
}

pub fn (spec SoftwareSpec) mirrors() []string {
	return spec.resource_value.mirrors.clone()
}

pub fn (spec SoftwareSpec) source_specs() map[string]string {
	return spec.resource_value.specs()
}

pub fn (spec SoftwareSpec) using() ?string {
	return spec.resource_value.using()
}

pub fn (mut spec SoftwareSpec) verify_download_integrity(filename string) ! {
	spec.resource_value.verify_download_integrity(filename)!
}

pub fn (mut spec SoftwareSpec) stage(target string, debug_symbols bool) !string {
	return spec.resource_value.stage(target, debug_symbols)
}

pub fn (mut spec SoftwareSpec) fetch(verify bool, timeout ?f64, quiet bool,
	skip_patches bool) !string {
	return spec.resource_value.fetch(verify, timeout, quiet, skip_patches)
}

pub fn (mut spec SoftwareSpec) cached_download() !string {
	return spec.resource_value.cached_download()
}

pub fn (mut spec SoftwareSpec) clear_cache() ! {
	spec.resource_value.clear_cache()!
}

pub fn (mut spec SoftwareSpec) downloader() !&download_strategy.CurlDownloadStrategy {
	return spec.resource_value.downloader()
}

pub fn (spec SoftwareSpec) source_modified_time() ?i64 {
	return if spec.resource_value.has_source_modified_time {
		spec.resource_value.source_modified_time
	} else {
		none
	}
}

pub fn (spec SoftwareSpec) download_queue_name() !string {
	return spec.resource_value.download_queue_name()
}

pub fn (spec SoftwareSpec) download_queue_type() string {
	return spec.resource_value.download_queue_type()
}

pub fn (spec SoftwareSpec) bottle_defined() bool {
	return spec.bottle_specification_value.collector.tags().len > 0
}

pub fn (spec SoftwareSpec) bottle_tag(tag ?BottleTag) bool {
	selected := tag or { current_bottle_tag() }
	return spec.bottle_specification_value.has_tag(selected, false)
}

pub fn (spec SoftwareSpec) bottled(tag ?BottleTag) bool {
	selected := tag or { current_bottle_tag() }
	if !spec.bottle_specification_value.has_tag(selected, false) {
		return false
	}
	if _ := tag {
		return true
	}
	if spec.bottle_specification_value.compatible_locations(selected, default_bottle_location_context(selected)) {
		return true
	}
	return spec.has_owner && spec.owner_value.kind == .formula && spec.owner_value.force_bottle
}

pub fn (mut spec SoftwareSpec) set_bottle_specification(value BottleSpecification) {
	spec.bottle_specification_value = value
}

pub fn (spec SoftwareSpec) resource_defined(name string) bool {
	return name in spec.resources_value
}

pub fn (mut spec SoftwareSpec) define_resource(name string, mut resource Resource) !Resource {
	if name == '' {
		return error('Resource must have a name.')
	}
	if spec.resource_defined(name) {
		return error('DuplicateResourceError: ${name}')
	}
	if _ := resource.url() {
	} else {
		return resource
	}
	resource.name = name
	resource.has_name = true
	spec.resources_value[name] = resource
	spec.collect_resource_dependencies(resource)
	return resource
}

pub fn (spec SoftwareSpec) resource(name ?string) !Resource {
	if value := name {
		return spec.resources_value[value] or {
			return error('ResourceMissingError: ${spec.full_name_value}: ${value}')
		}
	}
	return spec.resource_value
}

pub fn (spec SoftwareSpec) option_defined(name string) bool {
	return spec.options_value.contains(name)
}

pub fn (mut spec SoftwareSpec) add_option(name string, description string) ! {
	if name == '' {
		return error('option name is required')
	}
	if name.len <= 1 {
		return error('option name must be longer than one character: ${name}')
	}
	if name.starts_with('-') {
		return error('option name must not start with dashes: ${name}')
	}
	spec.options_value.add(new_option(name, description))
	spec.refresh_build()
}

fn unique_software_spec_flags(values []string) []string {
	mut output := []string{}
	for value in values {
		if value !in output {
			output << value
		}
	}
	return output
}

pub fn (mut spec SoftwareSpec) add_deprecated_options(old_options []string,
	new_options []string) ! {
	if old_options.len == 0 && new_options.len == 0 {
		return error('deprecated_option hash must not be empty')
	}
	for old_option in old_options {
		for new_option_name in new_options {
			deprecated := new_deprecated_option(old_option, new_option_name)
			spec.deprecated_option_values << deprecated
			if deprecated.old_flag() !in spec.flags {
				continue
			}
			spec.flags = spec.flags.filter(it != deprecated.old_flag())
			spec.flags << deprecated.current_flag()
			spec.flags = unique_software_spec_flags(spec.flags)
			spec.deprecated_flag_values << deprecated
		}
	}
	spec.refresh_build()
}

pub fn (mut spec SoftwareSpec) add_dependency(dependency Dependency) {
	spec.dependency_values << dependency
	spec.add_dep_option(dependency)
}

pub fn (mut spec SoftwareSpec) depends_on(name string, tags []string) {
	spec.add_dependency(new_dependency(name, tags))
}

pub fn (mut spec SoftwareSpec) add_requirement(requirement SoftwareSpecRequirement,
	set_in_block bool) ! {
	spec.record_os_requirement(requirement, set_in_block)!
	spec.requirement_values << requirement
}

pub fn (spec SoftwareSpec) depends_on_macos_set_top_level() bool {
	return spec.depends_on_macos_bare_set_top_level || spec.depends_on_macos_version_set_top_level || spec.depends_on_maximum_macos_set_top_level
}

pub fn (spec SoftwareSpec) depends_on_linux_set_top_level() bool {
	return spec.depends_on_linux_set_top_level
}

pub fn (mut spec SoftwareSpec) record_os_requirement(requirement SoftwareSpecRequirement,
	set_in_block bool) ! {
	match requirement.kind {
		.macos, .maximum_macos {
			if set_in_block {
				spec.depends_on_macos_set_in_block = true
				return
			}
			if spec.depends_on_linux_set_top_level {
				return error('`depends_on :linux` cannot be combined with `depends_on macos:`')
			}
			if requirement.kind == .macos && requirement.tags.len == 0 {
				if spec.depends_on_macos_bare_set_top_level {
					return error('`depends_on :macos` cannot be combined with another macOS `depends_on`')
				}
				spec.depends_on_macos_bare_set_top_level = true
			} else if requirement.kind == .maximum_macos || requirement.comparator == '<=' {
				if spec.depends_on_maximum_macos_set_top_level {
					return error('`depends_on maximum_macos:` cannot be combined with another macOS `depends_on`')
				}
				spec.depends_on_maximum_macos_set_top_level = true
			} else {
				if spec.depends_on_macos_version_set_top_level {
					return error('`depends_on macos:` cannot be combined with another macOS `depends_on`')
				}
				spec.depends_on_macos_version_set_top_level = true
			}
		}
		.linux {
			if set_in_block {
				return
			}
			if spec.depends_on_macos_set_top_level() {
				return error('`depends_on :linux` cannot be combined with `depends_on macos:`')
			}
			spec.depends_on_linux_set_top_level = true
		}
		else {}
	}
}

pub fn (mut spec SoftwareSpec) uses_from_macos(name string, tags []string,
	bounds map[string]string) {
	spec.add_dependency(new_uses_from_macos_dependency(name, tags.map(dependency_tag(it)), bounds))
}

fn software_spec_macos_provides(dependency Dependency, system string) bool {
	if !dependency.uses_from_macos_dependency() || system == 'linux' {
		return false
	}
	if system != 'macos' && system !in macos_symbol_versions() {
		return false
	}
	since := dependency.macos_bounds['since'] or { return true }
	bound := macos_version_from_symbol(since) or { return true }
	if system == 'macos' {
		return null_version().compare_to(bound.version) >= 0
	}
	effective := macos_version_from_symbol(system) or { return false }
	return effective.compare(bound) >= 0
}

pub fn (spec SoftwareSpec) deps_for_system(system string) []Dependency {
	return spec.dependency_values.filter(!software_spec_macos_provides(it, system))
}

pub fn (spec SoftwareSpec) deps() []Dependency {
	$if macos {
		return spec.deps_for_system(current_bottle_tag().system)
	} $else $if linux {
		return spec.deps_for_system('linux')
	} $else {
		return spec.deps_for_system('generic')
	}
}

pub fn (spec SoftwareSpec) declared_deps() []Dependency {
	return spec.dependency_values.clone()
}

fn collect_software_spec_recursive_dependencies(dependencies []Dependency,
	config FormularyLookupConfig, mut output []Dependency, mut expanded map[string]bool) ! {
	for dependency in dependencies {
		if !output.any(it.equal(dependency)) {
			output << dependency
		}
		if dependency.name in expanded {
			continue
		}
		expanded[dependency.name] = true
		formula := dependency_to_formula(dependency, false, config) or {
			if dependency.name.split('/').len >= 3 {
				continue
			}
			return err
		}
		collect_software_spec_recursive_dependencies(formula.deps(), config, mut output, mut expanded)!
	}
}

pub fn (spec SoftwareSpec) recursive_dependencies(config FormularyLookupConfig) ![]Dependency {
	mut output := []Dependency{}
	mut expanded := map[string]bool{}
	collect_software_spec_recursive_dependencies(spec.deps(), config, mut output, mut expanded)!
	return output
}

pub fn (spec SoftwareSpec) requirements() []SoftwareSpecRequirement {
	return spec.requirement_values.clone()
}

pub fn (spec SoftwareSpec) recursive_requirements() []SoftwareSpecRequirement {
	return spec.requirement_values.clone()
}

pub fn (mut spec SoftwareSpec) add_patch(strip string, source string) {
	mut selected_strip := strip.trim_string_left(':')
	mut selected_source := source.trim_string_left(':')
	if selected_strip == 'DATA' {
		selected_strip = 'p1'
		selected_source = 'DATA'
	}
	if selected_strip == '' {
		selected_strip = 'p1'
	}
	if selected_source == '' {
		return
	}
	spec.patch_values << ResourcePatch{
		strip: selected_strip
		source: selected_source
		owner_name: spec.full_name_value
	}
}

pub fn (mut spec SoftwareSpec) add_external_patch(strip string, url string,
	source_specs map[string]string) ! {
	if url == '' {
		return
	}
	mut resource := new_resource('patch')
	resource.kind = .patch
	resource.set_url(url, source_specs)!
	spec.collect_resource_dependencies(resource)
	spec.add_patch(strip, url)
}

pub fn (mut spec SoftwareSpec) add_compiler_failure(compiler string, version string,
	exact_major_match bool) ! {
	selected := if version == '' { '9999' } else { version }
	spec.compiler_failure_values << SoftwareSpecCompilerFailure{
		compiler: compiler.trim_string_left(':')
		version: new_version(selected)!
		exact_major_match: exact_major_match
	}
}

pub fn (mut spec SoftwareSpec) add_dep_option(dependency Dependency) {
	for name in dependency.option_names() {
		if dependency.optional() && !spec.option_defined('with-${name}') {
			spec.options_value.add(new_option('with-${name}', 'Build with ${name} support'))
		} else if dependency.recommended() && !spec.option_defined('without-${name}') {
			spec.options_value.add(new_option('without-${name}', 'Build without ${name} support'))
		}
	}
	spec.refresh_build()
}

pub fn software_spec_from_package_reference(reference api.PackageReference, selected_spec string,
	flags []string) !SoftwareSpec {
	if reference.kind != .formula {
		return error('SoftwareSpec API adapter requires a formula reference')
	}
	active := if selected_spec.trim_left(':') == '' {
		'stable'
	} else {
		selected_spec.trim_left(':')
	}
	mut spec := new_software_spec(flags)
	spec.set_owner(SoftwareSpecOwner{
		kind: .formula
		name: reference.name
		full_name: reference.full_name
		tap: reference.tap
	})
	if active == 'head' {
		if reference.head_version == '' {
			return error('${reference.full_name}: head spec is not available')
		}
		spec.set_version('HEAD')!
	} else {
		if reference.stable_version == '' {
			return error('${reference.full_name}: stable spec is not available')
		}
		if reference.source_url != '' {
			spec.set_url(reference.source_url, map[string]string{})!
		}
		spec.set_version(reference.stable_version)!
		if reference.source_checksum != '' {
			spec.sha256(reference.source_checksum)
		}
	}
	for name in reference.dependencies {
		spec.depends_on(name, []string{})
	}
	for name in reference.build_dependencies {
		spec.depends_on(name, [':build'])
	}
	for name in reference.test_dependencies {
		spec.depends_on(name, [':test'])
	}
	for name in reference.recommended_dependencies {
		spec.depends_on(name, [':recommended'])
	}
	for name in reference.optional_dependencies {
		spec.depends_on(name, [':optional'])
	}
	mut bottle := new_bottle_specification()
	bottle.rebuild_value = reference.bottle_rebuild
	bottle.tap = reference.tap
	bottle.has_tap = reference.tap != ''
	for tag, file in reference.bottle_files {
		bottle.sha256(tag, file.sha256, parse_bottle_cellar(file.cellar))!
	}
	spec.set_bottle_specification(bottle)
	return spec
}

const software_spec_boundary_separator = '\x1e'
const software_spec_dependency_separator = '\x1d'

fn software_spec_resource_kind(value string) ResourceKind {
	return match value {
		'local' { .local }
		'formula' { .formula }
		'bottle_manifest' { .bottle_manifest }
		'patch' { .patch }
		else { .resource }
	}
}

fn software_spec_dependency_tags(dependency Dependency) string {
	return dependency.tags.map(it.boundary_string()).join(',')
}
