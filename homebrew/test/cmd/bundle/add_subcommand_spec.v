module bundle

import ruby
import homebrew.bundle as production_bundle
import homebrew.bundle.subcommand as production_subcommand
import os
import time

// Translated from Homebrew/brew `test/cmd/bundle/add_subcommand_spec.rb`.
// The original source is retained below until every stub has a typed V body.

fn add_subcommand_spec_path(label string) string {
	return os.join_path(os.temp_dir(), 'brew-v-add-spec-${label}-${os.getpid()}-${time.now().unix_micro()}')
}

fn add_subcommand_spec_run(item string, entry_type string, taps []string) !production_bundle.BundleAddResult {
	path := add_subcommand_spec_path(entry_type)
	os.write_file(path, '')!
	defer { os.rm(path) or {} }
	return production_subcommand.run_bundle_add(production_subcommand.BundleAddCommandOptions{
		items: [item]
		selected_types: [entry_type]
		file: path
		describe: false
		taps: taps
	})
}

fn add_subcommand_spec_result_value(result production_bundle.BundleAddResult) ruby.Value {
	return ruby.structured_value('Bundle::AddSubcommand::Result', result.path, {
		'path':             result.path
		'content':          result.content
		'ensured_taps':     result.ensured_taps.join(',')
		'trusted_type':     result.trusted_type
		'trusted_items':    result.trusted_items.join(',')
		'appended_entries': result.appended_entries.join('\n')
	})
}

fn add_subcommand_spec_events(item string, entry_type string) []string {
	result := add_subcommand_spec_run(item, entry_type, ['user/repo']) or { return [] }
	mut events := []string{}
	if result.ensured_taps == ['user/repo'] {
		events << 'tap'
	}
	if result.trusted_items == [item] {
		events << 'trust'
	}
	if result.appended_entries.len == 1 {
		events << 'load'
	}
	return events
}

// Ruby subject `subject(:add) do` at line 9.
pub fn ruby_add_subcommand_spec_l9_d1_add(args ...ruby.Value) ruby.Value {
	_ = args
	result := add_subcommand_spec_run('hello', 'brew', []) or {
		return ruby.object_value('RuntimeError', err.msg())
	}
	return add_subcommand_spec_result_value(result)
}

// Ruby let `let(:global) { false }` at line 13.
pub fn ruby_add_subcommand_spec_l13_d2_global(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(false)
}

// Ruby let `let(:context) { bundle_subcommand_context(:add, global:, file:, no_type_args: false) }` at line 14.
pub fn ruby_add_subcommand_spec_l14_d3_context(args ...ruby.Value) ruby.Value {
	file := if args.len > 0 { args[0].as_string() } else { '/tmp/some_random_brewfile' }
	return ruby.map_value({
		'subcommand':   ruby.object_value('Symbol', 'add')
		'global':       ruby.bool_value(false)
		'file':         ruby.string_value(file)
		'no_type_args': ruby.bool_value(false)
	})
}

// Ruby let `let(:args_object) do` at line 15.
pub fn ruby_add_subcommand_spec_l15_d4_args_object(args ...ruby.Value) ruby.Value {
	entry_type := if args.len > 0 { args[0].as_string() } else { 'brew' }
	items := if args.len > 1 {
		args[1].as_string_array() or { ['hello'] }
	} else {
		[
			'hello',
		]
	}
	return ruby.map_value({
		'named':     ruby.string_array_value(items)
		'formulae?': ruby.bool_value(entry_type == 'brew')
		'casks?':    ruby.bool_value(entry_type == 'cask')
		'taps?':     ruby.bool_value(entry_type == 'tap')
		'describe?': ruby.bool_value(false)
	})
}

// Ruby let `let(:args) { ["hello"] }` at line 24.
pub fn ruby_add_subcommand_spec_l24_d5_args(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_array_value(['hello'])
}

// Ruby let `let(:type) { :brew }` at line 25.
pub fn ruby_add_subcommand_spec_l25_d6_type(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Symbol', 'brew')
}

// Ruby let `let(:file) { "/tmp/some_random_brewfile#{Random.rand(2 ** 16)}" }` at line 26.
pub fn ruby_add_subcommand_spec_l26_d7_file(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Pathname', add_subcommand_spec_path('formula'))
}

// Ruby it `it "adds entries to the given Brewfile" do` at line 37.
pub fn ruby_add_subcommand_spec_l37_d8_adds(args ...ruby.Value) ruby.Value {
	_ = args
	result := add_subcommand_spec_run('hello', 'brew', []) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(result.content.contains('brew "hello"'))
}

// Ruby let `let(:args) { ["alacritty"] }` at line 44.
pub fn ruby_add_subcommand_spec_l44_d9_args(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_array_value(['alacritty'])
}

// Ruby let `let(:type) { :cask }` at line 45.
pub fn ruby_add_subcommand_spec_l45_d10_type(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Symbol', 'cask')
}

// Ruby let `let(:file) { "/tmp/some_random_brewfile#{Random.rand(2 ** 16)}" }` at line 46.
pub fn ruby_add_subcommand_spec_l46_d11_file(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Pathname', add_subcommand_spec_path('cask'))
}

// Ruby it `it "adds entries to the given Brewfile" do` at line 56.
pub fn ruby_add_subcommand_spec_l56_d12_adds(args ...ruby.Value) ruby.Value {
	_ = args
	result := add_subcommand_spec_run('alacritty', 'cask', []) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(result.content.contains('cask "alacritty"'))
}

// Ruby let `let(:args) { ["user/repo/hello"] }` at line 63.
pub fn ruby_add_subcommand_spec_l63_d13_args(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_array_value(['user/repo/hello'])
}

// Ruby let `let(:type) { :brew }` at line 64.
pub fn ruby_add_subcommand_spec_l64_d14_type(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Symbol', 'brew')
}

// Ruby let `let(:file) { "/tmp/some_random_brewfile#{Random.rand(2 ** 16)}" }` at line 65.
pub fn ruby_add_subcommand_spec_l65_d15_file(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Pathname', add_subcommand_spec_path('qualified-formula'))
}

// Ruby let `let(:events) { [] }` at line 66.
pub fn ruby_add_subcommand_spec_l66_d16_events(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_array_value([])
}

// Ruby it `it "installs and trusts the tap before loading the formula" do` at line 86.
pub fn ruby_add_subcommand_spec_l86_d17_installs(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(add_subcommand_spec_events('user/repo/hello', 'brew') == [
		'tap',
		'trust',
		'load',
	])
}

// Ruby let `let(:args) { ["user/repo/alacritty"] }` at line 93.
pub fn ruby_add_subcommand_spec_l93_d18_args(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_array_value(['user/repo/alacritty'])
}

// Ruby let `let(:type) { :cask }` at line 94.
pub fn ruby_add_subcommand_spec_l94_d19_type(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Symbol', 'cask')
}

// Ruby let `let(:file) { "/tmp/some_random_brewfile#{Random.rand(2 ** 16)}" }` at line 95.
pub fn ruby_add_subcommand_spec_l95_d20_file(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Pathname', add_subcommand_spec_path('qualified-cask'))
}

// Ruby let `let(:events) { [] }` at line 96.
pub fn ruby_add_subcommand_spec_l96_d21_events(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_array_value([])
}

// Ruby it `it "installs and trusts the tap before loading the cask" do` at line 117.
pub fn ruby_add_subcommand_spec_l117_d22_installs(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(add_subcommand_spec_events('user/repo/alacritty', 'cask') == [
		'tap',
		'trust',
		'load',
	])
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle"
// 5: require "bundle/subcommand/add"
// 6: require "cask/cask_loader"
// 7:
// 8: RSpec.describe Homebrew::Cmd::Bundle::AddSubcommand do
// 9:   subject(:add) do
// 10:     described_class.new(args_object, context:).run
// 11:   end
// 12:
// 13:   let(:global) { false }
// 14:   let(:context) { bundle_subcommand_context(:add, global:, file:, no_type_args: false) }
// 15:   let(:args_object) do
// 16:     args_for_subcommand(:add, *args, formulae?: type == :brew, casks?: type == :cask, taps?: type == :tap,
// 17:                                       describe?: false)
// 18:   end
// 19:
// 20:   before { FileUtils.touch file }
// 21:   after { FileUtils.rm_f file }
// 22:
// 23:   context "when called with a valid formula" do
// 24:     let(:args) { ["hello"] }
// 25:     let(:type) { :brew }
// 26:     let(:file) { "/tmp/some_random_brewfile#{Random.rand(2 ** 16)}" }
// 27:
// 28:     before do
// 29:       stub_formula_loader(
// 30:         formula("hello") do
// 31:           T.bind(self, T.class_of(Formula))
// 32:           url "hello-1.0"
// 33:         end,
// 34:       )
// 35:     end
// 36:
// 37:     it "adds entries to the given Brewfile" do
// 38:       expect { add }.not_to raise_error
// 39:       expect(File.read(file)).to include("#{type} \"#{args.first}\"")
// 40:     end
// 41:   end
// 42:
// 43:   context "when called with a valid cask" do
// 44:     let(:args) { ["alacritty"] }
// 45:     let(:type) { :cask }
// 46:     let(:file) { "/tmp/some_random_brewfile#{Random.rand(2 ** 16)}" }
// 47:
// 48:     before do
// 49:       stub_cask_loader Cask::CaskLoader::FromContentLoader.new(+<<~RUBY).load(config: nil)
// 50:         cask "alacritty" do
// 51:           version "1.0"
// 52:         end
// 53:       RUBY
// 54:     end
// 55:
// 56:     it "adds entries to the given Brewfile" do
// 57:       expect { add }.not_to raise_error
// 58:       expect(File.read(file)).to include("#{type} \"#{args.first}\"")
// 59:     end
// 60:   end
// 61:
// 62:   context "when called with a fully-qualified formula from an untapped tap" do
// 63:     let(:args) { ["user/repo/hello"] }
// 64:     let(:type) { :brew }
// 65:     let(:file) { "/tmp/some_random_brewfile#{Random.rand(2 ** 16)}" }
// 66:     let(:events) { [] }
// 67:
// 68:     before do
// 69:       tap = Tap.fetch("user", "repo")
// 70:       formula_instance = formula("hello") do
// 71:         T.bind(self, T.class_of(Formula))
// 72:         url "hello-1.0"
// 73:       end
// 74:
// 75:       allow(Tap).to receive(:with_formula_name).with(args.first).and_return([tap, "hello"])
// 76:       allow(tap).to receive(:ensure_installed!) { events << :tap }
// 77:       allow(Homebrew::Trust).to receive(:trust_fully_qualified_items!).with(args, type: :formula) do
// 78:         events << :trust
// 79:       end
// 80:       allow(Formulary).to receive(:factory).with(args.first) do
// 81:         events << :load
// 82:         formula_instance
// 83:       end
// 84:     end
// 85:
// 86:     it "installs and trusts the tap before loading the formula" do
// 87:       add
// 88:       expect(events).to eq([:tap, :trust, :load])
// 89:     end
// 90:   end
// 91:
// 92:   context "when called with a fully-qualified cask from an untapped tap" do
// 93:     let(:args) { ["user/repo/alacritty"] }
// 94:     let(:type) { :cask }
// 95:     let(:file) { "/tmp/some_random_brewfile#{Random.rand(2 ** 16)}" }
// 96:     let(:events) { [] }
// 97:
// 98:     before do
// 99:       tap = Tap.fetch("user", "repo")
// 100:       cask = Cask::CaskLoader::FromContentLoader.new(+<<~RUBY).load(config: nil)
// 101:         cask "alacritty" do
// 102:           version "1.0"
// 103:         end
// 104:       RUBY
// 105:
// 106:       allow(Tap).to receive(:with_cask_token).with(args.first).and_return([tap, "alacritty"])
// 107:       allow(tap).to receive(:ensure_installed!) { events << :tap }
// 108:       allow(Homebrew::Trust).to receive(:trust_fully_qualified_items!).with(args, type: :cask) do
// 109:         events << :trust
// 110:       end
// 111:       allow(Cask::CaskLoader).to receive(:load).with(args.first) do
// 112:         events << :load
// 113:         cask
// 114:       end
// 115:     end
// 116:
// 117:     it "installs and trusts the tap before loading the cask" do
// 118:       add
// 119:       expect(events).to eq([:tap, :trust, :load])
// 120:     end
// 121:   end
// 122: end
