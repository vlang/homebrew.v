module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/deps.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(argv = ARGV.freeze)` at line 108.
pub fn ruby_deps_l108_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `run` at line 114.
pub fn ruby_deps_l114_d2_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `input_formulae_and_casks` at line 234.
pub fn ruby_deps_l234_d3_input_formulae_and_casks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('input_formulae_and_casks', ...args)
}

// Ruby method `brewfile_path(value)` at line 255.
pub fn ruby_deps_l255_d4_brewfile_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('brewfile_path', ...args)
}

// Ruby method `sorted_dependents(formulae_or_casks)` at line 263.
pub fn ruby_deps_l263_d5_sorted_dependents(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sorted_dependents', ...args)
}

// Ruby method `condense_requirements(deps)` at line 268.
pub fn ruby_deps_l268_d6_condense_requirements(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('condense_requirements', ...args)
}

// Ruby method `dep_display_name(dep)` at line 274.
pub fn ruby_deps_l274_d7_dep_display_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dep_display_name', ...args)
}

// Ruby method `deps_for_dependent(dependency, recursive: false)` at line 304.
pub fn ruby_deps_l304_d8_deps_for_dependent(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('deps_for_dependent', ...args)
}

// Ruby method `deps_for_dependents(dependents, deps_combine_mode:, recursive:)` at line 327.
pub fn ruby_deps_l327_d9_deps_for_dependents(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('deps_for_dependents', ...args)
}

// Ruby method `check_head_spec(dependents)` at line 333.
pub fn ruby_deps_l333_d10_check_head_spec(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_head_spec', ...args)
}

// Ruby method `puts_deps(dependents, recursive: false)` at line 340.
pub fn ruby_deps_l340_d11_puts_deps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('puts_deps', ...args)
}

// Ruby method `dot_code(dependents, recursive:)` at line 352.
pub fn ruby_deps_l352_d12_dot_code(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dot_code', ...args)
}

// Ruby method `graph_deps(formula, dep_graph:, recursive:)` at line 380.
pub fn ruby_deps_l380_d13_graph_deps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('graph_deps', ...args)
}

// Ruby method `puts_deps_tree(dependents, recursive: false)` at line 397.
pub fn ruby_deps_l397_d14_puts_deps_tree(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('puts_deps_tree', ...args)
}

// Ruby method `dependables(formula)` at line 407.
pub fn ruby_deps_l407_d15_dependables(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dependables', ...args)
}

// Ruby method `recursive_deps_tree(formula, deps_seen:, prefix:, recursive:)` at line 423.
pub fn ruby_deps_l423_d16_recursive_deps_tree(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('recursive_deps_tree', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6: require "cask/caskroom"
// 7: require "dependencies_helpers"
// 8:
// 9: module Homebrew
// 10:   module Cmd
// 11:     class Deps < AbstractCommand
// 12:       include DependenciesHelpers
// 13:
// 14:       class DepsCombineMode < T::Enum
// 15:         enums do
// 16:           # enum values are not mutable, and calling .freeze on them breaks Sorbet
// 17:           # rubocop:disable Style/MutableConstant
// 18:           Intersection = new
// 19:           Union = new
// 20:           # rubocop:enable Style/MutableConstant
// 21:         end
// 22:       end
// 23:
// 24:       cmd_args do
// 25:         description <<~EOS
// 26:           Show dependencies for <formula>. When given multiple formula arguments,
// 27:           show the intersection of dependencies for each formula. By default, `deps`
// 28:           shows all required and recommended dependencies.
// 29:
// 30:           If any version of each formula argument is installed and no other options
// 31:           are passed, this command displays their actual runtime dependencies (similar
// 32:           to `brew linkage`), which may differ from a formula's declared dependencies.
// 33:
// 34:           *Note:* `--missing` and `--skip-recommended` have precedence over `--include-*`.
// 35:         EOS
// 36:         switch "-n", "--topological",
// 37:                description: "Sort dependencies in topological order."
// 38:         switch "-1", "--direct", "--declared", "--1",
// 39:                description: "Show only the direct dependencies declared in the formula."
// 40:         switch "--union",
// 41:                description: "Show the union of dependencies for multiple <formula>, instead of the intersection."
// 42:         switch "--full-name",
// 43:                description: "List dependencies by their full name."
// 44:         switch "--include-implicit",
// 45:                description: "Include implicit dependencies used to download and unpack source files."
// 46:         switch "--include-build",
// 47:                description: "Include `:build` dependencies for <formula>."
// 48:         switch "--include-optional",
// 49:                description: "Include `:optional` dependencies for <formula>."
// 50:         switch "--include-test",
// 51:                description: "Include `:test` dependencies for <formula> (non-recursive unless `--graph` or `--tree`)."
// 52:         switch "--skip-recommended",
// 53:                description: "Skip `:recommended` dependencies for <formula>."
// 54:         switch "--include-requirements",
// 55:                description: "Include requirements in addition to dependencies for <formula>."
// 56:         switch "--tree",
// 57:                description: "Show dependencies as a tree. When given multiple formula arguments, " \
// 58:                             "show individual trees for each formula."
// 59:         switch "--prune",
// 60:                depends_on:  "--tree",
// 61:                description: "Prune parts of tree already seen."
// 62:         switch "--graph",
// 63:                description: "Show dependencies as a directed graph."
// 64:         switch "--dot",
// 65:                depends_on:  "--graph",
// 66:                description: "Show text-based graph description in DOT format."
// 67:         switch "--annotate",
// 68:                description: "Mark any build, test, implicit, optional, or recommended dependencies as " \
// 69:                             "such in the output."
// 70:         switch "--installed",
// 71:                description: "List dependencies for formulae that are currently installed. If <formula> is " \
// 72:                             "specified, list only its dependencies that are currently installed."
// 73:         flag   "--brewfile",
// 74:                description: "Use formulae and casks listed in a Brewfile as inputs. " \
// 75:                             "Defaults to `./Brewfile`; use `--brewfile=`<path> to specify another."
// 76:         switch "--missing",
// 77:                description: "Show only missing dependencies."
// 78:         switch "--eval-all",
// 79:                description: "Evaluate all available formulae and casks, whether installed or not, to list " \
// 80:                             "their dependencies.",
// 81:                env:         :eval_all,
// 82:                odeprecated: true
// 83:         switch "--for-each",
// 84:                description: "Switch into the mode used when evaluating all formulae and casks, but only list " \
// 85:                             "dependencies for each provided <formula>, one formula per line."
// 86:         switch "--HEAD",
// 87:                description: "Show dependencies for HEAD version instead of stable version."
// 88:         flag   "--os=",
// 89:                description: "Show dependencies for the given operating system."
// 90:         flag   "--arch=",
// 91:                description: "Show dependencies for the given CPU architecture."
// 92:         switch "--formula", "--formulae",
// 93:                description: "Treat all named arguments as formulae."
// 94:         switch "--cask", "--casks",
// 95:                description: "Treat all named arguments as casks."
// 96:
// 97:         conflicts "--tree", "--graph"
// 98:         conflicts "--installed", "--missing"
// 99:         conflicts "--installed", "--eval-all"
// 100:         conflicts "--brewfile", "--eval-all"
// 101:         conflicts "--formula", "--cask"
// 102:         formula_options
// 103:
// 104:         named_args [:formula, :cask]
// 105:       end
// 106:
// 107:       sig { override.params(argv: T::Array[String]).void }
// 108:       def initialize(argv = ARGV.freeze)
// 109:         super
// 110:         @use_runtime_dependencies = T.let(true, T::Boolean)
// 111:       end
// 112:
// 113:       sig { override.void }
// 114:       def run
// 115:         raise UsageError, "`brew deps --os=all` is not supported." if args.os == "all"
// 116:         raise UsageError, "`brew deps --arch=all` is not supported." if args.arch == "all"
// 117:
// 118:         os, arch = args.os_arch_combinations.fetch(0)
// 119:         eval_all = args.eval_all?
// 120:         eval_all ||= args.no_named? && !args.installed? && !args.brewfile &&
// 121:                      Homebrew::EnvConfig.tap_trust_configured?
// 122:
// 123:         Formulary.enable_factory_cache!
// 124:
// 125:         SimulateSystem.with(os:, arch:) do
// 126:           inputs = input_formulae_and_casks
// 127:           installed = args.installed? || dependents(inputs).all?(&:any_version_installed?)
// 128:           unless installed
// 129:             not_using_runtime_dependencies_reason = if args.installed?
// 130:               "not all the named formulae were installed"
// 131:             else
// 132:               "`--installed` was not passed"
// 133:             end
// 134:
// 135:             @use_runtime_dependencies = false
// 136:           end
// 137:
// 138:           %w[direct tree graph HEAD skip_recommended missing
// 139:              include_implicit include_build include_test include_optional].each do |arg|
// 140:             next unless args.public_send("#{arg}?")
// 141:
// 142:             not_using_runtime_dependencies_reason = "--#{arg.tr("_", "-")} was passed"
// 143:
// 144:             @use_runtime_dependencies = false
// 145:           end
// 146:
// 147:           %w[os arch].each do |arg|
// 148:             next if args.public_send(arg).nil?
// 149:
// 150:             not_using_runtime_dependencies_reason = "--#{arg.tr("_", "-")} was passed"
// 151:
// 152:             @use_runtime_dependencies = false
// 153:           end
// 154:
// 155:           if !@use_runtime_dependencies && !Homebrew::EnvConfig.no_env_hints?
// 156:             opoo <<~EOS
// 157:               `brew deps` is not the actual runtime dependencies because #{not_using_runtime_dependencies_reason}!
// 158:               This means dependencies may differ from a formula's declared dependencies.
// 159:               Hide these hints with `HOMEBREW_NO_ENV_HINTS=1` (see `man brew`).
// 160:             EOS
// 161:           end
// 162:
// 163:           recursive = !args.direct?
// 164:
// 165:           if args.tree? || args.graph?
// 166:             dependents = if inputs.any?
// 167:               sorted_dependents(inputs)
// 168:             elsif args.installed?
// 169:               case args.only_formula_or_cask
// 170:               when :formula
// 171:                 sorted_dependents(Formula.installed)
// 172:               when :cask
// 173:                 sorted_dependents(Cask::Caskroom.casks)
// 174:               else
// 175:                 sorted_dependents(Formula.installed + Cask::Caskroom.casks)
// 176:               end
// 177:             else
// 178:               raise FormulaUnspecifiedError
// 179:             end
// 180:
// 181:             if args.graph?
// 182:               dot_code = dot_code(dependents, recursive:)
// 183:               if args.dot?
// 184:                 puts dot_code
// 185:               else
// 186:                 exec_browser "https://dreampuf.github.io/GraphvizOnline/##{ERB::Util.url_encode(dot_code)}"
// 187:               end
// 188:               return
// 189:             end
// 190:
// 191:             puts_deps_tree(dependents, recursive:)
// 192:             return
// 193:           elsif eval_all
// 194:             puts_deps(sorted_dependents(
// 195:                         Formula.all(eval_all:) + Cask::Cask.all(eval_all:),
// 196:                       ), recursive:)
// 197:             return
// 198:           elsif inputs.any? && args.for_each?
// 199:             puts_deps(sorted_dependents(inputs), recursive:)
// 200:             return
// 201:           end
// 202:
// 203:           if inputs.empty?
// 204:             raise FormulaUnspecifiedError unless args.installed?
// 205:
// 206:             sorted_dependents_formulae_and_casks = case args.only_formula_or_cask
// 207:             when :formula
// 208:               sorted_dependents(Formula.installed)
// 209:             when :cask
// 210:               sorted_dependents(Cask::Caskroom.casks)
// 211:             else
// 212:               sorted_dependents(Formula.installed + Cask::Caskroom.casks)
// 213:             end
// 214:             puts_deps(sorted_dependents_formulae_and_casks, recursive:)
// 215:             return
// 216:           end
// 217:
// 218:           dependents = dependents(inputs)
// 219:           check_head_spec(dependents) if args.HEAD?
// 220:
// 221:           deps_combine_mode = args.union? ? DepsCombineMode::Union : DepsCombineMode::Intersection
// 222:           all_deps = deps_for_dependents(dependents, deps_combine_mode:, recursive:)
// 223:           condense_requirements(all_deps)
// 224:           all_deps.map! { dep_display_name(it) }
// 225:           all_deps.uniq!
// 226:           all_deps.sort! unless args.topological?
// 227:           puts all_deps
// 228:         end
// 229:       end
// 230:
// 231:       private
// 232:
// 233:       sig { returns(T::Array[T.any(Formula, Keg, Cask::Cask)]) }
// 234:       def input_formulae_and_casks
// 235:         named = args.named.to_formulae_and_casks
// 236:         brewfile = args.brewfile
// 237:         return named unless brewfile
// 238:
// 239:         require "bundle/brewfile"
// 240:         require "cask/cask_loader"
// 241:         only = args.only_formula_or_cask
// 242:         from_brewfile = Homebrew::Bundle::Brewfile.read(file: brewfile_path(brewfile)).entries.filter_map do |e|
// 243:           case e.type
// 244:           when :brew then Formulary.resolve(e.name) if only != :cask
// 245:           when :cask then Cask::CaskLoader.load(e.name) if only != :formula
// 246:           end
// 247:         end
// 248:         (named + from_brewfile).uniq
// 249:       end
// 250:
// 251:       # A bare `--brewfile` (no `=path`) yields `true` from OptionParser at
// 252:       # runtime; the generated RBI types it as `T.nilable(String)`, so accept
// 253:       # the wider type here and normalise `true`/`""` to the `nil` default.
// 254:       sig { params(value: T.nilable(T.any(String, TrueClass))).returns(T.nilable(String)) }
// 255:       def brewfile_path(value)
// 256:         value.presence if value.is_a?(String)
// 257:       end
// 258:
// 259:       sig {
// 260:         params(formulae_or_casks: T::Array[T.any(Formula, Keg, Cask::Cask)])
// 261:           .returns(T::Array[T.any(Formula, CaskDependent)])
// 262:       }
// 263:       def sorted_dependents(formulae_or_casks)
// 264:         dependents(formulae_or_casks).sort_by(&:name)
// 265:       end
// 266:
// 267:       sig { params(deps: T::Array[T.any(Dependency, Requirement)]).void }
// 268:       def condense_requirements(deps)
// 269:         deps.select! { |dep| dep.is_a?(Dependency) } unless args.include_requirements?
// 270:         deps.select! { |dep| dep.is_a?(Requirement) || dep.installed? } if args.installed?
// 271:       end
// 272:
// 273:       sig { params(dep: T.any(Requirement, Dependency)).returns(String) }
// 274:       def dep_display_name(dep)
// 275:         str = if dep.is_a? Requirement
// 276:           if args.include_requirements?
// 277:             ":#{dep.display_s}"
// 278:           else
// 279:             # This shouldn't happen, but we'll put something here to help debugging
// 280:             "::#{dep.name}"
// 281:           end
// 282:         elsif args.full_name?
// 283:           dep.to_formula.full_name
// 284:         else
// 285:           dep.name
// 286:         end
// 287:
// 288:         if args.annotate?
// 289:           str = "#{str} " if args.tree?
// 290:           str = "#{str} [build]" if dep.build?
// 291:           str = "#{str} [test]" if dep.test?
// 292:           str = "#{str} [optional]" if dep.optional?
// 293:           str = "#{str} [recommended]" if dep.recommended?
// 294:           str = "#{str} [implicit]" if dep.implicit?
// 295:         end
// 296:
// 297:         str
// 298:       end
// 299:
// 300:       sig {
// 301:         params(dependency: T.any(Formula, CaskDependent), recursive: T::Boolean)
// 302:           .returns(T::Array[T.any(Dependency, Requirement)])
// 303:       }
// 304:       def deps_for_dependent(dependency, recursive: false)
// 305:         includes, ignores = args_includes_ignores(args)
// 306:
// 307:         deps = dependency.runtime_dependencies if @use_runtime_dependencies
// 308:
// 309:         if recursive
// 310:           deps ||= recursive_dep_includes(dependency, includes, ignores)
// 311:           reqs = args.include_requirements? ? recursive_req_includes(dependency, includes, ignores) : Requirements.new
// 312:         else
// 313:           deps ||= select_includes(dependency.deps, ignores, includes)
// 314:           reqs   = select_includes(dependency.requirements, ignores, includes)
// 315:         end
// 316:
// 317:         deps + reqs.to_a
// 318:       end
// 319:
// 320:       sig {
// 321:         params(
// 322:           dependents:        T::Array[T.any(Formula, CaskDependent)],
// 323:           deps_combine_mode: DepsCombineMode,
// 324:           recursive:         T::Boolean,
// 325:         ).returns(T::Array[T.any(Dependency, Requirement)])
// 326:       }
// 327:       def deps_for_dependents(dependents, deps_combine_mode:, recursive:)
// 328:         symbol = (deps_combine_mode == DepsCombineMode::Intersection) ? :& : :|
// 329:         dependents.map { deps_for_dependent(it, recursive:) }.reduce(symbol)
// 330:       end
// 331:
// 332:       sig { params(dependents: T::Array[T.any(Formula, CaskDependent)]).void }
// 333:       def check_head_spec(dependents)
// 334:         headless = dependents.select { it.is_a?(Formula) && it.active_spec_sym != :head }
// 335:                              .to_sentence two_words_connector: " or ", last_word_connector: " or "
// 336:         opoo "No head spec for #{headless}, using stable spec instead" unless headless.empty?
// 337:       end
// 338:
// 339:       sig { params(dependents: T::Array[T.any(Formula, CaskDependent)], recursive: T::Boolean).void }
// 340:       def puts_deps(dependents, recursive: false)
// 341:         check_head_spec(dependents) if args.HEAD?
// 342:         dependents.each do |dependent|
// 343:           deps = deps_for_dependent(dependent, recursive:)
// 344:           condense_requirements(deps)
// 345:           deps.sort_by!(&:name)
// 346:           deps.map! { dep_display_name(it) }
// 347:           puts "#{dependent.full_name}: #{deps.join(" ")}"
// 348:         end
// 349:       end
// 350:
// 351:       sig { params(dependents: T::Array[T.any(Formula, CaskDependent)], recursive: T::Boolean).returns(String) }
// 352:       def dot_code(dependents, recursive:)
// 353:         dep_graph = {}
// 354:         dependents.each { graph_deps(it, dep_graph:, recursive:) }
// 355:
// 356:         dot_code = dep_graph.map do |d, deps|
// 357:           deps.map do |dep|
// 358:             attributes = []
// 359:             attributes << "style = dotted" if dep.build?
// 360:             attributes << "arrowhead = empty" if dep.test?
// 361:             if dep.optional?
// 362:               attributes << "color = red"
// 363:             elsif dep.recommended?
// 364:               attributes << "color = green"
// 365:             end
// 366:             comment = " # #{dep.tags.map(&:inspect).join(", ")}" if dep.tags.any?
// 367:             "  \"#{d.name}\" -> \"#{dep}\"#{" [#{attributes.join(", ")}]" if attributes.any?}#{comment}"
// 368:           end
// 369:         end.flatten.join("\n")
// 370:         "digraph {\n#{dot_code}\n}"
// 371:       end
// 372:
// 373:       sig {
// 374:         params(
// 375:           formula:   T.any(Formula, CaskDependent),
// 376:           dep_graph: T::Hash[T.any(Formula, CaskDependent), T::Array[T.any(Dependency, Requirement)]],
// 377:           recursive: T::Boolean,
// 378:         ).void
// 379:       }
// 380:       def graph_deps(formula, dep_graph:, recursive:)
// 381:         return if dep_graph.key?(formula)
// 382:
// 383:         dependables = dependables(formula)
// 384:         dep_graph[formula] = dependables
// 385:         return unless recursive
// 386:
// 387:         dependables.each do |dep|
// 388:           next unless dep.is_a? Dependency
// 389:
// 390:           graph_deps(Formulary.factory(dep.name),
// 391:                      dep_graph:,
// 392:                      recursive: true)
// 393:         end
// 394:       end
// 395:
// 396:       sig { params(dependents: T::Array[T.any(Formula, CaskDependent)], recursive: T::Boolean).void }
// 397:       def puts_deps_tree(dependents, recursive: false)
// 398:         check_head_spec(dependents) if args.HEAD?
// 399:         dependents.each do |d|
// 400:           puts d.full_name
// 401:           recursive_deps_tree(d, deps_seen: {}, prefix: "", recursive:)
// 402:           puts
// 403:         end
// 404:       end
// 405:
// 406:       sig { params(formula: T.any(Formula, CaskDependent)).returns(T::Array[T.any(Dependency, Requirement)]) }
// 407:       def dependables(formula)
// 408:         includes, ignores = args_includes_ignores(args)
// 409:         deps = @use_runtime_dependencies ? formula.runtime_dependencies : formula.deps
// 410:         deps = select_includes(deps, ignores, includes)
// 411:         reqs = select_includes(formula.requirements, ignores, includes) if args.include_requirements?
// 412:         reqs ||= []
// 413:         reqs + deps
// 414:       end
// 415:
// 416:       sig {
// 417:         params(
// 418:           formula: T.any(Formula, CaskDependent),
// 419:           deps_seen: T::Hash[String, T::Boolean],
// 420:           prefix: String, recursive: T::Boolean
// 421:         ).void
// 422:       }
// 423:       def recursive_deps_tree(formula, deps_seen:, prefix:, recursive:)
// 424:         dependables = dependables(formula)
// 425:         max = dependables.length - 1
// 426:         deps_seen[formula.name] = true
// 427:         dependables.each_with_index do |dep, i|
// 428:           tree_lines = if i == max
// 429:             "└──"
// 430:           else
// 431:             "├──"
// 432:           end
// 433:
// 434:           display_s = "#{tree_lines} #{dep_display_name(dep)}"
// 435:
// 436:           # Detect circular dependencies and consider them a failure if present.
// 437:           is_circular = deps_seen.fetch(dep.name, false)
// 438:           pruned = args.prune? && deps_seen.include?(dep.name)
// 439:           if is_circular
// 440:             display_s = "#{display_s} (CIRCULAR DEPENDENCY)"
// 441:             Homebrew.failed = true
// 442:           elsif pruned
// 443:             display_s = "#{display_s} (PRUNED)"
// 444:           end
// 445:
// 446:           puts "#{prefix}#{display_s}"
// 447:
// 448:           next if !recursive || is_circular || pruned
// 449:
// 450:           prefix_addition = if i == max
// 451:             "    "
// 452:           else
// 453:             "│   "
// 454:           end
// 455:
// 456:           next unless dep.is_a? Dependency
// 457:
// 458:           recursive_deps_tree(Formulary.factory(dep.name),
// 459:                               deps_seen:,
// 460:                               prefix:    prefix + prefix_addition,
// 461:                               recursive: true)
// 462:         end
// 463:
// 464:         deps_seen[formula.name] = false
// 465:       end
// 466:     end
// 467:   end
// 468: end
