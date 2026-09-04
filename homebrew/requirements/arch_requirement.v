module requirements

// Translated from Homebrew/brew `requirements/arch_requirement.rb`.
pub struct ArchRequirement {
pub:
	arch  ?string
	tags  []string
	fatal bool = true
}

pub fn new_arch_requirement(tags []string) ArchRequirement {
	if tags.len == 0 {
		return ArchRequirement{}
	}
	return ArchRequirement{
		arch: tags[0]
		tags: tags[1..].clone()
	}
}

pub fn current_cpu_architecture() string {
	$if amd64 {
		return 'x86_64'
	} $else $if arm64 {
		return 'arm64'
	} $else $if arm32 {
		return 'arm'
	} $else $if i386 {
		return 'i386'
	} $else {
		return 'dunno'
	}
}

pub fn current_cpu_type() string {
	architecture := current_cpu_architecture()
	if architecture in ['x86_64', 'i386'] {
		return 'intel'
	}
	if architecture in ['arm64', 'arm'] {
		return 'arm'
	}
	if architecture.starts_with('ppc') {
		return 'ppc'
	}
	return 'dunno'
}

pub fn current_cpu_bits() int {
	return if current_cpu_architecture() in ['x86_64', 'arm64', 'ppc64', 'ppc64le'] {
		64
	} else {
		32
	}
}

pub fn (requirement ArchRequirement) satisfied_for(cpu_type string, bits int) bool {
	architecture := requirement.arch or { return false }
	return match architecture {
		'x86_64' { cpu_type == 'intel' && bits == 64 }
		'arm64' { cpu_type == 'arm' && bits == 64 }
		'arm', 'intel', 'ppc' { cpu_type == architecture }
		else { false }
	}
}

pub fn (requirement ArchRequirement) satisfied() bool {
	return requirement.satisfied_for(current_cpu_type(), current_cpu_bits())
}

pub fn (requirement ArchRequirement) message() string {
	architecture := requirement.arch or { '' }
	return 'The ${architecture} architecture is required for this software.'
}

fn requirement_tags_inspect(tags []string) string {
	return '[${tags.map(':\${it}').join(', ')}]'
}

pub fn (requirement ArchRequirement) inspect() string {
	architecture := requirement.arch or { '' }
	return '#<ArchRequirement: arch="${architecture}" ${requirement_tags_inspect(requirement.tags)}>'
}

pub fn (requirement ArchRequirement) display_s() string {
	architecture := requirement.arch or { '' }
	return '${architecture} architecture'
}
