module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/reinstall.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 124.
pub fn ruby_reinstall_l124_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula_installer"
// 6: require "development_tools"
// 7: require "messages"
// 8: require "install"
// 9: require "reinstall"
// 10: require "cleanup"
// 11: require "cask/utils"
// 12: require "cask/reinstall"
// 13: require "upgrade"
// 14: require "api"
// 15: require "trust"
// 16:
// 17: module Homebrew
// 18:   module Cmd
// 19:     class Reinstall < AbstractCommand
// 20:       cmd_args do
// 21:         description <<~EOS
// 22:           Uninstall and then reinstall a <formula> or <cask> using the same options it was
// 23:           originally installed with, plus any appended options specific to a <formula>.
// 24:
// 25:           Unless `$HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK` is set, `brew upgrade` or `brew reinstall` will be run for
// 26:           outdated dependents and dependents with broken linkage, respectively.
// 27:
// 28:           Unless `$HOMEBREW_NO_INSTALL_CLEANUP` is set, `brew cleanup` will then be run for the
// 29:           reinstalled formulae or, every 30 days, for all formulae.
// 30:         EOS
// 31:         switch "-d", "--debug",
// 32:                description: "If brewing fails, open an interactive debugging session with access to IRB " \
// 33:                             "or a shell inside the temporary build directory."
// 34:         switch "--display-times",
// 35:                description: "Print install times for each package at the end of the run.",
// 36:                env:         :display_install_times
// 37:         switch "-f", "--force",
// 38:                description: "Install without checking for previously installed keg-only or " \
// 39:                             "non-migrated versions."
// 40:         switch "-v", "--verbose",
// 41:                description: "Print the verification and post-install steps."
// 42:         switch "--no-ask", "--yes", "-y",
// 43:                description: "Do not ask for confirmation before downloading and reinstalling. " \
// 44:                             "Ask mode is the default.",
// 45:                env:         :no_ask
// 46:         switch "--ask",
// 47:                description: "Ask for confirmation before downloading and reinstalling. " \
// 48:                             "Print what would be reinstalled before prompting. Only prompts if the plan " \
// 49:                             "includes dependencies or dependants; if the requested formulae or casks are the " \
// 50:                             "only things to reinstall, it only prints the plan. The confirmation prompt is " \
// 51:                             "skipped without a TTY. This is the default unless `$HOMEBREW_NO_ASK` is set.",
// 52:                env:         :ask,
// 53:                replacement: "the default behaviour",
// 54:                odeprecated: true
// 55:         [
// 56:           [:switch, "--formula", "--formulae", {
// 57:             description: "Treat all named arguments as formulae.",
// 58:           }],
// 59:           [:switch, "-s", "--build-from-source", {
// 60:             description: "Compile <formula> from source even if a bottle is available.",
// 61:           }],
// 62:           [:switch, "-i", "--interactive", {
// 63:             description: "Download and patch <formula>, then open a shell. This allows the user to " \
// 64:                          "run `./configure --help` and otherwise determine how to turn the software " \
// 65:                          "package into a Homebrew package.",
// 66:           }],
// 67:           [:switch, "--force-bottle", {
// 68:             description: "Install from a bottle if it exists for the current or newest version of " \
// 69:                          "macOS, even if it would not normally be used for installation.",
// 70:           }],
// 71:           [:switch, "--keep-tmp", {
// 72:             description: "Retain the temporary files created during installation.",
// 73:           }],
// 74:           [:switch, "--debug-symbols", {
// 75:             depends_on:  "--build-from-source",
// 76:             description: "Generate debug symbols on build. Source will be retained in a cache directory.",
// 77:           }],
// 78:           [:switch, "-g", "--git", {
// 79:             description: "Create a Git repository, useful for creating patches to the software.",
// 80:           }],
// 81:         ].each do |args|
// 82:           options = args.pop
// 83:           send(*args, **options)
// 84:           conflicts "--cask", args.last
// 85:         end
// 86:         formula_options
// 87:         [
// 88:           [:switch, "--cask", "--casks", {
// 89:             description: "Treat all named arguments as casks.",
// 90:           }],
// 91:           [:switch, "--[no-]binaries", {
// 92:             description: "Disable/enable linking of helper executables (default: enabled).",
// 93:             env:         :cask_opts_binaries,
// 94:           }],
// 95:           [:switch, "--require-sha", {
// 96:             description: "Require all casks to have a checksum.",
// 97:             env:         :cask_opts_require_sha,
// 98:           }],
// 99:           [:switch, "--adopt", {
// 100:             description: "Adopt existing artifacts in the destination that are identical to those being installed. " \
// 101:                          "Cannot be combined with `--force`.",
// 102:           }],
// 103:           [:switch, "--skip-cask-deps", {
// 104:             description: "Skip installing cask dependencies.",
// 105:           }],
// 106:           [:switch, "--zap", {
// 107:             description: "For use with `brew reinstall --cask`. Remove all files associated with a cask. " \
// 108:                          "*May remove files which are shared between applications.*",
// 109:           }],
// 110:         ].each do |args|
// 111:           options = args.pop
// 112:           send(*args, **options)
// 113:           conflicts "--formula", args.last
// 114:         end
// 115:         cask_options
// 116:
// 117:         conflicts "--build-from-source", "--force-bottle"
// 118:         conflicts "--ask", "--no-ask"
// 119:
// 120:         named_args [:formula, :cask], min: 1
// 121:       end
// 122:
// 123:       sig { override.void }
// 124:       def run
// 125:         formulae = T.let([], T::Array[Formula])
// 126:         casks = T.let([], T::Array[Cask::Cask])
// 127:         unavailable_errors = T.let(
// 128:           [],
// 129:           T::Array[T.any(FormulaOrCaskUnavailableError, NoSuchKegError)],
// 130:         )
// 131:         Homebrew::Trust.trust_fully_qualified_items!(args.named, type: args.only_formula_or_cask)
// 132:         ask = !args.no_ask?
// 133:
// 134:         args.named.to_formulae_and_casks_and_unavailable(method: :resolve).each do |item|
// 135:           case item
// 136:           when FormulaOrCaskUnavailableError, NoSuchKegError
// 137:             unavailable_errors << item
// 138:           when Formula
// 139:             formulae << item
// 140:           when Cask::Cask
// 141:             casks << item
// 142:           end
// 143:         end
// 144:
// 145:         if args.build_from_source?
// 146:           unless DevelopmentTools.installed?
// 147:             raise BuildFlagsError.new(["--build-from-source"], bottled: formulae.all?(&:bottled?))
// 148:           end
// 149:
// 150:           unless Homebrew::EnvConfig.developer?
// 151:             opoo "building from source is not supported!"
// 152:             puts "You're on your own. Failures are expected so don't create any issues, please!"
// 153:           end
// 154:         end
// 155:
// 156:         if Homebrew::EnvConfig.verify_attestations?
// 157:           formulae = Homebrew::Attestation.sort_formulae_for_install(formulae)
// 158:         end
// 159:         casks = casks.filter_map do |cask|
// 160:           if cask.pinned?
// 161:             onoe "#{cask.full_name} is pinned. You must unpin it to reinstall."
// 162:             next
// 163:           end
// 164:           cask
// 165:         end
// 166:         shared_download_queue = T.let(nil, T.nilable(Homebrew::DownloadQueue))
// 167:         casks_prefetched = T.let(false, T::Boolean)
// 168:
// 169:         Install.ask_casks casks, action: "reinstallation", skip_cask_deps: args.skip_cask_deps? if ask
// 170:
// 171:         unless formulae.empty?
// 172:           Install.perform_preinstall_checks_once
// 173:
// 174:           reinstall_contexts = formulae.filter_map do |formula|
// 175:             if formula.pinned?
// 176:               onoe "#{formula.full_name} is pinned. You must unpin it to reinstall."
// 177:               next
// 178:             end
// 179:             Migrator.migrate_if_needed(formula, force: args.force?)
// 180:             Homebrew::Reinstall.build_install_context(
// 181:               formula.latest_formula,
// 182:               flags:                      args.flags_only,
// 183:               force_bottle:               args.force_bottle?,
// 184:               build_from_source_formulae: args.build_from_source_formulae,
// 185:               interactive:                args.interactive?,
// 186:               keep_tmp:                   args.keep_tmp?,
// 187:               debug_symbols:              args.debug_symbols?,
// 188:               force:                      args.force?,
// 189:               debug:                      args.debug?,
// 190:               quiet:                      args.quiet?,
// 191:               verbose:                    args.verbose?,
// 192:               git:                        args.git?,
// 193:             )
// 194:           end
// 195:
// 196:           formulae_installers = reinstall_contexts.map(&:formula_installer)
// 197:           if !ask && formulae_installers.any?
// 198:             download_queue = Homebrew::DownloadQueue.new(pour: true)
// 199:             shared_download_queue = download_queue
// 200:             formulae_installers = Install.prelude_fetch_formulae(formulae_installers, download_queue:)
// 201:           end
// 202:
// 203:           dependants = begin
// 204:             Upgrade.dependants(
// 205:               formulae,
// 206:               flags:                      args.flags_only,
// 207:               ask:                        ask,
// 208:               force_bottle:               args.force_bottle?,
// 209:               build_from_source_formulae: args.build_from_source_formulae,
// 210:               interactive:                args.interactive?,
// 211:               keep_tmp:                   args.keep_tmp?,
// 212:               debug_symbols:              args.debug_symbols?,
// 213:               force:                      args.force?,
// 214:               debug:                      args.debug?,
// 215:               quiet:                      args.quiet?,
// 216:               verbose:                    args.verbose?,
// 217:             )
// 218:           # Ensure the early download queue is shut down on interrupts.
// 219:           rescue Exception # rubocop:disable Lint/RescueException
// 220:             shared_download_queue&.shutdown
// 221:             raise
// 222:           end
// 223:
// 224:           # Main block: if asking the user is enabled, show dry-run information.
// 225:           if ask
// 226:             Install.ask_formulae(
// 227:               formulae_installers,
// 228:               dependants,
// 229:               action:                     "reinstallation",
// 230:               flags:                      args.flags_only,
// 231:               force_bottle:               args.force_bottle?,
// 232:               build_from_source_formulae: args.build_from_source_formulae,
// 233:               interactive:                args.interactive?,
// 234:               keep_tmp:                   args.keep_tmp?,
// 235:               debug_symbols:              args.debug_symbols?,
// 236:               force:                      args.force?,
// 237:               debug:                      args.debug?,
// 238:               quiet:                      args.quiet?,
// 239:               verbose:                    args.verbose?,
// 240:             )
// 241:           end
// 242:
// 243:           valid_formula_installers = if casks.any?
// 244:             shared_download_queue ||= Homebrew::DownloadQueue.new(pour: true)
// 245:             download_queue = shared_download_queue
// 246:             begin
// 247:               valid_formula_installers = Install.enqueue_formulae(formulae_installers,
// 248:                                                                   download_queue:)
// 249:
// 250:               require "cask/installer"
// 251:               fetch_cask_installers = casks.map do |cask|
// 252:                 Cask::Installer.new(
// 253:                   cask,
// 254:                   binaries:       args.binaries?,
// 255:                   verbose:        args.verbose?,
// 256:                   force:          args.force?,
// 257:                   skip_cask_deps: args.skip_cask_deps?,
// 258:                   require_sha:    args.require_sha?,
// 259:                   reinstall:      true,
// 260:                   zap:            args.zap?,
// 261:                   download_queue:,
// 262:                   defer_fetch:    true,
// 263:                 )
// 264:               end
// 265:               Install.enqueue_cask_installers(fetch_cask_installers, download_queue:)
// 266:               download_queue.fetch(heading: Install.combined_fetch_downloads_heading(
// 267:                 formula_names: valid_formula_installers.map { |fi| fi.formula.name },
// 268:                 cask_names:    casks.map(&:full_name),
// 269:               ))
// 270:               casks_prefetched = true
// 271:               Install.reject_failed_downloads(valid_formula_installers, download_queue:)
// 272:             ensure
// 273:               download_queue.shutdown
// 274:             end
// 275:           elsif shared_download_queue
// 276:             download_queue = shared_download_queue
// 277:             begin
// 278:               Install.fetch_formulae(formulae_installers,
// 279:                                      download_queue:,
// 280:                                      shutdown_download_queue: false)
// 281:             ensure
// 282:               download_queue.shutdown
// 283:             end
// 284:           else
// 285:             Install.fetch_formulae(formulae_installers)
// 286:           end
// 287:
// 288:           # Reinstall everything that did download, rather than aborting the
// 289:           # whole run; the failures above still exit nonzero at the end.
// 290:           reinstall_contexts.each do |reinstall_context|
// 291:             next unless valid_formula_installers.include?(reinstall_context.formula_installer)
// 292:
// 293:             Homebrew::Reinstall.reinstall_formula(reinstall_context)
// 294:             Cleanup.install_formula_clean!(reinstall_context.formula)
// 295:           rescue BuildError
// 296:             # Reported (with analytics) by the global handler in `brew.rb`.
// 297:             raise
// 298:           rescue => e
// 299:             ofail "#{reinstall_context.formula.full_specified_name}: #{e}"
// 300:           end
// 301:
// 302:           Upgrade.upgrade_dependents(
// 303:             dependants, formulae,
// 304:             flags:                      args.flags_only,
// 305:             force_bottle:               args.force_bottle?,
// 306:             build_from_source_formulae: args.build_from_source_formulae,
// 307:             interactive:                args.interactive?,
// 308:             keep_tmp:                   args.keep_tmp?,
// 309:             debug_symbols:              args.debug_symbols?,
// 310:             force:                      args.force?,
// 311:             debug:                      args.debug?,
// 312:             quiet:                      args.quiet?,
// 313:             verbose:                    args.verbose?
// 314:           )
// 315:         end
// 316:
// 317:         if casks.any?
// 318:           begin
// 319:             Cask::Reinstall.reinstall_casks(
// 320:               *casks,
// 321:               binaries:       args.binaries?,
// 322:               verbose:        args.verbose?,
// 323:               force:          args.force?,
// 324:               require_sha:    args.require_sha?,
// 325:               skip_cask_deps: args.skip_cask_deps?,
// 326:               zap:            args.zap?,
// 327:               skip_prefetch:  casks_prefetched,
// 328:               download_queue: nil,
// 329:             )
// 330:           rescue => e
// 331:             ofail e
// 332:           end
// 333:         end
// 334:
// 335:         unavailable_errors.each { |e| ofail e }
// 336:
// 337:         Cleanup.periodic_clean!
// 338:
// 339:         Homebrew.messages.display_messages(display_times: args.display_times?)
// 340:       end
// 341:     end
// 342:   end
// 343: end
