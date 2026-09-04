module private

import ruby
import regex
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/private/sealed.rb`.
// The original source is retained below until every stub has a typed V body.
struct SealedEntry {
	declaration_file string
	subclasses       []ruby.Value
	cached_set       []ruby.Value
	frozen           bool
}

@[heap]
pub struct SealedRegistry {
	mutex &sync.Mutex = sync.new_mutex()
mut:
	entries map[string]SealedEntry
}

pub fn new_sealed_registry() &SealedRegistry {
	return &SealedRegistry{}
}

const sealed_registry_global = new_sealed_registry()

pub fn (mut registry SealedRegistry) declare(id string, name string, is_module bool,
	is_final bool, declaration_file string) ! {
	if !is_module {
		return error('${name} is not a class or module and cannot be declared `sealed!`')
	}
	registry.mutex.lock()
	defer {
		registry.mutex.unlock()
	}
	if id in registry.entries {
		return error('${name} was already declared `sealed!` and cannot be re-declared `sealed!`')
	}
	if is_final {
		return error('${name} was already declared `final!` and cannot be declared `sealed!`')
	}
	if declaration_file == '' {
		return error("Couldn't determine declaration file for sealed class.")
	}
	registry.entries[id] = SealedEntry{
		declaration_file: declaration_file
	}
}

pub fn (mut registry SealedRegistry) sealed_module(id string) bool {
	registry.mutex.lock()
	defer {
		registry.mutex.unlock()
	}
	return id in registry.entries
}

fn sealed_path_matches(pattern string, path string) bool {
	mut expression := regex.regex_opt(pattern) or { return path.contains(pattern) }
	return expression.matches_string(path)
}

pub fn (mut registry SealedRegistry) add_subclass(id string, parent_name string,
	child ruby.Value, verb string, caller_path string, whitelist []string) ! {
	registry.mutex.lock()
	defer {
		registry.mutex.unlock()
	}
	entry := registry.entries[id] or {
		return error('${parent_name} does not seem to be a sealed module (${verb} by ${child.as_string()})')
	}
	if caller_path == '' {
		return error('Could not use backtrace to determine file for ${verb} child ${child.as_string()}')
	}
	if !caller_path.starts_with(entry.declaration_file) && !whitelist.any(sealed_path_matches(it, caller_path)) {
		return error('${parent_name} was declared sealed and can only be ${verb} in ${entry.declaration_file}, not ${caller_path}')
	}
	mut subclasses := entry.subclasses.clone()
	subclasses << child
	registry.entries[id] = SealedEntry{
		declaration_file: entry.declaration_file
		subclasses: subclasses
		cached_set: entry.cached_set.clone()
		frozen: entry.frozen
	}
}

pub fn (mut registry SealedRegistry) sealed_subclasses(id string) []ruby.Value {
	registry.mutex.lock()
	defer {
		registry.mutex.unlock()
	}
	entry := registry.entries[id] or { return []ruby.Value{} }
	if entry.frozen {
		return entry.cached_set.clone()
	}
	mut unique := []ruby.Value{}
	mut seen := map[string]bool{}
	for subclass in entry.subclasses {
		key := subclass.attribute('object_id') or { '${subclass.type_name}:${subclass.as_string()}' }
		if key !in seen {
			unique << subclass
			seen[key] = true
		}
	}
	registry.entries[id] = SealedEntry{
		declaration_file: entry.declaration_file
		subclasses: entry.subclasses.clone()
		cached_set: unique.clone()
		frozen: true
	}
	return unique
}

fn sealed_registry() &SealedRegistry {
	return unsafe { &SealedRegistry(sealed_registry_global) }
}

fn sealed_value_id(value ruby.Value) string {
	return value.attribute('object_id') or { '${value.type_name}:${value.as_string()}' }
}

fn sealed_value_path(value ruby.Value) string {
	if value.type_name == 'NilClass' {
		return ''
	}
	return value.attribute('path') or { value.as_string() }
}

fn sealed_hook(args []ruby.Value, verb string) ruby.Value {
	if args.len < 2 {
		panic('sealed ${verb} hook requires parent and child')
	}
	parent := args[0]
	child := args[1]
	caller_path := if args.len > 2 { sealed_value_path(args[2]) } else { '' }
	whitelist := if args.len > 3 { args[3].as_string_array() or { []string{} } } else { []string{} }
	mut registry := sealed_registry()
	registry.add_subclass(sealed_value_id(parent), parent.as_string(), child, verb, caller_path, whitelist) or { panic(err.msg()) }
	return ruby.object_value('NilClass', 'nil')
}

fn sealed_subclasses_boundary(args []ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.array_value([])
	}
	mut registry := sealed_registry()
	return ruby.array_value(registry.sealed_subclasses(sealed_value_id(args[0])))
}

// Ruby method `inherited(child)` at line 6.
pub fn ruby_sealed_l6_d1_inherited(args ...ruby.Value) ruby.Value {
	return sealed_hook(args, 'inherited')
}

// Ruby method `sealed_subclasses` at line 13.
pub fn ruby_sealed_l13_d2_sealed_subclasses(args ...ruby.Value) ruby.Value {
	return sealed_subclasses_boundary(args)
}

// Ruby method `included(child)` at line 23.
pub fn ruby_sealed_l23_d3_included(args ...ruby.Value) ruby.Value {
	return sealed_hook(args, 'included')
}

// Ruby method `extended(child)` at line 30.
pub fn ruby_sealed_l30_d4_extended(args ...ruby.Value) ruby.Value {
	return sealed_hook(args, 'extended')
}

// Ruby method `sealed_subclasses` at line 37.
pub fn ruby_sealed_l37_d5_sealed_subclasses(args ...ruby.Value) ruby.Value {
	return sealed_subclasses_boundary(args)
}

// Ruby method `self.declare(mod, decl_file)` at line 49.
pub fn ruby_sealed_l49_d6_self_declare(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Sealed.declare requires a module and declaration file')
	}
	target := args[0]
	id := sealed_value_id(target)
	mut final_modules := final_registry()
	is_final := final_modules.final_module(id)
	mut registry := sealed_registry()
	registry.declare(id, target.as_string(), target.type_name in ['Class', 'Module'], is_final, args[1].as_string()) or { panic(err.msg()) }
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `self.sealed_module?(mod)` at line 67.
pub fn ruby_sealed_l67_d7_self_sealed_module(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.bool_value(false)
	}
	mut registry := sealed_registry()
	return ruby.bool_value(registry.sealed_module(sealed_value_id(args[0])))
}

// Ruby method `self.validate_inheritance(caller_loc, parent, child, verb)` at line 71.
pub fn ruby_sealed_l71_d8_self_validate_inheritance(args ...ruby.Value) ruby.Value {
	if args.len < 4 {
		panic('Sealed.validate_inheritance requires caller, parent, child, and verb')
	}
	parent := args[1]
	whitelist := if args.len > 4 { args[4].as_string_array() or { []string{} } } else { []string{} }
	mut registry := sealed_registry()
	registry.add_subclass(sealed_value_id(parent), parent.as_string(), args[2], args[3].as_string(), sealed_value_path(args[0]), whitelist) or { panic(err.msg()) }
	return ruby.object_value('NilClass', 'nil')
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: module T::Private::Sealed
// 5:   module NoInherit
// 6:     def inherited(child)
// 7:       super
// 8:       caller_loc = T::Private::CallerUtils.find_caller { |loc| loc.base_label != 'inherited' }
// 9:       T::Private::Sealed.validate_inheritance(caller_loc, self, child, 'inherited')
// 10:       @sorbet_sealed_module_all_subclasses << child
// 11:     end
// 12:
// 13:     def sealed_subclasses
// 14:       @sorbet_sealed_module_all_subclasses_set ||= # rubocop:disable Naming/MemoizedInstanceVariableName
// 15:         begin
// 16:           Kernel.require 'set'
// 17:           Set.new(@sorbet_sealed_module_all_subclasses).freeze
// 18:         end
// 19:     end
// 20:   end
// 21:
// 22:   module NoIncludeExtend
// 23:     def included(child)
// 24:       super
// 25:       caller_loc = T::Private::CallerUtils.find_caller { |loc| loc.base_label != 'included' }
// 26:       T::Private::Sealed.validate_inheritance(caller_loc, self, child, 'included')
// 27:       @sorbet_sealed_module_all_subclasses << child
// 28:     end
// 29:
// 30:     def extended(child)
// 31:       super
// 32:       caller_loc = T::Private::CallerUtils.find_caller { |loc| loc.base_label != 'extended' }
// 33:       T::Private::Sealed.validate_inheritance(caller_loc, self, child, 'extended')
// 34:       @sorbet_sealed_module_all_subclasses << child
// 35:     end
// 36:
// 37:     def sealed_subclasses
// 38:       # this will freeze the set so that you can never get into a
// 39:       # state where you use the subclasses list and then something
// 40:       # else will add to it
// 41:       @sorbet_sealed_module_all_subclasses_set ||= # rubocop:disable Naming/MemoizedInstanceVariableName
// 42:         begin
// 43:           Kernel.require 'set'
// 44:           Set.new(@sorbet_sealed_module_all_subclasses).freeze
// 45:         end
// 46:     end
// 47:   end
// 48:
// 49:   def self.declare(mod, decl_file)
// 50:     if !mod.is_a?(Module)
// 51:       raise "#{mod} is not a class or module and cannot be declared `sealed!`"
// 52:     end
// 53:     if sealed_module?(mod)
// 54:       raise "#{mod} was already declared `sealed!` and cannot be re-declared `sealed!`"
// 55:     end
// 56:     if T::Private::Final.final_module?(mod)
// 57:       raise "#{mod} was already declared `final!` and cannot be declared `sealed!`"
// 58:     end
// 59:     mod.extend(mod.is_a?(Class) ? NoInherit : NoIncludeExtend)
// 60:     if !decl_file
// 61:       raise "Couldn't determine declaration file for sealed class."
// 62:     end
// 63:     mod.instance_variable_set(:@sorbet_sealed_module_decl_file, decl_file)
// 64:     mod.instance_variable_set(:@sorbet_sealed_module_all_subclasses, [])
// 65:   end
// 66:
// 67:   def self.sealed_module?(mod)
// 68:     mod.instance_variable_defined?(:@sorbet_sealed_module_decl_file)
// 69:   end
// 70:
// 71:   def self.validate_inheritance(caller_loc, parent, child, verb)
// 72:     this_file = caller_loc&.path
// 73:     decl_file = parent.instance_variable_get(:@sorbet_sealed_module_decl_file)
// 74:
// 75:     if !this_file
// 76:       raise "Could not use backtrace to determine file for #{verb} child #{child}"
// 77:     end
// 78:     if !decl_file
// 79:       raise "#{parent} does not seem to be a sealed module (#{verb} by #{child})"
// 80:     end
// 81:
// 82:     if !this_file.start_with?(decl_file)
// 83:       whitelist = T::Configuration.sealed_violation_whitelist
// 84:       if !whitelist.nil? && whitelist.any? { |pattern| this_file =~ pattern }
// 85:         return
// 86:       end
// 87:
// 88:       raise "#{parent} was declared sealed and can only be #{verb} in #{decl_file}, not #{this_file}"
// 89:     end
// 90:   end
// 91: end
