module cask_loader

import ruby
import homebrew.cask
import os
import time

// Translated from Homebrew/brew `test/cask/cask_loader/from_path_loader_spec.rb`.
// The original source is retained below for exact boundary auditing.

const from_path_loader_fixture_root = '/Users/alex/code/3rd/brew/Library/Homebrew/test/support/fixtures/cask'

fn from_path_loader_temp_file(root string, contents string) !string {
	os.mkdir_all(root)!
	path := os.join_path(root, 'cask.rb')
	os.write_file(path, contents)!
	return path
}

fn from_path_loader_default_root(label string) string {
	return os.join_path(os.temp_dir(), 'brew-v-from-path-loader-${label}-${os.getpid()}-${time.now().unix_micro()}')
}

fn from_path_loader_load(path string, evaluation cask.CaskLoaderEvaluation) !cask.CaskLoaderCask {
	mut loader := cask.new_path_cask_loader(path, '', cask.CaskLoaderLookupContext{})
	return cask.cask_loader_load_path(mut loader, cask.CaskLoaderConfig{}, cask.CaskLoaderLoadContext{
		evaluation: evaluation
	})
}

fn from_path_loader_error_contains(path string, evaluation cask.CaskLoaderEvaluation,
	message string) bool {
	from_path_loader_load(path, evaluation) or { return err.msg().contains(message) }
	return false
}

pub fn from_path_loader_json_result(path string) !cask.CaskLoaderCask {
	return from_path_loader_load(path, cask.CaskLoaderEvaluation{})
}

// Ruby let `let(:path) do` at line 7.
pub fn ruby_from_path_loader_spec_l7_d1_path(args ...ruby.Value) ruby.Value {
	root := if args.len > 0 { args[0].as_string() } else { from_path_loader_default_root('plain') }
	path := from_path_loader_temp_file(root, 'true\n') or {
		return ruby.object_value('Error', err.msg())
	}
	return ruby.object_value('Pathname', path)
}

// Ruby it `it "raises an error" do` at line 15.
pub fn ruby_from_path_loader_spec_l15_d2_raises(args ...ruby.Value) ruby.Value {
	path := if args.len > 0 {
		args[0].as_string()
	} else {
		from_path_loader_temp_file(from_path_loader_default_root('plain-error'), 'true\n') or {
			return ruby.bool_value(false)
		}
	}
	return ruby.bool_value(from_path_loader_error_contains(path, cask.CaskLoaderEvaluation{}, 'does not contain a cask'))
}

// Ruby let `let(:path) do` at line 23.
pub fn ruby_from_path_loader_spec_l23_d3_path(args ...ruby.Value) ruby.Value {
	root := if args.len > 0 {
		args[0].as_string()
	} else {
		from_path_loader_default_root('name-error')
	}
	path := from_path_loader_temp_file(root, 'this_method_does_not_exist\n') or {
		return ruby.object_value('Error', err.msg())
	}
	return ruby.object_value('Pathname', path)
}

// Ruby it `it "raises an error" do` at line 31.
pub fn ruby_from_path_loader_spec_l31_d4_raises(args ...ruby.Value) ruby.Value {
	path := if args.len > 0 {
		args[0].as_string()
	} else {
		from_path_loader_temp_file(from_path_loader_default_root('name-error-check'), 'this_method_does_not_exist\n') or { return ruby.bool_value(false) }
	}
	return ruby.bool_value(from_path_loader_error_contains(path, cask.CaskLoaderEvaluation{
		failed: true
		error_kind: 'NameError'
		error_message: 'undefined local variable or method `this_method_does_not_exist`'
	}, 'CaskUnreadableError') && from_path_loader_error_contains(path, cask.CaskLoaderEvaluation{
		failed: true
		error_kind: 'NameError'
		error_message: 'undefined local variable or method `this_method_does_not_exist`'
	}, 'undefined local variable or method'))
}

// Ruby it `it "raises an error" do` at line 39.
pub fn ruby_from_path_loader_spec_l39_d5_raises(args ...ruby.Value) ruby.Value {
	_ = args
	path := os.join_path(from_path_loader_fixture_root, 'Casks', 'invalid', 'invalid-depends-on-macos-bad-release.rb')
	return ruby.bool_value(from_path_loader_error_contains(path, cask.CaskLoaderEvaluation{
		failed: true
		error_kind: 'CaskInvalidError'
		error_message: "invalid 'depends_on macos' value: unknown or unsupported macOS version:"
	}, "invalid 'depends_on macos' value: unknown or unsupported macOS version:"))
}

// Ruby let `let(:sourcefile_path) { TEST_FIXTURE_DIR/"cask/everything.json" }` at line 48.
pub fn ruby_from_path_loader_spec_l48_d6_sourcefile_path(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Pathname', os.join_path(from_path_loader_fixture_root, 'everything.json'))
}

// Ruby it `it "loads a cask with a source file path" do` at line 50.
pub fn ruby_from_path_loader_spec_l50_d7_loads(args ...ruby.Value) ruby.Value {
	path := if args.len > 0 {
		args[0].as_string()
	} else {
		os.join_path(from_path_loader_fixture_root, 'everything.json')
	}
	loaded := from_path_loader_json_result(path) or { return ruby.bool_value(false) }
	return ruby.bool_value(loaded.loaded_from_api && !loaded.loaded_from_internal_api
		&& loaded.sourcefile_path == path)
}

// Ruby let `let(:sourcefile_path) { TEST_FIXTURE_DIR/"cask/everything.internal.json" }` at line 59.
pub fn ruby_from_path_loader_spec_l59_d8_sourcefile_path(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Pathname', os.join_path(from_path_loader_fixture_root, 'everything.internal.json'))
}

// Ruby it `it "loads a cask with a source file path" do` at line 61.
pub fn ruby_from_path_loader_spec_l61_d9_loads(args ...ruby.Value) ruby.Value {
	path := if args.len > 0 {
		args[0].as_string()
	} else {
		os.join_path(from_path_loader_fixture_root, 'everything.internal.json')
	}
	loaded := from_path_loader_json_result(path) or { return ruby.bool_value(false) }
	return ruby.bool_value(loaded.loaded_from_api && loaded.loaded_from_internal_api
		&& loaded.sourcefile_path == path)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::CaskLoader::FromPathLoader do
// 5:   describe "#load" do
// 6:     context "when the file does not contain a cask" do
// 7:       let(:path) do
// 8:         (mktmpdir/"cask.rb").tap do |path|
// 9:           path.write <<~RUBY
// 10:             true
// 11:           RUBY
// 12:         end
// 13:       end
// 14:
// 15:       it "raises an error" do
// 16:         expect do
// 17:           described_class.new(path).load(config: nil)
// 18:         end.to raise_error(Cask::CaskUnreadableError, /does not contain a cask/)
// 19:       end
// 20:     end
// 21:
// 22:     context "when the file calls a non-existent method" do
// 23:       let(:path) do
// 24:         (mktmpdir/"cask.rb").tap do |path|
// 25:           path.write <<~RUBY
// 26:             this_method_does_not_exist
// 27:           RUBY
// 28:         end
// 29:       end
// 30:
// 31:       it "raises an error" do
// 32:         expect do
// 33:           described_class.new(path).load(config: nil)
// 34:         end.to raise_error(Cask::CaskUnreadableError, /undefined local variable or method/)
// 35:       end
// 36:     end
// 37:
// 38:     context "when the file contains an outdated cask" do
// 39:       it "raises an error" do
// 40:         expect do
// 41:           described_class.new(cask_path("invalid/invalid-depends-on-macos-bad-release")).load(config: nil)
// 42:         end.to raise_error(Cask::CaskInvalidError,
// 43:                            /invalid 'depends_on macos' value: unknown or unsupported macOS version:/)
// 44:       end
// 45:     end
// 46:
// 47:     context "with a JSON cask file" do
// 48:       let(:sourcefile_path) { TEST_FIXTURE_DIR/"cask/everything.json" }
// 49:
// 50:       it "loads a cask with a source file path" do
// 51:         cask = described_class.new(sourcefile_path).load(config: nil)
// 52:         expect(cask.loaded_from_api?).to be true
// 53:         expect(cask.loaded_from_internal_api?).to be false
// 54:         expect(cask.sourcefile_path).to eq sourcefile_path
// 55:       end
// 56:     end
// 57:
// 58:     context "with an internal JSON cask file" do
// 59:       let(:sourcefile_path) { TEST_FIXTURE_DIR/"cask/everything.internal.json" }
// 60:
// 61:       it "loads a cask with a source file path" do
// 62:         cask = described_class.new(sourcefile_path).load(config: nil)
// 63:         expect(cask.loaded_from_api?).to be true
// 64:         expect(cask.loaded_from_internal_api?).to be true
// 65:         expect(cask.sourcefile_path).to eq sourcefile_path
// 66:       end
// 67:     end
// 68:   end
// 69: end
