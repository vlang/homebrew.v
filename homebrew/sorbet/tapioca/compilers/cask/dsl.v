module cask

import ruby

// Translated from Homebrew/brew `sorbet/tapioca/compilers/cask/dsl.rb`.
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

fn cask_dsl_compiler_decoration_value(decoration CaskDslCompilerDecoration) ruby.Value {
	return ruby.map_value({
		'constant_name': ruby.string_value(decoration.constant_name)
		'kind':          ruby.string_value(decoration.kind)
		'methods':       ruby.array_value(decoration.methods.map(ruby.map_value({
			'name':        ruby.string_value(it.name)
			'parameters':  ruby.string_array_value(it.parameters)
			'return_type': ruby.string_value(it.return_type)
		})))
	})
}
