module mac

import ruby

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

fn mac_cellar_check_value(check MacCellarCheck) ruby.Value {
	if !check.present {
		return ruby.object_value('NilClass', 'nil')
	}
	return ruby.string_value(check.output)
}

fn mac_cellar_string(value ruby.Value, key string) string {
	if key in value.map_data {
		return value.map_data[key].as_string()
	}
	return ''
}

fn mac_cellar_bool(value ruby.Value, key string) bool {
	if key in value.map_data {
		return value.map_data[key].as_bool() or { false }
	}
	return false
}

fn mac_cellar_strings(value ruby.Value, key string) []string {
	if key in value.map_data {
		return value.map_data[key].as_string_array() or { []string{} }
	}
	return []string{}
}

fn mac_cellar_mach_files(value ruby.Value, key string) []MacCellarMachFile {
	if key !in value.map_data {
		return []MacCellarMachFile{}
	}
	mut files := []MacCellarMachFile{}
	for item in value.map_data[key].as_array() or { []ruby.Value{} } {
		mut slices := []bool{}
		if 'two_level_slices' in item.map_data {
			for slice in item.map_data['two_level_slices'].as_array() or { []ruby.Value{} } {
				slices << (slice.as_bool() or { false })
			}
		}
		files << MacCellarMachFile{
			path: mac_cellar_string(item, 'path')
			dylib: mac_cellar_bool(item, 'dylib')
			linked_libraries: mac_cellar_strings(item, 'linked_libraries')
			two_level_slices: slices
		}
	}
	return files
}

pub fn mac_formula_cellar_state_from_value(value ruby.Value) !MacFormulaCellarState {
	if value.type_name != 'Hash' {
		return error('expected Hash cellar state, got ${value.type_name}')
	}
	return MacFormulaCellarState{
		name: mac_cellar_string(value, 'name')
		prefix: mac_cellar_string(value, 'prefix')
		include_path: mac_cellar_string(value, 'include_path')
		lib_path: mac_cellar_string(value, 'lib_path')
		keg_only: mac_cellar_bool(value, 'keg_only')
		prefix_exists: mac_cellar_bool(value, 'prefix_exists')
		include_exists: mac_cellar_bool(value, 'include_exists')
		include_headers: mac_cellar_strings(value, 'include_headers')
		system_headers: mac_cellar_strings(value, 'system_headers')
		mach_files: mac_cellar_mach_files(value, 'mach_files')
		python_modules: mac_cellar_mach_files(value, 'python_modules')
		broken_library_linkage: mac_cellar_bool(value, 'broken_library_linkage')
		linkage_display: mac_cellar_string(value, 'linkage_display')
		poured_from_bottle: mac_cellar_bool(value, 'poured_from_bottle')
		tap_issues_url: mac_cellar_string(value, 'tap_issues_url')
		flat_namespace_allowlisted: mac_cellar_bool(value, 'flat_namespace_allowlisted')
		base_library_extensions: mac_cellar_strings(value, 'base_library_extensions')
	}
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
// The original source is retained below until every stub has a typed V body.

// Ruby method `check_shadowed_headers` at line 16.
pub fn ruby_formula_cellar_checks_l16_d1_check_shadowed_headers(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('check_shadowed_headers requires cellar state') }
	return mac_cellar_check_value(mac_formula_check_shadowed_headers(mac_formula_cellar_state_from_value(args[0]) or { panic(err) }))
}

// Ruby method `check_openssl_links` at line 38.
pub fn ruby_formula_cellar_checks_l38_d2_check_openssl_links(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('check_openssl_links requires cellar state') }
	return mac_cellar_check_value(mac_formula_check_openssl_links(mac_formula_cellar_state_from_value(args[0]) or { panic(err) }))
}

// Ruby method `check_python_framework_links(lib)` at line 58.
pub fn ruby_formula_cellar_checks_l58_d3_check_python_framework_links(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('check_python_framework_links requires cellar state') }
	return mac_cellar_check_value(mac_formula_check_python_framework_links(mac_formula_cellar_state_from_value(args[0]) or { panic(err) }))
}

// Ruby method `check_linkage` at line 77.
pub fn ruby_formula_cellar_checks_l77_d4_check_linkage(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('check_linkage requires cellar state') }
	return mac_cellar_check_value(mac_formula_check_linkage(mac_formula_cellar_state_from_value(args[0]) or { panic(err) }))
}

// Ruby method `check_flat_namespace(formula)` at line 105.
pub fn ruby_formula_cellar_checks_l105_d5_check_flat_namespace(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('check_flat_namespace requires cellar state') }
	return mac_cellar_check_value(mac_formula_check_flat_namespace(mac_formula_cellar_state_from_value(args[0]) or { panic(err) }))
}

// Ruby method `audit_installed` at line 133.
pub fn ruby_formula_cellar_checks_l133_d6_audit_installed(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('audit_installed requires cellar state') }
	return ruby.string_array_value(mac_formula_audit_installed(mac_formula_cellar_state_from_value(args[0]) or { panic(err) }))
}

// Ruby method `valid_library_extension?(filename)` at line 145.
pub fn ruby_formula_cellar_checks_l145_d7_valid_library_extension(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('valid_library_extension? requires a filename') }
	base := if args.len > 1 { args[1].as_string_array() or { panic(err) } } else { []string{} }
	return ruby.bool_value(mac_formula_valid_library_extension(args[0].as_string(), base))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cache_store"
// 5: require "linkage_checker"
// 6:
// 7: module OS
// 8:   module Mac
// 9:     module FormulaCellarChecks
// 10:       extend T::Helpers
// 11:
// 12:       requires_ancestor { Homebrew::FormulaAuditor }
// 13:       requires_ancestor { ::FormulaCellarChecks }
// 14:
// 15:       sig { returns(T.nilable(String)) }
// 16:       def check_shadowed_headers
// 17:         return if ["libtool", "subversion", "berkeley-db"].any? do |formula_name|
// 18:           formula.name.start_with?(formula_name)
// 19:         end
// 20:
// 21:         return if formula.name.match?(Version.formula_optionally_versioned_regex(:php))
// 22:         return if formula.keg_only? || !formula.include.directory?
// 23:
// 24:         files  = relative_glob(formula.include, "**/*.h")
// 25:         files &= relative_glob("#{MacOS.sdk_path}/usr/include", "**/*.h")
// 26:         files.map! { |p| File.join(formula.include, p) }
// 27:
// 28:         return if files.empty?
// 29:
// 30:         <<~EOS
// 31:           Header files that shadow system header files were installed to "#{formula.include}"
// 32:           The offending files are:
// 33:             #{files * "\n  "}
// 34:         EOS
// 35:       end
// 36:
// 37:       sig { returns(T.nilable(String)) }
// 38:       def check_openssl_links
// 39:         return unless formula.prefix.directory?
// 40:
// 41:         keg = ::Keg.new(formula.prefix)
// 42:         system_openssl = keg.mach_o_files.select do |obj|
// 43:           dlls = obj.dynamically_linked_libraries
// 44:           dlls.any? { |dll| %r{/usr/lib/lib(crypto|ssl|tls)\..*dylib}.match? dll }
// 45:         end
// 46:         return if system_openssl.empty?
// 47:
// 48:         <<~EOS
// 49:           object files were linked against system openssl
// 50:           These object files were linked against the deprecated system OpenSSL or
// 51:           the system's private LibreSSL.
// 52:           Adding `depends_on "openssl"` to the formula may help.
// 53:             #{system_openssl * "\n  "}
// 54:         EOS
// 55:       end
// 56:
// 57:       sig { params(lib: ::Pathname).returns(T.nilable(String)) }
// 58:       def check_python_framework_links(lib)
// 59:         python_modules = ::Pathname.glob lib/"python*/site-packages/**/*.so"
// 60:         framework_links = python_modules.select do |obj|
// 61:           obj = MachOPathname.wrap(obj)
// 62:           dlls = obj.dynamically_linked_libraries
// 63:           dlls.any? { |dll| dll.include?("Python.framework") }
// 64:         end
// 65:         return if framework_links.empty?
// 66:
// 67:         <<~EOS
// 68:           python modules have explicit framework links
// 69:           These python extension modules were linked directly to a Python
// 70:           framework binary. They should be linked with -undefined dynamic_lookup
// 71:           instead of -lpython or -framework Python.
// 72:             #{framework_links * "\n  "}
// 73:         EOS
// 74:       end
// 75:
// 76:       sig { void }
// 77:       def check_linkage
// 78:         return unless formula.prefix.directory?
// 79:
// 80:         keg = ::Keg.new(formula.prefix)
// 81:
// 82:         CacheStoreDatabase.use(:linkage) do |db|
// 83:           typed_db = T.cast(db, CacheStoreDatabase[String, T::Hash[T.any(String, Symbol), T.anything]])
// 84:           checker = ::LinkageChecker.new(keg, formula, cache_db: typed_db)
// 85:           next unless checker.broken_library_linkage?
// 86:
// 87:           output = <<~EOS
// 88:             #{formula} has broken dynamic library links:
// 89:               #{checker.display_test_output}
// 90:           EOS
// 91:
// 92:           tab = keg.tab
// 93:           if tab.poured_from_bottle
// 94:             output += <<~EOS
// 95:               Rebuild this from source with:
// 96:                 brew reinstall --build-from-source #{formula}
// 97:               If that's successful, file an issue#{formula.tap ? " here:\n  #{formula.tap!.issues_url}" : "."}
// 98:             EOS
// 99:           end
// 100:           problem_if_output output
// 101:         end
// 102:       end
// 103:
// 104:       sig { params(formula: ::Formula).returns(T.nilable(String)) }
// 105:       def check_flat_namespace(formula)
// 106:         return unless formula.prefix.directory?
// 107:         return if formula.tap&.audit_exception(:flat_namespace_allowlist, formula.name)
// 108:
// 109:         keg = ::Keg.new(formula.prefix)
// 110:         flat_namespace_files = keg.mach_o_files.reject do |file|
// 111:           next true unless file.dylib?
// 112:
// 113:           macho = MachO.open(file)
// 114:           if MachO::Utils.fat_magic?(macho.magic)
// 115:             macho.machos.map(&:header).all? { |h| h.flag? :MH_TWOLEVEL }
// 116:           else
// 117:             macho.header.flag? :MH_TWOLEVEL
// 118:           end
// 119:         end
// 120:         return if flat_namespace_files.empty?
// 121:
// 122:         <<~EOS
// 123:           Libraries were compiled with a flat namespace.
// 124:           This can cause linker errors due to name collisions and
// 125:           is often due to a bug in detecting the macOS version.
// 126:             #{flat_namespace_files * "\n  "}
// 127:            Learn more about this in:
// 128:             #{Formatter.url("https://developer.apple.com/forums/thread/689991?answerId=687895022#687895022")}
// 129:         EOS
// 130:       end
// 131:
// 132:       sig { void }
// 133:       def audit_installed
// 134:         super
// 135:         problem_if_output(check_shadowed_headers)
// 136:         problem_if_output(check_openssl_links)
// 137:         problem_if_output(check_python_framework_links(formula.lib))
// 138:         check_linkage
// 139:         problem_if_output(check_flat_namespace(formula))
// 140:       end
// 141:
// 142:       MACOS_LIB_EXTENSIONS = %w[.dylib .framework].freeze
// 143:
// 144:       sig { params(filename: ::Pathname).returns(T::Boolean) }
// 145:       def valid_library_extension?(filename)
// 146:         super || MACOS_LIB_EXTENSIONS.include?(filename.extname)
// 147:       end
// 148:     end
// 149:   end
// 150: end
// 151:
// 152: FormulaCellarChecks.prepend(OS::Mac::FormulaCellarChecks)
