module bundle

import ruby
import homebrew.bundle as production_bundle
import homebrew.bundle.subcommand as production_subcommand

// Translated from Homebrew/brew `test/cmd/bundle/list_subcommand_spec.rb`.
// The original source is retained below until every stub has a typed V body.

fn list_subcommand_spec_types() []string {
	return ['tap', 'brew', 'cask', 'mas', 'vscode', 'go', 'cargo', 'uv']
}

fn list_subcommand_spec_entries() []production_bundle.BundleListEntry {
	return [
		production_bundle.BundleListEntry{ entry_type: 'tap', name: 'phinze/cask' },
		production_bundle.BundleListEntry{ entry_type: 'brew', name: 'mysql' },
		production_bundle.BundleListEntry{ entry_type: 'cask', name: 'google-chrome' },
		production_bundle.BundleListEntry{ entry_type: 'mas', name: '1Password' },
		production_bundle.BundleListEntry{ entry_type: 'vscode', name: 'shopify.ruby-lsp' },
		production_bundle.BundleListEntry{ entry_type: 'go', name: 'github.com/charmbracelet/crush' },
		production_bundle.BundleListEntry{ entry_type: 'cargo', name: 'ripgrep' },
		production_bundle.BundleListEntry{ entry_type: 'uv', name: 'mkdocs' },
	]
}

fn list_subcommand_spec_flag(args []ruby.Value, index int, name string) bool {
	if args.len > 0 {
		flags := args[0].as_map() or { map[string]ruby.Value{} }
		if name in flags {
			return flags[name].as_bool() or { flags[name].as_string() == 'true' }
		}
	}
	if args.len > index {
		return args[index].as_bool() or { false }
	}
	return false
}

fn list_subcommand_spec_options(args []ruby.Value) production_subcommand.BundleListCommandOptions {
	formulae := list_subcommand_spec_flag(args, 0, 'formulae')
	casks := list_subcommand_spec_flag(args, 1, 'casks')
	taps := list_subcommand_spec_flag(args, 2, 'taps')
	mas := list_subcommand_spec_flag(args, 3, 'mas')
	vscode := list_subcommand_spec_flag(args, 4, 'vscode')
	go_enabled := list_subcommand_spec_flag(args, 5, 'go')
	cargo := list_subcommand_spec_flag(args, 6, 'cargo')
	uv := list_subcommand_spec_flag(args, 7, 'uv')
	return production_subcommand.BundleListCommandOptions{
		formulae: formulae
		casks: casks
		taps: taps
		no_type_args: !formulae && !casks && !taps && !mas && !vscode && !go_enabled
			&& !cargo && !uv
		extension_types: {
			'mas':    mas
			'vscode': vscode
			'go':     go_enabled
			'cargo':  cargo
			'uv':     uv
		}
	}
}

fn list_subcommand_spec_run(args []ruby.Value) []string {
	return production_subcommand.run_bundle_list(list_subcommand_spec_entries(), list_subcommand_spec_options(args))
}

// Ruby subject `subject(:list) do` at line 26.
pub fn ruby_list_subcommand_spec_l26_d1_list(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(list_subcommand_spec_run(args))
}

// Ruby let `let(:context) { bundle_subcommand_context(:list, no_type_args:) }` at line 30.
pub fn ruby_list_subcommand_spec_l30_d2_context(args ...ruby.Value) ruby.Value {
	options := list_subcommand_spec_options(args)
	return ruby.map_value({
		'subcommand':   ruby.string_value('list')
		'no_type_args': ruby.bool_value(options.no_type_args)
	})
}

// Ruby let `let(:args_object) do` at line 31.
pub fn ruby_list_subcommand_spec_l31_d3_args_object(args ...ruby.Value) ruby.Value {
	options := list_subcommand_spec_options(args)
	return ruby.map_value({
		'formulae?': ruby.bool_value(options.formulae)
		'casks?':    ruby.bool_value(options.casks)
		'taps?':     ruby.bool_value(options.taps)
		'mas?':      ruby.bool_value(options.extension_types['mas'])
		'vscode?':   ruby.bool_value(options.extension_types['vscode'])
		'go?':       ruby.bool_value(options.extension_types['go'])
		'cargo?':    ruby.bool_value(options.extension_types['cargo'])
		'uv?':       ruby.bool_value(options.extension_types['uv'])
		'flatpak?':  ruby.bool_value(false)
		'all?':      ruby.bool_value(false)
	})
}

// Ruby let `let(:no_type_args) { [formulae, casks, taps, mas, vscode, go, cargo, uv].none? }` at line 35.
pub fn ruby_list_subcommand_spec_l35_d4_no_type_args(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(list_subcommand_spec_options(args).no_type_args)
}

// Ruby let `let(:formulae) { false }` at line 36.
pub fn ruby_list_subcommand_spec_l36_d5_formulae(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(false)
}

// Ruby let `let(:casks)    { false }` at line 37.
pub fn ruby_list_subcommand_spec_l37_d6_casks(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(false)
}

// Ruby let `let(:taps)     { false }` at line 38.
pub fn ruby_list_subcommand_spec_l38_d7_taps(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(false)
}

// Ruby let `let(:mas)      { false }` at line 39.
pub fn ruby_list_subcommand_spec_l39_d8_mas(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(false)
}

// Ruby let `let(:vscode)   { false }` at line 40.
pub fn ruby_list_subcommand_spec_l40_d9_vscode(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(false)
}

// Ruby let `let(:go)       { false }` at line 41.
pub fn ruby_list_subcommand_spec_l41_d10_go(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(false)
}

// Ruby let `let(:cargo)    { false }` at line 42.
pub fn ruby_list_subcommand_spec_l42_d11_cargo(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(false)
}

// Ruby let `let(:uv)       { false }` at line 43.
pub fn ruby_list_subcommand_spec_l43_d12_uv(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(false)
}

// Ruby it `it "only shows brew deps when no options are passed" do` at line 65.
pub fn ruby_list_subcommand_spec_l65_d13_only(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(list_subcommand_spec_run([]) == ['mysql'])
}

// Ruby it `it "shows only the requested type(s) for all combinations" do` at line 70.
pub fn ruby_list_subcommand_spec_l70_d14_shows(args ...ruby.Value) ruby.Value {
	_ = args
	types := list_subcommand_spec_types()
	entries := list_subcommand_spec_entries()
	for mask in 1 .. (1 << types.len) {
		mut flags := map[string]bool{}
		mut expected := []string{}
		for index, entry_type in types {
			selected := (mask & (1 << index)) != 0
			flags[entry_type] = selected
			if selected {
				expected << entries[index].name
			}
		}
		actual := production_subcommand.run_bundle_list(entries, production_subcommand.BundleListCommandOptions{
			formulae: flags['brew']
			casks: flags['cask']
			taps: flags['tap']
			extension_types: {
				'mas':    flags['mas']
				'vscode': flags['vscode']
				'go':     flags['go']
				'cargo':  flags['cargo']
				'uv':     flags['uv']
			}
		})
		if actual != expected {
			return ruby.bool_value(false)
		}
	}
	return ruby.bool_value(true)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle"
// 5: require "bundle/subcommand/list"
// 6:
// 7: TYPES_AND_DEPS = {
// 8:   taps:     "phinze/cask",
// 9:   formulae: "mysql",
// 10:   casks:    "google-chrome",
// 11:   mas:      "1Password",
// 12:   vscode:   "shopify.ruby-lsp",
// 13:   go:       "github.com/charmbracelet/crush",
// 14:   cargo:    "ripgrep",
// 15:   uv:       "mkdocs",
// 16: }.freeze
// 17:
// 18: COMBINATIONS = begin
// 19:   keys = TYPES_AND_DEPS.keys
// 20:   1.upto(keys.length).flat_map do |i|
// 21:     keys.combination(i).take((1..keys.length).reduce(:*) || 1)
// 22:   end.sort
// 23: end.freeze
// 24:
// 25: RSpec.describe Homebrew::Cmd::Bundle::ListSubcommand do
// 26:   subject(:list) do
// 27:     described_class.new(args_object, context:).run
// 28:   end
// 29:
// 30:   let(:context) { bundle_subcommand_context(:list, no_type_args:) }
// 31:   let(:args_object) do
// 32:     args_for_subcommand(:list, formulae?: formulae, casks?: casks, taps?: taps, mas?: mas, vscode?: vscode,
// 33:                                cargo?: cargo, flatpak?: false, go?: go, uv?: uv, all?: false)
// 34:   end
// 35:   let(:no_type_args) { [formulae, casks, taps, mas, vscode, go, cargo, uv].none? }
// 36:   let(:formulae) { false }
// 37:   let(:casks)    { false }
// 38:   let(:taps)     { false }
// 39:   let(:mas)      { false }
// 40:   let(:vscode)   { false }
// 41:   let(:go)       { false }
// 42:   let(:cargo)    { false }
// 43:   let(:uv)       { false }
// 44:
// 45:   before do
// 46:     allow_any_instance_of(IO).to receive(:puts)
// 47:   end
// 48:
// 49:   describe "outputs dependencies to stdout" do
// 50:     before do
// 51:       allow_any_instance_of(Pathname).to receive(:read).and_return(
// 52:         <<~RUBY,
// 53:           tap 'phinze/cask'
// 54:           brew 'mysql', conflicts_with: ['mysql56']
// 55:           cask 'google-chrome'
// 56:           mas '1Password', id: 443987910
// 57:           vscode 'shopify.ruby-lsp'
// 58:           go 'github.com/charmbracelet/crush'
// 59:           cargo 'ripgrep'
// 60:           uv 'mkdocs'
// 61:         RUBY
// 62:       )
// 63:     end
// 64:
// 65:     it "only shows brew deps when no options are passed" do
// 66:       expect { list }.to output("mysql\n").to_stdout
// 67:     end
// 68:
// 69:     describe "limiting when certain options are passed" do
// 70:       it "shows only the requested type(s) for all combinations" do
// 71:         COMBINATIONS.each do |options_list|
// 72:           formulae = options_list.include?(:formulae)
// 73:           casks = options_list.include?(:casks)
// 74:           taps = options_list.include?(:taps)
// 75:           mas = options_list.include?(:mas)
// 76:           vscode = options_list.include?(:vscode)
// 77:           go = options_list.include?(:go)
// 78:           cargo = options_list.include?(:cargo)
// 79:           uv = options_list.include?(:uv)
// 80:
// 81:           no_type_args = [formulae, casks, taps, mas, vscode, go, cargo, uv].none?
// 82:           context = bundle_subcommand_context(:list, no_type_args:)
// 83:           args_object = args_for_subcommand(
// 84:             :list,
// 85:             formulae?: formulae,
// 86:             casks?:    casks,
// 87:             taps?:     taps,
// 88:             mas?:      mas,
// 89:             vscode?:   vscode,
// 90:             cargo?:    cargo,
// 91:             flatpak?:  false,
// 92:             go?:       go,
// 93:             uv?:       uv,
// 94:             all?:      false,
// 95:           )
// 96:
// 97:           expected = options_list.map { |opt| TYPES_AND_DEPS[opt] }.join("\n")
// 98:           expect do
// 99:             described_class.new(args_object, context:).run
// 100:           end.to output("#{expected}\n").to_stdout
// 101:         end
// 102:       end
// 103:     end
// 104:   end
// 105: end
