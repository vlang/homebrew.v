module env

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

// Translated from Homebrew/brew `extend/os/mac/extend/ENV/shared.rb`.
