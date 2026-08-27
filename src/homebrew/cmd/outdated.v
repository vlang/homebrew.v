module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/outdated.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 53.
pub fn ruby_outdated_l53_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `select_outdated(formulae_or_casks)` at line 96.
pub fn ruby_outdated_l96_d2_select_outdated(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('select_outdated', ...args)
}

// Ruby method `print_outdated(formulae_or_casks)` at line 121.
pub fn ruby_outdated_l121_d3_print_outdated(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('print_outdated', ...args)
}

// Ruby method `json_info(formulae_or_casks)` at line 182.
pub fn ruby_outdated_l182_d4_json_info(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('json_info', ...args)
}

// Ruby method `verbose?` at line 222.
pub fn ruby_outdated_l222_d5_verbose(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('verbose?', ...args)
}

// Ruby method `json_version(version)` at line 227.
pub fn ruby_outdated_l227_d6_json_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('json_version', ...args)
}

// Ruby method `minimum_version = args.minimum_version || args.min_version` at line 238.
pub fn ruby_outdated_l238_d7_minimum_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('minimum_version', ...args)
}

// Ruby method `outdated_formulae` at line 241.
pub fn ruby_outdated_l241_d8_outdated_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('outdated_formulae', ...args)
}

// Ruby method `outdated_casks` at line 249.
pub fn ruby_outdated_l249_d9_outdated_casks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('outdated_casks', ...args)
}

// Ruby method `outdated_formulae_casks` at line 260.
pub fn ruby_outdated_l260_d10_outdated_formulae_casks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('outdated_formulae_casks', ...args)
}

// Ruby method `formula_outdated_kegs(formula)` at line 272.
pub fn ruby_outdated_l272_d11_formula_outdated_kegs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_outdated_kegs', ...args)
}

// Ruby method `upgrade_greedy_cask?(greedy, cask)` at line 277.
pub fn ruby_outdated_l277_d12_upgrade_greedy_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('upgrade_greedy_cask?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6: require "cask/caskroom"
// 7: require "api"
// 8: require "minimum_version"
// 9:
// 10: module Homebrew
// 11:   module Cmd
// 12:     class Outdated < AbstractCommand
// 13:       cmd_args do
// 14:         description <<~EOS
// 15:           List installed casks and formulae that have an updated version available. By default, version
// 16:           information is displayed in interactive shells and suppressed otherwise.
// 17:         EOS
// 18:         switch "-q", "--quiet",
// 19:                description: "List only the names of outdated kegs (takes precedence over `--verbose`)."
// 20:         switch "-v", "--verbose",
// 21:                description: "Include detailed version information."
// 22:         switch "--formula", "--formulae",
// 23:                description: "List only outdated formulae."
// 24:         switch "--cask", "--casks",
// 25:                description: "List only outdated casks."
// 26:         flag   "--json",
// 27:                description: "Print output in JSON format. There are two versions: `v1` and `v2`. " \
// 28:                             "`v1` is deprecated and is currently the default if no version is specified. " \
// 29:                             "`v2` prints outdated formulae and casks."
// 30:         flag   "--minimum-version=", "--min-version=",
// 31:                description: "Only list a named formula or cask with an installed version below the given " \
// 32:                             "minimum version."
// 33:         switch "--fetch-HEAD",
// 34:                description: "Fetch the upstream repository to detect if the HEAD installation of the " \
// 35:                             "formula is outdated. Otherwise, the repository's HEAD will only be checked for " \
// 36:                             "updates when a new stable or development version has been released."
// 37:         switch "-g", "--greedy",
// 38:                description: "Also include outdated casks with `version :latest` and `auto_updates true` " \
// 39:                             "casks that would otherwise be skipped.",
// 40:                env:         :upgrade_greedy
// 41:         switch "--greedy-latest",
// 42:                description: "Also include outdated casks including those with `version :latest`."
// 43:         switch "--greedy-auto-updates",
// 44:                description: "Also include outdated `auto_updates true` casks that would otherwise be skipped."
// 45:
// 46:         conflicts "--quiet", "--verbose", "--json"
// 47:         conflicts "--formula", "--cask"
// 48:
// 49:         named_args [:formula, :cask]
// 50:       end
// 51:
// 52:       sig { override.void }
// 53:       def run
// 54:         raise UsageError, "`--minimum-version` requires exactly one formula or cask argument." if
// 55:           minimum_version.present? && args.named.length != 1
// 56:
// 57:         case json_version(args.json)
// 58:         when :v1
// 59:           odie "`brew outdated --json=v1` is no longer supported. Use brew outdated --json=v2 instead."
// 60:         when :v2, :default
// 61:           formulae, casks = if args.formula?
// 62:             [outdated_formulae, []]
// 63:           elsif args.cask?
// 64:             [[], outdated_casks]
// 65:           else
// 66:             outdated_formulae_casks
// 67:           end
// 68:
// 69:           json = {
// 70:             formulae: json_info(formulae),
// 71:             casks:    json_info(casks),
// 72:           }
// 73:           # json v2.8.1 is inconsistent it how it renders empty arrays,
// 74:           # so we use `[]` for consistency:
// 75:           puts JSON.pretty_generate(json).gsub(/\[\n\n\s*\]/, "[]")
// 76:
// 77:           outdated = formulae + casks
// 78:         else
// 79:           outdated = if args.formula?
// 80:             outdated_formulae
// 81:           elsif args.cask?
// 82:             outdated_casks
// 83:           else
// 84:             outdated_formulae_casks.flatten
// 85:           end
// 86:
// 87:           print_outdated(outdated)
// 88:         end
// 89:
// 90:         Homebrew.failed = args.named.present? && outdated.present?
// 91:       end
// 92:
// 93:       sig {
// 94:         params(formulae_or_casks: T::Array[T.any(Formula, Cask::Cask)]).returns(T::Array[T.any(Formula, Cask::Cask)])
// 95:       }
// 96:       def select_outdated(formulae_or_casks)
// 97:         formulae_or_casks.select do |formula_or_cask|
// 98:           if formula_or_cask.is_a?(Formula)
// 99:             if minimum_version.present?
// 100:               formula_outdated_kegs(formula_or_cask).present?
// 101:             else
// 102:               formula_or_cask.outdated?(fetch_head: args.fetch_HEAD?)
// 103:             end
// 104:           else
// 105:             if minimum_version.present?
// 106:               next MinimumVersion.cask_installed_below?(formula_or_cask, T.must(minimum_version))
// 107:             end
// 108:
// 109:             cask_greedy = upgrade_greedy_cask?(args.greedy?, formula_or_cask)
// 110:
// 111:             formula_or_cask.outdated?(greedy:              cask_greedy,
// 112:                                       greedy_latest:       args.greedy_latest?,
// 113:                                       greedy_auto_updates: args.greedy_auto_updates?)
// 114:           end
// 115:         end
// 116:       end
// 117:
// 118:       private
// 119:
// 120:       sig { params(formulae_or_casks: T::Array[T.any(Formula, Cask::Cask)]).void }
// 121:       def print_outdated(formulae_or_casks)
// 122:         formulae_or_casks.each do |formula_or_cask|
// 123:           if formula_or_cask.is_a?(Formula)
// 124:             f = formula_or_cask
// 125:
// 126:             if verbose?
// 127:               outdated_kegs = formula_outdated_kegs(f)
// 128:               latest_formula = f.latest_formula
// 129:
// 130:               current_version = if minimum_version.present?
// 131:                 minimum_version
// 132:               elsif f.alias_changed? && !latest_formula.latest_version_installed?
// 133:                 "#{latest_formula.name} (#{latest_formula.pkg_version})"
// 134:               elsif f.head?
// 135:                 latest_head_version = f.latest_head_pkg_version(fetch_head: args.fetch_HEAD?)
// 136:                 if outdated_kegs.any? { |k| k.version.to_s == latest_head_version.to_s }
// 137:                   # There is a newer HEAD but the version number has not changed.
// 138:                   "latest HEAD"
// 139:                 else
// 140:                   latest_head_version.to_s
// 141:                 end
// 142:               else
// 143:                 latest_formula.pkg_version.to_s
// 144:               end
// 145:
// 146:               outdated_versions = outdated_kegs.group_by { |keg| Formulary.from_keg(keg).full_name }
// 147:                                                .sort_by { |full_name, _kegs| full_name }
// 148:                                                .map do |full_name, kegs|
// 149:                 "#{full_name} (#{kegs.map(&:version).join(", ")})"
// 150:               end.join(", ")
// 151:
// 152:               pinned_version = " [pinned at #{f.pinned_version}]" if f.pinned?
// 153:
// 154:               puts "#{outdated_versions} < #{current_version}#{pinned_version}"
// 155:             else
// 156:               puts f.full_installed_specified_name
// 157:             end
// 158:           else
// 159:             c = formula_or_cask
// 160:
// 161:             if minimum_version.present?
// 162:               if verbose?
// 163:                 pinned_version = " [pinned at #{c.pinned_version}]" if c.pinned?
// 164:
// 165:                 puts "#{c.token} (#{c.installed_version}) < #{minimum_version}#{pinned_version}"
// 166:               else
// 167:                 puts c.token
// 168:               end
// 169:             else
// 170:               puts c.outdated_info(upgrade_greedy_cask?(args.greedy?, formula_or_cask), verbose?,
// 171:                                    false, args.greedy_latest?, args.greedy_auto_updates?)
// 172:             end
// 173:           end
// 174:         end
// 175:       end
// 176:
// 177:       sig {
// 178:         params(
// 179:           formulae_or_casks: T::Array[T.any(Formula, Cask::Cask)],
// 180:         ).returns(T::Array[T::Hash[Symbol, T.untyped]])
// 181:       }
// 182:       def json_info(formulae_or_casks)
// 183:         formulae_or_casks.map do |formula_or_cask|
// 184:           if formula_or_cask.is_a?(Formula)
// 185:             f = formula_or_cask
// 186:
// 187:             outdated_versions = formula_outdated_kegs(f).map(&:version)
// 188:             current_version = if minimum_version.present?
// 189:               minimum_version
// 190:             elsif f.head? && outdated_versions.any? { |v| v.to_s == f.pkg_version.to_s }
// 191:               "HEAD"
// 192:             else
// 193:               f.pkg_version.to_s
// 194:             end
// 195:
// 196:             { name:               f.full_name,
// 197:               installed_versions: outdated_versions.map(&:to_s),
// 198:               current_version:,
// 199:               pinned:             f.pinned?,
// 200:               pinned_version:     f.pinned_version }
// 201:           else
// 202:             c = formula_or_cask
// 203:
// 204:             if minimum_version.present?
// 205:               { name:               c.token,
// 206:                 installed_versions: [T.must(c.installed_version)],
// 207:                 current_version:    T.must(minimum_version),
// 208:                 pinned:             c.pinned?,
// 209:                 pinned_version:     c.pinned_version }
// 210:             else
// 211:               T.cast(
// 212:                 c.outdated_info(upgrade_greedy_cask?(args.greedy?, formula_or_cask),
// 213:                                 verbose?, true, args.greedy_latest?, args.greedy_auto_updates?),
// 214:                 T::Hash[Symbol, T.untyped],
// 215:               )
// 216:             end
// 217:           end
// 218:         end
// 219:       end
// 220:
// 221:       sig { returns(T::Boolean) }
// 222:       def verbose?
// 223:         ($stdout.tty? || Context.current.verbose?) && !Context.current.quiet?
// 224:       end
// 225:
// 226:       sig { params(version: T.nilable(T.any(TrueClass, String))).returns(T.nilable(Symbol)) }
// 227:       def json_version(version)
// 228:         version_hash = {
// 229:           nil  => nil,
// 230:           true => :default,
// 231:           "v1" => :v1,
// 232:           "v2" => :v2,
// 233:         }
// 234:         version_hash.fetch(version) { raise UsageError, "invalid JSON version: #{version}" }
// 235:       end
// 236:
// 237:       sig { returns(T.nilable(String)) }
// 238:       def minimum_version = args.minimum_version || args.min_version
// 239:
// 240:       sig { returns(T::Array[Formula]) }
// 241:       def outdated_formulae
// 242:         T.cast(
// 243:           select_outdated(args.named.to_resolved_formulae.presence || Formula.installed).sort,
// 244:           T::Array[Formula],
// 245:         )
// 246:       end
// 247:
// 248:       sig { returns(T::Array[Cask::Cask]) }
// 249:       def outdated_casks
// 250:         outdated = if args.named.present?
// 251:           select_outdated(args.named.to_casks)
// 252:         else
// 253:           select_outdated(Cask::Caskroom.casks)
// 254:         end
// 255:
// 256:         T.cast(outdated, T::Array[Cask::Cask])
// 257:       end
// 258:
// 259:       sig { returns([T::Array[T.any(Formula, Cask::Cask)], T::Array[T.any(Formula, Cask::Cask)]]) }
// 260:       def outdated_formulae_casks
// 261:         formulae, casks = args.named.to_resolved_formulae_to_casks
// 262:
// 263:         if formulae.blank? && casks.blank?
// 264:           formulae = Formula.installed
// 265:           casks = Cask::Caskroom.casks
// 266:         end
// 267:
// 268:         [select_outdated(formulae).sort, select_outdated(casks)]
// 269:       end
// 270:
// 271:       sig { params(formula: Formula).returns(T::Array[Keg]) }
// 272:       def formula_outdated_kegs(formula)
// 273:         MinimumVersion.formula_outdated_kegs(formula, minimum_version, fetch_head: args.fetch_HEAD?)
// 274:       end
// 275:
// 276:       sig { params(greedy: T::Boolean, cask: Cask::Cask).returns(T::Boolean) }
// 277:       def upgrade_greedy_cask?(greedy, cask)
// 278:         return true if greedy
// 279:
// 280:         @greedy_list ||= T.let(
// 281:           begin
// 282:             upgrade_greedy_casks = Homebrew::EnvConfig.upgrade_greedy_casks.presence
// 283:             upgrade_greedy_casks&.split || []
// 284:           end, T.nilable(T::Array[String])
// 285:         )
// 286:
// 287:         @greedy_list.include?(cask.token)
// 288:       end
// 289:     end
// 290:   end
// 291: end
