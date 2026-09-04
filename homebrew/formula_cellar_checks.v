module homebrew

import os
import homebrew.utils

// Translated from Homebrew/brew `formula_cellar_checks.rb`.
pub const formula_cellar_valid_library_extensions = ['.a', '.jnilib', '.la', '.o', '.so', '.jar',
	'.prl', '.pm', '.sh']

pub struct FormulaCellarDependency {
pub:
	name    string
	version string
}

// FormulaCellarBinary is the information exposed by Homebrew's MachOShim and
// ELFShim objects to this checker.
pub struct FormulaCellarBinary {
pub:
	path  string
	arch  string
	archs []string
}

// FormulaCellarFormula is the typed projection of Formula used by the checks in
// this module. Audit-exception fields correspond to the three exception keys
// queried by the pinned Ruby source.
pub struct FormulaCellarFormula {
pub:
	name                           string
	prefix                         string
	bin                            string
	sbin                           string
	lib                            string
	share                          string
	launchd_service_path           string
	keg_only                       bool
	dependencies                   []FormulaCellarDependency
	service_defined                bool
	service_command                []string
	intel                          bool
	dot_brew_formula               string
	no_cpuid_allowlisted           bool
	llvm_objdump                   string
	binutils_objdump               string
	objdump                        string
	original_objdump               string
	binary_files                   []FormulaCellarBinary
	current_arch                   string
	has_tap                        bool
	core_tap                       bool
	versioned_formula              bool
	universal_binary_allowlisted   bool
	mismatched_binary_allowlisted  bool
	has_mismatched_binary_patterns bool
	mismatched_binary_patterns     []string
	display_name                   string
}

@[heap]
pub struct FormulaCellarChecks {
pub:
	formula_value   FormulaCellarFormula
	homebrew_prefix string
	homebrew_cellar string
	shims_path      string
	original_paths  []string
	no_env_hints    bool
pub mut:
	shell_profile            string
	new_formula              bool
	problems                 []string
	instruction_column_index map[string]int
}

pub fn new_formula_cellar_checks(formula FormulaCellarFormula, homebrew_prefix string,
	homebrew_cellar string, shims_path string) &FormulaCellarChecks {
	return &FormulaCellarChecks{
		formula_value: formula
		homebrew_prefix: homebrew_prefix
		homebrew_cellar: homebrew_cellar
		shims_path: shims_path
		shell_profile: utils.shell_profile()
		instruction_column_index: map[string]int{}
	}
}

pub fn (checks &FormulaCellarChecks) formula() FormulaCellarFormula {
	return checks.formula_value
}

pub fn (mut checks FormulaCellarChecks) problem_if_output(output ?string) {
	if problem := output {
		checks.problems << problem
	}
}

fn formula_cellar_children(directory string) []string {
	entries := os.ls(directory) or { return []string{} }
	return entries.map(os.join_path(directory, it))
}

fn formula_cellar_join_offenders(paths []string) string {
	return paths.join('\n  ')
}

fn formula_cellar_walk(directory string) []string {
	mut paths := []string{}
	for path in formula_cellar_children(directory) {
		paths << path
		if os.is_dir(path) && !os.is_link(path) {
			paths << formula_cellar_walk(path)
		}
	}
	return paths
}

fn formula_cellar_relative_path(path string, root string) string {
	root_prefix := root.trim_right(os.path_separator) + os.path_separator
	return if path.starts_with(root_prefix) { path[root_prefix.len..] } else { path }
}

pub fn formula_cellar_check_env_path(checks &FormulaCellarChecks, bin string) ?string {
	if checks.no_env_hints || !os.is_dir(bin) || formula_cellar_children(bin).len == 0 {
		return none
	}
	prefix_bin_path := os.join_path(checks.homebrew_prefix, os.base(bin))
	if !os.is_dir(prefix_bin_path) {
		return none
	}
	prefix_bin := os.real_path(prefix_bin_path)
	if checks.original_paths.any(os.real_path(it) == prefix_bin) {
		return none
	}
	return '"${prefix_bin}" is not in your PATH.\nYou can amend this by altering your ${checks.shell_profile} file.\n'
}

pub fn formula_cellar_check_manpages(formula FormulaCellarFormula) ?string {
	if !os.is_dir(os.join_path(formula.prefix, 'man')) {
		return none
	}
	return 'A top-level "man" directory was found.\nHomebrew requires that man pages live under "share".\nThis can often be fixed by passing `--mandir=#{man}` to `configure`.\n'
}

pub fn formula_cellar_check_infopages(formula FormulaCellarFormula) ?string {
	if !os.is_dir(os.join_path(formula.prefix, 'info')) {
		return none
	}
	return 'A top-level "info" directory was found.\nHomebrew suggests that info pages live under "share".\nThis can often be fixed by passing `--infodir=#{info}` to `configure`.\n'
}

pub fn formula_cellar_check_jars(formula FormulaCellarFormula) ?string {
	if !os.is_dir(formula.lib) {
		return none
	}
	jars := formula_cellar_children(formula.lib).filter(os.file_ext(it) == '.jar')
	if jars.len == 0 {
		return none
	}
	return 'JARs were installed to "${formula.lib}".\nInstalling JARs to "lib" can cause conflicts between packages.\nFor Java software, it is typically better for the formula to\ninstall to "libexec" and then symlink or wrap binaries into "bin".\nSee formulae \'activemq\', \'jruby\', etc. for examples.\nThe offending files are:\n  ${formula_cellar_join_offenders(jars)}\n'
}

pub fn formula_cellar_valid_library_extension(filename string) bool {
	return os.file_ext(filename) in formula_cellar_valid_library_extensions
}

pub fn formula_cellar_check_non_libraries(formula FormulaCellarFormula) ?string {
	if !os.is_dir(formula.lib) {
		return none
	}
	non_libraries := formula_cellar_children(formula.lib).filter(!os.is_dir(it) && !formula_cellar_valid_library_extension(it))
	if non_libraries.len == 0 {
		return none
	}
	return 'Non-libraries were installed to "${formula.lib}".\nInstalling non-libraries to "lib" is discouraged.\nThe offending files are:\n  ${formula_cellar_join_offenders(non_libraries)}\n'
}

pub fn formula_cellar_check_non_executables(bin string) ?string {
	if !os.is_dir(bin) {
		return none
	}
	non_executables := formula_cellar_children(bin).filter(os.is_dir(it) || !os.is_executable(it))
	if non_executables.len == 0 {
		return none
	}
	return 'Non-executables were installed to "${bin}".\nThe offending files are:\n  ${formula_cellar_join_offenders(non_executables)}\n'
}

pub fn formula_cellar_check_generic_executables(bin string) ?string {
	if !os.is_dir(bin) {
		return none
	}
	generic_names := ['service', 'start', 'stop']
	generics := formula_cellar_children(bin).filter(os.base(it) in generic_names)
	if generics.len == 0 {
		return none
	}
	return 'Generic binaries were installed to "${bin}".\nBinaries with generic names are likely to conflict with other software.\nHomebrew suggests that this software is installed to "libexec" and then\nsymlinked as needed.\nThe offending files are:\n  ${formula_cellar_join_offenders(generics)}\n'
}

pub fn formula_cellar_check_easy_install_pth(lib string) ?string {
	pth_files := os.glob(os.join_path(lib, 'python3*', 'site-packages', 'easy-install.pth')) or {
		[]string{}
	}
	pth_found := pth_files.map(os.dir(it))
	if pth_found.len == 0 {
		return none
	}
	return "'easy-install.pth' files were found.\nThese '.pth' files are likely to cause link conflicts.\nEasy install is now deprecated, do not use it.\nThe offending files are:\n  ${formula_cellar_join_offenders(pth_found)}\n"
}

pub fn formula_cellar_check_elisp_dirname(share string, name string) ?string {
	site_lisp := os.join_path(share, 'emacs', 'site-lisp')
	if !os.is_dir(site_lisp) || name == 'emacs' {
		return none
	}
	bad_dir_name := formula_cellar_children(site_lisp).any(os.is_dir(it) && os.base(it) != name)
	if !bad_dir_name {
		return none
	}
	return 'Emacs Lisp files were installed into the wrong "site-lisp" subdirectory.\nThey should be installed into:\n  ${share}/emacs/site-lisp/${name}\n'
}

pub fn formula_cellar_check_elisp_root(checks &FormulaCellarChecks, share string,
	name string) ?string {
	site_lisp := os.join_path(share, 'emacs', 'site-lisp')
	if !os.is_dir(site_lisp) || name == 'emacs' {
		return none
	}
	elisps := formula_cellar_children(site_lisp).filter(os.file_ext(it) in ['.el', '.elc'])
	if elisps.len == 0 {
		return none
	}
	return 'Emacs Lisp files were linked directly to "${checks.homebrew_prefix}/share/emacs/site-lisp".\nThis may cause conflicts with other packages.\nThey should instead be installed into:\n  ${share}/emacs/site-lisp/${name}\nThe offending files are:\n  ${formula_cellar_join_offenders(elisps)}\n'
}

fn formula_cellar_python_directory_version(name string) ?string {
	if !name.starts_with('python') {
		return none
	}
	version := name['python'.len..]
	parts := version.split('.')
	if parts.len != 2 {
		return none
	}
	for part in parts {
		if part == '' {
			return none
		}
		for character in part.bytes() {
			if character < `0` || character > `9` {
				return none
			}
		}
	}
	return version
}

fn formula_cellar_dependency_python_version(dependency FormulaCellarDependency) ?string {
	if dependency.name != 'python' && !dependency.name.starts_with('python@') {
		return none
	}
	mut index := 0
	for index < dependency.version.len && dependency.version[index] >= `0` && dependency.version[index] <= `9` {
		index++
	}
	if index == 0 || index >= dependency.version.len || dependency.version[index] != `.` {
		return none
	}
	index++
	minor_start := index
	for index < dependency.version.len && dependency.version[index] >= `0` && dependency.version[index] <= `9` {
		index++
	}
	if index == minor_start {
		return none
	}
	return dependency.version[..index]
}

pub fn formula_cellar_check_python_packages(lib string,
	dependencies []FormulaCellarDependency) ?string {
	if !os.is_dir(lib) {
		return none
	}
	mut pythons := []string{}
	for child in formula_cellar_children(lib) {
		if os.is_dir(child) {
			if version := formula_cellar_python_directory_version(os.base(child)) {
				pythons << version
			}
		}
	}
	if pythons.len == 0 {
		return none
	}
	mut python_dependencies := []string{}
	for dependency in dependencies {
		if version := formula_cellar_dependency_python_version(dependency) {
			python_dependencies << version
		}
	}
	if python_dependencies.len == 0 || pythons.any(it in python_dependencies) {
		return none
	}
	installed := pythons.map('Python ${it}')
	depends_on := python_dependencies.map('Python ${it}')
	return 'Packages have been installed for:\n  ${formula_cellar_join_offenders(installed)}\nbut this formula depends on:\n  ${formula_cellar_join_offenders(depends_on)}\n'
}

pub fn formula_cellar_check_shim_references(checks &FormulaCellarChecks, prefix string) ?string {
	if !os.is_dir(prefix) {
		return none
	}
	mut seen_inodes := map[string]bool{}
	mut matches := []string{}
	for file in formula_cellar_walk(prefix) {
		if os.is_dir(file) || os.is_link(file) {
			continue
		}
		information := os.stat(file) or { continue }
		identity := '${information.dev}:${information.inode}'
		if identity in seen_inodes {
			continue
		}
		seen_inodes[identity] = true
		contents := os.read_file(file) or { continue }
		if !contents.contains(checks.shims_path) {
			continue
		}
		relative := formula_cellar_relative_path(file, prefix)
		parts := relative.split('/')
		if parts.len >= 4 && parts[0] == 'share' && parts[1] == 'doc' && parts.last() == 'INFO_BIN' {
			continue
		}
		matches << relative
	}
	if matches.len == 0 {
		return none
	}
	return 'Files were found with references to the Homebrew shims directory.\nThe offending files are:\n  ${formula_cellar_join_offenders(matches)}\n'
}

fn formula_cellar_xml_unescape(value string) string {
	return value.replace('&lt;', '<').replace('&gt;', '>').replace('&quot;', '"').replace('&apos;', "'").replace('&amp;', '&')
}

fn formula_cellar_xml_string(contents string, offset int, limit int) ?string {
	if offset < 0 || offset >= contents.len {
		return none
	}
	opening := '<string>'
	start_relative := contents[offset..].index(opening) or { return none }
	start := offset + start_relative + opening.len
	if limit > 0 && start > limit {
		return none
	}
	end_relative := contents[start..].index('</string>') or { return none }
	end := start + end_relative
	if limit > 0 && end > limit {
		return none
	}
	return formula_cellar_xml_unescape(contents[start..end].trim_space())
}

fn formula_cellar_plist_program(contents string) (string, string) {
	arguments_key := '<key>ProgramArguments</key>'
	if key_index := contents.index(arguments_key) {
		offset := key_index + arguments_key.len
		if array_relative := contents[offset..].index('<array>') {
			array_start := offset + array_relative + '<array>'.len
			array_end_relative := contents[array_start..].index('</array>') or { -1 }
			if array_end_relative >= 0 {
				if program := formula_cellar_xml_string(contents, array_start, array_start + array_end_relative) {
					return program, 'first ProgramArguments value'
				}
			}
		}
	}
	program_key := '<key>Program</key>'
	if key_index := contents.index(program_key) {
		if program := formula_cellar_xml_string(contents, key_index + program_key.len, 0) {
			return program, 'Program'
		}
	}
	return '', ''
}

pub fn formula_cellar_check_plist(prefix string, plist_path string) ?string {
	if !os.is_dir(prefix) {
		return none
	}
	contents := os.read_file(plist_path) or { return none }
	program_location, key := formula_cellar_plist_program(contents)
	if program_location == '' {
		return none
	}
	if !os.exists(program_location) {
		return 'The plist "${key}" does not exist:\n  ${program_location}\n'
	}
	if os.is_executable(program_location) {
		return none
	}
	return 'The plist "${key}" is not executable:\n  ${program_location}\n'
}

pub fn formula_cellar_check_python_symlinks(checks &FormulaCellarChecks, name string,
	keg_only bool) ?string {
	if !keg_only || !name.starts_with('python') {
		return none
	}
	cellar_prefix := os.join_path(checks.homebrew_cellar, name).trim_right(os.path_separator)
	mut linked_into_cellar := false
	for link_name in ['pip3', 'wheel3'] {
		link := os.join_path(checks.homebrew_prefix, 'bin', link_name)
		if (os.exists(link) || os.is_link(link)) && os.real_path(link).starts_with(cellar_prefix) {
			linked_into_cellar = true
			break
		}
	}
	if !linked_into_cellar {
		return none
	}
	return 'Python formulae that are keg-only should not create `pip3` and `wheel3` symlinks.'
}

pub fn formula_cellar_check_service_command(formula FormulaCellarFormula) ?string {
	if !os.is_dir(formula.prefix) || !formula.service_defined || formula.service_command.len == 0 {
		return none
	}
	if !os.exists(formula.service_command[0]) {
		return 'Service command does not exist'
	}
	return none
}

fn formula_cellar_shell_escape(value string) string {
	if value == '' {
		return "''"
	}
	mut safe := true
	for character in value.bytes() {
		if !((character >= `a` && character <= `z`) || (character >= `A` && character <= `Z`) || (character >= `0` && character <= `9`) || character in [
			`_`,
			`-`,
			`.`,
			`/`,
			`:`,
			`+`,
		]) {
			safe = false
			break
		}
	}
	return if safe { value } else { "'${value.replace("'", "'\\''")}'" }
}

fn formula_cellar_command(executable string, arguments []string) os.Result {
	mut command_parts := [formula_cellar_shell_escape(executable)]
	command_parts << arguments.map(formula_cellar_shell_escape(it))
	command := command_parts.join(' ')
	return os.execute(command)
}

pub fn formula_cellar_cpuid_instruction(mut checks FormulaCellarChecks, file string,
	objdump string) bool {
	mut instruction_column := 0
	if objdump in checks.instruction_column_index {
		instruction_column = checks.instruction_column_index[objdump]
	} else {
		version := formula_cellar_command(objdump, ['--version'])
		instruction_column = if version.output.contains('LLVM') { 1 } else { 2 }
		checks.instruction_column_index[objdump] = instruction_column
	}
	disassembly := formula_cellar_command(objdump, ['--disassemble', file])
	for line in disassembly.output.split_into_lines() {
		columns := line.split('\t')
		if instruction_column < columns.len && columns[instruction_column].trim_space() == 'cpuid' {
			return true
		}
	}
	return false
}

fn formula_cellar_objdump(formula FormulaCellarFormula) ?string {
	if formula.llvm_objdump != '' {
		return formula.llvm_objdump
	}
	if formula.binutils_objdump != '' {
		return formula.binutils_objdump
	}
	if formula.objdump != '' {
		return formula.objdump
	}
	if formula.original_objdump != '' {
		return formula.original_objdump
	}
	return none
}

pub fn formula_cellar_check_cpuid_instruction(mut checks FormulaCellarChecks,
	formula FormulaCellarFormula) ?string {
	if !formula.intel {
		return none
	}
	dot_brew_formula := if formula.dot_brew_formula != '' {
		formula.dot_brew_formula
	} else {
		os.join_path(formula.prefix, '.brew', '${formula.name}.rb')
	}
	if !os.exists(dot_brew_formula) {
		return none
	}
	contents := os.read_file(dot_brew_formula) or { return none }
	if !contents.contains('ENV.runtime_cpu_detection') || formula.no_cpuid_allowlisted {
		return none
	}
	objdump := formula_cellar_objdump(formula) or {
		return 'No `objdump` found, so cannot check for a `cpuid` instruction. Install `objdump` with\n  brew install binutils\n'
	}
	for file in formula.binary_files {
		if formula_cellar_cpuid_instruction(mut checks, file.path, objdump) {
			return none
		}
	}
	mut seen_inodes := map[string]bool{}
	if os.is_dir(formula.lib) {
		for path in formula_cellar_walk(formula.lib) {
			if os.is_link(path) || os.is_dir(path) || os.file_ext(path) != '.a' {
				continue
			}
			information := os.stat(path) or { continue }
			identity := '${information.dev}:${information.inode}'
			if identity in seen_inodes {
				continue
			}
			seen_inodes[identity] = true
			if formula_cellar_cpuid_instruction(mut checks, path, objdump) {
				return none
			}
		}
	}
	display := if formula.display_name != '' { formula.display_name } else { formula.name }
	return 'No `cpuid` instruction detected. ${display} should not use `ENV.runtime_cpu_detection`.'
}

fn formula_cellar_expand_braces(pattern string) []string {
	open := pattern.index('{') or { return [pattern] }
	close_relative := pattern[open..].index('}') or { return [pattern] }
	close := open + close_relative
	prefix := pattern[..open]
	suffix := pattern[close + 1..]
	mut expanded := []string{}
	for choice in pattern[open + 1..close].split(',') {
		expanded << formula_cellar_expand_braces(prefix + choice + suffix)
	}
	return expanded
}

fn formula_cellar_wildcard_match_at(pattern string, value string, pattern_index int,
	value_index int) bool {
	if pattern_index == pattern.len {
		return value_index == value.len
	}
	if pattern[pattern_index] == `*` {
		mut next_pattern := pattern_index + 1
		mut crosses_directories := false
		if next_pattern < pattern.len && pattern[next_pattern] == `*` {
			crosses_directories = true
			for next_pattern < pattern.len && pattern[next_pattern] == `*` {
				next_pattern++
			}
		}
		if formula_cellar_wildcard_match_at(pattern, value, next_pattern, value_index) {
			return true
		}
		mut cursor := value_index
		for cursor < value.len && (crosses_directories || value[cursor] != `/`) {
			cursor++
			if formula_cellar_wildcard_match_at(pattern, value, next_pattern, cursor) {
				return true
			}
		}
		return false
	}
	if value_index == value.len {
		return false
	}
	if pattern[pattern_index] == `?` {
		return value[value_index] != `/` && formula_cellar_wildcard_match_at(pattern, value, pattern_index + 1, value_index + 1)
	}
	return pattern[pattern_index] == value[value_index] && formula_cellar_wildcard_match_at(pattern, value, pattern_index + 1, value_index + 1)
}

fn formula_cellar_path_matches(pattern string, path string) bool {
	return formula_cellar_expand_braces(pattern).any(formula_cellar_wildcard_match_at(it, path, 0, 0))
}

pub fn formula_cellar_check_binary_arches(formula FormulaCellarFormula) ?string {
	if !os.is_dir(formula.prefix) {
		return none
	}
	mut mismatches := []FormulaCellarBinary{}
	for file in formula.binary_files {
		if file.arch != formula.current_arch {
			mismatches << file
		}
	}
	if mismatches.len == 0 {
		return none
	}
	mut compatible_universal_binaries := []FormulaCellarBinary{}
	mut incompatible := []FormulaCellarBinary{}
	for file in mismatches {
		if file.arch == 'universal' && formula.current_arch in file.archs {
			compatible_universal_binaries << file
		} else {
			incompatible << file
		}
	}
	universal_binaries_expected := if formula.has_tap && formula.core_tap {
		formula.universal_binary_allowlisted
	} else {
		true
	}
	mut mismatches_expected := !formula.has_tap || formula.mismatched_binary_allowlisted
	if formula.has_mismatched_binary_patterns {
		prefix := os.real_path(formula.prefix).trim_right(os.path_separator)
		mut unexpected := []FormulaCellarBinary{}
		for file in incompatible {
			mut expected := false
			for pattern in formula.mismatched_binary_patterns {
				if formula_cellar_path_matches(os.join_path(prefix, pattern), file.path) {
					expected = true
					break
				}
			}
			if !expected {
				unexpected << file
			}
		}
		incompatible = unexpected.clone()
		mismatches_expected = false
		if incompatible.len == 0 && compatible_universal_binaries.len == 0 {
			return none
		}
	}
	if (incompatible.len == 0 && universal_binaries_expected) || (compatible_universal_binaries.len == 0 && mismatches_expected) || (universal_binaries_expected && mismatches_expected) {
		return none
	}
	mut output := ''
	display := if formula.display_name != '' { formula.display_name } else { formula.name }
	if incompatible.len > 0 && !mismatches_expected {
		offenders := incompatible.map('${it.path}\t(${it.arch})')
		output += "Binaries built for a non-native architecture were installed into ${display}'s prefix.\nThe offending files are:\n  ${formula_cellar_join_offenders(offenders)}\n"
	}
	if compatible_universal_binaries.len > 0 && !universal_binaries_expected {
		offenders := compatible_universal_binaries.map(it.path)
		output += 'Unexpected universal binaries were found.\nThe offending files are:\n  ${formula_cellar_join_offenders(offenders)}\n'
	}
	return output
}

pub fn formula_cellar_audit_installed(mut checks FormulaCellarChecks) {
	formula := checks.formula()
	checks.problem_if_output(formula_cellar_check_manpages(formula))
	checks.problem_if_output(formula_cellar_check_infopages(formula))
	checks.problem_if_output(formula_cellar_check_jars(formula))
	checks.problem_if_output(formula_cellar_check_service_command(formula))
	if checks.new_formula {
		checks.problem_if_output(formula_cellar_check_non_libraries(formula))
	}
	checks.problem_if_output(formula_cellar_check_non_executables(formula.bin))
	checks.problem_if_output(formula_cellar_check_generic_executables(formula.bin))
	checks.problem_if_output(formula_cellar_check_non_executables(formula.sbin))
	checks.problem_if_output(formula_cellar_check_generic_executables(formula.sbin))
	checks.problem_if_output(formula_cellar_check_easy_install_pth(formula.lib))
	checks.problem_if_output(formula_cellar_check_elisp_dirname(formula.share, formula.name))
	checks.problem_if_output(formula_cellar_check_elisp_root(checks, formula.share, formula.name))
	checks.problem_if_output(formula_cellar_check_python_packages(formula.lib, formula.dependencies))
	checks.problem_if_output(formula_cellar_check_shim_references(checks, formula.prefix))
	checks.problem_if_output(formula_cellar_check_plist(formula.prefix, formula.launchd_service_path))
	checks.problem_if_output(formula_cellar_check_python_symlinks(checks, formula.name, formula.keg_only))
	checks.problem_if_output(formula_cellar_check_cpuid_instruction(mut checks, formula))
	checks.problem_if_output(formula_cellar_check_binary_arches(formula))
}

pub fn formula_cellar_relative_glob(directory string, pattern string) []string {
	if !os.is_dir(directory) {
		return []string{}
	}
	matches := os.glob(os.join_path(directory, pattern)) or { return []string{} }
	return matches.map(formula_cellar_relative_path(it, directory))
}
