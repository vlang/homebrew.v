module homebrew

import brew_runtime

// Translated from Homebrew/brew `formula_versions.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(formula)` at line 21.
pub fn ruby_formula_versions_l21_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `rev_list(branch, &_block)` at line 34.
pub fn ruby_formula_versions_l34_d2_rev_list(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rev_list', ...args)
}

// Ruby method `formula_at_revision(revision, formula_relative_path = relative_path, &_block)` at line 53.
pub fn ruby_formula_versions_l53_d3_formula_at_revision(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_at_revision', ...args)
}

// Ruby attr_reader `attr_reader :name, :relative_path` at line 76.
pub fn ruby_formula_versions_l76_d4_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby attr_reader `attr_reader :name, :relative_path` at line 76.
pub fn ruby_formula_versions_l76_d5_relative_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('relative_path', ...args)
}

// Ruby attr_reader `attr_reader :old_relative_path` at line 79.
pub fn ruby_formula_versions_l79_d6_old_relative_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('old_relative_path', ...args)
}

// Ruby attr_reader `attr_reader :path, :repository` at line 82.
pub fn ruby_formula_versions_l82_d7_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('path', ...args)
}

// Ruby attr_reader `attr_reader :path, :repository` at line 82.
pub fn ruby_formula_versions_l82_d8_repository(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('repository', ...args)
}

// Ruby method `file_contents_at_revision(revision, relative_path)` at line 85.
pub fn ruby_formula_versions_l85_d9_file_contents_at_revision(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('file_contents_at_revision', ...args)
}

// Ruby method `nostdout(&block)` at line 94.
pub fn ruby_formula_versions_l94_d10_nostdout(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('nostdout', ...args)
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
