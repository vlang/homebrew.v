module homebrew

import brew_runtime

// Translated from Homebrew/brew `caveats.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :formula` at line 11.
pub fn ruby_caveats_l11_d1_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula', ...args)
}

// Ruby method `initialize(formula)` at line 14.
pub fn ruby_caveats_l14_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `caveats` at line 21.
pub fn ruby_caveats_l21_d3_caveats(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('caveats', ...args)
}

// Ruby method `empty?` at line 40.
pub fn ruby_caveats_l40_d4_empty(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('empty?', ...args)
}

// Ruby delegate `delegate [:to_s] => :caveats` at line 44.
pub fn ruby_caveats_l44_d5_delegate_dynamic(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('delegate_dynamic', ...args)
}

// Ruby method `completions_and_elisp` at line 47.
pub fn ruby_caveats_l47_d6_completions_and_elisp(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('completions_and_elisp', ...args)
}

// Ruby method `keg_only_text(skip_reason: false)` at line 67.
pub fn ruby_caveats_l67_d7_keg_only_text(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('keg_only_text', ...args)
}

// Ruby method `shadowed_path_text` at line 129.
pub fn ruby_caveats_l129_d8_shadowed_path_text(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('shadowed_path_text', ...args)
}

// Ruby method `sibling_keg_name(shadower)` at line 172.
pub fn ruby_caveats_l172_d9_sibling_keg_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sibling_keg_name', ...args)
}

// Ruby method `shadowed_executables` at line 190.
pub fn ruby_caveats_l190_d10_shadowed_executables(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('shadowed_executables', ...args)
}

// Ruby method `keg` at line 210.
pub fn ruby_caveats_l210_d11_keg(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('keg', ...args)
}

// Ruby method `function_completion_caveats(shell)` at line 219.
pub fn ruby_caveats_l219_d12_function_completion_caveats(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('function_completion_caveats', ...args)
}

// Ruby method `elisp_caveats` at line 258.
pub fn ruby_caveats_l258_d13_elisp_caveats(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('elisp_caveats', ...args)
}

// Ruby method `service_caveats` at line 270.
pub fn ruby_caveats_l270_d14_service_caveats(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('service_caveats', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/service"
// 5:
// 6: # A formula's caveats.
// 7: class Caveats
// 8:   extend Forwardable
// 9:
// 10:   sig { returns(Formula) }
// 11:   attr_reader :formula
// 12:
// 13:   sig { params(formula: Formula).void }
// 14:   def initialize(formula)
// 15:     @formula = formula
// 16:     @caveats = T.let(nil, T.nilable(String))
// 17:     @completions_and_elisp = T.let(nil, T.nilable(T::Array[String]))
// 18:   end
// 19:
// 20:   sig { returns(String) }
// 21:   def caveats
// 22:     @caveats ||= begin
// 23:       caveats = []
// 24:       build = formula.build
// 25:       begin
// 26:         formula.build = Tab.for_formula(formula)
// 27:         string = formula.caveats.to_s
// 28:         caveats << "#{string.chomp}\n" unless string.empty?
// 29:       ensure
// 30:         formula.build = build
// 31:       end
// 32:       caveats << keg_only_text
// 33:       caveats << shadowed_path_text
// 34:       caveats << service_caveats
// 35:       caveats.compact.join("\n")
// 36:     end
// 37:   end
// 38:
// 39:   sig { returns(T::Boolean) }
// 40:   def empty?
// 41:     caveats.blank? && completions_and_elisp.blank?
// 42:   end
// 43:
// 44:   delegate [:to_s] => :caveats
// 45:
// 46:   sig { returns(T::Array[String]) }
// 47:   def completions_and_elisp
// 48:     @completions_and_elisp ||= begin
// 49:       valid_shells = [:bash, :zsh, :fish, :pwsh].freeze
// 50:       current_shell = Utils::Shell.preferred || Utils::Shell.parent
// 51:       shells = if current_shell.present? &&
// 52:                   (shell_sym = current_shell.to_sym) &&
// 53:                   valid_shells.include?(shell_sym)
// 54:         [shell_sym]
// 55:       else
// 56:         valid_shells
// 57:       end
// 58:       completions_and_elisp = shells.map do |shell|
// 59:         function_completion_caveats(shell)
// 60:       end
// 61:       completions_and_elisp << elisp_caveats
// 62:       completions_and_elisp.compact
// 63:     end
// 64:   end
// 65:
// 66:   sig { params(skip_reason: T::Boolean).returns(T.nilable(String)) }
// 67:   def keg_only_text(skip_reason: false)
// 68:     return unless formula.keg_only?
// 69:     return if formula.linked?
// 70:
// 71:     s = if skip_reason
// 72:       ""
// 73:     else
// 74:       <<~EOS
// 75:         #{formula.name} is keg-only, which means it was not symlinked into #{HOMEBREW_PREFIX},
// 76:         because #{formula.keg_only_reason.to_s.chomp}.
// 77:       EOS
// 78:     end.dup
// 79:
// 80:     if formula.bin.directory? || formula.sbin.directory?
// 81:       s << <<~EOS
// 82:
// 83:         If you need to have #{formula.name} first in your PATH, run:
// 84:       EOS
// 85:       s << "  #{Utils::Shell.prepend_path_in_profile(formula.opt_bin.to_s)}\n" if formula.bin.directory?
// 86:       s << "  #{Utils::Shell.prepend_path_in_profile(formula.opt_sbin.to_s)}\n" if formula.sbin.directory?
// 87:     end
// 88:
// 89:     if formula.lib.directory? || formula.include.directory?
// 90:       s << <<~EOS
// 91:
// 92:         For compilers to find #{formula.name} you may need to set:
// 93:       EOS
// 94:
// 95:       s << "  #{Utils::Shell.export_value("LDFLAGS", "-L#{formula.opt_lib}")}\n" if formula.lib.directory?
// 96:
// 97:       s << "  #{Utils::Shell.export_value("CPPFLAGS", "-I#{formula.opt_include}")}\n" if formula.include.directory?
// 98:
// 99:       if which("pkgconf", ORIGINAL_PATHS) &&
// 100:          ((formula.lib/"pkgconfig").directory? || (formula.share/"pkgconfig").directory?)
// 101:         s << <<~EOS
// 102:
// 103:           For pkgconf to find #{formula.name} you may need to set:
// 104:         EOS
// 105:
// 106:         if (formula.lib/"pkgconfig").directory?
// 107:           s << "  #{Utils::Shell.export_value("PKG_CONFIG_PATH", "#{formula.opt_lib}/pkgconfig")}\n"
// 108:         end
// 109:
// 110:         if (formula.share/"pkgconfig").directory?
// 111:           s << "  #{Utils::Shell.export_value("PKG_CONFIG_PATH", "#{formula.opt_share}/pkgconfig")}\n"
// 112:         end
// 113:       end
// 114:
// 115:       if which("cmake", ORIGINAL_PATHS) &&
// 116:          ((formula.lib/"cmake").directory? || (formula.share/"cmake").directory?)
// 117:         s << <<~EOS
// 118:
// 119:           For cmake to find #{formula.name} you may need to set:
// 120:             #{Utils::Shell.export_value("CMAKE_PREFIX_PATH", formula.opt_prefix.to_s)}
// 121:         EOS
// 122:       end
// 123:     end
// 124:     s << "\n" unless s.end_with?("\n")
// 125:     s
// 126:   end
// 127:
// 128:   sig { returns(T.nilable(String)) }
// 129:   def shadowed_path_text
// 130:     return if Homebrew::EnvConfig.no_path_shadow_check?
// 131:     return unless formula.any_version_installed?
// 132:
// 133:     shadowed = shadowed_executables
// 134:     shadowed = shadowed.select { |_, shadower| sibling_keg_name(shadower) } if formula.keg_only? && !formula.linked?
// 135:     return if shadowed.empty?
// 136:
// 137:     sibling, external = shadowed.sort_by(&:first).partition { |_, shadower| sibling_keg_name(shadower) }
// 138:     blocks = []
// 139:
// 140:     if external.any?
// 141:       lines = external.map { |name, shadower| "  #{name} (shadowed by #{shadower})" }
// 142:       blocks << <<~EOS
// 143:         The following #{formula.name} executables are shadowed by other commands earlier in your PATH:
// 144:         #{lines.join("\n")}
// 145:         Running these by name will not invoke the version provided by Homebrew.
// 146:       EOS
// 147:     end
// 148:
// 149:     if sibling.any?
// 150:       lines = sibling.map do |name, shadower|
// 151:         "  #{name} (shadowed by #{shadower} from #{sibling_keg_name(shadower)})"
// 152:       end
// 153:       blocks << <<~EOS
// 154:         The following #{formula.name} executables are shadowed by other linked Homebrew commands:
// 155:         #{lines.join("\n")}
// 156:         Running these by name will not invoke the version provided by this formula.
// 157:         Run `brew link #{formula.name}` to switch the active version to this keg.
// 158:       EOS
// 159:     end
// 160:
// 161:     s = blocks.join("\n").dup
// 162:     unless Homebrew::EnvConfig.no_env_hints?
// 163:       s << "Disable this behaviour by setting `HOMEBREW_NO_PATH_SHADOW_CHECK=1`.\n"
// 164:       s << "Hide these hints with `HOMEBREW_NO_ENV_HINTS=1` (see `man brew`).\n"
// 165:     end
// 166:     s
// 167:   end
// 168:
// 169:   private
// 170:
// 171:   sig { params(shadower: Pathname).returns(T.nilable(String)) }
// 172:   def sibling_keg_name(shadower)
// 173:     target = shadower.realpath
// 174:     return unless target.to_s.start_with?("#{HOMEBREW_CELLAR.realpath}/")
// 175:
// 176:     name = target.relative_path_from(HOMEBREW_CELLAR.realpath).each_filename.first
// 177:     return if name.nil? || name == formula.name
// 178:
// 179:     family = [
// 180:       formula.unversioned_formula_name,
// 181:       formula.name,
// 182:       *formula.versioned_formulae_names,
// 183:     ].compact
// 184:     name if family.include?(name)
// 185:   rescue Errno::ENOENT
// 186:     nil
// 187:   end
// 188:
// 189:   sig { returns(T::Array[[String, Pathname]]) }
// 190:   def shadowed_executables
// 191:     [formula.opt_bin, formula.opt_sbin].flat_map do |dir|
// 192:       next [] unless dir.directory?
// 193:
// 194:       dir.children.filter_map do |child|
// 195:         next if !child.file? || !child.executable?
// 196:
// 197:         name = child.basename.to_s
// 198:         found = which(name, ORIGINAL_PATHS)
// 199:         next unless found
// 200:         next if found.realpath == child.realpath
// 201:
// 202:         [name, found]
// 203:       rescue Errno::ENOENT
// 204:         nil
// 205:       end
// 206:     end
// 207:   end
// 208:
// 209:   sig { returns(T.nilable(Keg)) }
// 210:   def keg
// 211:     @keg ||= T.let([formula.prefix, formula.opt_prefix, formula.linked_keg].filter_map do |d|
// 212:       Keg.new(d.resolved_path)
// 213:     rescue
// 214:       nil
// 215:     end.first, T.nilable(Keg))
// 216:   end
// 217:
// 218:   sig { params(shell: Symbol).returns(T.nilable(String)) }
// 219:   def function_completion_caveats(shell)
// 220:     return unless (keg = self.keg)
// 221:     return unless which(shell.to_s, ORIGINAL_PATHS)
// 222:
// 223:     completion_installed = keg.completion_installed?(shell)
// 224:     functions_installed = keg.functions_installed?(shell)
// 225:     return if !completion_installed && !functions_installed
// 226:
// 227:     installed = []
// 228:     installed << "completions" if completion_installed
// 229:     installed << "functions" if functions_installed
// 230:
// 231:     root_dir = formula.keg_only? ? formula.opt_prefix : HOMEBREW_PREFIX
// 232:
// 233:     case shell
// 234:     when :bash
// 235:       <<~EOS
// 236:         Bash completion has been installed to:
// 237:           #{root_dir}/etc/bash_completion.d
// 238:       EOS
// 239:     when :fish
// 240:       fish_caveats = "fish #{installed.join(" and ")} have been installed to:"
// 241:       fish_caveats << "\n  #{root_dir}/share/fish/vendor_completions.d" if completion_installed
// 242:       fish_caveats << "\n  #{root_dir}/share/fish/vendor_functions.d" if functions_installed
// 243:       fish_caveats.freeze
// 244:     when :zsh
// 245:       <<~EOS
// 246:         zsh #{installed.join(" and ")} have been installed to:
// 247:           #{root_dir}/share/zsh/site-functions
// 248:       EOS
// 249:     when :pwsh
// 250:       <<~EOS
// 251:         PowerShell completion has been installed to:
// 252:           #{root_dir}/share/pwsh/completions
// 253:       EOS
// 254:     end
// 255:   end
// 256:
// 257:   sig { returns(T.nilable(String)) }
// 258:   def elisp_caveats
// 259:     return if formula.keg_only?
// 260:     return unless (keg = self.keg)
// 261:     return unless keg.elisp_installed?
// 262:
// 263:     <<~EOS
// 264:       Emacs Lisp files have been installed to:
// 265:         #{HOMEBREW_PREFIX}/share/emacs/site-lisp/#{formula.name}
// 266:     EOS
// 267:   end
// 268:
// 269:   sig { returns(T.nilable(String)) }
// 270:   def service_caveats
// 271:     return if !formula.service? && !Utils::Service.installed?(formula) && !keg&.plist_installed?
// 272:     return if formula.service? && !formula.service.command? && !Utils::Service.installed?(formula)
// 273:
// 274:     s = []
// 275:
// 276:     # Brew services only works with these two tools
// 277:     return <<~EOS if !Utils::Service.systemctl? && !Utils::Service.launchctl? && formula.service.command?
// 278:       #{Formatter.warning("Warning:")} #{formula.name} provides a service which can only be used on macOS or systemd!
// 279:       You can manually execute the service instead with:
// 280:         #{formula.service.manual_command}
// 281:     EOS
// 282:
// 283:     startup = formula.service.requires_root?
// 284:     if Utils::Service.running?(formula)
// 285:       s << "To restart #{formula.full_name} after an upgrade:"
// 286:       s << "  #{"sudo " if startup}brew services restart #{formula.full_name}"
// 287:     elsif startup
// 288:       s << "To start #{formula.full_name} now and restart at startup:"
// 289:       s << "  sudo brew services start #{formula.full_name}"
// 290:     else
// 291:       s << "To start #{formula.full_name} now and restart at login:"
// 292:       s << "  brew services start #{formula.full_name}"
// 293:     end
// 294:
// 295:     if formula.service.command?
// 296:       s << "Or, if you don't want/need a background service you can just run:"
// 297:       s << "  #{formula.service.manual_command}"
// 298:     end
// 299:
// 300:     # pbpaste is the system clipboard tool on macOS and fails with `tmux` by default
// 301:     # check if this is being run under `tmux` to avoid failing
// 302:     if ENV.fetch("HOMEBREW_TMUX", false) && File.executable?("/usr/bin/pbpaste") && !quiet_system("/usr/bin/pbpaste")
// 303:       s << "" << "WARNING: brew services will fail when run under tmux."
// 304:     end
// 305:
// 306:     "#{s.join("\n")}\n" unless s.empty?
// 307:   end
// 308: end
