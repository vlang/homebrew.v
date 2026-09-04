module env

import ruby

pub fn mac_setup_shared_build_environment(base map[string]string,
	preferred_perl_version string) map[string]string {
	mut environment := base.clone()
	environment['VERSIONER_PERL_VERSION'] = preferred_perl_version
	return environment
}

pub fn mac_no_weak_imports_support(compiler string) bool {
	return compiler.trim_string_left(':') == 'clang'
}

pub fn mac_no_fixup_chains_support(ld64_version int) bool {
	return ld64_version >= 711
}

fn mac_string_map_from_value(value ruby.Value) !map[string]string {
	values := value.as_map()!
	mut result := map[string]string{}
	for key, item in values {
		result[key] = item.as_string()
	}
	return result
}

fn mac_string_map_value(values map[string]string) ruby.Value {
	mut mapped := map[string]ruby.Value{}
	for key, value in values {
		mapped[key] = ruby.string_value(value)
	}
	return ruby.map_value(mapped)
}

// Translated from Homebrew/brew `extend/os/mac/extend/ENV/shared.rb`.
