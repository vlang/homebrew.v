module test_bot

import ruby
import homebrew.utils
import os
import time
import x.json2

// Translated from Homebrew/brew `test_bot/test_formulae.rb`.

pub struct TestFormulaeArtifact {
pub:
	name                 string
	archive_download_url string
	id                   i64
	files                map[string]string
}

pub struct TestFormulaeCheckRun {
pub:
	name   string
	status string
}

pub struct TestFormulaeWorkflowRun {
pub:
	database_id i64
	event       string
	name        string
}

pub struct TestFormulaeCheckSuite {
pub:
	status       string
	updated_at   string
	workflow_run ?TestFormulaeWorkflowRun
	check_runs   []TestFormulaeCheckRun
}

pub struct TestFormulaeDependency {
pub:
	name         string
	formula_name string
	build        bool
	test         bool
}

pub struct TestFormulaeFormula {
pub:
	name                     string
	full_name                string
	path                     string
	dependencies             []TestFormulaeDependency
	recursive_dependencies   []TestFormulaeDependency
	all_bottle               bool
	bottled                  bool
	bottled_current_version  bool
	has_stable               bool = true
	stable_using             string
	stable_resource_usings   []string
	has_head                 bool
	head_using               string
	head_resource_usings     []string
	unsatisfied_requirements []string
}

pub struct TestFormulaeConfig {
pub:
	test_config                TestConfig
	artifact_cache             string = 'artifact-cache'
	environment                map[string]string
	github_credentials         bool
	github_pull_request_labels []string
	check_suites               []TestFormulaeCheckSuite
	artifacts_by_run           map[i64][]TestFormulaeArtifact
	formulae                   map[string]TestFormulaeFormula
	testing_formulae           []string
	tested_formulae            []string
	bottle_tag                 string = 'all'
	no_diff_results            map[string]bool
	dependency_outputs         map[string][]string
	dependency_failures        []string
	cache_path                 string
	logs_path                  string
	free_gb                    i64 = -1
	installed_formulae         []string
	installed_formulae_deps    map[string][]string
	previous_run_artifact      string
	brew_executable            string = 'brew'
}

@[heap]
pub struct TestFormulae {
pub:
	artifact_cache             string
	environment                map[string]string
	github_credentials         bool
	github_pull_request_labels []string
	check_suites               []TestFormulaeCheckSuite
	artifacts_by_run           map[i64][]TestFormulaeArtifact
	formulae                   map[string]TestFormulaeFormula
	bottle_tag                 string
	no_diff_results            map[string]bool
	dependency_outputs         map[string][]string
	dependency_failures        []string
	cache_path                 string
	logs_path                  string
	free_gb                    i64
	installed_formulae         []string
	installed_formulae_deps    map[string][]string
	previous_run_artifact      string
	brew_executable            string
pub mut:
	base                       &Test
	skipped_or_failed_formulae []string
	downloaded_artifacts       map[string][]string
	testing_formulae           []string
	tested_formulae            []string
	fetched_refs               []string
	cleaned_up_during          bool
}

pub fn new_test_formulae(config TestFormulaeConfig) &TestFormulae {
	return &TestFormulae{
		base: new_test(config.test_config)
		artifact_cache: config.artifact_cache
		environment: config.environment.clone()
		github_credentials: config.github_credentials
		github_pull_request_labels: config.github_pull_request_labels.clone()
		check_suites: config.check_suites.clone()
		artifacts_by_run: config.artifacts_by_run.clone()
		formulae: config.formulae.clone()
		testing_formulae: config.testing_formulae.clone()
		tested_formulae: config.tested_formulae.clone()
		bottle_tag: if config.bottle_tag == '' { 'all' } else { config.bottle_tag }
		no_diff_results: config.no_diff_results.clone()
		dependency_outputs: config.dependency_outputs.clone()
		dependency_failures: config.dependency_failures.clone()
		cache_path: config.cache_path
		logs_path: config.logs_path
		free_gb: config.free_gb
		installed_formulae: config.installed_formulae.clone()
		installed_formulae_deps: config.installed_formulae_deps.clone()
		previous_run_artifact: config.previous_run_artifact
		brew_executable: if config.brew_executable == '' { 'brew' } else { config.brew_executable }
		downloaded_artifacts: map[string][]string{}
	}
}

fn test_formulae_nil() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn test_formulae_error(kind string, message string) ruby.Value {
	return ruby.structured_value(kind, message, {
		'message': message
	})
}

pub fn test_formulae_boundary(test_formulae &TestFormulae) ruby.Value {
	return ruby.structured_value('Homebrew::TestBot::TestFormulae', test_formulae.artifact_cache, {
		'test_formulae_address': u64(voidptr(test_formulae)).str()
	})
}

fn test_formulae_receiver(args []ruby.Value) !&TestFormulae {
	if args.len == 0 || 'test_formulae_address' !in args[0].attributes {
		return error('TestFormulae receiver is required')
	}
	address := args[0].attributes['test_formulae_address'].u64()
	if address == 0 {
		return error('TestFormulae receiver is invalid')
	}
	return unsafe { &TestFormulae(voidptr(address)) }
}

pub fn test_formulae_dependency_boundary(dependency TestFormulaeDependency) ruby.Value {
	return ruby.structured_value('Dependency', dependency.name, {
		'name':         dependency.name
		'formula_name': dependency.formula_name
		'build':        dependency.build.str()
		'test':         dependency.test.str()
	})
}

pub fn test_formulae_artifact_boundary(artifact TestFormulaeArtifact) ruby.Value {
	mut files := map[string]ruby.Value{}
	for path, contents in artifact.files {
		files[path] = ruby.string_value(contents)
	}
	return ruby.Value{
		type_name: 'GitHub::Artifact'
		repr: artifact.name
		attributes: {
			'name':                 artifact.name
			'archive_download_url': artifact.archive_download_url
			'id':                   artifact.id.str()
		}
		map_data: {
			'files': ruby.map_value(files)
		}
	}
}

fn test_formulae_artifact_from_value(value ruby.Value) TestFormulaeArtifact {
	mut files := map[string]string{}
	if file_values := value.map_data['files'] {
		for path, contents in file_values.as_map() or { map[string]ruby.Value{} } {
			files[path] = contents.as_string()
		}
	}
	return TestFormulaeArtifact{
		name: value.attributes['name'] or { value.as_string() }
		archive_download_url: value.attributes['archive_download_url'] or { '' }
		id: (value.attributes['id'] or { '0' }).i64()
		files: files
	}
}

pub fn test_formulae_check_suite_boundary(suite TestFormulaeCheckSuite) ruby.Value {
	mut workflow := test_formulae_nil()
	if run := suite.workflow_run {
		workflow = ruby.structured_value('GitHub::WorkflowRun', run.database_id.str(), {
			'database_id': run.database_id.str()
			'event':       run.event
			'name':        run.name
		})
	}
	return ruby.Value{
		type_name: 'GitHub::CheckSuite'
		repr: suite.updated_at
		attributes: {
			'status':     suite.status
			'updated_at': suite.updated_at
		}
		map_data: {
			'workflow_run': workflow
			'check_runs':   ruby.array_value(suite.check_runs.map(ruby.structured_value('GitHub::CheckRun', it.name, {
				'name':   it.name
				'status': it.status
			})))
		}
	}
}

fn test_formulae_check_suite_from_value(value ruby.Value) TestFormulaeCheckSuite {
	workflow_value := value.map_data['workflow_run'] or { test_formulae_nil() }
	workflow_run := if workflow_value.type_name in ['NilClass', 'Nil'] {
		none
	} else {
		?TestFormulaeWorkflowRun(TestFormulaeWorkflowRun{
			database_id: (workflow_value.attributes['database_id'] or { '0' }).i64()
			event: workflow_value.attributes['event'] or { '' }
			name: workflow_value.attributes['name'] or { '' }
		})
	}
	check_run_values := value.map_data['check_runs'] or { ruby.array_value([]) }
	return TestFormulaeCheckSuite{
		status: value.attributes['status'] or { '' }
		updated_at: value.attributes['updated_at'] or { '' }
		workflow_run: workflow_run
		check_runs: (check_run_values.as_array() or { []ruby.Value{} }).map(TestFormulaeCheckRun{
			name: it.attributes['name'] or { it.as_string() }
			status: it.attributes['status'] or { '' }
		})
	}
}

fn test_formulae_dependency_from_value(value ruby.Value) TestFormulaeDependency {
	return TestFormulaeDependency{
		name: value.attributes['name'] or { value.as_string() }
		formula_name: value.attributes['formula_name'] or { value.as_string() }
		build: (value.attributes['build'] or { 'false' }) == 'true'
		test: (value.attributes['test'] or { 'false' }) == 'true'
	}
}

fn test_formulae_dependencies_from_value(value ruby.Value) []TestFormulaeDependency {
	return (value.as_array() or { []ruby.Value{} }).map(test_formulae_dependency_from_value(it))
}

pub fn test_formulae_formula_boundary(formula TestFormulaeFormula) ruby.Value {
	return ruby.Value{
		type_name: 'Formula'
		repr: if formula.full_name == '' { formula.name } else { formula.full_name }
		attributes: {
			'name':                     formula.name
			'full_name':                formula.full_name
			'path':                     formula.path
			'all_bottle':               formula.all_bottle.str()
			'bottled':                  formula.bottled.str()
			'bottled_current_version':  formula.bottled_current_version.str()
			'has_stable':               formula.has_stable.str()
			'stable_using':             formula.stable_using
			'stable_resource_usings':   formula.stable_resource_usings.join('\x1f')
			'has_head':                 formula.has_head.str()
			'head_using':               formula.head_using
			'head_resource_usings':     formula.head_resource_usings.join('\x1f')
			'unsatisfied_requirements': formula.unsatisfied_requirements.join('\x1f')
		}
		map_data: {
			'dependencies':           ruby.array_value(formula.dependencies.map(test_formulae_dependency_boundary(it)))
			'recursive_dependencies': ruby.array_value(formula.recursive_dependencies.map(test_formulae_dependency_boundary(it)))
		}
	}
}

fn test_formulae_split_attribute(value ruby.Value, name string) []string {
	raw := value.attributes[name] or { return [] }
	return if raw == '' { [] } else { raw.split('\x1f') }
}

fn test_formulae_formula_from_value(value ruby.Value) TestFormulaeFormula {
	name := value.attributes['name'] or { value.as_string().all_after_last('/') }
	return TestFormulaeFormula{
		name: name
		full_name: value.attributes['full_name'] or { value.as_string() }
		path: value.attributes['path'] or { '' }
		dependencies: if dependencies := value.map_data['dependencies'] {
			test_formulae_dependencies_from_value(dependencies)
		} else {
			[]
		}
		recursive_dependencies: if dependencies := value.map_data['recursive_dependencies'] {
			test_formulae_dependencies_from_value(dependencies)
		} else {
			[]
		}
		all_bottle: (value.attributes['all_bottle'] or { 'false' }) == 'true'
		bottled: (value.attributes['bottled'] or { 'false' }) == 'true'
		bottled_current_version: (value.attributes['bottled_current_version'] or { 'false' }) == 'true'
		has_stable: (value.attributes['has_stable'] or { 'true' }) == 'true'
		stable_using: value.attributes['stable_using'] or { '' }
		stable_resource_usings: test_formulae_split_attribute(value, 'stable_resource_usings')
		has_head: (value.attributes['has_head'] or { 'false' }) == 'true'
		head_using: value.attributes['head_using'] or { '' }
		head_resource_usings: test_formulae_split_attribute(value, 'head_resource_usings')
		unsatisfied_requirements: test_formulae_split_attribute(value, 'unsatisfied_requirements')
	}
}

fn test_formulae_any_to_value(value json2.Any) ruby.Value {
	return match value {
		map[string]json2.Any {
			mut mapped := map[string]ruby.Value{}
			for key, nested in value {
				mapped[key] = test_formulae_any_to_value(nested)
			}
			ruby.map_value(mapped)
		}
		[]json2.Any { ruby.array_value(value.map(test_formulae_any_to_value(it))) }
		string { ruby.string_value(value) }
		bool { ruby.bool_value(value) }
		i64 { ruby.int_value(value) }
		int { ruby.int_value(value) }
		i32 { ruby.int_value(value) }
		i16 { ruby.int_value(value) }
		i8 { ruby.int_value(value) }
		u64 { ruby.int_value(i64(value)) }
		u32 { ruby.int_value(i64(value)) }
		u16 { ruby.int_value(i64(value)) }
		u8 { ruby.int_value(i64(value)) }
		f64 { ruby.float_value(value) }
		f32 { ruby.float_value(value) }
		time.Time { ruby.string_value(value.format_rfc3339()) }
		json2.Null { test_formulae_nil() }
	}
}

fn test_formulae_environment_value(test_formulae &TestFormulae, name string) string {
	if value := test_formulae.environment[name] {
		return value
	}
	return os.getenv(name)
}

fn test_formulae_json_map(value json2.Any) ?map[string]json2.Any {
	if value is map[string]json2.Any {
		return value
	}
	return none
}

fn test_formulae_json_at(value json2.Any, keys ...string) ?json2.Any {
	mut current := value
	for key in keys {
		current_map := test_formulae_json_map(current) or { return none }
		current = current_map[key] or { return none }
	}
	return current
}

fn test_formulae_json_string(value json2.Any) string {
	if value is json2.Null {
		return ''
	}
	return value.str()
}

fn test_formulae_wildcard_match_at(pattern string, value string, pattern_index int,
	value_index int) bool {
	if pattern_index == pattern.len {
		return value_index == value.len
	}
	if pattern[pattern_index] == `*` {
		if test_formulae_wildcard_match_at(pattern, value, pattern_index + 1, value_index) {
			return true
		}
		return value_index < value.len
			&& test_formulae_wildcard_match_at(pattern, value, pattern_index, value_index + 1)
	}
	if value_index == value.len {
		return false
	}
	if pattern[pattern_index] == `?` {
		return test_formulae_wildcard_match_at(pattern, value, pattern_index + 1, value_index + 1)
	}
	return pattern[pattern_index] == value[value_index]
		&& test_formulae_wildcard_match_at(pattern, value, pattern_index + 1, value_index + 1)
}

fn test_formulae_expand_braces(pattern string) []string {
	open := pattern.index('{') or { return [pattern] }
	close_relative := pattern[open + 1..].index('}') or { return [pattern] }
	close := open + 1 + close_relative
	prefix := pattern[..open]
	suffix := pattern[close + 1..]
	mut expanded := []string{}
	for choice in pattern[open + 1..close].split(',') {
		for nested in test_formulae_expand_braces(prefix + choice + suffix) {
			expanded << nested
		}
	}
	return expanded
}

fn test_formulae_pattern_matches(pattern string, value string) bool {
	return test_formulae_expand_braces(pattern).any(test_formulae_wildcard_match_at(it, value, 0, 0))
}

pub fn (test_formulae &TestFormulae) require_current_tap_trust_env() map[string]string {
	return {
		'HOMEBREW_REQUIRE_TAP_TRUST': '1'
	}
}

pub fn (test_formulae &TestFormulae) cached_event_json() ?string {
	path := os.join_path(test_formulae.artifact_cache, 'event.json')
	return if os.is_file(path) { path } else { none }
}

pub fn (test_formulae &TestFormulae) github_event_payload() ?json2.Any {
	path := test_formulae_environment_value(test_formulae, 'GITHUB_EVENT_PATH')
	if path == '' {
		return none
	}
	contents := os.read_file(path) or { return none }
	return json2.decode[json2.Any](contents) or { none }
}

pub fn (test_formulae &TestFormulae) previous_github_sha() ?string {
	if !test_formulae.base.has_tap || !os.is_dir(test_formulae.base.repository)
		|| !test_formulae.base.actions_enabled() {
		return none
	}
	payload := test_formulae.github_event_payload() or { return none }
	head_owner_value := test_formulae_json_at(payload, 'pull_request', 'head', 'repo', 'owner', 'login') or { json2.Any(json2.null) }
	head_owner := test_formulae_json_string(head_owner_value)
	repository_owner := test_formulae_environment_value(test_formulae, 'GITHUB_REPOSITORY_OWNER')
	if head_owner != repository_owner && head_owner != 'BrewTestBot' {
		return none
	}
	mut event_payload := payload
	if cached := test_formulae.cached_event_json() {
		if contents := os.read_file(cached) {
			event_payload = json2.decode[json2.Any](contents) or { payload }
		}
	}
	before := test_formulae_json_at(event_payload, 'before') or { return none }
	sha := test_formulae_json_string(before)
	return if sha == '' { none } else { sha }
}

pub fn (test_formulae &TestFormulae) artifact_metadata(check_suite_nodes []TestFormulaeCheckSuite,
	_repo string, event_name string, workflow_name string, check_run_name string,
	artifact_pattern string) []TestFormulaeArtifact {
	mut candidates := []TestFormulaeCheckSuite{}
	for node in check_suite_nodes {
		if node.status != 'COMPLETED' {
			continue
		}
		workflow_run := node.workflow_run or { continue }
		if workflow_run.event != event_name || workflow_run.name != workflow_name {
			continue
		}
		if !node.check_runs.any(it.name == check_run_name && it.status == 'COMPLETED') {
			continue
		}
		candidates << node
	}
	if candidates.len == 0 {
		return []
	}
	mut latest := candidates[0]
	for candidate in candidates[1..] {
		if candidate.updated_at > latest.updated_at {
			latest = candidate
		}
	}
	run := latest.workflow_run or { return [] }
	if run.database_id == 0 {
		return []
	}
	artifacts := test_formulae.artifacts_by_run[run.database_id] or { return [] }
	return artifacts.filter(test_formulae_pattern_matches(artifact_pattern, it.name))
}

fn test_formulae_write_artifact_files(cache string, artifact TestFormulaeArtifact) ! {
	for relative_path, contents in artifact.files {
		path := os.join_path(cache, relative_path)
		os.mkdir_all(os.dir(path))!
		os.write_file(path, contents)!
	}
}

pub fn (mut test_formulae TestFormulae) download_artifacts_from_previous_run(artifact_pattern string,
	dry_run bool) ! {
	if dry_run || !test_formulae.github_credentials {
		return
	}
	sha := test_formulae.previous_github_sha() or { return }
	payload := test_formulae.github_event_payload() or { return }
	pull_number_value := test_formulae_json_at(payload, 'pull_request', 'number') or { return }
	if test_formulae_json_string(pull_number_value) == '' {
		return
	}
	repository := test_formulae_environment_value(test_formulae, 'GITHUB_REPOSITORY')
	parts := repository.split('/')
	if parts.len != 2 || parts[0] == '' || parts[1] == '' {
		return error('github_repository ${repository} is invalid')
	}
	if 'CI-no-bottle-cache' in test_formulae.github_pull_request_labels
		|| 'workflows' in test_formulae.github_pull_request_labels {
		return
	}
	mut wanted := test_formulae.artifact_metadata(test_formulae.check_suites, repository, 'pull_request', 'CI', 'conclusion', artifact_pattern)
	mut wanted_pattern := artifact_pattern
	if wanted.len == 0 {
		wanted = test_formulae.artifact_metadata(test_formulae.check_suites, repository, 'pull_request_target', 'Triage tasks', 'upload-metadata', 'event_payload')
		wanted_pattern = 'event_payload'
	}
	if wanted.len == 0 {
		return
	}
	previous_attempts := test_formulae.downloaded_artifacts[sha] or { []string{} }
	attempted_artifacts := wanted.filter(it.name in previous_attempts)
	if attempted_artifacts.len > 0 {
		attempted := attempted_artifacts[0]
		test_formulae.base.emit('Warning: Already tried ${attempted.name} from ${sha}, giving up')
		return
	}
	if wanted_pattern == 'event_payload' {
		if cached := test_formulae.cached_event_json() {
			os.rm(cached)!
		}
	}
	os.mkdir_all(test_formulae.artifact_cache)!
	test_formulae.base.emit('Downloading artifacts matching pattern ${wanted_pattern} from ${sha}')
	for artifact in wanted {
		test_formulae.base.emit('Downloading artifact ${artifact.name} from ${sha}')
		mut downloaded := test_formulae.downloaded_artifacts[sha] or { []string{} }
		downloaded << artifact.name
		test_formulae.downloaded_artifacts[sha] = downloaded
		test_formulae_write_artifact_files(test_formulae.artifact_cache, artifact)!
	}
	if wanted_pattern != artifact_pattern {
		test_formulae.download_artifacts_from_previous_run(artifact_pattern, dry_run)!
	}
}

fn test_formulae_formula_name(formula TestFormulaeFormula) string {
	return if formula.full_name == '' { formula.name } else { formula.full_name }
}

fn test_formulae_no_diff_key(formula TestFormulaeFormula, git_ref string) string {
	return '${test_formulae_formula_name(formula)}\x1f${git_ref}'
}

pub fn (mut test_formulae TestFormulae) no_diff(formula TestFormulaeFormula,
	git_ref string) bool {
	if !os.is_dir(test_formulae.base.repository) {
		return false
	}
	key := test_formulae_no_diff_key(formula, git_ref)
	if configured := test_formulae.no_diff_results[key] {
		return configured
	}
	git := if test_formulae.base.git == '' { 'git' } else { test_formulae.base.git }
	if git_ref !in test_formulae.fetched_refs {
		step := test_formulae.base.run_step(TestRequest{
			arguments: [git, '-C', test_formulae.base.repository, 'fetch', 'origin', git_ref]
			ignore_failures: true
		})
		if step.passed() {
			test_formulae.fetched_refs << git_ref
		}
	}
	path := if formula.path.starts_with(test_formulae.base.repository.trim_right('/') + '/') {
		formula.path[test_formulae.base.repository.trim_right('/').len + 1..]
	} else {
		formula.path
	}
	result := execute_step_command([git, '-C', test_formulae.base.repository, 'diff', '--no-ext-diff',
		'--quiet', git_ref, '--', path], map[string]string{}, []) or { return false }
	return result.exit_code == 0
}

pub fn (test_formulae &TestFormulae) bottle_glob(formula_name string, bottle_dir string,
	ext string, bottle_tag string) []string {
	directory := if bottle_dir == '' { os.getwd() } else { bottle_dir }
	tag := if bottle_tag == '' { test_formulae.bottle_tag } else { bottle_tag }
	extension := if ext == '' { '.tar.gz' } else { ext }
	pattern := '${formula_name}--*.${tag}.bottle*${extension}'
	mut matches := []string{}
	for path in os.ls(directory) or { return [] } {
		if test_formulae_pattern_matches(pattern, path) {
			matches << os.join_path(directory, path)
		}
	}
	matches.sort()
	return matches
}

pub fn (test_formulae &TestFormulae) local_bottle_hash(formula string,
	bottle_dir string) ?json2.Any {
	paths := test_formulae.bottle_glob(formula, bottle_dir, '.json', test_formulae.bottle_tag)
	if paths.len == 0 {
		return none
	}
	contents := os.read_file(paths[0]) or { return none }
	return json2.decode[json2.Any](contents) or { none }
}

fn test_formulae_bottle_revision(value json2.Any, formula_name string) string {
	revision := test_formulae_json_at(value, formula_name, 'formula', 'tap_git_revision') or {
		return ''
	}
	return test_formulae_json_string(revision)
}

pub fn (mut test_formulae TestFormulae) artifact_cache_valid(formula TestFormulaeFormula,
	formulae_dependents bool) bool {
	sha := if formulae_dependents {
		test_formulae.previous_github_sha() or { return false }
	} else {
		hash := test_formulae.local_bottle_hash(formula.name, test_formulae.artifact_cache) or {
			return false
		}
		test_formulae_bottle_revision(hash, formula.name)
	}
	if sha == '' || !test_formulae.no_diff(formula, sha) {
		return false
	}
	for dependency in formula.recursive_dependencies {
		if !formulae_dependents && (dependency.build || dependency.test) {
			continue
		}
		dependency_name := if dependency.formula_name == '' {
			dependency.name
		} else {
			dependency.formula_name
		}
		dependency_formula := test_formulae.formulae[dependency_name] or {
			return false
		}
		if !test_formulae.no_diff(dependency_formula, sha) {
			return false
		}
	}
	return true
}

pub fn (mut test_formulae TestFormulae) install_formula_from_bottle(formula_name string,
	testing_formulae_dependents bool, dry_run bool, bottle_dir string) !bool {
	mut bottle_filename := ''
	paths := test_formulae.bottle_glob(formula_name, bottle_dir, '.tar.gz', test_formulae.bottle_tag)
	if paths.len > 0 {
		bottle_filename = paths[0]
	} else if testing_formulae_dependents && !dry_run {
		return error("Failed to find bottle for '${formula_name}'.")
	} else if !dry_run {
		return false
	} else {
		bottle_filename = r'$BOTTLE_FILENAME'
	}
	mut install_args := [test_formulae.brew_executable, 'install']
	if testing_formulae_dependents {
		install_args << ['--ignore-dependencies', '--skip-post-install']
	}
	install_args << bottle_filename
	install_step := test_formulae.base.run_step(TestRequest{ arguments: install_args })
	if !dry_run && !testing_formulae_dependents && install_step.passed() {
		if bottle_hash := test_formulae.local_bottle_hash(formula_name, bottle_dir) {
			revision := test_formulae_bottle_revision(bottle_hash, formula_name)
			test_formulae.base.emit('Bottle cache hit')
			test_formulae.base.emit('Bottle for ${formula_name} built at ${revision}'.trim_space())
		}
	}
	if !testing_formulae_dependents || !install_step.passed() {
		return install_step.passed()
	}
	test_formulae.base.run_step(TestRequest{
		arguments: [test_formulae.brew_executable, 'unlink', formula_name]
	})
	return install_step.passed()
}

pub fn (test_formulae &TestFormulae) bottled(formula TestFormulaeFormula,
	no_older_versions bool) bool {
	if formula.all_bottle {
		for dependency in formula.dependencies {
			dependency_name := if dependency.formula_name == '' {
				dependency.name
			} else {
				dependency.formula_name
			}
			dependency_formula := test_formulae.formulae[dependency_name] or { return false }
			bottle_no_older_versions := no_older_versions && (!dependency.test || dependency.build)
			if !test_formulae.bottled(dependency_formula, bottle_no_older_versions) {
				return false
			}
		}
		return true
	}
	return formula.bottled && (!no_older_versions || formula.bottled_current_version)
}

pub fn (test_formulae &TestFormulae) bottled_or_built(formula TestFormulaeFormula,
	built_formulae []string, no_older_versions bool) bool {
	return test_formulae.bottled(formula, no_older_versions)
		|| test_formulae_formula_name(formula) in built_formulae
}

pub fn (test_formulae &TestFormulae) downloads_using_homebrew_curl(formula TestFormulaeFormula) bool {
	return (formula.has_stable && (formula.stable_using == 'homebrew_curl'
		|| 'homebrew_curl' in formula.stable_resource_usings))
		|| (formula.has_head && (formula.head_using == 'homebrew_curl'
			|| 'homebrew_curl' in formula.head_resource_usings))
}

pub fn (mut test_formulae TestFormulae) install_curl_if_needed(formula TestFormulaeFormula) {
	if test_formulae.downloads_using_homebrew_curl(formula) {
		test_formulae.base.run_step(TestRequest{
			arguments: [test_formulae.brew_executable, 'install', 'curl']
			unset_environment: ['HOMEBREW_DEVELOPER']
		})
	}
}

fn test_formulae_has_build_dependency(dependencies []TestFormulaeDependency, name string) bool {
	return dependencies.any(it.name == name && it.build)
}

pub fn (mut test_formulae TestFormulae) install_mercurial_if_needed(dependencies []TestFormulaeDependency,
	requirements []TestFormulaeDependency) {
	if test_formulae_has_build_dependency(dependencies, 'mercurial')
		|| test_formulae_has_build_dependency(requirements, 'mercurial') {
		test_formulae.base.run_step(TestRequest{
			arguments: [test_formulae.brew_executable, 'install', 'mercurial']
			unset_environment: ['HOMEBREW_DEVELOPER']
		})
	}
}

pub fn (mut test_formulae TestFormulae) install_subversion_if_needed(dependencies []TestFormulaeDependency,
	requirements []TestFormulaeDependency) {
	if test_formulae_has_build_dependency(dependencies, 'subversion')
		|| test_formulae_has_build_dependency(requirements, 'subversion') {
		test_formulae.base.run_step(TestRequest{
			arguments: [test_formulae.brew_executable, 'install', 'subversion']
			unset_environment: ['HOMEBREW_DEVELOPER']
		})
	}
}

pub fn (mut test_formulae TestFormulae) skipped(formula_name string, reason string) {
	test_formulae.skipped_or_failed_formulae << formula_name
	state := utils.current_tty_state()
	test_formulae.base.emit(utils.formatter_headline('${utils.formatter_warning('SKIPPED', none, state)} ${utils.formatter_identifier(formula_name, state)}', 'yellow', state))
	test_formulae.base.emit('Warning: ${reason}')
}

pub fn (mut test_formulae TestFormulae) failed(formula_name string, reason string) {
	test_formulae.skipped_or_failed_formulae << formula_name
	state := utils.current_tty_state()
	test_formulae.base.emit(utils.formatter_headline('${utils.formatter_error('FAILED', none, state)} ${utils.formatter_identifier(formula_name, state)}', 'red', state))
	test_formulae.base.emit('Error: ${reason}')
}

pub fn (test_formulae &TestFormulae) unsatisfied_requirements_messages(formula TestFormulaeFormula) ?string {
	message := formula.unsatisfied_requirements.join('\n')
	return if message == '' { none } else { message }
}

pub fn (test_formulae &TestFormulae) previous_run_artifact_specifier() !string {
	if test_formulae.previous_run_artifact == '' {
		return error('TestFormulae must implement previous_run_artifact_specifier in extend/os.')
	}
	return test_formulae.previous_run_artifact
}

fn test_formulae_available_gb(test_formulae &TestFormulae) i64 {
	if test_formulae.free_gb >= 0 {
		return test_formulae.free_gb
	}
	result := execute_step_command(['df', test_formulae.cache_path], {
		'BLOCKSIZE': '1000000000'
	}, []) or { return 11 }
	lines := result.output.split_into_lines()
	if lines.len < 2 {
		return 11
	}
	fields := lines[1].fields()
	return if fields.len > 3 { fields[3].i64() } else { 11 }
}

fn test_formulae_path_contains(parent string, child string) bool {
	clean_parent := os.norm_path(parent).trim_right('/')
	clean_child := os.norm_path(child)
	return clean_child == clean_parent || clean_child.starts_with(clean_parent + '/')
}

pub fn (mut test_formulae TestFormulae) cleanup_during(keep_formulae []string,
	args TestCommandArgs) {
	if !test_cleanup_enabled(args, test_formulae.base.actions_enabled())
		|| test_formulae.cache_path == '' || !os.exists(test_formulae.cache_path)
		|| test_formulae_available_gb(test_formulae) > 10 {
		return
	}
	test_formulae.base.test_header('TestFormulae', 'cleanup_during!')
	logs_in_cache := test_formulae.logs_path != ''
		&& test_formulae_path_contains(test_formulae.cache_path, test_formulae.logs_path)
		&& os.exists(test_formulae.logs_path)
	backup := '${test_formulae.cache_path}.test-bot-logs'
	if logs_in_cache {
		test_formulae.base.run_step(TestRequest{ arguments: ['mv', test_formulae.logs_path, backup] })
	}
	test_formulae.base.run_step(TestRequest{
		arguments: ['chmod', '-R', 'u+rw', test_formulae.cache_path]
		ignore_failures: true
	})
	test_formulae.base.run_step(TestRequest{ arguments: ['rm', '-rf', test_formulae.cache_path] })
	if logs_in_cache {
		test_formulae.base.run_step(TestRequest{
			arguments: ['mkdir', '-p', os.dir(test_formulae.logs_path)]
		})
		test_formulae.base.run_step(TestRequest{ arguments: ['mv', backup, test_formulae.logs_path] })
	}
	if !test_formulae.cleaned_up_during {
		test_formulae.cleaned_up_during = true
		return
	}
	mut uninstallable := test_formulae.installed_formulae.filter(it !in keep_formulae)
	uninstallable = uninstallable.filter(fn [test_formulae, keep_formulae] (name string) bool {
		for formula in keep_formulae {
			if name in (test_formulae.installed_formulae_deps[formula] or { []string{} }) {
				return false
			}
		}
		return true
	})
	if uninstallable.len > 0 {
		mut arguments := [test_formulae.brew_executable, 'uninstall', '--force',
			'--ignore-dependencies']
		arguments << uninstallable
		test_formulae.base.run_step(TestRequest{
			arguments: arguments
		})
	}
}

pub fn (test_formulae &TestFormulae) sorted_formulae() ![]string {
	mut dependent_counts := map[string]int{}
	mut discovery_order := []string{}
	for formula in test_formulae.testing_formulae {
		if formula in test_formulae.dependency_failures {
			return error("Failed to determine dependencies for '${formula}'.")
		}
		dependencies := if configured := test_formulae.dependency_outputs[formula] {
			configured
		} else {
			result := execute_step_command([test_formulae.brew_executable, 'deps', '--full-name',
				'--include-build', '--include-test', formula], map[string]string{}, []) or {
				return error("Failed to determine dependencies for '${formula}'.")
			}
			if result.exit_code != 0 {
				return error("Failed to determine dependencies for '${formula}'.")
			}
			result.output.split_into_lines().filter(it != '')
		}
		for dependency in dependencies {
			if dependency !in test_formulae.testing_formulae {
				continue
			}
			if dependency !in dependent_counts {
				discovery_order << dependency
			}
			dependent_counts[dependency]++
		}
	}
	mut changed := discovery_order.clone()
	changed.sort_with_compare(fn [dependent_counts, discovery_order] (left &string, right &string) int {
		left_count := dependent_counts[*left]
		right_count := dependent_counts[*right]
		if left_count != right_count {
			return right_count - left_count
		}
		return discovery_order.index(*left) - discovery_order.index(*right)
	})
	mut unchanged := test_formulae.testing_formulae.filter(it !in changed)
	changed << unchanged
	return changed
}
