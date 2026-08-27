module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/bump-cask-pr.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 62.
pub fn ruby_bump_cask_pr_l62_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `generate_system_options(cask, new_version)` at line 220.
pub fn ruby_bump_cask_pr_l220_d2_generate_system_options(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('generate_system_options', ...args)
}

// Ruby method `replace_version_and_checksum(cask, new_hash, new_version, contents)` at line 284.
pub fn ruby_bump_cask_pr_l284_d3_replace_version_and_checksum(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('replace_version_and_checksum', ...args)
}

// Ruby method `replace_cask_stanza_value(contents, name, old_value, new_value, within: nil)` at line 384.
pub fn ruby_bump_cask_pr_l384_d4_replace_cask_stanza_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('replace_cask_stanza_value', ...args)
}

// Ruby method `check_throttle(cask, new_version:)` at line 402.
pub fn ruby_bump_cask_pr_l402_d5_check_throttle(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_throttle', ...args)
}

// Ruby method `shortened_version(version, cask:)` at line 424.
pub fn ruby_bump_cask_pr_l424_d6_shortened_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('shortened_version', ...args)
}

// Ruby method `split_root_version_and_checksum(new_version, contents)` at line 438.
pub fn ruby_bump_cask_pr_l438_d7_split_root_version_and_checksum(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('split_root_version_and_checksum', ...args)
}

// Ruby method `arch_specific_version_bump?(new_version)` at line 463.
pub fn ruby_bump_cask_pr_l463_d8_arch_specific_version_bump(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('arch_specific_version_bump?', ...args)
}

// Ruby method `default_cask_os` at line 468.
pub fn ruby_bump_cask_pr_l468_d9_default_cask_os(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('default_cask_os', ...args)
}

// Ruby method `unsupported_nested_arch_stanza?(contents, name, arch)` at line 476.
pub fn ruby_bump_cask_pr_l476_d10_unsupported_nested_arch_stanza(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('unsupported_nested_arch_stanza?', ...args)
}

// Ruby method `cask_stanza_scope(contents, name, arch)` at line 484.
pub fn ruby_bump_cask_pr_l484_d11_cask_stanza_scope(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_stanza_scope', ...args)
}

// Ruby method `check_pull_requests(cask, new_version:)` at line 492.
pub fn ruby_bump_cask_pr_l492_d12_check_pull_requests(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_pull_requests', ...args)
}

// Ruby method `run_cask_audit(cask, old_contents, audit_exceptions = [])` at line 520.
pub fn ruby_bump_cask_pr_l520_d13_run_cask_audit(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run_cask_audit', ...args)
}

// Ruby method `run_cask_style(cask, old_contents)` at line 547.
pub fn ruby_bump_cask_pr_l547_d14_run_cask_style(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run_cask_style', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "bump"
// 6: require "bump_version_parser"
// 7: require "cask"
// 8: require "cask/download"
// 9: require "livecheck/livecheck"
// 10: require "livecheck/livecheck_version"
// 11: require "utils/tar"
// 12:
// 13: module Homebrew
// 14:   module DevCmd
// 15:     class BumpCaskPr < AbstractCommand
// 16:       cmd_args do
// 17:         description <<~EOS
// 18:           Create a pull request to update <cask> with a new version.
// 19:
// 20:           A best effort to determine the <SHA-256> will be made if the value is not
// 21:           supplied by the user.
// 22:         EOS
// 23:         switch "-n", "--dry-run",
// 24:                description: "Print what would be done rather than doing it."
// 25:         switch "--write-only",
// 26:                description: "Make the expected file modifications without taking any Git actions."
// 27:         switch "--commit",
// 28:                depends_on:  "--write-only",
// 29:                description: "When passed with `--write-only`, generate a new commit after writing changes " \
// 30:                             "to the cask file."
// 31:         switch "--no-audit",
// 32:                description: "Don't run `brew audit` before opening the PR."
// 33:         switch "--no-style",
// 34:                description: "Don't run `brew style --fix` before opening the PR."
// 35:         switch "--no-browse",
// 36:                description: "Print the pull request URL instead of opening in a browser."
// 37:         switch "--no-fork",
// 38:                description: "Don't try to fork the repository."
// 39:         flag   "--version=",
// 40:                description: "Specify the new <version> for the cask."
// 41:         flag   "--version-arm=",
// 42:                description: "Specify the new cask <version> for the ARM architecture."
// 43:         flag   "--version-intel=",
// 44:                description: "Specify the new cask <version> for the Intel architecture."
// 45:         flag   "--message=",
// 46:                description: "Prepend <message> to the default pull request message."
// 47:         flag   "--url=",
// 48:                description: "Specify the <URL> for the new download."
// 49:         flag   "--sha256=",
// 50:                description: "Specify the <SHA-256> checksum of the new download."
// 51:         flag   "--fork-org=",
// 52:                description: "Use the specified GitHub organization for forking."
// 53:
// 54:         conflicts "--dry-run", "--write"
// 55:         conflicts "--version", "--version-arm"
// 56:         conflicts "--version", "--version-intel"
// 57:
// 58:         named_args :cask, number: 1, without_api: true
// 59:       end
// 60:
// 61:       sig { override.void }
// 62:       def run
// 63:         # This will be run by `brew audit` or `brew style` later so run it first to
// 64:         # not start spamming during normal output.
// 65:         gem_groups = ["ast"]
// 66:         gem_groups << "style" if !args.no_audit? || !args.no_style?
// 67:         gem_groups << "audit" unless args.no_audit?
// 68:         Homebrew.install_bundler_gems!(groups: gem_groups)
// 69:         require "utils/ast"
// 70:
// 71:         # As this command is simplifying user-run commands then let's just use a
// 72:         # user path, too.
// 73:         ENV["PATH"] = PATH.new(ORIGINAL_PATHS).to_s
// 74:
// 75:         # Use the user's browser, too.
// 76:         ENV["BROWSER"] = EnvConfig.browser
// 77:
// 78:         @cask_retried = T.let(false, T.nilable(T::Boolean))
// 79:         cask = begin
// 80:           args.named.to_casks.fetch(0)
// 81:         rescue Cask::CaskUnavailableError
// 82:           raise if @cask_retried
// 83:
// 84:           CoreCaskTap.instance.install(force: true)
// 85:           @cask_retried = true
// 86:           retry
// 87:         end
// 88:
// 89:         tap = cask.tap
// 90:         odie "This cask is not in a tap!" if tap.nil?
// 91:
// 92:         odie "This cask's tap is not a Git repository!" unless tap.git?
// 93:
// 94:         odie <<~EOS unless tap.allow_bump?(cask.token)
// 95:           Whoops, the #{cask.token} cask has its version update
// 96:           pull requests automatically opened by BrewTestBot every ~3 hours!
// 97:           We'd still love your contributions, though, so try another one
// 98:           that is excluded from autobump list (i.e. it has 'no_autobump!'
// 99:           method or 'livecheck' block with 'skip'.)
// 100:         EOS
// 101:
// 102:         if !args.write_only? && GitHub.too_many_open_prs?(cask.tap)
// 103:           odie "You have too many PRs open: close or merge some first!"
// 104:         end
// 105:
// 106:         new_version = BumpVersionParser.new(
// 107:           general: args.version,
// 108:           intel:   args.version_intel,
// 109:           arm:     args.version_arm,
// 110:         )
// 111:
// 112:         new_hash = unless (new_hash = args.sha256).nil?
// 113:           raise UsageError, "`--sha256` must not be empty." if new_hash.blank?
// 114:
// 115:           ["no_check", ":no_check"].include?(new_hash) ? :no_check : new_hash
// 116:         end
// 117:
// 118:         new_base_url = unless (new_base_url = args.url).nil?
// 119:           raise UsageError, "`--url` must not be empty." if new_base_url.blank?
// 120:
// 121:           begin
// 122:             URI(new_base_url)
// 123:           rescue URI::InvalidURIError
// 124:             raise UsageError, "`--url` is not valid."
// 125:           end
// 126:         end
// 127:
// 128:         if new_version.blank? && new_base_url.nil? && new_hash.nil?
// 129:           raise UsageError, "No `--version`, `--url` or `--sha256` argument specified!"
// 130:         end
// 131:
// 132:         check_throttle(cask, new_version:)
// 133:         check_pull_requests(cask, new_version:) unless args.write_only?
// 134:
// 135:         branch_name = "bump-#{cask.token}"
// 136:         commit_message = nil
// 137:
// 138:         sourcefile_path = cask.sourcefile_path
// 139:         raise "unexpected nil cask.sourcefile_path" unless sourcefile_path
// 140:
// 141:         old_contents = sourcefile_path.read
// 142:         new_contents = old_contents
// 143:
// 144:         if new_base_url
// 145:           commit_message ||= "#{cask.token}: update URL"
// 146:
// 147:           cask_ast = Utils::AST::CaskAST.new(new_contents)
// 148:           cask_ast.replace_first_stanza_value(:url, new_base_url.to_s)
// 149:           new_contents = cask_ast.process
// 150:         end
// 151:
// 152:         if new_version.present?
// 153:           # For simplicity, our naming defers to the arm version if multiple architectures are specified
// 154:           branch_version = new_version.arm || new_version.intel || new_version.general
// 155:           if branch_version.is_a?(Cask::DSL::Version)
// 156:             commit_version = shortened_version(branch_version, cask:)
// 157:             branch_name = "bump-#{cask.token}-#{branch_version.tr(",:", "-")}"
// 158:             commit_message ||= "#{cask.token} #{commit_version}"
// 159:
// 160:             # Append an arch-only suffix to the branch name and parenthetical to
// 161:             # the commit title if the cask is multi-arch but only one arch is
// 162:             # being updated
// 163:             if new_version.arm && !new_version.intel
// 164:               branch_name += "-arm-only"
// 165:               commit_message += " (arm only)"
// 166:             elsif new_version.intel && !new_version.arm
// 167:               branch_name += "-intel-only"
// 168:               commit_message += " (intel only)"
// 169:             end
// 170:           end
// 171:
// 172:           before_contents = new_contents
// 173:           new_contents = replace_version_and_checksum(cask, new_hash, new_version, new_contents)
// 174:           raise "Unable to update cask" if new_contents == before_contents
// 175:         end
// 176:
// 177:         commit_message ||= "#{cask.token}: update checksum" if new_hash
// 178:
// 179:         # We should have already thrown UsageError above if there's nothing to update
// 180:         raise "Expected to have a commit message" if commit_message.nil?
// 181:
// 182:         sourcefile_path.atomic_write(new_contents) unless args.dry_run?
// 183:
// 184:         audit_exceptions = []
// 185:         audit_exceptions << ["min_os", "rosetta", "signing"] if ENV["HOMEBREW_TEST_BOT_AUTOBUMP"].present?
// 186:         run_cask_audit(cask, old_contents, audit_exceptions)
// 187:         run_cask_style(cask, old_contents)
// 188:
// 189:         return if args.write_only? && !args.commit?
// 190:
// 191:         url = Homebrew::Bump.create_pr(
// 192:           Homebrew::Bump::BumpInfo.new(
// 193:             package_tap: cask.tap,
// 194:             branch_name:,
// 195:             pr_title:    commit_message,
// 196:             pr_message:  Homebrew::Bump.pr_message("bump-cask-pr", user_message: args.message),
// 197:             commits:     [
// 198:               Homebrew::Bump::Commit.new(
// 199:                 sourcefile_path:,
// 200:                 old_contents:,
// 201:                 commit_message:,
// 202:               ),
// 203:             ],
// 204:           ),
// 205:           dry_run:  args.dry_run?,
// 206:           no_fork:  args.no_fork? || args.write_only?,
// 207:           fork_org: args.fork_org,
// 208:           commit:   args.commit?,
// 209:         )
// 210:         return if url.blank?
// 211:
// 212:         if args.no_browse?
// 213:           puts url
// 214:         else
// 215:           exec_browser url
// 216:         end
// 217:       end
// 218:
// 219:       sig { params(cask: Cask::Cask, new_version: BumpVersionParser).returns(T::Array[[Symbol, Symbol]]) }
// 220:       def generate_system_options(cask, new_version)
// 221:         current_os = Homebrew::SimulateSystem.current_os
// 222:         current_os_is_macos = MacOSVersion::SYMBOLS.include?(current_os)
// 223:         newest_macos = MacOSVersion.new(HOMEBREW_MACOS_NEWEST_SUPPORTED).to_sym
// 224:
// 225:         # NOTE: We substitute the newest macOS (e.g. `:sequoia`) in place of
// 226:         # `:macos` values (when used), as a generic `:macos` value won't apply
// 227:         # to on_system blocks referencing macOS versions.
// 228:         os_values = []
// 229:
// 230:         arch_values = []
// 231:         if new_version.arm || new_version.intel
// 232:           arch_values << :arm if new_version.arm
// 233:           arch_values << :intel if new_version.intel
// 234:         end
// 235:
// 236:         if cask.on_system_blocks_exist?
// 237:           OnSystem::BASE_OS_OPTIONS.each do |os|
// 238:             os_values << if os == :macos
// 239:               (current_os_is_macos ? current_os : newest_macos)
// 240:             else
// 241:               os
// 242:             end
// 243:           end
// 244:
// 245:           # `depends_on arch:` may be scoped to an `on_os` block, so arch
// 246:           # filtering is deferred to `replace_version_and_checksum`.
// 247:           arch_values = OnSystem::ARCH_OPTIONS.dup if arch_values.empty?
// 248:         else
// 249:           # Architecture is only relevant if on_system blocks are present or
// 250:           # the cask uses `depends_on arch`, otherwise we default to ARM for
// 251:           # consistency.
// 252:           os_values << (current_os_is_macos ? current_os : newest_macos)
// 253:           if arch_values.empty?
// 254:             depends_on_archs = cask.depends_on.arch&.filter_map { |arch| arch[:type] }&.uniq
// 255:             arch_values = depends_on_archs.presence || [:arm]
// 256:           end
// 257:         end
// 258:
// 259:         if arch_values.length > 1 && !new_version.general
// 260:           # We sort arch values in descending order by version to mitigate the
// 261:           # issue where updating multiple arch-specific versions can lead to
// 262:           # incorrect version changes in the cask (e.g. ARM is version 1.2.3,
// 263:           # Intel is updated to 1.2.3, ARM is updated to 1.2.4 and this
// 264:           # incorrectly replaces the 1.2.3 version for both archs). This is
// 265:           # something that should be handled by better version replacement logic
// 266:           # but this is a workaround for now.
// 267:           arch_values = arch_values.sort_by do |type|
// 268:             new_version_value = Version.new(new_version.public_send(type) || "0")
// 269:             Livecheck::LivecheckVersion.create(cask, new_version_value)
// 270:           end.reverse
// 271:         end
// 272:
// 273:         os_values.product(arch_values)
// 274:       end
// 275:
// 276:       sig {
// 277:         params(
// 278:           cask:        Cask::Cask,
// 279:           new_hash:    T.nilable(T.any(String, Symbol)),
// 280:           new_version: BumpVersionParser,
// 281:           contents:    String,
// 282:         ).returns(String)
// 283:       }
// 284:       def replace_version_and_checksum(cask, new_hash, new_version, contents)
// 285:         cask_sourcefile_path = cask.sourcefile_path
// 286:         raise "unexpected nil cask.sourcefile_path" unless cask_sourcefile_path
// 287:
// 288:         contents = split_root_version_and_checksum(new_version, contents)
// 289:
// 290:         old_cask = Homebrew::SimulateSystem.with(os: default_cask_os, arch: :arm) do
// 291:           Cask::CaskLoader.load(cask_sourcefile_path)
// 292:         end
// 293:         generate_system_options(cask, new_version).each do |os, arch|
// 294:           tag = Utils::Bottles::Tag.new(system: os, arch:)
// 295:           old_cask.refresh_for_tag(tag) do
// 296:             next if tag.macos? && !old_cask.supports_macos?
// 297:             next if tag.linux? && !old_cask.supports_linux?
// 298:
// 299:             # Skip archs excluded by the cask's `depends_on arch:`.
// 300:             reloaded_archs = old_cask.depends_on.arch&.filter_map { |a| a[:type] }&.uniq
// 301:             next if reloaded_archs.present? && reloaded_archs.exclude?(arch)
// 302:
// 303:             old_version = old_cask.version
// 304:             next unless old_version
// 305:
// 306:             next if unsupported_nested_arch_stanza?(contents, :version, arch) ||
// 307:                     unsupported_nested_arch_stanza?(contents, :sha256, arch)
// 308:
// 309:             bump_version = new_version.public_send(arch) || new_version.general
// 310:             next unless bump_version
// 311:
// 312:             version_scope = cask_stanza_scope(contents, :version, arch)
// 313:             contents = replace_cask_stanza_value(
// 314:               contents, :version,
// 315:               old_version.latest? ? :latest : old_version.to_s,
// 316:               bump_version.latest? ? :latest : bump_version.to_s,
// 317:               within: version_scope
// 318:             )
// 319:
// 320:             tmp_cask = Cask::CaskLoader::FromContentLoader.new(contents)
// 321:                                                           .load(config: nil)
// 322:             old_hash = tmp_cask.sha256
// 323:             if old_hash.nil?
// 324:               raise Cask::CaskError, "#{cask}: No checksum is defined for #{tag.to_sym.inspect}. " \
// 325:                                      "Add `depends_on arch:` or an operating system `depends_on` to " \
// 326:                                      "declare unsupported platforms."
// 327:             end
// 328:             next if new_hash.is_a?(String) && old_hash.to_s == new_hash
// 329:
// 330:             checksum_scope = cask_stanza_scope(contents, :sha256, arch)
// 331:             if tmp_cask.version.latest? || new_hash == :no_check
// 332:               opoo "Ignoring specified `--sha256=` argument." if new_hash.is_a?(String)
// 333:               if old_hash != :no_check
// 334:                 contents = replace_cask_stanza_value(contents, :sha256, old_hash.to_s, :no_check,
// 335:                                                      within: checksum_scope)
// 336:               end
// 337:             elsif old_hash == :no_check && new_hash != :no_check
// 338:               if new_hash.is_a?(String) && (!arch_specific_version_bump?(new_version) || checksum_scope)
// 339:                 contents = replace_cask_stanza_value(contents, :sha256, :no_check, new_hash, within: checksum_scope)
// 340:               end
// 341:             elsif new_hash && cask.languages.empty? &&
// 342:                   (!cask.on_system_blocks_exist? || checksum_scope || arch_specific_version_bump?(new_version))
// 343:               contents = replace_cask_stanza_value(contents, :sha256, old_hash.to_s, new_hash.to_s,
// 344:                                                    within: checksum_scope)
// 345:             elsif old_hash != :no_check
// 346:               opoo "Multiple checksum replacements required; ignoring specified `--sha256` argument." if new_hash
// 347:               languages = if cask.languages.empty?
// 348:                 [nil]
// 349:               else
// 350:                 cask.languages
// 351:               end
// 352:               languages.each do |language|
// 353:                 new_cask        = Cask::CaskLoader.load(contents)
// 354:                 next unless new_cask.url
// 355:
// 356:                 new_cask.config = if language.blank?
// 357:                   tmp_cask.config
// 358:                 else
// 359:                   tmp_cask.config.merge(Cask::Config.new(explicit: { languages: [language] }))
// 360:                 end
// 361:                 download = Cask::Download.new(new_cask).fetch(verify_download_integrity: false)
// 362:                 Utils::Tar.validate_file(download)
// 363:
// 364:                 if new_cask.sha256.to_s != download.sha256
// 365:                   contents = replace_cask_stanza_value(contents, :sha256, new_cask.sha256.to_s, download.sha256,
// 366:                                                        within: checksum_scope)
// 367:                 end
// 368:               end
// 369:             end
// 370:           end
// 371:         end
// 372:         contents
// 373:       end
// 374:
// 375:       sig {
// 376:         params(
// 377:           contents:  String,
// 378:           name:      Symbol,
// 379:           old_value: T.any(Numeric, String, Symbol),
// 380:           new_value: T.any(Numeric, String, Symbol),
// 381:           within:    T.nilable(Symbol),
// 382:         ).returns(String)
// 383:       }
// 384:       def replace_cask_stanza_value(contents, name, old_value, new_value, within: nil)
// 385:         return contents if old_value == new_value
// 386:
// 387:         cask_ast = Utils::AST::CaskAST.new(contents)
// 388:         replacement_count = cask_ast.replace_stanza_value(name, old_value, new_value, within:)
// 389:         if replacement_count.zero?
// 390:           # Treat an already-applied replacement as a successful no-op so the
// 391:           # per-(os, arch) loop in `replace_version_and_checksum` can yield the
// 392:           # same general version more than once without raising.
// 393:           return contents if cask_ast.replace_stanza_value(name, new_value, new_value, within:).positive?
// 394:
// 395:           raise "Could not find '#{name}' stanza with value #{old_value.inspect}!"
// 396:         end
// 397:
// 398:         cask_ast.process
// 399:       end
// 400:
// 401:       sig { params(cask: Cask::Cask, new_version: BumpVersionParser).void }
// 402:       def check_throttle(cask, new_version:)
// 403:         return unless cask.tap
// 404:
// 405:         throttle_rate = cask.livecheck.throttle
// 406:         throttle_days = cask.livecheck.throttle_days
// 407:         return if throttle_rate.nil? && throttle_days.nil?
// 408:
// 409:         version = new_version.arm || new_version.intel || new_version.general
// 410:         return unless version.is_a?(Cask::DSL::Version)
// 411:
// 412:         return if Livecheck.throttle_allows_bump?(cask, version.to_s, throttle_rate:, throttle_days:)
// 413:
// 414:         throttle_items = []
// 415:         throttle_items << "#{throttle_rate} releases on multiples of #{throttle_rate}" if throttle_rate
// 416:         throttle_items << "#{throttle_days} #{Utils.pluralize("day", throttle_days)}" if throttle_days
// 417:
// 418:         odie "#{cask.token} should only be updated every #{throttle_items.join(" or ")}"
// 419:       end
// 420:
// 421:       private
// 422:
// 423:       sig { params(version: Cask::DSL::Version, cask: Cask::Cask).returns(Cask::DSL::Version) }
// 424:       def shortened_version(version, cask:)
// 425:         if version.before_comma == cask.version.before_comma
// 426:           version
// 427:         else
// 428:           version.before_comma
// 429:         end
// 430:       end
// 431:
// 432:       sig {
// 433:         params(
// 434:           new_version: BumpVersionParser,
// 435:           contents:    String,
// 436:         ).returns(String)
// 437:       }
// 438:       def split_root_version_and_checksum(new_version, contents)
// 439:         return contents unless arch_specific_version_bump?(new_version)
// 440:
// 441:         cask_ast = Utils::AST::CaskAST.new(contents)
// 442:         root_version = cask_ast.first_stanza_value(:version, within: :root)
// 443:         if root_version &&
// 444:            !cask_ast.stanza_anywhere?(:version, within: :on_arm) &&
// 445:            !cask_ast.stanza_anywhere?(:version, within: :on_intel)
// 446:           cask_ast.replace_root_stanza_with_arch_blocks(:version, root_version)
// 447:           contents = cask_ast.process
// 448:         end
// 449:
// 450:         cask_ast = Utils::AST::CaskAST.new(contents)
// 451:         root_sha256 = cask_ast.first_stanza_value(:sha256, within: :root)
// 452:         if root_sha256.is_a?(String) &&
// 453:            !cask_ast.stanza_anywhere?(:sha256, within: :on_arm) &&
// 454:            !cask_ast.stanza_anywhere?(:sha256, within: :on_intel)
// 455:           cask_ast.replace_root_stanza_with_arch_blocks(:sha256, root_sha256)
// 456:           contents = cask_ast.process
// 457:         end
// 458:
// 459:         contents
// 460:       end
// 461:
// 462:       sig { params(new_version: BumpVersionParser).returns(T::Boolean) }
// 463:       def arch_specific_version_bump?(new_version)
// 464:         new_version.arm.present? || new_version.intel.present?
// 465:       end
// 466:
// 467:       sig { returns(Symbol) }
// 468:       def default_cask_os
// 469:         current_os = Homebrew::SimulateSystem.current_os
// 470:         return current_os if MacOSVersion::SYMBOLS.include?(current_os)
// 471:
// 472:         MacOSVersion.new(HOMEBREW_MACOS_NEWEST_SUPPORTED).to_sym
// 473:       end
// 474:
// 475:       sig { params(contents: String, name: Symbol, arch: Symbol).returns(T::Boolean) }
// 476:       def unsupported_nested_arch_stanza?(contents, name, arch)
// 477:         cask_ast = Utils::AST::CaskAST.new(contents)
// 478:         scope = :"on_#{arch}"
// 479:
// 480:         cask_ast.stanza_anywhere?(name, within: scope) && !cask_ast.stanza?(name, within: scope)
// 481:       end
// 482:
// 483:       sig { params(contents: String, name: Symbol, arch: Symbol).returns(T.nilable(Symbol)) }
// 484:       def cask_stanza_scope(contents, name, arch)
// 485:         scope = :"on_#{arch}"
// 486:         return scope if Utils::AST::CaskAST.new(contents).stanza?(name, within: scope)
// 487:
// 488:         nil
// 489:       end
// 490:
// 491:       sig { params(cask: Cask::Cask, new_version: BumpVersionParser).void }
// 492:       def check_pull_requests(cask, new_version:)
// 493:         tap = cask.tap
// 494:         raise "unexpected nil cask.tap" unless tap
// 495:
// 496:         tap_remote_repo = tap.remote_repository
// 497:         odie "#{tap.name} tap does not have a remote repository!" unless tap_remote_repo
// 498:
// 499:         sourcefile_path = cask.sourcefile_path
// 500:         raise "unexpected nil cask.sourcefile_path" unless sourcefile_path
// 501:
// 502:         file = sourcefile_path.relative_path_from(tap.path).to_s
// 503:         quiet = args.quiet?
// 504:         official_tap = tap.official?
// 505:         GitHub.check_for_duplicate_pull_requests(cask.token, tap_remote_repo,
// 506:                                                  state: "open", file:, quiet:, official_tap:)
// 507:
// 508:         # if we haven't already found open requests, try for an exact match across all pull requests
// 509:         new_version.instance_variables.each do |version_type|
// 510:           version_type_version = new_version.instance_variable_get(version_type)
// 511:           next if version_type_version.blank?
// 512:
// 513:           version = shortened_version(version_type_version, cask:)
// 514:           GitHub.check_for_duplicate_pull_requests(cask.token, tap_remote_repo, version:,
// 515:                                                    file:, quiet:, official_tap:)
// 516:         end
// 517:       end
// 518:
// 519:       sig { params(cask: Cask::Cask, old_contents: String, audit_exceptions: T::Array[String]).void }
// 520:       def run_cask_audit(cask, old_contents, audit_exceptions = [])
// 521:         if args.dry_run?
// 522:           if args.no_audit?
// 523:             ohai "Skipping `brew audit`"
// 524:           else
// 525:             ohai "brew audit --cask --online #{cask.full_name}"
// 526:           end
// 527:           return
// 528:         end
// 529:         failed_audit = false
// 530:         if args.no_audit?
// 531:           ohai "Skipping `brew audit`"
// 532:         else
// 533:           system HOMEBREW_BREW_FILE.to_s, "audit", "--cask", "--online", cask.full_name,
// 534:                  "--except=#{audit_exceptions.join(",")}"
// 535:           failed_audit = !$CHILD_STATUS.success?
// 536:         end
// 537:         return unless failed_audit
// 538:
// 539:         sourcefile_path = cask.sourcefile_path
// 540:         raise "unexpected nil cask.sourcefile_path" unless sourcefile_path
// 541:
// 542:         sourcefile_path.atomic_write(old_contents)
// 543:         odie "`brew audit` failed!"
// 544:       end
// 545:
// 546:       sig { params(cask: Cask::Cask, old_contents: String).void }
// 547:       def run_cask_style(cask, old_contents)
// 548:         sourcefile_path = cask.sourcefile_path
// 549:         raise "unexpected nil cask.sourcefile_path" unless sourcefile_path
// 550:
// 551:         if args.dry_run?
// 552:           if args.no_style?
// 553:             ohai "Skipping `brew style --fix`"
// 554:           else
// 555:             ohai "brew style --fix #{sourcefile_path.basename}"
// 556:           end
// 557:           return
// 558:         end
// 559:         failed_style = false
// 560:         if args.no_style?
// 561:           ohai "Skipping `brew style --fix`"
// 562:         else
// 563:           system HOMEBREW_BREW_FILE.to_s, "style", "--fix", sourcefile_path.to_s
// 564:           failed_style = !$CHILD_STATUS.success?
// 565:         end
// 566:         return unless failed_style
// 567:
// 568:         sourcefile_path.atomic_write(old_contents)
// 569:         odie "`brew style --fix` failed!"
// 570:       end
// 571:     end
// 572:   end
// 573: end
