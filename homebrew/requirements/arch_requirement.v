module requirements

// Translated from Homebrew/brew `requirements/arch_requirement.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby attr_reader `attr_reader :arch` at line 15.
pub fn ruby_arch_requirement_l15_d1_arch(requirement ArchRequirement) ?string {
	return requirement.arch
}

// Ruby method `initialize(tags)` at line 18.
pub fn ruby_arch_requirement_l18_d2_initialize(tags []string) ArchRequirement {
	return new_arch_requirement(tags)
}

// Ruby method `message` at line 32.
pub fn ruby_arch_requirement_l32_d3_message(requirement ArchRequirement) string {
	return requirement.message()
}

// Ruby method `inspect` at line 37.
pub fn ruby_arch_requirement_l37_d4_inspect(requirement ArchRequirement) string {
	return requirement.inspect()
}

// Ruby method `display_s` at line 42.
pub fn ruby_arch_requirement_l42_d5_display_s(requirement ArchRequirement) string {
	return requirement.display_s()
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "requirement"
// 5:
// 6: # A requirement on a specific architecture.
// 7: class ArchRequirement < Requirement
// 8:   Cache = type_template { { fixed: T::Hash[String, T.untyped] } }
// 9:
// 10:   fatal true
// 11:
// 12:   @arch = T.let(nil, T.nilable(Symbol))
// 13:
// 14:   sig { returns(T.nilable(Symbol)) }
// 15:   attr_reader :arch
// 16:
// 17:   sig { params(tags: T::Array[Symbol]).void }
// 18:   def initialize(tags)
// 19:     @arch = T.let(tags.shift, T.nilable(Symbol))
// 20:     super
// 21:   end
// 22:
// 23:   satisfy(build_env: false) do
// 24:     case @arch
// 25:     when :x86_64 then Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
// 26:     when :arm64 then Hardware::CPU.arm64?
// 27:     when :arm, :intel, :ppc then Hardware::CPU.type == @arch
// 28:     end
// 29:   end
// 30:
// 31:   sig { returns(String) }
// 32:   def message
// 33:     "The #{@arch} architecture is required for this software."
// 34:   end
// 35:
// 36:   sig { returns(String) }
// 37:   def inspect
// 38:     "#<#{self.class.name}: arch=#{@arch.to_s.inspect} #{tags.inspect}>"
// 39:   end
// 40:
// 41:   sig { returns(String) }
// 42:   def display_s
// 43:     "#{@arch} architecture"
// 44:   end
// 45: end
