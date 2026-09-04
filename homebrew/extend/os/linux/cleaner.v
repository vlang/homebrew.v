module linux

import ruby

// Translated from Homebrew/brew `extend/os/linux/cleaner.rb`.

// Ruby method `executable_path?(path)` at line 10.
pub fn ruby_cleaner_l10_d1_executable_path(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(args.len >= 2 && executable_path(args[0].as_bool() or { false }, args[1].as_bool() or {
		false
	}))
}

pub fn executable_path(text_executable bool, elf_executable bool) bool {
	return text_executable || elf_executable
}
