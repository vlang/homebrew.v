module test_bot

import brew_runtime

// Translated from Homebrew/brew `test_bot/formulae_dependents.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_writer `attr_writer :testing_formulae` at line 11.
pub fn ruby_formulae_dependents_l11_d1_testing_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('testing_formulae=', ...args)
}

// Ruby attr_writer `attr_writer :tested_formulae` at line 14.
pub fn ruby_formulae_dependents_l14_d2_tested_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tested_formulae=', ...args)
}

// Ruby method `initialize(tap:, git:, dry_run:, fail_fast:, verbose:)` at line 25.
pub fn ruby_formulae_dependents_l25_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `run!(args:)` at line 36.
pub fn ruby_formulae_dependents_l36_d4_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run!', ...args)
}

// Ruby method `dependents_for_shard(dependents, shard)` at line 99.
pub fn ruby_formulae_dependents_l99_d5_dependents_for_shard(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dependents_for_shard', ...args)
}

// Ruby method `install_formulae_if_needed_from_bottles!(installable_bottles, args:)` at line 167.
pub fn ruby_formulae_dependents_l167_d6_install_formulae_if_needed_from_bottles(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_formulae_if_needed_from_bottles!', ...args)
}

// Ruby method `dependent_formulae!(formula_name, args:)` at line 177.
pub fn ruby_formulae_dependents_l177_d7_dependent_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dependent_formulae!', ...args)
}

// Ruby method `dependents_for_formula(formula, formula_name, args:)` at line 239.
pub fn ruby_formulae_dependents_l239_d8_dependents_for_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dependents_for_formula', ...args)
}

// Ruby method `dependent_pairs_for_formula(formula, formula_name, args:)` at line 293.
pub fn ruby_formulae_dependents_l293_d9_dependent_pairs_for_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dependent_pairs_for_formula', ...args)
}

// Ruby method `install_dependent(dependent, testable_dependents, args:, build_from_source: false)` at line 355.
pub fn ruby_formulae_dependents_l355_d10_install_dependent(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_dependent', ...args)
}

// Ruby method `skip_recursive_dependents?(_formula, args:)` at line 508.
pub fn ruby_formulae_dependents_l508_d11_skip_recursive_dependents(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skip_recursive_dependents?', ...args)
}

// Ruby method `build_dependent_from_source?(_dependent)` at line 513.
pub fn ruby_formulae_dependents_l513_d12_build_dependent_from_source(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('build_dependent_from_source?', ...args)
}

// Ruby method `unlink_conflicts(formula)` at line 518.
pub fn ruby_formulae_dependents_l518_d13_unlink_conflicts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('unlink_conflicts', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module TestBot
// 6:     class FormulaeDependents < TestFormulae
// 7:       DependentWithDependencies = T.type_alias { [Formula, T::Array[Dependency]] }
// 8:       private_constant :DependentWithDependencies
// 9:
// 10:       sig { params(testing_formulae: T::Array[String]).returns(T::Array[String]) }
// 11:       attr_writer :testing_formulae
// 12:
// 13:       sig { params(tested_formulae: T::Array[String]).returns(T::Array[String]) }
// 14:       attr_writer :tested_formulae
// 15:
// 16:       sig {
// 17:         params(
// 18:           tap:       T.nilable(Tap),
// 19:           git:       T.nilable(String),
// 20:           dry_run:   T::Boolean,
// 21:           fail_fast: T::Boolean,
// 22:           verbose:   T::Boolean,
// 23:         ).void
// 24:       }
// 25:       def initialize(tap:, git:, dry_run:, fail_fast:, verbose:)
// 26:         super
// 27:         @testing_formulae_with_tested_dependents = T.let([], T::Array[String])
// 28:         @tested_dependents_list = T.let(nil, T.nilable(Pathname))
// 29:         @dependent_testing_formulae = T.let([], T::Array[String])
// 30:         @tested_dependents = T.let([], T::Array[String])
// 31:         @formulae_dependents_filter = T.let(nil, T.nilable(T::Array[String]))
// 32:         @dependent_pairs_by_formula = T.let({}, T::Hash[String, T::Array[DependentWithDependencies]])
// 33:       end
// 34:
// 35:       sig { params(args: Homebrew::Cmd::TestBotCmd::Args).void }
// 36:       def run!(args:)
// 37:         if args.formulae_dependents_shard.present? && !args.only_formulae_dependents?
// 38:           raise UsageError, "`--formulae-dependents-shard` requires `--only-formulae-dependents`."
// 39:         end
// 40:
// 41:         test "brew", "untap", "--force", "homebrew/cask" if !tap&.core_cask_tap? && CoreCaskTap.instance.installed?
// 42:
// 43:         installable_bottles = @tested_formulae - @skipped_or_failed_formulae
// 44:         unneeded_formulae = @tested_formulae - @testing_formulae
// 45:         @skipped_or_failed_formulae += unneeded_formulae
// 46:
// 47:         info_header "Skipped or failed formulae:"
// 48:         puts skipped_or_failed_formulae
// 49:
// 50:         @testing_formulae_with_tested_dependents = []
// 51:         @tested_dependents_list = Pathname("tested-dependents-#{Utils::Bottles.tag}.txt")
// 52:
// 53:         @dependent_testing_formulae = sorted_formulae - skipped_or_failed_formulae
// 54:
// 55:         install_formulae_if_needed_from_bottles!(installable_bottles, args:)
// 56:
// 57:         download_artifacts_from_previous_run!("dependents{,_#{previous_run_artifact_specifier}*}",
// 58:                                               dry_run: args.dry_run?)
// 59:         @skip_candidates = T.let(
// 60:           if (tested_dependents_cache = artifact_cache/@tested_dependents_list).exist?
// 61:             tested_dependents_cache.read.split("\n")
// 62:           else
// 63:             []
// 64:           end,
// 65:           T.nilable(T::Array[String]),
// 66:         )
// 67:
// 68:         if args.formulae_dependents_shard.present?
// 69:           dependent_pairs = @dependent_testing_formulae.flat_map do |formula_name|
// 70:             dependent_pairs_for_formula(Formulary.factory(formula_name), formula_name, args:)
// 71:           end
// 72:           dependent_pairs.uniq! { |dependent, _| dependent.full_name }
// 73:
// 74:           @formulae_dependents_filter = dependents_for_shard(dependent_pairs, args.formulae_dependents_shard.to_s)
// 75:                                         .map { |dependent, _| dependent.full_name }
// 76:         end
// 77:
// 78:         @dependent_testing_formulae.each do |formula_name|
// 79:           dependent_formulae!(formula_name, args:)
// 80:           puts
// 81:         end
// 82:
// 83:         return unless GitHub::Actions.env_set?
// 84:
// 85:         # Remove `bash` after it is tested, since leaving a broken `bash`
// 86:         # installation in the environment can cause issues with subsequent
// 87:         # GitHub Actions steps.
// 88:         return unless @dependent_testing_formulae.include?("bash")
// 89:
// 90:         test "brew", "uninstall", "--formula", "--force", "bash"
// 91:       end
// 92:
// 93:       sig {
// 94:         params(
// 95:           dependents: T::Array[DependentWithDependencies],
// 96:           shard:      String,
// 97:         ).returns(T::Array[DependentWithDependencies])
// 98:       }
// 99:       def dependents_for_shard(dependents, shard)
// 100:         unless shard.match?(%r{\A[1-9]\d*/[1-9]\d*\z})
// 101:           raise UsageError, "`--formulae-dependents-shard` must use the format <SHARD/TOTAL>."
// 102:         end
// 103:
// 104:         shard_parts = shard.split("/", 2)
// 105:         shard_index = shard_parts.fetch(0).to_i
// 106:         shard_count = shard_parts.fetch(1).to_i
// 107:         if shard_index > shard_count
// 108:           raise UsageError, "`--formulae-dependents-shard` must not be greater than the total shard count."
// 109:         end
// 110:
// 111:         return dependents if shard_count == 1
// 112:
// 113:         dependents_by_name = dependents.to_h { |dependent, deps| [dependent.full_name, [dependent, deps]] }
// 114:         edges = dependents.to_h { |dependent, _| [dependent.full_name, T.let([], T::Array[String])] }
// 115:
// 116:         dependents.each do |dependent, deps|
// 117:           deps.each do |dep|
// 118:             dep_name = dep.to_formula.full_name
// 119:             next unless edges.key?(dep_name)
// 120:
// 121:             edges.fetch(dependent.full_name) << dep_name
// 122:             edges.fetch(dep_name) << dependent.full_name
// 123:           end
// 124:         end
// 125:
// 126:         seen = T.let(Set.new, T::Set[String])
// 127:         groups = T.let([], T::Array[T::Array[DependentWithDependencies]])
// 128:         max_group_size = (dependents.size + shard_count - 1) / shard_count
// 129:
// 130:         dependents.map(&:first).each do |dependent|
// 131:           next if seen.include?(dependent.full_name)
// 132:
// 133:           group = T.let([], T::Array[DependentWithDependencies])
// 134:           queue = T.let([dependent.full_name], T::Array[String])
// 135:
// 136:           until queue.empty?
// 137:             name = queue.fetch(0)
// 138:             queue.shift
// 139:             next if seen.include?(name)
// 140:
// 141:             seen << name
// 142:             group << dependents_by_name.fetch(name)
// 143:             break if group.size >= max_group_size
// 144:
// 145:             queue.concat(edges.fetch(name).reject { |edge| seen.include?(edge) })
// 146:           end
// 147:
// 148:           groups << group
// 149:         end
// 150:
// 151:         shards = Array.new(shard_count) { T.let([], T::Array[DependentWithDependencies]) }
// 152:         groups.sort_by { |group| [-group.count, group.map { |dependent, _| dependent.full_name }.min.to_s] }
// 153:               .each do |group|
// 154:           group_shard_index = 0
// 155:           shards.each_with_index do |current_shard, index|
// 156:             group_shard_index = index if current_shard.count < shards.fetch(group_shard_index).count
// 157:           end
// 158:           shards.fetch(group_shard_index).concat(group)
// 159:         end
// 160:
// 161:         shards.fetch(shard_index - 1).sort_by { |dependent, _| dependent.full_name }
// 162:       end
// 163:
// 164:       private
// 165:
// 166:       sig { params(installable_bottles: T::Array[String], args: Homebrew::Cmd::TestBotCmd::Args).void }
// 167:       def install_formulae_if_needed_from_bottles!(installable_bottles, args:)
// 168:         installable_bottles.each do |formula_name|
// 169:           formula = Formulary.factory(formula_name)
// 170:           next if formula.latest_version_installed?
// 171:
// 172:           install_formula_from_bottle!(formula_name, testing_formulae_dependents: true, dry_run: args.dry_run?)
// 173:         end
// 174:       end
// 175:
// 176:       sig { params(formula_name: String, args: Homebrew::Cmd::TestBotCmd::Args).void }
// 177:       def dependent_formulae!(formula_name, args:)
// 178:         cleanup_during!(@dependent_testing_formulae, args:)
// 179:
// 180:         test_header(:FormulaeDependents, method: "dependent_formulae!(#{formula_name})")
// 181:         @testing_formulae_with_tested_dependents << formula_name
// 182:
// 183:         formula = Formulary.factory(formula_name)
// 184:
// 185:         source_dependents, bottled_dependents, testable_dependents =
// 186:           dependents_for_formula(formula, formula_name, args:)
// 187:
// 188:         return if source_dependents.blank? && bottled_dependents.blank? && testable_dependents.blank?
// 189:
// 190:         # If we installed this from a bottle, then the formula isn't linked.
// 191:         # If the formula isn't linked, `brew install --only-dependences` does
// 192:         # nothing with the message:
// 193:         #     Warning: formula x.y.z is already installed, it's just not linked.
// 194:         #     To link this version, run:
// 195:         #       brew link formula
// 196:         unlink_conflicts formula
// 197:         test "brew", "link", formula_name unless formula.keg_only?
// 198:
// 199:         # Install formula dependencies. These may not be installed.
// 200:         test "brew", "install", "--only-dependencies",
// 201:              named_args:      formula_name,
// 202:              ignore_failures: !bottled?(formula, no_older_versions: true),
// 203:              env:             { "HOMEBREW_DEVELOPER" => nil }
// 204:         return unless steps.fetch(-1).passed?
// 205:
// 206:         # Restore etc/var files that may have been nuked in the build stage.
// 207:         test "brew", "postinstall",
// 208:              named_args:      formula_name,
// 209:              ignore_failures: !bottled?(formula, no_older_versions: true)
// 210:         return unless steps.fetch(-1).passed?
// 211:
// 212:         # Test texlive first to avoid GitHub-hosted runners running out of storage.
// 213:         # TODO: Try generalising this by sorting dependents according to install size,
// 214:         #       where ideally install size should include recursive dependencies.
// 215:         [source_dependents, bottled_dependents].each do |dependent_array|
// 216:           texlive = dependent_array.find { |dependent| dependent.name == "texlive" }
// 217:           next unless texlive.present?
// 218:
// 219:           dependent_array.delete(texlive)
// 220:           dependent_array.unshift(texlive)
// 221:         end
// 222:
// 223:         source_dependents.each do |dependent|
// 224:           install_dependent(dependent, testable_dependents, build_from_source: true, args:)
// 225:           install_dependent(dependent, testable_dependents, args:) if bottled?(dependent)
// 226:         end
// 227:
// 228:         bottled_dependents.each do |dependent|
// 229:           install_dependent(dependent, testable_dependents, args:)
// 230:         end
// 231:
// 232:         @tested_dependents |= (source_dependents + bottled_dependents).map(&:full_name)
// 233:       end
// 234:
// 235:       sig {
// 236:         params(formula: Formula, formula_name: String, args: Homebrew::Cmd::TestBotCmd::Args)
// 237:           .returns([T::Array[Formula], T::Array[Formula], T::Array[Formula]])
// 238:       }
// 239:       def dependents_for_formula(formula, formula_name, args:)
// 240:         info_header "Determining dependents..."
// 241:
// 242:         dependents = dependent_pairs_for_formula(formula, formula_name, args:)
// 243:         if (filter = @formulae_dependents_filter)
// 244:           dependents = dependents.select do |dependent, _|
// 245:             filter.include?(dependent.name) || filter.include?(dependent.full_name)
// 246:           end
// 247:         end
// 248:         dependents.reject! { |dependent, _| @tested_dependents.include?(dependent.full_name) }
// 249:
// 250:         # Split into dependents that we could potentially be building from source and those
// 251:         # we should not. The criteria is that a dependent must have bottled dependencies, and
// 252:         # either the `--build-dependents-from-source` flag was passed or a dependent has no
// 253:         # bottle on the current OS.
// 254:         source_dependents, dependents = dependents.partition do |dependent, deps|
// 255:           next false unless build_dependent_from_source?(dependent)
// 256:
// 257:           all_deps_bottled_or_built = deps.all? do |d|
// 258:             bottled_or_built?(d.to_formula, @dependent_testing_formulae)
// 259:           end
// 260:           args.build_dependents_from_source? && all_deps_bottled_or_built
// 261:         end
// 262:
// 263:         # From the non-source list, get rid of any dependents we are only a build dependency to
// 264:         dependents.select! do |_, deps|
// 265:           deps.reject { |d| d.build? && !d.test? }
// 266:               .map(&:to_formula)
// 267:               .include?(formula)
// 268:         end
// 269:
// 270:         dependents = dependents.transpose.first.to_a
// 271:         source_dependents = source_dependents.transpose.first.to_a
// 272:
// 273:         testable_dependents = source_dependents.select(&:test_defined?)
// 274:         bottled_dependents = dependents.select { |dep| bottled?(dep) }
// 275:         testable_dependents += bottled_dependents.select(&:test_defined?)
// 276:
// 277:         info_header "Source dependents:"
// 278:         puts source_dependents
// 279:
// 280:         info_header "Bottled dependents:"
// 281:         puts bottled_dependents
// 282:
// 283:         info_header "Testable dependents:"
// 284:         puts testable_dependents
// 285:
// 286:         [source_dependents, bottled_dependents, testable_dependents]
// 287:       end
// 288:
// 289:       sig {
// 290:         params(formula: Formula, formula_name: String, args: Homebrew::Cmd::TestBotCmd::Args)
// 291:           .returns(T::Array[DependentWithDependencies])
// 292:       }
// 293:       def dependent_pairs_for_formula(formula, formula_name, args:)
// 294:         @dependent_pairs_by_formula[formula_name] ||= begin
// 295:           # Always skip recursive dependents on Intel. It's really slow.
// 296:           # Also skip recursive dependents on Linux unless it's a Linux-only formula.
// 297:           #
// 298:           skip_recursive_dependents = skip_recursive_dependents?(formula, args:)
// 299:
// 300:           uses_args = %w[--formula]
// 301:           uses_include_test_args = [*uses_args, "--include-test"]
// 302:           uses_include_test_args << "--recursive" unless skip_recursive_dependents
// 303:           uses_env = require_current_tap_trust_env.merge("HOMEBREW_STDERR" => "1")
// 304:           dependents = with_env(uses_env) do
// 305:             Utils.safe_popen_read("brew", "uses", *uses_include_test_args, formula_name)
// 306:                  .split("\n")
// 307:           end
// 308:
// 309:           # TODO: Consider handling the following case better.
// 310:           #       `foo` has a build dependency on `bar`, and `bar` has a runtime dependency on
// 311:           #       `baz`. When testing `baz` with `--build-dependents-from-source`, `foo` is
// 312:           #       not tested, but maybe should be.
// 313:           dependents += with_env(uses_env) do
// 314:             Utils.safe_popen_read("brew", "uses", *uses_args, "--include-build", formula_name)
// 315:                  .split("\n")
// 316:           end
// 317:           dependents.uniq!
// 318:           dependents.sort!
// 319:
// 320:           dependents -= @tested_formulae
// 321:           dependents = dependents.map { |d| Formulary.factory(d) }
// 322:
// 323:           dependents = dependents.zip(dependents.map do |f|
// 324:             if skip_recursive_dependents
// 325:               f.deps.reject(&:implicit?)
// 326:             else
// 327:               Dependency.expand(f, cache_key: "test-bot-dependents") do |_, dependency|
// 328:                 next Dependable::SKIP if dependency.implicit?
// 329:                 next Dependable::KEEP_BUT_PRUNE_RECURSIVE_DEPS if dependency.build? || dependency.test?
// 330:               end
// 331:             end.reject(&:optional?)
// 332:           end)
// 333:
// 334:           # Defer formulae which could be tested later
// 335:           # i.e. formulae that also depend on something else yet to be built in this test run.
// 336:           unless args.only_formulae_dependents?
// 337:             dependents.reject! do |_, deps|
// 338:               still_to_test = @dependent_testing_formulae - @testing_formulae_with_tested_dependents
// 339:               deps.map { |d| d.to_formula.full_name }.intersect?(still_to_test)
// 340:             end
// 341:           end
// 342:
// 343:           dependents
// 344:         end
// 345:       end
// 346:
// 347:       sig {
// 348:         params(
// 349:           dependent:           Formula,
// 350:           testable_dependents: T::Array[Formula],
// 351:           args:                Homebrew::Cmd::TestBotCmd::Args,
// 352:           build_from_source:   T::Boolean,
// 353:         ).void
// 354:       }
// 355:       def install_dependent(dependent, testable_dependents, args:, build_from_source: false)
// 356:         if @skip_candidates&.include?(dependent.full_name) &&
// 357:            artifact_cache_valid?(dependent, formulae_dependents: true)
// 358:           @tested_dependents_list&.write(dependent.full_name, mode: "a")
// 359:           @tested_dependents_list&.write("\n", mode: "a")
// 360:           skipped dependent.name, "#{dependent.full_name} has been tested at #{previous_github_sha}"
// 361:           return
// 362:         end
// 363:
// 364:         if (messages = unsatisfied_requirements_messages(dependent))
// 365:           skipped dependent.name, messages
// 366:           return
// 367:         end
// 368:
// 369:         if dependent.deprecated? || dependent.disabled?
// 370:           verb = dependent.deprecated? ? :deprecated : :disabled
// 371:           skipped dependent.name, "#{dependent.full_name} has been #{verb}!"
// 372:           return
// 373:         end
// 374:
// 375:         cleanup_during!(@dependent_testing_formulae, args:)
// 376:
// 377:         required_dependent_deps = dependent.deps.reject(&:optional?)
// 378:         bottled_on_current_version = bottled?(dependent, no_older_versions: true)
// 379:         dependent_was_previously_installed = dependent.latest_version_installed?
// 380:
// 381:         dependent_dependencies = Dependency.expand(
// 382:           dependent,
// 383:           cache_key: "test-bot-dependent-dependencies-#{dependent.full_name}",
// 384:         ) do |dep_dependent, dependency|
// 385:           next if !dependency.build? && !dependency.test? && !dependency.optional?
// 386:           next if dependency.test? &&
// 387:                   dep_dependent == dependent &&
// 388:                   !dependency.optional? &&
// 389:                   testable_dependents.include?(dependent)
// 390:
// 391:           next Dependable::PRUNE
// 392:         end
// 393:
// 394:         unless dependent_was_previously_installed
// 395:           build_args = []
// 396:
// 397:           fetch_formulae = dependent_dependencies.reject(&:satisfied?).map(&:name)
// 398:
// 399:           if build_from_source
// 400:             required_dependent_reqs = dependent.requirements.reject(&:optional?)
// 401:             install_curl_if_needed(dependent)
// 402:             install_mercurial_if_needed(required_dependent_deps, required_dependent_reqs)
// 403:             install_subversion_if_needed(required_dependent_deps, required_dependent_reqs)
// 404:
// 405:             build_args << "--build-from-source"
// 406:
// 407:             test "brew", "fetch", "--build-from-source", "--retry", dependent.full_name
// 408:             return if steps.fetch(-1).failed?
// 409:           else
// 410:             fetch_formulae << dependent.full_name
// 411:           end
// 412:
// 413:           if fetch_formulae.present?
// 414:             test "brew", "fetch", "--retry", *fetch_formulae
// 415:             return if steps.fetch(-1).failed?
// 416:           end
// 417:
// 418:           unlink_conflicts dependent
// 419:
// 420:           test "brew", "install", *build_args, "--only-dependencies",
// 421:                named_args:      dependent.full_name,
// 422:                ignore_failures: !bottled_on_current_version,
// 423:                env:             { "HOMEBREW_DEVELOPER" => nil }
// 424:
// 425:           env = {}
// 426:           env["HOMEBREW_GIT_PATH"] = nil if build_from_source && required_dependent_deps.any? do |d|
// 427:             d.name == "git" && (!d.test? || d.build?)
// 428:           end
// 429:           test "brew", "install", *build_args,
// 430:                named_args:      dependent.full_name,
// 431:                env:             env.merge({ "HOMEBREW_DEVELOPER" => nil }),
// 432:                ignore_failures: !args.test_default_formula? && !bottled_on_current_version
// 433:           install_step = steps.fetch(-1)
// 434:
// 435:           return unless install_step.passed?
// 436:         end
// 437:         return unless dependent.latest_version_installed?
// 438:
// 439:         if !dependent.keg_only? && !dependent.linked_keg.exist?
// 440:           unlink_conflicts dependent
// 441:           test "brew", "link", dependent.full_name
// 442:         end
// 443:         test "brew", "install", "--only-dependencies", dependent.full_name
// 444:         test "brew", "linkage", "--test",
// 445:              named_args:      dependent.full_name,
// 446:              ignore_failures: !args.test_default_formula? && !bottled_on_current_version
// 447:         linkage_step = steps.fetch(-1)
// 448:
// 449:         if linkage_step.passed? && !build_from_source
// 450:           # Check for opportunistic linkage. Ignore failures because
// 451:           # they can be unavoidable but we still want to know about them.
// 452:           test "brew", "linkage", "--cached", "--test", "--strict",
// 453:                named_args:      dependent.full_name,
// 454:                ignore_failures: !args.test_default_formula?
// 455:         end
// 456:
// 457:         if testable_dependents.include? dependent
// 458:           test "brew", "install", "--only-dependencies", "--include-test", dependent.full_name
// 459:
// 460:           dependent_dependencies.each do |dependency|
// 461:             dependency_f = dependency.to_formula
// 462:             next if dependency_f.keg_only?
// 463:             next if dependency_f.linked?
// 464:
// 465:             unlink_conflicts dependency_f
// 466:             test "brew", "link", dependency_f.full_name
// 467:           end
// 468:
// 469:           env = {}
// 470:           env["HOMEBREW_GIT_PATH"] = nil if required_dependent_deps.any? do |d|
// 471:             d.name == "git" && (!d.build? || d.test?)
// 472:           end
// 473:           test "brew", "test", "--retry", "--verbose",
// 474:                named_args:      dependent.full_name,
// 475:                env:,
// 476:                ignore_failures: !args.test_default_formula? && !bottled_on_current_version
// 477:           test_step = steps.fetch(-1)
// 478:         end
// 479:
// 480:         test "brew", "uninstall", "--force", "--ignore-dependencies", dependent.full_name
// 481:
// 482:         all_tests_passed = (dependent_was_previously_installed || install_step.passed?) &&
// 483:                            linkage_step.passed? &&
// 484:                            (testable_dependents.exclude?(dependent) || test_step&.passed?)
// 485:
// 486:         if all_tests_passed
// 487:           @tested_dependents_list&.write(dependent.full_name, mode: "a")
// 488:           @tested_dependents_list&.write("\n", mode: "a")
// 489:         end
// 490:
// 491:         return unless GitHub::Actions.env_set?
// 492:
// 493:         if build_from_source &&
// 494:            !bottled_on_current_version &&
// 495:            !dependent_was_previously_installed &&
// 496:            all_tests_passed &&
// 497:            dependent.deps.all? { |d| bottled?(d.to_formula, no_older_versions: true) }
// 498:           puts GitHub::Actions::Annotation.new(
// 499:             :notice,
// 500:             "All tests passed.",
// 501:             file:  dependent.path.to_s.delete_prefix("#{repository}/"),
// 502:             title: "#{dependent} should be bottled for #{Homebrew::TestBot.runner_os_title}!",
// 503:           )
// 504:         end
// 505:       end
// 506:
// 507:       sig { params(_formula: Formula, args: Homebrew::Cmd::TestBotCmd::Args).returns(T::Boolean) }
// 508:       def skip_recursive_dependents?(_formula, args:)
// 509:         args.skip_recursive_dependents? != false
// 510:       end
// 511:
// 512:       sig { params(_dependent: Formula).returns(T::Boolean) }
// 513:       def build_dependent_from_source?(_dependent)
// 514:         true
// 515:       end
// 516:
// 517:       sig { params(formula: Formula).void }
// 518:       def unlink_conflicts(formula)
// 519:         return if formula.keg_only?
// 520:         return if formula.linked_keg.exist?
// 521:
// 522:         conflicts = formula.conflicts.map { |c| Formulary.factory(c.name) }.select(&:any_version_installed?)
// 523:         formula_recursive_dependencies = formula.recursive_dependencies
// 524:         formula_recursive_dependencies.each do |dependency|
// 525:           conflicts += dependency.to_formula.conflicts.map do |c|
// 526:             Formulary.factory(c.name)
// 527:           end.select(&:any_version_installed?)
// 528:         end
// 529:         conflicts.each do |conflict|
// 530:           test "brew", "unlink", conflict.name
// 531:         end
// 532:       end
// 533:     end
// 534:   end
// 535: end
