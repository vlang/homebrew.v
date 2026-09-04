module homebrew

import os
import time

// Translated from Homebrew/brew `sandbox.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby attr_reader `attr_reader :path` at line 22.
pub fn ruby_sandbox_l22_d1_path(filter SandboxPathFilter) string {
	return filter.path
}

// Ruby attr_reader `attr_reader :type` at line 25.
pub fn ruby_sandbox_l25_d2_type(filter SandboxPathFilter) SandboxFilterType {
	return filter.type_name
}

// Ruby method `initialize(path:, type:)` at line 28.
pub fn ruby_sandbox_l28_d3_initialize(path string, type_name SandboxFilterType) SandboxPathFilter {
	return SandboxPathFilter{ path: path, type_name: type_name }
}

// Ruby attr_reader `attr_reader :allow` at line 37.
pub fn ruby_sandbox_l37_d4_allow(rule SandboxRule) bool {
	return rule.allow
}

// Ruby attr_reader `attr_reader :operation` at line 40.
pub fn ruby_sandbox_l40_d5_operation(rule SandboxRule) string {
	return rule.operation
}

// Ruby attr_reader `attr_reader :filter` at line 43.
pub fn ruby_sandbox_l43_d6_filter(rule SandboxRule) ?SandboxPathFilter {
	return if rule.has_filter { rule.filter } else { none }
}

// Ruby attr_reader `attr_reader :modifier` at line 46.
pub fn ruby_sandbox_l46_d7_modifier(rule SandboxRule) ?string {
	return if rule.modifier != '' { rule.modifier } else { none }
}

// Ruby method `initialize(allow:, operation:, filter:, modifier:)` at line 52.
pub fn new_sandbox_rule(allow bool, operation string, filter ?SandboxPathFilter, modifier string) SandboxRule {
	return SandboxRule{ allow: allow, operation: operation, filter: filter or { SandboxPathFilter{} }, has_filter: filter != none, modifier: modifier }
}

// Ruby attr_reader `attr_reader :rules` at line 64.
pub fn ruby_sandbox_l64_d9_rules(profile SandboxProfile) []SandboxRule {
	return profile.rules.clone()
}

// Ruby method `initialize` at line 67.
pub fn new_sandbox_profile() SandboxProfile {
	return SandboxProfile{}
}

// Ruby method `add_rule(rule)` at line 72.
pub fn sandbox_profile_add_rule(mut profile SandboxProfile, rule SandboxRule) {
	profile.rules << rule
}

// Ruby method `self.available?` at line 79.
pub fn ruby_sandbox_l79_d12_self_available() bool {
	return false
}

// Ruby method `self.full_write_isolation? = true` at line 84.
pub fn ruby_sandbox_l84_d13_self_full_write_isolation() bool {
	return true
}

// Ruby method `self.nested_sandbox? = false` at line 90.
pub fn ruby_sandbox_l90_d14_self_nested_sandbox() bool {
	return false
}

// Ruby method `self.avoid_nested_sandboxing?` at line 98.
pub fn ruby_sandbox_l98_d15_self_avoid_nested_sandboxing(context SandboxAvoidContext) !bool {
	if !context.opted_in || !context.nested {
		return false
	}
	if context.default_prefix {
		return error('Refusing to skip the sandbox: `\$HOMEBREW_AVOID_NESTED_SANDBOXING` is set inside another sandbox but Homebrew is using its default prefix (${context.prefix}); this is only supported in a custom prefix.')
	}
	if context.privileged_group in sandbox_privileged_groups {
		return error('Refusing to skip the sandbox: `\$HOMEBREW_AVOID_NESTED_SANDBOXING` is set inside another sandbox but you are in the privileged `${context.privileged_group}` group; this is only supported for an unprivileged user.')
	}
	return true
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

// Ruby method `self.run_or_fork(*args, step:, warn_without_sandbox: true, &_block)` at line 146.
pub fn ruby_sandbox_l146_d17_self_run_or_fork(command []string, step string, warn bool, context SandboxUseContext) SandboxRunOrForkResult {
	decision := sandbox_use_for(step, warn, context)
	return SandboxRunOrForkResult{ sandboxed: decision.use, forked: !decision.use, command: command.clone(), warning: decision.warning }
}

// Ruby method `self.with_preserved_brew_file(&block)` at line 159.
pub fn ruby_sandbox_l159_d18_self_with_preserved_brew_file(prefix string, full_write_isolation bool, mutation SandboxBrewMutation) ! {
	brew_file := os.join_path(prefix, 'bin', 'brew')
	if full_write_isolation {
		sandbox_apply_brew_mutation(brew_file, mutation)!
		return
	}
	directory := os.dir(brew_file)
	directory_mode := os.stat(directory)!.mode & 0o7777
	was_link := os.is_link(brew_file)
	contents := if was_link { os.readlink(brew_file)! } else { os.read_file(brew_file)! }
	file_mode := os.lstat(brew_file)!.mode & 0o7777
	sandbox_apply_brew_mutation(brew_file, mutation)!
	os.chmod(directory, int(directory_mode))!
	if was_link {
		current_target := os.readlink(brew_file) or { '' }
		if !os.is_link(brew_file) || current_target != contents {
			sandbox_remove_path(brew_file)!
			os.symlink(contents, brew_file)!
		}
	} else {
		current_contents := os.read_file(brew_file) or { '' }
		if os.is_link(brew_file) || !os.is_file(brew_file) || current_contents != contents || (os.lstat(brew_file)!.mode & 0o7777) != file_mode {
			sandbox_remove_path(brew_file)!
			os.write_file(brew_file, contents)!
			os.chmod(brew_file, int(file_mode))!
		}
	}
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

// Ruby method `self.state` at line 194.
pub fn ruby_sandbox_l194_d20_self_state(available bool) SandboxState {
	return if available { .available } else { .unavailable }
}

// Ruby method `self.failure_reason` at line 199.
pub fn ruby_sandbox_l199_d21_self_failure_reason(state SandboxState) ?string {
	return if state == .available { none } else { 'The sandbox is not available.' }
}

// Ruby method `self.reset_state!; end` at line 206.
pub fn ruby_sandbox_l206_d22_self_reset_state() SandboxHookAction {
	return .base_noop
}

// Ruby method `self.run_command(*command, writable_path:, deny_network: false)` at line 209.
pub fn ruby_sandbox_l209_d23_self_run_command(command []string, writable_path string, deny_network bool, available bool, reason string, paths SandboxPaths) !SandboxCommandPlan {
	sandbox_ensure_sandbox_available(available, reason)!
	expanded := os.abs_path(writable_path)
	if !os.is_dir(expanded) || !os.is_writable(expanded) {
		return error('Invalid usage: `${expanded}` is not a writable directory.')
	}
	real := os.real_path(expanded)
	mut sandbox := new_sandbox(paths)
	sandbox_allow_write_temp_and_cache(mut sandbox)!
	sandbox_allow_write_path(mut sandbox, real)!
	sandbox_deny_read_home(mut sandbox)!
	if deny_network { sandbox_deny_all_network(mut sandbox) }
	mut sandbox_command := [
		'/bin/sh',
		'-c',
		'cd "\$1" && shift && exec "\$@"',
		'brew-sandbox-exec',
		real,
	]
	sandbox_command << command
	return SandboxCommandPlan{ sandbox: sandbox, writable_path: real, command: sandbox_command }
}

// Ruby method `self.executable_name` at line 228.
pub fn ruby_sandbox_l228_d24_self_executable_name() !string {
	return error('Sandbox is not implemented for this OS.')
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

// Ruby method `self.executable!` at line 259.
pub fn ruby_sandbox_l259_d27_self_executable(context SandboxExecutableContext) !string {
	return sandbox_executable(context) or { error('${context.executable_name} is required to use the sandbox.') }
}

// Ruby method `self.executable_usable?(_candidate)` at line 264.
pub fn sandbox_executable_usable(candidate string, unsuitable []string) bool {
	return candidate !in unsuitable
}

// Ruby method `self.terminal_ioctl_request` at line 269.
pub fn ruby_sandbox_l269_d29_self_terminal_ioctl_request() !int {
	return error('Sandbox is not implemented for this OS.')
}

// Ruby method `self.tty_state` at line 277.
pub fn ruby_sandbox_l277_d30_self_tty_state(captured string) ?string {
	return if captured != '' { captured.trim_space() } else { none }
}

// Ruby method `initialize` at line 283.
pub fn new_sandbox(paths SandboxPaths) Sandbox {
	return Sandbox{ profile: new_sandbox_profile(), paths: paths }
}

// Ruby method `record_log(file)` at line 291.
pub fn ruby_sandbox_l291_d32_record_log(mut sandbox Sandbox, file string) {
	sandbox.logfile = file
}

// Ruby method `add_rule(allow:, operation:, filter: nil, modifier: nil)` at line 299.
pub fn sandbox_add_rule(mut sandbox Sandbox, allow bool, operation string, filter ?SandboxPathFilter, modifier string) {
	sandbox_profile_add_rule(mut sandbox.profile, new_sandbox_rule(allow, operation, filter, modifier))
}

// Ruby method `allow_read(path:, type: :literal)` at line 305.
pub fn sandbox_allow_read(mut sandbox Sandbox, path string, type_name SandboxFilterType) ! {
	sandbox_add_rule(mut sandbox, true, 'file-read*', sandbox_path_filter(path, type_name)!, '')
}

// Ruby method `allow_process_exec(path, no_sandbox: false)` at line 310.
pub fn ruby_sandbox_l310_d35_allow_process_exec(mut sandbox Sandbox, path string, no_sandbox bool) ! {
	sandbox_add_rule(mut sandbox, true, 'process-exec', sandbox_path_filter(path, .literal)!, if no_sandbox {
		'no-sandbox'
	} else {
		''
	})
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

// Ruby method `allow_read_if_exists(path:, type: :literal)` at line 453.
pub fn ruby_sandbox_l453_d39_allow_read_if_exists(mut sandbox Sandbox, path ?string, type_name SandboxFilterType) ! {
	actual := path or { return }
	if os.exists(actual) { sandbox_allow_read(mut sandbox, actual, type_name)! }
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

// Ruby method `allow_write_path_if_exists(path)` at line 478.
pub fn ruby_sandbox_l478_d43_allow_write_path_if_exists(mut sandbox Sandbox, path ?string) ! {
	actual := path or { return }
	if os.exists(actual) { sandbox_allow_write_path(mut sandbox, actual)! }
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

// Ruby method `add_install_hook_rules(network_access_allowed:)` at line 497.
pub fn ruby_sandbox_l497_d46_add_install_hook_rules(mut sandbox Sandbox, network_access_allowed bool) ! {
	sandbox_allow_write_temp_and_cache(mut sandbox)!
	sandbox_deny_write_homebrew_repository(mut sandbox)!
	sandbox_deny_read_home(mut sandbox)!
	if !network_access_allowed { sandbox_deny_all_network(mut sandbox) }
}

// Ruby method `allow_cvs` at line 505.
pub fn ruby_sandbox_l505_d47_allow_cvs(mut sandbox Sandbox) ! {
	sandbox_allow_write_path(mut sandbox, os.join_path(sandbox.paths.home, '.cvspass'))!
}

// Ruby method `allow_fossil` at line 510.
pub fn ruby_sandbox_l510_d48_allow_fossil(mut sandbox Sandbox) ! {
	for name in ['.fossil', '.fossil-journal'] {
		sandbox_allow_write_path(mut sandbox, os.join_path(sandbox.paths.home, name))!
	}
}

// Ruby method `allow_write_cellar(formula)` at line 516.
pub fn ruby_sandbox_l516_d49_allow_write_cellar(mut sandbox Sandbox, formula SandboxFormulaPaths) ! {
	for path in [formula.rack, formula.etc, formula.var] {
		sandbox_allow_write_path(mut sandbox, path)!
	}
}

// Ruby method `allow_write_xcode; end` at line 523.
pub fn ruby_sandbox_l523_d50_allow_write_xcode() SandboxHookAction {
	return .base_noop
}

// Ruby method `allow_write_log(formula)` at line 526.
pub fn ruby_sandbox_l526_d51_allow_write_log(mut sandbox Sandbox, formula SandboxFormulaPaths) ! {
	sandbox_allow_write_path(mut sandbox, formula.logs)!
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

// Ruby attr_reader `attr_reader :profile` at line 681.
pub fn ruby_sandbox_l681_d57_profile(sandbox Sandbox) SandboxProfile {
	return sandbox.profile
}

// Ruby method `copy_pty_output(controller)` at line 684.
pub fn ruby_sandbox_l684_d58_copy_pty_output(characters string, eio bool) string {
	return if eio { characters } else { characters }
}

// Ruby attr_reader `attr_reader :failed` at line 694.
pub fn ruby_sandbox_l694_d59_failed(sandbox Sandbox) bool {
	return sandbox.failed
}

// Ruby attr_reader `attr_reader :logfile` at line 697.
pub fn ruby_sandbox_l697_d60_logfile(sandbox Sandbox) ?string {
	return if sandbox.logfile != '' { sandbox.logfile } else { none }
}

// Ruby attr_reader `attr_reader :start` at line 700.
pub fn ruby_sandbox_l700_d61_start(sandbox Sandbox) ?i64 {
	return if sandbox.start > 0 { sandbox.start } else { none }
}

// Ruby method `home_write_paths = []` at line 705.
pub fn ruby_sandbox_l705_d62_home_write_paths() []string {
	return []
}

// Ruby method `sandbox_command(_args, _tmpdir)` at line 708.
pub fn ruby_sandbox_l708_d63_sandbox_command(_ []string, _ string) ![]string {
	return error('Sandbox is not implemented for this OS.')
}

// Ruby method `allow_network_for_error_pipe?` at line 713.
pub fn ruby_sandbox_l713_d64_allow_network_for_error_pipe() bool {
	return false
}

// Ruby method `ensure_child_tty_available; end` at line 718.
pub fn ruby_sandbox_l718_d65_ensure_child_tty_available() SandboxHookAction {
	return .base_noop
}

// Ruby method `apply_sandbox; end` at line 721.
pub fn ruby_sandbox_l721_d66_apply_sandbox() SandboxHookAction {
	return .base_noop
}

// Ruby method `record_sandbox_log; end` at line 724.
pub fn ruby_sandbox_l724_d67_record_sandbox_log() SandboxHookAction {
	return .base_noop
}

// Ruby method `expand_realpath(path)` at line 727.
pub fn ruby_sandbox_l727_d68_expand_realpath(path string) !string {
	return sandbox_expand_realpath(path)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "etc"
// 5: require "io/console"
// 6: require "pty"
// 7: require "tempfile"
// 8: require "exceptions"
// 9: require "utils/fork"
// 10: require "utils/output"
// 11:
// 12: # Helper class for running a sub-process inside of a sandboxed environment.
// 13: class Sandbox
// 14:   include Utils::Output::Mixin
// 15:   extend Utils::Output::Mixin
// 16:
// 17:   # Privileged groups that are expected to be able to use a working sandbox.
// 18:   PRIVILEGED_GROUPS = %w[admin staff root wheel].freeze
// 19:
// 20:   class SandboxPathFilter
// 21:     sig { returns(String) }
// 22:     attr_reader :path
// 23:
// 24:     sig { returns(Symbol) }
// 25:     attr_reader :type
// 26:
// 27:     sig { params(path: String, type: Symbol).void }
// 28:     def initialize(path:, type:)
// 29:       @path = T.let(path.freeze, String)
// 30:       @type = type
// 31:     end
// 32:   end
// 33:   private_constant :SandboxPathFilter
// 34:
// 35:   class SandboxRule
// 36:     sig { returns(T::Boolean) }
// 37:     attr_reader :allow
// 38:
// 39:     sig { returns(String) }
// 40:     attr_reader :operation
// 41:
// 42:     sig { returns(T.nilable(SandboxPathFilter)) }
// 43:     attr_reader :filter
// 44:
// 45:     sig { returns(T.nilable(String)) }
// 46:     attr_reader :modifier
// 47:
// 48:     sig {
// 49:       params(allow: T::Boolean, operation: String, filter: T.nilable(SandboxPathFilter),
// 50:              modifier: T.nilable(String)).void
// 51:     }
// 52:     def initialize(allow:, operation:, filter:, modifier:)
// 53:       @allow = allow
// 54:       @operation = operation
// 55:       @filter = filter
// 56:       @modifier = modifier
// 57:     end
// 58:   end
// 59:   private_constant :SandboxRule
// 60:
// 61:   # Configuration profile for a sandbox.
// 62:   class SandboxProfile
// 63:     sig { returns(T::Array[SandboxRule]) }
// 64:     attr_reader :rules
// 65:
// 66:     sig { void }
// 67:     def initialize
// 68:       @rules = T.let([], T::Array[SandboxRule])
// 69:     end
// 70:
// 71:     sig { params(rule: SandboxRule).void }
// 72:     def add_rule(rule)
// 73:       @rules << rule
// 74:     end
// 75:   end
// 76:   private_constant :SandboxProfile
// 77:
// 78:   sig { returns(T::Boolean) }
// 79:   def self.available?
// 80:     false
// 81:   end
// 82:
// 83:   sig { returns(T::Boolean) }
// 84:   def self.full_write_isolation? = true
// 85:
// 86:   # Whether Homebrew is itself running inside another sandbox, which would make
// 87:   # its own nested sandbox hang (macOS) or fail to start (Linux). Overridden
// 88:   # per-OS.
// 89:   sig { returns(T::Boolean) }
// 90:   def self.nested_sandbox? = false
// 91:
// 92:   # Skip Homebrew's own sandbox when it is opted into via
// 93:   # `$HOMEBREW_AVOID_NESTED_SANDBOXING` and already running inside another
// 94:   # sandbox. The skip is only supported for an unprivileged user in a custom
// 95:   # prefix; error out explaining why rather than silently sandboxing (and
// 96:   # hanging) when either is not the case.
// 97:   sig { returns(T::Boolean) }
// 98:   def self.avoid_nested_sandboxing?
// 99:     return false unless Homebrew::EnvConfig.avoid_nested_sandboxing?
// 100:     return false unless nested_sandbox?
// 101:
// 102:     if Homebrew.default_prefix?
// 103:       odie "Refusing to skip the sandbox: `$HOMEBREW_AVOID_NESTED_SANDBOXING` is set " \
// 104:            "inside another sandbox but Homebrew is using its default prefix " \
// 105:            "(#{HOMEBREW_PREFIX}); this is only supported in a custom prefix."
// 106:     end
// 107:
// 108:     privileged_group = PRIVILEGED_GROUPS.find do |name|
// 109:       group = Etc.getgrnam(name)
// 110:       group && Process.groups.include?(group.gid)
// 111:     rescue ArgumentError
// 112:       false
// 113:     end
// 114:     if privileged_group
// 115:       odie "Refusing to skip the sandbox: `$HOMEBREW_AVOID_NESTED_SANDBOXING` is set " \
// 116:            "inside another sandbox but you are in the privileged `#{privileged_group}` " \
// 117:            "group; this is only supported for an unprivileged user."
// 118:     end
// 119:
// 120:     true
// 121:   end
// 122:
// 123:   sig { params(step: String, warn_without_sandbox: T::Boolean).returns(T::Boolean) }
// 124:   def self.use_for?(step, warn_without_sandbox: true)
// 125:     unless available?
// 126:       opoo "Sandbox unavailable: #{step} without sandboxing!" if warn_without_sandbox
// 127:       return false
// 128:     end
// 129:
// 130:     if avoid_nested_sandboxing?
// 131:       opoo "#{step.capitalize} without Homebrew's sandbox; relying on the outer sandbox." if warn_without_sandbox
// 132:       return false
// 133:     end
// 134:
// 135:     true
// 136:   end
// 137:
// 138:   sig {
// 139:     params(
// 140:       args:                 T.any(String, Pathname),
// 141:       step:                 String,
// 142:       warn_without_sandbox: T::Boolean,
// 143:       _block:               T.proc.params(sandbox: Sandbox).void,
// 144:     ).void
// 145:   }
// 146:   def self.run_or_fork(*args, step:, warn_without_sandbox: true, &_block)
// 147:     if use_for?(step, warn_without_sandbox:)
// 148:       sandbox = new
// 149:       yield sandbox
// 150:       sandbox.run(*args)
// 151:     else
// 152:       Utils.safe_fork { exec(*args) }
// 153:     end
// 154:   end
// 155:
// 156:   # Landlock cannot protect `bin/brew` while allowing writes to `bin`, so a
// 157:   # sandboxed install hook could replace `brew` to persist into later commands.
// 158:   sig { params(block: T.proc.void).void }
// 159:   def self.with_preserved_brew_file(&block)
// 160:     return yield if full_write_isolation?
// 161:
// 162:     brew_file = HOMEBREW_PREFIX/"bin/brew"
// 163:     File.open(brew_file.dirname) do |brew_directory|
// 164:       brew_directory_mode = brew_directory.stat.mode & 07777
// 165:       symlink = brew_file.symlink?
// 166:       contents = symlink ? brew_file.readlink.to_s : brew_file.binread
// 167:       brew_file_mode = brew_file.lstat.mode & 07777
// 168:
// 169:       begin
// 170:         yield
// 171:       ensure
// 172:         brew_directory.chmod brew_directory_mode
// 173:         if symlink && (!brew_file.symlink? || brew_file.readlink.to_s != contents)
// 174:           FileUtils.rm_rf brew_file
// 175:           brew_file.make_symlink contents
// 176:         elsif !symlink && (brew_file.symlink? || !brew_file.file? || brew_file.binread != contents ||
// 177:                            (brew_file.lstat.mode & 07777) != brew_file_mode)
// 178:           FileUtils.rm_rf brew_file
// 179:           brew_file.atomic_write contents
// 180:           brew_file.chmod brew_file_mode
// 181:         end
// 182:       end
// 183:     end
// 184:   end
// 185:
// 186:   sig { void }
// 187:   def self.ensure_sandbox_available!
// 188:     return if available?
// 189:
// 190:     raise failure_reason || "The sandbox is not available."
// 191:   end
// 192:
// 193:   sig { returns(Symbol) }
// 194:   def self.state
// 195:     available? ? :available : :unavailable
// 196:   end
// 197:
// 198:   sig { returns(T.nilable(String)) }
// 199:   def self.failure_reason
// 200:     return if state == :available
// 201:
// 202:     "The sandbox is not available."
// 203:   end
// 204:
// 205:   sig { void }
// 206:   def self.reset_state!; end
// 207:
// 208:   sig { params(command: T.any(String, Pathname), writable_path: T.any(String, Pathname), deny_network: T::Boolean).void }
// 209:   def self.run_command(*command, writable_path:, deny_network: false)
// 210:     ensure_sandbox_available!
// 211:
// 212:     writable_path = Pathname(writable_path).expand_path
// 213:     if !writable_path.directory? || !writable_path.writable?
// 214:       raise UsageError,
// 215:             "`#{writable_path}` is not a writable directory."
// 216:     end
// 217:
// 218:     writable_path = writable_path.realpath
// 219:     sandbox = new
// 220:     sandbox.allow_write_temp_and_cache
// 221:     sandbox.allow_write_path writable_path
// 222:     sandbox.deny_read_home
// 223:     sandbox.deny_all_network if deny_network
// 224:     sandbox.run "/bin/sh", "-c", "cd \"$1\" && shift && exec \"$@\"", "brew-sandbox-exec", writable_path, *command
// 225:   end
// 226:
// 227:   sig { returns(String) }
// 228:   def self.executable_name
// 229:     raise NotImplementedError, "Sandbox is not implemented for this OS."
// 230:   end
// 231:
// 232:   sig { returns(::PATH) }
// 233:   def self.executable_candidate_paths
// 234:     executable_path = Pathname.new(executable_name)
// 235:     return PATH.new(executable_path.dirname) if executable_path.absolute?
// 236:
// 237:     PATH.new(ORIGINAL_PATHS, ENV.fetch("PATH"), HOMEBREW_ORIGINAL_BREW_FILE.dirname)
// 238:   end
// 239:
// 240:   sig { returns(T.nilable(Pathname)) }
// 241:   def self.executable
// 242:     executable_candidate_paths.each do |path|
// 243:       begin
// 244:         candidate = Pathname.new(File.expand_path(executable_name, path))
// 245:       rescue ArgumentError
// 246:         next
// 247:       end
// 248:
// 249:       next if !candidate.file? || !candidate.executable?
// 250:       next unless executable_usable?(candidate)
// 251:
// 252:       return candidate
// 253:     end
// 254:
// 255:     nil
// 256:   end
// 257:
// 258:   sig { returns(Pathname) }
// 259:   def self.executable!
// 260:     executable || raise("#{executable_name} is required to use the sandbox.")
// 261:   end
// 262:
// 263:   sig { params(_candidate: Pathname).returns(T::Boolean) }
// 264:   def self.executable_usable?(_candidate)
// 265:     true
// 266:   end
// 267:
// 268:   sig { returns(Integer) }
// 269:   def self.terminal_ioctl_request
// 270:     raise NotImplementedError, "Sandbox is not implemented for this OS."
// 271:   end
// 272:
// 273:   # The terminal state to restore after a PTY passthrough. It cannot change
// 274:   # in the background while `brew` runs (each passthrough restores it), so
// 275:   # capture it once per process. `nil` when it cannot be captured.
// 276:   sig { returns(T.nilable(String)) }
// 277:   def self.tty_state
// 278:     @tty_state ||= T.let(Utils.popen_read("stty", "-g").chomp, T.nilable(String))
// 279:     @tty_state.presence
// 280:   end
// 281:
// 282:   sig { void }
// 283:   def initialize
// 284:     @profile = T.let(SandboxProfile.new, SandboxProfile)
// 285:     @failed = T.let(false, T::Boolean)
// 286:     @logfile = T.let(nil, T.nilable(T.any(String, Pathname)))
// 287:     @start = T.let(nil, T.nilable(Time))
// 288:   end
// 289:
// 290:   sig { params(file: T.any(String, Pathname)).void }
// 291:   def record_log(file)
// 292:     @logfile = file
// 293:   end
// 294:
// 295:   sig {
// 296:     params(allow: T::Boolean, operation: String, filter: T.nilable(SandboxPathFilter),
// 297:            modifier: T.nilable(String)).void
// 298:   }
// 299:   def add_rule(allow:, operation:, filter: nil, modifier: nil)
// 300:     rule = SandboxRule.new(allow:, operation:, filter:, modifier:)
// 301:     @profile.add_rule(rule)
// 302:   end
// 303:
// 304:   sig { params(path: T.any(String, Pathname), type: Symbol).void }
// 305:   def allow_read(path:, type: :literal)
// 306:     add_rule allow: true, operation: "file-read*", filter: path_filter(path, type)
// 307:   end
// 308:
// 309:   sig { params(path: T.any(String, Pathname), no_sandbox: T::Boolean).void }
// 310:   def allow_process_exec(path, no_sandbox: false)
// 311:     modifier = "no-sandbox" if no_sandbox
// 312:     add_rule allow: true, operation: "process-exec", filter: path_filter(path, :literal), modifier:
// 313:   end
// 314:
// 315:   sig { params(path: T.any(String, Pathname), type: Symbol).void }
// 316:   def deny_read(path:, type: :literal)
// 317:     add_rule allow: false, operation: "file-read*", filter: path_filter(path, type)
// 318:   end
// 319:
// 320:   sig { params(path: T.any(String, Pathname)).void }
// 321:   def deny_read_path(path)
// 322:     deny_read path:, type: :subpath
// 323:   end
// 324:
// 325:   sig { void }
// 326:   def deny_read_home
// 327:     require "trust"
// 328:
// 329:     home = Pathname(Dir.home(ENV.fetch("USER"))).realpath
// 330:     readable_paths = [
// 331:       HOMEBREW_PREFIX,
// 332:       HOMEBREW_REPOSITORY,
// 333:       HOMEBREW_CACHE,
// 334:       HOMEBREW_LOGS,
// 335:       HOMEBREW_TEMP,
// 336:       ENV.fetch("GITHUB_WORKSPACE", nil),
// 337:       ENV.fetch("RUNNER_WORKSPACE", nil),
// 338:       ENV.fetch("RUNNER_TEMP", nil),
// 339:       Homebrew::Trust.trust_file,
// 340:       *home_write_paths.select { |path| File.exist?(path) },
// 341:     ].compact.flat_map do |path|
// 342:       path = Pathname(path)
// 343:       [path.expand_path, (path.realpath if path.exist?)].compact
// 344:     end
// 345:     if readable_paths.any? { |path| path.ascend.include?(home) }
// 346:       # When Homebrew or CI needs some `$HOME` paths to stay readable, deny only
// 347:       # well-known credential and personal-data paths instead of enumerating all
// 348:       # of `$HOME`.
// 349:       [
// 350:         ".ssh",
// 351:         ".aws",
// 352:         ".azure",
// 353:         ".boto",
// 354:         ".docker",
// 355:         ".config/fish",
// 356:         ".config/gh",
// 357:         ".config/gcloud",
// 358:         ".config/huggingface",
// 359:         ".config/pip",
// 360:         ".config/pypoetry",
// 361:         ".config/rclone",
// 362:         ".config/containers/auth.json",
// 363:         ".config/composer/auth.json",
// 364:         ".config/sops/age/keys.txt",
// 365:         ".gnupg",
// 366:         ".git-credentials",
// 367:         ".gitconfig",
// 368:         ".gsutil",
// 369:         ".kube",
// 370:         ".netrc",
// 371:         ".npmrc",
// 372:         ".yarnrc",
// 373:         ".yarnrc.yml",
// 374:         ".pnpmrc",
// 375:         ".bunfig.toml",
// 376:         ".pypirc",
// 377:         ".pip",
// 378:         ".poetry",
// 379:         ".local/share/pypoetry",
// 380:         ".gem/credentials",
// 381:         ".bundle/config",
// 382:         ".cargo/credentials",
// 383:         ".cargo/credentials.toml",
// 384:         ".composer/auth.json",
// 385:         ".condarc",
// 386:         ".m2/settings.xml",
// 387:         ".gradle/gradle.properties",
// 388:         ".sbt/1.0/credentials.sbt",
// 389:         ".terraform.d/credentials.tfrc.json",
// 390:         ".pulumi/credentials.json",
// 391:         ".oci/config",
// 392:         ".huggingface/token",
// 393:         ".cache/huggingface/token",
// 394:         ".claude",
// 395:         ".claude.json",
// 396:         ".kiro",
// 397:         ".bash_login",
// 398:         ".bash_logout",
// 399:         ".bash_profile",
// 400:         ".bashrc",
// 401:         ".bash_history",
// 402:         ".profile",
// 403:         ".zlogin",
// 404:         ".zlogout",
// 405:         ".zprofile",
// 406:         ".zshenv",
// 407:         ".zshrc",
// 408:         ".zsh_history",
// 409:         ".python_history",
// 410:         ".mysql_history",
// 411:         ".psql_history",
// 412:         ".env",
// 413:         ".env.local",
// 414:         "Documents",
// 415:         "Movies",
// 416:         "Music",
// 417:         "Pictures",
// 418:         "Library/Keychains",
// 419:         "Library/Mobile Documents",
// 420:         "Library/CloudStorage",
// 421:         "Dropbox",
// 422:         "Google Drive",
// 423:         "OneDrive",
// 424:       ].each do |path|
// 425:         path = home/path
// 426:         next unless path.exist?
// 427:
// 428:         path = path.realpath
// 429:         next unless path.ascend.include?(home)
// 430:
// 431:         if (readable_path = readable_paths.find { |required_path| required_path.ascend.include?(path) })
// 432:           opoo <<~EOS
// 433:             The sandbox cannot prevent formulae from reading:
// 434:               #{path}
// 435:             because this required path is inside it:
// 436:               #{readable_path}
// 437:             Formulae may access personal data in this directory.
// 438:           EOS
// 439:           next
// 440:         end
// 441:
// 442:         deny_read_path path
// 443:       rescue Errno::ENOENT
// 444:         nil
// 445:       end
// 446:       return
// 447:     end
// 448:
// 449:     deny_read_path home
// 450:   end
// 451:
// 452:   sig { params(path: T.nilable(T.any(String, Pathname)), type: Symbol).void }
// 453:   def allow_read_if_exists(path:, type: :literal)
// 454:     return unless path
// 455:     return unless File.exist?(path)
// 456:
// 457:     allow_read path:, type:
// 458:   end
// 459:
// 460:   sig { params(path: T.any(String, Pathname), type: Symbol).void }
// 461:   def allow_write(path:, type: :literal)
// 462:     add_rule allow: true, operation: "file-write*", filter: path_filter(path, type)
// 463:     add_rule allow: true, operation: "file-write-setugid", filter: path_filter(path, type)
// 464:     add_rule allow: true, operation: "file-write-mode", filter: path_filter(path, type)
// 465:   end
// 466:
// 467:   sig { params(path: T.any(String, Pathname), type: Symbol).void }
// 468:   def deny_write(path:, type: :literal)
// 469:     add_rule allow: false, operation: "file-write*", filter: path_filter(path, type)
// 470:   end
// 471:
// 472:   sig { params(path: T.any(String, Pathname)).void }
// 473:   def allow_write_path(path)
// 474:     allow_write path:, type: :subpath
// 475:   end
// 476:
// 477:   sig { params(path: T.nilable(T.any(String, Pathname))).void }
// 478:   def allow_write_path_if_exists(path)
// 479:     return unless path
// 480:     return unless File.exist?(path)
// 481:
// 482:     allow_write_path path
// 483:   end
// 484:
// 485:   sig { params(path: T.any(String, Pathname)).void }
// 486:   def deny_write_path(path)
// 487:     deny_write path:, type: :subpath
// 488:   end
// 489:
// 490:   sig { void }
// 491:   def allow_write_temp_and_cache
// 492:     allow_write_path HOMEBREW_TEMP
// 493:     allow_write_path HOMEBREW_CACHE
// 494:   end
// 495:
// 496:   sig { params(network_access_allowed: T::Boolean).void }
// 497:   def add_install_hook_rules(network_access_allowed:)
// 498:     allow_write_temp_and_cache
// 499:     deny_write_homebrew_repository
// 500:     deny_read_home
// 501:     deny_all_network unless network_access_allowed
// 502:   end
// 503:
// 504:   sig { void }
// 505:   def allow_cvs
// 506:     allow_write_path "#{Dir.home(ENV.fetch("USER"))}/.cvspass"
// 507:   end
// 508:
// 509:   sig { void }
// 510:   def allow_fossil
// 511:     allow_write_path "#{Dir.home(ENV.fetch("USER"))}/.fossil"
// 512:     allow_write_path "#{Dir.home(ENV.fetch("USER"))}/.fossil-journal"
// 513:   end
// 514:
// 515:   sig { params(formula: Formula).void }
// 516:   def allow_write_cellar(formula)
// 517:     allow_write_path formula.rack
// 518:     allow_write_path formula.etc
// 519:     allow_write_path formula.var
// 520:   end
// 521:
// 522:   sig { void }
// 523:   def allow_write_xcode; end
// 524:
// 525:   sig { params(formula: Formula).void }
// 526:   def allow_write_log(formula)
// 527:     allow_write_path formula.logs
// 528:   end
// 529:
// 530:   sig { void }
// 531:   def deny_write_homebrew_repository
// 532:     deny_write path: HOMEBREW_ORIGINAL_BREW_FILE
// 533:     if HOMEBREW_PREFIX.to_s == HOMEBREW_REPOSITORY.to_s
// 534:       deny_write_path HOMEBREW_LIBRARY
// 535:       deny_write_path HOMEBREW_REPOSITORY/".git"
// 536:     else
// 537:       deny_write_path HOMEBREW_REPOSITORY
// 538:     end
// 539:   end
// 540:
// 541:   sig { params(path: T.any(String, Pathname), type: Symbol).void }
// 542:   def allow_network(path:, type: :literal)
// 543:     add_rule allow: true, operation: "network*", filter: path_filter(path, type)
// 544:   end
// 545:
// 546:   sig { void }
// 547:   def deny_all_network
// 548:     add_rule allow: false, operation: "network*"
// 549:   end
// 550:
// 551:   sig { params(args: T.any(String, Pathname)).void }
// 552:   def run(*args)
// 553:     Dir.mktmpdir("homebrew-sandbox", HOMEBREW_TEMP) do |tmpdir|
// 554:       allow_network path: File.join(tmpdir, "socket"), type: :literal if allow_network_for_error_pipe?
// 555:       @start = T.let(Time.now, T.nilable(Time))
// 556:
// 557:       begin
// 558:         command = sandbox_command(args, tmpdir)
// 559:         # Start sandbox in a pseudoterminal to prevent access of the parent terminal.
// 560:         PTY.open do |controller, worker|
// 561:           # Set the PTY's window size to match the parent terminal.
// 562:           # Some formula tests are sensitive to the terminal size and fail if this is not set.
// 563:           winch = proc do |_sig|
// 564:             controller.winsize = if $stdout.tty?
// 565:               # We can only use IO#winsize if the IO object is a TTY.
// 566:               $stdout.winsize
// 567:             else
// 568:               # Otherwise, default to tput, if available.
// 569:               # This relies on ncurses rather than the system's ioctl.
// 570:               [Utils.popen_read("tput", "lines").to_i, Utils.popen_read("tput", "cols").to_i]
// 571:             end
// 572:           end
// 573:
// 574:           write_to_pty = proc do
// 575:             # Don't hang if stdin is not able to be used - throw EIO instead.
// 576:             old_ttin = trap(:TTIN, "IGNORE")
// 577:
// 578:             # Update the window size whenever the parent terminal's window size changes.
// 579:             old_winch = trap(:WINCH, &winch)
// 580:             winch.call(nil)
// 581:
// 582:             stdin_thread = Thread.new do
// 583:               IO.copy_stream($stdin, controller)
// 584:             rescue Errno::EIO
// 585:               # stdin is unavailable - move on.
// 586:             end
// 587:
// 588:             stdout_thread = Thread.new do
// 589:               copy_pty_output(controller)
// 590:             end
// 591:
// 592:             Utils.safe_fork(directory: tmpdir, yield_parent: true) do |error_pipe|
// 593:               if error_pipe
// 594:                 # Child side
// 595:                 Process.setsid
// 596:                 controller.close
// 597:                 worker.ioctl(self.class.terminal_ioctl_request, 0) # Make this the controlling terminal.
// 598:
// 599:                 ensure_child_tty_available
// 600:
// 601:                 # Move into a non-denied directory before `exec` so subsequent
// 602:                 # `getcwd(3)` calls (which walk every parent) never cross a
// 603:                 # `deny_read_home` path inherited from the caller's CWD.
// 604:                 Dir.chdir(tmpdir)
// 605:
// 606:                 worker.close_on_exec = true
// 607:                 apply_sandbox
// 608:                 exec(*command, in: worker, out: worker, err: worker) # And map everything to the PTY.
// 609:               else
// 610:                 # Parent side
// 611:                 worker.close
// 612:               end
// 613:             end
// 614:           rescue ChildProcessError => e
// 615:             raise ErrorDuringExecution.new(command, status: e.status)
// 616:           ensure
// 617:             stdin_thread&.kill
// 618:             stdout_thread&.kill
// 619:             trap(:TTIN, old_ttin)
// 620:             trap(:WINCH, old_winch)
// 621:           end
// 622:
// 623:           if $stdin.tty?
// 624:             # If stdin is a TTY, set it to a raw, passthrough mode while we
// 625:             # copy the input/output of the process spawned in the PTY, then
// 626:             # restore its original state afterwards. Keep `opost` set, unlike
// 627:             # `IO#raw`: clearing it stops LF -> CRLF translation for the whole
// 628:             # terminal, so anything written outside the PTY meanwhile (e.g.
// 629:             # our own `$stdout` when piped) renders staircased — and set the
// 630:             # mode in one `stty` call so there is no window where `opost` is
// 631:             # clear.
// 632:             begin
// 633:               # Ignore SIGTTOU as setting raw mode will hang if the process is in the background.
// 634:               old_ttou = trap(:TTOU, "IGNORE")
// 635:               if (tty_state = Sandbox.tty_state)
// 636:                 begin
// 637:                   # `-echo` matches `IO#raw`; `stty raw` alone leaves echo on.
// 638:                   Utils.popen_read("stty", "raw", "-echo", "opost")
// 639:                   write_to_pty.call
// 640:                 ensure
// 641:                   Utils.popen_read("stty", tty_state)
// 642:                 end
// 643:               else
// 644:                 # Cannot get the terminal state, so don't change it either.
// 645:                 write_to_pty.call
// 646:               end
// 647:             ensure
// 648:               trap(:TTOU, old_ttou)
// 649:             end
// 650:           else
// 651:             write_to_pty.call
// 652:           end
// 653:         end
// 654:       rescue
// 655:         @failed = true
// 656:         raise
// 657:       ensure
// 658:         record_sandbox_log
// 659:       end
// 660:     end
// 661:   end
// 662:
// 663:   # @api private
// 664:   sig { params(path: T.any(String, Pathname), type: Symbol).returns(SandboxPathFilter) }
// 665:   def path_filter(path, type)
// 666:     # Any character is allowed: the OS-specific renderer quotes paths safely
// 667:     # (the seatbelt renderer escapes the `"` and `\` string delimiters; the
// 668:     # Linux sandbox passes each path as a separate argument), so even paths
// 669:     # with spaces, parentheses, quotes, backslashes or newlines are expressible.
// 670:     filter_path = case type
// 671:     when :regex   then path.to_s
// 672:     when :subpath, :literal
// 673:       expand_realpath(Pathname.new(path)).to_s
// 674:     else raise ArgumentError, "Invalid path filter type: #{type}"
// 675:     end
// 676:
// 677:     SandboxPathFilter.new(path: filter_path, type:)
// 678:   end
// 679:
// 680:   sig { returns(SandboxProfile) }
// 681:   attr_reader :profile
// 682:
// 683:   sig { params(controller: IO).void }
// 684:   def copy_pty_output(controller)
// 685:     controller.each_char { |c| print(c) }
// 686:   rescue Errno::EIO
// 687:     # Linux marks a PTY as an I/O error when its peer closes, so treat this as EOF:
// 688:     # https://github.com/torvalds/linux/blob/master/drivers/tty/pty.c
// 689:   end
// 690:
// 691:   private
// 692:
// 693:   sig { returns(T::Boolean) }
// 694:   attr_reader :failed
// 695:
// 696:   sig { returns(T.nilable(T.any(String, Pathname))) }
// 697:   attr_reader :logfile
// 698:
// 699:   sig { returns(T.nilable(Time)) }
// 700:   attr_reader :start
// 701:
// 702:   # Home directories a build needs to write to, and so must also read;
// 703:   # overridden per-OS (e.g. the Xcode directories on macOS).
// 704:   sig { returns(T::Array[String]) }
// 705:   def home_write_paths = []
// 706:
// 707:   sig { params(_args: T::Array[T.any(String, Pathname)], _tmpdir: String).returns(T::Array[T.any(String, Pathname)]) }
// 708:   def sandbox_command(_args, _tmpdir)
// 709:     raise NotImplementedError, "Sandbox is not implemented for this OS."
// 710:   end
// 711:
// 712:   sig { returns(T::Boolean) }
// 713:   def allow_network_for_error_pipe?
// 714:     false
// 715:   end
// 716:
// 717:   sig { void }
// 718:   def ensure_child_tty_available; end
// 719:
// 720:   sig { void }
// 721:   def apply_sandbox; end
// 722:
// 723:   sig { void }
// 724:   def record_sandbox_log; end
// 725:
// 726:   sig { params(path: Pathname).returns(Pathname) }
// 727:   def expand_realpath(path)
// 728:     raise unless path.absolute?
// 729:
// 730:     path.exist? ? path.realpath : expand_realpath(path.parent)/path.basename
// 731:   end
// 732: end
// 733:
// 734: require "extend/os/sandbox"
