module env

import ruby

// Translated from Homebrew/brew `extend/os/linux/extend/ENV/std.rb`.
pub struct LinuxStdFormula {
pub:
	include_path string
	lib_path     string
}

@[heap]
pub struct LinuxStdEnv {
pub:
	homebrew_prefix string = '/home/linuxbrew/.linuxbrew'
	libxml2_include ?string
pub mut:
	values      map[string]string
	super_calls int
}

fn (mut environment LinuxStdEnv) prepend_path(name string, path string) {
	current := environment.values[name] or { '' }
	environment.values[name] = if current == '' {
		path
	} else if path in current.split(':') {
		current
	} else {
		'${path}:${current}'
	}
}

pub fn (mut environment LinuxStdEnv) setup_build_environment(formula ?LinuxStdFormula) {
	environment.super_calls++
	prefix_include := '${environment.homebrew_prefix.trim_right('/')}/include'
	prefix_lib := '${environment.homebrew_prefix.trim_right('/')}/lib'
	environment.prepend_path('CPATH', prefix_include)
	environment.prepend_path('LIBRARY_PATH', prefix_lib)
	environment.prepend_path('LD_RUN_PATH', prefix_lib)
	if value := formula {
		environment.prepend_path('CPATH', value.include_path)
		environment.prepend_path('LIBRARY_PATH', value.lib_path)
		environment.prepend_path('LD_RUN_PATH', value.lib_path)
	}
}

pub fn (mut environment LinuxStdEnv) libxml2() {
	include_path := environment.libxml2_include or { return }
	flag := '-I${include_path.trim_right('/')}/libxml2'
	current := environment.values['CPPFLAGS'] or { '' }
	environment.values['CPPFLAGS'] = if current == '' { flag } else { '${current} ${flag}' }
}

fn linux_std_env_value(environment &LinuxStdEnv) ruby.Value {
	return ruby.structured_value('OS::Linux::Stdenv', '', {
		'linux_std_env_address': u64(voidptr(environment)).str()
	})
}

fn linux_std_env_from_value(value ruby.Value) &LinuxStdEnv {
	address := value.attributes['linux_std_env_address'] or { panic('invalid Linux Stdenv') }
	return unsafe { &LinuxStdEnv(voidptr(address.u64())) }
}

pub fn linux_std_env_boundary(environment &LinuxStdEnv) ruby.Value {
	return linux_std_env_value(environment)
}
