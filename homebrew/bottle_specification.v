module homebrew

import ruby

// Translated from Homebrew/brew `bottle_specification.rb`.

pub enum BottleCellarKind {
	path
	any
	any_skip_relocation
}

// BottleCellar preserves the Ruby String-or-Symbol cellar value without using
// a dynamic runtime value.
pub struct BottleCellar {
pub:
	kind  BottleCellarKind
	value string
}

pub struct BottleLocationContext {
pub:
	prefix                string
	cellar                string
	relocate_build_prefix bool
	linux                 bool
	tab_homebrew_version  string
}

pub struct BottleChecksumSpecification {
pub:
	tag    string
	digest Checksum
	cellar BottleCellar
}

pub struct BottleSpecification {
pub mut:
	tap            string
	has_tap        bool
	collector      BottleTagCollector
	root_url_specs map[string]string
	repository     string
	rebuild_value  int
	root_url_value string
	has_root_url   bool
}

pub fn bottle_cellar_any() BottleCellar {
	return BottleCellar{
		kind: .any
	}
}

pub fn bottle_cellar_any_skip_relocation() BottleCellar {
	return BottleCellar{
		kind: .any_skip_relocation
	}
}

pub fn bottle_cellar_path(path string) BottleCellar {
	return BottleCellar{
		kind: .path
		value: path
	}
}

pub fn parse_bottle_cellar(value string) BottleCellar {
	normalized := value.trim_string_left(':')
	return match normalized {
		'any' { bottle_cellar_any() }
		'any_skip_relocation' { bottle_cellar_any_skip_relocation() }
		else { bottle_cellar_path(value) }
	}
}

pub fn (cellar BottleCellar) str() string {
	return match cellar.kind {
		.any { 'any' }
		.any_skip_relocation { 'any_skip_relocation' }
		.path { cellar.value }
	}
}

pub fn (cellar BottleCellar) equals(other BottleCellar) bool {
	return cellar.kind == other.kind && cellar.value == other.value
}

pub fn (cellar BottleCellar) relocatable() bool {
	return cellar.kind in [.any, .any_skip_relocation]
}

fn default_bottle_domain() string {
	configured := ruby.environment_value('HOMEBREW_BOTTLE_DOMAIN')
	if configured != '' {
		return configured.trim_string_right('/')
	}
	configured_default := ruby.environment_value('HOMEBREW_BOTTLE_DEFAULT_DOMAIN')
	if configured_default != '' {
		return configured_default.trim_string_right('/')
	}
	return 'https://ghcr.io/v2/homebrew/core'
}

fn default_bottle_repository() string {
	configured := ruby.environment_value('HOMEBREW_DEFAULT_REPOSITORY')
	if configured != '' {
		return configured
	}
	return current_bottle_tag().default_prefix()
}

// github_packages_root_url_if_match translates
// GitHubPackages.root_url_if_match for bottle roots.
pub fn github_packages_root_url_if_match(value string) ?string {
	mut remainder := ''
	if value.starts_with('https://ghcr.io/v2/') {
		remainder = value.trim_string_left('https://ghcr.io/v2/')
	} else if value.starts_with('docker://ghcr.io/') {
		remainder = value.trim_string_left('docker://ghcr.io/')
	} else {
		return none
	}
	parts := remainder.split('/')
	if parts.len < 2 || parts[0] == '' || parts[1] == '' {
		return none
	}
	repository := parts[1].trim_string_left('homebrew-')
	return 'https://ghcr.io/v2/${parts[0].to_lower()}/${repository}'
}

pub fn new_bottle_specification() BottleSpecification {
	return BottleSpecification{
		collector: new_bottle_tag_collector()
		root_url_specs: map[string]string{}
		repository: default_bottle_repository()
	}
}

pub fn (specification BottleSpecification) rebuild() int {
	return specification.rebuild_value
}

pub fn (mut specification BottleSpecification) set_rebuild(value int) int {
	specification.rebuild_value = value
	return value
}

pub fn (mut specification BottleSpecification) root_url() string {
	if !specification.has_root_url {
		domain := default_bottle_domain()
		specification.root_url_value = github_packages_root_url_if_match(domain) or { domain }
		specification.has_root_url = true
	}
	return specification.root_url_value
}

pub fn (mut specification BottleSpecification) set_root_url(value string,
	specs map[string]string) string {
	specification.root_url_value = github_packages_root_url_if_match(value) or { value }
	specification.has_root_url = true
	for key, spec in specs {
		specification.root_url_specs[key] = spec
	}
	return specification.root_url_value
}

pub fn (left BottleSpecification) equals(right BottleSpecification) bool {
	mut left_copy := left
	mut right_copy := right
	return left.rebuild_value == right.rebuild_value && left.collector.equals(right.collector)
		&& left_copy.root_url() == right_copy.root_url()
		&& left.root_url_specs == right.root_url_specs && left.tap == right.tap
		&& left.has_tap == right.has_tap
}

pub fn (specification BottleSpecification) tag_to_cellar(tag BottleTag) BottleCellar {
	if tag_specification := specification.collector.specification_for(tag, false) {
		return tag_specification.cellar
	}
	return tag.default_cellar()
}

fn bottle_parent_path(path string) string {
	trimmed := path.trim_string_right('/')
	if index := trimmed.last_index('/') {
		if index == 0 {
			return '/'
		}
		return trimmed[..index]
	}
	return '.'
}

pub fn default_bottle_location_context(tag BottleTag) BottleLocationContext {
	mut prefix := ruby.environment_value('HOMEBREW_PREFIX')
	if prefix == '' {
		prefix = tag.default_prefix()
	}
	mut cellar := ruby.environment_value('HOMEBREW_CELLAR')
	if cellar == '' {
		cellar = '${prefix}/Cellar'
	}
	return BottleLocationContext{
		prefix: prefix
		cellar: cellar
		relocate_build_prefix: ruby.environment_value('HOMEBREW_RELOCATE_BUILD_PREFIX') != ''
		linux: tag.linux()
	}
}

pub fn (specification BottleSpecification) compatible_locations(tag BottleTag,
	context BottleLocationContext) bool {
	cellar := specification.tag_to_cellar(tag)
	if cellar.relocatable() {
		return true
	}
	cellar_path := cellar.str()
	prefix := bottle_parent_path(cellar_path)
	cellar_relocatable := cellar_path.len >= context.cellar.len && context.relocate_build_prefix
	prefix_relocatable := prefix.len >= context.prefix.len && context.relocate_build_prefix
	compatible_cellar := cellar_path == context.cellar || cellar_relocatable
	compatible_prefix := prefix == context.prefix || prefix_relocatable
	return compatible_cellar && compatible_prefix
}

pub fn (specification BottleSpecification) skip_relocation(tag BottleTag,
	context BottleLocationContext) bool {
	tag_specification := specification.collector.specification_for(tag, false) or { return false }
	if tag_specification.cellar.kind != .any_skip_relocation {
		return false
	}
	if !context.linux {
		return true
	}
	if context.tab_homebrew_version == '' {
		return false
	}
	minimum := new_version('5.1.15') or { return false }
	version := new_version(context.tab_homebrew_version) or { return false }
	return version.compare_to(minimum) >= 0
}

pub fn (specification BottleSpecification) has_tag(tag BottleTag,
	no_older_versions bool) bool {
	return specification.collector.has_tag(tag, no_older_versions)
}

fn valid_bottle_digest(digest string) bool {
	if digest.len != 64 {
		return false
	}
	for character in digest.to_lower() {
		if !(character.is_digit() || character in [`a`, `b`, `c`, `d`, `e`, `f`]) {
			return false
		}
	}
	return true
}

pub fn (mut specification BottleSpecification) sha256(tag_symbol string, digest string,
	cellar ?BottleCellar) ! {
	if !valid_bottle_digest(digest) {
		return error('Invalid sha256 hash: ${digest}')
	}
	tag := bottle_tag_from_symbol(tag_symbol)!
	selected_cellar := cellar or { tag.default_cellar() }
	specification.collector.add(tag, new_checksum(digest), selected_cellar)
}

pub fn (specification BottleSpecification) tag_specification_for(tag BottleTag,
	no_older_versions bool) ?BottleTagSpecification {
	return specification.collector.specification_for(tag, no_older_versions)
}

fn compare_bottle_checksum_tags(left &BottleTag, right &BottleTag) int {
	left_macos := left.macos()
	right_macos := right.macos()
	left_priority := if left_macos {
		if left.standardized_arch() == 'arm64' { 3 } else { 2 }
	} else if left.standardized_arch() == 'arm64' {
		1
	} else {
		0
	}
	right_priority := if right_macos {
		if right.standardized_arch() == 'arm64' { 3 } else { 2 }
	} else if right.standardized_arch() == 'arm64' {
		1
	} else {
		0
	}
	if left_priority != right_priority {
		return if left_priority < right_priority { -1 } else { 1 }
	}
	if left_macos && right_macos {
		left_version := left.macos_version() or { return -1 }
		right_version := right.macos_version() or { return 1 }
		return left_version.compare_to(right_version)
	}
	return if left.symbol() < right.symbol() {
		-1
	} else if left.symbol() > right.symbol() {
		1
	} else {
		0
	}
}

pub fn (specification BottleSpecification) checksums() []BottleChecksumSpecification {
	mut tags := specification.collector.tags()
	tags.sort_with_compare(compare_bottle_checksum_tags)
	mut checksums := []BottleChecksumSpecification{}
	for index := tags.len - 1; index >= 0; index-- {
		tag := tags[index]
		tag_specification := specification.collector.specification_for(tag, true) or { continue }
		checksums << BottleChecksumSpecification{
			tag: tag_specification.tag.symbol()
			digest: tag_specification.checksum
			cellar: tag_specification.cellar
		}
	}
	return checksums
}
