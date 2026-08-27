module language

import brew_runtime

// Translated from Homebrew/brew `language/python.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.major_minor_version(python)` at line 16.
pub fn ruby_python_l16_d1_self_major_minor_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.major_minor_version', ...args)
}

// Ruby method `self.homebrew_site_packages(python = "python3.7")` at line 24.
pub fn ruby_python_l24_d2_self_homebrew_site_packages(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.homebrew_site_packages', ...args)
}

// Ruby method `self.site_packages(python = "python3.7")` at line 29.
pub fn ruby_python_l29_d3_self_site_packages(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.site_packages', ...args)
}

// Ruby method `self.each_python(build, &block)` at line 43.
pub fn ruby_python_l43_d4_self_each_python(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.each_python', ...args)
}

// Ruby method `self.reads_brewed_pth_files?(python)` at line 64.
pub fn ruby_python_l64_d5_self_reads_brewed_pth_files(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.reads_brewed_pth_files?', ...args)
}

// Ruby method `self.user_site_packages(python)` at line 78.
pub fn ruby_python_l78_d6_self_user_site_packages(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.user_site_packages', ...args)
}

// Ruby method `self.in_sys_path?(python, path)` at line 83.
pub fn ruby_python_l83_d7_self_in_sys_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.in_sys_path?', ...args)
}

// Ruby method `python_shebang_rewrite_info(python_path)` at line 107.
pub fn ruby_python_l107_d8_python_shebang_rewrite_info(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('python_shebang_rewrite_info', ...args)
}

// Ruby method `detected_python_shebang(formula = T.cast(self, Formula), use_python_from_path: false)` at line 116.
pub fn ruby_python_l116_d9_detected_python_shebang(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('detected_python_shebang', ...args)
}

// Ruby method `virtualenv_create(venv_root, python = "python", formula = T.cast(self, Formula),` at line 159.
pub fn ruby_python_l159_d10_virtualenv_create(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('virtualenv_create', ...args)
}

// Ruby method `needs_python?(python)` at line 205.
pub fn ruby_python_l205_d11_needs_python(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('needs_python?', ...args)
}

// Ruby method `virtualenv_install_with_resources(using: nil, system_site_packages: true, without_pip: true,` at line 229.
pub fn ruby_python_l229_d12_virtualenv_install_with_resources(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('virtualenv_install_with_resources', ...args)
}

// Ruby method `python_names` at line 261.
pub fn ruby_python_l261_d13_python_names(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('python_names', ...args)
}

// Ruby method `slice_resources!(resources_hash, resource_names)` at line 273.
pub fn ruby_python_l273_d14_slice_resources(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('slice_resources!', ...args)
}

// Ruby method `initialize(formula, venv_root, python)` at line 293.
pub fn ruby_python_l293_d15_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `root` at line 300.
pub fn ruby_python_l300_d16_root(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('root', ...args)
}

// Ruby method `site_packages` at line 305.
pub fn ruby_python_l305_d17_site_packages(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('site_packages', ...args)
}

// Ruby method `create(system_site_packages: true, without_pip: true)` at line 313.
pub fn ruby_python_l313_d18_create(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('create', ...args)
}

// Ruby method `pip_install(targets, build_isolation: true)` at line 383.
pub fn ruby_python_l383_d19_pip_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pip_install', ...args)
}

// Ruby method `pip_install_and_link(targets, link_manpages: true, build_isolation: true)` at line 411.
pub fn ruby_python_l411_d20_pip_install_and_link(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pip_install_and_link', ...args)
}

// Ruby method `do_install(targets, build_isolation: true)` at line 437.
pub fn ruby_python_l437_d21_do_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do_install', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils"
// 5: require "utils/output"
// 6: require "utils/path"
// 7:
// 8: module Language
// 9:   # Helper functions for Python formulae.
// 10:   #
// 11:   # @api public
// 12:   module Python
// 13:     extend ::Utils::Output::Mixin
// 14:
// 15:     sig { params(python: T.any(String, Pathname)).returns(T.nilable(Version)) }
// 16:     def self.major_minor_version(python)
// 17:       version = `#{python} --version 2>&1`.chomp[/(\d\.\d+)/, 1]
// 18:       return unless version
// 19:
// 20:       Version.new(version)
// 21:     end
// 22:
// 23:     sig { params(python: T.any(String, Pathname)).returns(Pathname) }
// 24:     def self.homebrew_site_packages(python = "python3.7")
// 25:       HOMEBREW_PREFIX/site_packages(python)
// 26:     end
// 27:
// 28:     sig { params(python: T.any(String, Pathname)).returns(String) }
// 29:     def self.site_packages(python = "python3.7")
// 30:       if (python == "pypy") || (python == "pypy3")
// 31:         "site-packages"
// 32:       else
// 33:         "lib/python#{major_minor_version python}/site-packages"
// 34:       end
// 35:     end
// 36:
// 37:     sig {
// 38:       params(
// 39:         build: T.any(BuildOptions, Tab),
// 40:         block: T.nilable(T.proc.params(python: String, version: T.nilable(Version)).void),
// 41:       ).void
// 42:     }
// 43:     def self.each_python(build, &block)
// 44:       original_pythonpath = ENV.fetch("PYTHONPATH", nil)
// 45:       pythons = { "python@3" => "python3",
// 46:                   "pypy"     => "pypy",
// 47:                   "pypy3"    => "pypy3" }
// 48:       pythons.each do |python_formula, python|
// 49:         python_formula = Formulary.factory(python_formula)
// 50:         next if build.without? python_formula.to_s
// 51:
// 52:         version = major_minor_version python
// 53:         ENV["PYTHONPATH"] = if python_formula.latest_version_installed?
// 54:           nil
// 55:         else
// 56:           homebrew_site_packages(python).to_s
// 57:         end
// 58:         block&.call python, version
// 59:       end
// 60:       ENV["PYTHONPATH"] = original_pythonpath
// 61:     end
// 62:
// 63:     sig { params(python: T.any(String, Pathname)).returns(T::Boolean) }
// 64:     def self.reads_brewed_pth_files?(python)
// 65:       return false unless homebrew_site_packages(python).directory?
// 66:       return false unless homebrew_site_packages(python).writable?
// 67:
// 68:       probe_file = homebrew_site_packages(python)/"homebrew-pth-probe.pth"
// 69:       begin
// 70:         probe_file.atomic_write("import site; site.homebrew_was_here = True")
// 71:         with_homebrew_path { quiet_system python, "-c", "import site; assert(site.homebrew_was_here)" }
// 72:       ensure
// 73:         probe_file.unlink if probe_file.exist?
// 74:       end
// 75:     end
// 76:
// 77:     sig { params(python: T.any(String, Pathname)).returns(Pathname) }
// 78:     def self.user_site_packages(python)
// 79:       Pathname.new(`#{python} -c "import site; print(site.getusersitepackages())"`.chomp)
// 80:     end
// 81:
// 82:     sig { params(python: T.any(String, Pathname), path: T.any(String, Pathname)).returns(T::Boolean) }
// 83:     def self.in_sys_path?(python, path)
// 84:       script = <<~PYTHON
// 85:         import os, sys
// 86:         [os.path.realpath(p) for p in sys.path].index(os.path.realpath("#{path}"))
// 87:       PYTHON
// 88:       quiet_system python, "-c", script
// 89:     end
// 90:
// 91:     # Mixin module for {Formula} adding shebang rewrite features.
// 92:     module Shebang
// 93:       extend T::Helpers
// 94:
// 95:       requires_ancestor { Formula }
// 96:
// 97:       module_function
// 98:
// 99:       # A regex to match potential shebang permutations.
// 100:       PYTHON_SHEBANG_REGEX = %r{\A#! ?(?:/usr/bin/(?:env )?)?python(?:[23](?:\.\d{1,2})?)?( |$)}
// 101:
// 102:       # The length of the longest shebang matching `SHEBANG_REGEX`.
// 103:       PYTHON_SHEBANG_MAX_LENGTH = T.let("#! /usr/bin/env pythonx.yyy ".length, Integer)
// 104:
// 105:       # @private
// 106:       sig { params(python_path: T.any(String, Pathname)).returns(Utils::Shebang::RewriteInfo) }
// 107:       def python_shebang_rewrite_info(python_path)
// 108:         Utils::Shebang::RewriteInfo.new(
// 109:           PYTHON_SHEBANG_REGEX,
// 110:           PYTHON_SHEBANG_MAX_LENGTH,
// 111:           "#{python_path}\\1",
// 112:         )
// 113:       end
// 114:
// 115:       sig { params(formula: Formula, use_python_from_path: T::Boolean).returns(Utils::Shebang::RewriteInfo) }
// 116:       def detected_python_shebang(formula = T.cast(self, Formula), use_python_from_path: false)
// 117:         python_path = if use_python_from_path
// 118:           "/usr/bin/env python3"
// 119:         else
// 120:           python_deps = formula.deps.select(&:required?).map(&:name).grep(/^python(@.+)?$/)
// 121:           raise ShebangDetectionError.new("Python", "formula does not depend on Python") if python_deps.empty?
// 122:           if python_deps.length > 1
// 123:             raise ShebangDetectionError.new("Python", "formula has multiple Python dependencies")
// 124:           end
// 125:
// 126:           python_dep = python_deps.first
// 127:           Utils::Path.formula_opt_bin(python_dep)/python_dep.sub("@", "")
// 128:         end
// 129:
// 130:         python_shebang_rewrite_info(python_path)
// 131:       end
// 132:     end
// 133:
// 134:     # Mixin module for {Formula} adding virtualenv support features.
// 135:     module Virtualenv
// 136:       extend T::Helpers
// 137:
// 138:       requires_ancestor { Formula }
// 139:
// 140:       # Instantiates, creates and yields a {Virtualenv} object for use from
// 141:       # {Formula#install}, which provides helper methods for instantiating and
// 142:       # installing packages into a Python virtualenv.
// 143:       #
// 144:       # @param venv_root [Pathname, String] the path to the root of the virtualenv
// 145:       #   (often `libexec/"venv"`)
// 146:       # @param python [String, Pathname] which interpreter to use (e.g. `"python3"`
// 147:       #   or `"python3.x"`)
// 148:       # @param formula [Formula] the active {Formula}
// 149:       # @return [Virtualenv] a {Virtualenv} instance
// 150:       sig {
// 151:         params(
// 152:           venv_root:            T.any(String, Pathname),
// 153:           python:               T.any(String, Pathname),
// 154:           formula:              Formula,
// 155:           system_site_packages: T::Boolean,
// 156:           without_pip:          T::Boolean,
// 157:         ).returns(Virtualenv)
// 158:       }
// 159:       def virtualenv_create(venv_root, python = "python", formula = T.cast(self, Formula),
// 160:                             system_site_packages: true, without_pip: true)
// 161:         # Limit deprecation to 3.12+ for now (or if we can't determine the version).
// 162:         # Some used this argument for `setuptools`, which we no longer bundle since 3.12.
// 163:         unless without_pip
// 164:           python_version = Language::Python.major_minor_version(python)
// 165:           if python_version.nil? || python_version.null? || python_version >= "3.12"
// 166:             raise ArgumentError, "virtualenv_create's without_pip is deprecated starting with Python 3.12"
// 167:           end
// 168:         end
// 169:
// 170:         ENV.refurbish_args
// 171:         venv = Virtualenv.new formula, venv_root, python
// 172:         venv.create(system_site_packages:, without_pip:)
// 173:
// 174:         # Find any Python bindings provided by recursive dependencies
// 175:         pth_contents = []
// 176:         formula.recursive_dependencies do |dependent, dep|
// 177:           next Dependable::PRUNE if dep.build? || dep.test?
// 178:           # Apply default filter
// 179:           next Dependable::PRUNE if (dep.optional? || dep.recommended?) && !T.cast(dependent,
// 180:                                                                                    Formula).build.with?(dep)
// 181:           # Do not add the main site-package provided by the brewed
// 182:           # Python formula, to keep the virtual-env's site-package pristine
// 183:           next Dependable::PRUNE if python_names.include? dep.name
// 184:           # Skip uses_from_macos dependencies as these imply no Python bindings
// 185:           next Dependable::PRUNE if dep.uses_from_macos?
// 186:
// 187:           dep_site_packages = dep.to_formula.opt_prefix/Language::Python.site_packages(python)
// 188:           next Dependable::PRUNE unless dep_site_packages.exist?
// 189:
// 190:           pth_contents << "import site; site.addsitedir('#{dep_site_packages}')\n"
// 191:           nil # Return nil to satisfy T.nilable(Symbol) block sig (Array from << would violate it).
// 192:         end
// 193:         (venv.site_packages/"homebrew_deps.pth").write pth_contents.join unless pth_contents.empty?
// 194:
// 195:         venv
// 196:       end
// 197:
// 198:       # Returns true if a formula option for the specified python is currently
// 199:       # active or if the specified python is required by the formula. Valid
// 200:       # inputs are `"python"`, `"python2"` and `:python3`. Note that
// 201:       # `"with-python"`, `"without-python"`, `"with-python@2"` and `"without-python@2"`
// 202:       # formula options are handled correctly even if not associated with any
// 203:       # corresponding depends_on statement.
// 204:       sig { params(python: String).returns(T::Boolean) }
// 205:       def needs_python?(python)
// 206:         return true if build.with?(python)
// 207:
// 208:         (requirements.to_a | deps).any? { |r| Utils.name_from_full_name(r.name) == python && r.required? }
// 209:       end
// 210:
// 211:       # Helper method for the common case of installing a Python application.
// 212:       # Creates a virtualenv in `libexec`, installs all `resource`s defined
// 213:       # on the formula and then installs the formula. An options hash may be
// 214:       # passed (e.g. `:using => "python"`) to override the default, guessed
// 215:       # formula preference for python or python@x.y, or to resolve an ambiguous
// 216:       # case where it's not clear whether python or python@x.y should be the
// 217:       # default guess.
// 218:       sig {
// 219:         params(
// 220:           using:                T.nilable(String),
// 221:           system_site_packages: T::Boolean,
// 222:           without_pip:          T::Boolean,
// 223:           link_manpages:        T::Boolean,
// 224:           without:              T.nilable(T.any(String, T::Array[String])),
// 225:           start_with:           T.nilable(T.any(String, T::Array[String])),
// 226:           end_with:             T.nilable(T.any(String, T::Array[String])),
// 227:         ).returns(Virtualenv)
// 228:       }
// 229:       def virtualenv_install_with_resources(using: nil, system_site_packages: true, without_pip: true,
// 230:                                             link_manpages: true, without: nil, start_with: nil, end_with: nil)
// 231:         python = using
// 232:         if python.nil?
// 233:           wanted = python_names.select { |py| needs_python?(py) }
// 234:           raise FormulaUnknownPythonError, self if wanted.empty?
// 235:           raise FormulaAmbiguousPythonError, self if wanted.size > 1
// 236:
// 237:           python = wanted.fetch(0)
// 238:           python = "python3" if python == "python"
// 239:         end
// 240:
// 241:         venv_resources = if without.nil? && start_with.nil? && end_with.nil?
// 242:           resources
// 243:         else
// 244:           remaining_resources = resources.to_h { |resource| [resource.name, resource] }
// 245:
// 246:           slice_resources!(remaining_resources, Array(without))
// 247:           start_with_resources = slice_resources!(remaining_resources, Array(start_with))
// 248:           end_with_resources = slice_resources!(remaining_resources, Array(end_with))
// 249:
// 250:           start_with_resources + remaining_resources.values + end_with_resources
// 251:         end
// 252:
// 253:         venv = virtualenv_create(libexec, python.delete("@"), system_site_packages:,
// 254:                                                               without_pip:)
// 255:         venv.pip_install venv_resources
// 256:         venv.pip_install_and_link(T.must(buildpath), link_manpages:)
// 257:         venv
// 258:       end
// 259:
// 260:       sig { returns(T::Array[String]) }
// 261:       def python_names
// 262:         %w[python python3 pypy pypy3] + Formula.names.select { |name| name.start_with? "python@" }
// 263:       end
// 264:
// 265:       private
// 266:
// 267:       sig {
// 268:         params(
// 269:           resources_hash: T::Hash[String, Resource],
// 270:           resource_names: T::Array[String],
// 271:         ).returns(T::Array[Resource])
// 272:       }
// 273:       def slice_resources!(resources_hash, resource_names)
// 274:         resource_names.map do |resource_name|
// 275:           resources_hash.delete(resource_name) do
// 276:             raise ArgumentError, "Resource \"#{resource_name}\" is not defined in formula or is already used."
// 277:           end
// 278:         end
// 279:       end
// 280:
// 281:       # Convenience wrapper for creating and installing packages into Python
// 282:       # virtualenvs.
// 283:       class Virtualenv
// 284:         # Initializes a Virtualenv instance. This does not create the virtualenv
// 285:         # on disk; {#create} does that.
// 286:         #
// 287:         # @param formula [Formula] the active {Formula}
// 288:         # @param venv_root [Pathname, String] the path to the root of the
// 289:         #   virtualenv
// 290:         # @param python [String, Pathname] which interpreter to use, e.g.
// 291:         #   "python" or "python2"
// 292:         sig { params(formula: Formula, venv_root: T.any(String, Pathname), python: T.any(String, Pathname)).void }
// 293:         def initialize(formula, venv_root, python)
// 294:           @formula = formula
// 295:           @venv_root = T.let(Pathname(venv_root), Pathname)
// 296:           @python = python
// 297:         end
// 298:
// 299:         sig { returns(Pathname) }
// 300:         def root
// 301:           @venv_root
// 302:         end
// 303:
// 304:         sig { returns(Pathname) }
// 305:         def site_packages
// 306:           @venv_root/Language::Python.site_packages(@python)
// 307:         end
// 308:
// 309:         # Obtains a copy of the virtualenv library and creates a new virtualenv on disk.
// 310:         #
// 311:         # @return [void]
// 312:         sig { params(system_site_packages: T::Boolean, without_pip: T::Boolean).void }
// 313:         def create(system_site_packages: true, without_pip: true)
// 314:           return if (@venv_root/"bin/python").exist?
// 315:
// 316:           args = ["-m", "venv"]
// 317:           args << "--system-site-packages" if system_site_packages
// 318:           args << "--without-pip" if without_pip
// 319:           @formula.system @python, *args, @venv_root
// 320:
// 321:           # Robustify symlinks to survive python patch upgrades
// 322:           @venv_root.find do |f|
// 323:             next unless f.symlink?
// 324:             next unless f.readlink.expand_path.to_s.start_with? HOMEBREW_CELLAR
// 325:
// 326:             rp = f.realpath.to_s
// 327:             version = rp.match %r{^#{HOMEBREW_CELLAR}/python@(.*?)/}o
// 328:             version = "@#{version.captures.first}" unless version.nil?
// 329:
// 330:             new_target = rp.sub(
// 331:               %r{#{HOMEBREW_CELLAR}/python#{version}/[^/]+},
// 332:               Utils::Path.formula_opt_prefix("python#{version}").to_s,
// 333:             )
// 334:             f.unlink
// 335:             f.make_symlink new_target
// 336:           end
// 337:
// 338:           Pathname.glob(@venv_root/"lib/python*/orig-prefix.txt").each do |prefix_file|
// 339:             prefix_path = prefix_file.read
// 340:
// 341:             version = prefix_path.match %r{^#{HOMEBREW_CELLAR}/python@(.*?)/}o
// 342:             version = "@#{version.captures.first}" unless version.nil?
// 343:
// 344:             prefix_path.sub!(
// 345:               %r{^#{HOMEBREW_CELLAR}/python#{version}/[^/]+},
// 346:               Utils::Path.formula_opt_prefix("python#{version}").to_s,
// 347:             )
// 348:             prefix_file.atomic_write prefix_path
// 349:           end
// 350:
// 351:           # Reduce some differences between macOS and Linux venv
// 352:           lib64 = @venv_root/"lib64"
// 353:           lib64.make_symlink "lib" unless lib64.exist?
// 354:           if (cfg_file = @venv_root/"pyvenv.cfg").exist?
// 355:             cfg = cfg_file.read
// 356:             framework = "Frameworks/Python.framework/Versions"
// 357:             cfg.match(%r{= *(#{HOMEBREW_CELLAR}/(python@[\d.]+)/[^/]+(?:/#{framework}/[\d.]+)?/bin)}) do |match|
// 358:               cfg.sub! match[1].to_s, Utils::Path.formula_opt_bin(T.must(match[2])).to_s
// 359:               cfg_file.atomic_write cfg
// 360:             end
// 361:           end
// 362:
// 363:           # Remove unnecessary activate scripts
// 364:           (@venv_root/"bin").glob("[Aa]ctivate*").map(&:unlink)
// 365:         end
// 366:
// 367:         # Installs packages represented by `targets` into the virtualenv.
// 368:         #
// 369:         # @param targets [String, Pathname, Resource,
// 370:         #   Array<String, Pathname, Resource>] (A) token(s) passed to `pip`
// 371:         #   representing the object to be installed. This can be a directory
// 372:         #   containing a setup.py, a {Resource} which will be staged and
// 373:         #   installed, or a package identifier to be fetched from PyPI.
// 374:         #   Multiline strings are allowed and treated as though they represent
// 375:         #   the contents of a `requirements.txt`.
// 376:         # @return [void]
// 377:         sig {
// 378:           params(
// 379:             targets:         T.any(String, Pathname, Resource, T::Array[T.any(String, Pathname, Resource)]),
// 380:             build_isolation: T::Boolean,
// 381:           ).void
// 382:         }
// 383:         def pip_install(targets, build_isolation: true)
// 384:           targets = Array(targets)
// 385:           targets.each do |t|
// 386:             if t.is_a?(Resource)
// 387:               t.stage do
// 388:                 target = Pathname.pwd
// 389:                 target /= t.downloader.basename if t.url&.match?("[.-]py3[^-]*-none-any.whl$")
// 390:                 do_install(target, build_isolation:)
// 391:               end
// 392:             else
// 393:               t = t.lines.map(&:strip) if t.is_a?(String) && t.include?("\n")
// 394:               do_install(t, build_isolation:)
// 395:             end
// 396:           end
// 397:         end
// 398:
// 399:         # Installs packages represented by `targets` into the virtualenv, but
// 400:         # unlike {#pip_install} also links new scripts to {Formula#bin}.
// 401:         #
// 402:         # @param (see #pip_install)
// 403:         # @return (see #pip_install)
// 404:         sig {
// 405:           params(
// 406:             targets:         T.any(String, Pathname, Resource, T::Array[T.any(String, Pathname, Resource)]),
// 407:             link_manpages:   T::Boolean,
// 408:             build_isolation: T::Boolean,
// 409:           ).void
// 410:         }
// 411:         def pip_install_and_link(targets, link_manpages: true, build_isolation: true)
// 412:           bin_before = Dir[@venv_root/"bin/*"].to_set
// 413:           man_before = Dir[@venv_root/"share/man/man*/*"].to_set if link_manpages
// 414:
// 415:           pip_install(targets, build_isolation:)
// 416:
// 417:           bin_after = Dir[@venv_root/"bin/*"].to_set
// 418:           bin_to_link = (bin_after - bin_before).to_a
// 419:           @formula.bin.install_symlink(bin_to_link)
// 420:           return unless link_manpages
// 421:
// 422:           man_after = Dir[@venv_root/"share/man/man*/*"].to_set
// 423:           man_to_link = (man_after - man_before).to_a
// 424:           man_to_link.each do |manpage|
// 425:             (@formula.man/Pathname.new(manpage).dirname.basename).install_symlink manpage
// 426:           end
// 427:         end
// 428:
// 429:         private
// 430:
// 431:         sig {
// 432:           params(
// 433:             targets:         T.any(String, Pathname, T::Array[T.any(String, Pathname)]),
// 434:             build_isolation: T::Boolean,
// 435:           ).void
// 436:         }
// 437:         def do_install(targets, build_isolation: true)
// 438:           targets = Array(targets)
// 439:           args = @formula.std_pip_args(prefix: false, build_isolation:)
// 440:           @formula.system @python, "-m", "pip", "--python=#{@venv_root}/bin/python", "install", *args, *targets
// 441:         end
// 442:       end
// 443:     end
// 444:   end
// 445: end
