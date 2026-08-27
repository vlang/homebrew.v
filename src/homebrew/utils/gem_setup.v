module utils

import brew_runtime

// Translated from Homebrew/brew `utils/gem_setup.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.gemfile` at line 29.
pub fn ruby_gem_setup_l29_d1_self_gemfile(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.gemfile', ...args)
}

// Ruby method `self.bundler_definition` at line 34.
pub fn ruby_gem_setup_l34_d2_self_bundler_definition(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.bundler_definition', ...args)
}

// Ruby method `self.valid_gem_groups` at line 39.
pub fn ruby_gem_setup_l39_d3_self_valid_gem_groups(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.valid_gem_groups', ...args)
}

// Ruby method `self.ruby_bindir` at line 50.
pub fn ruby_gem_setup_l50_d4_self_ruby_bindir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.ruby_bindir', ...args)
}

// Ruby method `self.ohai_if_defined(message)` at line 54.
pub fn ruby_gem_setup_l54_d5_self_ohai_if_defined(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.ohai_if_defined', ...args)
}

// Ruby method `self.opoo_if_defined(message)` at line 62.
pub fn ruby_gem_setup_l62_d6_self_opoo_if_defined(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.opoo_if_defined', ...args)
}

// Ruby method `self.odie_if_defined(message)` at line 70.
pub fn ruby_gem_setup_l70_d7_self_odie_if_defined(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.odie_if_defined', ...args)
}

// Ruby method `self.setup_gem_environment!(setup_path: true)` at line 79.
pub fn ruby_gem_setup_l79_d8_self_setup_gem_environment(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.setup_gem_environment!', ...args)
}

// Ruby method `self.install_gem!(name, version: nil, setup_gem_environment: true)` at line 115.
pub fn ruby_gem_setup_l115_d9_self_install_gem(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.install_gem!', ...args)
}

// Ruby method `self.find_in_path(executable)` at line 142.
pub fn ruby_gem_setup_l142_d10_self_find_in_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.find_in_path', ...args)
}

// Ruby method `self.user_gem_groups` at line 149.
pub fn ruby_gem_setup_l149_d11_self_user_gem_groups(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.user_gem_groups', ...args)
}

// Ruby method `self.write_user_gem_groups(groups)` at line 158.
pub fn ruby_gem_setup_l158_d12_self_write_user_gem_groups(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.write_user_gem_groups', ...args)
}

// Ruby method `self.forget_user_gem_groups!` at line 181.
pub fn ruby_gem_setup_l181_d13_self_forget_user_gem_groups(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.forget_user_gem_groups!', ...args)
}

// Ruby method `self.user_vendor_version` at line 186.
pub fn ruby_gem_setup_l186_d14_self_user_vendor_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.user_vendor_version', ...args)
}

// Ruby method `self.install_bundler_gems!(only_warn_on_failure: false, setup_path: true, groups: [])` at line 195.
pub fn ruby_gem_setup_l195_d15_self_install_bundler_gems(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.install_bundler_gems!', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true  # rubocop:disable Sorbet/StrictSigil
// 2: # frozen_string_literal: true
// 3:
// 4: # Never `require` anything in this file (except English). It needs to be able to
// 5: # work as the first item in `brew.rb` so we can load gems with Bundler when
// 6: # needed before anything else is loaded (e.g. `json`).
// 7:
// 8: Homebrew::FastBootRequire.from_rubylibdir("English")
// 9:
// 10: module Homebrew
// 11:   # Bump this whenever a committed vendored gem is later added to or exclusion removed from gitignore.
// 12:   # This will trigger it to reinstall properly if `brew install-bundler-gems` needs it.
// 13:   VENDOR_VERSION = 9
// 14:   private_constant :VENDOR_VERSION
// 15:
// 16:   RUBY_BUNDLE_VENDOR_DIRECTORY = (HOMEBREW_LIBRARY_PATH/"vendor/bundle/ruby").freeze
// 17:   private_constant :RUBY_BUNDLE_VENDOR_DIRECTORY
// 18:
// 19:   # This is tracked across Ruby versions.
// 20:   GEM_GROUPS_FILE = (RUBY_BUNDLE_VENDOR_DIRECTORY/".homebrew_gem_groups").freeze
// 21:   private_constant :GEM_GROUPS_FILE
// 22:
// 23:   # This is tracked per Ruby version.
// 24:   VENDOR_VERSION_FILE = (
// 25:     RUBY_BUNDLE_VENDOR_DIRECTORY/"#{RbConfig::CONFIG["ruby_version"]}/.homebrew_vendor_version"
// 26:   ).freeze
// 27:   private_constant :VENDOR_VERSION_FILE
// 28:
// 29:   def self.gemfile
// 30:     File.join(ENV.fetch("HOMEBREW_LIBRARY"), "Homebrew", "Gemfile")
// 31:   end
// 32:   private_class_method :gemfile
// 33:
// 34:   def self.bundler_definition
// 35:     @bundler_definition ||= Bundler::Definition.build(Bundler.default_gemfile, Bundler.default_lockfile, false)
// 36:   end
// 37:   private_class_method :bundler_definition
// 38:
// 39:   def self.valid_gem_groups
// 40:     require "bundler"
// 41:
// 42:     Bundler.with_unbundled_env do
// 43:       ENV["BUNDLE_GEMFILE"] = gemfile
// 44:       groups = bundler_definition.groups
// 45:       groups.delete(:default)
// 46:       groups.map(&:to_s)
// 47:     end
// 48:   end
// 49:
// 50:   def self.ruby_bindir
// 51:     "#{RbConfig::CONFIG["prefix"]}/bin"
// 52:   end
// 53:
// 54:   def self.ohai_if_defined(message)
// 55:     if defined?(ohai)
// 56:       ohai message
// 57:     else
// 58:       $stderr.puts "==> #{message}"
// 59:     end
// 60:   end
// 61:
// 62:   def self.opoo_if_defined(message)
// 63:     if defined?(opoo)
// 64:       opoo message
// 65:     else
// 66:       $stderr.puts "Warning: #{message}"
// 67:     end
// 68:   end
// 69:
// 70:   def self.odie_if_defined(message)
// 71:     if defined?(odie)
// 72:       odie message
// 73:     else
// 74:       $stderr.puts "Error: #{message}"
// 75:       exit 1
// 76:     end
// 77:   end
// 78:
// 79:   def self.setup_gem_environment!(setup_path: true)
// 80:     require "rubygems"
// 81:     raise "RubyGems too old!" if Gem::Version.new(Gem::VERSION) < Gem::Version.new("2.2.0")
// 82:
// 83:     ENV["BUNDLER_NO_OLD_RUBYGEMS_WARNING"] = "1"
// 84:
// 85:     # Match where our bundler gems are.
// 86:     gem_home = "#{RUBY_BUNDLE_VENDOR_DIRECTORY}/#{RbConfig::CONFIG["ruby_version"]}"
// 87:     homebrew_cache = ENV.fetch("HOMEBREW_CACHE", nil)
// 88:     gem_cache = "#{homebrew_cache}/gem-spec-cache" if homebrew_cache
// 89:
// 90:     Gem.paths = {
// 91:       "GEM_HOME"       => gem_home,
// 92:       "GEM_PATH"       => gem_home,
// 93:       "GEM_SPEC_CACHE" => gem_cache,
// 94:     }.compact
// 95:
// 96:     # Set TMPDIR so Xcode's `make` doesn't fall back to `/var/tmp/`,
// 97:     # which may be not user-writable.
// 98:     ENV["TMPDIR"] = ENV.fetch("HOMEBREW_TEMP", nil)
// 99:
// 100:     return unless setup_path
// 101:
// 102:     # Add necessary Ruby and Gem binary directories to `PATH`.
// 103:     paths = ENV.fetch("PATH").split(":")
// 104:     paths.unshift(ruby_bindir) unless paths.include?(ruby_bindir)
// 105:     paths.unshift(Gem.bindir) unless paths.include?(Gem.bindir)
// 106:     ENV["PATH"] = paths.compact.join(":")
// 107:
// 108:     # Set envs so the above binaries can be invoked.
// 109:     # We don't do this unless requested as some formulae may invoke system Ruby instead of ours.
// 110:     ENV["GEM_HOME"] = gem_home
// 111:     ENV["GEM_PATH"] = gem_home
// 112:     ENV["GEM_SPEC_CACHE"] = gem_cache if gem_cache
// 113:   end
// 114:
// 115:   def self.install_gem!(name, version: nil, setup_gem_environment: true)
// 116:     setup_gem_environment! if setup_gem_environment
// 117:
// 118:     specs = Gem::Specification.find_all_by_name(name, version)
// 119:
// 120:     if specs.empty?
// 121:       ohai_if_defined "Installing '#{name}' gem"
// 122:       # `document: []` is equivalent to --no-document
// 123:       # `build_args: []` stops ARGV being used as a default
// 124:       # `env_shebang: true` makes shebangs generic to allow switching between system and Portable Ruby
// 125:       specs = Gem.install name, version, document: [], build_args: [], env_shebang: true
// 126:     end
// 127:
// 128:     specs += specs.flat_map(&:runtime_dependencies)
// 129:                   .flat_map(&:to_specs)
// 130:
// 131:     # Add the specs to the $LOAD_PATH.
// 132:     specs.each do |spec|
// 133:       spec.require_paths.each do |path|
// 134:         full_path = File.join(spec.full_gem_path, path)
// 135:         $LOAD_PATH.unshift full_path unless $LOAD_PATH.include?(full_path)
// 136:       end
// 137:     end
// 138:   rescue Gem::UnsatisfiableDependencyError
// 139:     odie_if_defined "failed to install the '#{name}' gem."
// 140:   end
// 141:
// 142:   def self.find_in_path(executable)
// 143:     ENV.fetch("PATH").split(":").find do |path|
// 144:       File.executable?(File.join(path, executable))
// 145:     end
// 146:   end
// 147:   private_class_method :find_in_path
// 148:
// 149:   def self.user_gem_groups
// 150:     @user_gem_groups ||= if GEM_GROUPS_FILE.exist?
// 151:       GEM_GROUPS_FILE.readlines(chomp: true)
// 152:     else
// 153:       []
// 154:     end
// 155:   end
// 156:   private_class_method :user_gem_groups
// 157:
// 158:   def self.write_user_gem_groups(groups)
// 159:     return if @user_gem_groups == groups && GEM_GROUPS_FILE.exist?
// 160:
// 161:     # Write the file atomically, in case we're working parallel
// 162:     require "tempfile"
// 163:     tmpfile = Tempfile.new([GEM_GROUPS_FILE.basename.to_s, "~"], GEM_GROUPS_FILE.dirname)
// 164:     path = tmpfile.path
// 165:     return if path.nil?
// 166:
// 167:     require "fileutils"
// 168:     begin
// 169:       FileUtils.chmod("+r", path)
// 170:       tmpfile.write(groups.join("\n"))
// 171:       tmpfile.close
// 172:       File.rename(path, GEM_GROUPS_FILE)
// 173:     ensure
// 174:       tmpfile.unlink
// 175:     end
// 176:
// 177:     @user_gem_groups = groups
// 178:   end
// 179:   private_class_method :write_user_gem_groups
// 180:
// 181:   def self.forget_user_gem_groups!
// 182:     GEM_GROUPS_FILE.truncate(0) if GEM_GROUPS_FILE.exist?
// 183:     @user_gem_groups = []
// 184:   end
// 185:
// 186:   def self.user_vendor_version
// 187:     @user_vendor_version ||= if VENDOR_VERSION_FILE.exist?
// 188:       VENDOR_VERSION_FILE.read.to_i
// 189:     else
// 190:       0
// 191:     end
// 192:   end
// 193:   private_class_method :user_vendor_version
// 194:
// 195:   def self.install_bundler_gems!(only_warn_on_failure: false, setup_path: true, groups: [])
// 196:     old_path = ENV.fetch("PATH", nil)
// 197:     old_gem_path = ENV.fetch("GEM_PATH", nil)
// 198:     old_gem_home = ENV.fetch("GEM_HOME", nil)
// 199:     old_gem_spec_cache = ENV.fetch("GEM_SPEC_CACHE", nil)
// 200:     old_bundle_gemfile = ENV.fetch("BUNDLE_GEMFILE", nil)
// 201:     old_bundle_with = ENV.fetch("BUNDLE_WITH", nil)
// 202:     old_bundle_frozen = ENV.fetch("BUNDLE_FROZEN", nil)
// 203:
// 204:     invalid_groups = groups - valid_gem_groups
// 205:     raise ArgumentError, "Invalid gem groups: #{invalid_groups.join(", ")}" unless invalid_groups.empty?
// 206:
// 207:     setup_gem_environment!
// 208:     # Tests should not modify the state of the repository.
// 209:     return if ENV["HOMEBREW_TESTS"]
// 210:
// 211:     # Combine the passed groups with the ones stored in settings.
// 212:     groups |= (user_gem_groups & valid_gem_groups)
// 213:     groups.sort!
// 214:
// 215:     if (homebrew_bundle_user_cache = ENV.fetch("HOMEBREW_BUNDLE_USER_CACHE", nil))
// 216:       ENV["BUNDLE_USER_CACHE"] = homebrew_bundle_user_cache
// 217:     end
// 218:     ENV["BUNDLE_GEMFILE"] = gemfile
// 219:     ENV["BUNDLE_WITH"] = groups.join(" ")
// 220:     ENV["BUNDLE_FROZEN"] = "true"
// 221:
// 222:     if @bundle_installed_groups != groups
// 223:       bundle = File.join(find_in_path("bundle"), "bundle")
// 224:       bundle_check_output = `#{bundle} check 2>&1`
// 225:       bundle_check_failed = !$CHILD_STATUS.success?
// 226:
// 227:       # for some reason sometimes the exit code lies so check the output too.
// 228:       bundle_install_required = bundle_check_failed || bundle_check_output.include?("Install missing gems")
// 229:
// 230:       if user_vendor_version != VENDOR_VERSION
// 231:         # Check if the install is intact. This is useful if any gems are added to gitignore.
// 232:         # We intentionally map over everything and then call `any?` so that we remove the spec of each bad gem.
// 233:         specs = bundler_definition.resolve.materialize(bundler_definition.locked_dependencies)
// 234:         vendor_reinstall_required = specs.map do |spec|
// 235:           spec_file = "#{Gem.dir}/specifications/#{spec.full_name}.gemspec"
// 236:           next false unless File.exist?(spec_file)
// 237:
// 238:           cache_file = "#{Gem.dir}/cache/#{spec.full_name}.gem"
// 239:           if File.exist?(cache_file)
// 240:             require "rubygems/package"
// 241:             package = Gem::Package.new(cache_file)
// 242:
// 243:             package_install_intact = begin
// 244:               contents = package.contents
// 245:
// 246:               # If the gem has contents, ensure we have every file installed it contains.
// 247:               contents&.all? do |gem_file|
// 248:                 File.exist?("#{Gem.dir}/gems/#{spec.full_name}/#{gem_file}")
// 249:               end
// 250:             rescue Gem::Package::Error, Gem::Security::Exception
// 251:               # Malformed, assume broken
// 252:               File.unlink(cache_file)
// 253:               false
// 254:             end
// 255:
// 256:             next false if package_install_intact
// 257:           end
// 258:
// 259:           # Mark gem for reinstallation
// 260:           File.unlink(spec_file)
// 261:           true
// 262:         end.any?
// 263:
// 264:         VENDOR_VERSION_FILE.dirname.mkpath
// 265:         VENDOR_VERSION_FILE.write(VENDOR_VERSION.to_s)
// 266:
// 267:         bundle_install_required ||= vendor_reinstall_required
// 268:       end
// 269:
// 270:       bundle_installed = if bundle_install_required
// 271:         Process.wait(fork do
// 272:           # Native build scripts fail if EUID != UID
// 273:           Process::UID.change_privilege(Process.euid) if Process.euid != Process.uid
// 274:           exec bundle, "install", out: :err
// 275:         end)
// 276:         if $CHILD_STATUS.success?
// 277:           Homebrew::Bootsnap.reset! if defined?(Homebrew::Bootsnap) # Gem install can run before Bootsnap loads
// 278:           true
// 279:         else
// 280:           message = <<~EOS
// 281:             failed to run `#{bundle} install`!
// 282:           EOS
// 283:           if only_warn_on_failure
// 284:             opoo_if_defined message
// 285:           else
// 286:             odie_if_defined message
// 287:           end
// 288:           false
// 289:         end
// 290:       elsif system bundle, "clean", out: :err # even if we have nothing to install, we may have removed gems
// 291:         true
// 292:       else
// 293:         message = <<~EOS
// 294:           failed to run `#{bundle} clean`!
// 295:         EOS
// 296:         if only_warn_on_failure
// 297:           opoo_if_defined message
// 298:         else
// 299:           odie_if_defined message
// 300:         end
// 301:         false
// 302:       end
// 303:
// 304:       if bundle_installed
// 305:         write_user_gem_groups(groups)
// 306:         @bundle_installed_groups = groups
// 307:       end
// 308:     end
// 309:
// 310:     setup_gem_environment!
// 311:   ensure
// 312:     unless setup_path
// 313:       # Reset the paths. We need to have at least temporarily changed them while invoking `bundle`.
// 314:       ENV["PATH"] = old_path
// 315:       ENV["GEM_PATH"] = old_gem_path
// 316:       ENV["GEM_HOME"] = old_gem_home
// 317:       ENV["GEM_SPEC_CACHE"] = old_gem_spec_cache
// 318:       ENV["BUNDLE_GEMFILE"] = old_bundle_gemfile
// 319:       ENV["BUNDLE_WITH"] = old_bundle_with
// 320:       ENV["BUNDLE_FROZEN"] = old_bundle_frozen
// 321:     end
// 322:   end
// 323: end
