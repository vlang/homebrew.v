module bundle

import brew_runtime
import homebrew.bundle as production_bundle
import homebrew.bundle.subcommand as production_subcommand
import os
import time

// Translated from Homebrew/brew `test/cmd/bundle/remove_subcommand_spec.rb`.
// The original source is retained below until every stub has a typed V body.

fn remove_subcommand_spec_package() production_bundle.BundlePackage {
	return production_bundle.BundlePackage{
		kind: .formula
		name: 'hello'
		full_name: 'homebrew/core/hello'
		desc: 'Program providing model for GNU coding standards and practices'
	}
}

fn remove_subcommand_spec_alias_package() production_bundle.BundlePackage {
	return production_bundle.BundlePackage{
		kind: .formula
		name: 'foo'
		full_name: 'qux/quuz/foo'
		oldnames: ['oldfoo']
		aliases: ['foobar']
	}
}

fn remove_subcommand_spec_run(content string, items []string, selected_type string,
	packages []production_bundle.BundlePackage) !production_bundle.BundleRemoveResult {
	path := os.join_path(os.temp_dir(), 'brew-v-remove-spec-${os.getpid()}-${time.now().unix_micro()}')
	os.write_file(path, content)!
	defer { os.rm(path) or {} }
	return production_subcommand.run_bundle_remove(production_subcommand.BundleRemoveCommandOptions{
		items: items
		selected_types: [selected_type]
		file: path
		packages: packages
	})
}

// Ruby subject `subject(:remove) do` at line 9.
pub fn ruby_remove_subcommand_spec_l9_d1_remove(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := remove_subcommand_spec_run('brew "hello"\n', ['hello'], 'brew', [
		remove_subcommand_spec_package(),
	]) or { return brew_runtime.object_value('RuntimeError', err.msg()) }
	return brew_runtime.structured_value('Bundle::RemoveSubcommand::Result', result.path, {
		'content': result.content
		'removed': result.removed.join(',')
	})
}

// Ruby let `let(:global) { false }` at line 13.
pub fn ruby_remove_subcommand_spec_l13_d2_global(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(false)
}

// Ruby let `let(:context) { bundle_subcommand_context(:remove, global:, file:, no_type_args: type == :none) }` at line 14.
pub fn ruby_remove_subcommand_spec_l14_d3_context(args ...brew_runtime.Value) brew_runtime.Value {
	selected_type := if args.len > 0 { args[0].as_string() } else { 'brew' }
	file := if args.len > 1 { args[1].as_string() } else { '/tmp/some_random_brewfile' }
	return brew_runtime.map_value({
		'subcommand':   brew_runtime.object_value('Symbol', 'remove')
		'global':       brew_runtime.bool_value(false)
		'file':         brew_runtime.string_value(file)
		'no_type_args': brew_runtime.bool_value(selected_type == 'none')
	})
}

// Ruby let `let(:type) { :brew }` at line 18.
pub fn ruby_remove_subcommand_spec_l18_d4_type(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.object_value('Symbol', 'brew')
}

// Ruby let `let(:file) { "/tmp/some_random_brewfile#{Random.rand(2 ** 16)}" }` at line 19.
pub fn ruby_remove_subcommand_spec_l19_d5_file(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.object_value('Pathname', '/tmp/some_random_brewfile')
}

// Ruby let `let(:content) { "dummy content for Sorbet" }` at line 20.
pub fn ruby_remove_subcommand_spec_l20_d6_content(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('dummy content for Sorbet')
}

// Ruby let `let(:args) { ["hello"] }` at line 21.
pub fn ruby_remove_subcommand_spec_l21_d7_args(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_array_value(['hello'])
}

// Ruby let `let(:args_object) do` at line 23.
pub fn ruby_remove_subcommand_spec_l23_d8_args_object(args ...brew_runtime.Value) brew_runtime.Value {
	selected_type := if args.len > 0 { args[0].as_string() } else { 'brew' }
	return brew_runtime.map_value({
		'named':     brew_runtime.string_array_value(['hello'])
		'formulae?': brew_runtime.bool_value(selected_type == 'brew')
		'casks?':    brew_runtime.bool_value(selected_type == 'cask')
		'taps?':     brew_runtime.bool_value(selected_type == 'tap')
	})
}

// Ruby let `let(:args) { ["hello"] }` at line 31.
pub fn ruby_remove_subcommand_spec_l31_d9_args(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_array_value(['hello'])
}

// Ruby let `let(:type) { :brew }` at line 32.
pub fn ruby_remove_subcommand_spec_l32_d10_type(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.object_value('Symbol', 'brew')
}

// Ruby let `let(:file) { "/tmp/some_random_brewfile#{Random.rand(2 ** 16)}" }` at line 33.
pub fn ruby_remove_subcommand_spec_l33_d11_file(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.object_value('Pathname', '/tmp/some_random_brewfile')
}

// Ruby let `let(:content) do` at line 34.
pub fn ruby_remove_subcommand_spec_l34_d12_content(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('brew "hello"\n')
}

// Ruby it `it "removes entries from the given Brewfile" do` at line 50.
pub fn ruby_remove_subcommand_spec_l50_d13_removes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := remove_subcommand_spec_run('brew "hello"\n', ['hello'], 'brew', [
		remove_subcommand_spec_package(),
	]) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(!result.content.contains('brew "hello"')
		&& result.removed == ['hello'])
}

// Ruby let `let(:content) do` at line 56.
pub fn ruby_remove_subcommand_spec_l56_d14_content(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('# Program providing model for GNU coding standards and practices\nbrew "hello"\n# Get a file from an HTTP, HTTPS or FTP server\nbrew "curl"\n')
}

// Ruby it `it "removes both the entry and its description comment" do` at line 65.
pub fn ruby_remove_subcommand_spec_l65_d15_removes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	content := ruby_remove_subcommand_spec_l56_d14_content().as_string()
	result := remove_subcommand_spec_run(content, ['hello'], 'brew', [
		remove_subcommand_spec_package(),
	]) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(result.content == '# Get a file from an HTTP, HTTPS or FTP server\nbrew "curl"\n')
}

// Ruby let `let(:content) do` at line 76.
pub fn ruby_remove_subcommand_spec_l76_d16_content(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('# Look at all these nice packages!\nbrew "hello"\n# cURL is awesome!\nbrew "curl"\n')
}

// Ruby it `it "removes the entry but not the preceding comment" do` at line 85.
pub fn ruby_remove_subcommand_spec_l85_d17_removes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	content := ruby_remove_subcommand_spec_l76_d16_content().as_string()
	result := remove_subcommand_spec_run(content, ['hello'], 'brew', [
		remove_subcommand_spec_package(),
	]) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(result.content == '# Look at all these nice packages!\n# cURL is awesome!\nbrew "curl"\n')
}

// Ruby let `let(:args) { ["foo"] }` at line 98.
pub fn ruby_remove_subcommand_spec_l98_d18_args(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_array_value(['foo'])
}

// Ruby let `let(:type) { :none }` at line 99.
pub fn ruby_remove_subcommand_spec_l99_d19_type(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.object_value('Symbol', 'none')
}

// Ruby let `let(:file) { "/tmp/some_random_brewfile#{Random.rand(2 ** 16)}" }` at line 100.
pub fn ruby_remove_subcommand_spec_l100_d20_file(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.object_value('Pathname', '/tmp/some_random_brewfile')
}

// Ruby let `let(:content) do` at line 101.
pub fn ruby_remove_subcommand_spec_l101_d21_content(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value('tap "someone/tap"\nbrew "foo"\ncask "foo"\n')
}

// Ruby it `it "removes all matching entries from the given Brewfile" do` at line 109.
pub fn ruby_remove_subcommand_spec_l109_d22_removes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := remove_subcommand_spec_run(ruby_remove_subcommand_spec_l101_d21_content().as_string(), [
		'foo',
	], 'none', []) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(!result.content.contains('foo'))
}

// Ruby let `let(:foo) do` at line 115.
pub fn ruby_remove_subcommand_spec_l115_d23_foo(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	package := remove_subcommand_spec_alias_package()
	return brew_runtime.structured_value('Formula', package.full_name, {
		'name':      package.name
		'full_name': package.full_name
		'oldnames':  package.oldnames.join(',')
		'aliases':   package.aliases.join(',')
	})
}

// Ruby let `let(:args) { ["foobar"] }` at line 124.
pub fn ruby_remove_subcommand_spec_l124_d24_args(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_array_value(['foobar'])
}

// Ruby it `it "suggests using `--formula` to match against formula aliases" do` at line 126.
pub fn ruby_remove_subcommand_spec_l126_d25_suggests(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	content := ruby_remove_subcommand_spec_l101_d21_content().as_string()
	result := remove_subcommand_spec_run(content, ['foobar'], 'none', [
		remove_subcommand_spec_alias_package(),
	]) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(result.content == content && result.warning.contains('--formula'))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle"
// 5: require "bundle/subcommand/remove"
// 6: require "cask/cask_loader"
// 7:
// 8: RSpec.describe Homebrew::Cmd::Bundle::RemoveSubcommand do
// 9:   subject(:remove) do
// 10:     described_class.new(args_object, context:).run
// 11:   end
// 12:
// 13:   let(:global) { false }
// 14:   let(:context) { bundle_subcommand_context(:remove, global:, file:, no_type_args: type == :none) }
// 15:
// 16:   # These next four `let`s are for the purposes of Sorbet typechecking; the
// 17:   # actual values in `args_object` are set by test `let`s.
// 18:   let(:type) { :brew }
// 19:   let(:file) { "/tmp/some_random_brewfile#{Random.rand(2 ** 16)}" }
// 20:   let(:content) { "dummy content for Sorbet" }
// 21:   let(:args) { ["hello"] }
// 22:
// 23:   let(:args_object) do
// 24:     args_for_subcommand(:remove, *args, formulae?: type == :brew, casks?: type == :cask, taps?: type == :tap)
// 25:   end
// 26:
// 27:   before { File.write(file, content) }
// 28:   after { FileUtils.rm_f file }
// 29:
// 30:   context "when called with a valid formula" do
// 31:     let(:args) { ["hello"] }
// 32:     let(:type) { :brew }
// 33:     let(:file) { "/tmp/some_random_brewfile#{Random.rand(2 ** 16)}" }
// 34:     let(:content) do
// 35:       <<~BREWFILE
// 36:         brew "hello"
// 37:       BREWFILE
// 38:     end
// 39:
// 40:     before do
// 41:       stub_formula_loader(
// 42:         formula("hello") do
// 43:           T.bind(self, T.class_of(Formula))
// 44:           url "hello-1.0"
// 45:           desc "Program providing model for GNU coding standards and practices"
// 46:         end,
// 47:       )
// 48:     end
// 49:
// 50:     it "removes entries from the given Brewfile" do
// 51:       expect { remove }.not_to raise_error
// 52:       expect(File.read(file)).not_to include("#{type} \"#{args.first}\"")
// 53:     end
// 54:
// 55:     context "when the entry has a preceding description comment" do
// 56:       let(:content) do
// 57:         <<~BREWFILE
// 58:           # Program providing model for GNU coding standards and practices
// 59:           brew "hello"
// 60:           # Get a file from an HTTP, HTTPS or FTP server
// 61:           brew "curl"
// 62:         BREWFILE
// 63:       end
// 64:
// 65:       it "removes both the entry and its description comment" do
// 66:         expect { remove }.not_to raise_error
// 67:
// 68:         expect(File.read(file)).to eq <<~BREWFILE
// 69:           # Get a file from an HTTP, HTTPS or FTP server
// 70:           brew "curl"
// 71:         BREWFILE
// 72:       end
// 73:     end
// 74:
// 75:     context "when the entry has a preceding comment that's not the entry's description" do
// 76:       let(:content) do
// 77:         <<~BREWFILE
// 78:           # Look at all these nice packages!
// 79:           brew "hello"
// 80:           # cURL is awesome!
// 81:           brew "curl"
// 82:         BREWFILE
// 83:       end
// 84:
// 85:       it "removes the entry but not the preceding comment" do
// 86:         expect { remove }.not_to raise_error
// 87:
// 88:         expect(File.read(file)).to eq <<~BREWFILE
// 89:           # Look at all these nice packages!
// 90:           # cURL is awesome!
// 91:           brew "curl"
// 92:         BREWFILE
// 93:       end
// 94:     end
// 95:   end
// 96:
// 97:   context "when called with no type" do
// 98:     let(:args) { ["foo"] }
// 99:     let(:type) { :none }
// 100:     let(:file) { "/tmp/some_random_brewfile#{Random.rand(2 ** 16)}" }
// 101:     let(:content) do
// 102:       <<~BREWFILE
// 103:         tap "someone/tap"
// 104:         brew "foo"
// 105:         cask "foo"
// 106:       BREWFILE
// 107:     end
// 108:
// 109:     it "removes all matching entries from the given Brewfile" do
// 110:       expect { remove }.not_to raise_error
// 111:       expect(File.read(file)).not_to include(args.first)
// 112:     end
// 113:
// 114:     context "with arguments that match entries only when considering formula aliases" do
// 115:       let(:foo) do
// 116:         instance_double(
// 117:           Formula,
// 118:           name:      "foo",
// 119:           full_name: "qux/quuz/foo",
// 120:           oldnames:  ["oldfoo"],
// 121:           aliases:   ["foobar"],
// 122:         )
// 123:       end
// 124:       let(:args) { ["foobar"] }
// 125:
// 126:       it "suggests using `--formula` to match against formula aliases" do
// 127:         expect(Formulary).to receive(:factory).with("foobar").and_return(foo)
// 128:         expect { remove }.not_to raise_error
// 129:         expect(File.read(file)).to eq(content)
// 130:         # FIXME: Why doesn't this work?
// 131:         # expect { remove }.to output("--formula").to_stderr
// 132:       end
// 133:     end
// 134:   end
// 135: end
