module dsl

import ruby

// Translated from Homebrew/brew `cask/dsl/caveats.rb`.
// The original source is retained below until every stub has a typed V body.
const conditional_caveats = ['requires_rosetta', 'files_in_usr_local']

pub struct CaskCaveatEntry {
pub:
	name string
	args []string
	text string
}

pub struct CaskCaveats {
pub mut:
	cask         ruby.Value
	built_in     []CaskCaveatEntry
	custom       []string
	discontinued bool
	invoked      []string
}

fn caveats_nil() ruby.Value {
	return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
}

pub fn new_cask_caveats(cask ruby.Value) CaskCaveats {
	return CaskCaveats{ cask: cask }
}

pub fn cask_caveats_value(caveats CaskCaveats) ruby.Value {
	return ruby.Value{
		type_name: 'Cask::DSL::Caveats'
		repr: caveats_text(caveats, true)
		map_data: {
			'cask':             caveats.cask
			'built_in_caveats': ruby.array_value(caveats.built_in.map(ruby.map_value({
				'name': ruby.string_value(it.name)
				'args': ruby.string_array_value(it.args)
				'text': ruby.string_value(it.text)
			})))
			'custom_caveats':   ruby.string_array_value(caveats.custom)
			'discontinued':     ruby.bool_value(caveats.discontinued)
			'invoked_caveats':  ruby.string_array_value(caveats.invoked)
		}
	}
}

pub fn cask_caveats_from_value(value ruby.Value) !CaskCaveats {
	if value.type_name != 'Cask::DSL::Caveats' {
		return error('expected Cask::DSL::Caveats, got ${value.type_name}')
	}
	mut caveats := CaskCaveats{
		cask: value.map_data['cask'] or { ruby.object_value('Cask', value.repr) }
		custom: (value.map_data['custom_caveats'] or { ruby.string_array_value([]) }).as_string_array()!
		discontinued: (value.map_data['discontinued'] or { ruby.bool_value(false) }).as_bool() or { false }
		invoked: (value.map_data['invoked_caveats'] or { ruby.string_array_value([]) }).as_string_array()!
	}
	for raw in (value.map_data['built_in_caveats'] or { ruby.array_value([]ruby.Value{}) }).as_array()! {
		caveats.built_in << CaskCaveatEntry{
			name: (raw.map_data['name'] or { ruby.string_value('') }).as_string()
			args: (raw.map_data['args'] or { ruby.string_array_value([]) }).as_string_array()!
			text: (raw.map_data['text'] or { ruby.string_value('') }).as_string()
		}
	}
	return caveats
}

fn caveats_text(caveats CaskCaveats, include_conditional bool) string {
	mut texts := caveats.custom.clone()
	for entry in caveats.built_in {
		if include_conditional || entry.name !in conditional_caveats { texts << entry.text }
	}
	return texts.join('\n')
}

fn caveats_cask_name(caveats CaskCaveats) string {
	return (caveats.cask.map_data['token'] or { ruby.string_value(caveats.cask.as_string()) }).as_string()
}

fn caveats_builtin_text(caveats CaskCaveats, name string, arguments []string) ?string {
	cask := caveats_cask_name(caveats)
	first := if arguments.len > 0 { arguments[0] } else { '' }
	match name {
		'kext' {
			version := (caveats.cask.map_data['macos_version'] or { ruby.string_value('sonoma') }).as_string()
			if version !in ['sonoma', 'sequoia', 'tahoe'] {
				return none
			}
			return '${cask} requires a kernel extension to work.\nIf the installation fails, retry after you enable it in:\n  System Settings → Privacy & Security\n\nFor more information, refer to vendor documentation or this Apple Technical Note:\n  https://developer.apple.com/library/content/technotes/tn2459/_index.html\n'
		}
		'unsigned_accessibility' {
			access := if first == '' || first == 'nil' { 'Accessibility' } else { first }
			version := (caveats.cask.map_data['macos_version'] or { ruby.string_value('ventura') }).as_string()
			navigation := if version in ['ventura', 'sonoma', 'sequoia', 'tahoe'] {
				'System Settings → Privacy & Security'
			} else {
				'System Preferences → Security & Privacy → Privacy'
			}
			return '${cask} is not signed and requires Accessibility access,\nso you will need to re-grant Accessibility access every time the app is updated.\n\nEnable or re-enable it in:\n  ${navigation} → ${access}\nTo re-enable, untick and retick ${cask}.app.\n'
		}
		'path_environment_variable' {
			return 'To use ${cask}, you may need to add the ${first} directory\nto your PATH environment variable, e.g. (for Bash shell):\n  export PATH=${first}:"\$PATH"\n'
		}
		'zsh_path_helper' {
			return 'To use ${cask}, zsh users may need to add the following line to their\n~/.zprofile. (Among other effects, ${first} will be added to the\nPATH environment variable):\n  eval `/usr/libexec/path_helper -s`\n'
		}
		'files_in_usr_local' {
			prefix := (caveats.cask.map_data['homebrew_prefix'] or { ruby.string_value('/opt/homebrew') }).as_string()
			if !prefix.to_lower().starts_with('/usr/local') {
				return none
			}
			return "Cask ${cask} installs files under /usr/local. The presence of such\nfiles can cause warnings when running `brew doctor`, which is considered\nto be a bug in Homebrew's cask handling.\n"
		}
		'depends_on_java' {
			version := if first == '' { 'any' } else { first.trim_left(':') }
			if version == 'any' {
				return '${cask} requires Java. You can install the latest version with:\n  brew install --cask temurin\n'
			}
			if version.contains('+') {
				return '${cask} requires Java ${version}. You can install the latest version with:\n  brew install --cask temurin\n'
			}
			return '${cask} requires Java ${version}. You can install it with:\n  brew install --cask temurin@${version}\n'
		}
		'requires_rosetta' {
			arch := (caveats.cask.map_data['system_arch'] or { ruby.string_value('intel') }).as_string().trim_left(':')
			installed := (caveats.cask.map_data['rosetta_installed'] or { ruby.bool_value(false) }).as_bool() or { false }
			if arch !in ['arm', 'arm64'] || installed {
				return none
			}
			return '${cask} is built for Intel macOS and so requires Rosetta 2 to be installed.\nYou can install Rosetta 2 with:\n  softwareupdate --install-rosetta --agree-to-license\nNote that it is very difficult to remove Rosetta 2 once it is installed.\n'
		}
		'logout' {
			return 'You must log out and log back in for the installation of ${cask} to take effect.\n'
		}
		'reboot' {
			return 'You must reboot for the installation of ${cask} to take effect.\n'
		}
		'license' {
			return 'Installing ${cask} means you have AGREED to the license at:\n  ${first}\n'
		}
		'free_license' {
			return 'The vendor offers a free license for ${cask} at:\n  ${first}\n'
		}
		else {
			return none
		}
	}
}

pub fn (mut caveats CaskCaveats) invoke(name string, arguments []string) {
	if name !in caveats.invoked { caveats.invoked << name }
	text := caveats_builtin_text(caveats, name, arguments) or { return }
	for index, entry in caveats.built_in {
		if entry.name == name && entry.args == arguments {
			caveats.built_in[index] = CaskCaveatEntry{ name: name, args: arguments, text: text }
			return
		}
	}
	caveats.built_in << CaskCaveatEntry{ name: name, args: arguments, text: text }
}

// Ruby method `initialize(*args)` at line 23.
pub fn ruby_caveats_l23_d1_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'Caveats#initialize requires a cask')
	}
	return cask_caveats_value(new_cask_caveats(args[0]))
}

// Ruby method `self.caveat(name, &block)` at line 34.
pub fn ruby_caveats_l34_d2_self_caveat(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'caveat requires a name')
	}
	return ruby.structured_value('Cask::DSL::CaveatDefinition', args[0].as_string(), {
		'name': args[0].as_string().trim_left(':')
	})
}

// Ruby define_method `define_method(name) do |*args|` at line 35.
pub fn ruby_caveats_l35_d3_name(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'caveat invocation requires receiver and name')
	}
	mut caveats := cask_caveats_from_value(args[0]) or { return ruby.object_value('TypeError', err.msg()) }
	mut values := []string{}
	for index in 2 .. args.len {
		values << args[index].as_string()
	}
	caveats.invoke(args[1].as_string().trim_left(':'), values)
	result := cask_caveats_value(caveats)
	return ruby.Value{
		...result
		attributes: {
			'return': 'built_in_caveat'
		}
	}
}

// Ruby method `discontinued? = @discontinued` at line 48.
pub fn ruby_caveats_l48_d4_discontinued(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'discontinued? requires a receiver')
	}
	caveats := cask_caveats_from_value(args[0]) or { return ruby.object_value('TypeError', err.msg()) }
	return ruby.bool_value(caveats.discontinued)
}

// Ruby method `to_s` at line 51.
pub fn ruby_caveats_l51_d5_to_s(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'to_s requires a receiver')
	}
	caveats := cask_caveats_from_value(args[0]) or { return ruby.object_value('TypeError', err.msg()) }
	return ruby.string_value(caveats_text(caveats, true))
}

// Ruby method `to_s_without_conditional` at line 59.
pub fn ruby_caveats_l59_d6_to_s_without_conditional(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'to_s_without_conditional requires a receiver')
	}
	caveats := cask_caveats_from_value(args[0]) or { return ruby.object_value('TypeError', err.msg()) }
	return ruby.string_value(caveats_text(caveats, false))
}

// Ruby method `invoked?(name)` at line 68.
pub fn ruby_caveats_l68_d7_invoked(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'invoked? requires a name')
	}
	caveats := cask_caveats_from_value(args[0]) or { return ruby.object_value('TypeError', err.msg()) }
	return ruby.bool_value(args[1].as_string().trim_left(':') in caveats.invoked)
}

// Ruby method `puts(*args)` at line 74.
pub fn ruby_caveats_l74_d8_puts(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'puts requires a receiver')
	}
	mut caveats := cask_caveats_from_value(args[0]) or { return ruby.object_value('TypeError', err.msg()) }
	for index in 1 .. args.len {
		caveats.custom << args[index].as_string()
	}
	return cask_caveats_value(caveats)
}

// Ruby method `eval_caveats(&block)` at line 80.
pub fn ruby_caveats_l80_d9_eval_caveats(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'eval_caveats requires a receiver')
	}
	mut caveats := cask_caveats_from_value(args[0]) or { return ruby.object_value('TypeError', err.msg()) }
	if args.len > 1 {
		result := args[1]
		if result.type_name != 'NilClass' && !(result.type_name == 'Symbol' && result.as_string().trim_left(':') == 'built_in_caveat') {
			caveats.custom << result.as_string().trim_right(' \t\r\n') + '\n'
		}
	}
	return cask_caveats_value(caveats)
}

// Ruby attr_reader `attr_reader :invoked_caveats` at line 204.
pub fn ruby_caveats_l204_d10_invoked_caveats(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'invoked_caveats requires a receiver')
	}
	caveats := cask_caveats_from_value(args[0]) or { return ruby.object_value('TypeError', err.msg()) }
	return ruby.string_array_value(caveats.invoked)
}

// Ruby attr_reader `attr_reader :built_in_caveats` at line 207.
pub fn ruby_caveats_l207_d11_built_in_caveats(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'built_in_caveats requires a receiver')
	}
	caveats := cask_caveats_from_value(args[0]) or { return ruby.object_value('TypeError', err.msg()) }
	mut values := map[string]ruby.Value{}
	for entry in caveats.built_in {
		values['${entry.name}:${entry.args.join(',')}'] = ruby.string_value(entry.text)
	}
	return ruby.map_value(values)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/utils"
// 5:
// 6: module Cask
// 7:   class DSL
// 8:     # Class corresponding to the `caveats` stanza.
// 9:     #
// 10:     # Each method should handle output, following the
// 11:     # convention of at least one trailing blank line so that the user
// 12:     # can distinguish separate caveats.
// 13:     #
// 14:     # The return value of the last method in the block is also sent
// 15:     # to the output by the caller, but that feature is only for the
// 16:     # convenience of cask authors.
// 17:     class Caveats < Base
// 18:       # Built-in caveats that have runtime conditions (arch, prefix, etc.)
// 19:       # and should not be pre-serialized into the API JSON string.
// 20:       CONDITIONAL_CAVEATS = [:requires_rosetta, :files_in_usr_local].freeze
// 21:
// 22:       sig { params(args: T.anything).void }
// 23:       def initialize(*args)
// 24:         super
// 25:         @built_in_caveats = T.let({}, T::Hash[T::Array[T.any(String, Symbol)], String])
// 26:         @custom_caveats = T.let([], T::Array[String])
// 27:         @discontinued = T.let(false, T::Boolean)
// 28:         @invoked_caveats = T.let(Set.new, T::Set[Symbol])
// 29:       end
// 30:
// 31:       sig {
// 32:         params(name: Symbol, block: T.proc.bind(Caveats).void).void
// 33:       }
// 34:       def self.caveat(name, &block)
// 35:         define_method(name) do |*args|
// 36:           T.bind(self, Caveats)
// 37:           key = [name, *args]
// 38:           invoked_caveats.add(name)
// 39:           text = instance_exec(*args, &block)
// 40:           built_in_caveats[key] = text if text
// 41:           :built_in_caveat
// 42:         end
// 43:       end
// 44:
// 45:       private_class_method :caveat
// 46:
// 47:       sig { returns(T::Boolean) }
// 48:       def discontinued? = @discontinued
// 49:
// 50:       sig { returns(String) }
// 51:       def to_s
// 52:         (@custom_caveats + @built_in_caveats.values).join("\n")
// 53:       end
// 54:
// 55:       # Returns caveats text excluding conditional built-in caveats.
// 56:       # Used when serializing caveats for the JSON API so that conditional
// 57:       # caveats (like requires_rosetta) are not pre-baked into the string.
// 58:       sig { returns(String) }
// 59:       def to_s_without_conditional
// 60:         unconditional = @built_in_caveats.reject do |key, _|
// 61:           name = key.first
// 62:           name && CONDITIONAL_CAVEATS.include?(name)
// 63:         end
// 64:         (@custom_caveats + unconditional.values).join("\n")
// 65:       end
// 66:
// 67:       sig { params(name: Symbol).returns(T::Boolean) }
// 68:       def invoked?(name)
// 69:         @invoked_caveats.include?(name)
// 70:       end
// 71:
// 72:       # Override `puts` to collect caveats.
// 73:       sig { params(args: String).returns(Symbol) }
// 74:       def puts(*args)
// 75:         @custom_caveats += args
// 76:         :built_in_caveat
// 77:       end
// 78:
// 79:       sig { params(block: T.proc.bind(Caveats).returns(T.nilable(T.any(Symbol, String)))).void }
// 80:       def eval_caveats(&block)
// 81:         result = instance_eval(&block)
// 82:         return unless result
// 83:         return if result == :built_in_caveat
// 84:
// 85:         @custom_caveats << result.to_s.sub(/\s*\Z/, "\n")
// 86:       end
// 87:
// 88:       caveat :kext do
// 89:         next if MacOS.version < :sonoma
// 90:
// 91:         <<~EOS
// 92:           #{cask} requires a kernel extension to work.
// 93:           If the installation fails, retry after you enable it in:
// 94:             System Settings → Privacy & Security
// 95:
// 96:           For more information, refer to vendor documentation or this Apple Technical Note:
// 97:             #{Formatter.url("https://developer.apple.com/library/content/technotes/tn2459/_index.html")}
// 98:         EOS
// 99:       end
// 100:
// 101:       caveat :unsigned_accessibility do |access = "Accessibility"|
// 102:         # access: the category in the privacy settings the app requires.
// 103:         access = "Accessibility" if access.nil?
// 104:
// 105:         <<~EOS
// 106:           #{cask} is not signed and requires Accessibility access,
// 107:           so you will need to re-grant Accessibility access every time the app is updated.
// 108:
// 109:           Enable or re-enable it in:
// 110:             #{::Cask::Utils.privacy_security_preference_pane(access)}
// 111:           To re-enable, untick and retick #{cask}.app.
// 112:         EOS
// 113:       end
// 114:
// 115:       caveat :path_environment_variable do |path|
// 116:         <<~EOS
// 117:           To use #{cask}, you may need to add the #{path} directory
// 118:           to your PATH environment variable, e.g. (for Bash shell):
// 119:             export PATH=#{path}:"$PATH"
// 120:         EOS
// 121:       end
// 122:
// 123:       caveat :zsh_path_helper do |path|
// 124:         <<~EOS
// 125:           To use #{cask}, zsh users may need to add the following line to their
// 126:           ~/.zprofile. (Among other effects, #{path} will be added to the
// 127:           PATH environment variable):
// 128:             eval `/usr/libexec/path_helper -s`
// 129:         EOS
// 130:       end
// 131:
// 132:       caveat :files_in_usr_local do
// 133:         next unless HOMEBREW_PREFIX.to_s.downcase.start_with?("/usr/local")
// 134:
// 135:         <<~EOS
// 136:           Cask #{cask} installs files under /usr/local. The presence of such
// 137:           files can cause warnings when running `brew doctor`, which is considered
// 138:           to be a bug in Homebrew's cask handling.
// 139:         EOS
// 140:       end
// 141:
// 142:       caveat :depends_on_java do |java_version = :any|
// 143:         if java_version == :any
// 144:           <<~EOS
// 145:             #{cask} requires Java. You can install the latest version with:
// 146:               brew install --cask temurin
// 147:           EOS
// 148:         elsif java_version.to_s.include?("+")
// 149:           <<~EOS
// 150:             #{cask} requires Java #{java_version}. You can install the latest version with:
// 151:               brew install --cask temurin
// 152:           EOS
// 153:         else
// 154:           <<~EOS
// 155:             #{cask} requires Java #{java_version}. You can install it with:
// 156:               brew install --cask temurin@#{java_version}
// 157:           EOS
// 158:         end
// 159:       end
// 160:
// 161:       caveat :requires_rosetta do
// 162:         next if Homebrew::SimulateSystem.current_arch != :arm
// 163:         next if Hardware::CPU.rosetta_installed?
// 164:
// 165:         <<~EOS
// 166:           #{cask} is built for Intel macOS and so requires Rosetta 2 to be installed.
// 167:           You can install Rosetta 2 with:
// 168:             softwareupdate --install-rosetta --agree-to-license
// 169:           Note that it is very difficult to remove Rosetta 2 once it is installed.
// 170:         EOS
// 171:       end
// 172:
// 173:       caveat :logout do
// 174:         <<~EOS
// 175:           You must log out and log back in for the installation of #{cask} to take effect.
// 176:         EOS
// 177:       end
// 178:
// 179:       caveat :reboot do
// 180:         <<~EOS
// 181:           You must reboot for the installation of #{cask} to take effect.
// 182:         EOS
// 183:       end
// 184:
// 185:       caveat :license do |web_page|
// 186:         <<~EOS
// 187:           Installing #{cask} means you have AGREED to the license at:
// 188:             #{Formatter.url(web_page.to_s)}
// 189:         EOS
// 190:       end
// 191:
// 192:       caveat :free_license do |web_page|
// 193:         <<~EOS
// 194:           The vendor offers a free license for #{cask} at:
// 195:             #{Formatter.url(web_page.to_s)}
// 196:         EOS
// 197:       end
// 198:
// 199:       private
// 200:
// 201:       # These attrs are required as a workaround for https://github.com/sorbet/sorbet/issues/8106
// 202:
// 203:       sig { returns(T::Set[Symbol]) }
// 204:       attr_reader :invoked_caveats
// 205:
// 206:       sig { returns(T::Hash[T::Array[T.any(String, Symbol)], String]) }
// 207:       attr_reader :built_in_caveats
// 208:     end
// 209:   end
// 210: end
