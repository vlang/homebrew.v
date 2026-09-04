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

fn software_spec_string_map_boundary(values map[string]string) ruby.Value {
	mut entries := map[string]ruby.Value{}
	for key, value in values {
		entries[key] = ruby.string_value(value)
	}
	return ruby.map_value(entries)
}

fn software_spec_string_map_from_boundary(value ruby.Value) map[string]string {
	mut entries := map[string]string{}
	for key, item in value.as_map() or { return entries } {
		entries[key] = item.as_string()
	}
	return entries
}

fn software_spec_resource_boundary(resource Resource) ruby.Value {
	mut patch_values := []ruby.Value{}
	for patch in resource.patches {
		patch_values << ruby.structured_value('ResourcePatch', patch.source, {
			'strip':  patch.strip
			'source': patch.source
			'owner':  patch.owner_name
		})
	}
	return ruby.Value{
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
			'mirrors': ruby.string_array_value(resource.mirrors)
			'patches': ruby.array_value(patch_values)
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

fn software_spec_resource_from_boundary(value ruby.Value) Resource {
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
		for patch in patches.as_array() or { []ruby.Value{} } {
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

fn software_spec_dependency_value(dependency Dependency) ruby.Value {
	return ruby.Value{
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

fn software_spec_dependency_from_value(value ruby.Value) Dependency {
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

fn software_spec_requirement_value(requirement SoftwareSpecRequirement) ruby.Value {
	return ruby.structured_value('Requirement', requirement.kind.str(), {
		'kind':       requirement.kind.str()
		'tags':       requirement.tags.join(software_spec_dependency_separator)
		'comparator': requirement.comparator
	})
}

fn software_spec_requirement_from_value(value ruby.Value) SoftwareSpecRequirement {
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

fn software_spec_bottle_boundary(bottle BottleSpecification) ruby.Value {
	mut checksum_values := []ruby.Value{}
	for symbol in bottle.collector.order {
		entry := bottle.collector.tag_specs[symbol] or { continue }
		checksum_values << ruby.structured_value('BottleChecksum', entry.checksum.hexdigest, {
			'tag':    symbol
			'digest': entry.checksum.hexdigest
			'cellar': entry.cellar.str()
		})
	}
	return ruby.Value{
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
			'checksums':      ruby.array_value(checksum_values)
			'root_url_specs': software_spec_string_map_boundary(bottle.root_url_specs)
		}
	}
}

fn software_spec_bottle_from_boundary(value ruby.Value) BottleSpecification {
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
		for entry in checksums.as_array() or { []ruby.Value{} } {
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

pub fn software_spec_boundary_value(spec SoftwareSpec) ruby.Value {
	mut resource_values := map[string]ruby.Value{}
	for name, resource in spec.resources_value {
		resource_values[name] = software_spec_resource_boundary(resource)
	}
	option_values := spec.options_value.to_array().map(ruby.structured_value('Option', it.flag, {
		'name':        it.name
		'description': it.description
	}))
	deprecated_flag_values := spec.deprecated_flag_values.map(ruby.structured_value('DeprecatedOption', '${it.old}=>${it.current}', {
		'old':     it.old
		'current': it.current
	}))
	deprecated_option_values := spec.deprecated_option_values.map(ruby.structured_value('DeprecatedOption', '${it.old}=>${it.current}', {
		'old':     it.old
		'current': it.current
	}))
	compiler_failure_values := spec.compiler_failure_values.map(ruby.structured_value('CompilerFailure', '${it.compiler} ${it.version}', {
		'compiler':          it.compiler
		'version':           it.version.to_s()
		'exact_major_match': it.exact_major_match.str()
	}))
	version := spec.version() or { null_version() }
	checksum := spec.checksum() or { Checksum{} }
	return ruby.Value{
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
			'resources':          ruby.map_value(resource_values)
			'dependencies':       ruby.array_value(spec.dependency_values.map(software_spec_dependency_value(it)))
			'requirements':       ruby.array_value(spec.requirement_values.map(software_spec_requirement_value(it)))
			'bottle':             software_spec_bottle_boundary(spec.bottle_specification_value)
			'patches':            ruby.array_value(spec.patch_values.map(ruby.structured_value('Patch', it.source, {
				'strip':  it.strip
				'source': it.source
				'owner':  it.owner_name
			})))
			'options':            ruby.array_value(option_values)
			'deprecated_flags':   ruby.array_value(deprecated_flag_values)
			'deprecated_options': ruby.array_value(deprecated_option_values)
			'compiler_failures':  ruby.array_value(compiler_failure_values)
		}
	}
}

pub fn software_spec_from_boundary(value ruby.Value) SoftwareSpec {
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
				.cask
			} else {
				.formula
			}
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
		for resource_name, resource in resources.as_map() or { map[string]ruby.Value{} } {
			spec.resources_value[resource_name] = software_spec_resource_from_boundary(resource)
		}
	}
	if dependencies := value.map_data['dependencies'] {
		for dependency in dependencies.as_array() or { []ruby.Value{} } {
			spec.dependency_values << software_spec_dependency_from_value(dependency)
		}
	}
	if requirements := value.map_data['requirements'] {
		for requirement in requirements.as_array() or { []ruby.Value{} } {
			spec.requirement_values << software_spec_requirement_from_value(requirement)
		}
	}
	if bottle := value.map_data['bottle'] {
		spec.bottle_specification_value = software_spec_bottle_from_boundary(bottle)
	}
	if patches := value.map_data['patches'] {
		for patch in patches.as_array() or { []ruby.Value{} } {
			spec.patch_values << ResourcePatch{
				strip: patch.attribute('strip') or { '' }
				source: patch.attribute('source') or { patch.as_string() }
				owner_name: patch.attribute('owner') or { '' }
			}
		}
	}
	if options := value.map_data['options'] {
		spec.options_value = new_options()
		for option in options.as_array() or { []ruby.Value{} } {
			spec.options_value.add(new_option(option.attribute('name') or { option.as_string() }, option.attribute('description') or { '' }))
		}
	}
	if deprecated_flags := value.map_data['deprecated_flags'] {
		for option in deprecated_flags.as_array() or { []ruby.Value{} } {
			spec.deprecated_flag_values << new_deprecated_option(option.attribute('old') or { '' }, option.attribute('current') or { '' })
		}
	}
	if deprecated_options := value.map_data['deprecated_options'] {
		for option in deprecated_options.as_array() or { []ruby.Value{} } {
			spec.deprecated_option_values << new_deprecated_option(option.attribute('old') or {
				''
			}, option.attribute('current') or { '' })
		}
	}
	if compiler_failures := value.map_data['compiler_failures'] {
		for failure in compiler_failures.as_array() or { []ruby.Value{} } {
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

fn software_spec_receiver(args []ruby.Value, method string) SoftwareSpec {
	if args.len == 0 || args[0].type_name != 'SoftwareSpec' {
		panic('SoftwareSpec#${method} requires a receiver')
	}
	return software_spec_from_boundary(args[0])
}

fn software_spec_optional_string(value ?string) ruby.Value {
	if text := value {
		return ruby.string_value(text)
	}
	return ruby.object_value('NilClass', 'nil')
}

fn software_spec_dependency_boundary(dependencies []Dependency) ruby.Value {
	return ruby.array_value(dependencies.map(software_spec_dependency_value(it)))
}

fn software_spec_dependency_tags(dependency Dependency) string {
	return dependency.tags.map(it.boundary_string()).join(',')
}

fn software_spec_tags_from_boundary(value ruby.Value) []string {
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
