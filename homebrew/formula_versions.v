module homebrew

import ruby
import os

pub struct FormulaVersionsInput {
pub:
	name       string
	tap_path   string
	repository string
	verbose    bool
}

pub struct FormulaVersionsRevision {
pub:
	revision      string
	relative_path string
}

pub struct FormulaVersionsGitRequest {
pub:
	repository string
	arguments  []string
}

pub struct FormulaVersionsLoadRequest {
pub:
	name            string
	path            string
	contents        string
	suppress_stdout bool
}

pub type FormulaVersionsGitRunner = fn (FormulaVersionsGitRequest) !string

pub type FormulaVersionsLoader = fn (FormulaVersionsLoadRequest) !Formula

pub type FormulaVersionsOutputBlock = fn () !ruby.Value

@[heap]
pub struct FormulaVersions {
pub:
	name              string
	path              string
	repository        string
	relative_path     string
	old_relative_path ?string
	verbose           bool
pub mut:
	formula_at_revision_cache    map[string]Formula
	raise_deprecation_exceptions bool
}

fn formula_versions_relative_path(path string, repository string) string {
	normalized_path := os.norm_path(path).replace('\\', '/')
	normalized_repository := os.norm_path(repository).replace('\\', '/').trim_right('/')
	if normalized_path == normalized_repository {
		return '.'
	}
	prefix := '${normalized_repository}/'
	if normalized_path.starts_with(prefix) {
		return normalized_path[prefix.len..]
	}
	path_parts := normalized_path.trim('/').split('/')
	repository_parts := normalized_repository.trim('/').split('/')
	mut common := 0
	for common < path_parts.len && common < repository_parts.len
		&& path_parts[common] == repository_parts[common] {
		common++
	}
	mut relative_parts := []string{}
	for _ in common .. repository_parts.len {
		relative_parts << '..'
	}
	relative_parts << path_parts[common..]
	return if relative_parts.len == 0 { '.' } else { relative_parts.join('/') }
}

fn formula_versions_old_relative_path(relative_path string) ?string {
	parts := relative_path.split('/')
	if parts.len < 3 || parts[0] !in ['HomebrewFormula', 'Formula'] {
		return none
	}
	shard := parts[1]
	if shard != 'lib' && (shard.len != 1 || shard[0] < `a` || shard[0] > `z`) {
		return none
	}
	return '${parts[0]}/${parts[2..].join('/')}'
}

pub fn new_formula_versions(input FormulaVersionsInput) &FormulaVersions {
	relative_path := formula_versions_relative_path(input.tap_path, input.repository)
	return &FormulaVersions{
		name: input.name
		path: input.tap_path
		repository: input.repository
		relative_path: relative_path
		old_relative_path: formula_versions_old_relative_path(relative_path)
		verbose: input.verbose
		formula_at_revision_cache: map[string]Formula{}
	}
}

fn formula_versions_native_git_runner(request FormulaVersionsGitRequest) !string {
	mut command := ['git']
	command << request.arguments
	result := ruby.run_captured_command(command, ruby.CapturedCommandOptions{
		chdir: request.repository
		environment: ruby.environment()
	})!
	if result.exit_code != 0 {
		message := result.stderr.trim_space()
		return error(if message == '' {
			'git ${request.arguments.join(' ')} failed with status ${result.exit_code}'
		} else {
			message
		})
	}
	return result.stdout
}

fn formula_versions_default_loader(request FormulaVersionsLoadRequest) !Formula {
	return formulary_from_contents(request.name, request.path, request.contents, '', '', none, false, []string{}, true, FormularyLoadContext{})
}

pub fn formula_versions_rev_list_with_runner(versions &FormulaVersions, branch string,
	runner FormulaVersionsGitRunner) ![]FormulaVersionsRevision {
	mut paths := [versions.relative_path]
	if old_relative_path := versions.old_relative_path {
		paths << old_relative_path
	}
	mut revisions := []FormulaVersionsRevision{}
	for relative_path in paths {
		output := runner(FormulaVersionsGitRequest{
			repository: versions.repository
			arguments: ['rev-list', '--abbrev-commit', '--remove-empty', branch, '--', relative_path]
		})!
		for line in output.split_into_lines() {
			revision := line.trim_right('\r\n')
			if revision != '' {
				revisions << FormulaVersionsRevision{
					revision: revision
					relative_path: relative_path
				}
			}
		}
	}
	return revisions
}

pub fn (versions &FormulaVersions) rev_list(branch string) ![]FormulaVersionsRevision {
	return formula_versions_rev_list_with_runner(versions, branch, formula_versions_native_git_runner)
}

pub fn formula_versions_file_contents_with_runner(versions &FormulaVersions, revision string,
	relative_path string, runner FormulaVersionsGitRunner) !string {
	return runner(FormulaVersionsGitRequest{
		repository: versions.repository
		arguments: ['cat-file', 'blob', '${revision}:${relative_path}']
	})
}

pub fn (versions &FormulaVersions) file_contents_at_revision(revision string,
	relative_path string) !string {
	return formula_versions_file_contents_with_runner(versions, revision, relative_path, formula_versions_native_git_runner)
}

pub fn formula_versions_formula_at_revision_with_runner(mut versions FormulaVersions,
	revision string, formula_relative_path string, runner FormulaVersionsGitRunner,
	loader FormulaVersionsLoader) ?Formula {
	versions.raise_deprecation_exceptions = true
	defer {
		versions.raise_deprecation_exceptions = false
	}
	if revision in versions.formula_at_revision_cache {
		return versions.formula_at_revision_cache[revision]
	}
	relative_path := if formula_relative_path == '' {
		versions.relative_path
	} else {
		formula_relative_path
	}
	contents := formula_versions_file_contents_with_runner(versions, revision, relative_path, runner) or { return none }
	formula := loader(FormulaVersionsLoadRequest{
		name: versions.name
		path: versions.path
		contents: contents
		suppress_stdout: !versions.verbose
	}) or {
		// We rescue these so that we can skip bad versions and
		// continue walking the history
		return none
	}
	versions.formula_at_revision_cache[revision] = formula
	return formula
}

pub fn (mut versions FormulaVersions) formula_at_revision(revision string,
	formula_relative_path string) ?Formula {
	return formula_versions_formula_at_revision_with_runner(mut versions, revision, formula_relative_path, formula_versions_native_git_runner, formula_versions_default_loader)
}

pub fn formula_versions_nostdout(verbose bool,
	block FormulaVersionsOutputBlock) !ruby.Value {
	if verbose {
		return block()
	}
	mut null_file := os.open_file(os.path_devnull, 'w')!
	saved_stdout := os.fd_dup(1)
	if saved_stdout < 0 {
		null_file.close()
		return error('unable to duplicate stdout')
	}
	flush_stdout()
	if os.fd_dup2(null_file.fd, 1) < 0 {
		os.fd_close(saved_stdout)
		null_file.close()
		return error('unable to redirect stdout')
	}
	defer {
		flush_stdout()
		os.fd_dup2(saved_stdout, 1)
		os.fd_close(saved_stdout)
		null_file.close()
	}
	return block()
}

// Translated from Homebrew/brew `formula_versions.rb`.
