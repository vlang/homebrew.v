module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/bump.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 107.
pub fn ruby_bump_l107_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `skip_ineligible_formulae!(formula_or_cask)` at line 193.
pub fn ruby_bump_l193_d2_skip_ineligible_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skip_ineligible_formulae!', ...args)
}

// Ruby method `retrieve_versions_by_arch(formula_or_cask:, repositories:, name:)` at line 225.
pub fn ruby_bump_l225_d3_retrieve_versions_by_arch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('retrieve_versions_by_arch', ...args)
}

// Ruby method `retrieve_and_display_info_and_open_pr(formula_or_cask, name, repositories, ambiguous_cask: false)` at line 413.
pub fn ruby_bump_l413_d4_retrieve_and_display_info_and_open_pr(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('retrieve_and_display_info_and_open_pr', ...args)
}

// Ruby method `version_args_for_bump(current_version:, new_version:, multiple_versions:, name:)` at line 588.
pub fn ruby_bump_l588_d5_version_args_for_bump(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('version_args_for_bump', ...args)
}

// Ruby method `compare_versions(current_version, new_version, formula_or_cask)` at line 630.
pub fn ruby_bump_l630_d6_compare_versions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('compare_versions', ...args)
}

// Ruby method `message?(value)` at line 698.
pub fn ruby_bump_l698_d7_message(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('message?', ...args)
}

// Ruby method `version_with_cooldown(version_info, current = nil)` at line 715.
pub fn ruby_bump_l715_d8_version_with_cooldown(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('version_with_cooldown', ...args)
}

// Ruby method `skip_repology?(formula_or_cask)` at line 824.
pub fn ruby_bump_l824_d9_skip_repology(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skip_repology?', ...args)
}

// Ruby method `handle_formulae_and_casks(formulae_and_casks)` at line 832.
pub fn ruby_bump_l832_d10_handle_formulae_and_casks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('handle_formulae_and_casks', ...args)
}

// Ruby method `livecheck_result(formula_or_cask, current)` at line 911.
pub fn ruby_bump_l911_d11_livecheck_result(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('livecheck_result', ...args)
}

// Ruby method `retrieve_pull_requests(formula_or_cask, name, version: nil)` at line 973.
pub fn ruby_bump_l973_d12_retrieve_pull_requests(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('retrieve_pull_requests', ...args)
}

// Ruby method `collect_resource_versions(formula, formula_latest_version)` at line 994.
pub fn ruby_bump_l994_d13_collect_resource_versions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('collect_resource_versions', ...args)
}

// Ruby method `synced_with(formula, new_version)` at line 1056.
pub fn ruby_bump_l1056_d14_synced_with(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('synced_with', ...args)
}

// Ruby method `autobumped_formulae_or_casks(tap, casks: false)` at line 1074.
pub fn ruby_bump_l1074_d15_autobumped_formulae_or_casks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('autobumped_formulae_or_casks', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "bump_version_parser"
// 6: require "livecheck/livecheck"
// 7: require "release_cooldown"
// 8: require "utils/curl"
// 9: require "utils/repology"
// 10:
// 11: module Homebrew
// 12:   module DevCmd
// 13:     class Bump < AbstractCommand
// 14:       DEFAULT_CURL_ARGS = [
// 15:         "--compressed",
// 16:         "--fail-with-body",
// 17:         "--location",
// 18:         "--max-redirs",
// 19:         "5",
// 20:         "--silent",
// 21:       ].freeze
// 22:       DEFAULT_CURL_OPTIONS = T.let({
// 23:         connect_timeout: 15,
// 24:         max_time:        55,
// 25:         timeout:         60,
// 26:         retries:         0,
// 27:       }.freeze, T::Hash[Symbol, T.untyped])
// 28:       MAX_CONSECUTIVE_GITHUB_API_ERRORS = 5
// 29:       MAX_GITHUB_API_RETRIES = 3
// 30:       PYPI_UNSTABLE_VERSION_REGEX = /^(?:\d+!)?\d+(?:\.\d+)*(?:a|b|rc)\d+|\.dev\d+$/i
// 31:
// 32:       LIVECHECK_MESSAGE_REGEX = /^(?:error:|skipped|unable to get(?: throttled)? versions)/i
// 33:       NEWER_THAN_UPSTREAM_MSG = " (newer than upstream)"
// 34:
// 35:       class ResourceVersionInfo < T::Struct
// 36:         const :name, String
// 37:         const :current_version, String
// 38:         const :latest_version, T.nilable(String)
// 39:         const :outdated, T::Boolean
// 40:         const :newer_than_upstream, T::Boolean
// 41:       end
// 42:
// 43:       class VersionBumpInfo < T::Struct
// 44:         const :type, Symbol
// 45:         const :deprecated, T::Hash[Symbol, T::Boolean], default: {}
// 46:         const :multiple_versions, T::Hash[Symbol, T::Boolean], default: {}
// 47:         const :version_name, String
// 48:         const :current_version, BumpVersionParser
// 49:         const :new_version, BumpVersionParser
// 50:         const :resource_versions, T::Array[ResourceVersionInfo], default: []
// 51:         const :repology_latest, T.any(String, Version)
// 52:         const :newer_than_upstream, T::Hash[Symbol, T::Boolean], default: {}
// 53:         const :cooldown_skipped_versions, T::Hash[Symbol, Version], default: {}
// 54:         const :duplicate_pull_requests, T.nilable(T.any(T::Array[String], String))
// 55:         const :maybe_duplicate_pull_requests, T.nilable(T.any(T::Array[String], String))
// 56:       end
// 57:
// 58:       cmd_args do
// 59:         description <<~EOS
// 60:           Displays out-of-date packages and the latest version available. If the
// 61:           returned current and livecheck versions differ or when querying specific
// 62:           packages, also displays whether a pull request has been opened with the URL.
// 63:         EOS
// 64:         switch "--full-name",
// 65:                description: "Print formulae/casks with fully-qualified names."
// 66:         switch "--no-pull-requests",
// 67:                description: "Do not retrieve pull requests from GitHub."
// 68:         switch "--auto",
// 69:                description: "Read the list of formulae/casks from the tap autobump list.",
// 70:                hidden:      true
// 71:         switch "--no-autobump",
// 72:                description: "Ignore formulae/casks in autobump list (official repositories only)."
// 73:         switch "--formula", "--formulae",
// 74:                description: "Check only formulae."
// 75:         switch "--cask", "--casks",
// 76:                description: "Check only casks."
// 77:         switch "--eval-all",
// 78:                description: "Evaluate all available formulae and casks.",
// 79:                env:         :eval_all,
// 80:                odeprecated: true
// 81:         switch "--repology",
// 82:                description: "Use Repology to check for outdated packages."
// 83:         flag   "--tap=",
// 84:                description: "Check formulae and casks within the given tap, specified as <user>`/`<repo>."
// 85:         switch "--installed",
// 86:                description: "Check formulae and casks that are currently installed."
// 87:         switch "--no-fork",
// 88:                description: "Don't try to fork the repository."
// 89:         switch "--open-pr",
// 90:                description: "Open a pull request for the new version if none have been opened yet."
// 91:         flag   "--start-with=",
// 92:                description: "Letter or word that the list of package results should alphabetically follow."
// 93:         switch "--bump-synced",
// 94:                description: "Bump additional formulae marked as synced with the given formulae."
// 95:
// 96:         conflicts "--formula", "--cask"
// 97:         conflicts "--tap", "--installed"
// 98:         conflicts "--tap", "--no-autobump"
// 99:         conflicts "--installed", "--eval-all"
// 100:         conflicts "--installed", "--auto"
// 101:         conflicts "--no-pull-requests", "--open-pr"
// 102:
// 103:         named_args [:formula, :cask], without_api: true
// 104:       end
// 105:
// 106:       sig { override.void }
// 107:       def run
// 108:         Homebrew.install_bundler_gems!(groups: ["livecheck"])
// 109:
// 110:         Homebrew.with_no_api_env do
// 111:           eval_all = args.eval_all?
// 112:           eval_all ||= args.no_named? && Homebrew::EnvConfig.tap_trust_configured?
// 113:
// 114:           excluded_autobump = []
// 115:           if args.no_autobump? && eval_all
// 116:             excluded_autobump.concat(autobumped_formulae_or_casks(CoreTap.instance)) if args.formula?
// 117:             excluded_autobump.concat(autobumped_formulae_or_casks(CoreCaskTap.instance, casks: true)) if args.cask?
// 118:           end
// 119:
// 120:           formulae_and_casks = if args.auto?
// 121:             raise UsageError, "`--formula` or `--cask` must be passed with `--auto`." if !args.formula? && !args.cask?
// 122:
// 123:             tap_arg = args.tap
// 124:             raise UsageError, "`--tap=` must be passed with `--auto`." if tap_arg.blank?
// 125:
// 126:             tap = Tap.fetch(tap_arg)
// 127:             autobump_list = tap.autobump
// 128:             what = args.cask? ? "casks" : "formulae"
// 129:             raise UsageError, "No autobumped #{what} found." if autobump_list.blank?
// 130:
// 131:             # Only run bump on the first formula in each synced group
// 132:             if args.bump_synced? && args.formula?
// 133:               synced_formulae = Set.new(tap.synced_versions_formulae.flat_map { it.drop(1) })
// 134:             end
// 135:
// 136:             autobump_list.filter_map do |name|
// 137:               qualified_name = "#{tap.name}/#{name}"
// 138:               next Cask::CaskLoader.load(qualified_name) if args.cask?
// 139:               next if synced_formulae&.include?(name)
// 140:
// 141:               Formulary.factory(qualified_name)
// 142:             end
// 143:           elsif args.tap
// 144:             tap = Tap.fetch(args.tap)
// 145:             raise UsageError, "`--tap` requires `--auto` for official taps." if tap.official?
// 146:
// 147:             formulae = args.cask? ? [] : tap.formula_files.map { |path| Formulary.factory(path) }
// 148:             casks = args.formula? ? [] : tap.cask_files.map { |path| Cask::CaskLoader.load(path) }
// 149:             formulae + casks
// 150:           elsif args.installed?
// 151:             formulae = args.cask? ? [] : Formula.installed
// 152:             casks = args.formula? ? [] : Cask::Caskroom.casks
// 153:             formulae + casks
// 154:           elsif args.named.present?
// 155:             T.cast(args.named.to_formulae_and_casks_with_taps, T::Array[T.any(Formula, Cask::Cask)])
// 156:           elsif eval_all
// 157:             formulae = args.cask? ? [] : Formula.all(eval_all:)
// 158:             casks = args.formula? ? [] : Cask::Cask.all(eval_all:)
// 159:             formulae + casks
// 160:           else
// 161:             raise UsageError,
// 162:                   "`brew bump` without named arguments needs `--installed`, `HOMEBREW_REQUIRE_TAP_TRUST=1` or " \
// 163:                   "`HOMEBREW_NO_REQUIRE_TAP_TRUST=1` set!"
// 164:           end
// 165:
// 166:           if (start_with = args.start_with)
// 167:             formulae_and_casks.select! do |formula_or_cask|
// 168:               Utils.name_or_token(formula_or_cask).start_with?(start_with)
// 169:             end
// 170:           end
// 171:
// 172:           formulae_and_casks = formulae_and_casks.sort_by do |formula_or_cask|
// 173:             Utils.name_or_token(formula_or_cask)
// 174:           end
// 175:
// 176:           formulae_and_casks -= excluded_autobump
// 177:
// 178:           if args.repology? && !Utils::Curl.curl_supports_tls13?
// 179:             begin
// 180:               Formula["curl"].ensure_installed!(reason: "Repology queries") unless HOMEBREW_BREWED_CURL_PATH.exist?
// 181:             rescue FormulaUnavailableError
// 182:               opoo "A newer `curl` is required for Repology queries."
// 183:             end
// 184:           end
// 185:
// 186:           handle_formulae_and_casks(formulae_and_casks)
// 187:         end
// 188:       end
// 189:
// 190:       sig {
// 191:         params(formula_or_cask: T.any(Formula, Cask::Cask)).returns(T::Boolean)
// 192:       }
// 193:       def skip_ineligible_formulae!(formula_or_cask)
// 194:         if formula_or_cask.is_a?(Formula)
// 195:           skip = formula_or_cask.disabled? || formula_or_cask.head_only?
// 196:           name = formula_or_cask.name
// 197:           text = "Formula is #{formula_or_cask.disabled? ? "disabled" : "HEAD-only"} so not accepting updates.\n"
// 198:         else
// 199:           skip = formula_or_cask.disabled? || formula_or_cask.version.latest?
// 200:           name = formula_or_cask.token
// 201:           text = if formula_or_cask.disabled?
// 202:             "Cask is disabled so not accepting updates.\n"
// 203:           else
// 204:             "Cask uses `version :latest` so `brew bump` cannot check it.\n"
// 205:           end
// 206:         end
// 207:         if (tap = formula_or_cask.tap) && !tap.allow_bump?(name)
// 208:           skip = true
// 209:           text = "#{text.split.first} is autobumped so will have bump PRs opened by BrewTestBot every ~3 hours.\n"
// 210:         end
// 211:         return false unless skip
// 212:
// 213:         ohai name
// 214:         puts text
// 215:         true
// 216:       end
// 217:
// 218:       sig {
// 219:         params(
// 220:           formula_or_cask: T.any(Formula, Cask::Cask),
// 221:           repositories:    T::Array[String],
// 222:           name:            String,
// 223:         ).returns(VersionBumpInfo)
// 224:       }
// 225:       def retrieve_versions_by_arch(formula_or_cask:, repositories:, name:)
// 226:         is_cask_with_blocks = formula_or_cask.is_a?(Cask::Cask) && formula_or_cask.on_system_blocks_exist?
// 227:         type, version_name = if formula_or_cask.is_a?(Formula)
// 228:           [:formula, "formula version:"]
// 229:         else
// 230:           [:cask, "cask version:   "]
// 231:         end
// 232:
// 233:         deprecated = {}
// 234:         current_versions = {}
// 235:         new_versions = {}
// 236:         cooldown_skipped_versions = {}
// 237:
// 238:         repology_latest = repositories.present? ? Repology.latest_version(repositories) : "not found"
// 239:         repology_latest_is_a_version = repology_latest.is_a?(Version)
// 240:
// 241:         # When blocks are absent, arch is not relevant. For consistency, we
// 242:         # simulate the arm architecture.
// 243:         arch_options = is_cask_with_blocks ? OnSystem::ARCH_OPTIONS : [:arm]
// 244:
// 245:         # If the cask restricts to specific architectures via
// 246:         # `depends_on arch:`, only simulate those architectures.
// 247:         if is_cask_with_blocks && formula_or_cask.is_a?(Cask::Cask)
// 248:           arch_deps = formula_or_cask.depends_on.arch
// 249:           if arch_deps.present?
// 250:             supported_archs = arch_deps.filter_map { |dep| dep[:type] } & arch_options
// 251:             arch_options = supported_archs if supported_archs.present?
// 252:           end
// 253:         end
// 254:
// 255:         arch_options.each do |arch|
// 256:           SimulateSystem.with(arch:) do
// 257:             version_key = is_cask_with_blocks ? arch : :general
// 258:
// 259:             # We reload the formula/cask here to ensure we're getting the
// 260:             # correct version for the current arch
// 261:             if formula_or_cask.is_a?(Formula)
// 262:               loaded_formula_or_cask = formula_or_cask
// 263:               stable = loaded_formula_or_cask.stable
// 264:               raise "unexpected nil stable" unless stable
// 265:
// 266:               current_version_value = stable.version
// 267:             else
// 268:               sourcefile_path = formula_or_cask.sourcefile_path
// 269:               raise "unexpected nil sourcefile_path" unless sourcefile_path
// 270:
// 271:               loaded_formula_or_cask = Cask::CaskLoader.load(sourcefile_path)
// 272:               current_version_value = Version.new(loaded_formula_or_cask.version)
// 273:             end
// 274:
// 275:             deprecated[version_key] = loaded_formula_or_cask.deprecated?
// 276:             formula_or_cask_has_livecheck = loaded_formula_or_cask.livecheck_defined?
// 277:
// 278:             livecheck_latest, cooldown_skipped = livecheck_result(loaded_formula_or_cask, current_version_value)
// 279:             cooldown_skipped_versions[version_key] = cooldown_skipped if cooldown_skipped
// 280:             livecheck_latest_is_a_version = livecheck_latest.is_a?(Version)
// 281:
// 282:             new_version_value = if (livecheck_latest_is_a_version &&
// 283:                                     Livecheck::LivecheckVersion.create(formula_or_cask, livecheck_latest) >=
// 284:                                     Livecheck::LivecheckVersion.create(formula_or_cask, current_version_value)) ||
// 285:                                    current_version_value == "latest" ||
// 286:                                    message?(livecheck_latest)
// 287:               livecheck_latest
// 288:             elsif repology_latest_is_a_version &&
// 289:                   !formula_or_cask_has_livecheck &&
// 290:                   repology_latest > current_version_value &&
// 291:                   current_version_value != "latest"
// 292:               repology_latest
// 293:             end.presence
// 294:
// 295:             # Fall back to the upstream version if there isn't a new version
// 296:             # value at this point, as this will allow us to surface an upstream
// 297:             # version that's lower than the current version.
// 298:             new_version_value ||= livecheck_latest if livecheck_latest_is_a_version
// 299:             new_version_value ||= repology_latest if repology_latest_is_a_version && !formula_or_cask_has_livecheck
// 300:
// 301:             # Store old and new versions
// 302:             current_versions[version_key] = current_version_value
// 303:             new_versions[version_key] = new_version_value
// 304:           end
// 305:         end
// 306:
// 307:         # Consolidate into a single general version when only one architecture
// 308:         # was simulated (e.g. `depends_on arch:` restricts to a single arch) or
// 309:         # when the arm and intel versions are identical, as happens with casks
// 310:         # where only the checksums differ.
// 311:         if is_cask_with_blocks && arch_options.length == 1
// 312:           single_arch = arch_options[0]
// 313:           current_versions = { general: current_versions[single_arch] }
// 314:           new_versions = { general: new_versions[single_arch] }
// 315:           cooldown_skipped_versions = { general: cooldown_skipped_versions[single_arch] }.compact
// 316:         else
// 317:           if current_versions[:arm].present? && current_versions[:arm] == current_versions[:intel]
// 318:             current_versions = { general: current_versions[:arm] }
// 319:           end
// 320:           if new_versions[:arm].present? && new_versions[:arm] == new_versions[:intel]
// 321:             new_versions = { general: new_versions[:arm] }
// 322:           end
// 323:           if cooldown_skipped_versions[:arm].present? &&
// 324:              cooldown_skipped_versions[:arm] == cooldown_skipped_versions[:intel]
// 325:             cooldown_skipped_versions = { general: cooldown_skipped_versions[:arm] }
// 326:           end
// 327:         end
// 328:
// 329:         current_version = BumpVersionParser.new(general: current_versions[:general],
// 330:                                                 arm:     current_versions[:arm],
// 331:                                                 intel:   current_versions[:intel])
// 332:
// 333:         begin
// 334:           new_version = BumpVersionParser.new(general: new_versions[:general],
// 335:                                               arm:     new_versions[:arm],
// 336:                                               intel:   new_versions[:intel])
// 337:         rescue
// 338:           # When livecheck fails, we fail gracefully. Otherwise VersionParser
// 339:           # will raise a usage error
// 340:           new_version = BumpVersionParser.new(general: "unable to get versions")
// 341:         end
// 342:
// 343:         compare_versions(current_version, new_version, formula_or_cask) =>
// 344:           { multiple_versions:, newer_than_upstream: }
// 345:         if !multiple_versions[:current] && deprecated[:general].nil?
// 346:           deprecated = { general: deprecated[:arm] || deprecated[:intel] || false }
// 347:         end
// 348:
// 349:         # Collect resource version info for formulae with resources that have explicit livecheck blocks
// 350:         resource_versions = if formula_or_cask.is_a?(Formula) && new_version.general.is_a?(Version)
// 351:           collect_resource_versions(formula_or_cask, new_version.general.to_s)
// 352:         else
// 353:           []
// 354:         end
// 355:
// 356:         if !args.no_pull_requests? &&
// 357:            !newer_than_upstream.all? { |_k, v| v == true }
// 358:           pull_request_version = nil
// 359:           if (new_version_arm = new_version.arm) &&
// 360:              !message?(new_version_arm) &&
// 361:              (new_version_arm != current_version.arm)
// 362:             # We use the ARM version for the pull request version even if there
// 363:             # are multiple arch versions to be consistent with the behavior of
// 364:             # bump-cask-pr.
// 365:             pull_request_version = new_version_arm.to_s
// 366:           elsif (new_version_intel = new_version.intel) &&
// 367:                 !message?(new_version_intel) &&
// 368:                 (new_version_intel != current_version.intel)
// 369:             pull_request_version = new_version_intel.to_s
// 370:           elsif (new_version_general = new_version.general) &&
// 371:                 !message?(new_version_general) &&
// 372:                 (new_version_general != current_version.general)
// 373:             pull_request_version = new_version_general.to_s
// 374:           end
// 375:
// 376:           if pull_request_version
// 377:             duplicate_pull_requests = retrieve_pull_requests(
// 378:               formula_or_cask,
// 379:               name,
// 380:               version: pull_request_version,
// 381:             )
// 382:
// 383:             maybe_duplicate_pull_requests = if duplicate_pull_requests.nil?
// 384:               retrieve_pull_requests(formula_or_cask, name)
// 385:             end
// 386:           end
// 387:         end
// 388:
// 389:         VersionBumpInfo.new(
// 390:           type:,
// 391:           deprecated:,
// 392:           multiple_versions:,
// 393:           version_name:,
// 394:           current_version:,
// 395:           new_version:,
// 396:           resource_versions:,
// 397:           repology_latest:,
// 398:           newer_than_upstream:,
// 399:           cooldown_skipped_versions:,
// 400:           duplicate_pull_requests:,
// 401:           maybe_duplicate_pull_requests:,
// 402:         )
// 403:       end
// 404:
// 405:       sig {
// 406:         params(
// 407:           formula_or_cask: T.any(Formula, Cask::Cask),
// 408:           name:            String,
// 409:           repositories:    T::Array[String],
// 410:           ambiguous_cask:  T::Boolean,
// 411:         ).void
// 412:       }
// 413:       def retrieve_and_display_info_and_open_pr(formula_or_cask, name, repositories, ambiguous_cask: false)
// 414:         version_info = retrieve_versions_by_arch(formula_or_cask:,
// 415:                                                  repositories:,
// 416:                                                  name:)
// 417:
// 418:         deprecated = version_info.deprecated
// 419:         multiple_versions = version_info.multiple_versions
// 420:         current_version = version_info.current_version
// 421:         new_version = version_info.new_version
// 422:         repology_latest = version_info.repology_latest
// 423:         newer_than_upstream = version_info.newer_than_upstream
// 424:         cooldown_skipped_version = version_info.cooldown_skipped_versions.values.max
// 425:         duplicate_pull_requests = version_info.duplicate_pull_requests
// 426:         maybe_duplicate_pull_requests = version_info.maybe_duplicate_pull_requests
// 427:
// 428:         versions_equal = (new_version == current_version)
// 429:         all_newer_than_upstream = newer_than_upstream.all? { |_k, v| v == true }
// 430:
// 431:         title_name = ambiguous_cask ? "#{name} (cask)" : name
// 432:         title = if (repology_latest == current_version.general || !repology_latest.is_a?(Version)) && versions_equal
// 433:           if cooldown_skipped_version
// 434:             "#{title_name} #{Tty.yellow}has a new version in release cooldown#{Tty.reset}"
// 435:           else
// 436:             "#{title_name} #{Tty.green}is up to date!#{Tty.reset}"
// 437:           end
// 438:         else
// 439:           title_name
// 440:         end
// 441:
// 442:         # Conditionally format output based on type of formula_or_cask
// 443:         current_versions = if multiple_versions[:current]
// 444:           "arm:   #{current_version.arm || current_version.general}" \
// 445:             "#{NEWER_THAN_UPSTREAM_MSG if newer_than_upstream[:arm]}" \
// 446:             "#{" (deprecated)" if deprecated[:arm]}" \
// 447:             "\n                          " \
// 448:             "intel: #{current_version.intel || current_version.general}" \
// 449:             "#{NEWER_THAN_UPSTREAM_MSG if newer_than_upstream[:intel]}" \
// 450:             "#{" (deprecated)" if deprecated[:intel]}"
// 451:         else
// 452:           "#{current_version.general}" \
// 453:             "#{NEWER_THAN_UPSTREAM_MSG if newer_than_upstream[:general]}" \
// 454:             "#{" (deprecated)" if deprecated[:general]}"
// 455:         end
// 456:
// 457:         new_versions = if multiple_versions[:new] && new_version.arm && new_version.intel
// 458:           "arm:   #{new_version.arm}
// 459:                           intel: #{new_version.intel}"
// 460:         else
// 461:           new_version.general
// 462:         end
// 463:
// 464:         throttled = formula_or_cask.livecheck.throttle || formula_or_cask.livecheck.throttle_days
// 465:         latest_versions = if cooldown_skipped_version
// 466:           cooldown_days = Utils.pluralize("day", Homebrew::RELEASE_COOLDOWN_DAYS, include_count: true)
// 467:           "#{cooldown_skipped_version} (released less than #{cooldown_days} ago)"
// 468:         else
// 469:           "#{new_versions}#{" (throttled)" if throttled}"
// 470:         end
// 471:         ohai title
// 472:         puts <<~EOS
// 473:           Current #{version_info.version_name}  #{current_versions}
// 474:           Latest livecheck version: #{latest_versions}
// 475:         EOS
// 476:         puts "Bump-ready version:       #{new_versions}" if cooldown_skipped_version
// 477:         puts <<~EOS unless skip_repology?(formula_or_cask)
// 478:           Latest Repology version:  #{repology_latest}
// 479:         EOS
// 480:         if formula_or_cask.is_a?(Formula) && formula_or_cask.synced_with_other_formulae?
// 481:           outdated_synced_formulae = synced_with(formula_or_cask, new_version.general)
// 482:           if !args.bump_synced? && outdated_synced_formulae.present?
// 483:             puts <<~EOS
// 484:               Version syncing:          #{title_name} version should be kept in sync with
// 485:                                         #{outdated_synced_formulae.join(", ")}.
// 486:             EOS
// 487:           end
// 488:         end
// 489:
// 490:         # Display resource version info for formulae
// 491:         resource_versions = version_info.resource_versions
// 492:         puts "Resources with livecheck:" unless resource_versions.empty?
// 493:         resource_versions.each do |rv|
// 494:           status = if rv.latest_version.nil?
// 495:             "#{Tty.red}unable to get versions#{Tty.reset}"
// 496:           elsif rv.newer_than_upstream
// 497:             "#{Tty.red}#{rv.current_version}#{Tty.reset} -> #{rv.latest_version}#{NEWER_THAN_UPSTREAM_MSG}"
// 498:           elsif rv.outdated
// 499:             "#{rv.current_version} -> #{Tty.green}#{rv.latest_version}#{Tty.reset}"
// 500:           else
// 501:             "#{rv.current_version} -> #{rv.latest_version}"
// 502:           end
// 503:           puts "  #{rv.name}: #{status}"
// 504:         end
// 505:
// 506:         if !args.no_pull_requests? &&
// 507:            !message?(new_version.general) &&
// 508:            !versions_equal &&
// 509:            !all_newer_than_upstream
// 510:           if duplicate_pull_requests
// 511:             duplicate_pull_requests_text = duplicate_pull_requests
// 512:           elsif maybe_duplicate_pull_requests
// 513:             duplicate_pull_requests_text = "none"
// 514:             maybe_duplicate_pull_requests_text = maybe_duplicate_pull_requests
// 515:           else
// 516:             duplicate_pull_requests_text = "none"
// 517:             maybe_duplicate_pull_requests_text = "none"
// 518:           end
// 519:
// 520:           puts "Duplicate pull requests:  #{duplicate_pull_requests_text}"
// 521:           if maybe_duplicate_pull_requests_text
// 522:             puts "Maybe duplicate pull requests: #{maybe_duplicate_pull_requests_text}"
// 523:           end
// 524:         end
// 525:
// 526:         if !args.open_pr? ||
// 527:            message?(new_version.general) ||
// 528:            all_newer_than_upstream
// 529:           return
// 530:         end
// 531:
// 532:         if GitHub.too_many_open_prs?(formula_or_cask.tap)
// 533:           odie "You have too many PRs open: close or merge some first!"
// 534:         end
// 535:
// 536:         if repology_latest.is_a?(Version) &&
// 537:            repology_latest > current_version.general &&
// 538:            repology_latest > new_version.general &&
// 539:            formula_or_cask.livecheck_defined?
// 540:           puts "#{title_name} was not bumped to the Repology version because it has a `livecheck` block."
// 541:         end
// 542:         if new_version.blank? || versions_equal ||
// 543:            (!new_version.general.is_a?(Version) && !multiple_versions[:new])
// 544:           return
// 545:         end
// 546:
// 547:         return if duplicate_pull_requests.present?
// 548:
// 549:         version_args = version_args_for_bump(current_version:, new_version:, multiple_versions:, name:)
// 550:         return if version_args.blank?
// 551:
// 552:         bump_pr_args = [
// 553:           "bump-#{version_info.type}-pr",
// 554:           name,
// 555:           *version_args,
// 556:           "--no-browse",
// 557:           "--message=Created by `brew bump`",
// 558:         ]
// 559:
// 560:         bump_pr_args << "--no-fork" if args.no_fork?
// 561:
// 562:         if args.bump_synced? && outdated_synced_formulae.present?
// 563:           bump_pr_args << "--bump-synced=#{outdated_synced_formulae.join(",")}"
// 564:         end
// 565:
// 566:         # Pass all livecheck-checked resources to bump-formula-pr, including
// 567:         # up-to-date and failed ones, so it can track what was checked
// 568:         if version_info.type == :formula && !resource_versions.empty?
// 569:           require "json"
// 570:           resource_data = resource_versions.map do |rv|
// 571:             { name: rv.name, current_version: rv.current_version, latest_version: rv.latest_version }
// 572:           end
// 573:           bump_pr_args << "--resource-versions=#{resource_data.to_json}"
// 574:         end
// 575:
// 576:         result = system HOMEBREW_BREW_FILE, *bump_pr_args
// 577:         Homebrew.failed = true unless result
// 578:       end
// 579:
// 580:       sig {
// 581:         params(
// 582:           current_version:   BumpVersionParser,
// 583:           new_version:       BumpVersionParser,
// 584:           multiple_versions: T::Hash[Symbol, T::Boolean],
// 585:           name:              String,
// 586:         ).returns(T::Array[String])
// 587:       }
// 588:       def version_args_for_bump(current_version:, new_version:, multiple_versions:, name:)
// 589:         version_args = T.let([], T::Array[String])
// 590:
// 591:         if multiple_versions[:new]
// 592:           (BumpVersionParser::VERSION_SYMBOLS - [:general]).each do |arch|
// 593:             new_arch_version = new_version.public_send(arch)
// 594:             next if new_arch_version.blank? || message?(new_arch_version)
// 595:
// 596:             current_arch_version = if multiple_versions[:current]
// 597:               current_version.public_send(arch)
// 598:             else
// 599:               current_version.general
// 600:             end
// 601:             next if current_arch_version.blank? || new_arch_version <= current_arch_version
// 602:
// 603:             version_args << "--version-#{arch}=#{new_arch_version}"
// 604:           end
// 605:         elsif multiple_versions[:current]
// 606:           if (new_version_general = new_version.general) && !message?(new_version_general)
// 607:             (BumpVersionParser::VERSION_SYMBOLS - [:general]).each do |arch|
// 608:               current_arch_version = current_version.public_send(arch)
// 609:               next if current_arch_version.blank? || new_version_general <= current_arch_version
// 610:
// 611:               version_args << "--version-#{arch}=#{new_version_general}"
// 612:             end
// 613:           end
// 614:
// 615:           opoo "`#{name}` needs to be manually updated using one version" if version_args.blank?
// 616:         elsif new_version.general
// 617:           version_args << "--version=#{new_version.general}"
// 618:         end
// 619:
// 620:         version_args
// 621:       end
// 622:
// 623:       sig {
// 624:         params(
// 625:           current_version: BumpVersionParser,
// 626:           new_version:     BumpVersionParser,
// 627:           formula_or_cask: T.any(Formula, Cask::Cask),
// 628:         ).returns(T::Hash[Symbol, T::Hash[Symbol, T::Boolean]])
// 629:       }
// 630:       def compare_versions(current_version, new_version, formula_or_cask)
// 631:         current_versions = {}
// 632:         new_versions = {}
// 633:         BumpVersionParser::VERSION_SYMBOLS.each do |type|
// 634:           current_version_value = current_version.public_send(type)
// 635:           if current_version_value
// 636:             current_versions[type] = Livecheck::LivecheckVersion.create(formula_or_cask, current_version_value)
// 637:           end
// 638:
// 639:           new_version_value = new_version.public_send(type)
// 640:           if message?(new_version_value)
// 641:             # Store a string, so we can easily tell when a value is a message
// 642:             # rather than a version
// 643:             new_versions[type] = new_version_value.to_s
// 644:           elsif new_version_value
// 645:             new_versions[type] = Livecheck::LivecheckVersion.create(formula_or_cask, new_version_value)
// 646:           end
// 647:         end
// 648:
// 649:         multiple_versions = {
// 650:           current: current_versions.length > 1,
// 651:           new:     new_versions.length > 1,
// 652:         }
// 653:
// 654:         current_version_types = current_versions.keys
// 655:         new_version_types = new_versions.keys
// 656:         comparison_pairs = {}
// 657:
// 658:         # Compare the same version types when shared by current/new versions
// 659:         (current_version_types & new_version_types).each do |type|
// 660:           comparison_pairs[type] = [current_versions[type], new_versions[type]]
// 661:         end
// 662:
// 663:         # Compare current versions to `new_version.general` when the current
// 664:         # version differs by arch but the new version does not
// 665:         if multiple_versions[:current] && new_versions.key?(:general)
// 666:           (current_version_types - new_version_types).each do |type|
// 667:             comparison_pairs[type] ||= [current_versions[type], new_versions[:general]]
// 668:           end
// 669:         end
// 670:
// 671:         # Compare `current_version.general` to the highest new version when the
// 672:         # current version does not differ by arch but the new version does
// 673:         if !comparison_pairs.key?(:general) &&
// 674:            current_versions.key?(:general) &&
// 675:            multiple_versions[:new]
// 676:           highest_new_version = (new_version_types - current_version_types).filter_map do |type|
// 677:             version = new_versions[type]
// 678:             next unless version.is_a?(Livecheck::LivecheckVersion)
// 679:
// 680:             version
// 681:           end.max
// 682:           comparison_pairs[:general] = [current_versions[:general], highest_new_version]
// 683:         end
// 684:
// 685:         newer_than_upstream = {}
// 686:         comparison_pairs.each do |version_type, (current_value, new_value)|
// 687:           newer_than_upstream[version_type] = if new_value.is_a?(Livecheck::LivecheckVersion)
// 688:             (current_value > new_value)
// 689:           else
// 690:             false
// 691:           end
// 692:         end
// 693:
// 694:         { multiple_versions:, newer_than_upstream: }
// 695:       end
// 696:
// 697:       sig { params(value: T.nilable(T.any(Version, Cask::DSL::Version, String))).returns(T::Boolean) }
// 698:       def message?(value)
// 699:         return false if !value.is_a?(Cask::DSL::Version) && !value.is_a?(String)
// 700:
// 701:         value.match?(LIVECHECK_MESSAGE_REGEX)
// 702:       end
// 703:
// 704:       # Identifies the highest upstream version that has been released before
// 705:       # the cooldown interval.
// 706:       #
// 707:       # @param version_info the return hash from `Livecheck.latest_version`
// 708:       # @param current the current version
// 709:       sig {
// 710:         params(
// 711:           version_info: T::Hash[Symbol, T.untyped],
// 712:           current:      T.nilable(T.any(Version, Cask::DSL::Version)),
// 713:         ).returns(T.nilable(Version))
// 714:       }
// 715:       def version_with_cooldown(version_info, current = nil)
// 716:         return unless current
// 717:
// 718:         latest = Version.new(version_info[:latest]) if version_info[:latest]
// 719:         return unless latest
// 720:         return if latest <= current
// 721:
// 722:         strategy = T.cast(version_info.dig(:meta, :strategy), T.nilable(String))
// 723:         case strategy
// 724:         when "Npm"
// 725:           url = version_info.dig(:meta, :url, :strategy)&.delete_suffix("/latest")
// 726:           return unless url
// 727:
// 728:           stdout, _stderr, status = Utils::Curl.curl_output(*DEFAULT_CURL_ARGS, url, **DEFAULT_CURL_OPTIONS).to_a
// 729:           return unless status.success?
// 730:           return if (content = stdout.scrub).blank?
// 731:
// 732:           json = Homebrew::Livecheck::Strategy::Json.parse_json(content)
// 733:           release_dates = json["time"]&.except("created", "modified")
// 734:                                       &.transform_values { |v| DateTime.parse(v) }
// 735:           return unless release_dates.present?
// 736:
// 737:           current_str = current.to_s
// 738:           current_is_prerelease = current_str.include?("-")
// 739:           cooldown_interval = (DateTime.now - Homebrew::RELEASE_COOLDOWN_DAYS)
// 740:           release_dates.sort_by { |_, date| date }.reverse_each do |version_str, date|
// 741:             version = Version.new(version_str)
// 742:             return version if version_str == current_str
// 743:             next if (version > latest) || (version < current)
// 744:
// 745:             # TODO: Properly handle prerelease version comparison
// 746:             next if !current_is_prerelease && version_str.include?("-")
// 747:
// 748:             return version if date < cooldown_interval
// 749:           end
// 750:         when "Pypi"
// 751:           url = version_info.dig(:meta, :url, :strategy)
// 752:           original_url = version_info.dig(:meta, :url, :original)
// 753:           return if !url || !original_url
// 754:
// 755:           suffix = Homebrew::Livecheck::Strategy::Pypi::URL_MATCH_REGEX.match(original_url)&.[](:suffix)
// 756:           return unless suffix
// 757:
// 758:           content = version_info[:content]
// 759:           unless content
// 760:             stdout, _stderr, status = Utils::Curl.curl_output(*DEFAULT_CURL_ARGS, url, **DEFAULT_CURL_OPTIONS).to_a
// 761:             return unless status.success?
// 762:
// 763:             content = stdout.scrub
// 764:           end
// 765:           return if content.blank?
// 766:
// 767:           json = Homebrew::Livecheck::Strategy::Json.parse_json(content)
// 768:           return unless (releases = json["releases"])
// 769:
// 770:           current_str = current.to_s
// 771:           current_is_prerelease = current_str.match?(PYPI_UNSTABLE_VERSION_REGEX)
// 772:           cooldown_interval = (DateTime.now - Homebrew::RELEASE_COOLDOWN_DAYS)
// 773:           releases.sort_by { |k, _| Version.new(k) }.reverse_each do |version_str, assets|
// 774:             version = Version.new(version_str)
// 775:             return version if version_str == current_str
// 776:             next if (version > latest) || (version < current)
// 777:             next if !current_is_prerelease && version_str.match?(PYPI_UNSTABLE_VERSION_REGEX)
// 778:
// 779:             assets.each do |asset|
// 780:               next if asset["yanked"]
// 781:               next unless asset["url"]&.end_with?(suffix)
// 782:               next unless (date_str = asset["upload_time_iso_8601"])
// 783:
// 784:               date = DateTime.parse(date_str)
// 785:               return version if date < cooldown_interval
// 786:             end
// 787:           end
// 788:         when "RubyGems"
// 789:           url = version_info.dig(:meta, :url, :strategy)&.sub(%r{/latest\.json\z}, ".json")
// 790:           original_url = version_info.dig(:meta, :url, :original)
// 791:           return if !url || !original_url
// 792:
// 793:           match = Homebrew::Livecheck::Strategy::RubyGems::URL_MATCH_REGEX.match(original_url)
// 794:           return unless match
// 795:
// 796:           stdout, _stderr, status = Utils::Curl.curl_output(*DEFAULT_CURL_ARGS, url, **DEFAULT_CURL_OPTIONS).to_a
// 797:           return unless status.success?
// 798:           return if (content = stdout.scrub).blank?
// 799:
// 800:           json = Homebrew::Livecheck::Strategy::Json.parse_json(content)
// 801:           return unless json.is_a?(Array)
// 802:
// 803:           current_str = current.to_s
// 804:           cooldown_interval = (DateTime.now - Homebrew::RELEASE_COOLDOWN_DAYS)
// 805:           json.sort_by { |release| Version.new(release["number"]) }.reverse_each do |release|
// 806:             next if release["platform"] != (match[:platform] || "ruby")
// 807:
// 808:             version_str = release["number"]
// 809:             version = Version.new(version_str)
// 810:             return version if version_str == current_str
// 811:             next if (version > latest) || (version < current)
// 812:             next if release["prerelease"] &&
// 813:                     !(Gem::Version.correct?(current_str) && Gem::Version.new(current_str).prerelease?)
// 814:             next unless (date_str = release["created_at"])
// 815:
// 816:             return version if DateTime.parse(date_str) < cooldown_interval
// 817:           end
// 818:         end
// 819:       end
// 820:
// 821:       private
// 822:
// 823:       sig { params(formula_or_cask: T.any(Formula, Cask::Cask)).returns(T::Boolean) }
// 824:       def skip_repology?(formula_or_cask)
// 825:         return true unless args.repology?
// 826:
// 827:         (ENV["CI"].present? && args.open_pr? && formula_or_cask.livecheck_defined?) ||
// 828:           (formula_or_cask.is_a?(Formula) && formula_or_cask.versioned_formula?)
// 829:       end
// 830:
// 831:       sig { params(formulae_and_casks: T::Array[T.any(Formula, Cask::Cask)]).void }
// 832:       def handle_formulae_and_casks(formulae_and_casks)
// 833:         Livecheck.load_other_tap_strategies(formulae_and_casks)
// 834:
// 835:         ambiguous_casks = []
// 836:         if !args.formula? && !args.cask?
// 837:           ambiguous_casks = formulae_and_casks
// 838:                             .group_by { |item| Livecheck.package_or_resource_name(item, full_name: true) }
// 839:                             .values
// 840:                             .select { |items| items.length > 1 }
// 841:                             .flatten
// 842:                             .grep(Cask::Cask)
// 843:         end
// 844:
// 845:         ambiguous_names = []
// 846:         unless args.full_name?
// 847:           ambiguous_names = (formulae_and_casks - ambiguous_casks)
// 848:                             .group_by { |item| Livecheck.package_or_resource_name(item) }
// 849:                             .values
// 850:                             .select { |items| items.length > 1 }
// 851:                             .flatten
// 852:         end
// 853:
// 854:         consecutive_github_api_errors = 0
// 855:         formulae_and_casks.each_with_index do |formula_or_cask, i|
// 856:           puts if i.positive?
// 857:           next if skip_ineligible_formulae!(formula_or_cask)
// 858:
// 859:           use_full_name = args.full_name? || ambiguous_names.include?(formula_or_cask)
// 860:           name = Livecheck.package_or_resource_name(formula_or_cask, full_name: use_full_name)
// 861:           repository = if formula_or_cask.is_a?(Formula)
// 862:             Repology::HOMEBREW_CORE
// 863:           else
// 864:             Repology::HOMEBREW_CASK
// 865:           end
// 866:
// 867:           package_data = Repology.single_package_query(name, repository:) unless skip_repology?(formula_or_cask)
// 868:
// 869:           github_api_retries = 0
// 870:           begin
// 871:             retrieve_and_display_info_and_open_pr(
// 872:               formula_or_cask,
// 873:               name,
// 874:               package_data&.values&.first || [],
// 875:               ambiguous_cask: ambiguous_casks.include?(formula_or_cask),
// 876:             )
// 877:             consecutive_github_api_errors = 0
// 878:           rescue GitHub::API::RateLimitExceededError => e
// 879:             GitHub::API.sleep_for_rate_limit(e)
// 880:             retry
// 881:           rescue GitHub::API::AuthenticationFailedError
// 882:             # Retrying this for the remaining packages cannot succeed, so stop now.
// 883:             raise
// 884:           rescue GitHub::API::Error => e
// 885:             github_api_retries += 1
// 886:             if github_api_retries <= MAX_GITHUB_API_RETRIES
// 887:               Utils.exponential_backoff_sleep(github_api_retries) do |wait|
// 888:                 onoe "#{name}: retrying in #{wait}s after a GitHub API error: #{e}"
// 889:               end
// 890:               retry
// 891:             end
// 892:
// 893:             consecutive_github_api_errors += 1
// 894:             if consecutive_github_api_errors >= MAX_CONSECUTIVE_GITHUB_API_ERRORS
// 895:               odie "Aborting after #{consecutive_github_api_errors} consecutive GitHub API errors: #{e}"
// 896:             end
// 897:
// 898:             onoe "#{name}: skipped after a GitHub API error: #{e}"
// 899:           end
// 900:         end
// 901:       end
// 902:
// 903:       # Returns the new version (or a message string) and the newest upstream
// 904:       # version skipped due to the release cooldown, if any.
// 905:       sig {
// 906:         params(
// 907:           formula_or_cask: T.any(Formula, Cask::Cask),
// 908:           current:         T.nilable(T.any(Version, Cask::DSL::Version)),
// 909:         ).returns([T.any(Version, String), T.nilable(Version)])
// 910:       }
// 911:       def livecheck_result(formula_or_cask, current)
// 912:         name = Livecheck.package_or_resource_name(formula_or_cask)
// 913:
// 914:         referenced_formula_or_cask, = Livecheck.resolve_livecheck_reference(
// 915:           formula_or_cask,
// 916:           full_name: false,
// 917:           debug:     false,
// 918:         )
// 919:
// 920:         # Check skip conditions for a referenced formula/cask
// 921:         if referenced_formula_or_cask
// 922:           skip_info = Livecheck::SkipConditions.referenced_skip_information(
// 923:             referenced_formula_or_cask,
// 924:             name,
// 925:             full_name: false,
// 926:             verbose:   false,
// 927:           )
// 928:         end
// 929:
// 930:         skip_info ||= Livecheck::SkipConditions.skip_information(
// 931:           formula_or_cask,
// 932:           full_name: false,
// 933:           verbose:   false,
// 934:         )
// 935:
// 936:         if skip_info.present?
// 937:           skip_status = skip_info[:status]
// 938:           skip_messages = skip_info[:messages]
// 939:           skip_message = skip_messages.join("; ") if skip_messages.present?
// 940:           return "error: #{skip_message}", nil if skip_status == "error" && skip_message
// 941:
// 942:           return "skipped - #{skip_message || skip_status}", nil
// 943:         end
// 944:
// 945:         version_info = Livecheck.latest_version(
// 946:           formula_or_cask,
// 947:           referenced_formula_or_cask:,
// 948:           json: true, full_name: false, verbose: true, debug: false
// 949:         )
// 950:         return "unable to get versions", nil if version_info.blank?
// 951:
// 952:         if !version_info.key?(:latest_throttled)
// 953:           latest = Version.new(version_info[:latest])
// 954:           cooldown_version = version_with_cooldown(version_info, current)
// 955:           cooldown_skipped = (latest if cooldown_version && cooldown_version < latest)
// 956:           [cooldown_version || latest, cooldown_skipped]
// 957:         elsif version_info[:latest_throttled].nil?
// 958:           ["unable to get throttled versions", nil]
// 959:         else
// 960:           [Version.new(version_info[:latest_throttled]), nil]
// 961:         end
// 962:       rescue => e
// 963:         ["error: #{e}", nil]
// 964:       end
// 965:
// 966:       sig {
// 967:         params(
// 968:           formula_or_cask: T.any(Formula, Cask::Cask),
// 969:           name:            String,
// 970:           version:         T.nilable(String),
// 971:         ).returns T.nilable(T.any(T::Array[String], String))
// 972:       }
// 973:       def retrieve_pull_requests(formula_or_cask, name, version: nil)
// 974:         tap_remote_repo = formula_or_cask.tap&.remote_repository || formula_or_cask.tap&.full_name
// 975:         odie "unexpected nil tap remote repository" if tap_remote_repo.nil?
// 976:
// 977:         pull_requests = begin
// 978:           GitHub.fetch_pull_requests(name, tap_remote_repo, version:)
// 979:         rescue GitHub::API::ValidationFailedError => e
// 980:           odebug "Error fetching pull requests for #{formula_or_cask} #{name}: #{e}"
// 981:           nil
// 982:         end
// 983:         return if pull_requests.blank?
// 984:
// 985:         pull_requests.map { |pr| "#{pr["title"]} (#{Formatter.url(pr["html_url"])})" }.join(", ")
// 986:       end
// 987:
// 988:       sig {
// 989:         params(
// 990:           formula:                Formula,
// 991:           formula_latest_version: String,
// 992:         ).returns(T::Array[ResourceVersionInfo])
// 993:       }
// 994:       def collect_resource_versions(formula, formula_latest_version)
// 995:         resource_versions = []
// 996:
// 997:         formula.resources.each do |resource|
// 998:           next unless resource.livecheck_defined?
// 999:           next if resource.livecheck.skip?
// 1000:
// 1001:           # Resources that reference :parent track the formula version directly
// 1002:           if resource.livecheck.formula == :parent
// 1003:             current = resource.version.to_s
// 1004:             resource_versions << ResourceVersionInfo.new(
// 1005:               name:                resource.name,
// 1006:               current_version:     current,
// 1007:               latest_version:      formula_latest_version,
// 1008:               outdated:            Version.new(current) < Version.new(formula_latest_version),
// 1009:               newer_than_upstream: Version.new(current) > Version.new(formula_latest_version),
// 1010:             )
// 1011:             next
// 1012:           end
// 1013:
// 1014:           resource_info = Livecheck.resource_version(
// 1015:             resource,
// 1016:             formula_latest_version,
// 1017:             json:      true,
// 1018:             full_name: false,
// 1019:             debug:     false,
// 1020:             quiet:     true,
// 1021:             verbose:   false,
// 1022:           )
// 1023:
// 1024:           if resource_info.empty? || resource_info[:status] == "error"
// 1025:             resource_versions << ResourceVersionInfo.new(
// 1026:               name:                resource.name,
// 1027:               current_version:     resource.version.to_s,
// 1028:               latest_version:      nil,
// 1029:               outdated:            false,
// 1030:               newer_than_upstream: false,
// 1031:             )
// 1032:             next
// 1033:           end
// 1034:
// 1035:           version_info = resource_info[:version]
// 1036:           next if version_info.blank?
// 1037:
// 1038:           resource_versions << ResourceVersionInfo.new(
// 1039:             name:                resource.name,
// 1040:             current_version:     version_info[:current],
// 1041:             latest_version:      version_info[:latest],
// 1042:             outdated:            version_info[:outdated] == true,
// 1043:             newer_than_upstream: version_info[:newer_than_upstream] == true,
// 1044:           )
// 1045:         end
// 1046:
// 1047:         resource_versions
// 1048:       end
// 1049:
// 1050:       sig {
// 1051:         params(
// 1052:           formula:     Formula,
// 1053:           new_version: T.nilable(T.any(Version, Cask::DSL::Version)),
// 1054:         ).returns(T::Array[String])
// 1055:       }
// 1056:       def synced_with(formula, new_version)
// 1057:         synced_with = []
// 1058:
// 1059:         formula.tap&.synced_versions_formulae&.each do |synced_formulae|
// 1060:           next unless synced_formulae.include?(formula.name)
// 1061:
// 1062:           synced_formulae.each do |synced_formula|
// 1063:             synced_formula = Formulary.factory(synced_formula)
// 1064:             next if synced_formula == formula.name
// 1065:
// 1066:             synced_with << synced_formula.name if synced_formula.version != new_version
// 1067:           end
// 1068:         end
// 1069:
// 1070:         synced_with
// 1071:       end
// 1072:
// 1073:       sig { params(tap: Tap, casks: T::Boolean).returns(T::Array[T.any(Formula, Cask::Cask)]) }
// 1074:       def autobumped_formulae_or_casks(tap, casks: false)
// 1075:         autobump_list = tap.autobump
// 1076:         autobump_list.map do |name|
// 1077:           qualified_name = "#{tap.name}/#{name}"
// 1078:           if casks
// 1079:             Cask::CaskLoader.load(qualified_name)
// 1080:           else
// 1081:             Formulary.factory(qualified_name)
// 1082:           end
// 1083:         end
// 1084:       end
// 1085:     end
// 1086:   end
// 1087: end
