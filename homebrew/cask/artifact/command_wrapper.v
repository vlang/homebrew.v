module artifact

import ruby
import homebrew.extend as pathname_extension
import os

// Translated from Homebrew/brew `cask/artifact/command_wrapper.rb`.
pub struct CommandWrapperOptions {
pub:
	content    string
	executable string
	scalar_arg ?string
	args       []string
	env        map[string]string
}

pub struct CommandWrapperArtifact {
pub:
	cask_token  string
	staged_path string
	binarydir   string
	name        string
	source      string
	target      string
	content     string
	executable  string
	args        []string
	env         map[string]string
	symlinked   SymlinkedArtifact
}

fn command_wrapper_shellescape(value string) string {
	if value == '' {
		return "''"
	}
	mut escaped := ''
	for character in value.runes() {
		if character == `\n` {
			escaped += "'\n'"
		} else if (character >= `a` && character <= `z`) || (character >= `A` && character <= `Z`) || (character >= `0` && character <= `9`) || character in [
			`_`,
			`-`,
			`.`,
			`,`,
			`:`,
			`/`,
			`@`,
			`~`,
			`+`,
		] {
			escaped += character.str()
		} else {
			escaped += '\\${character.str()}'
		}
	}
	return escaped
}

pub fn new_command_wrapper(cask_token string, staged_path string, binarydir string,
	name string, options CommandWrapperOptions) !CommandWrapperArtifact {
	if os.file_name(name) != name || name in ['.', '..'] {
		return error("'command_wrapper' requires a command name without path components")
	}
	content := if options.content.trim_space() == '' { '' } else { options.content }
	executable := if options.executable.trim_space() == '' { '' } else { options.executable }
	if content == '' && executable == '' {
		return error("'command_wrapper' requires content or executable")
	}
	if content != '' && executable != '' {
		return error("'command_wrapper' requires content or executable, not both")
	}
	if content != '' && (options.scalar_arg != none || options.args.len > 0 || options.env.len > 0) {
		return error("'command_wrapper' args and env require executable")
	}
	arguments := if scalar := options.scalar_arg { [scalar] } else { options.args.clone() }
	source := os.join_path(staged_path, '.homebrew-command-wrappers', name)
	target := os.join_path(binarydir, name)
	return CommandWrapperArtifact{
		cask_token: cask_token
		staged_path: staged_path
		binarydir: binarydir
		name: name
		source: source
		target: target
		content: content
		executable: executable
		args: arguments
		env: options.env.clone()
		symlinked: SymlinkedArtifact{
			source: source
			target: target
			english_name: 'Binary'
			printable_target: target
		}
	}
}

pub fn install_command_wrapper_with_command(artifact CommandWrapperArtifact, force bool,
	adopt bool, runner ArtifactCommandRunner) ! {
	if artifact.content != '' {
		os.mkdir_all(os.dir(artifact.source))!
		os.write_file(artifact.source, artifact.content)!
	} else {
		arguments := artifact.args.map(command_wrapper_shellescape(it))
		mut environment := []pathname_extension.EnvironmentAssignment{}
		for key, value in artifact.env {
			environment << pathname_extension.EnvironmentAssignment{
				key: key
				value: value
			}
		}
		pathname_extension.pathname_write_env_script(artifact.source, artifact.executable, arguments, environment)!
	}
	linked := link_symlinked_artifact_with_command(artifact.symlinked, SymlinkedInstallOptions{
		force: force
		adopt: adopt
	}, runner)
	if !linked.success {
		return error(linked.error)
	}
	executable := link_executable_artifact(artifact.source)!
	if executable.sudo_required {
		runner(ArtifactCommand{
			executable: 'chmod'
			args: executable.command_arguments
			sudo: true
		})!
	}
}

pub fn install_command_wrapper(artifact CommandWrapperArtifact, force bool, adopt bool) ! {
	install_command_wrapper_with_command(artifact, force, adopt, default_artifact_command_runner)!
}

pub fn command_wrapper_to_args(artifact CommandWrapperArtifact) ruby.Value {
	mut options := map[string]ruby.Value{}
	if artifact.content != '' {
		options['content'] = ruby.string_value(artifact.content)
	} else {
		options['executable'] = ruby.string_value(artifact.executable)
		if artifact.args.len > 0 {
			options['args'] = ruby.string_array_value(artifact.args)
		}
		if artifact.env.len > 0 {
			mut environment := map[string]ruby.Value{}
			for key, value in artifact.env {
				environment[key] = ruby.string_value(value)
			}
			options['env'] = ruby.map_value(environment)
		}
	}
	return ruby.array_value([
		ruby.string_value(artifact.name),
		ruby.map_value(options),
	])
}
