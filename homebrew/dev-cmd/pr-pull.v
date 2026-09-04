module dev_cmd

import ruby

// Translated from Homebrew/brew `dev-cmd/pr-pull.rb`.

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

pub fn pr_pull_boundary_input(input &PrPullBoundaryInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::PrPull::Input', '', {
		'pr_pull_input_address': u64(voidptr(input)).str()
	})
}

fn pr_pull_boundary_input_from_value(value ruby.Value) &PrPullBoundaryInput {
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

fn pr_pull_package_value(package PrPullPackage) ruby.Value {
	return ruby.map_value({
		'name':     ruby.string_value(package.name)
		'version':  ruby.string_value(package.version)
		'revision': ruby.int_value(package.revision)
		'sha256':   ruby.string_value(package.sha256)
		'is_cask':  ruby.bool_value(package.is_cask)
	})
}

fn pr_pull_effect_value(effect PrPullEffect) ruby.Value {
	mut details := map[string]ruby.Value{}
	for key, value in effect.details {
		details[key] = ruby.string_value(value)
	}
	return ruby.map_value({
		'kind':    ruby.string_value(effect.kind)
		'argv':    ruby.string_array_value(effect.argv)
		'details': ruby.map_value(details)
	})
}

fn pr_pull_parts_value(parts PrPullCommitParts) ruby.Value {
	return ruby.string_array_value([parts.subject, parts.body, parts.trailers])
}

fn pr_pull_rewrite_value(result PrPullRewriteResult) ruby.Value {
	return ruby.map_value({
		'subject': ruby.string_value(result.subject)
		'effects': ruby.array_value(result.effects.map(pr_pull_effect_value(it)))
	})
}

fn pr_pull_run_result_value(result PrPullRunResult) ruby.Value {
	mut environment := map[string]ruby.Value{}
	for key, value in result.environment {
		environment[key] = ruby.string_value(value)
	}
	mut writes := map[string]ruby.Value{}
	for key, value in result.output_writes {
		writes[key] = ruby.string_value(value)
	}
	return ruby.map_value({
		'required_executables': ruby.string_array_value(result.required_executables)
		'environment':          ruby.map_value(environment)
		'effects':              ruby.array_value(result.effects.map(pr_pull_effect_value(it)))
		'downloads':            ruby.array_value(result.downloads.map(ruby.map_value({
			'url':          ruby.string_value(it.url)
			'pull_request': ruby.string_value(it.pull_request)
		})))
		'ohai':                 ruby.string_array_value(result.ohai)
		'warnings':             ruby.string_array_value(result.warnings)
		'debug':                ruby.string_array_value(result.debug)
		'removed_directories':  ruby.string_array_value(result.removed_directories)
		'retained_directories': ruby.string_array_value(result.retained_directories)
		'output_writes':        ruby.map_value(writes)
	})
}
