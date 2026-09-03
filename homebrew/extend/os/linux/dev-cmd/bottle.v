module dev_cmd

// Translated from Homebrew/brew `extend/os/linux/dev-cmd/bottle.rb`.
// The original source is retained below until every stub has a typed V body.
pub fn linux_formula_ignores(formula_name string, cellar string, prefix string,
	base_ignores []string) []string {
	mut ignores := base_ignores.clone()
	if formula_name == 'gcc' || formula_name.starts_with('gcc@') {
		ignores << '${cellar}/gcc|${prefix}/opt/gcc'
	} else if formula_name == 'binutils' || formula_name.starts_with('binutils@') {
		ignores << '${cellar}/binutils'
	}
	return ignores
}

// Ruby method `formula_ignores(formula)` at line 9.
pub fn ruby_bottle_l9_d1_formula_ignores(formula_name string, cellar string, prefix string,
	base_ignores []string) []string {
	return linux_formula_ignores(formula_name, cellar, prefix, base_ignores)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Linux
// 6:     module DevCmd
// 7:       module Bottle
// 8:         sig { params(formula: Formula).returns(T::Array[Regexp]) }
// 9:         def formula_ignores(formula)
// 10:           ignores = super
// 11:
// 12:           cellar_regex = Regexp.escape(HOMEBREW_CELLAR)
// 13:           prefix_regex = Regexp.escape(HOMEBREW_PREFIX)
// 14:
// 15:           ignores << case formula.name
// 16:           # On Linux, GCC installation can be moved so long as the whole directory tree is moved together:
// 17:           # https://gcc-help.gcc.gnu.narkive.com/GnwuCA7l/moving-gcc-from-the-installation-path-is-it-allowed.
// 18:           when Version.formula_optionally_versioned_regex(:gcc)
// 19:             Regexp.union(%r{#{cellar_regex}/gcc}, %r{#{prefix_regex}/opt/gcc})
// 20:           # binutils is relocatable for the same reason: https://github.com/Homebrew/brew/pull/11899#issuecomment-906804451.
// 21:           when Version.formula_optionally_versioned_regex(:binutils)
// 22:             %r{#{cellar_regex}/binutils}
// 23:           end
// 24:
// 25:           ignores.compact
// 26:         end
// 27:       end
// 28:     end
// 29:   end
// 30: end
// 31:
// 32: Homebrew::DevCmd::Bottle.prepend(OS::Linux::DevCmd::Bottle)
