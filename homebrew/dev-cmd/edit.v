module dev_cmd

import brew_runtime
import os

// Translated from Homebrew/brew `dev-cmd/edit.rb`.
// The original source is retained below until every stub has a typed V body.

const edit_default_core_tap_name = 'homebrew/core'
const edit_default_core_cask_tap_name = 'homebrew/cask'

pub enum EditErrorKind {
	option_constraint
	fatal
	tap_unavailable
	usage
	editor
}

pub struct EditCommandError {
pub:
	kind    EditErrorKind
	message string
}

pub fn (edit_error EditCommandError) msg() string {
	return edit_error.message
}

pub fn (edit_error EditCommandError) code() int {
	return match edit_error.kind {
		.option_constraint, .usage { 64 }
		else { 1 }
	}
}

// EditNamedTarget is the resolved NamedArgs input for one command-line name.
// Separate formula and cask paths preserve NamedArgs#to_paths returning both
// when an unqualified name exists in both namespaces.
pub struct EditNamedTarget {
pub:
	name          string
	explicit_path string
	tap_path      string
	formula_path  string
	cask_path     string
	fallback_path string
	api_formula   bool
	api_cask      bool
}

pub struct EditTapInstall {
pub:
	name           string
	force          bool
	requested_name string
}

pub struct EditOptions {
pub:
	repository                       string
	library_path                     string
	named                            []EditNamedTarget
	formula                          bool
	cask                             bool
	print_path                       bool
	homebrew_editor                  string
	editor                           string
	visual                           string
	available_editors                []string
	editor_available                 bool = true
	editor_succeeds                  bool = true
	editor_stdout                    string
	editor_stderr                    string
	homebrew_colorterm               string
	homebrew_colorterm_set           bool
	homebrew_tmpdir                  string
	homebrew_tmpdir_set              bool
	homebrew_vscode_ipc_hook_cli     string
	homebrew_vscode_ipc_hook_cli_set bool
	repository_git_known             bool
	repository_git_directory         bool
	core_tap_name                    string = edit_default_core_tap_name
	core_tap_path                    string
	core_tap_installed               bool = true
	core_cask_tap_name               string = edit_default_core_cask_tap_name
	core_cask_tap_path               string
	core_cask_tap_installed          bool = true
	api_formula_names                []string
	api_cask_tokens                  []string
	existing_paths                   []string
	missing_paths                    []string
	no_env_hints                     bool
	no_install_from_api              bool
}

pub struct EditResult {
pub:
	paths             []string
	selected_editor   string
	editor_command    []string
	editor_invoked    bool
	tap_installs      []EditTapInstall
	environment       map[string]string
	unset_environment []string
	stdout            string
	stderr            string
	hint              string
}

@[heap]
pub struct EditInput {
pub:
	options EditOptions
}

@[heap]
pub struct EditMissingPathInput {
pub:
	options EditOptions
	path    string
	cask    bool
}

fn edit_core_tap_name(options EditOptions) string {
	return if options.core_tap_name != '' {
		options.core_tap_name
	} else {
		edit_default_core_tap_name
	}
}

fn edit_core_cask_tap_name(options EditOptions) string {
	return if options.core_cask_tap_name != '' {
		options.core_cask_tap_name
	} else {
		edit_default_core_cask_tap_name
	}
}

fn edit_delete_prefix(value string, prefix string) string {
	return if prefix != '' && value.starts_with(prefix) { value[prefix.len..] } else { value }
}

fn edit_normalized_path(path string) string {
	return os.norm_path(path.replace('\\', '/'))
}

pub fn edit_core_formula_path(path string) bool {
	normalized := edit_normalized_path(path)
	marker := 'homebrew-core/Formula/'
	matches_tap := normalized.starts_with(marker) || normalized.contains('/${marker}')
	return matches_tap && normalized.all_after(marker) != '' && normalized.ends_with('.rb')
}

pub fn edit_core_cask_path(path string) bool {
	normalized := edit_normalized_path(path)
	marker := 'homebrew-cask/Casks/'
	matches_tap := normalized.starts_with(marker) || normalized.contains('/${marker}')
	return matches_tap && normalized.all_after(marker) != '' && normalized.ends_with('.rb')
}

pub fn edit_core_formula_tap(path string, core_tap_path string) bool {
	return core_tap_path != '' && edit_normalized_path(path) == edit_normalized_path(core_tap_path)
}

pub fn edit_core_cask_tap(path string, core_cask_tap_path string) bool {
	return core_cask_tap_path != ''
		&& edit_normalized_path(path) == edit_normalized_path(core_cask_tap_path)
}

fn edit_tap_name_for_path(path string, library_path string) ?string {
	if library_path == '' {
		return none
	}
	prefix := edit_normalized_path(os.join_path(library_path, 'Taps')) + '/'
	normalized := edit_normalized_path(path)
	if !normalized.starts_with(prefix) {
		return none
	}
	parts := normalized[prefix.len..].split('/')
	if parts.len != 2 || parts[0] == '' || parts[1] == '' {
		return none
	}
	return '${parts[0]}/${parts[1]}'
}

fn edit_tap_unavailable_error(name string, options EditOptions) EditCommandError {
	core := name in [edit_core_tap_name(options), edit_core_cask_tap_name(options)]
	command := if core { 'brew tap --force ${name}' } else { 'brew tap-new ${name}' }
	action := if core { 'tap ${name}' } else { 'create a new ${name} tap' }
	return EditCommandError{
		kind: .tap_unavailable
		message: 'No available tap ${name}.\nRun `${command}` to ${action}!\n'
	}
}

fn edit_name_from_path(path string) string {
	base := os.base(path)
	return if base.ends_with('.rb') { base[..base.len - 3] } else { base }
}

pub fn edit_missing_path_error(options EditOptions, path string, cask bool) EditCommandError {
	if edit_core_formula_tap(path, options.core_tap_path) {
		return edit_tap_unavailable_error(edit_core_tap_name(options), options)
	}
	if edit_core_cask_tap(path, options.core_cask_tap_path) {
		return edit_tap_unavailable_error(edit_core_cask_tap_name(options), options)
	}
	if tap_name := edit_tap_name_for_path(path, options.library_path) {
		return edit_tap_unavailable_error(tap_name, options)
	}

	name := edit_name_from_path(path)
	mut command := ''
	mut action := ''
	if cask || edit_core_cask_path(path) {
		if !options.core_cask_tap_installed && name in options.api_cask_tokens {
			command = 'brew tap --force ${edit_core_cask_tap_name(options)}'
			action = 'tap ${edit_core_cask_tap_name(options)}'
		} else {
			command = 'brew create --cask --set-name ${name} \$URL'
			action = 'create a new cask'
		}
	} else if edit_core_formula_path(path) && !options.core_tap_installed
		&& name in options.api_formula_names {
		command = 'brew tap --force ${edit_core_tap_name(options)}'
		action = 'tap ${edit_core_tap_name(options)}'
	} else {
		command = 'brew create --set-name ${name} \$URL'
		action = 'create a new formula'
	}
	return EditCommandError{
		kind: .usage
		message: "${name} doesn't exist on disk.\nRun `${command}` to ${action}!\n"
	}
}

fn edit_configured_editor(options EditOptions) string {
	for editor in [options.homebrew_editor, options.editor, options.visual] {
		if editor != '' {
			return editor
		}
	}
	for candidate in ['code', 'codium', 'cursor', 'code-insiders', 'subl', 'mate', 'bbedit', 'vim'] {
		if candidate in options.available_editors {
			return candidate
		}
	}
	return 'vim'
}

fn edit_shell_split(command string) []string {
	mut words := []string{}
	mut current := []u8{}
	mut quote := u8(0)
	mut escaped := false
	for character in command.bytes() {
		if escaped {
			current << character
			escaped = false
			continue
		}
		if character == `\\` && quote != `'` {
			escaped = true
			continue
		}
		if quote != 0 {
			if character == quote {
				quote = 0
			} else {
				current << character
			}
			continue
		}
		if character == `'` || character == `"` {
			quote = character
		} else if character.is_space() {
			if current.len > 0 {
				words << current.bytestr()
				current.clear()
			}
		} else {
			current << character
		}
	}
	if escaped {
		current << `\\`
	}
	if current.len > 0 {
		words << current.bytestr()
	}
	return words
}

fn edit_target_formula_known(target EditNamedTarget, options EditOptions) bool {
	name := edit_delete_prefix(target.name, '${edit_core_tap_name(options)}/')
	return target.api_formula || name in options.api_formula_names
}

fn edit_target_cask_known(target EditNamedTarget, options EditOptions) bool {
	name := edit_delete_prefix(target.name, '${edit_core_cask_tap_name(options)}/')
	return target.api_cask || name in options.api_cask_tokens
}

fn edit_resolve_target_paths(target EditNamedTarget, options EditOptions) []string {
	fallback_path := if target.fallback_path != '' {
		target.fallback_path
	} else {
		os.abs_path(target.name)
	}
	if target.explicit_path != '' {
		return [target.explicit_path]
	}
	if target.tap_path != '' {
		return [target.tap_path]
	}
	if options.formula {
		return [
			if target.formula_path != '' { target.formula_path } else { fallback_path },
		]
	}
	if options.cask {
		return [
			if target.cask_path != '' { target.cask_path } else { fallback_path },
		]
	}
	mut paths := []string{}
	if target.formula_path != '' {
		paths << target.formula_path
	}
	if target.cask_path != '' {
		paths << target.cask_path
	}
	if paths.len == 0 {
		paths << fallback_path
	}
	return paths
}

fn edit_unique_nonempty_paths(paths []string) []string {
	mut seen := map[string]bool{}
	mut unique := []string{}
	for path in paths {
		if path != '' && !seen[path] {
			seen[path] = true
			unique << path
		}
	}
	return unique
}

fn edit_path_exists(path string, available_after_tap []string, options EditOptions) bool {
	if path in options.missing_paths {
		return false
	}
	if path in options.existing_paths || path in available_after_tap {
		return true
	}
	return os.exists(path)
}

pub fn run_edit(options EditOptions) !EditResult {
	if options.formula && options.cask {
		return EditCommandError{
			kind: .option_constraint
			message: '`--formula` and `--cask` are mutually exclusive.'
		}
	}

	selected_editor := edit_configured_editor(options)
	mut environment := map[string]string{}
	mut unset_environment := []string{}
	if options.homebrew_colorterm_set {
		environment['COLORTERM'] = options.homebrew_colorterm
	} else {
		unset_environment << 'COLORTERM'
	}
	if options.homebrew_tmpdir_set {
		environment['TMPDIR'] = options.homebrew_tmpdir
	} else {
		unset_environment << 'TMPDIR'
	}
	if selected_editor == 'code' && options.homebrew_vscode_ipc_hook_cli_set {
		environment['VSCODE_IPC_HOOK_CLI'] = options.homebrew_vscode_ipc_hook_cli
	}

	repository_has_git := if options.repository_git_known {
		options.repository_git_directory
	} else {
		os.is_dir(os.join_path(options.repository, '.git'))
	}
	if !repository_has_git {
		return EditCommandError{
			kind: .fatal
			message: 'Changes will be lost!\nThe first time you `brew update`, all local changes will be lost; you should\nthus `brew update` before you `brew edit`!\n'
		}
	}

	mut tap_installs := []EditTapInstall{}
	mut available_after_tap := []string{}
	mut core_tap_installed := options.core_tap_installed
	mut core_cask_tap_installed := options.core_cask_tap_installed
	mut installed_core_tap := false
	mut installed_core_cask_tap := false
	for target in options.named {
		if !options.cask && !core_tap_installed && edit_target_formula_known(target, options) {
			tap_installs << EditTapInstall{
				name: edit_core_tap_name(options)
				force: true
				requested_name: target.name
			}
			core_tap_installed = true
			installed_core_tap = true
		} else if !options.formula && !core_cask_tap_installed
			&& edit_target_cask_known(target, options) {
			tap_installs << EditTapInstall{
				name: edit_core_cask_tap_name(options)
				force: true
				requested_name: target.name
			}
			core_cask_tap_installed = true
			installed_core_cask_tap = true
		}
	}
	for target in options.named {
		if installed_core_tap && edit_target_formula_known(target, options)
			&& target.formula_path != '' {
			available_after_tap << target.formula_path
		}
		if installed_core_cask_tap && edit_target_cask_known(target, options)
			&& target.cask_path != '' {
			available_after_tap << target.cask_path
		}
	}

	mut paths := []string{}
	if options.named.len == 0 {
		if selected_editor == 'subl' {
			paths = ['--project',
				os.join_path(options.repository, '.sublime', 'homebrew.sublime-project')]
		} else {
			paths = [options.repository]
		}
	} else {
		for target in options.named {
			paths << edit_resolve_target_paths(target, options)
		}
		paths = edit_unique_nonempty_paths(paths)
		validation_options := EditOptions{
			...options
			core_tap_installed: core_tap_installed
			core_cask_tap_installed: core_cask_tap_installed
		}
		for path in paths {
			if !edit_path_exists(path, available_after_tap, options) {
				return edit_missing_path_error(validation_options, path, options.cask)
			}
		}
	}

	if options.print_path {
		return EditResult{
			paths: paths
			selected_editor: selected_editor
			tap_installs: tap_installs
			environment: environment
			unset_environment: unset_environment
			stdout: if paths.len > 0 { '${paths.join('\n')}\n' } else { '' }
		}
	}

	mut editor_command := edit_shell_split(selected_editor)
	if editor_command.len == 0 {
		return EditCommandError{
			kind: .editor
			message: 'editor command is empty'
		}
	}
	editor_command << paths
	if !options.editor_available || !options.editor_succeeds {
		return EditCommandError{
			kind: .editor
			message: 'Failure while executing: ${editor_command.join(' ')}'
		}
	}

	mut hint := ''
	if !options.no_env_hints {
		mut is_formula := false
		mut edits_core := false
		for path in paths {
			if path == '--project' {
				continue
			}
			is_formula = edit_core_formula_path(path)
			if is_formula || edit_core_cask_path(path)
				|| edit_core_formula_tap(path, options.core_tap_path)
				|| edit_core_cask_tap(path, options.core_cask_tap_path) {
				edits_core = true
				break
			}
		}
		if edits_core {
			no_api := if options.no_install_from_api {
				''
			} else {
				'HOMEBREW_NO_INSTALL_FROM_API=1 '
			}
			from_source := if is_formula { ' --build-from-source' } else { '' }
			names := options.named.map(it.name)
			hint = 'To test your local edits, run:\n  ${no_api}brew install${from_source} --verbose --debug ${names.join(' ')}\n'
		}
	}

	return EditResult{
		paths: paths
		selected_editor: selected_editor
		editor_command: editor_command
		editor_invoked: true
		tap_installs: tap_installs
		environment: environment
		unset_environment: unset_environment
		stdout: options.editor_stdout + hint
		stderr: options.editor_stderr
		hint: hint
	}
}

pub fn edit_input_boundary(input &EditInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::DevCmd::Edit::Input', '', {
		'edit_input_address': u64(voidptr(input)).str()
	})
}

fn edit_input_from_value(value brew_runtime.Value) &EditInput {
	address := value.attributes['edit_input_address'] or { panic('invalid Edit input') }
	return unsafe { &EditInput(voidptr(address.u64())) }
}

pub fn edit_missing_path_input_boundary(input &EditMissingPathInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::DevCmd::Edit::MissingPathInput', '', {
		'edit_missing_path_input_address': u64(voidptr(input)).str()
	})
}

fn edit_missing_path_input_from_value(value brew_runtime.Value) &EditMissingPathInput {
	address := value.attributes['edit_missing_path_input_address'] or {
		panic('invalid Edit missing-path input')
	}
	return unsafe { &EditMissingPathInput(voidptr(address.u64())) }
}

fn edit_tap_install_value(install EditTapInstall) brew_runtime.Value {
	return brew_runtime.map_value({
		'name':           brew_runtime.string_value(install.name)
		'force':          brew_runtime.bool_value(install.force)
		'requested_name': brew_runtime.string_value(install.requested_name)
	})
}

fn edit_result_value(result EditResult) brew_runtime.Value {
	mut environment := map[string]brew_runtime.Value{}
	for name, value in result.environment {
		environment[name] = brew_runtime.string_value(value)
	}
	return brew_runtime.map_value({
		'paths':             brew_runtime.string_array_value(result.paths)
		'selected_editor':   brew_runtime.string_value(result.selected_editor)
		'editor_command':    brew_runtime.string_array_value(result.editor_command)
		'editor_invoked':    brew_runtime.bool_value(result.editor_invoked)
		'tap_installs':      brew_runtime.array_value(result.tap_installs.map(edit_tap_install_value(it)))
		'environment':       brew_runtime.map_value(environment)
		'unset_environment': brew_runtime.string_array_value(result.unset_environment)
		'stdout':            brew_runtime.string_value(result.stdout)
		'stderr':            brew_runtime.string_value(result.stderr)
		'hint':              brew_runtime.string_value(result.hint)
	})
}

fn edit_boundary_error(edit_error EditCommandError) brew_runtime.Value {
	type_name := match edit_error.kind {
		.option_constraint { 'Homebrew::CLI::OptionConstraintError' }
		.fatal { 'FatalError' }
		.tap_unavailable { 'TapUnavailableError' }
		.usage { 'UsageError' }
		.editor { 'ErrorDuringExecution' }
	}
	return brew_runtime.object_value(type_name, edit_error.message)
}

// Ruby method `run` at line 28.
pub fn ruby_edit_l28_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	return edit_result_value(run_edit(edit_input_from_value(args[0]).options) or {
		if err is EditCommandError {
			return edit_boundary_error(err)
		}
		return brew_runtime.object_value('Error', err.msg())
	})
}

// Ruby method `core_formula_path?(path)` at line 99.
pub fn ruby_edit_l99_d2_core_formula_path(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'path is required')
	}
	return brew_runtime.bool_value(edit_core_formula_path(args[0].as_string()))
}

// Ruby method `core_cask_path?(path)` at line 104.
pub fn ruby_edit_l104_d3_core_cask_path(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'path is required')
	}
	return brew_runtime.bool_value(edit_core_cask_path(args[0].as_string()))
}

// Ruby method `core_formula_tap?(path)` at line 109.
pub fn ruby_edit_l109_d4_core_formula_tap(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'path and core tap path are required')
	}
	return brew_runtime.bool_value(edit_core_formula_tap(args[0].as_string(), args[1].as_string()))
}

// Ruby method `core_cask_tap?(path)` at line 114.
pub fn ruby_edit_l114_d5_core_cask_tap(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'path and core cask tap path are required')
	}
	return brew_runtime.bool_value(edit_core_cask_tap(args[0].as_string(), args[1].as_string()))
}

// Ruby method `raise_with_message!(path, cask)` at line 119.
pub fn ruby_edit_l119_d6_raise_with_message(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'missing-path input is required')
	}
	input := edit_missing_path_input_from_value(args[0])
	return edit_boundary_error(edit_missing_path_error(input.options, input.path, input.cask))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6:
// 7: module Homebrew
// 8:   module DevCmd
// 9:     class Edit < AbstractCommand
// 10:       cmd_args do
// 11:         description <<~EOS
// 12:           Open a <formula>, <cask> or <tap> in the editor set by `$EDITOR` or `$HOMEBREW_EDITOR`,
// 13:           or open the Homebrew repository for editing if no argument is provided.
// 14:         EOS
// 15:         switch "--formula", "--formulae",
// 16:                description: "Treat all named arguments as formulae."
// 17:         switch "--cask", "--casks",
// 18:                description: "Treat all named arguments as casks."
// 19:         switch "--print-path",
// 20:                description: "Print the file path to be edited, without opening an editor."
// 21:
// 22:         conflicts "--formula", "--cask"
// 23:
// 24:         named_args [:formula, :cask, :tap], without_api: true
// 25:       end
// 26:
// 27:       sig { override.void }
// 28:       def run
// 29:         ENV["COLORTERM"] = ENV.fetch("HOMEBREW_COLORTERM", nil)
// 30:         # Recover $TMPDIR for emacsclient
// 31:         ENV["TMPDIR"] = ENV.fetch("HOMEBREW_TMPDIR", nil)
// 32:
// 33:         # VS Code remote development relies on this env var to work
// 34:         if which_editor(silent: true) == "code" && ENV.include?("HOMEBREW_VSCODE_IPC_HOOK_CLI")
// 35:           ENV["VSCODE_IPC_HOOK_CLI"] = ENV.fetch("HOMEBREW_VSCODE_IPC_HOOK_CLI", nil)
// 36:         end
// 37:
// 38:         unless (HOMEBREW_REPOSITORY/".git").directory?
// 39:           odie <<~EOS
// 40:             Changes will be lost!
// 41:             The first time you `brew update`, all local changes will be lost; you should
// 42:             thus `brew update` before you `brew edit`!
// 43:           EOS
// 44:         end
// 45:
// 46:         paths = if args.named.empty?
// 47:           # Sublime requires opting into the project editing path,
// 48:           # as opposed to VS Code which will infer from the .vscode path
// 49:           if which_editor(silent: true) == "subl"
// 50:             ["--project", HOMEBREW_REPOSITORY/".sublime/homebrew.sublime-project"]
// 51:           else
// 52:             # If no formulae are listed, open the project root in an editor.
// 53:             [HOMEBREW_REPOSITORY]
// 54:           end
// 55:         else
// 56:           args.named.each do |name|
// 57:             if !args.cask? && !CoreTap.instance.installed? &&
// 58:                Homebrew::API.formula_name?(name.delete_prefix("#{CoreTap.instance.name}/"))
// 59:               CoreTap.instance.install(force: true)
// 60:             elsif !args.formula? && !CoreCaskTap.instance.installed? &&
// 61:                   Homebrew::API.cask_token?(name.delete_prefix("#{CoreCaskTap.instance.name}/"))
// 62:               CoreCaskTap.instance.install(force: true)
// 63:             end
// 64:           end
// 65:
// 66:           expanded_paths = args.named.to_paths
// 67:           expanded_paths.each do |path|
// 68:             raise_with_message!(path, args.cask?) unless path.exist?
// 69:           end
// 70:           expanded_paths
// 71:         end
// 72:
// 73:         if args.print_path?
// 74:           paths.each { puts it }
// 75:           return
// 76:         end
// 77:
// 78:         exec_editor(*paths)
// 79:
// 80:         is_formula = T.let(false, T::Boolean)
// 81:         if !Homebrew::EnvConfig.no_env_hints? && paths.any? do |path|
// 82:              next if path == "--project"
// 83:
// 84:              is_formula = core_formula_path?(path)
// 85:              is_formula || core_cask_path?(path) || core_formula_tap?(path) || core_cask_tap?(path)
// 86:            end
// 87:           from_source = " --build-from-source" if is_formula
// 88:           no_api = "HOMEBREW_NO_INSTALL_FROM_API=1 " unless Homebrew::EnvConfig.no_install_from_api?
// 89:           puts <<~EOS
// 90:             To test your local edits, run:
// 91:               #{no_api}brew install#{from_source} --verbose --debug #{args.named.join(" ")}
// 92:           EOS
// 93:         end
// 94:       end
// 95:
// 96:       private
// 97:
// 98:       sig { params(path: Pathname).returns(T::Boolean) }
// 99:       def core_formula_path?(path)
// 100:         path.fnmatch?("**/homebrew-core/Formula/**.rb", File::FNM_DOTMATCH)
// 101:       end
// 102:
// 103:       sig { params(path: Pathname).returns(T::Boolean) }
// 104:       def core_cask_path?(path)
// 105:         path.fnmatch?("**/homebrew-cask/Casks/**.rb", File::FNM_DOTMATCH)
// 106:       end
// 107:
// 108:       sig { params(path: Pathname).returns(T::Boolean) }
// 109:       def core_formula_tap?(path)
// 110:         path == CoreTap.instance.path
// 111:       end
// 112:
// 113:       sig { params(path: Pathname).returns(T::Boolean) }
// 114:       def core_cask_tap?(path)
// 115:         path == CoreCaskTap.instance.path
// 116:       end
// 117:
// 118:       sig { params(path: Pathname, cask: T::Boolean).returns(T.noreturn) }
// 119:       def raise_with_message!(path, cask)
// 120:         name = path.basename(".rb").to_s
// 121:
// 122:         if (tap_match = Regexp.new("#{HOMEBREW_TAP_DIR_REGEX.source}$").match(path.to_s))
// 123:           raise TapUnavailableError, CoreTap.instance.name if core_formula_tap?(path)
// 124:           raise TapUnavailableError, CoreCaskTap.instance.name if core_cask_tap?(path)
// 125:
// 126:           raise TapUnavailableError, "#{tap_match[:user]}/#{tap_match[:repo]}"
// 127:         elsif cask || core_cask_path?(path)
// 128:           if !CoreCaskTap.instance.installed? && Homebrew::API.cask_token?(name)
// 129:             command = "brew tap --force #{CoreCaskTap.instance.name}"
// 130:             action = "tap #{CoreCaskTap.instance.name}"
// 131:           else
// 132:             command = "brew create --cask --set-name #{name} $URL"
// 133:             action = "create a new cask"
// 134:           end
// 135:         elsif core_formula_path?(path) &&
// 136:               !CoreTap.instance.installed? &&
// 137:               Homebrew::API.formula_name?(name)
// 138:           command = "brew tap --force #{CoreTap.instance.name}"
// 139:           action = "tap #{CoreTap.instance.name}"
// 140:         else
// 141:           command = "brew create --set-name #{name} $URL"
// 142:           action = "create a new formula"
// 143:         end
// 144:
// 145:         raise UsageError, <<~EOS
// 146:           #{name} doesn't exist on disk.
// 147:           Run #{Formatter.identifier(command)} to #{action}!
// 148:         EOS
// 149:       end
// 150:     end
// 151:   end
// 152: end
