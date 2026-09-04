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
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(formula)` at line 21.
pub fn ruby_formula_versions_l21_d1_initialize(input FormulaVersionsInput) &FormulaVersions {
	return new_formula_versions(input)
}

// Ruby method `rev_list(branch, &_block)` at line 34.
pub fn ruby_formula_versions_l34_d2_rev_list(versions &FormulaVersions,
	branch string) ![]FormulaVersionsRevision {
	return versions.rev_list(branch)
}

// Ruby method `formula_at_revision(revision, formula_relative_path = relative_path, &_block)` at line 53.
pub fn ruby_formula_versions_l53_d3_formula_at_revision(mut versions FormulaVersions,
	revision string, formula_relative_path string) ?Formula {
	return versions.formula_at_revision(revision, formula_relative_path)
}

// Ruby attr_reader `attr_reader :name, :relative_path` at line 76.
pub fn ruby_formula_versions_l76_d4_name(versions &FormulaVersions) string {
	return versions.name
}

// Ruby attr_reader `attr_reader :name, :relative_path` at line 76.
pub fn ruby_formula_versions_l76_d5_relative_path(versions &FormulaVersions) string {
	return versions.relative_path
}

// Ruby attr_reader `attr_reader :old_relative_path` at line 79.
pub fn ruby_formula_versions_l79_d6_old_relative_path(versions &FormulaVersions) ?string {
	return versions.old_relative_path
}

// Ruby attr_reader `attr_reader :path, :repository` at line 82.
pub fn ruby_formula_versions_l82_d7_path(versions &FormulaVersions) string {
	return versions.path
}

// Ruby attr_reader `attr_reader :path, :repository` at line 82.
pub fn ruby_formula_versions_l82_d8_repository(versions &FormulaVersions) string {
	return versions.repository
}

// Ruby method `file_contents_at_revision(revision, relative_path)` at line 85.
pub fn ruby_formula_versions_l85_d9_file_contents_at_revision(versions &FormulaVersions,
	revision string, relative_path string) !string {
	return versions.file_contents_at_revision(revision, relative_path)
}

// Ruby method `nostdout(&block)` at line 94.
pub fn ruby_formula_versions_l94_d10_nostdout(verbose bool,
	block FormulaVersionsOutputBlock) !ruby.Value {
	return formula_versions_nostdout(verbose, block)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "formula"
// 5: require "utils/output"
// 6:
// 7: # Helper class for traversing a formula's previous versions.
// 8: #
// 9: # @api internal
// 10: class FormulaVersions
// 11:   include Context
// 12:   include Utils::Output::Mixin
// 13:
// 14:   IGNORED_EXCEPTIONS = [
// 15:     ArgumentError, NameError, SyntaxError, TypeError, LegacyDSLError,
// 16:     FormulaSpecificationError, FormulaValidationError,
// 17:     ErrorDuringExecution, LoadError, MethodDeprecatedError
// 18:   ].freeze
// 19:
// 20:   sig { params(formula: Formula).void }
// 21:   def initialize(formula)
// 22:     @name = T.let(formula.name, String)
// 23:     @path = T.let(formula.tap_path, Pathname)
// 24:     @repository = T.let(formula.tap!.path, Pathname)
// 25:     @relative_path = T.let(@path.relative_path_from(repository).to_s, String)
// 26:     # Also look at e.g. older homebrew-core paths before sharding.
// 27:     if (match = @relative_path.match(%r{^(HomebrewFormula|Formula)/([a-z]|lib)/(.+)}))
// 28:       @old_relative_path = T.let("#{match[1]}/#{match[3]}", T.nilable(String))
// 29:     end
// 30:     @formula_at_revision = T.let({}, T::Hash[String, Formula])
// 31:   end
// 32:
// 33:   sig { params(branch: String, _block: T.proc.params(revision: String, path: String).void).void }
// 34:   def rev_list(branch, &_block)
// 35:     repository.cd do
// 36:       rev_list_cmd = ["git", "rev-list", "--abbrev-commit", "--remove-empty"]
// 37:       [relative_path, old_relative_path].compact.each do |entry|
// 38:         Utils.popen_read(*rev_list_cmd, branch, "--", entry) do |io|
// 39:           yield io.readline.chomp, entry until io.eof?
// 40:         end
// 41:       end
// 42:     end
// 43:   end
// 44:
// 45:   sig {
// 46:     type_parameters(:U)
// 47:       .params(
// 48:         revision:              String,
// 49:         formula_relative_path: String,
// 50:         _block:                T.proc.params(arg0: Formula).returns(T.type_parameter(:U)),
// 51:       ).returns(T.nilable(T.type_parameter(:U)))
// 52:   }
// 53:   def formula_at_revision(revision, formula_relative_path = relative_path, &_block)
// 54:     Homebrew.raise_deprecation_exceptions = true
// 55:
// 56:     yield @formula_at_revision[revision] ||= begin
// 57:       contents = file_contents_at_revision(revision, formula_relative_path)
// 58:       nostdout { Formulary.from_contents(name, path, contents, ignore_errors: true) }
// 59:     end
// 60:   rescue *IGNORED_EXCEPTIONS => e
// 61:     require "utils/backtrace"
// 62:
// 63:     # We rescue these so that we can skip bad versions and
// 64:     # continue walking the history
// 65:     odebug "#{e} in #{name} at revision #{revision}", Utils::Backtrace.clean(e)
// 66:     nil
// 67:   rescue FormulaUnavailableError
// 68:     nil
// 69:   ensure
// 70:     Homebrew.raise_deprecation_exceptions = false
// 71:   end
// 72:
// 73:   private
// 74:
// 75:   sig { returns(String) }
// 76:   attr_reader :name, :relative_path
// 77:
// 78:   sig { returns(T.nilable(String)) }
// 79:   attr_reader :old_relative_path
// 80:
// 81:   sig { returns(Pathname) }
// 82:   attr_reader :path, :repository
// 83:
// 84:   sig { params(revision: String, relative_path: String).returns(String) }
// 85:   def file_contents_at_revision(revision, relative_path)
// 86:     repository.cd { Utils.popen_read("git", "cat-file", "blob", "#{revision}:#{relative_path}") }
// 87:   end
// 88:
// 89:   sig {
// 90:     type_parameters(:U)
// 91:       .params(block: T.proc.returns(T.type_parameter(:U)))
// 92:       .returns(T.type_parameter(:U))
// 93:   }
// 94:   def nostdout(&block)
// 95:     if verbose?
// 96:       yield
// 97:     else
// 98:       redirect_stdout(File::NULL, &block)
// 99:     end
// 100:   end
// 101: end
