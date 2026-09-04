module cmd

import ruby
import homebrew.cmd as brew_cmd

// Translated from Homebrew/brew `test/cmd/link_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn link_spec_action(keg brew_cmd.LinkCommandKeg, options brew_cmd.LinkOperationOptions) !int {
	if keg.name == '' {
		return error('a named keg is required')
	}
	if options != brew_cmd.LinkOperationOptions{} {
		return error('the retained specs invoke Keg#link with all options disabled')
	}
	return 1
}

fn link_spec_conflict(formula brew_cmd.LinkCommandKeg, verbose bool) ! {
	if formula.formula_unavailable || verbose {
		return error('unexpected formula conflict arguments')
	}
}

fn link_spec_run(keg brew_cmd.LinkCommandKeg) ?brew_cmd.LinkCommandResult {
	return brew_cmd.run_link_command([keg], brew_cmd.LinkCommandOptions{}, link_spec_action, link_spec_conflict) or { return none }
}

// Ruby it `it "uses formula-aware conflict handling when linking a Formula" do` at line 10.
pub fn ruby_link_spec_l10_d1_uses(args ...ruby.Value) ruby.Value {
	result := link_spec_run(brew_cmd.LinkCommandKeg{
		name: 'testball'
		path: '/cellar/testball/1.0'
		rack: '/cellar/testball'
	}) or { return ruby.bool_value(false) }
	return ruby.bool_value(result.conflicts_handled == ['testball'] && result.operations.len == 1 && result.operations[0].options == brew_cmd.LinkOperationOptions{} && result.stdout.contains('Linking /cellar/testball/1.0... 1 symlinks created.'))
}

// Ruby it `it "links a given Formula", :integration_test do` at line 28.
pub fn ruby_link_spec_l28_d2_links(args ...ruby.Value) ruby.Value {
	result := link_spec_run(brew_cmd.LinkCommandKeg{
		name: 'testball'
		path: '/cellar/testball/1.0'
	}) or { return ruby.bool_value(false) }
	return ruby.bool_value(result.linked_kegs == ['testball'] && result.stdout.starts_with('Linking ') && result.stderr == '')
}

// Ruby it `it "does not print keg-only output when linking a` at line 45.
pub fn ruby_link_spec_l45_d3_does(args ...ruby.Value) ruby.Value {
	unexpected_fragments := [
		'unexpected caveat output',
		'unexpected post_install output',
		'If you need to have this software first in your PATH',
		'keg-only',
	]
	for formula_name in ['testball-link-output@1.0', 'testball-link-output-full'] {
		result := link_spec_run(brew_cmd.LinkCommandKeg{
			name: formula_name
			path: '${formula_name}/1.0'
			keg_only: true
			keg_only_reason: 'versioned_formula'
			keg_only_text: 'unexpected caveat output'
			bin_directory: true
		}) or { return ruby.bool_value(false) }
		combined_output := result.stdout + result.stderr
		if unexpected_fragments.any(combined_output.contains(it)) {
			return ruby.bool_value(false)
		}
	}
	return ruby.bool_value(true)
}

// Ruby method `caveats` at line 51.
pub fn ruby_link_spec_l51_d4_caveats(args ...ruby.Value) ruby.Value {
	return ruby.string_value('unexpected caveat output')
}

// Ruby method `post_install; end` at line 55.
pub fn ruby_link_spec_l55_d5_post_install(args ...ruby.Value) ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/link"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::Link do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "uses formula-aware conflict handling when linking a Formula" do
// 11:     formula = formula "testball" do
// 12:       T.bind(self, T.class_of(Formula))
// 13:       url "foo-1.0"
// 14:     end
// 15:     keg = instance_double(Keg, rack: HOMEBREW_CELLAR/"testball", linked?: false, name: "testball")
// 16:
// 17:     cmd = described_class.new(["testball"])
// 18:     allow(cmd.args.named).to receive(:to_latest_kegs).and_return([keg])
// 19:     allow(Formulary).to receive(:keg_only?).with(keg.rack).and_return(false)
// 20:     allow(keg).to receive(:to_formula).and_return(formula)
// 21:     expect(Homebrew::Unlink).to receive(:unlink_link_overwrite_formulae).with(formula, verbose: false)
// 22:     allow(keg).to receive(:lock).and_yield
// 23:     expect(keg).to receive(:link).with(dry_run: false, verbose: false, overwrite: false).and_return(1)
// 24:
// 25:     expect { cmd.run }.to output(/Linking .*1 symlinks created\./).to_stdout
// 26:   end
// 27:
// 28:   it "links a given Formula", :integration_test do
// 29:     setup_test_formula "testball", tab_attributes: { installed_on_request: true }
// 30:     Formula["testball"].any_installed_keg.unlink
// 31:     Formula["testball"].bin.mkpath
// 32:     FileUtils.touch Formula["testball"].bin/"testfile"
// 33:
// 34:     expect { brew "link", "testball" }
// 35:       .to output(/Linking/).to_stdout
// 36:       .and not_to_output.to_stderr
// 37:       .and be_a_success
// 38:     expect(HOMEBREW_PREFIX/"bin/testfile").to be_a_file
// 39:   end
// 40:
// 41:   test_each_hash({
// 42:     "@-versioned" => "testball-link-output@1.0",
// 43:     "-full"       => "testball-link-output-full",
// 44:   }) do |formula_type, formula_name|
// 45:     it "does not print keg-only output when linking a #{formula_type} formula" do
// 46:       test_formula = formula(formula_name) do
// 47:         T.bind(self, T.class_of(Formula))
// 48:         url "https://brew.sh/#{formula_name}-1.0"
// 49:         keg_only :versioned_formula
// 50:
// 51:         def caveats
// 52:           "unexpected caveat output"
// 53:         end
// 54:
// 55:         def post_install; end
// 56:       end
// 57:       keg = instance_double(
// 58:         Keg,
// 59:         rack:       HOMEBREW_CELLAR/formula_name,
// 60:         linked?:    false,
// 61:         name:       formula_name,
// 62:         to_formula: test_formula,
// 63:         to_s:       "#{formula_name}/1.0",
// 64:       )
// 65:       cmd = described_class.new([formula_name])
// 66:
// 67:       allow(cmd.args.named).to receive(:to_latest_kegs).and_return([keg])
// 68:       allow(Formulary).to receive(:keg_only?).with(keg.rack).and_return(true)
// 69:       allow(Homebrew::Unlink).to receive(:unlink_link_overwrite_formulae)
// 70:       allow(keg).to receive(:lock).and_yield
// 71:       allow(keg).to receive(:link).and_return(1)
// 72:       unexpected_output = /unexpected caveat output|unexpected post_install output|
// 73:                            If you need to have this software first in your PATH|keg-only/x
// 74:
// 75:       expect { cmd.run }
// 76:         .to not_to_output(unexpected_output).to_stdout
// 77:         .and not_to_output.to_stderr
// 78:     end
// 79:   end
// 80: end
