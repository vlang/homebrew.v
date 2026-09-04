module homebrew

import ruby
import os

// Translated from Homebrew/brew `development_tools.rb`.
pub struct DevelopmentTools {
pub:
	prefix           string
	executable_paths []string
	command_outputs  map[string]string
	environment      map[string]string
	system           string
	os_version       string
	cpu_family       string
	preferred_gcc    string = 'gcc'
mut:
	locate_cache            map[string]string
	clang_output_cached     bool
	clang_output            string
	clang_version_cached    bool
	clang_version_value     string
	clang_build_cached      bool
	clang_build_value       string
	llvm_clang_build_cached bool
	llvm_clang_build_value  string
	gcc_versions            map[string]string
}

fn development_tools_environment() map[string]string {
	mut environment := map[string]string{}
	for key in ['HOMEBREW_SYSTEM_CA_CERTIFICATES_TOO_OLD', 'HOMEBREW_FORCE_BREWED_CA_CERTIFICATES'] {
		if value := os.getenv_opt(key) {
			environment[key] = value
		}
	}
	return environment
}

fn development_tools_system() string {
	configured := os.getenv('HOMEBREW_SYSTEM')
	if configured != '' {
		return configured
	}
	$if macos {
		return 'Macintosh'
	} $else $if linux {
		return 'Linux'
	} $else {
		return os.user_os()
	}
}

fn development_tools_cpu_family() string {
	configured := os.getenv('HOMEBREW_PROCESSOR')
	if configured != '' {
		return configured
	}
	$if arm64 {
		return 'arm'
	} $else $if amd64 {
		return 'intel'
	} $else {
		return 'unknown'
	}
}

pub fn new_development_tools(prefix string) &DevelopmentTools {
	return &DevelopmentTools{
		prefix: prefix
		environment: development_tools_environment()
		system: development_tools_system()
		os_version: os.getenv('HOMEBREW_OS_VERSION')
		cpu_family: development_tools_cpu_family()
		locate_cache: map[string]string{}
		gcc_versions: map[string]string{}
	}
}

fn (tools DevelopmentTools) executable(path string) bool {
	if tools.executable_paths.len > 0 {
		return path in tools.executable_paths
	}
	return os.is_file(path) && os.is_executable(path)
}

pub fn (mut tools DevelopmentTools) locate(tool string) ?string {
	if tool in tools.locate_cache {
		cached := tools.locate_cache[tool]
		return if cached == '' { none } else { cached }
	}
	usr_path := '/usr/bin/${tool}'
	prefix_path := os.join_path(tools.prefix, 'bin', tool)
	path := if tools.executable(usr_path) {
		usr_path
	} else if tools.executable(prefix_path) {
		prefix_path
	} else {
		''
	}
	tools.locate_cache[tool] = path
	return if path == '' { none } else { path }
}

pub fn (mut tools DevelopmentTools) installed() bool {
	tools.locate('clang') or {
		tools.locate('gcc') or { return false }
	}
	return true
}

pub fn development_tools_installation_instructions() string {
	return 'Install Clang or run `brew install gcc`.'
}

pub fn development_tools_insecure_download_warning(resource string) string {
	return 'Using `--insecure` with curl to download ${resource} because we need it to run `brew install ca-certificates` in order to download securely from now on. Checksums will still be verified.'
}

fn (tools DevelopmentTools) command_output(path string) string {
	if path in tools.command_outputs {
		return tools.command_outputs[path]
	}
	return os.execute('${os.quoted_path(path)} --version').output
}

pub fn (mut tools DevelopmentTools) clang_version_output() ?string {
	if tools.clang_output_cached {
		return if tools.clang_output == '' { none } else { tools.clang_output }
	}
	tools.clang_output_cached = true
	path := tools.locate('clang') or { return none }
	tools.clang_output = tools.command_output(path)
	return tools.clang_output
}

fn development_tools_numeric_component(value string) bool {
	return value != '' && value.bytes().all(it.is_digit())
}

fn development_tools_clang_version(output string) string {
	for marker in ['clang version ', 'LLVM version '] {
		if index := output.index(marker) {
			value := output[index + marker.len..].all_before(' ').trim_space()
			parts := value.split('.')
			if parts.len in [2, 3] && parts[1].len == 1 && (parts.len == 2 || parts[2].len == 1) && parts.all(development_tools_numeric_component(it)) {
				return value
			}
		}
	}
	return ''
}

fn development_tools_digits_after(output string, marker string, minimum int) string {
	if index := output.index(marker) {
		mut end := index + marker.len
		for end < output.len && output[end].is_digit() {
			end++
		}
		value := output[index + marker.len..end]
		if value.len >= minimum {
			return value
		}
	}
	return ''
}

fn development_tools_clang_build_version(output string) string {
	version := development_tools_digits_after(output, 'clang-', 2)
	if version != '' {
		return version
	}
	return development_tools_digits_after(output, '(tags/RELEASE_', 2)
}

fn development_tools_semantic_version(output string) string {
	for start, character in output.bytes() {
		if !character.is_digit() || (start > 0 && output[start - 1].is_digit()) {
			continue
		}
		mut end := start
		mut dots := 0
		for end < output.len && (output[end].is_digit() || output[end] == `.`) {
			if output[end] == `.` {
				dots++
			}
			end++
		}
		candidate := output[start..end].trim_right('.')
		if dots == 2 && candidate.split('.').all(development_tools_numeric_component(it)) {
			return candidate
		}
	}
	return ''
}

pub fn (mut tools DevelopmentTools) clang_version() string {
	if !tools.clang_version_cached {
		tools.clang_version_cached = true
		output := tools.clang_version_output() or { '' }
		tools.clang_version_value = development_tools_clang_version(output)
	}
	return tools.clang_version_value
}

pub fn (mut tools DevelopmentTools) clang_build_version() string {
	if !tools.clang_build_cached {
		tools.clang_build_cached = true
		output := tools.clang_version_output() or { '' }
		tools.clang_build_value = development_tools_clang_build_version(output)
	}
	return tools.clang_build_value
}

pub fn (mut tools DevelopmentTools) llvm_clang_build_version() string {
	if tools.llvm_clang_build_cached {
		return tools.llvm_clang_build_value
	}
	tools.llvm_clang_build_cached = true
	path := os.join_path(tools.prefix, 'opt', 'llvm', 'bin', 'clang')
	if tools.executable(path) {
		tools.llvm_clang_build_value = development_tools_clang_version(tools.command_output(path))
	}
	return tools.llvm_clang_build_value
}

pub fn development_tools_host_gcc_path() string {
	return '/usr/bin/gcc'
}

pub fn (mut tools DevelopmentTools) gcc_version(cc string) string {
	if cc in tools.gcc_versions {
		return tools.gcc_versions[cc]
	}
	preferred := os.join_path(tools.prefix, 'opt', tools.preferred_gcc, 'bin', cc)
	path := if tools.executable(preferred) { preferred } else { tools.locate(cc) or { '' } }
	version := if path == '' {
		''
	} else {
		development_tools_semantic_version(tools.command_output(path))
	}
	tools.gcc_versions[cc] = version
	return version
}

pub fn (mut tools DevelopmentTools) clear_version_cache() {
	tools.clang_output_cached = false
	tools.clang_output = ''
	tools.clang_version_cached = false
	tools.clang_version_value = ''
	tools.clang_build_cached = false
	tools.clang_build_value = ''
	tools.gcc_versions.clear()
}

pub fn (tools DevelopmentTools) ca_file_handles_most_https_certificates() bool {
	return 'HOMEBREW_SYSTEM_CA_CERTIFICATES_TOO_OLD' !in tools.environment
}

pub fn (tools DevelopmentTools) ca_file_substitution_required() bool {
	force := (tools.environment['HOMEBREW_FORCE_BREWED_CA_CERTIFICATES'] or { '' }) != ''
	cert := os.join_path(tools.prefix, 'etc', 'ca-certificates', 'cert.pem')
	return (!tools.ca_file_handles_most_https_certificates() || force) && !os.exists(cert)
}

pub fn (tools DevelopmentTools) build_system_info() map[string]string {
	return {
		'os':         tools.system
		'os_version': tools.os_version
		'cpu_family': tools.cpu_family
	}
}

fn development_tools_value(tools &DevelopmentTools) ruby.Value {
	return ruby.structured_value('DevelopmentTools', '', {
		'development_tools_address': u64(voidptr(tools)).str()
	})
}

fn development_tools_from_args(args []ruby.Value) (&DevelopmentTools, int) {
	if args.len > 0 && 'development_tools_address' in args[0].attributes {
		return unsafe { &DevelopmentTools(voidptr(args[0].attributes['development_tools_address'].u64())) }, 1
	}
	return new_development_tools(os.getenv('HOMEBREW_PREFIX')), 0
}

pub fn development_tools_boundary(tools &DevelopmentTools) ruby.Value {
	return development_tools_value(tools)
}

fn development_tools_version_value(version string) ruby.Value {
	return if version == '' {
		ruby.object_value('Version::NULL', '')
	} else {
		ruby.object_value('Version', version)
	}
}

// Ruby method `locate(tool)` at line 15.
pub fn ruby_development_tools_l15_d1_locate(args ...ruby.Value) ruby.Value {
	mut tools, offset := development_tools_from_args(args)
	if args.len <= offset {
		return ruby.object_value('NilClass', 'nil')
	}
	path := tools.locate(args[offset].as_string()) or {
		return ruby.object_value('NilClass', 'nil')
	}
	return ruby.object_value('Pathname', path)
}
