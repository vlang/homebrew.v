module language

import ruby
import homebrew.utils

// Translated from Homebrew/brew `language/php.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `php_shebang_rewrite_info(php_path)` at line 27.
pub fn ruby_php_l27_d1_php_shebang_rewrite_info(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'PHP path is required')
	}
	info := php_shebang_rewrite_info(args[0].as_string()) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	return utils.rewrite_info_value(info)
}

// Ruby method `detected_php_shebang(formula = T.cast(self, Formula))` at line 36.
pub fn ruby_php_l36_d2_detected_php_shebang(args ...ruby.Value) ruby.Value {
	dependencies := if args.len > 0 {
		php_dependencies_from_value(args[0])
	} else {
		[]PhpDependency{}
	}
	prefix := if args.len > 1 { args[1].as_string() } else { '/opt/homebrew' }
	info := detected_php_shebang(dependencies, prefix) or {
		return ruby.object_value('ShebangDetectionError', err.msg())
	}
	return utils.rewrite_info_value(info)
}

pub struct PhpDependency {
pub:
	name     string
	required bool = true
}

pub fn php_shebang_rewrite_info(php_path string) !utils.RewriteInfo {
	if php_path.trim_space() == '' {
		return error('PHP path is required')
	}
	return utils.new_shebang_rewrite_info(r'^#! ?(?:/usr/bin/(?:env )?)?php( |$)', '#! /usr/bin/env php '.len, '${php_path}\\1')
}

pub fn detected_php_shebang(dependencies []PhpDependency, prefix string) !utils.RewriteInfo {
	php_dependencies := dependencies.filter(it.required && (it.name == 'php' || it.name.starts_with('php@')))
	if php_dependencies.len == 0 {
		return error('Cannot detect PHP shebang: formula does not depend on PHP.')
	}
	if php_dependencies.len > 1 {
		return error('Cannot detect PHP shebang: formula has multiple PHP dependencies.')
	}
	php_path := '${prefix.trim_right('/')}/opt/${php_dependencies[0].name}/bin/php'
	return php_shebang_rewrite_info(php_path)
}

fn php_dependency_from_value(value ruby.Value) PhpDependency {
	if value.type_name == 'String' {
		return PhpDependency{ name: value.as_string() }
	}
	return PhpDependency{
		name: value.attribute('name') or { value.as_string() }
		required: (value.attribute('required') or { 'true' }) == 'true'
	}
}

fn php_dependencies_from_value(value ruby.Value) []PhpDependency {
	values := if value.type_name == 'Array' {
		value.as_array() or { [] }
	} else {
		[
			value,
		]
	}
	return values.map(php_dependency_from_value(it))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/path"
// 5:
// 6: module Language
// 7:   # Helper functions for PHP formulae.
// 8:   #
// 9:   # @api public
// 10:   module PHP
// 11:     # Helper module for replacing `php` shebangs.
// 12:     module Shebang
// 13:       extend T::Helpers
// 14:
// 15:       requires_ancestor { Formula }
// 16:
// 17:       module_function
// 18:
// 19:       # A regex to match potential shebang permutations.
// 20:       PHP_SHEBANG_REGEX = %r{\A#! ?(?:/usr/bin/(?:env )?)?php( |$)}
// 21:
// 22:       # The length of the longest shebang matching `SHEBANG_REGEX`.
// 23:       PHP_SHEBANG_MAX_LENGTH = T.let("#! /usr/bin/env php ".length, Integer)
// 24:
// 25:       # @private
// 26:       sig { params(php_path: T.any(String, Pathname)).returns(Utils::Shebang::RewriteInfo) }
// 27:       def php_shebang_rewrite_info(php_path)
// 28:         Utils::Shebang::RewriteInfo.new(
// 29:           PHP_SHEBANG_REGEX,
// 30:           PHP_SHEBANG_MAX_LENGTH,
// 31:           "#{php_path}\\1",
// 32:         )
// 33:       end
// 34:
// 35:       sig { params(formula: Formula).returns(Utils::Shebang::RewriteInfo) }
// 36:       def detected_php_shebang(formula = T.cast(self, Formula))
// 37:         php_deps = formula.deps.select(&:required?).map(&:name).grep(/^php(@.+)?$/)
// 38:         raise ShebangDetectionError.new("PHP", "formula does not depend on PHP") if php_deps.empty?
// 39:         raise ShebangDetectionError.new("PHP", "formula has multiple PHP dependencies") if php_deps.length > 1
// 40:
// 41:         php_shebang_rewrite_info(Utils::Path.formula_opt_bin(php_deps.first)/"php")
// 42:       end
// 43:     end
// 44:   end
// 45: end
