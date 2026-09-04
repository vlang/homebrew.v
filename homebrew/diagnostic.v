module homebrew

import ruby
import homebrew.diagnostic as diagnostic_finding

// Translated from Homebrew/brew `diagnostic.rb`.
pub struct DiagnosticTap {
pub:
	name                  string
	full_name             string
	path                  string
	remote                string
	git_head              string
	branch_name           string
	origin_branch_name    string
	default_origin_branch bool = true
	official              bool
	core                  bool
	core_cask             bool
	installed             bool = true
	formula_names         []string
	cask_tokens           []string
	bad_ruby_files        []string
	cask_count            int
	cask_read_error       bool
}

pub struct DiagnosticFormula {
pub:
	name               string
	full_name          string
	tap                string
	deprecated         bool
	disabled           bool
	installed          bool = true
	linked             bool
	keg_only           bool
	read_error         string
	loadable           bool = true
	installed_prefixes []string
	linked_files       map[string]string
	opt_libexec        string
	libexec            string
}

pub struct DiagnosticCask {
pub:
	token      string
	tap        string
	deprecated bool
	disabled   bool
}

pub struct DiagnosticChecks {
pub mut:
	verbose          bool = true
	found            []string
	seen_prefix_bin  bool
	seen_prefix_sbin bool
	user_path_1_done bool
	info             [][]string
	events           []string
pub:
	prefix                       string = '/opt/homebrew'
	repository                   string = '/opt/homebrew'
	cellar                       string = '/opt/homebrew/Cellar'
	temp                         string = '/tmp'
	home                         string = '/Users/test'
	current_user_name            string = 'test'
	brew_version                 string = '0.0.0'
	default_prefix               string = '/opt/homebrew'
	original_paths               []string
	existing_files               []string
	existing_directories         []string
	writable_directories         []string
	symlinks                     []string
	resolved_paths               map[string]string
	executable_files             []string
	directory_children           map[string][]string
	must_exist_directories       []string
	must_be_writable_directories []string
	git_available                bool = true
	repository_is_git            bool = true
	repository_origin            string
	desired_brew_origin          string = 'https://github.com/Homebrew/brew'
	repository_head              string
	repository_branch            string
	minimum_git_version          string = '2.7.0'
	git_version                  string = '2.40.0'
	git_formula_installed        bool
	git_autocrlf                 string
	developer_tools_installed    bool = true
	developer_tools_instructions string
	nix_managed                  bool
	ci                           bool
	github_actions               bool
	no_install_from_api          bool
	developer                    bool
	devcmdrun                    bool
	no_require_tap_trust         bool
	no_env_hints                 bool
	test_bot                     bool
	taps                         []DiagnosticTap
	formulae                     []DiagnosticFormula
	casks                        []DiagnosticCask
	untrusted_taps               []string
	deprecated_official_taps     []string
	missing_dependencies         []string
	git_statuses                 map[string][]string
	frameworks                   []string
	tmpdir                       string
	deleted_formulae             []string
	legacy_cask_locations        []string
	caskroom_path                string = '/opt/homebrew/Caskroom'
	corrupt_casks                []string
	load_paths                   []string
	environment                  map[string]string
	quarantine_available         bool
	xattr_exists                 bool
	xattr_success                bool
	xattr_stderr                 string
	system_python_version        string
	software_version             string = '0.0.0'
	desired_core_origin          string = 'https://github.com/Homebrew/homebrew-core'
	core_formula_names           []string
	core_cask_names              []string
	installed_formula_tap_names  []string
	installed_cask_tap_names     []string
}

pub struct DiagnosticRunResult {
pub:
	failed    bool
	exit_code int
	output    []string
}

fn diagnostic_nil() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn diagnostic_strings_value(values []string) ruby.Value {
	return ruby.array_value(values.map(ruby.string_value(it)))
}

fn diagnostic_strings(value ruby.Value) []string {
	return value.as_array() or { return [] }.map(it.as_string())
}

fn diagnostic_string_map_value(values map[string]string) ruby.Value {
	mut result := map[string]ruby.Value{}
	for key, value in values {
		result[key] = ruby.string_value(value)
	}
	return ruby.map_value(result)
}

fn diagnostic_string_map(value ruby.Value) map[string]string {
	mut result := map[string]string{}
	for key, item in value.map_data {
		result[key] = item.as_string()
	}
	return result
}

pub fn diagnostic_checks_value(checks &DiagnosticChecks) ruby.Value {
	return ruby.structured_value('Homebrew::Diagnostic::Checks', 'Homebrew::Diagnostic::Checks', {
		'checks_address': u64(voidptr(checks)).str()
	})
}

fn diagnostic_checks_from_value(value ruby.Value) &DiagnosticChecks {
	address := value.attributes['checks_address'] or { panic('invalid Diagnostic::Checks receiver') }
	return unsafe { &DiagnosticChecks(voidptr(address.u64())) }
}

pub fn diagnostic_tap_value(tap DiagnosticTap) ruby.Value {
	return ruby.Value{
		type_name: 'Tap'
		repr: tap.name
		map_data: {
			'formula_names':  diagnostic_strings_value(tap.formula_names)
			'cask_tokens':    diagnostic_strings_value(tap.cask_tokens)
			'bad_ruby_files': diagnostic_strings_value(tap.bad_ruby_files)
		}
		attributes: {
			'name':                  tap.name
			'full_name':             tap.full_name
			'path':                  tap.path
			'remote':                tap.remote
			'git_head':              tap.git_head
			'branch_name':           tap.branch_name
			'origin_branch_name':    tap.origin_branch_name
			'default_origin_branch': tap.default_origin_branch.str()
			'official':              tap.official.str()
			'core':                  tap.core.str()
			'core_cask':             tap.core_cask.str()
			'installed':             tap.installed.str()
			'cask_count':            tap.cask_count.str()
			'cask_read_error':       tap.cask_read_error.str()
		}
	}
}

fn diagnostic_tap_from_value(value ruby.Value) DiagnosticTap {
	return DiagnosticTap{
		name: value.attributes['name'] or { value.repr }
		full_name: value.attributes['full_name'] or { value.repr }
		path: value.attributes['path'] or { '' }
		remote: value.attributes['remote'] or { '' }
		git_head: value.attributes['git_head'] or { '' }
		branch_name: value.attributes['branch_name'] or { '' }
		origin_branch_name: value.attributes['origin_branch_name'] or { '' }
		default_origin_branch: (value.attributes['default_origin_branch'] or { 'true' }).bool()
		official: (value.attributes['official'] or { 'false' }).bool()
		core: (value.attributes['core'] or { 'false' }).bool()
		core_cask: (value.attributes['core_cask'] or { 'false' }).bool()
		installed: (value.attributes['installed'] or { 'true' }).bool()
		formula_names: diagnostic_strings(value.map_data['formula_names'] or { diagnostic_strings_value([]) })
		cask_tokens: diagnostic_strings(value.map_data['cask_tokens'] or { diagnostic_strings_value([]) })
		bad_ruby_files: diagnostic_strings(value.map_data['bad_ruby_files'] or { diagnostic_strings_value([]) })
		cask_count: (value.attributes['cask_count'] or { '0' }).int()
		cask_read_error: (value.attributes['cask_read_error'] or { 'false' }).bool()
	}
}

pub fn diagnostic_formula_value(formula DiagnosticFormula) ruby.Value {
	return ruby.Value{
		type_name: 'Formula'
		repr: formula.full_name
		map_data: {
			'installed_prefixes': diagnostic_strings_value(formula.installed_prefixes)
			'linked_files':       diagnostic_string_map_value(formula.linked_files)
		}
		attributes: {
			'name':        formula.name
			'full_name':   formula.full_name
			'tap':         formula.tap
			'deprecated':  formula.deprecated.str()
			'disabled':    formula.disabled.str()
			'installed':   formula.installed.str()
			'linked':      formula.linked.str()
			'keg_only':    formula.keg_only.str()
			'read_error':  formula.read_error
			'loadable':    formula.loadable.str()
			'opt_libexec': formula.opt_libexec
			'libexec':     formula.libexec
		}
	}
}

fn diagnostic_formula_from_value(value ruby.Value) DiagnosticFormula {
	return DiagnosticFormula{
		name: value.attributes['name'] or { value.repr }
		full_name: value.attributes['full_name'] or { value.repr }
		tap: value.attributes['tap'] or { '' }
		deprecated: (value.attributes['deprecated'] or { 'false' }).bool()
		disabled: (value.attributes['disabled'] or { 'false' }).bool()
		installed: (value.attributes['installed'] or { 'true' }).bool()
		linked: (value.attributes['linked'] or { 'false' }).bool()
		keg_only: (value.attributes['keg_only'] or { 'false' }).bool()
		read_error: value.attributes['read_error'] or { '' }
		loadable: (value.attributes['loadable'] or { 'true' }).bool()
		installed_prefixes: diagnostic_strings(value.map_data['installed_prefixes'] or { diagnostic_strings_value([]) })
		linked_files: diagnostic_string_map(value.map_data['linked_files'] or { ruby.map_value({}) })
		opt_libexec: value.attributes['opt_libexec'] or { '' }
		libexec: value.attributes['libexec'] or { '' }
	}
}

fn diagnostic_remediation(text string, commands []string) ?diagnostic_finding.Remediation {
	return diagnostic_finding.Remediation{ text: text, commands: commands }
}

fn diagnostic_finding_value(finding ?diagnostic_finding.Finding) ruby.Value {
	value := finding or { return diagnostic_nil() }
	return value.to_value()
}

fn diagnostic_finding_array_value(findings []diagnostic_finding.Finding) ruby.Value {
	return ruby.array_value(findings.map(it.to_value()))
}

fn diagnostic_add_info(mut checks DiagnosticChecks, values []string) {
	if checks.verbose {
		checks.info << values.clone()
	}
}

pub fn diagnostic_inject_file_list(list []string, message string) string {
	mut output := message
	for item in list {
		output += '  ${item}\n'
	}
	return output
}

pub fn diagnostic_user_tilde(path string, home string) string {
	if path == home {
		return '~'
	}
	prefix := '${home}/'
	return if path.starts_with(prefix) { '~/${path[prefix.len..]}' } else { path }
}

fn diagnostic_path_join(left string, right string) string {
	return '${left.trim_right('/')}/${right.trim_left('/')}'
}

fn diagnostic_basename(path string) string {
	parts := path.trim_right('/').split('/')
	return if parts.len > 0 { parts.last() } else { path }
}

fn diagnostic_unique(values []string) []string {
	mut result := []string{}
	for value in values {
		if value !in result { result << value }
	}
	return result
}

fn diagnostic_wildcard_match(pattern string, value string) bool {
	mut p := 0
	mut v := 0
	mut star := -1
	mut checkpoint := 0
	for v < value.len {
		if p < pattern.len && (pattern[p] == value[v] || pattern[p] == `?`) {
			p++
			v++
		} else if p < pattern.len && pattern[p] == `*` {
			star = p
			p++
			checkpoint = v
		} else if star >= 0 {
			p = star + 1
			checkpoint++
			v = checkpoint
		} else {
			return false
		}
	}
	for p < pattern.len && pattern[p] == `*` {
		p++
	}
	return p == pattern.len
}

fn diagnostic_version_parts(version string) []int {
	mut parts := []int{}
	for piece in version.split('.') {
		mut digits := ''
		for character in piece {
			if character.is_digit() {
				digits += character.str()
			} else {
				break
			}
		}
		parts << if digits == '' { 0 } else { digits.int() }
	}
	return parts
}

fn diagnostic_version_less(left string, right string) bool {
	a := diagnostic_version_parts(left)
	b := diagnostic_version_parts(right)
	maximum_length := if a.len > b.len { a.len } else { b.len }
	for index in 0 .. maximum_length {
		av := if index < a.len { a[index] } else { 0 }
		bv := if index < b.len { b[index] } else { 0 }
		if av != bv {
			return av < bv
		}
	}
	return false
}

pub fn diagnostic_find_relative_paths(mut checks DiagnosticChecks, relative_paths []string) {
	mut prefixes := diagnostic_unique([checks.prefix, '/usr/local'])
	mut found := []string{}
	for prefix in prefixes {
		for relative_path in relative_paths {
			path := diagnostic_path_join(prefix, relative_path)
			if path in checks.existing_files || path in checks.existing_directories {
				found << path
			}
		}
	}
	checks.found = found
}

pub fn diagnostic_examine_git_origin(checks DiagnosticChecks, repository_path string,
	desired_origin string, current_origin ?string) ?diagnostic_finding.Finding {
	if !checks.git_available || !checks.repository_is_git {
		return none
	}
	origin := current_origin or {
		return diagnostic_finding.Finding{
			text: "Missing ${desired_origin} git origin remote.\n\nWithout a correctly configured origin, Homebrew won't update properly.\n"
			remediation: diagnostic_remediation('You can solve this by adding the remote:\n  git -C "${repository_path}" remote add origin ${desired_origin}\n', [
				'git -C "${repository_path}" remote add origin ${desired_origin}',
			])
		}
	}
	mut normalized := origin.to_lower().trim_right('/')
	if normalized.ends_with('.git') {
		normalized = normalized[..normalized.len - 4]
	}
	mut desired := desired_origin.to_lower().trim_right('/')
	if desired.ends_with('.git') {
		desired = desired[..desired.len - 4]
	}
	if normalized.ends_with(desired) {
		return none
	}
	return diagnostic_finding.Finding{
		text: "The current git origin is:\n  ${origin}\n\nWith a non-standard origin, Homebrew won't update properly.\n"
		remediation: diagnostic_remediation('You can solve this by setting the origin remote:\n  git -C "${repository_path}" remote set-url origin ${desired_origin}\n', [
			'git -C "${repository_path}" remote set-url origin ${desired_origin}',
		])
	}
}

pub fn diagnostic_broken_tap(checks DiagnosticChecks, tap DiagnosticTap) ?diagnostic_finding.Finding {
	if !checks.git_available || !checks.repository_is_git {
		return none
	}
	finding := diagnostic_finding.Finding{
		text: '${if tap.full_name != '' { tap.full_name } else { tap.name }} was not tapped properly!'
		remediation: diagnostic_remediation('You can solve this by tapping again:\n  rm -rf "${tap.path}"\n  brew tap ${tap.name}\n', [
			'rm -rf "${tap.path}"',
			'brew tap ${tap.name}',
		])
	}
	if tap.remote == '' || tap.git_head == '' || tap.git_head == checks.repository_head {
		return finding
	}
	return none
}

pub fn diagnostic_check_developer_tools(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	if checks.developer_tools_installed {
		return none
	}
	return diagnostic_finding.Finding{
		text: 'No developer tools installed.\n'
		remediation: if checks.developer_tools_instructions == '' {
			none
		} else {
			diagnostic_remediation(checks.developer_tools_instructions, [])
		}
	}
}

pub fn diagnostic_check_stray_files(checks DiagnosticChecks, directory string, pattern string,
	allow_list []string, message string) ?string {
	if directory !in checks.existing_directories {
		return none
	}
	mut files := []string{}
	prefix := '${directory.trim_right('/')}/'
	for file in checks.existing_files {
		if !file.starts_with(prefix) || file in checks.symlinks {
			continue
		}
		mut relative := file[prefix.len..]
		if !diagnostic_wildcard_match(pattern, relative) {
			continue
		}
		if allow_list.any(diagnostic_wildcard_match(it, relative)) {
			continue
		}
		if !checks.verbose && relative.contains('/') {
			relative = '${relative.all_before('/')}/*'
		}
		files << diagnostic_path_join(directory, relative)
	}
	files.sort()
	files = diagnostic_unique(files)
	if files.len == 0 {
		return none
	}
	return diagnostic_inject_file_list(files, message)
}

fn diagnostic_stray_finding(checks DiagnosticChecks, directory string, pattern string,
	allow_list []string, message string) ?diagnostic_finding.Finding {
	text := diagnostic_check_stray_files(checks, directory, pattern, allow_list, message) or { return none }
	return diagnostic_finding.Finding{ text: text }
}

pub fn diagnostic_check_stray_dylibs(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	return diagnostic_stray_finding(checks, '/usr/local/lib', '*.dylib', [
		'libfuse.2.dylib',
		'libfuse3.*.dylib',
		'libfuse_ino64.2.dylib',
		'libfuse-t*.dylib',
		'libmacfuse_i32.2.dylib',
		'libmacfuse_i64.2.dylib',
		'libosxfuse_i32.2.dylib',
		'libosxfuse_i64.2.dylib',
		'libosxfuse.2.dylib',
		'libTrAPI.dylib',
		'libntfs-3g.*.dylib',
		'libntfs.*.dylib',
		'libublio.*.dylib',
		'libUFSDNTFS.dylib',
		'libUFSDExtFS.dylib',
		'libecomlodr.dylib',
		'libsymsea*.dylib',
		'sentinel.dylib',
		'sentinel-*.dylib',
		'libASAF.dylib',
	], "Unbrewed dylibs were found in /usr/local/lib.\nIf you didn't put them there on purpose they could cause problems when\nbuilding Homebrew formulae and may need to be deleted.\n\nUnexpected dylibs:\n")
}

pub fn diagnostic_check_stray_static_libs(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	return diagnostic_stray_finding(checks, '/usr/local/lib', '*.a', [
		'libfuse-t*.a',
		'libfuse3.a',
		'libntfs-3g.a',
		'libntfs.a',
		'libublio.a',
		'libappfirewall.a',
		'libautoblock.a',
		'libautosetup.a',
		'libconnectionsclient.a',
		'liblocationawareness.a',
		'libpersonalfirewall.a',
		'libtrustedcomponents.a',
	], "Unbrewed static libraries were found in /usr/local/lib.\nIf you didn't put them there on purpose they could cause problems when\nbuilding Homebrew formulae and may need to be deleted.\n\nUnexpected static libraries:\n")
}

pub fn diagnostic_check_stray_pcs(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	return diagnostic_stray_finding(checks, '/usr/local/lib/pkgconfig', '*.pc', [
		'fuse.pc',
		'fuse3.pc',
		'fuse-t.pc',
		'macfuse.pc',
		'osxfuse.pc',
		'libntfs-3g.pc',
		'libublio.pc',
	], "Unbrewed '.pc' files were found in /usr/local/lib/pkgconfig.\nIf you didn't put them there on purpose they could cause problems when\nbuilding Homebrew formulae and may need to be deleted.\n\nUnexpected '.pc' files:\n")
}

pub fn diagnostic_check_stray_las(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	return diagnostic_stray_finding(checks, '/usr/local/lib', '*.la', [
		'libfuse.la',
		'libfuse_ino64.la',
		'libosxfuse_i32.la',
		'libosxfuse_i64.la',
		'libosxfuse.la',
		'libntfs-3g.la',
		'libntfs.la',
		'libublio.la',
	], "Unbrewed '.la' files were found in /usr/local/lib.\nIf you didn't put them there on purpose they could cause problems when\nbuilding Homebrew formulae and may need to be deleted.\n\nUnexpected '.la' files:\n")
}

pub fn diagnostic_check_stray_headers(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	return diagnostic_stray_finding(checks, '/usr/local/include', '**/*.h', [
		'fuse.h',
		'fuse/**/*.h',
		'fuse3/**/*.h',
		'macfuse/**/*.h',
		'osxfuse/**/*.h',
		'ntfs/**/*.h',
		'ntfs-3g/**/*.h',
	], "Unbrewed header files were found in /usr/local/include.\nIf you didn't put them there on purpose they could cause problems when\nbuilding Homebrew formulae and may need to be deleted.\n\nUnexpected header files:\n")
}

pub fn diagnostic_check_broken_symlinks(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	mut broken := []string{}
	for path in checks.symlinks {
		if checks.must_exist_directories.any(path.starts_with('${it.trim_right('/')}/')) && (checks.resolved_paths[path] or { '' }) == '' {
			broken << path
		}
	}
	if broken.len == 0 {
		return none
	}
	return diagnostic_finding.Finding{
		text: diagnostic_inject_file_list(broken, 'Broken symlinks were found:\n')
		remediation: diagnostic_remediation('Remove them with `brew cleanup`\n', [
			'brew cleanup',
		])
	}
}

pub fn diagnostic_check_tmpdir_sticky_bit(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	world_writable := checks.temp in checks.writable_directories
	sticky := '${checks.temp}/.sticky' in checks.existing_files
	if !world_writable || sticky {
		return none
	}
	return diagnostic_finding.Finding{
		text: '${checks.temp} is world-writable but does not have the sticky bit set.\n'
		remediation: diagnostic_remediation('To set it, run the following command:\n  sudo chmod +t ${checks.temp}\n', [
			'sudo chmod +t ${checks.temp}',
		])
	}
}

pub fn diagnostic_check_exist_directories(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	if checks.prefix in checks.writable_directories {
		return none
	}
	missing := checks.must_exist_directories.filter(it !in checks.existing_directories)
	if missing.len == 0 {
		return none
	}
	joined := missing.join(' ')
	return diagnostic_finding.Finding{
		text: 'The following directories do not exist:\n${missing.join('\n')}\n'
		remediation: diagnostic_remediation('You should create these directories and change their ownership to your user.\n  sudo mkdir -p ${joined}\n  sudo chown -R ${checks.current_user_name} ${joined}\n', [
			'sudo mkdir -p ${joined}',
			'sudo chown -R ${checks.current_user_name} ${joined}',
		])
	}
}

pub fn diagnostic_check_access_directories(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	not_writable := checks.must_be_writable_directories.filter(it in checks.existing_directories && it !in checks.writable_directories)
	if not_writable.len == 0 {
		return none
	}
	joined := not_writable.join(' ')
	return diagnostic_finding.Finding{
		text: 'The following directories are not writable by your user:\n${not_writable.join('\n')}\n'
		remediation: diagnostic_remediation('You should change the ownership of these directories to your user.\n  sudo chown -R ${checks.current_user_name} ${joined}\n\nAnd make sure that your user has write permission.\n  chmod u+w ${joined}\n', [
			'sudo chown -R ${checks.current_user_name} ${joined}',
			'chmod u+w ${joined}',
		])
	}
}

pub fn diagnostic_check_multiple_cellars(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	if checks.prefix == checks.repository {
		return none
	}
	repository_cellar := diagnostic_path_join(checks.repository, 'Cellar')
	prefix_cellar := diagnostic_path_join(checks.prefix, 'Cellar')
	if repository_cellar !in checks.existing_directories || prefix_cellar !in checks.existing_directories {
		return none
	}
	return diagnostic_finding.Finding{
		text: 'You have multiple Cellars.\n'
		remediation: diagnostic_remediation('You should delete ${repository_cellar}:\n  rm -rf ${repository_cellar}\n', [
			'rm -rf ${repository_cellar}',
		])
	}
}

fn diagnostic_prepend_path(path string) string {
	return 'echo \'export PATH="${path}:\$PATH"\' >> ~/.zshrc'
}

pub fn diagnostic_check_user_path_1(mut checks DiagnosticChecks) ?diagnostic_finding.Finding {
	checks.seen_prefix_bin = false
	checks.seen_prefix_sbin = false
	mut conflicts := []string{}
	for path in diagnostic_unique(checks.original_paths) {
		if path == '/usr/bin' && !checks.seen_prefix_bin {
			for child in checks.directory_children[diagnostic_path_join(checks.prefix, 'bin')] or { [] } {
				name := diagnostic_basename(child)
				if diagnostic_path_join('/usr/bin', name) in checks.existing_files { conflicts << name }
			}
		} else if path == diagnostic_path_join(checks.prefix, 'bin') {
			checks.seen_prefix_bin = true
		} else if path == diagnostic_path_join(checks.prefix, 'sbin') {
			checks.seen_prefix_sbin = true
		}
	}
	checks.user_path_1_done = true
	if conflicts.len == 0 {
		return none
	}
	path := diagnostic_path_join(checks.prefix, 'bin')
	return diagnostic_finding.Finding{
		text: diagnostic_inject_file_list(conflicts, '/usr/bin occurs before ${path} in your PATH.\nThis means that system-provided programs will be used instead of those\nprovided by Homebrew.\n\nThe following tools exist at both paths:\n')
		remediation: diagnostic_remediation('Consider setting your PATH so that\n${path} occurs before /usr/bin. Here is a one-liner:\n  ${diagnostic_prepend_path(path)}\n', [
			diagnostic_prepend_path(path),
		])
	}
}

pub fn diagnostic_check_user_path_2(mut checks DiagnosticChecks) ?diagnostic_finding.Finding {
	if !checks.user_path_1_done {
		_ = diagnostic_check_user_path_1(mut checks)
	}
	if checks.seen_prefix_bin {
		return none
	}
	path := diagnostic_path_join(checks.prefix, 'bin')
	return diagnostic_finding.Finding{
		text: 'Homebrew\'s "bin" was not found in your PATH.\n'
		remediation: diagnostic_remediation('Consider setting your PATH for example like so:\n  ${diagnostic_prepend_path(path)}\n', [
			diagnostic_prepend_path(path),
		])
	}
}

pub fn diagnostic_check_user_path_3(mut checks DiagnosticChecks) ?diagnostic_finding.Finding {
	if !checks.user_path_1_done {
		_ = diagnostic_check_user_path_1(mut checks)
	}
	if checks.seen_prefix_sbin {
		return none
	}
	sbin := diagnostic_path_join(checks.prefix, 'sbin')
	if sbin !in checks.existing_directories {
		return none
	}
	children := checks.directory_children[sbin] or { [] }
	if children.len == 0 || (children.len == 1 && diagnostic_basename(children[0]) == '.keepme') {
		return none
	}
	return diagnostic_finding.Finding{
		text: 'Homebrew\'s "sbin" was not found in your PATH but you have installed\nformulae that put executables in ${sbin}.\n'
		remediation: diagnostic_remediation('Consider setting your PATH for example like so:\n  ${diagnostic_prepend_path(sbin)}\n', [
			diagnostic_prepend_path(sbin),
		])
	}
}

pub fn diagnostic_check_symlinked_cellar(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	if checks.cellar !in checks.existing_directories || checks.cellar !in checks.symlinks {
		return none
	}
	realpath := checks.resolved_paths[checks.cellar] or { '' }
	return diagnostic_finding.Finding{ text: 'Symlinked Cellars can cause problems.\nYour Homebrew Cellar is a symlink: ${checks.cellar}\n                which resolves to: ${realpath}\n\nThe recommended Homebrew installations are either:\n(A) Have Cellar be a real directory inside of your `\$HOMEBREW_PREFIX`\n(B) Symlink "bin/brew" into your prefix, but don\'t symlink "Cellar".\n\nOlder installations of Homebrew may have created a symlinked Cellar, but this can\ncause problems when two formulae install to locations that are mapped on top of each\nother during the linking step.\n' }
}

pub fn diagnostic_check_git_version(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	if !checks.git_available || !diagnostic_version_less(checks.git_version, checks.minimum_git_version) {
		return none
	}
	verb := if checks.git_formula_installed { 'upgrade' } else { 'install' }
	return diagnostic_finding.Finding{
		text: 'An outdated version (${checks.git_version}) of Git was detected in your PATH.\nGit ${checks.minimum_git_version} or newer is required for Homebrew.\n'
		remediation: diagnostic_remediation('Please upgrade:\n  brew ${verb} git\n', [
			'brew ${verb} git',
		])
	}
}

pub fn diagnostic_check_for_git(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	if checks.git_available {
		return none
	}
	return diagnostic_finding.Finding{
		text: 'Git could not be found in your PATH.\nHomebrew uses Git for several internal functions and some formulae use Git\ncheckouts instead of stable tarballs.\n'
		remediation: diagnostic_remediation('You may want to install Git:\n  brew install git\n', [
			'brew install git',
		])
	}
}

pub fn diagnostic_check_git_newline(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	if !checks.git_available || checks.git_autocrlf != 'true' {
		return none
	}
	return diagnostic_finding.Finding{
		text: 'Suspicious Git newline settings found.\n\nThe detected Git newline settings will cause checkout problems:\n  core.autocrlf = ${checks.git_autocrlf}\n'
		remediation: diagnostic_remediation('If you are not routinely dealing with Windows-based projects,\nconsider removing these by running:\n  git config --global core.autocrlf input\n', [
			'git config --global core.autocrlf input',
		])
	}
}

pub fn diagnostic_check_repository_hooks(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	mut found := []string{}
	hooks := diagnostic_path_join(checks.repository, '.git/hooks')
	for child in checks.directory_children[hooks] or { [] } {
		if !child.ends_with('.sample') { found << child }
	}
	gitconfig := diagnostic_path_join(checks.repository, '.gitconfig')
	if gitconfig in checks.existing_files { found << gitconfig }
	found.sort()
	if found.len == 0 {
		return none
	}
	return diagnostic_finding.Finding{
		text: diagnostic_inject_file_list(found, 'Git hooks or a repository-local `.gitconfig` were found in your Homebrew repository.\nHomebrew does not use these, and they can break Homebrew operations.\n\nPaths found:\n')
		remediation: diagnostic_remediation('Remove them with:\n  rm -rf "${hooks}" "${gitconfig}"\n', [
			'rm -rf "${hooks}" "${gitconfig}"',
		])
	}
}

pub fn diagnostic_check_nix(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	if !checks.nix_managed {
		return none
	}
	return diagnostic_finding.Finding{ text: 'Your Homebrew installation is managed by Nix.\nHomebrew does not support Nix-managed installations.\n', tier: '3' }
}

pub fn diagnostic_check_tap_integrity(checks DiagnosticChecks, tap DiagnosticTap,
	desired_origin string) ?diagnostic_finding.Finding {
	if !tap.installed {
		return none
	}
	if finding := diagnostic_broken_tap(checks, tap) {
		return finding
	}
	return diagnostic_examine_git_origin(checks, tap.path, desired_origin, if tap.remote == '' {
		none
	} else {
		tap.remote
	})
}

fn diagnostic_core_tap(checks DiagnosticChecks) ?DiagnosticTap {
	for tap in checks.taps {
		if tap.core {
			return tap
		}
	}
	return none
}

fn diagnostic_core_cask_tap(checks DiagnosticChecks) ?DiagnosticTap {
	for tap in checks.taps {
		if tap.core_cask {
			return tap
		}
	}
	return none
}

pub fn diagnostic_check_tap_git_branch(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	if checks.ci || !checks.git_available {
		return none
	}
	mut deprecated_master := []string{}
	mut commands := []string{}
	if checks.repository_branch == 'master' { deprecated_master << 'Homebrew/brew' }
	for tap in checks.taps.filter(it.installed) {
		if tap.branch_name == 'master' && tap.official {
			deprecated_master << tap.name
		} else if !tap.default_origin_branch {
			commands << 'git -C \$(brew --repo ${tap.name}) checkout ${tap.origin_branch_name}'
		}
	}
	mut message := ''
	if deprecated_master.len > 0 {
		message = 'The following repositories are on the deprecated "master" branch.\nThe "master" branch sync will stop and this warning will become an error\nwhen Homebrew 5.2.0 is released (no earlier than 2026-06-10).\nRun `brew update` to migrate to "main":\n  ${deprecated_master.join('\n  ')}\n'
	}
	mut remediation := ?diagnostic_finding.Remediation(none)
	if commands.len > 0 {
		if message != '' {
			message += '\n'
		}
		message += 'Some taps are not on the default git origin branch and may not receive updates.\n'
		remediation = diagnostic_remediation('If this is a surprise to you, check out the default branch with:\n  ${commands.join('\n  ')}\n', commands)
	}
	if message == '' {
		return none
	}
	return diagnostic_finding.Finding{ text: message, remediation: remediation }
}

pub fn diagnostic_check_deprecated_official_taps(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	mut taps := checks.deprecated_official_taps.clone()
	if checks.github_actions {
		taps = taps.filter(it != 'bundle')
	}
	if taps.len == 0 {
		return none
	}
	return diagnostic_finding.Finding{
		text: 'You have the following deprecated, official taps tapped:\n  Homebrew/homebrew-${taps.join('\n  Homebrew/homebrew-')}\n'
		remediation: diagnostic_remediation('Untap them with `brew untap`.\n', [])
	}
}

fn diagnostic_tap_name_from_full_name(name string) string {
	parts := name.split('/')
	return if parts.len == 3 { '${parts[0]}/${parts[1]}' } else { '' }
}

fn diagnostic_to_sentence(values []string) string {
	if values.len == 0 {
		return ''
	}
	if values.len == 1 {
		return values[0]
	}
	if values.len == 2 {
		return '${values[0]} and ${values[1]}'
	}
	return '${values[..values.len - 1].join(', ')}, and ${values.last()}'
}

pub fn diagnostic_check_untrusted_taps(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	if checks.no_require_tap_trust || checks.untrusted_taps.len == 0 {
		return none
	}
	mut tap_names := checks.untrusted_taps.clone()
	mut formulae_by_tap := map[string][]string{}
	mut casks_by_tap := map[string][]string{}
	for formula in checks.formulae {
		if formula.tap in tap_names {
			formulae_by_tap[formula.tap] << '${formula.tap}/${formula.name}'
		}
	}
	for cask in checks.casks {
		if cask.tap in tap_names {
			casks_by_tap[cask.tap] << '${cask.tap}/${cask.token}'
		}
	}
	mut formula_taps := formulae_by_tap.keys()
	formula_taps.sort()
	mut cask_taps := casks_by_tap.keys()
	cask_taps.sort()
	mut formula_commands := []string{}
	for tap in formula_taps {
		mut names := formulae_by_tap[tap]
		names.sort()
		if names.len > 0 { formula_commands << '  brew trust --formula ${names.join(' ')}' }
	}
	mut cask_commands := []string{}
	for tap in cask_taps {
		mut names := casks_by_tap[tap]
		names.sort()
		if names.len > 0 { cask_commands << '  brew trust --cask ${names.join(' ')}' }
	}
	installed_items := formula_commands.len > 0 || cask_commands.len > 0
	untap := 'Untap them with:\n  brew untap ${tap_names.join(' ')}'
	mut generic_types := []string{}
	mut generic_commands := []string{}
	if formula_commands.len == 0 {
		generic_types << 'formulae'
		generic_commands << '  brew trust --formula <user>/<tap>/<formula>'
	}
	if cask_commands.len == 0 {
		generic_types << 'casks'
		generic_commands << '  brew trust --cask <user>/<tap>/<cask>'
	}
	generic_types << 'commands'
	generic_commands << '  brew trust --command <user>/<tap>/<command>'
	prefix := if installed_items { 'Trust other specific' } else { 'Trust specific' }
	mut trust_messages := if installed_items {
		['Prefer trusting only the specific formulae, casks or commands you need.']
	} else {
		[untap]
	}
	if formula_commands.len > 0 {
		trust_messages << 'Trust installed formulae from these taps with:\n${formula_commands.join('\n')}'
	}
	if cask_commands.len > 0 {
		trust_messages << 'Trust installed casks from these taps with:\n${cask_commands.join('\n')}'
	}
	trust_messages << '${prefix} ${diagnostic_to_sentence(generic_types)} with:\n${generic_commands.join('\n')}'
	trust_messages << 'Whole-tap trust is broader and includes all current and future formulae,\ncasks and commands from the listed taps. Trust whole taps with:\n  brew trust ${tap_names.join(' ')}'
	if installed_items { trust_messages << untap }
	if !checks.no_env_hints {
		trust_messages << 'To disable trust checks:\n  export HOMEBREW_NO_REQUIRE_TAP_TRUST=1\nThis is not recommended and will be removed in a later release.'
	}
	trust_messages << 'For more information, see:\n  https://docs.brew.sh/Tap-Trust'
	return diagnostic_finding.Finding{
		text: 'The following taps are not trusted:\n  ${tap_names.join('\n  ')}\n\nHomebrew is currently ignoring formulae, casks and commands from these taps because tap trust is required.\n'
		links: ['https://docs.brew.sh/Tap-Trust']
		remediation: diagnostic_remediation(trust_messages.join('\n'), [])
	}
}

pub fn diagnostic_check_linked_brew(formula DiagnosticFormula) bool {
	for prefix in formula.installed_prefixes {
		for source, destination in formula.linked_files {
			if source.starts_with('${prefix.trim_right('/')}/') && destination == source {
				return true
			}
		}
	}
	return false
}

pub fn diagnostic_check_other_frameworks(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	allowed := ['expat.framework', 'libexpat.framework', 'libcurl.framework']
	found := checks.frameworks.filter(diagnostic_basename(it) in allowed)
	if found.len == 0 {
		return none
	}
	return diagnostic_finding.Finding{
		text: "Some frameworks can be picked up by CMake's build system and will likely\ncause the build to fail.\n"
		remediation: diagnostic_remediation('To compile CMake, you may wish to move these out of the way:\n${found.join('\n')}\n', [])
	}
}

pub fn diagnostic_check_tmpdir(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	if checks.tmpdir == '' || checks.tmpdir in checks.existing_directories {
		return none
	}
	return diagnostic_finding.Finding{ text: 'TMPDIR "${checks.tmpdir}" doesn\'t exist.\n' }
}

pub fn diagnostic_check_missing_deps(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	if checks.cellar !in checks.existing_directories && checks.caskroom_path !in checks.existing_directories {
		return none
	}
	mut missing := diagnostic_unique(checks.missing_dependencies)
	missing.sort()
	if missing.len == 0 {
		return none
	}
	return diagnostic_finding.Finding{
		text: 'Some installed formulae or casks are missing dependencies.\nRun `brew missing` for more details.\n'
		remediation: diagnostic_remediation('You should `brew install` the missing dependencies:\n  brew install ${missing.join(' ')}\n', [
			'brew install ${missing.join(' ')}',
		])
	}
}

pub fn diagnostic_check_deprecated_disabled(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	if checks.cellar !in checks.existing_directories {
		return none
	}
	mut affected := checks.formulae.filter(it.deprecated || it.disabled).map(it.full_name)
	if affected.len == 0 {
		return none
	}
	mut sorted := diagnostic_unique(affected)
	sorted.sort()
	return diagnostic_finding.Finding{
		text: 'Some installed formulae are deprecated or disabled.'
		affects: affected
		remediation: diagnostic_remediation('You should find replacements for the following formulae:\n    ${sorted.join('\n  ')}\n', [])
	}
}

pub fn diagnostic_check_cask_deprecated_disabled(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	mut affected := checks.casks.filter(it.deprecated).map(it.token)
	affected << checks.casks.filter(it.disabled).map(it.token)
	if affected.len == 0 {
		return none
	}
	mut sorted := diagnostic_unique(affected)
	sorted.sort()
	return diagnostic_finding.Finding{
		text: 'Some installed casks are deprecated or disabled.'
		affects: affected
		remediation: diagnostic_remediation('You should find replacements for the following casks:\n${sorted.join('\n  ')}\n', [])
	}
}

pub fn diagnostic_tap_git_status(checks DiagnosticChecks, tap string, path string) ?diagnostic_finding.Finding {
	if path !in checks.existing_directories {
		return none
	}
	modified := checks.git_statuses[path] or { return none }
	if modified.len == 0 {
		return none
	}
	return diagnostic_finding.Finding{
		text: diagnostic_inject_file_list(modified, 'You have uncommitted modifications to ${tap}.\nUncommitted files:\n')
		affects: modified
		remediation: diagnostic_remediation('If this is a surprise to you, then you should stash these modifications.\nStashing returns Homebrew to a pristine state but can be undone\nshould you later need to do so for some reason.\n\n  git -C "${path}" stash -u && git -C "${path}" clean -d -f\n', [
			'git -C "${path}" stash -u && git -C "${path}" clean -d -f',
		])
	}
}

pub fn diagnostic_check_git_status(checks DiagnosticChecks) []diagnostic_finding.Finding {
	if !checks.git_available {
		return []
	}
	mut repositories := {
		'Homebrew/brew': checks.repository
	}
	if tap := diagnostic_core_tap(checks) {
		repositories['Homebrew/homebrew-core'] = tap.path
	}
	if tap := diagnostic_core_cask_tap(checks) {
		repositories['Homebrew/homebrew-cask'] = tap.path
	}
	mut findings := []diagnostic_finding.Finding{}
	for name, path in repositories {
		if finding := diagnostic_tap_git_status(checks, name, path) { findings << finding }
	}
	return findings
}

pub fn diagnostic_check_non_prefixed_coreutils(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	formula := checks.formulae.filter(it.name == 'coreutils' && it.installed)
	if formula.len == 0 {
		return none
	}
	gnubin := [diagnostic_path_join(formula[0].opt_libexec, 'gnubin'),
		diagnostic_path_join(formula[0].libexec, 'gnubin')]
	if !checks.original_paths.any(it in gnubin) {
		return none
	}
	return diagnostic_finding.Finding{ text: 'Putting non-prefixed coreutils in your path can cause GMP builds to fail.\n' }
}

pub fn diagnostic_check_pydistutils(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	if diagnostic_path_join(checks.home, '.pydistutils.cfg') !in checks.existing_files {
		return none
	}
	return diagnostic_finding.Finding{
		text: "A '.pydistutils.cfg' file was found in \$HOME, which may cause Python\nbuilds to fail. See:\n  https://bugs.python.org/issue6138\n  https://bugs.python.org/issue4655\n"
		links: ['https://bugs.python.org/issue6138', 'https://bugs.python.org/issue4655']
	}
}

pub fn diagnostic_check_unreadable_formulae(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	errors := checks.formulae.map(it.read_error).filter(it != '')
	if errors.len == 0 {
		return none
	}
	return diagnostic_finding.Finding{
		text: 'Some installed formulae are not readable:\n  ${errors.join('\n\n  ')}\n'
		affects: errors
	}
}

pub fn diagnostic_check_unlinked_formulae(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	mut unlinked := []string{}
	for formula in checks.formulae {
		if formula.linked || formula.keg_only || formula.read_error.starts_with('UntrustedTapError') {
			continue
		}
		unlinked << formula.name
	}
	if unlinked.len == 0 {
		return none
	}
	return diagnostic_finding.Finding{
		text: 'You have unlinked kegs in your Cellar.\nLeaving kegs unlinked can lead to build-trouble and cause formulae that depend on\nthose kegs to fail to run properly once built.\n'
		affects: unlinked
		remediation: diagnostic_remediation(diagnostic_inject_file_list(unlinked, 'Run `brew link` on these:\n'), unlinked.map('brew link ${it}'))
	}
}

pub fn diagnostic_check_external_command_conflicts(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	mut commands := map[string][]string{}
	for path in checks.executable_files {
		name := diagnostic_basename(path).trim_string_right('.rb')
		if name.starts_with('brew-') { commands[name] << path }
	}
	for name in commands.keys() {
		if commands[name].len < 2 { commands.delete(name) }
	}
	if commands.len == 0 {
		return none
	}
	if checks.ci && commands.len == 1 && 'brew-test-bot' in commands {
		return none
	}
	mut message := 'You have external commands with conflicting names.\n'
	mut names := commands.keys()
	names.sort()
	for name in names {
		message += diagnostic_inject_file_list(commands[name], 'Found command `${name}` in the following places:\n')
	}
	return diagnostic_finding.Finding{ text: message }
}

pub fn diagnostic_check_tap_ruby_locations(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	mut messages := []string{}
	for tap in checks.taps {
		if tap.bad_ruby_files.len > 0 {
			messages << 'Found Ruby file outside ${tap.name} tap formula directory.\n(${diagnostic_path_join(tap.path, 'Formula')}):\n  ${tap.bad_ruby_files.join('\n  ')}\n'
		}
	}
	if messages.len == 0 {
		return none
	}
	return diagnostic_finding.Finding{ text: messages.join('\n') }
}

pub fn diagnostic_check_homebrew_prefix(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	if checks.prefix == checks.default_prefix {
		return none
	}
	return diagnostic_finding.Finding{
		text: "Your Homebrew's prefix is not ${checks.default_prefix}.\n\nMost of Homebrew's bottles (binary packages) can only be used with the default prefix.\n"
		tier: '3'
		remediation: diagnostic_remediation('Consider uninstalling Homebrew and reinstalling into the default prefix.', [])
	}
}

pub fn diagnostic_check_deleted_formula(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	mut deleted := checks.deleted_formulae.clone()
	for formula in checks.formulae {
		if !formula.loadable && formula.name !in deleted { deleted << formula.name }
	}
	if deleted.len == 0 {
		return none
	}
	return diagnostic_finding.Finding{
		text: 'Some installed kegs have no formulae!\nThis means they were either deleted or installed manually.\n\n'
		affects: deleted
		remediation: diagnostic_remediation('You should find replacements for the following formulae:\n  ${deleted.join('\n  ')}\n', [])
	}
}

pub fn diagnostic_check_unnecessary_tap(checks DiagnosticChecks, tap DiagnosticTap,
	cask bool) ?diagnostic_finding.Finding {
	if checks.developer || checks.no_install_from_api || checks.devcmdrun || !tap.installed {
		return none
	}
	label := if cask { 'Cask tap.' } else { 'Core tap!' }
	return diagnostic_finding.Finding{
		text: 'You have an unnecessary local ${label}\nThis can cause problems installing up-to-date ${if cask {
			'casks'
		} else {
			'formulae'
		}}.\n'
		remediation: diagnostic_remediation('Please remove it by running:\n brew untap ${tap.name}\n', [
			'brew untap ${tap.name}',
		])
	}
}

pub fn diagnostic_check_deprecated_cask_taps(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	mut names := checks.taps.filter(it.name == 'phinze/cask' || it.name.starts_with('caskroom/')).map(it.name)
	if names.len == 0 {
		return none
	}
	return diagnostic_finding.Finding{
		text: 'You have the following deprecated Cask taps installed:\n  ${names.join('\n  ')}\n'
		remediation: diagnostic_remediation('Please remove it by running:\n brew untap ${names.join(' ')}\n', [
			'brew untap ${names.join(' ')}',
		])
	}
}

pub fn diagnostic_check_cask_install_location(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	if checks.legacy_cask_locations.len == 0 {
		return none
	}
	mut locations := checks.legacy_cask_locations.clone()
	locations.reverse_in_place()
	return diagnostic_finding.Finding{
		text: locations.map('Legacy install at ${it}.').join('\n')
		remediation: diagnostic_remediation('Run `brew uninstall --force brew-cask`.\n', [])
	}
}

pub fn diagnostic_check_cask_software_versions(mut checks DiagnosticChecks) {
	version := if checks.software_version == '0.0.0' {
		checks.brew_version
	} else {
		checks.software_version
	}
	diagnostic_add_info(mut checks, ['Homebrew Version', version])
}

pub fn diagnostic_check_cask_staging(mut checks DiagnosticChecks) ?diagnostic_finding.Finding {
	if checks.github_actions {
		return none
	}
	display := diagnostic_user_tilde(checks.caskroom_path, checks.home)
	diagnostic_add_info(mut checks, ['Cask Staging Location', display])
	if checks.caskroom_path !in checks.existing_directories || checks.caskroom_path in checks.writable_directories {
		return none
	}
	return diagnostic_finding.Finding{
		text: 'The staging path ${display} is not writable by the current user.\n'
		remediation: diagnostic_remediation('To fix, run:\n  sudo chown -R ${checks.current_user_name} ${display}\n', [
			'sudo chown -R ${checks.current_user_name} ${display}',
		])
	}
}

pub fn diagnostic_check_cask_corrupt(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	if checks.corrupt_casks.len == 0 {
		return none
	}
	fixes := checks.corrupt_casks.map('brew reinstall --cask --force ${it}')
	paths := checks.corrupt_casks.map(diagnostic_path_join(checks.caskroom_path, it))
	label := if checks.corrupt_casks.len == 1 { 'cask' } else { 'casks' }
	return diagnostic_finding.Finding{
		text: 'Some directories in the Caskroom do not have valid metadata.\n  ${paths.join('\n  ')}\nThe following ${label} cannot be upgraded as-is.\n'
		remediation: diagnostic_remediation('To fix this, run:\n  ${fixes.join('\n  ')}\n', fixes)
	}
}

pub fn diagnostic_check_cask_taps(mut checks DiagnosticChecks) ?diagnostic_finding.Finding {
	mut errors := []string{}
	mut info := []string{}
	for tap in checks.taps {
		if tap.cask_read_error {
			errors << tap.path
		} else if tap.cask_count > 0 {
			label := if tap.cask_count == 1 { '1 cask' } else { '${tap.cask_count} casks' }
			info << '${tap.path} (${label})'
		}
	}
	mut details := ['Cask Taps:']
	details << info
	diagnostic_add_info(mut checks, details)
	if errors.len == 0 {
		return none
	}
	return diagnostic_finding.Finding{
		text: 'Unable to read from cask ${if errors.len == 1 {
			'tap'
		} else {
			'taps'
		}}: ${diagnostic_to_sentence(errors)}'
	}
}

pub fn diagnostic_check_cask_load_path(mut checks DiagnosticChecks) ?diagnostic_finding.Finding {
	paths := checks.load_paths.map(diagnostic_user_tilde(it, checks.home))
	mut details := ['\$LOAD_PATHS']
	details << if paths.len > 0 { paths } else { ['<NONE>'] }
	diagnostic_add_info(mut checks, details)
	if paths.len == 0 {
		return diagnostic_finding.Finding{ text: '\$LOAD_PATH is empty' }
	}
	return none
}

fn diagnostic_shell_quote(value string) string {
	return if value.contains_any(' \t\n\'"') { "'${value.replace("'", "'\\''")}'" } else { value }
}

pub fn diagnostic_check_cask_environment(mut checks DiagnosticChecks) {
	base := ['RUBYLIB', 'RUBYOPT', 'RUBYPATH', 'RBENV_VERSION', 'CHRUBY_VERSION', 'GEM_HOME',
		'GEM_PATH', 'BUNDLE_PATH', 'PATH', 'SHELL', 'HOMEBREW_CASK_OPTS']
	mut keys := checks.environment.keys().filter(it == 'LANG' || it == 'LANGUAGE' || it.starts_with('LC_'))
	keys << base
	keys = diagnostic_unique(keys)
	keys.sort()
	values := keys.filter(it in checks.environment).map('${it}="${diagnostic_shell_quote(checks.environment[it])}"')
	mut details := ['Cask Environment Variables:']
	details << values
	diagnostic_add_info(mut checks, details)
}

pub fn diagnostic_check_cask_xattr(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	if !checks.quarantine_available {
		return none
	}
	if !checks.xattr_exists {
		return diagnostic_finding.Finding{ text: 'Unable to find `xattr`.' }
	}
	if checks.xattr_success {
		return none
	}
	if checks.xattr_stderr.contains('ImportError: No module named pkg_resources') {
		if checks.system_python_version.contains('Python 2.7') {
			return diagnostic_finding.Finding{ text: 'Your Python installation has a broken version of setuptools.\n', remediation: diagnostic_remediation('To fix, reinstall macOS or run:\n  sudo /usr/bin/python -m pip install -I setuptools\n', []) }
		}
		return diagnostic_finding.Finding{ text: 'The system Python version is wrong.\n', remediation: diagnostic_remediation('To fix, run:\n  defaults write com.apple.versioner.python Version 2.7\n', []) }
	}
	if checks.xattr_stderr.contains('pkg_resources.DistributionNotFound') {
		return diagnostic_finding.Finding{ text: 'Your Python installation is unable to find `xattr`.' }
	}
	lines := checks.xattr_stderr.split_into_lines()
	return diagnostic_finding.Finding{
		text: 'unknown xattr error: ${if lines.len > 0 {
			lines.last()
		} else {
			''
		}}'
	}
}

pub fn diagnostic_non_core_taps(checks DiagnosticChecks) []DiagnosticTap {
	return checks.taps.filter(!it.core && !it.core_cask && it.installed)
}

fn diagnostic_intersection(left []string, right []string) []string {
	return diagnostic_unique(left.filter(it in right))
}

pub fn diagnostic_check_duplicate_formulae(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	if checks.test_bot {
		return none
	}
	mut shadowed := []string{}
	for tap in diagnostic_non_core_taps(checks) {
		prefix := '${tap.name}/'
		names := tap.formula_names.map(if it.starts_with(prefix) { it[prefix.len..] } else { it })
		for name in diagnostic_intersection(checks.core_formula_names, names) {
			shadowed << '${tap.name}/${name}'
		}
	}
	shadowed.sort()
	if shadowed.len == 0 {
		return none
	}
	shadow_taps := diagnostic_unique(shadowed.map(diagnostic_tap_name_from_full_name(it)))
	mut unused := shadow_taps.filter(it !in checks.installed_formula_tap_names)
	unused.sort()
	text := if unused.len == 0 {
		'Their taps are in use, so you must use these full names throughout Homebrew.'
	} else {
		'Some of these can be resolved with:\n  brew untap ${unused.join(' ')}'
	}
	return diagnostic_finding.Finding{ text: 'The following formulae have the same name as core formulae:\n  ${shadowed.join('\n  ')}\n', remediation: diagnostic_remediation(text, []) }
}

pub fn diagnostic_check_duplicate_casks(checks DiagnosticChecks) ?diagnostic_finding.Finding {
	if checks.test_bot {
		return none
	}
	mut shadowed := []string{}
	for tap in diagnostic_non_core_taps(checks) {
		prefix := '${tap.name}/'
		names := tap.cask_tokens.map(if it.starts_with(prefix) { it[prefix.len..] } else { it })
		for name in diagnostic_intersection(checks.core_cask_names, names) {
			shadowed << '${tap.name}/${name}'
		}
	}
	shadowed.sort()
	if shadowed.len == 0 {
		return none
	}
	shadow_taps := diagnostic_unique(shadowed.map(diagnostic_tap_name_from_full_name(it)))
	mut unused := shadow_taps.filter(it !in checks.installed_cask_tap_names)
	unused.sort()
	remediation := if unused.len == 0 {
		diagnostic_remediation('Their taps are in use, so you must use these full names throughout Homebrew.', [])
	} else {
		diagnostic_remediation('Some of these can be resolved with:', [
			'brew untap ${unused.join(' ')}',
		])
	}
	return diagnostic_finding.Finding{ text: 'The following casks have the same name as core casks:\n  ${shadowed.join('\n  ')}\n', affects: shadowed, remediation: remediation }
}

pub const diagnostic_all_checks = [
	'check_access_directories',
	'check_brew_git_origin',
	'check_cask_corrupt_dirs',
	'check_cask_deprecated_disabled',
	'check_cask_environment_variables',
	'check_cask_install_location',
	'check_cask_load_path',
	'check_cask_software_versions',
	'check_cask_staging_location',
	'check_cask_taps',
	'check_cask_xattr',
	'check_casktap_integrity',
	'check_coretap_integrity',
	'check_deleted_formula',
	'check_deprecated_cask_taps',
	'check_deprecated_disabled',
	'check_deprecated_official_taps',
	'check_for_broken_symlinks',
	'check_for_duplicate_casks',
	'check_for_duplicate_formulae',
	'check_for_external_cmd_name_conflict',
	'check_for_git',
	'check_for_installed_developer_tools',
	'check_for_nix_homebrew',
	'check_for_non_prefixed_coreutils',
	'check_for_other_frameworks',
	'check_for_pydistutils_cfg_in_home',
	'check_for_stray_dylibs',
	'check_for_stray_headers',
	'check_for_stray_las',
	'check_for_stray_pcs',
	'check_for_stray_static_libs',
	'check_for_symlinked_cellar',
	'check_for_tap_ruby_files_locations',
	'check_for_unlinked_but_not_keg_only',
	'check_for_unnecessary_cask_tap',
	'check_for_unnecessary_core_tap',
	'check_for_unreadable_installed_formula',
	'check_git_newline_settings',
	'check_git_status',
	'check_git_version',
	'check_homebrew_prefix',
	'check_homebrew_repository_git_hooks',
	'check_missing_deps',
	'check_multiple_cellars',
	'check_tap_git_branch',
	'check_tmpdir',
	'check_tmpdir_sticky_bit',
	'check_untrusted_taps',
	'check_user_path_1',
	'check_user_path_2',
	'check_user_path_3',
]

pub fn diagnostic_cask_checks() []string {
	return diagnostic_all_checks.filter(it.starts_with('check_cask_'))
}

fn diagnostic_optional_finding(finding ?diagnostic_finding.Finding) []diagnostic_finding.Finding {
	value := finding or { return []diagnostic_finding.Finding{} }
	return [value]
}

pub fn diagnostic_run_named_check(mut checks DiagnosticChecks, name string) []diagnostic_finding.Finding {
	return match name {
		'check_access_directories' {
			diagnostic_optional_finding(diagnostic_check_access_directories(checks))
		}
		'check_brew_git_origin' {
			diagnostic_optional_finding(diagnostic_examine_git_origin(checks, checks.repository, checks.desired_brew_origin, if checks.repository_origin == '' {
				none
			} else {
				checks.repository_origin
			}))
		}
		'check_cask_corrupt_dirs' {
			diagnostic_optional_finding(diagnostic_check_cask_corrupt(checks))
		}
		'check_cask_deprecated_disabled' {
			diagnostic_optional_finding(diagnostic_check_cask_deprecated_disabled(checks))
		}
		'check_cask_environment_variables' {
			diagnostic_check_cask_environment(mut checks)
			[]diagnostic_finding.Finding{}
		}
		'check_cask_install_location' {
			diagnostic_optional_finding(diagnostic_check_cask_install_location(checks))
		}
		'check_cask_load_path' {
			diagnostic_optional_finding(diagnostic_check_cask_load_path(mut checks))
		}
		'check_cask_software_versions' {
			diagnostic_check_cask_software_versions(mut checks)
			[]diagnostic_finding.Finding{}
		}
		'check_cask_staging_location' {
			diagnostic_optional_finding(diagnostic_check_cask_staging(mut checks))
		}
		'check_cask_taps' { diagnostic_optional_finding(diagnostic_check_cask_taps(mut checks)) }
		'check_cask_xattr' { diagnostic_optional_finding(diagnostic_check_cask_xattr(checks)) }
		'check_casktap_integrity' {
			if tap := diagnostic_core_cask_tap(checks) {
				diagnostic_optional_finding(diagnostic_check_tap_integrity(checks, tap, tap.remote))
			} else {
				[]diagnostic_finding.Finding{}
			}
		}
		'check_coretap_integrity' {
			if tap := diagnostic_core_tap(checks) {
				diagnostic_optional_finding(diagnostic_check_tap_integrity(checks, tap, checks.desired_core_origin))
			} else {
				[]diagnostic_finding.Finding{}
			}
		}
		'check_deleted_formula' {
			diagnostic_optional_finding(diagnostic_check_deleted_formula(checks))
		}
		'check_deprecated_cask_taps' {
			diagnostic_optional_finding(diagnostic_check_deprecated_cask_taps(checks))
		}
		'check_deprecated_disabled' {
			diagnostic_optional_finding(diagnostic_check_deprecated_disabled(checks))
		}
		'check_deprecated_official_taps' {
			diagnostic_optional_finding(diagnostic_check_deprecated_official_taps(checks))
		}
		'check_for_broken_symlinks' {
			diagnostic_optional_finding(diagnostic_check_broken_symlinks(checks))
		}
		'check_for_duplicate_casks' {
			diagnostic_optional_finding(diagnostic_check_duplicate_casks(checks))
		}
		'check_for_duplicate_formulae' {
			diagnostic_optional_finding(diagnostic_check_duplicate_formulae(checks))
		}
		'check_for_external_cmd_name_conflict' {
			diagnostic_optional_finding(diagnostic_check_external_command_conflicts(checks))
		}
		'check_for_git' { diagnostic_optional_finding(diagnostic_check_for_git(checks)) }
		'check_for_installed_developer_tools' {
			diagnostic_optional_finding(diagnostic_check_developer_tools(checks))
		}
		'check_for_nix_homebrew' { diagnostic_optional_finding(diagnostic_check_nix(checks)) }
		'check_for_non_prefixed_coreutils' {
			diagnostic_optional_finding(diagnostic_check_non_prefixed_coreutils(checks))
		}
		'check_for_other_frameworks' {
			diagnostic_optional_finding(diagnostic_check_other_frameworks(checks))
		}
		'check_for_pydistutils_cfg_in_home' {
			diagnostic_optional_finding(diagnostic_check_pydistutils(checks))
		}
		'check_for_stray_dylibs' {
			diagnostic_optional_finding(diagnostic_check_stray_dylibs(checks))
		}
		'check_for_stray_headers' {
			diagnostic_optional_finding(diagnostic_check_stray_headers(checks))
		}
		'check_for_stray_las' { diagnostic_optional_finding(diagnostic_check_stray_las(checks)) }
		'check_for_stray_pcs' { diagnostic_optional_finding(diagnostic_check_stray_pcs(checks)) }
		'check_for_stray_static_libs' {
			diagnostic_optional_finding(diagnostic_check_stray_static_libs(checks))
		}
		'check_for_symlinked_cellar' {
			diagnostic_optional_finding(diagnostic_check_symlinked_cellar(checks))
		}
		'check_for_tap_ruby_files_locations' {
			diagnostic_optional_finding(diagnostic_check_tap_ruby_locations(checks))
		}
		'check_for_unlinked_but_not_keg_only' {
			diagnostic_optional_finding(diagnostic_check_unlinked_formulae(checks))
		}
		'check_for_unnecessary_cask_tap' {
			if tap := diagnostic_core_cask_tap(checks) {
				diagnostic_optional_finding(diagnostic_check_unnecessary_tap(checks, tap, true))
			} else {
				[]diagnostic_finding.Finding{}
			}
		}
		'check_for_unnecessary_core_tap' {
			if tap := diagnostic_core_tap(checks) {
				diagnostic_optional_finding(diagnostic_check_unnecessary_tap(checks, tap, false))
			} else {
				[]diagnostic_finding.Finding{}
			}
		}
		'check_for_unreadable_installed_formula' {
			diagnostic_optional_finding(diagnostic_check_unreadable_formulae(checks))
		}
		'check_git_newline_settings' {
			diagnostic_optional_finding(diagnostic_check_git_newline(checks))
		}
		'check_git_status' { diagnostic_check_git_status(checks) }
		'check_git_version' { diagnostic_optional_finding(diagnostic_check_git_version(checks)) }
		'check_homebrew_prefix' {
			diagnostic_optional_finding(diagnostic_check_homebrew_prefix(checks))
		}
		'check_homebrew_repository_git_hooks' {
			diagnostic_optional_finding(diagnostic_check_repository_hooks(checks))
		}
		'check_missing_deps' { diagnostic_optional_finding(diagnostic_check_missing_deps(checks)) }
		'check_multiple_cellars' {
			diagnostic_optional_finding(diagnostic_check_multiple_cellars(checks))
		}
		'check_tap_git_branch' {
			diagnostic_optional_finding(diagnostic_check_tap_git_branch(checks))
		}
		'check_tmpdir' { diagnostic_optional_finding(diagnostic_check_tmpdir(checks)) }
		'check_tmpdir_sticky_bit' {
			diagnostic_optional_finding(diagnostic_check_tmpdir_sticky_bit(checks))
		}
		'check_untrusted_taps' {
			diagnostic_optional_finding(diagnostic_check_untrusted_taps(checks))
		}
		'check_user_path_1' {
			diagnostic_optional_finding(diagnostic_check_user_path_1(mut checks))
		}
		'check_user_path_2' {
			diagnostic_optional_finding(diagnostic_check_user_path_2(mut checks))
		}
		'check_user_path_3' {
			diagnostic_optional_finding(diagnostic_check_user_path_3(mut checks))
		}
		else { panic('unknown diagnostic check `${name}`') }
	}
}

fn diagnostic_check_names(checks_type string) []string {
	return match checks_type {
		'fatal_preinstall_checks' { ['check_access_directories'] }
		'fatal_build_from_source_checks' { ['check_for_installed_developer_tools'] }
		'fatal_setup_build_environment_checks', 'supported_configuration_checks', 'build_from_source_checks', 'build_error_checks' {
			[]string{}
		}
		'preinstall_checks' { ['check_untrusted_taps'] }
		'all' { diagnostic_all_checks.clone() }
		'cask_checks' { diagnostic_cask_checks() }
		else { panic('unknown diagnostic check group `${checks_type}`') }
	}
}

pub fn diagnostic_run_checks(mut checks DiagnosticChecks, checks_type string,
	fatal bool) DiagnosticRunResult {
	mut output := []string{}
	for check in diagnostic_check_names(checks_type) {
		for finding in diagnostic_run_named_check(mut checks, check) {
			output << finding.string()
		}
	}
	failed := output.len > 0 && fatal
	return DiagnosticRunResult{
		failed: failed
		exit_code: if failed { 1 } else { 0 }
		output: output
	}
}

fn diagnostic_run_result_value(result DiagnosticRunResult) ruby.Value {
	return ruby.map_value({
		'failed':    ruby.bool_value(result.failed)
		'exit_code': ruby.int_value(result.exit_code)
		'output':    diagnostic_strings_value(result.output)
	})
}

fn diagnostic_receiver(args []ruby.Value) &DiagnosticChecks {
	if args.len == 0 {
		panic('Diagnostic::Checks receiver is required')
	}
	return diagnostic_checks_from_value(args[0])
}

fn diagnostic_value_is_nil(value ruby.Value) bool {
	return value.type_name == 'NilClass'
}
