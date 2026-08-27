module homebrew

import brew_runtime

// Translated from Homebrew/brew `formula_cellar_checks.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `formula; end` at line 15.
pub fn ruby_formula_cellar_checks_l15_d1_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula', ...args)
}

// Ruby method `problem_if_output(output); end` at line 18.
pub fn ruby_formula_cellar_checks_l18_d2_problem_if_output(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('problem_if_output', ...args)
}

// Ruby method `check_env_path(bin)` at line 21.
pub fn ruby_formula_cellar_checks_l21_d3_check_env_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_env_path', ...args)
}

// Ruby method `check_manpages` at line 41.
pub fn ruby_formula_cellar_checks_l41_d4_check_manpages(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_manpages', ...args)
}

// Ruby method `check_infopages` at line 53.
pub fn ruby_formula_cellar_checks_l53_d5_check_infopages(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_infopages', ...args)
}

// Ruby method `check_jars` at line 65.
pub fn ruby_formula_cellar_checks_l65_d6_check_jars(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_jars', ...args)
}

// Ruby method `valid_library_extension?(filename)` at line 85.
pub fn ruby_formula_cellar_checks_l85_d7_valid_library_extension(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('valid_library_extension?', ...args)
}

// Ruby method `check_non_libraries` at line 90.
pub fn ruby_formula_cellar_checks_l90_d8_check_non_libraries(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_non_libraries', ...args)
}

// Ruby method `check_non_executables(bin)` at line 109.
pub fn ruby_formula_cellar_checks_l109_d9_check_non_executables(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_non_executables', ...args)
}

// Ruby method `check_generic_executables(bin)` at line 123.
pub fn ruby_formula_cellar_checks_l123_d10_check_generic_executables(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_generic_executables', ...args)
}

// Ruby method `check_easy_install_pth(lib)` at line 141.
pub fn ruby_formula_cellar_checks_l141_d11_check_easy_install_pth(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_easy_install_pth', ...args)
}

// Ruby method `check_elisp_dirname(share, name)` at line 155.
pub fn ruby_formula_cellar_checks_l155_d12_check_elisp_dirname(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_elisp_dirname', ...args)
}

// Ruby method `check_elisp_root(share, name)` at line 174.
pub fn ruby_formula_cellar_checks_l174_d13_check_elisp_root(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_elisp_root', ...args)
}

// Ruby method `check_python_packages(lib, deps)` at line 195.
pub fn ruby_formula_cellar_checks_l195_d14_check_python_packages(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_python_packages', ...args)
}

// Ruby method `check_shim_references(prefix)` at line 232.
pub fn ruby_formula_cellar_checks_l232_d15_check_shim_references(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_shim_references', ...args)
}

// Ruby method `check_plist(prefix, plist)` at line 256.
pub fn ruby_formula_cellar_checks_l256_d16_check_plist(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_plist', ...args)
}

// Ruby method `check_python_symlinks(name, keg_only)` at line 293.
pub fn ruby_formula_cellar_checks_l293_d17_check_python_symlinks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_python_symlinks', ...args)
}

// Ruby method `check_service_command(formula)` at line 306.
pub fn ruby_formula_cellar_checks_l306_d18_check_service_command(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_service_command', ...args)
}

// Ruby method `check_cpuid_instruction(formula)` at line 315.
pub fn ruby_formula_cellar_checks_l315_d19_check_cpuid_instruction(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_cpuid_instruction', ...args)
}

// Ruby method `check_binary_arches(formula)` at line 361.
pub fn ruby_formula_cellar_checks_l361_d20_check_binary_arches(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_binary_arches', ...args)
}

// Ruby method `audit_installed` at line 427.
pub fn ruby_formula_cellar_checks_l427_d21_audit_installed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_installed', ...args)
}

// Ruby method `relative_glob(dir, pattern)` at line 453.
pub fn ruby_formula_cellar_checks_l453_d22_relative_glob(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('relative_glob', ...args)
}

// Ruby method `cpuid_instruction?(file, objdump)` at line 458.
pub fn ruby_formula_cellar_checks_l458_d23_cpuid_instruction(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cpuid_instruction?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/shell"
// 5: require "utils/path"
// 6:
// 7: # Checks to perform on a formula's keg (versioned Cellar path).
// 8: module FormulaCellarChecks
// 9:   extend T::Helpers
// 10:
// 11:   abstract!
// 12:   requires_ancestor { Kernel }
// 13:
// 14:   sig { abstract.returns(Formula) }
// 15:   def formula; end
// 16:
// 17:   sig { abstract.params(output: T.nilable(String)).void }
// 18:   def problem_if_output(output); end
// 19:
// 20:   sig { params(bin: Pathname).returns(T.nilable(String)) }
// 21:   def check_env_path(bin)
// 22:     return if Homebrew::EnvConfig.no_env_hints?
// 23:
// 24:     # warn the user if stuff was installed outside of their PATH
// 25:     return unless bin.directory?
// 26:     return if bin.children.empty?
// 27:
// 28:     prefix_bin = (HOMEBREW_PREFIX/bin.basename)
// 29:     return unless prefix_bin.directory?
// 30:
// 31:     prefix_bin = prefix_bin.realpath
// 32:     return if ORIGINAL_PATHS.include? prefix_bin
// 33:
// 34:     <<~EOS
// 35:       "#{prefix_bin}" is not in your PATH.
// 36:       You can amend this by altering your #{Utils::Shell.profile} file.
// 37:     EOS
// 38:   end
// 39:
// 40:   sig { returns(T.nilable(String)) }
// 41:   def check_manpages
// 42:     # Check for man pages that aren't in share/man
// 43:     return unless (formula.prefix/"man").directory?
// 44:
// 45:     <<~EOS
// 46:       A top-level "man" directory was found.
// 47:       Homebrew requires that man pages live under "share".
// 48:       This can often be fixed by passing `--mandir=\#{man}` to `configure`.
// 49:     EOS
// 50:   end
// 51:
// 52:   sig { returns(T.nilable(String)) }
// 53:   def check_infopages
// 54:     # Check for info pages that aren't in share/info
// 55:     return unless (formula.prefix/"info").directory?
// 56:
// 57:     <<~EOS
// 58:       A top-level "info" directory was found.
// 59:       Homebrew suggests that info pages live under "share".
// 60:       This can often be fixed by passing `--infodir=\#{info}` to `configure`.
// 61:     EOS
// 62:   end
// 63:
// 64:   sig { returns(T.nilable(String)) }
// 65:   def check_jars
// 66:     return unless formula.lib.directory?
// 67:
// 68:     jars = formula.lib.children.select { |g| g.extname == ".jar" }
// 69:     return if jars.empty?
// 70:
// 71:     <<~EOS
// 72:       JARs were installed to "#{formula.lib}".
// 73:       Installing JARs to "lib" can cause conflicts between packages.
// 74:       For Java software, it is typically better for the formula to
// 75:       install to "libexec" and then symlink or wrap binaries into "bin".
// 76:       See formulae 'activemq', 'jruby', etc. for examples.
// 77:       The offending files are:
// 78:         #{jars * "\n  "}
// 79:     EOS
// 80:   end
// 81:
// 82:   VALID_LIBRARY_EXTENSIONS = %w[.a .jnilib .la .o .so .jar .prl .pm .sh].freeze
// 83:
// 84:   sig { params(filename: Pathname).returns(T::Boolean) }
// 85:   def valid_library_extension?(filename)
// 86:     VALID_LIBRARY_EXTENSIONS.include? filename.extname
// 87:   end
// 88:
// 89:   sig { returns(T.nilable(String)) }
// 90:   def check_non_libraries
// 91:     return unless formula.lib.directory?
// 92:
// 93:     non_libraries = formula.lib.children.reject do |g|
// 94:       next true if g.directory?
// 95:
// 96:       valid_library_extension? g
// 97:     end
// 98:     return if non_libraries.empty?
// 99:
// 100:     <<~EOS
// 101:       Non-libraries were installed to "#{formula.lib}".
// 102:       Installing non-libraries to "lib" is discouraged.
// 103:       The offending files are:
// 104:         #{non_libraries * "\n  "}
// 105:     EOS
// 106:   end
// 107:
// 108:   sig { params(bin: Pathname).returns(T.nilable(String)) }
// 109:   def check_non_executables(bin)
// 110:     return unless bin.directory?
// 111:
// 112:     non_exes = bin.children.select { |g| g.directory? || !g.executable? }
// 113:     return if non_exes.empty?
// 114:
// 115:     <<~EOS
// 116:       Non-executables were installed to "#{bin}".
// 117:       The offending files are:
// 118:         #{non_exes * "\n  "}
// 119:     EOS
// 120:   end
// 121:
// 122:   sig { params(bin: Pathname).returns(T.nilable(String)) }
// 123:   def check_generic_executables(bin)
// 124:     return unless bin.directory?
// 125:
// 126:     generic_names = %w[service start stop]
// 127:     generics = bin.children.select { |g| generic_names.include? g.basename.to_s }
// 128:     return if generics.empty?
// 129:
// 130:     <<~EOS
// 131:       Generic binaries were installed to "#{bin}".
// 132:       Binaries with generic names are likely to conflict with other software.
// 133:       Homebrew suggests that this software is installed to "libexec" and then
// 134:       symlinked as needed.
// 135:       The offending files are:
// 136:         #{generics * "\n  "}
// 137:     EOS
// 138:   end
// 139:
// 140:   sig { params(lib: Pathname).returns(T.nilable(String)) }
// 141:   def check_easy_install_pth(lib)
// 142:     pth_found = Dir["#{lib}/python3*/site-packages/easy-install.pth"].map { |f| File.dirname(f) }
// 143:     return if pth_found.empty?
// 144:
// 145:     <<~EOS
// 146:       'easy-install.pth' files were found.
// 147:       These '.pth' files are likely to cause link conflicts.
// 148:       Easy install is now deprecated, do not use it.
// 149:       The offending files are:
// 150:         #{pth_found * "\n  "}
// 151:     EOS
// 152:   end
// 153:
// 154:   sig { params(share: Pathname, name: String).returns(T.nilable(String)) }
// 155:   def check_elisp_dirname(share, name)
// 156:     return unless (share/"emacs/site-lisp").directory?
// 157:     # Emacs itself can do what it wants
// 158:     return if name == "emacs"
// 159:
// 160:     bad_dir_name = (share/"emacs/site-lisp").children.any? do |child|
// 161:       child.directory? && child.basename.to_s != name
// 162:     end
// 163:
// 164:     return unless bad_dir_name
// 165:
// 166:     <<~EOS
// 167:       Emacs Lisp files were installed into the wrong "site-lisp" subdirectory.
// 168:       They should be installed into:
// 169:         #{share}/emacs/site-lisp/#{name}
// 170:     EOS
// 171:   end
// 172:
// 173:   sig { params(share: Pathname, name: String).returns(T.nilable(String)) }
// 174:   def check_elisp_root(share, name)
// 175:     return unless (share/"emacs/site-lisp").directory?
// 176:     # Emacs itself can do what it wants
// 177:     return if name == "emacs"
// 178:
// 179:     elisps = (share/"emacs/site-lisp").children.select do |file|
// 180:       Keg::ELISP_EXTENSIONS.include? file.extname
// 181:     end
// 182:     return if elisps.empty?
// 183:
// 184:     <<~EOS
// 185:       Emacs Lisp files were linked directly to "#{HOMEBREW_PREFIX}/share/emacs/site-lisp".
// 186:       This may cause conflicts with other packages.
// 187:       They should instead be installed into:
// 188:         #{share}/emacs/site-lisp/#{name}
// 189:       The offending files are:
// 190:         #{elisps * "\n  "}
// 191:     EOS
// 192:   end
// 193:
// 194:   sig { params(lib: Pathname, deps: Dependencies).returns(T.nilable(String)) }
// 195:   def check_python_packages(lib, deps)
// 196:     return unless lib.directory?
// 197:
// 198:     lib_subdirs = lib.children
// 199:                      .select(&:directory?)
// 200:                      .map(&:basename)
// 201:
// 202:     pythons = lib_subdirs.filter_map do |p|
// 203:       match = p.to_s.match(/^python(\d+\.\d+)$/)
// 204:       next if match.blank?
// 205:       next if match.captures.blank?
// 206:
// 207:       match.captures.first
// 208:     end
// 209:
// 210:     return if pythons.blank?
// 211:
// 212:     python_deps = deps.to_a
// 213:                       .map(&:name)
// 214:                       .grep(/^python(@.*)?$/)
// 215:                       .filter_map { |d| Formula[d].version.to_s[/^\d+\.\d+/] }
// 216:
// 217:     return if python_deps.blank?
// 218:     return if pythons.intersect?(python_deps)
// 219:
// 220:     pythons = pythons.map { |v| "Python #{v}" }
// 221:     python_deps = python_deps.map { |v| "Python #{v}" }
// 222:
// 223:     <<~EOS
// 224:       Packages have been installed for:
// 225:         #{pythons * "\n  "}
// 226:       but this formula depends on:
// 227:         #{python_deps * "\n  "}
// 228:     EOS
// 229:   end
// 230:
// 231:   sig { params(prefix: Pathname).returns(T.nilable(String)) }
// 232:   def check_shim_references(prefix)
// 233:     return unless prefix.directory?
// 234:
// 235:     keg = Keg.new(prefix)
// 236:
// 237:     matches = []
// 238:     keg.each_unique_file_matching(HOMEBREW_SHIMS_PATH.to_s) do |f|
// 239:       match = f.relative_path_from(keg.to_path)
// 240:
// 241:       next if match.to_s.match? %r{^share/doc/.+?/INFO_BIN$}
// 242:
// 243:       matches << match
// 244:     end
// 245:
// 246:     return if matches.empty?
// 247:
// 248:     <<~EOS
// 249:       Files were found with references to the Homebrew shims directory.
// 250:       The offending files are:
// 251:         #{matches * "\n  "}
// 252:     EOS
// 253:   end
// 254:
// 255:   sig { params(prefix: Pathname, plist: Pathname).returns(T.nilable(String)) }
// 256:   def check_plist(prefix, plist)
// 257:     return unless prefix.directory?
// 258:
// 259:     require "plist"
// 260:     plist = begin
// 261:       Plist.parse_xml(plist, marshal: false)
// 262:     rescue
// 263:       nil
// 264:     end
// 265:     return if plist.blank?
// 266:
// 267:     program_location = plist["ProgramArguments"]&.first
// 268:     key = "first ProgramArguments value"
// 269:     if program_location.blank?
// 270:       program_location = plist["Program"]
// 271:       key = "Program"
// 272:     end
// 273:     return if program_location.blank?
// 274:
// 275:     Dir.chdir("/") do
// 276:       unless File.exist?(program_location)
// 277:         return <<~EOS
// 278:           The plist "#{key}" does not exist:
// 279:             #{program_location}
// 280:         EOS
// 281:       end
// 282:
// 283:       return if File.executable?(program_location)
// 284:     end
// 285:
// 286:     <<~EOS
// 287:       The plist "#{key}" is not executable:
// 288:         #{program_location}
// 289:     EOS
// 290:   end
// 291:
// 292:   sig { params(name: String, keg_only: T::Boolean).returns(T.nilable(String)) }
// 293:   def check_python_symlinks(name, keg_only)
// 294:     return unless keg_only
// 295:     return unless name.start_with? "python"
// 296:
// 297:     return if %w[pip3 wheel3].none? do |l|
// 298:       link = HOMEBREW_PREFIX/"bin"/l
// 299:       link.exist? && File.realpath(link).start_with?(HOMEBREW_CELLAR/name)
// 300:     end
// 301:
// 302:     "Python formulae that are keg-only should not create `pip3` and `wheel3` symlinks."
// 303:   end
// 304:
// 305:   sig { params(formula: Formula).returns(T.nilable(String)) }
// 306:   def check_service_command(formula)
// 307:     return unless formula.prefix.directory?
// 308:     return unless formula.service?
// 309:     return unless formula.service.command?
// 310:
// 311:     "Service command does not exist" unless File.exist?(formula.service.command.first)
// 312:   end
// 313:
// 314:   sig { params(formula: Formula).returns(T.nilable(String)) }
// 315:   def check_cpuid_instruction(formula)
// 316:     # Checking for `cpuid` only makes sense on Intel:
// 317:     # https://en.wikipedia.org/wiki/CPUID
// 318:     return unless Hardware::CPU.intel?
// 319:
// 320:     dot_brew_formula = formula.prefix/".brew/#{formula.name}.rb"
// 321:     return unless dot_brew_formula.exist?
// 322:
// 323:     return unless dot_brew_formula.read.include? "ENV.runtime_cpu_detection"
// 324:     return if formula.tap&.audit_exception(:no_cpuid_allowlist, formula.name)
// 325:
// 326:     # macOS `objdump` is a bit slow, so we prioritise llvm's `llvm-objdump` (~5.7x faster)
// 327:     # or binutils' `objdump` (~1.8x faster) if they are installed.
// 328:     if Utils::Path.formula_any_version_installed?("llvm")
// 329:       objdump   = Utils::Path.formula_opt_bin("llvm")/"llvm-objdump"
// 330:     end
// 331:     if Utils::Path.formula_any_version_installed?("binutils")
// 332:       objdump ||= Utils::Path.formula_opt_bin("binutils")/"objdump"
// 333:     end
// 334:     objdump ||= which("objdump")
// 335:     objdump ||= which("objdump", ORIGINAL_PATHS)
// 336:
// 337:     unless objdump
// 338:       return <<~EOS
// 339:         No `objdump` found, so cannot check for a `cpuid` instruction. Install `objdump` with
// 340:           brew install binutils
// 341:       EOS
// 342:     end
// 343:
// 344:     keg = Keg.new(formula.prefix)
// 345:     return if keg.binary_executable_or_library_files.any? do |file|
// 346:       cpuid_instruction?(file, objdump)
// 347:     end
// 348:
// 349:     hardlinks = Set.new
// 350:     return if formula.lib.directory? && formula.lib.find.any? do |pn|
// 351:       next false if pn.symlink? || pn.directory? || pn.extname != ".a"
// 352:       next false unless hardlinks.add? [pn.stat.dev, pn.stat.ino]
// 353:
// 354:       cpuid_instruction?(pn, objdump)
// 355:     end
// 356:
// 357:     "No `cpuid` instruction detected. #{formula} should not use `ENV.runtime_cpu_detection`."
// 358:   end
// 359:
// 360:   sig { params(formula: Formula).returns(T.nilable(String)) }
// 361:   def check_binary_arches(formula)
// 362:     return unless formula.prefix.directory?
// 363:
// 364:     keg = Keg.new(formula.prefix)
// 365:     mismatches = {}
// 366:     keg.binary_executable_or_library_files.each do |file|
// 367:       # we know this has an `arch` method because it's a `MachOShim` or `ELFShim`
// 368:       farch = T.unsafe(file).arch
// 369:       mismatches[file] = farch if farch != Hardware::CPU.arch
// 370:     end
// 371:     return if mismatches.empty?
// 372:
// 373:     compatible_universal_binaries, mismatches = mismatches.partition do |file, arch|
// 374:       arch == :universal && file.archs.include?(Hardware::CPU.arch)
// 375:     end
// 376:     # To prevent transformation into nested arrays
// 377:     compatible_universal_binaries = compatible_universal_binaries.to_h
// 378:     mismatches = mismatches.to_h
// 379:
// 380:     universal_binaries_expected = if (formula_tap = formula.tap).present? && formula_tap.core_tap?
// 381:       formula_name = formula.name
// 382:       # Apply audit exception to versioned formulae too from the unversioned name.
// 383:       formula_name = formula_name.gsub(/@\d+(\.\d+)*$/, "") if formula.versioned_formula?
// 384:       formula_tap.audit_exception(:universal_binary_allowlist, formula_name)
// 385:     else
// 386:       true
// 387:     end
// 388:
// 389:     mismatches_expected = (formula_tap = formula.tap).blank? ||
// 390:                           formula_tap.audit_exception(:mismatched_binary_allowlist, formula.name)
// 391:     mismatches_expected = [mismatches_expected] if mismatches_expected.is_a?(String)
// 392:     if mismatches_expected.is_a?(Array)
// 393:       glob_flags = File::FNM_DOTMATCH | File::FNM_EXTGLOB | File::FNM_PATHNAME
// 394:       mismatches.delete_if do |file, _arch|
// 395:         mismatches_expected.any? { |pattern| file.fnmatch?("#{formula.prefix.realpath}/#{pattern}", glob_flags) }
// 396:       end
// 397:       mismatches_expected = false
// 398:       return if mismatches.empty? && compatible_universal_binaries.empty?
// 399:     end
// 400:
// 401:     return if mismatches.empty? && universal_binaries_expected
// 402:     return if compatible_universal_binaries.empty? && mismatches_expected
// 403:     return if universal_binaries_expected && mismatches_expected
// 404:
// 405:     s = ""
// 406:
// 407:     if mismatches.present? && !mismatches_expected
// 408:       s += <<~EOS
// 409:         Binaries built for a non-native architecture were installed into #{formula}'s prefix.
// 410:         The offending files are:
// 411:           #{mismatches.map { |m| "#{m.first}\t(#{m.last})" } * "\n  "}
// 412:       EOS
// 413:     end
// 414:
// 415:     if compatible_universal_binaries.present? && !universal_binaries_expected
// 416:       s += <<~EOS
// 417:         Unexpected universal binaries were found.
// 418:         The offending files are:
// 419:           #{compatible_universal_binaries.keys * "\n  "}
// 420:       EOS
// 421:     end
// 422:
// 423:     s
// 424:   end
// 425:
// 426:   sig { void }
// 427:   def audit_installed
// 428:     @new_formula ||= T.let(false, T.nilable(T::Boolean))
// 429:
// 430:     problem_if_output(check_manpages)
// 431:     problem_if_output(check_infopages)
// 432:     problem_if_output(check_jars)
// 433:     problem_if_output(check_service_command(formula))
// 434:     problem_if_output(check_non_libraries) if @new_formula
// 435:     problem_if_output(check_non_executables(formula.bin))
// 436:     problem_if_output(check_generic_executables(formula.bin))
// 437:     problem_if_output(check_non_executables(formula.sbin))
// 438:     problem_if_output(check_generic_executables(formula.sbin))
// 439:     problem_if_output(check_easy_install_pth(formula.lib))
// 440:     problem_if_output(check_elisp_dirname(formula.share, formula.name))
// 441:     problem_if_output(check_elisp_root(formula.share, formula.name))
// 442:     problem_if_output(check_python_packages(formula.lib, formula.deps))
// 443:     problem_if_output(check_shim_references(formula.prefix))
// 444:     problem_if_output(check_plist(formula.prefix, formula.launchd_service_path))
// 445:     problem_if_output(check_python_symlinks(formula.name, formula.keg_only?))
// 446:     problem_if_output(check_cpuid_instruction(formula))
// 447:     problem_if_output(check_binary_arches(formula))
// 448:   end
// 449:
// 450:   private
// 451:
// 452:   sig { params(dir: T.any(Pathname, String), pattern: String).returns(T::Array[String]) }
// 453:   def relative_glob(dir, pattern)
// 454:     File.directory?(dir) ? Dir.chdir(dir) { Dir[pattern] } : []
// 455:   end
// 456:
// 457:   sig { params(file: T.any(Pathname, String), objdump: Pathname).returns(T::Boolean) }
// 458:   def cpuid_instruction?(file, objdump)
// 459:     @instruction_column_index ||= T.let({}, T.nilable(T::Hash[Pathname, Integer]))
// 460:     instruction_column_index_objdump = @instruction_column_index[objdump] ||= begin
// 461:       objdump_version = Utils.popen_read(objdump, "--version")
// 462:
// 463:       if objdump_version.include?("LLVM")
// 464:         1 # `llvm-objdump` or macOS `objdump`
// 465:       else
// 466:         2 # GNU Binutils `objdump`
// 467:       end
// 468:     end
// 469:
// 470:     has_cpuid_instruction = T.let(false, T::Boolean)
// 471:     Utils.popen_read(objdump, "--disassemble", file) do |io|
// 472:       until io.eof?
// 473:         instruction = io.readline.split("\t")[instruction_column_index_objdump]&.strip
// 474:         has_cpuid_instruction = instruction == "cpuid" if instruction.present?
// 475:         break if has_cpuid_instruction
// 476:       end
// 477:     end
// 478:
// 479:     has_cpuid_instruction
// 480:   end
// 481: end
// 482:
// 483: require "extend/os/formula_cellar_checks"
