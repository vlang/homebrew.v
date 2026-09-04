module cmd

import ruby

// Translated from Homebrew/brew `extend/os/linux/cmd/info.rb`.

// Ruby method `requirement_for_other_os?(requirement)` at line 11.
pub fn ruby_info_l11_d1_requirement_for_other_os(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len > 0 && requirement_for_other_os(args[0].type_name))
}

pub fn requirement_for_other_os(requirement_type string) bool {
	return requirement_type == 'MacOSRequirement'
}
