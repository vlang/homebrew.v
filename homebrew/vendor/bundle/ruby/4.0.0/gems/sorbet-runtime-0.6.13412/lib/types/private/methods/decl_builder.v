module methods

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/private/methods/decl_builder.rb`.
// The original source is retained below until every stub has a typed V body.
fn declaration_missing() ruby.Value {
	return ruby.object_value('T::Private::Methods::ARG_NOT_PROVIDED', 'ARG_NOT_PROVIDED')
}

fn declaration_nil() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn declaration_is_missing(value ruby.Value) bool {
	return value.type_name == 'T::Private::Methods::ARG_NOT_PROVIDED'
}

@[heap]
pub struct SignatureDeclaration {
pub mut:
	mod                         ruby.Value
	params                      ruby.Value
	returns                     ruby.Value
	bind                        ruby.Value
	mode                        string
	checked                     string
	finalized                   bool
	on_failure                  ruby.Value
	override_allow_incompatible string
	type_parameters             []ruby.Value
	type_parameters_provided    bool
	raw                         bool
}

@[heap]
pub struct DeclarationBuilder {
pub mut:
	decl &SignatureDeclaration
}

pub fn new_declaration_builder(mod ruby.Value, abstract bool,
	override_allow_incompatible string, overridable bool) !&DeclarationBuilder {
	mut builder := &DeclarationBuilder{
		decl: &SignatureDeclaration{
			mod: mod
			params: declaration_missing()
			returns: declaration_missing()
			bind: declaration_missing()
			mode: 'standard'
			on_failure: declaration_missing()
			override_allow_incompatible: 'false'
		}
	}
	if abstract {
		builder.set_abstract()!
	}
	if override_allow_incompatible != '' {
		builder.set_override(override_allow_incompatible)!
	}
	if overridable {
		builder.set_overridable()!
	}
	return builder
}

fn (builder &DeclarationBuilder) check_live() ! {
	if builder.decl.finalized {
		return error("You can't modify a signature declaration after it has been used.")
	}
}

pub fn (mut builder DeclarationBuilder) set_params(params map[string]ruby.Value,
	positional_count int) ! {
	builder.check_live()!
	if !declaration_is_missing(builder.decl.params) {
		return error("You can't call .params twice")
	}
	if positional_count > 0 {
		some_or_only := if params.len > 0 { 'some' } else { 'only' }
		return error("'params' was called with ${some_or_only} positional arguments, but it needs to be called with keyword arguments.\nThe keyword arguments' keys must match the name and order of the method's parameters.\n")
	}
	if params.len == 0 {
		return error("'params' was called without any arguments, but it needs to be called with keyword arguments.\nThe keyword arguments' keys must match the name and order of the method's parameters.\n\nOmit 'params' entirely for methods with no parameters.\n")
	}
	builder.decl.params = ruby.map_value(params)
}

pub fn (mut builder DeclarationBuilder) set_returns(type_value ruby.Value) ! {
	builder.check_live()!
	if builder.decl.returns.type_name == 'T::Private::Types::Void' {
		return error("You can't call .returns after calling .void.")
	}
	if !declaration_is_missing(builder.decl.returns) {
		return error("You can't call .returns multiple times in a signature.")
	}
	builder.decl.returns = type_value
}

pub fn (mut builder DeclarationBuilder) set_void() ! {
	builder.check_live()!
	if !declaration_is_missing(builder.decl.returns) {
		return error("You can't call .void after calling .returns.")
	}
	builder.decl.returns = ruby.object_value('T::Private::Types::Void', 'void')
}

pub fn (mut builder DeclarationBuilder) set_bind(type_value ruby.Value) ! {
	builder.check_live()!
	if !declaration_is_missing(builder.decl.bind) {
		return error("You can't call .bind multiple times in a signature.")
	}
	builder.decl.bind = type_value
}

pub fn (mut builder DeclarationBuilder) set_checked(level string) ! {
	builder.check_live()!
	clean := level.trim_string_left(':')
	if builder.decl.checked != '' {
		return error("You can't call .checked multiple times in a signature.")
	}
	if clean == 'never' && !declaration_is_missing(builder.decl.on_failure) {
		return error("You can't use .checked(:${clean}) with .on_failure because .on_failure will have no effect.")
	}
	if clean !in ['always', 'tests', 'never'] {
		return error("Invalid `checked` level '${clean}'. Use one of: ['always', 'tests', 'never'].")
	}
	builder.decl.checked = clean
}

pub fn (mut builder DeclarationBuilder) set_on_failure(arguments []ruby.Value,
	default_checked_level string) ! {
	builder.check_live()!
	if !declaration_is_missing(builder.decl.on_failure) {
		return error("You can't call .on_failure multiple times in a signature.")
	}
	effective := if builder.decl.checked == '' {
		default_checked_level
	} else {
		builder.decl.checked
	}
	if effective == 'never' {
		if builder.decl.checked == '' {
			return error('To use .on_failure you must additionally call .checked(:tests) or .checked(:always), otherwise, the .on_failure has no effect.')
		}
		return error("You can't use .on_failure with .checked(:${effective}) because .on_failure will have no effect.")
	}
	builder.decl.on_failure = ruby.array_value(arguments)
}

pub fn (mut builder DeclarationBuilder) set_abstract() ! {
	builder.check_live()!
	match builder.decl.mode {
		'standard' {
			builder.decl.mode = 'abstract'
		}
		'abstract' {
			return error('.abstract cannot be repeated in a single signature')
		}
		else {
			return error('`.abstract` cannot be combined with `.override` or `.overridable`.')
		}
	}
}

pub fn (mut builder DeclarationBuilder) set_override(allow_incompatible string) ! {
	builder.check_live()!
	match builder.decl.mode {
		'standard' {
			if allow_incompatible !in ['true', 'false', 'visibility'] {
				return error('.override(allow_incompatible: ...) only accepts `true`, `false`, or `:visibility`, got: ${allow_incompatible}')
			}
			builder.decl.mode = 'override'
			builder.decl.override_allow_incompatible = allow_incompatible
		}
		'override', 'overridable_override' {
			return error('.override cannot be repeated in a single signature')
		}
		'overridable' {
			builder.decl.mode = 'overridable_override'
		}
		else {
			return error('`.override` cannot be combined with `.abstract`.')
		}
	}
}

pub fn (mut builder DeclarationBuilder) set_overridable() ! {
	builder.check_live()!
	match builder.decl.mode {
		'abstract' {
			return error('`.overridable` cannot be combined with `.abstract`')
		}
		'override' {
			builder.decl.mode = 'overridable_override'
		}
		'standard' {
			builder.decl.mode = 'overridable'
		}
		'overridable', 'overridable_override' {
			return error('.overridable cannot be repeated in a single signature')
		}
		else {}
	}
}

pub fn (mut builder DeclarationBuilder) set_type_parameters(names []ruby.Value) ! {
	builder.check_live()!
	for name in names {
		if name.type_name != 'Symbol' {
			return error('not a symbol: ${name.as_string()}')
		}
	}
	if builder.decl.type_parameters_provided {
		return error("You can't call .type_parameters multiple times in a signature.")
	}
	builder.decl.type_parameters = names.clone()
	builder.decl.type_parameters_provided = true
}

pub fn (mut builder DeclarationBuilder) finalize() ! {
	builder.check_live()!
	if declaration_is_missing(builder.decl.returns) {
		return error('You must provide a return type; use the `.returns` or `.void` builder methods.')
	}
	if declaration_is_missing(builder.decl.bind) {
		builder.decl.bind = declaration_nil()
	}
	if declaration_is_missing(builder.decl.on_failure) {
		builder.decl.on_failure = declaration_nil()
	}
	if declaration_is_missing(builder.decl.params) {
		builder.decl.params = ruby.map_value({})
	}
	if !builder.decl.type_parameters_provided {
		builder.decl.type_parameters = []
		builder.decl.type_parameters_provided = true
	}
	builder.decl.finalized = true
}

fn declaration_value(decl &SignatureDeclaration) ruby.Value {
	return ruby.Value{
		type_name: 'T::Private::Methods::Declaration'
		repr: '#<T::Private::Methods::Declaration>'
		map_data: {
			'mod':        decl.mod
			'params':     decl.params
			'returns':    decl.returns
			'bind':       decl.bind
			'on_failure': decl.on_failure
		}
		attributes: {
			'declaration_address':         u64(voidptr(decl)).str()
			'mode':                        decl.mode
			'checked':                     decl.checked
			'finalized':                   decl.finalized.str()
			'override_allow_incompatible': decl.override_allow_incompatible
			'raw':                         decl.raw.str()
		}
		array_data: decl.type_parameters.clone()
	}
}

fn declaration_from_value(value ruby.Value) &SignatureDeclaration {
	address := value.attribute('declaration_address') or { panic('invalid Declaration value') }
	return unsafe { &SignatureDeclaration(voidptr(address.u64())) }
}

fn declaration_builder_value(builder &DeclarationBuilder) ruby.Value {
	return ruby.structured_value('T::Private::Methods::DeclBuilder', '#<T::Private::Methods::DeclBuilder>', {
		'declaration_builder_address': u64(voidptr(builder)).str()
	})
}

fn declaration_builder_from_args(args []ruby.Value) &DeclarationBuilder {
	if args.len == 0 {
		panic('DeclBuilder method requires a receiver')
	}
	address := args[0].attribute('declaration_builder_address') or { panic('invalid DeclBuilder receiver') }
	return unsafe { &DeclarationBuilder(voidptr(address.u64())) }
}

// Ruby attr_reader `attr_reader :decl` at line 8.
pub fn ruby_decl_builder_l8_d1_decl(args ...ruby.Value) ruby.Value {
	return declaration_value(declaration_builder_from_args(args).decl)
}

// Ruby method `check_live!` at line 12.
pub fn ruby_decl_builder_l12_d2_check_live(args ...ruby.Value) ruby.Value {
	declaration_builder_from_args(args).check_live() or { panic(err) }
	return declaration_nil()
}

// Ruby method `initialize(mod, abstract, override, overridable)` at line 18.
pub fn ruby_decl_builder_l18_d3_initialize(args ...ruby.Value) ruby.Value {
	if args.len < 4 {
		panic('DeclBuilder.initialize requires mod, abstract, override, and overridable')
	}
	abstract := args[1].as_bool() or { false }
	override_value := if args[2].type_name == 'NilClass' || (args[2].type_name == 'Bool' && !(args[2].as_bool() or { false })) {
		''
	} else {
		args[2].attribute('allow_incompatible') or { args[2].as_string().trim_string_left(':') }
	}
	overridable := args[3].as_bool() or { false }
	return declaration_builder_value(new_declaration_builder(args[0], abstract, override_value, overridable) or { panic(err) })
}

// Ruby method `params(*unused_positional_params, **params)` at line 48.
pub fn ruby_decl_builder_l48_d4_params(args ...ruby.Value) ruby.Value {
	mut builder := declaration_builder_from_args(args)
	has_keyword_hash := args.len > 1 && args[args.len - 1].type_name == 'Hash'
	params := if has_keyword_hash {
		args[args.len - 1].as_map() or { panic(err) }
	} else {
		map[string]ruby.Value{}
	}
	positional_count := if has_keyword_hash { args.len - 2 } else { args.len - 1 }
	builder.set_params(params, positional_count) or { panic(err) }
	return args[0]
}

// Ruby method `returns(type)` at line 76.
pub fn ruby_decl_builder_l76_d5_returns(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('DeclBuilder#returns requires a type') }
	mut builder := declaration_builder_from_args(args)
	builder.set_returns(args[1]) or { panic(err) }
	return args[0]
}

// Ruby method `void` at line 90.
pub fn ruby_decl_builder_l90_d6_void(args ...ruby.Value) ruby.Value {
	mut builder := declaration_builder_from_args(args)
	builder.set_void() or { panic(err) }
	return args[0]
}

// Ruby method `bind(type)` at line 101.
pub fn ruby_decl_builder_l101_d7_bind(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('DeclBuilder#bind requires a type') }
	mut builder := declaration_builder_from_args(args)
	builder.set_bind(args[1]) or { panic(err) }
	return args[0]
}

// Ruby method `checked(level)` at line 112.
pub fn ruby_decl_builder_l112_d8_checked(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('DeclBuilder#checked requires a level') }
	mut builder := declaration_builder_from_args(args)
	builder.set_checked(args[1].as_string()) or { panic(err) }
	return args[0]
}

// Ruby method `on_failure(*args)` at line 130.
pub fn ruby_decl_builder_l130_d9_on_failure(args ...ruby.Value) ruby.Value {
	mut builder := declaration_builder_from_args(args)
	builder.set_on_failure(args[1..], 'always') or { panic(err) }
	return args[0]
}

// Ruby method `abstract` at line 150.
pub fn ruby_decl_builder_l150_d10_abstract(args ...ruby.Value) ruby.Value {
	mut builder := declaration_builder_from_args(args)
	builder.set_abstract() or { panic(err) }
	return args[0]
}

// Ruby method `final` at line 165.
pub fn ruby_decl_builder_l165_d11_final(args ...ruby.Value) ruby.Value {
	declaration_builder_from_args(args).check_live() or { panic(err) }
	panic('The syntax for declaring a method final is `sig(:final) {...}`, not `sig {final. ...}`')
}

// Ruby method `override(allow_incompatible: false)` at line 170.
pub fn ruby_decl_builder_l170_d12_override(args ...ruby.Value) ruby.Value {
	mut builder := declaration_builder_from_args(args)
	allow := if args.len > 1 { args[1].as_string().trim_string_left(':') } else { 'false' }
	builder.set_override(allow) or { panic(err) }
	return args[0]
}

// Ruby method `overridable` at line 193.
pub fn ruby_decl_builder_l193_d13_overridable(args ...ruby.Value) ruby.Value {
	mut builder := declaration_builder_from_args(args)
	builder.set_overridable() or { panic(err) }
	return args[0]
}

// Ruby method `type_parameters(*names)` at line 221.
pub fn ruby_decl_builder_l221_d14_type_parameters(args ...ruby.Value) ruby.Value {
	mut builder := declaration_builder_from_args(args)
	builder.set_type_parameters(args[1..]) or { panic(err) }
	return args[0]
}

// Ruby method `finalize!` at line 237.
pub fn ruby_decl_builder_l237_d15_finalize(args ...ruby.Value) ruby.Value {
	mut builder := declaration_builder_from_args(args)
	builder.finalize() or { panic(err) }
	return args[0]
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Private::Methods
// 5:   Declaration = Struct.new(:mod, :params, :returns, :bind, :mode, :checked, :finalized, :on_failure, :override_allow_incompatible, :type_parameters, :raw)
// 6:
// 7:   class DeclBuilder
// 8:     attr_reader :decl
// 9:
// 10:     class BuilderError < StandardError; end
// 11:
// 12:     private def check_live!
// 13:       if decl.finalized
// 14:         raise BuilderError.new("You can't modify a signature declaration after it has been used.")
// 15:       end
// 16:     end
// 17:
// 18:     def initialize(mod, abstract, override, overridable)
// 19:       @decl = Declaration.new(
// 20:         mod,
// 21:         ARG_NOT_PROVIDED, # params
// 22:         ARG_NOT_PROVIDED, # returns
// 23:         ARG_NOT_PROVIDED, # bind
// 24:         Modes.standard, # mode
// 25:         nil, # checked
// 26:         false, # finalized
// 27:         ARG_NOT_PROVIDED, # on_failure
// 28:         false, # override_allow_incompatible
// 29:         ARG_NOT_PROVIDED, # type_parameters
// 30:       )
// 31:
// 32:       # Call the methods after the fact (instead of setting them in the constructor)
// 33:       # so we get the BuilderError's, if applicable
// 34:
// 35:       if abstract
// 36:         self.abstract
// 37:       end
// 38:
// 39:       if override
// 40:         self.override(**override)
// 41:       end
// 42:
// 43:       if overridable
// 44:         self.overridable
// 45:       end
// 46:     end
// 47:
// 48:     def params(*unused_positional_params, **params)
// 49:       check_live!
// 50:       if !decl.params.equal?(ARG_NOT_PROVIDED)
// 51:         raise BuilderError.new("You can't call .params twice")
// 52:       end
// 53:
// 54:       if unused_positional_params.any?
// 55:         some_or_only = params.any? ? "some" : "only"
// 56:         raise BuilderError.new(<<~MSG)
// 57:           'params' was called with #{some_or_only} positional arguments, but it needs to be called with keyword arguments.
// 58:           The keyword arguments' keys must match the name and order of the method's parameters.
// 59:         MSG
// 60:       end
// 61:
// 62:       if params.empty?
// 63:         raise BuilderError.new(<<~MSG)
// 64:           'params' was called without any arguments, but it needs to be called with keyword arguments.
// 65:           The keyword arguments' keys must match the name and order of the method's parameters.
// 66:
// 67:           Omit 'params' entirely for methods with no parameters.
// 68:         MSG
// 69:       end
// 70:
// 71:       decl.params = params
// 72:
// 73:       self
// 74:     end
// 75:
// 76:     def returns(type)
// 77:       check_live!
// 78:       if decl.returns.is_a?(T::Private::Types::Void)
// 79:         raise BuilderError.new("You can't call .returns after calling .void.")
// 80:       end
// 81:       if !decl.returns.equal?(ARG_NOT_PROVIDED)
// 82:         raise BuilderError.new("You can't call .returns multiple times in a signature.")
// 83:       end
// 84:
// 85:       decl.returns = type
// 86:
// 87:       self
// 88:     end
// 89:
// 90:     def void
// 91:       check_live!
// 92:       if !decl.returns.equal?(ARG_NOT_PROVIDED)
// 93:         raise BuilderError.new("You can't call .void after calling .returns.")
// 94:       end
// 95:
// 96:       decl.returns = T::Private::Types::Void::Private::INSTANCE
// 97:
// 98:       self
// 99:     end
// 100:
// 101:     def bind(type)
// 102:       check_live!
// 103:       if !decl.bind.equal?(ARG_NOT_PROVIDED)
// 104:         raise BuilderError.new("You can't call .bind multiple times in a signature.")
// 105:       end
// 106:
// 107:       decl.bind = type
// 108:
// 109:       self
// 110:     end
// 111:
// 112:     def checked(level)
// 113:       check_live!
// 114:
// 115:       if !decl.checked.nil?
// 116:         raise BuilderError.new("You can't call .checked multiple times in a signature.")
// 117:       end
// 118:       if :never == level && !decl.on_failure.equal?(ARG_NOT_PROVIDED)
// 119:         raise BuilderError.new("You can't use .checked(:#{level}) with .on_failure because .on_failure will have no effect.")
// 120:       end
// 121:       if !T::Private::RuntimeLevels::LEVELS.include?(level)
// 122:         raise BuilderError.new("Invalid `checked` level '#{level}'. Use one of: #{T::Private::RuntimeLevels::LEVELS}.")
// 123:       end
// 124:
// 125:       decl.checked = level
// 126:
// 127:       self
// 128:     end
// 129:
// 130:     def on_failure(*args)
// 131:       check_live!
// 132:
// 133:       if !decl.on_failure.equal?(ARG_NOT_PROVIDED)
// 134:         raise BuilderError.new("You can't call .on_failure multiple times in a signature.")
// 135:       end
// 136:       effective_checked = decl.checked.nil? ? T::Private::RuntimeLevels.default_checked_level : decl.checked
// 137:       if effective_checked == :never
// 138:         if decl.checked.nil?
// 139:           raise BuilderError.new("To use .on_failure you must additionally call .checked(:tests) or .checked(:always), otherwise, the .on_failure has no effect.")
// 140:         else
// 141:           raise BuilderError.new("You can't use .on_failure with .checked(:#{effective_checked}) because .on_failure will have no effect.")
// 142:         end
// 143:       end
// 144:
// 145:       decl.on_failure = args
// 146:
// 147:       self
// 148:     end
// 149:
// 150:     def abstract
// 151:       check_live!
// 152:
// 153:       case decl.mode
// 154:       when Modes.standard
// 155:         decl.mode = Modes.abstract
// 156:       when Modes.abstract
// 157:         raise BuilderError.new(".abstract cannot be repeated in a single signature")
// 158:       else
// 159:         raise BuilderError.new("`.abstract` cannot be combined with `.override` or `.overridable`.")
// 160:       end
// 161:
// 162:       self
// 163:     end
// 164:
// 165:     def final
// 166:       check_live!
// 167:       raise BuilderError.new("The syntax for declaring a method final is `sig(:final) {...}`, not `sig {final. ...}`")
// 168:     end
// 169:
// 170:     def override(allow_incompatible: false)
// 171:       check_live!
// 172:
// 173:       case decl.mode
// 174:       when Modes.standard
// 175:         decl.mode = Modes.override
// 176:         case allow_incompatible
// 177:         when true, false, :visibility
// 178:           decl.override_allow_incompatible = allow_incompatible
// 179:         else
// 180:           raise BuilderError.new(".override(allow_incompatible: ...) only accepts `true`, `false`, or `:visibility`, got: #{allow_incompatible.inspect}")
// 181:         end
// 182:       when Modes.override, Modes.overridable_override
// 183:         raise BuilderError.new(".override cannot be repeated in a single signature")
// 184:       when Modes.overridable
// 185:         decl.mode = Modes.overridable_override
// 186:       else
// 187:         raise BuilderError.new("`.override` cannot be combined with `.abstract`.")
// 188:       end
// 189:
// 190:       self
// 191:     end
// 192:
// 193:     def overridable
// 194:       check_live!
// 195:
// 196:       case decl.mode
// 197:       when Modes.abstract
// 198:         raise BuilderError.new("`.overridable` cannot be combined with `.#{decl.mode}`")
// 199:       when Modes.override
// 200:         decl.mode = Modes.overridable_override
// 201:       when Modes.standard
// 202:         decl.mode = Modes.overridable
// 203:       when Modes.overridable, Modes.overridable_override
// 204:         raise BuilderError.new(".overridable cannot be repeated in a single signature")
// 205:       end
// 206:
// 207:       self
// 208:     end
// 209:
// 210:     # Declares valid type parameters which can be used with `T.type_parameter` in
// 211:     # this `sig`.
// 212:     #
// 213:     # This is used for generic methods. Example usage:
// 214:     #
// 215:     #  sig do
// 216:     #    type_parameters(:U)
// 217:     #    .params(blk: T.proc.params(arg0: Elem).returns(T.type_parameter(:U)))
// 218:     #    .returns(T::Array[T.type_parameter(:U)])
// 219:     #  end
// 220:     #  def map(&blk); end
// 221:     def type_parameters(*names)
// 222:       check_live!
// 223:
// 224:       names.each do |name|
// 225:         raise BuilderError.new("not a symbol: #{name}") unless Symbol === name
// 226:       end
// 227:
// 228:       if !decl.type_parameters.equal?(ARG_NOT_PROVIDED)
// 229:         raise BuilderError.new("You can't call .type_parameters multiple times in a signature.")
// 230:       end
// 231:
// 232:       decl.type_parameters = names
// 233:
// 234:       self
// 235:     end
// 236:
// 237:     def finalize!
// 238:       check_live!
// 239:
// 240:       if decl.returns.equal?(ARG_NOT_PROVIDED)
// 241:         raise BuilderError.new("You must provide a return type; use the `.returns` or `.void` builder methods.")
// 242:       end
// 243:
// 244:       if decl.bind.equal?(ARG_NOT_PROVIDED)
// 245:         decl.bind = nil
// 246:       end
// 247:       if decl.on_failure.equal?(ARG_NOT_PROVIDED)
// 248:         decl.on_failure = nil
// 249:       end
// 250:       if decl.params.equal?(ARG_NOT_PROVIDED)
// 251:         decl.params = FROZEN_HASH
// 252:       end
// 253:       if decl.type_parameters.equal?(ARG_NOT_PROVIDED)
// 254:         decl.type_parameters = FROZEN_ARRAY
// 255:       end
// 256:
// 257:       decl.finalized = true
// 258:
// 259:       self
// 260:     end
// 261:
// 262:     FROZEN_HASH = {}.freeze
// 263:     FROZEN_ARRAY = [].freeze
// 264:   end
// 265: end
