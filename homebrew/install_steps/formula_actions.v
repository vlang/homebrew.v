module install_steps

import brew_runtime
import homebrew

fn formula_action_nil_value() brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'NilClass'
		repr: 'nil'
	}
}

fn formula_action_error_value(message string) brew_runtime.Value {
	return brew_runtime.structured_value('ArgumentError', message, {
		'message': message
	})
}

fn formula_action_run(kind string, args []brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return formula_action_error_value('${kind} requires a Runner receiver')
	}
	mut fields := map[string]brew_runtime.Value{}
	fields['type'] = brew_runtime.string_value(kind)
	if kind == 'install_gzipped_executable' {
		if args.len < 2 {
			return formula_action_error_value('run_install_gzipped_executable requires a step')
		}
		fields = args[1].map_data.clone()
		fields['type'] = brew_runtime.string_value(kind)
	} else if kind == 'bootstrap_pypy' {
		if args.len < 2 {
			return formula_action_error_value('run_bootstrap_pypy requires an ABI version')
		}
		fields['abi_version'] = brew_runtime.string_value(args[1].repr)
	}
	return homebrew.ruby_install_steps_l954_d75_run_install_step(args[0], brew_runtime.map_value(fields))
}

// Translated from Homebrew/brew `install_steps/formula_actions.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run_configure_gcc_runtime` at line 10.
pub fn ruby_formula_actions_l10_d1_run_configure_gcc_runtime(args ...brew_runtime.Value) brew_runtime.Value {
	return formula_action_run('configure_gcc_runtime', args)
}

// Ruby method `run_install_gzipped_executable(step)` at line 66.
pub fn ruby_formula_actions_l66_d2_run_install_gzipped_executable(args ...brew_runtime.Value) brew_runtime.Value {
	return formula_action_run('install_gzipped_executable', args)
}

// Ruby method `run_configure_glibc_runtime` at line 90.
pub fn ruby_formula_actions_l90_d3_run_configure_glibc_runtime(args ...brew_runtime.Value) brew_runtime.Value {
	return formula_action_run('configure_glibc_runtime', args)
}

// Ruby method `run_configure_clang_system` at line 120.
pub fn ruby_formula_actions_l120_d4_run_configure_clang_system(args ...brew_runtime.Value) brew_runtime.Value {
	return formula_action_run('configure_clang_system', args)
}

// Ruby method `run_configure_php` at line 141.
pub fn ruby_formula_actions_l141_d5_run_configure_php(args ...brew_runtime.Value) brew_runtime.Value {
	return formula_action_run('configure_php', args)
}

// Ruby method `run_bootstrap_cpython` at line 200.
pub fn ruby_formula_actions_l200_d6_run_bootstrap_cpython(args ...brew_runtime.Value) brew_runtime.Value {
	return formula_action_run('bootstrap_cpython', args)
}

// Ruby method `make_cpython_venv_activation_scripts_writable(lib_cellar)` at line 273.
pub fn ruby_formula_actions_l273_d7_make_cpython_venv_activation_scripts_writable(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return formula_action_error_value('make_cpython_venv_activation_scripts_writable requires lib_cellar')
	}
	homebrew.install_steps_make_cpython_venv_activation_scripts_writable(args[1].repr) or {
		return formula_action_error_value(err.msg())
	}
	return formula_action_nil_value()
}

// Ruby method `run_bootstrap_pypy(abi_version)` at line 280.
pub fn ruby_formula_actions_l280_d8_run_bootstrap_pypy(args ...brew_runtime.Value) brew_runtime.Value {
	return formula_action_run('bootstrap_pypy', args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module InstallSteps
// 6:     class Runner
// 7:       private
// 8:
// 9:       sig { void }
// 10:       def run_configure_gcc_runtime
// 11:         return unless Homebrew::SimulateSystem.simulating_or_running_on_linux?
// 12:
// 13:         version_major = context_version_major
// 14:         raise ArgumentError, "GCC runtime configuration requires a version" if version_major.nil?
// 15:
// 16:         gcc = context_path("bin")/"gcc-#{version_major}"
// 17:         libgcc = Pathname(run_command_output(gcc, "-print-libgcc-file-name").strip).dirname
// 18:         require "utils/path"
// 19:
// 20:         glibc_installed = Utils::Path.formula_any_version_installed?("glibc")
// 21:         glibc_lib = Utils::Path.formula_opt_lib("glibc")
// 22:         crtdir = if glibc_installed
// 23:           glibc_lib
// 24:         else
// 25:           Pathname(run_command_output("/usr/bin/cc", "-print-file-name=crti.o").strip).dirname
// 26:         end
// 27:         FileUtils.ln_sf Dir[crtdir/"*crt?.o"], libgcc
// 28:
// 29:         specs = libgcc/"specs"
// 30:         ohai "Creating the GCC specs file: #{specs}"
// 31:         FileUtils.rm_f ["#{specs}.orig", specs]
// 32:         system_header_dirs = [HOMEBREW_PREFIX/"include"]
// 33:         if glibc_installed
// 34:           system_header_dirs << Utils::Path.formula_opt_include("glibc")
// 35:         else
// 36:           target = run_command_output(gcc, "-print-multiarch").strip
// 37:           system_header_dirs += [Pathname("/usr/include")/target, Pathname("/usr/include")]
// 38:         end
// 39:
// 40:         specs_string = run_command_output(gcc, "-dumpspecs")
// 41:         Pathname("#{specs}.orig").write specs_string
// 42:         libdir = if context_name == "gcc"
// 43:           HOMEBREW_PREFIX/"lib/gcc/current"
// 44:         else
// 45:           HOMEBREW_PREFIX/"lib/gcc"/version_major
// 46:         end
// 47:         link_libgcc = glibc_installed ? "-nostdlib -L#{libgcc} -L#{glibc_lib}" : "+"
// 48:         homebrew_rpath = version_major.to_i >= 11
// 49:         specs_string += <<~EOS
// 50:           *cpp_unique_options:
// 51:           + -isysroot #{HOMEBREW_PREFIX}/nonexistent #{system_header_dirs.map { |p| "-idirafter #{p}" }.join(" ")}
// 52:
// 53:           *link_libgcc:
// 54:           #{link_libgcc} -L#{libdir} -L#{HOMEBREW_PREFIX}/lib
// 55:
// 56:           *link:
// 57:           + --dynamic-linker #{HOMEBREW_PREFIX}/lib/ld.so -rpath #{libdir}#{" -rpath #{HOMEBREW_PREFIX}/lib" unless homebrew_rpath}
// 58:
// 59:           #{"*homebrew_rpath:\n-rpath #{HOMEBREW_PREFIX}/lib\n" if homebrew_rpath}
// 60:         EOS
// 61:         specs_string.gsub!(" %o ", "\\0%(homebrew_rpath) ") if homebrew_rpath
// 62:         specs.write specs_string
// 63:       end
// 64:
// 65:       sig { params(step: Step).void }
// 66:       def run_install_gzipped_executable(step)
// 67:         source = resolve_path(step_path(step, "source"))
// 68:         return unless source.exist?
// 69:
// 70:         require "zlib"
// 71:
// 72:         target = resolve_path(step_path(step, "target"))
// 73:         target.dirname.mkpath
// 74:         temporary_target = target.dirname/".#{target.basename}.install-step"
// 75:         FileUtils.rm_f temporary_target
// 76:         begin
// 77:           Zlib::GzipReader.open(source.to_s) do |gzip|
// 78:             IO.copy_stream(gzip, temporary_target.to_s)
// 79:           end
// 80:           FileUtils.rm_f target
// 81:           FileUtils.mv temporary_target, target
// 82:           source.unlink
// 83:         ensure
// 84:           FileUtils.rm_f temporary_target
// 85:         end
// 86:         target.chmod 0755
// 87:       end
// 88:
// 89:       sig { void }
// 90:       def run_configure_glibc_runtime
// 91:         (context_path("lib")/"locale").mkpath
// 92:         legacy_formula = context_name != "glibc"
// 93:         locales = ENV.filter_map do |key, value|
// 94:           next unless key.match?(legacy_formula ? /^LANG$|^LC_/ : /^HOMEBREW_LANG$|^LANG$|^LC_/)
// 95:           next if value == "C" || (legacy_formula && value.start_with?("C."))
// 96:
// 97:           value
// 98:         end
// 99:         locales = (locales + ["en_US.UTF-8"]).sort.uniq
// 100:         ohai "Installing locale data for #{locales.join(" ")}"
// 101:         locales.each do |locale|
// 102:           lang, charmap = locale.split(".", 2)
// 103:           next if lang.nil?
// 104:
// 105:           if charmap.present?
// 106:             charmap = "UTF-8" if charmap == "utf8"
// 107:             run_command context_path("bin")/"localedef", "-i", lang, "-f", charmap, locale
// 108:           else
// 109:             run_command context_path("bin")/"localedef", "-i", lang, locale
// 110:           end
// 111:         end
// 112:
// 113:         [[Pathname("/etc/localtime"), context_path("etc")/"localtime"],
// 114:          [Pathname("/usr/share/zoneinfo"), context_path("share")/"zoneinfo"]].each do |source, target|
// 115:           File.symlink source, target if source.exist? && !target.exist?
// 116:         end
// 117:       end
// 118:
// 119:       sig { void }
// 120:       def run_configure_clang_system
// 121:         return unless Homebrew::SimulateSystem.simulating_or_running_on_macos?
// 122:
// 123:         macos_version = MacOS.version
// 124:         kernel_version = OS.kernel_version.major
// 125:         raise ArgumentError, "Clang system configuration requires a kernel version" if kernel_version.nil?
// 126:
// 127:         kernel_version = kernel_version.to_s
// 128:         arch = Hardware::CPU.arch
// 129:         config_dir = context_path("etc")/"clang"
// 130:         return if [:arm64, :x86_64, :aarch64, arch].uniq.product(
// 131:           ["darwin#{kernel_version}", "macosx#{macos_version}"],
// 132:         ).all? do |target_arch, system|
// 133:           (config_dir/"#{target_arch}-apple-#{system}.cfg").exist?
// 134:         end
// 135:
// 136:         require "utils/clang"
// 137:         Utils::Clang.write_system_config_files(config_dir:, macos_version:, kernel_version:, arch:)
// 138:       end
// 139:
// 140:       sig { void }
// 141:       def run_configure_php
// 142:         pear_prefix = context_path("pkgshare")/"pear"
// 143:         channels = [pear_prefix/".channels", pear_prefix/".channels/.alias"]
// 144:         channels.select(&:directory?).each { |directory| FileUtils.chmod 0755, directory }
// 145:         pear_files = %w[.depdblock .filemap .depdb .lock].map { |file| pear_prefix/file }.select(&:file?)
// 146:         pear_files.concat(channels.flat_map do |directory|
// 147:           directory.directory? ? directory.children.select(&:file?) : []
// 148:         end)
// 149:         FileUtils.chmod 0644, pear_files
// 150:
// 151:         pecl_path = HOMEBREW_PREFIX/"lib/php/pecl"
// 152:         pecl_path.mkpath
// 153:         prefix_pecl = context_path("prefix")/"pecl"
// 154:         prefix_pecl.unlink if prefix_pecl.symlink?
// 155:         File.symlink pecl_path, prefix_pecl unless prefix_pecl.exist?
// 156:         php_basename = File.basename(run_command_output(context_path("bin")/"php-config", "--extension-dir").strip)
// 157:         (pecl_path/php_basename).mkpath
// 158:
// 159:         version_major_minor = context_version_major_minor
// 160:         raise ArgumentError, "PHP configuration requires a version" if version_major_minor.nil?
// 161:
// 162:         pear_dir = (context_name == "php") ? "pear" : "pear@#{version_major_minor}"
// 163:         pear_path = HOMEBREW_PREFIX/"share"/pear_dir
// 164:         FileUtils.cp_r "#{pear_prefix}/.", pear_path
// 165:         php_ext_dir = context_path("opt_prefix")/"lib/php"/php_basename
// 166:         {
// 167:           "php_ini"  => context_path("etc")/"php/#{version_major_minor}/php.ini",
// 168:           "php_dir"  => pear_path,
// 169:           "doc_dir"  => pear_path/"doc",
// 170:           "ext_dir"  => pecl_path/php_basename,
// 171:           "bin_dir"  => context_path("opt_prefix")/"bin",
// 172:           "data_dir" => pear_path/"data",
// 173:           "cfg_dir"  => pear_path/"cfg",
// 174:           "www_dir"  => pear_path/"htdocs",
// 175:           "man_dir"  => HOMEBREW_PREFIX/"share/man",
// 176:           "test_dir" => pear_path/"test",
// 177:           "php_bin"  => context_path("opt_prefix")/"bin/php",
// 178:         }.each do |key, value|
// 179:           value.mkpath if /(?<!bin|man)_dir$/.match?(key)
// 180:           run_command context_path("bin")/"pear", "config-set", key, value, "system"
// 181:         end
// 182:         run_command context_path("bin")/"pear", "update-channels"
// 183:         return if context_name == "php"
// 184:
// 185:         ext_config_path = context_path("etc")/"php/#{version_major_minor}/conf.d/ext-opcache.ini"
// 186:         ext_config_path.dirname.mkpath
// 187:         zend_extension_line = %Q(zend_extension="#{php_ext_dir}/opcache.so")
// 188:         if ext_config_path.exist?
// 189:           require "utils/inreplace"
// 190:           Utils::Inreplace.inreplace(ext_config_path, /^\s*zend_extension\s*=.*$/, zend_extension_line)
// 191:         else
// 192:           ext_config_path.atomic_write <<~INI
// 193:             [opcache]
// 194:             #{zend_extension_line}
// 195:           INI
// 196:         end
// 197:       end
// 198:
// 199:       sig { void }
// 200:       def run_bootstrap_cpython
// 201:         ENV.delete("PYTHONPATH")
// 202:         version_major_minor = context_version_major_minor
// 203:         raise ArgumentError, "CPython bootstrap requires a version" if version_major_minor.nil?
// 204:
// 205:         site_packages = HOMEBREW_PREFIX/"lib/python#{version_major_minor}/site-packages"
// 206:         lib_cellar = if Homebrew::SimulateSystem.simulating_or_running_on_macos?
// 207:           context_path("frameworks")/"Python.framework/Versions/#{version_major_minor}/lib/python#{version_major_minor}"
// 208:         else
// 209:           context_path("lib")/"python#{version_major_minor}"
// 210:         end
// 211:         site_packages_cellar = lib_cellar/"site-packages"
// 212:         site_packages.mkpath
// 213:         FileUtils.rm_rf site_packages_cellar
// 214:         site_packages_cellar.parent.install_symlink site_packages
// 215:         FileUtils.rm_r Dir[site_packages/"sitecustomize.py[co]"], force: true
// 216:         %w[setuptools distribute pip wheel].each do |package|
// 217:           FileUtils.rm_r Dir[site_packages/"#{package}[-_.][0-9]*", site_packages/package], force: true
// 218:         end
// 219:
// 220:         python = context_path("bin")/"python#{version_major_minor}"
// 221:         run_command python, "-Im", "ensurepip"
// 222:         bundled = lib_cellar/"ensurepip/_bundled"
// 223:         wheels = [
// 224:           bundled/"setuptools-*-py3-none-any.whl",
// 225:           bundled/"pip-*-py3-none-any.whl",
// 226:           context_path("libexec")/"wheel-*-py3-none-any.whl",
// 227:         ].map do |pattern|
// 228:           matches = Pathname.glob(pattern)
// 229:           raise ArgumentError, "CPython bootstrap wheel must match exactly one path: #{pattern}" unless matches.one?
// 230:
// 231:           matches.fetch(0)
// 232:         end
// 233:
// 234:         run_command python, "-Im", "pip", "install", "-v", "--no-deps", "--no-index", "--upgrade", "--isolated",
// 235:                     "--target=#{site_packages}", *wheels
// 236:         FileUtils.mv (site_packages/"bin").children, context_path("bin")
// 237:         (site_packages/"bin").rmdir
// 238:         FileUtils.rm_r context_path("bin").glob("pip{,3}"), force: true
// 239:         FileUtils.mv context_path("bin")/"wheel", context_path("bin")/"wheel#{version_major_minor}"
// 240:         {
// 241:           "pip"    => "pip#{version_major_minor}",
// 242:           "pip3"   => "pip#{version_major_minor}",
// 243:           "wheel"  => "wheel#{version_major_minor}",
// 244:           "wheel3" => "wheel#{version_major_minor}",
// 245:         }.each do |short_name, long_name|
// 246:           (context_path("libexec")/"bin").install_symlink (context_path("bin")/long_name).realpath => short_name
// 247:         end
// 248:         (HOMEBREW_PREFIX/"bin").install_symlink [context_path("bin")/"wheel#{version_major_minor}",
// 249:                                                  context_path("bin")/"pip#{version_major_minor}"]
// 250:         make_cpython_venv_activation_scripts_writable(lib_cellar)
// 251:         return if version_major_minor != "3.9"
// 252:
// 253:         include_dirs = [HOMEBREW_PREFIX/"include", Utils::Path.formula_opt_include("openssl@3"),
// 254:                         Utils::Path.formula_opt_include("sqlite")]
// 255:         library_dirs = [HOMEBREW_PREFIX/"lib", Utils::Path.formula_opt_lib("openssl@3"),
// 256:                         Utils::Path.formula_opt_lib("sqlite")]
// 257:         (lib_cellar/"distutils/distutils.cfg").atomic_write <<~INI
// 258:           [install]
// 259:           prefix=#{HOMEBREW_PREFIX}
// 260:           [build_ext]
// 261:           include_dirs=#{include_dirs.join(":")}
// 262:           library_dirs=#{library_dirs.join(":")}
// 263:         INI
// 264:         framework_compat = site_packages/"setuptools/_distutils/command/_framework_compat.py"
// 265:         require "utils/inreplace"
// 266:         Utils::Inreplace.inreplace(framework_compat, /^(\s+homebrew_prefix\s+=\s+).*/,
// 267:                                    "\\1'#{HOMEBREW_PREFIX}'")
// 268:       end
// 269:
// 270:       public
// 271:
// 272:       sig { params(lib_cellar: Pathname).void }
// 273:       def make_cpython_venv_activation_scripts_writable(lib_cellar)
// 274:         FileUtils.chmod "u+w", lib_cellar.glob("venv/scripts/**/*").select(&:file?)
// 275:       end
// 276:
// 277:       private
// 278:
// 279:       sig { params(abi_version: String).void }
// 280:       def run_bootstrap_pypy(abi_version)
// 281:         pypy = context_path("bin")/"pypy#{abi_version}"
// 282:         %w[_sqlite3 _curses syslog gdbm _tkinter].each do |module_name|
// 283:           @command.run(pypy, args: ["-c", "import #{module_name}"], print_stdout: false, print_stderr: false)
// 284:         end
// 285:         site_packages = HOMEBREW_PREFIX/"lib/pypy#{abi_version}/site-packages"
// 286:         libexec_site_packages = context_path("libexec")/"lib/pypy#{abi_version}/site-packages"
// 287:         scripts_folder = HOMEBREW_PREFIX/"share/pypy#{abi_version}"
// 288:         site_packages.mkpath
// 289:         FileUtils.touch site_packages/".keepme"
// 290:         FileUtils.rm_rf libexec_site_packages
// 291:         libexec_site_packages.parent.install_symlink site_packages
// 292:         if abi_version == "3.9"
// 293:           if scripts_folder.symlink?
// 294:             scripts_folder.unlink
// 295:             scripts_folder.install_symlink context_path("pkgshare").children
// 296:           end
// 297:           unless (context_path("libexec")/"bin").exist?
// 298:             context_path("libexec").install_symlink scripts_folder => "bin"
// 299:           end
// 300:         end
// 301:         scripts_folder.mkpath
// 302:         (libexec_site_packages.parent/"distutils/distutils.cfg").atomic_write <<~INI
// 303:           [install]
// 304:           install-scripts=#{scripts_folder}
// 305:         INI
// 306:         require "unpack_strategy"
// 307:         %w[setuptools pip].each do |package|
// 308:           archive = context_path("libexec")/"post-install-resources/#{package}.tar.gz"
// 309:           raise ArgumentError, "PyPy bootstrap archive is missing: #{archive}" unless archive.file?
// 310:
// 311:           Dir.mktmpdir("homebrew-pypy-#{package}", HOMEBREW_TEMP) do |temporary_directory|
// 312:             temporary_path = Pathname(temporary_directory)
// 313:             UnpackStrategy.detect(archive).extract(to: temporary_path)
// 314:             children = temporary_path.children
// 315:             source_path = (children.one? && children.fetch(0).directory?) ? children.fetch(0) : temporary_path
// 316:             Dir.chdir(source_path) do
// 317:               run_command pypy, "-s", "setup.py", "--no-user-cfg", "install", "--force", "--verbose"
// 318:             end
// 319:           end
// 320:         end
// 321:         context_path("bin").install_symlink scripts_folder/"pip#{abi_version}" => "pip_pypy#{abi_version}"
// 322:         prefix_links = [context_path("bin")/"pip_pypy#{abi_version}"]
// 323:         if context_name == "pypy3"
// 324:           context_path("bin").install_symlink "pip_pypy#{abi_version}" => "pip_pypy3"
// 325:           prefix_links << (context_path("bin")/"pip_pypy3")
// 326:         end
// 327:         (HOMEBREW_PREFIX/"bin").install_symlink prefix_links
// 328:       end
// 329:     end
// 330:   end
// 331: end
