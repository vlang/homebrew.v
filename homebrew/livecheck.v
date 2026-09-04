module homebrew

import ruby
import homebrew.livecheck as livecheck_options

// Translated from Homebrew/brew `livecheck.rb`.
// The original source is retained below until every stub has a typed V body.
const livecheck_url_option_keys = ['compressed', 'cookies', 'header', 'homebrew_curl', 'post_form',
	'post_json', 'referer', 'user_agent']

pub struct LivecheckDSL {
pub mut:
	package_or_resource ruby.Value
	options             livecheck_options.LivecheckOptions
	referenced_cask     ruby.Value
	referenced_formula  ruby.Value
	regex               ruby.Value
	skip                bool
	skip_msg            ruby.Value
	strategy            ruby.Value
	strategy_block      ruby.Value
	throttle            ruby.Value
	throttle_days       ruby.Value
	url                 ruby.Value
}

fn livecheck_nil() ruby.Value {
	return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
}

pub fn new_livecheck_dsl(package_or_resource ruby.Value) LivecheckDSL {
	return LivecheckDSL{
		package_or_resource: package_or_resource
		options: livecheck_options.new_livecheck_options({})
		referenced_cask: livecheck_nil()
		referenced_formula: livecheck_nil()
		regex: livecheck_nil()
		skip_msg: livecheck_nil()
		strategy: livecheck_nil()
		strategy_block: livecheck_nil()
		throttle: livecheck_nil()
		throttle_days: livecheck_nil()
		url: livecheck_nil()
	}
}

pub fn livecheck_dsl_value(livecheck LivecheckDSL) ruby.Value {
	return ruby.Value{
		type_name: 'Livecheck'
		repr: 'Livecheck'
		map_data: {
			'package_or_resource': livecheck.package_or_resource
			'options':             livecheck_options.livecheck_options_value(livecheck.options)
			'cask':                livecheck.referenced_cask
			'formula':             livecheck.referenced_formula
			'regex':               livecheck.regex
			'skip':                ruby.bool_value(livecheck.skip)
			'skip_msg':            livecheck.skip_msg
			'strategy':            livecheck.strategy
			'strategy_block':      livecheck.strategy_block
			'throttle':            livecheck.throttle
			'throttle_days':       livecheck.throttle_days
			'url':                 livecheck.url
		}
	}
}

pub fn livecheck_dsl_from_value(value ruby.Value) !LivecheckDSL {
	if value.type_name != 'Livecheck' {
		return error('expected Livecheck, got ${value.type_name}')
	}
	return LivecheckDSL{
		package_or_resource: value.map_data['package_or_resource'] or { livecheck_nil() }
		options: livecheck_options.livecheck_options_from_value(value.map_data['options'] or { livecheck_options.livecheck_options_value(livecheck_options.new_livecheck_options({})) })!
		referenced_cask: value.map_data['cask'] or { livecheck_nil() }
		referenced_formula: value.map_data['formula'] or { livecheck_nil() }
		regex: value.map_data['regex'] or { livecheck_nil() }
		skip: (value.map_data['skip'] or { ruby.bool_value(false) }).as_bool() or { false }
		skip_msg: value.map_data['skip_msg'] or { livecheck_nil() }
		strategy: value.map_data['strategy'] or { livecheck_nil() }
		strategy_block: value.map_data['strategy_block'] or { livecheck_nil() }
		throttle: value.map_data['throttle'] or { livecheck_nil() }
		throttle_days: value.map_data['throttle_days'] or { livecheck_nil() }
		url: value.map_data['url'] or { livecheck_nil() }
	}
}

fn livecheck_receiver(args []ruby.Value, method string) ?LivecheckDSL {
	if args.len == 0 {
		_ = method
		return none
	}
	return livecheck_dsl_from_value(args[0]) or { return none }
}

fn livecheck_keywords(args []ruby.Value) map[string]ruby.Value {
	for index := args.len - 1; index >= 1; index-- {
		if args[index].type_name == 'Hash' {
			return args[index].map_data.clone()
		}
	}
	return map[string]ruby.Value{}
}

fn livecheck_argument_error(method string) ruby.Value {
	return ruby.object_value('ArgumentError', '${method} requires a Livecheck receiver')
}

// Ruby attr_reader `attr_reader :options` at line 21.
pub fn ruby_livecheck_l21_d1_options(args ...ruby.Value) ruby.Value {
	livecheck := livecheck_receiver(args, 'options') or { return livecheck_argument_error('options') }
	return livecheck_options.livecheck_options_value(livecheck.options)
}

// Ruby attr_reader `attr_reader :skip_msg` at line 26.
pub fn ruby_livecheck_l26_d2_skip_msg(args ...ruby.Value) ruby.Value {
	livecheck := livecheck_receiver(args, 'skip_msg') or { return livecheck_argument_error('skip_msg') }
	return livecheck.skip_msg
}

// Ruby attr_reader `attr_reader :strategy_block` at line 30.
pub fn ruby_livecheck_l30_d3_strategy_block(args ...ruby.Value) ruby.Value {
	livecheck := livecheck_receiver(args, 'strategy_block') or { return livecheck_argument_error('strategy_block') }
	return livecheck.strategy_block
}

// Ruby attr_reader `attr_reader :throttle_days` at line 35.
pub fn ruby_livecheck_l35_d4_throttle_days(args ...ruby.Value) ruby.Value {
	livecheck := livecheck_receiver(args, 'throttle_days') or { return livecheck_argument_error('throttle_days') }
	return livecheck.throttle_days
}

// Ruby method `initialize(package_or_resource)` at line 38.
pub fn ruby_livecheck_l38_d5_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'Livecheck#initialize requires a package or resource')
	}
	return livecheck_dsl_value(new_livecheck_dsl(args[0]))
}

// Ruby method `cask(cask_name = T.unsafe(nil))` at line 63.
pub fn ruby_livecheck_l63_d6_cask(args ...ruby.Value) ruby.Value {
	mut livecheck := livecheck_receiver(args, 'cask') or { return livecheck_argument_error('cask') }
	if args.len == 1 || args[1].type_name == 'NilClass' {
		return livecheck.referenced_cask
	}
	if args[1].type_name == 'String' {
		livecheck.referenced_cask = args[1]
	}
	return livecheck_dsl_value(livecheck)
}

// Ruby method `formula(formula_name = T.unsafe(nil))` at line 82.
pub fn ruby_livecheck_l82_d7_formula(args ...ruby.Value) ruby.Value {
	mut livecheck := livecheck_receiver(args, 'formula') or { return livecheck_argument_error('formula') }
	if args.len == 1 || args[1].type_name == 'NilClass' {
		return livecheck.referenced_formula
	}
	if args[1].type_name == 'String' || (args[1].type_name == 'Symbol' && args[1].as_string().trim_left(':') == 'parent') {
		livecheck.referenced_formula = args[1]
	}
	return livecheck_dsl_value(livecheck)
}

// Ruby method `regex(pattern = T.unsafe(nil))` at line 99.
pub fn ruby_livecheck_l99_d8_regex(args ...ruby.Value) ruby.Value {
	mut livecheck := livecheck_receiver(args, 'regex') or { return livecheck_argument_error('regex') }
	if args.len == 1 || args[1].type_name == 'NilClass' {
		return livecheck.regex
	}
	if args[1].type_name == 'Regexp' {
		livecheck.regex = args[1]
	}
	return livecheck_dsl_value(livecheck)
}

// Ruby method `skip(skip_msg = T.unsafe(nil))` at line 119.
pub fn ruby_livecheck_l119_d9_skip(args ...ruby.Value) ruby.Value {
	mut livecheck := livecheck_receiver(args, 'skip') or { return livecheck_argument_error('skip') }
	if args.len > 1 && args[1].type_name == 'String' {
		livecheck.skip_msg = args[1]
	}
	livecheck.skip = true
	return livecheck_dsl_value(livecheck)
}

// Ruby method `skip?` at line 127.
pub fn ruby_livecheck_l127_d10_skip(args ...ruby.Value) ruby.Value {
	livecheck := livecheck_receiver(args, 'skip?') or { return livecheck_argument_error('skip?') }
	return ruby.bool_value(livecheck.skip)
}

// Ruby method `strategy(symbol = T.unsafe(nil), &block)` at line 142.
pub fn ruby_livecheck_l142_d11_strategy(args ...ruby.Value) ruby.Value {
	mut livecheck := livecheck_receiver(args, 'strategy') or { return livecheck_argument_error('strategy') }
	if args.len > 2 && args[2].type_name == 'Proc' {
		livecheck.strategy_block = args[2]
	}
	if args.len == 1 || args[1].type_name == 'NilClass' {
		return livecheck.strategy
	}
	if args[1].type_name == 'Symbol' {
		livecheck.strategy = args[1]
	}
	return livecheck_dsl_value(livecheck)
}

// Ruby method `throttle(rate = T.unsafe(nil), days: nil)` at line 168.
pub fn ruby_livecheck_l168_d12_throttle(args ...ruby.Value) ruby.Value {
	mut livecheck := livecheck_receiver(args, 'throttle') or { return livecheck_argument_error('throttle') }
	keywords := livecheck_keywords(args)
	if days := keywords['days'] {
		if days.type_name != 'NilClass' {
			livecheck.throttle_days = days
		}
	}
	if args.len == 1 || args[1].type_name == 'NilClass' || args[1].type_name == 'Hash' {
		return if livecheck.throttle.type_name == 'NilClass' && keywords.len > 0 {
			livecheck_dsl_value(livecheck)
		} else {
			livecheck.throttle
		}
	}
	if args[1].type_name == 'Integer' {
		livecheck.throttle = args[1]
	}
	return livecheck_dsl_value(livecheck)
}

// Ruby method `url(` at line 199.
pub fn ruby_livecheck_l199_d13_url(args ...ruby.Value) ruby.Value {
	mut livecheck := livecheck_receiver(args, 'url') or { return livecheck_argument_error('url') }
	keywords := livecheck_keywords(args)
	if compressed := keywords['compressed'] {
		if compressed.type_name == 'Bool' && compressed.bool_data {
			return ruby.object_value('ArgumentError', '`compressed` option should only be `false` or omitted')
		}
	}
	if homebrew_curl := keywords['homebrew_curl'] {
		if homebrew_curl.type_name == 'Bool' && !homebrew_curl.bool_data {
			return ruby.object_value('ArgumentError', '`homebrew_curl` option should only be `true` or omitted')
		}
	}
	if post_form := keywords['post_form'] {
		if post_form.type_name != 'NilClass' {
			if post_json := keywords['post_json'] {
				if post_json.type_name != 'NilClass' {
					return ruby.object_value('ArgumentError', 'Only use `post_form` or `post_json`, not both')
				}
			}
		}
	}
	for key in livecheck_url_option_keys {
		if value := keywords[key] {
			if value.type_name != 'NilClass' {
				livecheck.options.values[key] = value
			}
		}
	}
	if args.len == 1 || args[1].type_name == 'NilClass' || args[1].type_name == 'Hash' {
		return if keywords.len > 0 { livecheck_dsl_value(livecheck) } else { livecheck.url }
	}
	url := args[1]
	if url.type_name == 'String' {
		livecheck.url = url
	} else if url.type_name == 'Symbol' {
		shorthand := url.as_string().trim_left(':')
		if shorthand !in ['head', 'homepage', 'stable', 'url'] {
			return ruby.object_value('ArgumentError', '${url.repr} is not a valid URL shorthand')
		}
		livecheck.url = url
	}
	return livecheck_dsl_value(livecheck)
}

// Ruby delegate `delegate url_options: :@options` at line 233.
pub fn ruby_livecheck_l233_d14_url_options(args ...ruby.Value) ruby.Value {
	livecheck := livecheck_receiver(args, 'url_options') or { return livecheck_argument_error('url_options') }
	return ruby.map_value(livecheck.options.url_options())
}

// Ruby delegate `delegate arch: :@package_or_resource` at line 234.
pub fn ruby_livecheck_l234_d15_arch(args ...ruby.Value) ruby.Value {
	livecheck := livecheck_receiver(args, 'arch') or { return livecheck_argument_error('arch') }
	return livecheck.package_or_resource.map_data['arch'] or { livecheck_nil() }
}

// Ruby delegate `delegate os: :@package_or_resource` at line 235.
pub fn ruby_livecheck_l235_d16_os(args ...ruby.Value) ruby.Value {
	livecheck := livecheck_receiver(args, 'os') or { return livecheck_argument_error('os') }
	return livecheck.package_or_resource.map_data['os'] or { livecheck_nil() }
}

// Ruby delegate `delegate version: :@package_or_resource` at line 236.
pub fn ruby_livecheck_l236_d17_version(args ...ruby.Value) ruby.Value {
	livecheck := livecheck_receiver(args, 'version') or { return livecheck_argument_error('version') }
	return livecheck.package_or_resource.map_data['version'] or { livecheck_nil() }
}

// Ruby method `to_hash` at line 241.
pub fn ruby_livecheck_l241_d18_to_hash(args ...ruby.Value) ruby.Value {
	livecheck := livecheck_receiver(args, 'to_hash') or { return livecheck_argument_error('to_hash') }
	return ruby.map_value({
		'options':       ruby.map_value(livecheck.options.values)
		'cask':          livecheck.referenced_cask
		'formula':       livecheck.referenced_formula
		'regex':         livecheck.regex
		'skip':          ruby.bool_value(livecheck.skip)
		'skip_msg':      livecheck.skip_msg
		'strategy':      livecheck.strategy
		'throttle':      livecheck.throttle
		'throttle_days': livecheck.throttle_days
		'url':           livecheck.url
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "livecheck/constants"
// 5: require "livecheck/options"
// 6: require "cask/cask"
// 7:
// 8: # The {Livecheck} class implements the DSL methods used in a formula's, cask's
// 9: # or resource's `livecheck` block and stores related instance variables. Most
// 10: # of these methods also return the related instance variable when no argument
// 11: # is provided.
// 12: #
// 13: # This information is used by the `brew livecheck` command to control its
// 14: # behavior. Example `livecheck` blocks can be found in the
// 15: # [`brew livecheck` documentation](https://docs.brew.sh/Brew-Livecheck).
// 16: class Livecheck
// 17:   extend Forwardable
// 18:
// 19:   # Options to modify livecheck's behavior.
// 20:   sig { returns(Homebrew::Livecheck::Options) }
// 21:   attr_reader :options
// 22:
// 23:   # A very brief description of why the formula/cask/resource is skipped (e.g.
// 24:   # `No longer developed or maintained`).
// 25:   sig { returns(T.nilable(String)) }
// 26:   attr_reader :skip_msg
// 27:
// 28:   # A block used by strategies to identify version information.
// 29:   sig { returns(T.nilable(Proc)) }
// 30:   attr_reader :strategy_block
// 31:
// 32:   # The number of days from the last version update before a new version can be
// 33:   # surfaced.
// 34:   sig { returns(T.nilable(Integer)) }
// 35:   attr_reader :throttle_days
// 36:
// 37:   sig { params(package_or_resource: T.any(Cask::Cask, T.class_of(Formula), Resource)).void }
// 38:   def initialize(package_or_resource)
// 39:     @package_or_resource = package_or_resource
// 40:     @options = T.let(Homebrew::Livecheck::Options.new, Homebrew::Livecheck::Options)
// 41:     @referenced_cask_name = T.let(nil, T.nilable(String))
// 42:     @referenced_formula_name = T.let(nil, T.nilable(String))
// 43:     @regex = T.let(nil, T.nilable(Regexp))
// 44:     @skip = T.let(false, T::Boolean)
// 45:     @skip_msg = T.let(nil, T.nilable(String))
// 46:     @strategy = T.let(nil, T.nilable(Symbol))
// 47:     @strategy_block = T.let(nil, T.nilable(Proc))
// 48:     @throttle = T.let(nil, T.nilable(Integer))
// 49:     @throttle_days = T.let(nil, T.nilable(Integer))
// 50:     @url = T.let(nil, T.nilable(T.any(String, Symbol)))
// 51:   end
// 52:
// 53:   # Sets the `@referenced_cask_name` instance variable to the provided `String`
// 54:   # or returns the `@referenced_cask_name` instance variable when no argument
// 55:   # is provided. Inherited livecheck values from the referenced cask
// 56:   # (e.g. regex) can be overridden in the `livecheck` block.
// 57:   sig {
// 58:     params(
// 59:       # Name of cask to inherit livecheck info from.
// 60:       cask_name: String,
// 61:     ).returns(T.nilable(String))
// 62:   }
// 63:   def cask(cask_name = T.unsafe(nil))
// 64:     case cask_name
// 65:     when nil
// 66:       @referenced_cask_name
// 67:     when String
// 68:       @referenced_cask_name = cask_name
// 69:     end
// 70:   end
// 71:
// 72:   # Sets the `@referenced_formula_name` instance variable to the provided
// 73:   # `String`/`Symbol` or returns the `@referenced_formula_name` instance
// 74:   # variable when no argument is provided. Inherited livecheck values from the
// 75:   # referenced formula (e.g. regex) can be overridden in the `livecheck` block.
// 76:   sig {
// 77:     params(
// 78:       # Name of formula to inherit livecheck info from.
// 79:       formula_name: T.any(String, Symbol),
// 80:     ).returns(T.nilable(T.any(String, Symbol)))
// 81:   }
// 82:   def formula(formula_name = T.unsafe(nil))
// 83:     case formula_name
// 84:     when nil
// 85:       @referenced_formula_name
// 86:     when String, :parent
// 87:       @referenced_formula_name = formula_name
// 88:     end
// 89:   end
// 90:
// 91:   # Sets the `@regex` instance variable to the provided `Regexp` or returns the
// 92:   # `@regex` instance variable when no argument is provided.
// 93:   sig {
// 94:     params(
// 95:       # Regex to use for matching versions in content.
// 96:       pattern: Regexp,
// 97:     ).returns(T.nilable(Regexp))
// 98:   }
// 99:   def regex(pattern = T.unsafe(nil))
// 100:     case pattern
// 101:     when nil
// 102:       @regex
// 103:     when Regexp
// 104:       @regex = pattern
// 105:     end
// 106:   end
// 107:
// 108:   # Sets the `@skip` instance variable to `true` and sets the `@skip_msg`
// 109:   # instance variable if a `String` is provided. `@skip` is used to indicate
// 110:   # that the formula/cask/resource should be skipped and the `skip_msg` very
// 111:   # briefly describes why it is skipped (e.g. "No longer developed or
// 112:   # maintained").
// 113:   sig {
// 114:     params(
// 115:       # String describing why the formula/cask is skipped.
// 116:       skip_msg: String,
// 117:     ).returns(T::Boolean)
// 118:   }
// 119:   def skip(skip_msg = T.unsafe(nil))
// 120:     @skip_msg = skip_msg if skip_msg.is_a?(String)
// 121:
// 122:     @skip = true
// 123:   end
// 124:
// 125:   # Should `livecheck` skip this formula/cask/resource?
// 126:   sig { returns(T::Boolean) }
// 127:   def skip?
// 128:     @skip
// 129:   end
// 130:
// 131:   # Sets the `@strategy` instance variable to the provided `Symbol` or returns
// 132:   # the `@strategy` instance variable when no argument is provided. The strategy
// 133:   # symbols use snake case (e.g. `:page_match`) and correspond to the strategy
// 134:   # file name.
// 135:   sig {
// 136:     params(
// 137:       # Symbol for the desired strategy.
// 138:       symbol: Symbol,
// 139:       block:  T.nilable(Proc),
// 140:     ).returns(T.nilable(Symbol))
// 141:   }
// 142:   def strategy(symbol = T.unsafe(nil), &block)
// 143:     @strategy_block = block if block
// 144:
// 145:     case symbol
// 146:     when nil
// 147:       @strategy
// 148:     when Symbol
// 149:       @strategy = symbol
// 150:     end
// 151:   end
// 152:
// 153:   # Sets the `@throttle` instance variable to the provided `Integer` or returns
// 154:   # the `@throttle` instance variable when no argument is provided. The `days`
// 155:   # argument will set `@throttle_days`.
// 156:   #
// 157:   # If both a throttle rate and days are provided, then the throttle days are
// 158:   # used as a fallback when a new throttled version doesn't appear before the
// 159:   # throttle interval ends.
// 160:   sig {
// 161:     params(
// 162:       # Throttle rate of version patch number to use for bumpable versions.
// 163:       rate: Integer,
// 164:       # Maximum number of days before allowing a non-multiple update.
// 165:       days: T.nilable(Integer),
// 166:     ).returns(T.nilable(Integer))
// 167:   }
// 168:   def throttle(rate = T.unsafe(nil), days: nil)
// 169:     @throttle_days = days unless days.nil?
// 170:
// 171:     case rate
// 172:     when nil
// 173:       @throttle
// 174:     when Integer
// 175:       @throttle = rate
// 176:     end
// 177:   end
// 178:
// 179:   # Sets the `@url` instance variable to the provided argument or returns the
// 180:   # `@url` instance variable when no argument is provided. The argument can be
// 181:   # a `String` (a URL) or a supported `Symbol` corresponding to a URL in the
// 182:   # formula/cask/resource (e.g. `:stable`, `:homepage`, `:head`, `:url`).
// 183:   # Any options provided to the method are passed through to `Strategy` methods
// 184:   # (`page_headers`, `page_content`).
// 185:   sig {
// 186:     params(
// 187:       # URL to check for version information.
// 188:       url:           T.any(String, Symbol),
// 189:       compressed:    T.nilable(T::Boolean),
// 190:       cookies:       T.nilable(T::Hash[String, String]),
// 191:       header:        T.nilable(T.any(String, T::Array[String])),
// 192:       homebrew_curl: T.nilable(T::Boolean),
// 193:       post_form:     T.nilable(T::Hash[Symbol, String]),
// 194:       post_json:     T.nilable(T::Hash[Symbol, T.anything]),
// 195:       referer:       T.nilable(String),
// 196:       user_agent:    T.nilable(T.any(String, Symbol)),
// 197:     ).returns(T.nilable(T.any(String, Symbol)))
// 198:   }
// 199:   def url(
// 200:     url = T.unsafe(nil),
// 201:     compressed: nil,
// 202:     cookies: nil,
// 203:     header: nil,
// 204:     homebrew_curl: nil,
// 205:     post_form: nil,
// 206:     post_json: nil,
// 207:     referer: nil,
// 208:     user_agent: nil
// 209:   )
// 210:     raise ArgumentError, "`compressed` option should only be `false` or omitted" if compressed == true
// 211:     raise ArgumentError, "`homebrew_curl` option should only be `true` or omitted" if homebrew_curl == false
// 212:     raise ArgumentError, "Only use `post_form` or `post_json`, not both" if post_form && post_json
// 213:
// 214:     @options.compressed = compressed unless compressed.nil?
// 215:     @options.cookies = cookies unless cookies.nil?
// 216:     @options.header = header unless header.nil?
// 217:     @options.homebrew_curl = homebrew_curl unless homebrew_curl.nil?
// 218:     @options.post_form = post_form unless post_form.nil?
// 219:     @options.post_json = post_json unless post_json.nil?
// 220:     @options.referer = referer unless referer.nil?
// 221:     @options.user_agent = user_agent unless user_agent.nil?
// 222:
// 223:     case url
// 224:     when nil
// 225:       @url
// 226:     when String, :head, :homepage, :stable, :url
// 227:       @url = url
// 228:     when Symbol
// 229:       raise ArgumentError, "#{url.inspect} is not a valid URL shorthand"
// 230:     end
// 231:   end
// 232:
// 233:   delegate url_options: :@options
// 234:   delegate arch: :@package_or_resource
// 235:   delegate os: :@package_or_resource
// 236:   delegate version: :@package_or_resource
// 237:   private :arch, :os, :version
// 238:   # Returns a `Hash` of all instance variable values.
// 239:   # @return [Hash]
// 240:   sig { returns(T::Hash[String, T.untyped]) }
// 241:   def to_hash
// 242:     {
// 243:       "options"       => @options.to_hash,
// 244:       "cask"          => @referenced_cask_name,
// 245:       "formula"       => @referenced_formula_name,
// 246:       "regex"         => @regex,
// 247:       "skip"          => @skip,
// 248:       "skip_msg"      => @skip_msg,
// 249:       "strategy"      => @strategy,
// 250:       "throttle"      => @throttle,
// 251:       "throttle_days" => @throttle_days,
// 252:       "url"           => @url,
// 253:     }
// 254:   end
// 255: end
