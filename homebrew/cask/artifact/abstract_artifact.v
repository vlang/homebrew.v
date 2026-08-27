module artifact

import brew_runtime

// Translated from Homebrew/brew `cask/artifact/abstract_artifact.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.english_name` at line 28.
pub fn ruby_abstract_artifact_l28_d1_self_english_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.english_name', ...args)
}

// Ruby method `self.english_article` at line 33.
pub fn ruby_abstract_artifact_l33_d2_self_english_article(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.english_article', ...args)
}

// Ruby method `self.dsl_key` at line 38.
pub fn ruby_abstract_artifact_l38_d3_self_dsl_key(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.dsl_key', ...args)
}

// Ruby method `self.dirmethod` at line 44.
pub fn ruby_abstract_artifact_l44_d4_self_dirmethod(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.dirmethod', ...args)
}

// Ruby method `summarize; end` at line 49.
pub fn ruby_abstract_artifact_l49_d5_summarize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('summarize', ...args)
}

// Ruby method `staged_path_join_executable(path)` at line 52.
pub fn ruby_abstract_artifact_l52_d6_staged_path_join_executable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('staged_path_join_executable', ...args)
}

// Ruby method `sort_order` at line 72.
pub fn ruby_abstract_artifact_l72_d7_sort_order(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sort_order', ...args)
}

// Ruby method `<=>(other)` at line 129.
pub fn ruby_abstract_artifact_l129_d8_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('<=>', ...args)
}

// Ruby method `self.read_script_arguments(arguments, stanza, default_arguments = {}, override_arguments = {}, key = nil)` at line 149.
pub fn ruby_abstract_artifact_l149_d9_self_read_script_arguments(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.read_script_arguments', ...args)
}

// Ruby attr_reader `attr_reader :cask` at line 187.
pub fn ruby_abstract_artifact_l187_d10_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby method `initialize(cask, *dsl_args)` at line 190.
pub fn ruby_abstract_artifact_l190_d11_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `config` at line 201.
pub fn ruby_abstract_artifact_l201_d12_config(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('config', ...args)
}

// Ruby method `cask_sandbox(network_access_allowed: false)` at line 206.
pub fn ruby_abstract_artifact_l206_d13_cask_sandbox(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_sandbox', ...args)
}

// Ruby method `run_cask_sandbox(sandbox, payload)` at line 221.
pub fn ruby_abstract_artifact_l221_d14_run_cask_sandbox(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run_cask_sandbox', ...args)
}

// Ruby method `to_s` at line 252.
pub fn ruby_abstract_artifact_l252_d15_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby method `to_args` at line 257.
pub fn ruby_abstract_artifact_l257_d16_to_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_args', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "extend/object/deep_dup"
// 5: require "env_config"
// 6: require "json"
// 7: require "sandbox"
// 8: require "tmpdir"
// 9: require "utils/output"
// 10:
// 11: module Cask
// 12:   # Module containing all cask artifact classes.
// 13:   module Artifact
// 14:     # Abstract superclass for all artifacts.
// 15:     class AbstractArtifact
// 16:       extend T::Helpers
// 17:       extend ::Utils::Output::Mixin
// 18:
// 19:       abstract!
// 20:
// 21:       include Comparable
// 22:       include ::Utils::Output::Mixin
// 23:
// 24:       # T.anything or the union of all possible argument types would be better choice, but it's convenient to be
// 25:       # able to invoke `.inspect`, `.to_s`, etc. without the overhead of type guards.
// 26:       DirectivesType = T.type_alias { Object }
// 27:       sig { overridable.returns(String) }
// 28:       def self.english_name
// 29:         @english_name ||= T.let(T.must(name).sub(/^.*:/, "").gsub(/(.)([A-Z])/, '\1 \2'), T.nilable(String))
// 30:       end
// 31:
// 32:       sig { returns(String) }
// 33:       def self.english_article
// 34:         @english_article ||= T.let(/^[aeiou]/i.match?(english_name) ? "an" : "a", T.nilable(String))
// 35:       end
// 36:
// 37:       sig { overridable.returns(Symbol) }
// 38:       def self.dsl_key
// 39:         @dsl_key ||= T.let(T.must(name).sub(/^.*:/, "").gsub(/(.)([A-Z])/, '\1_\2').downcase.to_sym,
// 40:                            T.nilable(Symbol))
// 41:       end
// 42:
// 43:       sig { overridable.returns(Symbol) }
// 44:       def self.dirmethod
// 45:         @dirmethod ||= T.let(:"#{dsl_key}dir", T.nilable(Symbol))
// 46:       end
// 47:
// 48:       sig { abstract.returns(String) }
// 49:       def summarize; end
// 50:
// 51:       sig { params(path: T.any(String, Pathname)).returns(Pathname) }
// 52:       def staged_path_join_executable(path)
// 53:         path = Pathname(path)
// 54:         path = path.expand_path if path.to_s.start_with?("~")
// 55:
// 56:         absolute_path = if path.absolute?
// 57:           path
// 58:         else
// 59:           cask.staged_path.join(path)
// 60:         end
// 61:
// 62:         FileUtils.chmod "+x", absolute_path if absolute_path.exist? && !absolute_path.executable?
// 63:
// 64:         if absolute_path.exist?
// 65:           absolute_path
// 66:         else
// 67:           path
// 68:         end
// 69:       end
// 70:
// 71:       sig { returns(T::Hash[T.class_of(AbstractArtifact), Integer]) }
// 72:       def sort_order
// 73:         @sort_order ||= T.let(
// 74:           [
// 75:             PreflightSteps,
// 76:             UninstallPreflightSteps,
// 77:             PreflightBlock,
// 78:             # The `uninstall` stanza should be run first, as it may
// 79:             # depend on other artifacts still being installed.
// 80:             Uninstall,
// 81:             GeneratedScript,
// 82:             Installer,
// 83:             # `pkg` should be run before `binary`, so
// 84:             # targets are created prior to linking.
// 85:             # `pkg` should be run before `app`, since an `app` could
// 86:             # contain a nested installer (e.g. `wireshark`).
// 87:             Pkg,
// 88:             [
// 89:               App,
// 90:               AppImage,
// 91:               Suite,
// 92:               Artifact,
// 93:               Colorpicker,
// 94:               Prefpane,
// 95:               Qlplugin,
// 96:               Mdimporter,
// 97:               Dictionary,
// 98:               Font,
// 99:               Service,
// 100:               InputMethod,
// 101:               InternetPlugin,
// 102:               KeyboardLayout,
// 103:               AudioUnitPlugin,
// 104:               VstPlugin,
// 105:               Vst3Plugin,
// 106:               ScreenSaver,
// 107:             ],
// 108:             [
// 109:               Binary,
// 110:               CommandWrapper,
// 111:             ],
// 112:             Manpage,
// 113:             [
// 114:               BashCompletion,
// 115:               FishCompletion,
// 116:               ZshCompletion,
// 117:             ],
// 118:             GeneratedCompletion,
// 119:             PostflightSteps,
// 120:             UninstallPostflightSteps,
// 121:             PostflightBlock,
// 122:             Zap,
// 123:           ].each_with_index.flat_map { |classes, i| Array(classes).map { |c| [c, i] } }.to_h,
// 124:           T.nilable(T::Hash[T.class_of(AbstractArtifact), Integer]),
// 125:         )
// 126:       end
// 127:
// 128:       sig { override.params(other: BasicObject).returns(T.nilable(Integer)) }
// 129:       def <=>(other)
// 130:         case other
// 131:         when AbstractArtifact
// 132:           return 0 if instance_of?(other.class)
// 133:
// 134:           (sort_order[self.class] <=> sort_order[other.class]).to_i
// 135:         end
// 136:       end
// 137:
// 138:       # TODO: this sort of logic would make more sense in dsl.rb, or a
// 139:       #       constructor called from dsl.rb, so long as that isn't slow.
// 140:       sig {
// 141:         params(
// 142:           arguments:          DirectivesType,
// 143:           stanza:             T.any(String, Symbol),
// 144:           default_arguments:  T::Hash[Symbol, T.anything],
// 145:           override_arguments: T::Hash[Symbol, T.anything],
// 146:           key:                T.nilable(Symbol),
// 147:         ).returns([T.nilable(String), T::Hash[Symbol, T.untyped]])
// 148:       }
// 149:       def self.read_script_arguments(arguments, stanza, default_arguments = {}, override_arguments = {}, key = nil)
// 150:         # TODO: when stanza names are harmonized with class names,
// 151:         #       stanza may not be needed as an explicit argument
// 152:         description = key ? "#{stanza} #{key.inspect}" : stanza.to_s
// 153:
// 154:         arguments = case arguments
// 155:         when String then { executable: arguments } # backward-compatible string value
// 156:         when Hash then arguments.dup # Avoid mutating the original argument
// 157:         else odie "Unsupported arguments type #{arguments.class}"
// 158:         end
// 159:
// 160:         # key sanity
// 161:         permitted_keys = [:args, :input, :executable, :must_succeed, :sudo, :print_stdout, :print_stderr]
// 162:         unknown_keys = arguments.keys - permitted_keys
// 163:         unless unknown_keys.empty?
// 164:           opoo "Unknown arguments to #{description} -- " \
// 165:                "#{unknown_keys.inspect} (ignored). Running " \
// 166:                "`brew update; brew cleanup` will likely fix it."
// 167:         end
// 168:         arguments.select! { |k| permitted_keys.include?(k) }
// 169:
// 170:         # key warnings
// 171:         override_keys = override_arguments.keys
// 172:         ignored_keys = arguments.keys & override_keys
// 173:         unless ignored_keys.empty?
// 174:           onoe "Some arguments to #{description} will be ignored -- :#{unknown_keys.inspect} (overridden)."
// 175:         end
// 176:
// 177:         # extract executable
// 178:         executable = arguments.key?(:executable) ? arguments.delete(:executable) : nil
// 179:
// 180:         arguments = default_arguments.merge arguments
// 181:         arguments.merge! override_arguments
// 182:
// 183:         [executable, arguments]
// 184:       end
// 185:
// 186:       sig { returns(Cask) }
// 187:       attr_reader :cask
// 188:
// 189:       sig { params(cask: Cask, dsl_args: T.anything).void }
// 190:       def initialize(cask, *dsl_args)
// 191:         @cask = cask
// 192:         @dirmethod = T.let(nil, T.nilable(Symbol))
// 193:         @dsl_args = T.let(dsl_args.deep_dup, T::Array[T.anything])
// 194:         @dsl_key = T.let(nil, T.nilable(Symbol))
// 195:         @english_article = T.let(nil, T.nilable(String))
// 196:         @english_name = T.let(nil, T.nilable(String))
// 197:         @sort_order = T.let(nil, T.nilable(T::Hash[T.class_of(AbstractArtifact), Integer]))
// 198:       end
// 199:
// 200:       sig { returns(Config) }
// 201:       def config
// 202:         cask.config
// 203:       end
// 204:
// 205:       sig { params(network_access_allowed: T::Boolean).returns(T.nilable(Sandbox)) }
// 206:       def cask_sandbox(network_access_allowed: false)
// 207:         return unless Sandbox.use_for?("running cask artifact operations")
// 208:
// 209:         Sandbox.new.tap do |sandbox|
// 210:           sandbox.allow_read(path: cask.staged_path, type: :subpath)
// 211:           sandbox.add_install_hook_rules(network_access_allowed:)
// 212:         end
// 213:       end
// 214:
// 215:       sig {
// 216:         params(
// 217:           sandbox: Sandbox,
// 218:           payload: T::Hash[String, T.untyped],
// 219:         ).void
// 220:       }
// 221:       def run_cask_sandbox(sandbox, payload)
// 222:         # Formulae sandbox the complete `postinstall.rb` process. Do the same
// 223:         # for cask operations so Ruby file changes and every command share one
// 224:         # profile, instead of forwarding command input and output through files.
// 225:         Dir.mktmpdir("homebrew-cask-sandbox", HOMEBREW_TEMP) do |temporary_directory|
// 226:           temporary_path = Pathname(temporary_directory)
// 227:           home = temporary_path/"home"
// 228:           payload_path = temporary_path/"payload.json"
// 229:           home.mkpath
// 230:           payload_path.write(JSON.generate(payload))
// 231:           sandbox.allow_read(path: payload_path)
// 232:
// 233:           # The payload carries only structured data, not a cask `.rb` file.
// 234:           # Set HOME before starting this child so its boot process and any
// 235:           # commands it runs cannot discover the user's real home directory.
// 236:           Sandbox.with_preserved_brew_file do
// 237:             sandbox.run(
// 238:               "/usr/bin/env",
// 239:               "HOME=#{home}",
// 240:               "nice",
// 241:               *HOMEBREW_RUBY_EXEC_ARGS,
// 242:               "-I", $LOAD_PATH.join(File::PATH_SEPARATOR),
// 243:               "--",
// 244:               HOMEBREW_LIBRARY_PATH/"cask_artifact.rb",
// 245:               payload_path
// 246:             )
// 247:           end
// 248:         end
// 249:       end
// 250:
// 251:       sig { returns(String) }
// 252:       def to_s
// 253:         "#{summarize} (#{self.class.english_name})"
// 254:       end
// 255:
// 256:       sig { returns(T::Array[T.anything]) }
// 257:       def to_args
// 258:         @dsl_args.compact_blank
// 259:       end
// 260:     end
// 261:   end
// 262: end
