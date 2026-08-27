module subcommand

import brew_runtime

// Translated from Homebrew/brew `bundle/subcommand/cleanup.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 78.
pub fn ruby_cleanup_l78_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `self.reset!` at line 100.
pub fn ruby_cleanup_l100_d2_self_reset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.reset!', ...args)
}

// Ruby method `self.cleanup(global: false, file: nil, force: false, zap: false, dsl: nil,` at line 121.
pub fn ruby_cleanup_l121_d3_self_cleanup(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.cleanup', ...args)
}

// Ruby method `self.read_dsl_from_brewfile!(global: false, file: nil, dsl: nil)` at line 233.
pub fn ruby_cleanup_l233_d4_self_read_dsl_from_brewfile(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.read_dsl_from_brewfile!', ...args)
}

// Ruby method `self.dsl` at line 246.
pub fn ruby_cleanup_l246_d5_self_dsl(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.dsl', ...args)
}

// Ruby method `self.casks_to_uninstall(global: false, file: nil)` at line 251.
pub fn ruby_cleanup_l251_d6_self_casks_to_uninstall(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.casks_to_uninstall', ...args)
}

// Ruby method `self.formulae_to_uninstall(global: false, file: nil)` at line 259.
pub fn ruby_cleanup_l259_d7_self_formulae_to_uninstall(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.formulae_to_uninstall', ...args)
}

// Ruby method `self.kept_formulae(global: false, file: nil)` at line 280.
pub fn ruby_cleanup_l280_d8_self_kept_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.kept_formulae', ...args)
}

// Ruby method `self.kept_casks(global: false, file: nil)` at line 304.
pub fn ruby_cleanup_l304_d9_self_kept_casks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.kept_casks', ...args)
}

// Ruby method `self.recursive_dependencies(current_formulae, formulae_names, top_level: true)` at line 322.
pub fn ruby_cleanup_l322_d10_self_recursive_dependencies(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.recursive_dependencies', ...args)
}

// Ruby method `self.taps_to_untap(global: false, file: nil)` at line 352.
pub fn ruby_cleanup_l352_d11_self_taps_to_untap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.taps_to_untap', ...args)
}

// Ruby method `self.lookup_formula(formula)` at line 373.
pub fn ruby_cleanup_l373_d12_self_lookup_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.lookup_formula', ...args)
}

// Ruby method `self.system_output_no_stderr(cmd, *args)` at line 381.
pub fn ruby_cleanup_l381_d13_self_system_output_no_stderr(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.system_output_no_stderr', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_subcommand"
// 5: require "bundle/extensions/extension"
// 6: require "cleanup"
// 7:
// 8: require "utils/formatter"
// 9: require "utils"
// 10: require "bundle/dsl"
// 11: require "bundle/extensions"
// 12: require "bundle/trust"
// 13: require "trust"
// 14: require "ask"
// 15: module Homebrew
// 16:   module Cmd
// 17:     class Bundle < Homebrew::AbstractCommand
// 18:       class CleanupSubcommand < Homebrew::AbstractSubcommand
// 19:         subcommand_args do
// 20:           usage_banner <<~EOS
// 21:             `brew bundle cleanup`:
// 22:             Uninstall all dependencies not present in the `Brewfile`.
// 23:
// 24:             This workflow is useful for maintainers or testers who regularly install lots of formulae.
// 25:
// 26:             When cleanup is performed, Homebrew's global trust store is reset to the trust values declared by the `Brewfile`, removing trust entries not declared there.
// 27:
// 28:             Unless `--force` is passed, this prompts before removing anything and returns a 1 exit code if the prompt is declined or cannot be shown.
// 29:           EOS
// 30:           named_args :none
// 31:           switch "--install",
// 32:                  description: "Run `install` before cleaning up dependencies."
// 33:           switch "-f", "--force",
// 34:                  description: "Actually perform cleanup operations and reset Homebrew's global trust store " \
// 35:                               "to the `Brewfile` values."
// 36:           switch "--all",
// 37:                  description: "Clean up all supported dependencies."
// 38:           switch "--formula", "--formulae", "--brews",
// 39:                  description: "Clean up Homebrew formula dependencies."
// 40:           switch "--no-formula", "--no-formulae", "--no-brews",
// 41:                  description: "Clean up without Homebrew formula dependencies. " \
// 42:                               "Enabled by default if `$HOMEBREW_BUNDLE_CLEANUP_NO_BREW` is set."
// 43:           switch "--no-cleanup-brew",
// 44:                  description: "Clean up without Homebrew formula dependencies.",
// 45:                  env:         :bundle_cleanup_no_brew
// 46:           switch "--cask", "--casks",
// 47:                  description: "Clean up Homebrew cask dependencies."
// 48:           switch "--no-cask", "--no-casks",
// 49:                  description: "Clean up without Homebrew cask dependencies. " \
// 50:                               "Enabled by default if `$HOMEBREW_BUNDLE_CLEANUP_NO_CASK` is set."
// 51:           switch "--no-cleanup-cask",
// 52:                  description: "Clean up without Homebrew cask dependencies.",
// 53:                  env:         :bundle_cleanup_no_cask
// 54:           switch "--tap", "--taps",
// 55:                  description: "Clean up Homebrew tap dependencies."
// 56:           switch "--no-tap", "--no-taps",
// 57:                  description: "Clean up without Homebrew tap dependencies. " \
// 58:                               "Enabled by default if `$HOMEBREW_BUNDLE_CLEANUP_NO_TAP` is set."
// 59:           switch "--no-cleanup-tap",
// 60:                  description: "Clean up without Homebrew tap dependencies.",
// 61:                  env:         :bundle_cleanup_no_tap
// 62:           Homebrew::Bundle.extensions.select(&:cleanup_supported?).each do |extension|
// 63:             env = "HOMEBREW_#{extension.cleanup_disable_env.to_s.upcase}"
// 64:             switch "--#{extension.flag}",
// 65:                    description: extension.switch_description("Clean up #{extension.banner_name}.")
// 66:             switch "--no-#{extension.flag}",
// 67:                    description: "#{extension.cleanup_disable_description} " \
// 68:                                 "Enabled by default if `$#{env}` is set."
// 69:             switch "--no-cleanup-#{extension.flag}",
// 70:                    description: extension.cleanup_disable_description,
// 71:                    env:         extension.cleanup_disable_env
// 72:           end
// 73:           switch "--zap",
// 74:                  description: "Clean up casks using the `zap` command instead of `uninstall`."
// 75:         end
// 76:
// 77:         sig { override.void }
// 78:         def run
// 79:           core_type_options = context.core_type_options(args, "cleanup", all: args.all?)
// 80:           self.class.cleanup(
// 81:             global:          context.global,
// 82:             file:            context.file,
// 83:             force:           context.force,
// 84:             zap:             context.zap,
// 85:             ask:             context.ask || !context.force,
// 86:             formulae:        core_type_options.fetch(:formulae),
// 87:             casks:           core_type_options.fetch(:casks),
// 88:             taps:            core_type_options.fetch(:taps),
// 89:             extension_types: context.extensions.select(&:cleanup_supported?).to_h do |extension|
// 90:               [
// 91:                 extension.type,
// 92:                 !context.extension_disabled?(args, extension) &&
// 93:                   (context.extension_selected?(args, extension) || args.all? || context.no_type_args),
// 94:               ]
// 95:             end,
// 96:           )
// 97:         end
// 98:
// 99:         sig { void }
// 100:         def self.reset!
// 101:           require "bundle/cask"
// 102:           require "bundle/brew"
// 103:           require "bundle/tap"
// 104:           require "bundle/brew_services"
// 105:
// 106:           @dsl = T.let(nil, T.nilable(Homebrew::Bundle::Dsl))
// 107:           @kept_casks = nil
// 108:           @kept_formulae = nil
// 109:           Homebrew::Bundle::Cask.reset!
// 110:           Homebrew::Bundle::Brew.reset!
// 111:           Homebrew::Bundle::Tap.reset!
// 112:           Homebrew::Bundle::Brew::Services.reset!
// 113:           Homebrew::Bundle.extensions.each(&:reset!)
// 114:         end
// 115:
// 116:         sig {
// 117:           params(global: T::Boolean, file: T.nilable(String), force: T::Boolean, zap: T::Boolean,
// 118:                  dsl: T.nilable(Homebrew::Bundle::Dsl), formulae: T::Boolean, casks: T::Boolean, taps: T::Boolean,
// 119:                  ask: T::Boolean, extension_types: Homebrew::Bundle::ExtensionTypes).void
// 120:         }
// 121:         def self.cleanup(global: false, file: nil, force: false, zap: false, dsl: nil,
// 122:                          formulae: true, casks: true, taps: true, ask: false, extension_types: {})
// 123:           read_dsl_from_brewfile!(global:, file:, dsl:)
// 124:
// 125:           cleanup_formulae = formulae
// 126:           cleanup_casks = casks
// 127:           cleanup_taps = taps
// 128:           extension_types = Homebrew::Bundle.extensions.select(&:cleanup_supported?).to_h do |extension|
// 129:             [extension.type, true]
// 130:           end.merge(extension_types)
// 131:           casks = if casks
// 132:             casks_to_uninstall(global:, file:)
// 133:           else
// 134:             []
// 135:           end
// 136:           formulae = if formulae
// 137:             formulae_to_uninstall(global:, file:)
// 138:           else
// 139:             []
// 140:           end
// 141:           taps = if taps
// 142:             taps_to_untap(global:, file:)
// 143:           else
// 144:             []
// 145:           end
// 146:           cleanup_extensions = Homebrew::Bundle.extensions.select(&:cleanup_supported?).filter_map do |extension|
// 147:             next unless extension_types.fetch(extension.type, false)
// 148:             raise ArgumentError, "dsl is unset!" unless @dsl
// 149:
// 150:             [extension, extension.cleanup_items(@dsl.entries)]
// 151:           end
// 152:           if force
// 153:             dsl = @dsl
// 154:             raise ArgumentError, "dsl is unset!" unless dsl
// 155:
// 156:             Homebrew::Trust.replace!(Homebrew::Bundle::Trust.entries(dsl.entries))
// 157:
// 158:             if casks.any?
// 159:               args = if zap
// 160:                 ["--zap"]
// 161:               else
// 162:                 []
// 163:               end
// 164:               Kernel.system HOMEBREW_BREW_FILE, "uninstall", "--cask", *args, "--force", *casks
// 165:               puts "Uninstalled #{casks.size} cask#{"s" if casks.size != 1}"
// 166:             end
// 167:
// 168:             if formulae.any?
// 169:               # Mark Brewfile formulae as installed_on_request to prevent autoremove
// 170:               # from removing them when their dependents are uninstalled
// 171:               Homebrew::Bundle.mark_as_installed_on_request!(dsl.entries)
// 172:
// 173:               Kernel.system HOMEBREW_BREW_FILE, "uninstall", "--formula", "--force", *formulae
// 174:               puts "Uninstalled #{formulae.size} formula#{"e" if formulae.size != 1}"
// 175:             end
// 176:
// 177:             Kernel.system HOMEBREW_BREW_FILE, "untap", *taps if taps.any?
// 178:
// 179:             cleanup_extensions.each do |extension, items|
// 180:               next if items.empty?
// 181:
// 182:               extension.cleanup!(items)
// 183:             end
// 184:
// 185:             cleanup = system_output_no_stderr(HOMEBREW_BREW_FILE, "cleanup")
// 186:             puts cleanup unless cleanup.empty?
// 187:           else
// 188:             would_uninstall = false
// 189:
// 190:             if casks.any?
// 191:               puts "Would uninstall casks:"
// 192:               puts Formatter.columns casks
// 193:               would_uninstall = true
// 194:             end
// 195:
// 196:             if formulae.any?
// 197:               puts "Would uninstall formulae:"
// 198:               puts Formatter.columns formulae
// 199:               would_uninstall = true
// 200:             end
// 201:
// 202:             if taps.any?
// 203:               puts "Would untap:"
// 204:               puts Formatter.columns taps
// 205:               would_uninstall = true
// 206:             end
// 207:
// 208:             cleanup_extensions.each do |extension, items|
// 209:               next if items.empty?
// 210:
// 211:               puts "Would uninstall #{extension.cleanup_heading}:"
// 212:               puts Formatter.columns items.map { |item| extension.cleanup_item_name(item) }
// 213:               would_uninstall = true
// 214:             end
// 215:
// 216:             would_cleanup = Cleanup.printed_dry_run_output?(Cleanup.dry_run_output)
// 217:             would_change = would_uninstall || would_cleanup
// 218:
// 219:             # `Ask.confirm?` only prints a prompt on a TTY; when it does, don't
// 220:             # also tell the user to rerun with `--force`.
// 221:             if ask && would_change && Homebrew::Ask.confirm?(action: "cleanup")
// 222:               cleanup(global:, file:, force: true, zap:, dsl: @dsl, formulae: cleanup_formulae, casks: cleanup_casks,
// 223:                       taps: cleanup_taps, extension_types:)
// 224:               return
// 225:             end
// 226:
// 227:             puts "Run `brew bundle cleanup --force` to make these changes." if would_change
// 228:             exit 1 if would_uninstall
// 229:           end
// 230:         end
// 231:
// 232:         sig { params(global: T::Boolean, file: T.nilable(String), dsl: T.nilable(Homebrew::Bundle::Dsl)).void }
// 233:         def self.read_dsl_from_brewfile!(global: false, file: nil, dsl: nil)
// 234:           @dsl = T.let(
// 235:             if dsl
// 236:               dsl
// 237:             else
// 238:               require "bundle/brewfile"
// 239:               Homebrew::Bundle::Brewfile.read(global:, file:)
// 240:             end,
// 241:             T.nilable(Homebrew::Bundle::Dsl),
// 242:           )
// 243:         end
// 244:
// 245:         sig { returns(T.nilable(Homebrew::Bundle::Dsl)) }
// 246:         def self.dsl
// 247:           T.let(@dsl, T.nilable(Homebrew::Bundle::Dsl))
// 248:         end
// 249:
// 250:         sig { params(global: T::Boolean, file: T.nilable(String)).returns(T::Array[String]) }
// 251:         def self.casks_to_uninstall(global: false, file: nil)
// 252:           raise ArgumentError, "@dsl is unset!" unless @dsl
// 253:
// 254:           require "bundle/cask"
// 255:           Homebrew::Bundle::Cask.cask_names - kept_casks(global:, file:)
// 256:         end
// 257:
// 258:         sig { params(global: T::Boolean, file: T.nilable(String)).returns(T::Array[String]) }
// 259:         def self.formulae_to_uninstall(global: false, file: nil)
// 260:           raise ArgumentError, "@dsl is unset!" unless @dsl
// 261:
// 262:           kept_formulae = self.kept_formulae(global:, file:)
// 263:
// 264:           require "bundle/brew"
// 265:           current_formulae = Homebrew::Bundle::Brew.formulae
// 266:           current_formulae.reject! do |f|
// 267:             Homebrew::Bundle::Brew.formula_in_array?(f[:full_name], kept_formulae)
// 268:           end
// 269:
// 270:           # Don't try to uninstall formulae with keepme references
// 271:           current_formulae.reject! do |f|
// 272:             Formula[f[:full_name]].installed_kegs.any? do |keg|
// 273:               keg.keepme_refs.present?
// 274:             end
// 275:           end
// 276:           current_formulae.map { |f| f[:full_name] }
// 277:         end
// 278:
// 279:         sig { params(global: T::Boolean, file: T.nilable(String)).returns(T::Array[String]) }
// 280:         private_class_method def self.kept_formulae(global: false, file: nil)
// 281:           require "bundle/brew"
// 282:           require "bundle/cask"
// 283:
// 284:           @kept_formulae ||= T.let(
// 285:             begin
// 286:               raise ArgumentError, "dsl is unset!" unless @dsl
// 287:
// 288:               kept_formulae = @dsl.entries.select { |e| e.type == :brew }.map(&:name)
// 289:               kept_formulae += Homebrew::Bundle::Cask.formula_dependencies(kept_casks)
// 290:               kept_formulae.map! do |f|
// 291:                 Homebrew::Bundle::Brew.formula_aliases.fetch(
// 292:                   f,
// 293:                   Homebrew::Bundle::Brew.formula_oldnames.fetch(f, f),
// 294:                 )
// 295:               end
// 296:
// 297:               kept_formulae + recursive_dependencies(Homebrew::Bundle::Brew.formulae, kept_formulae)
// 298:             end,
// 299:             T.nilable(T::Array[String]),
// 300:           )
// 301:         end
// 302:
// 303:         sig { params(global: T::Boolean, file: T.nilable(String)).returns(T::Array[String]) }
// 304:         private_class_method def self.kept_casks(global: false, file: nil)
// 305:           return @kept_casks if @kept_casks
// 306:           raise ArgumentError, "dsl is unset!" unless @dsl
// 307:
// 308:           kept_casks = @dsl.entries.select { |e| e.type == :cask }.flat_map(&:name)
// 309:           kept_casks.map! do |c|
// 310:             Homebrew::Bundle::Cask.cask_oldnames.fetch(c, c)
// 311:           end
// 312:           @kept_casks = T.let(kept_casks, T.nilable(T::Array[String]))
// 313:           raise "kept_casks is nil" unless @kept_casks
// 314:
// 315:           @kept_casks
// 316:         end
// 317:
// 318:         sig {
// 319:           params(current_formulae: T::Array[T::Hash[Symbol, T.untyped]], formulae_names: T::Array[String],
// 320:                  top_level: T::Boolean).returns(T::Array[String])
// 321:         }
// 322:         private_class_method def self.recursive_dependencies(current_formulae, formulae_names, top_level: true)
// 323:           @checked_formulae_names = T.let([], T.nilable(T::Array[String])) if top_level
// 324:           dependencies = T.let([], T::Array[String])
// 325:
// 326:           formulae_names.each do |name|
// 327:             raise "checked_formulae_names is unset!" unless @checked_formulae_names
// 328:             next if @checked_formulae_names.include?(name)
// 329:
// 330:             formula = current_formulae.find { |f| f[:full_name] == name }
// 331:             next unless formula
// 332:
// 333:             f_deps = formula[:dependencies]
// 334:             unless formula[:poured_from_bottle?]
// 335:               f_deps += formula[:build_dependencies]
// 336:               f_deps.uniq!
// 337:             end
// 338:             next unless f_deps
// 339:             next if f_deps.empty?
// 340:
// 341:             @checked_formulae_names << name
// 342:             f_deps += recursive_dependencies(current_formulae, f_deps, top_level: false)
// 343:             dependencies += f_deps
// 344:           end
// 345:
// 346:           dependencies.uniq
// 347:         end
// 348:
// 349:         IGNORED_TAPS = %w[homebrew/core].freeze
// 350:
// 351:         sig { params(global: T::Boolean, file: T.nilable(String)).returns(T::Array[String]) }
// 352:         def self.taps_to_untap(global: false, file: nil)
// 353:           raise ArgumentError, "@dsl is unset!" unless @dsl
// 354:
// 355:           require "bundle/tap"
// 356:
// 357:           kept_formulae = self.kept_formulae(global:, file:).filter_map { lookup_formula(it) }
// 358:           kept_taps = @dsl.entries.select { |e| e.type == :tap }.map(&:name)
// 359:           kept_taps += @dsl.entries.filter_map do |entry|
// 360:             case entry.type
// 361:             when :brew
// 362:               Utils.tap_from_full_name(entry.name)
// 363:             when :cask
// 364:               Utils.tap_from_full_name(T.cast(entry.options.fetch(:full_name, entry.name), String))
// 365:             end
// 366:           end
// 367:           kept_taps += kept_formulae.filter_map(&:tap).map(&:name)
// 368:           current_taps = Homebrew::Bundle::Tap.tap_names
// 369:           current_taps - kept_taps - IGNORED_TAPS
// 370:         end
// 371:
// 372:         sig { params(formula: String).returns(T.nilable(Formula)) }
// 373:         private_class_method def self.lookup_formula(formula)
// 374:           Formulary.factory(formula)
// 375:         rescue TapFormulaUnavailableError
// 376:           # ignore these as an unavailable formula implies there is no tap to worry about
// 377:           nil
// 378:         end
// 379:
// 380:         sig { params(cmd: T.any(Pathname, String), args: T.anything).returns(String) }
// 381:         def self.system_output_no_stderr(cmd, *args)
// 382:           Utils.safe_popen_read(cmd, *args, err: File::NULL)
// 383:         end
// 384:       end
// 385:     end
// 386:   end
// 387: end
