module homebrew

import os
import time

// Translated from Homebrew/brew `sandbox.rb`.
pub enum SandboxFilterType {
	literal
	subpath
	regex
}

pub enum SandboxState {
	available
	unavailable
	config_disabled
	missing_fiddle
	unsupported
	disabled
	unsupported_abi
}

pub enum SandboxHookAction {
	base_noop
	applied
}

pub struct SandboxPathFilter {
pub:
	path      string
	type_name SandboxFilterType
}

pub struct SandboxRule {
pub:
	allow      bool
	operation  string
	filter     SandboxPathFilter
	has_filter bool
	modifier   string
}

pub struct SandboxProfile {
pub mut:
	rules []SandboxRule
}

pub struct SandboxPaths {
pub:
	home               string
	prefix             string
	repository         string
	cache              string
	logs               string
	temp               string
	library            string
	original_brew_file string
	trust_file         string
	github_workspace   string
	runner_workspace   string
	runner_temp        string
	home_write_paths   []string
}

pub struct Sandbox {
pub mut:
	profile      SandboxProfile
	failed       bool
	logfile      string
	start        i64
	paths        SandboxPaths
	warnings     []string
	last_command []string
	forked       bool
}

pub struct SandboxAvoidContext {
pub:
	opted_in         bool
	nested           bool
	default_prefix   bool
	prefix           string
	privileged_group string
}

pub struct SandboxUseContext {
pub:
	available    bool
	avoid_nested bool
}

pub struct SandboxUseDecision {
pub:
	use     bool
	warning string
}

pub struct SandboxRunOrForkResult {
pub:
	sandboxed bool
	forked    bool
	command   []string
	warning   string
}

pub struct SandboxFormulaPaths {
pub:
	rack string
	etc  string
	var  string
	logs string
}

pub struct SandboxFileOperation {
pub:
	operation string
	path      string
	content   string
	mode      int
}

pub struct SandboxRunContext {
pub:
	tmpdir                       string
	exit_status                  int
	output                       string
	sandbox_command              []string
	allow_network_for_error_pipe bool
	operations                   []SandboxFileOperation
}

pub struct SandboxRunResult {
pub:
	command []string
	tmpdir  string
	output  string
}

pub struct SandboxCommandPlan {
pub:
	sandbox       Sandbox
	command       []string
	writable_path string
}

pub struct SandboxExecutableContext {
pub:
	executable_name    string
	original_paths     []string
	environment_path   string
	original_brew_file string
	unsuitable         []string
}

pub struct SandboxBrewMutation {
pub:
	replacement    string
	make_symlink   bool
	target         string
	directory_mode int
}

const sandbox_privileged_groups = ['admin', 'staff', 'root', 'wheel']
const sandbox_sensitive_home_paths = ['.ssh', '.aws', '.azure', '.boto', '.docker', '.config/fish',
	'.config/gh', '.config/gcloud', '.config/huggingface', '.config/pip', '.config/pypoetry',
	'.config/rclone', '.config/containers/auth.json', '.config/composer/auth.json',
	'.config/sops/age/keys.txt', '.gnupg', '.git-credentials', '.gitconfig', '.gsutil', '.kube',
	'.netrc', '.npmrc', '.yarnrc', '.yarnrc.yml', '.pnpmrc', '.bunfig.toml', '.pypirc', '.pip',
	'.poetry', '.local/share/pypoetry', '.gem/credentials', '.bundle/config', '.cargo/credentials',
	'.cargo/credentials.toml', '.composer/auth.json', '.condarc', '.m2/settings.xml',
	'.gradle/gradle.properties', '.sbt/1.0/credentials.sbt', '.terraform.d/credentials.tfrc.json',
	'.pulumi/credentials.json', '.oci/config', '.huggingface/token', '.cache/huggingface/token',
	'.claude', '.claude.json', '.kiro', '.bash_login', '.bash_logout', '.bash_profile', '.bashrc',
	'.bash_history', '.profile', '.zlogin', '.zlogout', '.zprofile', '.zshenv', '.zshrc',
	'.zsh_history', '.python_history', '.mysql_history', '.psql_history', '.env', '.env.local',
	'Documents', 'Movies', 'Music', 'Pictures', 'Library/Keychains', 'Library/Mobile Documents',
	'Library/CloudStorage', 'Dropbox', 'Google Drive', 'OneDrive']

fn sandbox_path_inside(path string, ancestor string) bool {
	normal := os.norm_path(path)
	root := os.norm_path(ancestor)
	return normal == root || normal.starts_with(root.trim_right(os.path_separator) + os.path_separator)
}

fn sandbox_expand_realpath(path string) !string {
	if !os.is_abs_path(path) {
		return error('path must be absolute')
	}
	if os.exists(path) || os.is_link(path) {
		return os.real_path(path)
	}
	parent := os.dir(path)
	if parent == path {
		return path
	}
	return os.join_path(sandbox_expand_realpath(parent)!, os.base(path))
}

fn sandbox_rule_matches(rule SandboxRule, path string) bool {
	if !rule.has_filter {
		return true
	}
	resolved := sandbox_expand_realpath(os.abs_path(path)) or { os.abs_path(path) }
	return match rule.filter.type_name {
		.literal { os.norm_path(rule.filter.path) == os.norm_path(resolved) }
		.subpath { sandbox_path_inside(resolved, rule.filter.path) }
		.regex { path.contains(rule.filter.path.trim('^\$')) }
	}
}

fn sandbox_operation_allowed(sandbox Sandbox, operation string, path string) bool {
	mut allowed := !operation.starts_with('file-write')
	for rule in sandbox.profile.rules {
		if (rule.operation == operation || (rule.operation.ends_with('*') && operation.starts_with(rule.operation.trim_string_right('*')))) && sandbox_rule_matches(rule, path) {
			allowed = rule.allow
		}
	}
	return allowed
}

// Ruby method `initialize(allow:, operation:, filter:, modifier:)` at line 52.
pub fn new_sandbox_rule(allow bool, operation string, filter ?SandboxPathFilter, modifier string) SandboxRule {
	return SandboxRule{ allow: allow, operation: operation, filter: filter or { SandboxPathFilter{} }, has_filter: filter != none, modifier: modifier }
}

// Ruby method `initialize` at line 67.
pub fn new_sandbox_profile() SandboxProfile {
	return SandboxProfile{}
}

// Ruby method `add_rule(rule)` at line 72.
pub fn sandbox_profile_add_rule(mut profile SandboxProfile, rule SandboxRule) {
	profile.rules << rule
}

// Ruby method `self.use_for?(step, warn_without_sandbox: true)` at line 124.
pub fn sandbox_use_for(step string, warn bool, context SandboxUseContext) SandboxUseDecision {
	if !context.available {
		return SandboxUseDecision{
			warning: if warn {
				'Sandbox unavailable: ${step} without sandboxing!'
			} else {
				''
			}
		}
	}
	if context.avoid_nested {
		return SandboxUseDecision{
			warning: if warn {
				"${step.capitalize()} without Homebrew's sandbox; relying on the outer sandbox."
			} else {
				''
			}
		}
	}
	return SandboxUseDecision{ use: true }
}

fn sandbox_apply_brew_mutation(brew_file string, mutation SandboxBrewMutation) ! {
	if mutation.make_symlink {
		sandbox_remove_path(brew_file)!
		os.symlink(mutation.target, brew_file)!
	} else if mutation.replacement != '' {
		sandbox_remove_path(brew_file)!
		os.write_file(brew_file, mutation.replacement)!
	}
	if mutation.directory_mode > 0 {
		os.chmod(os.dir(brew_file), mutation.directory_mode)!
	}
}

fn sandbox_remove_path(path string) ! {
	if os.is_dir(path) && !os.is_link(path) {
		os.rmdir_all(path)!
	} else if os.exists(path) || os.is_link(path) {
		os.rm(path)!
	}
}

// Ruby method `self.ensure_sandbox_available!` at line 187.
pub fn sandbox_ensure_sandbox_available(available bool, reason string) ! {
	if !available {
		message := if reason != '' { reason } else { 'The sandbox is not available.' }
		return error(message)
	}
}

// Ruby method `self.executable_candidate_paths` at line 233.
pub fn sandbox_executable_candidate_paths(context SandboxExecutableContext) []string {
	if os.is_abs_path(context.executable_name) {
		return [os.dir(context.executable_name)]
	}
	mut paths := context.original_paths.clone()
	paths << context.environment_path.split(os.path_delimiter)
	paths << os.dir(context.original_brew_file)
	mut result := []string{}
	for path in paths {
		if path != '' && path !in result { result << path }
	}
	return result
}

// Ruby method `self.executable` at line 241.
pub fn sandbox_executable(context SandboxExecutableContext) ?string {
	for path in sandbox_executable_candidate_paths(context) {
		candidate := if os.is_abs_path(context.executable_name) {
			os.abs_path(context.executable_name)
		} else {
			os.abs_path(os.join_path(path, context.executable_name))
		}
		if os.is_file(candidate) && os.is_executable(candidate) && sandbox_executable_usable(candidate, context.unsuitable) {
			return candidate
		}
	}
	return none
}

// Ruby method `self.executable_usable?(_candidate)` at line 264.
pub fn sandbox_executable_usable(candidate string, unsuitable []string) bool {
	return candidate !in unsuitable
}

// Ruby method `initialize` at line 283.
pub fn new_sandbox(paths SandboxPaths) Sandbox {
	return Sandbox{ profile: new_sandbox_profile(), paths: paths }
}

// Ruby method `add_rule(allow:, operation:, filter: nil, modifier: nil)` at line 299.
pub fn sandbox_add_rule(mut sandbox Sandbox, allow bool, operation string, filter ?SandboxPathFilter, modifier string) {
	sandbox_profile_add_rule(mut sandbox.profile, new_sandbox_rule(allow, operation, filter, modifier))
}

// Ruby method `allow_read(path:, type: :literal)` at line 305.
pub fn sandbox_allow_read(mut sandbox Sandbox, path string, type_name SandboxFilterType) ! {
	sandbox_add_rule(mut sandbox, true, 'file-read*', sandbox_path_filter(path, type_name)!, '')
}

// Ruby method `deny_read(path:, type: :literal)` at line 316.
pub fn sandbox_deny_read(mut sandbox Sandbox, path string, type_name SandboxFilterType) ! {
	sandbox_add_rule(mut sandbox, false, 'file-read*', sandbox_path_filter(path, type_name)!, '')
}

// Ruby method `deny_read_path(path)` at line 321.
pub fn sandbox_deny_read_path(mut sandbox Sandbox, path string) ! {
	sandbox_deny_read(mut sandbox, path, .subpath)!
}

// Ruby method `deny_read_home` at line 326.
pub fn sandbox_deny_read_home(mut sandbox Sandbox) ! {
	home := os.real_path(sandbox.paths.home)
	mut required := [sandbox.paths.prefix, sandbox.paths.repository, sandbox.paths.cache,
		sandbox.paths.logs, sandbox.paths.temp, sandbox.paths.github_workspace,
		sandbox.paths.runner_workspace, sandbox.paths.runner_temp, sandbox.paths.trust_file]
	required << sandbox.paths.home_write_paths.filter(os.exists(it))
	mut readable := []string{}
	for item in required {
		if item == '' {
			continue
		}
		readable << os.abs_path(item)
		if os.exists(item) {
			real := os.real_path(item)
			if real !in readable { readable << real }
		}
	}
	if readable.any(sandbox_path_inside(it, home)) {
		for relative in sandbox_sensitive_home_paths {
			path := os.join_path(home, relative)
			if !os.exists(path) && !os.is_link(path) {
				continue
			}
			real := os.real_path(path)
			if !os.exists(real) && !os.is_link(real) {
				continue
			}
			if !sandbox_path_inside(real, home) {
				continue
			}
			mut required_inside := ''
			for item in readable {
				if sandbox_path_inside(item, real) {
					required_inside = item
					break
				}
			}
			if required_inside != '' {
				sandbox.warnings << 'The sandbox cannot prevent formulae from reading:\n  ${real}\nbecause this required path is inside it:\n  ${required_inside}\nFormulae may access personal data in this directory.\n'
				continue
			}
			sandbox_deny_read_path(mut sandbox, real)!
		}
		return
	}
	sandbox_deny_read_path(mut sandbox, home)!
}

// Ruby method `allow_write(path:, type: :literal)` at line 461.
pub fn sandbox_allow_write(mut sandbox Sandbox, path string, type_name SandboxFilterType) ! {
	filter := sandbox_path_filter(path, type_name)!
	for operation in ['file-write*', 'file-write-setugid', 'file-write-mode'] {
		sandbox_add_rule(mut sandbox, true, operation, filter, '')
	}
}

// Ruby method `deny_write(path:, type: :literal)` at line 468.
pub fn sandbox_deny_write(mut sandbox Sandbox, path string, type_name SandboxFilterType) ! {
	sandbox_add_rule(mut sandbox, false, 'file-write*', sandbox_path_filter(path, type_name)!, '')
}

// Ruby method `allow_write_path(path)` at line 473.
pub fn sandbox_allow_write_path(mut sandbox Sandbox, path string) ! {
	sandbox_allow_write(mut sandbox, path, .subpath)!
}

// Ruby method `deny_write_path(path)` at line 486.
pub fn sandbox_deny_write_path(mut sandbox Sandbox, path string) ! {
	sandbox_deny_write(mut sandbox, path, .subpath)!
}

// Ruby method `allow_write_temp_and_cache` at line 491.
pub fn sandbox_allow_write_temp_and_cache(mut sandbox Sandbox) ! {
	sandbox_allow_write_path(mut sandbox, sandbox.paths.temp)!
	sandbox_allow_write_path(mut sandbox, sandbox.paths.cache)!
}

// Ruby method `deny_write_homebrew_repository` at line 531.
pub fn sandbox_deny_write_homebrew_repository(mut sandbox Sandbox) ! {
	sandbox_deny_write(mut sandbox, sandbox.paths.original_brew_file, .literal)!
	if os.norm_path(sandbox.paths.prefix) == os.norm_path(sandbox.paths.repository) {
		sandbox_deny_write_path(mut sandbox, sandbox.paths.library)!
		sandbox_deny_write_path(mut sandbox, os.join_path(sandbox.paths.repository, '.git'))!
	} else {
		sandbox_deny_write_path(mut sandbox, sandbox.paths.repository)!
	}
}

// Ruby method `allow_network(path:, type: :literal)` at line 542.
pub fn sandbox_allow_network(mut sandbox Sandbox, path string, type_name SandboxFilterType) ! {
	sandbox_add_rule(mut sandbox, true, 'network*', sandbox_path_filter(path, type_name)!, '')
}

// Ruby method `deny_all_network` at line 547.
pub fn sandbox_deny_all_network(mut sandbox Sandbox) {
	sandbox_add_rule(mut sandbox, false, 'network*', none, '')
}

// Ruby method `run(*args)` at line 552.
pub fn sandbox_run(mut sandbox Sandbox, args []string, context SandboxRunContext) !SandboxRunResult {
	tmpdir := context.tmpdir
	os.mkdir_all(tmpdir)!
	if context.allow_network_for_error_pipe {
		sandbox_allow_network(mut sandbox, os.join_path(tmpdir, 'socket'), .literal)!
	}
	sandbox.start = time.now().unix()
	command := if context.sandbox_command.len > 0 {
		context.sandbox_command.clone()
	} else {
		args.clone()
	}
	sandbox.last_command = command.clone()
	for operation in context.operations {
		if !sandbox_operation_allowed(sandbox, operation.operation, operation.path) {
			sandbox.failed = true
			return error('ErrorDuringExecution: ${command.join(' ')}')
		}
		match operation.operation {
			'file-write*' {
				os.mkdir_all(os.dir(operation.path))!
				os.write_file(operation.path, operation.content)!
			}
			'file-write-mode' { os.chmod(operation.path, operation.mode)! }
			'file-write-setugid' { os.chmod(operation.path, operation.mode)! }
			else {}
		}
	}
	if context.exit_status != 0 {
		sandbox.failed = true
		return error('ErrorDuringExecution: ${command.join(' ')} (status ${context.exit_status})')
	}
	return SandboxRunResult{ command: command, tmpdir: tmpdir, output: context.output }
}

// Ruby method `path_filter(path, type)` at line 665.
pub fn sandbox_path_filter(path string, type_name SandboxFilterType) !SandboxPathFilter {
	filter_path := match type_name {
		.regex { path }
		.subpath, .literal { sandbox_expand_realpath(path)! }
	}
	return SandboxPathFilter{ path: filter_path, type_name: type_name }
}
