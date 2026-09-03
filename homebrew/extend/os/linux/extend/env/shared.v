module env

// Translated from Homebrew/brew `extend/os/linux/extend/ENV/shared.rb`.
// The original source is retained below until every stub has a typed V body.
pub fn linux_effective_arch(build_bottle bool, bottle_arch string, oldest_cpu string,
	is_intel bool, is_arm bool) string {
	if build_bottle && bottle_arch != '' {
		return bottle_arch
	}
	if build_bottle {
		return oldest_cpu
	}
	if is_intel || is_arm {
		return 'native'
	}
	return 'dunno'
}

// Ruby method `effective_arch` at line 12.
pub fn ruby_shared_l12_d1_effective_arch(build_bottle bool, bottle_arch string,
	oldest_cpu string, is_intel bool, is_arm bool) string {
	return linux_effective_arch(build_bottle, bottle_arch, oldest_cpu, is_intel, is_arm)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Linux
// 6:     module SharedEnvExtension
// 7:       extend T::Helpers
// 8:
// 9:       requires_ancestor { ::SharedEnvExtension }
// 10:
// 11:       sig { returns(Symbol) }
// 12:       def effective_arch
// 13:         if build_bottle? && (bottle_arch = self.bottle_arch)
// 14:           bottle_arch.to_sym
// 15:         elsif build_bottle?
// 16:           ::Hardware.oldest_cpu
// 17:         elsif ::Hardware::CPU.intel? || ::Hardware::CPU.arm?
// 18:           :native
// 19:         else
// 20:           :dunno
// 21:         end
// 22:       end
// 23:     end
// 24:   end
// 25: end
// 26:
// 27: SharedEnvExtension.prepend(OS::Linux::SharedEnvExtension)
