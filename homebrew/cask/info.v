module cask

import brew_runtime

// Translated from Homebrew/brew `cask/info.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.get_info(cask)` at line 13.
pub fn ruby_info_l13_d1_self_get_info(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.get_info', ...args)
}

// Ruby method `self.info(cask, args:)` at line 43.
pub fn ruby_info_l43_d2_self_info(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.info', ...args)
}

// Ruby method `self.title_info(cask, installed:)` at line 53.
pub fn ruby_info_l53_d3_self_title_info(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.title_info', ...args)
}

// Ruby method `self.installation_info(cask, installed:)` at line 67.
pub fn ruby_info_l67_d4_self_installation_info(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.installation_info', ...args)
}

// Ruby method `self.deps_info(cask, mark_uninstalled: true)` at line 88.
pub fn ruby_info_l88_d5_self_deps_info(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.deps_info', ...args)
}

// Ruby method `self.decorate_dependency(dep, installed:, mark_uninstalled: true)` at line 137.
pub fn ruby_info_l137_d6_self_decorate_dependency(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.decorate_dependency', ...args)
}

// Ruby method `self.requirements_info(cask, mark_uninstalled: true)` at line 142.
pub fn ruby_info_l142_d7_self_requirements_info(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.requirements_info', ...args)
}

// Ruby method `self.language_info(cask)` at line 182.
pub fn ruby_info_l182_d8_self_language_info(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.language_info', ...args)
}

// Ruby method `self.repo_info(cask)` at line 192.
pub fn ruby_info_l192_d9_self_repo_info(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.repo_info', ...args)
}

// Ruby method `self.artifact_info(cask)` at line 205.
pub fn ruby_info_l205_d10_self_artifact_info(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.artifact_info', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "json"
// 5: require "cmd/info"
// 6: require "utils/output"
// 7:
// 8: module Cask
// 9:   class Info
// 10:     extend ::Utils::Output::Mixin
// 11:
// 12:     sig { params(cask: Cask).returns(String) }
// 13:     def self.get_info(cask)
// 14:       require "cask/installer"
// 15:
// 16:       installed = cask.installed?
// 17:       output = "#{title_info(cask, installed:)}\n"
// 18:       output << "#{cask.desc}\n" if cask.desc
// 19:       output << "#{Formatter.url(cask.homepage)}\n" if cask.homepage
// 20:       deprecate_disable = DeprecateDisable.message(cask)
// 21:       if deprecate_disable.present?
// 22:         deprecate_disable.tap { |message| message[0] = message[0].upcase }
// 23:         output << "#{deprecate_disable}\n"
// 24:       end
// 25:       output << "#{installation_info(cask, installed:)}\n"
// 26:       metadata = Homebrew::Cmd::Info.metadata_lines(cask)
// 27:       output << "#{metadata.join("\n")}\n" if metadata.present?
// 28:       repo = repo_info(cask)
// 29:       output << "#{repo}\n" if repo
// 30:       deps = deps_info(cask, mark_uninstalled: installed)
// 31:       output << deps if deps
// 32:       requirements = requirements_info(cask, mark_uninstalled: installed)
// 33:       output << requirements if requirements
// 34:       language = language_info(cask)
// 35:       output << language if language
// 36:       output << "#{artifact_info(cask)}\n"
// 37:       caveats = Installer.caveats(cask)
// 38:       output << caveats if caveats
// 39:       output
// 40:     end
// 41:
// 42:     sig { params(cask: Cask, args: Homebrew::Cmd::Info::Args).void }
// 43:     def self.info(cask, args:)
// 44:       puts get_info(cask)
// 45:
// 46:       return unless cask.tap&.core_cask_tap?
// 47:
// 48:       require "utils/analytics"
// 49:       ::Utils::Analytics.cask_output(cask, args:)
// 50:     end
// 51:
// 52:     sig { params(cask: Cask, installed: T::Boolean).returns(String) }
// 53:     def self.title_info(cask, installed:)
// 54:       name_with_status = if installed
// 55:         pretty_installed(cask.token)
// 56:       else
// 57:         pretty_uninstalled(cask.token)
// 58:       end
// 59:       title = oh1_title(name_with_status).to_s
// 60:       title += " (#{cask.name.join(", ")})" unless cask.name.empty?
// 61:       title += ": #{cask.version}"
// 62:       title += " (auto_updates)" if cask.auto_updates
// 63:       title
// 64:     end
// 65:
// 66:     sig { params(cask: Cask, installed: T::Boolean).returns(String) }
// 67:     def self.installation_info(cask, installed:)
// 68:       return "Not installed" unless installed
// 69:       return "No installed version" unless (installed_version = cask.installed_version).present?
// 70:
// 71:       versioned_staged_path = cask.caskroom_path.join(installed_version)
// 72:       tab = Tab.for_cask(cask)
// 73:
// 74:       unless versioned_staged_path.exist?
// 75:         return "#{Homebrew::Cmd::Info.installation_status(tab)}\n" \
// 76:                "#{versioned_staged_path} (#{Formatter.error("does not exist")})\n"
// 77:       end
// 78:
// 79:       path_details = versioned_staged_path.children.sum(&:disk_usage)
// 80:
// 81:       info = [Homebrew::Cmd::Info.installation_status(tab)]
// 82:       info << "#{versioned_staged_path} (#{Formatter.disk_usage_readable(path_details)})"
// 83:       info << "  #{tab}" if tab.tabfile&.exist?
// 84:       info.join("\n")
// 85:     end
// 86:
// 87:     sig { params(cask: Cask, mark_uninstalled: T::Boolean).returns(T.nilable(String)) }
// 88:     def self.deps_info(cask, mark_uninstalled: true)
// 89:       depends_on = cask.depends_on
// 90:
// 91:       formula_deps = Array(depends_on[:formula]).map do |dep|
// 92:         name = dep.to_s
// 93:         rack = HOMEBREW_CELLAR/::Utils.name_from_full_name(name)
// 94:         decorate_dependency(
// 95:           name,
// 96:           installed:        rack.directory? && !rack.subdirs.empty?,
// 97:           mark_uninstalled:,
// 98:         )
// 99:       end
// 100:
// 101:       cask_deps = Array(depends_on[:cask]).map do |dep|
// 102:         name = dep.to_s
// 103:         decorate_dependency(
// 104:           "#{name} (cask)",
// 105:           installed:        (Caskroom.path/name).directory?,
// 106:           mark_uninstalled:,
// 107:         )
// 108:       end
// 109:
// 110:       all_deps = formula_deps + cask_deps
// 111:       return if all_deps.empty?
// 112:
// 113:       formula_dependencies = T.let(Set.new, T::Set[String])
// 114:       cask_dependencies = T.let(Set.new, T::Set[String])
// 115:       Homebrew::Cmd::Info.collect_cask_dependency_names(cask, formula_dependencies, cask_dependencies,
// 116:                                                         Set[cask.token])
// 117:       recursive_count = formula_dependencies.count + cask_dependencies.count
// 118:       lines = T.let(
// 119:         [ohai_title("Dependencies").to_s, "Required (#{all_deps.count}): #{all_deps.join(", ")}"],
// 120:         T::Array[String],
// 121:       )
// 122:       unless recursive_count.zero?
// 123:         installed_count = formula_dependencies.count do |name|
// 124:           rack = HOMEBREW_CELLAR/::Utils.name_from_full_name(name)
// 125:           rack.directory? && !rack.subdirs.empty?
// 126:         end + cask_dependencies.count do |name|
// 127:           (Caskroom.path/name).directory?
// 128:         end
// 129:         lines << "Recursive Runtime (#{recursive_count}): " \
// 130:                  "#{Homebrew::Cmd::Info.dependency_status_counts(installed_count, recursive_count)}"
// 131:       end
// 132:
// 133:       "#{lines.join("\n")}\n"
// 134:     end
// 135:
// 136:     sig { params(dep: String, installed: T::Boolean, mark_uninstalled: T::Boolean).returns(String) }
// 137:     def self.decorate_dependency(dep, installed:, mark_uninstalled: true)
// 138:       pretty_install_status(dep, installed:, mark_uninstalled:)
// 139:     end
// 140:
// 141:     sig { params(cask: Cask, mark_uninstalled: T::Boolean).returns(T.nilable(String)) }
// 142:     def self.requirements_info(cask, mark_uninstalled: true)
// 143:       require "cask_dependent"
// 144:
// 145:       requirements = CaskDependent.new(cask).requirements.grep_v(CaskDependent::Requirement)
// 146:       return if requirements.empty?
// 147:
// 148:       supports_linux = cask.supports_linux?
// 149:       output = "#{ohai_title("Requirements")}\n"
// 150:       %w[build required recommended optional].each do |type|
// 151:         reqs = case type
// 152:         when "build"
// 153:           requirements.select(&:build?)
// 154:         when "required"
// 155:           requirements.select(&:required?)
// 156:         when "recommended"
// 157:           requirements.select(&:recommended?)
// 158:         when "optional"
// 159:           requirements.select(&:optional?)
// 160:         else
// 161:           []
// 162:         end
// 163:         next if reqs.empty?
// 164:
// 165:         output << "#{type.capitalize}: #{reqs.map do |requirement|
// 166:           requirement_s = if requirement.is_a?(MacOSRequirement) && !supports_linux
// 167:             requirement.display_s.delete_suffix(" (or Linux)")
// 168:           else
// 169:             requirement.display_s
// 170:           end
// 171:           pretty_install_status(
// 172:             requirement_s,
// 173:             installed:        requirement.satisfied?,
// 174:             mark_uninstalled:,
// 175:           )
// 176:         end.join(", ")}\n"
// 177:       end
// 178:       output
// 179:     end
// 180:
// 181:     sig { params(cask: Cask).returns(T.nilable(String)) }
// 182:     def self.language_info(cask)
// 183:       return if cask.languages.empty?
// 184:
// 185:       <<~EOS
// 186:         #{ohai_title("Languages")}
// 187:         #{cask.languages.join(", ")}
// 188:       EOS
// 189:     end
// 190:
// 191:     sig { params(cask: Cask).returns(T.nilable(String)) }
// 192:     def self.repo_info(cask)
// 193:       return unless (tap = cask.tap)
// 194:
// 195:       url = if tap.custom_remote? && !tap.remote.nil?
// 196:         tap.remote
// 197:       else
// 198:         "#{tap.default_remote}/blob/HEAD/#{tap.relative_cask_path(cask.token)}"
// 199:       end
// 200:
// 201:       "From: #{Formatter.url(url)}"
// 202:     end
// 203:
// 204:     sig { params(cask: Cask).returns(String) }
// 205:     def self.artifact_info(cask)
// 206:       artifact_output = ohai_title("Artifacts").dup
// 207:       cask.artifacts.each do |artifact|
// 208:         next unless artifact.respond_to?(:install_phase)
// 209:         next unless DSL::ORDINARY_ARTIFACT_CLASSES.include?(artifact.class)
// 210:
// 211:         artifact_output << "\n" << artifact.to_s
// 212:       end
// 213:       artifact_output.freeze
// 214:     end
// 215:   end
// 216: end
