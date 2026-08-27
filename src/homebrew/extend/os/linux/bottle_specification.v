module linux

import brew_runtime

// Translated from Homebrew/brew `extend/os/linux/bottle_specification.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `skip_relocation?(tag: Utils::Bottles.tag, tab: nil)` at line 8.
pub fn ruby_bottle_specification_l8_d1_skip_relocation(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skip_relocation?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Linux
// 6:     module BottleSpecification
// 7:       sig { params(tag: Utils::Bottles::Tag, tab: T.nilable(Tab)).returns(T::Boolean) }
// 8:       def skip_relocation?(tag: Utils::Bottles.tag, tab: nil)
// 9:         # Homebrew versions prior to 5.1.15 generated incorrect :any_skip_relocation
// 10:         !tab.nil? && tab.parsed_homebrew_version >= "5.1.15" && super
// 11:       end
// 12:     end
// 13:   end
// 14: end
// 15:
// 16: BottleSpecification.prepend(OS::Linux::BottleSpecification)
