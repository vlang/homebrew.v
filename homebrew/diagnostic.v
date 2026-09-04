module homebrew

import ruby
import homebrew.diagnostic as diagnostic_finding

// Translated from Homebrew/brew `diagnostic.rb`.
// The original source is retained below until every stub has a typed V body.
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
			none} else {
			diagnostic_remediation(checks.developer_tools_instructions, [])}
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
			'casks'} else {
			'formulae'}}.\n'
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
			'tap'} else {
			'taps'}}: ${diagnostic_to_sentence(errors)}'
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
			lines.last()} else {
			''}}'
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

// Ruby method `self.checks(type, fatal: true)` at line 26.
pub fn ruby_diagnostic_l26_d1_self_checks(args ...ruby.Value) ruby.Value {
	mut argument := 0
	mut checks := &DiagnosticChecks{}
	if args.len > 0 && args[0].type_name == 'Homebrew::Diagnostic::Checks' {
		checks = diagnostic_checks_from_value(args[0])
		argument++
	}
	if argument >= args.len {
		panic('Diagnostic.checks requires a check group')
	}
	checks_type := args[argument].as_string()
	fatal := if argument + 1 < args.len { args[argument + 1].as_bool() or { true } } else { true }
	return diagnostic_run_result_value(diagnostic_run_checks(mut checks, checks_type, fatal))
}

// Ruby method `initialize(verbose: true)` at line 49.
pub fn ruby_diagnostic_l49_d2_initialize(args ...ruby.Value) ruby.Value {
	verbose := if args.len == 0 {
		true
	} else if args[0].type_name == 'Hash' {
		(args[0].map_data['verbose'] or { ruby.bool_value(true) }).as_bool() or { true }
	} else {
		args[0].as_bool() or { true }
	}
	mut checks := &DiagnosticChecks{ verbose: verbose }
	return diagnostic_checks_value(checks)
}

// Ruby method `find_relative_paths(*relative_paths)` at line 63.
pub fn ruby_diagnostic_l63_d3_find_relative_paths(args ...ruby.Value) ruby.Value {
	mut checks := diagnostic_receiver(args)
	mut relative_paths := []string{}
	for value in args[1..] {
		if value.type_name == 'Array' {
			relative_paths << diagnostic_strings(value)
		} else {
			relative_paths << value.as_string()
		}
	}
	diagnostic_find_relative_paths(mut checks, relative_paths)
	return diagnostic_nil()
}

// Ruby method `inject_file_list(list, string)` at line 70.
pub fn ruby_diagnostic_l70_d4_inject_file_list(args ...ruby.Value) ruby.Value {
	_ = diagnostic_receiver(args)
	return ruby.string_value(diagnostic_inject_file_list(diagnostic_strings(args[1]), args[2].as_string()))
}

// Ruby method `user_tilde(path)` at line 76.
pub fn ruby_diagnostic_l76_d5_user_tilde(args ...ruby.Value) ruby.Value {
	checks := diagnostic_receiver(args)
	return ruby.string_value(diagnostic_user_tilde(args[1].as_string(), checks.home))
}

// Ruby method `none_string` at line 86.
pub fn ruby_diagnostic_l86_d6_none_string(args ...ruby.Value) ruby.Value {
	_ = diagnostic_receiver(args)
	return ruby.string_value('<NONE>')
}

// Ruby method `add_info(*args)` at line 91.
pub fn ruby_diagnostic_l91_d7_add_info(args ...ruby.Value) ruby.Value {
	mut checks := diagnostic_receiver(args)
	diagnostic_add_info(mut checks, args[1..].map(it.as_string()))
	return diagnostic_nil()
}

// Ruby method `fatal_preinstall_checks` at line 97.
pub fn ruby_diagnostic_l97_d8_fatal_preinstall_checks(args ...ruby.Value) ruby.Value {
	_ = diagnostic_receiver(args)
	return diagnostic_strings_value(['check_access_directories'])
}

// Ruby method `fatal_build_from_source_checks` at line 104.
pub fn ruby_diagnostic_l104_d9_fatal_build_from_source_checks(args ...ruby.Value) ruby.Value {
	_ = diagnostic_receiver(args)
	return diagnostic_strings_value(['check_for_installed_developer_tools'])
}

// Ruby method `fatal_setup_build_environment_checks` at line 111.
pub fn ruby_diagnostic_l111_d10_fatal_setup_build_environment_checks(args ...ruby.Value) ruby.Value {
	_ = diagnostic_receiver(args)
	return diagnostic_strings_value([])
}

// Ruby method `supported_configuration_checks` at line 116.
pub fn ruby_diagnostic_l116_d11_supported_configuration_checks(args ...ruby.Value) ruby.Value {
	_ = diagnostic_receiver(args)
	return diagnostic_strings_value([])
}

// Ruby method `build_from_source_checks` at line 121.
pub fn ruby_diagnostic_l121_d12_build_from_source_checks(args ...ruby.Value) ruby.Value {
	_ = diagnostic_receiver(args)
	return diagnostic_strings_value([])
}

// Ruby method `preinstall_checks` at line 126.
pub fn ruby_diagnostic_l126_d13_preinstall_checks(args ...ruby.Value) ruby.Value {
	_ = diagnostic_receiver(args)
	return diagnostic_strings_value(['check_untrusted_taps'])
}

// Ruby method `build_error_checks` at line 133.
pub fn ruby_diagnostic_l133_d14_build_error_checks(args ...ruby.Value) ruby.Value {
	_ = diagnostic_receiver(args)
	return diagnostic_strings_value([])
}

// Ruby method `examine_git_origin(repository_path, desired_origin)` at line 138.
pub fn ruby_diagnostic_l138_d15_examine_git_origin(args ...ruby.Value) ruby.Value {
	checks := diagnostic_receiver(args)
	current_origin := if args.len < 4 || diagnostic_value_is_nil(args[3]) {
		?string(none)
	} else {
		?string(args[3].as_string())
	}
	return diagnostic_finding_value(diagnostic_examine_git_origin(checks, args[1].as_string(), args[2].as_string(), current_origin))
}

// Ruby method `broken_tap(tap)` at line 182.
pub fn ruby_diagnostic_l182_d16_broken_tap(args ...ruby.Value) ruby.Value {
	checks := diagnostic_receiver(args)
	return diagnostic_finding_value(diagnostic_broken_tap(checks, diagnostic_tap_from_value(args[1])))
}

// Ruby method `check_for_installed_developer_tools` at line 213.
pub fn ruby_diagnostic_l213_d17_check_for_installed_developer_tools(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_developer_tools(diagnostic_receiver(args)))
}

// Ruby method `__check_stray_files(dir, pattern, allow_list, message)` at line 223.
pub fn ruby_diagnostic_l223_d18_check_stray_files(args ...ruby.Value) ruby.Value {
	checks := diagnostic_receiver(args)
	text := diagnostic_check_stray_files(checks, args[1].as_string(), args[2].as_string(), diagnostic_strings(args[3]), args[4].as_string()) or { return diagnostic_nil() }
	return ruby.string_value(text)
}

// Ruby method `check_for_stray_dylibs` at line 241.
pub fn ruby_diagnostic_l241_d19_check_for_stray_dylibs(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_stray_dylibs(diagnostic_receiver(args)))
}

// Ruby method `check_for_stray_static_libs` at line 278.
pub fn ruby_diagnostic_l278_d20_check_for_stray_static_libs(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_stray_static_libs(diagnostic_receiver(args)))
}

// Ruby method `check_for_stray_pcs` at line 308.
pub fn ruby_diagnostic_l308_d21_check_for_stray_pcs(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_stray_pcs(diagnostic_receiver(args)))
}

// Ruby method `check_for_stray_las` at line 333.
pub fn ruby_diagnostic_l333_d22_check_for_stray_las(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_stray_las(diagnostic_receiver(args)))
}

// Ruby method `check_for_stray_headers` at line 357.
pub fn ruby_diagnostic_l357_d23_check_for_stray_headers(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_stray_headers(diagnostic_receiver(args)))
}

// Ruby method `check_for_broken_symlinks` at line 380.
pub fn ruby_diagnostic_l380_d24_check_for_broken_symlinks(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_broken_symlinks(diagnostic_receiver(args)))
}

// Ruby method `check_tmpdir_sticky_bit` at line 407.
pub fn ruby_diagnostic_l407_d25_check_tmpdir_sticky_bit(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_tmpdir_sticky_bit(diagnostic_receiver(args)))
}

// Ruby method `check_exist_directories` at line 426.
pub fn ruby_diagnostic_l426_d26_check_exist_directories(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_exist_directories(diagnostic_receiver(args)))
}

// Ruby method `check_access_directories` at line 450.
pub fn ruby_diagnostic_l450_d27_check_access_directories(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_access_directories(diagnostic_receiver(args)))
}

// Ruby method `check_multiple_cellars` at line 476.
pub fn ruby_diagnostic_l476_d28_check_multiple_cellars(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_multiple_cellars(diagnostic_receiver(args)))
}

// Ruby method `check_user_path_1` at line 496.
pub fn ruby_diagnostic_l496_d29_check_user_path_1(args ...ruby.Value) ruby.Value {
	mut checks := diagnostic_receiver(args)
	return diagnostic_finding_value(diagnostic_check_user_path_1(mut checks))
}

// Ruby method `check_user_path_2` at line 543.
pub fn ruby_diagnostic_l543_d30_check_user_path_2(args ...ruby.Value) ruby.Value {
	mut checks := diagnostic_receiver(args)
	return diagnostic_finding_value(diagnostic_check_user_path_2(mut checks))
}

// Ruby method `check_user_path_3` at line 562.
pub fn ruby_diagnostic_l562_d31_check_user_path_3(args ...ruby.Value) ruby.Value {
	mut checks := diagnostic_receiver(args)
	return diagnostic_finding_value(diagnostic_check_user_path_3(mut checks))
}

// Ruby method `check_for_symlinked_cellar` at line 588.
pub fn ruby_diagnostic_l588_d32_check_for_symlinked_cellar(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_symlinked_cellar(diagnostic_receiver(args)))
}

// Ruby method `check_git_version` at line 610.
pub fn ruby_diagnostic_l610_d33_check_git_version(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_git_version(diagnostic_receiver(args)))
}

// Ruby method `check_for_git` at line 633.
pub fn ruby_diagnostic_l633_d34_check_for_git(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_for_git(diagnostic_receiver(args)))
}

// Ruby method `check_git_newline_settings` at line 653.
pub fn ruby_diagnostic_l653_d35_check_git_newline_settings(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_git_newline(diagnostic_receiver(args)))
}

// Ruby method `check_homebrew_repository_git_hooks` at line 678.
pub fn ruby_diagnostic_l678_d36_check_homebrew_repository_git_hooks(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_repository_hooks(diagnostic_receiver(args)))
}

// Ruby method `check_brew_git_origin` at line 709.
pub fn ruby_diagnostic_l709_d37_check_brew_git_origin(args ...ruby.Value) ruby.Value {
	checks := diagnostic_receiver(args)
	current_origin := if checks.repository_origin == '' {
		?string(none)
	} else {
		?string(checks.repository_origin)
	}
	return diagnostic_finding_value(diagnostic_examine_git_origin(checks, checks.repository, checks.desired_brew_origin, current_origin))
}

// Ruby method `check_for_nix_homebrew` at line 715.
pub fn ruby_diagnostic_l715_d38_check_for_nix_homebrew(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_nix(diagnostic_receiver(args)))
}

// Ruby method `check_coretap_integrity` at line 728.
pub fn ruby_diagnostic_l728_d39_check_coretap_integrity(args ...ruby.Value) ruby.Value {
	checks := diagnostic_receiver(args)
	tap := diagnostic_core_tap(checks) or { return diagnostic_nil() }
	return diagnostic_finding_value(diagnostic_check_tap_integrity(checks, tap, checks.desired_core_origin))
}

// Ruby method `check_casktap_integrity` at line 740.
pub fn ruby_diagnostic_l740_d40_check_casktap_integrity(args ...ruby.Value) ruby.Value {
	checks := diagnostic_receiver(args)
	tap := diagnostic_core_cask_tap(checks) or { return diagnostic_nil() }
	return diagnostic_finding_value(diagnostic_check_tap_integrity(checks, tap, tap.remote))
}

// Ruby method `check_tap_git_branch` at line 748.
pub fn ruby_diagnostic_l748_d41_check_tap_git_branch(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_tap_git_branch(diagnostic_receiver(args)))
}

// Ruby method `check_deprecated_official_taps` at line 794.
pub fn ruby_diagnostic_l794_d42_check_deprecated_official_taps(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_deprecated_official_taps(diagnostic_receiver(args)))
}

// Ruby method `check_untrusted_taps` at line 815.
pub fn ruby_diagnostic_l815_d43_check_untrusted_taps(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_untrusted_taps(diagnostic_receiver(args)))
}

// Ruby method `__check_linked_brew!(formula)` at line 916.
pub fn ruby_diagnostic_l916_d44_check_linked_brew(args ...ruby.Value) ruby.Value {
	formula_index := if args.len > 1 && args[0].type_name == 'Homebrew::Diagnostic::Checks' {
		1
	} else {
		0
	}
	return ruby.bool_value(diagnostic_check_linked_brew(diagnostic_formula_from_value(args[formula_index])))
}

// Ruby method `check_for_other_frameworks` at line 930.
pub fn ruby_diagnostic_l930_d45_check_for_other_frameworks(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_other_frameworks(diagnostic_receiver(args)))
}

// Ruby method `check_tmpdir` at line 955.
pub fn ruby_diagnostic_l955_d46_check_tmpdir(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_tmpdir(diagnostic_receiver(args)))
}

// Ruby method `check_missing_deps` at line 967.
pub fn ruby_diagnostic_l967_d47_check_missing_deps(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_missing_deps(diagnostic_receiver(args)))
}

// Ruby method `check_deprecated_disabled` at line 992.
pub fn ruby_diagnostic_l992_d48_check_deprecated_disabled(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_deprecated_disabled(diagnostic_receiver(args)))
}

// Ruby method `check_cask_deprecated_disabled` at line 1009.
pub fn ruby_diagnostic_l1009_d49_check_cask_deprecated_disabled(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_cask_deprecated_disabled(diagnostic_receiver(args)))
}

// Ruby method `check_git_status` at line 1025.
pub fn ruby_diagnostic_l1025_d50_check_git_status(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_array_value(diagnostic_check_git_status(diagnostic_receiver(args)))
}

// Ruby method `__tap_git_status(tap, path)` at line 1044.
pub fn ruby_diagnostic_l1044_d51_tap_git_status(args ...ruby.Value) ruby.Value {
	checks := diagnostic_receiver(args)
	return diagnostic_finding_value(diagnostic_tap_git_status(checks, args[1].as_string(), args[2].as_string()))
}

// Ruby method `check_for_non_prefixed_coreutils` at line 1075.
pub fn ruby_diagnostic_l1075_d52_check_for_non_prefixed_coreutils(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_non_prefixed_coreutils(diagnostic_receiver(args)))
}

// Ruby method `check_for_pydistutils_cfg_in_home` at line 1092.
pub fn ruby_diagnostic_l1092_d53_check_for_pydistutils_cfg_in_home(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_pydistutils(diagnostic_receiver(args)))
}

// Ruby method `check_for_unreadable_installed_formula` at line 1110.
pub fn ruby_diagnostic_l1110_d54_check_for_unreadable_installed_formula(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_unreadable_formulae(diagnostic_receiver(args)))
}

// Ruby method `check_for_unlinked_but_not_keg_only` at line 1132.
pub fn ruby_diagnostic_l1132_d55_check_for_unlinked_but_not_keg_only(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_unlinked_formulae(diagnostic_receiver(args)))
}

// Ruby method `check_for_external_cmd_name_conflict` at line 1164.
pub fn ruby_diagnostic_l1164_d56_check_for_external_cmd_name_conflict(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_external_command_conflicts(diagnostic_receiver(args)))
}

// Ruby method `check_for_tap_ruby_files_locations` at line 1192.
pub fn ruby_diagnostic_l1192_d57_check_for_tap_ruby_files_locations(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_tap_ruby_locations(diagnostic_receiver(args)))
}

// Ruby method `check_homebrew_prefix` at line 1219.
pub fn ruby_diagnostic_l1219_d58_check_homebrew_prefix(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_homebrew_prefix(diagnostic_receiver(args)))
}

// Ruby method `check_deleted_formula` at line 1234.
pub fn ruby_diagnostic_l1234_d59_check_deleted_formula(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_deleted_formula(diagnostic_receiver(args)))
}

// Ruby method `check_for_unnecessary_core_tap` at line 1275.
pub fn ruby_diagnostic_l1275_d60_check_for_unnecessary_core_tap(args ...ruby.Value) ruby.Value {
	checks := diagnostic_receiver(args)
	tap := diagnostic_core_tap(checks) or { return diagnostic_nil() }
	return diagnostic_finding_value(diagnostic_check_unnecessary_tap(checks, tap, false))
}

// Ruby method `check_for_unnecessary_cask_tap` at line 1295.
pub fn ruby_diagnostic_l1295_d61_check_for_unnecessary_cask_tap(args ...ruby.Value) ruby.Value {
	checks := diagnostic_receiver(args)
	tap := diagnostic_core_cask_tap(checks) or { return diagnostic_nil() }
	return diagnostic_finding_value(diagnostic_check_unnecessary_tap(checks, tap, true))
}

// Ruby method `check_deprecated_cask_taps` at line 1317.
pub fn ruby_diagnostic_l1317_d62_check_deprecated_cask_taps(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_deprecated_cask_taps(diagnostic_receiver(args)))
}

// Ruby method `check_cask_software_versions` at line 1339.
pub fn ruby_diagnostic_l1339_d63_check_cask_software_versions(args ...ruby.Value) ruby.Value {
	mut checks := diagnostic_receiver(args)
	diagnostic_check_cask_software_versions(mut checks)
	return diagnostic_nil()
}

// Ruby method `check_cask_install_location` at line 1346.
pub fn ruby_diagnostic_l1346_d64_check_cask_install_location(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_cask_install_location(diagnostic_receiver(args)))
}

// Ruby method `check_cask_staging_location` at line 1361.
pub fn ruby_diagnostic_l1361_d65_check_cask_staging_location(args ...ruby.Value) ruby.Value {
	mut checks := diagnostic_receiver(args)
	return diagnostic_finding_value(diagnostic_check_cask_staging(mut checks))
}

// Ruby method `check_cask_corrupt_dirs` at line 1387.
pub fn ruby_diagnostic_l1387_d66_check_cask_corrupt_dirs(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_cask_corrupt(diagnostic_receiver(args)))
}

// Ruby method `check_cask_taps` at line 1409.
pub fn ruby_diagnostic_l1409_d67_check_cask_taps(args ...ruby.Value) ruby.Value {
	mut checks := diagnostic_receiver(args)
	return diagnostic_finding_value(diagnostic_check_cask_taps(mut checks))
}

// Ruby method `check_cask_load_path` at line 1434.
pub fn ruby_diagnostic_l1434_d68_check_cask_load_path(args ...ruby.Value) ruby.Value {
	mut checks := diagnostic_receiver(args)
	return diagnostic_finding_value(diagnostic_check_cask_load_path(mut checks))
}

// Ruby method `check_cask_environment_variables` at line 1443.
pub fn ruby_diagnostic_l1443_d69_check_cask_environment_variables(args ...ruby.Value) ruby.Value {
	mut checks := diagnostic_receiver(args)
	diagnostic_check_cask_environment(mut checks)
	return diagnostic_nil()
}

// Ruby method `check_cask_xattr` at line 1471.
pub fn ruby_diagnostic_l1471_d70_check_cask_xattr(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_cask_xattr(diagnostic_receiver(args)))
}

// Ruby method `non_core_taps` at line 1512.
pub fn ruby_diagnostic_l1512_d71_non_core_taps(args ...ruby.Value) ruby.Value {
	taps := diagnostic_non_core_taps(diagnostic_receiver(args))
	return ruby.array_value(taps.map(diagnostic_tap_value(it)))
}

// Ruby method `check_for_duplicate_formulae` at line 1517.
pub fn ruby_diagnostic_l1517_d72_check_for_duplicate_formulae(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_duplicate_formulae(diagnostic_receiver(args)))
}

// Ruby method `check_for_duplicate_casks` at line 1547.
pub fn ruby_diagnostic_l1547_d73_check_for_duplicate_casks(args ...ruby.Value) ruby.Value {
	return diagnostic_finding_value(diagnostic_check_duplicate_casks(diagnostic_receiver(args)))
}

// Ruby method `all` at line 1583.
pub fn ruby_diagnostic_l1583_d74_all(args ...ruby.Value) ruby.Value {
	_ = diagnostic_receiver(args)
	return diagnostic_strings_value(diagnostic_all_checks)
}

// Ruby method `cask_checks` at line 1588.
pub fn ruby_diagnostic_l1588_d75_cask_checks(args ...ruby.Value) ruby.Value {
	_ = diagnostic_receiver(args)
	return diagnostic_strings_value(diagnostic_cask_checks())
}

// Ruby method `current_user` at line 1593.
pub fn ruby_diagnostic_l1593_d76_current_user(args ...ruby.Value) ruby.Value {
	checks := diagnostic_receiver(args)
	return ruby.string_value(if checks.current_user_name == '' {
		'\$(whoami)'
	} else {
		checks.current_user_name
	})
}

// Ruby method `paths` at line 1600.
pub fn ruby_diagnostic_l1600_d77_paths(args ...ruby.Value) ruby.Value {
	checks := diagnostic_receiver(args)
	return diagnostic_strings_value(diagnostic_unique(checks.original_paths))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "keg"
// 5: require "formula"
// 6: require "formulary"
// 7: require "utils"
// 8: require "version"
// 9: require "development_tools"
// 10: require "utils/shell"
// 11: require "utils/output"
// 12: require "cask/caskroom"
// 13: require "cask/quarantine"
// 14: require "diagnostic/finding"
// 15: require "git_repository"
// 16: require "missing"
// 17: require "system_command"
// 18: require "trust"
// 19:
// 20: module Homebrew
// 21:   # Module containing diagnostic checks.
// 22:   module Diagnostic
// 23:     extend Utils::Output::Mixin
// 24:
// 25:     sig { params(type: Symbol, fatal: T::Boolean).void }
// 26:     def self.checks(type, fatal: true)
// 27:       @checks ||= T.let(Checks.new, T.nilable(Checks))
// 28:       failed = T.let(false, T::Boolean)
// 29:       @checks.public_send(type).each do |check|
// 30:         out = @checks.public_send(check)
// 31:         next if out.nil?
// 32:
// 33:         if fatal
// 34:           failed ||= true
// 35:           ofail out.to_s
// 36:         else
// 37:           opoo out.to_s
// 38:         end
// 39:       end
// 40:       exit 1 if failed && fatal
// 41:     end
// 42:
// 43:     # Diagnostic checks.
// 44:     class Checks
// 45:       include SystemCommand::Mixin
// 46:       include Utils::Output::Mixin
// 47:
// 48:       sig { params(verbose: T::Boolean).void }
// 49:       def initialize(verbose: true)
// 50:         @verbose = verbose
// 51:         @found = T.let([], T::Array[String])
// 52:         @seen_prefix_bin = T.let(false, T::Boolean)
// 53:         @seen_prefix_sbin = T.let(false, T::Boolean)
// 54:         @user_path_1_done = T.let(false, T::Boolean)
// 55:         @non_core_taps = T.let([], T.nilable(T::Array[Tap]))
// 56:       end
// 57:
// 58:       ############# @!group HELPERS
// 59:       # Finds files in `HOMEBREW_PREFIX` *and* /usr/local.
// 60:       # Specify paths relative to a prefix, e.g. "include/foo.h".
// 61:       # Sets @found for your convenience.
// 62:       sig { params(relative_paths: T.any(String, T::Array[String])).void }
// 63:       def find_relative_paths(*relative_paths)
// 64:         @found = [HOMEBREW_PREFIX, "/usr/local"].uniq.reduce([]) do |found, prefix|
// 65:           found + relative_paths.map { |f| File.join(prefix, f) }.select { |f| File.exist? f }
// 66:         end
// 67:       end
// 68:
// 69:       sig { params(list: T::Array[T.any(Formula, Pathname, String)], string: String).returns(String) }
// 70:       def inject_file_list(list, string)
// 71:         list.reduce(string.dup) { |acc, elem| acc << "  #{elem}\n" }
// 72:             .freeze
// 73:       end
// 74:
// 75:       sig { params(path: String).returns(String) }
// 76:       def user_tilde(path)
// 77:         home = Dir.home
// 78:         if path == home
// 79:           "~"
// 80:         else
// 81:           path.gsub(%r{^#{home}/}, "~/")
// 82:         end
// 83:       end
// 84:
// 85:       sig { returns(T.nilable(String)) }
// 86:       def none_string
// 87:         "<NONE>"
// 88:       end
// 89:
// 90:       sig { params(args: T.anything).void }
// 91:       def add_info(*args)
// 92:         ohai(*args) if @verbose
// 93:       end
// 94:       ############# @!endgroup END HELPERS
// 95:
// 96:       sig { returns(T::Array[String]) }
// 97:       def fatal_preinstall_checks
// 98:         %w[
// 99:           check_access_directories
// 100:         ].freeze
// 101:       end
// 102:
// 103:       sig { returns(T::Array[String]) }
// 104:       def fatal_build_from_source_checks
// 105:         %w[
// 106:           check_for_installed_developer_tools
// 107:         ].freeze
// 108:       end
// 109:
// 110:       sig { returns(T::Array[String]) }
// 111:       def fatal_setup_build_environment_checks
// 112:         [].freeze
// 113:       end
// 114:
// 115:       sig { returns(T::Array[String]) }
// 116:       def supported_configuration_checks
// 117:         [].freeze
// 118:       end
// 119:
// 120:       sig { returns(T::Array[String]) }
// 121:       def build_from_source_checks
// 122:         [].freeze
// 123:       end
// 124:
// 125:       sig { returns(T::Array[String]) }
// 126:       def preinstall_checks
// 127:         %w[
// 128:           check_untrusted_taps
// 129:         ].freeze
// 130:       end
// 131:
// 132:       sig { returns(T::Array[String]) }
// 133:       def build_error_checks
// 134:         supported_configuration_checks + build_from_source_checks
// 135:       end
// 136:
// 137:       sig { params(repository_path: GitRepository, desired_origin: String).returns(T.nilable(Finding)) }
// 138:       def examine_git_origin(repository_path, desired_origin)
// 139:         return if !Utils::Git.available? || !repository_path.git_repository?
// 140:
// 141:         current_origin = repository_path.origin_url
// 142:
// 143:         if current_origin.nil?
// 144:           Finding.new(
// 145:             <<~EOS,
// 146:               Missing #{desired_origin} git origin remote.
// 147:
// 148:               Without a correctly configured origin, Homebrew won't update properly.
// 149:             EOS
// 150:             remediation: Finding::Remediation.new(
// 151:               text:     <<~EOS,
// 152:                 You can solve this by adding the remote:
// 153:                   git -C "#{repository_path}" remote add origin #{Formatter.url(desired_origin)}
// 154:               EOS
// 155:               commands: [
// 156:                 "git -C \"#{repository_path}\" remote add origin #{desired_origin}",
// 157:               ],
// 158:             ),
// 159:           )
// 160:         elsif !current_origin.match?(%r{#{desired_origin}(\.git|/)?$}i)
// 161:           Finding.new(
// 162:             <<~EOS,
// 163:               The current git origin is:
// 164:                 #{current_origin}
// 165:
// 166:               With a non-standard origin, Homebrew won't update properly.
// 167:             EOS
// 168:             remediation: Finding::Remediation.new(
// 169:               text:     <<~EOS,
// 170:                 You can solve this by setting the origin remote:
// 171:                   git -C "#{repository_path}" remote set-url origin #{Formatter.url(desired_origin)}
// 172:               EOS
// 173:               commands: [
// 174:                 "git -C \"#{repository_path}\" remote set-url origin #{desired_origin}",
// 175:               ],
// 176:             ),
// 177:           )
// 178:         end
// 179:       end
// 180:
// 181:       sig { params(tap: Tap).returns(T.nilable(Finding)) }
// 182:       def broken_tap(tap)
// 183:         return unless Utils::Git.available?
// 184:
// 185:         repo = GitRepository.new(HOMEBREW_REPOSITORY)
// 186:         return unless repo.git_repository?
// 187:
// 188:         finding = Finding.new(
// 189:           "#{tap.full_name} was not tapped properly!",
// 190:           remediation: Finding::Remediation.new(
// 191:             text:     <<~EOS,
// 192:               You can solve this by tapping again:
// 193:                 rm -rf "#{tap.path}"
// 194:                 brew tap #{tap.name}
// 195:             EOS
// 196:             commands: [
// 197:               "rm -rf \"#{tap.path}\"",
// 198:               "brew tap #{tap.name}",
// 199:             ],
// 200:           ),
// 201:         )
// 202:
// 203:         return finding if tap.remote.blank?
// 204:
// 205:         tap_head = tap.git_head
// 206:         return finding if tap_head.blank?
// 207:         return if tap_head != repo.head_ref
// 208:
// 209:         finding
// 210:       end
// 211:
// 212:       sig { returns(T.nilable(Finding)) }
// 213:       def check_for_installed_developer_tools
// 214:         return if DevelopmentTools.installed?
// 215:
// 216:         Finding.new(
// 217:           "No developer tools installed.\n",
// 218:           remediation: DevelopmentTools.installation_instructions,
// 219:         )
// 220:       end
// 221:
// 222:       sig { params(dir: String, pattern: String, allow_list: T::Array[String], message: String).returns(T.nilable(String)) }
// 223:       def __check_stray_files(dir, pattern, allow_list, message)
// 224:         return unless File.directory?(dir)
// 225:
// 226:         files = Dir.chdir(dir) do
// 227:           (Dir.glob(pattern) - Dir.glob(allow_list))
// 228:             .select { |f| File.file?(f) && !File.symlink?(f) }
// 229:             .map do |f|
// 230:               f.sub!(%r{/.*}, "/*") unless @verbose
// 231:               File.join(dir, f)
// 232:             end
// 233:             .sort.uniq
// 234:         end
// 235:         return if files.empty?
// 236:
// 237:         inject_file_list(files, message)
// 238:       end
// 239:
// 240:       sig { returns(T.nilable(Finding)) }
// 241:       def check_for_stray_dylibs
// 242:         # Dylibs which are generally OK should be added to this list,
// 243:         # with a short description of the software they come with.
// 244:         allow_list = [
// 245:           "libfuse.2.dylib", # MacFuse
// 246:           "libfuse3.*.dylib", # MacFuse
// 247:           "libfuse_ino64.2.dylib", # MacFuse
// 248:           "libfuse-t*.dylib", # FUSE-T
// 249:           "libmacfuse_i32.2.dylib", # OSXFuse MacFuse compatibility layer
// 250:           "libmacfuse_i64.2.dylib", # OSXFuse MacFuse compatibility layer
// 251:           "libosxfuse_i32.2.dylib", # OSXFuse
// 252:           "libosxfuse_i64.2.dylib", # OSXFuse
// 253:           "libosxfuse.2.dylib", # OSXFuse
// 254:           "libTrAPI.dylib", # TrAPI/Endpoint Security VPN
// 255:           "libntfs-3g.*.dylib", # NTFS-3G
// 256:           "libntfs.*.dylib", # NTFS-3G
// 257:           "libublio.*.dylib", # NTFS-3G
// 258:           "libUFSDNTFS.dylib", # Paragon NTFS
// 259:           "libUFSDExtFS.dylib", # Paragon ExtFS
// 260:           "libecomlodr.dylib", # Symantec Endpoint Protection
// 261:           "libsymsea*.dylib", # Symantec Endpoint Protection
// 262:           "sentinel.dylib", # SentinelOne
// 263:           "sentinel-*.dylib", # SentinelOne
// 264:           "libASAF.dylib", # Apple Immersive Audio SDK
// 265:         ]
// 266:
// 267:         msg = __check_stray_files "/usr/local/lib", "*.dylib", allow_list, <<~EOS
// 268:           Unbrewed dylibs were found in /usr/local/lib.
// 269:           If you didn't put them there on purpose they could cause problems when
// 270:           building Homebrew formulae and may need to be deleted.
// 271:
// 272:           Unexpected dylibs:
// 273:         EOS
// 274:         Finding.new(msg) if msg.present?
// 275:       end
// 276:
// 277:       sig { returns(T.nilable(Finding)) }
// 278:       def check_for_stray_static_libs
// 279:         # Static libs which are generally OK should be added to this list,
// 280:         # with a short description of the software they come with.
// 281:         allow_list = [
// 282:           "libfuse-t*.a", # FUSE-T
// 283:           "libfuse3.a", # FUSE-T
// 284:           "libntfs-3g.a", # NTFS-3G
// 285:           "libntfs.a", # NTFS-3G
// 286:           "libublio.a", # NTFS-3G
// 287:           "libappfirewall.a", # Symantec Endpoint Protection
// 288:           "libautoblock.a", # Symantec Endpoint Protection
// 289:           "libautosetup.a", # Symantec Endpoint Protection
// 290:           "libconnectionsclient.a", # Symantec Endpoint Protection
// 291:           "liblocationawareness.a", # Symantec Endpoint Protection
// 292:           "libpersonalfirewall.a", # Symantec Endpoint Protection
// 293:           "libtrustedcomponents.a", # Symantec Endpoint Protection
// 294:         ]
// 295:
// 296:         msg = __check_stray_files "/usr/local/lib", "*.a", allow_list, <<~EOS
// 297:           Unbrewed static libraries were found in /usr/local/lib.
// 298:           If you didn't put them there on purpose they could cause problems when
// 299:           building Homebrew formulae and may need to be deleted.
// 300:
// 301:           Unexpected static libraries:
// 302:         EOS
// 303:
// 304:         Finding.new(msg) if msg.present?
// 305:       end
// 306:
// 307:       sig { returns(T.nilable(Finding)) }
// 308:       def check_for_stray_pcs
// 309:         # Package-config files which are generally OK should be added to this list,
// 310:         # with a short description of the software they come with.
// 311:         allow_list = [
// 312:           "fuse.pc", # OSXFuse/MacFuse
// 313:           "fuse3.pc", # OSXFuse/MacFuse
// 314:           "fuse-t.pc", # FUSE-T
// 315:           "macfuse.pc", # OSXFuse MacFuse compatibility layer
// 316:           "osxfuse.pc", # OSXFuse
// 317:           "libntfs-3g.pc", # NTFS-3G
// 318:           "libublio.pc", # NTFS-3G
// 319:         ]
// 320:
// 321:         msg = __check_stray_files("/usr/local/lib/pkgconfig", "*.pc", allow_list, <<~EOS
// 322:           Unbrewed '.pc' files were found in /usr/local/lib/pkgconfig.
// 323:           If you didn't put them there on purpose they could cause problems when
// 324:           building Homebrew formulae and may need to be deleted.
// 325:
// 326:           Unexpected '.pc' files:
// 327:         EOS
// 328:         )
// 329:         Finding.new(msg) if msg.present?
// 330:       end
// 331:
// 332:       sig { returns(T.nilable(Finding)) }
// 333:       def check_for_stray_las
// 334:         allow_list = [
// 335:           "libfuse.la", # MacFuse
// 336:           "libfuse_ino64.la", # MacFuse
// 337:           "libosxfuse_i32.la", # OSXFuse
// 338:           "libosxfuse_i64.la", # OSXFuse
// 339:           "libosxfuse.la", # OSXFuse
// 340:           "libntfs-3g.la", # NTFS-3G
// 341:           "libntfs.la", # NTFS-3G
// 342:           "libublio.la", # NTFS-3G
// 343:         ]
// 344:
// 345:         msg = __check_stray_files("/usr/local/lib", "*.la", allow_list, <<~EOS
// 346:           Unbrewed '.la' files were found in /usr/local/lib.
// 347:           If you didn't put them there on purpose they could cause problems when
// 348:           building Homebrew formulae and may need to be deleted.
// 349:
// 350:           Unexpected '.la' files:
// 351:         EOS
// 352:         )
// 353:         Finding.new(msg) if msg.present?
// 354:       end
// 355:
// 356:       sig { returns(T.nilable(Finding)) }
// 357:       def check_for_stray_headers
// 358:         allow_list = [
// 359:           "fuse.h", # MacFuse
// 360:           "fuse/**/*.h", # MacFuse
// 361:           "fuse3/**/*.h", # MacFuse
// 362:           "macfuse/**/*.h", # OSXFuse MacFuse compatibility layer
// 363:           "osxfuse/**/*.h", # OSXFuse
// 364:           "ntfs/**/*.h", # NTFS-3G
// 365:           "ntfs-3g/**/*.h", # NTFS-3G
// 366:         ]
// 367:
// 368:         msg = __check_stray_files "/usr/local/include", "**/*.h", allow_list, <<~EOS
// 369:           Unbrewed header files were found in /usr/local/include.
// 370:           If you didn't put them there on purpose they could cause problems when
// 371:           building Homebrew formulae and may need to be deleted.
// 372:
// 373:           Unexpected header files:
// 374:         EOS
// 375:
// 376:         Finding.new(msg) if msg.present?
// 377:       end
// 378:
// 379:       sig { returns(T.nilable(Finding)) }
// 380:       def check_for_broken_symlinks
// 381:         broken_symlinks = []
// 382:
// 383:         Keg.must_exist_subdirectories.each do |d|
// 384:           next unless d.directory?
// 385:
// 386:           d.find do |path|
// 387:             broken_symlinks << path if path.symlink? && !path.resolved_path_exists?
// 388:           end
// 389:         end
// 390:         return if broken_symlinks.empty?
// 391:
// 392:         Finding.new(
// 393:           inject_file_list(broken_symlinks, <<~EOS
// 394:             Broken symlinks were found:
// 395:           EOS
// 396:           ),
// 397:           remediation: Finding::Remediation.new(
// 398:             text:     <<~EOS,
// 399:               Remove them with `brew cleanup`
// 400:             EOS
// 401:             commands: ["brew cleanup"],
// 402:           ),
// 403:         )
// 404:       end
// 405:
// 406:       sig { returns(T.nilable(Finding)) }
// 407:       def check_tmpdir_sticky_bit
// 408:         world_writable = HOMEBREW_TEMP.stat.mode & 0777 == 0777
// 409:         return if !world_writable || HOMEBREW_TEMP.sticky?
// 410:
// 411:         Finding.new(
// 412:           <<~EOS,
// 413:             #{HOMEBREW_TEMP} is world-writable but does not have the sticky bit set.
// 414:           EOS
// 415:           remediation: Finding::Remediation.new(
// 416:             text:     <<~EOS,
// 417:               To set it, run the following command:
// 418:                 sudo chmod +t #{HOMEBREW_TEMP}
// 419:             EOS
// 420:             commands: ["sudo chmod +t #{HOMEBREW_TEMP}"],
// 421:           ),
// 422:         )
// 423:       end
// 424:
// 425:       sig { returns(T.nilable(Finding)) }
// 426:       def check_exist_directories
// 427:         return if HOMEBREW_PREFIX.writable?
// 428:
// 429:         not_exist_dirs = Keg.must_exist_directories.reject(&:exist?)
// 430:         return if not_exist_dirs.empty?
// 431:
// 432:         Finding.new(
// 433:           <<~EOS,
// 434:             The following directories do not exist:
// 435:             #{not_exist_dirs.join("\n")}
// 436:           EOS
// 437:           remediation: Finding::Remediation.new(
// 438:             text:     <<~EOS,
// 439:               You should create these directories and change their ownership to your user.
// 440:                 sudo mkdir -p #{not_exist_dirs.join(" ")}
// 441:                 sudo chown -R #{current_user} #{not_exist_dirs.join(" ")}
// 442:             EOS
// 443:             commands: ["sudo mkdir -p #{not_exist_dirs.join(" ")}",
// 444:                        "sudo chown -R #{current_user} #{not_exist_dirs.join(" ")}"],
// 445:           ),
// 446:         )
// 447:       end
// 448:
// 449:       sig { returns(T.nilable(Finding)) }
// 450:       def check_access_directories
// 451:         not_writable_dirs =
// 452:           Keg.must_be_writable_directories.select(&:exist?)
// 453:              .reject(&:writable?)
// 454:         return if not_writable_dirs.empty?
// 455:
// 456:         Finding.new(
// 457:           <<~EOS,
// 458:             The following directories are not writable by your user:
// 459:             #{not_writable_dirs.join("\n")}
// 460:           EOS
// 461:           remediation: Finding::Remediation.new(
// 462:             text:     <<~EOS,
// 463:               You should change the ownership of these directories to your user.
// 464:                 sudo chown -R #{current_user} #{not_writable_dirs.join(" ")}
// 465:
// 466:               And make sure that your user has write permission.
// 467:                 chmod u+w #{not_writable_dirs.join(" ")}
// 468:             EOS
// 469:             commands: ["sudo chown -R #{current_user} #{not_writable_dirs.join(" ")}",
// 470:                        "chmod u+w #{not_writable_dirs.join(" ")}"],
// 471:           ),
// 472:         )
// 473:       end
// 474:
// 475:       sig { returns(T.nilable(Finding)) }
// 476:       def check_multiple_cellars
// 477:         return if HOMEBREW_PREFIX.to_s == HOMEBREW_REPOSITORY.to_s
// 478:         return unless (HOMEBREW_REPOSITORY/"Cellar").exist?
// 479:         return unless (HOMEBREW_PREFIX/"Cellar").exist?
// 480:
// 481:         Finding.new(
// 482:           <<~EOS,
// 483:             You have multiple Cellars.
// 484:           EOS
// 485:           remediation: Finding::Remediation.new(
// 486:             text:     <<~EOS,
// 487:               You should delete #{HOMEBREW_REPOSITORY}/Cellar:
// 488:                 rm -rf #{HOMEBREW_REPOSITORY}/Cellar
// 489:             EOS
// 490:             commands: ["rm -rf #{HOMEBREW_REPOSITORY}/Cellar"],
// 491:           ),
// 492:         )
// 493:       end
// 494:
// 495:       sig { returns(T.nilable(Finding)) }
// 496:       def check_user_path_1
// 497:         @seen_prefix_bin = false
// 498:         @seen_prefix_sbin = false
// 499:
// 500:         message = ""
// 501:         remediation = T.let(nil, T.nilable(Finding::Remediation))
// 502:
// 503:         paths.each do |p|
// 504:           case p
// 505:           when "/usr/bin"
// 506:             unless @seen_prefix_bin
// 507:               # only show the doctor message if there are any conflicts
// 508:               # rationale: a default install should not trigger any brew doctor messages
// 509:               conflicts = Dir["#{HOMEBREW_PREFIX}/bin/*"]
// 510:                           .map { |fn| File.basename fn }
// 511:                           .select { |bn| File.exist? "/usr/bin/#{bn}" }
// 512:
// 513:               unless conflicts.empty?
// 514:                 message = inject_file_list conflicts, <<~EOS
// 515:                   /usr/bin occurs before #{HOMEBREW_PREFIX}/bin in your PATH.
// 516:                   This means that system-provided programs will be used instead of those
// 517:                   provided by Homebrew.
// 518:
// 519:                   The following tools exist at both paths:
// 520:                 EOS
// 521:                 remediation = Finding::Remediation.new(
// 522:                   text:     <<~EOS,
// 523:                     Consider setting your PATH so that
// 524:                     #{HOMEBREW_PREFIX}/bin occurs before /usr/bin. Here is a one-liner:
// 525:                       #{Utils::Shell.prepend_path_in_profile("#{HOMEBREW_PREFIX}/bin")}
// 526:                   EOS
// 527:                   commands: [T.must(Utils::Shell.prepend_path_in_profile("#{HOMEBREW_PREFIX}/bin"))],
// 528:                 )
// 529:               end
// 530:             end
// 531:           when "#{HOMEBREW_PREFIX}/bin"
// 532:             @seen_prefix_bin = true
// 533:           when "#{HOMEBREW_PREFIX}/sbin"
// 534:             @seen_prefix_sbin = true
// 535:           end
// 536:         end
// 537:
// 538:         @user_path_1_done = true
// 539:         Finding.new(message, remediation:) if message.present?
// 540:       end
// 541:
// 542:       sig { returns(T.nilable(Finding)) }
// 543:       def check_user_path_2
// 544:         check_user_path_1 unless @user_path_1_done
// 545:         return if @seen_prefix_bin
// 546:
// 547:         Finding.new(
// 548:           <<~EOS,
// 549:             Homebrew's "bin" was not found in your PATH.
// 550:           EOS
// 551:           remediation: Finding::Remediation.new(
// 552:             text:     <<~EOS,
// 553:               Consider setting your PATH for example like so:
// 554:                   #{Utils::Shell.prepend_path_in_profile("#{HOMEBREW_PREFIX}/bin")}
// 555:             EOS
// 556:             commands: [T.must(Utils::Shell.prepend_path_in_profile("#{HOMEBREW_PREFIX}/bin"))],
// 557:           ),
// 558:         )
// 559:       end
// 560:
// 561:       sig { returns(T.nilable(Finding)) }
// 562:       def check_user_path_3
// 563:         check_user_path_1 unless @user_path_1_done
// 564:         return if @seen_prefix_sbin
// 565:
// 566:         # Don't complain about sbin not being in the path if it doesn't exist
// 567:         sbin = HOMEBREW_PREFIX/"sbin"
// 568:         return unless sbin.directory?
// 569:         return if sbin.children.empty?
// 570:         return if sbin.children.one? && sbin.children.first.basename.to_s == ".keepme"
// 571:
// 572:         Finding.new(
// 573:           <<~EOS,
// 574:             Homebrew's "sbin" was not found in your PATH but you have installed
// 575:             formulae that put executables in #{HOMEBREW_PREFIX}/sbin.
// 576:           EOS
// 577:           remediation: Finding::Remediation.new(
// 578:             text:     <<~EOS,
// 579:               Consider setting your PATH for example like so:
// 580:                 #{Utils::Shell.prepend_path_in_profile("#{HOMEBREW_PREFIX}/sbin")}
// 581:             EOS
// 582:             commands: [T.must(Utils::Shell.prepend_path_in_profile("#{HOMEBREW_PREFIX}/sbin"))],
// 583:           ),
// 584:         )
// 585:       end
// 586:
// 587:       sig { returns(T.nilable(Finding)) }
// 588:       def check_for_symlinked_cellar
// 589:         return unless HOMEBREW_CELLAR.exist?
// 590:         return unless HOMEBREW_CELLAR.symlink?
// 591:
// 592:         Finding.new(
// 593:           <<~EOS,
// 594:             Symlinked Cellars can cause problems.
// 595:             Your Homebrew Cellar is a symlink: #{HOMEBREW_CELLAR}
// 596:                             which resolves to: #{HOMEBREW_CELLAR.realpath}
// 597:
// 598:             The recommended Homebrew installations are either:
// 599:             (A) Have Cellar be a real directory inside of your `$HOMEBREW_PREFIX`
// 600:             (B) Symlink "bin/brew" into your prefix, but don't symlink "Cellar".
// 601:
// 602:             Older installations of Homebrew may have created a symlinked Cellar, but this can
// 603:             cause problems when two formulae install to locations that are mapped on top of each
// 604:             other during the linking step.
// 605:           EOS
// 606:         )
// 607:       end
// 608:
// 609:       sig { returns(T.nilable(Finding)) }
// 610:       def check_git_version
// 611:         minimum_version = ENV.fetch("HOMEBREW_MINIMUM_GIT_VERSION")
// 612:         return unless Utils::Git.available?
// 613:         return if Utils::Git.version >= Version.new(minimum_version)
// 614:
// 615:         git = Formula["git"]
// 616:         git_upgrade_cmd = git.any_version_installed? ? "upgrade" : "install"
// 617:         Finding.new(
// 618:           <<~EOS,
// 619:             An outdated version (#{Utils::Git.version}) of Git was detected in your PATH.
// 620:             Git #{minimum_version} or newer is required for Homebrew.
// 621:           EOS
// 622:           remediation: Finding::Remediation.new(
// 623:             text:     <<~EOS,
// 624:               Please upgrade:
// 625:                 brew #{git_upgrade_cmd} git
// 626:             EOS
// 627:             commands: ["brew #{git_upgrade_cmd} git"],
// 628:           ),
// 629:         )
// 630:       end
// 631:
// 632:       sig { returns(T.nilable(Finding)) }
// 633:       def check_for_git
// 634:         return if Utils::Git.available?
// 635:
// 636:         Finding.new(
// 637:           <<~EOS,
// 638:             Git could not be found in your PATH.
// 639:             Homebrew uses Git for several internal functions and some formulae use Git
// 640:             checkouts instead of stable tarballs.
// 641:           EOS
// 642:           remediation: Finding::Remediation.new(
// 643:             text:     <<~EOS,
// 644:               You may want to install Git:
// 645:                 brew install git
// 646:             EOS
// 647:             commands: ["brew install git"],
// 648:           ),
// 649:         )
// 650:       end
// 651:
// 652:       sig { returns(T.nilable(Finding)) }
// 653:       def check_git_newline_settings
// 654:         return unless Utils::Git.available?
// 655:
// 656:         autocrlf = HOMEBREW_REPOSITORY.cd { `git config --get core.autocrlf`.chomp }
// 657:         return if autocrlf != "true"
// 658:
// 659:         Finding.new(
// 660:           <<~EOS,
// 661:             Suspicious Git newline settings found.
// 662:
// 663:             The detected Git newline settings will cause checkout problems:
// 664:               core.autocrlf = #{autocrlf}
// 665:           EOS
// 666:           remediation: Finding::Remediation.new(
// 667:             text:     <<~EOS,
// 668:               If you are not routinely dealing with Windows-based projects,
// 669:               consider removing these by running:
// 670:                 git config --global core.autocrlf input
// 671:             EOS
// 672:             commands: ["git config --global core.autocrlf input"],
// 673:           ),
// 674:         )
// 675:       end
// 676:
// 677:       sig { returns(T.nilable(Finding)) }
// 678:       def check_homebrew_repository_git_hooks
// 679:         found = T.let([], T::Array[Pathname])
// 680:
// 681:         hooks_dir = HOMEBREW_REPOSITORY/".git/hooks"
// 682:         if hooks_dir.directory?
// 683:           found += hooks_dir.children.reject { |path| path.basename.to_s.end_with?(".sample") }.sort_by(&:to_s)
// 684:         end
// 685:
// 686:         gitconfig = HOMEBREW_REPOSITORY/".gitconfig"
// 687:         found << gitconfig if gitconfig.exist?
// 688:         return if found.empty?
// 689:
// 690:         Finding.new(
// 691:           inject_file_list(found, <<~EOS
// 692:             Git hooks or a repository-local `.gitconfig` were found in your Homebrew repository.
// 693:             Homebrew does not use these, and they can break Homebrew operations.
// 694:
// 695:             Paths found:
// 696:           EOS
// 697:           ),
// 698:           remediation: Finding::Remediation.new(
// 699:             text:     <<~EOS,
// 700:               Remove them with:
// 701:                 rm -rf "#{HOMEBREW_REPOSITORY}/.git/hooks" "#{HOMEBREW_REPOSITORY}/.gitconfig"
// 702:             EOS
// 703:             commands: ["rm -rf \"#{HOMEBREW_REPOSITORY}/.git/hooks\" \"#{HOMEBREW_REPOSITORY}/.gitconfig\""],
// 704:           ),
// 705:         )
// 706:       end
// 707:
// 708:       sig { returns(T.nilable(Finding)) }
// 709:       def check_brew_git_origin
// 710:         repo = GitRepository.new(HOMEBREW_REPOSITORY)
// 711:         examine_git_origin(repo, Homebrew::EnvConfig.brew_git_remote)
// 712:       end
// 713:
// 714:       sig { returns(T.nilable(Finding)) }
// 715:       def check_for_nix_homebrew
// 716:         return unless OS.nix_managed_homebrew?
// 717:
// 718:         Finding.new(
// 719:           <<~EOS,
// 720:             Your Homebrew installation is managed by Nix.
// 721:             Homebrew does not support Nix-managed installations.
// 722:           EOS
// 723:           tier: 3,
// 724:         )
// 725:       end
// 726:
// 727:       sig { returns(T.nilable(Finding)) }
// 728:       def check_coretap_integrity
// 729:         core_tap = CoreTap.instance
// 730:         unless core_tap.installed?
// 731:           return unless EnvConfig.no_install_from_api?
// 732:
// 733:           core_tap.ensure_installed!
// 734:         end
// 735:
// 736:         broken_tap(core_tap) || examine_git_origin(core_tap.git_repository, Homebrew::EnvConfig.core_git_remote)
// 737:       end
// 738:
// 739:       sig { returns(T.nilable(Finding)) }
// 740:       def check_casktap_integrity
// 741:         core_cask_tap = CoreCaskTap.instance
// 742:         return unless core_cask_tap.installed?
// 743:
// 744:         broken_tap(core_cask_tap) || examine_git_origin(core_cask_tap.git_repository, T.must(core_cask_tap.remote))
// 745:       end
// 746:
// 747:       sig { returns(T.nilable(Finding)) }
// 748:       def check_tap_git_branch
// 749:         return if ENV["CI"]
// 750:         return unless Utils::Git.available?
// 751:
// 752:         deprecated_master = []
// 753:         commands = []
// 754:
// 755:         brew_repo = GitRepository.new(HOMEBREW_REPOSITORY)
// 756:         deprecated_master << "Homebrew/brew" if brew_repo.branch_name == "master"
// 757:
// 758:         Tap.installed.each do |tap|
// 759:           if tap.git_repository.branch_name == "master" && tap.official?
// 760:             deprecated_master << tap.name
// 761:           elsif !tap.git_repository.default_origin_branch?
// 762:             commands << "git -C $(brew --repo #{tap.name}) checkout #{tap.git_repository.origin_branch_name}"
// 763:           end
// 764:         end
// 765:
// 766:         message = +""
// 767:
// 768:         if deprecated_master.any?
// 769:           message << <<~EOS
// 770:             The following repositories are on the deprecated "master" branch.
// 771:             The "master" branch sync will stop and this warning will become an error
// 772:             when Homebrew 5.2.0 is released (no earlier than 2026-06-10).
// 773:             Run `brew update` to migrate to "main":
// 774:               #{deprecated_master.join("\n  ")}
// 775:           EOS
// 776:         end
// 777:
// 778:         remediation = nil
// 779:         if commands.any?
// 780:           message << "\n" if deprecated_master.any?
// 781:           message << <<~EOS
// 782:             Some taps are not on the default git origin branch and may not receive updates.
// 783:           EOS
// 784:           remediation = Finding::Remediation.new(text: <<~EOS, commands: commands)
// 785:             If this is a surprise to you, check out the default branch with:
// 786:               #{commands.join("\n  ")}
// 787:           EOS
// 788:         end
// 789:
// 790:         Finding.new(message, remediation:) if message.present?
// 791:       end
// 792:
// 793:       sig { returns(T.nilable(Finding)) }
// 794:       def check_deprecated_official_taps
// 795:         tapped_deprecated_taps =
// 796:           Tap.select(&:official?).map(&:repository) & DEPRECATED_OFFICIAL_TAPS
// 797:
// 798:         # TODO: remove this once it's no longer in the default GitHub Actions image
// 799:         tapped_deprecated_taps -= ["bundle"] if GitHub::Actions.env_set?
// 800:
// 801:         return if tapped_deprecated_taps.empty?
// 802:
// 803:         Finding.new(
// 804:           <<~EOS,
// 805:             You have the following deprecated, official taps tapped:
// 806:               Homebrew/homebrew-#{tapped_deprecated_taps.join("\n  Homebrew/homebrew-")}
// 807:           EOS
// 808:           remediation: <<~EOS,
// 809:             Untap them with `brew untap`.
// 810:           EOS
// 811:         )
// 812:       end
// 813:
// 814:       sig { returns(T.nilable(Finding)) }
// 815:       def check_untrusted_taps
// 816:         return if Homebrew::EnvConfig.no_require_tap_trust?
// 817:
// 818:         untrusted_taps = Homebrew::Trust.wholly_untrusted_taps
// 819:         return if untrusted_taps.empty?
// 820:
// 821:         untrusted_tap_names = untrusted_taps.map(&:name)
// 822:         untrusted_tap_name_set = untrusted_tap_names.to_set
// 823:         installed_formulae_by_tap = {}
// 824:         installed_casks_by_tap = {}
// 825:         Formula.racks.each do |rack|
// 826:           next unless (keg = Keg.from_rack(rack))
// 827:           next unless (tap = keg.tab.tap)
// 828:           next unless untrusted_tap_name_set.include?(tap.name)
// 829:
// 830:           installed_formulae = installed_formulae_by_tap[tap.name] ||= []
// 831:           installed_formulae << "#{tap.name}/#{rack.basename}"
// 832:         rescue
// 833:           nil
// 834:         end
// 835:         installed_formula_message = installed_formulae_by_tap.sort_by(&:first).filter_map do |_tap_name, formulae|
// 836:           next if formulae.empty?
// 837:
// 838:           "  brew trust --formula #{formulae.sort.join(" ")}"
// 839:         end.join("\n")
// 840:         Cask::Caskroom.casks.each do |cask|
// 841:           next unless (tap = cask.tab.tap)
// 842:           next unless untrusted_tap_name_set.include?(tap.name)
// 843:
// 844:           installed_casks = installed_casks_by_tap[tap.name] ||= []
// 845:           installed_casks << "#{tap.name}/#{cask.token}"
// 846:         end
// 847:         installed_cask_message = installed_casks_by_tap.sort_by(&:first).filter_map do |_tap_name, casks|
// 848:           next if casks.empty?
// 849:
// 850:           "  brew trust --cask #{casks.sort.join(" ")}"
// 851:         end.join("\n")
// 852:         installed_items_from_untrusted_taps = installed_formula_message.present? || installed_cask_message.present?
// 853:         untap_message = "Untap them with:\n  brew untap #{untrusted_tap_names.join(" ")}"
// 854:         generic_trust_types = []
// 855:         generic_trust_commands = []
// 856:         if installed_formula_message.blank?
// 857:           generic_trust_types << "formulae"
// 858:           generic_trust_commands << "  brew trust --formula <user>/<tap>/<formula>"
// 859:         end
// 860:         if installed_cask_message.blank?
// 861:           generic_trust_types << "casks"
// 862:           generic_trust_commands << "  brew trust --cask <user>/<tap>/<cask>"
// 863:         end
// 864:         generic_trust_types << "commands"
// 865:         generic_trust_commands << "  brew trust --command <user>/<tap>/<command>"
// 866:         generic_trust_prefix = if installed_items_from_untrusted_taps
// 867:           "Trust other specific"
// 868:         else
// 869:           "Trust specific"
// 870:         end
// 871:         generic_trust_message = "#{generic_trust_prefix} #{generic_trust_types.to_sentence} with:\n" \
// 872:                                 "#{generic_trust_commands.join("\n")}"
// 873:         trust_messages = if installed_items_from_untrusted_taps
// 874:           ["Prefer trusting only the specific formulae, casks or commands you need."]
// 875:         else
// 876:           [untap_message]
// 877:         end
// 878:         if installed_formula_message.present?
// 879:           trust_messages << "Trust installed formulae from these taps with:\n#{installed_formula_message}"
// 880:         end
// 881:         if installed_cask_message.present?
// 882:           trust_messages << "Trust installed casks from these taps with:\n#{installed_cask_message}"
// 883:         end
// 884:         trust_messages << generic_trust_message
// 885:         trust_messages << <<~EOS.chomp
// 886:           Whole-tap trust is broader and includes all current and future formulae,
// 887:           casks and commands from the listed taps. Trust whole taps with:
// 888:             brew trust #{untrusted_tap_names.join(" ")}
// 889:         EOS
// 890:         trust_messages << untap_message if installed_items_from_untrusted_taps
// 891:         unless Homebrew::EnvConfig.no_env_hints?
// 892:           trust_messages << <<~EOS.chomp
// 893:             To disable trust checks:
// 894:               export HOMEBREW_NO_REQUIRE_TAP_TRUST=1
// 895:             This is not recommended and will be removed in a later release.
// 896:           EOS
// 897:         end
// 898:         trust_messages << <<~EOS.chomp
// 899:           For more information, see:
// 900:             #{Formatter.url("https://docs.brew.sh/Tap-Trust")}
// 901:         EOS
// 902:
// 903:         Finding.new(
// 904:           <<~EOS,
// 905:             The following taps are not trusted:
// 906:               #{untrusted_tap_names.join("\n  ")}
// 907:
// 908:             Homebrew is currently ignoring formulae, casks and commands from these taps because tap trust is required.
// 909:           EOS
// 910:           links:       ["https://docs.brew.sh/Tap-Trust"],
// 911:           remediation: trust_messages.join("\n"),
// 912:         )
// 913:       end
// 914:
// 915:       sig { params(formula: Formula).returns(T::Boolean) }
// 916:       def __check_linked_brew!(formula)
// 917:         formula.installed_prefixes.each do |prefix|
// 918:           prefix.find do |src|
// 919:             next if src == prefix
// 920:
// 921:             dst = HOMEBREW_PREFIX + src.relative_path_from(prefix)
// 922:             return true if dst.symlink? && src == dst.resolved_path
// 923:           end
// 924:         end
// 925:
// 926:         false
// 927:       end
// 928:
// 929:       sig { returns(T.nilable(Finding)) }
// 930:       def check_for_other_frameworks
// 931:         # Other frameworks that are known to cause problems when present
// 932:         frameworks_to_check = %w[
// 933:           expat.framework
// 934:           libexpat.framework
// 935:           libcurl.framework
// 936:         ]
// 937:         frameworks_found = frameworks_to_check
// 938:                            .map { |framework| "/Library/Frameworks/#{framework}" }
// 939:                            .select { |framework| File.exist? framework }
// 940:         return if frameworks_found.empty?
// 941:
// 942:         Finding.new(
// 943:           <<~EOS,
// 944:             Some frameworks can be picked up by CMake's build system and will likely
// 945:             cause the build to fail.
// 946:           EOS
// 947:           remediation: <<~EOS,
// 948:             To compile CMake, you may wish to move these out of the way:
// 949:             #{frameworks_found.join("\n")}
// 950:           EOS
// 951:         )
// 952:       end
// 953:
// 954:       sig { returns(T.nilable(Finding)) }
// 955:       def check_tmpdir
// 956:         tmpdir = ENV.fetch("TMPDIR", nil)
// 957:         return if tmpdir.nil? || File.directory?(tmpdir)
// 958:
// 959:         Finding.new(
// 960:           <<~EOS,
// 961:             TMPDIR #{tmpdir.inspect} doesn't exist.
// 962:           EOS
// 963:         )
// 964:       end
// 965:
// 966:       sig { returns(T.nilable(Finding)) }
// 967:       def check_missing_deps
// 968:         return if !HOMEBREW_CELLAR.exist? && !Cask::Caskroom.path.exist?
// 969:
// 970:         missing = Set.new
// 971:         Homebrew::Missing.deps(Formula.installed, Cask::Caskroom.casks).each_value do |deps|
// 972:           missing.merge(deps)
// 973:         end
// 974:         return if missing.empty?
// 975:
// 976:         Finding.new(
// 977:           <<~EOS,
// 978:             Some installed formulae or casks are missing dependencies.
// 979:             Run `brew missing` for more details.
// 980:           EOS
// 981:           remediation: Finding::Remediation.new(
// 982:             text:     <<~EOS,
// 983:               You should `brew install` the missing dependencies:
// 984:                 brew install #{missing.sort * " "}
// 985:             EOS
// 986:             commands: ["brew install #{missing.sort * " "}"],
// 987:           ),
// 988:         )
// 989:       end
// 990:
// 991:       sig { returns(T.nilable(Finding)) }
// 992:       def check_deprecated_disabled
// 993:         return unless HOMEBREW_CELLAR.exist?
// 994:
// 995:         deprecated_or_disabled = Formula.installed.select { |f| f.deprecated? || f.disabled? }
// 996:         return if deprecated_or_disabled.empty?
// 997:
// 998:         Finding.new(
// 999:           "Some installed formulae are deprecated or disabled.",
// 1000:           affects:     deprecated_or_disabled.map(&:full_name),
// 1001:           remediation: <<~EOS,
// 1002:             You should find replacements for the following formulae:
// 1003:                 #{deprecated_or_disabled.sort_by(&:full_name).uniq * "\n  "}
// 1004:           EOS
// 1005:         )
// 1006:       end
// 1007:
// 1008:       sig { returns(T.nilable(Finding)) }
// 1009:       def check_cask_deprecated_disabled
// 1010:         deprecated_or_disabled = Cask::Caskroom.casks.select(&:deprecated?)
// 1011:         deprecated_or_disabled += Cask::Caskroom.casks.select(&:disabled?)
// 1012:         return if deprecated_or_disabled.empty?
// 1013:
// 1014:         Finding.new(
// 1015:           "Some installed casks are deprecated or disabled.",
// 1016:           affects:     deprecated_or_disabled.map(&:token),
// 1017:           remediation: <<~EOS,
// 1018:             You should find replacements for the following casks:
// 1019:             #{deprecated_or_disabled.sort_by(&:token).uniq * "\n  "}
// 1020:           EOS
// 1021:         )
// 1022:       end
// 1023:
// 1024:       sig { returns(T::Array[Finding]) }
// 1025:       def check_git_status
// 1026:         return [] unless Utils::Git.available?
// 1027:
// 1028:         repos = {
// 1029:           "Homebrew/brew"          => HOMEBREW_REPOSITORY,
// 1030:           "Homebrew/homebrew-core" => CoreTap.instance.path,
// 1031:           "Homebrew/homebrew-cask" => CoreCaskTap.instance.path,
// 1032:         }
// 1033:
// 1034:         status = []
// 1035:         repos.each do |name, path|
// 1036:           finding = __tap_git_status(name, path)
// 1037:           status << finding if finding.present?
// 1038:         end
// 1039:
// 1040:         status
// 1041:       end
// 1042:
// 1043:       sig { params(tap: String, path: Pathname).returns(T.nilable(Finding)) }
// 1044:       def __tap_git_status(tap, path)
// 1045:         return unless path.exist?
// 1046:
// 1047:         status = path.cd do
// 1048:           `git status --untracked-files=all --porcelain 2>/dev/null`
// 1049:         end
// 1050:         return if status.blank?
// 1051:
// 1052:         message = <<~EOS
// 1053:           You have uncommitted modifications to #{tap}.
// 1054:         EOS
// 1055:         remediation = Finding::Remediation.new(
// 1056:           commands: ["git -C \"#{path}\" stash -u && git -C \"#{path}\" clean -d -f"],
// 1057:           text:     <<~EOS,
// 1058:             If this is a surprise to you, then you should stash these modifications.
// 1059:             Stashing returns Homebrew to a pristine state but can be undone
// 1060:             should you later need to do so for some reason.
// 1061:
// 1062:               git -C "#{path}" stash -u && git -C "#{path}" clean -d -f
// 1063:           EOS
// 1064:         )
// 1065:
// 1066:         modified = status.split("\n")
// 1067:         message += inject_file_list modified, <<~EOS
// 1068:           Uncommitted files:
// 1069:         EOS
// 1070:
// 1071:         Finding.new(message, affects: modified, remediation:) if message.present?
// 1072:       end
// 1073:
// 1074:       sig { returns(T.nilable(Finding)) }
// 1075:       def check_for_non_prefixed_coreutils
// 1076:         coreutils = Formula["coreutils"]
// 1077:         return unless coreutils.any_version_installed?
// 1078:
// 1079:         gnubin = %W[#{coreutils.opt_libexec}/gnubin #{coreutils.libexec}/gnubin]
// 1080:         return unless paths.intersect?(gnubin)
// 1081:
// 1082:         Finding.new(
// 1083:           <<~EOS,
// 1084:             Putting non-prefixed coreutils in your path can cause GMP builds to fail.
// 1085:           EOS
// 1086:         )
// 1087:       rescue FormulaUnavailableError
// 1088:         nil
// 1089:       end
// 1090:
// 1091:       sig { returns(T.nilable(Finding)) }
// 1092:       def check_for_pydistutils_cfg_in_home
// 1093:         return unless File.exist? "#{Dir.home}/.pydistutils.cfg"
// 1094:
// 1095:         Finding.new(
// 1096:           <<~EOS,
// 1097:             A '.pydistutils.cfg' file was found in $HOME, which may cause Python
// 1098:             builds to fail. See:
// 1099:               #{Formatter.url("https://bugs.python.org/issue6138")}
// 1100:               #{Formatter.url("https://bugs.python.org/issue4655")}
// 1101:           EOS
// 1102:           links: [
// 1103:             "https://bugs.python.org/issue6138",
// 1104:             "https://bugs.python.org/issue4655",
// 1105:           ],
// 1106:         )
// 1107:       end
// 1108:
// 1109:       sig { returns(T.nilable(Finding)) }
// 1110:       def check_for_unreadable_installed_formula
// 1111:         formula_unavailable_exceptions = []
// 1112:         Formula.racks.each do |rack|
// 1113:           Formulary.from_rack(rack)
// 1114:         rescue FormulaUnreadableError, FormulaClassUnavailableError,
// 1115:                TapFormulaUnreadableError, TapFormulaClassUnavailableError => e
// 1116:           formula_unavailable_exceptions << e
// 1117:         rescue Homebrew::UntrustedTapError, FormulaUnavailableError, TapFormulaAmbiguityError
// 1118:           nil
// 1119:         end
// 1120:         return if formula_unavailable_exceptions.empty?
// 1121:
// 1122:         Finding.new(
// 1123:           <<~EOS,
// 1124:             Some installed formulae are not readable:
// 1125:               #{formula_unavailable_exceptions.join("\n\n  ")}
// 1126:           EOS
// 1127:           affects: formula_unavailable_exceptions,
// 1128:         )
// 1129:       end
// 1130:
// 1131:       sig { returns(T.nilable(Finding)) }
// 1132:       def check_for_unlinked_but_not_keg_only
// 1133:         unlinked = Formula.racks.reject do |rack|
// 1134:           next true if (HOMEBREW_LINKED_KEGS/rack.basename).directory?
// 1135:
// 1136:           begin
// 1137:             Formulary.from_rack(rack).keg_only?
// 1138:           rescue Homebrew::UntrustedTapError
// 1139:             true
// 1140:           rescue FormulaUnavailableError, TapFormulaAmbiguityError
// 1141:             false
// 1142:           end
// 1143:         end.map(&:basename)
// 1144:         return if unlinked.empty?
// 1145:
// 1146:         Finding.new(
// 1147:           <<~EOS,
// 1148:             You have unlinked kegs in your Cellar.
// 1149:             Leaving kegs unlinked can lead to build-trouble and cause formulae that depend on
// 1150:             those kegs to fail to run properly once built.
// 1151:           EOS
// 1152:           affects:     unlinked.map(&:to_s),
// 1153:           remediation: Finding::Remediation.new(
// 1154:             text:     inject_file_list(unlinked, <<~EOS
// 1155:               Run `brew link` on these:
// 1156:             EOS
// 1157:             ),
// 1158:             commands: unlinked.map { |unlink| "brew link #{unlink}" },
// 1159:           ),
// 1160:         )
// 1161:       end
// 1162:
// 1163:       sig { returns(T.nilable(Finding)) }
// 1164:       def check_for_external_cmd_name_conflict
// 1165:         cmds = Commands.tap_cmd_directories.flat_map { |p| Dir["#{p}/brew-*"] }.uniq
// 1166:         cmds = cmds.select { |cmd| File.file?(cmd) && File.executable?(cmd) }
// 1167:         cmd_map = {}
// 1168:         cmds.each do |cmd|
// 1169:           cmd_name = File.basename(cmd, ".rb")
// 1170:           cmd_map[cmd_name] ||= []
// 1171:           cmd_map[cmd_name] << cmd
// 1172:         end
// 1173:         cmd_map.reject! { |_cmd_name, cmd_paths| cmd_paths.size == 1 }
// 1174:         return if cmd_map.empty?
// 1175:
// 1176:         if ENV["CI"].present? && cmd_map.keys.length == 1 &&
// 1177:            cmd_map.keys.first == "brew-test-bot"
// 1178:           return
// 1179:         end
// 1180:
// 1181:         message = "You have external commands with conflicting names.\n"
// 1182:         cmd_map.each do |cmd_name, cmd_paths|
// 1183:           message += inject_file_list cmd_paths, <<~EOS
// 1184:             Found command `#{cmd_name}` in the following places:
// 1185:           EOS
// 1186:         end
// 1187:
// 1188:         Finding.new(message)
// 1189:       end
// 1190:
// 1191:       sig { returns(T.nilable(Finding)) }
// 1192:       def check_for_tap_ruby_files_locations
// 1193:         bad_tap_files = {}
// 1194:         Tap.installed.each do |tap|
// 1195:           unused_formula_dirs = tap.potential_formula_dirs - [tap.formula_dir]
// 1196:           unused_formula_dirs.each do |dir|
// 1197:             next unless dir.exist?
// 1198:
// 1199:             dir.children.each do |path|
// 1200:               next if path.extname != ".rb"
// 1201:
// 1202:               bad_tap_files[tap] ||= []
// 1203:               bad_tap_files[tap] << path
// 1204:             end
// 1205:           end
// 1206:         end
// 1207:         return if bad_tap_files.empty?
// 1208:
// 1209:         Finding.new(bad_tap_files.keys.map do |tap|
// 1210:           <<~EOS
// 1211:             Found Ruby file outside #{tap} tap formula directory.
// 1212:             (#{tap.formula_dir}):
// 1213:               #{bad_tap_files[tap].join("\n  ")}
// 1214:           EOS
// 1215:         end.join("\n"))
// 1216:       end
// 1217:
// 1218:       sig { returns(T.nilable(Finding)) }
// 1219:       def check_homebrew_prefix
// 1220:         return if Homebrew.default_prefix?
// 1221:
// 1222:         Finding.new(
// 1223:           <<~EOS,
// 1224:             Your Homebrew's prefix is not #{Homebrew::DEFAULT_PREFIX}.
// 1225:
// 1226:             Most of Homebrew's bottles (binary packages) can only be used with the default prefix.
// 1227:           EOS
// 1228:           tier:        3,
// 1229:           remediation: "Consider uninstalling Homebrew and reinstalling into the default prefix.",
// 1230:         )
// 1231:       end
// 1232:
// 1233:       sig { returns(T.nilable(Finding)) }
// 1234:       def check_deleted_formula
// 1235:         kegs = Keg.all
// 1236:
// 1237:         deleted_formulae = kegs.filter_map do |keg|
// 1238:           tap = keg.tab.tap
// 1239:           tap_keg_name = tap ? "#{tap}/#{keg.name}" : keg.name
// 1240:
// 1241:           loadable = [
// 1242:             Formulary::FromAPILoader,
// 1243:             Formulary::FromTapLoader,
// 1244:             Formulary::FromNameLoader,
// 1245:           ].any? do |loader_class|
// 1246:             loader = begin
// 1247:               loader_class.try_new(tap_keg_name, warn: false)
// 1248:             rescue TapFormulaAmbiguityError => e
// 1249:               e.loaders.first
// 1250:             end
// 1251:
// 1252:             loader.instance_of?(Formulary::FromTapLoader) ? loader.path.exist? : loader.present?
// 1253:           end
// 1254:
// 1255:           keg.name unless loadable
// 1256:         end.uniq
// 1257:
// 1258:         return if deleted_formulae.blank?
// 1259:
// 1260:         Finding.new(
// 1261:           <<~EOS,
// 1262:             Some installed kegs have no formulae!
// 1263:             This means they were either deleted or installed manually.
// 1264:
// 1265:           EOS
// 1266:           affects:     deleted_formulae,
// 1267:           remediation: <<~EOS,
// 1268:             You should find replacements for the following formulae:
// 1269:               #{deleted_formulae.join("\n  ")}
// 1270:           EOS
// 1271:         )
// 1272:       end
// 1273:
// 1274:       sig { returns(T.nilable(Finding)) }
// 1275:       def check_for_unnecessary_core_tap
// 1276:         return if Homebrew::EnvConfig.developer?
// 1277:         return if Homebrew::EnvConfig.no_install_from_api?
// 1278:         return if Homebrew::EnvConfig.devcmdrun?
// 1279:         return unless CoreTap.instance.installed?
// 1280:
// 1281:         remediation = Finding::Remediation.new(text: <<~EOS, commands: ["brew untap #{CoreTap.instance.name}"])
// 1282:           Please remove it by running:
// 1283:            brew untap #{CoreTap.instance.name}
// 1284:         EOS
// 1285:         Finding.new(
// 1286:           <<~EOS,
// 1287:             You have an unnecessary local Core tap!
// 1288:             This can cause problems installing up-to-date formulae.
// 1289:           EOS
// 1290:           remediation:,
// 1291:         )
// 1292:       end
// 1293:
// 1294:       sig { returns(T.nilable(Finding)) }
// 1295:       def check_for_unnecessary_cask_tap
// 1296:         return if Homebrew::EnvConfig.developer?
// 1297:         return if Homebrew::EnvConfig.no_install_from_api?
// 1298:         return if Homebrew::EnvConfig.devcmdrun?
// 1299:
// 1300:         cask_tap = CoreCaskTap.instance
// 1301:         return unless cask_tap.installed?
// 1302:
// 1303:         remediation = Finding::Remediation.new(text: <<~EOS, commands: ["brew untap #{cask_tap.name}"])
// 1304:           Please remove it by running:
// 1305:            brew untap #{cask_tap.name}
// 1306:         EOS
// 1307:         Finding.new(
// 1308:           <<~EOS,
// 1309:             You have an unnecessary local Cask tap.
// 1310:             This can cause problems installing up-to-date casks.
// 1311:           EOS
// 1312:           remediation:,
// 1313:         )
// 1314:       end
// 1315:
// 1316:       sig { returns(T.nilable(Finding)) }
// 1317:       def check_deprecated_cask_taps
// 1318:         tapped_caskroom_taps = ::Tap.select { |t| t.user == "caskroom" || t.name == "phinze/cask" }
// 1319:                                     .map(&:name)
// 1320:         return if tapped_caskroom_taps.empty?
// 1321:
// 1322:         remediation = Finding::Remediation.new(
// 1323:           text:     <<~EOS,
// 1324:             Please remove it by running:
// 1325:              brew untap #{tapped_caskroom_taps.join(" ")}
// 1326:           EOS
// 1327:           commands: ["brew untap #{tapped_caskroom_taps.join(" ")}"],
// 1328:         )
// 1329:         Finding.new(
// 1330:           <<~EOS,
// 1331:             You have the following deprecated Cask taps installed:
// 1332:               #{tapped_caskroom_taps.join("\n  ")}
// 1333:           EOS
// 1334:           remediation:,
// 1335:         )
// 1336:       end
// 1337:
// 1338:       sig { returns(T.nilable(Finding)) }
// 1339:       def check_cask_software_versions
// 1340:         add_info "Homebrew Version", HOMEBREW_VERSION
// 1341:
// 1342:         nil
// 1343:       end
// 1344:
// 1345:       sig { returns(T.nilable(Finding)) }
// 1346:       def check_cask_install_location
// 1347:         locations = Dir.glob(HOMEBREW_CELLAR.join("brew-cask", "*")).reverse
// 1348:         return if locations.empty?
// 1349:
// 1350:         Finding.new(
// 1351:           locations.map do |l|
// 1352:             "Legacy install at #{l}."
// 1353:           end.join("\n"),
// 1354:           remediation: <<~EOS,
// 1355:             Run `brew uninstall --force brew-cask`.
// 1356:           EOS
// 1357:         )
// 1358:       end
// 1359:
// 1360:       sig { returns(T.nilable(Finding)) }
// 1361:       def check_cask_staging_location
// 1362:         # Skip this check when running CI since the staging path is not writable for security reasons
// 1363:         return if GitHub::Actions.env_set?
// 1364:
// 1365:         path = Cask::Caskroom.path
// 1366:
// 1367:         add_info "Cask Staging Location", user_tilde(path.to_s)
// 1368:
// 1369:         return if !path.exist? || path.writable?
// 1370:
// 1371:         remediation = Finding::Remediation.new(
// 1372:           text:     <<~EOS,
// 1373:             To fix, run:
// 1374:               sudo chown -R #{current_user} #{user_tilde(path.to_s)}
// 1375:           EOS
// 1376:           commands: ["sudo chown -R #{current_user} #{user_tilde(path.to_s)}"],
// 1377:         )
// 1378:         Finding.new(
// 1379:           <<~EOS,
// 1380:             The staging path #{user_tilde(path.to_s)} is not writable by the current user.
// 1381:           EOS
// 1382:           remediation:,
// 1383:         )
// 1384:       end
// 1385:
// 1386:       sig { returns(T.nilable(Finding)) }
// 1387:       def check_cask_corrupt_dirs
// 1388:         corrupt = Cask::Caskroom.corrupt_cask_dirs
// 1389:         return if corrupt.empty?
// 1390:
// 1391:         fixes = corrupt.map { |token| "brew reinstall --cask --force #{token}" }
// 1392:         Finding.new(
// 1393:           <<~EOS,
// 1394:             Some directories in the Caskroom do not have valid metadata.
// 1395:               #{corrupt.map { |token| "#{Cask::Caskroom.path}/#{token}" }.join("\n  ")}
// 1396:             The following #{Utils.pluralize("cask", corrupt.count)} cannot be upgraded as-is.
// 1397:           EOS
// 1398:           remediation: Finding::Remediation.new(
// 1399:             text:     <<~EOS,
// 1400:               To fix this, run:
// 1401:                 #{fixes.join("\n  ")}
// 1402:             EOS
// 1403:             commands: fixes,
// 1404:           ),
// 1405:         )
// 1406:       end
// 1407:
// 1408:       sig { returns(T.nilable(Finding)) }
// 1409:       def check_cask_taps
// 1410:         error_tap_paths = []
// 1411:
// 1412:         taps = (Tap.to_a + [CoreCaskTap.instance]).uniq
// 1413:
// 1414:         taps_info = taps.filter_map do |tap|
// 1415:           cask_count = begin
// 1416:             tap.cask_files.count
// 1417:           rescue
// 1418:             error_tap_paths << tap.path
// 1419:             0
// 1420:           end
// 1421:           next if cask_count.zero?
// 1422:
// 1423:           "#{tap.path} (#{Utils.pluralize("cask", cask_count, include_count: true)})"
// 1424:         end
// 1425:         add_info "Cask Taps:", taps_info
// 1426:
// 1427:         taps_string = Utils.pluralize("tap", error_tap_paths.count)
// 1428:         return unless error_tap_paths.present?
// 1429:
// 1430:         Finding.new("Unable to read from cask #{taps_string}: #{error_tap_paths.to_sentence}")
// 1431:       end
// 1432:
// 1433:       sig { returns(T.nilable(Finding)) }
// 1434:       def check_cask_load_path
// 1435:         paths = $LOAD_PATH.map { user_tilde(it) }
// 1436:
// 1437:         add_info "$LOAD_PATHS", paths.presence || none_string
// 1438:
// 1439:         Finding.new("$LOAD_PATH is empty") if paths.blank?
// 1440:       end
// 1441:
// 1442:       sig { returns(T.nilable(Finding)) }
// 1443:       def check_cask_environment_variables
// 1444:         environment_variables = %w[
// 1445:           RUBYLIB
// 1446:           RUBYOPT
// 1447:           RUBYPATH
// 1448:           RBENV_VERSION
// 1449:           CHRUBY_VERSION
// 1450:           GEM_HOME
// 1451:           GEM_PATH
// 1452:           BUNDLE_PATH
// 1453:           PATH
// 1454:           SHELL
// 1455:           HOMEBREW_CASK_OPTS
// 1456:         ]
// 1457:
// 1458:         locale_variables = ENV.keys.grep(/^(?:LC_\S+|LANG|LANGUAGE)\Z/).sort
// 1459:
// 1460:         cask_environment_variables = (locale_variables + environment_variables).sort.filter_map do |var|
// 1461:           next unless ENV.key?(var)
// 1462:
// 1463:           %Q(#{var}="#{Utils::Shell.sh_quote(ENV.fetch(var))}")
// 1464:         end
// 1465:         add_info "Cask Environment Variables:", cask_environment_variables
// 1466:
// 1467:         nil
// 1468:       end
// 1469:
// 1470:       sig { returns(T.nilable(Finding)) }
// 1471:       def check_cask_xattr
// 1472:         # If quarantine is not available, a warning is already shown by check_cask_quarantine_support so just return
// 1473:         return unless Cask::Quarantine.available?
// 1474:         return Finding.new("Unable to find `xattr`.") unless File.exist?("/usr/bin/xattr")
// 1475:
// 1476:         result = system_command "/usr/bin/xattr", args: ["-h"]
// 1477:
// 1478:         return if result.status.success?
// 1479:
// 1480:         if result.stderr.include? "ImportError: No module named pkg_resources"
// 1481:           result = Utils.popen_read "/usr/bin/python", "--version", err: :out
// 1482:
// 1483:           if result.include? "Python 2.7"
// 1484:             Finding.new(
// 1485:               <<~EOS,
// 1486:                 Your Python installation has a broken version of setuptools.
// 1487:               EOS
// 1488:               remediation: <<~EOS,
// 1489:                 To fix, reinstall macOS or run:
// 1490:                   sudo /usr/bin/python -m pip install -I setuptools
// 1491:               EOS
// 1492:             )
// 1493:           else
// 1494:             Finding.new(
// 1495:               <<~EOS,
// 1496:                 The system Python version is wrong.
// 1497:               EOS
// 1498:               remediation: <<~EOS,
// 1499:                 To fix, run:
// 1500:                   defaults write com.apple.versioner.python Version 2.7
// 1501:               EOS
// 1502:             )
// 1503:           end
// 1504:         elsif result.stderr.include? "pkg_resources.DistributionNotFound"
// 1505:           Finding.new("Your Python installation is unable to find `xattr`.")
// 1506:         else
// 1507:           Finding.new("unknown xattr error: #{result.stderr.split("\n").last}")
// 1508:         end
// 1509:       end
// 1510:
// 1511:       sig { returns(T::Array[Tap]) }
// 1512:       def non_core_taps
// 1513:         @non_core_taps ||= Tap.installed.reject(&:core_tap?).reject(&:core_cask_tap?)
// 1514:       end
// 1515:
// 1516:       sig { returns(T.nilable(Finding)) }
// 1517:       def check_for_duplicate_formulae
// 1518:         return if ENV["HOMEBREW_TEST_BOT"].present?
// 1519:
// 1520:         core_formula_names = CoreTap.instance.formula_names
// 1521:         shadowed_formula_full_names = non_core_taps.flat_map do |tap|
// 1522:           tap_formula_names = tap.formula_names.map { |s| s.delete_prefix("#{tap.name}/") }
// 1523:           (core_formula_names & tap_formula_names).map { |f| "#{tap.name}/#{f}" }
// 1524:         end.compact.sort
// 1525:         return if shadowed_formula_full_names.empty?
// 1526:
// 1527:         installed_formula_tap_names = Formula.installed.filter_map(&:tap).uniq.reject(&:official?).map(&:name)
// 1528:         shadowed_formula_tap_names = shadowed_formula_full_names.filter_map { |s| Utils.tap_from_full_name(s) }.uniq
// 1529:         unused_shadowed_formula_tap_names = (shadowed_formula_tap_names - installed_formula_tap_names).sort
// 1530:
// 1531:         remediation = if unused_shadowed_formula_tap_names.empty?
// 1532:           "Their taps are in use, so you must use these full names throughout Homebrew."
// 1533:         else
// 1534:           "Some of these can be resolved with:\n  brew untap #{unused_shadowed_formula_tap_names.join(" ")}"
// 1535:         end
// 1536:
// 1537:         Finding.new(
// 1538:           <<~EOS,
// 1539:             The following formulae have the same name as core formulae:
// 1540:               #{shadowed_formula_full_names.join("\n  ")}
// 1541:           EOS
// 1542:           remediation:,
// 1543:         )
// 1544:       end
// 1545:
// 1546:       sig { returns(T.nilable(Finding)) }
// 1547:       def check_for_duplicate_casks
// 1548:         return if ENV["HOMEBREW_TEST_BOT"].present?
// 1549:
// 1550:         core_cask_names = CoreCaskTap.instance.cask_tokens
// 1551:         shadowed_cask_full_names = non_core_taps.flat_map do |tap|
// 1552:           tap_cask_names = tap.cask_tokens.map { |s| s.delete_prefix("#{tap.name}/") }
// 1553:           (core_cask_names & tap_cask_names).map { |f| "#{tap.name}/#{f}" }
// 1554:         end.compact.sort
// 1555:         return if shadowed_cask_full_names.empty?
// 1556:
// 1557:         installed_cask_tap_names = Cask::Caskroom.casks.filter_map(&:tap).uniq.reject(&:official?).map(&:name)
// 1558:         shadowed_cask_tap_names = shadowed_cask_full_names.filter_map { |s| Utils.tap_from_full_name(s) }.uniq
// 1559:         unused_shadowed_cask_tap_names = (shadowed_cask_tap_names - installed_cask_tap_names).sort
// 1560:
// 1561:         remediation = if unused_shadowed_cask_tap_names.empty?
// 1562:           Finding::Remediation.new(
// 1563:             text: "Their taps are in use, so you must use these full names throughout Homebrew.",
// 1564:           )
// 1565:         else
// 1566:           Finding::Remediation.new(
// 1567:             text:     "Some of these can be resolved with:",
// 1568:             commands: ["brew untap #{unused_shadowed_cask_tap_names.join(" ")}"],
// 1569:           )
// 1570:         end
// 1571:
// 1572:         Finding.new(
// 1573:           <<~EOS,
// 1574:             The following casks have the same name as core casks:
// 1575:               #{shadowed_cask_full_names.join("\n  ")}
// 1576:           EOS
// 1577:           affects:     shadowed_cask_full_names,
// 1578:           remediation:,
// 1579:         )
// 1580:       end
// 1581:
// 1582:       sig { returns(T::Array[String]) }
// 1583:       def all
// 1584:         methods.map(&:to_s).grep(/^check_/).sort
// 1585:       end
// 1586:
// 1587:       sig { returns(T::Array[String]) }
// 1588:       def cask_checks
// 1589:         all.grep(/^check_cask_/)
// 1590:       end
// 1591:
// 1592:       sig { returns(String) }
// 1593:       def current_user
// 1594:         ENV.fetch("USER", "$(whoami)")
// 1595:       end
// 1596:
// 1597:       private
// 1598:
// 1599:       sig { returns(T::Array[String]) }
// 1600:       def paths
// 1601:         @paths ||= T.let(ORIGINAL_PATHS.uniq.map(&:to_s), T.nilable(T::Array[String]))
// 1602:       end
// 1603:     end
// 1604:   end
// 1605: end
// 1606:
// 1607: require "extend/os/diagnostic"
