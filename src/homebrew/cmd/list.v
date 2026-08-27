module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/list.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 94.
pub fn ruby_list_l94_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `warn_about_broken_caskroom_symlinks` at line 272.
pub fn ruby_list_l272_d2_warn_about_broken_caskroom_symlinks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('warn_about_broken_caskroom_symlinks', ...args)
}

// Ruby method `pinned_formula_entry(name)` at line 281.
pub fn ruby_list_l281_d3_pinned_formula_entry(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pinned_formula_entry', ...args)
}

// Ruby method `pinned_cask_entry(token)` at line 289.
pub fn ruby_list_l289_d4_pinned_cask_entry(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pinned_cask_entry', ...args)
}

// Ruby method `filtered_list` at line 297.
pub fn ruby_list_l297_d5_filtered_list(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('filtered_list', ...args)
}

// Ruby method `list_casks` at line 316.
pub fn ruby_list_l316_d6_list_casks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('list_casks', ...args)
}

// Ruby method `initialize(path)` at line 348.
pub fn ruby_list_l348_d7_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `print_dir(root, &block)` at line 378.
pub fn ruby_list_l378_d8_print_dir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('print_dir', ...args)
}

// Ruby method `print_remaining_files(files, root, other = "")` at line 404.
pub fn ruby_list_l404_d9_print_remaining_files(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('print_remaining_files', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "metafiles"
// 6: require "formula"
// 7: require "cli/parser"
// 8: require "cask/list"
// 9: require "system_command"
// 10: require "tab"
// 11:
// 12: module Homebrew
// 13:   module Cmd
// 14:     class List < AbstractCommand
// 15:       include SystemCommand::Mixin
// 16:
// 17:       cmd_args do
// 18:         description <<~EOS
// 19:           List all installed formulae and casks.
// 20:           If <formula> is provided, summarise the paths within its current keg.
// 21:           If <cask> is provided, list its artifacts.
// 22:         EOS
// 23:         switch "--formula", "--formulae",
// 24:                description: "List only formulae, or treat all named arguments as formulae."
// 25:         switch "--cask", "--casks",
// 26:                description: "List only casks, or treat all named arguments as casks."
// 27:         switch "--full-name",
// 28:                description: "Print formulae with fully-qualified names. Unless `--full-name`, `--versions` " \
// 29:                             "or `--pinned` are passed, other options (i.e. `-1`, `-l`, `-r` and `-t`) are " \
// 30:                             "passed to `ls`(1) which produces the actual output."
// 31:         switch "--versions",
// 32:                description: "Show the version number for installed formulae, or only the specified " \
// 33:                             "formulae if <formula> are provided."
// 34:         switch "--json",
// 35:                description: "Output installed formulae and casks with versions, linked and opt-linked formula " \
// 36:                             "versions and pinned versions as JSON using the fast Bash command path. Requires " \
// 37:                             "`--versions`, no named arguments and `jq`."
// 38:         switch "--multiple",
// 39:                description: "Only show formulae with multiple versions installed. Implies `--versions`."
// 40:         switch "--pinned",
// 41:                description: "List only pinned packages, or only the specified (pinned) packages if <formula> or " \
// 42:                             "<cask> are provided. See also `pin`, `unpin`."
// 43:         switch "--installed-on-request",
// 44:                description: "List the formulae installed on request."
// 45:         switch "--no-installed-on-request",
// 46:                description: "List the formulae not installed on request (i.e. installed as dependencies)."
// 47:         switch "--installed-as-dependency",
// 48:                description: "List the formulae installed as dependencies.",
// 49:                odeprecated: true,
// 50:                replacement: "--no-installed-on-request"
// 51:         switch "--poured-from-bottle",
// 52:                description: "List the formulae installed from a bottle."
// 53:         switch "--built-from-source",
// 54:                description: "List the formulae compiled from source."
// 55:
// 56:         # passed through to ls
// 57:         switch "-1",
// 58:                description: "Force output to be one entry per line. " \
// 59:                             "This is the default when output is not to a terminal."
// 60:         switch "-l",
// 61:                description: "List formulae and/or casks in long format. " \
// 62:                             "Has no effect when a formula or cask name is passed as an argument."
// 63:         switch "-r",
// 64:                description: "Reverse the order of formula and/or cask sorting to list the oldest entries first. " \
// 65:                             "Has no effect when a formula or cask name is passed as an argument."
// 66:         switch "-t",
// 67:                description: "Sort formulae and/or casks by time modified, listing most recently modified first. " \
// 68:                             "Has no effect when a formula or cask name is passed as an argument."
// 69:
// 70:         conflicts "--formula", "--cask"
// 71:         conflicts "--multiple", "--cask"
// 72:         conflicts "--pinned", "--multiple"
// 73:         ["--installed-on-request", "--no-installed-on-request", "--installed-as-dependency",
// 74:          "--poured-from-bottle", "--built-from-source"].each do |flag|
// 75:           conflicts "--cask", flag
// 76:           conflicts "--versions", flag
// 77:           conflicts "--multiple", flag
// 78:           conflicts "--pinned", flag
// 79:           conflicts "-l", flag
// 80:         end
// 81:         ["-1", "-l", "-r", "-t"].each do |flag|
// 82:           conflicts "--versions", flag
// 83:           conflicts "--multiple", flag
// 84:           conflicts "--pinned", flag
// 85:         end
// 86:         ["--versions", "--multiple", "--pinned", "-l", "-r", "-t"].each do |flag|
// 87:           conflicts "--full-name", flag
// 88:         end
// 89:
// 90:         named_args [:installed_formula, :installed_cask]
// 91:       end
// 92:
// 93:       sig { override.void }
// 94:       def run
// 95:         if args.json?
// 96:           raise UsageError, "`brew list --json` requires `--versions`." unless args.versions?
// 97:           raise UsageError, "`brew list --versions --json` does not support named arguments." unless args.no_named?
// 98:
// 99:           raise UsageError, "`brew list --versions --json` is only supported by the fast Bash path with `jq`."
// 100:         end
// 101:
// 102:         installed_as_dependency = args.no_installed_on_request? || args.installed_as_dependency?
// 103:
// 104:         if args.full_name? &&
// 105:            !(args.installed_on_request? || installed_as_dependency ||
// 106:              args.poured_from_bottle? || args.built_from_source?)
// 107:           unless args.cask?
// 108:             full_formula_names = if args.no_named?
// 109:               Formula.racks.map do |rack|
// 110:                 name = rack.basename.to_s
// 111:                 tap = begin
// 112:                   Keg.from_rack(rack)&.tab&.tap
// 113:                 rescue JSON::ParserError, SystemCallError, Tap::InvalidNameError
// 114:                   opoo "Could not identify the tap for #{name} from its installation receipt."
// 115:                   nil
// 116:                 end
// 117:                 (tap.nil? || tap.core_tap?) ? name : "#{tap}/#{name}"
// 118:               end
// 119:             else
// 120:               args.named.to_resolved_formulae.map(&:full_name)
// 121:             end.sort(&Cask::List::TAP_AND_NAME_COMPARISON)
// 122:             full_formula_names = Formatter.columns(full_formula_names) unless args.public_send(:"1?")
// 123:             puts full_formula_names if full_formula_names.present?
// 124:           end
// 125:           if args.cask? || (!args.formula? && args.no_named?)
// 126:             cask_names = if args.no_named?
// 127:               Cask::Caskroom.casks
// 128:             else
// 129:               args.named.to_formulae_and_casks(only: :cask, method: :resolve)
// 130:             end
// 131:             # The cast is because `Keg`` does not define `full_name`
// 132:             full_cask_names = T.cast(cask_names, T::Array[T.any(Formula, Cask::Cask)])
// 133:                                .map(&:full_name).sort(&Cask::List::TAP_AND_NAME_COMPARISON)
// 134:             full_cask_names = Formatter.columns(full_cask_names) unless args.public_send(:"1?")
// 135:             puts full_cask_names if full_cask_names.present?
// 136:           end
// 137:         elsif args.pinned?
// 138:           pinned = if args.no_named?
// 139:             entries = T.let([], T::Array[String])
// 140:             unless args.cask?
// 141:               Formula.racks.each do |rack|
// 142:                 entry = pinned_formula_entry(rack.basename.to_s)
// 143:                 entries << entry if entry
// 144:               end
// 145:             end
// 146:
// 147:             if !args.formula? && Cask::Caskroom.path.directory?
// 148:               Cask::Caskroom.path.children.reject(&:file?).each do |path|
// 149:                 entry = pinned_cask_entry(path.basename.to_s)
// 150:                 entries << entry if entry
// 151:               end
// 152:             end
// 153:             entries
// 154:           else
// 155:             args.named.filter_map do |name|
// 156:               entry = T.let(nil, T.nilable(String))
// 157:               package_found = T.let(false, T::Boolean)
// 158:               package_name = T.let(nil, T.nilable(String))
// 159:
// 160:               unless args.cask?
// 161:                 rack = Formulary.to_rack(name)
// 162:                 if rack.exist?
// 163:                   package_found = true
// 164:                   package_name = rack.basename.to_s
// 165:                   entry ||= pinned_formula_entry(rack.basename.to_s)
// 166:                 end
// 167:               end
// 168:
// 169:               unless args.formula?
// 170:                 token = ::Utils.name_from_full_name(name).to_s
// 171:                 caskroom_path = Cask::Caskroom.path/token
// 172:                 if caskroom_path.exist? || caskroom_path.symlink?
// 173:                   package_found = true
// 174:                   package_name ||= token
// 175:                   entry ||= pinned_cask_entry(token)
// 176:                 end
// 177:               end
// 178:
// 179:               if package_found && entry.nil?
// 180:                 opoo "#{package_name || name} not pinned"
// 181:               elsif !package_found
// 182:                 Homebrew.failed = true
// 183:               end
// 184:               entry
// 185:             end
// 186:           end
// 187:
// 188:           puts pinned.sort(&Cask::List::TAP_AND_NAME_COMPARISON)
// 189:         elsif args.versions? || args.multiple?
// 190:           filtered_list unless args.cask?
// 191:           list_casks if args.cask? || (!args.formula? && !args.multiple? && args.no_named?)
// 192:         elsif args.installed_on_request? ||
// 193:               installed_as_dependency ||
// 194:               args.poured_from_bottle? ||
// 195:               args.built_from_source?
// 196:           flags = []
// 197:           flags << "`--installed-on-request`" if args.installed_on_request?
// 198:           flags << "`--no-installed-on-request`" if installed_as_dependency
// 199:           flags << "`--poured-from-bottle`" if args.poured_from_bottle?
// 200:           flags << "`--built-from-source`" if args.built_from_source?
// 201:
// 202:           raise UsageError, "Cannot use #{flags.join(", ")} with formula arguments." unless args.no_named?
// 203:
// 204:           formulae = if args.t?
// 205:             # See https://ruby-doc.org/3.2/Kernel.html#method-i-test
// 206:             Formula.installed.sort_by { |formula| T.cast(test("M", formula.rack.to_s), Time) }.reverse!
// 207:           elsif args.full_name?
// 208:             Formula.installed.sort { |a, b| Cask::List::TAP_AND_NAME_COMPARISON.call(a.full_name, b.full_name) }
// 209:           else
// 210:             Formula.installed.sort
// 211:           end
// 212:           formulae.reverse! if args.r?
// 213:           formulae.each do |formula|
// 214:             tab = Tab.for_formula(formula)
// 215:
// 216:             statuses = []
// 217:             statuses << "installed on request" if args.installed_on_request? && tab.installed_on_request
// 218:             statuses << "installed as dependency" if installed_as_dependency && !tab.installed_on_request
// 219:             statuses << "poured from bottle" if args.poured_from_bottle? && tab.poured_from_bottle
// 220:             statuses << "built from source" if args.built_from_source? && !tab.poured_from_bottle
// 221:             next if statuses.empty?
// 222:
// 223:             name = args.full_name? ? formula.full_name : formula.name
// 224:             if flags.count > 1
// 225:               puts "#{name}: #{statuses.join(", ")}"
// 226:             else
// 227:               puts name
// 228:             end
// 229:           end
// 230:         elsif args.no_named?
// 231:           ENV["CLICOLOR"] = nil
// 232:
// 233:           ls_args = []
// 234:           ls_args << "-1" if args.public_send(:"1?")
// 235:           ls_args << "-l" if args.l?
// 236:           ls_args << "-r" if args.r?
// 237:           ls_args << "-t" if args.t?
// 238:
// 239:           if !args.cask? && HOMEBREW_CELLAR.exist? && HOMEBREW_CELLAR.children.any?
// 240:             ohai "Formulae" if $stdout.tty? && !args.formula?
// 241:             system_command! "ls", args: [*ls_args, HOMEBREW_CELLAR], print_stdout: true
// 242:             puts if $stdout.tty? && !args.formula?
// 243:           end
// 244:           unless args.formula?
// 245:             if Cask::Caskroom.any_casks_installed?
// 246:               ohai "Casks" if $stdout.tty? && !args.cask?
// 247:               system_command! "ls", args: [*ls_args, Cask::Caskroom.path], print_stdout: true
// 248:             end
// 249:             warn_about_broken_caskroom_symlinks
// 250:           end
// 251:         else
// 252:           kegs, casks = args.named.to_kegs_to_casks
// 253:
// 254:           if args.verbose? || !$stdout.tty?
// 255:             find_args = %w[-not -type d -not -name .DS_Store -print]
// 256:             system_command! "find", args: kegs.map(&:to_s) + find_args, print_stdout: true if kegs.present?
// 257:             system_command! "find", args: casks.map(&:caskroom_path) + find_args, print_stdout: true if casks.present?
// 258:           else
// 259:             kegs.each { |keg| PrettyListing.new keg } if kegs.present?
// 260:             Cask::List.list_casks(*casks, one: args.public_send(:"1?")) if casks.present?
// 261:           end
// 262:         end
// 263:       end
// 264:
// 265:       private
// 266:
// 267:       # A broken symlink in the Caskroom (e.g. a dangling cask rename alias) lists
// 268:       # like an installed cask but cannot load or uninstall, so flag it.
// 269:       # Keep in sync with the broken-symlink warning in `homebrew-list` in
// 270:       # Library/Homebrew/list.sh.
// 271:       sig { void }
// 272:       def warn_about_broken_caskroom_symlinks
// 273:         broken_symlinks = Cask::Caskroom.path.glob("*").select { |child| child.symlink? && !child.exist? }
// 274:         return if broken_symlinks.empty?
// 275:
// 276:         opoo "Broken Caskroom symlinks (`brew cleanup` removes them): " \
// 277:              "#{broken_symlinks.map(&:basename).sort.join(", ")}"
// 278:       end
// 279:
// 280:       sig { params(name: String).returns(T.nilable(String)) }
// 281:       def pinned_formula_entry(name)
// 282:         pin_path = HOMEBREW_PINNED_KEGS/name
// 283:         return unless pin_path.symlink?
// 284:
// 285:         "#{name}#{" #{pin_path.readlink.basename}" if args.versions?}"
// 286:       end
// 287:
// 288:       sig { params(token: String).returns(T.nilable(String)) }
// 289:       def pinned_cask_entry(token)
// 290:         pin_path = HOMEBREW_PINNED_CASKS/token
// 291:         return if !pin_path.symlink? || !pin_path.exist?
// 292:
// 293:         "#{token}#{" #{pin_path.resolved_path.basename}" if args.versions?}"
// 294:       end
// 295:
// 296:       sig { void }
// 297:       def filtered_list
// 298:         names = if args.no_named?
// 299:           Formula.racks
// 300:         else
// 301:           racks = args.named.map { |n| Formulary.to_rack(n) }
// 302:           racks.select do |rack|
// 303:             Homebrew.failed = true unless rack.exist?
// 304:             rack.exist?
// 305:           end
// 306:         end
// 307:         names.sort.each do |d|
// 308:           versions = d.subdirs.map { |pn| pn.basename.to_s }
// 309:           next if args.multiple? && versions.length < 2
// 310:
// 311:           puts "#{d.basename} #{versions * " "}"
// 312:         end
// 313:       end
// 314:
// 315:       sig { void }
// 316:       def list_casks
// 317:         casks = if args.no_named?
// 318:           cask_paths = Cask::Caskroom.path.children.reject(&:file?).map do |path|
// 319:             if path.symlink?
// 320:               real_path = path.realpath
// 321:               real_path.basename.to_s
// 322:             else
// 323:               path.basename.to_s
// 324:             end
// 325:           end.uniq.sort
// 326:           cask_paths.map { |name| Cask::CaskLoader.load(name) }
// 327:         else
// 328:           filtered_args = args.named.dup.delete_if do |n|
// 329:             Homebrew.failed = true unless Cask::Caskroom.path.join(n).exist?
// 330:             !Cask::Caskroom.path.join(n).exist?
// 331:           end
// 332:           # NamedAargs subclasses array
// 333:           T.cast(filtered_args, Homebrew::CLI::NamedArgs).to_formulae_and_casks(only: :cask)
// 334:         end
// 335:         return if casks.blank?
// 336:
// 337:         Cask::List.list_casks(
// 338:           *casks,
// 339:           one:       args.public_send(:"1?"),
// 340:           full_name: args.full_name?,
// 341:           versions:  args.versions?,
// 342:         )
// 343:       end
// 344:     end
// 345:
// 346:     class PrettyListing
// 347:       sig { params(path: T.any(String, Pathname, Keg)).void }
// 348:       def initialize(path)
// 349:         valid_lib_extensions = [".cps", ".dylib", ".pc"]
// 350:         Pathname.new(path).children.sort_by { |p| p.to_s.downcase }.each do |pn|
// 351:           case pn.basename.to_s
// 352:           when "bin", "sbin"
// 353:             pn.find { |pnn| puts pnn unless pnn.directory? }
// 354:           when "lib"
// 355:             print_dir pn do |pnn|
// 356:               # dylibs have multiple symlinks and we don't care about them
// 357:               valid_lib_extensions.include?(pnn.extname) && !pnn.symlink?
// 358:             end
// 359:           when ".brew"
// 360:             next # Ignore .brew
// 361:           else
// 362:             if pn.directory?
// 363:               if pn.symlink?
// 364:                 puts "#{pn} -> #{pn.readlink}"
// 365:               else
// 366:                 print_dir pn
// 367:               end
// 368:             elsif Metafiles.list?(pn.basename.to_s)
// 369:               puts pn
// 370:             end
// 371:           end
// 372:         end
// 373:       end
// 374:
// 375:       private
// 376:
// 377:       sig { params(root: Pathname, block: T.nilable(T.proc.params(arg0: Pathname).returns(T::Boolean))).void }
// 378:       def print_dir(root, &block)
// 379:         dirs = []
// 380:         remaining_root_files = []
// 381:         other = ""
// 382:
// 383:         root.children.sort.each do |pn|
// 384:           if pn.directory?
// 385:             dirs << pn
// 386:           elsif block && yield(pn)
// 387:             puts pn
// 388:             other = "other "
// 389:           elsif pn.basename.to_s != ".DS_Store"
// 390:             remaining_root_files << pn
// 391:           end
// 392:         end
// 393:
// 394:         dirs.each do |d|
// 395:           files = []
// 396:           d.find { |pn| files << pn unless pn.directory? }
// 397:           print_remaining_files files, d
// 398:         end
// 399:
// 400:         print_remaining_files remaining_root_files, root, other
// 401:       end
// 402:
// 403:       sig { params(files: T::Array[Pathname], root: Pathname, other: String).void }
// 404:       def print_remaining_files(files, root, other = "")
// 405:         if files.length == 1
// 406:           puts files
// 407:         elsif files.length > 1
// 408:           puts "#{root}/ (#{files.length} #{other}files)"
// 409:         end
// 410:       end
// 411:     end
// 412:   end
// 413: end
