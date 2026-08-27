module utils

import brew_runtime

// Translated from Homebrew/brew `utils/output.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `ohai_title(title)` at line 15.
pub fn ruby_output_l15_d1_ohai_title(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ohai_title', ...args)
}

// Ruby method `ohai(title, *sput)` at line 27.
pub fn ruby_output_l27_d2_ohai(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ohai', ...args)
}

// Ruby method `odebug(title, *sput, always_display: false)` at line 33.
pub fn ruby_output_l33_d3_odebug(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('odebug', ...args)
}

// Ruby method `oh1_title(title, truncate: :auto)` at line 47.
pub fn ruby_output_l47_d4_oh1_title(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('oh1_title', ...args)
}

// Ruby method `oh1(title, truncate: :auto)` at line 59.
pub fn ruby_output_l59_d5_oh1(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('oh1', ...args)
}

// Ruby method `opoo(message)` at line 68.
pub fn ruby_output_l68_d6_opoo(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('opoo', ...args)
}

// Ruby method `opoo_without_github_actions_annotation(message)` at line 80.
pub fn ruby_output_l80_d7_opoo_without_github_actions_annotation(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('opoo_without_github_actions_annotation', ...args)
}

// Ruby method `opoo_outside_github_actions(message)` at line 95.
pub fn ruby_output_l95_d8_opoo_outside_github_actions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('opoo_outside_github_actions', ...args)
}

// Ruby method `onoe(message)` at line 107.
pub fn ruby_output_l107_d9_onoe(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('onoe', ...args)
}

// Ruby method `ofail(error)` at line 122.
pub fn ruby_output_l122_d10_ofail(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ofail', ...args)
}

// Ruby method `issue_reporting_message(issues_url, homebrew: false, read_this: false)` at line 128.
pub fn ruby_output_l128_d11_issue_reporting_message(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('issue_reporting_message', ...args)
}

// Ruby method `odie(error)` at line 151.
pub fn ruby_output_l151_d12_odie(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('odie', ...args)
}

// Ruby method `odeprecated(method, replacement = nil,` at line 161.
pub fn ruby_output_l161_d13_odeprecated(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('odeprecated', ...args)
}

// Ruby method `odisabled(method, replacement = nil,` at line 244.
pub fn ruby_output_l244_d14_odisabled(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('odisabled', ...args)
}

// Ruby method `pretty_installed(string)` at line 255.
pub fn ruby_output_l255_d15_pretty_installed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pretty_installed', ...args)
}

// Ruby method `pretty_upgradable(string, bold: true)` at line 266.
pub fn ruby_output_l266_d16_pretty_upgradable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pretty_upgradable', ...args)
}

// Ruby method `pretty_deprecated(string)` at line 278.
pub fn ruby_output_l278_d17_pretty_deprecated(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pretty_deprecated', ...args)
}

// Ruby method `pretty_disabled(string)` at line 287.
pub fn ruby_output_l287_d18_pretty_disabled(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pretty_disabled', ...args)
}

// Ruby method `pretty_uninstalled(string, bold: true)` at line 298.
pub fn ruby_output_l298_d19_pretty_uninstalled(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pretty_uninstalled', ...args)
}

// Ruby method `pretty_unmarked(string, bold: true)` at line 310.
pub fn ruby_output_l310_d20_pretty_unmarked(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pretty_unmarked', ...args)
}

// Ruby method `pretty_warning(string, bold: true)` at line 319.
pub fn ruby_output_l319_d21_pretty_warning(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pretty_warning', ...args)
}

// Ruby method `pretty_install_status(string, installed:, warning: false, outdated: false, deprecated: false,` at line 335.
pub fn ruby_output_l335_d22_pretty_install_status(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pretty_install_status', ...args)
}

// Ruby method `pretty_duration(seconds)` at line 359.
pub fn ruby_output_l359_d23_pretty_duration(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pretty_duration', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Utils
// 5:   # Helper methods for outputting messages in Homebrew's formats.
// 6:   module Output
// 7:     # Mixin used to add these helpers to stdout and stderr.
// 8:     module Mixin
// 9:       extend T::Helpers
// 10:
// 11:       requires_ancestor { Kernel }
// 12:
// 13:       # Keep in sync with `ohai` in Library/Homebrew/utils.sh.
// 14:       sig { params(title: String).returns(String) }
// 15:       def ohai_title(title)
// 16:         verbose = if respond_to?(:verbose?)
// 17:           T.unsafe(self).verbose?
// 18:         else
// 19:           Context.current.verbose?
// 20:         end
// 21:
// 22:         title = Tty.truncate(title.to_s) if $stdout.tty? && !verbose
// 23:         Formatter.headline(title, color: :blue)
// 24:       end
// 25:
// 26:       sig { params(title: T.any(String, Exception), sput: T.anything).void }
// 27:       def ohai(title, *sput)
// 28:         puts ohai_title(title.to_s)
// 29:         puts sput
// 30:       end
// 31:
// 32:       sig { params(title: T.any(String, Exception), sput: T.anything, always_display: T::Boolean).void }
// 33:       def odebug(title, *sput, always_display: false)
// 34:         debug = if respond_to?(:debug)
// 35:           T.unsafe(self).debug?
// 36:         else
// 37:           Context.current.debug?
// 38:         end
// 39:
// 40:         return if !debug && !always_display
// 41:
// 42:         $stderr.puts Formatter.headline(title.to_s, color: :magenta)
// 43:         $stderr.puts sput unless sput.empty?
// 44:       end
// 45:
// 46:       sig { params(title: String, truncate: T.any(Symbol, T::Boolean)).returns(String) }
// 47:       def oh1_title(title, truncate: :auto)
// 48:         verbose = if respond_to?(:verbose?)
// 49:           T.unsafe(self).verbose?
// 50:         else
// 51:           Context.current.verbose?
// 52:         end
// 53:
// 54:         title = Tty.truncate(title.to_s) if $stdout.tty? && !verbose && truncate == :auto
// 55:         Formatter.headline(title, color: :green)
// 56:       end
// 57:
// 58:       sig { params(title: String, truncate: T.any(Symbol, T::Boolean)).void }
// 59:       def oh1(title, truncate: :auto)
// 60:         puts oh1_title(title, truncate:)
// 61:       end
// 62:
// 63:       # Print a warning message.
// 64:       #
// 65:       # @api public
// 66:       # Keep in sync with `opoo` in Library/Homebrew/utils.sh.
// 67:       sig { params(message: T.any(String, Exception)).void }
// 68:       def opoo(message)
// 69:         require "utils/github/actions"
// 70:         return if GitHub::Actions.puts_annotation_if_env_set!(:warning, message.to_s)
// 71:
// 72:         require "utils/formatter"
// 73:
// 74:         Tty.with($stderr) do |stderr|
// 75:           stderr.puts Formatter.warning(message, label: "Warning")
// 76:         end
// 77:       end
// 78:
// 79:       sig { params(message: T.any(String, Exception)).void }
// 80:       def opoo_without_github_actions_annotation(message)
// 81:         require "utils/github/actions"
// 82:         return opoo(message) unless GitHub::Actions.env_set?
// 83:
// 84:         require "utils/formatter"
// 85:
// 86:         Tty.with($stderr) do |stderr|
// 87:           stderr.puts Formatter.warning(message, label: "Warning")
// 88:         end
// 89:       end
// 90:
// 91:       # Print a warning message only if not running in GitHub Actions.
// 92:       #
// 93:       # @api public
// 94:       sig { params(message: T.any(String, Exception)).void }
// 95:       def opoo_outside_github_actions(message)
// 96:         require "utils/github/actions"
// 97:         return if GitHub::Actions.env_set?
// 98:
// 99:         opoo(message)
// 100:       end
// 101:
// 102:       # Print an error message.
// 103:       #
// 104:       # @api public
// 105:       # Keep in sync with `onoe` in Library/Homebrew/utils.sh.
// 106:       sig { params(message: T.any(String, Exception)).void }
// 107:       def onoe(message)
// 108:         require "utils/github/actions"
// 109:         return if GitHub::Actions.puts_annotation_if_env_set!(:error, message.to_s)
// 110:
// 111:         require "utils/formatter"
// 112:
// 113:         Tty.with($stderr) do |stderr|
// 114:           stderr.puts Formatter.error(message, label: "Error")
// 115:         end
// 116:       end
// 117:
// 118:       # Print an error message and fail at the end of the program.
// 119:       #
// 120:       # @api public
// 121:       sig { params(error: T.any(String, Exception)).void }
// 122:       def ofail(error)
// 123:         onoe error
// 124:         Homebrew.failed = true
// 125:       end
// 126:
// 127:       sig { params(issues_url: String, homebrew: T::Boolean, read_this: T::Boolean).returns(String) }
// 128:       def issue_reporting_message(issues_url, homebrew: false, read_this: false)
// 129:         formatted_issues_url = Formatter.url(issues_url)
// 130:
// 131:         if read_this
// 132:           Formatter.error(formatted_issues_url, label: "READ THIS")
// 133:         elsif homebrew
// 134:           <<~EOS
// 135:             #{Tty.bold}Please report this issue:#{Tty.reset}
// 136:               #{formatted_issues_url}
// 137:           EOS
// 138:         else
// 139:           <<~EOS
// 140:             If reporting this issue please do so at (not Homebrew/* repositories):
// 141:               #{formatted_issues_url}
// 142:           EOS
// 143:         end
// 144:       end
// 145:
// 146:       # Print an error message and fail immediately.
// 147:       #
// 148:       # @api public
// 149:       # Keep in sync with `odie` in Library/Homebrew/utils.sh.
// 150:       sig { params(error: T.any(String, Exception)).returns(T.noreturn) }
// 151:       def odie(error)
// 152:         onoe error
// 153:         exit 1
// 154:       end
// 155:
// 156:       # Output a deprecation warning/error message.
// 157:       sig {
// 158:         params(method: String, replacement: T.nilable(T.any(String, Symbol)), disable: T::Boolean,
// 159:                disable_on: T.nilable(Time), disable_for_developers: T::Boolean, caller: T::Array[String]).void
// 160:       }
// 161:       def odeprecated(method, replacement = nil,
// 162:                       disable:                false,
// 163:                       disable_on:             nil,
// 164:                       disable_for_developers: true,
// 165:                       caller:                 send(:caller))
// 166:         replacement_message = if replacement
// 167:           "Use #{replacement} instead."
// 168:         else
// 169:           "There is no replacement."
// 170:         end
// 171:
// 172:         unless disable_on.nil?
// 173:           if disable_on > Time.now
// 174:             will_be_disabled_message = " and will be disabled on #{disable_on.strftime("%Y-%m-%d")}"
// 175:           else
// 176:             disable = true
// 177:           end
// 178:         end
// 179:
// 180:         verb = if disable
// 181:           "disabled"
// 182:         else
// 183:           "deprecated#{will_be_disabled_message}"
// 184:         end
// 185:
// 186:         # Try to show the most relevant location in message, i.e. (if applicable):
// 187:         # - Location in a formula.
// 188:         # - Location of caller of deprecated method (if all else fails).
// 189:         backtrace = caller
// 190:
// 191:         # Don't throw deprecations at all for cached, .brew or .metadata files.
// 192:         return if backtrace.any? do |line|
// 193:           next true if line.include?(HOMEBREW_CACHE.to_s)
// 194:           next true if line.include?("/.brew/")
// 195:           next true if line.include?("/.metadata/")
// 196:
// 197:           next false unless line.match?(HOMEBREW_TAP_PATH_REGEX)
// 198:
// 199:           path = Pathname(line.split(":", 2).first)
// 200:           next false unless path.file?
// 201:           next false unless path.readable?
// 202:
// 203:           formula_contents = path.read
// 204:           formula_contents.include?(" deprecate! ") || formula_contents.include?(" disable! ")
// 205:         end
// 206:
// 207:         tap_message = T.let(nil, T.nilable(String))
// 208:
// 209:         backtrace.each do |line|
// 210:           next unless (match = line.match(HOMEBREW_TAP_PATH_REGEX))
// 211:
// 212:           require "tap"
// 213:
// 214:           tap = Tap.fetch(match[:user], match[:repository])
// 215:           tap_message = "\nPlease report this issue to the #{tap.full_name} tap"
// 216:           tap_message += " (not Homebrew/* repositories)" unless tap.official?
// 217:           tap_message += ", or even better, submit a PR to fix it" if replacement
// 218:           tap_message << ":\n  #{line.sub(/^(.*:\d+):.*$/, '\1')}\n\n"
// 219:           break
// 220:         end
// 221:         file, line, = backtrace.first.split(":")
// 222:         line = line.to_i if line.present?
// 223:
// 224:         message = "Calling #{method} is #{verb}! #{replacement_message}"
// 225:         message << tap_message if tap_message
// 226:         message.freeze
// 227:
// 228:         disable = true if disable_for_developers && Homebrew::EnvConfig.developer?
// 229:         if disable || Homebrew.raise_deprecation_exceptions?
// 230:           require "utils/github/actions"
// 231:           GitHub::Actions.puts_annotation_if_env_set!(:error, message, file:, line:)
// 232:           exception = MethodDeprecatedError.new(message)
// 233:           exception.set_backtrace(backtrace)
// 234:           raise exception
// 235:         elsif !Homebrew.auditing?
// 236:           opoo message
// 237:         end
// 238:       end
// 239:
// 240:       sig {
// 241:         params(method: String, replacement: T.nilable(T.any(String, Symbol)),
// 242:                disable_on: T.nilable(Time), disable_for_developers: T::Boolean, caller: T::Array[String]).void
// 243:       }
// 244:       def odisabled(method, replacement = nil,
// 245:                     disable_on:             nil,
// 246:                     disable_for_developers: true,
// 247:                     caller:                 send(:caller))
// 248:         # This odeprecated should stick around indefinitely.
// 249:         odeprecated(method, replacement, disable: true, disable_on:, disable_for_developers:, caller:)
// 250:       end
// 251:
// 252:       # Keep status labels, colours and emoji in sync with
// 253:       # `pretty_installed` in Library/Homebrew/utils.sh.
// 254:       sig { params(string: String).returns(String) }
// 255:       def pretty_installed(string)
// 256:         if !$stdout.tty?
// 257:           string
// 258:         elsif Homebrew::EnvConfig.no_emoji?
// 259:           Formatter.success("#{Tty.bold}#{string} (installed)#{Tty.reset}")
// 260:         else
// 261:           "#{Tty.bold}#{string} #{Formatter.success("✔")}#{Tty.reset}"
// 262:         end
// 263:       end
// 264:
// 265:       sig { params(string: String, bold: T::Boolean).returns(String) }
// 266:       def pretty_upgradable(string, bold: true)
// 267:         weight = bold ? Tty.bold.to_s : ""
// 268:         if !$stdout.tty?
// 269:           string
// 270:         elsif Homebrew::EnvConfig.no_emoji?
// 271:           "#{weight}#{string} (upgradable)#{Tty.reset}"
// 272:         else
// 273:           "#{weight}#{string} #{Formatter.success("↑")}#{Tty.reset}"
// 274:         end
// 275:       end
// 276:
// 277:       sig { params(string: String).returns(String) }
// 278:       def pretty_deprecated(string)
// 279:         if $stdout.tty?
// 280:           "#{string} #{Formatter.warning("(deprecated)")}"
// 281:         else
// 282:           string
// 283:         end
// 284:       end
// 285:
// 286:       sig { params(string: String).returns(String) }
// 287:       def pretty_disabled(string)
// 288:         if $stdout.tty?
// 289:           "#{string} #{Formatter.error("(disabled)")}"
// 290:         else
// 291:           string
// 292:         end
// 293:       end
// 294:
// 295:       # Keep status labels, colours and emoji in sync with
// 296:       # `pretty_uninstalled` in Library/Homebrew/utils.sh.
// 297:       sig { params(string: String, bold: T::Boolean).returns(String) }
// 298:       def pretty_uninstalled(string, bold: true)
// 299:         weight = bold ? Tty.bold.to_s : ""
// 300:         if !$stdout.tty?
// 301:           string
// 302:         elsif Homebrew::EnvConfig.no_emoji?
// 303:           Formatter.error("#{weight}#{string} (uninstalled)#{Tty.reset}")
// 304:         else
// 305:           "#{weight}#{string} #{Formatter.error("✘")}#{Tty.reset}"
// 306:         end
// 307:       end
// 308:
// 309:       sig { params(string: String, bold: T::Boolean).returns(String) }
// 310:       def pretty_unmarked(string, bold: true)
// 311:         if bold && $stdout.tty?
// 312:           "#{Tty.bold}#{string}#{Tty.reset}"
// 313:         else
// 314:           string
// 315:         end
// 316:       end
// 317:
// 318:       sig { params(string: String, bold: T::Boolean).returns(String) }
// 319:       def pretty_warning(string, bold: true)
// 320:         weight = bold ? Tty.bold.to_s : ""
// 321:         if !$stdout.tty?
// 322:           string
// 323:         elsif Homebrew::EnvConfig.no_emoji?
// 324:           Formatter.warning("#{weight}#{string} (warning)#{Tty.reset}")
// 325:         else
// 326:           "#{weight}#{string} #{Formatter.warning("⚠")}#{Tty.reset}"
// 327:         end
// 328:       end
// 329:
// 330:       sig {
// 331:         params(string: String, installed: T::Boolean, warning: T::Boolean, outdated: T::Boolean,
// 332:                deprecated: T::Boolean, disabled: T::Boolean, mark_uninstalled: T::Boolean,
// 333:                bold: T.nilable(T::Boolean)).returns(String)
// 334:       }
// 335:       def pretty_install_status(string, installed:, warning: false, outdated: false, deprecated: false,
// 336:                                 disabled: false, mark_uninstalled: true, bold: nil)
// 337:         bold = installed if bold.nil?
// 338:         status = if warning
// 339:           pretty_warning(string, bold:)
// 340:         elsif installed && outdated
// 341:           pretty_upgradable(string, bold:)
// 342:         elsif installed
// 343:           pretty_installed(string)
// 344:         elsif mark_uninstalled
// 345:           pretty_uninstalled(string, bold:)
// 346:         else
// 347:           pretty_unmarked(string, bold:)
// 348:         end
// 349:         if disabled
// 350:           pretty_disabled(status)
// 351:         elsif deprecated
// 352:           pretty_deprecated(status)
// 353:         else
// 354:           status
// 355:         end
// 356:       end
// 357:
// 358:       sig { params(seconds: T.nilable(T.any(Integer, Float))).returns(String) }
// 359:       def pretty_duration(seconds)
// 360:         seconds = seconds.to_i
// 361:         hide_seconds = seconds > 300
// 362:
// 363:         minutes, seconds = seconds.divmod(60)
// 364:         hours, minutes = minutes.divmod(60)
// 365:
// 366:         res = +""
// 367:
// 368:         if hours.positive?
// 369:           res << Utils.pluralize("hour", hours, include_count: true)
// 370:           return res.freeze if minutes.zero?
// 371:
// 372:           res << " " << Utils.pluralize("minute", minutes, include_count: true)
// 373:           return res.freeze
// 374:         end
// 375:
// 376:         if minutes.positive?
// 377:           res << Utils.pluralize("minute", minutes, include_count: true)
// 378:           return res.freeze if hide_seconds || seconds.zero?
// 379:
// 380:           res << " "
// 381:         end
// 382:
// 383:         res << Utils.pluralize("second", seconds, include_count: true)
// 384:         res.freeze
// 385:       end
// 386:     end
// 387:
// 388:     extend Mixin
// 389:     $stdout.extend Mixin
// 390:     $stderr.extend Mixin
// 391:   end
// 392: end
