module utils

import ruby

// Translated from Homebrew/brew `utils/user.rb`.

pub struct User {
pub:
	name string
}

pub fn current_user() ?User {
	name := ruby.current_username()
	if name == '' {
		return none
	}
	return User{
		name: name
	}
}

pub fn (user User) gui_from_who_output(output string, command_succeeded bool) bool {
	if !command_succeeded {
		return false
	}
	for line in output.split_into_lines() {
		fields := line.fields()
		if fields.len >= 2 && fields[0] == user.name && fields[1] == 'console' {
			return true
		}
	}
	return false
}

pub fn (user User) gui() bool {
	who := ruby.find_executable('who') or { return false }
	result := ruby.run_command(who, [])
	return user.gui_from_who_output(result.output, result.exit_code == 0)
}

pub fn (user User) str() string {
	return user.name
}
