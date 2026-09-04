module homebrew

import ruby

// Translated from Homebrew/brew `missing.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct MissingDependency {
pub:
	full_name string
}

pub struct MissingFormula {
pub:
	full_name            string
	display_name         string
	missing_dependencies []string
}

pub struct MissingCask {
pub:
	full_name            string
	display_name         string
	runtime_dependencies map[string][]MissingDependency
}

fn missing_dependency_name(full_name string) string {
	parts := full_name.split('/')
	return parts.last()
}

pub fn missing_cask_dependencies(cask MissingCask, hide []string, installed_formulae []string,
	installed_casks []string) []string {
	mut missing := []string{}
	for dependency_type, dependencies in cask.runtime_dependencies {
		for dependency in dependencies {
			if dependency.full_name.trim_space() == '' {
				continue
			}
			name := missing_dependency_name(dependency.full_name)
			installed := match dependency_type {
				'cask' { name in installed_casks }
				'formula' { name in installed_formulae }
				else { true }
			}
			if name !in hide && installed {
				continue
			}
			missing << dependency.full_name
		}
	}
	missing.sort()
	return missing
}

pub fn missing_dependencies(formulae []MissingFormula, casks []MissingCask, hide []string,
	installed_formulae []string, installed_casks []string) map[string][]string {
	mut missing := map[string][]string{}
	for formula in formulae {
		if formula.missing_dependencies.len > 0 {
			missing[formula.full_name] = formula.missing_dependencies.clone()
		}
	}
	for cask in casks {
		dependencies := missing_cask_dependencies(cask, hide, installed_formulae, installed_casks)
		if dependencies.len > 0 {
			missing[cask.full_name] = dependencies
		}
	}
	return missing
}

fn missing_formulae_from_value(value ruby.Value) []MissingFormula {
	return value.array_data.map(MissingFormula{
		full_name: it.attributes['full_name'] or { it.as_string() }
		display_name: it.attributes['display_name'] or { it.as_string() }
		missing_dependencies: (it.attributes['missing_dependencies'] or { '' }).split(',').filter(it != '')
	})
}

fn missing_cask_from_value(value ruby.Value) MissingCask {
	mut dependencies := map[string][]MissingDependency{}
	for dependency_type, list in value.map_data {
		dependencies[dependency_type] = list.array_data.map(MissingDependency{
			full_name: it.attributes['full_name'] or { it.as_string() }
		})
	}
	return MissingCask{
		full_name: value.attributes['full_name'] or { value.as_string() }
		display_name: value.attributes['display_name'] or { value.as_string() }
		runtime_dependencies: dependencies
	}
}

fn missing_casks_from_value(value ruby.Value) []MissingCask {
	return value.array_data.map(missing_cask_from_value(it))
}

fn missing_map_value(values map[string][]string) ruby.Value {
	mut result := map[string]ruby.Value{}
	for name, dependencies in values {
		result[name] = ruby.string_array_value(dependencies)
	}
	return ruby.map_value(result)
}

// Ruby method `self.deps(formulae, casks = [], hide = [], &_block)` at line 16.
pub fn ruby_missing_l16_d1_self_deps(args ...ruby.Value) ruby.Value {
	formulae := if args.len > 0 { missing_formulae_from_value(args[0]) } else { []MissingFormula{} }
	casks := if args.len > 1 { missing_casks_from_value(args[1]) } else { []MissingCask{} }
	hide := if args.len > 2 { args[2].as_string_array() or { []string{} } } else { []string{} }
	installed_formulae := if args.len > 3 {
		args[3].as_string_array() or { []string{} }
	} else {
		[]string{}
	}
	installed_casks := if args.len > 4 {
		args[4].as_string_array() or { []string{} }
	} else {
		[]string{}
	}
	return missing_map_value(missing_dependencies(formulae, casks, hide, installed_formulae, installed_casks))
}

// Ruby method `self.cask_deps(cask, hide)` at line 37.
pub fn ruby_missing_l37_d2_self_cask_deps(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_array_value([])
	}
	hide := if args.len > 1 { args[1].as_string_array() or { []string{} } } else { []string{} }
	installed_formulae := if args.len > 2 {
		args[2].as_string_array() or { []string{} }
	} else {
		[]string{}
	}
	installed_casks := if args.len > 3 {
		args[3].as_string_array() or { []string{} }
	} else {
		[]string{}
	}
	return ruby.string_array_value(missing_cask_dependencies(missing_cask_from_value(args[0]), hide, installed_formulae, installed_casks))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "formula"
// 5: require "utils"
// 6: require "cask/caskroom"
// 7: require "cask/tab"
// 8:
// 9: module Homebrew
// 10:   module Missing
// 11:     sig {
// 12:       params(formulae: T::Array[Formula], casks: T::Array[Cask::Cask], hide: T::Array[String], _block: T.nilable(
// 13:         T.proc.params(package_name: String, missing_dependencies: T::Array[String]).void,
// 14:       )).returns(T::Hash[String, T::Array[String]])
// 15:     }
// 16:     def self.deps(formulae, casks = [], hide = [], &_block)
// 17:       missing = {}
// 18:       formulae.each do |formula|
// 19:         missing_dependencies = formula.missing_dependencies(hide: hide).map(&:to_s)
// 20:         next if missing_dependencies.empty?
// 21:
// 22:         yield formula.full_name, missing_dependencies if block_given?
// 23:         missing[formula.full_name] = missing_dependencies
// 24:       end
// 25:
// 26:       casks.each do |cask|
// 27:         missing_dependencies = cask_deps(cask, hide)
// 28:         next if missing_dependencies.empty?
// 29:
// 30:         yield cask.full_name, missing_dependencies if block_given?
// 31:         missing[cask.full_name] = missing_dependencies
// 32:       end
// 33:       missing
// 34:     end
// 35:
// 36:     sig { params(cask: Cask::Cask, hide: T::Array[String]).returns(T::Array[String]) }
// 37:     def self.cask_deps(cask, hide)
// 38:       tab_deps = T.let(Cask::Tab.for_cask(cask).runtime_dependencies, T.untyped)
// 39:       return [] unless tab_deps.is_a?(Hash)
// 40:
// 41:       tab_deps.keys.flat_map do |type|
// 42:         deps = tab_deps[type]
// 43:         next [] unless deps.is_a?(Array)
// 44:
// 45:         deps.filter_map do |dep|
// 46:           next unless dep.is_a?(Hash)
// 47:
// 48:           full_name = T.cast(dep["full_name"], T.nilable(String))
// 49:           next if full_name.blank?
// 50:
// 51:           name = Utils.name_from_full_name(full_name)
// 52:           installed = case type.to_s
// 53:           when "cask"
// 54:             (Cask::Caskroom.path/name).directory?
// 55:           when "formula"
// 56:             (HOMEBREW_CELLAR/name).directory?
// 57:           else
// 58:             true
// 59:           end
// 60:           next if hide.exclude?(name) && installed
// 61:
// 62:           full_name
// 63:         end
// 64:       end.sort
// 65:     end
// 66:     private_class_method :cask_deps
// 67:   end
// 68: end
