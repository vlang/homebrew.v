module homebrew

import ruby

// BottleTag is the typed translation of Utils::Bottles::Tag. It denotes the
// architecture and operating system encoded in a bottle filename.
pub struct BottleTag {
pub:
	system string
	arch   string
}

// BottleTagSpecification is the typed translation of
// Utils::Bottles::TagSpecification.
pub struct BottleTagSpecification {
pub:
	tag      BottleTag
	checksum Checksum
	cellar   BottleCellar
}

// BottleTagCollector is the typed translation of Utils::Bottles::Collector.
// V maps cannot use arbitrary structs as keys, so the source Tag key is stored
// by its canonical symbol while insertion order is retained separately.
pub struct BottleTagCollector {
pub mut:
	tag_specs map[string]BottleTagSpecification
	order     []string
}

const bottle_tag_arches = ['x86_64', 'i386', 'ppc64le', 'ppc64', 'ppc970', 'ppc7450', 'ppc7400',
	'ppc32', 'ppc', 'arm64', 'aarch64']

const bottle_macos_versions = {
	'golden_gate': '27'
	'tahoe':       '26'
	'sequoia':     '15'
	'sonoma':      '14'
	'ventura':     '13'
	'monterey':    '12'
	'big_sur':     '11'
	'catalina':    '10.15'
}

pub fn new_bottle_tag(system string, arch string) BottleTag {
	return BottleTag{
		system: system
		arch:   arch
	}
}

// bottle_tag_from_symbol translates Tag.from_symbol.
pub fn bottle_tag_from_symbol(value string) !BottleTag {
	if value == 'all' {
		return new_bottle_tag('all', 'all')
	}
	if value == '' {
		return error('Invalid bottle tag symbol')
	}
	for arch in bottle_tag_arches {
		prefix := '${arch}_'
		if value.starts_with(prefix) && value.len > prefix.len {
			return new_bottle_tag(value[prefix.len..], arch)
		}
	}
	for character in value {
		if !(character.is_alnum() || character in [`_`, `.`]) {
			return error('Invalid bottle tag symbol')
		}
	}
	return new_bottle_tag(value, 'x86_64')
}

// bottle_tag_from_arg translates Tag.from_arg.
pub fn bottle_tag_from_arg(argument ?string, system string, arch string) !BottleTag {
	if value := argument {
		return bottle_tag_from_symbol(value)
	}
	return new_bottle_tag(system, arch)
}

pub fn (tag BottleTag) standardized_arch() string {
	if tag.arch in ['x86_64', 'intel'] {
		return 'x86_64'
	}
	if tag.arch in ['arm64', 'arm', 'aarch64'] {
		return 'arm64'
	}
	return tag.arch
}

fn (tag BottleTag) arch_symbol(arch string) string {
	if tag.system == 'all' && arch == 'all' {
		return 'all'
	}
	if tag.macos() && tag.standardized_arch() == 'x86_64' {
		return tag.system
	}
	return '${arch}_${tag.system}'
}

pub fn (tag BottleTag) symbol() string {
	return tag.arch_symbol(tag.standardized_arch())
}

pub fn (tag BottleTag) str() string {
	return tag.symbol()
}

pub fn (tag BottleTag) unstandardized_symbol() string {
	// Never allow these generic names.
	if tag.arch in ['intel', 'arm'] {
		return tag.symbol()
	}

	// Backwards compatibility with older bottle names.
	return tag.arch_symbol(tag.arch)
}

pub fn (tag BottleTag) equals(other BottleTag) bool {
	return tag.system == other.system && tag.standardized_arch() == other.standardized_arch()
}

pub fn (tag BottleTag) macos_version() !Version {
	version := bottle_macos_versions[tag.system] or {
		return error('unknown or unsupported macOS version: ${tag.system}')
	}
	return new_version(version)
}

pub fn (tag BottleTag) linux() bool {
	return tag.system == 'linux'
}

pub fn (tag BottleTag) macos() bool {
	return tag.system in bottle_macos_versions
}

pub fn (tag BottleTag) valid_combination() bool {
	if tag.arch !in ['arm64', 'arm', 'aarch64'] || !tag.macos() {
		return true
	}
	big_sur := new_version('11') or { return false }
	version := tag.macos_version() or { return false }
	return version.compare_to(big_sur) >= 0
}

pub fn (tag BottleTag) default_prefix() string {
	if tag.linux() {
		return '/home/linuxbrew/.linuxbrew'
	}
	if tag.standardized_arch() == 'arm64' {
		return '/opt/homebrew'
	}
	return '/usr/local'
}

pub fn (tag BottleTag) default_cellar() BottleCellar {
	return bottle_cellar_path('${tag.default_prefix()}/Cellar')
}

fn darwin_bottle_system(release string) string {
	major_text := release.all_before('.')
	return match major_text.int() {
		26 { 'golden_gate' }
		25 { 'tahoe' }
		24 { 'sequoia' }
		23 { 'sonoma' }
		22 { 'ventura' }
		21 { 'monterey' }
		20 { 'big_sur' }
		19 { 'catalina' }
		else { major_text }
	}
}

// current_bottle_tag translates Utils::Bottles.tag for the running platform.
pub fn current_bottle_tag() BottleTag {
	information := ruby.kernel_info()
	mut system := if information.name.to_lower() == 'darwin' {
		darwin_bottle_system(information.release)
	} else {
		information.name.to_lower()
	}
	configured_system := ruby.environment_value('HOMEBREW_BOTTLE_SYSTEM')
	if configured_system != '' {
		system = configured_system
	}
	mut arch := 'x86_64'
	$if arm64 {
		arch = 'arm64'
	} $else $if aarch64 {
		arch = 'arm64'
	}
	configured_arch := ruby.environment_value('HOMEBREW_PROCESSOR')
	if configured_arch != '' {
		arch = configured_arch.to_lower()
	}
	return new_bottle_tag(system, arch)
}

pub fn new_bottle_tag_collector() BottleTagCollector {
	return BottleTagCollector{
		tag_specs: map[string]BottleTagSpecification{}
	}
}

pub fn (collector BottleTagCollector) tags() []BottleTag {
	mut tags := []BottleTag{}
	for symbol in collector.order {
		if specification := collector.tag_specs[symbol] {
			tags << specification.tag
		}
	}
	return tags
}

pub fn (collector BottleTagCollector) equals(other BottleTagCollector) bool {
	if collector.tag_specs.len != other.tag_specs.len {
		return false
	}
	for symbol, specification in collector.tag_specs {
		other_specification := other.tag_specs[symbol] or { return false }
		if !specification.tag.equals(other_specification.tag)
			|| !specification.checksum.equals(other_specification.checksum)
			|| !specification.cellar.equals(other_specification.cellar) {
			return false
		}
	}
	return true
}

pub fn (mut collector BottleTagCollector) add(tag BottleTag, checksum Checksum,
	cellar BottleCellar) {
	symbol := tag.symbol()
	if symbol !in collector.tag_specs {
		collector.order << symbol
	}
	collector.tag_specs[symbol] = BottleTagSpecification{
		tag:      tag
		checksum: checksum
		cellar:   cellar
	}
}

pub fn (collector BottleTagCollector) find_matching_tag(tag BottleTag,
	no_older_versions bool) ?BottleTag {
	if specification := collector.tag_specs[tag.symbol()] {
		return specification.tag
	}
	if specification := collector.tag_specs['all'] {
		return specification.tag
	}
	if no_older_versions || !tag.macos() {
		return none
	}
	tag_version := tag.macos_version() or { return none }
	for candidate in collector.tags() {
		if candidate.standardized_arch() != tag.standardized_arch() || !candidate.macos() {
			continue
		}
		candidate_version := candidate.macos_version() or { continue }
		if candidate_version.compare_to(tag_version) <= 0 {
			return candidate
		}
	}
	return none
}

pub fn (collector BottleTagCollector) has_tag(tag BottleTag, no_older_versions bool) bool {
	return collector.find_matching_tag(tag, no_older_versions) != none
}

pub fn (collector BottleTagCollector) specification_for(tag BottleTag,
	no_older_versions bool) ?BottleTagSpecification {
	matching := collector.find_matching_tag(tag, no_older_versions) or { return none }
	return collector.tag_specs[matching.symbol()]
}
