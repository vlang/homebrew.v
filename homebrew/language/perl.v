module language

import ruby
import homebrew.utils

// Translated from Homebrew/brew `language/perl.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `perl_shebang_rewrite_info(perl_path)` at line 27.
pub fn ruby_perl_l27_d1_perl_shebang_rewrite_info(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'Perl path is required')
	}
	info := perl_shebang_rewrite_info(args[0].as_string()) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	return utils.rewrite_info_value(info)
}

// Ruby method `detected_perl_shebang(formula = T.cast(self, Formula))` at line 36.
pub fn ruby_perl_l36_d2_detected_perl_shebang(args ...ruby.Value) ruby.Value {
	dependencies := if args.len > 0 {
		perl_dependencies_from_value(args[0])
	} else {
		[]PerlDependency{}
	}
	prefix := if args.len > 1 { args[1].as_string() } else { '/opt/homebrew' }
	preferred_version := if args.len > 2 { args[2].as_string() } else { '' }
	info := detected_perl_shebang(dependencies, prefix, preferred_version) or {
		return ruby.object_value('ShebangDetectionError', err.msg())
	}
	return utils.rewrite_info_value(info)
}

pub struct PerlDependency {
pub:
	name              string
	required          bool = true
	uses_from_macos   bool
	use_macos_install bool
}

pub fn perl_shebang_rewrite_info(perl_path string) !utils.RewriteInfo {
	if perl_path.trim_space() == '' {
		return error('Perl path is required')
	}
	return utils.new_shebang_rewrite_info(r'^#! ?(?:/usr/bin/(?:env )?)?perl( |$)', '#! /usr/bin/env perl '.len, '${perl_path}\\1')
}

pub fn detected_perl_shebang(dependencies []PerlDependency, prefix string,
	preferred_version string) !utils.RewriteInfo {
	perl_dependencies := dependencies.filter(it.required && it.name == 'perl')
	if perl_dependencies.len == 0 {
		return error('Cannot detect Perl shebang: formula does not depend on Perl.')
	}
	use_brewed_perl := perl_dependencies.any(!it.uses_from_macos || !it.use_macos_install)
	perl_path := if use_brewed_perl {
		'${prefix.trim_right('/')}/opt/perl/bin/perl'
	} else {
		'/usr/bin/perl${preferred_version}'
	}
	return perl_shebang_rewrite_info(perl_path)
}

fn perl_dependency_from_value(value ruby.Value) PerlDependency {
	if value.type_name == 'String' {
		return PerlDependency{ name: value.as_string() }
	}
	return PerlDependency{
		name: value.attribute('name') or { value.as_string() }
		required: (value.attribute('required') or { 'true' }) == 'true'
		uses_from_macos: (value.attribute('uses_from_macos') or { 'false' }) == 'true'
		use_macos_install: (value.attribute('use_macos_install') or { 'false' }) == 'true'
	}
}

fn perl_dependencies_from_value(value ruby.Value) []PerlDependency {
	values := if value.type_name == 'Array' {
		value.as_array() or { [] }
	} else {
		[
			value,
		]
	}
	return values.map(perl_dependency_from_value(it))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/path"
// 5:
// 6: module Language
// 7:   # Helper functions for Perl formulae.
// 8:   #
// 9:   # @api public
// 10:   module Perl
// 11:     # Helper module for replacing `perl` shebangs.
// 12:     module Shebang
// 13:       extend T::Helpers
// 14:
// 15:       requires_ancestor { Formula }
// 16:
// 17:       module_function
// 18:
// 19:       # A regex to match potential shebang permutations.
// 20:       PERL_SHEBANG_REGEX = %r{\A#! ?(?:/usr/bin/(?:env )?)?perl( |$)}
// 21:
// 22:       # The length of the longest shebang matching `SHEBANG_REGEX`.
// 23:       PERL_SHEBANG_MAX_LENGTH = T.let("#! /usr/bin/env perl ".length, Integer)
// 24:
// 25:       # @private
// 26:       sig { params(perl_path: T.any(String, Pathname)).returns(Utils::Shebang::RewriteInfo) }
// 27:       def perl_shebang_rewrite_info(perl_path)
// 28:         Utils::Shebang::RewriteInfo.new(
// 29:           PERL_SHEBANG_REGEX,
// 30:           PERL_SHEBANG_MAX_LENGTH,
// 31:           "#{perl_path}\\1",
// 32:         )
// 33:       end
// 34:
// 35:       sig { params(formula: Formula).returns(Utils::Shebang::RewriteInfo) }
// 36:       def detected_perl_shebang(formula = T.cast(self, Formula))
// 37:         perl_deps = formula.declared_deps.select { |dep| dep.required? && dep.name == "perl" }
// 38:         raise ShebangDetectionError.new("Perl", "formula does not depend on Perl") if perl_deps.empty?
// 39:
// 40:         perl_path = if perl_deps.any? { |dep| !dep.uses_from_macos? || !dep.use_macos_install? }
// 41:           Utils::Path.formula_opt_bin("perl")/"perl"
// 42:         else
// 43:           "/usr/bin/perl#{MacOS.preferred_perl_version}"
// 44:         end
// 45:
// 46:         perl_shebang_rewrite_info(perl_path)
// 47:       end
// 48:     end
// 49:   end
// 50: end
