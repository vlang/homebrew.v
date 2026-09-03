module bundle

import brew_runtime
import homebrew.bundle as production_bundle
import homebrew.bundle.subcommand as production_subcommand
import os
import time

// Translated from Homebrew/brew `test/cmd/bundle/dump_subcommand_spec.rb`.
// The original source is retained below until every stub has a typed V body.

fn dump_subcommand_spec_root(args []brew_runtime.Value, label string) string {
	if args.len > 0 && args[0].as_string() != '' {
		return args[0].as_string()
	}
	return os.join_path(os.temp_dir(), 'brew-v-dump-subcommand-${label}-${os.getpid()}-${time.now().unix_micro()}')
}

fn dump_subcommand_spec_config(root string, global bool) production_bundle.BundleBrewfilePathConfig {
	return production_bundle.BundleBrewfilePathConfig{
		global: global
		working_directory: root
		home_directory: root
		user_config_home: os.join_path(root, '.config', 'homebrew')
	}
}

fn dump_subcommand_spec_input() production_bundle.BundleDumpInput {
	return production_bundle.BundleDumpInput{
		formulae: [production_bundle.BundleDumpFormula{
			full_name: 'alpha'
			installed_on_request: true
		}]
		casks: [production_bundle.BundleDumpCask{
			full_name: 'desktop'
		}]
		taps: [production_bundle.BundleDumpTap{
			name: 'vendor/tools'
		}]
		extensions: [
			production_bundle.BundleDumpSection{
				type_name: 'mas'
				output: 'mas "Example", id: 1'
			},
			production_bundle.BundleDumpSection{
				type_name: 'vscode'
				output: 'vscode "example.extension"'
			},
		]
	}
}

fn dump_subcommand_spec_options(root string, global bool, force bool,
	formulae bool, taps bool, mas bool) production_subcommand.BundleDumpCommandOptions {
	return production_subcommand.BundleDumpCommandOptions{
		config: dump_subcommand_spec_config(root, global)
		input: dump_subcommand_spec_input()
		force: force
		formulae: formulae
		taps: taps
		casks: true
		extension_types: {
			'mas':    mas
			'vscode': true
		}
	}
}

fn dump_subcommand_spec_run(options production_subcommand.BundleDumpCommandOptions) !production_bundle.BundleDumpResult {
	os.mkdir_all(options.config.working_directory)!
	return production_subcommand.run_bundle_dump(options, production_bundle.real_brewfile_writer)
}

fn dump_subcommand_spec_result_value(result production_bundle.BundleDumpResult) brew_runtime.Value {
	return brew_runtime.structured_value('BundleDumpResult', result.path, {
		'path':    result.path
		'content': result.content
	})
}

// Ruby subject `subject(:dump) do` at line 8.
pub fn ruby_dump_subcommand_spec_l8_d1_dump(args ...brew_runtime.Value) brew_runtime.Value {
	root := dump_subcommand_spec_root(args, 'subject')
	force := args.len > 1 && (args[1].as_bool() or { false })
	global := args.len > 2 && (args[2].as_bool() or { false })
	result := dump_subcommand_spec_run(dump_subcommand_spec_options(root, global, force, true, true, true)) or { return brew_runtime.object_value('RuntimeError', err.msg()) }
	return dump_subcommand_spec_result_value(result)
}

// Ruby let `let(:force) { false }` at line 12.
pub fn ruby_dump_subcommand_spec_l12_d2_force(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(false)
}

// Ruby let `let(:global) { false }` at line 13.
pub fn ruby_dump_subcommand_spec_l13_d3_global(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(false)
}

// Ruby let `let(:context) { bundle_subcommand_context(:dump, global:, force:, no_type_args: false) }` at line 14.
pub fn ruby_dump_subcommand_spec_l14_d4_context(args ...brew_runtime.Value) brew_runtime.Value {
	global := args.len > 0 && (args[0].as_bool() or { false })
	force := args.len > 1 && (args[1].as_bool() or { false })
	return brew_runtime.map_value({
		'subcommand':   brew_runtime.string_value('dump')
		'global':       brew_runtime.bool_value(global)
		'force':        brew_runtime.bool_value(force)
		'no_type_args': brew_runtime.bool_value(false)
	})
}

// Ruby let `let(:args_object) do` at line 15.
pub fn ruby_dump_subcommand_spec_l15_d5_args_object(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.map_value({
		'describe?':   brew_runtime.bool_value(false)
		'no_restart?': brew_runtime.bool_value(false)
		'taps?':       brew_runtime.bool_value(true)
		'formulae?':   brew_runtime.bool_value(true)
		'casks?':      brew_runtime.bool_value(true)
		'mas?':        brew_runtime.bool_value(true)
		'vscode?':     brew_runtime.bool_value(true)
		'cargo?':      brew_runtime.bool_value(true)
		'flatpak?':    brew_runtime.bool_value(false)
		'go?':         brew_runtime.bool_value(true)
		'uv?':         brew_runtime.bool_value(true)
	})
}

// Ruby it `it "raises error" do` at line 39.
pub fn ruby_dump_subcommand_spec_l39_d6_raises(args ...brew_runtime.Value) brew_runtime.Value {
	root := dump_subcommand_spec_root(args, 'raises')
	os.mkdir_all(root) or { return brew_runtime.bool_value(false) }
	os.write_file(os.join_path(root, 'Brewfile'), 'existing') or {
		return brew_runtime.bool_value(false)
	}
	if _ := dump_subcommand_spec_run(dump_subcommand_spec_options(root, false, false, true, true, true)) {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(true)
}

// Ruby it `it "exits before doing any work" do` at line 45.
pub fn ruby_dump_subcommand_spec_l45_d7_exits(args ...brew_runtime.Value) brew_runtime.Value {
	root := dump_subcommand_spec_root(args, 'early')
	os.mkdir_all(root) or { return brew_runtime.bool_value(false) }
	path := os.join_path(root, 'Brewfile')
	os.write_file(path, 'unchanged') or { return brew_runtime.bool_value(false) }
	if _ := dump_subcommand_spec_run(dump_subcommand_spec_options(root, false, false, true, true, true)) {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value((os.read_file(path) or { '' }) == 'unchanged')
}

// Ruby it `it "does not dump disabled types by default" do` at line 55.
pub fn ruby_dump_subcommand_spec_l55_d8_does(args ...brew_runtime.Value) brew_runtime.Value {
	root := dump_subcommand_spec_root(args, 'disabled-default')
	result := dump_subcommand_spec_run(dump_subcommand_spec_options(root, false, false, false, true, false)) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(!result.content.contains('brew "alpha"')
		&& result.content.contains('cask "desktop"') && result.content.contains('tap "vendor/tools"')
		&& !result.content.contains('mas "Example"')
		&& result.content.contains('vscode "example.extension"'))
}

// Ruby it `it "treats --no-tap as --no-dump-tap" do` at line 70.
pub fn ruby_dump_subcommand_spec_l70_d9_treats(args ...brew_runtime.Value) brew_runtime.Value {
	root := dump_subcommand_spec_root(args, 'no-tap')
	result := dump_subcommand_spec_run(dump_subcommand_spec_options(root, false, false, true, false, true)) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(!result.content.contains('tap "vendor/tools"'))
}

// Ruby it `it "does not dump types disabled by environment" do` at line 81.
pub fn ruby_dump_subcommand_spec_l81_d10_does(args ...brew_runtime.Value) brew_runtime.Value {
	root := dump_subcommand_spec_root(args, 'disabled-env')
	result := dump_subcommand_spec_run(dump_subcommand_spec_options(root, false, false, false, true, false)) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(!result.content.contains('brew "alpha"')
		&& !result.content.contains('mas "Example"') && result.content.contains('cask "desktop"')
		&& result.content.contains('vscode "example.extension"'))
}

// Ruby let `let(:force) { true }` at line 98.
pub fn ruby_dump_subcommand_spec_l98_d11_force(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(true)
}

// Ruby let `let(:global) { true }` at line 99.
pub fn ruby_dump_subcommand_spec_l99_d12_global(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(true)
}

// Ruby it `it "doesn't raise error" do` at line 115.
pub fn ruby_dump_subcommand_spec_l115_d13_doesn(args ...brew_runtime.Value) brew_runtime.Value {
	root := dump_subcommand_spec_root(args, 'force-global')
	os.mkdir_all(root) or { return brew_runtime.bool_value(false) }
	path := os.join_path(root, '.Brewfile')
	os.write_file(path, 'existing') or { return brew_runtime.bool_value(false) }
	result := dump_subcommand_spec_run(dump_subcommand_spec_options(root, true, true, true, true, true)) or { return brew_runtime.bool_value(false) }
	return brew_runtime.bool_value(result.path == path
		&& (os.read_file(path) or { '' }).contains('brew "alpha"'))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle"
// 5: require "bundle/subcommand/dump"
// 6:
// 7: RSpec.describe Homebrew::Cmd::Bundle::DumpSubcommand do
// 8:   subject(:dump) do
// 9:     described_class.new(args_object, context:).run
// 10:   end
// 11:
// 12:   let(:force) { false }
// 13:   let(:global) { false }
// 14:   let(:context) { bundle_subcommand_context(:dump, global:, force:, no_type_args: false) }
// 15:   let(:args_object) do
// 16:     args_for_subcommand(:dump, describe?: false, no_restart?: false, taps?: true, formulae?: true, casks?: true,
// 17:                                mas?: true, vscode?: true, cargo?: true, flatpak?: false, go?: true, uv?: true)
// 18:   end
// 19:
// 20:   before do
// 21:     Homebrew::Bundle::Cask.reset!
// 22:     Homebrew::Bundle::Brew.reset!
// 23:     Homebrew::Bundle::Tap.reset!
// 24:     Homebrew::Bundle::VscodeExtension.reset!
// 25:     allow(Homebrew::Bundle::Cargo).to receive(:dump).and_return("")
// 26:     allow(Homebrew::Bundle::Uv).to receive(:dump).and_return("")
// 27:     allow(Formulary).to receive(:factory).and_call_original
// 28:     allow(Formulary).to receive(:factory).with("rust").and_return(
// 29:       instance_double(Formula, opt_bin: Pathname.new("/tmp/rust/bin")),
// 30:     )
// 31:   end
// 32:
// 33:   context "when files existed" do
// 34:     before do
// 35:       allow_any_instance_of(Pathname).to receive(:exist?).and_return(true)
// 36:       allow(Homebrew::Bundle).to receive(:cask_installed?).and_return(true)
// 37:     end
// 38:
// 39:     it "raises error" do
// 40:       expect do
// 41:         dump
// 42:       end.to raise_error(RuntimeError)
// 43:     end
// 44:
// 45:     it "exits before doing any work" do
// 46:       expect(Homebrew::Bundle::Tap).not_to receive(:dump)
// 47:       expect(Homebrew::Bundle::Brew).not_to receive(:dump)
// 48:       expect(Homebrew::Bundle::Cask).not_to receive(:dump)
// 49:       expect do
// 50:         dump
// 51:       end.to raise_error(RuntimeError)
// 52:     end
// 53:   end
// 54:
// 55:   it "does not dump disabled types by default" do
// 56:     args_object = args_for_subcommand(:dump, describe?: false, no_restart?: false, no_formulae?: true, no_mas?: true)
// 57:     context = bundle_subcommand_context(:dump)
// 58:
// 59:     expect(Homebrew::Bundle::Dumper).to receive(:dump_brewfile) do |formulae:, casks:, taps:, extension_types:, **|
// 60:       expect(formulae).to be(false)
// 61:       expect(casks).to be(true)
// 62:       expect(taps).to be(true)
// 63:       expect(extension_types[:mas]).to be(false)
// 64:       expect(extension_types[:vscode]).to be(true)
// 65:     end
// 66:
// 67:     described_class.new(args_object, context:).run
// 68:   end
// 69:
// 70:   it "treats --no-tap as --no-dump-tap" do
// 71:     args_object = args_for_subcommand(:dump, describe?: false, no_restart?: false, no_taps?: true)
// 72:     context = bundle_subcommand_context(:dump)
// 73:
// 74:     expect(Homebrew::Bundle::Dumper).to receive(:dump_brewfile) do |taps:, **|
// 75:       expect(taps).to be(false)
// 76:     end
// 77:
// 78:     described_class.new(args_object, context:).run
// 79:   end
// 80:
// 81:   it "does not dump types disabled by environment" do
// 82:     args_object = args_for_subcommand(:dump, describe?: false, no_restart?: false, no_dump_brew?: true,
// 83:                                              no_dump_mas?: true)
// 84:     context = bundle_subcommand_context(:dump)
// 85:
// 86:     expect(Homebrew::Bundle::Dumper).to receive(:dump_brewfile) do |formulae:, casks:, taps:, extension_types:, **|
// 87:       expect(formulae).to be(false)
// 88:       expect(casks).to be(true)
// 89:       expect(taps).to be(true)
// 90:       expect(extension_types[:mas]).to be(false)
// 91:       expect(extension_types[:vscode]).to be(true)
// 92:     end
// 93:
// 94:     described_class.new(args_object, context:).run
// 95:   end
// 96:
// 97:   context "when files existed and `--force` and `--global` are passed" do
// 98:     let(:force) { true }
// 99:     let(:global) { true }
// 100:
// 101:     before do
// 102:       ENV["HOMEBREW_BUNDLE_FILE"] = ""
// 103:       stub_formula_loader formula("mas") {
// 104:         T.bind(self, T.class_of(Formula))
// 105:         url "mas-1.0"
// 106:       }
// 107:       allow_any_instance_of(Pathname).to receive(:exist?).and_return(true)
// 108:       allow(Homebrew::Bundle).to receive(:cask_installed?).and_return(true)
// 109:       allow(Cask::Caskroom).to receive(:casks).and_return([])
// 110:
// 111:       # don't try to load gcc/glibc
// 112:       allow(DevelopmentTools).to receive_messages(needs_libc_formula?: false, needs_compiler_formula?: false)
// 113:     end
// 114:
// 115:     it "doesn't raise error" do
// 116:       io = instance_double(File, write: true)
// 117:       expect_any_instance_of(Pathname).to receive(:open).with("w").and_yield(io)
// 118:       expect(io).to receive(:write)
// 119:       expect { dump }.not_to raise_error
// 120:     end
// 121:   end
// 122: end
