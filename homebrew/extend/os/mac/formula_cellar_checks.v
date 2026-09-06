module mac

pub struct MacCellarMachFile {
pub:
	path             string
	dylib            bool
	linked_libraries []string
	two_level_slices []bool
}

pub struct MacFormulaCellarState {
pub:
	name                       string
	prefix                     string
	include_path               string
	lib_path                   string
	keg_only                   bool
	prefix_exists              bool
	include_exists             bool
	include_headers            []string
	system_headers             []string
	mach_files                 []MacCellarMachFile
	python_modules             []MacCellarMachFile
	broken_library_linkage     bool
	linkage_display            string
	poured_from_bottle         bool
	tap_issues_url             string
	flat_namespace_allowlisted bool
	base_library_extensions    []string
}

pub struct MacCellarCheck {
pub:
	present bool
	output  string
}

fn mac_cellar_join_paths(paths []string) string {
	return paths.join('\n  ')
}

pub fn mac_formula_check_shadowed_headers(state MacFormulaCellarState) MacCellarCheck {
	if ['libtool', 'subversion', 'berkeley-db'].any(state.name.starts_with(it)) || state.name == 'php' || state.name.starts_with('php@') || state.keg_only || !state.include_exists {
		return MacCellarCheck{}
	}
	mut system := map[string]bool{}
	for header in state.system_headers {
		system[header] = true
	}
	mut files := []string{}
	for header in state.include_headers {
		if header in system {
			files << '${state.include_path}/${header}'
		}
	}
	if files.len == 0 {
		return MacCellarCheck{}
	}
	return MacCellarCheck{
		present: true
		output: 'Header files that shadow system header files were installed to "${state.include_path}"\nThe offending files are:\n  ${mac_cellar_join_paths(files)}\n'
	}
}

fn mac_cellar_system_openssl(library string) bool {
	for name in ['crypto', 'ssl', 'tls'] {
		prefix := '/usr/lib/lib${name}.'
		if library.starts_with(prefix) && library.ends_with('dylib') {
			return true
		}
	}
	return false
}

pub fn mac_formula_check_openssl_links(state MacFormulaCellarState) MacCellarCheck {
	if !state.prefix_exists {
		return MacCellarCheck{}
	}
	mut linked := []string{}
	for file in state.mach_files {
		if file.linked_libraries.any(mac_cellar_system_openssl(it)) {
			linked << file.path
		}
	}
	if linked.len == 0 {
		return MacCellarCheck{}
	}
	return MacCellarCheck{
		present: true
		output: 'object files were linked against system openssl\nThese object files were linked against the deprecated system OpenSSL or\nthe system\'s private LibreSSL.\nAdding `depends_on "openssl"` to the formula may help.\n  ${mac_cellar_join_paths(linked)}\n'
	}
}

pub fn mac_formula_check_python_framework_links(state MacFormulaCellarState) MacCellarCheck {
	mut linked := []string{}
	for file in state.python_modules {
		if file.linked_libraries.any(it.contains('Python.framework')) {
			linked << file.path
		}
	}
	if linked.len == 0 {
		return MacCellarCheck{}
	}
	return MacCellarCheck{
		present: true
		output: 'python modules have explicit framework links\nThese python extension modules were linked directly to a Python\nframework binary. They should be linked with -undefined dynamic_lookup\ninstead of -lpython or -framework Python.\n  ${mac_cellar_join_paths(linked)}\n'
	}
}

pub fn mac_formula_check_linkage(state MacFormulaCellarState) MacCellarCheck {
	if !state.prefix_exists || !state.broken_library_linkage {
		return MacCellarCheck{}
	}
	mut output := '${state.name} has broken dynamic library links:\n  ${state.linkage_display}\n'
	if state.poured_from_bottle {
		issue := if state.tap_issues_url == '' { '.' } else { ' here:\n  ${state.tap_issues_url}' }
		output += "Rebuild this from source with:\n  brew reinstall --build-from-source ${state.name}\nIf that's successful, file an issue${issue}\n"
	}
	return MacCellarCheck{ present: true, output: output }
}

pub fn mac_formula_check_flat_namespace(state MacFormulaCellarState) MacCellarCheck {
	if !state.prefix_exists || state.flat_namespace_allowlisted {
		return MacCellarCheck{}
	}
	mut flat := []string{}
	for file in state.mach_files {
		if file.dylib && file.two_level_slices.any(!it) {
			flat << file.path
		}
	}
	if flat.len == 0 {
		return MacCellarCheck{}
	}
	return MacCellarCheck{
		present: true
		output: 'Libraries were compiled with a flat namespace.\nThis can cause linker errors due to name collisions and\nis often due to a bug in detecting the macOS version.\n  ${mac_cellar_join_paths(flat)}\n Learn more about this in:\n  https://developer.apple.com/forums/thread/689991?answerId=687895022#687895022\n'
	}
}

pub fn mac_formula_audit_installed(state MacFormulaCellarState) []string {
	checks := [
		mac_formula_check_shadowed_headers(state),
		mac_formula_check_openssl_links(state),
		mac_formula_check_python_framework_links(state),
		mac_formula_check_linkage(state),
		mac_formula_check_flat_namespace(state),
	]
	return checks.filter(it.present).map(it.output)
}

pub fn mac_formula_valid_library_extension(filename string,
	base_extensions []string) bool {
	dot := filename.last_index('.') or { return false }
	extension := filename[dot..]
	return extension in base_extensions || extension in ['.dylib', '.framework']
}

// Translated from Homebrew/brew `extend/os/mac/formula_cellar_checks.rb`.
