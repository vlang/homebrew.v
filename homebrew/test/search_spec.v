module test

import homebrew
import homebrew.utils as brew_utils

// Translated from Homebrew/brew `test/search_spec.rb`.
pub struct SearchSpecTab {
pub:
	installed_on_request bool
}

pub struct SearchSpecDependsOn {
pub:
	formulae []string
	casks    []string
}

pub struct SearchSpecApiFormula {
pub:
	description          string
	homepage             string
	license              string
	ruby_source_checksum string
	stable_url           string
	stable_version       string
}

pub struct SearchSpecApiCask {
pub:
	description string
	has_desc    bool
	names       []string
	sha256      string
	url         string
	version     string
}

fn search_spec_output_options() brew_utils.OutputOptions {
	return brew_utils.OutputOptions{
		tty: brew_utils.TtyState{
			stream_is_tty: true
		}
	}
}

fn search_spec_formula(deprecated bool, disabled bool, installed bool) homebrew.SearchFormula {
	return homebrew.SearchFormula{
		name: 'testball'
		full_name: 'testball'
		installed: installed
		valid_platform: true
		deprecated: deprecated
		disabled: disabled
	}
}

fn search_spec_formula_state(deprecated bool, disabled bool,
	installed bool) homebrew.SearchFormulaState {
	formula := search_spec_formula(deprecated, disabled, installed)
	return homebrew.SearchFormulaState{
		full_names: ['testball']
		formulae: {
			'testball': formula
		}
		output_options: search_spec_output_options()
	}
}

fn search_spec_cask(deprecated bool, disabled bool, installed bool,
	supports_linux bool) homebrew.SearchCask {
	return homebrew.SearchCask{
		token: 'testball'
		full_name: 'testball'
		installed: installed
		deprecated: deprecated
		disabled: disabled
		supports_linux: supports_linux
	}
}

fn search_spec_cask_state(deprecated bool, disabled bool, installed bool, supports_linux bool,
	host_linux bool) homebrew.SearchCaskState {
	cask := search_spec_cask(deprecated, disabled, installed, supports_linux)
	return homebrew.SearchCaskState{
		taps: [homebrew.SearchTap{
			cask_tokens: ['testball']
		}]
		casks: {
			'testball': cask
		}
		host_linux: host_linux
		output_options: search_spec_output_options()
	}
}

fn search_spec_short_name(values []string) []string {
	if values.len < 2 {
		return []string{}
	}
	return [values[1]]
}

fn search_spec_long_name(values []string) []string {
	if values.len == 0 {
		return []string{}
	}
	return [values[0]]
}

fn search_spec_api_formulae() map[string]SearchSpecApiFormula {
	return {
		'testball': SearchSpecApiFormula{
			description: 'Some test'
			homepage: 'https://brew.sh/testball'
			license: 'MIT'
			ruby_source_checksum: 'abc123'
			stable_url: 'https://brew.sh/testball-1.0.tar.gz'
			stable_version: '1.0'
		}
	}
}

fn search_spec_api_casks(has_desc bool) map[string]SearchSpecApiCask {
	return {
		'testball': SearchSpecApiCask{
			description: if has_desc { 'Some test' } else { '' }
			has_desc: has_desc
			names: ['Test Ball']
			sha256: 'abc123'
			url: 'https://brew.sh/testball.zip'
			version: '1.0'
		}
	}
}

fn search_spec_description_state(has_cask_desc bool,
	tap_trust_configured bool) homebrew.SearchDescriptionsState {
	formula_entries := {
		'testball': homebrew.description_formula('Some test')
	}
	cask_entries := {
		'testball': if has_cask_desc {
			homebrew.description_cask('Test Ball', 'Some test')
		} else {
			homebrew.description_cask('Test Ball', none)
		}
	}
	return homebrew.SearchDescriptionsState{
		tap_trust_configured: tap_trust_configured
		formula_api: formula_entries
		cask_api: cask_entries
		formula_cache: formula_entries
		cask_cache: cask_entries
		output_options: brew_utils.OutputOptions{}
	}
}

// Ruby it `it "correctly parses a regex query" do` at line 10.
pub fn ruby_search_spec_l10_d1_correctly() bool {
	query := homebrew.ruby_search_l39_d1_self_query_regexp('/^query\$/') or { return false }
	return query.is_regex && query.value == '^query\$'
}

// Ruby it `it "returns the original string if it is not a regex query" do` at line 14.
pub fn ruby_search_spec_l14_d2_returns() bool {
	query := homebrew.ruby_search_l39_d1_self_query_regexp('query') or { return false }
	return !query.is_regex && query.value == 'query'
}

// Ruby it `it "raises an error if the query is an invalid regex" do` at line 18.
pub fn ruby_search_spec_l18_d3_raises() bool {
	mut message := ''
	homebrew.ruby_search_l39_d1_self_query_regexp('/+/') or { message = err.msg() }
	return message.contains('not a valid regex')
}

// Ruby let `let(:collection) { ["with-dashes", "with@alpha", "with+plus"] }` at line 24.
pub fn ruby_search_spec_l24_d4_collection() []string {
	return ['with-dashes', 'with@alpha', 'with+plus']
}

// Ruby let `let(:collection) { [["with-dashes", "withdashes"]] }` at line 27.
pub fn ruby_search_spec_l27_d5_collection() [][]string {
	return [['with-dashes', 'withdashes']]
}

// Ruby it `it "searches by the selected argument" do` at line 29.
pub fn ruby_search_spec_l29_d6_searches() bool {
	collection := homebrew.search_row_collection(ruby_search_spec_l27_d5_collection())
	query := homebrew.SearchQuery{ value: 'withdashes', is_regex: true }
	short := homebrew.ruby_search_l223_d7_self_search(collection, query, search_spec_short_name) or {
		return false
	}
	long := homebrew.ruby_search_l223_d7_self_search(collection, query, search_spec_long_name) or {
		return false
	}
	return short.entries.len > 0 && long.entries.len == 0
}

// Ruby it `it "does not simplify strings" do` at line 36.
pub fn ruby_search_spec_l36_d7_does() bool {
	result := homebrew.ruby_search_l223_d7_self_search(homebrew.search_string_collection(ruby_search_spec_l24_d4_collection()), homebrew.SearchQuery{ value: 'with-dashes', is_regex: true }, homebrew.search_identity_projector) or { return false }
	return homebrew.search_collection_strings(result) == ['with-dashes']
}

// Ruby it `it "simplifies both the query and searched strings" do` at line 42.
pub fn ruby_search_spec_l42_d8_simplifies() bool {
	result := homebrew.ruby_search_l223_d7_self_search(homebrew.search_string_collection(ruby_search_spec_l24_d4_collection()), homebrew.SearchQuery{ value: 'with dashes' }, homebrew.search_identity_projector) or {
		return false
	}
	return homebrew.search_collection_strings(result) == ['with-dashes']
}

// Ruby it `it "does not simplify strings with @ and + characters" do` at line 46.
pub fn ruby_search_spec_l46_d9_does() bool {
	collection := homebrew.search_string_collection(ruby_search_spec_l24_d4_collection())
	alpha := homebrew.ruby_search_l223_d7_self_search(collection, homebrew.SearchQuery{ value: 'with@alpha' }, homebrew.search_identity_projector) or {
		return false
	}
	plus := homebrew.ruby_search_l223_d7_self_search(collection, homebrew.SearchQuery{ value: 'with+plus' }, homebrew.search_identity_projector) or {
		return false
	}
	return homebrew.search_collection_strings(alpha) == ['with@alpha'] && homebrew.search_collection_strings(plus) == [
		'with+plus',
	]
}

// Ruby let `let(:collection) { { "foo" => "bar" } }` at line 53.
pub fn ruby_search_spec_l53_d10_collection() homebrew.SearchCollection {
	return homebrew.SearchCollection{
		kind: .string_map
		entries: [homebrew.SearchEntry{
			key: 'foo'
			values: [homebrew.SearchOptionalString{ present: true, value: 'bar' }]
		}]
	}
}

// Ruby it `it "returns a Hash" do` at line 55.
pub fn ruby_search_spec_l55_d11_returns() bool {
	result := homebrew.ruby_search_l223_d7_self_search(ruby_search_spec_l53_d10_collection(), homebrew.SearchQuery{ value: 'foo' }, homebrew.search_identity_projector) or { return false }
	return result.kind == .string_map && result.entries == ruby_search_spec_l53_d10_collection().entries
}

// Ruby let `let(:collection) { { "foo" => nil } }` at line 60.
pub fn ruby_search_spec_l60_d12_collection() homebrew.SearchCollection {
	return homebrew.SearchCollection{
		kind: .string_map
		entries: [homebrew.SearchEntry{
			key: 'foo'
			values: [homebrew.SearchOptionalString{}]
		}]
	}
}

// Ruby it `it "does not raise an error" do` at line 62.
pub fn ruby_search_spec_l62_d13_does() bool {
	result := homebrew.ruby_search_l223_d7_self_search(ruby_search_spec_l60_d12_collection(), homebrew.SearchQuery{ value: 'foo' }, homebrew.search_identity_projector) or { return false }
	return result.entries == ruby_search_spec_l60_d12_collection().entries
}

// Ruby let `let(:tab) { instance_double(Tab, installed_on_request: false) }` at line 70.
pub fn ruby_search_spec_l70_d14_tab() SearchSpecTab {
	return SearchSpecTab{}
}

// Ruby let `let(:formula) do` at line 71.
pub fn ruby_search_spec_l71_d15_formula() homebrew.SearchFormula {
	return search_spec_formula(false, false, false)
}

// Ruby it `it "annotates deprecated formulae" do` at line 85.
pub fn ruby_search_spec_l85_d16_annotates() bool {
	result := homebrew.ruby_search_l118_d4_self_search_formulae(homebrew.SearchQuery{ value: 'testball', is_regex: true }, search_spec_formula_state(true, false, false)) or { return false }
	return result.len == 1 && result[0].contains('(deprecated)')
}

// Ruby it `it "annotates disabled formulae" do` at line 90.
pub fn ruby_search_spec_l90_d17_annotates() bool {
	result := homebrew.ruby_search_l118_d4_self_search_formulae(homebrew.SearchQuery{ value: 'testball', is_regex: true }, search_spec_formula_state(false, true, false)) or { return false }
	return result.len == 1 && result[0].contains('(disabled)')
}

// Ruby it `it "does not annotate normal formulae" do` at line 95.
pub fn ruby_search_spec_l95_d18_does() bool {
	result := homebrew.ruby_search_l118_d4_self_search_formulae(homebrew.SearchQuery{ value: 'testball', is_regex: true }, search_spec_formula_state(false, false, false)) or { return false }
	return result == ['testball']
}

// Ruby it `it "shows only the installed icon for installed formulae" do` at line 99.
pub fn ruby_search_spec_l99_d19_shows() bool {
	result := homebrew.ruby_search_l118_d4_self_search_formulae(homebrew.SearchQuery{ value: 'testball', is_regex: true }, search_spec_formula_state(false, false, true)) or { return false }
	return result == [
		brew_utils.pretty_installed('testball', search_spec_output_options()),
	]
}

// Ruby let `let(:depends_on) { instance_double(Cask::DSL::DependsOn, formula: [], cask: []) }` at line 108.
pub fn ruby_search_spec_l108_d20_depends_on() SearchSpecDependsOn {
	return SearchSpecDependsOn{}
}

// Ruby let `let(:tab) { instance_double(Cask::Tab, installed_on_request: false) }` at line 109.
pub fn ruby_search_spec_l109_d21_tab() SearchSpecTab {
	return SearchSpecTab{}
}

// Ruby let `let(:cask) do` at line 110.
pub fn ruby_search_spec_l110_d22_cask() homebrew.SearchCask {
	return search_spec_cask(false, false, false, true)
}

// Ruby it `it "annotates deprecated casks", :needs_macos do` at line 122.
pub fn ruby_search_spec_l122_d23_annotates() bool {
	result := homebrew.ruby_search_l160_d5_self_search_casks(homebrew.SearchQuery{ value: 'testball', is_regex: true }, search_spec_cask_state(true, false, false, true, false)) or { return false }
	return result.len == 1 && result[0].contains('(deprecated)')
}

// Ruby it `it "annotates disabled casks", :needs_macos do` at line 127.
pub fn ruby_search_spec_l127_d24_annotates() bool {
	result := homebrew.ruby_search_l160_d5_self_search_casks(homebrew.SearchQuery{ value: 'testball', is_regex: true }, search_spec_cask_state(false, true, false, true, false)) or { return false }
	return result.len == 1 && result[0].contains('(disabled)')
}

// Ruby it `it "does not annotate normal casks", :needs_macos do` at line 132.
pub fn ruby_search_spec_l132_d25_does() bool {
	result := homebrew.ruby_search_l160_d5_self_search_casks(homebrew.SearchQuery{ value: 'testball', is_regex: true }, search_spec_cask_state(false, false, false, true, false)) or { return false }
	return result == ['testball']
}

// Ruby it `it "hides macOS-only casks on Linux", :needs_linux do` at line 136.
pub fn ruby_search_spec_l136_d26_hides() bool {
	result := homebrew.ruby_search_l160_d5_self_search_casks(homebrew.SearchQuery{ value: 'testball', is_regex: true }, search_spec_cask_state(false, false, false, false, true)) or { return false }
	return result.len == 0
}

// Ruby it `it "shows Linux-compatible casks on Linux", :needs_linux do` at line 142.
pub fn ruby_search_spec_l142_d27_shows() bool {
	result := homebrew.ruby_search_l160_d5_self_search_casks(homebrew.SearchQuery{ value: 'testball', is_regex: true }, search_spec_cask_state(false, false, false, true, true)) or { return false }
	return result == ['testball']
}

// Ruby it `it "shows only the installed icon for installed casks", :needs_macos do` at line 146.
pub fn ruby_search_spec_l146_d28_shows() bool {
	result := homebrew.ruby_search_l160_d5_self_search_casks(homebrew.SearchQuery{ value: 'testball', is_regex: true }, search_spec_cask_state(false, false, true, true, false)) or { return false }
	return result == [
		brew_utils.pretty_installed('testball', search_spec_output_options()),
	]
}

// Ruby let `let(:args) { Homebrew::Cmd::Desc.new(["min_arg_placeholder"]).args }` at line 155.
pub fn ruby_search_spec_l155_d29_args() homebrew.SearchArgs {
	return homebrew.SearchArgs{}
}

// Ruby let `let(:api_formulae) do` at line 158.
pub fn ruby_search_spec_l158_d30_api_formulae() map[string]SearchSpecApiFormula {
	return search_spec_api_formulae()
}

// Ruby let `let(:api_casks) do` at line 171.
pub fn ruby_search_spec_l171_d31_api_casks() map[string]SearchSpecApiCask {
	return search_spec_api_casks(true)
}

// Ruby it `it "searches formula descriptions" do` at line 193.
pub fn ruby_search_spec_l193_d32_searches() bool {
	result := homebrew.ruby_search_l62_d3_self_search_descriptions(homebrew.SearchDescriptionsRequest{
		query: homebrew.SearchQuery{ value: 'some' }
		args: ruby_search_spec_l155_d29_args()
	}, search_spec_description_state(true, false)) or { return false }
	return result.stdout.contains('testball: Some test')
}

// Ruby it `it "searches all trusted descriptions with tap trust enabled" do` at line 198.
pub fn ruby_search_spec_l198_d33_searches() bool {
	result := homebrew.ruby_search_l62_d3_self_search_descriptions(homebrew.SearchDescriptionsRequest{
		query: homebrew.SearchQuery{ value: 'some' }
		args: homebrew.SearchArgs{ formula: true }
	}, search_spec_description_state(true, true)) or { return false }
	return result.calls == ['descriptions:formula:cache:eval_all=true']
}

// Ruby it `it "searches cask descriptions", :needs_macos do` at line 212.
pub fn ruby_search_spec_l212_d34_searches() bool {
	result := homebrew.ruby_search_l62_d3_self_search_descriptions(homebrew.SearchDescriptionsRequest{
		query: homebrew.SearchQuery{ value: 'ball' }
		args: ruby_search_spec_l155_d29_args()
	}, search_spec_description_state(true, false)) or { return false }
	return result.stdout.contains('testball: (Test Ball) Some test') && !result.stdout.contains('testball: Some test')
}

// Ruby it `it "searches cask names without descriptions", :needs_macos do` at line 218.
pub fn ruby_search_spec_l218_d35_searches() bool {
	result := homebrew.ruby_search_l62_d3_self_search_descriptions(homebrew.SearchDescriptionsRequest{
		query: homebrew.SearchQuery{ value: 'ball' }
		args: ruby_search_spec_l155_d29_args()
		show_missing: true
	}, search_spec_description_state(false, false)) or { return false }
	return result.stdout.contains('testball: (Test Ball) [no description]')
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "search"
// 5: require "descriptions"
// 6: require "cmd/desc"
// 7:
// 8: RSpec.describe Homebrew::Search do
// 9:   describe "#query_regexp" do
// 10:     it "correctly parses a regex query" do
// 11:       expect(described_class.query_regexp("/^query$/")).to eq(/^query$/)
// 12:     end
// 13:
// 14:     it "returns the original string if it is not a regex query" do
// 15:       expect(described_class.query_regexp("query")).to eq("query")
// 16:     end
// 17:
// 18:     it "raises an error if the query is an invalid regex" do
// 19:       expect { described_class.query_regexp("/+/") }.to raise_error(/not a valid regex/)
// 20:     end
// 21:   end
// 22:
// 23:   describe "#search" do
// 24:     let(:collection) { ["with-dashes", "with@alpha", "with+plus"] }
// 25:
// 26:     context "when given a block" do
// 27:       let(:collection) { [["with-dashes", "withdashes"]] }
// 28:
// 29:       it "searches by the selected argument" do
// 30:         expect(described_class.search(collection, /withdashes/) { |_, short_name| short_name }).not_to be_empty
// 31:         expect(described_class.search(collection, /withdashes/) { |long_name, _| long_name }).to be_empty
// 32:       end
// 33:     end
// 34:
// 35:     context "when given a regex" do
// 36:       it "does not simplify strings" do
// 37:         expect(described_class.search(collection, /with-dashes/)).to eq ["with-dashes"]
// 38:       end
// 39:     end
// 40:
// 41:     context "when given a string" do
// 42:       it "simplifies both the query and searched strings" do
// 43:         expect(described_class.search(collection, "with dashes")).to eq ["with-dashes"]
// 44:       end
// 45:
// 46:       it "does not simplify strings with @ and + characters" do
// 47:         expect(described_class.search(collection, "with@alpha")).to eq ["with@alpha"]
// 48:         expect(described_class.search(collection, "with+plus")).to eq ["with+plus"]
// 49:       end
// 50:     end
// 51:
// 52:     context "when searching a Hash" do
// 53:       let(:collection) { { "foo" => "bar" } }
// 54:
// 55:       it "returns a Hash" do
// 56:         expect(described_class.search(collection, "foo")).to eq "foo" => "bar"
// 57:       end
// 58:
// 59:       context "with a nil value" do
// 60:         let(:collection) { { "foo" => nil } }
// 61:
// 62:         it "does not raise an error" do
// 63:           expect(described_class.search(collection, "foo")).to eq "foo" => nil
// 64:         end
// 65:       end
// 66:     end
// 67:   end
// 68:
// 69:   describe "#search_formulae" do
// 70:     let(:tab) { instance_double(Tab, installed_on_request: false) }
// 71:     let(:formula) do
// 72:       instance_double(Formula, full_name: "testball", any_version_installed?: false,
// 73:                               valid_platform?: true, deprecated?: false, disabled?: false,
// 74:                               pinned?: false, requirements: [], deps: [],
// 75:                               runtime_installed_formula_dependents: [], stable: nil, head: nil, pour_bottle?: true)
// 76:     end
// 77:
// 78:     before do
// 79:       allow($stdout).to receive(:tty?).and_return(true)
// 80:       allow(Formula).to receive_messages(full_names: ["testball"], alias_full_names: [])
// 81:       allow(Formulary).to receive(:factory).with("testball").and_return(formula)
// 82:       allow(Tab).to receive(:for_formula).with(formula).and_return(tab)
// 83:     end
// 84:
// 85:     it "annotates deprecated formulae" do
// 86:       allow(formula).to receive(:deprecated?).and_return(true)
// 87:       expect(described_class.search_formulae(/testball/)).to contain_exactly(include("(deprecated)"))
// 88:     end
// 89:
// 90:     it "annotates disabled formulae" do
// 91:       allow(formula).to receive(:disabled?).and_return(true)
// 92:       expect(described_class.search_formulae(/testball/)).to contain_exactly(include("(disabled)"))
// 93:     end
// 94:
// 95:     it "does not annotate normal formulae" do
// 96:       expect(described_class.search_formulae(/testball/)).to eq(["testball"])
// 97:     end
// 98:
// 99:     it "shows only the installed icon for installed formulae" do
// 100:       allow(formula).to receive_messages(any_version_installed?: true, pinned?: true)
// 101:
// 102:       expect(described_class.search_formulae(/testball/))
// 103:         .to eq([described_class.pretty_installed("testball")])
// 104:     end
// 105:   end
// 106:
// 107:   describe "#search_casks" do
// 108:     let(:depends_on) { instance_double(Cask::DSL::DependsOn, formula: [], cask: []) }
// 109:     let(:tab) { instance_double(Cask::Tab, installed_on_request: false) }
// 110:     let(:cask) do
// 111:       instance_double(Cask::Cask, full_name: "testball", installed?: false, deprecated?: false, disabled?: false,
// 112:                                    supports_linux?: true, depends_on:)
// 113:     end
// 114:
// 115:     before do
// 116:       allow($stdout).to receive(:tty?).and_return(true)
// 117:       allow(Tap).to receive(:each_with_object).and_return(["testball"])
// 118:       allow(Cask::CaskLoader).to receive(:load).with("testball").and_return(cask)
// 119:       allow(Cask::Tab).to receive(:for_cask).with(cask).and_return(tab)
// 120:     end
// 121:
// 122:     it "annotates deprecated casks", :needs_macos do
// 123:       allow(cask).to receive(:deprecated?).and_return(true)
// 124:       expect(described_class.search_casks(/testball/)).to contain_exactly(include("(deprecated)"))
// 125:     end
// 126:
// 127:     it "annotates disabled casks", :needs_macos do
// 128:       allow(cask).to receive(:disabled?).and_return(true)
// 129:       expect(described_class.search_casks(/testball/)).to contain_exactly(include("(disabled)"))
// 130:     end
// 131:
// 132:     it "does not annotate normal casks", :needs_macos do
// 133:       expect(described_class.search_casks(/testball/)).to eq(["testball"])
// 134:     end
// 135:
// 136:     it "hides macOS-only casks on Linux", :needs_linux do
// 137:       allow(cask).to receive(:supports_linux?).and_return(false)
// 138:
// 139:       expect(described_class.search_casks(/testball/)).to eq([])
// 140:     end
// 141:
// 142:     it "shows Linux-compatible casks on Linux", :needs_linux do
// 143:       expect(described_class.search_casks(/testball/)).to eq(["testball"])
// 144:     end
// 145:
// 146:     it "shows only the installed icon for installed casks", :needs_macos do
// 147:       allow(cask).to receive(:installed?).and_return(true)
// 148:
// 149:       expect(described_class.search_casks(/testball/))
// 150:         .to eq([described_class.pretty_installed("testball")])
// 151:     end
// 152:   end
// 153:
// 154:   describe "#search_descriptions" do
// 155:     let(:args) { Homebrew::Cmd::Desc.new(["min_arg_placeholder"]).args }
// 156:
// 157:     context "with api" do
// 158:       let(:api_formulae) do
// 159:         {
// 160:           "testball" => {
// 161:             "desc"                 => "Some test",
// 162:             "homepage"             => "https://brew.sh/testball",
// 163:             "license"              => "MIT",
// 164:             "ruby_source_checksum" => "abc123",
// 165:             "stable_url_args"      => ["https://brew.sh/testball-1.0.tar.gz", {}],
// 166:             "stable_version"       => "1.0",
// 167:           },
// 168:         }
// 169:       end
// 170:
// 171:       let(:api_casks) do
// 172:         {
// 173:           "testball" => {
// 174:             "desc"    => "Some test",
// 175:             "names"   => ["Test Ball"],
// 176:             "sha256"  => "abc123",
// 177:             "url"     => "https://brew.sh/testball.zip",
// 178:             "version" => "1.0",
// 179:           },
// 180:         }
// 181:       end
// 182:
// 183:       before do
// 184:         allow(Homebrew::API::Internal).to receive_messages(formula_hashes: api_formulae, cask_hashes: api_casks)
// 185:         allow(Homebrew::API::Internal).to receive(:formula_names) { api_formulae.keys }
// 186:         allow(Homebrew::API::Internal).to receive(:formula_name?) { |name| api_formulae.key?(name) }
// 187:         allow(Homebrew::API::Internal).to receive(:formula_hash) { |name| api_formulae[name] }
// 188:         allow(Homebrew::API::Internal).to receive(:cask_names) { api_casks.keys }
// 189:         allow(Homebrew::API::Internal).to receive(:cask_name?) { |token| api_casks.key?(token) }
// 190:         allow(Homebrew::API::Internal).to receive(:cask_hash) { |token| api_casks[token] }
// 191:       end
// 192:
// 193:       it "searches formula descriptions" do
// 194:         expect { described_class.search_descriptions(described_class.query_regexp("some"), args) }
// 195:           .to output(/testball: Some test/).to_stdout
// 196:       end
// 197:
// 198:       it "searches all trusted descriptions with tap trust enabled" do
// 199:         cache_store = instance_double(DescriptionCacheStore)
// 200:         allow(DescriptionCacheStore).to receive(:new).and_return(cache_store)
// 201:         allow(CacheStoreDatabase).to receive(:use).with(:descriptions).and_yield(instance_double(CacheStoreDatabase))
// 202:         expect(Descriptions).to receive(:search)
// 203:           .with("some", Descriptions::SearchField::Description, cache_store, eval_all: true)
// 204:           .and_return(instance_double(Descriptions, print: nil))
// 205:
// 206:         with_env(HOMEBREW_REQUIRE_TAP_TRUST: "1") do
// 207:           args = Homebrew::Cmd::Desc.new(["--formula", "min_arg_placeholder"]).args
// 208:           described_class.search_descriptions("some", args)
// 209:         end
// 210:       end
// 211:
// 212:       it "searches cask descriptions", :needs_macos do
// 213:         expect { described_class.search_descriptions(described_class.query_regexp("ball"), args) }
// 214:           .to output(/testball: \(Test Ball\) Some test/).to_stdout
// 215:           .and not_to_output(/testball: Some test/).to_stdout
// 216:       end
// 217:
// 218:       it "searches cask names without descriptions", :needs_macos do
// 219:         api_casks["testball"]["desc"] = nil
// 220:
// 221:         expect do
// 222:           described_class.search_descriptions(described_class.query_regexp("ball"), args, show_missing: true)
// 223:         end
// 224:           .to output(/testball: \(Test Ball\) \[no description\]/).to_stdout
// 225:       end
// 226:     end
// 227:   end
// 228: end
