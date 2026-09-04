module cask

import ruby

// Translated from Homebrew/brew `cask/exceptions.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(errors)` at line 11.
pub fn ruby_exceptions_l11_d1_initialize(args ...ruby.Value) ruby.Value {
	errors := if args.len > 0 {
		args[0].as_array() or { []ruby.Value{} }
	} else {
		[]ruby.Value{}
	}
	return cask_exception_value(CaskException{ kind: .multiple, errors: errors.map(it.as_string()) })
}

// Ruby method `to_s` at line 18.
pub fn ruby_exceptions_l18_d2_to_s(args ...ruby.Value) ruby.Value {
	return ruby.string_value(cask_exception_message(cask_exception_from_args(args, .multiple)))
}

// Ruby attr_reader `attr_reader :token` at line 29.
pub fn ruby_exceptions_l29_d3_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value(cask_exception_from_args(args, .not_installed).token)
}

// Ruby attr_reader `attr_reader :reason` at line 32.
pub fn ruby_exceptions_l32_d4_reason(args ...ruby.Value) ruby.Value {
	return ruby.string_value(cask_exception_from_args(args, .unavailable).reason)
}

// Ruby method `initialize(token, reason = nil)` at line 35.
pub fn ruby_exceptions_l35_d5_initialize(args ...ruby.Value) ruby.Value {
	return cask_exception_value(CaskException{ token: (args[0] or { ruby.string_value('') }).as_string(), reason: (args[1] or { ruby.string_value('') }).as_string() })
}

// Ruby method `to_s` at line 46.
pub fn ruby_exceptions_l46_d6_to_s(args ...ruby.Value) ruby.Value {
	return ruby.string_value(cask_exception_message(cask_exception_from_args(args, .not_installed)))
}

// Ruby attr_reader `attr_reader :message` at line 54.
pub fn ruby_exceptions_l54_d7_message(args ...ruby.Value) ruby.Value {
	return ruby.string_value(cask_exception_from_args(args, .cannot_install).detail)
}

// Ruby method `initialize(token, message)` at line 57.
pub fn ruby_exceptions_l57_d8_initialize(args ...ruby.Value) ruby.Value {
	return cask_exception_value(CaskException{ kind: .cannot_install, token: (args[0] or { ruby.string_value('') }).as_string(), detail: (args[1] or { ruby.string_value('') }).as_string() })
}

// Ruby method `to_s` at line 63.
pub fn ruby_exceptions_l63_d9_to_s(args ...ruby.Value) ruby.Value {
	return ruby.string_value(cask_exception_message(cask_exception_from_args(args, .cannot_install)))
}

// Ruby attr_reader `attr_reader :conflicting_cask` at line 71.
pub fn ruby_exceptions_l71_d10_conflicting_cask(args ...ruby.Value) ruby.Value {
	return ruby.string_value(cask_exception_from_args(args, .conflict).conflicting_cask)
}

// Ruby method `initialize(token, conflicting_cask)` at line 74.
pub fn ruby_exceptions_l74_d11_initialize(args ...ruby.Value) ruby.Value {
	return cask_exception_value(CaskException{ kind: .conflict, token: (args[0] or { ruby.string_value('') }).as_string(), conflicting_cask: (args[1] or { ruby.string_value('') }).as_string() })
}

// Ruby method `to_s` at line 80.
pub fn ruby_exceptions_l80_d12_to_s(args ...ruby.Value) ruby.Value {
	return ruby.string_value(cask_exception_message(cask_exception_from_args(args, .conflict)))
}

// Ruby method `to_s` at line 88.
pub fn ruby_exceptions_l88_d13_to_s(args ...ruby.Value) ruby.Value {
	return ruby.string_value(cask_exception_message(cask_exception_from_args(args, .unavailable)))
}

// Ruby method `to_s` at line 96.
pub fn ruby_exceptions_l96_d14_to_s(args ...ruby.Value) ruby.Value {
	return ruby.string_value(cask_exception_message(cask_exception_from_args(args, .unreadable)))
}

// Ruby attr_reader `attr_reader :tap` at line 104.
pub fn ruby_exceptions_l104_d15_tap(args ...ruby.Value) ruby.Value {
	return ruby.string_value(cask_exception_from_args(args, .tap_unavailable).tap)
}

// Ruby method `initialize(tap, token)` at line 107.
pub fn ruby_exceptions_l107_d16_initialize(args ...ruby.Value) ruby.Value {
	tap := (args[0] or { ruby.string_value('') }).as_string()
	return cask_exception_value(CaskException{ kind: .tap_unavailable, tap: tap, tap_installed: args.len > 2 && args[2].bool_data, token: '${tap}/${(args[1] or { ruby.string_value('') }).as_string()}' })
}

// Ruby method `to_s` at line 113.
pub fn ruby_exceptions_l113_d17_to_s(args ...ruby.Value) ruby.Value {
	return ruby.string_value(cask_exception_message(cask_exception_from_args(args, .tap_unavailable)))
}

// Ruby attr_reader `attr_reader :token` at line 126.
pub fn ruby_exceptions_l126_d18_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value(cask_exception_from_args(args, .ambiguity).token)
}

// Ruby attr_reader `attr_reader :loaders` at line 129.
pub fn ruby_exceptions_l129_d19_loaders(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(cask_exception_from_args(args, .ambiguity).loaders)
}

// Ruby method `initialize(token, loaders)` at line 132.
pub fn ruby_exceptions_l132_d20_initialize(args ...ruby.Value) ruby.Value {
	loaders := (args[1] or { ruby.string_array_value([]) }).as_string_array() or { []string{} }
	return cask_exception_value(CaskException{ kind: .ambiguity, token: (args[0] or { ruby.string_value('') }).as_string(), loaders: loaders })
}

// Ruby method `to_s` at line 151.
pub fn ruby_exceptions_l151_d21_to_s(args ...ruby.Value) ruby.Value {
	return ruby.string_value(cask_exception_message(cask_exception_from_args(args, .already_created)))
}

// Ruby method `to_s` at line 159.
pub fn ruby_exceptions_l159_d22_to_s(args ...ruby.Value) ruby.Value {
	return ruby.string_value(cask_exception_message(cask_exception_from_args(args, .cyclic)))
}

// Ruby method `to_s` at line 167.
pub fn ruby_exceptions_l167_d23_to_s(args ...ruby.Value) ruby.Value {
	return ruby.string_value(cask_exception_message(cask_exception_from_args(args, .self_referencing)))
}

// Ruby method `to_s` at line 175.
pub fn ruby_exceptions_l175_d24_to_s(args ...ruby.Value) ruby.Value {
	return ruby.string_value(cask_exception_message(CaskException{ kind: .unspecified }))
}

// Ruby method `to_s` at line 183.
pub fn ruby_exceptions_l183_d25_to_s(args ...ruby.Value) ruby.Value {
	return ruby.string_value(cask_exception_message(cask_exception_from_args(args, .invalid)))
}

// Ruby method `initialize(token, header_token)` at line 191.
pub fn ruby_exceptions_l191_d26_initialize(args ...ruby.Value) ruby.Value {
	token := (args[0] or { ruby.string_value('') }).as_string()
	header := (args[1] or { ruby.string_value('') }).as_string()
	return cask_exception_value(CaskException{ kind: .invalid, token: token, reason: "Token '${header}' in header line does not match the file name." })
}

// Ruby attr_reader `attr_reader :path` at line 199.
pub fn ruby_exceptions_l199_d27_path(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Pathname', cask_exception_from_args(args, .quarantine).path)
}

// Ruby attr_reader `attr_reader :reason` at line 202.
pub fn ruby_exceptions_l202_d28_reason(args ...ruby.Value) ruby.Value {
	return ruby.string_value(cask_exception_from_args(args, .quarantine).reason)
}

// Ruby method `initialize(path, reason)` at line 205.
pub fn ruby_exceptions_l205_d29_initialize(args ...ruby.Value) ruby.Value {
	return cask_exception_value(CaskException{ kind: .quarantine, path: (args[0] or { ruby.string_value('') }).as_string(), reason: (args[1] or { ruby.string_value('') }).as_string() })
}

// Ruby method `to_s` at line 213.
pub fn ruby_exceptions_l213_d30_to_s(args ...ruby.Value) ruby.Value {
	return ruby.string_value(cask_exception_message(cask_exception_from_args(args, .quarantine)))
}

// Ruby method `to_s` at line 229.
pub fn ruby_exceptions_l229_d31_to_s(args ...ruby.Value) ruby.Value {
	return ruby.string_value(cask_exception_message(cask_exception_from_args(args, .quarantine_propagation)))
}

// Ruby method `to_s` at line 245.
pub fn ruby_exceptions_l245_d32_to_s(args ...ruby.Value) ruby.Value {
	return ruby.string_value(cask_exception_message(cask_exception_from_args(args, .quarantine_release)))
}

pub enum CaskExceptionKind {
	multiple
	not_installed
	cannot_install
	conflict
	unavailable
	unreadable
	tap_unavailable
	ambiguity
	already_created
	cyclic
	self_referencing
	unspecified
	invalid
	quarantine
	quarantine_propagation
	quarantine_release
}

pub struct CaskException {
pub:
	kind             CaskExceptionKind
	token            string
	reason           string
	detail           string
	conflicting_cask string
	tap              string
	tap_installed    bool
	loaders          []string
	errors           []string
	path             string
}

pub fn cask_exception_message(exception CaskException) string {
	return match exception.kind {
		.multiple { 'Problems with multiple casks:\n${exception.errors.join('\n')}\n' }
		.not_installed { "Cask '${exception.token}' is not installed." }
		.cannot_install { "Cask '${exception.token}' has been ${exception.detail}" }
		.conflict { "Cask '${exception.token}' conflicts with '${exception.conflicting_cask}'." }
		.unavailable {
			"Cask '${exception.token}' is unavailable${if exception.reason == '' {
				'.'
			} else {
				': ' + exception.reason
			}}"
		}
		.unreadable {
			"Cask '${exception.token}' is unreadable${if exception.reason == '' {
				'.'
			} else {
				': ' + exception.reason
			}}"
		}
		.tap_unavailable {
			mut message := "Cask '${exception.token}' is unavailable."
			if !exception.tap_installed {
				message += '\nThis command requires the tap ${exception.tap}.\nIf you trust this tap, tap it explicitly and then try again:\n  brew tap ${exception.tap}'
			}
			message
		}
		.ambiguity {
			mut casks := exception.loaders.map('${it}/${exception.token}')
			casks.sort()
			list := casks.map('\n       * ${it}').join('')
			example := casks[0] or { exception.token }
			'Cask ${exception.token} exists in multiple taps:${list}\n\nPlease use the fully-qualified name (e.g. ${example}) to refer to a specific Cask.\n'
		}
		.already_created {
			"Cask '${exception.token}' already exists. Run `brew edit --cask ${exception.token}` to edit it."
		}
		.cyclic {
			"Cask '${exception.token}' includes cyclic dependencies on other Casks${if exception.reason == '' {
				'.'
			} else {
				': ' + exception.reason
			}}"
		}
		.self_referencing { "Cask '${exception.token}' depends on itself." }
		.unspecified { 'This command requires a Cask token.' }
		.invalid {
			"Cask '${exception.token}' definition is invalid${if exception.reason == '' {
				'.'
			} else {
				': ' + exception.reason
			}}"
		}
		.quarantine {
			cask_quarantine_message('Failed to quarantine ${exception.path}.', exception.reason)
		}
		.quarantine_propagation {
			cask_quarantine_message('Failed to quarantine one or more files within ${exception.path}.', exception.reason)
		}
		.quarantine_release {
			cask_quarantine_message('Failed to release ${exception.path} from quarantine.', exception.reason)
		}
	}
}

fn cask_quarantine_message(prefix string, reason string) string {
	if reason == '' {
		return prefix
	}
	return "${prefix} Here's the reason:\n${reason}${if reason.ends_with('\n') { '' } else { '\n' }}"
}

fn cask_exception_from_args(args []ruby.Value, default_kind CaskExceptionKind) CaskException {
	value := args[0] or { return CaskException{ kind: default_kind } }
	if value.type_name != 'Hash' {
		return CaskException{ kind: default_kind, token: value.as_string() }
	}
	values := value.map_data.clone()
	return CaskException{
		kind: default_kind
		token: (values['token'] or { ruby.string_value('') }).as_string()
		reason: (values['reason'] or { ruby.string_value('') }).as_string()
		detail: (values['message'] or { ruby.string_value('') }).as_string()
		conflicting_cask: (values['conflicting_cask'] or { ruby.string_value('') }).as_string()
		tap: (values['tap'] or { ruby.string_value('') }).as_string()
		tap_installed: (values['tap_installed'] or { ruby.bool_value(false) }).bool_data
		loaders: (values['loaders'] or { ruby.string_array_value([]) }).as_string_array() or { []string{} }
		errors: (values['errors'] or { ruby.string_array_value([]) }).as_string_array() or { []string{} }
		path: (values['path'] or { ruby.string_value('') }).as_string()
	}
}

fn cask_exception_value(exception CaskException) ruby.Value {
	return ruby.map_value({
		'kind':             ruby.string_value(exception.kind.str())
		'token':            ruby.string_value(exception.token)
		'reason':           ruby.string_value(exception.reason)
		'message':          ruby.string_value(exception.detail)
		'conflicting_cask': ruby.string_value(exception.conflicting_cask)
		'tap':              ruby.string_value(exception.tap)
		'tap_installed':    ruby.bool_value(exception.tap_installed)
		'loaders':          ruby.string_array_value(exception.loaders)
		'errors':           ruby.string_array_value(exception.errors)
		'path':             ruby.string_value(exception.path)
	})
}

fn cask_exception_kind(name string, fallback CaskExceptionKind) CaskExceptionKind {
	return match name {
		'multiple' { .multiple }
		'not_installed' { .not_installed }
		'cannot_install' { .cannot_install }
		'conflict' { .conflict }
		'unavailable' { .unavailable }
		'unreadable' { .unreadable }
		'tap_unavailable' { .tap_unavailable }
		'ambiguity' { .ambiguity }
		'already_created' { .already_created }
		'cyclic' { .cyclic }
		'self_referencing' { .self_referencing }
		'unspecified' { .unspecified }
		'invalid' { .invalid }
		'quarantine' { .quarantine }
		'quarantine_propagation' { .quarantine_propagation }
		'quarantine_release' { .quarantine_release }
		else { fallback }
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Cask
// 5:   # General cask error.
// 6:   class CaskError < RuntimeError; end
// 7:
// 8:   # Cask error containing multiple other errors.
// 9:   class MultipleCaskErrors < CaskError
// 10:     sig { params(errors: T::Array[StandardError]).void }
// 11:     def initialize(errors)
// 12:       super()
// 13:
// 14:       @errors = errors
// 15:     end
// 16:
// 17:     sig { returns(String) }
// 18:     def to_s
// 19:       <<~EOS
// 20:         Problems with multiple casks:
// 21:         #{@errors.join("\n")}
// 22:       EOS
// 23:     end
// 24:   end
// 25:
// 26:   # Abstract cask error containing a cask token.
// 27:   class AbstractCaskErrorWithToken < CaskError
// 28:     sig { returns(String) }
// 29:     attr_reader :token
// 30:
// 31:     sig { returns(String) }
// 32:     attr_reader :reason
// 33:
// 34:     sig { params(token: T.any(String, Symbol, Cask), reason: T.nilable(Object)).void }
// 35:     def initialize(token, reason = nil)
// 36:       super()
// 37:
// 38:       @token = T.let(token.to_s, String)
// 39:       @reason = T.let(reason.to_s, String)
// 40:     end
// 41:   end
// 42:
// 43:   # Error when a cask is not installed.
// 44:   class CaskNotInstalledError < AbstractCaskErrorWithToken
// 45:     sig { returns(String) }
// 46:     def to_s
// 47:       "Cask '#{token}' is not installed."
// 48:     end
// 49:   end
// 50:
// 51:   # Error when a cask cannot be installed.
// 52:   class CaskCannotBeInstalledError < AbstractCaskErrorWithToken
// 53:     sig { returns(String) }
// 54:     attr_reader :message
// 55:
// 56:     sig { params(token: T.any(String, Symbol, Cask), message: String).void }
// 57:     def initialize(token, message)
// 58:       super(token)
// 59:       @message = message
// 60:     end
// 61:
// 62:     sig { returns(String) }
// 63:     def to_s
// 64:       "Cask '#{token}' has been #{message}"
// 65:     end
// 66:   end
// 67:
// 68:   # Error when a cask conflicts with another cask.
// 69:   class CaskConflictError < AbstractCaskErrorWithToken
// 70:     sig { returns(Cask) }
// 71:     attr_reader :conflicting_cask
// 72:
// 73:     sig { params(token: T.any(String, Symbol, Cask), conflicting_cask: Cask).void }
// 74:     def initialize(token, conflicting_cask)
// 75:       super(token)
// 76:       @conflicting_cask = conflicting_cask
// 77:     end
// 78:
// 79:     sig { returns(String) }
// 80:     def to_s
// 81:       "Cask '#{token}' conflicts with '#{conflicting_cask}'."
// 82:     end
// 83:   end
// 84:
// 85:   # Error when a cask is not available.
// 86:   class CaskUnavailableError < AbstractCaskErrorWithToken
// 87:     sig { returns(String) }
// 88:     def to_s
// 89:       "Cask '#{token}' is unavailable#{reason.empty? ? "." : ": #{reason}"}"
// 90:     end
// 91:   end
// 92:
// 93:   # Error when a cask is unreadable.
// 94:   class CaskUnreadableError < CaskUnavailableError
// 95:     sig { returns(String) }
// 96:     def to_s
// 97:       "Cask '#{token}' is unreadable#{reason.empty? ? "." : ": #{reason}"}"
// 98:     end
// 99:   end
// 100:
// 101:   # Error when a cask in a specific tap is not available.
// 102:   class TapCaskUnavailableError < CaskUnavailableError
// 103:     sig { returns(Tap) }
// 104:     attr_reader :tap
// 105:
// 106:     sig { params(tap: Tap, token: String).void }
// 107:     def initialize(tap, token)
// 108:       super("#{tap}/#{token}")
// 109:       @tap = tap
// 110:     end
// 111:
// 112:     sig { returns(String) }
// 113:     def to_s
// 114:       s = super
// 115:       unless tap.installed?
// 116:         s += "\nThis command requires the tap #{tap}."
// 117:         s += "\nIf you trust this tap, tap it explicitly and then try again:\n  brew tap #{tap}"
// 118:       end
// 119:       s
// 120:     end
// 121:   end
// 122:
// 123:   # Error when a cask with the same name is found in multiple taps.
// 124:   class TapCaskAmbiguityError < CaskError
// 125:     sig { returns(String) }
// 126:     attr_reader :token
// 127:
// 128:     sig { returns(T::Array[CaskLoader::FromNameLoader]) }
// 129:     attr_reader :loaders
// 130:
// 131:     sig { params(token: String, loaders: T::Array[CaskLoader::FromNameLoader]).void }
// 132:     def initialize(token, loaders)
// 133:       @token = token
// 134:       @loaders = loaders
// 135:
// 136:       taps = loaders.map(&:tap)
// 137:       casks = taps.map { |tap| "#{tap}/#{token}" }
// 138:       cask_list = casks.sort.map { |f| "\n       * #{f}" }.join
// 139:
// 140:       super <<~EOS
// 141:         Cask #{token} exists in multiple taps:#{cask_list}
// 142:
// 143:         Please use the fully-qualified name (e.g. #{casks.first}) to refer to a specific Cask.
// 144:       EOS
// 145:     end
// 146:   end
// 147:
// 148:   # Error when a cask already exists.
// 149:   class CaskAlreadyCreatedError < AbstractCaskErrorWithToken
// 150:     sig { returns(String) }
// 151:     def to_s
// 152:       %Q(Cask '#{token}' already exists. Run #{Formatter.identifier("brew edit --cask #{token}")} to edit it.)
// 153:     end
// 154:   end
// 155:
// 156:   # Error when there is a cyclic cask dependency.
// 157:   class CaskCyclicDependencyError < AbstractCaskErrorWithToken
// 158:     sig { returns(String) }
// 159:     def to_s
// 160:       "Cask '#{token}' includes cyclic dependencies on other Casks#{reason.empty? ? "." : ": #{reason}"}"
// 161:     end
// 162:   end
// 163:
// 164:   # Error when a cask depends on itself.
// 165:   class CaskSelfReferencingDependencyError < CaskCyclicDependencyError
// 166:     sig { returns(String) }
// 167:     def to_s
// 168:       "Cask '#{token}' depends on itself."
// 169:     end
// 170:   end
// 171:
// 172:   # Error when no cask is specified.
// 173:   class CaskUnspecifiedError < CaskError
// 174:     sig { returns(String) }
// 175:     def to_s
// 176:       "This command requires a Cask token."
// 177:     end
// 178:   end
// 179:
// 180:   # Error when a cask is invalid.
// 181:   class CaskInvalidError < AbstractCaskErrorWithToken
// 182:     sig { returns(String) }
// 183:     def to_s
// 184:       "Cask '#{token}' definition is invalid#{reason.empty? ? "." : ": #{reason}"}"
// 185:     end
// 186:   end
// 187:
// 188:   # Error when a cask token does not match the file name.
// 189:   class CaskTokenMismatchError < CaskInvalidError
// 190:     sig { params(token: T.any(String, Symbol, Cask), header_token: String).void }
// 191:     def initialize(token, header_token)
// 192:       super(token, "Token '#{header_token}' in header line does not match the file name.")
// 193:     end
// 194:   end
// 195:
// 196:   # Error during quarantining of a file.
// 197:   class CaskQuarantineError < CaskError
// 198:     sig { returns(T.any(String, Pathname)) }
// 199:     attr_reader :path
// 200:
// 201:     sig { returns(String) }
// 202:     attr_reader :reason
// 203:
// 204:     sig { params(path: T.any(String, Pathname), reason: String).void }
// 205:     def initialize(path, reason)
// 206:       super()
// 207:
// 208:       @path = path
// 209:       @reason = reason
// 210:     end
// 211:
// 212:     sig { returns(String) }
// 213:     def to_s
// 214:       s = "Failed to quarantine #{path}."
// 215:
// 216:       unless reason.empty?
// 217:         s << " Here's the reason:\n"
// 218:         s << Formatter.error(reason)
// 219:         s << "\n" unless reason.end_with?("\n")
// 220:       end
// 221:
// 222:       s.freeze
// 223:     end
// 224:   end
// 225:
// 226:   # Error while propagating quarantine information to subdirectories.
// 227:   class CaskQuarantinePropagationError < CaskQuarantineError
// 228:     sig { returns(String) }
// 229:     def to_s
// 230:       s = "Failed to quarantine one or more files within #{path}."
// 231:
// 232:       unless reason.empty?
// 233:         s << " Here's the reason:\n"
// 234:         s << Formatter.error(reason)
// 235:         s << "\n" unless reason.end_with?("\n")
// 236:       end
// 237:
// 238:       s.freeze
// 239:     end
// 240:   end
// 241:
// 242:   # Error while removing quarantine information.
// 243:   class CaskQuarantineReleaseError < CaskQuarantineError
// 244:     sig { returns(String) }
// 245:     def to_s
// 246:       s = "Failed to release #{path} from quarantine."
// 247:
// 248:       unless reason.empty?
// 249:         s << " Here's the reason:\n"
// 250:         s << Formatter.error(reason)
// 251:         s << "\n" unless reason.end_with?("\n")
// 252:       end
// 253:
// 254:       s.freeze
// 255:     end
// 256:   end
// 257: end
