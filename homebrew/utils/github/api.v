module github

import brew_runtime

// Translated from Homebrew/brew `utils/github/api.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.pat_blurb(scopes = ALL_SCOPES)` at line 11.
pub fn ruby_api_l11_d1_self_pat_blurb(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.pat_blurb', ...args)
}

// Ruby method `initialize(message = nil, github_message = T.unsafe(nil))` at line 58.
pub fn ruby_api_l58_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize(github_message)` at line 67.
pub fn ruby_api_l67_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize(github_message)` at line 75.
pub fn ruby_api_l75_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize(github_message, reset:, resource:, limit:)` at line 83.
pub fn ruby_api_l83_d5_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby attr_reader `attr_reader :reset` at line 95.
pub fn ruby_api_l95_d6_reset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reset', ...args)
}

// Ruby method `pretty_ratelimit_reset` at line 98.
pub fn ruby_api_l98_d7_pretty_ratelimit_reset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pretty_ratelimit_reset', ...args)
}

// Ruby method `initialize(credentials_type, github_message)` at line 117.
pub fn ruby_api_l117_d8_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize` at line 148.
pub fn ruby_api_l148_d9_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize(github_message, errors)` at line 156.
pub fn ruby_api_l156_d10_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `self.sleep_for_rate_limit(exception)` at line 174.
pub fn ruby_api_l174_d11_self_sleep_for_rate_limit(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.sleep_for_rate_limit', ...args)
}

// Ruby method `self.github_cli_token` at line 182.
pub fn ruby_api_l182_d12_self_github_cli_token(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.github_cli_token', ...args)
}

// Ruby method `self.keychain_username_password` at line 199.
pub fn ruby_api_l199_d13_self_keychain_username_password(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.keychain_username_password', ...args)
}

// Ruby method `self.credentials` at line 223.
pub fn ruby_api_l223_d14_self_credentials(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.credentials', ...args)
}

// Ruby method `self.credentials_type` at line 231.
pub fn ruby_api_l231_d15_self_credentials_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.credentials_type', ...args)
}

// Ruby method `self.credentials_error_message(response_headers, needed_scopes)` at line 253.
pub fn ruby_api_l253_d16_self_credentials_error_message(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.credentials_error_message', ...args)
}

// Ruby method `self.open_rest(url, data: T.unsafe(nil), data_binary_path: T.unsafe(nil), request_method: T.unsafe(nil),` at line 289.
pub fn ruby_api_l289_d17_self_open_rest(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.open_rest', ...args)
}

// Ruby method `self.commit(user, repo, branch: "main")` at line 364.
pub fn ruby_api_l364_d18_self_commit(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.commit', ...args)
}

// Ruby method `self.paginate_rest(url, additional_query_params: T.unsafe(nil), per_page: 100, scopes: [].freeze, &_block)` at line 379.
pub fn ruby_api_l379_d19_self_paginate_rest(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.paginate_rest', ...args)
}

// Ruby method `self.open_graphql(query, variables: {}, scopes: [].freeze, raise_errors: true)` at line 406.
pub fn ruby_api_l406_d20_self_open_graphql(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.open_graphql', ...args)
}

// Ruby method `self.paginate_graphql(query, variables: {}, scopes: [].freeze, raise_errors: true, &_block)` at line 428.
pub fn ruby_api_l428_d21_self_paginate_graphql(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.paginate_graphql', ...args)
}

// Ruby method `self.raise_error(output, errors, http_code, headers, scopes)` at line 451.
pub fn ruby_api_l451_d22_self_raise_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.raise_error', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "system_command"
// 5: require "uri"
// 6: require "utils/output"
// 7: require "utils/path"
// 8:
// 9: module GitHub
// 10:   sig { params(scopes: T::Array[String]).returns(String) }
// 11:   def self.pat_blurb(scopes = ALL_SCOPES)
// 12:     require "utils/formatter"
// 13:     require "utils/shell"
// 14:     <<~EOS
// 15:       Create a GitHub personal access token:
// 16:         #{Formatter.url(
// 17:           "https://github.com/settings/tokens/new?scopes=#{scopes.join(",")}&description=Homebrew",
// 18:         )}
// 19:       #{Utils::Shell.set_variable_in_profile("HOMEBREW_GITHUB_API_TOKEN", "your_token_here")}
// 20:     EOS
// 21:   end
// 22:
// 23:   API_URL = "https://api.github.com"
// 24:   API_MAX_PAGES = 50
// 25:   private_constant :API_MAX_PAGES
// 26:   API_MAX_ITEMS = 5000
// 27:   private_constant :API_MAX_ITEMS
// 28:   PAGINATE_RETRY_COUNT = 3
// 29:   private_constant :PAGINATE_RETRY_COUNT
// 30:
// 31:   CREATE_GIST_SCOPES = ["gist"].freeze
// 32:   CREATE_ISSUE_FORK_OR_PR_SCOPES = ["repo"].freeze
// 33:   CREATE_WORKFLOW_SCOPES = ["workflow"].freeze
// 34:   ALL_SCOPES = T.let((CREATE_GIST_SCOPES + CREATE_ISSUE_FORK_OR_PR_SCOPES + CREATE_WORKFLOW_SCOPES).freeze,
// 35:                      T::Array[String])
// 36:   private_constant :ALL_SCOPES
// 37:   GITHUB_ACCESS_TOKEN_REGEX = %r{
// 38:     ^(?:
// 39:       [a-f0-9]{40}                       | # legacy 40-char hex PAT
// 40:       (?:gh[pour]|github_pat)_\w{36,251} | # PAT / OAuth / user / refresh tokens
// 41:       ghs_[A-Za-z0-9.\-_]{36,}             # GitHub App installation token
// 42:     )$
// 43:   }x
// 44:   private_constant :GITHUB_ACCESS_TOKEN_REGEX
// 45:
// 46:   # Helper functions for accessing the GitHub API.
// 47:   #
// 48:   # @api internal
// 49:   module API
// 50:     extend SystemCommand::Mixin
// 51:     extend Utils::Output::Mixin
// 52:
// 53:     # Generic API error.
// 54:     class Error < RuntimeError
// 55:       include Utils::Output::Mixin
// 56:
// 57:       sig { params(message: T.nilable(String), github_message: String).void }
// 58:       def initialize(message = nil, github_message = T.unsafe(nil))
// 59:         @github_message = T.let(github_message, T.nilable(String))
// 60:         super(message)
// 61:       end
// 62:     end
// 63:
// 64:     # Error when the Git repository to be queried is empty.
// 65:     class GitRepositoryIsEmptyError < Error
// 66:       sig { params(github_message: String).void }
// 67:       def initialize(github_message)
// 68:         super(nil, github_message)
// 69:       end
// 70:     end
// 71:
// 72:     # Error when the requested URL is not found.
// 73:     class HTTPNotFoundError < Error
// 74:       sig { params(github_message: String).void }
// 75:       def initialize(github_message)
// 76:         super(nil, github_message)
// 77:       end
// 78:     end
// 79:
// 80:     # Error when the API rate limit is exceeded.
// 81:     class RateLimitExceededError < Error
// 82:       sig { params(github_message: String, reset: Integer, resource: String, limit: Integer).void }
// 83:       def initialize(github_message, reset:, resource:, limit:)
// 84:         @reset = reset
// 85:         new_pat_message = ", or:\n#{GitHub.pat_blurb}" if API.credentials.blank?
// 86:         message = <<~EOS
// 87:           GitHub API Error: #{github_message}
// 88:           Rate limit exceeded for #{resource} resource (#{limit} limit).
// 89:           Try again in #{pretty_ratelimit_reset}#{new_pat_message}
// 90:         EOS
// 91:         super(message, github_message)
// 92:       end
// 93:
// 94:       sig { returns(Integer) }
// 95:       attr_reader :reset
// 96:
// 97:       sig { returns(String) }
// 98:       def pretty_ratelimit_reset
// 99:         pretty_duration(Time.at(@reset) - Time.now)
// 100:       end
// 101:     end
// 102:
// 103:     GITHUB_IP_ALLOWLIST_ERROR = Regexp.new(
// 104:       "Although you appear to have the correct authorization credentials, " \
// 105:       "the `(.+)` organization has an IP allow list enabled, " \
// 106:       "and your IP address is not permitted to access this resource",
// 107:     ).freeze
// 108:
// 109:     NO_CREDENTIALS_MESSAGE = T.let(<<~MESSAGE.freeze, String)
// 110:       No GitHub credentials found in macOS Keychain, GitHub CLI or the environment.
// 111:       #{GitHub.pat_blurb}
// 112:     MESSAGE
// 113:
// 114:     # Error when authentication fails.
// 115:     class AuthenticationFailedError < Error
// 116:       sig { params(credentials_type: Symbol, github_message: String).void }
// 117:       def initialize(credentials_type, github_message)
// 118:         message = "GitHub API Error: #{github_message}\n"
// 119:         message << case credentials_type
// 120:         when :github_cli_token
// 121:           <<~EOS
// 122:             Your GitHub CLI login session may be invalid.
// 123:             Refresh it with:
// 124:               gh auth login --hostname github.com
// 125:           EOS
// 126:         when :keychain_username_password
// 127:           <<~EOS
// 128:             The GitHub credentials in the macOS keychain may be invalid.
// 129:             Clear them with:
// 130:               printf "protocol=https\\nhost=github.com\\n" | git credential-osxkeychain erase
// 131:           EOS
// 132:         when :env_token
// 133:           require "utils/formatter"
// 134:           <<~EOS
// 135:             `$HOMEBREW_GITHUB_API_TOKEN` may be invalid or expired; check:
// 136:               #{Formatter.url("https://github.com/settings/tokens")}
// 137:           EOS
// 138:         when :none
// 139:           NO_CREDENTIALS_MESSAGE
// 140:         end
// 141:         super message.freeze, github_message
// 142:       end
// 143:     end
// 144:
// 145:     # Error when the user has no GitHub API credentials set at all (macOS keychain, GitHub CLI or env var).
// 146:     class MissingAuthenticationError < Error
// 147:       sig { void }
// 148:       def initialize
// 149:         super NO_CREDENTIALS_MESSAGE
// 150:       end
// 151:     end
// 152:
// 153:     # Error when the API returns a validation error.
// 154:     class ValidationFailedError < Error
// 155:       sig { params(github_message: String, errors: T::Array[String]).void }
// 156:       def initialize(github_message, errors)
// 157:         github_message = "#{github_message}: #{errors}" unless errors.empty?
// 158:
// 159:         super(github_message, github_message)
// 160:       end
// 161:     end
// 162:
// 163:     ERRORS = [
// 164:       AuthenticationFailedError,
// 165:       GitRepositoryIsEmptyError,
// 166:       HTTPNotFoundError,
// 167:       RateLimitExceededError,
// 168:       Error,
// 169:       JSON::ParserError,
// 170:     ].freeze
// 171:
// 172:     # Sleeps until the rate limit from the given exception has reset.
// 173:     sig { params(exception: RateLimitExceededError).void }
// 174:     def self.sleep_for_rate_limit(exception)
// 175:       sleep_seconds = [exception.reset - Time.now.to_i, 1].max
// 176:       opoo "GitHub rate limit exceeded, sleeping for #{sleep_seconds} seconds..."
// 177:       sleep sleep_seconds
// 178:     end
// 179:
// 180:     # Gets the token from the GitHub CLI for github.com.
// 181:     sig { returns(T.nilable(String)) }
// 182:     def self.github_cli_token
// 183:       require "utils/uid"
// 184:       # Avoid `Formula["gh"].opt_bin` so this method works even with `HOMEBREW_DISABLE_LOAD_FORMULA`.
// 185:       env = Utils::Path.formula_opt_bin_env("gh").merge("HOME" => Utils::UID.uid_home).compact
// 186:       gh_out, _, result = system_command("gh",
// 187:                                          args:            ["auth", "token", "--hostname", "github.com"],
// 188:                                          env:,
// 189:                                          print_stderr:    false,
// 190:                                          run_as_real_uid: true).to_a
// 191:       return unless result.success?
// 192:
// 193:       gh_out.chomp.presence
// 194:     end
// 195:
// 196:     # Gets the password field from `git-credential-osxkeychain` for github.com,
// 197:     # but only if that password looks like a GitHub access token.
// 198:     sig { returns(T.nilable(String)) }
// 199:     def self.keychain_username_password
// 200:       require "utils/uid"
// 201:       git_credential_out, _, result = system_command("git",
// 202:                                                      args:            ["credential-osxkeychain", "get"],
// 203:                                                      input:           ["protocol=https\n", "host=github.com\n"],
// 204:                                                      env:             { "HOME" => Utils::UID.uid_home }.compact,
// 205:                                                      print_stderr:    false,
// 206:                                                      run_as_real_uid: true).to_a
// 207:       return unless result.success?
// 208:
// 209:       git_credential_out.force_encoding("ASCII-8BIT")
// 210:       github_username = git_credential_out[/^username=(.+)/, 1]
// 211:       github_password = git_credential_out[/^password=(.+)/, 1]
// 212:       return unless github_username
// 213:
// 214:       # Don't use passwords from the keychain unless they look like
// 215:       # GitHub access tokens:
// 216:       #   https://github.com/Homebrew/brew/issues/6862#issuecomment-572610344
// 217:       return unless GITHUB_ACCESS_TOKEN_REGEX.match?(github_password)
// 218:
// 219:       github_password.presence
// 220:     end
// 221:
// 222:     sig { returns(T.nilable(String)) }
// 223:     def self.credentials
// 224:       @credentials ||= T.let(nil, T.nilable(String))
// 225:       @credentials ||= Homebrew::EnvConfig.github_api_token.presence
// 226:       @credentials ||= github_cli_token
// 227:       @credentials ||= keychain_username_password
// 228:     end
// 229:
// 230:     sig { returns(Symbol) }
// 231:     def self.credentials_type
// 232:       if Homebrew::EnvConfig.github_api_token.present?
// 233:         :env_token
// 234:       elsif github_cli_token.present?
// 235:         :github_cli_token
// 236:       elsif keychain_username_password.present?
// 237:         :keychain_username_password
// 238:       else
// 239:         :none
// 240:       end
// 241:     end
// 242:
// 243:     CREDENTIAL_NAMES = T.let({
// 244:       env_token:                  "HOMEBREW_GITHUB_API_TOKEN",
// 245:       github_cli_token:           "GitHub CLI login",
// 246:       keychain_username_password: "macOS Keychain GitHub",
// 247:       none:                       "none",
// 248:     }.freeze, T::Hash[Symbol, String])
// 249:
// 250:     # Given an API response from GitHub, warn the user if their credentials
// 251:     # have insufficient permissions.
// 252:     sig { params(response_headers: T::Hash[String, String], needed_scopes: T::Array[String]).void }
// 253:     def self.credentials_error_message(response_headers, needed_scopes)
// 254:       return if response_headers.empty?
// 255:
// 256:       scopes = response_headers["x-accepted-oauth-scopes"].to_s.split(", ").presence
// 257:       needed_scopes = Set.new(scopes || needed_scopes)
// 258:       credentials_scopes = response_headers["x-oauth-scopes"]
// 259:       return if needed_scopes.subset?(Set.new(credentials_scopes.to_s.split(", ")))
// 260:
// 261:       github_permission_link = GitHub.pat_blurb(needed_scopes.to_a)
// 262:       needed_scopes = needed_scopes.to_a.join(", ").presence || "none"
// 263:       credentials_scopes = "none" if credentials_scopes.blank?
// 264:
// 265:       what = CREDENTIAL_NAMES.fetch(credentials_type)
// 266:       @credentials_error_message ||= T.let(begin
// 267:         error_message = <<~EOS
// 268:           Your #{what} credentials do not have sufficient scope!
// 269:           Scopes required: #{needed_scopes}
// 270:           Scopes present:  #{credentials_scopes}
// 271:           #{github_permission_link}
// 272:         EOS
// 273:         onoe error_message
// 274:         error_message
// 275:       end, T.nilable(String))
// 276:     end
// 277:
// 278:     T::Sig::WithoutRuntime.sig {
// 279:       params(
// 280:         url:              T.any(String, URI::Generic),
// 281:         data:             T::Hash[Symbol, T.untyped],
// 282:         data_binary_path: String,
// 283:         request_method:   Symbol,
// 284:         scopes:           T::Array[String],
// 285:         parse_json:       T::Boolean,
// 286:         _block:           T.nilable(T.proc.params(data: T::Hash[String, T.untyped]).returns(T.untyped)),
// 287:       ).returns(T.untyped)
// 288:     }
// 289:     def self.open_rest(url, data: T.unsafe(nil), data_binary_path: T.unsafe(nil), request_method: T.unsafe(nil),
// 290:                        scopes: [].freeze, parse_json: true, &_block)
// 291:       # This is a no-op if the user is opting out of using the GitHub API.
// 292:       return block_given? ? yield({}) : {} if Homebrew::EnvConfig.no_github_api?
// 293:
// 294:       # This is a Curl format token, not a Ruby one.
// 295:       # rubocop:disable Style/FormatStringToken
// 296:       args = ["--header", "Accept: application/vnd.github+json", "--write-out", "\n%{http_code}"]
// 297:       # rubocop:enable Style/FormatStringToken
// 298:
// 299:       token = credentials
// 300:       args += ["--header", "Authorization: token #{token}"] if credentials_type != :none
// 301:       args += ["--header", "X-GitHub-Api-Version:2022-11-28"]
// 302:
// 303:       require "tempfile"
// 304:       data_tmpfile = nil
// 305:       if data
// 306:         begin
// 307:           data = JSON.pretty_generate data
// 308:           data_tmpfile = Tempfile.new("github_api_post", HOMEBREW_TEMP)
// 309:         rescue JSON::ParserError => e
// 310:           raise Error, "Failed to parse JSON request:\n#{e.message}\n#{data}", e.backtrace
// 311:         end
// 312:       end
// 313:
// 314:       if data_binary_path.present?
// 315:         args += ["--data-binary", "@#{data_binary_path}"]
// 316:         args += ["--header", "Content-Type: application/gzip"]
// 317:       end
// 318:
// 319:       headers_tmpfile = Tempfile.new("github_api_headers", HOMEBREW_TEMP)
// 320:       begin
// 321:         if data_tmpfile
// 322:           data_tmpfile.write data
// 323:           data_tmpfile.close
// 324:           args += ["--data", "@#{data_tmpfile.path}"]
// 325:
// 326:           args += ["--request", request_method.to_s] if request_method
// 327:         end
// 328:
// 329:         args += ["--dump-header", T.must(headers_tmpfile.path)]
// 330:
// 331:         require "utils/curl"
// 332:         result = Utils::Curl.curl_output("--location", url.to_s, *args, secrets: token ? [token] : [])
// 333:         output, _, http_code = result.stdout.rpartition("\n")
// 334:         output, _, http_code = output.rpartition("\n") if http_code == "000"
// 335:         headers = headers_tmpfile.read
// 336:       ensure
// 337:         if data_tmpfile
// 338:           data_tmpfile.close
// 339:           data_tmpfile.unlink
// 340:         end
// 341:         headers_tmpfile.close
// 342:         headers_tmpfile.unlink
// 343:       end
// 344:
// 345:       begin
// 346:         if !http_code.start_with?("2") || !result.status.success?
// 347:           raise_error(output, result.stderr, http_code, headers || "", scopes)
// 348:         end
// 349:
// 350:         return if http_code == "204" # No Content
// 351:
// 352:         output = JSON.parse output if parse_json
// 353:         if block_given?
// 354:           yield output
// 355:         else
// 356:           output
// 357:         end
// 358:       rescue JSON::ParserError => e
// 359:         raise Error, "Failed to parse JSON response\n#{e.message}", e.backtrace
// 360:       end
// 361:     end
// 362:
// 363:     sig { params(user: String, repo: String, branch: String).returns(T::Hash[String, T.untyped]) }
// 364:     def self.commit(user, repo, branch: "main")
// 365:       open_rest("#{API_URL}/repos/#{user}/#{repo}/commits/#{URI.encode_uri_component(branch)}", request_method: :GET)
// 366:     end
// 367:
// 368:     T::Sig::WithoutRuntime.sig {
// 369:       params(
// 370:         url:                     T.any(String, URI::Generic),
// 371:         additional_query_params: String,
// 372:         per_page:                Integer,
// 373:         scopes:                  T::Array[String],
// 374:         _block:                  T.proc
// 375:                                   .params(result: T.untyped, page: Integer)
// 376:                                   .returns(T.untyped),
// 377:       ).void
// 378:     }
// 379:     def self.paginate_rest(url, additional_query_params: T.unsafe(nil), per_page: 100, scopes: [].freeze, &_block)
// 380:       (1..API_MAX_PAGES).each do |page|
// 381:         retry_count = 1
// 382:         result = begin
// 383:           API.open_rest("#{url}?per_page=#{per_page}&page=#{page}&#{additional_query_params}", scopes:)
// 384:         rescue Error
// 385:           if retry_count < PAGINATE_RETRY_COUNT
// 386:             retry_count += 1
// 387:             retry
// 388:           end
// 389:
// 390:           raise
// 391:         end
// 392:         break if result.blank?
// 393:
// 394:         yield(result, page)
// 395:       end
// 396:     end
// 397:
// 398:     sig {
// 399:       params(
// 400:         query:        String,
// 401:         variables:    T::Hash[Symbol, T.untyped],
// 402:         scopes:       T::Array[String],
// 403:         raise_errors: T::Boolean,
// 404:       ).returns(T.untyped)
// 405:     }
// 406:     def self.open_graphql(query, variables: {}, scopes: [].freeze, raise_errors: true)
// 407:       data = { query:, variables: }
// 408:       result = open_rest("#{API_URL}/graphql", scopes:, data:, request_method: :POST)
// 409:
// 410:       if raise_errors
// 411:         raise Error, result["errors"].map { |e| e["message"] }.join("\n") if result["errors"].present?
// 412:
// 413:         result["data"]
// 414:       else
// 415:         result
// 416:       end
// 417:     end
// 418:
// 419:     sig {
// 420:       params(
// 421:         query:        String,
// 422:         variables:    T::Hash[Symbol, T.untyped],
// 423:         scopes:       T::Array[String],
// 424:         raise_errors: T::Boolean,
// 425:         _block:       T.proc.params(data: T::Hash[String, T.untyped]).returns(T.untyped),
// 426:       ).void
// 427:     }
// 428:     def self.paginate_graphql(query, variables: {}, scopes: [].freeze, raise_errors: true, &_block)
// 429:       result = API.open_graphql(query, variables:, scopes:, raise_errors:)
// 430:
// 431:       has_next_page = T.let(true, T::Boolean)
// 432:       while has_next_page
// 433:         page_info = yield result
// 434:         has_next_page = page_info["hasNextPage"]
// 435:         if has_next_page
// 436:           variables[:after] = page_info["endCursor"]
// 437:           result = API.open_graphql(query, variables:, scopes:, raise_errors:)
// 438:         end
// 439:       end
// 440:     end
// 441:
// 442:     sig {
// 443:       params(
// 444:         output:    String,
// 445:         errors:    String,
// 446:         http_code: String,
// 447:         headers:   String,
// 448:         scopes:    T::Array[String],
// 449:       ).void
// 450:     }
// 451:     def self.raise_error(output, errors, http_code, headers, scopes)
// 452:       json = begin
// 453:         JSON.parse(output)
// 454:       rescue
// 455:         nil
// 456:       end
// 457:       message = json&.[]("message") || "curl failed! #{errors}"
// 458:
// 459:       meta = {}
// 460:       headers.lines.each do |l|
// 461:         key, _, value = l.delete(":").partition(" ")
// 462:         key = key.downcase.strip
// 463:         next if key.empty?
// 464:
// 465:         meta[key] = value.strip
// 466:       end
// 467:
// 468:       credentials_error_message(meta, scopes)
// 469:
// 470:       case http_code
// 471:       when "401"
// 472:         raise AuthenticationFailedError.new(credentials_type, message)
// 473:       when "403"
// 474:         if meta.fetch("x-ratelimit-remaining", 1).to_i <= 0
// 475:           reset = meta.fetch("x-ratelimit-reset").to_i
// 476:           resource = meta.fetch("x-ratelimit-resource")
// 477:           limit = meta.fetch("x-ratelimit-limit").to_i
// 478:           raise RateLimitExceededError.new(message, reset:, resource:, limit:)
// 479:         end
// 480:
// 481:         raise AuthenticationFailedError.new(credentials_type, message)
// 482:       when "404"
// 483:         raise MissingAuthenticationError if credentials_type == :none && scopes.present?
// 484:
// 485:         raise HTTPNotFoundError, message
// 486:       when "409"
// 487:         raise GitRepositoryIsEmptyError, message if message.downcase.include? "git repository is empty"
// 488:
// 489:         raise Error, message
// 490:       when "422"
// 491:         errors = json&.[]("errors") || []
// 492:         raise ValidationFailedError.new(message, errors)
// 493:       else
// 494:         raise Error, message
// 495:       end
// 496:     end
// 497:   end
// 498: end
