module language

import ruby
import homebrew.utils

// Translated from Homebrew/brew `language/perl.rb`.

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
