module language

import ruby
import homebrew.utils

// Translated from Homebrew/brew `language/php.rb`.

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
