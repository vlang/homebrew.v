module artifact

import ruby

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

fn flight_block_from_args(args []ruby.Value) FlightBlock {
	return new_flight_block(if args.len > 0 { args[0].as_string() } else { '' }, if args.len > 1 {
		args[1].as_string()
	} else {
		'Cask::Artifact::AbstractFlightBlock'
	}, if args.len > 2 { args[2].as_string_array() or { []string{} } } else { []string{} })
}

fn flight_block_value(block FlightBlock) ruby.Value {
	return ruby.structured_value(block.class_name, block.cask, {
		'cask':       block.cask
		'class_name': block.class_name
		'directives': block.directive_keys.join(', ')
	})
}

fn flight_phase_value(result FlightPhaseResult) ruby.Value {
	return ruby.map_value({
		'invoked':  ruby.bool_value(result.invoked)
		'dsl_key':  ruby.string_value(result.dsl_key)
		'dsl_type': ruby.string_value(result.dsl_type)
		'cask':     ruby.string_value(result.cask)
	})
}
