module env

import ruby

// Translated from Homebrew/brew `extend/os/linux/extend/ENV/std.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `setup_build_environment(formula: nil, cc: nil, build_bottle: false, bottle_arch: nil,` at line 21.
pub fn ruby_std_l21_d1_setup_build_environment(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'environment is required')
	}
	mut environment := linux_std_env_from_value(args[0])
	formula := if args.len > 1 && args[1].type_name != 'NilClass' {
		?LinuxStdFormula(LinuxStdFormula{
			include_path: args[1].attributes['include'] or { '' }
			lib_path: args[1].attributes['lib'] or { '' }
		})
	} else {
		none
	}
	environment.setup_build_environment(formula)
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `libxml2` at line 37.
pub fn ruby_std_l37_d2_libxml2(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'environment is required')
	}
	mut environment := linux_std_env_from_value(args[0])
	environment.libxml2()
	return ruby.object_value('NilClass', 'nil')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Linux
// 6:     module Stdenv
// 7:       extend T::Helpers
// 8:
// 9:       requires_ancestor { ::SharedEnvExtension }
// 10:
// 11:       sig {
// 12:         params(
// 13:           formula:         T.nilable(::Formula),
// 14:           cc:              T.nilable(String),
// 15:           build_bottle:    T.nilable(T::Boolean),
// 16:           bottle_arch:     T.nilable(String),
// 17:           testing_formula: T::Boolean,
// 18:           debug_symbols:   T.nilable(T::Boolean),
// 19:         ).void
// 20:       }
// 21:       def setup_build_environment(formula: nil, cc: nil, build_bottle: false, bottle_arch: nil,
// 22:                                   testing_formula: false, debug_symbols: false)
// 23:         super
// 24:
// 25:         prepend_path "CPATH", HOMEBREW_PREFIX/"include"
// 26:         prepend_path "LIBRARY_PATH", HOMEBREW_PREFIX/"lib"
// 27:         prepend_path "LD_RUN_PATH", HOMEBREW_PREFIX/"lib"
// 28:
// 29:         return unless formula
// 30:
// 31:         prepend_path "CPATH", formula.include
// 32:         prepend_path "LIBRARY_PATH", formula.lib
// 33:         prepend_path "LD_RUN_PATH", formula.lib
// 34:       end
// 35:
// 36:       sig { void }
// 37:       def libxml2
// 38:         append "CPPFLAGS", "-I#{::Formula["libxml2"].include/"libxml2"}"
// 39:       rescue FormulaUnavailableError
// 40:         nil
// 41:       end
// 42:     end
// 43:   end
// 44: end
// 45:
// 46: Stdenv.prepend(OS::Linux::Stdenv)
