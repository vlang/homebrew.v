module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/unbottled.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 44.
pub fn ruby_unbottled_l44_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `formulae_all_installs_from_args(eval_all)` at line 128.
pub fn ruby_unbottled_l128_d2_formulae_all_installs_from_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formulae_all_installs_from_args', ...args)
}

// Ruby method `deps_uses_from_formulae(all_formulae)` at line 187.
pub fn ruby_unbottled_l187_d3_deps_uses_from_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('deps_uses_from_formulae', ...args)
}

// Ruby method `output_total(formulae)` at line 209.
pub fn ruby_unbottled_l209_d4_output_total(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('output_total', ...args)
}

// Ruby method `output_unbottled(formulae, deps_hash, noun, hash, any_named_args)` at line 225.
pub fn ruby_unbottled_l225_d5_output_unbottled(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('output_unbottled', ...args)
}

// Ruby method `output_lost_bottles` at line 303.
pub fn ruby_unbottled_l303_d6_output_lost_bottles(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('output_lost_bottles', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6: require "api"
// 7: require "os/mac/xcode"
// 8:
// 9: module Homebrew
// 10:   module DevCmd
// 11:     class Unbottled < AbstractCommand
// 12:       PORTABLE_FORMULAE = %w[
// 13:         portable-libffi
// 14:         portable-libxcrypt
// 15:         portable-libyaml
// 16:         portable-openssl
// 17:         portable-ruby
// 18:         portable-zlib
// 19:       ].freeze
// 20:
// 21:       cmd_args do
// 22:         description <<~EOS
// 23:           Show the unbottled dependents of formulae.
// 24:         EOS
// 25:         flag   "--tag=",
// 26:                description: "Use the specified bottle tag (e.g. `big_sur`) instead of the current OS."
// 27:         switch "--dependents",
// 28:                description: "Skip getting analytics data and sort by number of dependents instead."
// 29:         switch "--total",
// 30:                description: "Print the number of unbottled and total formulae."
// 31:         switch "--lost",
// 32:                description: "Print the `homebrew/core` commits where bottles were lost in the last week."
// 33:         switch "--eval-all",
// 34:                description: "Evaluate all available formulae and casks, whether installed or not, to check them.",
// 35:                env:         :eval_all,
// 36:                odeprecated: true
// 37:
// 38:         conflicts "--dependents", "--total", "--lost"
// 39:
// 40:         named_args :formula
// 41:       end
// 42:
// 43:       sig { override.void }
// 44:       def run
// 45:         Formulary.enable_factory_cache!
// 46:
// 47:         @bottle_tag = T.let(
// 48:           if (tag = args.tag)
// 49:             Utils::Bottles::Tag.from_symbol(tag.to_sym)
// 50:           else
// 51:             Utils::Bottles.tag
// 52:           end,
// 53:           T.nilable(Utils::Bottles::Tag),
// 54:         )
// 55:         return unless @bottle_tag
// 56:
// 57:         if args.lost?
// 58:           if args.named.present?
// 59:             raise UsageError, "`brew unbottled --lost` cannot be used with formula arguments!"
// 60:           elsif !CoreTap.instance.installed?
// 61:             raise UsageError, "`brew unbottled --lost` requires `homebrew/core` to be tapped locally!"
// 62:           else
// 63:             output_lost_bottles
// 64:             return
// 65:           end
// 66:         end
// 67:
// 68:         os = @bottle_tag.system
// 69:         arch = if Hardware::CPU::INTEL_ARCHS.include?(@bottle_tag.arch)
// 70:           :intel
// 71:         elsif Hardware::CPU::ARM_ARCHS.include?(@bottle_tag.arch)
// 72:           :arm
// 73:         else
// 74:           raise "Unknown arch #{@bottle_tag.arch}."
// 75:         end
// 76:
// 77:         Homebrew::SimulateSystem.with(os:, arch:) do
// 78:           eval_all = args.eval_all?
// 79:           eval_all ||= args.named.blank? && (args.total? || args.dependents?) &&
// 80:                        Homebrew::EnvConfig.tap_trust_configured?
// 81:
// 82:           if args.total? && !eval_all
// 83:             raise UsageError,
// 84:                   "`brew unbottled --total` needs `HOMEBREW_REQUIRE_TAP_TRUST=1` or " \
// 85:                   "`HOMEBREW_NO_REQUIRE_TAP_TRUST=1` set!"
// 86:           end
// 87:
// 88:           if args.named.blank?
// 89:             ohai "Getting formulae..."
// 90:           elsif eval_all
// 91:             raise UsageError, "Cannot specify formulae when evaluating all formulae or using `--total`."
// 92:           end
// 93:
// 94:           formulae, all_formulae, formula_installs = formulae_all_installs_from_args(eval_all)
// 95:           deps_hash, uses_hash = deps_uses_from_formulae(all_formulae)
// 96:
// 97:           if args.dependents?
// 98:             formula_dependents = {}
// 99:             formulae = formulae.sort_by do |f|
// 100:               dependents = uses_hash[f.name]&.length || 0
// 101:               formula_dependents[f.name] ||= dependents
// 102:             end.reverse
// 103:           elsif eval_all
// 104:             output_total(formulae)
// 105:             return
// 106:           end
// 107:
// 108:           noun, hash = if args.named.present?
// 109:             [nil, {}]
// 110:           elsif args.dependents?
// 111:             ["dependents", formula_dependents]
// 112:           else
// 113:             ["installs", formula_installs]
// 114:           end
// 115:
// 116:           return if hash.nil?
// 117:
// 118:           output_unbottled(formulae, deps_hash, noun, hash, args.named.present?)
// 119:         end
// 120:       end
// 121:
// 122:       private
// 123:
// 124:       sig {
// 125:         params(eval_all: T::Boolean).returns([T::Array[Formula], T::Array[Formula],
// 126:                                               T.nilable(T::Hash[Symbol, Integer])])
// 127:       }
// 128:       def formulae_all_installs_from_args(eval_all)
// 129:         if args.named.present?
// 130:           formulae = all_formulae = args.named.to_formulae
// 131:         elsif args.dependents?
// 132:           unless eval_all
// 133:             raise UsageError,
// 134:                   "`brew unbottled --dependents` needs `HOMEBREW_REQUIRE_TAP_TRUST=1` or " \
// 135:                   "`HOMEBREW_NO_REQUIRE_TAP_TRUST=1` set!"
// 136:           end
// 137:
// 138:           formulae = all_formulae = Formula.all(eval_all:)
// 139:
// 140:           @sort = T.let(" (sorted by number of dependents)", T.nilable(String))
// 141:         elsif eval_all
// 142:           formulae = all_formulae = Formula.all(eval_all:)
// 143:         else
// 144:           formula_installs = {}
// 145:
// 146:           ohai "Getting analytics data..."
// 147:           analytics = Homebrew::API::Analytics.fetch "install", 90
// 148:
// 149:           if analytics.blank?
// 150:             raise UsageError,
// 151:                   "default sort by analytics data requires " \
// 152:                   "`$HOMEBREW_NO_GITHUB_API` and `$HOMEBREW_NO_ANALYTICS` to be unset."
// 153:           end
// 154:
// 155:           formulae = analytics["items"].filter_map do |i|
// 156:             f = i["formula"].split.first
// 157:             next if f.include?("/")
// 158:             next if formula_installs[f].present?
// 159:
// 160:             formula_installs[f] = i["count"]
// 161:             begin
// 162:               Formula[f]
// 163:             rescue FormulaUnavailableError
// 164:               nil
// 165:             end
// 166:           end
// 167:           @sort = T.let(" (sorted by installs in the last 90 days; top 10,000 only)", T.nilable(String))
// 168:
// 169:           all_formulae = Formula.all(eval_all:)
// 170:         end
// 171:
// 172:         # Remove deprecated and disabled formulae as we do not care if they are unbottled
// 173:         formulae = Array(formulae).reject { |f| f.deprecated? || f.disabled? } if formulae.present?
// 174:         all_formulae = Array(all_formulae).reject { |f| f.deprecated? || f.disabled? } if all_formulae.present?
// 175:
// 176:         # Remove portable formulae as they are handled differently
// 177:         formulae = formulae.reject { |f| PORTABLE_FORMULAE.include?(f.name) } if formulae.present?
// 178:         all_formulae = all_formulae.reject { |f| PORTABLE_FORMULAE.include?(f.name) } if all_formulae.present?
// 179:
// 180:         [T.let(formulae, T::Array[Formula]), T.let(all_formulae, T::Array[Formula]),
// 181:          T.let(formula_installs, T.nilable(T::Hash[Symbol, Integer]))]
// 182:       end
// 183:
// 184:       sig {
// 185:         params(all_formulae: T::Array[Formula]).returns([T::Hash[String, T.untyped], T::Hash[String, T.untyped]])
// 186:       }
// 187:       def deps_uses_from_formulae(all_formulae)
// 188:         ohai "Populating dependency tree..."
// 189:
// 190:         deps_hash = {}
// 191:         uses_hash = {}
// 192:
// 193:         all_formulae.each do |f|
// 194:           deps = Dependency.expand(f, cache_key: "unbottled") do |_, dep|
// 195:             next Dependable::PRUNE if dep.optional?
// 196:           end.map(&:to_formula)
// 197:           deps_hash[f.name] = deps
// 198:
// 199:           deps.each do |dep|
// 200:             uses_hash[dep.name] ||= []
// 201:             uses_hash[dep.name] << f
// 202:           end
// 203:         end
// 204:
// 205:         [deps_hash, uses_hash]
// 206:       end
// 207:
// 208:       sig { params(formulae: T::Array[Formula]).void }
// 209:       def output_total(formulae)
// 210:         return unless @bottle_tag
// 211:
// 212:         ohai "Unbottled :#{@bottle_tag} formulae"
// 213:         unbottled_formulae = formulae.count do |f|
// 214:           !f.bottle_specification.tag?(@bottle_tag, no_older_versions: true)
// 215:         end
// 216:
// 217:         puts "#{unbottled_formulae}/#{formulae.length} remaining."
// 218:       end
// 219:
// 220:       sig {
// 221:         params(formulae: T::Array[Formula], deps_hash: T::Hash[T.any(Symbol, String), T.untyped],
// 222:                noun: T.nilable(String), hash: T::Hash[T.any(Symbol, String), T.untyped],
// 223:                any_named_args: T::Boolean).void
// 224:       }
// 225:       def output_unbottled(formulae, deps_hash, noun, hash, any_named_args)
// 226:         return unless @bottle_tag
// 227:
// 228:         ohai ":#{@bottle_tag} bottle status#{@sort}"
// 229:         any_found = T.let(false, T::Boolean)
// 230:
// 231:         formulae.each do |f|
// 232:           name = f.name.downcase
// 233:
// 234:           if f.disabled?
// 235:             puts "#{Tty.bold}#{Tty.green}#{name}#{Tty.reset}: formula disabled" if any_named_args
// 236:             next
// 237:           end
// 238:
// 239:           requirements = f.recursive_requirements
// 240:           if @bottle_tag.linux?
// 241:             if requirements.any?(MacOSRequirement)
// 242:               puts "#{Tty.bold}#{Tty.red}#{name}#{Tty.reset}: requires macOS" if any_named_args
// 243:               next
// 244:             elsif requirements.any? { |r| r.is_a?(ArchRequirement) && r.arch != @bottle_tag.arch }
// 245:               if any_named_args
// 246:                 puts "#{Tty.bold}#{Tty.red}#{name}#{Tty.reset}: doesn't support #{@bottle_tag.arch} Linux"
// 247:               end
// 248:               next
// 249:             end
// 250:           elsif requirements.any?(LinuxRequirement)
// 251:             puts "#{Tty.bold}#{Tty.red}#{name}#{Tty.reset}: requires Linux" if any_named_args
// 252:             next
// 253:           else
// 254:             macos_version = @bottle_tag.to_macos_version
// 255:             macos_satisfied = requirements.all? do |r|
// 256:               case r
// 257:               when MacOSRequirement
// 258:                 next true unless r.version_specified?
// 259:
// 260:                 macos_version.compare(r.comparator, T.cast(r.version, MacOSVersion))
// 261:               when XcodeRequirement
// 262:                 next true unless r.version
// 263:
// 264:                 Version.new(::OS::Mac::Xcode.latest_version(macos: macos_version)) >= r.version
// 265:               when ArchRequirement
// 266:                 r.arch == @bottle_tag.arch
// 267:               else
// 268:                 true
// 269:               end
// 270:             end
// 271:             unless macos_satisfied
// 272:               puts "#{Tty.bold}#{Tty.red}#{name}#{Tty.reset}: doesn't support this macOS" if any_named_args
// 273:               next
// 274:             end
// 275:           end
// 276:
// 277:           if f.bottle_specification.tag?(@bottle_tag, no_older_versions: true)
// 278:             puts "#{Tty.bold}#{Tty.green}#{name}#{Tty.reset}: already bottled" if any_named_args
// 279:             next
// 280:           end
// 281:
// 282:           deps = Array(deps_hash[f.name]).reject do |dep|
// 283:             dep.bottle_specification.tag?(@bottle_tag, no_older_versions: true)
// 284:           end
// 285:
// 286:           if deps.blank?
// 287:             count = " (#{hash[f.name]} #{noun})" if noun
// 288:             puts "#{Tty.bold}#{Tty.green}#{name}#{Tty.reset}#{count}: ready to bottle"
// 289:             next
// 290:           end
// 291:
// 292:           any_found ||= true
// 293:           count = " (#{hash[f.name]} #{noun})" if noun
// 294:           puts "#{Tty.bold}#{Tty.yellow}#{name}#{Tty.reset}#{count}: unbottled deps: #{deps.join(" ")}"
// 295:         end
// 296:         return if any_found
// 297:         return if any_named_args
// 298:
// 299:         puts "No unbottled dependencies found!"
// 300:       end
// 301:
// 302:       sig { void }
// 303:       def output_lost_bottles
// 304:         ohai ":#{@bottle_tag} lost bottles"
// 305:
// 306:         bottle_tag_regex_fragment = " +sha256.* #{@bottle_tag}: "
// 307:
// 308:         # $ git log --patch --no-ext-diff -G'^ +sha256.* sonoma:' --since=@{'1 week ago'}
// 309:         git_log = %w[git log --patch --no-ext-diff]
// 310:         git_log << "-G^#{bottle_tag_regex_fragment}"
// 311:         git_log << "--since=@{'1 week ago'}"
// 312:
// 313:         bottle_tag_sha_regex = /^[+-]#{bottle_tag_regex_fragment}/
// 314:
// 315:         processed_formulae = Set.new
// 316:         commit = T.let(nil, T.nilable(String))
// 317:         formula = T.let(nil, T.nilable(String))
// 318:         lost_bottles = 0
// 319:
// 320:         CoreTap.instance.path.cd do
// 321:           Utils.safe_popen_read(*git_log) do |io|
// 322:             io.each_line do |line|
// 323:               case line
// 324:               when /^commit [0-9a-f]{40}$/
// 325:                 # Example match: `commit 7289b409b96a752540befef1a56b8a818baf1db7`
// 326:                 if commit && formula && lost_bottles.positive? && processed_formulae.exclude?(formula)
// 327:                   puts "#{commit}: bottle lost for #{formula}"
// 328:                 end
// 329:                 processed_formulae << formula
// 330:                 commit = line.split.last
// 331:                 formula = nil
// 332:               when %r{^diff --git a/Formula/}
// 333:                 # Example match: `diff --git a/Formula/a/aws-cdk.rb b/Formula/a/aws-cdk.rb`
// 334:                 formula = line.split("/").fetch(-1).chomp(".rb\n")
// 335:                 formula = CoreTap.instance.formula_renames.fetch(formula, formula)
// 336:                 lost_bottles = 0
// 337:               when bottle_tag_sha_regex
// 338:                 # Example match: `-    sha256 cellar: :any_skip_relocation, sonoma: "f0a4..."`
// 339:                 next if processed_formulae.include?(formula)
// 340:
// 341:                 case line.chr
// 342:                 when "+" then lost_bottles -= 1
// 343:                 when "-" then lost_bottles += 1
// 344:                 end
// 345:               when /^[+] +sha256.* all: /
// 346:                 # Example match: `+    sha256 cellar: :any_skip_relocation, all: "9e35..."`
// 347:                 lost_bottles -= 1
// 348:               end
// 349:             end
// 350:           end
// 351:         end
// 352:
// 353:         return if !commit || !formula || !lost_bottles.positive? || processed_formulae.include?(formula)
// 354:
// 355:         puts "#{commit}: bottle lost for #{formula}"
// 356:       end
// 357:     end
// 358:   end
// 359: end
