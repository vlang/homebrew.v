module requirements

import ruby
import homebrew
import homebrew.requirements as requirement_api

pub fn macos_requirement_satisfied(requirement requirement_api.MacOSRequirement,
	current homebrew.MacOSVersion) bool {
	return requirement.satisfied_on(current, true)
}

pub fn macos_requirement_message(requirement requirement_api.MacOSRequirement,
	dependent_type string) string {
	return requirement.message(dependent_type, true)
}

fn macos_requirement_from_boundary(args []ruby.Value) !requirement_api.MacOSRequirement {
	versions := if args.len > 0 && args[0].type_name == 'Array' {
		args[0].as_string_array()!
	} else {
		[]string{}
	}
	comparator := if args.len > 1 { args[1].as_string() } else { '>=' }
	if versions.len > 1 && comparator == '==' {
		return requirement_api.new_macos_range_requirement(versions, []string{})
	}
	return requirement_api.new_macos_requirement(versions, comparator)
}

// Translated from Homebrew/brew `extend/os/mac/requirements/macos_requirement.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `macos_version_satisfied?` at line 12.
pub fn ruby_macos_requirement_l12_d1_macos_version_satisfied(args ...ruby.Value) ruby.Value {
	requirement := macos_requirement_from_boundary(args) or { panic(err) }
	current_index := if args.len > 0 && args[0].type_name == 'Array' { 2 } else { 0 }
	current_text := if args.len > current_index { args[current_index].as_string() } else { '26.0' }
	current := homebrew.new_macos_version(current_text) or { panic(err) }
	return ruby.bool_value(macos_requirement_satisfied(requirement, current))
}

// Ruby method `message(type: :formula)` at line 17.
pub fn ruby_macos_requirement_l17_d2_message(args ...ruby.Value) ruby.Value {
	requirement := macos_requirement_from_boundary(args) or { panic(err) }
	type_index := if args.len > 0 && args[0].type_name == 'Array' { 2 } else { 0 }
	dependent_type := if args.len > type_index { args[type_index].as_string() } else { 'formula' }
	return ruby.string_value(macos_requirement_message(requirement, dependent_type))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Mac
// 6:     module MacOSRequirement
// 7:       extend T::Helpers
// 8:
// 9:       requires_ancestor { ::MacOSRequirement }
// 10:
// 11:       sig { returns(T::Boolean) }
// 12:       def macos_version_satisfied?
// 13:         !version_specified? || Array(version).any? { |v| OS::Mac.version.compare(comparator, v) }
// 14:       end
// 15:
// 16:       sig { params(type: Symbol).returns(String) }
// 17:       def message(type: :formula)
// 18:         subject = (type == :cask) ? "This cask" : "This formula"
// 19:
// 20:         return "#{subject} requires macOS." unless version_specified?
// 21:
// 22:         case comparator
// 23:         when ">="
// 24:           "#{subject} does not run on macOS versions older than #{T.cast(version, MacOSVersion).pretty_name}."
// 25:         when "<="
// 26:           case type
// 27:           when :formula
// 28:             <<~EOS
// 29:               #{subject} either does not compile or function as expected on macOS
// 30:               versions newer than #{T.cast(version, MacOSVersion).pretty_name} due to an upstream incompatibility.
// 31:             EOS
// 32:           when :cask
// 33:             "#{subject} does not run on macOS versions newer than #{T.cast(version, MacOSVersion).pretty_name}."
// 34:           else
// 35:             ""
// 36:           end
// 37:         else
// 38:           if version.respond_to?(:to_ary) || version.is_a?(Array)
// 39:             *versions, last = T.unsafe(version).map(&:pretty_name)
// 40:             return "#{subject} does not run on macOS versions other than #{versions.join(", ")} and #{last}."
// 41:           end
// 42:
// 43:           "#{subject} does not run on macOS versions other than #{T.cast(version, MacOSVersion).pretty_name}."
// 44:         end
// 45:       end
// 46:     end
// 47:   end
// 48: end
// 49:
// 50: MacOSRequirement.prepend(OS::Mac::MacOSRequirement)
