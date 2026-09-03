module compilers

import brew_runtime
import os
import regex

// Translated from Homebrew/brew `sorbet/tapioca/compilers/rspec_dynamic_matchers.rb`.
// The original source is retained below until every stub has a typed V body.
fn rspec_matcher_unique_sorted(values []string) []string {
	mut seen := map[string]bool{}
	for value in values {
		seen[value] = true
	}
	mut result := seen.keys()
	result.sort()
	return result
}

fn rspec_matcher_word_byte(value u8) bool {
	return (value >= `a` && value <= `z`) || (value >= `A` && value <= `Z`) || (value >= `0` && value <= `9`) || value == `_`
}

fn rspec_matcher_name_byte(value u8) bool {
	return (value >= `a` && value <= `z`) || (value >= `0` && value <= `9`) || value == `_`
}

fn rspec_matcher_used_in_content(content string) []string {
	mut names := []string{}
	for index := 0; index < content.len; index++ {
		if index > 0 && rspec_matcher_word_byte(content[index - 1]) {
			continue
		}
		prefix := if content[index..].starts_with('be_') {
			'be_'
		} else if content[index..].starts_with('have_') {
			'have_'
		} else {
			continue
		}
		mut end := index + prefix.len
		for end < content.len && rspec_matcher_name_byte(content[end]) {
			end++
		}
		if end > index + prefix.len && (end == content.len || !rspec_matcher_word_byte(content[end])) {
			names << content[index..end]
		}
	}
	return names
}

fn rspec_matcher_declarations_in_content(content string) []string {
	patterns := [r'(RSpec::Matchers\.)?define[ \t\r\n]+:[a-z][a-z0-9_]*[!?]?',
		r'(RSpec::Matchers\.)?define_negated_matcher[ \t\r\n]+:[a-z][a-z0-9_]*[!?]?',
		r'(RSpec::Matchers\.)?alias_matcher[ \t\r\n]+:[a-z][a-z0-9_]*[!?]?',
		r'matcher[ \t\r\n]+:[a-z][a-z0-9_]*[!?]?']
	mut names := []string{}
	for pattern in patterns {
		mut expression := regex.regex_opt(pattern) or { continue }
		for matched in expression.find_all_str(content) {
			colon := matched.last_index(':') or { continue }
			names << matched[colon + 1..]
		}
	}
	return names
}

fn rspec_matcher_known_in_content(content string) []string {
	mut names := []string{}
	for line in content.split_into_lines() {
		trimmed := line.trim_space()
		if !trimmed.starts_with('def ') {
			continue
		}
		mut end := 4
		if end >= trimmed.len || trimmed[end] < `a` || trimmed[end] > `z` {
			continue
		}
		for end < trimmed.len && rspec_matcher_name_byte(trimmed[end]) {
			end++
		}
		if end < trimmed.len && (trimmed[end] == `!` || trimmed[end] == `?`) {
			end++
		}
		names << trimmed[4..end]
	}
	return names
}

pub fn rspec_matcher_declaration_files(test_root string) []string {
	if !os.is_dir(test_root) {
		return []
	}
	mut files := os.walk_ext(test_root, '.rb', hidden: true)
	files = files.filter(os.is_file(it))
	files.sort()
	return files
}

pub fn rspec_used_matchers(test_root string) ![]string {
	mut matchers := []string{}
	for file in rspec_matcher_declaration_files(test_root) {
		if !file.ends_with('_spec.rb') {
			continue
		}
		matchers << rspec_matcher_used_in_content(os.read_file(file)!)
	}
	return rspec_matcher_unique_sorted(matchers)
}

pub fn rspec_declared_dynamic_matchers(test_root string) ![]string {
	mut matchers := []string{}
	for file in rspec_matcher_declaration_files(test_root) {
		matchers << rspec_matcher_declarations_in_content(os.read_file(file)!)
	}
	return rspec_matcher_unique_sorted(matchers)
}

pub fn rspec_known_matchers(rbi_root string) ![]string {
	mut matchers := []string{}
	mut files := os.glob(os.join_path(rbi_root, 'rspec-expectations@*.rbi'))!
	files.sort()
	for file in files {
		matchers << rspec_matcher_known_in_content(os.read_file(file)!)
	}
	return rspec_matcher_unique_sorted(matchers)
}

pub fn rspec_missing_matchers(test_root string, rbi_root string) ![]string {
	mut known := map[string]bool{}
	for name in rspec_known_matchers(rbi_root)! {
		known[name] = true
	}
	mut missing := []string{}
	for name in rspec_used_matchers(test_root)! {
		if name !in known {
			missing << name
		}
	}
	for name in rspec_declared_dynamic_matchers(test_root)! {
		if name !in known {
			missing << name
		}
	}
	return rspec_matcher_unique_sorted(missing)
}

pub fn rspec_dynamic_matchers_decoration(test_root string,
	rbi_root string) !TapiocaDecoration {
	return TapiocaDecoration{
		constant_name: 'RSpec::Matchers'
		kind: 'path'
		methods: rspec_missing_matchers(test_root, rbi_root)!.map(TapiocaGeneratedMethod{
			name: it
			parameters: ['*args: T.untyped', '&block: T.untyped']
		})
	}
}

fn rspec_matcher_roots(args []brew_runtime.Value) (string, string) {
	return if args.len > 0 { args[0].as_string() } else { 'homebrew/test' }, if args.len > 1 {
		args[1].as_string()
	} else {
		'homebrew/sorbet/rbi/gems'
	}
}

// Ruby method `self.gather_constants` at line 12.
pub fn ruby_rspec_dynamic_matchers_l12_d1_self_gather_constants(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.array_value([
		brew_runtime.object_value('Module', 'RSpec::Matchers'),
	])
}

// Ruby method `decorate` at line 17.
pub fn ruby_rspec_dynamic_matchers_l17_d2_decorate(args ...brew_runtime.Value) brew_runtime.Value {
	test_root, rbi_root := rspec_matcher_roots(args)
	decoration := rspec_dynamic_matchers_decoration(test_root, rbi_root) or {
		return brew_runtime.object_value('Error', err.msg())
	}
	return tapioca_decoration_value(decoration)
}

// Ruby method `missing_matchers` at line 34.
pub fn ruby_rspec_dynamic_matchers_l34_d3_missing_matchers(args ...brew_runtime.Value) brew_runtime.Value {
	test_root, rbi_root := rspec_matcher_roots(args)
	return brew_runtime.string_array_value(rspec_missing_matchers(test_root, rbi_root) or {
		return brew_runtime.object_value('Error', err.msg())
	})
}

// Ruby method `used_matchers` at line 39.
pub fn ruby_rspec_dynamic_matchers_l39_d4_used_matchers(args ...brew_runtime.Value) brew_runtime.Value {
	test_root, _ := rspec_matcher_roots(args)
	return brew_runtime.string_array_value(rspec_used_matchers(test_root) or {
		return brew_runtime.object_value('Error', err.msg())
	})
}

// Ruby method `declared_dynamic_matchers` at line 52.
pub fn ruby_rspec_dynamic_matchers_l52_d5_declared_dynamic_matchers(args ...brew_runtime.Value) brew_runtime.Value {
	test_root, _ := rspec_matcher_roots(args)
	return brew_runtime.string_array_value(rspec_declared_dynamic_matchers(test_root) or {
		return brew_runtime.object_value('Error', err.msg())
	})
}

// Ruby method `matcher_declaration_files` at line 76.
pub fn ruby_rspec_dynamic_matchers_l76_d6_matcher_declaration_files(args ...brew_runtime.Value) brew_runtime.Value {
	test_root, _ := rspec_matcher_roots(args)
	return brew_runtime.string_array_value(rspec_matcher_declaration_files(test_root))
}

// Ruby method `known_rspec_matchers` at line 82.
pub fn ruby_rspec_dynamic_matchers_l82_d7_known_rspec_matchers(args ...brew_runtime.Value) brew_runtime.Value {
	_, rbi_root := rspec_matcher_roots(args)
	return brew_runtime.string_array_value(rspec_known_matchers(rbi_root) or {
		return brew_runtime.object_value('Error', err.msg())
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rspec/expectations"
// 5:
// 6: module Tapioca
// 7:   module Compilers
// 8:     class RspecDynamicMatchers < Tapioca::Dsl::Compiler
// 9:       ConstantType = type_member { { fixed: T::Module[T.anything] } }
// 10:
// 11:       sig { override.returns(T::Enumerable[T::Module[T.anything]]) }
// 12:       def self.gather_constants
// 13:         [::RSpec::Matchers]
// 14:       end
// 15:
// 16:       sig { override.void }
// 17:       def decorate
// 18:         root.create_path(constant) do |mod|
// 19:           missing_matchers.each do |name|
// 20:             mod.create_method(
// 21:               name,
// 22:               parameters: [
// 23:                 create_rest_param("args", type: "T.untyped"),
// 24:                 create_block_param("block", type: "T.untyped"),
// 25:               ],
// 26:             )
// 27:           end
// 28:         end
// 29:       end
// 30:
// 31:       private
// 32:
// 33:       sig { returns(T::Array[String]) }
// 34:       def missing_matchers
// 35:         (used_matchers + declared_dynamic_matchers - known_rspec_matchers).to_a.sort
// 36:       end
// 37:
// 38:       sig { returns(T::Set[String]) }
// 39:       def used_matchers
// 40:         matchers = T.let(Set.new, T::Set[String])
// 41:
// 42:         Dir[File.join(__dir__, "../../../test/**/*_spec.rb")].each do |file|
// 43:           File.read(file).scan(/\b(?:be|have)_[a-z0-9_]+\b/) do |name|
// 44:             matchers.add(name)
// 45:           end
// 46:         end
// 47:
// 48:         matchers
// 49:       end
// 50:
// 51:       sig { returns(T::Set[String]) }
// 52:       def declared_dynamic_matchers
// 53:         matchers = T.let(Set.new, T::Set[String])
// 54:
// 55:         matcher_declaration_files.each do |file|
// 56:           content = File.read(file)
// 57:
// 58:           content.scan(/\b(?:RSpec::Matchers\.)?define\s+:([a-z][a-z0-9_]*[!?]?)/) do |captures|
// 59:             matchers.add(captures.first)
// 60:           end
// 61:           content.scan(/\b(?:RSpec::Matchers\.)?define_negated_matcher\s+:([a-z][a-z0-9_]*[!?]?)/) do |captures|
// 62:             matchers.add(captures.first)
// 63:           end
// 64:           content.scan(/\b(?:RSpec::Matchers\.)?alias_matcher\s+:([a-z][a-z0-9_]*[!?]?)/) do |captures|
// 65:             matchers.add(captures.first)
// 66:           end
// 67:           content.scan(/\bmatcher\s+:([a-z][a-z0-9_]*[!?]?)/) do |captures|
// 68:             matchers.add(captures.first)
// 69:           end
// 70:         end
// 71:
// 72:         matchers
// 73:       end
// 74:
// 75:       sig { returns(T::Array[String]) }
// 76:       def matcher_declaration_files
// 77:         files = Dir[File.join(__dir__, "../../../test/**/*.rb")]
// 78:         files.select { |file| File.file?(file) }
// 79:       end
// 80:
// 81:       sig { returns(T::Set[String]) }
// 82:       def known_rspec_matchers
// 83:         known = T.let(Set.new, T::Set[String])
// 84:
// 85:         Dir[File.join(__dir__, "../../rbi/gems/rspec-expectations@*.rbi")].each do |file|
// 86:           File.read(file).scan(/^\s*def\s+([a-z][a-z0-9_]*[!?]?)/) do |captures|
// 87:             known.add(captures.first)
// 88:           end
// 89:         end
// 90:
// 91:         known
// 92:       end
// 93:     end
// 94:   end
// 95: end
