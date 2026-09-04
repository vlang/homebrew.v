module requirements

import ruby
import homebrew
import x.json2

// Translated from Homebrew/brew `requirements/macos_requirement.rb`.
pub struct MacOSRequirement {
pub:
	comparator string
	versions   []homebrew.MacOSVersion
	tags       []string
	fatal      bool = true
}

struct MacOSComparisonArgument {
	comparator string
	version    string
}

pub fn macos_oldest_allowed_version() homebrew.MacOSVersion {
	configured := ruby.environment_value('HOMEBREW_MACOS_OLDEST_ALLOWED')
	value := if configured.len > 0 { configured } else { '10.15' }
	return homebrew.new_macos_version(value) or { panic(err) }
}

pub fn macos_newest_unsupported_version() homebrew.MacOSVersion {
	configured := ruby.environment_value('HOMEBREW_MACOS_NEWEST_UNSUPPORTED')
	value := if configured.len > 0 { configured } else { '27' }
	return homebrew.new_macos_version(value) or { panic(err) }
}

fn macos_requirement_version(value string) !homebrew.MacOSVersion {
	if value in homebrew.macos_symbol_versions() {
		return homebrew.macos_version_from_symbol(value)
	}
	return homebrew.new_macos_version(value)
}

fn disabled_macos_requirement_version(value string) bool {
	return value in ['mojave', 'high_sierra', 'sierra', 'el_capitan']
}

fn macos_comparison_argument(value string) ?MacOSComparisonArgument {
	trimmed := value.trim_space()
	for comparator in ['<=', '>=', '==', '<', '>'] {
		if trimmed.starts_with(comparator) {
			mut version := trimmed[comparator.len..].trim_space()
			if version.starts_with(':') {
				version = version[1..]
			}
			if version.len == 0 || version.contains(' ') || version.contains('\t') {
				return none
			}
			return MacOSComparisonArgument{
				comparator: comparator
				version: version
			}
		}
	}
	return none
}

pub fn new_macos_requirement(tags []string, comparator string) !MacOSRequirement {
	comparison := if comparator.len > 0 { comparator } else { '>=' }
	if comparison !in ['>=', '<=', '==', '>', '<'] {
		return error('unsupported macOS requirement comparator `${comparison}`')
	}
	if tags.len == 0 {
		return MacOSRequirement{
			comparator: comparison
		}
	}
	version := macos_requirement_version(tags[0]) or {
		if disabled_macos_requirement_version(tags[0]) {
			return MacOSRequirement{
				comparator: comparison
				versions: if comparison == '>=' {
					[macos_oldest_allowed_version()]
				} else {
					[]homebrew.MacOSVersion{}
				}
				tags: tags[1..].clone()
			}
		}
		return err
	}
	return MacOSRequirement{
		comparator: comparison
		versions: [version]
		tags: tags[1..].clone()
	}
}

pub fn new_macos_range_requirement(version_values []string, tags []string) !MacOSRequirement {
	mut versions := []homebrew.MacOSVersion{}
	for value in version_values {
		version := macos_requirement_version(value) or {
			if disabled_macos_requirement_version(value) {
				continue
			}
			return err
		}
		versions << version
	}
	return MacOSRequirement{
		comparator: '=='
		versions: versions
		tags: tags.clone()
	}
}

pub fn parse_macos_requirement(arguments []string, comparator string) !MacOSRequirement {
	if arguments.len == 0 || arguments[0] == 'any' {
		return new_macos_requirement([]string{}, '>=')
	}
	if arguments.len > 1 {
		return new_macos_range_requirement(arguments, []string{})
	}
	if arguments[0] in homebrew.macos_symbol_versions() {
		return new_macos_requirement(arguments, comparator)
	}
	if comparison := macos_comparison_argument(arguments[0]) {
		return new_macos_requirement([comparison.version], comparison.comparator)
	}
	return new_macos_requirement(arguments, '==')
}

pub fn (requirement MacOSRequirement) version_specified() bool {
	return requirement.versions.len > 0
}

pub fn (requirement MacOSRequirement) macos_version_satisfied() bool {
	return false
}

pub fn (requirement MacOSRequirement) satisfied_on(current homebrew.MacOSVersion,
	running_on_macos bool) bool {
	if !running_on_macos {
		return false
	}
	if !requirement.version_specified() {
		return true
	}
	for version in requirement.versions {
		matches := match requirement.comparator {
			'>=' { current.compare(version) >= 0 }
			'<=' { current.compare(version) <= 0 }
			else { current.compare(version) == 0 }
		}
		if matches {
			return true
		}
	}
	return false
}

pub fn (requirement MacOSRequirement) minimum_version() homebrew.MacOSVersion {
	if requirement.comparator == '<=' || !requirement.version_specified() {
		return macos_oldest_allowed_version()
	}
	mut minimum := requirement.versions[0]
	for version in requirement.versions[1..] {
		if version.compare(minimum) < 0 {
			minimum = version
		}
	}
	return minimum
}

pub fn (requirement MacOSRequirement) maximum_version() homebrew.MacOSVersion {
	if requirement.comparator == '>=' || !requirement.version_specified() {
		return macos_newest_unsupported_version()
	}
	mut maximum := requirement.versions[0]
	for version in requirement.versions[1..] {
		if version.compare(maximum) > 0 {
			maximum = version
		}
	}
	return maximum
}

pub fn (requirement MacOSRequirement) allows(other homebrew.MacOSVersion) bool {
	if !requirement.version_specified() {
		return true
	}
	return match requirement.comparator {
		'>=' { other.compare(requirement.versions[0]) >= 0 }
		'<=' { other.compare(requirement.versions[0]) <= 0 }
		else { requirement.versions.any(it.compare(other) == 0) }
	}
}

pub fn (requirement MacOSRequirement) message(dependent_type string,
	running_on_macos bool) string {
	subject := if dependent_type == 'cask' { 'This cask' } else { 'This formula' }
	if !running_on_macos || !requirement.version_specified() {
		return '${subject} requires macOS.'
	}
	match requirement.comparator {
		'>=' {
			return '${subject} does not run on macOS versions older than ${requirement.versions[0].pretty_name()}.'
		}
		'<=' {
			if dependent_type == 'cask' {
				return '${subject} does not run on macOS versions newer than ${requirement.versions[0].pretty_name()}.'
			}
			return '${subject} either does not compile or function as expected on macOS\nversions newer than ${requirement.versions[0].pretty_name()} due to an upstream incompatibility.\n'
		}
		else {
			pretty_versions := requirement.versions.map(it.pretty_name())
			if pretty_versions.len > 1 {
				return '${subject} does not run on macOS versions other than ${pretty_versions[..pretty_versions.len - 1].join(', ')} and ${pretty_versions.last()}.'
			}
			return '${subject} does not run on macOS versions other than ${pretty_versions[0]}.'
		}
	}
}

pub fn (requirement MacOSRequirement) equals(other MacOSRequirement) bool {
	if requirement.comparator != other.comparator || requirement.tags != other.tags || requirement.versions.len != other.versions.len {
		return false
	}
	for index, version in requirement.versions {
		if version.compare(other.versions[index]) != 0 {
			return false
		}
	}
	return true
}

pub fn (requirement MacOSRequirement) hash_value() i64 {
	mut hash := u64(14695981039346656037)
	for character in '${requirement.comparator}\x00${requirement.versions.map(it.str()).join('\x00')}\x00${requirement.tags.join('\x00')}'.bytes() {
		hash = (hash ^ u64(character)) * u64(1099511628211)
	}
	return i64(hash)
}

pub fn (requirement MacOSRequirement) inspect() string {
	version_text := if requirement.versions.len > 1 {
		'[${requirement.versions.map(it.str()).join(', ')}]'
	} else if requirement.versions.len == 1 {
		requirement.versions[0].str()
	} else {
		''
	}
	return '#<MacOSRequirement: version${requirement.comparator}"${version_text}" ${requirement_tags_inspect(requirement.tags)}>'
}

pub fn (requirement MacOSRequirement) display_s() string {
	if !requirement.version_specified() {
		return 'macOS'
	}
	return 'macOS ${requirement.comparator} ${requirement.versions.map(it.str()).join(' / ')}'
}

pub fn (requirement MacOSRequirement) to_h() map[string][]string {
	if !requirement.version_specified() {
		return map[string][]string{}
	}
	return {
		requirement.comparator: requirement.versions.map(it.str())
	}
}

pub fn (requirement MacOSRequirement) to_json() string {
	return json2.encode(requirement.to_h())
}
