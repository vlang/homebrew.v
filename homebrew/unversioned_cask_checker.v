module homebrew

import brew_runtime

// Translated from Homebrew/brew `unversioned_cask_checker.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :cask` at line 18.
pub fn ruby_unversioned_cask_checker_l18_d1_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby method `initialize(cask)` at line 21.
pub fn ruby_unversioned_cask_checker_l21_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `installer` at line 26.
pub fn ruby_unversioned_cask_checker_l26_d3_installer(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installer', ...args)
}

// Ruby method `apps` at line 31.
pub fn ruby_unversioned_cask_checker_l31_d4_apps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('apps', ...args)
}

// Ruby method `keyboard_layouts` at line 36.
pub fn ruby_unversioned_cask_checker_l36_d5_keyboard_layouts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('keyboard_layouts', ...args)
}

// Ruby method `qlplugins` at line 42.
pub fn ruby_unversioned_cask_checker_l42_d6_qlplugins(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('qlplugins', ...args)
}

// Ruby method `dictionaries` at line 48.
pub fn ruby_unversioned_cask_checker_l48_d7_dictionaries(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dictionaries', ...args)
}

// Ruby method `screen_savers` at line 54.
pub fn ruby_unversioned_cask_checker_l54_d8_screen_savers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('screen_savers', ...args)
}

// Ruby method `colorpickers` at line 60.
pub fn ruby_unversioned_cask_checker_l60_d9_colorpickers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('colorpickers', ...args)
}

// Ruby method `mdimporters` at line 66.
pub fn ruby_unversioned_cask_checker_l66_d10_mdimporters(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('mdimporters', ...args)
}

// Ruby method `installers` at line 72.
pub fn ruby_unversioned_cask_checker_l72_d11_installers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installers', ...args)
}

// Ruby method `pkgs` at line 78.
pub fn ruby_unversioned_cask_checker_l78_d12_pkgs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pkgs', ...args)
}

// Ruby method `single_app_cask?` at line 83.
pub fn ruby_unversioned_cask_checker_l83_d13_single_app_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('single_app_cask?', ...args)
}

// Ruby method `single_qlplugin_cask?` at line 88.
pub fn ruby_unversioned_cask_checker_l88_d14_single_qlplugin_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('single_qlplugin_cask?', ...args)
}

// Ruby method `single_pkg_cask?` at line 93.
pub fn ruby_unversioned_cask_checker_l93_d15_single_pkg_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('single_pkg_cask?', ...args)
}

// Ruby method `top_level_info_plists(paths)` at line 100.
pub fn ruby_unversioned_cask_checker_l100_d16_top_level_info_plists(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('top_level_info_plists', ...args)
}

// Ruby method `all_versions` at line 110.
pub fn ruby_unversioned_cask_checker_l110_d17_all_versions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('all_versions', ...args)
}

// Ruby method `guess_cask_version` at line 182.
pub fn ruby_unversioned_cask_checker_l182_d18_guess_cask_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('guess_cask_version', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle_version"
// 5: require "cask/cask"
// 6: require "cask/installer"
// 7: require "system_command"
// 8: require "utils/output"
// 9:
// 10: module Homebrew
// 11:   # Check unversioned casks for updates by extracting their
// 12:   # contents and guessing the version from contained files.
// 13:   class UnversionedCaskChecker
// 14:     include SystemCommand::Mixin
// 15:     include Utils::Output::Mixin
// 16:
// 17:     sig { returns(Cask::Cask) }
// 18:     attr_reader :cask
// 19:
// 20:     sig { params(cask: Cask::Cask).void }
// 21:     def initialize(cask)
// 22:       @cask = cask
// 23:     end
// 24:
// 25:     sig { returns(Cask::Installer) }
// 26:     def installer
// 27:       @installer ||= T.let(Cask::Installer.new(cask, verify_download_integrity: false), T.nilable(Cask::Installer))
// 28:     end
// 29:
// 30:     sig { returns(T::Array[Cask::Artifact::App]) }
// 31:     def apps
// 32:       @apps ||= T.let(@cask.artifacts.grep(Cask::Artifact::App), T.nilable(T::Array[Cask::Artifact::App]))
// 33:     end
// 34:
// 35:     sig { returns(T::Array[Cask::Artifact::KeyboardLayout]) }
// 36:     def keyboard_layouts
// 37:       @keyboard_layouts ||= T.let(@cask.artifacts.grep(Cask::Artifact::KeyboardLayout),
// 38:                                   T.nilable(T::Array[Cask::Artifact::KeyboardLayout]))
// 39:     end
// 40:
// 41:     sig { returns(T::Array[Cask::Artifact::Qlplugin]) }
// 42:     def qlplugins
// 43:       @qlplugins ||= T.let(@cask.artifacts.grep(Cask::Artifact::Qlplugin),
// 44:                            T.nilable(T::Array[Cask::Artifact::Qlplugin]))
// 45:     end
// 46:
// 47:     sig { returns(T::Array[Cask::Artifact::Dictionary]) }
// 48:     def dictionaries
// 49:       @dictionaries ||= T.let(@cask.artifacts.grep(Cask::Artifact::Dictionary),
// 50:                               T.nilable(T::Array[Cask::Artifact::Dictionary]))
// 51:     end
// 52:
// 53:     sig { returns(T::Array[Cask::Artifact::ScreenSaver]) }
// 54:     def screen_savers
// 55:       @screen_savers ||= T.let(@cask.artifacts.grep(Cask::Artifact::ScreenSaver),
// 56:                                T.nilable(T::Array[Cask::Artifact::ScreenSaver]))
// 57:     end
// 58:
// 59:     sig { returns(T::Array[Cask::Artifact::Colorpicker]) }
// 60:     def colorpickers
// 61:       @colorpickers ||= T.let(@cask.artifacts.grep(Cask::Artifact::Colorpicker),
// 62:                               T.nilable(T::Array[Cask::Artifact::Colorpicker]))
// 63:     end
// 64:
// 65:     sig { returns(T::Array[Cask::Artifact::Mdimporter]) }
// 66:     def mdimporters
// 67:       @mdimporters ||= T.let(@cask.artifacts.grep(Cask::Artifact::Mdimporter),
// 68:                              T.nilable(T::Array[Cask::Artifact::Mdimporter]))
// 69:     end
// 70:
// 71:     sig { returns(T::Array[Cask::Artifact::Installer]) }
// 72:     def installers
// 73:       @installers ||= T.let(@cask.artifacts.grep(Cask::Artifact::Installer),
// 74:                             T.nilable(T::Array[Cask::Artifact::Installer]))
// 75:     end
// 76:
// 77:     sig { returns(T::Array[Cask::Artifact::Pkg]) }
// 78:     def pkgs
// 79:       @pkgs ||= T.let(@cask.artifacts.grep(Cask::Artifact::Pkg), T.nilable(T::Array[Cask::Artifact::Pkg]))
// 80:     end
// 81:
// 82:     sig { returns(T::Boolean) }
// 83:     def single_app_cask?
// 84:       apps.one?
// 85:     end
// 86:
// 87:     sig { returns(T::Boolean) }
// 88:     def single_qlplugin_cask?
// 89:       qlplugins.one?
// 90:     end
// 91:
// 92:     sig { returns(T::Boolean) }
// 93:     def single_pkg_cask?
// 94:       pkgs.one?
// 95:     end
// 96:
// 97:     # Filter paths to `Info.plist` files so that ones belonging
// 98:     # to e.g. nested `.app`s are ignored.
// 99:     sig { params(paths: T::Array[Pathname]).returns(T::Array[Pathname]) }
// 100:     def top_level_info_plists(paths)
// 101:       # Go from `./Contents/Info.plist` to `./`.
// 102:       top_level_paths = paths.map { |path| path.parent.parent }
// 103:
// 104:       paths.reject do |path|
// 105:         path.ascend.drop(3).intersect?(top_level_paths)
// 106:       end
// 107:     end
// 108:
// 109:     sig { returns(T::Hash[String, BundleVersion]) }
// 110:     def all_versions
// 111:       versions = {}
// 112:
// 113:       parse_info_plist = proc do |info_plist_path|
// 114:         plist = system_command!("plutil", args: ["-convert", "xml1", "-o", "-", info_plist_path]).plist
// 115:
// 116:         id = plist["CFBundleIdentifier"]
// 117:         version = BundleVersion.from_info_plist_content(plist)
// 118:
// 119:         versions[id] = version if id && version
// 120:       end
// 121:
// 122:       Dir.mktmpdir("cask-checker", HOMEBREW_TEMP) do |dir|
// 123:         dir = Pathname(dir)
// 124:
// 125:         installer.extract_primary_container(to: dir)
// 126:         installer.process_rename_operations(target_dir: dir)
// 127:
// 128:         info_plist_paths = [
// 129:           *apps,
// 130:           *keyboard_layouts,
// 131:           *mdimporters,
// 132:           *colorpickers,
// 133:           *dictionaries,
// 134:           *qlplugins,
// 135:           *installers,
// 136:           *screen_savers,
// 137:         ].flat_map do |artifact|
// 138:           sources = if artifact.is_a?(Cask::Artifact::Installer)
// 139:             # Installers are sometimes contained within an `.app`, so try both.
// 140:             installer_path = artifact.path
// 141:             installer_path.ascend
// 142:                           .select { |path| path == installer_path || path.extname == ".app" }
// 143:                           .sort
// 144:           else
// 145:             [artifact.source.basename]
// 146:           end
// 147:
// 148:           sources.flat_map do |source|
// 149:             top_level_info_plists(Pathname.glob(dir/"**"/source/"Contents"/"Info.plist")).sort
// 150:           end
// 151:         end
// 152:
// 153:         info_plist_paths.each(&parse_info_plist)
// 154:
// 155:         pkg_paths = pkgs.flat_map { |pkg| Pathname.glob(dir/"**"/pkg.path.basename).sort }
// 156:         pkg_paths = Pathname.glob(dir/"**"/"*.pkg").sort if pkg_paths.empty?
// 157:
// 158:         pkg_paths.each do |pkg_path|
// 159:           Dir.mktmpdir("cask-checker", HOMEBREW_TEMP) do |extract_dir|
// 160:             extract_dir = Pathname(extract_dir)
// 161:             FileUtils.rmdir extract_dir
// 162:
// 163:             system_command! "pkgutil", args: ["--expand-full", pkg_path, extract_dir]
// 164:
// 165:             top_level_info_plist_paths = top_level_info_plists(Pathname.glob(extract_dir/"**/Contents/Info.plist"))
// 166:
// 167:             top_level_info_plist_paths.each(&parse_info_plist)
// 168:           ensure
// 169:             extract_dir = Pathname(extract_dir)
// 170:             Cask::Utils.gain_permissions_remove(extract_dir)
// 171:             extract_dir.mkpath
// 172:           end
// 173:         end
// 174:
// 175:         nil
// 176:       end
// 177:
// 178:       versions
// 179:     end
// 180:
// 181:     sig { returns(T.nilable(String)) }
// 182:     def guess_cask_version
// 183:       if apps.empty? && pkgs.empty? && qlplugins.empty?
// 184:         opoo "Cask #{cask} does not contain any apps, qlplugins or PKG installers."
// 185:         return
// 186:       end
// 187:
// 188:       Dir.mktmpdir("cask-checker", HOMEBREW_TEMP) do |dir|
// 189:         dir = Pathname(dir)
// 190:
// 191:         installer.then do |i|
// 192:           i.extract_primary_container(to: dir)
// 193:         rescue ErrorDuringExecution => e
// 194:           onoe e
// 195:           return nil
// 196:         end
// 197:
// 198:         info_plist_paths = apps.flat_map do |app|
// 199:           top_level_info_plists(Pathname.glob(dir/"**"/app.source.basename/"Contents"/"Info.plist")).sort
// 200:         end
// 201:
// 202:         info_plist_paths.each do |info_plist_path|
// 203:           if (version = BundleVersion.from_info_plist(info_plist_path))
// 204:             return version.nice_version
// 205:           end
// 206:         end
// 207:
// 208:         pkg_paths = pkgs.flat_map do |pkg|
// 209:           Pathname.glob(dir/"**"/pkg.path.basename).sort
// 210:         end
// 211:
// 212:         pkg_paths.each do |pkg_path|
// 213:           packages =
// 214:             system_command!("installer", args: ["-plist", "-pkginfo", "-pkg", pkg_path])
// 215:             .plist
// 216:             .map { |package| package.fetch("Package") }
// 217:
// 218:           Dir.mktmpdir("cask-checker", HOMEBREW_TEMP) do |extract_dir|
// 219:             extract_dir = Pathname(extract_dir)
// 220:             FileUtils.rmdir extract_dir
// 221:
// 222:             begin
// 223:               system_command! "pkgutil", args: ["--expand-full", pkg_path, extract_dir]
// 224:             rescue ErrorDuringExecution => e
// 225:               onoe "Failed to extract #{pkg_path.basename}: #{e}"
// 226:               next
// 227:             end
// 228:
// 229:             top_level_info_plist_paths = top_level_info_plists(Pathname.glob(extract_dir/"**/Contents/Info.plist"))
// 230:
// 231:             unique_info_plist_versions =
// 232:               top_level_info_plist_paths.filter_map { |i| BundleVersion.from_info_plist(i)&.nice_version }
// 233:                                         .uniq
// 234:             return unique_info_plist_versions.first if unique_info_plist_versions.one?
// 235:
// 236:             package_info_path = extract_dir/"PackageInfo"
// 237:             if package_info_path.exist?
// 238:               if (version = BundleVersion.from_package_info(package_info_path))
// 239:                 return version.nice_version
// 240:               end
// 241:             elsif packages.one?
// 242:               onoe "#{pkg_path.basename} does not contain a `PackageInfo` file."
// 243:             end
// 244:
// 245:             distribution_path = extract_dir/"Distribution"
// 246:             if distribution_path.exist?
// 247:               require "rexml/document"
// 248:
// 249:               xml = REXML::Document.new(distribution_path.read)
// 250:
// 251:               product = xml.get_elements("//installer-gui-script//product").first
// 252:               product_version = product["version"] if product
// 253:               return product_version if product_version.present?
// 254:             end
// 255:
// 256:             opoo "#{pkg_path.basename} contains multiple packages: #{packages}" if packages.count != 1
// 257:
// 258:             $stderr.puts Pathname.glob(extract_dir/"**/*")
// 259:                                  .map { |path|
// 260:                                    regex = %r{\A(.*?\.(app|qlgenerator|saver|plugin|kext|bundle|osax))/.*\Z}
// 261:                                    path.to_s.sub(regex, '\1')
// 262:                                  }.uniq
// 263:           ensure
// 264:             extract_dir = Pathname(extract_dir)
// 265:             Cask::Utils.gain_permissions_remove(extract_dir)
// 266:             extract_dir.mkpath
// 267:           end
// 268:         end
// 269:
// 270:         nil
// 271:       end
// 272:     end
// 273:   end
// 274: end
