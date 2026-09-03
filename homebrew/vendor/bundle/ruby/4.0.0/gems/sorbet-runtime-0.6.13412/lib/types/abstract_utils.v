module types

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/abstract_utils.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct AbstractMethodInfo {
pub:
	name        string
	owner       string
	mode        string
	actual_mode string
	visibility  string
}

pub struct AbstractModuleInfo {
pub:
	name          string
	abstract_type string
	ancestors     [][]AbstractMethodInfo
}

pub fn abstract_module(info AbstractModuleInfo) bool {
	return info.abstract_type != ''
}

pub fn abstract_method(method AbstractMethodInfo) bool {
	return method.mode.trim_string_left(':') == 'abstract'
}

pub fn declared_abstract_methods(info AbstractModuleInfo) []AbstractMethodInfo {
	mut methods := []AbstractMethodInfo{}
	for ancestor_methods in info.ancestors {
		// The Ruby traversal combines private methods before public/protected
		// instance methods for every ancestor.
		for visibility in ['private', 'public', 'protected'] {
			for method in ancestor_methods {
				if method.visibility == visibility && abstract_method(method) {
					methods << method
				}
			}
		}
	}
	return methods
}

pub fn unresolved_abstract_methods(info AbstractModuleInfo) []AbstractMethodInfo {
	return declared_abstract_methods(info).filter(it.actual_mode.trim_string_left(':') == 'abstract')
}

fn abstract_method_from_value(value brew_runtime.Value) AbstractMethodInfo {
	return AbstractMethodInfo{
		name: value.attribute('name') or { value.as_string() }
		owner: value.attribute('owner') or { '' }
		mode: value.attribute('mode') or { '' }
		actual_mode: value.attribute('actual_mode') or { value.attribute('mode') or { '' } }
		visibility: value.attribute('visibility') or { 'public' }
	}
}

fn abstract_method_value(method AbstractMethodInfo) brew_runtime.Value {
	return brew_runtime.structured_value('UnboundMethod', method.name, {
		'name':        method.name
		'owner':       method.owner
		'mode':        method.mode
		'actual_mode': method.actual_mode
		'visibility':  method.visibility
	})
}

fn abstract_module_from_value(value brew_runtime.Value) AbstractModuleInfo {
	mut ancestors := [][]AbstractMethodInfo{}
	ancestor_values := value.map_data['ancestors'] or { brew_runtime.array_value([]) }
	for ancestor in ancestor_values.as_array() or { []brew_runtime.Value{} } {
		mut methods := []AbstractMethodInfo{}
		for method in ancestor.as_array() or { []brew_runtime.Value{} } {
			methods << abstract_method_from_value(method)
		}
		ancestors << methods
	}
	if ancestors.len == 0 && value.array_data.len > 0 {
		ancestors << value.array_data.map(abstract_method_from_value(it))
	}
	return AbstractModuleInfo{
		name: value.as_string()
		abstract_type: value.attribute('abstract_type') or { '' }
		ancestors: ancestors
	}
}

fn abstract_methods_value(methods []AbstractMethodInfo) brew_runtime.Value {
	return brew_runtime.array_value(methods.map(abstract_method_value(it)))
}

// Ruby method `self.abstract_module?(mod)` at line 14.
pub fn ruby_abstract_utils_l14_d1_self_abstract_module(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(abstract_module(abstract_module_from_value(args[0])))
}

// Ruby method `self.abstract_method?(method)` at line 18.
pub fn ruby_abstract_utils_l18_d2_self_abstract_method(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(abstract_method(abstract_method_from_value(args[0])))
}

// Ruby method `self.abstract_methods_for(mod)` at line 25.
pub fn ruby_abstract_utils_l25_d3_self_abstract_methods_for(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.array_value([])
	}
	return abstract_methods_value(unresolved_abstract_methods(abstract_module_from_value(args[0])))
}

// Ruby method `self.declared_abstract_methods_for(mod)` at line 39.
pub fn ruby_abstract_utils_l39_d4_self_declared_abstract_methods_for(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.array_value([])
	}
	return abstract_methods_value(declared_abstract_methods(abstract_module_from_value(args[0])))
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::AbstractUtils
// 5:   Methods = T::Private::Methods
// 6:
// 7:   # Returns whether a module is declared as abstract. After the module is finished being declared,
// 8:   # this is equivalent to whether it has any abstract methods that haven't been implemented
// 9:   # (because we validate that and raise an error otherwise).
// 10:   #
// 11:   # Note that checking `mod.is_a?(Abstract::Hooks)` is not a safe substitute for this method; when
// 12:   # a class extends `Abstract::Hooks`, all of its subclasses, including the eventual concrete
// 13:   # ones, will still have `Abstract::Hooks` as an ancestor.
// 14:   def self.abstract_module?(mod)
// 15:     !T::Private::Abstract::Data.get(mod, :abstract_type).nil?
// 16:   end
// 17:
// 18:   def self.abstract_method?(method)
// 19:     signature = Methods.signature_for_method(method)
// 20:     signature&.mode == Methods::Modes.abstract
// 21:   end
// 22:
// 23:   # Given a module, returns the set of methods declared as abstract (in itself or ancestors)
// 24:   # that have not been implemented.
// 25:   def self.abstract_methods_for(mod)
// 26:     declared_methods = declared_abstract_methods_for(mod)
// 27:     declared_methods.select do |declared_method|
// 28:       actual_method = mod.instance_method(declared_method.name)
// 29:       # Note that in the case where an abstract method is overridden by another abstract method,
// 30:       # this method will return them both. This is intentional to ensure we validate the final
// 31:       # implementation against all declarations of an abstract method (they might not all have the
// 32:       # same signature).
// 33:       abstract_method?(actual_method)
// 34:     end
// 35:   end
// 36:
// 37:   # Given a module, returns the set of methods declared as abstract (in itself or ancestors)
// 38:   # regardless of whether they have been implemented.
// 39:   def self.declared_abstract_methods_for(mod)
// 40:     methods = []
// 41:     mod.ancestors.each do |ancestor|
// 42:       ancestor_methods = ancestor.private_instance_methods(false) + ancestor.instance_methods(false)
// 43:       ancestor_methods.each do |method_name|
// 44:         method = ancestor.instance_method(method_name)
// 45:         methods << method if abstract_method?(method)
// 46:       end
// 47:     end
// 48:     methods
// 49:   end
// 50: end
