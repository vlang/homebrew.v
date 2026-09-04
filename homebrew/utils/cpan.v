module utils

import ruby
import x.json2

// Translated from Homebrew/brew `utils/cpan.rb`.
pub const metacpan_url_prefix = 'https://cpan.metacpan.org/authors/id/'

pub struct CpanReleaseInfo {
pub:
	name         string
	download_url string
	checksum     string
	version      string
}

pub struct CpanInfoLookup {
pub:
	found bool
	info  CpanReleaseInfo
}

pub type CpanMetadataFetch = fn (string) !string

@[heap]
pub struct CpanPackage {
pub:
	resource_name string
	resource_url  string
	is_cpan_url   bool
mut:
	current_version_cache string
	info_cache            ?CpanReleaseInfo
	metadata_queried      bool
}

struct CpanMetadataDocument {
pub:
	download_url    ?string
	checksum_sha256 ?string
	version         ?string
}

pub fn new_cpan_package(resource_name string, resource_url string) &CpanPackage {
	return &CpanPackage{
		resource_name: resource_name
		resource_url: resource_url
		is_cpan_url: resource_url.starts_with(metacpan_url_prefix)
	}
}

pub fn (package &CpanPackage) name() string {
	return package.resource_name
}

fn cpan_archive_version(url string) ?string {
	filename := url.all_after_last('/')
	mut stem := ''
	if filename.ends_with('.tar.gz') {
		stem = filename[..filename.len - 7]
	} else if filename.ends_with('.tgz') {
		stem = filename[..filename.len - 4]
	} else {
		return none
	}
	separator := stem.last_index('-') or { return none }
	version := stem[separator + 1..]
	mut invalid := version.len == 0
	for character in version {
		if !(character.is_digit() || character in [`v`, `.`]) {
			invalid = true
			break
		}
	}
	if invalid {
		return none
	}
	return version
}

pub fn (mut package CpanPackage) current_version() ?string {
	if package.current_version_cache.len == 0 && package.is_cpan_url {
		package.current_version_cache = cpan_archive_version(package.resource_url) or { '' }
	}
	return if package.current_version_cache.len > 0 { package.current_version_cache } else { none }
}

pub fn (package &CpanPackage) valid() bool {
	return package.is_cpan_url
}

pub fn (mut package CpanPackage) latest_info(fetch CpanMetadataFetch) !CpanInfoLookup {
	if cached := package.info_cache {
		return CpanInfoLookup{
			found: true
			info: cached
		}
	}
	if package.metadata_queried || !package.valid() {
		return CpanInfoLookup{}
	}
	package.metadata_queried = true
	metadata_url := 'https://fastapi.metacpan.org/v1/download_url/${package.resource_name}'
	payload := fetch(metadata_url) or { return CpanInfoLookup{} }
	document := json2.decode[CpanMetadataDocument](payload) or { return CpanInfoLookup{} }
	download_url := document.download_url or { return CpanInfoLookup{} }
	checksum := document.checksum_sha256 or { return CpanInfoLookup{} }
	info := CpanReleaseInfo{
		name: package.resource_name
		download_url: download_url
		checksum: checksum
		version: document.version or { '' }
	}
	package.info_cache = info
	return CpanInfoLookup{
		found: true
		info: info
	}
}

pub struct CpanResource {
pub:
	name      string
	url       string
	livecheck bool
}

pub struct CpanFormula {
pub:
	name      string
	path      string
	source    string
	resources []CpanResource
}

pub struct CpanUpdateOptions {
pub:
	print_only    bool
	quiet         bool
	verbose       bool
	ignore_errors bool
}

pub struct CpanUpdateResult {
pub:
	resource_section string
	updated_source   string
	messages         []string
	errors           []string
	updated_count    int
	failed           bool
}

fn cpan_resource_block(info CpanReleaseInfo) string {
	return '  resource "${info.name}" do\n    url "${info.download_url}"\n    sha256 "${info.checksum}"\n  end\n\n'
}

fn cpan_replace_resource_stanzas(source string, replacement string) !string {
	// `String#split_into_lines` discards separators in V. Ruby's AST replacement
	// retains the complete formula layout, including its trailing newline, so use
	// explicit newline elements and join them with the same separator below.
	lines := source.split('\n')
	mut output := []string{cap: lines.len}
	mut first_resource_index := -1
	mut index := 0
	for index < lines.len {
		line := lines[index]
		if line.starts_with('  resource "') && line.trim_space().ends_with(' do') {
			if first_resource_index < 0 {
				first_resource_index = output.len
			}
			index++
			mut depth := 1
			for index < lines.len && depth > 0 {
				trimmed := lines[index].trim_space()
				if trimmed.ends_with(' do') {
					depth++
				}
				if trimmed == 'end' {
					depth--
				}
				index++
			}
			if index < lines.len && lines[index].trim_space() == '' {
				index++
			}
			continue
		}
		output << line
		index++
	}
	if first_resource_index < 0 {
		for i, line in output {
			if line.starts_with('  def install') {
				first_resource_index = i
				break
			}
		}
	}
	if first_resource_index < 0 {
		return error('multiple_groups')
	}
	// Resource sections end with a blank separator. Remove only the final newline
	// before splitting so insertion adds one blank line, not two, ahead of the
	// following formula stanza.
	replacement_body := if replacement.ends_with('\n') {
		replacement[..replacement.len - 1]
	} else {
		replacement
	}
	replacement_lines := replacement_body.split('\n')
	mut combined := []string{cap: output.len + replacement_lines.len}
	combined << output[..first_resource_index]
	combined << replacement_lines
	combined << output[first_resource_index..]
	return combined.join('\n')
}

pub fn update_perl_resources(formula CpanFormula, options CpanUpdateOptions,
	fetch CpanMetadataFetch) !CpanUpdateResult {
	cpan_resources := formula.resources.filter(it.url.starts_with(metacpan_url_prefix))
	if cpan_resources.len == 0 {
		return error('"${formula.name}" has no CPAN resources to update.')
	}
	non_cpan_names := formula.resources.filter(!it.url.starts_with(metacpan_url_prefix)).map(it.name).sorted()
	livecheck_names := cpan_resources.filter(it.livecheck).map(it.name).sorted()
	if !options.print_only && non_cpan_names.len > 0 {
		return error('"${formula.name}" contains non-CPAN resources: ${non_cpan_names.join(', ')}\nPlease update the resources manually.')
	}
	if !options.print_only && livecheck_names.len > 0 {
		return error('"${formula.name}" contains CPAN resources with livecheck blocks: ${livecheck_names.join(', ')}\nPlease update the resources manually.')
	}
	show_info := !options.print_only && !options.quiet
	mut messages := []string{}
	if show_info {
		messages << 'Found ${cpan_resources.len} CPAN resources to update'
	}
	mut resource_blocks := ''
	mut package_errors := ''
	mut updated_count := 0
	for resource in cpan_resources {
		mut package := new_cpan_package(resource.name, resource.url)
		if show_info {
			messages << 'Checking "${resource.name}" for updates...'
		}
		lookup := package.latest_info(fetch) or { CpanInfoLookup{} }
		if lookup.found {
			resolved := lookup.info
			current := package.current_version()
			if current_version := current {
				if resolved.version.len > 0 && current_version != resolved.version {
					if show_info {
						messages << '"${resource.name}": ${current_version} -> ${resolved.version}'
					}
					updated_count++
				} else if show_info {
					messages << '"${resource.name}": already up to date (${current_version})'
				}
			}
			resource_blocks += cpan_resource_block(resolved)
		} else if options.ignore_errors {
			package_errors += '  # RESOURCE-ERROR: Unable to resolve "${resource.name}"\n'
		} else {
			return error('Unable to resolve "${resource.name}"')
		}
	}
	if package_errors.len > 0 {
		package_errors += '\n'
	}
	section := package_errors + resource_blocks
	if options.print_only {
		return CpanUpdateResult{
			resource_section: section.trim_right('\n')
			updated_source: formula.source
			messages: messages
			updated_count: updated_count
		}
	}
	if !options.quiet {
		messages << 'Updating resource blocks'
	}
	updated_source := cpan_replace_resource_stanzas(formula.source, section) or {
		return error('Unable to update resource blocks for "${formula.name}" automatically. Please update them manually.')
	}
	mut errors := []string{}
	mut failed := false
	if package_errors.len > 0 {
		errors << 'Unable to resolve some dependencies. Please check ${formula.path} for RESOURCE-ERROR comments.'
		failed = true
	} else if updated_count > 0 && !options.quiet {
		messages << 'Updated ${updated_count} CPAN resource${if updated_count != 1 {
			's'
		} else {
			''
		}}'
	}
	return CpanUpdateResult{
		resource_section: section
		updated_source: updated_source
		messages: messages
		errors: errors
		updated_count: updated_count
		failed: failed
	}
}

fn cpan_package_value(package &CpanPackage) ruby.Value {
	return ruby.structured_value('CPAN::Package', package.resource_name, {
		'cpan_package_address': u64(voidptr(package)).str()
		'resource_name':        package.resource_name
		'resource_url':         package.resource_url
	})
}

fn cpan_package_from_value(value ruby.Value) &CpanPackage {
	address := value.attribute('cpan_package_address') or { panic('invalid CPAN::Package receiver') }
	return unsafe { &CpanPackage(voidptr(address.u64())) }
}

fn cpan_boundary_fetch(_ string) !string {
	return error('MetaCPAN response was not supplied')
}

fn cpan_info_value(info CpanInfoLookup) ruby.Value {
	if info.found {
		release := info.info
		return ruby.string_array_value([release.name, release.download_url, release.checksum,
			release.version])
	}
	return ruby.object_value('NilClass', 'nil')
}

fn cpan_option_bool(values map[string]ruby.Value, name string) bool {
	value := values[name] or { return false }
	return value.type_name == 'Bool' && value.bool_data
}
