module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/pr-pull.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct PrPullArgs {
pub mut:
	no_upload              bool
	no_commit              bool
	no_cherry_pick         bool
	dry_run                bool
	clean                  bool
	keep_old               bool
	autosquash             bool
	branch_okay            bool
	resolve                bool
	warn_on_upload_failure bool
	retain_bottle_dir      bool
	debug                  bool
	verbose                bool
	committer              string
	committer_set          bool
	message                string
	message_set            bool
	artifact_pattern       string
	artifact_pattern_set   bool
	tap                    string
	tap_set                bool
	head_sha               string
	head_sha_set           bool
	root_url               string
	root_url_set           bool
	root_url_using         string
	root_url_using_set     bool
	workflows              []string
	ignore_missing         []string
	named                  []string
}

pub struct PrPullTap {
pub:
	name                  string = 'homebrew/core'
	user                  string = 'Homebrew'
	full_repository       string = 'homebrew-core'
	path                  string
	default_remote        string = 'https://github.com/Homebrew/homebrew-core'
	formula_dir           string
	cask_dir              string
	installed             bool = true
	default_origin_branch bool = true
	branch_name           string = 'main'
	origin_branch_name    string = 'main'
	git_head              string
	commit_message        string
	git_executable        string = 'git'
}

pub struct PrPullPackage {
pub:
	name     string
	version  string
	revision int
	sha256   string
	is_cask  bool
	loaded   bool = true
}

pub struct PrPullReview {
pub:
	name  string
	email string
}

pub struct PrPullIssue {
pub:
	number       int
	pull_request bool
}

pub struct PrPullWorkflowRun {
pub:
	present       bool
	artifact_urls []string
}

// PrPullInjectedEffects is the safe boundary around GitHub, Git and filesystem
// reads. Tests and callers inject observations here; translated workflows return
// the writes and commands they would perform instead of executing them.
pub struct PrPullInjectedEffects {
pub:
	labels                     map[string][]string
	commits                    map[string][]string
	approved_reviews           map[string][]PrPullReview
	workflow_runs              map[string]PrPullWorkflowRun
	changed_packages           map[string][]PrPullPackage
	temporary_directories      map[string]string
	merge_bases                map[string]string
	github_sha                 string
	github_sha_set             bool
	github_actions_environment bool
	github_output              string
	issues                     []PrPullIssue
	changed_files              map[string][]string
}

pub struct PrPullEffect {
pub:
	kind    string
	argv    []string
	details map[string]string
}

pub struct PrPullDownload {
pub:
	url          string
	pull_request string
}

pub struct PrPullRunResult {
pub mut:
	args                 PrPullArgs
	required_executables []string
	environment          map[string]string
	effects              []PrPullEffect
	downloads            []PrPullDownload
	ohai                 []string
	warnings             []string
	debug                []string
	removed_directories  []string
	retained_directories []string
	output_writes        map[string]string
}

pub struct PrPullRunInput {
pub:
	argv      []string
	tap       PrPullTap
	effects   PrPullInjectedEffects
	brew_file string = 'brew'
}

pub struct PrPullCommitParts {
pub:
	subject  string
	body     string
	trailers string
}

pub struct PrPullSignoffInput {
pub:
	tap          PrPullTap
	pull_request string
	dry_run      bool
	reviews      []PrPullReview
}

pub struct PrPullSignoffResult {
pub:
	parts   PrPullCommitParts
	effects []PrPullEffect
}

pub struct PrPullPackageInput {
pub:
	tap       PrPullTap
	name      string
	path      string
	content   string
	overrides map[string]PrPullPackage
}

pub struct PrPullBumpInput {
pub:
	tap             PrPullTap
	old_contents    string
	new_contents    string
	subject_path    string
	reason          string
	reason_provided bool
	overrides       map[string]PrPullPackage
}

pub struct PrPullRewriteResult {
pub:
	subject string
	effects []PrPullEffect
}

pub struct PrPullRewordInput {
pub:
	commit          string
	file            string
	tap             PrPullTap
	old_contents    string
	new_contents    string
	reason          string
	reason_provided bool
	verbose         bool
	resolve         bool
	overrides       map[string]PrPullPackage
}

pub struct PrPullSquashInput {
pub:
	commits         []string
	file            string
	tap             PrPullTap
	commit_messages map[string]string
	authors         []string
	original_date   string
	old_contents    string
	new_contents    string
	reason          string
	reason_provided bool
	verbose         bool
	resolve         bool
	overrides       map[string]PrPullPackage
}

pub struct PrPullAutosquashAction {
pub:
	kind    string
	file    string
	commits []string
}

pub struct PrPullAutosquashInput {
pub:
	original_commit string
	tap             PrPullTap
	commits         []string
	commit_files    map[string][]string
	original_head   string
	reason          string
	reason_provided bool
	verbose         bool
	resolve         bool
	cherry_picked   bool
}

pub struct PrPullAutosquashResult {
pub mut:
	actions []PrPullAutosquashAction
	effects []PrPullEffect
	error   string
}

pub struct PrPullHeadInput {
pub:
	user         string
	repo         string
	pull_request string
	commits      []string
}

pub struct PrPullHeadResult {
pub:
	commits []string
	message string
}

pub struct PrPullCherryPickInput {
pub:
	user             string
	repo             string
	pull_request     string
	head_sha         string
	path             string = '.'
	commits          []string
	commits_provided bool
	fetched_commits  []string
	dry_run          bool
	verbose          bool
	resolve          bool
}

pub struct PrPullCherryPickResult {
pub:
	effects []PrPullEffect
	stdout  []string
	ohai    []string
}

pub struct PrPullBottlesInput {
pub:
	dry_run  bool
	labels   []string
	packages []PrPullPackage
}

pub struct PrPullChangedPackagesInput {
pub:
	tap                  PrPullTap
	original_commit      string
	formula_diff         string
	cask_diff            string
	disable_load_formula bool
	formula_packages     map[string]PrPullPackage
	cask_packages        map[string]PrPullPackage
}

pub struct PrPullChangedPackagesResult {
pub:
	packages []PrPullPackage
	warnings []string
	effects  []PrPullEffect
}

pub struct PrPullConflict {
pub:
	pull_request string
	files        []string
}

pub struct PrPullConflictsInput {
pub:
	repo          string
	pull_request  string
	issues        []PrPullIssue
	changed_files map[string][]string
}

pub struct PrPullConflictsResult {
pub:
	conflicts []PrPullConflict
	error     string
}

@[heap]
pub struct PrPullBoundaryInput {
pub:
	run         PrPullRunInput
	signoff     PrPullSignoffInput
	package     PrPullPackageInput
	bump        PrPullBumpInput
	reword      PrPullRewordInput
	squash      PrPullSquashInput
	autosquash  PrPullAutosquashInput
	head        PrPullHeadInput
	cherry_pick PrPullCherryPickInput
	bottles     PrPullBottlesInput
	changed     PrPullChangedPackagesInput
	conflicts   PrPullConflictsInput
}

pub fn pr_pull_boundary_input(input &PrPullBoundaryInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::DevCmd::PrPull::Input', '', {
		'pr_pull_input_address': u64(voidptr(input)).str()
	})
}

fn pr_pull_boundary_input_from_value(value brew_runtime.Value) &PrPullBoundaryInput {
	address := value.attributes['pr_pull_input_address'] or { panic('invalid PrPull input') }
	return unsafe { &PrPullBoundaryInput(voidptr(address.u64())) }
}

fn pr_pull_unique(values []string) []string {
	mut unique := []string{}
	for value in values {
		if value !in unique {
			unique << value
		}
	}
	return unique
}

fn pr_pull_comma_values(value string) []string {
	if value == '' {
		return []string{}
	}
	return value.split(',').filter(it != '')
}

fn pr_pull_option_value(argv []string, index int, option string) !(string, int) {
	argument := argv[index]
	if argument.starts_with('${option}=') {
		return argument.all_after('='), index
	}
	if index + 1 >= argv.len {
		return error('option `${option}` requires a value')
	}
	return argv[index + 1], index + 1
}

pub fn parse_pr_pull_args(argv []string) !PrPullArgs {
	mut parsed := PrPullArgs{}
	mut index := 0
	for index < argv.len {
		argument := argv[index]
		match argument {
			'--no-upload' {
				parsed.no_upload = true
			}
			'--no-commit' {
				parsed.no_commit = true
			}
			'--no-cherry-pick' {
				parsed.no_cherry_pick = true
			}
			'-n', '--dry-run' {
				parsed.dry_run = true
			}
			'--clean' {
				parsed.clean = true
			}
			'--keep-old' {
				parsed.keep_old = true
			}
			'--autosquash' {
				parsed.autosquash = true
			}
			'--branch-okay' {
				parsed.branch_okay = true
			}
			'--resolve' {
				parsed.resolve = true
			}
			'--warn-on-upload-failure' {
				parsed.warn_on_upload_failure = true
			}
			'--retain-bottle-dir' {
				parsed.retain_bottle_dir = true
			}
			'--debug' {
				parsed.debug = true
			}
			'--verbose' {
				parsed.verbose = true
			}
			else {
				if argument == '--committer' || argument.starts_with('--committer=') {
					value, next_index := pr_pull_option_value(argv, index, '--committer')!
					parsed.committer = value
					index = next_index
					parsed.committer_set = true
				} else if argument == '--message' || argument.starts_with('--message=') {
					value, next_index := pr_pull_option_value(argv, index, '--message')!
					parsed.message = value
					index = next_index
					parsed.message_set = true
				} else if argument == '--artifact-pattern' || argument.starts_with('--artifact-pattern=') {
					value, next_index := pr_pull_option_value(argv, index, '--artifact-pattern')!
					parsed.artifact_pattern = value
					index = next_index
					parsed.artifact_pattern_set = true
				} else if argument == '--artifact' || argument.starts_with('--artifact=') {
					value, next_index := pr_pull_option_value(argv, index, '--artifact')!
					parsed.artifact_pattern = value
					index = next_index
					parsed.artifact_pattern_set = true
				} else if argument == '--tap' || argument.starts_with('--tap=') {
					value, next_index := pr_pull_option_value(argv, index, '--tap')!
					parsed.tap = value
					index = next_index
					parsed.tap_set = true
				} else if argument == '--head-sha' || argument.starts_with('--head-sha=') {
					value, next_index := pr_pull_option_value(argv, index, '--head-sha')!
					parsed.head_sha = value
					index = next_index
					parsed.head_sha_set = true
				} else if argument == '--root-url' || argument.starts_with('--root-url=') {
					value, next_index := pr_pull_option_value(argv, index, '--root-url')!
					parsed.root_url = value
					index = next_index
					parsed.root_url_set = true
				} else if argument == '--root-url-using' || argument.starts_with('--root-url-using=') {
					value, next_index := pr_pull_option_value(argv, index, '--root-url-using')!
					parsed.root_url_using = value
					index = next_index
					parsed.root_url_using_set = true
				} else if argument == '--workflows' || argument.starts_with('--workflows=') {
					value, next_index := pr_pull_option_value(argv, index, '--workflows')!
					parsed.workflows = pr_pull_comma_values(value)
					index = next_index
				} else if argument == '--ignore-missing-artifacts'
					|| argument.starts_with('--ignore-missing-artifacts=') {
					value, next_index := pr_pull_option_value(argv, index, '--ignore-missing-artifacts')!
					parsed.ignore_missing = pr_pull_comma_values(value)
					index = next_index
				} else if argument.starts_with('-') {
					return error('unknown option `${argument}`')
				} else {
					parsed.named << argument
				}
			}
		}
		index++
	}
	if parsed.clean && parsed.autosquash {
		return error('options `--clean` and `--autosquash` conflict')
	}
	if parsed.message_set && !parsed.autosquash {
		return error('option `--message` depends on `--autosquash`')
	}
	if parsed.named.len == 0 {
		return error('at least one pull request is required')
	}
	return parsed
}

fn pr_pull_positive_integer(value string) bool {
	if value == '' || value[0] < `0` || value[0] > `9` {
		return false
	}
	mut end := 0
	for end < value.len && value[end] >= `0` && value[end] <= `9` {
		end++
	}
	return value[..end].int() > 0
}

fn pr_pull_parse_url(value string) !(string, string, string) {
	prefix := 'https://github.com/'
	location := value.index(prefix) or {
		return error('Not a GitHub pull request: ${value}')
	}
	parts := value[location + prefix.len..].split('/')
	if parts.len < 4 || parts[0] == '' || parts[1] == '' || parts[2] != 'pull'
		|| !parts[0].bytes().all((it >= `a` && it <= `z`) || (it >= `A` && it <= `Z`)
			|| (it >= `0` && it <= `9`) || it == `_` || it == `-`)
		|| !parts[1].bytes().all((it >= `a` && it <= `z`) || (it >= `A` && it <= `Z`)
			|| (it >= `0` && it <= `9`) || it == `_` || it == `-`) {
		return error('Not a GitHub pull request: ${value}')
	}
	mut digit_end := 0
	for digit_end < parts[3].len && parts[3][digit_end] >= `0` && parts[3][digit_end] <= `9` {
		digit_end++
	}
	if digit_end == 0 {
		return error('Not a GitHub pull request: ${value}')
	}
	return parts[0], parts[1], parts[3][..digit_end]
}

fn pr_pull_key(user string, repo string, pull_request string) string {
	return '${user}/${repo}#${pull_request}'
}

fn pr_pull_workflow_key(user string, repo string, pull_request string, workflow string) string {
	return '${pr_pull_key(user, repo, pull_request)}:${workflow}'
}

fn pr_pull_parse_author(value string) !(string, string) {
	open := value.last_index('<') or { return error('invalid author: ${value}') }
	if !value.ends_with('>') {
		return error('invalid author: ${value}')
	}
	name := value[..open].trim_space()
	email := value[open + 1..value.len - 1].trim_space()
	if name == '' || email == '' {
		return error('invalid author: ${value}')
	}
	return name, email
}

fn pr_pull_effect(kind string, argv []string, details map[string]string) PrPullEffect {
	return PrPullEffect{
		kind: kind
		argv: argv
		details: details
	}
}

fn pr_pull_is_trailer(line string) bool {
	colon := line.index(':') or { return false }
	if colon < 3 {
		return false
	}
	prefix := line[..colon].to_lower()
	if !prefix.ends_with('-by') {
		return false
	}
	return prefix.bytes().all((it >= `a` && it <= `z`) || it == `-`)
}

fn pr_pull_collapse_body(value string) string {
	mut result := ''
	mut newlines := 0
	for character in value {
		if character == `\n` {
			newlines++
			if newlines <= 2 {
				result += '\n'
			}
		} else {
			newlines = 0
			result += character.ascii_str()
		}
	}
	return result
}

pub fn separate_pr_pull_commit_message(message string) PrPullCommitParts {
	if message == '' {
		return PrPullCommitParts{}
	}
	lines := message.replace('\r\n', '\n').split('\n')
	if lines.len == 0 {
		return PrPullCommitParts{}
	}
	mut body_lines := []string{}
	mut trailer_lines := []string{}
	for line in lines[1..] {
		if pr_pull_is_trailer(line) {
			if line !in trailer_lines {
				trailer_lines << line
			}
		} else {
			body_lines << line
		}
	}
	return PrPullCommitParts{
		subject: lines[0].trim_space()
		body: pr_pull_collapse_body(body_lines.join('\n').trim_space())
		trailers: trailer_lines.join('\n').trim_space()
	}
}

fn pr_pull_trimmed_unique_lines(value string, additions []string) []string {
	mut lines := []string{}
	if value != '' {
		for line in value.split('\n') {
			trimmed := line.trim_space()
			if trimmed !in lines {
				lines << trimmed
			}
		}
	}
	for addition in additions {
		trimmed := addition.trim_space()
		if trimmed !in lines {
			lines << trimmed
		}
	}
	return lines
}

pub fn signoff_pr_pull(input PrPullSignoffInput) PrPullSignoffResult {
	if input.tap.commit_message.trim_space() == '' {
		return PrPullSignoffResult{}
	}
	mut parts := separate_pr_pull_commit_message(input.tap.commit_message)
	if input.pull_request != '' {
		review_trailers := input.reviews.map('Signed-off-by: ${it.name} <${it.email}>')
		parts = PrPullCommitParts{
			subject: parts.subject
			body: parts.body
			trailers: pr_pull_trimmed_unique_lines(parts.trailers, review_trailers).join('\n')
		}
		close_message := 'Closes #${input.pull_request}.'
		if !parts.body.contains(close_message) {
			parts = PrPullCommitParts{
				subject: parts.subject
				body: parts.body + '\n\n' + close_message
				trailers: parts.trailers
			}
		}
	}
	argv := [input.tap.git_executable, '-C', input.tap.path, 'commit', '--amend', '--signoff',
		'--allow-empty', '--quiet', '--message', parts.subject, '--message', parts.body, '--message',
		parts.trailers]
	kind := if input.dry_run { 'print' } else { 'safe_system' }
	return PrPullSignoffResult{
		parts: parts
		effects: [pr_pull_effect(kind, argv, map[string]string{})]
	}
}

fn pr_pull_path_under(path string, directory string) bool {
	return directory != '' && path.starts_with(directory.trim_string_right('/') + '/')
}

fn pr_pull_quoted_directive(content string, directive string) ?string {
	for raw_line in content.split_into_lines() {
		line := raw_line.trim_space()
		if !line.starts_with('${directive} ') {
			continue
		}
		remainder := line[directive.len..].trim_space()
		if remainder.len >= 2 && ((remainder[0] == `"` && remainder.contains('"'))
			|| (remainder[0] == `'` && remainder.contains("'"))) {
			quote := remainder[0]
			for index in 1 .. remainder.len {
				if remainder[index] == quote {
					return remainder[1..index]
				}
			}
		}
	}
	return none
}

pub fn get_pr_pull_package(input PrPullPackageInput) ?PrPullPackage {
	if package := input.overrides[input.content] {
		if package.loaded {
			return package
		}
		return none
	}
	is_cask := pr_pull_path_under(input.path, input.tap.cask_dir)
	trimmed := input.content.trim_space()
	if trimmed == '' {
		return none
	}
	if is_cask {
		if !trimmed.contains('cask ') || !trimmed.contains(' do') {
			return none
		}
	} else if !trimmed.contains('< Formula') {
		return none
	}
	version := pr_pull_quoted_directive(input.content, 'version') or { '' }
	sha256 := pr_pull_quoted_directive(input.content, 'sha256') or { '' }
	mut revision := 0
	for raw_line in input.content.split_into_lines() {
		line := raw_line.trim_space()
		if line.starts_with('revision ') {
			revision = line.all_after('revision ').trim_space().int()
			break
		}
	}
	return PrPullPackage{
		name: input.name
		version: version
		revision: revision
		sha256: sha256
		is_cask: is_cask
		loaded: true
	}
}

fn pr_pull_basename_without_rb(path string) string {
	name := path.replace('\\', '/').all_after_last('/')
	return if name.ends_with('.rb') { name[..name.len - 3] } else { name }
}

fn pr_pull_reasoned(prefix string, reason string, provided bool) string {
	if provided {
		return '${prefix} ${reason}'.trim_space()
	}
	return prefix.trim_space()
}

pub fn determine_pr_pull_bump_subject(input PrPullBumpInput) string {
	subject_name := pr_pull_basename_without_rb(input.subject_path)
	is_cask := pr_pull_path_under(input.subject_path, input.tap.cask_dir)
	new_package := get_pr_pull_package(PrPullPackageInput{
		tap: input.tap
		name: subject_name
		path: input.subject_path
		content: input.new_contents
		overrides: input.overrides
	}) or {
		return pr_pull_reasoned('${subject_name}: delete', input.reason, input.reason_provided)
	}
	old_package := get_pr_pull_package(PrPullPackageInput{
		tap: input.tap
		name: subject_name
		path: input.subject_path
		content: input.old_contents
		overrides: input.overrides
	}) or {
		kind := if is_cask { 'cask' } else { 'formula' }
		return '${subject_name} ${new_package.version} (new ${kind})'
	}
	if old_package.version != new_package.version {
		return '${subject_name} ${new_package.version}'
	}
	if !is_cask && old_package.revision != new_package.revision {
		return pr_pull_reasoned('${subject_name}: revision', input.reason, input.reason_provided)
	}
	if is_cask && old_package.sha256 != new_package.sha256 {
		return pr_pull_reasoned('${subject_name}: checksum update', input.reason, input.reason_provided)
	}
	if input.reason_provided {
		return '${subject_name}: ${input.reason}'.trim_space()
	}
	return '${subject_name}: rebuild'
}

pub fn reword_pr_pull_package_commit(input PrPullRewordInput) PrPullRewriteResult {
	package_path := input.tap.path.trim_string_right('/') + '/' + input.file
	package_name := pr_pull_basename_without_rb(package_path)
	mut effects := [pr_pull_effect('debug', []string{}, {
		'message': 'Cherry-picking ${package_path}: ${input.commit}'
	}), pr_pull_effect('cherry_pick', [input.tap.git_executable, '-C', input.tap.path, 'cherry-pick',
		input.commit], {
		'verbose': input.verbose.str()
		'resolve': input.resolve.str()
	})]
	bump_subject := determine_pr_pull_bump_subject(PrPullBumpInput{
		tap: input.tap
		old_contents: input.old_contents
		new_contents: input.new_contents
		subject_path: package_path
		reason: input.reason
		reason_provided: input.reason_provided
		overrides: input.overrides
	}).trim_space()
	if input.tap.commit_message.trim_space() == '' {
		return PrPullRewriteResult{
			subject: bump_subject
			effects: effects
		}
	}
	parts := separate_pr_pull_commit_message(input.tap.commit_message)
	if parts.subject != bump_subject && !parts.subject.starts_with('${package_name}:') {
		effects << pr_pull_effect('safe_system', [input.tap.git_executable, '-C', input.tap.path,
			'commit', '--amend', '-q', '-m', bump_subject, '-m', parts.subject, '-m', parts.body,
			'-m', parts.trailers], map[string]string{})
		effects << pr_pull_effect('ohai', []string{}, {
			'message': bump_subject
		})
	} else {
		effects << pr_pull_effect('ohai', []string{}, {
			'message': parts.subject
		})
	}
	return PrPullRewriteResult{
		subject: bump_subject
		effects: effects
	}
}

fn pr_pull_indented_body(body string) string {
	if body == '' {
		return ''
	}
	return body.split('\n').map('  ${it.trim_space()}').join('\n')
}

pub fn squash_pr_pull_package_commits(input PrPullSquashInput) !PrPullRewriteResult {
	if input.commits.len == 0 {
		return error('cannot squash an empty commit series')
	}
	mut effects := [pr_pull_effect('debug', []string{}, {
		'message': 'Squashing ${input.file}: ${input.commits.join(' ')}'
	})]
	mut messages := []string{}
	mut trailers := []string{}
	for commit in input.commits {
		message := input.commit_messages[commit] or { '' }
		if message.trim_space() == '' {
			continue
		}
		parts := separate_pr_pull_commit_message(message)
		body := pr_pull_indented_body(parts.body)
		formatted := '* ${parts.subject}\n${body}'.trim_space()
		messages << formatted
		trailers << parts.trailers
	}
	mut authors := pr_pull_unique(input.authors)
	original_author := if authors.len > 0 { authors[0] } else { '' }
	if authors.len > 0 {
		authors.delete(0)
	}
	for author in authors {
		trailers << 'Co-authored-by: ${author}'
	}
	trailers = pr_pull_unique(trailers)
	mut cherry_argv := [input.tap.git_executable, '-C', input.tap.path, 'cherry-pick', '--no-commit']
	cherry_argv << input.commits
	effects << pr_pull_effect('cherry_pick', cherry_argv, {
		'verbose': input.verbose.str()
		'resolve': input.resolve.str()
	})
	package_path := input.tap.path.trim_string_right('/') + '/' + input.file
	bump_subject := determine_pr_pull_bump_subject(PrPullBumpInput{
		tap: input.tap
		old_contents: input.old_contents
		new_contents: input.new_contents
		subject_path: package_path
		reason: input.reason
		reason_provided: input.reason_provided
		overrides: input.overrides
	})
	effects << pr_pull_effect('safe_system', [input.tap.git_executable, '-C', input.tap.path, 'commit',
		'--quiet', '-m', bump_subject, '-m', messages.join('\n'), '-m', trailers.join('\n'),
		'--author', original_author, '--date', input.original_date, '--', input.file], map[string]string{})
	effects << pr_pull_effect('ohai', []string{}, {
		'message': bump_subject
	})
	return PrPullRewriteResult{
		subject: bump_subject
		effects: effects
	}
}

fn pr_pull_valid_package_file(tap PrPullTap, file string) bool {
	absolute := tap.path.trim_string_right('/') + '/' + file
	return absolute.ends_with('.rb')
		&& (pr_pull_path_under(absolute, tap.formula_dir)
			|| pr_pull_path_under(absolute, tap.cask_dir))
}

fn pr_pull_autosquash_failure(mut result PrPullAutosquashResult, input PrPullAutosquashInput,
	message string) PrPullAutosquashResult {
	result.error = message
	if input.original_head != '' {
		result.effects << pr_pull_effect('warning', []string{}, {
			'message': 'Autosquash encountered an error; resetting to original state at ${input.original_head}'
		})
		result.effects << pr_pull_effect('system', [input.tap.git_executable, '-C', input.tap.path,
			'reset', '--hard', input.original_head], map[string]string{})
		if input.cherry_picked {
			result.effects << pr_pull_effect('system', [input.tap.git_executable, '-C',
				input.tap.path, 'cherry-pick', '--abort'], map[string]string{})
		}
	}
	return result
}

pub fn autosquash_pr_pull(input PrPullAutosquashInput) PrPullAutosquashResult {
	mut result := PrPullAutosquashResult{}
	mut files_to_commits := map[string][]string{}
	for commit in input.commits {
		files := input.commit_files[commit] or { []string{} }
		for file in files {
			files_to_commits[file] << commit
			if !pr_pull_valid_package_file(input.tap, file) {
				message := 'Autosquash can only squash commits that modify formula or cask files.\n  File:   ${file}\n  Commit: ${commit}\n'
				return pr_pull_autosquash_failure(mut result, input, message)
			}
		}
	}
	result.effects << pr_pull_effect('safe_system', [input.tap.git_executable, '-C', input.tap.path,
		'reset', '--hard', input.original_commit], map[string]string{})
	mut processed := []string{}
	for commit in input.commits {
		if commit in processed {
			continue
		}
		files := input.commit_files[commit] or { []string{} }
		if files.len == 1 && (files_to_commits[files[0]] or { []string{} }).len == 1 {
			result.actions << PrPullAutosquashAction{
				kind: 'reword'
				file: files[0]
				commits: [commit]
			}
			processed << commit
		} else if files.len == 1 && (files_to_commits[files[0]] or { []string{} }).len > 1 {
			series := files_to_commits[files[0]] or { []string{} }
			result.actions << PrPullAutosquashAction{
				kind: 'squash'
				file: files[0]
				commits: series.clone()
			}
			processed << series
		} else {
			message := "Autosquash can't split commits that modify multiple files.\n  Commit: ${commit}\n  Files:  ${files.join(' ')}\n"
			return pr_pull_autosquash_failure(mut result, input, message)
		}
	}
	return result
}

pub fn check_pr_pull_head_sha(input PrPullHeadInput) !PrPullHeadResult {
	if input.commits.len == 0 {
		return error('pull request #${input.pull_request} has no commits')
	}
	return PrPullHeadResult{
		commits: input.commits.clone()
		message: 'Pull request #${input.pull_request} head SHA: ${input.commits.last()}'
	}
}

pub fn cherry_pick_pr_pull(input PrPullCherryPickInput) !PrPullCherryPickResult {
	if input.dry_run {
		return PrPullCherryPickResult{
			stdout: [
				'git fetch --force origin +refs/pull/${input.pull_request}/head\ngit merge-base HEAD FETCH_HEAD\ngit cherry-pick --ff --allow-empty \$merge_base..FETCH_HEAD\n',
			]
		}
	}
	commits := if input.commits_provided {
		input.commits.clone()
	} else {
		input.fetched_commits.clone()
	}
	if commits.len == 0 {
		return error('pull request #${input.pull_request} has no commits')
	}
	actual := commits.last().to_lower()
	if actual != input.head_sha {
		return error('Pull request #${input.pull_request} is at ${actual} but expected ${input.head_sha}.')
	}
	count_word := if commits.len == 1 { 'commit' } else { 'commits' }
	mut cherry_argv := ['git', '-C', input.path, 'cherry-pick', '--ff', '--allow-empty']
	cherry_argv << commits
	return PrPullCherryPickResult{
		effects: [
			pr_pull_effect('safe_system', ['git', '-C', input.path, 'fetch', '--quiet', '--force',
				'origin', commits.last()], map[string]string{}),
			pr_pull_effect('cherry_pick', cherry_argv, {
				'verbose': input.verbose.str()
				'resolve': input.resolve.str()
			}),
		]
		ohai: ['Using ${commits.len} ${count_word} from #${input.pull_request}']
	}
}

pub fn pr_pull_formulae_need_bottles(input PrPullBottlesInput) bool {
	if input.dry_run || 'CI-syntax-only' in input.labels || 'CI-no-bottles' in input.labels {
		return false
	}
	return input.packages.any(!it.is_cask)
}

fn pr_pull_terminated_lines(output string) []string {
	mut lines := []string{}
	mut start := 0
	for index, character in output {
		if character == `\n` {
			mut line := output[start..index]
			if line.ends_with('\r') {
				line = line[..line.len - 1]
			}
			lines << line
			start = index + 1
		}
	}
	return lines
}

pub fn changed_pr_pull_packages(input PrPullChangedPackagesInput) PrPullChangedPackagesResult {
	formula_command := [input.tap.git_executable, '-C', input.tap.path, 'diff-tree', '-r',
		'--name-only', '--diff-filter=AM', input.original_commit, 'HEAD', '--',
		input.tap.formula_dir]
	cask_command := [input.tap.git_executable, '-C', input.tap.path, 'diff-tree', '-r', '--name-only',
		'--diff-filter=AM', input.original_commit, 'HEAD', '--', input.tap.cask_dir]
	mut formulae := []PrPullPackage{}
	mut warnings := []string{}
	formula_lines := pr_pull_terminated_lines(input.formula_diff).filter(it.ends_with('.rb'))
	if input.disable_load_formula && formula_lines.len > 0 {
		warnings << "Can't check if updated bottles are necessary as `\$HOMEBREW_DISABLE_LOAD_FORMULA` is set!"
	} else {
		for line in formula_lines {
			name := '${input.tap.name}/${pr_pull_basename_without_rb(line)}'
			if package := input.formula_packages[name] {
				if package.loaded {
					formulae << package
				}
			}
		}
	}
	mut casks := []PrPullPackage{}
	for line in pr_pull_terminated_lines(input.cask_diff) {
		if !line.ends_with('.rb') {
			continue
		}
		name := '${input.tap.name}/${pr_pull_basename_without_rb(line)}'
		if package := input.cask_packages[name] {
			if package.loaded {
				casks << package
			}
		}
	}
	mut packages := formulae.clone()
	packages << casks
	return PrPullChangedPackagesResult{
		packages: packages
		warnings: warnings
		effects: [pr_pull_effect('popen_read', formula_command, map[string]string{}),
			pr_pull_effect('popen_read', cask_command, map[string]string{})]
	}
}

fn pr_pull_json_escape(value string) string {
	return value.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n')
}

fn pr_pull_conflicts_json(conflicts []PrPullConflict) string {
	mut blocks := []string{}
	for conflict in conflicts {
		mut file_lines := []string{}
		for file in conflict.files {
			file_lines << '    "${pr_pull_json_escape(file)}"'
		}
		blocks << '  "${pr_pull_json_escape(conflict.pull_request)}": [\n${file_lines.join(',\n')}\n  ]'
	}
	return '{\n${blocks.join(',\n')}\n}'
}

pub fn check_pr_pull_conflicts(input PrPullConflictsInput) PrPullConflictsResult {
	mut files_to_prs := map[string][]int{}
	current_number := input.pull_request.int()
	for issue in input.issues {
		if !issue.pull_request || issue.number == current_number {
			continue
		}
		for file in input.changed_files[issue.number.str()] or { []string{} } {
			files_to_prs[file] << issue.number
		}
	}
	if files_to_prs.len == 0 {
		return PrPullConflictsResult{}
	}
	mut conflicts := []PrPullConflict{}
	for filename in input.changed_files[input.pull_request] or { []string{} } {
		for number in files_to_prs[filename] or { []int{} } {
			key := '${input.repo}/pull/${number}'
			mut found := -1
			for index, conflict in conflicts {
				if conflict.pull_request == key {
					found = index
					break
				}
			}
			if found < 0 {
				conflicts << PrPullConflict{
					pull_request: key
					files: [filename]
				}
			} else {
				mut files := conflicts[found].files.clone()
				files << filename
				conflicts[found] = PrPullConflict{
					pull_request: key
					files: files
				}
			}
		}
	}
	if conflicts.len == 0 {
		return PrPullConflictsResult{}
	}
	return PrPullConflictsResult{
		conflicts: conflicts
		error: 'You are trying to merge a pull request that conflicts with a long running build in:\n${pr_pull_conflicts_json(conflicts)}\n'
	}
}

pub fn run_pr_pull(input PrPullRunInput) !PrPullRunResult {
	parsed := parse_pr_pull_args(input.argv)!
	if !input.tap.installed {
		return error(input.tap.name)
	}
	mut result := PrPullRunResult{
		args: parsed
		required_executables: ['unzip']
		environment: map[string]string{}
		effects: [pr_pull_effect('set_name_email', []string{}, {
			'committer': (!parsed.committer_set || parsed.committer.trim_space() == '').str()
		}), pr_pull_effect('setup_gpg', []string{}, map[string]string{})]
		output_writes: map[string]string{}
	}
	if parsed.committer_set {
		name, email := pr_pull_parse_author(parsed.committer)!
		result.environment['GIT_COMMITTER_NAME'] = name
		result.environment['GIT_COMMITTER_EMAIL'] = email
	}
	workflows := if parsed.workflows.len > 0 {
		parsed.workflows.clone()
	} else {
		[
			'tests.yml',
		]
	}
	artifact_pattern := if parsed.artifact_pattern_set {
		parsed.artifact_pattern
	} else {
		'bottles{,_*}'
	}
	mut seen := []string{}
	for original in parsed.named {
		if original in seen {
			continue
		}
		seen << original
		argument := if pr_pull_positive_integer(original) {
			'${input.tap.default_remote}/pull/${original}'
		} else {
			original
		}
		user, repo, pull_request := pr_pull_parse_url(argument)!
		if !input.tap.default_origin_branch && !parsed.branch_okay && !parsed.no_commit
			&& !parsed.no_cherry_pick {
			result.warnings << 'Current branch is ${input.tap.branch_name}: do you need to pull inside ${input.tap.origin_branch_name}?'
		}
		key := pr_pull_key(user, repo, pull_request)
		labels := input.effects.labels[key] or { []string{} }
		if 'autosquash' in labels && !parsed.autosquash {
			result.warnings << 'Pull request is labelled `autosquash`: do you need to pass `--autosquash`?'
		}
		mut commits := []string{}
		mut head_sha := ''
		if parsed.head_sha_set && parsed.head_sha.trim_space() != '' {
			head_sha = parsed.head_sha.to_lower()
			result.ohai << 'Pull request #${pull_request} expected head SHA: ${head_sha}'
		} else {
			commits = input.effects.commits[key] or { []string{} }
			head := check_pr_pull_head_sha(PrPullHeadInput{
				user: user
				repo: repo
				pull_request: pull_request
				commits: commits
			})!
			head_sha = head.commits.last()
			result.ohai << head.message
		}
		conflicts := check_pr_pull_conflicts(PrPullConflictsInput{
			repo: '${user}/${repo}'
			pull_request: pull_request
			issues: input.effects.issues
			changed_files: input.effects.changed_files
		})
		if conflicts.error != '' {
			return error(conflicts.error)
		}
		result.ohai << 'Fetching ${input.tap.name} pull request #${pull_request}'
		directory := input.effects.temporary_directories[pull_request] or { '/tmp/pr-pull-${pull_request}' }
		current_head := if input.effects.github_sha_set {
			input.effects.github_sha
		} else {
			input.tap.git_head
		}
		original_commit := if parsed.no_cherry_pick {
			(input.effects.merge_bases[pull_request] or { '' }).trim_space()
		} else {
			if current_head == '' {
				return error('Failed to get current branch head')
			} else {
				current_head
			}
		}
		result.debug << 'Pull request merge-base: ${original_commit}'
		if !parsed.no_commit {
			if !parsed.no_cherry_pick {
				picked := cherry_pick_pr_pull(PrPullCherryPickInput{
					user: user
					repo: repo
					pull_request: pull_request
					head_sha: head_sha
					path: input.tap.path
					commits: commits
					commits_provided: commits.len > 0
					fetched_commits: input.effects.commits[key] or { []string{} }
					dry_run: parsed.dry_run
					verbose: parsed.verbose
					resolve: parsed.resolve
				})!
				result.effects << picked.effects
				result.ohai << picked.ohai
				for printed in picked.stdout {
					result.effects << pr_pull_effect('print', []string{}, {
						'message': printed
					})
				}
			}
			if parsed.autosquash && !parsed.dry_run {
				result.effects << pr_pull_effect('autosquash', []string{}, {
					'original_commit': original_commit
					'tap':             input.tap.name
					'cherry_picked':   (!parsed.no_cherry_pick).str()
					'verbose':         parsed.verbose.str()
					'resolve':         parsed.resolve.str()
					'reason':          parsed.message
				})
			}
			if !parsed.clean {
				reviews := input.effects.approved_reviews[key] or { []PrPullReview{} }
				signed := signoff_pr_pull(PrPullSignoffInput{
					tap: input.tap
					pull_request: pull_request
					dry_run: parsed.dry_run
					reviews: reviews
				})
				result.effects << signed.effects
			}
		}
		packages := input.effects.changed_packages[original_commit] or { []PrPullPackage{} }
		if !pr_pull_formulae_need_bottles(PrPullBottlesInput{
			dry_run: parsed.dry_run
			labels: labels
			packages: packages
		}) {
			result.ohai << "Skipping artifacts for #${pull_request} as the formulae don't need bottles"
			if parsed.retain_bottle_dir && input.effects.github_actions_environment {
				result.ohai << ['Bottle files retained at:', directory]
				result.retained_directories << directory
				if input.effects.github_output == '' {
					return error('key not found: "GITHUB_OUTPUT"')
				}
				result.output_writes[input.effects.github_output] = (result.output_writes[input.effects.github_output] or {
					''
				}) + 'bottle_path=${directory}\n'
			} else {
				result.removed_directories << directory
			}
			continue
		}
		for workflow in workflows {
			workflow_run := input.effects.workflow_runs[pr_pull_workflow_key(user, repo, pull_request, workflow)] or { PrPullWorkflowRun{} }
			result.effects << pr_pull_effect('get_workflow_run', []string{}, {
				'user':             user
				'repo':             repo
				'pull_request':     pull_request
				'workflow':         workflow
				'artifact_pattern': artifact_pattern
				'head_sha':         head_sha
			})
			if workflow in parsed.ignore_missing && !workflow_run.present {
				result.ohai << 'Ignoring workflow ${workflow} as requested by `--ignore-missing-artifacts`'
				continue
			}
			result.ohai << 'Downloading bottles for workflow: ${workflow}'
			for url in workflow_run.artifact_urls {
				result.downloads << PrPullDownload{
					url: url
					pull_request: pull_request
				}
			}
		}
		if !parsed.no_upload {
			mut upload := [input.brew_file, 'pr-upload']
			if parsed.debug { upload << '--debug' }
			if parsed.verbose { upload << '--verbose' }
			if parsed.no_commit { upload << '--no-commit' }
			if parsed.dry_run { upload << '--dry-run' }
			if parsed.keep_old { upload << '--keep-old' }
			if parsed.warn_on_upload_failure { upload << '--warn-on-upload-failure' }
			if parsed.root_url_set { upload << '--root-url=${parsed.root_url}' }
			if parsed.root_url_using_set { upload << '--root-url-using=${parsed.root_url_using}' }
			result.effects << pr_pull_effect('safe_system', upload, map[string]string{})
		}
		if parsed.retain_bottle_dir && input.effects.github_actions_environment {
			result.ohai << ['Bottle files retained at:', directory]
			result.retained_directories << directory
			if input.effects.github_output == '' {
				return error('key not found: "GITHUB_OUTPUT"')
			}
			result.output_writes[input.effects.github_output] = (result.output_writes[input.effects.github_output] or {
				''
			}) + 'bottle_path=${directory}\n'
		} else {
			result.removed_directories << directory
		}
	}
	return result
}

fn pr_pull_package_value(package PrPullPackage) brew_runtime.Value {
	return brew_runtime.map_value({
		'name':     brew_runtime.string_value(package.name)
		'version':  brew_runtime.string_value(package.version)
		'revision': brew_runtime.int_value(package.revision)
		'sha256':   brew_runtime.string_value(package.sha256)
		'is_cask':  brew_runtime.bool_value(package.is_cask)
	})
}

fn pr_pull_effect_value(effect PrPullEffect) brew_runtime.Value {
	mut details := map[string]brew_runtime.Value{}
	for key, value in effect.details {
		details[key] = brew_runtime.string_value(value)
	}
	return brew_runtime.map_value({
		'kind':    brew_runtime.string_value(effect.kind)
		'argv':    brew_runtime.string_array_value(effect.argv)
		'details': brew_runtime.map_value(details)
	})
}

fn pr_pull_parts_value(parts PrPullCommitParts) brew_runtime.Value {
	return brew_runtime.string_array_value([parts.subject, parts.body, parts.trailers])
}

fn pr_pull_rewrite_value(result PrPullRewriteResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'subject': brew_runtime.string_value(result.subject)
		'effects': brew_runtime.array_value(result.effects.map(pr_pull_effect_value(it)))
	})
}

fn pr_pull_run_result_value(result PrPullRunResult) brew_runtime.Value {
	mut environment := map[string]brew_runtime.Value{}
	for key, value in result.environment {
		environment[key] = brew_runtime.string_value(value)
	}
	mut writes := map[string]brew_runtime.Value{}
	for key, value in result.output_writes {
		writes[key] = brew_runtime.string_value(value)
	}
	return brew_runtime.map_value({
		'required_executables': brew_runtime.string_array_value(result.required_executables)
		'environment':          brew_runtime.map_value(environment)
		'effects':              brew_runtime.array_value(result.effects.map(pr_pull_effect_value(it)))
		'downloads':            brew_runtime.array_value(result.downloads.map(brew_runtime.map_value({
			'url':          brew_runtime.string_value(it.url)
			'pull_request': brew_runtime.string_value(it.pull_request)
		})))
		'ohai':                 brew_runtime.string_array_value(result.ohai)
		'warnings':             brew_runtime.string_array_value(result.warnings)
		'debug':                brew_runtime.string_array_value(result.debug)
		'removed_directories':  brew_runtime.string_array_value(result.removed_directories)
		'retained_directories': brew_runtime.string_array_value(result.retained_directories)
		'output_writes':        brew_runtime.map_value(writes)
	})
}

// Ruby method `run` at line 79.
pub fn ruby_pr_pull_l79_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	input := pr_pull_boundary_input_from_value(args[0])
	return pr_pull_run_result_value(run_pr_pull(input.run) or {
		return brew_runtime.object_value('Error', err.msg())
	})
}

// Ruby method `separate_commit_message(message)` at line 203.
pub fn ruby_pr_pull_l203_d2_separate_commit_message(args ...brew_runtime.Value) brew_runtime.Value {
	message := if args.len > 0 { args[0].as_string() } else { '' }
	return pr_pull_parts_value(separate_pr_pull_commit_message(message))
}

// Ruby method `signoff!(git_repo, pull_request: nil, dry_run: false)` at line 218.
pub fn ruby_pr_pull_l218_d3_signoff(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'signoff input is required')
	}
	result := signoff_pr_pull(pr_pull_boundary_input_from_value(args[0]).signoff)
	return brew_runtime.map_value({
		'parts':   pr_pull_parts_value(result.parts)
		'effects': brew_runtime.array_value(result.effects.map(pr_pull_effect_value(it)))
	})
}

// Ruby method `get_package(tap, subject_name, subject_path, content)` at line 248.
pub fn ruby_pr_pull_l248_d4_get_package(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'package input is required')
	}
	package := get_pr_pull_package(pr_pull_boundary_input_from_value(args[0]).package) or {
		return brew_runtime.Value{ type_name: 'NilClass' }
	}
	return pr_pull_package_value(package)
}

// Ruby method `determine_bump_subject(old_contents, new_contents, subject_path, reason: nil)` at line 269.
pub fn ruby_pr_pull_l269_d5_determine_bump_subject(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'bump input is required')
	}
	return brew_runtime.string_value(determine_pr_pull_bump_subject(pr_pull_boundary_input_from_value(args[0]).bump))
}

// Ruby method `reword_package_commit(commit, file, git_repo:, reason: "", verbose: false, resolve: false)` at line 301.
pub fn ruby_pr_pull_l301_d6_reword_package_commit(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'reword input is required')
	}
	return pr_pull_rewrite_value(reword_pr_pull_package_commit(pr_pull_boundary_input_from_value(args[0]).reword))
}

// Ruby method `squash_package_commits(commits, file, git_repo:, reason: "", verbose: false, resolve: false)` at line 333.
pub fn ruby_pr_pull_l333_d7_squash_package_commits(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'squash input is required')
	}
	result := squash_pr_pull_package_commits(pr_pull_boundary_input_from_value(args[0]).squash) or {
		return brew_runtime.object_value('Error', err.msg())
	}
	return pr_pull_rewrite_value(result)
}

// Ruby method `autosquash!(original_commit, tap:, reason: "", verbose: false, resolve: false, cherry_picked: false)` at line 386.
pub fn ruby_pr_pull_l386_d8_autosquash(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'autosquash input is required')
	}
	result := autosquash_pr_pull(pr_pull_boundary_input_from_value(args[0]).autosquash)
	return brew_runtime.map_value({
		'error':   brew_runtime.string_value(result.error)
		'actions': brew_runtime.array_value(result.actions.map(brew_runtime.map_value({
			'kind':    brew_runtime.string_value(it.kind)
			'file':    brew_runtime.string_value(it.file)
			'commits': brew_runtime.string_array_value(it.commits)
		})))
		'effects': brew_runtime.array_value(result.effects.map(pr_pull_effect_value(it)))
	})
}

// Ruby method `check_pull_request_head_sha!(user, repo, pull_request)` at line 457.
pub fn ruby_pr_pull_l457_d9_check_pull_request_head_sha(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'head input is required')
	}
	result := check_pr_pull_head_sha(pr_pull_boundary_input_from_value(args[0]).head) or {
		return brew_runtime.object_value('Error', err.msg())
	}
	return brew_runtime.map_value({
		'commits': brew_runtime.string_array_value(result.commits)
		'message': brew_runtime.string_value(result.message)
	})
}

// Ruby method `cherry_pick_pr!(user, repo, pull_request, head_sha:, path: ".", commits: nil)` at line 476.
pub fn ruby_pr_pull_l476_d10_cherry_pick_pr(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'cherry-pick input is required')
	}
	result := cherry_pick_pr_pull(pr_pull_boundary_input_from_value(args[0]).cherry_pick) or {
		return brew_runtime.object_value('Error', err.msg())
	}
	return brew_runtime.map_value({
		'effects': brew_runtime.array_value(result.effects.map(pr_pull_effect_value(it)))
		'stdout':  brew_runtime.string_array_value(result.stdout)
		'ohai':    brew_runtime.string_array_value(result.ohai)
	})
}

// Ruby method `formulae_need_bottles?(tap, original_commit, labels)` at line 499.
pub fn ruby_pr_pull_l499_d11_formulae_need_bottles(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(pr_pull_formulae_need_bottles(pr_pull_boundary_input_from_value(args[0]).bottles))
}

// Ruby method `changed_packages(tap, original_commit)` at line 510.
pub fn ruby_pr_pull_l510_d12_changed_packages(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'changed-packages input is required')
	}
	result := changed_pr_pull_packages(pr_pull_boundary_input_from_value(args[0]).changed)
	return brew_runtime.map_value({
		'packages': brew_runtime.array_value(result.packages.map(pr_pull_package_value(it)))
		'warnings': brew_runtime.string_array_value(result.warnings)
		'effects':  brew_runtime.array_value(result.effects.map(pr_pull_effect_value(it)))
	})
}

// Ruby method `pr_check_conflicts(repo, pull_request)` at line 547.
pub fn ruby_pr_pull_l547_d13_pr_check_conflicts(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'conflicts input is required')
	}
	result := check_pr_pull_conflicts(pr_pull_boundary_input_from_value(args[0]).conflicts)
	return brew_runtime.map_value({
		'error':     brew_runtime.string_value(result.error)
		'conflicts': brew_runtime.array_value(result.conflicts.map(brew_runtime.map_value({
			'pull_request': brew_runtime.string_value(it.pull_request)
			'files':        brew_runtime.string_array_value(it.files)
		})))
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "fileutils"
// 6: require "utils/github"
// 7: require "utils/github/artifacts"
// 8: require "tmpdir"
// 9: require "formula"
// 10:
// 11: module Homebrew
// 12:   module DevCmd
// 13:     class PrPull < AbstractCommand
// 14:       include FileUtils
// 15:
// 16:       cmd_args do
// 17:         description <<~EOS
// 18:           Download and publish bottles and apply the bottle commit from a
// 19:           pull request with artifacts generated by GitHub Actions.
// 20:           Requires write access to the repository.
// 21:         EOS
// 22:         switch "--no-upload",
// 23:                description: "Download the bottles but don't upload them."
// 24:         switch "--no-commit",
// 25:                description: "Do not generate a new commit before uploading."
// 26:         switch "--no-cherry-pick",
// 27:                description: "Do not cherry-pick commits from the pull request branch."
// 28:         switch "-n", "--dry-run",
// 29:                description: "Print what would be done rather than doing it."
// 30:         switch "--clean",
// 31:                description: "Do not amend the commits from pull requests."
// 32:         switch "--keep-old",
// 33:                description: "If the formula specifies a rebuild version, " \
// 34:                             "attempt to preserve its value in the generated DSL."
// 35:         switch "--autosquash",
// 36:                description: "Automatically reformat and reword commits in the pull request to our " \
// 37:                             "preferred format."
// 38:         switch "--branch-okay",
// 39:                description: "Do not warn if pulling to a branch besides the repository default (useful for testing)."
// 40:         switch "--resolve",
// 41:                description: "When a patch fails to apply, leave in progress and allow user to resolve, " \
// 42:                             "instead of aborting."
// 43:         switch "--warn-on-upload-failure",
// 44:                description: "Warn instead of raising an error if the bottle upload fails. " \
// 45:                             "Useful for repairing bottle uploads that previously failed."
// 46:         switch "--retain-bottle-dir",
// 47:                description: "Does not clean up the tmp directory for the bottle so it can be used later."
// 48:         flag   "--committer=",
// 49:                description: "Specify a committer name and email in `git`'s standard author format.",
// 50:                odeprecated: true
// 51:         flag   "--message=",
// 52:                depends_on:  "--autosquash",
// 53:                description: "Message to include when autosquashing revision bumps, deletions and rebuilds."
// 54:         flag   "--artifact-pattern=", "--artifact=",
// 55:                description: "Download artifacts with the specified pattern (default: `bottles{,_*}`)."
// 56:         flag   "--tap=",
// 57:                description: "Target tap repository (default: `homebrew/core`)."
// 58:         flag   "--head-sha=",
// 59:                description: "Expected pull request head commit SHA."
// 60:         flag   "--root-url=",
// 61:                description: "Use the specified <URL> as the root of the bottle's URL instead of Homebrew's default."
// 62:         flag   "--root-url-using=",
// 63:                description: "Use the specified download strategy class for downloading the bottle's URL instead of " \
// 64:                             "Homebrew's default."
// 65:         comma_array "--workflows",
// 66:                     description: "Retrieve artifacts from the specified workflow (default: `tests.yml`). " \
// 67:                                  "Can be a comma-separated list to include multiple workflows."
// 68:         comma_array "--ignore-missing-artifacts",
// 69:                     description: "Comma-separated list of workflows which can be ignored if they have not been run."
// 70:
// 71:         conflicts "--clean", "--autosquash"
// 72:
// 73:         named_args :pull_request, min: 1
// 74:
// 75:         hide_from_man_page!
// 76:       end
// 77:
// 78:       sig { override.void }
// 79:       def run
// 80:         # Needed when extracting the CI artifact.
// 81:         ensure_executable!("unzip", reason: "extracting CI artifacts")
// 82:
// 83:         workflows = args.workflows.presence || ["tests.yml"]
// 84:         artifact_pattern = args.artifact_pattern || "bottles{,_*}"
// 85:         tap = Tap.fetch(args.tap || CoreTap.instance.name)
// 86:         raise TapUnavailableError, tap.name unless tap.installed?
// 87:
// 88:         Utils::Git.set_name_email!(committer: args.committer.blank?)
// 89:         Utils::Git.setup_gpg!
// 90:
// 91:         if (committer = args.committer)
// 92:           committer = Utils.parse_author!(committer)
// 93:           ENV["GIT_COMMITTER_NAME"] = committer[:name]
// 94:           ENV["GIT_COMMITTER_EMAIL"] = committer[:email]
// 95:         end
// 96:
// 97:         args.named.uniq.each do |arg|
// 98:           arg = "#{tap.default_remote}/pull/#{arg}" if arg.to_i.positive?
// 99:           url_match = arg.match HOMEBREW_PULL_OR_COMMIT_URL_REGEX
// 100:           _, user, repo, pr = *url_match
// 101:           odie "Not a GitHub pull request: #{arg}" if !user || !repo || !pr
// 102:
// 103:           git_repo = tap.git_repository
// 104:           if !git_repo.default_origin_branch? && !args.branch_okay? && !args.no_commit? && !args.no_cherry_pick?
// 105:             origin_branch_name = git_repo.origin_branch_name
// 106:             opoo "Current branch is #{git_repo.branch_name}: do you need to pull inside #{origin_branch_name}?"
// 107:           end
// 108:
// 109:           pr_labels = GitHub.pull_request_labels(user, repo, pr)
// 110:           if pr_labels.include?("autosquash") && !args.autosquash?
// 111:             opoo "Pull request is labelled `autosquash`: do you need to pass `--autosquash`?"
// 112:           end
// 113:
// 114:           pull_request_commits = nil
// 115:           head_sha = if (head_sha_arg = args.head_sha.presence)
// 116:             head_sha_arg = head_sha_arg.downcase
// 117:             ohai "Pull request ##{pr} expected head SHA: #{head_sha_arg}"
// 118:             head_sha_arg
// 119:           else
// 120:             pull_request_commits = check_pull_request_head_sha!(user, repo, pr)
// 121:             pull_request_commits.fetch(-1)
// 122:           end
// 123:           pr_check_conflicts("#{user}/#{repo}", pr)
// 124:
// 125:           ohai "Fetching #{tap} pull request ##{pr}"
// 126:           dir = Dir.mktmpdir("pr-pull-#{pr}-", HOMEBREW_TEMP)
// 127:           begin
// 128:             cd dir do
// 129:               current_branch_head = ENV["GITHUB_SHA"] || tap.git_head
// 130:               original_commit = if args.no_cherry_pick?
// 131:                 # TODO: Handle the case where `merge-base` returns multiple commits.
// 132:                 Utils.safe_popen_read("git", "-C", tap.path, "merge-base", "origin/HEAD",
// 133:                                       current_branch_head).strip
// 134:               else
// 135:                 current_branch_head || odie("Failed to get current branch head")
// 136:               end
// 137:               odebug "Pull request merge-base: #{original_commit}"
// 138:
// 139:               unless args.no_commit?
// 140:                 unless args.no_cherry_pick?
// 141:                   cherry_pick_pr!(user, repo, pr, path:    tap.path,
// 142:                                                   commits: pull_request_commits, head_sha:)
// 143:                 end
// 144:                 if args.autosquash? && !args.dry_run?
// 145:                   autosquash!(original_commit, tap:, cherry_picked: !args.no_cherry_pick?,
// 146:                               verbose: args.verbose?, resolve: args.resolve?, reason: args.message)
// 147:                 end
// 148:                 signoff!(git_repo, pull_request: pr, dry_run: args.dry_run?) unless args.clean?
// 149:               end
// 150:
// 151:               unless formulae_need_bottles?(tap, original_commit, pr_labels)
// 152:                 ohai "Skipping artifacts for ##{pr} as the formulae don't need bottles"
// 153:                 next
// 154:               end
// 155:
// 156:               workflows.each do |workflow|
// 157:                 workflow_run = GitHub.get_workflow_run(
// 158:                   user, repo, pr, workflow_id: workflow, artifact_pattern:, head_sha:
// 159:                 )
// 160:                 if args.ignore_missing_artifacts.present? &&
// 161:                    args.ignore_missing_artifacts&.include?(workflow) &&
// 162:                    workflow_run.first.blank?
// 163:                   # Ignore that workflow as it was not executed and we specified
// 164:                   # that we could skip it.
// 165:                   ohai "Ignoring workflow #{workflow} as requested by `--ignore-missing-artifacts`"
// 166:                   next
// 167:                 end
// 168:
// 169:                 ohai "Downloading bottles for workflow: #{workflow}"
// 170:
// 171:                 urls = GitHub.get_artifact_urls(workflow_run)
// 172:                 urls.each { |url| GitHub.download_artifact(url, pr) }
// 173:               end
// 174:
// 175:               next if args.no_upload?
// 176:
// 177:               upload_args = ["pr-upload"]
// 178:               upload_args << "--debug" if args.debug?
// 179:               upload_args << "--verbose" if args.verbose?
// 180:               upload_args << "--no-commit" if args.no_commit?
// 181:               upload_args << "--dry-run" if args.dry_run?
// 182:               upload_args << "--keep-old" if args.keep_old?
// 183:               upload_args << "--warn-on-upload-failure" if args.warn_on_upload_failure?
// 184:               upload_args << "--root-url=#{args.root_url}" if args.root_url
// 185:               upload_args << "--root-url-using=#{args.root_url_using}" if args.root_url_using
// 186:               safe_system HOMEBREW_BREW_FILE, *upload_args
// 187:             end
// 188:           ensure
// 189:             if args.retain_bottle_dir? && GitHub::Actions.env_set?
// 190:               ohai "Bottle files retained at:", dir
// 191:               File.open(ENV.fetch("GITHUB_OUTPUT"), "a") do |f|
// 192:                 f.puts "bottle_path=#{dir}"
// 193:               end
// 194:             else
// 195:               FileUtils.remove_entry dir
// 196:             end
// 197:           end
// 198:         end
// 199:       end
// 200:
// 201:       # Separates a commit message into subject, body and trailers.
// 202:       sig { params(message: String).returns([String, String, String]) }
// 203:       def separate_commit_message(message)
// 204:         first_line = message.lines.first
// 205:         return ["", "", ""] unless first_line
// 206:
// 207:         # Skip the subject and separate lines that look like trailers (e.g. "Co-authored-by")
// 208:         # from lines that look like regular body text.
// 209:         trailers, body = message.lines.drop(1).partition { |s| s.match?(/^[a-z-]+-by:/i) }
// 210:
// 211:         trailers = trailers.uniq.join.strip
// 212:         body = body.join.strip.gsub(/\n{3,}/, "\n\n")
// 213:
// 214:         [first_line.strip, body, trailers]
// 215:       end
// 216:
// 217:       sig { params(git_repo: GitRepository, pull_request: T.nilable(String), dry_run: T::Boolean).void }
// 218:       def signoff!(git_repo, pull_request: nil, dry_run: false)
// 219:         msg = git_repo.commit_message
// 220:         return if msg.blank?
// 221:
// 222:         subject, body, trailers = separate_commit_message(msg)
// 223:
// 224:         if pull_request
// 225:           # This is a tap pull request and approving reviewers should also sign-off.
// 226:           tap = T.must(Tap.from_path(git_repo.pathname))
// 227:           review_trailers = GitHub.repository_approved_reviews(tap.user, tap.full_repository, pull_request).map do |r|
// 228:             "Signed-off-by: #{r["name"]} <#{r["email"]}>"
// 229:           end
// 230:           trailers = trailers.lines.concat(review_trailers).map(&:strip).uniq.join("\n")
// 231:
// 232:           # Append the close message as well, unless the commit body already includes it.
// 233:           close_message = "Closes ##{pull_request}."
// 234:           body.concat("\n\n#{close_message}") unless body.include?(close_message)
// 235:         end
// 236:
// 237:         git_args = Utils::Git.git, "-C", git_repo.pathname, "commit", "--amend", "--signoff", "--allow-empty",
// 238:                    "--quiet", "--message", subject, "--message", body, "--message", trailers
// 239:
// 240:         if dry_run
// 241:           puts(*git_args)
// 242:         else
// 243:           safe_system(*git_args)
// 244:         end
// 245:       end
// 246:
// 247:       sig { params(tap: Tap, subject_name: String, subject_path: Pathname, content: String).returns(T.untyped) }
// 248:       def get_package(tap, subject_name, subject_path, content)
// 249:         if subject_path.to_s.start_with?("#{tap.cask_dir}/")
// 250:           cask = begin
// 251:             Cask::CaskLoader.load(content.dup)
// 252:           rescue Cask::CaskUnavailableError
// 253:             nil
// 254:           end
// 255:           return cask
// 256:         end
// 257:
// 258:         begin
// 259:           Formulary.from_contents(subject_name, subject_path, content, :stable)
// 260:         rescue FormulaUnavailableError
// 261:           nil
// 262:         end
// 263:       end
// 264:
// 265:       sig {
// 266:         params(old_contents: String, new_contents: String, subject_path: T.any(String, Pathname),
// 267:                reason: T.nilable(String)).returns(String)
// 268:       }
// 269:       def determine_bump_subject(old_contents, new_contents, subject_path, reason: nil)
// 270:         subject_path = Pathname(subject_path)
// 271:         tap          = T.must(Tap.from_path(subject_path))
// 272:         subject_name = subject_path.basename.to_s.chomp(".rb")
// 273:         is_cask      = subject_path.to_s.start_with?("#{tap.cask_dir}/")
// 274:         name         = is_cask ? "cask" : "formula"
// 275:
// 276:         new_package = get_package(tap, subject_name, subject_path, new_contents)
// 277:
// 278:         return "#{subject_name}: delete #{reason}".strip if new_package.blank?
// 279:
// 280:         old_package = get_package(tap, subject_name, subject_path, old_contents)
// 281:
// 282:         if old_package.blank?
// 283:           "#{subject_name} #{new_package.version} (new #{name})"
// 284:         elsif old_package.version != new_package.version
// 285:           "#{subject_name} #{new_package.version}"
// 286:         elsif !is_cask && old_package.revision != new_package.revision
// 287:           "#{subject_name}: revision #{reason}".strip
// 288:         elsif is_cask && old_package.sha256 != new_package.sha256
// 289:           "#{subject_name}: checksum update #{reason}".strip
// 290:         else
// 291:           "#{subject_name}: #{reason || "rebuild"}".strip
// 292:         end
// 293:       end
// 294:
// 295:       # Cherry picks a single commit that modifies a single file.
// 296:       # Potentially rewords this commit using {determine_bump_subject}.
// 297:       sig {
// 298:         params(commit: String, file: String, git_repo: GitRepository, reason: T.nilable(String), verbose: T::Boolean,
// 299:                resolve: T::Boolean).void
// 300:       }
// 301:       def reword_package_commit(commit, file, git_repo:, reason: "", verbose: false, resolve: false)
// 302:         package_file = git_repo.pathname / file
// 303:         package_name = package_file.basename.to_s.chomp(".rb")
// 304:
// 305:         odebug "Cherry-picking #{package_file}: #{commit}"
// 306:         Utils::Git.cherry_pick!(git_repo.to_s, commit, verbose:, resolve:)
// 307:
// 308:         old_package = Utils::Git.file_at_commit(git_repo.to_s, file, "HEAD^")
// 309:         new_package = Utils::Git.file_at_commit(git_repo.to_s, file, "HEAD")
// 310:
// 311:         bump_subject = determine_bump_subject(old_package, new_package, package_file, reason:).strip
// 312:         msg = git_repo.commit_message
// 313:         return if msg.blank?
// 314:
// 315:         subject, body, trailers = separate_commit_message(msg)
// 316:
// 317:         if subject != bump_subject && !subject.start_with?("#{package_name}:")
// 318:           safe_system("git", "-C", git_repo.pathname, "commit", "--amend", "-q",
// 319:                       "-m", bump_subject, "-m", subject, "-m", body, "-m", trailers)
// 320:           ohai bump_subject
// 321:         else
// 322:           ohai subject
// 323:         end
// 324:       end
// 325:
// 326:       # Cherry picks multiple commits that each modify a single file.
// 327:       # Words the commit according to {determine_bump_subject} with the body
// 328:       # corresponding to all the original commit messages combined.
// 329:       sig {
// 330:         params(commits: T::Array[String], file: String, git_repo: GitRepository, reason: T.nilable(String),
// 331:                verbose: T::Boolean, resolve: T::Boolean).void
// 332:       }
// 333:       def squash_package_commits(commits, file, git_repo:, reason: "", verbose: false, resolve: false)
// 334:         odebug "Squashing #{file}: #{commits.join " "}"
// 335:
// 336:         # Format commit messages into something similar to `git fmt-merge-message`.
// 337:         # * subject 1
// 338:         # * subject 2
// 339:         #   optional body
// 340:         # * subject 3
// 341:         messages = []
// 342:         trailers = []
// 343:         commits.each do |commit|
// 344:           msg = git_repo.commit_message(commit)
// 345:           next if msg.blank?
// 346:
// 347:           subject, body, trailer = separate_commit_message(msg)
// 348:           body = body.lines.map { |line| "  #{line.strip}" }.join("\n")
// 349:           messages << "* #{subject}\n#{body}".strip
// 350:           trailers << trailer
// 351:         end
// 352:
// 353:         # Get the set of authors in this series.
// 354:         authors = Utils.safe_popen_read("git", "-C", git_repo.pathname, "show",
// 355:                                         "--no-patch", "--pretty=%an <%ae>", *commits).lines.map(&:strip).uniq.compact
// 356:
// 357:         # Get the author and date of the first commit of this series, which we use for the squashed commit.
// 358:         original_author = authors.shift
// 359:         original_date = Utils.safe_popen_read "git", "-C", git_repo.pathname, "show", "--no-patch", "--pretty=%ad",
// 360:                                               commits.first
// 361:
// 362:         # Generate trailers for coauthors and combine them with the existing trailers.
// 363:         co_author_trailers = authors.map { |au| "Co-authored-by: #{au}" }
// 364:         trailers = [trailers + co_author_trailers].flatten.uniq.compact
// 365:
// 366:         # Apply the patch series but don't commit anything yet.
// 367:         Utils::Git.cherry_pick!(git_repo.pathname, "--no-commit", *commits, verbose:, resolve:)
// 368:
// 369:         # Determine the bump subject by comparing the original state of the tree to its current state.
// 370:         package_file = git_repo.pathname / file
// 371:         old_package = Utils::Git.file_at_commit(git_repo.pathname, file, "#{commits.first}^")
// 372:         new_package = package_file.read
// 373:         bump_subject = determine_bump_subject(old_package, new_package, package_file, reason:)
// 374:
// 375:         # Commit with the new subject, body and trailers.
// 376:         safe_system("git", "-C", git_repo.pathname, "commit", "--quiet",
// 377:                     "-m", bump_subject, "-m", messages.join("\n"), "-m", trailers.join("\n"),
// 378:                     "--author", original_author, "--date", original_date, "--", file)
// 379:         ohai bump_subject
// 380:       end
// 381:
// 382:       sig {
// 383:         params(original_commit: String, tap: Tap, reason: T.nilable(String), verbose: T::Boolean, resolve: T::Boolean,
// 384:                cherry_picked: T::Boolean).void
// 385:       }
// 386:       def autosquash!(original_commit, tap:, reason: "", verbose: false, resolve: false, cherry_picked: false)
// 387:         git_repo = tap.git_repository
// 388:
// 389:         commits = Utils.safe_popen_read("git", "-C", tap.path, "rev-list",
// 390:                                         "--reverse", "#{original_commit}..HEAD").lines.map(&:strip)
// 391:
// 392:         # Generate a bidirectional mapping of commits <=> formula/cask files.
// 393:         files_to_commits = T.let({}, T::Hash[String, T::Array[String]])
// 394:         commits_to_files = commits.to_h do |commit|
// 395:           files = Utils.safe_popen_read("git", "-C", tap.path, "diff-tree", "--diff-filter=AMD",
// 396:                                         "-r", "--name-only", "#{commit}^", commit).lines.map(&:strip)
// 397:           files.each do |file|
// 398:             files_to_commits[file] ||= []
// 399:             files_to_commits.fetch(file) << commit
// 400:             tap_file = (tap.path/file).to_s
// 401:             if tap_file.start_with?("#{tap.formula_dir}/", "#{tap.cask_dir}/") &&
// 402:                File.extname(file) == ".rb"
// 403:               next
// 404:             end
// 405:
// 406:             odie <<~EOS
// 407:               Autosquash can only squash commits that modify formula or cask files.
// 408:                 File:   #{file}
// 409:                 Commit: #{commit}
// 410:             EOS
// 411:           end
// 412:           [commit, files]
// 413:         end
// 414:
// 415:         # Reset to state before cherry-picking.
// 416:         safe_system "git", "-C", tap.path, "reset", "--hard", original_commit
// 417:
// 418:         # Iterate over every commit in the pull request series, but if we have to squash
// 419:         # multiple commits into one, ensure that we skip over commits we've already squashed.
// 420:         processed_commits = T.let([], T::Array[String])
// 421:         commits.each do |commit|
// 422:           next if processed_commits.include? commit
// 423:
// 424:           files = commits_to_files.fetch(commit)
// 425:           if files.length == 1 && files_to_commits.fetch(files.fetch(0)).length == 1
// 426:             # If there's a 1:1 mapping of commits to files, just cherry pick and (maybe) reword.
// 427:             reword_package_commit(
// 428:               commit, files.fetch(0), git_repo:, reason:, verbose:, resolve:
// 429:             )
// 430:             processed_commits << commit
// 431:           elsif files.length == 1 && files_to_commits.fetch(files.fetch(0)).length > 1
// 432:             # If multiple commits modify a single file, squash them down into a single commit.
// 433:             file = files.fetch(0)
// 434:             commits = files_to_commits.fetch(file)
// 435:             squash_package_commits(commits, file, git_repo:, reason:, verbose:, resolve:)
// 436:             processed_commits += commits
// 437:           else
// 438:             # We can't split commits (yet) so just raise an error.
// 439:             odie <<~EOS
// 440:               Autosquash can't split commits that modify multiple files.
// 441:                 Commit: #{commit}
// 442:                 Files:  #{files.join " "}
// 443:             EOS
// 444:           end
// 445:         end
// 446:       rescue
// 447:         original_head = git_repo&.head_ref
// 448:         return if original_head.nil?
// 449:
// 450:         opoo "Autosquash encountered an error; resetting to original state at #{original_head}"
// 451:         system "git", "-C", tap.path.to_s, "reset", "--hard", original_head
// 452:         system "git", "-C", tap.path.to_s, "cherry-pick", "--abort" if cherry_picked
// 453:         raise
// 454:       end
// 455:
// 456:       sig { params(user: String, repo: String, pull_request: String).returns(T::Array[String]) }
// 457:       def check_pull_request_head_sha!(user, repo, pull_request)
// 458:         commits = GitHub.pull_request_commits(user, repo, pull_request)
// 459:         pull_request_head_sha = commits.fetch(-1)
// 460:         ohai "Pull request ##{pull_request} head SHA: #{pull_request_head_sha}"
// 461:         commits
// 462:       end
// 463:
// 464:       private
// 465:
// 466:       sig {
// 467:         params(
// 468:           user:         String,
// 469:           repo:         String,
// 470:           pull_request: String,
// 471:           head_sha:     String,
// 472:           path:         T.any(String, Pathname),
// 473:           commits:      T.nilable(T::Array[String]),
// 474:         ).void
// 475:       }
// 476:       def cherry_pick_pr!(user, repo, pull_request, head_sha:, path: ".", commits: nil)
// 477:         if args.dry_run?
// 478:           puts <<~EOS
// 479:             git fetch --force origin +refs/pull/#{pull_request}/head
// 480:             git merge-base HEAD FETCH_HEAD
// 481:             git cherry-pick --ff --allow-empty $merge_base..FETCH_HEAD
// 482:           EOS
// 483:           return
// 484:         end
// 485:
// 486:         commits ||= GitHub.pull_request_commits(user, repo, pull_request)
// 487:         pull_request_head_sha = commits.fetch(-1).downcase
// 488:         if pull_request_head_sha != head_sha
// 489:           odie "Pull request ##{pull_request} is at #{pull_request_head_sha} but expected #{head_sha}."
// 490:         end
// 491:
// 492:         safe_system "git", "-C", path, "fetch", "--quiet", "--force", "origin", commits.last
// 493:         ohai "Using #{commits.count} commit#{"s" if commits.count != 1} from ##{pull_request}"
// 494:         Utils::Git.cherry_pick!(path, "--ff", "--allow-empty", *commits, verbose: args.verbose?,
// 495:                                                                          resolve: args.resolve?)
// 496:       end
// 497:
// 498:       sig { params(tap: Tap, original_commit: String, labels: T::Array[String]).returns(T::Boolean) }
// 499:       def formulae_need_bottles?(tap, original_commit, labels)
// 500:         return false if args.dry_run?
// 501:
// 502:         return false if labels.include?("CI-syntax-only") || labels.include?("CI-no-bottles")
// 503:
// 504:         changed_packages(tap, original_commit).any? do |f|
// 505:           !f.instance_of?(Cask::Cask)
// 506:         end
// 507:       end
// 508:
// 509:       sig { params(tap: Tap, original_commit: String).returns(T::Array[T.any(Formula, Cask::Cask)]) }
// 510:       def changed_packages(tap, original_commit)
// 511:         formulae = Utils.popen_read("git", "-C", tap.path, "diff-tree",
// 512:                                     "-r", "--name-only", "--diff-filter=AM",
// 513:                                     original_commit, "HEAD", "--", tap.formula_dir)
// 514:                         .lines
// 515:                         .filter_map do |line|
// 516:           next unless line.end_with? ".rb\n"
// 517:
// 518:           name = "#{tap.name}/#{File.basename(line.chomp, ".rb")}"
// 519:           if Homebrew::EnvConfig.disable_load_formula?
// 520:             opoo "Can't check if updated bottles are necessary as `$HOMEBREW_DISABLE_LOAD_FORMULA` is set!"
// 521:             break []
// 522:           end
// 523:           begin
// 524:             Formulary.resolve(name)
// 525:           rescue FormulaUnavailableError
// 526:             nil
// 527:           end
// 528:         end
// 529:         casks = Utils.popen_read("git", "-C", tap.path, "diff-tree",
// 530:                                  "-r", "--name-only", "--diff-filter=AM",
// 531:                                  original_commit, "HEAD", "--", tap.cask_dir)
// 532:                      .lines
// 533:                      .filter_map do |line|
// 534:           next unless line.end_with? ".rb\n"
// 535:
// 536:           name = "#{tap.name}/#{File.basename(line.chomp, ".rb")}"
// 537:           begin
// 538:             Cask::CaskLoader.load(name)
// 539:           rescue Cask::CaskUnavailableError
// 540:             nil
// 541:           end
// 542:         end
// 543:         formulae + casks
// 544:       end
// 545:
// 546:       sig { params(repo: String, pull_request: String).void }
// 547:       def pr_check_conflicts(repo, pull_request)
// 548:         long_build_pr_files = GitHub.issues(
// 549:           repo:, state: "open", labels: "no long build conflict",
// 550:         ).each_with_object({}) do |long_build_pr, hash|
// 551:           next unless long_build_pr.key?("pull_request")
// 552:
// 553:           number = long_build_pr["number"]
// 554:           next if number == pull_request.to_i
// 555:
// 556:           GitHub.get_pull_request_changed_files(repo, number).each do |file|
// 557:             key = file["filename"]
// 558:             hash[key] ||= []
// 559:             hash[key] << number
// 560:           end
// 561:         end
// 562:
// 563:         return if long_build_pr_files.blank?
// 564:
// 565:         this_pr_files = GitHub.get_pull_request_changed_files(repo, pull_request)
// 566:
// 567:         conflicts = this_pr_files.each_with_object({}) do |file, hash|
// 568:           filename = file["filename"]
// 569:           next unless long_build_pr_files.key?(filename)
// 570:
// 571:           long_build_pr_files[filename].each do |pr_number|
// 572:             key = "#{repo}/pull/#{pr_number}"
// 573:             hash[key] ||= []
// 574:             hash[key] << filename
// 575:           end
// 576:         end
// 577:
// 578:         return if conflicts.blank?
// 579:
// 580:         # Raise an error, display the conflicting PR. For example:
// 581:         # Error: You are trying to merge a pull request that conflicts with a long running build in:
// 582:         # {
// 583:         #   "homebrew-core/pull/98809": [
// 584:         #    "Formula/icu4c.rb",
// 585:         #    "Formula/node@10.rb"
// 586:         #   ]
// 587:         # }
// 588:         odie <<~EOS
// 589:           You are trying to merge a pull request that conflicts with a long running build in:
// 590:           #{JSON.pretty_generate(conflicts)}
// 591:         EOS
// 592:       end
// 593:     end
// 594:   end
// 595: end
