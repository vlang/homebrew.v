module cmd

import ruby

// Translated from Homebrew/brew `extend/os/linux/cmd/info.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `requirement_for_other_os?(requirement)` at line 11.
pub fn ruby_info_l11_d1_requirement_for_other_os(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && requirement_for_other_os(args[0].type_name))
}

pub fn requirement_for_other_os(requirement_type string) bool {
	return requirement_type == 'MacOSRequirement'
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Linux
// 6:     module Cmd
// 7:       module Info
// 8:         private
// 9:
// 10:         sig { params(requirement: Requirement).returns(T::Boolean) }
// 11:         def requirement_for_other_os?(requirement)
// 12:           requirement.instance_of?(::MacOSRequirement)
// 13:         end
// 14:       end
// 15:     end
// 16:   end
// 17: end
// 18:
// 19: Homebrew::Cmd::Info.singleton_class.prepend(OS::Linux::Cmd::Info)
