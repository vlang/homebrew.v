module cask

import brew_runtime

// Translated from Homebrew/brew `sorbet/tapioca/compilers/cask/dsl.rb`.
// The original source is retained below until every stub has a typed V body.
pub const cask_dsl_compiler_ordinary_artifacts = ['installer', 'app', 'app_image', 'artifact',
	'audio_unit_plugin', 'binary', 'command_wrapper', 'colorpicker', 'dictionary', 'font',
	'generated_script', 'input_method', 'internet_plugin', 'keyboard_layout', 'manpage', 'pkg',
	'prefpane', 'qlplugin', 'mdimporter', 'screen_saver', 'service', 'stage_only', 'suite',
	'vst_plugin', 'vst3_plugin', 'zsh_completion', 'fish_completion', 'bash_completion',
	'generated_completion', 'uninstall', 'zap']

pub const cask_dsl_compiler_block_artifacts = ['preflight', 'postflight']

pub const cask_dsl_compiler_install_step_artifacts = ['preflight_steps', 'postflight_steps',
	'uninstall_preflight_steps', 'uninstall_postflight_steps']

pub struct CaskDslCompilerMethod {
pub:
	name        string
	parameters  []string
	return_type string
}

pub struct CaskDslCompilerDecoration {
pub:
	constant_name string
	kind          string
	methods       []CaskDslCompilerMethod
}

pub fn cask_dsl_compiler_block_type(dsl_class string) string {
	return 'T.nilable(T.proc.bind(${dsl_class}).params(dsl: ${dsl_class}).void)'
}

pub fn cask_dsl_compiler_decoration() CaskDslCompilerDecoration {
	mut methods := []CaskDslCompilerMethod{}
	for artifact in cask_dsl_compiler_ordinary_artifacts {
		methods << CaskDslCompilerMethod{
			name: artifact
			parameters: ['*args: T.anything', '**kwargs: T.anything']
			return_type: 'void'
		}
	}
	for artifact in cask_dsl_compiler_block_artifacts {
		for key in [artifact, 'uninstall_${artifact}'] {
			dsl_class := key.split('_').map(it.title()).join('')
			full_class := 'Cask::DSL::${dsl_class}'
			block_parameter := '&block: ${cask_dsl_compiler_block_type(full_class)}'
			methods << CaskDslCompilerMethod{
				name: key
				parameters: [block_parameter]
				return_type: 'void'
			}
		}
	}
	install_steps_block := '&block: ${cask_dsl_compiler_block_type('Homebrew::InstallSteps::DSL')}'
	for artifact in cask_dsl_compiler_install_step_artifacts {
		methods << CaskDslCompilerMethod{
			name: artifact
			parameters: ['steps: T.anything = nil', '**kwargs: T.anything', install_steps_block]
			return_type: 'void'
		}
	}
	return CaskDslCompilerDecoration{
		constant_name: 'Cask::DSL'
		kind: 'path'
		methods: methods
	}
}

fn cask_dsl_compiler_decoration_value(decoration CaskDslCompilerDecoration) brew_runtime.Value {
	return brew_runtime.map_value({
		'constant_name': brew_runtime.string_value(decoration.constant_name)
		'kind':          brew_runtime.string_value(decoration.kind)
		'methods':       brew_runtime.array_value(decoration.methods.map(brew_runtime.map_value({
			'name':        brew_runtime.string_value(it.name)
			'parameters':  brew_runtime.string_array_value(it.parameters)
			'return_type': brew_runtime.string_value(it.return_type)
		})))
	})
}

// Ruby method `self.gather_constants = [Cask::DSL]` at line 13.
pub fn ruby_dsl_l13_d1_self_gather_constants(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.array_value([
		brew_runtime.object_value('Module', 'Cask::DSL'),
	])
}

// Ruby method `decorate` at line 16.
pub fn ruby_dsl_l16_d2_decorate(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cask_dsl_compiler_decoration_value(cask_dsl_compiler_decoration())
}

// Ruby method `block_type(dsl_class)` at line 57.
pub fn ruby_dsl_l57_d3_block_type(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'block_type requires a DSL class')
	}
	return brew_runtime.string_value(cask_dsl_compiler_block_type(args[0].as_string()))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "../../../../global"
// 5: require "cask/cask"
// 6:
// 7: module Tapioca
// 8:   module Compilers
// 9:     class CaskDsl < Tapioca::Dsl::Compiler
// 10:       ConstantType = type_member { { fixed: T::Module[T.anything] } }
// 11:
// 12:       sig { override.returns(T::Enumerable[T::Module[T.anything]]) }
// 13:       def self.gather_constants = [Cask::DSL]
// 14:
// 15:       sig { override.void }
// 16:       def decorate
// 17:         root.create_path(constant) do |klass|
// 18:           Cask::DSL::ORDINARY_ARTIFACT_CLASSES.each do |artifact|
// 19:             klass.create_method(
// 20:               artifact.dsl_key.to_s,
// 21:               parameters:  [
// 22:                 create_rest_param("args", type: "T.anything"),
// 23:                 create_kw_rest_param("kwargs", type: "T.anything"),
// 24:               ],
// 25:               return_type: "void",
// 26:             )
// 27:           end
// 28:
// 29:           Cask::DSL::ARTIFACT_BLOCK_CLASSES.each do |artifact|
// 30:             [artifact.dsl_key, artifact.uninstall_dsl_key].each do |dsl_key|
// 31:               dsl_class = artifact.class_for_dsl_key(dsl_key).to_s
// 32:               klass.create_method(
// 33:                 dsl_key.to_s,
// 34:                 parameters:  [create_block_param("block", type: block_type(dsl_class))],
// 35:                 return_type: "void",
// 36:               )
// 37:             end
// 38:           end
// 39:
// 40:           Cask::DSL::INSTALL_STEP_ARTIFACT_CLASSES.each do |artifact|
// 41:             klass.create_method(
// 42:               artifact.dsl_key.to_s,
// 43:               parameters:  [
// 44:                 create_opt_param("steps", type: "T.anything", default: "nil"),
// 45:                 create_kw_rest_param("kwargs", type: "T.anything"),
// 46:                 create_block_param("block", type: block_type("Homebrew::InstallSteps::DSL")),
// 47:               ],
// 48:               return_type: "void",
// 49:             )
// 50:           end
// 51:         end
// 52:       end
// 53:
// 54:       private
// 55:
// 56:       sig { params(dsl_class: String).returns(String) }
// 57:       def block_type(dsl_class)
// 58:         "T.nilable(T.proc.bind(#{dsl_class}).params(dsl: #{dsl_class}).void)"
// 59:       end
// 60:     end
// 61:   end
// 62: end
