module pathname

import ruby

// Translated from Homebrew/brew `extend/os/linux/extend/pathname/os.rb`.

// Ruby method `activate_extensions!` at line 13.
pub fn ruby_os_l13_d1_activate_extensions(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(active_pathname_extensions())
}

pub fn active_pathname_extensions() []string {
	return ['WriteMkpathExtension', 'ELFShim']
}
