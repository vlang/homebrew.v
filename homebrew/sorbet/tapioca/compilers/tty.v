module compilers

import ruby

// Translated from Homebrew/brew `sorbet/tapioca/compilers/tty.rb`.
pub const tty_compiler_dynamic_methods = ['red', 'green', 'yellow', 'blue', 'magenta', 'cyan',
	'default', 'reset', 'bold', 'italic', 'underline', 'strikethrough', 'no_underline', 'up', 'down',
	'right', 'left', 'erase_line', 'erase_char']

pub fn tty_compiler_decoration(constant_name string) TapiocaDecoration {
	return TapiocaDecoration{
		constant_name: constant_name
		kind: 'module'
		methods: tty_compiler_dynamic_methods.map(TapiocaGeneratedMethod{
			name: it
			return_type: 'String'
			class_method: true
		})
	}
}
