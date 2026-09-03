module homebrew

import brew_runtime
import os

// Translated from Homebrew/brew `development_tools.rb`.
// The original source is retained below until every stub has a typed V body.
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

fn development_tools_value(tools &DevelopmentTools) brew_runtime.Value {
	return brew_runtime.structured_value('DevelopmentTools', '', {
		'development_tools_address': u64(voidptr(tools)).str()
	})
}

fn development_tools_from_args(args []brew_runtime.Value) (&DevelopmentTools, int) {
	if args.len > 0 && 'development_tools_address' in args[0].attributes {
		return unsafe { &DevelopmentTools(voidptr(args[0].attributes['development_tools_address'].u64())) }, 1
	}
	return new_development_tools(os.getenv('HOMEBREW_PREFIX')), 0
}

pub fn development_tools_boundary(tools &DevelopmentTools) brew_runtime.Value {
	return development_tools_value(tools)
}

fn development_tools_version_value(version string) brew_runtime.Value {
	return if version == '' {
		brew_runtime.object_value('Version::NULL', '')
	} else {
		brew_runtime.object_value('Version', version)
	}
}

// Ruby method `locate(tool)` at line 15.
pub fn ruby_development_tools_l15_d1_locate(args ...brew_runtime.Value) brew_runtime.Value {
	mut tools, offset := development_tools_from_args(args)
	if args.len <= offset {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	path := tools.locate(args[offset].as_string()) or {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return brew_runtime.object_value('Pathname', path)
}

// Ruby method `installed?` at line 30.
pub fn ruby_development_tools_l30_d2_installed(args ...brew_runtime.Value) brew_runtime.Value {
	mut tools, _ := development_tools_from_args(args)
	return brew_runtime.bool_value(tools.installed())
}

// Ruby method `installation_instructions` at line 35.
pub fn ruby_development_tools_l35_d3_installation_instructions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(development_tools_installation_instructions())
}

// Ruby method `custom_installation_instructions` at line 40.
pub fn ruby_development_tools_l40_d4_custom_installation_instructions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(development_tools_installation_instructions())
}

// Ruby method `insecure_download_warning(resource)` at line 45.
pub fn ruby_development_tools_l45_d5_insecure_download_warning(args ...brew_runtime.Value) brew_runtime.Value {
	_, offset := development_tools_from_args(args)
	resource := if args.len > offset { args[offset].as_string() } else { '' }
	return brew_runtime.string_value(development_tools_insecure_download_warning(resource))
}

// Ruby method `default_compiler` at line 56.
pub fn ruby_development_tools_l56_d6_default_compiler(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Symbol', 'clang')
}

// Ruby method `ld64_version` at line 61.
pub fn ruby_development_tools_l61_d7_ld64_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Version::NULL', '')
}

// Ruby method `clang_version_output` at line 66.
pub fn ruby_development_tools_l66_d8_clang_version_output(args ...brew_runtime.Value) brew_runtime.Value {
	mut tools, _ := development_tools_from_args(args)
	output := tools.clang_version_output() or {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return brew_runtime.string_value(output)
}

// Ruby method `clang_version` at line 78.
pub fn ruby_development_tools_l78_d9_clang_version(args ...brew_runtime.Value) brew_runtime.Value {
	mut tools, _ := development_tools_from_args(args)
	return development_tools_version_value(tools.clang_version())
}

// Ruby method `clang_build_version` at line 92.
pub fn ruby_development_tools_l92_d10_clang_build_version(args ...brew_runtime.Value) brew_runtime.Value {
	mut tools, _ := development_tools_from_args(args)
	return development_tools_version_value(tools.clang_build_version())
}

// Ruby method `llvm_clang_build_version` at line 106.
pub fn ruby_development_tools_l106_d11_llvm_clang_build_version(args ...brew_runtime.Value) brew_runtime.Value {
	mut tools, _ := development_tools_from_args(args)
	return development_tools_version_value(tools.llvm_clang_build_version())
}

// Ruby method `host_gcc_path` at line 120.
pub fn ruby_development_tools_l120_d12_host_gcc_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Pathname', development_tools_host_gcc_path())
}

// Ruby method `gcc_version(cc = host_gcc_path.to_s)` at line 128.
pub fn ruby_development_tools_l128_d13_gcc_version(args ...brew_runtime.Value) brew_runtime.Value {
	mut tools, offset := development_tools_from_args(args)
	cc := if args.len > offset {
		args[offset].as_string()
	} else {
		development_tools_host_gcc_path()
	}
	return development_tools_version_value(tools.gcc_version(cc))
}

// Ruby method `clear_version_cache` at line 143.
pub fn ruby_development_tools_l143_d14_clear_version_cache(args ...brew_runtime.Value) brew_runtime.Value {
	mut tools, _ := development_tools_from_args(args)
	tools.clear_version_cache()
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `needs_build_formulae?` at line 150.
pub fn ruby_development_tools_l150_d15_needs_build_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(false)
}

// Ruby method `needs_libc_formula?` at line 155.
pub fn ruby_development_tools_l155_d16_needs_libc_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(false)
}

// Ruby method `needs_compiler_formula?` at line 160.
pub fn ruby_development_tools_l160_d17_needs_compiler_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(false)
}

// Ruby method `ca_file_handles_most_https_certificates?` at line 165.
pub fn ruby_development_tools_l165_d18_ca_file_handles_most_https_certificates(args ...brew_runtime.Value) brew_runtime.Value {
	tools, _ := development_tools_from_args(args)
	return brew_runtime.bool_value(tools.ca_file_handles_most_https_certificates())
}

// Ruby method `curl_handles_most_https_certificates?` at line 172.
pub fn ruby_development_tools_l172_d19_curl_handles_most_https_certificates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(true)
}

// Ruby method `ca_file_substitution_required?` at line 177.
pub fn ruby_development_tools_l177_d20_ca_file_substitution_required(args ...brew_runtime.Value) brew_runtime.Value {
	tools, _ := development_tools_from_args(args)
	return brew_runtime.bool_value(tools.ca_file_substitution_required())
}

// Ruby method `curl_substitution_required?` at line 183.
pub fn ruby_development_tools_l183_d21_curl_substitution_required(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(false)
}

// Ruby method `build_system_info` at line 188.
pub fn ruby_development_tools_l188_d22_build_system_info(args ...brew_runtime.Value) brew_runtime.Value {
	tools, _ := development_tools_from_args(args)
	mut result := map[string]brew_runtime.Value{}
	for key, value in tools.build_system_info() {
		result[key] = brew_runtime.string_value(value)
	}
	return brew_runtime.map_value(result)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "version"
// 5:
// 6: # Helper class for gathering information about development tools.
// 7: #
// 8: # @api public
// 9: class DevelopmentTools
// 10:   class << self
// 11:     # Locate a development tool.
// 12:     #
// 13:     # @api public
// 14:     sig { params(tool: T.any(String, Symbol)).returns(T.nilable(Pathname)) }
// 15:     def locate(tool)
// 16:       # Don't call tools (cc, make, strip, etc.) directly!
// 17:       # Give the name of the binary you look for as a string to this method
// 18:       # in order to get the full path back as a Pathname.
// 19:       (@locate ||= T.let({}, T.nilable(T::Hash[T.any(String, Symbol), T.untyped]))).fetch(tool) do |key|
// 20:         @locate[key] = if File.executable?(path = "/usr/bin/#{tool}")
// 21:           Pathname.new path
// 22:         # Homebrew GCCs most frequently; much faster to check this before xcrun
// 23:         elsif (path = HOMEBREW_PREFIX/"bin/#{tool}").executable?
// 24:           path
// 25:         end
// 26:       end
// 27:     end
// 28:
// 29:     sig { returns(T::Boolean) }
// 30:     def installed?
// 31:       !!(locate("clang") || locate("gcc"))
// 32:     end
// 33:
// 34:     sig { returns(String) }
// 35:     def installation_instructions
// 36:       "Install Clang or run `brew install gcc`."
// 37:     end
// 38:
// 39:     sig { returns(String) }
// 40:     def custom_installation_instructions
// 41:       installation_instructions
// 42:     end
// 43:
// 44:     sig { params(resource: String).returns(String) }
// 45:     def insecure_download_warning(resource)
// 46:       package = curl_handles_most_https_certificates? ? "ca-certificates" : "curl"
// 47:       "Using `--insecure` with curl to download #{resource} because we need it to run " \
// 48:         "`brew install #{package}` in order to download securely from now on. " \
// 49:         "Checksums will still be verified."
// 50:     end
// 51:
// 52:     # Get the default C compiler.
// 53:     #
// 54:     # @api public
// 55:     sig { returns(Symbol) }
// 56:     def default_compiler
// 57:       :clang
// 58:     end
// 59:
// 60:     sig { returns(Version) }
// 61:     def ld64_version
// 62:       Version::NULL
// 63:     end
// 64:
// 65:     sig { returns(T.nilable(String)) }
// 66:     def clang_version_output
// 67:       @clang_version_output ||= T.let(
// 68:         if (path = locate("clang"))
// 69:           `#{path} --version`
// 70:         end, T.nilable(String)
// 71:       )
// 72:     end
// 73:
// 74:     # Get the Clang version.
// 75:     #
// 76:     # @api public
// 77:     sig { returns(Version) }
// 78:     def clang_version
// 79:       @clang_version ||= T.let(
// 80:         if (build_version = clang_version_output&.[](/(?:clang|LLVM) version (\d+\.\d(?:\.\d)?)/, 1))
// 81:           Version.new(build_version)
// 82:         else
// 83:           Version::NULL
// 84:         end, T.nilable(Version)
// 85:       )
// 86:     end
// 87:
// 88:     # Get the Clang build version.
// 89:     #
// 90:     # @api public
// 91:     sig { returns(Version) }
// 92:     def clang_build_version
// 93:       @clang_build_version ||= T.let(
// 94:         if (build_version = clang_version_output&.[](%r{clang(-| version [^ ]+ \(tags/RELEASE_)(\d{2,})}, 2))
// 95:           Version.new(build_version)
// 96:         else
// 97:           Version::NULL
// 98:         end, T.nilable(Version)
// 99:       )
// 100:     end
// 101:
// 102:     # Get the LLVM Clang build version.
// 103:     #
// 104:     # @api public
// 105:     sig { returns(Version) }
// 106:     def llvm_clang_build_version
// 107:       @llvm_clang_build_version ||= T.let(begin
// 108:         path = Formula["llvm"].opt_prefix/"bin/clang"
// 109:         if path.executable? && (build_version = `#{path} --version`[/clang version (\d+\.\d\.\d)/, 1])
// 110:           Version.new(build_version)
// 111:         else
// 112:           Version::NULL
// 113:         end
// 114:       rescue FormulaUnavailableError
// 115:         Version::NULL
// 116:       end, T.nilable(Version))
// 117:     end
// 118:
// 119:     sig { returns(Pathname) }
// 120:     def host_gcc_path
// 121:       Pathname.new("/usr/bin/gcc")
// 122:     end
// 123:
// 124:     # Get the GCC version.
// 125:     #
// 126:     # @api public
// 127:     sig { params(cc: String).returns(Version) }
// 128:     def gcc_version(cc = host_gcc_path.to_s)
// 129:       (@gcc_version ||= T.let({}, T.nilable(T::Hash[String, Version]))).fetch(cc) do
// 130:         path = HOMEBREW_PREFIX/"opt/#{CompilerSelector.preferred_gcc}/bin"/cc
// 131:         path = locate(cc) unless path.exist?
// 132:         version = if path &&
// 133:                      (build_version = `#{path} --version`[/gcc(?:(?:-\d+(?:\.\d)?)? \(.+\))? (\d+\.\d\.\d)/, 1])
// 134:           Version.new(build_version)
// 135:         else
// 136:           Version::NULL
// 137:         end
// 138:         @gcc_version[cc] = version
// 139:       end
// 140:     end
// 141:
// 142:     sig { void }
// 143:     def clear_version_cache
// 144:       @clang_version_output = T.let(nil, T.nilable(String))
// 145:       @clang_version = @clang_build_version = T.let(nil, T.nilable(Version))
// 146:       @gcc_version = T.let({}, T.nilable(T::Hash[String, Version]))
// 147:     end
// 148:
// 149:     sig { returns(T::Boolean) }
// 150:     def needs_build_formulae?
// 151:       needs_libc_formula? || needs_compiler_formula?
// 152:     end
// 153:
// 154:     sig { returns(T::Boolean) }
// 155:     def needs_libc_formula?
// 156:       false
// 157:     end
// 158:
// 159:     sig { returns(T::Boolean) }
// 160:     def needs_compiler_formula?
// 161:       false
// 162:     end
// 163:
// 164:     sig { returns(T::Boolean) }
// 165:     def ca_file_handles_most_https_certificates?
// 166:       # The system CA file is too old for some modern HTTPS certificates on
// 167:       # older OS versions.
// 168:       ENV["HOMEBREW_SYSTEM_CA_CERTIFICATES_TOO_OLD"].nil?
// 169:     end
// 170:
// 171:     sig { returns(T::Boolean) }
// 172:     def curl_handles_most_https_certificates?
// 173:       true
// 174:     end
// 175:
// 176:     sig { returns(T::Boolean) }
// 177:     def ca_file_substitution_required?
// 178:       (!ca_file_handles_most_https_certificates? || ENV["HOMEBREW_FORCE_BREWED_CA_CERTIFICATES"].present?) &&
// 179:         !(HOMEBREW_PREFIX/"etc/ca-certificates/cert.pem").exist?
// 180:     end
// 181:
// 182:     sig { returns(T::Boolean) }
// 183:     def curl_substitution_required?
// 184:       !curl_handles_most_https_certificates? && !HOMEBREW_BREWED_CURL_PATH.exist?
// 185:     end
// 186:
// 187:     sig { returns(T::Hash[String, T.nilable(String)]) }
// 188:     def build_system_info
// 189:       {
// 190:         "os"         => HOMEBREW_SYSTEM,
// 191:         "os_version" => OS_VERSION,
// 192:         "cpu_family" => Hardware::CPU.family.to_s,
// 193:       }
// 194:     end
// 195:   end
// 196: end
// 197:
// 198: require "extend/os/development_tools"
