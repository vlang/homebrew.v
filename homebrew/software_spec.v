module homebrew

import brew_runtime
import homebrew.api
import homebrew.download_strategy

// Translated from Homebrew/brew `software_spec.rb`.
// The original source is retained below until every stub has a typed V body.
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
	brew_runtime.find_executable(name) or { return true }
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

fn software_spec_string_map_boundary(values map[string]string) brew_runtime.Value {
	mut entries := map[string]brew_runtime.Value{}
	for key, value in values {
		entries[key] = brew_runtime.string_value(value)
	}
	return brew_runtime.map_value(entries)
}

fn software_spec_string_map_from_boundary(value brew_runtime.Value) map[string]string {
	mut entries := map[string]string{}
	for key, item in value.as_map() or { return entries } {
		entries[key] = item.as_string()
	}
	return entries
}

fn software_spec_resource_boundary(resource Resource) brew_runtime.Value {
	mut patch_values := []brew_runtime.Value{}
	for patch in resource.patches {
		patch_values << brew_runtime.structured_value('ResourcePatch', patch.source, {
			'strip':  patch.strip
			'source': patch.source
			'owner':  patch.owner_name
		})
	}
	return brew_runtime.Value{
		type_name: 'Resource'
		repr: resource.url() or { '' }
		attributes: {
			'name':                     resource.name
			'has_name':                 resource.has_name.str()
			'owner':                    resource.owner_name
			'has_owner':                resource.has_owner.str()
			'url':                      resource.url() or { '' }
			'has_url':                  resource.has_url.str()
			'version':                  resource.version_value.to_s()
			'has_version':              resource.has_version.str()
			'checksum':                 resource.checksum.hexdigest
			'has_checksum':             resource.has_checksum.str()
			'source_modified_time':     resource.source_modified_time.str()
			'has_source_modified_time': resource.has_source_modified_time.str()
			'insecure':                 resource.insecure.str()
			'kind':                     resource.kind.str()
			'using':                    resource.using() or { '' }
		}
		map_data: {
			'specs':   software_spec_string_map_boundary(resource.specs())
			'mirrors': brew_runtime.string_array_value(resource.mirrors)
			'patches': brew_runtime.array_value(patch_values)
		}
	}
}

fn software_spec_resource_kind(value string) ResourceKind {
	return match value {
		'local' { .local }
		'formula' { .formula }
		'bottle_manifest' { .bottle_manifest }
		'patch' { .patch }
		else { .resource }
	}
}

fn software_spec_resource_from_boundary(value brew_runtime.Value) Resource {
	mut resource := new_resource(value.attribute('name') or { '' })
	resource.has_name = (value.attribute('has_name') or { (resource.name != '').str() }) == 'true'
	resource.kind = software_spec_resource_kind(value.attribute('kind') or { 'resource' })
	resource.insecure = (value.attribute('insecure') or { 'false' }) == 'true'
	url := value.attribute('url') or { '' }
	if (value.attribute('has_url') or { (url != '').str() }) == 'true' && url != '' {
		mut specs := if stored := value.map_data['specs'] {
			software_spec_string_map_from_boundary(stored)
		} else {
			map[string]string{}
		}
		if using := value.attribute('using') {
			if using != '' {
				specs['using'] = using
			}
		}
		resource.set_url(url, specs) or { panic(err) }
	}
	version := value.attribute('version') or { '' }
	if (value.attribute('has_version') or { 'false' }) == 'true' {
		resource.set_version(version) or { panic(err) }
	}
	checksum := value.attribute('checksum') or { '' }
	if (value.attribute('has_checksum') or { (checksum != '').str() }) == 'true' {
		resource.sha256(checksum)
	}
	if mirrors := value.map_data['mirrors'] {
		for mirror in mirrors.as_string_array() or { []string{} } {
			resource.mirror(mirror)
		}
	}
	if patches := value.map_data['patches'] {
		for patch in patches.as_array() or { []brew_runtime.Value{} } {
			resource.patches << ResourcePatch{
				strip: patch.attribute('strip') or { '' }
				source: patch.attribute('source') or { patch.as_string() }
				owner_name: patch.attribute('owner') or { '' }
			}
		}
	}
	resource.source_modified_time = (value.attribute('source_modified_time') or { '0' }).i64()
	resource.has_source_modified_time = (value.attribute('has_source_modified_time') or {
		'false'
	}) == 'true'
	if (value.attribute('has_owner') or { 'false' }) == 'true' {
		resource.set_owner(value.attribute('owner') or { '' })
	}
	return resource
}

fn software_spec_dependency_value(dependency Dependency) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Dependency'
		repr: dependency.inspect()
		attributes: {
			'name':            dependency.name
			'tags':            software_spec_dependency_tags(dependency)
			'uses_from_macos': dependency.uses_from_macos.str()
		}
		map_data: {
			'macos_bounds': software_spec_string_map_boundary(dependency.macos_bounds)
		}
	}
}

fn software_spec_dependency_from_value(value brew_runtime.Value) Dependency {
	name := value.attribute('name') or { value.as_string() }
	tags_text := value.attribute('tags') or { '' }
	tags := if tags_text == '' { []string{} } else { tags_text.split(',') }
	if (value.attribute('uses_from_macos') or { 'false' }) == 'true' {
		bounds := if stored := value.map_data['macos_bounds'] {
			software_spec_string_map_from_boundary(stored)
		} else {
			map[string]string{}
		}
		return new_uses_from_macos_dependency(name, tags.map(dependency_tag(it)), bounds)
	}
	return new_dependency(name, tags)
}

fn software_spec_requirement_value(requirement SoftwareSpecRequirement) brew_runtime.Value {
	return brew_runtime.structured_value('Requirement', requirement.kind.str(), {
		'kind':       requirement.kind.str()
		'tags':       requirement.tags.join(software_spec_dependency_separator)
		'comparator': requirement.comparator
	})
}

fn software_spec_requirement_from_value(value brew_runtime.Value) SoftwareSpecRequirement {
	kind := match (value.attribute('kind') or { value.as_string() }).trim_string_left(':') {
		'macos' { SoftwareSpecRequirementKind.macos }
		'maximum_macos' { SoftwareSpecRequirementKind.maximum_macos }
		'linux' { SoftwareSpecRequirementKind.linux }
		'arch' { SoftwareSpecRequirementKind.arch }
		else { SoftwareSpecRequirementKind.xcode }
	}
	tags := value.attribute('tags') or { '' }
	return SoftwareSpecRequirement{
		kind: kind
		tags: if tags == '' { []string{} } else { tags.split(software_spec_dependency_separator) }
		comparator: value.attribute('comparator') or { '' }
	}
}

fn software_spec_bottle_boundary(bottle BottleSpecification) brew_runtime.Value {
	mut checksum_values := []brew_runtime.Value{}
	for symbol in bottle.collector.order {
		entry := bottle.collector.tag_specs[symbol] or { continue }
		checksum_values << brew_runtime.structured_value('BottleChecksum', entry.checksum.hexdigest, {
			'tag':    symbol
			'digest': entry.checksum.hexdigest
			'cellar': entry.cellar.str()
		})
	}
	return brew_runtime.Value{
		type_name: 'BottleSpecification'
		repr: bottle.checksums().str()
		attributes: {
			'tap':          bottle.tap
			'has_tap':      bottle.has_tap.str()
			'repository':   bottle.repository
			'rebuild':      bottle.rebuild_value.str()
			'root_url':     bottle.root_url_value
			'has_root_url': bottle.has_root_url.str()
			'tags':         bottle.collector.tags().map(it.symbol()).join(software_spec_boundary_separator)
		}
		map_data: {
			'checksums':      brew_runtime.array_value(checksum_values)
			'root_url_specs': software_spec_string_map_boundary(bottle.root_url_specs)
		}
	}
}

fn software_spec_bottle_from_boundary(value brew_runtime.Value) BottleSpecification {
	mut bottle := new_bottle_specification()
	bottle.tap = value.attribute('tap') or { '' }
	bottle.has_tap = (value.attribute('has_tap') or { (bottle.tap != '').str() }) == 'true'
	bottle.repository = value.attribute('repository') or { bottle.repository }
	bottle.rebuild_value = (value.attribute('rebuild') or { '0' }).int()
	root_url := value.attribute('root_url') or { '' }
	if (value.attribute('has_root_url') or { (root_url != '').str() }) == 'true' {
		root_specs := if stored := value.map_data['root_url_specs'] {
			software_spec_string_map_from_boundary(stored)
		} else {
			map[string]string{}
		}
		bottle.set_root_url(root_url, root_specs)
	}
	if checksums := value.map_data['checksums'] {
		for entry in checksums.as_array() or { []brew_runtime.Value{} } {
			bottle.sha256(entry.attribute('tag') or { '' }, entry.attribute('digest') or {
				entry.as_string()
			}, parse_bottle_cellar(entry.attribute('cellar') or { '' })) or { panic(err) }
		}
	} else {
		for encoded in (value.attribute('checksums') or { '' }).split(software_spec_boundary_separator) {
			parts := encoded.split(software_spec_dependency_separator)
			if parts.len >= 2 {
				bottle.sha256(parts[0], parts[1], if parts.len > 2 {
					parse_bottle_cellar(parts[2])
				} else {
					none
				}) or { panic(err) }
			}
		}
	}
	return bottle
}

pub fn software_spec_boundary_value(spec SoftwareSpec) brew_runtime.Value {
	mut resource_values := map[string]brew_runtime.Value{}
	for name, resource in spec.resources_value {
		resource_values[name] = software_spec_resource_boundary(resource)
	}
	option_values := spec.options_value.to_array().map(brew_runtime.structured_value('Option', it.flag, {
		'name':        it.name
		'description': it.description
	}))
	deprecated_flag_values := spec.deprecated_flag_values.map(brew_runtime.structured_value('DeprecatedOption', '${it.old}=>${it.current}', {
		'old':     it.old
		'current': it.current
	}))
	deprecated_option_values := spec.deprecated_option_values.map(brew_runtime.structured_value('DeprecatedOption', '${it.old}=>${it.current}', {
		'old':     it.old
		'current': it.current
	}))
	compiler_failure_values := spec.compiler_failure_values.map(brew_runtime.structured_value('CompilerFailure', '${it.compiler} ${it.version}', {
		'compiler':          it.compiler
		'version':           it.version.to_s()
		'exact_major_match': it.exact_major_match.str()
	}))
	version := spec.version() or { null_version() }
	checksum := spec.checksum() or { Checksum{} }
	return brew_runtime.Value{
		type_name: 'SoftwareSpec'
		repr: version.to_s()
		attributes: {
			'name':                         spec.name_value
			'full_name':                    spec.full_name_value
			'owner_kind':                   spec.owner_value.kind.str()
			'owner_tap':                    spec.owner_value.tap
			'owner_force_bottle':           spec.owner_value.force_bottle.str()
			'has_owner':                    spec.has_owner.str()
			'url':                          spec.url() or { '' }
			'version':                      version.to_s()
			'checksum':                     checksum.hexdigest
			'flags':                        spec.flags.join(software_spec_boundary_separator)
			'options':                      spec.options().as_flags().join(software_spec_boundary_separator)
			'depends_on_macos_bare_top':    spec.depends_on_macos_bare_set_top_level.str()
			'depends_on_macos_version_top': spec.depends_on_macos_version_set_top_level.str()
			'depends_on_maximum_macos_top': spec.depends_on_maximum_macos_set_top_level.str()
			'depends_on_macos_block':       spec.depends_on_macos_set_in_block.str()
			'depends_on_linux_top':         spec.depends_on_linux_set_top_level.str()
			'bottle_tags':                  spec.bottle_specification_value.collector.tags().map(it.symbol()).join(software_spec_boundary_separator)
			'frozen':                       spec.frozen.str()
		}
		map_data: {
			'resource':           software_spec_resource_boundary(spec.resource_value)
			'resources':          brew_runtime.map_value(resource_values)
			'dependencies':       brew_runtime.array_value(spec.dependency_values.map(software_spec_dependency_value(it)))
			'requirements':       brew_runtime.array_value(spec.requirement_values.map(software_spec_requirement_value(it)))
			'bottle':             software_spec_bottle_boundary(spec.bottle_specification_value)
			'patches':            brew_runtime.array_value(spec.patch_values.map(brew_runtime.structured_value('Patch', it.source, {
				'strip':  it.strip
				'source': it.source
				'owner':  it.owner_name
			})))
			'options':            brew_runtime.array_value(option_values)
			'deprecated_flags':   brew_runtime.array_value(deprecated_flag_values)
			'deprecated_options': brew_runtime.array_value(deprecated_option_values)
			'compiler_failures':  brew_runtime.array_value(compiler_failure_values)
		}
	}
}

pub fn software_spec_from_boundary(value brew_runtime.Value) SoftwareSpec {
	flags_text := value.attribute('flags') or { '' }
	mut spec := new_software_spec(if flags_text == '' {
		[]string{}
	} else {
		flags_text.split(software_spec_boundary_separator)
	})
	name := value.attribute('name') or { '' }
	full_name := value.attribute('full_name') or { name }
	if (value.attribute('has_owner') or { 'false' }) == 'true' {
		spec.set_owner(SoftwareSpecOwner{
			kind: if (value.attribute('owner_kind') or { 'formula' }) == 'cask' {
				.cask} else {
				.formula}
			name: name
			full_name: full_name
			tap: value.attribute('owner_tap') or { '' }
			force_bottle: (value.attribute('owner_force_bottle') or { 'false' }) == 'true'
		})
	}
	if resource := value.map_data['resource'] {
		spec.resource_value = software_spec_resource_from_boundary(resource)
	} else {
		if url := value.attribute('url') {
			if url != '' {
				spec.resource_value.set_url(url, map[string]string{}) or { panic(err) }
			}
		}
		if version := value.attribute('version') {
			if version != '' {
				spec.set_version(version) or { panic(err) }
			}
		}
		if checksum := value.attribute('checksum') {
			if checksum != '' {
				spec.sha256(checksum)
			}
		}
	}
	if resources := value.map_data['resources'] {
		for resource_name, resource in resources.as_map() or { map[string]brew_runtime.Value{} } {
			spec.resources_value[resource_name] = software_spec_resource_from_boundary(resource)
		}
	}
	if dependencies := value.map_data['dependencies'] {
		for dependency in dependencies.as_array() or { []brew_runtime.Value{} } {
			spec.dependency_values << software_spec_dependency_from_value(dependency)
		}
	}
	if requirements := value.map_data['requirements'] {
		for requirement in requirements.as_array() or { []brew_runtime.Value{} } {
			spec.requirement_values << software_spec_requirement_from_value(requirement)
		}
	}
	if bottle := value.map_data['bottle'] {
		spec.bottle_specification_value = software_spec_bottle_from_boundary(bottle)
	}
	if patches := value.map_data['patches'] {
		for patch in patches.as_array() or { []brew_runtime.Value{} } {
			spec.patch_values << ResourcePatch{
				strip: patch.attribute('strip') or { '' }
				source: patch.attribute('source') or { patch.as_string() }
				owner_name: patch.attribute('owner') or { '' }
			}
		}
	}
	if options := value.map_data['options'] {
		spec.options_value = new_options()
		for option in options.as_array() or { []brew_runtime.Value{} } {
			spec.options_value.add(new_option(option.attribute('name') or { option.as_string() }, option.attribute('description') or { '' }))
		}
	}
	if deprecated_flags := value.map_data['deprecated_flags'] {
		for option in deprecated_flags.as_array() or { []brew_runtime.Value{} } {
			spec.deprecated_flag_values << new_deprecated_option(option.attribute('old') or { '' }, option.attribute('current') or { '' })
		}
	}
	if deprecated_options := value.map_data['deprecated_options'] {
		for option in deprecated_options.as_array() or { []brew_runtime.Value{} } {
			spec.deprecated_option_values << new_deprecated_option(option.attribute('old') or {
				''
			}, option.attribute('current') or { '' })
		}
	}
	if compiler_failures := value.map_data['compiler_failures'] {
		for failure in compiler_failures.as_array() or { []brew_runtime.Value{} } {
			spec.add_compiler_failure(failure.attribute('compiler') or { '' }, failure.attribute('version') or { '' }, (failure.attribute('exact_major_match') or {
				'false'
			}) == 'true') or { panic(err) }
		}
	}
	spec.depends_on_macos_bare_set_top_level = (value.attribute('depends_on_macos_bare_top') or {
		'false'
	}) == 'true'
	spec.depends_on_macos_version_set_top_level = (value.attribute('depends_on_macos_version_top') or {
		'false'
	}) == 'true'
	spec.depends_on_maximum_macos_set_top_level = (value.attribute('depends_on_maximum_macos_top') or {
		'false'
	}) == 'true'
	spec.depends_on_macos_set_in_block = (value.attribute('depends_on_macos_block') or {
		'false'
	}) == 'true'
	spec.depends_on_linux_set_top_level = (value.attribute('depends_on_linux_top') or {
		'false'
	}) == 'true'
	spec.refresh_build()
	if (value.attribute('frozen') or { 'false' }) == 'true' {
		spec.freeze()
	}
	return spec
}

fn software_spec_receiver(args []brew_runtime.Value, method string) SoftwareSpec {
	if args.len == 0 || args[0].type_name != 'SoftwareSpec' {
		panic('SoftwareSpec#${method} requires a receiver')
	}
	return software_spec_from_boundary(args[0])
}

fn software_spec_optional_string(value ?string) brew_runtime.Value {
	if text := value {
		return brew_runtime.string_value(text)
	}
	return brew_runtime.object_value('NilClass', 'nil')
}

fn software_spec_dependency_boundary(dependencies []Dependency) brew_runtime.Value {
	return brew_runtime.array_value(dependencies.map(software_spec_dependency_value(it)))
}

fn software_spec_dependency_tags(dependency Dependency) string {
	return dependency.tags.map(it.boundary_string()).join(',')
}

fn software_spec_tags_from_boundary(value brew_runtime.Value) []string {
	if value.type_name == 'Array' {
		mut tags := []string{}
		for item in value.as_array() or { panic(err) } {
			tags << software_spec_tags_from_boundary(item)
		}
		return tags
	}
	if value.type_name == 'NilClass' {
		return []string{}
	}
	text := value.as_string()
	return [
		if value.type_name == 'Symbol' && !text.starts_with(':') { ':${text}' } else { text },
	]
}

// Ruby attr_reader `attr_reader :name` at line 24.
pub fn ruby_software_spec_l24_d1_name(args ...brew_runtime.Value) brew_runtime.Value {
	return software_spec_optional_string(software_spec_receiver(args, 'name').name())
}

// Ruby attr_reader `attr_reader :full_name` at line 27.
pub fn ruby_software_spec_l27_d2_full_name(args ...brew_runtime.Value) brew_runtime.Value {
	return software_spec_optional_string(software_spec_receiver(args, 'full_name').full_name())
}

// Ruby attr_reader `attr_reader :owner` at line 30.
pub fn ruby_software_spec_l30_d3_owner(args ...brew_runtime.Value) brew_runtime.Value {
	spec := software_spec_receiver(args, 'owner')
	owner := spec.owner() or { return brew_runtime.object_value('NilClass', 'nil') }
	return brew_runtime.structured_value(if owner.kind == .formula { 'Formula' } else { 'Cask' }, owner.full_name, {
		'name':         owner.name
		'full_name':    owner.full_name
		'tap':          owner.tap
		'force_bottle': owner.force_bottle.str()
	})
}

// Ruby attr_reader `attr_reader :build` at line 33.
pub fn ruby_software_spec_l33_d4_build(args ...brew_runtime.Value) brew_runtime.Value {
	build := software_spec_receiver(args, 'build').build()
	return brew_runtime.structured_value('BuildOptions', build.used_options().inspect(), {
		'args':    build.args.as_flags().join(software_spec_boundary_separator)
		'options': build.options.as_flags().join(software_spec_boundary_separator)
	})
}

// Ruby attr_reader `attr_reader :resources` at line 36.
pub fn ruby_software_spec_l36_d5_resources(args ...brew_runtime.Value) brew_runtime.Value {
	resources := software_spec_receiver(args, 'resources').resources()
	mut values := map[string]brew_runtime.Value{}
	for name, resource in resources {
		values[name] = software_spec_resource_boundary(resource)
	}
	return brew_runtime.map_value(values)
}

// Ruby attr_reader `attr_reader :patches` at line 39.
pub fn ruby_software_spec_l39_d6_patches(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.array_value(software_spec_receiver(args, 'patches').patches().map(brew_runtime.structured_value('Patch', it.source, {
		'strip':  it.strip
		'source': it.source
		'owner':  it.owner_name
	})))
}

// Ruby attr_reader `attr_reader :options` at line 42.
pub fn ruby_software_spec_l42_d7_options(args ...brew_runtime.Value) brew_runtime.Value {
	return formula_options_boundary(software_spec_receiver(args, 'options').options())
}

// Ruby attr_reader `attr_reader :deprecated_flags` at line 45.
pub fn ruby_software_spec_l45_d8_deprecated_flags(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.array_value(software_spec_receiver(args, 'deprecated_flags').deprecated_flags().map(brew_runtime.structured_value('DeprecatedOption', '${it.old}=>${it.current}', {
		'old':     it.old
		'current': it.current
	})))
}

// Ruby attr_reader `attr_reader :deprecated_options` at line 48.
pub fn ruby_software_spec_l48_d9_deprecated_options(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.array_value(software_spec_receiver(args, 'deprecated_options').deprecated_options().map(brew_runtime.structured_value('DeprecatedOption', '${it.old}=>${it.current}', {
		'old':     it.old
		'current': it.current
	})))
}

// Ruby attr_reader `attr_reader :dependency_collector` at line 51.
pub fn ruby_software_spec_l51_d10_dependency_collector(args ...brew_runtime.Value) brew_runtime.Value {
	spec := software_spec_receiver(args, 'dependency_collector')
	return brew_runtime.structured_value('DependencyCollector', spec.declared_deps().str(), {
		'deps':         spec.declared_deps().map(it.name).join(software_spec_boundary_separator)
		'requirements': spec.requirements().map(it.kind.str()).join(software_spec_boundary_separator)
	})
}

// Ruby attr_reader `attr_reader :bottle_specification` at line 54.
pub fn ruby_software_spec_l54_d11_bottle_specification(args ...brew_runtime.Value) brew_runtime.Value {
	bottle := software_spec_receiver(args, 'bottle_specification').bottle_specification()
	return software_spec_bottle_boundary(bottle)
}

// Ruby attr_reader `attr_reader :compiler_failures` at line 57.
pub fn ruby_software_spec_l57_d12_compiler_failures(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.array_value(software_spec_receiver(args, 'compiler_failures').compiler_failures().map(brew_runtime.structured_value('CompilerFailure', '${it.compiler} ${it.version}', {
		'type':    it.compiler
		'version': it.version.to_s()
	})))
}

// Ruby attr_reader `attr_reader :depends_on_macos_set_in_block` at line 60.
pub fn ruby_software_spec_l60_d13_depends_on_macos_set_in_block(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(software_spec_receiver(args, 'depends_on_macos_set_in_block').depends_on_macos_set_in_block)
}

// Ruby def_delegators `def_delegators :@resource, :stage, :fetch, :verify_download_integrity, :source_modified_time, :cached_download, :clear_cache, :checksum, :mirrors, :specs, :using, :version, :mirror, :downloader, :download_queue_name, :download_queue_type` at line 62.
pub fn ruby_software_spec_l62_d14_stage(args ...brew_runtime.Value) brew_runtime.Value {
	mut spec := software_spec_receiver(args, 'stage')
	target := if args.len > 1 { args[1].as_string() } else { '' }
	return brew_runtime.object_value('Pathname', spec.stage(target, false) or { panic(err) })
}

// Ruby def_delegators `def_delegators :@resource, :stage, :fetch, :verify_download_integrity, :source_modified_time, :cached_download, :clear_cache, :checksum, :mirrors, :specs, :using, :version, :mirror, :downloader, :download_queue_name, :download_queue_type` at line 62.
pub fn ruby_software_spec_l62_d15_fetch(args ...brew_runtime.Value) brew_runtime.Value {
	mut spec := software_spec_receiver(args, 'fetch')
	return brew_runtime.object_value('Pathname', spec.fetch(true, none, false, false) or {
		panic(err)
	})
}

// Ruby def_delegators `def_delegators :@resource, :stage, :fetch, :verify_download_integrity, :source_modified_time, :cached_download, :clear_cache, :checksum, :mirrors, :specs, :using, :version, :mirror, :downloader, :download_queue_name, :download_queue_type` at line 62.
pub fn ruby_software_spec_l62_d16_verify_download_integrity(args ...brew_runtime.Value) brew_runtime.Value {
	mut spec := software_spec_receiver(args, 'verify_download_integrity')
	if args.len < 2 { panic('SoftwareSpec#verify_download_integrity requires a filename') }
	spec.verify_download_integrity(args[1].as_string()) or { panic(err) }
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby def_delegators `def_delegators :@resource, :stage, :fetch, :verify_download_integrity, :source_modified_time, :cached_download, :clear_cache, :checksum, :mirrors, :specs, :using, :version, :mirror, :downloader, :download_queue_name, :download_queue_type` at line 62.
pub fn ruby_software_spec_l62_d17_source_modified_time(args ...brew_runtime.Value) brew_runtime.Value {
	spec := software_spec_receiver(args, 'source_modified_time')
	if modified := spec.source_modified_time() {
		return brew_runtime.int_value(modified)
	}
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby def_delegators `def_delegators :@resource, :stage, :fetch, :verify_download_integrity, :source_modified_time, :cached_download, :clear_cache, :checksum, :mirrors, :specs, :using, :version, :mirror, :downloader, :download_queue_name, :download_queue_type` at line 62.
pub fn ruby_software_spec_l62_d18_cached_download(args ...brew_runtime.Value) brew_runtime.Value {
	mut spec := software_spec_receiver(args, 'cached_download')
	return brew_runtime.object_value('Pathname', spec.cached_download() or { panic(err) })
}

// Ruby def_delegators `def_delegators :@resource, :stage, :fetch, :verify_download_integrity, :source_modified_time, :cached_download, :clear_cache, :checksum, :mirrors, :specs, :using, :version, :mirror, :downloader, :download_queue_name, :download_queue_type` at line 62.
pub fn ruby_software_spec_l62_d19_clear_cache(args ...brew_runtime.Value) brew_runtime.Value {
	mut spec := software_spec_receiver(args, 'clear_cache')
	spec.clear_cache() or { panic(err) }
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby def_delegators `def_delegators :@resource, :stage, :fetch, :verify_download_integrity, :source_modified_time, :cached_download, :clear_cache, :checksum, :mirrors, :specs, :using, :version, :mirror, :downloader, :download_queue_name, :download_queue_type` at line 62.
pub fn ruby_software_spec_l62_d20_checksum(args ...brew_runtime.Value) brew_runtime.Value {
	checksum := software_spec_receiver(args, 'checksum').checksum() or {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return brew_runtime.object_value('Checksum', checksum.hexdigest)
}

// Ruby def_delegators `def_delegators :@resource, :stage, :fetch, :verify_download_integrity, :source_modified_time, :cached_download, :clear_cache, :checksum, :mirrors, :specs, :using, :version, :mirror, :downloader, :download_queue_name, :download_queue_type` at line 62.
pub fn ruby_software_spec_l62_d21_mirrors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_array_value(software_spec_receiver(args, 'mirrors').mirrors())
}

// Ruby def_delegators `def_delegators :@resource, :stage, :fetch, :verify_download_integrity, :source_modified_time, :cached_download, :clear_cache, :checksum, :mirrors, :specs, :using, :version, :mirror, :downloader, :download_queue_name, :download_queue_type` at line 62.
pub fn ruby_software_spec_l62_d22_specs(args ...brew_runtime.Value) brew_runtime.Value {
	mut values := map[string]brew_runtime.Value{}
	for key, value in software_spec_receiver(args, 'specs').source_specs() {
		values[key] = brew_runtime.string_value(value)
	}
	return brew_runtime.map_value(values)
}

// Ruby def_delegators `def_delegators :@resource, :stage, :fetch, :verify_download_integrity, :source_modified_time, :cached_download, :clear_cache, :checksum, :mirrors, :specs, :using, :version, :mirror, :downloader, :download_queue_name, :download_queue_type` at line 62.
pub fn ruby_software_spec_l62_d23_using(args ...brew_runtime.Value) brew_runtime.Value {
	return software_spec_optional_string(software_spec_receiver(args, 'using').using())
}

// Ruby def_delegators `def_delegators :@resource, :stage, :fetch, :verify_download_integrity, :source_modified_time, :cached_download, :clear_cache, :checksum, :mirrors, :specs, :using, :version, :mirror, :downloader, :download_queue_name, :download_queue_type` at line 62.
pub fn ruby_software_spec_l62_d24_version(args ...brew_runtime.Value) brew_runtime.Value {
	version := software_spec_receiver(args, 'version').version() or {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return brew_runtime.object_value('Version', version.to_s())
}

// Ruby def_delegators `def_delegators :@resource, :stage, :fetch, :verify_download_integrity, :source_modified_time, :cached_download, :clear_cache, :checksum, :mirrors, :specs, :using, :version, :mirror, :downloader, :download_queue_name, :download_queue_type` at line 62.
pub fn ruby_software_spec_l62_d25_mirror(args ...brew_runtime.Value) brew_runtime.Value {
	mut spec := software_spec_receiver(args, 'mirror')
	if args.len < 2 { panic('SoftwareSpec#mirror requires a URL') }
	return brew_runtime.string_array_value(spec.mirror(args[1].as_string()))
}

// Ruby def_delegators `def_delegators :@resource, :stage, :fetch, :verify_download_integrity, :source_modified_time, :cached_download, :clear_cache, :checksum, :mirrors, :specs, :using, :version, :mirror, :downloader, :download_queue_name, :download_queue_type` at line 62.
pub fn ruby_software_spec_l62_d26_downloader(args ...brew_runtime.Value) brew_runtime.Value {
	mut spec := software_spec_receiver(args, 'downloader')
	downloader := spec.downloader() or { panic(err) }
	return brew_runtime.structured_value('DownloadStrategy', downloader.file.base.url, {
		'url': downloader.file.base.url
	})
}

// Ruby def_delegators `def_delegators :@resource, :stage, :fetch, :verify_download_integrity, :source_modified_time, :cached_download, :clear_cache, :checksum, :mirrors, :specs, :using, :version, :mirror, :downloader, :download_queue_name, :download_queue_type` at line 62.
pub fn ruby_software_spec_l62_d27_download_queue_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(software_spec_receiver(args, 'download_queue_name').download_queue_name() or {
		panic(err)
	})
}

// Ruby def_delegators `def_delegators :@resource, :stage, :fetch, :verify_download_integrity, :source_modified_time, :cached_download, :clear_cache, :checksum, :mirrors, :specs, :using, :version, :mirror, :downloader, :download_queue_name, :download_queue_type` at line 62.
pub fn ruby_software_spec_l62_d28_download_queue_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(software_spec_receiver(args, 'download_queue_type').download_queue_type())
}

// Ruby def_delegators `def_delegators :@resource, :sha256` at line 66.
pub fn ruby_software_spec_l66_d29_sha256(args ...brew_runtime.Value) brew_runtime.Value {
	mut spec := software_spec_receiver(args, 'sha256')
	if args.len < 2 { panic('SoftwareSpec#sha256 requires a digest') }
	return brew_runtime.object_value('Checksum', spec.sha256(args[1].as_string()).hexdigest)
}

// Ruby method `initialize(flags: [])` at line 69.
pub fn ruby_software_spec_l69_d30_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	flags := if args.len > 0 && args[0].type_name == 'Array' {
		args[0].as_string_array() or { []string{} }
	} else {
		[]string{}
	}
	return software_spec_boundary_value(new_software_spec(flags))
}

// Ruby method `initialize_dup(other)` at line 96.
pub fn ruby_software_spec_l96_d31_initialize_dup(args ...brew_runtime.Value) brew_runtime.Value {
	return software_spec_boundary_value(software_spec_receiver(args, 'initialize_dup').duplicate())
}

// Ruby method `freeze` at line 112.
pub fn ruby_software_spec_l112_d32_freeze(args ...brew_runtime.Value) brew_runtime.Value {
	mut spec := software_spec_receiver(args, 'freeze')
	spec.freeze()
	return software_spec_boundary_value(spec)
}

// Ruby method `owner=(owner)` at line 128.
pub fn ruby_software_spec_l128_d33_owner(args ...brew_runtime.Value) brew_runtime.Value {
	mut spec := software_spec_receiver(args, 'owner=')
	if args.len < 2 { panic('SoftwareSpec#owner= requires an owner') }
	owner := args[1]
	spec.set_owner(SoftwareSpecOwner{
		kind: if owner.type_name == 'Cask' || owner.type_name == 'Cask::Cask' {
			.cask} else {
			.formula}
		name: owner.attribute('name') or { owner.as_string() }
		full_name: owner.attribute('full_name') or { owner.as_string() }
		tap: owner.attribute('tap') or { '' }
		force_bottle: (owner.attribute('force_bottle') or { 'false' }) == 'true'
	})
	return software_spec_boundary_value(spec)
}

// Ruby method `url(val = nil, specs = {})` at line 145.
pub fn ruby_software_spec_l145_d34_url(args ...brew_runtime.Value) brew_runtime.Value {
	mut spec := software_spec_receiver(args, 'url')
	if args.len > 1 && args[1].type_name != 'NilClass' {
		mut source_specs := map[string]string{}
		if args.len > 2 && args[2].type_name == 'Hash' {
			for key, value in args[2].as_map() or { panic(err) } {
				source_specs[key] = value.as_string()
			}
		}
		spec.set_url(args[1].as_string(), source_specs) or { panic(err) }
		return brew_runtime.structured_value('SoftwareSpecUrlResult', args[1].as_string(), software_spec_boundary_value(spec).attributes)
	}
	return software_spec_optional_string(spec.url())
}

// Ruby method `bottle_defined?` at line 154.
pub fn ruby_software_spec_l154_d35_bottle_defined(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(software_spec_receiver(args, 'bottle_defined?').bottle_defined())
}

// Ruby method `bottle_tag?(tag = nil)` at line 159.
pub fn ruby_software_spec_l159_d36_bottle_tag(args ...brew_runtime.Value) brew_runtime.Value {
	spec := software_spec_receiver(args, 'bottle_tag?')
	tag := if args.len > 1 && args[1].type_name != 'NilClass' {
		bottle_tag_from_symbol(args[1].as_string()) or { panic(err) }
	} else {
		current_bottle_tag()
	}
	return brew_runtime.bool_value(spec.bottle_tag(tag))
}

// Ruby method `bottled?(tag = nil)` at line 164.
pub fn ruby_software_spec_l164_d37_bottled(args ...brew_runtime.Value) brew_runtime.Value {
	spec := software_spec_receiver(args, 'bottled?')
	if args.len > 1 && args[1].type_name != 'NilClass' {
		tag := bottle_tag_from_symbol(args[1].as_string()) or { panic(err) }
		return brew_runtime.bool_value(spec.bottled(tag))
	}
	return brew_runtime.bool_value(spec.bottled(none))
}

// Ruby method `bottle(&block)` at line 177.
pub fn ruby_software_spec_l177_d38_bottle(args ...brew_runtime.Value) brew_runtime.Value {
	mut spec := software_spec_receiver(args, 'bottle')
	if args.len > 1 && args[1].type_name == 'BottleSpecification' {
		spec.set_bottle_specification(software_spec_bottle_from_boundary(args[1]))
	}
	return software_spec_boundary_value(spec)
}

// Ruby method `resource_defined?(name)` at line 182.
pub fn ruby_software_spec_l182_d39_resource_defined(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('SoftwareSpec#resource_defined? requires a name') }
	return brew_runtime.bool_value(software_spec_receiver(args, 'resource_defined?').resource_defined(args[1].as_string()))
}

// Ruby method `resource(name = T.unsafe(nil), klass = Resource, &block)` at line 190.
pub fn ruby_software_spec_l190_d40_resource(args ...brew_runtime.Value) brew_runtime.Value {
	mut spec := software_spec_receiver(args, 'resource')
	if args.len == 1 || args[1].type_name == 'NilClass' {
		resource := spec.resource(none) or { panic(err) }
		return software_spec_resource_boundary(resource)
	}
	name := args[1].as_string()
	if args.len > 2 {
		mut resource := if args[2].type_name == 'Resource' {
			software_spec_resource_from_boundary(args[2])
		} else {
			mut value := new_resource(name)
			url := args[2].attribute('url') or { args[2].as_string() }
			if url != '' {
				value.set_url(url, map[string]string{}) or { panic(err) }
			}
			value
		}
		spec.define_resource(name, mut resource) or { panic(err) }
		return software_spec_boundary_value(spec)
	}
	resource := spec.resource(name) or { panic(err) }
	return software_spec_resource_boundary(resource)
}

// Ruby method `option_defined?(name)` at line 209.
pub fn ruby_software_spec_l209_d41_option_defined(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('SoftwareSpec#option_defined? requires a name') }
	return brew_runtime.bool_value(software_spec_receiver(args, 'option_defined?').option_defined(args[1].as_string()))
}

// Ruby method `option(name, description = "")` at line 214.
pub fn ruby_software_spec_l214_d42_option(args ...brew_runtime.Value) brew_runtime.Value {
	mut spec := software_spec_receiver(args, 'option')
	if args.len < 2 { panic('SoftwareSpec#option requires a name') }
	spec.add_option(args[1].as_string(), if args.len > 2 { args[2].as_string() } else { '' }) or {
		panic(err)
	}
	return software_spec_boundary_value(spec)
}

// Ruby method `deprecated_option(hash)` at line 223.
pub fn ruby_software_spec_l223_d43_deprecated_option(args ...brew_runtime.Value) brew_runtime.Value {
	mut spec := software_spec_receiver(args, 'deprecated_option')
	if args.len < 2 || args[1].type_name != 'Hash' {
		panic('SoftwareSpec#deprecated_option requires a hash')
	}
	values := args[1].as_map() or { panic(err) }
	if values.len == 0 { panic('deprecated_option hash must not be empty') }
	for old, current in values {
		new_values := if current.type_name == 'Array' {
			current.as_string_array() or { panic(err) }
		} else {
			[current.as_string()]
		}
		spec.add_deprecated_options([old], new_values) or { panic(err) }
	}
	return software_spec_boundary_value(spec)
}

// Ruby method `depends_on(spec = nil, set_in_block: false, **spec_kwargs)` at line 254.
pub fn ruby_software_spec_l254_d44_depends_on(args ...brew_runtime.Value) brew_runtime.Value {
	mut spec := software_spec_receiver(args, 'depends_on')
	if args.len < 2 {
		return software_spec_boundary_value(spec)
	}
	value := args[1]
	if value.type_name == 'Hash' {
		entries := value.as_map() or { panic(err) }
		for name, tags_value in entries {
			if name in ['macos', 'maximum_macos', 'linux', 'arch', 'xcode'] {
				kind := match name {
					'macos' { SoftwareSpecRequirementKind.macos }
					'maximum_macos' { SoftwareSpecRequirementKind.maximum_macos }
					'linux' { SoftwareSpecRequirementKind.linux }
					'arch' { SoftwareSpecRequirementKind.arch }
					else { SoftwareSpecRequirementKind.xcode }
				}
				spec.add_requirement(SoftwareSpecRequirement{
					kind: kind
					tags: [tags_value.as_string()]
					comparator: if kind == .maximum_macos { '<=' } else { '>=' }
				}, false) or { panic(err) }
				continue
			}
			tags := software_spec_tags_from_boundary(tags_value)
			spec.depends_on(name, tags)
		}
	} else if value.type_name == 'Dependency' {
		name := value.attribute('name') or { value.as_string() }
		tags_text := value.attribute('tags') or { '' }
		spec.depends_on(name, if tags_text == '' { []string{} } else { tags_text.split(',') })
	} else if value.type_name == 'Symbol' && value.as_string() in ['macos', 'linux'] {
		spec.add_requirement(SoftwareSpecRequirement{
			kind: if value.as_string() == 'macos' { .macos } else { .linux }
		}, false) or { panic(err) }
	} else {
		tags := if args.len > 2 {
			software_spec_tags_from_boundary(args[2])
		} else {
			[]string{}
		}
		spec.depends_on(value.as_string(), tags)
	}
	return software_spec_boundary_value(spec)
}

// Ruby method `depends_on_macos_set_top_level?` at line 262.
pub fn ruby_software_spec_l262_d45_depends_on_macos_set_top_level(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(software_spec_receiver(args, 'depends_on_macos_set_top_level?').depends_on_macos_set_top_level())
}

// Ruby method `depends_on_linux_set_top_level?` at line 269.
pub fn ruby_software_spec_l269_d46_depends_on_linux_set_top_level(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(software_spec_receiver(args, 'depends_on_linux_set_top_level?').depends_on_linux_set_top_level())
}

// Ruby method `record_os_requirement(dep, set_in_block:)` at line 274.
pub fn ruby_software_spec_l274_d47_record_os_requirement(args ...brew_runtime.Value) brew_runtime.Value {
	mut spec := software_spec_receiver(args, 'record_os_requirement')
	if args.len < 2 {
		return software_spec_boundary_value(spec)
	}
	kind_text := args[1].attribute('kind') or { args[1].as_string() }
	kind := match kind_text.trim_string_left(':') {
		'macos' { SoftwareSpecRequirementKind.macos }
		'maximum_macos' { SoftwareSpecRequirementKind.maximum_macos }
		'linux' { SoftwareSpecRequirementKind.linux }
		'arch' { SoftwareSpecRequirementKind.arch }
		else { SoftwareSpecRequirementKind.xcode }
	}
	tags_text := args[1].attribute('tags') or { '' }
	spec.record_os_requirement(SoftwareSpecRequirement{
		kind: kind
		tags: if tags_text == '' { []string{} } else { tags_text.split(',') }
		comparator: args[1].attribute('comparator') or { '' }
	}, args.len > 2 && (args[2].as_bool() or { false })) or { panic(err) }
	return software_spec_boundary_value(spec)
}

// Ruby method `uses_from_macos(dep, bounds = {})` at line 339.
pub fn ruby_software_spec_l339_d48_uses_from_macos(args ...brew_runtime.Value) brew_runtime.Value {
	mut spec := software_spec_receiver(args, 'uses_from_macos')
	if args.len < 2 { panic('SoftwareSpec#uses_from_macos requires a dependency') }
	mut name := args[1].attribute('name') or { args[1].as_string() }
	mut tags := []string{}
	mut bounds := map[string]string{}
	if args[1].type_name == 'Hash' {
		mut found_dependency := false
		for key, value in args[1].as_map() or { panic(err) } {
			if key == 'since' {
				bounds[key] = value.as_string()
			} else if !found_dependency {
				name = key
				tags = software_spec_tags_from_boundary(value)
				found_dependency = true
			}
		}
		if !found_dependency {
			panic('SoftwareSpec#uses_from_macos requires a dependency')
		}
	} else if tags_text := args[1].attribute('tags') {
		tags = if tags_text == '' { []string{} } else { tags_text.split(',') }
	} else if args.len > 2 && args[2].type_name != 'Hash' {
		tags = software_spec_tags_from_boundary(args[2])
	}
	if args.len > 2 && args[2].type_name == 'Hash' {
		for key, value in args[2].as_map() or { panic(err) } {
			bounds[key] = value.as_string()
		}
	}
	spec.uses_from_macos(name, tags, bounds)
	return software_spec_boundary_value(spec)
}

// Ruby method `deps` at line 354.
pub fn ruby_software_spec_l354_d49_deps(args ...brew_runtime.Value) brew_runtime.Value {
	return software_spec_dependency_boundary(software_spec_receiver(args, 'deps').deps())
}

// Ruby method `declared_deps` at line 359.
pub fn ruby_software_spec_l359_d50_declared_deps(args ...brew_runtime.Value) brew_runtime.Value {
	return software_spec_dependency_boundary(software_spec_receiver(args, 'declared_deps').declared_deps())
}

// Ruby method `recursive_dependencies` at line 364.
pub fn ruby_software_spec_l364_d51_recursive_dependencies(args ...brew_runtime.Value) brew_runtime.Value {
	spec := software_spec_receiver(args, 'recursive_dependencies')
	return software_spec_dependency_boundary(spec.recursive_dependencies(default_formulary_lookup_config()) or {
		panic(err)
	})
}

// Ruby method `requirements` at line 382.
pub fn ruby_software_spec_l382_d52_requirements(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.array_value(software_spec_receiver(args, 'requirements').requirements().map(software_spec_requirement_value(it)))
}

// Ruby method `recursive_requirements` at line 387.
pub fn ruby_software_spec_l387_d53_recursive_requirements(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.array_value(software_spec_receiver(args, 'recursive_requirements').recursive_requirements().map(software_spec_requirement_value(it)))
}

// Ruby method `patch(strip = :p1, src = T.unsafe(nil), &block)` at line 395.
pub fn ruby_software_spec_l395_d54_patch(args ...brew_runtime.Value) brew_runtime.Value {
	mut spec := software_spec_receiver(args, 'patch')
	strip := if args.len > 1 { args[1].as_string() } else { 'p1' }
	source := if args.len > 2 { args[2].as_string() } else { '' }
	spec.add_patch(strip, source)
	return software_spec_boundary_value(spec)
}

// Ruby method `fails_with(compiler, &block)` at line 404.
pub fn ruby_software_spec_l404_d55_fails_with(args ...brew_runtime.Value) brew_runtime.Value {
	mut spec := software_spec_receiver(args, 'fails_with')
	if args.len < 2 { panic('SoftwareSpec#fails_with requires a compiler') }
	if args[1].type_name == 'Hash' {
		for compiler, version in args[1].as_map() or { panic(err) } {
			if compiler != 'gcc' { panic('The `fails_with` hash syntax only supports GCC') }
			spec.add_compiler_failure(compiler, '${version.as_string()}.999', true) or {
				panic(err)
			}
			break
		}
	} else {
		spec.add_compiler_failure(args[1].as_string(), if args.len > 2 {
			args[2].as_string()
		} else {
			'9999'
		}, false) or { panic(err) }
	}
	return software_spec_boundary_value(spec)
}

// Ruby method `add_dep_option(dep)` at line 409.
pub fn ruby_software_spec_l409_d56_add_dep_option(args ...brew_runtime.Value) brew_runtime.Value {
	mut spec := software_spec_receiver(args, 'add_dep_option')
	if args.len < 2 { panic('SoftwareSpec#add_dep_option requires a dependency') }
	name := args[1].attribute('name') or { args[1].as_string() }
	tags_text := args[1].attribute('tags') or { '' }
	spec.add_dep_option(new_dependency(name, if tags_text == '' {
		[]string{}
	} else {
		tags_text.split(',')
	}))
	return software_spec_boundary_value(spec)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "resource"
// 5: require "download_strategy"
// 6: require "checksum"
// 7: require "version"
// 8: require "options"
// 9: require "build_options"
// 10: require "dependency_collector"
// 11: require "utils/bottles"
// 12: require "patch"
// 13: require "compilers"
// 14: require "macos_version"
// 15: require "on_system"
// 16:
// 17: class SoftwareSpec
// 18:   include Downloadable
// 19:
// 20:   extend Forwardable
// 21:   include OnSystem::MacOSAndLinux
// 22:
// 23:   sig { returns(T.nilable(String)) }
// 24:   attr_reader :name
// 25:
// 26:   sig { returns(T.nilable(String)) }
// 27:   attr_reader :full_name
// 28:
// 29:   sig { returns(T.nilable(T.any(Formula, Cask::Cask))) }
// 30:   attr_reader :owner
// 31:
// 32:   sig { returns(BuildOptions) }
// 33:   attr_reader :build
// 34:
// 35:   sig { returns(T::Hash[String, Resource]) }
// 36:   attr_reader :resources
// 37:
// 38:   sig { returns(T::Array[T.any(EmbeddedPatch, ExternalPatch)]) }
// 39:   attr_reader :patches
// 40:
// 41:   sig { returns(Options) }
// 42:   attr_reader :options
// 43:
// 44:   sig { returns(T::Array[DeprecatedOption]) }
// 45:   attr_reader :deprecated_flags
// 46:
// 47:   sig { returns(T::Array[DeprecatedOption]) }
// 48:   attr_reader :deprecated_options
// 49:
// 50:   sig { returns(DependencyCollector) }
// 51:   attr_reader :dependency_collector
// 52:
// 53:   sig { returns(BottleSpecification) }
// 54:   attr_reader :bottle_specification
// 55:
// 56:   sig { returns(T::Array[CompilerFailure]) }
// 57:   attr_reader :compiler_failures
// 58:
// 59:   sig { returns(T::Boolean) }
// 60:   attr_reader :depends_on_macos_set_in_block
// 61:
// 62:   def_delegators :@resource, :stage, :fetch, :verify_download_integrity, :source_modified_time,
// 63:                  :cached_download, :clear_cache, :checksum, :mirrors, :specs, :using, :version, :mirror,
// 64:                  :downloader, :download_queue_name, :download_queue_type
// 65:
// 66:   def_delegators :@resource, :sha256
// 67:
// 68:   sig { params(flags: T::Array[String]).void }
// 69:   def initialize(flags: [])
// 70:     super()
// 71:
// 72:     @name = T.let(nil, T.nilable(String))
// 73:     @full_name = T.let(nil, T.nilable(String))
// 74:     @owner = T.let(nil, T.nilable(T.any(Formula, Cask::Cask)))
// 75:
// 76:     # Ensure this is synced with `initialize_dup` and `freeze` (excluding simple objects like integers and booleans)
// 77:     @resource = T.let(Resource::Formula.new, Resource::Formula)
// 78:     @resources = T.let({}, T::Hash[String, Resource])
// 79:     @dependency_collector = T.let(DependencyCollector.new, DependencyCollector)
// 80:     @bottle_specification = T.let(BottleSpecification.new, BottleSpecification)
// 81:     @patches = T.let([], T::Array[T.any(EmbeddedPatch, ExternalPatch)])
// 82:     @options = T.let(Options.new, Options)
// 83:     @flags = flags
// 84:     @deprecated_flags = T.let([], T::Array[DeprecatedOption])
// 85:     @deprecated_options = T.let([], T::Array[DeprecatedOption])
// 86:     @build = T.let(BuildOptions.new(Options.create(@flags), options), BuildOptions)
// 87:     @compiler_failures = T.let([], T::Array[CompilerFailure])
// 88:     @depends_on_macos_bare_set_top_level = T.let(false, T::Boolean)
// 89:     @depends_on_macos_version_set_top_level = T.let(false, T::Boolean)
// 90:     @depends_on_maximum_macos_set_top_level = T.let(false, T::Boolean)
// 91:     @depends_on_macos_set_in_block = T.let(false, T::Boolean)
// 92:     @depends_on_linux_set_top_level = T.let(false, T::Boolean)
// 93:   end
// 94:
// 95:   sig { override.params(other: T.any(SoftwareSpec, Downloadable)).void }
// 96:   def initialize_dup(other)
// 97:     super
// 98:     @resource = @resource.dup
// 99:     @resources = @resources.dup
// 100:     @dependency_collector = @dependency_collector.dup
// 101:     @bottle_specification = @bottle_specification.dup
// 102:     @patches = @patches.dup
// 103:     @options = @options.dup
// 104:     @flags = @flags.dup
// 105:     @deprecated_flags = @deprecated_flags.dup
// 106:     @deprecated_options = @deprecated_options.dup
// 107:     @build = @build.dup
// 108:     @compiler_failures = @compiler_failures.dup
// 109:   end
// 110:
// 111:   sig { override.returns(T.self_type) }
// 112:   def freeze
// 113:     @resource.freeze
// 114:     @resources.freeze
// 115:     @dependency_collector.freeze
// 116:     @bottle_specification.freeze
// 117:     @patches.freeze
// 118:     @options.freeze
// 119:     @flags.freeze
// 120:     @deprecated_flags.freeze
// 121:     @deprecated_options.freeze
// 122:     @build.freeze
// 123:     @compiler_failures.freeze
// 124:     super
// 125:   end
// 126:
// 127:   sig { params(owner: T.any(Formula, Cask::Cask)).void }
// 128:   def owner=(owner)
// 129:     @name = owner.name
// 130:     @full_name = owner.full_name
// 131:     @bottle_specification.tap = owner.tap
// 132:     @owner = owner
// 133:     @resource.owner = self
// 134:     resources.each_value do |r|
// 135:       r.owner = self
// 136:       next if r.version
// 137:       next if version.nil?
// 138:
// 139:       r.version(version.head? ? Version.new("HEAD") : version.dup)
// 140:     end
// 141:     patches.each { |p| p.owner = self }
// 142:   end
// 143:
// 144:   sig { override.params(val: T.nilable(String), specs: T::Hash[Symbol, T.anything]).returns(T.nilable(String)) }
// 145:   def url(val = nil, specs = {})
// 146:     if val
// 147:       @resource.url(val, **specs)
// 148:       dependency_collector.add(@resource)
// 149:     end
// 150:     @resource.url
// 151:   end
// 152:
// 153:   sig { returns(T::Boolean) }
// 154:   def bottle_defined?
// 155:     !bottle_specification.collector.tags.empty?
// 156:   end
// 157:
// 158:   sig { params(tag: T.nilable(T.any(Utils::Bottles::Tag, Symbol))).returns(T::Boolean) }
// 159:   def bottle_tag?(tag = nil)
// 160:     bottle_specification.tag?(Utils::Bottles.tag(tag))
// 161:   end
// 162:
// 163:   sig { params(tag: T.nilable(T.any(Utils::Bottles::Tag, Symbol))).returns(T::Boolean) }
// 164:   def bottled?(tag = nil)
// 165:     return false unless bottle_tag?(tag)
// 166:
// 167:     return true if tag.present?
// 168:     return true if bottle_specification.compatible_locations?
// 169:
// 170:     owner = self.owner
// 171:     return false unless owner.is_a?(Formula)
// 172:
// 173:     owner.force_bottle
// 174:   end
// 175:
// 176:   sig { params(block: T.proc.bind(BottleSpecification).void).void }
// 177:   def bottle(&block)
// 178:     bottle_specification.instance_eval(&block)
// 179:   end
// 180:
// 181:   sig { params(name: String).returns(T::Boolean) }
// 182:   def resource_defined?(name)
// 183:     resources.key?(name)
// 184:   end
// 185:
// 186:   sig {
// 187:     params(name: String, klass: T.class_of(Resource), block: T.nilable(T.proc.bind(Resource).void))
// 188:       .returns(T.nilable(Resource))
// 189:   }
// 190:   def resource(name = T.unsafe(nil), klass = Resource, &block)
// 191:     if block
// 192:       raise ArgumentError, "Resource must have a name." if name.nil?
// 193:       raise DuplicateResourceError, name if resource_defined?(name)
// 194:
// 195:       res = klass.new(name, &block)
// 196:       return unless res.url
// 197:
// 198:       resources[name] = res
// 199:       dependency_collector.add(res)
// 200:       res
// 201:     else
// 202:       return @resource if name.nil?
// 203:
// 204:       resources.fetch(name) { raise ResourceMissingError.new(owner, name) }
// 205:     end
// 206:   end
// 207:
// 208:   sig { params(name: T.any(Option, String)).returns(T::Boolean) }
// 209:   def option_defined?(name)
// 210:     options.include?(name)
// 211:   end
// 212:
// 213:   sig { params(name: String, description: String).void }
// 214:   def option(name, description = "")
// 215:     raise ArgumentError, "option name is required" if name.empty?
// 216:     raise ArgumentError, "option name must be longer than one character: #{name}" if name.length <= 1
// 217:     raise ArgumentError, "option name must not start with dashes: #{name}" if name.start_with?("-")
// 218:
// 219:     options << Option.new(name, description)
// 220:   end
// 221:
// 222:   sig { params(hash: T::Hash[T.any(String, T::Array[String]), T.any(String, T::Array[String])]).void }
// 223:   def deprecated_option(hash)
// 224:     raise ArgumentError, "deprecated_option hash must not be empty" if hash.empty?
// 225:
// 226:     hash.each do |old_options, new_options|
// 227:       Array(old_options).each do |old_option|
// 228:         Array(new_options).each do |new_option|
// 229:           deprecated_option = DeprecatedOption.new(old_option, new_option)
// 230:           deprecated_options << deprecated_option
// 231:
// 232:           old_flag = deprecated_option.old_flag
// 233:           new_flag = deprecated_option.current_flag
// 234:           next unless @flags.include? old_flag
// 235:
// 236:           @flags -= [old_flag]
// 237:           @flags |= [new_flag]
// 238:           @deprecated_flags << deprecated_option
// 239:         end
// 240:       end
// 241:     end
// 242:     @build = BuildOptions.new(Options.create(@flags), options)
// 243:   end
// 244:
// 245:   sig {
// 246:     params(
// 247:       spec:         T.nilable(T.any(String, Symbol,
// 248:                                     T::Hash[T.any(String, Symbol, T::Class[Requirement]), T.untyped],
// 249:                                     T::Class[Requirement], Dependable)),
// 250:       set_in_block: T::Boolean,
// 251:       spec_kwargs:  T.untyped,
// 252:     ).void
// 253:   }
// 254:   def depends_on(spec = nil, set_in_block: false, **spec_kwargs)
// 255:     spec = spec_kwargs if spec.nil? && spec_kwargs.present?
// 256:     dep = dependency_collector.add(spec)
// 257:     record_os_requirement(dep, set_in_block:)
// 258:     add_dep_option(dep) if dep
// 259:   end
// 260:
// 261:   sig { returns(T::Boolean) }
// 262:   def depends_on_macos_set_top_level?
// 263:     @depends_on_macos_bare_set_top_level ||
// 264:       @depends_on_macos_version_set_top_level ||
// 265:       @depends_on_maximum_macos_set_top_level
// 266:   end
// 267:
// 268:   sig { returns(T::Boolean) }
// 269:   def depends_on_linux_set_top_level?
// 270:     @depends_on_linux_set_top_level
// 271:   end
// 272:
// 273:   sig { params(dep: T.untyped, set_in_block: T::Boolean).void }
// 274:   def record_os_requirement(dep, set_in_block:)
// 275:     case dep
// 276:     when MacOSRequirement
// 277:       if set_in_block
// 278:         @depends_on_macos_set_in_block = true
// 279:         return
// 280:       end
// 281:
// 282:       if @depends_on_linux_set_top_level
// 283:         raise ArgumentError,
// 284:               "`depends_on :linux` cannot be combined with `depends_on macos:`"
// 285:       end
// 286:
// 287:       if !dep.version_specified?
// 288:         if @depends_on_macos_bare_set_top_level
// 289:           raise ArgumentError, "`depends_on :macos` cannot be combined with another macOS `depends_on`"
// 290:         end
// 291:
// 292:         if @depends_on_macos_version_set_top_level || @depends_on_maximum_macos_set_top_level
// 293:           odeprecated "`depends_on :macos` with `depends_on macos:`",
// 294:                       "`depends_on :macos` with `depends_on macos:` inside an `on_macos` block"
// 295:         end
// 296:
// 297:         @depends_on_macos_bare_set_top_level = true
// 298:       elsif dep.comparator == "<="
// 299:         if @depends_on_macos_bare_set_top_level
// 300:           odeprecated "`depends_on :macos` with `depends_on maximum_macos:`",
// 301:                       "`depends_on :macos` with `depends_on maximum_macos:` inside an `on_macos` block"
// 302:         end
// 303:
// 304:         if @depends_on_maximum_macos_set_top_level
// 305:           raise ArgumentError, "`depends_on maximum_macos:` cannot be combined with another macOS `depends_on`"
// 306:         end
// 307:
// 308:         @depends_on_maximum_macos_set_top_level = true
// 309:       else
// 310:         if @depends_on_macos_bare_set_top_level
// 311:           odeprecated "`depends_on :macos` with `depends_on macos:`",
// 312:                       "`depends_on :macos` with `depends_on macos:` inside an `on_macos` block"
// 313:         end
// 314:
// 315:         if @depends_on_macos_version_set_top_level
// 316:           raise ArgumentError, "`depends_on macos:` cannot be combined with another macOS `depends_on`"
// 317:         end
// 318:
// 319:         @depends_on_macos_version_set_top_level = true
// 320:       end
// 321:     when LinuxRequirement
// 322:       return if set_in_block
// 323:
// 324:       if depends_on_macos_set_top_level?
// 325:         raise ArgumentError,
// 326:               "`depends_on :linux` cannot be combined with `depends_on macos:`"
// 327:       end
// 328:
// 329:       @depends_on_linux_set_top_level = true
// 330:     end
// 331:   end
// 332:
// 333:   sig {
// 334:     params(
// 335:       dep:    T.any(String, T::Hash[T.any(String, Symbol), T.any(Symbol, T::Array[Symbol])]),
// 336:       bounds: T::Hash[Symbol, Symbol],
// 337:     ).void
// 338:   }
// 339:   def uses_from_macos(dep, bounds = {})
// 340:     if dep.is_a?(Hash)
// 341:       bounds = dep.dup
// 342:       dep, tags = bounds.shift
// 343:       dep = T.cast(dep, String)
// 344:       tags = [*tags]
// 345:       bounds = T.cast(bounds, T::Hash[Symbol, Symbol])
// 346:     else
// 347:       tags = []
// 348:     end
// 349:
// 350:     depends_on UsesFromMacOSDependency.new(dep, tags, bounds:)
// 351:   end
// 352:
// 353:   sig { returns(Dependencies) }
// 354:   def deps
// 355:     dependency_collector.deps.dup_without_system_deps
// 356:   end
// 357:
// 358:   sig { returns(Dependencies) }
// 359:   def declared_deps
// 360:     dependency_collector.deps
// 361:   end
// 362:
// 363:   sig { returns(T::Array[Dependency]) }
// 364:   def recursive_dependencies
// 365:     deps_f = []
// 366:     recursive_dependencies = deps.filter_map do |dep|
// 367:       deps_f << dep.to_formula
// 368:       dep
// 369:     rescue TapFormulaUnavailableError
// 370:       # Don't complain about missing cross-tap dependencies
// 371:       next
// 372:     end.uniq
// 373:     deps_f.compact.each do |f|
// 374:       f.recursive_dependencies.each do |dep|
// 375:         recursive_dependencies << dep unless recursive_dependencies.include?(dep)
// 376:       end
// 377:     end
// 378:     recursive_dependencies
// 379:   end
// 380:
// 381:   sig { returns(Requirements) }
// 382:   def requirements
// 383:     dependency_collector.requirements
// 384:   end
// 385:
// 386:   sig { returns(Requirements) }
// 387:   def recursive_requirements
// 388:     Requirement.expand(self)
// 389:   end
// 390:
// 391:   sig {
// 392:     params(strip: T.any(Symbol, String), src: T.nilable(T.any(String, Symbol)),
// 393:            block: T.nilable(T.proc.bind(Resource::Patch).void)).void
// 394:   }
// 395:   def patch(strip = :p1, src = T.unsafe(nil), &block)
// 396:     p = Patch.create(strip, src, &block)
// 397:     return if p.is_a?(ExternalPatch) && p.url.blank?
// 398:
// 399:     dependency_collector.add(p.resource) if p.is_a? ExternalPatch
// 400:     patches << p
// 401:   end
// 402:
// 403:   sig { params(compiler: T.any(T::Hash[Symbol, String], Symbol), block: T.nilable(T.proc.bind(CompilerFailure).void)).void }
// 404:   def fails_with(compiler, &block)
// 405:     compiler_failures << CompilerFailure.create(compiler, &block)
// 406:   end
// 407:
// 408:   sig { params(dep: Dependable).void }
// 409:   def add_dep_option(dep)
// 410:     dep.option_names.each do |name|
// 411:       if dep.optional? && !option_defined?("with-#{name}")
// 412:         options << Option.new("with-#{name}", "Build with #{name} support")
// 413:       elsif dep.recommended? && !option_defined?("without-#{name}")
// 414:         options << Option.new("without-#{name}", "Build without #{name} support")
// 415:       end
// 416:     end
// 417:   end
// 418: end
