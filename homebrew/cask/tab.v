module cask

import brew_runtime

// Translated from Homebrew/brew `cask/tab.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_accessor `attr_accessor :uninstall_flight_blocks` at line 12.
pub fn ruby_tab_l12_d1_uninstall_flight_blocks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uninstall_flight_blocks', ...args)
}

// Ruby attr_accessor `attr_accessor :uninstall_flight_blocks` at line 12.
pub fn ruby_tab_l12_d2_uninstall_flight_blocks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uninstall_flight_blocks=', ...args)
}

// Ruby attr_accessor `attr_accessor :uninstall_artifacts` at line 15.
pub fn ruby_tab_l15_d3_uninstall_artifacts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uninstall_artifacts', ...args)
}

// Ruby attr_accessor `attr_accessor :uninstall_artifacts` at line 15.
pub fn ruby_tab_l15_d4_uninstall_artifacts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uninstall_artifacts=', ...args)
}

// Ruby method `initialize(uninstall_flight_blocks: nil, uninstall_artifacts: nil, **rest)` at line 22.
pub fn ruby_tab_l22_d5_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `self.create(formula_or_cask)` at line 31.
pub fn ruby_tab_l31_d6_self_create(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.create', ...args)
}

// Ruby method `self.for_cask(cask)` at line 48.
pub fn ruby_tab_l48_d7_self_for_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.for_cask', ...args)
}

// Ruby method `self.empty` at line 66.
pub fn ruby_tab_l66_d8_self_empty(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.empty', ...args)
}

// Ruby method `self.runtime_deps_hash(cask)` at line 76.
pub fn ruby_tab_l76_d9_self_runtime_deps_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.runtime_deps_hash', ...args)
}

// Ruby method `version` at line 104.
pub fn ruby_tab_l104_d10_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('version', ...args)
}

// Ruby method `to_json(*_args)` at line 109.
pub fn ruby_tab_l109_d11_to_json(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_json', ...args)
}

// Ruby method `to_s` at line 128.
pub fn ruby_tab_l128_d12_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "tab"
// 5: require "utils/topological_hash"
// 6:
// 7: module Cask
// 8:   class Tab < ::AbstractTab
// 9:     Cache = type_template { { fixed: T::Hash[T.any(Pathname, String), T.untyped] } }
// 10:
// 11:     sig { returns(T.nilable(T::Boolean)) }
// 12:     attr_accessor :uninstall_flight_blocks
// 13:
// 14:     sig { returns(T.nilable(T::Array[T.untyped])) }
// 15:     attr_accessor :uninstall_artifacts
// 16:
// 17:     sig {
// 18:       params(uninstall_flight_blocks: T.nilable(T::Boolean),
// 19:              uninstall_artifacts:     T.nilable(T::Array[T.untyped]),
// 20:              rest:                    T.untyped).void
// 21:     }
// 22:     def initialize(uninstall_flight_blocks: nil, uninstall_artifacts: nil, **rest)
// 23:       @uninstall_flight_blocks = uninstall_flight_blocks
// 24:       @uninstall_artifacts = uninstall_artifacts
// 25:
// 26:       super(**rest)
// 27:     end
// 28:
// 29:     # Instantiates a {Tab} for a new installation of a cask.
// 30:     sig { override.params(formula_or_cask: T.any(Formula, Cask)).returns(T.attached_class) }
// 31:     def self.create(formula_or_cask)
// 32:       cask = T.cast(formula_or_cask, Cask)
// 33:       tab = super
// 34:
// 35:       tab.tabfile = cask.metadata_main_container_path/FILENAME
// 36:       tab.uninstall_flight_blocks = cask.uninstall_flight_blocks?
// 37:       tab.runtime_dependencies = Tab.runtime_deps_hash(cask)
// 38:       tab.source["version"] = cask.version.to_s
// 39:       tab.source["path"] = cask.sourcefile_path.to_s
// 40:       tab.uninstall_artifacts = cask.artifacts_list(uninstall_only: true)
// 41:
// 42:       tab
// 43:     end
// 44:
// 45:     # Returns a {Tab} for an already installed cask,
// 46:     # or a fake one if the cask is not installed.
// 47:     sig { params(cask: Cask).returns(T.attached_class) }
// 48:     def self.for_cask(cask)
// 49:       path = cask.metadata_main_container_path/FILENAME
// 50:
// 51:       return from_file(path) if path.exist?
// 52:
// 53:       tab = empty
// 54:       tab.source = {
// 55:         "path"         => cask.sourcefile_path.to_s,
// 56:         "tap"          => cask.tap&.name,
// 57:         "tap_git_head" => cask.tap_git_head,
// 58:         "version"      => cask.version.to_s,
// 59:       }
// 60:       tab.uninstall_artifacts = cask.artifacts_list(uninstall_only: true)
// 61:
// 62:       tab
// 63:     end
// 64:
// 65:     sig { returns(T.attached_class) }
// 66:     def self.empty
// 67:       tab = super
// 68:       tab.uninstall_flight_blocks = false
// 69:       tab.uninstall_artifacts = []
// 70:       tab.source["version"] = nil
// 71:
// 72:       tab
// 73:     end
// 74:
// 75:     sig { params(cask: Cask).returns(T::Hash[Symbol, T::Array[T::Hash[String, T.untyped]]]) }
// 76:     def self.runtime_deps_hash(cask)
// 77:       cask_and_formula_dep_graph = ::Utils::TopologicalHash.graph_package_dependencies(cask)
// 78:       cask_deps, formula_deps = T.cast(cask_and_formula_dep_graph.values.flatten.uniq.partition do |dep|
// 79:         dep.is_a?(Cask)
// 80:       end, [T::Array[Cask], T::Array[Formula]])
// 81:
// 82:       runtime_deps = {}
// 83:
// 84:       if cask_deps.any?
// 85:         runtime_deps[:cask] = cask_deps.map do |dep|
// 86:           {
// 87:             "full_name"         => dep.full_name,
// 88:             "version"           => dep.version.to_s,
// 89:             "declared_directly" => cask.depends_on.cask.include?(dep.full_name),
// 90:           }
// 91:         end
// 92:       end
// 93:
// 94:       if formula_deps.any?
// 95:         runtime_deps[:formula] = formula_deps.map do |dep|
// 96:           formula_to_dep_hash(dep, cask.depends_on.formula)
// 97:         end
// 98:       end
// 99:
// 100:       runtime_deps
// 101:     end
// 102:
// 103:     sig { returns(T.nilable(String)) }
// 104:     def version
// 105:       source["version"]
// 106:     end
// 107:
// 108:     sig { params(_args: T.untyped).returns(String) }
// 109:     def to_json(*_args)
// 110:       attributes = {
// 111:         "homebrew_version"         => homebrew_version,
// 112:         "loaded_from_api"          => loaded_from_api,
// 113:         "loaded_from_internal_api" => loaded_from_internal_api,
// 114:         "uninstall_flight_blocks"  => uninstall_flight_blocks,
// 115:         "installed_on_request"     => installed_on_request,
// 116:         "time"                     => time,
// 117:         "runtime_dependencies"     => runtime_dependencies,
// 118:         "source"                   => source,
// 119:         "arch"                     => arch,
// 120:         "uninstall_artifacts"      => uninstall_artifacts,
// 121:         "built_on"                 => built_on,
// 122:       }
// 123:
// 124:       JSON.pretty_generate(attributes)
// 125:     end
// 126:
// 127:     sig { returns(String) }
// 128:     def to_s
// 129:       s = ["Installed"]
// 130:       if loaded_from_internal_api
// 131:         s << "using the internal formulae.brew.sh API"
// 132:       elsif loaded_from_api
// 133:         s << "using the formulae.brew.sh API"
// 134:       end
// 135:       if (t = time)
// 136:         s << Time.at(t).strftime("on %Y-%m-%d at %H:%M:%S")
// 137:       end
// 138:       s.join(" ")
// 139:     end
// 140:   end
// 141: end
