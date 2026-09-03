module test_bot

import brew_runtime
import homebrew.utils
import os
import time
import x.json2

// Translated from Homebrew/brew `test_bot/test_formulae.rb`.
// The original source is retained below until every stub has a typed V body.

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

fn test_formulae_nil() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

fn test_formulae_error(kind string, message string) brew_runtime.Value {
	return brew_runtime.structured_value(kind, message, {
		'message': message
	})
}

pub fn test_formulae_boundary(test_formulae &TestFormulae) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::TestBot::TestFormulae', test_formulae.artifact_cache, {
		'test_formulae_address': u64(voidptr(test_formulae)).str()
	})
}

fn test_formulae_receiver(args []brew_runtime.Value) !&TestFormulae {
	if args.len == 0 || 'test_formulae_address' !in args[0].attributes {
		return error('TestFormulae receiver is required')
	}
	address := args[0].attributes['test_formulae_address'].u64()
	if address == 0 {
		return error('TestFormulae receiver is invalid')
	}
	return unsafe { &TestFormulae(voidptr(address)) }
}

pub fn test_formulae_dependency_boundary(dependency TestFormulaeDependency) brew_runtime.Value {
	return brew_runtime.structured_value('Dependency', dependency.name, {
		'name':         dependency.name
		'formula_name': dependency.formula_name
		'build':        dependency.build.str()
		'test':         dependency.test.str()
	})
}

pub fn test_formulae_artifact_boundary(artifact TestFormulaeArtifact) brew_runtime.Value {
	mut files := map[string]brew_runtime.Value{}
	for path, contents in artifact.files {
		files[path] = brew_runtime.string_value(contents)
	}
	return brew_runtime.Value{
		type_name: 'GitHub::Artifact'
		repr: artifact.name
		attributes: {
			'name':                 artifact.name
			'archive_download_url': artifact.archive_download_url
			'id':                   artifact.id.str()
		}
		map_data: {
			'files': brew_runtime.map_value(files)
		}
	}
}

fn test_formulae_artifact_from_value(value brew_runtime.Value) TestFormulaeArtifact {
	mut files := map[string]string{}
	if file_values := value.map_data['files'] {
		for path, contents in file_values.as_map() or { map[string]brew_runtime.Value{} } {
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

pub fn test_formulae_check_suite_boundary(suite TestFormulaeCheckSuite) brew_runtime.Value {
	mut workflow := test_formulae_nil()
	if run := suite.workflow_run {
		workflow = brew_runtime.structured_value('GitHub::WorkflowRun', run.database_id.str(), {
			'database_id': run.database_id.str()
			'event':       run.event
			'name':        run.name
		})
	}
	return brew_runtime.Value{
		type_name: 'GitHub::CheckSuite'
		repr: suite.updated_at
		attributes: {
			'status':     suite.status
			'updated_at': suite.updated_at
		}
		map_data: {
			'workflow_run': workflow
			'check_runs':   brew_runtime.array_value(suite.check_runs.map(brew_runtime.structured_value('GitHub::CheckRun', it.name, {
				'name':   it.name
				'status': it.status
			})))
		}
	}
}

fn test_formulae_check_suite_from_value(value brew_runtime.Value) TestFormulaeCheckSuite {
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
	check_run_values := value.map_data['check_runs'] or { brew_runtime.array_value([]) }
	return TestFormulaeCheckSuite{
		status: value.attributes['status'] or { '' }
		updated_at: value.attributes['updated_at'] or { '' }
		workflow_run: workflow_run
		check_runs: (check_run_values.as_array() or { []brew_runtime.Value{} }).map(TestFormulaeCheckRun{
			name: it.attributes['name'] or { it.as_string() }
			status: it.attributes['status'] or { '' }
		})
	}
}

fn test_formulae_dependency_from_value(value brew_runtime.Value) TestFormulaeDependency {
	return TestFormulaeDependency{
		name: value.attributes['name'] or { value.as_string() }
		formula_name: value.attributes['formula_name'] or { value.as_string() }
		build: (value.attributes['build'] or { 'false' }) == 'true'
		test: (value.attributes['test'] or { 'false' }) == 'true'
	}
}

fn test_formulae_dependencies_from_value(value brew_runtime.Value) []TestFormulaeDependency {
	return (value.as_array() or { []brew_runtime.Value{} }).map(test_formulae_dependency_from_value(it))
}

pub fn test_formulae_formula_boundary(formula TestFormulaeFormula) brew_runtime.Value {
	return brew_runtime.Value{
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
			'dependencies':           brew_runtime.array_value(formula.dependencies.map(test_formulae_dependency_boundary(it)))
			'recursive_dependencies': brew_runtime.array_value(formula.recursive_dependencies.map(test_formulae_dependency_boundary(it)))
		}
	}
}

fn test_formulae_split_attribute(value brew_runtime.Value, name string) []string {
	raw := value.attributes[name] or { return [] }
	return if raw == '' { [] } else { raw.split('\x1f') }
}

fn test_formulae_formula_from_value(value brew_runtime.Value) TestFormulaeFormula {
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

fn test_formulae_any_to_value(value json2.Any) brew_runtime.Value {
	return match value {
		map[string]json2.Any {
			mut mapped := map[string]brew_runtime.Value{}
			for key, nested in value {
				mapped[key] = test_formulae_any_to_value(nested)
			}
			brew_runtime.map_value(mapped)
		}
		[]json2.Any { brew_runtime.array_value(value.map(test_formulae_any_to_value(it))) }
		string { brew_runtime.string_value(value) }
		bool { brew_runtime.bool_value(value) }
		i64 { brew_runtime.int_value(value) }
		int { brew_runtime.int_value(value) }
		i32 { brew_runtime.int_value(value) }
		i16 { brew_runtime.int_value(value) }
		i8 { brew_runtime.int_value(value) }
		u64 { brew_runtime.int_value(i64(value)) }
		u32 { brew_runtime.int_value(i64(value)) }
		u16 { brew_runtime.int_value(i64(value)) }
		u8 { brew_runtime.int_value(i64(value)) }
		f64 { brew_runtime.float_value(value) }
		f32 { brew_runtime.float_value(value) }
		time.Time { brew_runtime.string_value(value.format_rfc3339()) }
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

// Ruby attr_accessor `attr_accessor :skipped_or_failed_formulae` at line 10.
pub fn ruby_test_formulae_l10_d1_skipped_or_failed_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	test_formulae := test_formulae_receiver(args) or { return test_formulae_error('ArgumentError', err.msg()) }
	return brew_runtime.string_array_value(test_formulae.skipped_or_failed_formulae)
}

// Ruby attr_accessor `attr_accessor :skipped_or_failed_formulae` at line 10.
pub fn ruby_test_formulae_l10_d2_skipped_or_failed_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	mut test_formulae := test_formulae_receiver(args) or { return test_formulae_error('ArgumentError', err.msg()) }
	if args.len < 2 {
		return test_formulae_error('ArgumentError', 'skipped_or_failed_formulae= requires a value')
	}
	test_formulae.skipped_or_failed_formulae = args[1].as_string_array() or { return test_formulae_error('TypeError', err.msg()) }
	return brew_runtime.string_array_value(test_formulae.skipped_or_failed_formulae)
}

// Ruby attr_reader `attr_reader :artifact_cache` at line 13.
pub fn ruby_test_formulae_l13_d3_artifact_cache(args ...brew_runtime.Value) brew_runtime.Value {
	test_formulae := test_formulae_receiver(args) or { return test_formulae_error('ArgumentError', err.msg()) }
	return brew_runtime.object_value('Pathname', test_formulae.artifact_cache)
}

// Ruby attr_reader `attr_reader :downloaded_artifacts` at line 16.
pub fn ruby_test_formulae_l16_d4_downloaded_artifacts(args ...brew_runtime.Value) brew_runtime.Value {
	test_formulae := test_formulae_receiver(args) or { return test_formulae_error('ArgumentError', err.msg()) }
	mut downloaded := map[string]brew_runtime.Value{}
	for sha, artifacts in test_formulae.downloaded_artifacts {
		downloaded[sha] = brew_runtime.string_array_value(artifacts)
	}
	return brew_runtime.map_value(downloaded)
}

// Ruby method `initialize(tap:, git:, dry_run:, fail_fast:, verbose:)` at line 27.
pub fn ruby_test_formulae_l27_d5_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	tap := if args.len > 0 && args[0].type_name !in ['NilClass', 'Nil'] {
		TestTap{
			name: args[0].attributes['name'] or { args[0].as_string() }
			full_name: args[0].attributes['full_name'] or { args[0].as_string() }
			path: args[0].attributes['path'] or { args[0].as_string() }
		}
	} else {
		TestTap{}
	}
	test_formulae := new_test_formulae(TestFormulaeConfig{
		test_config: TestConfig{
			tap: tap
			has_tap: args.len > 0 && args[0].type_name !in ['NilClass', 'Nil']
			git: if args.len > 1 { args[1].as_string() } else { '' }
			has_git: args.len > 1 && args[1].type_name !in ['NilClass', 'Nil']
			dry_run: args.len > 2 && (args[2].as_bool() or { false })
			fail_fast: args.len > 3 && (args[3].as_bool() or { false })
			verbose: args.len > 4 && (args[4].as_bool() or { false })
			emit_output: false
		}
		artifact_cache: if args.len > 5 { args[5].as_string() } else { 'artifact-cache' }
	})
	return test_formulae_boundary(test_formulae)
}

// Ruby method `download_artifacts_from_previous_run!(artifact_pattern, dry_run:)` at line 40.
pub fn ruby_test_formulae_l40_d6_download_artifacts_from_previous_run(args ...brew_runtime.Value) brew_runtime.Value {
	mut test_formulae := test_formulae_receiver(args) or { return test_formulae_error('ArgumentError', err.msg()) }
	pattern := if args.len > 1 { args[1].as_string() } else { '' }
	dry_run := args.len > 2 && (args[2].as_bool() or { false })
	test_formulae.download_artifacts_from_previous_run(pattern, dry_run) or {
		return test_formulae_error('RuntimeError', err.msg())
	}
	return test_formulae_nil()
}

// Ruby method `require_current_tap_trust_env` at line 116.
pub fn ruby_test_formulae_l116_d7_require_current_tap_trust_env(args ...brew_runtime.Value) brew_runtime.Value {
	test_formulae := test_formulae_receiver(args) or { return test_formulae_error('ArgumentError', err.msg()) }
	mut values := map[string]brew_runtime.Value{}
	for name, value in test_formulae.require_current_tap_trust_env() {
		values[name] = brew_runtime.string_value(value)
	}
	return brew_runtime.map_value(values)
}

// Ruby method `cached_event_json` at line 121.
pub fn ruby_test_formulae_l121_d8_cached_event_json(args ...brew_runtime.Value) brew_runtime.Value {
	test_formulae := test_formulae_receiver(args) or { return test_formulae_error('ArgumentError', err.msg()) }
	if path := test_formulae.cached_event_json() {
		return brew_runtime.object_value('Pathname', path)
	}
	return test_formulae_nil()
}

// Ruby method `github_event_payload` at line 128.
pub fn ruby_test_formulae_l128_d9_github_event_payload(args ...brew_runtime.Value) brew_runtime.Value {
	test_formulae := test_formulae_receiver(args) or { return test_formulae_error('ArgumentError', err.msg()) }
	if payload := test_formulae.github_event_payload() {
		return test_formulae_any_to_value(payload)
	}
	return test_formulae_nil()
}

// Ruby method `previous_github_sha` at line 135.
pub fn ruby_test_formulae_l135_d10_previous_github_sha(args ...brew_runtime.Value) brew_runtime.Value {
	test_formulae := test_formulae_receiver(args) or { return test_formulae_error('ArgumentError', err.msg()) }
	if sha := test_formulae.previous_github_sha() {
		return brew_runtime.string_value(sha)
	}
	return test_formulae_nil()
}

// Ruby method `artifact_metadata(check_suite_nodes, repo, event_name, workflow_name, check_run_name, artifact_pattern)` at line 164.
pub fn ruby_test_formulae_l164_d11_artifact_metadata(args ...brew_runtime.Value) brew_runtime.Value {
	test_formulae := test_formulae_receiver(args) or { return test_formulae_error('ArgumentError', err.msg()) }
	if args.len < 7 {
		return test_formulae_error('ArgumentError', 'artifact_metadata requires six arguments')
	}
	nodes := (args[1].as_array() or { []brew_runtime.Value{} }).map(test_formulae_check_suite_from_value(it))
	artifacts := test_formulae.artifact_metadata(nodes, args[2].as_string(), args[3].as_string(), args[4].as_string(), args[5].as_string(), args[6].as_string())
	return brew_runtime.array_value(artifacts.map(test_formulae_artifact_boundary(it)))
}

// Ruby method `no_diff?(formula, git_ref)` at line 227.
pub fn ruby_test_formulae_l227_d12_no_diff(args ...brew_runtime.Value) brew_runtime.Value {
	mut test_formulae := test_formulae_receiver(args) or { return brew_runtime.bool_value(false) }
	if args.len < 3 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(test_formulae.no_diff(test_formulae_formula_from_value(args[1]), args[2].as_string()))
}

// Ruby method `local_bottle_hash(formula, bottle_dir:)` at line 242.
pub fn ruby_test_formulae_l242_d13_local_bottle_hash(args ...brew_runtime.Value) brew_runtime.Value {
	test_formulae := test_formulae_receiver(args) or { return test_formulae_error('ArgumentError', err.msg()) }
	if args.len < 2 {
		return test_formulae_nil()
	}
	directory := if args.len > 2 { args[2].as_string() } else { os.getwd() }
	if value := test_formulae.local_bottle_hash(args[1].as_string(), directory) {
		return test_formulae_any_to_value(value)
	}
	return test_formulae_nil()
}

// Ruby method `artifact_cache_valid?(formula, formulae_dependents: false)` at line 249.
pub fn ruby_test_formulae_l249_d14_artifact_cache_valid(args ...brew_runtime.Value) brew_runtime.Value {
	mut test_formulae := test_formulae_receiver(args) or { return brew_runtime.bool_value(false) }
	if args.len < 2 {
		return brew_runtime.bool_value(false)
	}
	dependents := args.len > 2 && (args[2].as_bool() or { false })
	return brew_runtime.bool_value(test_formulae.artifact_cache_valid(test_formulae_formula_from_value(args[1]), dependents))
}

// Ruby method `bottle_glob(formula_name, bottle_dir = Pathname.pwd, ext = ".tar.gz", bottle_tag: Utils::Bottles.tag.to_s)` at line 281.
pub fn ruby_test_formulae_l281_d15_bottle_glob(args ...brew_runtime.Value) brew_runtime.Value {
	test_formulae := test_formulae_receiver(args) or { return test_formulae_error('ArgumentError', err.msg()) }
	if args.len < 2 {
		return brew_runtime.string_array_value([])
	}
	directory := if args.len > 2 { args[2].as_string() } else { os.getwd() }
	extension := if args.len > 3 { args[3].as_string() } else { '.tar.gz' }
	tag := if args.len > 4 { args[4].as_string() } else { test_formulae.bottle_tag }
	return brew_runtime.string_array_value(test_formulae.bottle_glob(args[1].as_string(), directory, extension, tag))
}

// Ruby method `install_formula_from_bottle!(formula_name, testing_formulae_dependents:, dry_run:,` at line 293.
pub fn ruby_test_formulae_l293_d16_install_formula_from_bottle(args ...brew_runtime.Value) brew_runtime.Value {
	mut test_formulae := test_formulae_receiver(args) or { return test_formulae_error('ArgumentError', err.msg()) }
	if args.len < 2 {
		return test_formulae_error('ArgumentError', 'formula name is required')
	}
	dependents := args.len > 2 && (args[2].as_bool() or { false })
	dry_run := args.len > 3 && (args[3].as_bool() or { false })
	directory := if args.len > 4 { args[4].as_string() } else { os.getwd() }
	installed := test_formulae.install_formula_from_bottle(args[1].as_string(), dependents, dry_run, directory) or { return test_formulae_error('RuntimeError', err.msg()) }
	return brew_runtime.bool_value(installed)
}

// Ruby method `bottled?(formula, no_older_versions: false)` at line 342.
pub fn ruby_test_formulae_l342_d17_bottled(args ...brew_runtime.Value) brew_runtime.Value {
	test_formulae := test_formulae_receiver(args) or { return brew_runtime.bool_value(false) }
	if args.len < 2 {
		return brew_runtime.bool_value(false)
	}
	no_older := args.len > 2 && (args[2].as_bool() or { false })
	return brew_runtime.bool_value(test_formulae.bottled(test_formulae_formula_from_value(args[1]), no_older))
}

// Ruby method `bottled_or_built?(formula, built_formulae, no_older_versions: false)` at line 364.
pub fn ruby_test_formulae_l364_d18_bottled_or_built(args ...brew_runtime.Value) brew_runtime.Value {
	test_formulae := test_formulae_receiver(args) or { return brew_runtime.bool_value(false) }
	if args.len < 3 {
		return brew_runtime.bool_value(false)
	}
	built := args[2].as_string_array() or { []string{} }
	no_older := args.len > 3 && (args[3].as_bool() or { false })
	return brew_runtime.bool_value(test_formulae.bottled_or_built(test_formulae_formula_from_value(args[1]), built, no_older))
}

// Ruby method `downloads_using_homebrew_curl?(formula)` at line 369.
pub fn ruby_test_formulae_l369_d19_downloads_using_homebrew_curl(args ...brew_runtime.Value) brew_runtime.Value {
	test_formulae := test_formulae_receiver(args) or { return brew_runtime.bool_value(false) }
	if args.len < 2 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(test_formulae.downloads_using_homebrew_curl(test_formulae_formula_from_value(args[1])))
}

// Ruby method `install_curl_if_needed(formula)` at line 378.
pub fn ruby_test_formulae_l378_d20_install_curl_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	mut test_formulae := test_formulae_receiver(args) or { return test_formulae_error('ArgumentError', err.msg()) }
	if args.len > 1 {
		test_formulae.install_curl_if_needed(test_formulae_formula_from_value(args[1]))
	}
	return test_formulae_nil()
}

// Ruby method `install_mercurial_if_needed(deps, reqs)` at line 386.
pub fn ruby_test_formulae_l386_d21_install_mercurial_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	mut test_formulae := test_formulae_receiver(args) or { return test_formulae_error('ArgumentError', err.msg()) }
	dependencies := if args.len > 1 { test_formulae_dependencies_from_value(args[1]) } else { [] }
	requirements := if args.len > 2 { test_formulae_dependencies_from_value(args[2]) } else { [] }
	test_formulae.install_mercurial_if_needed(dependencies, requirements)
	return test_formulae_nil()
}

// Ruby method `install_subversion_if_needed(deps, reqs)` at line 394.
pub fn ruby_test_formulae_l394_d22_install_subversion_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	mut test_formulae := test_formulae_receiver(args) or { return test_formulae_error('ArgumentError', err.msg()) }
	dependencies := if args.len > 1 { test_formulae_dependencies_from_value(args[1]) } else { [] }
	requirements := if args.len > 2 { test_formulae_dependencies_from_value(args[2]) } else { [] }
	test_formulae.install_subversion_if_needed(dependencies, requirements)
	return test_formulae_nil()
}

// Ruby method `skipped(formula_name, reason)` at line 402.
pub fn ruby_test_formulae_l402_d23_skipped(args ...brew_runtime.Value) brew_runtime.Value {
	mut test_formulae := test_formulae_receiver(args) or { return test_formulae_error('ArgumentError', err.msg()) }
	if args.len < 3 {
		return test_formulae_error('ArgumentError', 'skipped requires a formula and reason')
	}
	test_formulae.skipped(args[1].as_string(), args[2].as_string())
	return test_formulae_nil()
}

// Ruby method `failed(formula_name, reason)` at line 413.
pub fn ruby_test_formulae_l413_d24_failed(args ...brew_runtime.Value) brew_runtime.Value {
	mut test_formulae := test_formulae_receiver(args) or { return test_formulae_error('ArgumentError', err.msg()) }
	if args.len < 3 {
		return test_formulae_error('ArgumentError', 'failed requires a formula and reason')
	}
	test_formulae.failed(args[1].as_string(), args[2].as_string())
	return test_formulae_nil()
}

// Ruby method `unsatisfied_requirements_messages(formula)` at line 424.
pub fn ruby_test_formulae_l424_d25_unsatisfied_requirements_messages(args ...brew_runtime.Value) brew_runtime.Value {
	test_formulae := test_formulae_receiver(args) or { return test_formulae_error('ArgumentError', err.msg()) }
	if args.len > 1 {
		if message := test_formulae.unsatisfied_requirements_messages(test_formulae_formula_from_value(args[1])) {
			return brew_runtime.string_value(message)
		}
	}
	return test_formulae_nil()
}

// Ruby method `previous_run_artifact_specifier` at line 435.
pub fn ruby_test_formulae_l435_d26_previous_run_artifact_specifier(args ...brew_runtime.Value) brew_runtime.Value {
	test_formulae := test_formulae_receiver(args) or { return test_formulae_error('ArgumentError', err.msg()) }
	value := test_formulae.previous_run_artifact_specifier() or {
		return test_formulae_error('NotImplementedError', err.msg())
	}
	return brew_runtime.string_value(value)
}

// Ruby method `cleanup_during!(keep_formulae = [], args:)` at line 440.
pub fn ruby_test_formulae_l440_d27_cleanup_during(args ...brew_runtime.Value) brew_runtime.Value {
	mut test_formulae := test_formulae_receiver(args) or { return test_formulae_error('ArgumentError', err.msg()) }
	keep_formulae := if args.len > 1 { args[1].as_string_array() or { []string{} } } else { [] }
	options_value := if args.len > 2 { args[2] } else { brew_runtime.Value{} }
	options := TestCommandArgs{
		cleanup: (options_value.attributes['cleanup'] or { 'false' }) == 'true'
		local_mode: (options_value.attributes['local'] or { 'false' }) == 'true'
	}
	test_formulae.cleanup_during(keep_formulae, options)
	return test_formulae_nil()
}

// Ruby method `sorted_formulae` at line 491.
pub fn ruby_test_formulae_l491_d28_sorted_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	test_formulae := test_formulae_receiver(args) or { return test_formulae_error('ArgumentError', err.msg()) }
	sorted := test_formulae.sorted_formulae() or { return test_formulae_error('RuntimeError', err.msg()) }
	return brew_runtime.string_array_value(sorted)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "trust"
// 5:
// 6: module Homebrew
// 7:   module TestBot
// 8:     class TestFormulae < Test
// 9:       sig { returns(T::Array[String]) }
// 10:       attr_accessor :skipped_or_failed_formulae
// 11:
// 12:       sig { returns(Pathname) }
// 13:       attr_reader :artifact_cache
// 14:
// 15:       sig { returns(T::Hash[String, T::Array[String]]) }
// 16:       attr_reader :downloaded_artifacts
// 17:
// 18:       sig {
// 19:         params(
// 20:           tap:       T.nilable(Tap),
// 21:           git:       T.nilable(String),
// 22:           dry_run:   T::Boolean,
// 23:           fail_fast: T::Boolean,
// 24:           verbose:   T::Boolean,
// 25:         ).void
// 26:       }
// 27:       def initialize(tap:, git:, dry_run:, fail_fast:, verbose:)
// 28:         super
// 29:
// 30:         @skipped_or_failed_formulae = T.let([], T::Array[String])
// 31:         @artifact_cache = T.let(Pathname.new("artifact-cache"), Pathname)
// 32:         # Let's keep track of the artifacts we've already downloaded
// 33:         # to avoid repeatedly trying to download the same thing.
// 34:         @downloaded_artifacts = T.let(Hash.new { |h, k| h[k] = [] }, T::Hash[String, T::Array[String]])
// 35:         @testing_formulae = T.let([], T::Array[String])
// 36:         @tested_formulae = T.let([], T::Array[String])
// 37:       end
// 38:
// 39:       sig { params(artifact_pattern: String, dry_run: T::Boolean).void }
// 40:       def download_artifacts_from_previous_run!(artifact_pattern, dry_run:)
// 41:         return if dry_run
// 42:         return if GitHub::API.credentials_type == :none
// 43:         return if (sha = previous_github_sha).blank?
// 44:
// 45:         pull_number = github_event_payload&.dig("pull_request", "number")
// 46:         return if pull_number.blank?
// 47:
// 48:         github_repository = ENV.fetch("GITHUB_REPOSITORY")
// 49:         owner, repo = *github_repository.split("/")
// 50:         raise "github_repository #{github_repository} is invalid" if owner.nil? || repo.nil?
// 51:
// 52:         pr_labels = GitHub.pull_request_labels(owner, repo, pull_number)
// 53:         # Also disable bottle cache for PRs modifying workflows to avoid cache poisoning.
// 54:         return if pr_labels.include?("CI-no-bottle-cache") || pr_labels.include?("workflows")
// 55:
// 56:         variables = {
// 57:           owner:,
// 58:           repo:,
// 59:           commit: sha,
// 60:         }
// 61:
// 62:         response = GitHub::API.open_graphql(GRAPHQL_QUERY, variables:)
// 63:         check_suite_nodes = response.dig("repository", "object", "checkSuites", "nodes")
// 64:         return if check_suite_nodes.blank?
// 65:
// 66:         wanted_artifacts = artifact_metadata(check_suite_nodes, github_repository, "pull_request",
// 67:                                              "CI", "conclusion", artifact_pattern)
// 68:         wanted_artifacts_pattern = artifact_pattern
// 69:         if wanted_artifacts.empty?
// 70:           # If we didn't find the artifacts that we wanted, fall back to the `event_payload` artifact.
// 71:           wanted_artifacts = artifact_metadata(check_suite_nodes, github_repository, "pull_request_target",
// 72:                                                "Triage tasks", "upload-metadata", "event_payload")
// 73:           wanted_artifacts_pattern = "event_payload"
// 74:         end
// 75:         return if wanted_artifacts.empty?
// 76:
// 77:         if (attempted_artifact = wanted_artifacts.find do |artifact|
// 78:               # Hash value must exist due to the hash having a default value of an empty array.
// 79:               T.must(@downloaded_artifacts[sha]).include?(artifact.fetch("name"))
// 80:             end)
// 81:           opoo "Already tried #{attempted_artifact.fetch("name")} from #{sha}, giving up"
// 82:           return
// 83:         end
// 84:
// 85:         cached_event_json&.unlink if File.fnmatch?(wanted_artifacts_pattern, "event_payload", File::FNM_EXTGLOB)
// 86:
// 87:         require "utils/github/artifacts"
// 88:
// 89:         ohai "Downloading artifacts matching pattern #{wanted_artifacts_pattern} from #{sha}"
// 90:         artifact_cache.mkpath
// 91:         artifact_cache.cd do
// 92:           wanted_artifacts.each do |artifact|
// 93:             name = artifact.fetch("name")
// 94:             ohai "Downloading artifact #{name} from #{sha}"
// 95:             # Hash value must exist due to the hash having a default value of an empty array.
// 96:             T.must(@downloaded_artifacts[sha]) << name
// 97:
// 98:             download_url = artifact.fetch("archive_download_url")
// 99:             artifact_id = artifact.fetch("id")
// 100:             GitHub.download_artifact(download_url, artifact_id.to_s)
// 101:           end
// 102:         end
// 103:
// 104:         return if wanted_artifacts_pattern == artifact_pattern
// 105:
// 106:         # If we made it here, then we downloaded an `event_payload` artifact.
// 107:         # We can now use this `event_payload` artifact to attempt to download the artifact we wanted.
// 108:         download_artifacts_from_previous_run!(artifact_pattern, dry_run:)
// 109:       rescue GitHub::API::AuthenticationFailedError => e
// 110:         opoo e
// 111:       end
// 112:
// 113:       protected
// 114:
// 115:       sig { returns(T::Hash[String, String]) }
// 116:       def require_current_tap_trust_env
// 117:         { "HOMEBREW_REQUIRE_TAP_TRUST" => "1" }
// 118:       end
// 119:
// 120:       sig { returns(T.nilable(Pathname)) }
// 121:       def cached_event_json
// 122:         return unless (event_json = artifact_cache/"event.json").exist?
// 123:
// 124:         event_json
// 125:       end
// 126:
// 127:       sig { returns(T.nilable(T::Hash[String, T.untyped])) }
// 128:       def github_event_payload
// 129:         return if (github_event_path = ENV.fetch("GITHUB_EVENT_PATH", nil)).blank?
// 130:
// 131:         JSON.parse(File.read(github_event_path))
// 132:       end
// 133:
// 134:       sig { returns(T.nilable(String)) }
// 135:       def previous_github_sha
// 136:         return if tap.blank?
// 137:         return unless repository.directory?
// 138:         return unless GitHub::Actions.env_set?
// 139:         return if (payload = github_event_payload).blank?
// 140:
// 141:         head_repo_owner = payload.dig("pull_request", "head", "repo", "owner", "login")
// 142:         head_from_fork = head_repo_owner != ENV.fetch("GITHUB_REPOSITORY_OWNER")
// 143:         return if head_from_fork && head_repo_owner != "BrewTestBot"
// 144:
// 145:         # If we have a cached event payload, then we failed to get the artifact we wanted
// 146:         # from `GITHUB_EVENT_PATH`, so use the cached payload to check for a SHA1.
// 147:         cached_json = cached_event_json
// 148:         event_payload = JSON.parse(cached_json.read) if cached_json
// 149:         event_payload ||= payload
// 150:
// 151:         event_payload.fetch("before", nil)
// 152:       end
// 153:
// 154:       sig {
// 155:         params(
// 156:           check_suite_nodes: T::Array[T::Hash[String, T.untyped]],
// 157:           repo:              String,
// 158:           event_name:        String,
// 159:           workflow_name:     String,
// 160:           check_run_name:    String,
// 161:           artifact_pattern:  String,
// 162:         ).returns(T::Array[T::Hash[String, T.untyped]])
// 163:       }
// 164:       def artifact_metadata(check_suite_nodes, repo, event_name, workflow_name, check_run_name, artifact_pattern)
// 165:         candidate_nodes = check_suite_nodes.select do |node|
// 166:           next false if node.fetch("status") != "COMPLETED"
// 167:
// 168:           workflow_run = node.fetch("workflowRun")
// 169:           next false if workflow_run.blank?
// 170:           next false if workflow_run.fetch("event") != event_name
// 171:           next false if workflow_run.dig("workflow", "name") != workflow_name
// 172:
// 173:           check_run_nodes = node.dig("checkRuns", "nodes")
// 174:           next false if check_run_nodes.blank?
// 175:
// 176:           check_run_nodes.any? do |check_run_node|
// 177:             check_run_node.fetch("name") == check_run_name && check_run_node.fetch("status") == "COMPLETED"
// 178:           end
// 179:         end
// 180:         return [] if candidate_nodes.blank?
// 181:
// 182:         run_id = candidate_nodes.max_by { |node| Time.parse(node.fetch("updatedAt")) }
// 183:                                 &.dig("workflowRun", "databaseId")
// 184:         return [] if run_id.blank?
// 185:
// 186:         url = GitHub.url_to("repos", repo, "actions", "runs", run_id, "artifacts")
// 187:         response = GitHub::API.open_rest(url)
// 188:         return [] if response.fetch("total_count").zero?
// 189:
// 190:         artifacts = response.fetch("artifacts")
// 191:         artifacts.select do |artifact|
// 192:           File.fnmatch?(artifact_pattern, artifact.fetch("name"), File::FNM_EXTGLOB)
// 193:         end
// 194:       end
// 195:
// 196:       GRAPHQL_QUERY = <<~GRAPHQL
// 197:         query ($owner: String!, $repo: String!, $commit: GitObjectID!) {
// 198:           repository(owner: $owner, name: $repo) {
// 199:             object(oid: $commit) {
// 200:               ... on Commit {
// 201:                 checkSuites(last: 100) {
// 202:                   nodes {
// 203:                     status
// 204:                     updatedAt
// 205:                     workflowRun {
// 206:                       databaseId
// 207:                       event
// 208:                       workflow {
// 209:                         name
// 210:                       }
// 211:                     }
// 212:                     checkRuns(last: 100) {
// 213:                       nodes {
// 214:                         name
// 215:                         status
// 216:                       }
// 217:                     }
// 218:                   }
// 219:                 }
// 220:               }
// 221:             }
// 222:           }
// 223:         }
// 224:       GRAPHQL
// 225:
// 226:       sig { params(formula: Formula, git_ref: String).returns(T::Boolean) }
// 227:       def no_diff?(formula, git_ref)
// 228:         return false unless repository.directory?
// 229:
// 230:         @fetched_refs ||= T.let([], T.nilable(T::Array[String]))
// 231:         if @fetched_refs.exclude?(git_ref)
// 232:           test git.to_s, "-C", repository.to_s, "fetch", "origin", git_ref, ignore_failures: true
// 233:           @fetched_refs << git_ref if steps.fetch(-1).passed?
// 234:         end
// 235:
// 236:         relative_formula_path = formula.path.relative_path_from(repository)
// 237:         !!system(git.to_s, "-C", repository.to_s, "diff", "--no-ext-diff", "--quiet", git_ref, "--",
// 238:                  relative_formula_path.to_s)
// 239:       end
// 240:
// 241:       sig { params(formula: String, bottle_dir: Pathname).returns(T.nilable(T::Hash[String, T.untyped])) }
// 242:       def local_bottle_hash(formula, bottle_dir:)
// 243:         return unless (local_bottle_json = bottle_glob(formula, bottle_dir, ".json").first)
// 244:
// 245:         JSON.parse(local_bottle_json.read)
// 246:       end
// 247:
// 248:       sig { params(formula: Formula, formulae_dependents: T::Boolean).returns(T::Boolean) }
// 249:       def artifact_cache_valid?(formula, formulae_dependents: false)
// 250:         sha = if formulae_dependents
// 251:           previous_github_sha
// 252:         else
// 253:           local_bottle_hash(formula.name, bottle_dir: artifact_cache)
// 254:             &.dig(formula.name, "formula", "tap_git_revision")
// 255:         end
// 256:
// 257:         return false if sha.blank?
// 258:         return false unless no_diff?(formula, sha)
// 259:
// 260:         recursive_dependencies = if formulae_dependents
// 261:           formula.recursive_dependencies
// 262:         else
// 263:           formula.recursive_dependencies do |_, dep|
// 264:             next Dependable::PRUNE if dep.build? || dep.test?
// 265:           end
// 266:         end
// 267:
// 268:         recursive_dependencies.all? do |dep|
// 269:           no_diff?(dep.to_formula, sha)
// 270:         end
// 271:       end
// 272:
// 273:       sig {
// 274:         params(
// 275:           formula_name: String,
// 276:           bottle_dir:   Pathname,
// 277:           ext:          String,
// 278:           bottle_tag:   String,
// 279:         ).returns(T::Array[Pathname])
// 280:       }
// 281:       def bottle_glob(formula_name, bottle_dir = Pathname.pwd, ext = ".tar.gz", bottle_tag: Utils::Bottles.tag.to_s)
// 282:         bottle_dir.glob("#{formula_name}--*.#{bottle_tag}.bottle*#{ext}")
// 283:       end
// 284:
// 285:       sig {
// 286:         params(
// 287:           formula_name:                String,
// 288:           testing_formulae_dependents: T::Boolean,
// 289:           dry_run:                     T::Boolean,
// 290:           bottle_dir:                  Pathname,
// 291:         ).returns(T::Boolean)
// 292:       }
// 293:       def install_formula_from_bottle!(formula_name, testing_formulae_dependents:, dry_run:,
// 294:                                        bottle_dir: Pathname.pwd)
// 295:         bottle_filename = bottle_glob(formula_name, bottle_dir).first
// 296:         if bottle_filename.blank?
// 297:           if testing_formulae_dependents && !dry_run
// 298:             raise "Failed to find bottle for '#{formula_name}'."
// 299:           elsif !dry_run
// 300:             return false
// 301:           end
// 302:
// 303:           bottle_filename = "$BOTTLE_FILENAME"
// 304:         end
// 305:
// 306:         install_args = []
// 307:         install_args += %w[--ignore-dependencies --skip-post-install] if testing_formulae_dependents
// 308:         test "brew", "install", *install_args, bottle_filename.to_s
// 309:         install_step = steps.fetch(-1)
// 310:
// 311:         if !dry_run && !testing_formulae_dependents && install_step.passed?
// 312:           bottle_hash = local_bottle_hash(formula_name, bottle_dir:)
// 313:           bottle_revision = bottle_hash&.dig(formula_name, "formula", "tap_git_revision")
// 314:           bottle_header = "Bottle cache hit"
// 315:           bottle_commit_details = if @fetched_refs&.include?(bottle_revision)
// 316:             Utils.safe_popen_read(git, "-C", repository, "show", "--format=reference", bottle_revision)
// 317:           else
// 318:             bottle_revision
// 319:           end
// 320:           bottle_message = "Bottle for #{formula_name} built at #{bottle_commit_details}".strip
// 321:
// 322:           if GitHub::Actions.env_set?
// 323:             puts GitHub::Actions::Annotation.new(
// 324:               :notice,
// 325:               bottle_message,
// 326:               file:  bottle_hash&.dig(formula_name, "formula", "tap_git_path"),
// 327:               title: bottle_header,
// 328:             )
// 329:           else
// 330:             ohai bottle_header, bottle_message
// 331:           end
// 332:         end
// 333:         return install_step.passed? if !testing_formulae_dependents || !install_step.passed?
// 334:
// 335:         test "brew", "unlink", formula_name
// 336:         puts
// 337:
// 338:         install_step.passed?
// 339:       end
// 340:
// 341:       sig { params(formula: Formula, no_older_versions: T::Boolean).returns(T::Boolean) }
// 342:       def bottled?(formula, no_older_versions: false)
// 343:         # If a formula has an `:all` bottle, then all its dependencies have
// 344:         # to be bottled too for us to use it. We only need to recurse
// 345:         # up the dep tree when we encounter an `:all` bottle because
// 346:         # a formula is not bottled unless its dependencies are.
// 347:         if formula.bottle_specification.tag?(Utils::Bottles.tag(:all))
// 348:           formula.deps.all? do |dep|
// 349:             bottle_no_older_versions = no_older_versions && (!dep.test? || dep.build?)
// 350:             bottled?(dep.to_formula, no_older_versions: bottle_no_older_versions)
// 351:           end
// 352:         else
// 353:           formula.bottle_specification.tag?(Utils::Bottles.tag, no_older_versions:)
// 354:         end
// 355:       end
// 356:
// 357:       sig {
// 358:         params(
// 359:           formula:           Formula,
// 360:           built_formulae:    T::Enumerable[String],
// 361:           no_older_versions: T::Boolean,
// 362:         ).returns(T::Boolean)
// 363:       }
// 364:       def bottled_or_built?(formula, built_formulae, no_older_versions: false)
// 365:         bottled?(formula, no_older_versions:) || built_formulae.include?(formula.full_name)
// 366:       end
// 367:
// 368:       sig { params(formula: Formula).returns(T::Boolean) }
// 369:       def downloads_using_homebrew_curl?(formula)
// 370:         [:stable, :head].any? do |spec_name|
// 371:           next false unless (spec = formula.public_send(spec_name))
// 372:
// 373:           spec.using == :homebrew_curl || spec.resources.values.any? { |r| r.using == :homebrew_curl }
// 374:         end
// 375:       end
// 376:
// 377:       sig { params(formula: Formula).void }
// 378:       def install_curl_if_needed(formula)
// 379:         return unless downloads_using_homebrew_curl?(formula)
// 380:
// 381:         test "brew", "install", "curl",
// 382:              env: { "HOMEBREW_DEVELOPER" => nil }
// 383:       end
// 384:
// 385:       sig { params(deps: T::Array[Dependency], reqs: T::Array[Requirement]).void }
// 386:       def install_mercurial_if_needed(deps, reqs)
// 387:         return if (deps | reqs).none? { |d| d.name == "mercurial" && d.build? }
// 388:
// 389:         test "brew", "install", "mercurial",
// 390:              env:  { "HOMEBREW_DEVELOPER" => nil }
// 391:       end
// 392:
// 393:       sig { params(deps: T::Array[Dependency], reqs: T::Array[Requirement]).void }
// 394:       def install_subversion_if_needed(deps, reqs)
// 395:         return if (deps | reqs).none? { |d| d.name == "subversion" && d.build? }
// 396:
// 397:         test "brew", "install", "subversion",
// 398:              env:  { "HOMEBREW_DEVELOPER" => nil }
// 399:       end
// 400:
// 401:       sig { params(formula_name: String, reason: String).void }
// 402:       def skipped(formula_name, reason)
// 403:         @skipped_or_failed_formulae << formula_name
// 404:
// 405:         puts Formatter.headline(
// 406:           "#{Formatter.warning("SKIPPED")} #{Formatter.identifier(formula_name)}",
// 407:           color: :yellow,
// 408:         )
// 409:         opoo reason
// 410:       end
// 411:
// 412:       sig { params(formula_name: String, reason: String).void }
// 413:       def failed(formula_name, reason)
// 414:         @skipped_or_failed_formulae << formula_name
// 415:
// 416:         puts Formatter.headline(
// 417:           "#{Formatter.error("FAILED")} #{Formatter.identifier(formula_name)}",
// 418:           color: :red,
// 419:         )
// 420:         onoe reason
// 421:       end
// 422:
// 423:       sig { params(formula: Formula).returns(T.nilable(String)) }
// 424:       def unsatisfied_requirements_messages(formula)
// 425:         f = Formulary.factory(formula.full_name)
// 426:         fi = FormulaInstaller.new(f, build_bottle: true)
// 427:
// 428:         unsatisfied_requirements, = fi.expand_requirements
// 429:         return if unsatisfied_requirements.blank?
// 430:
// 431:         unsatisfied_requirements.values.flatten.map(&:message).join("\n").presence
// 432:       end
// 433:
// 434:       sig { returns(String) }
// 435:       def previous_run_artifact_specifier
// 436:         raise NotImplementedError, "#{self.class} must implement previous_run_artifact_specifier in extend/os."
// 437:       end
// 438:
// 439:       sig { params(keep_formulae: T::Array[String], args: Homebrew::Cmd::TestBotCmd::Args).void }
// 440:       def cleanup_during!(keep_formulae = [], args:)
// 441:         return unless cleanup?(args)
// 442:         return unless HOMEBREW_CACHE.exist?
// 443:
// 444:         free_gb = Utils.safe_popen_read({ "BLOCKSIZE" => (1000 ** 3).to_s }, "df", HOMEBREW_CACHE.to_s)
// 445:                        .lines
// 446:                        .fetch(1) # HOMEBREW_CACHE
// 447:                        .split[3] # free GB
// 448:                        .to_i
// 449:         return if free_gb > 10
// 450:
// 451:         test_header(:TestFormulae, method: :cleanup_during!)
// 452:
// 453:         # HOMEBREW_LOGS can be a subdirectory of HOMEBREW_CACHE.
// 454:         # Preserve the logs in that case.
// 455:         logs_are_in_cache = HOMEBREW_LOGS.ascend { |path| break true if path == HOMEBREW_CACHE }
// 456:         should_save_logs = logs_are_in_cache && HOMEBREW_LOGS.exist?
// 457:
// 458:         test "mv", HOMEBREW_LOGS.to_s, (tmpdir = Dir.mktmpdir) if should_save_logs
// 459:         FileUtils.chmod_R "u+rw", HOMEBREW_CACHE, force: true
// 460:         test "rm", "-rf", HOMEBREW_CACHE.to_s
// 461:         if should_save_logs
// 462:           FileUtils.mkdir_p HOMEBREW_LOGS.parent
// 463:           test "mv", "#{tmpdir}/#{HOMEBREW_LOGS.basename}", HOMEBREW_LOGS.to_s
// 464:         end
// 465:
// 466:         if @cleaned_up_during.blank?
// 467:           @cleaned_up_during = T.let(true, T.nilable(T::Boolean))
// 468:           return
// 469:         end
// 470:
// 471:         installed_formulae = Utils.safe_popen_read("brew", "list", "--full-name", "--formulae").split("\n")
// 472:         uninstallable_formulae = installed_formulae - keep_formulae
// 473:
// 474:         @installed_formulae_deps ||= T.let(
// 475:           Hash.new do |h, formula|
// 476:             h[formula] = Utils.safe_popen_read("brew", "deps", "--full-name", formula).split("\n")
// 477:           end,
// 478:           T.nilable(T::Hash[String, T::Array[String]]),
// 479:         )
// 480:
// 481:         uninstallable_formulae.reject! do |name|
// 482:           keep_formulae.any? { |f| @installed_formulae_deps[f].include?(name) }
// 483:         end
// 484:
// 485:         return if uninstallable_formulae.blank?
// 486:
// 487:         test "brew", "uninstall", "--force", "--ignore-dependencies", *uninstallable_formulae
// 488:       end
// 489:
// 490:       sig { returns(T::Array[String]) }
// 491:       def sorted_formulae
// 492:         changed_formulae_dependents = {}
// 493:
// 494:         @testing_formulae.each do |formula|
// 495:           formula_dependencies =
// 496:             Utils.popen_read("brew", "deps", "--full-name",
// 497:                              "--include-build",
// 498:                              "--include-test", formula)
// 499:                  .split("\n")
// 500:           # deps can fail if deps are not tapped
// 501:           unless $CHILD_STATUS.success?
// 502:             Formulary.factory(formula).recursive_dependencies
// 503:             # If we haven't got a TapFormulaUnavailableError, then something else is broken
// 504:             raise "Failed to determine dependencies for '#{formula}'."
// 505:           end
// 506:
// 507:           unchanged_dependencies = formula_dependencies - @testing_formulae
// 508:           changed_dependencies = formula_dependencies - unchanged_dependencies
// 509:           changed_dependencies.each do |changed_formula|
// 510:             changed_formulae_dependents[changed_formula] ||= 0
// 511:             changed_formulae_dependents[changed_formula] += 1
// 512:           end
// 513:         end
// 514:
// 515:         changed_formulae = changed_formulae_dependents.sort do |a1, a2|
// 516:           a2[1].to_i <=> a1[1].to_i
// 517:         end
// 518:         changed_formulae.map!(&:first)
// 519:         unchanged_formulae = @testing_formulae - changed_formulae
// 520:         changed_formulae + unchanged_formulae
// 521:       end
// 522:     end
// 523:   end
// 524: end
