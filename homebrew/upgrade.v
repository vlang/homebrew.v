module homebrew

import brew_runtime

// Translated from Homebrew/brew `upgrade.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `format_upgrade_summary(upgrades)` at line 26.
pub fn ruby_upgrade_l26_d1_format_upgrade_summary(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('format_upgrade_summary', ...args)
}

// Ruby method `formula_installers(` at line 65.
pub fn ruby_upgrade_l65_d2_formula_installers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_installers', ...args)
}

// Ruby method `upgrade_formulae(formula_installers, dry_run: false, verbose: false, fetch: true, skip_formula_names: [])` at line 178.
pub fn ruby_upgrade_l178_d3_upgrade_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('upgrade_formulae', ...args)
}

// Ruby method `outdated_kegs(formula)` at line 201.
pub fn ruby_upgrade_l201_d4_outdated_kegs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('outdated_kegs', ...args)
}

// Ruby method `print_upgrade_message(formula, fi_options)` at line 208.
pub fn ruby_upgrade_l208_d5_print_upgrade_message(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('print_upgrade_message', ...args)
}

// Ruby method `dependants(` at line 227.
pub fn ruby_upgrade_l227_d6_dependants(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dependants', ...args)
}

// Ruby method `upgrade_dependents(deps, formulae,` at line 283.
pub fn ruby_upgrade_l283_d7_upgrade_dependents(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('upgrade_dependents', ...args)
}

// Ruby method `upgrade_formula(formula_installer, dry_run: false, verbose: false, skip_formula_names: [])` at line 466.
pub fn ruby_upgrade_l466_d8_upgrade_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('upgrade_formula', ...args)
}

// Ruby method `check_broken_dependents(installed_formulae)` at line 504.
pub fn ruby_upgrade_l504_d9_check_broken_dependents(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_broken_dependents', ...args)
}

// Ruby method `puts_no_installed_dependents_check_disable_message_if_not_already!` at line 522.
pub fn ruby_upgrade_l522_d10_puts_no_installed_dependents_check_disable_message_if_not_already(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('puts_no_installed_dependents_check_disable_message_if_not_already!',
		...args)
}

// Ruby method `create_formula_installer(` at line 539.
pub fn ruby_upgrade_l539_d11_create_formula_installer(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('create_formula_installer', ...args)
}

// Ruby method `depends_on(one, two)` at line 599.
pub fn ruby_upgrade_l599_d12_depends_on(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('depends_on', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "reinstall"
// 5: require "formula_installer"
// 6: require "download_queue"
// 7: require "development_tools"
// 8: require "messages"
// 9: require "cleanup"
// 10: require "utils/topological_hash"
// 11: require "utils/output"
// 12:
// 13: module Homebrew
// 14:   # Helper functions for upgrading formulae.
// 15:   module Upgrade
// 16:     extend Utils::Output::Mixin
// 17:
// 18:     class Dependents < T::Struct
// 19:       const :upgradeable, T::Array[Formula]
// 20:       const :pinned, T::Array[Formula]
// 21:       const :skipped, T::Array[Formula]
// 22:     end
// 23:
// 24:     class << self
// 25:       sig { params(upgrades: T::Array[String]).returns(T::Array[String]) }
// 26:       def format_upgrade_summary(upgrades)
// 27:         return upgrades if upgrades.size < 2
// 28:
// 29:         name_width = upgrades.map { |upgrade| upgrade.split(" ", 2).fetch(0).length }.max
// 30:         name_width ||= 0
// 31:         old_version_width = upgrades.filter_map do |upgrade|
// 32:           versions = upgrade.split(" ", 2).fetch(1, "")
// 33:           next unless versions.include?(" -> ")
// 34:
// 35:           versions.split(" -> ", 2).fetch(0).length
// 36:         end.max
// 37:         old_version_width ||= 0
// 38:
// 39:         upgrades.map do |upgrade|
// 40:           parts = upgrade.split(" ", 2)
// 41:           name = parts.fetch(0)
// 42:           versions = parts.fetch(1, "")
// 43:           next name if versions.blank?
// 44:
// 45:           if versions.include?(" -> ")
// 46:             version_parts = versions.split(" -> ", 2)
// 47:             old_version = version_parts.fetch(0)
// 48:             new_version = version_parts.fetch(1)
// 49:             "#{name.ljust(name_width)}  #{old_version.ljust(old_version_width)} -> #{new_version}"
// 50:           else
// 51:             "#{name.ljust(name_width)}  #{versions}"
// 52:           end
// 53:         end
// 54:       end
// 55:
// 56:       sig {
// 57:         params(
// 58:           formulae_to_install: T::Array[Formula], flags: T::Array[String], dry_run: T::Boolean,
// 59:           force_bottle: T::Boolean, build_from_source_formulae: T::Array[String],
// 60:           dependents: T::Boolean, interactive: T::Boolean, keep_tmp: T::Boolean,
// 61:           debug_symbols: T::Boolean, force: T::Boolean, overwrite: T::Boolean,
// 62:           debug: T::Boolean, quiet: T::Boolean, verbose: T::Boolean
// 63:         ).returns(T::Array[FormulaInstaller])
// 64:       }
// 65:       def formula_installers(
// 66:         formulae_to_install,
// 67:         flags:,
// 68:         dry_run: false,
// 69:         force_bottle: false,
// 70:         build_from_source_formulae: [],
// 71:         dependents: false,
// 72:         interactive: false,
// 73:         keep_tmp: false,
// 74:         debug_symbols: false,
// 75:         force: false,
// 76:         overwrite: false,
// 77:         debug: false,
// 78:         quiet: false,
// 79:         verbose: false
// 80:       )
// 81:         return [] if formulae_to_install.empty?
// 82:
// 83:         # Sort keg-only before non-keg-only formulae to avoid any needless conflicts
// 84:         # with outdated, non-keg-only versions of formulae being upgraded.
// 85:         formulae_to_install.sort! do |a, b|
// 86:           if !a.keg_only? && b.keg_only?
// 87:             1
// 88:           elsif a.keg_only? && !b.keg_only?
// 89:             -1
// 90:           else
// 91:             0
// 92:           end
// 93:         end
// 94:
// 95:         dependency_graph = Utils::TopologicalHash.graph_package_dependencies(formulae_to_install)
// 96:         sorted = dependency_graph.tsort_with_cycles do |cycles|
// 97:           raise CyclicDependencyError, cycles if Homebrew::EnvConfig.developer?
// 98:
// 99:           odebug "Ignoring cyclic dependencies: #{cycles.map(&:to_sentence).join(", ")}"
// 100:         end
// 101:         formulae_to_install = sorted & formulae_to_install
// 102:
// 103:         # We need to fetch the bottle tabs ahead of the `Install.fetch_formulae`
// 104:         # pipeline because we need to first filter out those formulae with all
// 105:         # runtime dependencies already satisfied (see below).
// 106:         download_queue = Homebrew::DownloadQueue.new
// 107:         begin
// 108:           installers = formulae_to_install.filter_map do |formula|
// 109:             Migrator.migrate_if_needed(formula, force:, dry_run:)
// 110:             begin
// 111:               fi = create_formula_installer(
// 112:                 formula,
// 113:                 flags:,
// 114:                 download_queue:,
// 115:                 force_bottle:,
// 116:                 build_from_source_formulae:,
// 117:                 interactive:,
// 118:                 keep_tmp:,
// 119:                 debug_symbols:,
// 120:                 force:,
// 121:                 overwrite:,
// 122:                 debug:,
// 123:                 quiet:,
// 124:                 verbose:,
// 125:               )
// 126:               fi.fetch_bottle_tab(quiet: !debug, enqueue: true)
// 127:               fi
// 128:             rescue CannotInstallFormulaError => e
// 129:               ofail e
// 130:               nil
// 131:             rescue UnsatisfiedRequirements, DownloadError => e
// 132:               ofail "#{formula}: #{e}"
// 133:               nil
// 134:             end
// 135:           end
// 136:
// 137:           download_queue.fetch(only: Resource::BottleManifest, heading: "Downloading bottle manifests",
// 138:                                allow_failures: true)
// 139:         ensure
// 140:           download_queue.shutdown
// 141:         end
// 142:
// 143:         installers.filter_map do |fi|
// 144:           fi.determine_bottle_tab_attributes
// 145:
// 146:           if !dry_run && dependents
// 147:             all_runtime_deps_installed = fi.bottle_tab_runtime_dependencies.presence&.all? do |dependency, hash|
// 148:               minimum_version = if (version = hash["version"])
// 149:                 Version.new(version)
// 150:               end
// 151:               Dependency.new(dependency).installed?(minimum_version:, minimum_revision: hash["revision"].to_i)
// 152:             end
// 153:
// 154:             if all_runtime_deps_installed
// 155:               ohai "Not upgrading #{fi.formula.full_specified_name}: " \
// 156:                    "installed runtime dependencies satisfy bottle metadata"
// 157:               next
// 158:             end
// 159:           end
// 160:
// 161:           if dry_run
// 162:             begin
// 163:               fi.check_install_sanity
// 164:             rescue CannotInstallFormulaError => e
// 165:               ofail e.message
// 166:               next
// 167:             end
// 168:           end
// 169:
// 170:           fi
// 171:         end
// 172:       end
// 173:
// 174:       sig {
// 175:         params(formula_installers: T::Array[FormulaInstaller], dry_run: T::Boolean, verbose: T::Boolean,
// 176:                fetch: T::Boolean, skip_formula_names: T::Array[String]).returns(T::Array[FormulaInstaller])
// 177:       }
// 178:       def upgrade_formulae(formula_installers, dry_run: false, verbose: false, fetch: true, skip_formula_names: [])
// 179:         valid_formula_installers = if dry_run || !fetch
// 180:           formula_installers
// 181:         else
// 182:           Install.fetch_formulae(formula_installers)
// 183:         end
// 184:
// 185:         upgraded_formula_installers = valid_formula_installers.select do |fi|
// 186:           upgraded = upgrade_formula(fi, dry_run:, verbose:, skip_formula_names:)
// 187:           Cleanup.install_formula_clean!(fi.formula) if upgraded && !dry_run
// 188:           upgraded
// 189:         end
// 190:         return upgraded_formula_installers unless dry_run
// 191:
// 192:         formulae_to_clean = Cleanup.install_cleanup_formulae(upgraded_formula_installers.map(&:formula))
// 193:         if formulae_to_clean.present? &&
// 194:            Cleanup.printed_dry_run_output?(Cleanup.dry_run_output(formulae: formulae_to_clean), ohai: true)
// 195:           Cleanup.puts_no_install_cleanup_disable_message_if_not_already!
// 196:         end
// 197:         upgraded_formula_installers
// 198:       end
// 199:
// 200:       sig { params(formula: Formula).returns(T::Array[Keg]) }
// 201:       def outdated_kegs(formula)
// 202:         [formula, *formula.old_installed_formulae].map(&:linked_keg)
// 203:                                                   .select(&:directory?)
// 204:                                                   .map { |k| Keg.new(k.resolved_path) }
// 205:       end
// 206:
// 207:       sig { params(formula: Formula, fi_options: Options).void }
// 208:       def print_upgrade_message(formula, fi_options)
// 209:         version_upgrade = if formula.optlinked?
// 210:           "#{Keg.new(formula.opt_prefix).version} -> #{formula.pkg_version}"
// 211:         else
// 212:           "-> #{formula.pkg_version}"
// 213:         end
// 214:         oh1 "Upgrading #{Formatter.identifier(formula.full_specified_name)}"
// 215:         puts "  #{version_upgrade} #{fi_options.to_a.join(" ")}"
// 216:       end
// 217:
// 218:       sig {
// 219:         params(
// 220:           formulae: T::Array[Formula], flags: T::Array[String], dry_run: T::Boolean,
// 221:           ask: T::Boolean, installed_on_request: T::Boolean, force_bottle: T::Boolean,
// 222:           build_from_source_formulae: T::Array[String], interactive: T::Boolean,
// 223:           keep_tmp: T::Boolean, debug_symbols: T::Boolean, force: T::Boolean,
// 224:           debug: T::Boolean, quiet: T::Boolean, verbose: T::Boolean
// 225:         ).returns(Dependents)
// 226:       }
// 227:       def dependants(
// 228:         formulae,
// 229:         flags:,
// 230:         dry_run: false,
// 231:         ask: false,
// 232:         installed_on_request: false,
// 233:         force_bottle: false,
// 234:         build_from_source_formulae: [],
// 235:         interactive: false,
// 236:         keep_tmp: false,
// 237:         debug_symbols: false,
// 238:         force: false,
// 239:         debug: false,
// 240:         quiet: false,
// 241:         verbose: false
// 242:       )
// 243:         no_dependents = Dependents.new(upgradeable: [], pinned: [], skipped: [])
// 244:         if Homebrew::EnvConfig.no_installed_dependents_check?
// 245:           unless Homebrew::EnvConfig.no_env_hints?
// 246:             opoo <<~EOS
// 247:               `$HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK` is set: not checking for outdated
// 248:               dependents or dependents with broken linkage!
// 249:             EOS
// 250:           end
// 251:           return no_dependents
// 252:         end
// 253:         formulae_to_install = formulae.reject { |f| f.core_formula? && f.versioned_formula? }
// 254:         return no_dependents if formulae_to_install.empty?
// 255:
// 256:         # TODO: this should be refactored to use FormulaInstaller new logic
// 257:         outdated = formulae_to_install.flat_map(&:runtime_installed_formula_dependents)
// 258:                                       .uniq
// 259:                                       .select(&:outdated?)
// 260:
// 261:         # Ensure we never attempt a source build for outdated dependents of upgraded formulae.
// 262:         outdated, skipped = outdated.partition do |dependent|
// 263:           dependent.bottled? && dependent.deps.map(&:to_formula).all?(&:bottled?)
// 264:         end
// 265:         return no_dependents if outdated.blank?
// 266:
// 267:         outdated -= formulae_to_install if dry_run
// 268:         upgradeable = outdated.reject(&:pinned?)
// 269:                               .sort { |a, b| depends_on(a, b) }
// 270:         pinned = outdated.select(&:pinned?)
// 271:                          .sort { |a, b| depends_on(a, b) }
// 272:
// 273:         Dependents.new(upgradeable:, pinned:, skipped:)
// 274:       end
// 275:
// 276:       sig {
// 277:         params(deps: Dependents, formulae: T::Array[Formula], flags: T::Array[String],
// 278:                dry_run: T::Boolean, installed_on_request: T::Boolean, force_bottle: T::Boolean,
// 279:                build_from_source_formulae: T::Array[String], interactive: T::Boolean, keep_tmp: T::Boolean,
// 280:                debug_symbols: T::Boolean, force: T::Boolean, debug: T::Boolean, quiet: T::Boolean,
// 281:                verbose: T::Boolean, skip_formula_names: T::Array[String]).returns(T::Array[Formula])
// 282:       }
// 283:       def upgrade_dependents(deps, formulae,
// 284:                              flags:,
// 285:                              dry_run: false,
// 286:                              installed_on_request: false,
// 287:                              force_bottle: false,
// 288:                              build_from_source_formulae: [],
// 289:                              interactive: false,
// 290:                              keep_tmp: false,
// 291:                              debug_symbols: false,
// 292:                              force: false,
// 293:                              debug: false,
// 294:                              quiet: false,
// 295:                              verbose: false,
// 296:                              skip_formula_names: [])
// 297:         return [] if deps.blank?
// 298:
// 299:         upgradeable = deps.upgradeable
// 300:         pinned      = deps.pinned
// 301:         skipped     = deps.skipped
// 302:         if pinned.present?
// 303:           plural = Utils.pluralize("dependent", pinned.count)
// 304:           opoo "Not upgrading #{pinned.count} pinned #{plural}:"
// 305:           puts(pinned.map do |f|
// 306:             "#{f.full_specified_name} #{f.pkg_version}"
// 307:           end.join(", "))
// 308:         end
// 309:         if skipped.present?
// 310:           opoo <<~EOS
// 311:             The following dependents of upgraded formulae are outdated but will not
// 312:             be upgraded because they are not bottled:
// 313:               #{skipped * "\n  "}
// 314:           EOS
// 315:         end
// 316:
// 317:         installed_formulae = FormulaInstaller.installed
// 318:         upgraded_formulae = T.let([], T::Array[Formula])
// 319:         unless dry_run
// 320:           primary_formula_names = formulae.map(&:full_name)
// 321:           upgraded_formulae.concat(upgradeable.select do |f|
// 322:             installed_formulae.include?(f) && primary_formula_names.exclude?(f.full_name)
// 323:           end)
// 324:         end
// 325:
// 326:         upgradeable.reject! do |f|
// 327:           installed_formulae.include?(f) || (dry_run && skip_formula_names.include?(f.full_name))
// 328:         end
// 329:
// 330:         return upgraded_formulae if upgradeable.blank?
// 331:
// 332:         dependent_installers = T.let([], T::Array[FormulaInstaller])
// 333:         unless dry_run
// 334:           dependent_installers = formula_installers(
// 335:             upgradeable.dup,
// 336:             flags:,
// 337:             force_bottle:,
// 338:             build_from_source_formulae:,
// 339:             dependents:                 true,
// 340:             interactive:,
// 341:             keep_tmp:,
// 342:             debug_symbols:,
// 343:             force:,
// 344:             debug:,
// 345:             quiet:,
// 346:             verbose:,
// 347:           )
// 348:           upgradeable = dependent_installers.map(&:formula)
// 349:         end
// 350:
// 351:         # Print the upgradable dependents.
// 352:         if upgradeable.present?
// 353:           installed_formulae = (dry_run ? formulae : FormulaInstaller.installed.to_a).dup
// 354:           formula_plural = Utils.pluralize("formula", installed_formulae.count)
// 355:           upgrade_verb = dry_run ? "Would upgrade" : "Upgrading"
// 356:           ohai "#{upgrade_verb} #{Utils.pluralize("dependent", upgradeable.count,
// 357:                                                   include_count: true)} of upgraded #{formula_plural}:"
// 358:           puts_no_installed_dependents_check_disable_message_if_not_already!
// 359:           formulae_upgrades = upgradeable.map do |f|
// 360:             name = f.full_specified_name
// 361:             if f.optlinked?
// 362:               "#{name} #{Keg.new(f.opt_prefix).version} -> #{f.pkg_version}"
// 363:             else
// 364:               "#{name} #{f.pkg_version}"
// 365:             end
// 366:           end
// 367:           puts format_upgrade_summary(formulae_upgrades).join("\n")
// 368:         end
// 369:
// 370:         upgraded_formulae.concat(upgrade_formulae(dependent_installers, verbose:).map(&:formula)) unless dry_run
// 371:
// 372:         # Update non-core installed formulae for linkage checks after upgrading
// 373:         # Don't need to check core formulae because we do so at CI time.
// 374:         installed_non_core_formulae = FormulaInstaller.installed.to_a.reject(&:core_formula?)
// 375:         return upgraded_formulae if installed_non_core_formulae.blank?
// 376:
// 377:         # Assess the dependents tree again now we've upgraded.
// 378:         unless dry_run
// 379:           oh1 "Checking for dependents of upgraded formulae..."
// 380:           puts_no_installed_dependents_check_disable_message_if_not_already!
// 381:         end
// 382:
// 383:         broken_dependents = check_broken_dependents(installed_non_core_formulae)
// 384:         if broken_dependents.blank?
// 385:           if dry_run
// 386:             ohai "No currently broken dependents found!"
// 387:             opoo "If they are broken by the upgrade they will also be upgraded or reinstalled."
// 388:           else
// 389:             ohai "No broken dependents found!"
// 390:           end
// 391:           return upgraded_formulae
// 392:         end
// 393:
// 394:         reinstallable_broken_dependents =
// 395:           broken_dependents.reject(&:outdated?)
// 396:                            .reject(&:pinned?)
// 397:                            .sort { |a, b| depends_on(a, b) }
// 398:         outdated_pinned_broken_dependents =
// 399:           broken_dependents.select(&:outdated?)
// 400:                            .select(&:pinned?)
// 401:                            .sort { |a, b| depends_on(a, b) }
// 402:
// 403:         # Print the pinned dependents.
// 404:         if outdated_pinned_broken_dependents.present?
// 405:           count = outdated_pinned_broken_dependents.count
// 406:           plural = Utils.pluralize("dependent", outdated_pinned_broken_dependents.count)
// 407:           onoe "Not reinstalling #{count} broken and outdated, but pinned #{plural}:"
// 408:           $stderr.puts(outdated_pinned_broken_dependents.map do |f|
// 409:             "#{f.full_specified_name} #{f.pkg_version}"
// 410:           end.join(", "))
// 411:         end
// 412:
// 413:         # Print the broken dependents.
// 414:         if reinstallable_broken_dependents.blank?
// 415:           ohai "No broken dependents to reinstall!"
// 416:         else
// 417:           ohai "Reinstalling #{Utils.pluralize("dependent", reinstallable_broken_dependents.count,
// 418:                                                include_count: true)} with broken linkage from source:"
// 419:           puts_no_installed_dependents_check_disable_message_if_not_already!
// 420:           puts reinstallable_broken_dependents.map(&:full_specified_name)
// 421:                                               .join(", ")
// 422:         end
// 423:
// 424:         return upgraded_formulae if dry_run
// 425:
// 426:         reinstall_contexts = reinstallable_broken_dependents.map do |formula|
// 427:           Reinstall.build_install_context(
// 428:             formula,
// 429:             flags:,
// 430:             force_bottle:,
// 431:             build_from_source_formulae: build_from_source_formulae + [formula.full_name],
// 432:             interactive:,
// 433:             keep_tmp:,
// 434:             debug_symbols:,
// 435:             force:,
// 436:             debug:,
// 437:             quiet:,
// 438:             verbose:,
// 439:           )
// 440:         end
// 441:
// 442:         valid_formula_installers = Install.fetch_formulae(reinstall_contexts.map(&:formula_installer))
// 443:
// 444:         reinstall_contexts.each do |reinstall_context|
// 445:           next unless valid_formula_installers.include?(reinstall_context.formula_installer)
// 446:
// 447:           Reinstall.reinstall_formula(reinstall_context)
// 448:         rescue FormulaInstallationAlreadyAttemptedError
// 449:           # We already attempted to reinstall f as part of the dependency tree of
// 450:           # another formula. In that case, don't generate an error, just move on.
// 451:           nil
// 452:         rescue BuildError => e
// 453:           e.dump(verbose:)
// 454:           puts
// 455:           Homebrew.failed = true
// 456:         rescue => e
// 457:           ofail e
// 458:         end
// 459:         upgraded_formulae
// 460:       end
// 461:
// 462:       sig {
// 463:         params(formula_installer: FormulaInstaller, dry_run: T::Boolean, verbose: T::Boolean,
// 464:                skip_formula_names: T::Array[String]).returns(T::Boolean)
// 465:       }
// 466:       def upgrade_formula(formula_installer, dry_run: false, verbose: false, skip_formula_names: [])
// 467:         formula = formula_installer.formula
// 468:
// 469:         if dry_run
// 470:           Install.print_dry_run_dependencies(formula, formula_installer.compute_dependencies,
// 471:                                              skip_formula_names:) do |f|
// 472:             name = f.full_specified_name
// 473:             current_version = if f.optlinked?
// 474:               Keg.new(f.opt_prefix).version
// 475:             else
// 476:               f.installed_kegs.map(&:version).max
// 477:             end
// 478:             if current_version && current_version != f.pkg_version
// 479:               "#{name} #{current_version} -> #{f.pkg_version}"
// 480:             else
// 481:               "#{name} #{f.pkg_version}"
// 482:             end
// 483:           end
// 484:           return true
// 485:         end
// 486:
// 487:         Install.install_formula(formula_installer, upgrade: true)
// 488:         true
// 489:       rescue BuildError => e
// 490:         e.dump(verbose:)
// 491:         puts
// 492:         Homebrew.failed = true
// 493:         false
// 494:       rescue => e
// 495:         # Keep a single failed upgrade (e.g. a bottle that fails to extract)
// 496:         # from aborting the rest of the batch while still failing the run.
// 497:         ofail "#{formula_installer.formula.full_specified_name}: #{e}"
// 498:         false
// 499:       end
// 500:
// 501:       private
// 502:
// 503:       sig { params(installed_formulae: T::Array[Formula]).returns(T::Array[Formula]) }
// 504:       def check_broken_dependents(installed_formulae)
// 505:         CacheStoreDatabase.use(:linkage) do |db|
// 506:           installed_formulae.flat_map(&:runtime_installed_formula_dependents)
// 507:                             .uniq
// 508:                             .select do |f|
// 509:             keg = f.any_installed_keg
// 510:             next unless keg
// 511:             next unless keg.directory?
// 512:
// 513:             LinkageChecker.new(
// 514:               keg,
// 515:               cache_db: T.cast(db, CacheStoreDatabase[String, T::Hash[T.any(String, Symbol), T.anything]]),
// 516:             ).broken_library_linkage?
// 517:           end.compact
// 518:         end
// 519:       end
// 520:
// 521:       sig { void }
// 522:       def puts_no_installed_dependents_check_disable_message_if_not_already!
// 523:         return if Homebrew::EnvConfig.no_env_hints?
// 524:         return if Homebrew::EnvConfig.no_installed_dependents_check?
// 525:         return if @puts_no_installed_dependents_check_disable_message_if_not_already
// 526:
// 527:         puts "Disable this behaviour by setting `HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK=1`."
// 528:         puts "Hide these hints with `HOMEBREW_NO_ENV_HINTS=1` (see `man brew`)."
// 529:         @puts_no_installed_dependents_check_disable_message_if_not_already = T.let(true, T.nilable(T::Boolean))
// 530:       end
// 531:
// 532:       sig {
// 533:         params(formula: Formula, flags: T::Array[String], download_queue: Homebrew::DownloadQueue,
// 534:                force_bottle: T::Boolean,
// 535:                build_from_source_formulae: T::Array[String], interactive: T::Boolean,
// 536:                keep_tmp: T::Boolean, debug_symbols: T::Boolean, force: T::Boolean,
// 537:                overwrite: T::Boolean, debug: T::Boolean, quiet: T::Boolean, verbose: T::Boolean).returns(FormulaInstaller)
// 538:       }
// 539:       def create_formula_installer(
// 540:         formula,
// 541:         flags:,
// 542:         download_queue:,
// 543:         force_bottle: false,
// 544:         build_from_source_formulae: [],
// 545:         interactive: false,
// 546:         keep_tmp: false,
// 547:         debug_symbols: false,
// 548:         force: false,
// 549:         overwrite: false,
// 550:         debug: false,
// 551:         quiet: false,
// 552:         verbose: false
// 553:       )
// 554:         keg = if formula.optlinked?
// 555:           Keg.new(formula.opt_prefix.resolved_path)
// 556:         else
// 557:           formula.installed_kegs.find(&:optlinked?)
// 558:         end
// 559:
// 560:         if keg
// 561:           tab = keg.tab
// 562:           link_keg = keg.linked?
// 563:           installed_on_request = tab.installed_on_request == true
// 564:           build_bottle = tab.built_bottle?
// 565:         else
// 566:           link_keg = nil
// 567:           installed_on_request = true
// 568:           build_bottle = false
// 569:         end
// 570:
// 571:         build_options = BuildOptions.new(Options.create(flags), formula.options)
// 572:         options = build_options.used_options
// 573:         options |= formula.build.used_options
// 574:         options &= formula.options
// 575:
// 576:         FormulaInstaller.new(
// 577:           formula,
// 578:           **{
// 579:             download_queue:,
// 580:             options:,
// 581:             link_keg:,
// 582:             installed_on_request:,
// 583:             build_bottle:,
// 584:             force_bottle:,
// 585:             build_from_source_formulae:,
// 586:             interactive:,
// 587:             keep_tmp:,
// 588:             debug_symbols:,
// 589:             force:,
// 590:             overwrite:,
// 591:             debug:,
// 592:             quiet:,
// 593:             verbose:,
// 594:           }.compact,
// 595:         )
// 596:       end
// 597:
// 598:       sig { params(one: Formula, two: Formula).returns(Integer) }
// 599:       def depends_on(one, two)
// 600:         if one.any_installed_keg
// 601:               &.runtime_dependencies
// 602:               &.any? { |dependency| dependency["full_name"] == two.full_name }
// 603:           1
// 604:         else
// 605:           T.must(one <=> two)
// 606:         end
// 607:       end
// 608:     end
// 609:   end
// 610: end
