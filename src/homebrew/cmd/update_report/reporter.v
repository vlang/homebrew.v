module update_report

import brew_runtime

// Translated from Homebrew/brew `cmd/update_report/reporter.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(var_name)` at line 25.
pub fn ruby_reporter_l25_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `initialize(tap, api_names_txt: nil, api_names_before_txt: nil, api_dir_prefix: nil)` at line 34.
pub fn ruby_reporter_l34_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `report(auto_update: false)` at line 56.
pub fn ruby_reporter_l56_d3_report(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('report', ...args)
}

// Ruby method `updated?` at line 211.
pub fn ruby_reporter_l211_d4_updated(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('updated?', ...args)
}

// Ruby method `migrate_tap_migration` at line 220.
pub fn ruby_reporter_l220_d5_migrate_tap_migration(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('migrate_tap_migration', ...args)
}

// Ruby method `migrate_cask_rename` at line 313.
pub fn ruby_reporter_l313_d6_migrate_cask_rename(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('migrate_cask_rename', ...args)
}

// Ruby method `migrate_formula_rename(force:, verbose:)` at line 320.
pub fn ruby_reporter_l320_d7_migrate_formula_rename(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('migrate_formula_rename', ...args)
}

// Ruby method `ensure_trusted_tap_installed!(name, new_name, new_tap)` at line 342.
pub fn ruby_reporter_l342_d8_ensure_trusted_tap_installed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ensure_trusted_tap_installed!', ...args)
}

// Ruby method `diff` at line 370.
pub fn ruby_reporter_l370_d9_diff(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('diff', ...args)
}

// Ruby attr_reader `attr_reader :tap` at line 414.
pub fn ruby_reporter_l414_d10_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tap', ...args)
}

// Ruby attr_reader `attr_reader :initial_revision` at line 417.
pub fn ruby_reporter_l417_d11_initial_revision(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initial_revision', ...args)
}

// Ruby attr_reader `attr_reader :current_revision` at line 420.
pub fn ruby_reporter_l420_d12_current_revision(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('current_revision', ...args)
}

// Ruby attr_reader `attr_reader :api_names_txt` at line 423.
pub fn ruby_reporter_l423_d13_api_names_txt(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('api_names_txt', ...args)
}

// Ruby attr_reader `attr_reader :api_names_before_txt` at line 426.
pub fn ruby_reporter_l426_d14_api_names_before_txt(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('api_names_before_txt', ...args)
}

// Ruby attr_reader `attr_reader :api_dir_prefix` at line 429.
pub fn ruby_reporter_l429_d15_api_dir_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('api_dir_prefix', ...args)
}

// Ruby method `installed_from_api?(api_names_txt = @api_names_txt, api_names_before_txt = @api_names_before_txt,` at line 435.
pub fn ruby_reporter_l435_d16_installed_from_api(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installed_from_api?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "trust"
// 5:
// 6: class Reporter
// 7:   include Utils::Output::Mixin
// 8:
// 9:   Report = T.type_alias do
// 10:     {
// 11:       A:  T::Array[String],
// 12:       AC: T::Array[String],
// 13:       D:  T::Array[String],
// 14:       DC: T::Array[String],
// 15:       M:  T::Array[String],
// 16:       MC: T::Array[String],
// 17:       R:  T::Array[[String, String]],
// 18:       RC: T::Array[[String, String]],
// 19:       T:  T::Array[String],
// 20:     }
// 21:   end
// 22:
// 23:   class ReporterRevisionUnsetError < RuntimeError
// 24:     sig { params(var_name: String).void }
// 25:     def initialize(var_name)
// 26:       super "#{var_name} is unset!"
// 27:     end
// 28:   end
// 29:
// 30:   sig {
// 31:     params(tap: Tap, api_names_txt: T.nilable(Pathname), api_names_before_txt: T.nilable(Pathname),
// 32:            api_dir_prefix: T.nilable(Pathname)).void
// 33:   }
// 34:   def initialize(tap, api_names_txt: nil, api_names_before_txt: nil, api_dir_prefix: nil)
// 35:     @tap = tap
// 36:
// 37:     # This is slightly involved/weird but all the #report logic is shared so it's worth it.
// 38:     if installed_from_api?(api_names_txt, api_names_before_txt, api_dir_prefix)
// 39:       @api_names_txt = T.let(api_names_txt, T.nilable(Pathname))
// 40:       @api_names_before_txt = T.let(api_names_before_txt, T.nilable(Pathname))
// 41:       @api_dir_prefix = T.let(api_dir_prefix, T.nilable(Pathname))
// 42:     else
// 43:       initial_revision_var = "HOMEBREW_UPDATE_BEFORE#{tap.repository_var_suffix}"
// 44:       @initial_revision = T.let(ENV[initial_revision_var].to_s, String)
// 45:       raise ReporterRevisionUnsetError, initial_revision_var if @initial_revision.empty?
// 46:
// 47:       current_revision_var = "HOMEBREW_UPDATE_AFTER#{tap.repository_var_suffix}"
// 48:       @current_revision = T.let(ENV[current_revision_var].to_s, String)
// 49:       raise ReporterRevisionUnsetError, current_revision_var if @current_revision.empty?
// 50:     end
// 51:
// 52:     @report = T.let(nil, T.nilable(Report))
// 53:   end
// 54:
// 55:   sig { params(auto_update: T::Boolean).returns(Report) }
// 56:   def report(auto_update: false)
// 57:     return @report if @report
// 58:
// 59:     @report = {
// 60:       A: [], AC: [], D: [], DC: [], M: [], MC: [], R: T.let([], T::Array[[String, String]]),
// 61:       RC: T.let([], T::Array[[String, String]]), T: []
// 62:     }
// 63:     return @report unless updated?
// 64:
// 65:     diff.each_line do |line|
// 66:       status, *paths = line.split
// 67:       src = Pathname.new paths.first
// 68:       dst = Pathname.new paths.last
// 69:
// 70:       next if dst.extname != ".rb"
// 71:
// 72:       if paths.any? { |p| tap.cask_file?(p) }
// 73:         case status
// 74:         when "A"
// 75:           # Have a dedicated report array for new casks.
// 76:           @report[:AC] << tap.formula_file_to_name(src)
// 77:         when "D"
// 78:           # Have a dedicated report array for deleted casks.
// 79:           @report[:DC] << tap.formula_file_to_name(src)
// 80:         when "M"
// 81:           # Report updated casks
// 82:           @report[:MC] << tap.formula_file_to_name(src)
// 83:         when /^R\d{0,3}/
// 84:           src_full_name = tap.formula_file_to_name(src)
// 85:           dst_full_name = tap.formula_file_to_name(dst)
// 86:           # Don't report formulae that are moved within a tap but not renamed
// 87:           next if src_full_name == dst_full_name
// 88:
// 89:           @report[:DC] << src_full_name
// 90:           @report[:AC] << dst_full_name
// 91:         end
// 92:       end
// 93:
// 94:       next unless paths.any? do |p|
// 95:         tap.formula_file?(p) ||
// 96:         # Need to check for case where Formula directory was deleted
// 97:         (status == "D" && File.fnmatch?("{Homebrew,}Formula/**/*.rb", p, File::FNM_EXTGLOB | File::FNM_PATHNAME))
// 98:       end
// 99:
// 100:       case status
// 101:       when "A", "D"
// 102:         full_name = tap.formula_file_to_name(src)
// 103:         name = Utils.name_from_full_name(full_name)
// 104:         new_tap = tap.tap_migrations[name]
// 105:         if new_tap.blank?
// 106:           @report[T.must(status).to_sym] << full_name
// 107:         elsif status == "D"
// 108:           # Retain deleted formulae for tap migrations separately to avoid reporting as deleted
// 109:           @report[:T] << full_name
// 110:         end
// 111:       when "M"
// 112:         name = tap.formula_file_to_name(src)
// 113:
// 114:         @report[:M] << name
// 115:       when /^R\d{0,3}/
// 116:         src_full_name = tap.formula_file_to_name(src)
// 117:         dst_full_name = tap.formula_file_to_name(dst)
// 118:         # Don't report formulae that are moved within a tap but not renamed
// 119:         next if src_full_name == dst_full_name
// 120:
// 121:         @report[:D] << src_full_name
// 122:         @report[:A] << dst_full_name
// 123:       end
// 124:     end
// 125:
// 126:     renamed_casks = Set.new
// 127:     @report[:DC].each do |old_full_name|
// 128:       old_name = Utils.name_from_full_name(old_full_name)
// 129:       new_name = tap.cask_renames[old_name]
// 130:       next unless new_name
// 131:
// 132:       new_full_name = if tap.core_cask_tap?
// 133:         new_name
// 134:       else
// 135:         "#{tap}/#{new_name}"
// 136:       end
// 137:
// 138:       renamed_casks << [old_full_name, new_full_name] if @report[:AC].include?(new_full_name)
// 139:     end
// 140:
// 141:     @report[:AC].each do |new_full_name|
// 142:       new_name = Utils.name_from_full_name(new_full_name)
// 143:       old_name = tap.cask_renames.key(new_name)
// 144:       next unless old_name
// 145:
// 146:       old_full_name = if tap.core_cask_tap?
// 147:         old_name
// 148:       else
// 149:         "#{tap}/#{old_name}"
// 150:       end
// 151:
// 152:       renamed_casks << [old_full_name, new_full_name]
// 153:     end
// 154:
// 155:     if renamed_casks.any?
// 156:       @report[:AC] -= renamed_casks.map(&:last)
// 157:       @report[:DC] -= renamed_casks.map(&:first)
// 158:       @report[:RC] = renamed_casks.to_a
// 159:     end
// 160:
// 161:     renamed_formulae = Set.new
// 162:     @report[:D].each do |old_full_name|
// 163:       old_name = Utils.name_from_full_name(old_full_name)
// 164:       new_name = tap.formula_renames[old_name]
// 165:       next unless new_name
// 166:
// 167:       new_full_name = if tap.core_tap?
// 168:         new_name
// 169:       else
// 170:         "#{tap}/#{new_name}"
// 171:       end
// 172:
// 173:       renamed_formulae << [old_full_name, new_full_name] if @report[:A].include? new_full_name
// 174:     end
// 175:
// 176:     @report[:A].each do |new_full_name|
// 177:       new_name = Utils.name_from_full_name(new_full_name)
// 178:       old_name = tap.formula_renames.key(new_name)
// 179:       next unless old_name
// 180:
// 181:       old_full_name = if tap.core_tap?
// 182:         old_name
// 183:       else
// 184:         "#{tap}/#{old_name}"
// 185:       end
// 186:
// 187:       renamed_formulae << [old_full_name, new_full_name]
// 188:     end
// 189:
// 190:     if renamed_formulae.any?
// 191:       @report[:A] -= renamed_formulae.map(&:last)
// 192:       @report[:D] -= renamed_formulae.map(&:first)
// 193:       @report[:R] = renamed_formulae.to_a
// 194:     end
// 195:
// 196:     # If any formulae/casks are marked as added and deleted, remove them from
// 197:     # the report as we've not detected things correctly.
// 198:     if (added_and_deleted_formulae = (@report[:A] & @report[:D]).presence)
// 199:       @report[:A] -= added_and_deleted_formulae
// 200:       @report[:D] -= added_and_deleted_formulae
// 201:     end
// 202:     if (added_and_deleted_casks = (@report[:AC] & @report[:DC]).presence)
// 203:       @report[:AC] -= added_and_deleted_casks
// 204:       @report[:DC] -= added_and_deleted_casks
// 205:     end
// 206:
// 207:     @report
// 208:   end
// 209:
// 210:   sig { returns(T::Boolean) }
// 211:   def updated?
// 212:     if installed_from_api?
// 213:       diff.present?
// 214:     else
// 215:       initial_revision != current_revision
// 216:     end
// 217:   end
// 218:
// 219:   sig { void }
// 220:   def migrate_tap_migration
// 221:     [report[:D], report[:DC], report[:T]].flatten.each do |full_name|
// 222:       name = Utils.name_from_full_name(full_name)
// 223:       migration_target = tap.tap_migrations[name]
// 224:       next if migration_target.nil? # skip if not in tap_migrations list.
// 225:
// 226:       migrated_tap_name = Utils.tap_from_full_name(migration_target)
// 227:       new_name = if migrated_tap_name
// 228:         new_full_name = Utils.name_from_full_name(migration_target)
// 229:         new_tap_name = migrated_tap_name
// 230:         new_full_name
// 231:       elsif migration_target.include?("/")
// 232:         new_tap_name = migration_target
// 233:         new_full_name = "#{new_tap_name}/#{name}"
// 234:         name
// 235:       else
// 236:         new_tap_name = tap.name
// 237:         new_full_name = "#{new_tap_name}/#{migration_target}"
// 238:         migration_target
// 239:       end
// 240:
// 241:       # This means it is a cask
// 242:       if Array(report[:DC]).include? full_name
// 243:         next unless (HOMEBREW_PREFIX/"Caskroom"/name).exist?
// 244:
// 245:         new_tap = Tap.fetch(new_tap_name)
// 246:         next unless ensure_trusted_tap_installed!(name, new_name, new_tap)
// 247:
// 248:         ohai "#{name} has been moved to Homebrew.", <<~EOS
// 249:           To uninstall the cask, run:
// 250:             brew uninstall --cask --force #{name}
// 251:         EOS
// 252:         next if (HOMEBREW_CELLAR/Utils.name_from_full_name(new_name)).directory?
// 253:
// 254:         ohai "Installing #{new_name}..."
// 255:         begin
// 256:           system HOMEBREW_BREW_FILE.to_s, "install", "--overwrite", new_full_name
// 257:         # Rescue any possible exception types.
// 258:         rescue Exception => e # rubocop:disable Lint/RescueException
// 259:           if Homebrew::EnvConfig.developer?
// 260:             require "utils/backtrace"
// 261:             onoe "#{e.message}\n#{Utils::Backtrace.clean(e)&.join("\n")}"
// 262:           end
// 263:         end
// 264:         next
// 265:       end
// 266:
// 267:       next unless (dir = HOMEBREW_CELLAR/name).exist? # skip if formula is not installed.
// 268:
// 269:       tabs = dir.subdirs.map { |d| Keg.new(d).tab }
// 270:       next if tabs.first.tap != tap # skip if installed formula is not from this tap.
// 271:
// 272:       new_tap = Tap.fetch(new_tap_name)
// 273:       # For formulae migrated to cask: Auto-install cask or provide install instructions.
// 274:       # Check if the migration target is a cask (either in homebrew/cask or any other tap)
// 275:       if new_tap.core_cask_tap? || new_tap.cask_tokens.intersect?([new_full_name, new_name])
// 276:         migration_message = if new_tap == tap
// 277:           "#{full_name} has been migrated from a formula to a cask."
// 278:         else
// 279:           "#{name} has been moved to #{new_tap_name}."
// 280:         end
// 281:         if new_tap.installed? && (HOMEBREW_PREFIX/"Caskroom").directory?
// 282:           ohai migration_message
// 283:           ohai "brew unlink #{name}"
// 284:           system HOMEBREW_BREW_FILE.to_s, "unlink", name
// 285:           ohai "brew cleanup"
// 286:           system HOMEBREW_BREW_FILE.to_s, "cleanup"
// 287:           ohai "brew install --cask #{new_full_name}"
// 288:           system HOMEBREW_BREW_FILE.to_s, "install", "--cask", new_full_name
// 289:           ohai migration_message, <<~EOS
// 290:             The existing keg has been unlinked.
// 291:             Please uninstall the formula when convenient by running:
// 292:               brew uninstall --formula --force #{name}
// 293:           EOS
// 294:         else
// 295:           ohai migration_message, <<~EOS
// 296:             To uninstall the formula and install the cask, run:
// 297:               brew uninstall --formula --force #{name}
// 298:               brew tap #{new_tap_name}
// 299:               brew install --cask #{new_full_name}
// 300:           EOS
// 301:         end
// 302:       else
// 303:         next unless ensure_trusted_tap_installed!(name, new_name, new_tap)
// 304:
// 305:         # update tap for each Tab
// 306:         tabs.each { |tab| tab.tap = new_tap }
// 307:         tabs.each(&:write)
// 308:       end
// 309:     end
// 310:   end
// 311:
// 312:   sig { void }
// 313:   def migrate_cask_rename
// 314:     Cask::Caskroom.casks.each do |cask|
// 315:       Cask::Migrator.migrate_if_needed(cask)
// 316:     end
// 317:   end
// 318:
// 319:   sig { params(force: T::Boolean, verbose: T::Boolean).void }
// 320:   def migrate_formula_rename(force:, verbose:)
// 321:     Formula.installed.each do |formula|
// 322:       next unless Migrator.needs_migration?(formula)
// 323:
// 324:       oldnames_to_migrate = formula.oldnames.select do |oldname|
// 325:         oldname_rack = HOMEBREW_CELLAR/oldname
// 326:         next false unless oldname_rack.exist?
// 327:
// 328:         if oldname_rack.subdirs.empty?
// 329:           oldname_rack.rmdir_if_possible
// 330:           next false
// 331:         end
// 332:
// 333:         true
// 334:       end
// 335:       next if oldnames_to_migrate.empty?
// 336:
// 337:       Migrator.migrate_if_needed(formula, force:)
// 338:     end
// 339:   end
// 340:
// 341:   sig { params(name: String, new_name: String, new_tap: Tap).returns(T::Boolean) }
// 342:   def ensure_trusted_tap_installed!(name, new_name, new_tap)
// 343:     return true if new_tap.installed?
// 344:
// 345:     unless Homebrew::Trust.trusted_tap?(new_tap)
// 346:       new_bare_name = Utils.name_from_full_name(new_name)
// 347:       new_full_name = "#{new_tap.name}/#{new_bare_name}"
// 348:       # `brew migrate` only migrates renamed packages, so a tap-only migration
// 349:       # (unchanged name) needs a reinstall from the new tap instead.
// 350:       complete_command = if new_bare_name == name
// 351:         "brew reinstall #{name}"
// 352:       else
// 353:         "brew migrate #{name}"
// 354:       end
// 355:       opoo <<~EOS
// 356:         Not automatically tapping #{new_tap} to migrate #{name} as it is not a
// 357:         trusted tap. To complete the migration yourself, run:
// 358:           brew tap #{new_tap}
// 359:           brew trust #{new_full_name}
// 360:           #{complete_command}
// 361:       EOS
// 362:       return false
// 363:     end
// 364:
// 365:     new_tap.ensure_installed!
// 366:     true
// 367:   end
// 368:
// 369:   sig { returns(String) }
// 370:   def diff
// 371:     @diff ||= T.let(nil, T.nilable(String))
// 372:     @diff ||= if installed_from_api?
// 373:       # Hack `git diff` output with regexes to look like `git diff-tree` output.
// 374:       # Yes, I know this is a bit filthy but it saves duplicating the #report logic.
// 375:       diff_output = Utils.popen_read("git", "diff", "--no-ext-diff", api_names_before_txt, api_names_txt)
// 376:       header_regex = /^(---|\+\+\+) /
// 377:       add_delete_characters = ["+", "-"].freeze
// 378:
// 379:       api_dir_prefix_basename = T.must(api_dir_prefix).basename
// 380:
// 381:       diff_hash = diff_output.lines.each_with_object({}) do |line, hash|
// 382:         next if line.match?(header_regex)
// 383:         next unless add_delete_characters.include?(line[0])
// 384:
// 385:         name = line.chomp.delete_prefix("+").delete_prefix("-")
// 386:         file = "#{api_dir_prefix_basename}/#{name}.rb"
// 387:
// 388:         hash[file] ||= 0
// 389:         if line.start_with?("+")
// 390:           hash[file] += 1
// 391:         elsif line.start_with?("-")
// 392:           hash[file] -= 1
// 393:         end
// 394:       end
// 395:
// 396:       diff_hash.filter_map do |file, count|
// 397:         if count.positive?
// 398:           "A #{file}"
// 399:         elsif count.negative?
// 400:           "D #{file}"
// 401:         end
// 402:       end.join("\n")
// 403:     else
// 404:       Utils.popen_read(
// 405:         "git", "-C", tap.path, "diff-tree", "-r", "--name-status", "--diff-filter=AMDR",
// 406:         "-M85%", initial_revision, current_revision
// 407:       )
// 408:     end
// 409:   end
// 410:
// 411:   private
// 412:
// 413:   sig { returns(Tap) }
// 414:   attr_reader :tap
// 415:
// 416:   sig { returns(String) }
// 417:   attr_reader :initial_revision
// 418:
// 419:   sig { returns(String) }
// 420:   attr_reader :current_revision
// 421:
// 422:   sig { returns(T.nilable(Pathname)) }
// 423:   attr_reader :api_names_txt
// 424:
// 425:   sig { returns(T.nilable(Pathname)) }
// 426:   attr_reader :api_names_before_txt
// 427:
// 428:   sig { returns(T.nilable(Pathname)) }
// 429:   attr_reader :api_dir_prefix
// 430:
// 431:   sig {
// 432:     params(api_names_txt: T.nilable(Pathname), api_names_before_txt: T.nilable(Pathname),
// 433:            api_dir_prefix: T.nilable(Pathname)).returns(T::Boolean)
// 434:   }
// 435:   def installed_from_api?(api_names_txt = @api_names_txt, api_names_before_txt = @api_names_before_txt,
// 436:                           api_dir_prefix = @api_dir_prefix)
// 437:     !api_names_txt.nil? && !api_names_before_txt.nil? && !api_dir_prefix.nil?
// 438:   end
// 439: end
