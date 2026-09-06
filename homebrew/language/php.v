module language

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
