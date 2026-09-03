module artifact

import brew_runtime

pub struct FlightBlock {
pub:
	cask           string
	class_name     string
	directive_keys []string
}

pub struct FlightPhaseResult {
pub:
	invoked  bool
	dsl_key  string
	dsl_type string
	cask     string
}

// Translated from Homebrew/brew `cask/artifact/abstract_flight_block.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.dsl_key` at line 11.
pub fn ruby_abstract_flight_block_l11_d1_self_dsl_key(args ...brew_runtime.Value) brew_runtime.Value {
	class_name := if args.len > 0 { args[0].as_string() } else { 'AbstractFlightBlock' }
	return brew_runtime.string_value(flight_dsl_key(class_name))
}

// Ruby method `self.uninstall_dsl_key` at line 16.
pub fn ruby_abstract_flight_block_l16_d2_self_uninstall_dsl_key(args ...brew_runtime.Value) brew_runtime.Value {
	class_name := if args.len > 0 { args[0].as_string() } else { 'AbstractFlightBlock' }
	return brew_runtime.string_value(flight_uninstall_dsl_key(class_name))
}

// Ruby attr_reader `attr_reader :directives` at line 21.
pub fn ruby_abstract_flight_block_l21_d3_directives(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_array_value(if args.len > 0 {
		args[0].as_string_array() or { []string{} }
	} else {
		[]string{}
	})
}

// Ruby method `initialize(cask, **directives)` at line 24.
pub fn ruby_abstract_flight_block_l24_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	block := new_flight_block(if args.len > 0 { args[0].as_string() } else { '' }, if args.len > 1 {
		args[1].as_string()
	} else {
		'AbstractFlightBlock'
	}, if args.len > 2 { args[2].as_string_array() or { []string{} } } else { []string{} })
	return flight_block_value(block)
}

// Ruby method `install_phase(**_options)` at line 30.
pub fn ruby_abstract_flight_block_l30_d5_install_phase(args ...brew_runtime.Value) brew_runtime.Value {
	block := flight_block_from_args(args)
	return flight_phase_value(flight_install_phase(block))
}

// Ruby method `uninstall_phase(**_options)` at line 35.
pub fn ruby_abstract_flight_block_l35_d6_uninstall_phase(args ...brew_runtime.Value) brew_runtime.Value {
	block := flight_block_from_args(args)
	return flight_phase_value(flight_uninstall_phase(block))
}

// Ruby method `summarize` at line 40.
pub fn ruby_abstract_flight_block_l40_d7_summarize(args ...brew_runtime.Value) brew_runtime.Value {
	directives := if args.len > 0 {
		args[0].as_string_array() or { []string{} }
	} else {
		[]string{}
	}
	return brew_runtime.string_value(flight_summarize(directives))
}

// Ruby method `self.class_for_dsl_key(dsl_key)` at line 45.
pub fn ruby_abstract_flight_block_l45_d8_self_class_for_dsl_key(args ...brew_runtime.Value) brew_runtime.Value {
	class_name := if args.len > 0 {
		args[0].as_string()
	} else {
		'Cask::Artifact::AbstractFlightBlock'
	}
	dsl_key := if args.len > 1 { args[1].as_string() } else { flight_dsl_key(class_name) }
	return brew_runtime.object_value('Class', flight_class_for_dsl_key(class_name, dsl_key))
}

// Ruby method `abstract_phase(dsl_key)` at line 56.
pub fn ruby_abstract_flight_block_l56_d9_abstract_phase(args ...brew_runtime.Value) brew_runtime.Value {
	block := flight_block_from_args(args)
	dsl_key := if args.len > 3 { args[3].as_string() } else { flight_dsl_key(block.class_name) }
	return flight_phase_value(flight_abstract_phase(block, dsl_key))
}

pub fn new_flight_block(cask string, class_name string, directive_keys []string) FlightBlock {
	return FlightBlock{
		cask: cask
		class_name: class_name
		directive_keys: directive_keys.clone()
	}
}

pub fn flight_dsl_key(class_name string) string {
	short_name := class_name.all_after_last('::')
	mut snake := ''
	for index, character in short_name {
		if character >= `A` && character <= `Z` {
			if index > 0 {
				snake += '_'
			}
			snake += (character + 32).ascii_str()
		} else {
			snake += character.ascii_str()
		}
	}
	return snake.trim_string_right('_block')
}

pub fn flight_uninstall_dsl_key(class_name string) string {
	return 'uninstall_${flight_dsl_key(class_name)}'
}

pub fn flight_class_for_dsl_key(class_name string, dsl_key string) string {
	namespace := class_name.all_before('::')
	class_parts := dsl_key.split('_').map(if it == '' { '' } else { it[..1].to_upper() + it[1..] })
	return '${namespace}::DSL::${class_parts.join('')}'
}

pub fn flight_install_phase(block FlightBlock) FlightPhaseResult {
	return flight_abstract_phase(block, flight_dsl_key(block.class_name))
}

pub fn flight_uninstall_phase(block FlightBlock) FlightPhaseResult {
	return flight_abstract_phase(block, flight_uninstall_dsl_key(block.class_name))
}

pub fn flight_abstract_phase(block FlightBlock, dsl_key string) FlightPhaseResult {
	if dsl_key !in block.directive_keys {
		return FlightPhaseResult{ dsl_key: dsl_key }
	}
	return FlightPhaseResult{
		invoked: true
		dsl_key: dsl_key
		dsl_type: flight_class_for_dsl_key(block.class_name, dsl_key)
		cask: block.cask
	}
}

pub fn flight_summarize(directive_keys []string) string {
	return directive_keys.join(', ')
}

fn flight_block_from_args(args []brew_runtime.Value) FlightBlock {
	return new_flight_block(if args.len > 0 { args[0].as_string() } else { '' }, if args.len > 1 {
		args[1].as_string()
	} else {
		'Cask::Artifact::AbstractFlightBlock'
	}, if args.len > 2 { args[2].as_string_array() or { []string{} } } else { []string{} })
}

fn flight_block_value(block FlightBlock) brew_runtime.Value {
	return brew_runtime.structured_value(block.class_name, block.cask, {
		'cask':       block.cask
		'class_name': block.class_name
		'directives': block.directive_keys.join(', ')
	})
}

fn flight_phase_value(result FlightPhaseResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'invoked':  brew_runtime.bool_value(result.invoked)
		'dsl_key':  brew_runtime.string_value(result.dsl_key)
		'dsl_type': brew_runtime.string_value(result.dsl_type)
		'cask':     brew_runtime.string_value(result.cask)
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/abstract_artifact"
// 5:
// 6: module Cask
// 7:   module Artifact
// 8:     # Abstract superclass for block artifacts.
// 9:     class AbstractFlightBlock < AbstractArtifact
// 10:       sig { override.returns(Symbol) }
// 11:       def self.dsl_key
// 12:         super.to_s.sub(/_block$/, "").to_sym
// 13:       end
// 14:
// 15:       sig { returns(Symbol) }
// 16:       def self.uninstall_dsl_key
// 17:         :"uninstall_#{dsl_key}"
// 18:       end
// 19:
// 20:       sig { returns(T::Hash[Symbol, DirectivesType]) }
// 21:       attr_reader :directives
// 22:
// 23:       sig { params(cask: Cask, directives: DirectivesType).void }
// 24:       def initialize(cask, **directives)
// 25:         super(cask)
// 26:         @directives = directives
// 27:       end
// 28:
// 29:       sig { params(_options: T.anything).void }
// 30:       def install_phase(**_options)
// 31:         abstract_phase(self.class.dsl_key)
// 32:       end
// 33:
// 34:       sig { params(_options: T.anything).void }
// 35:       def uninstall_phase(**_options)
// 36:         abstract_phase(self.class.uninstall_dsl_key)
// 37:       end
// 38:
// 39:       sig { override.returns(String) }
// 40:       def summarize
// 41:         directives.keys.join(", ")
// 42:       end
// 43:
// 44:       sig { params(dsl_key: Symbol).returns(T::Class[::Cask::DSL::Base]) }
// 45:       def self.class_for_dsl_key(dsl_key)
// 46:         namespace = name.to_s.sub(/::.*::.*$/, "")
// 47:         # The DSL class name is derived dynamically from the flight block's key.
// 48:         # rubocop:disable Sorbet/ConstantsFromStrings
// 49:         const_get("#{namespace}::DSL::#{dsl_key.to_s.split("_").map(&:capitalize).join}")
// 50:         # rubocop:enable Sorbet/ConstantsFromStrings
// 51:       end
// 52:
// 53:       private
// 54:
// 55:       sig { params(dsl_key: Symbol).void }
// 56:       def abstract_phase(dsl_key)
// 57:         return if (block = directives[dsl_key]).nil?
// 58:
// 59:         self.class.class_for_dsl_key(dsl_key).new(cask).instance_eval(&T.cast(block, T.proc.returns(T.anything)))
// 60:       end
// 61:     end
// 62:   end
// 63: end
