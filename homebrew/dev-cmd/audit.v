module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/audit.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 98.
pub fn ruby_audit_l98_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `cask_for_audit(path, cask_audit_os, cask_audit_arch)` at line 365.
pub fn ruby_audit_l365_d2_cask_for_audit(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_for_audit', ...args)
}

// Ruby method `print_problems(results)` at line 390.
pub fn ruby_audit_l390_d3_print_problems(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('print_problems', ...args)
}

// Ruby method `format_problem_lines(problems)` at line 405.
pub fn ruby_audit_l405_d4_format_problem_lines(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('format_problem_lines', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6: require "utils/curl"
// 7: require "utils/github/actions"
// 8: require "utils/spdx"
// 9: require "extend/ENV"
// 10: require "formula_cellar_checks"
// 11: require "cmd/search"
// 12: require "style"
// 13: require "date"
// 14: require "missing_formula"
// 15: require "digest"
// 16: require "json"
// 17: require "formula_auditor"
// 18: require "tap_auditor"
// 19: require "utils/git"
// 20:
// 21: module Homebrew
// 22:   module DevCmd
// 23:     class Audit < AbstractCommand
// 24:       cmd_args do
// 25:         description <<~EOS
// 26:           Check <formula> or <cask> for Homebrew coding style violations. This should be run
// 27:           before submitting a new formula or cask. If no <formula> or <cask> are provided, check
// 28:           all locally available formulae and casks and skip style checks. Will exit with a
// 29:           non-zero status if any errors are found.
// 30:         EOS
// 31:         flag   "--os=",
// 32:                description: "Audit the given operating system. (Pass `all` to audit all operating systems.)"
// 33:         flag   "--arch=",
// 34:                description: "Audit the given CPU architecture. (Pass `all` to audit all architectures.)"
// 35:         switch "--strict",
// 36:                description: "Run additional, stricter style checks."
// 37:         switch "--git",
// 38:                description: "Run additional, slower style checks that navigate the Git repository."
// 39:         switch "--online",
// 40:                description: "Run additional, slower style checks that require a network connection."
// 41:         switch "--installed",
// 42:                description: "Only check formulae and casks that are currently installed."
// 43:         switch "--eval-all",
// 44:                description: "Evaluate all available formulae and casks, whether installed or not, to audit them.",
// 45:                env:         :eval_all,
// 46:                odeprecated: true
// 47:         switch "--new",
// 48:                description: "Run various additional style checks to determine if a new formula or cask is eligible " \
// 49:                             "for Homebrew. This should be used when creating new formulae or casks and implies " \
// 50:                             "`--strict` and `--online`."
// 51:         switch "--[no-]signing",
// 52:                description: "Audit for app signatures, which are required by macOS on ARM.",
// 53:                odeprecated: true
// 54:         switch "--changed",
// 55:                description: "Check files that were changed from the `main` branch."
// 56:         flag   "--tap=",
// 57:                description: "Check formulae and casks within the given tap, specified as <user>`/`<repo>."
// 58:         switch "--fix",
// 59:                description: "Fix style violations automatically using RuboCop's auto-correct feature."
// 60:         switch "--display-cop-names",
// 61:                description: "Include the RuboCop cop name for each violation in the output. This is the default.",
// 62:                hidden:      true
// 63:         switch "--display-filename",
// 64:                description: "Prefix every line of output with the file or formula name being audited, to " \
// 65:                             "make output easy to grep."
// 66:         switch "--skip-style",
// 67:                description: "Skip running non-RuboCop style checks. Useful if you plan on running " \
// 68:                             "`brew style` separately. Enabled by default unless a formula is specified by name."
// 69:         switch "-D", "--audit-debug",
// 70:                description: "Enable debugging and profiling of audit methods."
// 71:         comma_array "--only",
// 72:                     description: "Specify a comma-separated <method> list to only run the methods named " \
// 73:                                  "`audit_`<method>."
// 74:         comma_array "--except",
// 75:                     description: "Specify a comma-separated <method> list to skip running the methods named " \
// 76:                                  "`audit_`<method>."
// 77:         comma_array "--only-cops",
// 78:                     description: "Specify a comma-separated <cops> list to check for violations of only the listed " \
// 79:                                  "RuboCop cops."
// 80:         comma_array "--except-cops",
// 81:                     description: "Specify a comma-separated <cops> list to skip checking for violations of the " \
// 82:                                  "listed RuboCop cops."
// 83:         switch "--formula", "--formulae",
// 84:                description: "Treat all named arguments as formulae."
// 85:         switch "--cask", "--casks",
// 86:                description: "Treat all named arguments as casks."
// 87:
// 88:         conflicts "--installed", "--eval-all", "--changed", "--tap"
// 89:         conflicts "--only", "--except"
// 90:         conflicts "--only-cops", "--except-cops", "--strict"
// 91:         conflicts "--only-cops", "--except-cops", "--only"
// 92:         conflicts "--formula", "--cask"
// 93:
// 94:         named_args [:formula, :cask], without_api: true
// 95:       end
// 96:
// 97:       sig { override.void }
// 98:       def run
// 99:         Formulary.enable_factory_cache!
// 100:
// 101:         os_arch_combinations = args.os_arch_combinations
// 102:         cask_audit_os, cask_audit_arch =
// 103:           os_arch_combinations.find { |os, _arch| os != :linux } || os_arch_combinations.fetch(0)
// 104:
// 105:         Homebrew.auditing = true
// 106:         Homebrew.inject_dump_stats!(FormulaAuditor, /^audit_/) if args.audit_debug?
// 107:
// 108:         strict = args.new? || args.strict?
// 109:         online = args.new? || args.online?
// 110:         tap_audit = args.tap.present?
// 111:         skip_style = args.skip_style? || args.no_named? || tap_audit
// 112:         no_named_args = T.let(false, T::Boolean)
// 113:
// 114:         gem_groups = ["audit", "ast"]
// 115:         gem_groups << "style" unless skip_style
// 116:         Homebrew.install_bundler_gems!(groups: gem_groups)
// 117:         require "utils/ast"
// 118:
// 119:         ENV.activate_extensions!
// 120:         ENV.setup_build_environment
// 121:
// 122:         audit_formulae, audit_casks = Homebrew.with_no_api_env do # audit requires full Ruby source
// 123:           if args.changed?
// 124:             tap = Tap.from_path(Dir.pwd)
// 125:             odie "`brew audit --changed` must be run inside a tap!" if tap.blank?
// 126:
// 127:             no_named_args = true
// 128:
// 129:             audit_formulae = []
// 130:             audit_casks = []
// 131:
// 132:             Utils::Git.changed_files(tap.path).each do |file|
// 133:               next unless file.end_with?(".rb")
// 134:
// 135:               absolute_file = File.expand_path(file, tap.path)
// 136:               next unless File.exist?(absolute_file)
// 137:
// 138:               if tap.formula_file?(file)
// 139:                 audit_formulae << Formulary.factory(absolute_file)
// 140:               elsif tap.cask_file?(file) && (cask = cask_for_audit(absolute_file, cask_audit_os, cask_audit_arch))
// 141:                 audit_casks << cask
// 142:               end
// 143:             end
// 144:
// 145:             [audit_formulae, audit_casks]
// 146:           elsif args.tap
// 147:             Tap.fetch(args.tap).then do |tap|
// 148:               [
// 149:                 tap.formula_files.map { |path| Formulary.factory(path) },
// 150:                 tap.cask_files.filter_map { |path| cask_for_audit(path, cask_audit_os, cask_audit_arch) },
// 151:               ]
// 152:             end
// 153:           elsif args.installed?
// 154:             no_named_args = true
// 155:             [Formula.installed, Cask::Caskroom.casks]
// 156:           elsif args.no_named?
// 157:             eval_all = args.eval_all?
// 158:             eval_all ||= Homebrew::EnvConfig.tap_trust_configured?
// 159:
// 160:             unless eval_all
// 161:               # This odisabled should probably stick around indefinitely.
// 162:               odisabled "`brew audit`",
// 163:                         "set `HOMEBREW_REQUIRE_TAP_TRUST=1`"
// 164:             end
// 165:             no_named_args = true
// 166:             [
// 167:               Formula.all(eval_all:),
// 168:               Cask::Cask.all(eval_all:),
// 169:             ]
// 170:           else
// 171:             if args.named.any? { |named_arg| named_arg.end_with?(".rb") }
// 172:               # This odisabled should probably stick around indefinitely,
// 173:               # until at least we have a way to exclude error on these in the CLI parser.
// 174:               odisabled "`brew audit [path ...]`",
// 175:                         "`brew audit [name ...]`"
// 176:             end
// 177:
// 178:             args.named.to_formulae_and_casks_with_taps
// 179:                 .partition { |formula_or_cask| formula_or_cask.is_a?(Formula) }
// 180:           end
// 181:         end
// 182:
// 183:         if audit_formulae.empty? && audit_casks.empty? && !args.tap
// 184:           ofail "No matching formulae or casks to audit!"
// 185:           return
// 186:         end
// 187:
// 188:         style_files = args.named.to_paths unless skip_style
// 189:
// 190:         only_cops = args.only_cops
// 191:         except_cops = args.except_cops
// 192:         style_options = { fix: args.fix?, debug: args.debug?, verbose: args.verbose? }
// 193:
// 194:         if only_cops
// 195:           style_options[:only_cops] = only_cops
// 196:         elsif args.new?
// 197:           nil
// 198:         elsif except_cops
// 199:           style_options[:except_cops] = except_cops
// 200:         elsif !strict
// 201:           style_options[:except_cops] = %w[FormulaAuditStrict]
// 202:         end
// 203:
// 204:         # Run tap audits first
// 205:         named_arg_taps = [*audit_formulae, *audit_casks].map(&:tap).uniq if !args.tap && !no_named_args
// 206:         tap_problems = Tap.installed.each_with_object({}) do |tap, problems|
// 207:           next if args.tap && tap != args.tap
// 208:           next if named_arg_taps&.exclude?(tap)
// 209:
// 210:           ta = TapAuditor.new(tap, strict: args.strict?)
// 211:           ta.audit
// 212:
// 213:           problems[[tap.name, tap.path]] = ta.problems if ta.problems.any?
// 214:         end
// 215:
// 216:         # Check style in a single batch run up front for performance
// 217:         style_offenses = Style.check_style_json(style_files, **style_options) if style_files
// 218:         # load licenses
// 219:         spdx_license_data = SPDX.license_data
// 220:         spdx_exception_data = SPDX.exception_data
// 221:
// 222:         formula_problems = audit_formulae.sort.each_with_object({}) do |f, problems|
// 223:           path = f.path
// 224:
// 225:           only = only_cops ? ["style"] : args.only
// 226:           options = {
// 227:             new_formula:         args.new?,
// 228:             strict:,
// 229:             online:,
// 230:             git:                 args.git?,
// 231:             only:,
// 232:             except:              args.except,
// 233:             spdx_license_data:,
// 234:             spdx_exception_data:,
// 235:             style_offenses:      style_offenses&.for_path(f.path),
// 236:             tap_audit:,
// 237:           }.compact
// 238:
// 239:           errors = os_arch_combinations.flat_map do |os, arch|
// 240:             SimulateSystem.with(os:, arch:) do
// 241:               odebug "Auditing Formula #{f} on os #{os} and arch #{arch}"
// 242:
// 243:               audit_proc = proc { FormulaAuditor.new(Formulary.factory(path), **options).tap(&:audit) }
// 244:
// 245:               # Audit requires full Ruby source so disable API. We shouldn't do this for taps however so that we
// 246:               # don't unnecessarily require a full Homebrew/core clone.
// 247:               fa = if f.core_formula?
// 248:                 Homebrew.with_no_api_env(&audit_proc)
// 249:               elsif Homebrew::EnvConfig.automatically_set_no_install_from_api?
// 250:                 with_env(
// 251:                   HOMEBREW_NO_INSTALL_FROM_API:                   nil,
// 252:                   HOMEBREW_AUTOMATICALLY_SET_NO_INSTALL_FROM_API: nil,
// 253:                   &audit_proc
// 254:                 )
// 255:               else
// 256:                 audit_proc.call
// 257:               end
// 258:
// 259:               fa.problems + fa.new_formula_problems
// 260:             end
// 261:           end.uniq
// 262:
// 263:           problems[[f.full_name, path]] = errors if errors.any?
// 264:         end
// 265:
// 266:         require "cask/auditor" if audit_casks.any?
// 267:
// 268:         cask_problems = audit_casks.each_with_object({}) do |cask, problems|
// 269:           path = cask.sourcefile_path
// 270:
// 271:           errors = os_arch_combinations.flat_map do |os, arch|
// 272:             # Linux-only casks have no stanza values for macOS, so audit them
// 273:             # under Linux instead.
// 274:             os = :linux if os != :linux && !cask.supports_macos?
// 275:
// 276:             SimulateSystem.with(os:, arch:) do
// 277:               odebug "Auditing Cask #{cask} on os #{os} and arch #{arch}"
// 278:
// 279:               Cask::Auditor.audit(
// 280:                 Cask::CaskLoader.load(path),
// 281:                 # For switches, we add `|| nil` so that `nil` will be passed
// 282:                 # instead of `false` if they aren't set.
// 283:                 # This way, we can distinguish between "not set" and "set to false".
// 284:                 audit_online:   args.online? || nil,
// 285:                 audit_strict:   args.strict? || nil,
// 286:
// 287:                 # No need for `|| nil` for `--[no-]signing`
// 288:                 # because boolean switches are already `nil` if not passed
// 289:                 audit_signing:  args.signing?,
// 290:                 audit_new_cask: args.new? || nil,
// 291:                 any_named_args: !no_named_args,
// 292:                 only:           args.only || [],
// 293:                 except:         args.except || [],
// 294:               ).to_a
// 295:             end
// 296:           end.uniq
// 297:
// 298:           problems[[cask.full_name, path]] = errors if errors.any?
// 299:         end
// 300:
// 301:         print_problems(tap_problems)
// 302:         print_problems(formula_problems)
// 303:         print_problems(cask_problems)
// 304:
// 305:         tap_count = tap_problems.keys.count
// 306:         formula_count = formula_problems.keys.count
// 307:         cask_count = cask_problems.keys.count
// 308:
// 309:         corrected_problem_count = (formula_problems.values + cask_problems.values)
// 310:                                   .sum { |problems| problems.count { |problem| problem.fetch(:corrected) } }
// 311:
// 312:         tap_problem_count = tap_problems.sum { |_, problems| problems.count }
// 313:         formula_problem_count = formula_problems.sum { |_, problems| problems.count }
// 314:         cask_problem_count = cask_problems.sum { |_, problems| problems.count }
// 315:         total_problems_count = formula_problem_count + cask_problem_count + tap_problem_count
// 316:
// 317:         if total_problems_count.positive?
// 318:           errors_summary = Utils.pluralize("problem", total_problems_count, include_count: true)
// 319:
// 320:           error_sources = []
// 321:           error_sources << Utils.pluralize("formula", formula_count, include_count: true) if formula_count.positive?
// 322:           error_sources << Utils.pluralize("cask", cask_count, include_count: true) if cask_count.positive?
// 323:           error_sources << Utils.pluralize("tap", tap_count, include_count: true) if tap_count.positive?
// 324:
// 325:           errors_summary += " in #{error_sources.to_sentence}" if error_sources.any?
// 326:
// 327:           errors_summary += " detected"
// 328:
// 329:           if corrected_problem_count.positive?
// 330:             errors_summary +=
// 331:               ", #{Utils.pluralize("problem", corrected_problem_count, include_count: true)} corrected"
// 332:           end
// 333:
// 334:           ofail "#{errors_summary}."
// 335:         end
// 336:
// 337:         return unless GitHub::Actions.env_set?
// 338:
// 339:         annotations = formula_problems.merge(cask_problems).flat_map do |(_, path), problems|
// 340:           problems.map do |problem|
// 341:             GitHub::Actions::Annotation.new(
// 342:               :error,
// 343:               problem[:message],
// 344:               file:   path,
// 345:               line:   problem[:location]&.line,
// 346:               column: problem[:location]&.column,
// 347:             )
// 348:           end
// 349:         end.compact
// 350:
// 351:         annotations.each do |annotation|
// 352:           puts annotation if annotation.relevant?
// 353:         end
// 354:       end
// 355:
// 356:       private
// 357:
// 358:       sig {
// 359:         params(
// 360:           path:            T.any(String, Pathname),
// 361:           cask_audit_os:   Symbol,
// 362:           cask_audit_arch: Symbol,
// 363:         ).returns(T.nilable(Cask::Cask))
// 364:       }
// 365:       def cask_for_audit(path, cask_audit_os, cask_audit_arch)
// 366:         if cask_audit_os == :linux
// 367:           return if Utils::AST::CaskAST.new(Pathname(path).read).depends_on_macos?
// 368:
// 369:           cask = SimulateSystem.with(os: :macos, arch: cask_audit_arch) do
// 370:             loaded_cask = Cask::CaskLoader.load(path)
// 371:             loaded_cask if loaded_cask.supports_linux?
// 372:           end
// 373:           return unless cask
// 374:
// 375:           SimulateSystem.with(os: :linux, arch: cask_audit_arch) { cask.refresh }
// 376:           return cask
// 377:         end
// 378:
// 379:         SimulateSystem.with(os: cask_audit_os, arch: cask_audit_arch) { Cask::CaskLoader.load(path) }
// 380:       end
// 381:
// 382:       sig {
// 383:         params(
// 384:           results: T::Hash[
// 385:             T::Array[T.any(String, Pathname)],
// 386:             T::Array[T::Hash[Symbol, T.untyped]],
// 387:           ],
// 388:         ).void
// 389:       }
// 390:       def print_problems(results)
// 391:         results.each do |(name, path), problems|
// 392:           problem_lines = format_problem_lines(problems)
// 393:
// 394:           if args.display_filename?
// 395:             problem_lines.each do |l|
// 396:               puts "#{path}: #{l}"
// 397:             end
// 398:           else
// 399:             puts name, problem_lines.map { |l| l.dup.prepend("  ") }
// 400:           end
// 401:         end
// 402:       end
// 403:
// 404:       sig { params(problems: T::Array[T::Hash[Symbol, T.untyped]]).returns(T::Array[String]) }
// 405:       def format_problem_lines(problems)
// 406:         problems.map do |problem|
// 407:           status = " #{Formatter.success("[corrected]")}" if problem.fetch(:corrected)
// 408:           location = problem.fetch(:location)
// 409:           if location
// 410:             location = "#{location.line&.to_s&.prepend("line ")}#{location.column&.to_s&.prepend(", col ")}: "
// 411:           end
// 412:           message = problem.fetch(:message)
// 413:           "* #{location}#{message.chomp.gsub("\n", "\n    ")}#{status}"
// 414:         end
// 415:       end
// 416:     end
// 417:   end
// 418: end
