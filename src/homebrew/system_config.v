module homebrew

import brew_runtime

// Translated from Homebrew/brew `system_config.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize` at line 17.
pub fn ruby_system_config_l17_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `clang` at line 23.
pub fn ruby_system_config_l23_d2_clang(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('clang', ...args)
}

// Ruby method `clang_build` at line 32.
pub fn ruby_system_config_l32_d3_clang_build(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('clang_build', ...args)
}

// Ruby method `homebrew_repo` at line 41.
pub fn ruby_system_config_l41_d4_homebrew_repo(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('homebrew_repo', ...args)
}

// Ruby method `homebrew_head_info` at line 46.
pub fn ruby_system_config_l46_d5_homebrew_head_info(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('homebrew_head_info', ...args)
}

// Ruby method `branch` at line 54.
pub fn ruby_system_config_l54_d6_branch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('branch', ...args)
}

// Ruby method `head` at line 59.
pub fn ruby_system_config_l59_d7_head(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('head', ...args)
}

// Ruby method `last_commit` at line 64.
pub fn ruby_system_config_l64_d8_last_commit(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('last_commit', ...args)
}

// Ruby method `origin` at line 69.
pub fn ruby_system_config_l69_d9_origin(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('origin', ...args)
}

// Ruby method `describe_clang` at line 74.
pub fn ruby_system_config_l74_d10_describe_clang(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('describe_clang', ...args)
}

// Ruby method `describe_homebrew_ruby` at line 85.
pub fn ruby_system_config_l85_d11_describe_homebrew_ruby(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('describe_homebrew_ruby', ...args)
}

// Ruby method `hardware` at line 90.
pub fn ruby_system_config_l90_d12_hardware(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('hardware', ...args)
}

// Ruby method `kernel` at line 97.
pub fn ruby_system_config_l97_d13_kernel(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('kernel', ...args)
}

// Ruby method `windows_version; end` at line 102.
pub fn ruby_system_config_l102_d14_windows_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('windows_version', ...args)
}

// Ruby method `describe_git` at line 105.
pub fn ruby_system_config_l105_d15_describe_git(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('describe_git', ...args)
}

// Ruby method `describe_curl` at line 112.
pub fn ruby_system_config_l112_d16_describe_curl(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('describe_curl', ...args)
}

// Ruby method `dump_tap_config(tap, out = $stdout)` at line 124.
pub fn ruby_system_config_l124_d17_dump_tap_config(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dump_tap_config', ...args)
}

// Ruby method `core_tap_config(out = $stdout)` at line 154.
pub fn ruby_system_config_l154_d18_core_tap_config(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('core_tap_config', ...args)
}

// Ruby method `homebrew_config(out = $stdout)` at line 160.
pub fn ruby_system_config_l160_d19_homebrew_config(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('homebrew_config', ...args)
}

// Ruby method `homebrew_env_config(out = $stdout)` at line 169.
pub fn ruby_system_config_l169_d20_homebrew_env_config(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('homebrew_env_config', ...args)
}

// Ruby method `host_software_config(out = $stdout)` at line 198.
pub fn ruby_system_config_l198_d21_host_software_config(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('host_software_config', ...args)
}

// Ruby method `hardware_config(out = $stdout)` at line 205.
pub fn ruby_system_config_l205_d22_hardware_config(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('hardware_config', ...args)
}

// Ruby method `config_sections` at line 211.
pub fn ruby_system_config_l211_d23_config_sections(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('config_sections', ...args)
}

// Ruby method `dump_verbose_config(out = $stdout)` at line 216.
pub fn ruby_system_config_l216_d24_dump_verbose_config(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dump_verbose_config', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "hardware"
// 5: require "tap"
// 6: require "development_tools"
// 7: require "extend/ENV"
// 8: require "system_command"
// 9: require "git_repository"
// 10:
// 11: # Helper module for querying information about the system configuration.
// 12: module SystemConfig
// 13:   class << self
// 14:     include SystemCommand::Mixin
// 15:
// 16:     sig { void }
// 17:     def initialize
// 18:       @clang = T.let(nil, T.nilable(Version))
// 19:       @clang_build = T.let(nil, T.nilable(Version))
// 20:     end
// 21:
// 22:     sig { returns(Version) }
// 23:     def clang
// 24:       @clang ||= if DevelopmentTools.installed?
// 25:         DevelopmentTools.clang_version
// 26:       else
// 27:         Version::NULL
// 28:       end
// 29:     end
// 30:
// 31:     sig { returns(Version) }
// 32:     def clang_build
// 33:       @clang_build ||= if DevelopmentTools.installed?
// 34:         DevelopmentTools.clang_build_version
// 35:       else
// 36:         Version::NULL
// 37:       end
// 38:     end
// 39:
// 40:     sig { returns(GitRepository) }
// 41:     def homebrew_repo
// 42:       GitRepository.new(HOMEBREW_REPOSITORY)
// 43:     end
// 44:
// 45:     sig { returns([T.nilable(String), T.nilable(String), T.nilable(String)]) }
// 46:     def homebrew_head_info
// 47:       @homebrew_head_info ||= T.let(
// 48:         homebrew_repo.head_info,
// 49:         T.nilable([T.nilable(String), T.nilable(String), T.nilable(String)]),
// 50:       )
// 51:     end
// 52:
// 53:     sig { returns(String) }
// 54:     def branch
// 55:       homebrew_head_info[2] || "(none)"
// 56:     end
// 57:
// 58:     sig { returns(String) }
// 59:     def head
// 60:       homebrew_head_info[0] || "(none)"
// 61:     end
// 62:
// 63:     sig { returns(String) }
// 64:     def last_commit
// 65:       homebrew_head_info[1] || "never"
// 66:     end
// 67:
// 68:     sig { returns(String) }
// 69:     def origin
// 70:       homebrew_repo.origin_url || "(none)"
// 71:     end
// 72:
// 73:     sig { returns(String) }
// 74:     def describe_clang
// 75:       return "N/A" if clang.null?
// 76:
// 77:       if clang_build.null?
// 78:         clang.to_s
// 79:       else
// 80:         "#{clang} build #{clang_build}"
// 81:       end
// 82:     end
// 83:
// 84:     sig { returns(String) }
// 85:     def describe_homebrew_ruby
// 86:       "#{RUBY_VERSION} => #{RUBY_PATH}"
// 87:     end
// 88:
// 89:     sig { returns(T.nilable(String)) }
// 90:     def hardware
// 91:       return if Hardware::CPU.type == :dunno
// 92:
// 93:       "CPU: #{Hardware.cores_as_words}-core #{Hardware::CPU.bits}-bit #{Hardware::CPU.family}"
// 94:     end
// 95:
// 96:     sig { returns(String) }
// 97:     def kernel
// 98:       `uname -m`.chomp
// 99:     end
// 100:
// 101:     sig { returns(T.nilable(String)) }
// 102:     def windows_version; end
// 103:
// 104:     sig { returns(String) }
// 105:     def describe_git
// 106:       return "N/A" unless Utils::Git.available?
// 107:
// 108:       "#{Utils::Git.version} => #{Utils::Git.path}"
// 109:     end
// 110:
// 111:     sig { returns(String) }
// 112:     def describe_curl
// 113:       out = system_command(Utils::Curl.curl_executable, args: ["--version"], verbose: false).stdout
// 114:
// 115:       match_data = /^curl (?<curl_version>[\d.]+)/.match(out)
// 116:       if match_data
// 117:         "#{match_data[:curl_version]} => #{Utils::Curl.curl_path}"
// 118:       else
// 119:         "N/A"
// 120:       end
// 121:     end
// 122:
// 123:     sig { params(tap: Tap, out: T.any(File, StringIO, IO)).void }
// 124:     def dump_tap_config(tap, out = $stdout)
// 125:       case tap
// 126:       when CoreTap
// 127:         tap_name = "Core tap"
// 128:         json_file_name = "formula.jws.json"
// 129:       when CoreCaskTap
// 130:         tap_name = "Core cask tap"
// 131:         json_file_name = "cask.jws.json"
// 132:       else
// 133:         raise ArgumentError, "Unknown tap: #{tap}"
// 134:       end
// 135:
// 136:       if tap.installed?
// 137:         out.puts "#{tap_name} origin: #{tap.remote}" if tap.remote != tap.default_remote
// 138:         head, last_commit, branch = tap.git_repository.head_info
// 139:         out.puts "#{tap_name} HEAD: #{head || "(none)"}"
// 140:         out.puts "#{tap_name} last commit: #{last_commit || "never"}"
// 141:         default_branches = %w[main master].freeze
// 142:         out.puts "#{tap_name} branch: #{branch || "(none)"}" if default_branches.exclude?(branch)
// 143:       end
// 144:
// 145:       json_file = Homebrew::API::HOMEBREW_CACHE_API/json_file_name
// 146:       if json_file.exist?
// 147:         out.puts "#{tap_name} JSON: #{json_file.mtime.utc.strftime("%d %b %H:%M UTC")}"
// 148:       elsif !tap.installed?
// 149:         out.puts "#{tap_name}: N/A"
// 150:       end
// 151:     end
// 152:
// 153:     sig { params(out: T.any(File, StringIO, IO)).void }
// 154:     def core_tap_config(out = $stdout)
// 155:       dump_tap_config(CoreTap.instance, out)
// 156:       dump_tap_config(CoreCaskTap.instance, out)
// 157:     end
// 158:
// 159:     sig { params(out: T.any(File, StringIO, IO)).void }
// 160:     def homebrew_config(out = $stdout)
// 161:       out.puts "HOMEBREW_VERSION: #{HOMEBREW_VERSION}"
// 162:       out.puts "ORIGIN: #{origin}"
// 163:       out.puts "HEAD: #{head}"
// 164:       out.puts "Last commit: #{last_commit}"
// 165:       out.puts "Branch: #{branch}"
// 166:     end
// 167:
// 168:     sig { params(out: T.any(File, StringIO, IO)).void }
// 169:     def homebrew_env_config(out = $stdout)
// 170:       out.puts "HOMEBREW_PREFIX: #{HOMEBREW_PREFIX}"
// 171:       repository = HOMEBREW_REPOSITORY
// 172:       cellar = HOMEBREW_CELLAR
// 173:       out.puts "HOMEBREW_REPOSITORY: #{repository}" if repository.to_s != Homebrew::DEFAULT_REPOSITORY.to_s
// 174:       out.puts "HOMEBREW_CELLAR: #{cellar}" if cellar.to_s != Homebrew::DEFAULT_CELLAR.to_s
// 175:
// 176:       Homebrew::EnvConfig.non_default_variables.each do |env|
// 177:         env_symbol = env.to_sym
// 178:         hash = Homebrew::EnvConfig::ENVS.fetch(env_symbol)
// 179:         value = Homebrew::EnvConfig.public_send(Homebrew::EnvConfig.env_method_name(env_symbol, hash))
// 180:
// 181:         if hash[:boolean]
// 182:           out.puts "#{env}: #{value ? "set" : "false"}"
// 183:           next
// 184:         end
// 185:
// 186:         next unless value
// 187:
// 188:         if ENV.sensitive?(env)
// 189:           out.puts "#{env}: set"
// 190:         else
// 191:           out.puts "#{env}: #{value}"
// 192:         end
// 193:       end
// 194:       out.puts "Homebrew Ruby: #{describe_homebrew_ruby}"
// 195:     end
// 196:
// 197:     sig { params(out: T.any(File, StringIO, IO)).void }
// 198:     def host_software_config(out = $stdout)
// 199:       out.puts "Clang: #{describe_clang}"
// 200:       out.puts "Git: #{describe_git}"
// 201:       out.puts "Curl: #{describe_curl}"
// 202:     end
// 203:
// 204:     sig { params(out: T.any(File, StringIO, IO)).void }
// 205:     def hardware_config(out = $stdout)
// 206:       hardware = self.hardware
// 207:       out.puts hardware if hardware
// 208:     end
// 209:
// 210:     sig { returns(T::Array[Symbol]) }
// 211:     def config_sections
// 212:       [:homebrew_config, :core_tap_config, :homebrew_env_config, :hardware_config, :host_software_config]
// 213:     end
// 214:
// 215:     sig { params(out: T.any(File, StringIO, IO)).void }
// 216:     def dump_verbose_config(out = $stdout)
// 217:       # Most sections shell out for their values (Git, compilers, curl,
// 218:       # etc.), so render them concurrently and print them in order.
// 219:       sections = Utils.parallel_map(config_sections) do |section|
// 220:         io = StringIO.new
// 221:         public_send(section, io)
// 222:         io.string
// 223:       end
// 224:       sections.each { |section| out.print section }
// 225:     end
// 226:   end
// 227: end
// 228:
// 229: require "extend/os/system_config"
