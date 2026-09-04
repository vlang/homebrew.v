module homebrew

import os
import x.json2

// Translated from Homebrew/brew `tap.rb`.
pub struct TapReference {
pub:
	user            string
	repository      string
	full_repository string
	name            string
	full_name       string
	remote          string
}

pub struct TapCache {
pub:
	remote                            ?string
	repository_var_suffix             ?string
	private                           ?bool
	formula_dir                       ?string
	formula_files                     []string
	formula_files_by_name             map[string]string
	formula_names                     []string
	prefix_to_versioned_formula_names map[string][]string
	formula_renames                   map[string]string
	formula_reverse_renames           map[string][]string
	cask_dir                          ?string
	cask_files                        []string
	cask_files_by_name                map[string]string
	cask_tokens                       []string
	cask_renames                      map[string]string
	cask_reverse_renames              map[string][]string
	alias_dir                         ?string
	alias_files                       []string
	aliases                           []string
	alias_table                       map[string]string
	alias_reverse_table               map[string][]string
	command_dir                       ?string
	command_files                     []string
	tap_migrations                    map[string]string
	reverse_tap_migrations            map[string][]string
	audit_exceptions                  map[string]json2.Any
	style_exceptions                  map[string]json2.Any
	synced_versions_formulae          [][]string
}

pub struct TapPrivateQuery {
pub:
	core_tap          bool
	core_cask_tap     bool
	custom_remote     bool
	github_value      ?bool
	github_api_failed bool
}

pub struct TapCommand {
pub:
	arguments   []string
	chdir       string
	environment map[string]string
}

pub struct TapRedirectRequest {
pub:
	tap                      TapReference
	tap_path                 string
	redirected_remote        string
	redirected_tap_installed bool
	allowed                  bool = true
	forbidden                bool
	forbidden_owner          string
	forbidden_owner_contact  string
	trust_invalidated        bool
	quiet                    bool
}

pub struct TapRedirectPlan {
pub:
	changed           bool
	tap               TapReference
	old_name          string
	old_remote        string
	old_path          string
	new_path          string
	move_repository   bool
	set_remote        TapCommand
	message           string
	trust_message     string
	invalidate_name   string
	invalidate_remote string
}

pub struct TapInstallRequest {
pub:
	tap                       TapReference
	path                      string
	installed                 bool
	shallow                   bool
	quiet                     bool
	clone_target              ?string
	custom_remote             bool
	verify                    bool
	force                     bool
	core_tap                  bool
	core_cask_tap             bool
	no_install_from_api       bool
	worktree_source_tap_path  ?string
	allowed                   bool = true
	forbidden                 bool
	forbidden_owner           string
	forbidden_owner_contact   string
	current_remote            ?string
	configured_core_remote    ?string
	fetched_worktree_head     ?string
	deprecated_official_taps  []string
	developer                 bool
	readall_valid             bool = true
	private                   bool
	credential_helper_present bool
	formula_names             []string
	cask_tokens               []string
}

pub enum TapInstallDisposition {
	clone
	fetch
	worktree
}

pub struct TapInstallPlan {
pub:
	disposition             TapInstallDisposition
	requested_remote        string
	command                 TapCommand
	worktree_source         string
	worktree_fetch          TapCommand
	worktree_add            TapCommand
	fix_remote              bool
	verify                  bool
	link_completions        bool
	rebuild_commands        bool
	update_formula_cache    bool
	update_cask_cache       bool
	remove_untapped_name    bool
	show_private_advice     bool
	cleanup_path_on_error   string
	cleanup_parent_on_error string
	delete_forceautoupdate  bool
}

pub struct TapEachResult {
pub:
	enumerator bool
	taps       []TapReference
}

pub struct TapLinkPlan {
pub:
	link_manpages      bool
	link_completions   bool
	unlink_completions bool
	command            string
}

pub struct TapFixRemoteRequest {
pub:
	path                      string
	name                      string
	remote                    ?string
	requested_remote          ?string
	quiet                     bool
	current_upstream_head     ?string
	origin_has_current_branch bool
	new_upstream_head         ?string
}

pub struct TapFixRemotePlan {
pub:
	set_remote_commands  []TapCommand
	fetch_command        ?TapCommand
	set_head_origin_auto bool
	rename_old_branch    string
	rename_new_branch    string
	message              string
}

pub struct TapUninstallPlan {
pub:
	path                     string
	worktree_source_path     ?string
	worktree_remove_command  ?TapCommand
	delete_formula_names     []string
	delete_cask_tokens       []string
	unlink_manpages          bool
	unlink_completions       bool
	rebuild_commands         bool
	add_to_untapped_official bool
}

pub struct TapPackageMetadata {
pub:
	autobump       bool
	disabled       bool
	skip_livecheck bool
}

pub struct TapHash {
pub:
	name                string
	user                string
	repo                string
	repository          string
	path                string
	installed           bool
	official            bool
	trusted             bool
	formula_names       []string
	cask_tokens         []string
	formula_files       []string
	cask_files          []string
	command_files       []string
	remote              string
	custom_remote       bool
	private             bool
	head                string
	last_commit         string
	branch              string
	has_install_details bool
}

pub struct TapAuditList {
pub:
	array_values []string
	hash_values  map[string]TapAuditValue
	is_hash      bool
}

pub struct TapAuditValue {
pub:
	value        string
	array_values []string
	is_array     bool
}

pub struct TapAuditResult {
pub:
	matched       bool
	value_present bool
	value         string
	is_array      bool
	array_value   []string
}

pub struct TapFormulaListResult {
pub:
	value   json2.Any
	warning string
}

pub type TapComparable = TapReference | string

fn tap_repository_without_official_prefix(repository string) string {
	lower := repository.to_lower()
	for prefix in ['homebrew-', 'linuxbrew-'] {
		if lower.starts_with(prefix) {
			return repository[prefix.len..]
		}
	}
	return repository
}

pub fn new_tap_reference(name string, remote string) !TapReference {
	parts := name.split('/')
	if parts.len != 2 || parts[0] == '' || parts[1] == '' {
		return error("Invalid tap name: '${name}'")
	}
	mut user := parts[0]
	mut repository := tap_repository_without_official_prefix(parts[1])
	if user.to_lower() in ['homebrew', 'linuxbrew'] {
		user = if user.to_lower() == 'homebrew' { 'Homebrew' } else { 'Linuxbrew' }
	}
	if user in ['Homebrew', 'Linuxbrew'] && repository in ['core', 'homebrew'] {
		user = 'Homebrew'
		repository = 'core'
	}
	if user == 'Homebrew' && repository == 'cask' {
		repository = 'cask'
	}
	full_repository := 'homebrew-${repository}'
	full_name := '${user}/${full_repository}'
	default_remote := 'https://github.com/${full_name}'
	return TapReference{
		user: user
		repository: repository
		full_repository: full_repository
		name: '${user}/${repository}'.to_lower()
		full_name: full_name
		remote: if remote.trim_space() == '' { default_remote } else { remote }
	}
}

pub fn tap_remote_reference(reference string) bool {
	if reference.starts_with('/') || reference.starts_with('.') || reference.starts_with('~') {
		return true
	}
	colon := reference.index(':') or { return false }
	slash := reference.index('/') or { reference.len }
	return colon < slash && colon + 1 < reference.len
}

fn valid_tap_remote_scheme(scheme string) bool {
	if scheme == '' || !scheme[0].is_letter() {
		return false
	}
	for character in scheme[1..] {
		if !character.is_alnum() && character !in [`+`, `.`, `-`] {
			return false
		}
	}
	return true
}

fn tap_remote_host(remote string) string {
	mut authority := remote
	if scheme_end := remote.index('://') {
		if valid_tap_remote_scheme(remote[..scheme_end]) {
			authority = remote[scheme_end + 3..]
		}
	}
	if slash := authority.index('/') {
		authority = authority[..slash]
	}
	if at := authority.last_index('@') {
		authority = authority[at + 1..]
	}
	if colon := authority.index(':') {
		authority = authority[..colon]
	}
	return authority
}

fn canonicalize_github_remote(remote string) string {
	if scheme_end := remote.index('://') {
		scheme := remote[..scheme_end]
		if !valid_tap_remote_scheme(scheme) {
			return remote
		}
		rest := remote[scheme_end + 3..]
		slash := rest.index('/') or { return remote }
		authority := rest[..slash]
		host := if at := authority.last_index('@') {
			authority[at + 1..]
		} else {
			authority
		}
		if host == 'github.com' {
			return 'https://github.com/${rest[slash + 1..]}'
		}
		return remote
	}
	colon := remote.index(':') or { return remote }
	authority := remote[..colon]
	host := if at := authority.last_index('@') {
		authority[at + 1..]
	} else {
		authority
	}
	if host == 'github.com' {
		return 'https://github.com/${remote[colon + 1..]}'
	}
	return remote
}

pub fn normalize_tap_remote(remote string) ?string {
	mut normalized := remote.trim_space().to_lower()
	if normalized == '' {
		return none
	}
	normalized = canonicalize_github_remote(normalized)
	if tap_remote_host(normalized) !in ['github.com', 'gitlab.com'] {
		return normalized
	}
	for normalized.ends_with('/') {
		normalized = normalized[..normalized.len - 1]
	}
	if normalized.ends_with('.git') {
		normalized = normalized[..normalized.len - 4]
	}
	return normalized
}

pub fn same_tap_remote(first string, second string) bool {
	first_normalized := normalize_tap_remote(first) or { return false }
	second_normalized := normalize_tap_remote(second) or { return false }
	return first_normalized == second_normalized
}

pub fn (tap TapReference) default_remote() string {
	return 'https://github.com/${tap.full_name}'
}

fn tap_remote_repository(remote string) ?string {
	mut repository_remote := remote.trim_space()
	if repository_remote == '' {
		return none
	}
	for repository_remote.ends_with('/') {
		repository_remote = repository_remote[..repository_remote.len - 1]
	}
	if repository_remote.ends_with('.git') {
		repository_remote = repository_remote[..repository_remote.len - 4]
	}
	mut path := repository_remote
	if scheme_end := repository_remote.index('://') {
		path = repository_remote[scheme_end + 3..]
		if slash := path.index('/') {
			path = path[slash + 1..]
		} else {
			return none
		}
	} else if colon := repository_remote.index(':') {
		path = repository_remote[colon + 1..]
	}
	parts := path.split('/')
	if parts.len < 2 || parts[parts.len - 2] == '' || parts.last() == '' {
		return none
	}
	return '${parts[parts.len - 2]}/${parts.last()}'
}

pub fn tap_remote_to_reference(remote string) ?string {
	normalized := normalize_tap_remote(remote) or { return none }
	repository := tap_remote_repository(normalized) or { return normalized }
	tap := new_tap_reference(repository, '') or { return normalized }
	return if same_tap_remote(normalized, tap.default_remote()) { tap.name } else { normalized }
}

pub fn normalize_tap_references(references []string, env_var string) []string {
	mut normalized := []string{}
	for reference in references {
		if tap_remote_reference(reference) {
			normalized << reference
			continue
		}
		tap := new_tap_reference(reference, '') or {
			eprintln('Warning: Invalid tap name in `\$${env_var}`: ${reference}')
			continue
		}
		normalized << tap.name
	}
	return normalized
}

pub fn tap_list_references(env_taps string, env_var string) []string {
	return normalize_tap_references(env_taps.fields(), env_var)
}

pub fn (tap TapReference) uses_custom_remote() bool {
	return tap.remote != '' && !same_tap_remote(tap.remote, tap.default_remote())
}

pub fn (tap TapReference) custom_remote() bool {
	return tap.remote == '' || !same_tap_remote(tap.remote, tap.default_remote())
}

pub fn (tap TapReference) official() bool {
	return tap.user == 'Homebrew'
}

pub fn (tap TapReference) reference() string {
	return if tap.remote == '' || same_tap_remote(tap.remote, tap.default_remote()) {
		tap.name
	} else {
		tap.remote
	}
}

pub fn (tap TapReference) matches_reference(reference string) bool {
	if tap_remote_reference(reference) {
		return same_tap_remote(reference, tap.remote)
	}
	return !tap.uses_custom_remote() && tap.name == reference.to_lower()
}

pub fn (tap TapReference) canonical_remote() bool {
	return tap.remote == '' || same_tap_remote(tap.remote, tap.default_remote())
}

pub fn (tap TapReference) implicitly_trusted() bool {
	return tap.user == 'Homebrew' && tap.canonical_remote()
}

pub fn tap_core_implicitly_trusted(remote string, no_install_from_api bool,
	core_git_remote string) bool {
	return !no_install_from_api || same_tap_remote(remote, core_git_remote)
}

pub fn (tap TapReference) allowed_by_references(allowed []string) bool {
	return tap.implicitly_trusted() || allowed.len == 0 || allowed.any(tap.matches_reference(it))
}

pub fn (tap TapReference) forbidden_by_references(forbidden []string) bool {
	return forbidden.any(tap.matches_reference(it))
}

pub fn tap_path(tap TapReference, tap_directory string) string {
	return os.join_path(tap_directory, tap.full_name.to_lower())
}

pub fn tap_from_path(path string, tap_directory string) ?TapReference {
	absolute := os.abs_path(path)
	root := os.abs_path(tap_directory).trim_right(os.path_separator)
	prefix := root + os.path_separator
	if !absolute.starts_with(prefix) {
		return none
	}
	relative := absolute[prefix.len..].replace('\\', '/')
	parts := relative.split('/')
	if parts.len < 2 || !parts[1].to_lower().starts_with('homebrew-') {
		return none
	}
	return new_tap_reference('${parts[0]}/${parts[1]}', '') or { none }
}

pub fn tap_with_formula_name(name string) ?(TapReference, string) {
	parts := name.split('/')
	if parts.len != 3 || parts[0] in ['.', '..'] || parts[1] in ['.', '..'] || parts.any(it == '') {
		return none
	}
	tap := new_tap_reference('${parts[0]}/${parts[1]}', '') or { return none }
	return tap, parts[2].to_lower()
}

pub fn tap_with_cask_token(token string) ?(TapReference, string) {
	return tap_with_formula_name(token)
}

pub fn tap_repository_var_suffix(tap TapReference, tap_directory string) string {
	path := tap_path(tap, tap_directory)
	mut relative := path.trim_string_left(tap_directory)
	mut suffix := ''
	for character in relative {
		suffix += if character.is_alnum() { character.ascii_str() } else { '_' }
	}
	return suffix.to_upper()
}

pub fn tap_worktree_source_path(tap TapReference, path string, repository_path string,
	worktree_list string) ?string {
	git_file := os.join_path(path, '.git')
	if !os.is_file(git_file) {
		return none
	}
	line := os.read_file(git_file) or { return none }.trim_right('\r\n')
	prefix := 'gitdir: '
	if !line.starts_with(prefix) || line.len == prefix.len {
		return none
	}
	mut git_dir := line[prefix.len..]
	if !os.is_abs_path(git_dir) {
		git_dir = os.join_path(path, git_dir)
	}
	git_dir = os.norm_path(git_dir)
	parent := os.dir(git_dir)
	grandparent := os.dir(parent)
	if os.base(grandparent) == '.git' && os.base(parent) == 'worktrees' {
		source_path := os.dir(grandparent)
		if os.norm_path(path) != os.norm_path(repository_path) {
			return source_path
		}
		candidate := os.join_path(source_path, 'Library', 'Taps', tap.full_name.to_lower())
		if os.exists(os.join_path(candidate, '.git')) {
			return candidate
		}
	}
	for worktree_line in worktree_list.split_into_lines() {
		if !worktree_line.starts_with('worktree ') {
			continue
		}
		candidate := os.join_path(worktree_line['worktree '.len..], 'Library', 'Taps', tap.full_name.to_lower())
		if os.exists(os.join_path(candidate, '.git')) {
			return candidate
		}
	}
	return none
}

pub fn tap_private(query TapPrivateQuery) bool {
	if query.core_tap || query.core_cask_tap {
		return false
	}
	if query.custom_remote || query.github_api_failed {
		return true
	}
	return query.github_value or { true }
}

pub fn tap_update_remote_from_redirect(output string, request TapRedirectRequest) !TapRedirectPlan {
	for line in output.split_into_lines() {
		lower := line.to_lower()
		needle := 'redirecting to '
		index := lower.index(needle) or { continue }
		mut redirected := line[index + needle.len..].fields()
		if redirected.len == 0 {
			continue
		}
		return tap_apply_redirect(request, redirected[0])
	}
	return TapRedirectPlan{
		tap: request.tap
		old_name: request.tap.name
		old_remote: request.tap.remote
	}
}

pub fn tap_apply_redirect(request TapRedirectRequest, redirected_remote string) !TapRedirectPlan {
	if request.tap.remote != '' && same_tap_remote(request.tap.remote, redirected_remote) {
		return TapRedirectPlan{
			tap: request.tap
			old_name: request.tap.name
			old_remote: request.tap.remote
		}
	}
	if !request.allowed || request.forbidden {
		mut message := '${request.tap.name} was redirected to ${redirected_remote} but ${request.forbidden_owner}\n'
		if !request.allowed {
			message += 'has not allowed this tap in `\$HOMEBREW_ALLOWED_TAPS`'
		}
		if !request.allowed && request.forbidden {
			message += ' and\n'
		}
		if request.forbidden {
			message += 'has forbidden this tap in `\$HOMEBREW_FORBIDDEN_TAPS`'
		}
		if request.forbidden_owner_contact != '' {
			message += '.\n${request.forbidden_owner_contact}'
		} else {
			message += '.'
		}
		return error(message)
	}
	mut redirected_tap := request.tap
	mut move_repository := false
	mut new_path := request.tap_path
	if reference := tap_remote_to_reference(redirected_remote) {
		if !tap_remote_reference(reference) {
			candidate := new_tap_reference(reference, redirected_remote)!
			if candidate.name != request.tap.name && !request.redirected_tap_installed {
				redirected_tap = candidate
				move_repository = true
				new_path = os.join_path(os.dir(os.dir(request.tap_path)), candidate.full_name.to_lower())
			}
		}
	}
	message := if request.quiet {
		''
	} else if request.tap.name == redirected_tap.name {
		'Redirected tap ${redirected_tap.name} remote to ${redirected_remote}'
	} else {
		'Redirected tap ${request.tap.name} to tap ${redirected_tap.name}'
	}
	return TapRedirectPlan{
		changed: true
		tap: redirected_tap
		old_name: request.tap.name
		old_remote: request.tap.remote
		old_path: request.tap_path
		new_path: new_path
		move_repository: move_repository
		set_remote: TapCommand{
			arguments: ['git', '-C', new_path, 'remote', 'set-url', 'origin', '--end-of-options',
				redirected_remote]
		}
		message: message
		trust_message: if request.quiet {
			''
		} else if request.trust_invalidated {
			'Untrusted tap: ${request.tap.name}'
		} else {
			'Not trusted tap: ${request.tap.name}'
		}
		invalidate_name: request.tap.name
		invalidate_remote: request.tap.remote
	}
}

pub fn tap_git_command(arguments []string, chdir string) TapCommand {
	mut args := ['git', '-c', 'core.hooksPath=${os.path_devnull}']
	args << arguments
	return TapCommand{
		arguments: args
		chdir: chdir
		environment: {
			'GIT_TERMINAL_PROMPT': '0'
		}
	}
}

pub fn tap_install_plan(request TapInstallRequest) !TapInstallPlan {
	if request.tap.official() && request.tap.repository in request.deprecated_official_taps {
		return error('${request.tap.name} was deprecated. This tap is now empty and all its contents were either deleted or migrated.')
	}
	if request.tap.user.to_lower() == 'caskroom' || request.tap.name == 'phinze/cask' {
		new_repository := if request.tap.repository == 'cask' {
			'cask'
		} else {
			'cask-${request.tap.repository}'
		}
		return error('${request.tap.name} was moved. Tap homebrew/${new_repository} instead.')
	}
	if request.custom_remote && request.clone_target == none {
		return error('TapNoCustomRemoteError: ${request.tap.name}')
	}
	requested_remote := request.clone_target or { request.tap.default_remote() }
	if request.core_tap {
		if configured := request.configured_core_remote {
			if requested := request.clone_target {
				if !same_tap_remote(requested, configured) {
					return error('TapCoreRemoteMismatchError: ${requested} != ${configured}')
				}
			}
		}
	}
	if request.installed && !request.custom_remote {
		if clone_target := request.clone_target {
			if current := request.current_remote {
				if requested_remote != current {
					return error('TapRemoteMismatchError: ${request.tap.name}: ${current} != ${requested_remote}')
				}
			}
			_ = clone_target
		}
		if !request.shallow {
			return error('TapAlreadyTappedError: ${request.tap.name}')
		}
	}
	if !request.allowed || request.forbidden {
		mut message := 'The installation of the ${request.tap.full_name} was requested but ${request.forbidden_owner}\n'
		if !request.allowed {
			message += 'has not allowed this tap in `\$HOMEBREW_ALLOWED_TAPS`'
		}
		if !request.allowed && request.forbidden {
			message += ' and\n'
		}
		if request.forbidden {
			message += 'has forbidden this tap in `\$HOMEBREW_FORBIDDEN_TAPS`'
		}
		message += '.'
		if request.forbidden_owner_contact != '' {
			message += '\n${request.forbidden_owner_contact}'
		}
		return error(message)
	}
	if request.verify && !request.developer && !request.readall_valid {
		return error('Cannot tap ${request.tap.name}: invalid syntax in tap!')
	}
	use_worktree := request.core_tap || (request.core_cask_tap && request.clone_target == none && !request.custom_remote)
	worktree_source := if use_worktree { request.worktree_source_tap_path } else { none }
	if request.installed {
		mut fetch_args := ['fetch']
		if request.shallow {
			fetch_args << '--unshallow'
		}
		if request.quiet {
			fetch_args << '-q'
		}
		return TapInstallPlan{
			disposition: .fetch
			requested_remote: requested_remote
			command: tap_git_command(fetch_args, request.path)
			fix_remote: (request.current_remote or { '' }) != requested_remote
			delete_forceautoupdate: true
		}
	}
	if (request.core_tap || request.core_cask_tap) && !request.no_install_from_api && !request.force && worktree_source == none {
		return error('Tapping ${request.tap.name} is no longer typically necessary. Add --force if you are sure you need it for contributing to Homebrew.')
	}
	mut clone_args := ['clone', '--origin=origin']
	if request.quiet {
		clone_args << '-q'
	}
	clone_args << ['--template=', '--config', 'core.fsmonitor=false', '--end-of-options',
		requested_remote, request.path]
	if source := worktree_source {
		mut fetch_args := ['git', '-c', 'core.hooksPath=${os.path_devnull}', '-C', source, 'fetch']
		if request.quiet {
			fetch_args << '--quiet'
		}
		fetch_args << ['origin', 'HEAD']
		mut add_args := ['git', '-c', 'core.hooksPath=${os.path_devnull}', '-C', source, 'worktree',
			'add']
		if request.quiet {
			add_args << '--quiet'
		}
		add_args << ['--detach', request.path, request.fetched_worktree_head or { 'HEAD' }]
		return TapInstallPlan{
			disposition: .worktree
			requested_remote: requested_remote
			worktree_source: source
			worktree_fetch: TapCommand{
				arguments: fetch_args
				environment: {
					'GIT_TERMINAL_PROMPT': '0'
				}
			}
			worktree_add: TapCommand{ arguments: add_args }
			verify: request.verify && !request.developer
			link_completions: true
			rebuild_commands: true
			remove_untapped_name: request.tap.official()
			show_private_advice: request.clone_target == none && request.private && !request.quiet && !request.credential_helper_present
			update_formula_cache: request.formula_names.len > 0
			update_cask_cache: request.cask_tokens.len > 0
			cleanup_path_on_error: request.path
			cleanup_parent_on_error: os.dir(request.path)
		}
	}
	return TapInstallPlan{
		disposition: .clone
		requested_remote: requested_remote
		command: tap_git_command(clone_args, '')
		verify: request.verify && !request.developer
		link_completions: true
		rebuild_commands: true
		remove_untapped_name: request.tap.official()
		show_private_advice: request.clone_target == none && request.private && !request.quiet && !request.credential_helper_present
		update_formula_cache: request.formula_names.len > 0
		update_cask_cache: request.cask_tokens.len > 0
		cleanup_path_on_error: request.path
		cleanup_parent_on_error: os.dir(request.path)
	}
}

pub fn tap_link_plan(tap TapReference, completions_enabled bool) TapLinkPlan {
	return TapLinkPlan{
		link_manpages: true
		link_completions: tap.official() || completions_enabled
		unlink_completions: !tap.official() && !completions_enabled
		command: 'brew tap --repair'
	}
}

pub fn tap_fix_remote_plan(request TapFixRemoteRequest) TapFixRemotePlan {
	mut commands := []TapCommand{}
	if requested := request.requested_remote {
		if requested != '' {
			commands << TapCommand{
				arguments: ['git', 'remote', 'set-url', 'origin', '--end-of-options', requested]
				chdir: request.path
			}
			commands << TapCommand{
				arguments: ['git', 'config', 'remote.origin.fetch',
					'+refs/heads/*:refs/remotes/origin/*']
				chdir: request.path
			}
		}
	}
	if request.remote == none {
		return TapFixRemotePlan{ set_remote_commands: commands }
	}
	if current := request.current_upstream_head {
		if current != '' && request.requested_remote == none && request.origin_has_current_branch {
			return TapFixRemotePlan{ set_remote_commands: commands }
		}
	}
	mut fetch_args := ['fetch']
	if request.quiet {
		fetch_args << '--quiet'
	}
	fetch_args << ['origin', '+refs/heads/*:refs/remotes/origin/*']
	old_head := request.current_upstream_head or { request.new_upstream_head or { '' } }
	new_head := request.new_upstream_head or { '' }
	return TapFixRemotePlan{
		set_remote_commands: commands
		fetch_command: tap_git_command(fetch_args, request.path)
		set_head_origin_auto: true
		rename_old_branch: if new_head != old_head { old_head } else { '' }
		rename_new_branch: if new_head != old_head { new_head } else { '' }
		message: if !request.quiet && new_head != old_head {
			'${request.name}: changed default branch name from ${old_head} to ${new_head}!'
		} else {
			''
		}
	}
}

pub fn tap_uninstall_plan(tap TapReference, path string, installed bool, manual bool,
	worktree_source ?string, formula_names []string, cask_tokens []string) !TapUninstallPlan {
	if !installed {
		return error('TapUnavailableError: ${tap.name}')
	}
	return TapUninstallPlan{
		path: path
		worktree_source_path: worktree_source
		worktree_remove_command: if source := worktree_source {
			TapCommand{ arguments: ['git', '-C', source, 'worktree', 'remove', '--force', path] }
		} else {
			none
		}
		delete_formula_names: formula_names
		delete_cask_tokens: cask_tokens
		unlink_manpages: true
		unlink_completions: true
		rebuild_commands: true
		add_to_untapped_official: manual && tap.official()
	}
}

pub fn tap_potential_formula_dirs(path string) []string {
	return [os.join_path(path, 'Formula'), os.join_path(path, 'HomebrewFormula'), path]
}

pub fn tap_formula_dir(tap TapReference, path string) string {
	if tap.official() {
		return os.join_path(path, 'Formula')
	}
	for candidate in tap_potential_formula_dirs(path) {
		if os.is_dir(candidate) {
			return candidate
		}
	}
	return os.join_path(path, 'Formula')
}

pub fn tap_formula_files(tap TapReference, path string) []string {
	directory := tap_formula_dir(tap, path)
	if !os.is_dir(directory) {
		return []
	}
	pattern := if os.norm_path(directory) == os.norm_path(path) {
		os.join_path(directory, '*.rb')
	} else {
		os.join_path(directory, '**', '*.rb')
	}
	mut files := os.glob(pattern) or { []string{} }
	files.sort()
	return files
}

pub fn tap_cask_files(path string) []string {
	directory := os.join_path(path, 'Casks')
	if !os.is_dir(directory) {
		return []
	}
	mut files := os.glob(os.join_path(directory, '**', '*.rb')) or { []string{} }
	files.sort()
	return files
}

pub fn tap_files_by_name(files []string) map[string]string {
	mut result := map[string]string{}
	for file in files {
		base := os.base(file).trim_string_right('.rb')
		existing := result[base] or { '' }
		if existing == '' || existing.len < file.len {
			result[base] = file
		}
	}
	return result
}

fn tap_ruby_relative_path(file string, prefix string, allow_subdirectories bool) bool {
	if prefix == '' {
		return !file.contains('/') && file.ends_with('.rb') && file.len > 3
	}
	if !file.starts_with('${prefix}/') {
		return false
	}
	relative := file[prefix.len + 1..]
	if relative == '' || !relative.ends_with('.rb') {
		return false
	}
	return allow_subdirectories || !relative.contains('/')
}

pub fn tap_formula_file(tap TapReference, path string, file string) !bool {
	directory := tap_formula_dir(tap, path)
	if os.norm_path(directory) == os.norm_path(os.join_path(path, 'Formula')) {
		return tap_ruby_relative_path(file, 'Formula', true)
	}
	if os.norm_path(directory) == os.norm_path(os.join_path(path, 'HomebrewFormula')) {
		return tap_ruby_relative_path(file, 'HomebrewFormula', true)
	}
	if os.norm_path(directory) == os.norm_path(path) {
		return tap_ruby_relative_path(file, '', false)
	}
	return error('Unexpected formula_dir: ${directory}')
}

pub fn tap_cask_file(file string) bool {
	return tap_ruby_relative_path(file, 'Casks', true)
}

pub fn tap_formula_file_to_name(tap TapReference, file string) string {
	return '${tap.name}/${os.base(file).trim_string_right('.rb')}'
}

pub fn tap_alias_file_to_name(tap TapReference, file string) string {
	return '${tap.name}/${os.base(file)}'
}

pub fn tap_formula_names(tap TapReference, files []string) []string {
	return files.map(tap_formula_file_to_name(tap, it))
}

fn tap_versioned_formula_prefix(name string) string {
	mut base := name
	mut full_suffix := ''
	if base.ends_with('-full') {
		base = base[..base.len - 5]
		full_suffix = '-full'
	}
	at := base.last_index('@') or { return name }
	version := base[at + 1..]
	if version == '' || !version.bytes().all(it.is_digit() || it == `.`) {
		return name
	}
	return base[..at] + full_suffix
}

pub fn tap_prefix_to_versioned_formulae_names(names []string) map[string][]string {
	mut result := map[string][]string{}
	for name in names {
		if !name.contains('@') {
			continue
		}
		prefix := tap_versioned_formula_prefix(name)
		result[prefix] << name
	}
	for key, values in result {
		mut sorted := values.clone()
		sorted.sort()
		result[key] = sorted
	}
	return result
}

pub fn tap_alias_files(path string) []string {
	directory := os.join_path(path, 'Aliases')
	mut files := os.glob(os.join_path(directory, '*')) or { []string{} }
	files = files.filter(os.is_file(it))
	files.sort()
	return files
}

pub fn tap_alias_table(tap TapReference, files []string) map[string]string {
	mut table := map[string]string{}
	for file in files {
		table[tap_alias_file_to_name(tap, file)] = tap_formula_file_to_name(tap, os.real_path(file))
	}
	return table
}

pub fn tap_reverse_table(table map[string]string) map[string][]string {
	mut reverse := map[string][]string{}
	for old_name, new_name in table {
		reverse[new_name] << old_name
	}
	return reverse
}

pub fn tap_contents(command_files []string, cask_files []string, formula_files []string) []string {
	mut contents := []string{}
	for pair in [TapCount{ singular: 'command', count: command_files.len }, TapCount{
		singular: 'cask'
		count: cask_files.len
	}, TapCount{ singular: 'formula', count: formula_files.len }] {
		if pair.count > 0 {
			plural := if pair.count == 1 {
				pair.singular
			} else if pair.singular == 'formula' {
				'formulae'
			} else {
				'${pair.singular}s'
			}
			contents << '${pair.count} ${plural}'
		}
	}
	return contents
}

struct TapCount {
	singular string
	count    int
}

pub fn tap_command_files(path string) []string {
	directory := os.join_path(path, 'cmd')
	return if os.is_dir(directory) { find_commands(directory) } else { [] }
}

pub fn tap_hash(tap TapReference, path string, installed bool, trusted bool, private_value bool,
	formula_names []string, cask_tokens []string, formula_files []string, cask_files []string,
	command_files []string, head ?string, last_commit ?string, branch ?string) TapHash {
	return TapHash{
		name: tap.name
		user: tap.user
		repo: tap.repository
		repository: tap.repository
		path: path
		installed: installed
		official: tap.official()
		trusted: trusted
		formula_names: formula_names
		cask_tokens: cask_tokens
		formula_files: if installed { formula_files } else { [] }
		cask_files: if installed { cask_files } else { [] }
		command_files: if installed { command_files } else { [] }
		remote: if installed { tap.remote } else { '' }
		custom_remote: installed && tap.custom_remote()
		private: installed && private_value
		head: if installed { head or { '(none)' } } else { '' }
		last_commit: if installed { last_commit or { 'never' } } else { '' }
		branch: if installed { branch or { '(none)' } } else { '' }
		has_install_details: installed
	}
}

pub fn tap_read_string_map(path string) map[string]string {
	if !os.is_file(path) {
		return map[string]string{}
	}
	return json2.decode[map[string]string](os.read_file(path) or {
		return map[string]string{}
	}) or { map[string]string{} }
}

fn tap_full_name(value string) bool {
	parts := value.split('/')
	return parts.len == 3 && parts.all(it != '')
}

pub fn tap_reverse_migration_renames(migrations map[string]string) map[string][]string {
	mut reverse := map[string][]string{}
	for old_name, new_name in migrations {
		if tap_full_name(new_name) {
			reverse[new_name] << old_name
		}
	}
	return reverse
}

pub fn tap_migration_oldnames(taps []map[string][]string, current_tap TapReference,
	name_or_token string) []string {
	key := '${current_tap.name}/${name_or_token}'
	mut result := []string{}
	for reverse in taps {
		result << reverse[key] or { []string{} }
	}
	return result
}

pub fn tap_autobump(packages map[string]TapPackageMetadata, autobump_file string) []string {
	mut names := []string{}
	for name, package in packages {
		if !package.disabled && !package.skip_livecheck && package.autobump {
			names << name
		}
	}
	if names.len == 0 && os.is_file(autobump_file) {
		names = os.read_lines(autobump_file) or { []string{} }
	}
	return names
}

pub fn tap_autobump_for_tap(core_tap bool, core_cask_tap bool,
	formula_packages map[string]TapPackageMetadata, cask_packages map[string]TapPackageMetadata,
	autobump_file string) []string {
	packages := if core_cask_tap {
		cask_packages
	} else if core_tap {
		formula_packages
	} else {
		map[string]TapPackageMetadata{}
	}
	return tap_autobump(packages, autobump_file)
}

pub fn tap_allow_bump(tap TapReference, autobump []string, name string,
	test_bot_autobump bool) bool {
	return test_bot_autobump || !tap.official() || name !in autobump
}

pub fn tap_read_string_arrays(path string) [][]string {
	if !os.is_file(path) {
		return []
	}
	return json2.decode[[][]string](os.read_file(path) or { return [] }) or { [] }
}

pub fn tap_read_string_array(path string) []string {
	if !os.is_file(path) {
		return []
	}
	return json2.decode[[]string](os.read_file(path) or { return [] }) or { [] }
}

pub fn tap_audit_exception(exceptions map[string]TapAuditList, list_name string,
	formula_or_cask string, value ?string) TapAuditResult {
	list := exceptions[list_name] or { return TapAuditResult{} }
	if !list.is_hash {
		return TapAuditResult{ matched: formula_or_cask in list.array_values }
	}
	entry := list.hash_values[formula_or_cask] or { return TapAuditResult{} }
	if query := value {
		return TapAuditResult{
			matched: if entry.is_array { query in entry.array_values } else { entry.value == query }
		}
	}
	return TapAuditResult{
		matched: true
		value_present: true
		value: entry.value
		is_array: entry.is_array
		array_value: entry.array_values
	}
}

pub fn tap_installed(tap_directory string) []TapReference {
	if !os.is_dir(tap_directory) {
		return []
	}
	mut result := []TapReference{}
	for user in os.ls(tap_directory) or { []string{} } {
		user_path := os.join_path(tap_directory, user)
		if !os.is_dir(user_path) {
			continue
		}
		for repository in os.ls(user_path) or { []string{} } {
			path := os.join_path(user_path, repository)
			if !os.is_dir(path) {
				continue
			}
			if tap := tap_from_path(path, tap_directory) {
				result << tap
			}
		}
	}
	return result
}

pub fn tap_core_taps() []TapReference {
	return [new_tap_reference('Homebrew/core', '') or { panic(err) },
		new_tap_reference('Homebrew/cask', '') or { panic(err) }]
}

pub fn tap_union(first []TapReference, second []TapReference) []TapReference {
	mut result := first.clone()
	mut names := result.map(it.name)
	for tap in second {
		if tap.name !in names {
			result << tap
			names << tap.name
		}
	}
	return result
}

pub fn tap_equal(tap TapReference, other ?TapComparable) bool {
	value := other or { return false }
	return match value {
		TapReference { tap.name == value.name }
		string {
			candidate := new_tap_reference(value, '') or { return false }
			tap.name == candidate.name
		}
	}
}

pub fn tap_read_formula_list(file string) TapFormulaListResult {
	contents := os.read_file(file) or {
		return TapFormulaListResult{ value: json2.Any(map[string]json2.Any{}) }
	}
	value := json2.decode[json2.Any](contents) or {
		return TapFormulaListResult{
			value: json2.Any(map[string]json2.Any{})
			warning: '${file} contains invalid JSON'
		}
	}
	return TapFormulaListResult{ value: value }
}

pub fn tap_read_formula_list_directory(path string, directory string) map[string]json2.Any {
	mut list := map[string]json2.Any{}
	for exception_file in os.glob(os.join_path(path, directory)) or { []string{} } {
		entry := tap_read_formula_list(exception_file)
		if entry.warning != '' {
			eprintln('Warning: ${entry.warning}')
		}
		if entry.value.str() in ['', '{}', '[]', 'null'] {
			continue
		}
		name := os.base(exception_file).trim_string_right('.json')
		list[name] = entry.value
	}
	return list
}
