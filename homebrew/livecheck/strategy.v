module livecheck

import brew_runtime

// Translated from Homebrew/brew `livecheck/strategy.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.strategies` at line 106.
pub fn ruby_strategy_l106_d1_self_strategies(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.strategies', ...args)
}

// Ruby method `self.from_symbol(symbol)` at line 127.
pub fn ruby_strategy_l127_d2_self_from_symbol(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.from_symbol', ...args)
}

// Ruby method `self.from_url(url, livecheck_strategy: nil, regex_provided: false, block_provided: false)` at line 149.
pub fn ruby_strategy_l149_d3_self_from_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.from_url', ...args)
}

// Ruby method `self.post_args(post_form: nil, post_json: nil)` at line 195.
pub fn ruby_strategy_l195_d4_self_post_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.post_args', ...args)
}

// Ruby method `self.page_headers(url, options: Options.new)` at line 226.
pub fn ruby_strategy_l226_d5_self_page_headers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.page_headers', ...args)
}

// Ruby method `self.page_content(url, options: Options.new)` at line 276.
pub fn ruby_strategy_l276_d6_self_page_content(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.page_content', ...args)
}

// Ruby method `self.handle_block_return(value)` at line 337.
pub fn ruby_strategy_l337_d7_self_handle_block_return(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.handle_block_return', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/curl"
// 5: require "livecheck/options"
// 6:
// 7: module Homebrew
// 8:   module Livecheck
// 9:     # The `Livecheck::Strategy` module contains the various strategies as well
// 10:     # as some general-purpose methods for working with them. Within the context
// 11:     # of the `brew livecheck` command, strategies are established procedures
// 12:     # for finding new software versions at a given source.
// 13:     module Strategy
// 14:       extend Utils::Curl
// 15:
// 16:       # {Strategy} priorities informally range from 1 to 10, where 10 is the
// 17:       # highest priority. 5 is the default priority because it's roughly in
// 18:       # the middle of this range. Strategies with a priority of 0 (or lower)
// 19:       # are ignored.
// 20:       DEFAULT_PRIORITY = 5
// 21:
// 22:       # cURL's default `--connect-timeout` value can be up to two minutes, so
// 23:       # we need to use a more reasonable duration (in seconds) to avoid a
// 24:       # lengthy wait when a connection can't be established.
// 25:       CURL_CONNECT_TIMEOUT = 10
// 26:
// 27:       # cURL does not set a default `--max-time` value, so we provide a value
// 28:       # to ensure cURL will time out in a reasonable amount of time.
// 29:       CURL_MAX_TIME = T.let(CURL_CONNECT_TIMEOUT + 5, Integer)
// 30:
// 31:       # The `curl` process will sometimes hang indefinitely (despite setting
// 32:       # the `--max-time` argument) and it needs to be quit for livecheck to
// 33:       # continue. This value is used to set the `timeout` argument on
// 34:       # `Utils::Curl` method calls in {Strategy}.
// 35:       CURL_PROCESS_TIMEOUT = T.let(CURL_MAX_TIME + 5, Integer)
// 36:
// 37:       # The maximum number of redirections that `curl` should allow.
// 38:       MAX_REDIRECTIONS = 5
// 39:
// 40:       # This value is passed to `#parse_curl_output` to ensure that the limit
// 41:       # for the number of responses it will parse corresponds to the maximum
// 42:       # number of responses in this context. The `+ 1` here accounts for the
// 43:       # situation where there are exactly `MAX_REDIRECTIONS` number of
// 44:       # redirections, followed by a final `200 OK` response.
// 45:       MAX_PARSE_ITERATIONS = T.let(MAX_REDIRECTIONS + 1, Integer)
// 46:
// 47:       # `curl` arguments used when following redirections in {Strategy}
// 48:       # methods.
// 49:       REDIRECTION_CURL_ARGS = T.let([
// 50:         "--max-redirs", MAX_REDIRECTIONS.to_s,
// 51:         *https_redirect_curl_args
// 52:       ].freeze, T::Array[String])
// 53:
// 54:       # Baseline `curl` arguments used in {Strategy} methods.
// 55:       DEFAULT_CURL_ARGS = T.let([
// 56:         # Follow redirections to handle mirrors, relocations, etc.
// 57:         "--location",
// 58:         *REDIRECTION_CURL_ARGS,
// 59:         # Avoid progress bar text, so we can reliably identify `curl` error
// 60:         # messages in output
// 61:         "--silent",
// 62:       ].freeze, T::Array[String])
// 63:
// 64:       # `curl` arguments used in `Strategy#page_content` method.
// 65:       PAGE_CONTENT_CURL_ARGS = T.let(([
// 66:         # Return an error when the HTTP response code is 400 or greater but
// 67:         # continue to return body content
// 68:         "--fail-with-body",
// 69:         # Include HTTP response headers in output, so we can identify the
// 70:         # final URL after any redirections
// 71:         "--include",
// 72:       ] + DEFAULT_CURL_ARGS).freeze, T::Array[String])
// 73:
// 74:       # Baseline `curl` options used in {Strategy} methods.
// 75:       DEFAULT_CURL_OPTIONS = T.let({
// 76:         print_stdout:    false,
// 77:         print_stderr:    false,
// 78:         debug:           false,
// 79:         verbose:         false,
// 80:         timeout:         CURL_PROCESS_TIMEOUT,
// 81:         connect_timeout: CURL_CONNECT_TIMEOUT,
// 82:         max_time:        CURL_MAX_TIME,
// 83:         retries:         0,
// 84:       }.freeze, T::Hash[Symbol, T.untyped])
// 85:
// 86:       # A regex used to identify a tarball extension at the end of a string.
// 87:       TARBALL_EXTENSION_REGEX = /
// 88:         \.t
// 89:         (?:ar(?:\.(?:bz2|gz|lz|lzma|lzo|xz|Z|zst))?|
// 90:         b2|bz2?|z2|az|gz|lz|lzma|xz|Z|aZ|zst)
// 91:         $
// 92:       /ix
// 93:
// 94:       # An error message to use when a `strategy` block returns a value of
// 95:       # an inappropriate type.
// 96:       INVALID_BLOCK_RETURN_VALUE_MSG = "Return value of a strategy block must be a string or array of strings."
// 97:
// 98:       # Creates and/or returns a `@strategies` `Hash`, which maps a snake
// 99:       # case strategy name symbol (e.g. `:page_match`) to the associated
// 100:       # strategy.
// 101:       #
// 102:       # At present, this should only be called after tap strategies have been
// 103:       # loaded, otherwise livecheck won't be able to use them.
// 104:       # @return [Hash]
// 105:       sig { returns(T::Hash[Symbol, T.untyped]) }
// 106:       def self.strategies
// 107:         # Strategies (including tap-provided ones) are discovered dynamically.
// 108:         # rubocop:disable Sorbet/ConstantsFromStrings
// 109:         @strategies ||= T.let(Strategy.constants.sort.each_with_object({}) do |const_symbol, hash|
// 110:           constant = Strategy.const_get(const_symbol)
// 111:           next unless constant.is_a?(Class)
// 112:
// 113:           key = Utils.underscore(const_symbol).to_sym
// 114:           hash[key] = constant
// 115:         end, T.nilable(T::Hash[Symbol, T.untyped]))
// 116:         # rubocop:enable Sorbet/ConstantsFromStrings
// 117:       end
// 118:       private_class_method :strategies
// 119:
// 120:       # Returns the strategy that corresponds to the provided `Symbol` (or
// 121:       # `nil` if there is no matching strategy).
// 122:       #
// 123:       # @param symbol [Symbol, nil] the strategy name in snake case as a
// 124:       #   `Symbol` (e.g. `:page_match`)
// 125:       # @return [Class, nil]
// 126:       sig { params(symbol: T.nilable(Symbol)).returns(T.untyped) }
// 127:       def self.from_symbol(symbol)
// 128:         strategies[symbol] if symbol.present?
// 129:       end
// 130:
// 131:       # Returns an array of strategies that apply to the provided URL.
// 132:       #
// 133:       # @param url [String] the URL to check for matching strategies
// 134:       # @param livecheck_strategy [Symbol] a strategy symbol from the
// 135:       #   `livecheck` block
// 136:       # @param regex_provided [Boolean] whether a regex is provided in the
// 137:       #   `livecheck` block
// 138:       # @param block_provided [Boolean] whether a `strategy` block is provided
// 139:       #   in the `livecheck` block
// 140:       # @return [Array]
// 141:       sig {
// 142:         params(
// 143:           url:                String,
// 144:           livecheck_strategy: T.nilable(Symbol),
// 145:           regex_provided:     T::Boolean,
// 146:           block_provided:     T::Boolean,
// 147:         ).returns(T::Array[T.untyped])
// 148:       }
// 149:       def self.from_url(url, livecheck_strategy: nil, regex_provided: false, block_provided: false)
// 150:         usable_strategies = strategies.select do |strategy_symbol, strategy|
// 151:           if strategy == PageMatch
// 152:             # Only treat the strategy as usable if the `livecheck` block
// 153:             # contains a regex and/or `strategy` block
// 154:             next if !regex_provided && !block_provided
// 155:           elsif [Json, Xml, Yaml].include?(strategy)
// 156:             # Only treat the strategy as usable if the `livecheck` block
// 157:             # specifies the strategy and contains a `strategy` block
// 158:             next if (livecheck_strategy != strategy_symbol) || !block_provided
// 159:           # The strategy's optional `PRIORITY` constant is read dynamically.
// 160:           # rubocop:disable Sorbet/ConstantsFromStrings
// 161:           elsif strategy.const_defined?(:PRIORITY) &&
// 162:                 !strategy.const_get(:PRIORITY).positive? &&
// 163:                 livecheck_strategy != strategy_symbol
// 164:             # rubocop:enable Sorbet/ConstantsFromStrings
// 165:             # Ignore strategies with a priority of 0 or lower, unless the
// 166:             # strategy is specified in the `livecheck` block
// 167:             next
// 168:           end
// 169:
// 170:           strategy.respond_to?(:match?) && strategy.match?(url)
// 171:         end.values
// 172:
// 173:         # Sort usable strategies in descending order by priority, using the
// 174:         # DEFAULT_PRIORITY when a strategy doesn't contain a PRIORITY constant
// 175:         usable_strategies.sort_by do |strategy|
// 176:           # The strategy's optional `PRIORITY` constant is read dynamically.
// 177:           # rubocop:disable Sorbet/ConstantsFromStrings
// 178:           strategy.const_defined?(:PRIORITY) ? -strategy.const_get(:PRIORITY) : -DEFAULT_PRIORITY
// 179:           # rubocop:enable Sorbet/ConstantsFromStrings
// 180:         end
// 181:       end
// 182:
// 183:       # Creates `curl` `--data` or `--json` arguments (for `POST` requests`)
// 184:       # from related `livecheck` block `url` options.
// 185:       #
// 186:       # @param post_form [Hash, nil] data to encode using `URI::encode_www_form`
// 187:       # @param post_json [Hash, nil] data to encode using `JSON::generate`
// 188:       # @return [Array]
// 189:       sig {
// 190:         params(
// 191:           post_form: T.nilable(T::Hash[Symbol, String]),
// 192:           post_json: T.nilable(T::Hash[Symbol, T.anything]),
// 193:         ).returns(T::Array[String])
// 194:       }
// 195:       def self.post_args(post_form: nil, post_json: nil)
// 196:         args = if post_form.present?
// 197:           require "uri"
// 198:           ["--data", URI.encode_www_form(post_form)]
// 199:         elsif post_json.present?
// 200:           require "json"
// 201:           ["--json", JSON.generate(post_json)]
// 202:         else
// 203:           []
// 204:         end
// 205:
// 206:         if (content_length = args[1]&.length)
// 207:           args << "--header" << "Content-Length: #{content_length}"
// 208:         end
// 209:
// 210:         args
// 211:       end
// 212:
// 213:       # Collects HTTP response headers, starting with the provided URL.
// 214:       # Redirections will be followed and all the response headers are
// 215:       # collected into an array of hashes.
// 216:       #
// 217:       # @param url [String] the URL to fetch
// 218:       # @param options [Options] options to modify behavior
// 219:       # @return [Array]
// 220:       sig {
// 221:         params(
// 222:           url:     String,
// 223:           options: Options,
// 224:         ).returns(T::Array[T::Hash[String, T.any(String, T::Array[String])]])
// 225:       }
// 226:       def self.page_headers(url, options: Options.new)
// 227:         headers = []
// 228:
// 229:         if options.post_form || options.post_json
// 230:           curl_post_args = ["--request", "POST", *post_args(
// 231:             post_form: options.post_form,
// 232:             post_json: options.post_json,
// 233:           )]
// 234:         end
// 235:
// 236:         user_agents = if options.user_agent
// 237:           [options.user_agent]
// 238:         else
// 239:           [:default, :browser]
// 240:         end
// 241:
// 242:         user_agents.each do |user_agent|
// 243:           begin
// 244:             parsed_output = curl_headers(
// 245:               *curl_post_args,
// 246:               *REDIRECTION_CURL_ARGS,
// 247:               url,
// 248:               wanted_headers:    ["location", "content-disposition"],
// 249:               use_homebrew_curl: options.homebrew_curl || false,
// 250:               cookies:           options.cookies,
// 251:               header:            options.header,
// 252:               referer:           options.referer,
// 253:               user_agent:,
// 254:               **DEFAULT_CURL_OPTIONS,
// 255:             )
// 256:           rescue ErrorDuringExecution
// 257:             next
// 258:           end
// 259:
// 260:           parsed_output[:responses].each { |response| headers << response[:headers] }
// 261:           break if headers.present?
// 262:         end
// 263:
// 264:         headers
// 265:       end
// 266:
// 267:       # Fetches the content at the URL and returns a hash containing the
// 268:       # content and, if there are any redirections, the final URL.
// 269:       # If `curl` encounters an error, the hash will contain a `:messages`
// 270:       # array with the error message instead.
// 271:       #
// 272:       # @param url [String] the URL of the content to check
// 273:       # @param options [Options] options to modify behavior
// 274:       # @return [Hash]
// 275:       sig { params(url: String, options: Options).returns(T::Hash[Symbol, T.untyped]) }
// 276:       def self.page_content(url, options: Options.new)
// 277:         if options.post_form || options.post_json
// 278:           curl_post_args = ["--request", "POST", *post_args(
// 279:             post_form: options.post_form,
// 280:             post_json: options.post_json,
// 281:           )]
// 282:         end
// 283:
// 284:         args = if options.compressed == false
// 285:           PAGE_CONTENT_CURL_ARGS
// 286:         else
// 287:           PAGE_CONTENT_CURL_ARGS + ["--compressed"]
// 288:         end
// 289:
// 290:         user_agents = if options.user_agent
// 291:           [options.user_agent]
// 292:         else
// 293:           [:default, :browser]
// 294:         end
// 295:
// 296:         stderr = T.let(nil, T.nilable(String))
// 297:         user_agents.each do |user_agent|
// 298:           stdout, stderr, status = curl_output(
// 299:             *curl_post_args,
// 300:             *args,
// 301:             url,
// 302:             **DEFAULT_CURL_OPTIONS,
// 303:             use_homebrew_curl: options.homebrew_curl ||
// 304:                                !curl_supports_fail_with_body? ||
// 305:                                false,
// 306:             cookies:           options.cookies,
// 307:             header:            options.header,
// 308:             referer:           options.referer,
// 309:             user_agent:,
// 310:           )
// 311:           next unless status.success?
// 312:
// 313:           # stdout contains the header information followed by the page content.
// 314:           # We use #scrub here to avoid "invalid byte sequence in UTF-8" errors.
// 315:           output = stdout.scrub
// 316:
// 317:           # Separate the head(s)/body and identify the final URL (after any
// 318:           # redirections)
// 319:           parsed_output = parse_curl_output(output, max_iterations: MAX_PARSE_ITERATIONS)
// 320:           final_url = curl_response_last_location(parsed_output[:responses], absolutize: true, base_url: url)
// 321:
// 322:           data = { content: parsed_output[:body] }
// 323:           data[:final_url] = final_url if final_url.present? && final_url != url
// 324:           return data
// 325:         end
// 326:
// 327:         error_msgs = stderr&.scan(/^curl:.+$/)
// 328:         { messages: error_msgs.presence || ["cURL failed without a detectable error"] }
// 329:       end
// 330:
// 331:       # Handles the return value from a `strategy` block in a `livecheck`
// 332:       # block.
// 333:       #
// 334:       # @param value [] the return value from a `strategy` block
// 335:       # @return [Array]
// 336:       sig { params(value: T.untyped).returns(T::Array[String]) }
// 337:       def self.handle_block_return(value)
// 338:         case value
// 339:         when String, Version
// 340:           [value.to_s]
// 341:         when Array
// 342:           value.compact.map(&:to_s).uniq
// 343:         when nil
// 344:           []
// 345:         else
// 346:           raise TypeError, INVALID_BLOCK_RETURN_VALUE_MSG
// 347:         end
// 348:       end
// 349:     end
// 350:   end
// 351: end
// 352:
// 353: require_relative "strategy/apache"
// 354: require_relative "strategy/bitbucket"
// 355: require_relative "strategy/cpan"
// 356: require_relative "strategy/crate"
// 357: require_relative "strategy/electron_builder"
// 358: require_relative "strategy/extract_plist"
// 359: require_relative "strategy/git"
// 360: require_relative "strategy/github_latest"
// 361: require_relative "strategy/github_releases"
// 362: require_relative "strategy/gnome"
// 363: require_relative "strategy/gnu"
// 364: require_relative "strategy/hackage"
// 365: require_relative "strategy/header_match"
// 366: require_relative "strategy/json"
// 367: require_relative "strategy/launchpad"
// 368: require_relative "strategy/npm"
// 369: require_relative "strategy/page_match"
// 370: require_relative "strategy/pypi"
// 371: require_relative "strategy/ruby_gems"
// 372: require_relative "strategy/sourceforge"
// 373: require_relative "strategy/sparkle"
// 374: require_relative "strategy/xml"
// 375: require_relative "strategy/xorg"
// 376: require_relative "strategy/yaml"
