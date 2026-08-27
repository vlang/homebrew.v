module homebrew

import brew_runtime

// Translated from Homebrew/brew `livecheck.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :options` at line 21.
pub fn ruby_livecheck_l21_d1_options(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('options', ...args)
}

// Ruby attr_reader `attr_reader :skip_msg` at line 26.
pub fn ruby_livecheck_l26_d2_skip_msg(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skip_msg', ...args)
}

// Ruby attr_reader `attr_reader :strategy_block` at line 30.
pub fn ruby_livecheck_l30_d3_strategy_block(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('strategy_block', ...args)
}

// Ruby attr_reader `attr_reader :throttle_days` at line 35.
pub fn ruby_livecheck_l35_d4_throttle_days(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('throttle_days', ...args)
}

// Ruby method `initialize(package_or_resource)` at line 38.
pub fn ruby_livecheck_l38_d5_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `cask(cask_name = T.unsafe(nil))` at line 63.
pub fn ruby_livecheck_l63_d6_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby method `formula(formula_name = T.unsafe(nil))` at line 82.
pub fn ruby_livecheck_l82_d7_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula', ...args)
}

// Ruby method `regex(pattern = T.unsafe(nil))` at line 99.
pub fn ruby_livecheck_l99_d8_regex(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('regex', ...args)
}

// Ruby method `skip(skip_msg = T.unsafe(nil))` at line 119.
pub fn ruby_livecheck_l119_d9_skip(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skip', ...args)
}

// Ruby method `skip?` at line 127.
pub fn ruby_livecheck_l127_d10_skip(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skip?', ...args)
}

// Ruby method `strategy(symbol = T.unsafe(nil), &block)` at line 142.
pub fn ruby_livecheck_l142_d11_strategy(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('strategy', ...args)
}

// Ruby method `throttle(rate = T.unsafe(nil), days: nil)` at line 168.
pub fn ruby_livecheck_l168_d12_throttle(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('throttle', ...args)
}

// Ruby method `url(` at line 199.
pub fn ruby_livecheck_l199_d13_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('url', ...args)
}

// Ruby delegate `delegate url_options: :@options` at line 233.
pub fn ruby_livecheck_l233_d14_url_options(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('url_options', ...args)
}

// Ruby delegate `delegate arch: :@package_or_resource` at line 234.
pub fn ruby_livecheck_l234_d15_arch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('arch', ...args)
}

// Ruby delegate `delegate os: :@package_or_resource` at line 235.
pub fn ruby_livecheck_l235_d16_os(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('os', ...args)
}

// Ruby delegate `delegate version: :@package_or_resource` at line 236.
pub fn ruby_livecheck_l236_d17_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('version', ...args)
}

// Ruby method `to_hash` at line 241.
pub fn ruby_livecheck_l241_d18_to_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_hash', ...args)
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
