module rubocops

import brew_runtime
import homebrew.rubocops as unreferenced_core

// Translated from Homebrew/brew `test/rubocops/unreferenced_let_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn unreferenced_let_spec_bool(value bool) brew_runtime.Value {
	return brew_runtime.bool_value(value)
}

fn analyze_unreferenced_lets(source string) unreferenced_core.UnreferencedLetAnalysis {
	return unreferenced_core.analyze_unreferenced_lets(source)
}

fn unreferenced_let_definition_value(definition unreferenced_core.UnreferencedLetDefinition) brew_runtime.Value {
	return unreferenced_core.unreferenced_let_definition_value(definition)
}

fn unreferenced_let_spec_example(source string, names []string, correction string) brew_runtime.Value {
	analysis := analyze_unreferenced_lets(source)
	if analysis.offenses.map(it.name) != names {
		return unreferenced_let_spec_bool(false)
	}
	for offense in analysis.offenses {
		expected := 'Remove unreferenced `let(:${offense.name})` -- its name is never used, so the block never runs.'
		if offense.message != expected || offense.selector_end - offense.selector_begin != 3 {
			return unreferenced_let_spec_bool(false)
		}
	}
	return unreferenced_let_spec_bool(analysis.corrected == correction)
}

fn unreferenced_let_spec_no_offenses(source string) brew_runtime.Value {
	return unreferenced_let_spec_bool(analyze_unreferenced_lets(source).offenses.len == 0)
}

fn unreferenced_let_spec_definition(source string, name string, method string, occurrence int) brew_runtime.Value {
	analysis := analyze_unreferenced_lets(source)
	mut seen := 0
	for definition in analysis.definitions {
		if definition.name == name && definition.method == method {
			if seen == occurrence {
				return unreferenced_let_definition_value(definition)
			}
			seen++
		}
	}
	return brew_runtime.Value{ type_name: 'NilClass', repr: 'nil' }
}

fn unreferenced_let_spec_flags_source() string {
	return 'RSpec.describe Thing do\n  let(:unused) { create(:thing) }\n  let(:also_unused) { create(:other) }\n\n  it { expect(1).to eq(1) }\nend\n'
}

fn unreferenced_let_spec_sig_source() string {
	return 'RSpec.describe Thing do\n  sig { returns(Integer) }\n  let(:unused) { 1 }\n\n  it { expect(1).to eq(1) }\nend\n'
}

fn unreferenced_let_spec_numbered_source() string {
	return 'RSpec.describe Thing do\n  let(:unused) { create(_1) }\nend\n'
}

fn unreferenced_let_spec_comment_source() string {
	return 'RSpec.describe Thing do\n  let(:kept) { 1 }\n\n  # allows us to see the output\n  let(:unused) { false }\n\n  it { expect(kept).to eq(1) }\nend\n'
}

fn unreferenced_let_spec_final_let_source() string {
	return 'RSpec.describe Thing do\n  let(:kept) { 1 }\n  let(:unused) { 2 }\n\n  it { expect(kept).to eq(1) }\nend\n'
}

fn unreferenced_let_spec_directive_source() string {
	return 'RSpec.describe Thing do\n  # rubocop:disable Style/Something\n  let(:unused) { false }\n  # rubocop:enable Style/Something\nend\n'
}

fn unreferenced_let_spec_eager_source() string {
	return 'RSpec.describe Thing do\n  let!(:unused) { create(:thing) }\n\n  it { expect(1).to eq(1) }\nend\n'
}

fn unreferenced_let_spec_referenced_source() string {
	return 'RSpec.describe Thing do\n  let(:thing) { create(:thing) }\n\n  it { expect(thing).to be_present }\nend\n'
}

fn unreferenced_let_spec_reserved_source() string {
	return 'RSpec.describe RuboCop::Cop::Homebrew::SomeCop, :config do\n  let(:cop_config) { { "Enabled" => true } }\n\n  it { expect(1).to eq(1) }\nend\n'
}

fn unreferenced_let_spec_symbol_dispatch_source() string {
	return 'RSpec.describe Thing do\n  let(:thing) { create(:thing) }\n\n  it { expect(send(:thing)).to be_present }\nend\n'
}

fn unreferenced_let_spec_data_dispatch_source() string {
	return 'RSpec.describe Thing do\n  let(:special_formula) { build(:formula) }\n\n  it "dispatches by name" do\n    [[:special_formula, :pending]].each do |name, _state|\n      expect(send(name)).to be_present\n    end\n  end\nend\n'
}

fn unreferenced_let_spec_string_dispatch_source() string {
	return 'RSpec.describe Thing do\n  let(:special_formula) { build(:formula) }\n\n  it { expect(send("special_formula")).to be_present }\nend\n'
}

fn unreferenced_let_spec_heredoc_source() string {
	return 'RSpec.describe Thing do\n  let(:cutoff_date) { Date.today }\n  let(:query) do\n    <<~SQL\n      SELECT * FROM things WHERE created_at < cutoff_date\n    SQL\n  end\n\n  it { expect(described_class.run(query)).to be_present }\nend\n'
}

fn unreferenced_let_spec_interpolated_source() string {
	return 'RSpec.describe Thing do\n  let(:expected_dental_value) { 1 }\n\n  it "dispatches by interpolated name" do\n    %w[dental vision].each do |type|\n      expect(described_class.for(type)).to eq(send("expected_#{type}_value"))\n    end\n  end\nend\n'
}

fn unreferenced_let_spec_static_send_source() string {
	return 'RSpec.describe Thing do\n  let(:unused) { create(:thing) }\n\n  it { expect(send("other")).to be_present }\nend\n'
}

fn unreferenced_let_spec_invalid_utf8_source() string {
	return 'RSpec.describe Thing do\n  let(:unused) { String.new("\\xc2invalid", encoding: "UTF-8") }\n\n  it { expect(1).to eq(1) }\nend\n'
}

fn unreferenced_let_spec_override_source() string {
	return 'RSpec.describe Thing do\n  let(:value) { 1 }\n\n  context "nested" do\n    let!(:value) { 2 }\n\n    it { expect(1).to eq(1) }\n  end\nend\n'
}

fn unreferenced_let_spec_subject_override_source() string {
	return 'RSpec.describe Thing do\n  let(:described) { build(:thing) }\n\n  context "when active" do\n    subject(:described) { super().tap(&:activate) }\n\n    it { is_expected.to be_active }\n  end\nend\n'
}

fn unreferenced_let_spec_subject_source() string {
	return 'RSpec.describe Thing do\n  subject(:unused) { build(:thing) }\n\n  it { expect(1).to eq(1) }\nend\n'
}

fn unreferenced_let_spec_consumer_source() string {
	return 'RSpec.describe Thing do\n  let(:unused) { create(:thing) }\n\n  it_behaves_like "a thing"\nend\n'
}

fn unreferenced_let_spec_inside_shared_source() string {
	return 'RSpec.shared_examples "a thing" do\n  let(:unused_inner) { create(:thing) }\n\n  it { expect(1).to eq(1) }\nend\n'
}

fn unreferenced_let_spec_outside_shared_source() string {
	return 'RSpec.describe Thing do\n  let(:unused) { create(:thing) }\n\n  shared_examples "a thing" do\n    it { expect(1).to eq(1) }\n  end\nend\n'
}

fn unreferenced_let_spec_dynamic_name_source() string {
	return 'RSpec.describe Thing do\n  name = :dynamic\n  let(name) { create(:thing) }\n  let { create(:thing) }\nend\n'
}

fn unreferenced_let_spec_no_block_source() string {
	return 'RSpec.describe Thing do\n  let(:unused)\nend\n'
}

fn unreferenced_let_spec_receiver_source() string {
	return 'RSpec.describe Thing do\n  config.let(:unused) { create(:thing) }\nend\n'
}

// Ruby let `let(:other_cops) do` at line 11.
pub fn ruby_unreferenced_let_spec_l11_d1_other_cops(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.map_value({
		'RSpec': brew_runtime.map_value({
			'Language': brew_runtime.map_value({})
		})
	})
}

// Ruby it `it "flags and removes unreferenced lazy lets" do` at line 20.
pub fn ruby_unreferenced_let_spec_l20_d2_flags(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_example(unreferenced_let_spec_flags_source(), [
		'unused',
		'also_unused',
	], 'RSpec.describe Thing do\n\n  it { expect(1).to eq(1) }\nend\n')
}

// Ruby let `let(:unused) { create(:thing) }` at line 23.
pub fn ruby_unreferenced_let_spec_l23_d3_unused(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_definition(unreferenced_let_spec_flags_source(), 'unused', 'let', 0)
}

// Ruby let `let(:also_unused) { create(:other) }` at line 25.
pub fn ruby_unreferenced_let_spec_l25_d4_also_unused(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_definition(unreferenced_let_spec_flags_source(), 'also_unused', 'let', 0)
}

// Ruby it `it { expect(1).to eq(1) }` at line 28.
pub fn ruby_unreferenced_let_spec_l28_d5_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	analysis := analyze_unreferenced_lets(unreferenced_let_spec_flags_source())
	return unreferenced_let_spec_bool(1 == 1 && analysis.offenses.len == 2)
}

// Ruby it `it { expect(1).to eq(1) }` at line 35.
pub fn ruby_unreferenced_let_spec_l35_d6_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_bool(analyze_unreferenced_lets(unreferenced_let_spec_flags_source()).corrected.contains('expect(1).to eq(1)'))
}

// Ruby it `it "removes a preceding Sorbet signature along with the let" do` at line 40.
pub fn ruby_unreferenced_let_spec_l40_d7_removes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_example(unreferenced_let_spec_sig_source(), ['unused'], 'RSpec.describe Thing do\n  it { expect(1).to eq(1) }\nend\n')
}

// Ruby let `let(:unused) { 1 }` at line 44.
pub fn ruby_unreferenced_let_spec_l44_d8_unused(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_definition(unreferenced_let_spec_sig_source(), 'unused', 'let', 0)
}

// Ruby it `it { expect(1).to eq(1) }` at line 47.
pub fn ruby_unreferenced_let_spec_l47_d9_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	analysis := analyze_unreferenced_lets(unreferenced_let_spec_sig_source())
	return unreferenced_let_spec_bool(analysis.offenses.len == 1 && analysis.offenses[0].removal.first_line == 1)
}

// Ruby it `it { expect(1).to eq(1) }` at line 53.
pub fn ruby_unreferenced_let_spec_l53_d10_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_bool(!analyze_unreferenced_lets(unreferenced_let_spec_sig_source()).corrected.contains('sig'))
}

// Ruby it `it "flags an unreferenced let written as a numbered-parameter block" do` at line 58.
pub fn ruby_unreferenced_let_spec_l58_d11_flags(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_example(unreferenced_let_spec_numbered_source(), [
		'unused',
	], 'RSpec.describe Thing do\nend\n')
}

// Ruby let `let(:unused) { create(_1) }` at line 61.
pub fn ruby_unreferenced_let_spec_l61_d12_unused(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_definition(unreferenced_let_spec_numbered_source(), 'unused', 'let', 0)
}

// Ruby it `it "removes an explanatory comment attached directly above the let" do` at line 72.
pub fn ruby_unreferenced_let_spec_l72_d13_removes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_example(unreferenced_let_spec_comment_source(), [
		'unused',
	], 'RSpec.describe Thing do\n  let(:kept) { 1 }\n\n  it { expect(kept).to eq(1) }\nend\n')
}

// Ruby let `let(:kept) { 1 }` at line 75.
pub fn ruby_unreferenced_let_spec_l75_d14_kept(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_definition(unreferenced_let_spec_comment_source(), 'kept', 'let', 0)
}

// Ruby let `let(:unused) { false }` at line 78.
pub fn ruby_unreferenced_let_spec_l78_d15_unused(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_definition(unreferenced_let_spec_comment_source(), 'unused', 'let', 0)
}

// Ruby it `it { expect(kept).to eq(1) }` at line 81.
pub fn ruby_unreferenced_let_spec_l81_d16_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	analysis := analyze_unreferenced_lets(unreferenced_let_spec_comment_source())
	return unreferenced_let_spec_bool('kept' in analysis.referenced_names && !analysis.corrected.contains('allows us to see'))
}

// Ruby let `let(:kept) { 1 }` at line 89.
pub fn ruby_unreferenced_let_spec_l89_d17_kept(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_definition(unreferenced_let_spec_comment_source(), 'kept', 'let', 0)
}

// Ruby it `it { expect(kept).to eq(1) }` at line 91.
pub fn ruby_unreferenced_let_spec_l91_d18_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_bool(analyze_unreferenced_lets(unreferenced_let_spec_comment_source()).corrected.contains('expect(kept).to eq(1)'))
}

// Ruby it `it "consumes a trailing blank at a block-body edge but keeps the blank after a final let" do` at line 96.
pub fn ruby_unreferenced_let_spec_l96_d19_consumes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_example(unreferenced_let_spec_final_let_source(), [
		'unused',
	], 'RSpec.describe Thing do\n  let(:kept) { 1 }\n\n  it { expect(kept).to eq(1) }\nend\n')
}

// Ruby let `let(:kept) { 1 }` at line 99.
pub fn ruby_unreferenced_let_spec_l99_d20_kept(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_definition(unreferenced_let_spec_final_let_source(), 'kept', 'let', 0)
}

// Ruby let `let(:unused) { 2 }` at line 100.
pub fn ruby_unreferenced_let_spec_l100_d21_unused(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_definition(unreferenced_let_spec_final_let_source(), 'unused', 'let', 0)
}

// Ruby it `it { expect(kept).to eq(1) }` at line 103.
pub fn ruby_unreferenced_let_spec_l103_d22_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	corrected := analyze_unreferenced_lets(unreferenced_let_spec_final_let_source()).corrected
	return unreferenced_let_spec_bool(corrected.contains('let(:kept) { 1 }\n\n  it'))
}

// Ruby let `let(:kept) { 1 }` at line 110.
pub fn ruby_unreferenced_let_spec_l110_d23_kept(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_definition(unreferenced_let_spec_final_let_source(), 'kept', 'let', 0)
}

// Ruby it `it { expect(kept).to eq(1) }` at line 112.
pub fn ruby_unreferenced_let_spec_l112_d24_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_bool(analyze_unreferenced_lets(unreferenced_let_spec_final_let_source()).corrected.contains('expect(kept).to eq(1)'))
}

// Ruby it `it "does not absorb a rubocop directive comment above the let" do` at line 117.
pub fn ruby_unreferenced_let_spec_l117_d25_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_example(unreferenced_let_spec_directive_source(), [
		'unused',
	], 'RSpec.describe Thing do\n  # rubocop:disable Style/Something\n  # rubocop:enable Style/Something\nend\n')
}

// Ruby let `let(:unused) { false }` at line 121.
pub fn ruby_unreferenced_let_spec_l121_d26_unused(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_definition(unreferenced_let_spec_directive_source(), 'unused', 'let', 0)
}

// Ruby it `it "does not flag an eager let! (out of scope)" do` at line 135.
pub fn ruby_unreferenced_let_spec_l135_d27_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_no_offenses(unreferenced_let_spec_eager_source())
}

// Ruby let! `let!(:unused) { create(:thing) }` at line 138.
pub fn ruby_unreferenced_let_spec_l138_d28_unused(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_definition(unreferenced_let_spec_eager_source(), 'unused', 'let!', 0)
}

// Ruby it `it { expect(1).to eq(1) }` at line 140.
pub fn ruby_unreferenced_let_spec_l140_d29_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_bool(1 == 1 && analyze_unreferenced_lets(unreferenced_let_spec_eager_source()).offenses.len == 0)
}

// Ruby it `it "does not flag a referenced lazy let" do` at line 145.
pub fn ruby_unreferenced_let_spec_l145_d30_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_no_offenses(unreferenced_let_spec_referenced_source())
}

// Ruby let `let(:thing) { create(:thing) }` at line 148.
pub fn ruby_unreferenced_let_spec_l148_d31_thing(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_definition(unreferenced_let_spec_referenced_source(), 'thing', 'let', 0)
}

// Ruby it `it { expect(thing).to be_present }` at line 150.
pub fn ruby_unreferenced_let_spec_l150_d32_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_bool('thing' in analyze_unreferenced_lets(unreferenced_let_spec_referenced_source()).referenced_names)
}

// Ruby it `it "does not flag `let(:cop_config)` (a rubocop-rspec framework contract)" do` at line 155.
pub fn ruby_unreferenced_let_spec_l155_d33_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_no_offenses(unreferenced_let_spec_reserved_source())
}

// Ruby let `let(:cop_config) { { "Enabled" => true } }` at line 158.
pub fn ruby_unreferenced_let_spec_l158_d34_cop_config(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_definition(unreferenced_let_spec_reserved_source(), 'cop_config', 'let', 0)
}

// Ruby it `it { expect(1).to eq(1) }` at line 160.
pub fn ruby_unreferenced_let_spec_l160_d35_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_bool(1 == 1 && analyze_unreferenced_lets(unreferenced_let_spec_reserved_source()).offenses.len == 0)
}

// Ruby it `it "does not flag a let referenced via dynamic dispatch" do` at line 165.
pub fn ruby_unreferenced_let_spec_l165_d36_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_no_offenses(unreferenced_let_spec_symbol_dispatch_source())
}

// Ruby let `let(:thing) { create(:thing) }` at line 168.
pub fn ruby_unreferenced_let_spec_l168_d37_thing(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_definition(unreferenced_let_spec_symbol_dispatch_source(), 'thing', 'let', 0)
}

// Ruby it `it { expect(send(:thing)).to be_present }` at line 170.
pub fn ruby_unreferenced_let_spec_l170_d38_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	analysis := analyze_unreferenced_lets(unreferenced_let_spec_symbol_dispatch_source())
	return unreferenced_let_spec_bool('thing' in analysis.referenced_names && !analysis.dynamic_dispatch)
}

// Ruby it `it "does not flag a let referenced only as a symbol literal (data-table dispatch)" do` at line 175.
pub fn ruby_unreferenced_let_spec_l175_d39_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_no_offenses(unreferenced_let_spec_data_dispatch_source())
}

// Ruby let `let(:special_formula) { build(:formula) }` at line 178.
pub fn ruby_unreferenced_let_spec_l178_d40_special_formula(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_definition(unreferenced_let_spec_data_dispatch_source(), 'special_formula', 'let', 0)
}

// Ruby it `it "dispatches by name" do` at line 180.
pub fn ruby_unreferenced_let_spec_l180_d41_dispatches(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	analysis := analyze_unreferenced_lets(unreferenced_let_spec_data_dispatch_source())
	return unreferenced_let_spec_bool('special_formula' in analysis.referenced_names && analysis.dynamic_dispatch)
}

// Ruby it `it "does not flag a let referenced only as a string literal (string dispatch)" do` at line 189.
pub fn ruby_unreferenced_let_spec_l189_d42_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_no_offenses(unreferenced_let_spec_string_dispatch_source())
}

// Ruby let `let(:special_formula) { build(:formula) }` at line 192.
pub fn ruby_unreferenced_let_spec_l192_d43_special_formula(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_definition(unreferenced_let_spec_string_dispatch_source(), 'special_formula', 'let', 0)
}

// Ruby it `it { expect(send("special_formula")).to be_present }` at line 194.
pub fn ruby_unreferenced_let_spec_l194_d44_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	analysis := analyze_unreferenced_lets(unreferenced_let_spec_string_dispatch_source())
	return unreferenced_let_spec_bool('special_formula' in analysis.referenced_names && !analysis.dynamic_dispatch)
}

// Ruby it `it "does not flag a let referenced only inside a heredoc body" do` at line 199.
pub fn ruby_unreferenced_let_spec_l199_d45_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_no_offenses(unreferenced_let_spec_heredoc_source())
}

// Ruby let `let(:cutoff_date) { Date.today }` at line 202.
pub fn ruby_unreferenced_let_spec_l202_d46_cutoff_date(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_definition(unreferenced_let_spec_heredoc_source(), 'cutoff_date', 'let', 0)
}

// Ruby let `let(:query) do` at line 203.
pub fn ruby_unreferenced_let_spec_l203_d47_query(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_definition(unreferenced_let_spec_heredoc_source(), 'query', 'let', 0)
}

// Ruby it `it { expect(described_class.run(query)).to be_present }` at line 209.
pub fn ruby_unreferenced_let_spec_l209_d48_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	names := analyze_unreferenced_lets(unreferenced_let_spec_heredoc_source()).referenced_names
	return unreferenced_let_spec_bool('cutoff_date' in names && 'query' in names)
}

// Ruby it `it "skips every let in a file that dispatches through an interpolated string" do` at line 214.
pub fn ruby_unreferenced_let_spec_l214_d49_skips(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	analysis := analyze_unreferenced_lets(unreferenced_let_spec_interpolated_source())
	return unreferenced_let_spec_bool(analysis.dynamic_dispatch && analysis.offenses.len == 0)
}

// Ruby let `let(:expected_dental_value) { 1 }` at line 217.
pub fn ruby_unreferenced_let_spec_l217_d50_expected_dental_value(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_definition(unreferenced_let_spec_interpolated_source(), 'expected_dental_value', 'let', 0)
}

// Ruby it `it "dispatches by interpolated name" do` at line 219.
pub fn ruby_unreferenced_let_spec_l219_d51_dispatches(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_bool(analyze_unreferenced_lets(unreferenced_let_spec_interpolated_source()).dynamic_dispatch)
}

// Ruby it `it "still flags a dead let in a file whose only send target is a static string" do` at line 228.
pub fn ruby_unreferenced_let_spec_l228_d52_still(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_example(unreferenced_let_spec_static_send_source(), [
		'unused',
	], 'RSpec.describe Thing do\n  it { expect(send("other")).to be_present }\nend\n')
}

// Ruby let `let(:unused) { create(:thing) }` at line 231.
pub fn ruby_unreferenced_let_spec_l231_d53_unused(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_definition(unreferenced_let_spec_static_send_source(), 'unused', 'let', 0)
}

// Ruby it `it { expect(send("other")).to be_present }` at line 234.
pub fn ruby_unreferenced_let_spec_l234_d54_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	analysis := analyze_unreferenced_lets(unreferenced_let_spec_static_send_source())
	return unreferenced_let_spec_bool('other' in analysis.referenced_names && !analysis.dynamic_dispatch && analysis.offenses.len == 1)
}

// Ruby it `it { expect(send("other")).to be_present }` at line 240.
pub fn ruby_unreferenced_let_spec_l240_d55_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_bool(analyze_unreferenced_lets(unreferenced_let_spec_static_send_source()).corrected.contains('send("other")'))
}

// Ruby it `it "does not crash on a let whose block contains an invalid-UTF-8 string literal" do` at line 245.
pub fn ruby_unreferenced_let_spec_l245_d56_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_example(unreferenced_let_spec_invalid_utf8_source(), [
		'unused',
	], 'RSpec.describe Thing do\n  it { expect(1).to eq(1) }\nend\n')
}

// Ruby let `let(:unused) { String.new("\xc2invalid", encoding: "UTF-8") }` at line 248.
pub fn ruby_unreferenced_let_spec_l248_d57_unused(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_definition(unreferenced_let_spec_invalid_utf8_source(), 'unused', 'let', 0)
}

// Ruby it `it { expect(1).to eq(1) }` at line 251.
pub fn ruby_unreferenced_let_spec_l251_d58_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_bool(analyze_unreferenced_lets(unreferenced_let_spec_invalid_utf8_source()).offenses.len == 1)
}

// Ruby it `it { expect(1).to eq(1) }` at line 257.
pub fn ruby_unreferenced_let_spec_l257_d59_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_bool(analyze_unreferenced_lets(unreferenced_let_spec_invalid_utf8_source()).corrected.contains('expect(1).to eq(1)'))
}

// Ruby it `it "does not flag a name defined by more than one let/let! (override / super chain)" do` at line 262.
pub fn ruby_unreferenced_let_spec_l262_d60_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	analysis := analyze_unreferenced_lets(unreferenced_let_spec_override_source())
	return unreferenced_let_spec_bool(analysis.definitions_by_name['value'] == 2 && analysis.offenses.len == 0)
}

// Ruby let `let(:value) { 1 }` at line 265.
pub fn ruby_unreferenced_let_spec_l265_d61_value(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_definition(unreferenced_let_spec_override_source(), 'value', 'let', 0)
}

// Ruby let! `let!(:value) { 2 }` at line 268.
pub fn ruby_unreferenced_let_spec_l268_d62_value(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_definition(unreferenced_let_spec_override_source(), 'value', 'let!', 0)
}

// Ruby it `it { expect(1).to eq(1) }` at line 270.
pub fn ruby_unreferenced_let_spec_l270_d63_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_bool(1 == 1 && analyze_unreferenced_lets(unreferenced_let_spec_override_source()).offenses.len == 0)
}

// Ruby it `it "does not flag a let overridden by a subject of the same name (super chain)" do` at line 276.
pub fn ruby_unreferenced_let_spec_l276_d64_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	analysis := analyze_unreferenced_lets(unreferenced_let_spec_subject_override_source())
	return unreferenced_let_spec_bool(analysis.definitions_by_name['described'] == 2 && analysis.offenses.len == 0)
}

// Ruby let `let(:described) { build(:thing) }` at line 279.
pub fn ruby_unreferenced_let_spec_l279_d65_described(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_definition(unreferenced_let_spec_subject_override_source(), 'described', 'let', 0)
}

// Ruby subject `subject(:described) { super().tap(&:activate) }` at line 282.
pub fn ruby_unreferenced_let_spec_l282_d66_described(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_definition(unreferenced_let_spec_subject_override_source(), 'described', 'subject', 0)
}

// Ruby it `it { is_expected.to be_active }` at line 284.
pub fn ruby_unreferenced_let_spec_l284_d67_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_bool(analyze_unreferenced_lets(unreferenced_let_spec_subject_override_source()).offenses.len == 0)
}

// Ruby it `it "does not flag an unreferenced subject (only lazy let is in scope)" do` at line 290.
pub fn ruby_unreferenced_let_spec_l290_d68_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_no_offenses(unreferenced_let_spec_subject_source())
}

// Ruby subject `subject(:unused) { build(:thing) }` at line 293.
pub fn ruby_unreferenced_let_spec_l293_d69_unused(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_definition(unreferenced_let_spec_subject_source(), 'unused', 'subject', 0)
}

// Ruby it `it { expect(1).to eq(1) }` at line 295.
pub fn ruby_unreferenced_let_spec_l295_d70_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_bool(1 == 1 && analyze_unreferenced_lets(unreferenced_let_spec_subject_source()).offenses.len == 0)
}

// Ruby it `it "skips every let in a file that consumes shared examples" do` at line 300.
pub fn ruby_unreferenced_let_spec_l300_d71_skips(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	analysis := analyze_unreferenced_lets(unreferenced_let_spec_consumer_source())
	return unreferenced_let_spec_bool(analysis.consumes_shared_examples && analysis.offenses.len == 0)
}

// Ruby let `let(:unused) { create(:thing) }` at line 303.
pub fn ruby_unreferenced_let_spec_l303_d72_unused(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_definition(unreferenced_let_spec_consumer_source(), 'unused', 'let', 0)
}

// Ruby it `it "skips a let declared inside a shared example definition" do` at line 310.
pub fn ruby_unreferenced_let_spec_l310_d73_skips(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	analysis := analyze_unreferenced_lets(unreferenced_let_spec_inside_shared_source())
	return unreferenced_let_spec_bool(analysis.definitions.len == 1 && analysis.definitions[0].within_shared && analysis.offenses.len == 0)
}

// Ruby let `let(:unused_inner) { create(:thing) }` at line 313.
pub fn ruby_unreferenced_let_spec_l313_d74_unused_inner(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_definition(unreferenced_let_spec_inside_shared_source(), 'unused_inner', 'let', 0)
}

// Ruby it `it { expect(1).to eq(1) }` at line 315.
pub fn ruby_unreferenced_let_spec_l315_d75_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_bool(1 == 1 && analyze_unreferenced_lets(unreferenced_let_spec_inside_shared_source()).offenses.len == 0)
}

// Ruby it `it "still flags an unreferenced let declared outside a shared example definition" do` at line 320.
pub fn ruby_unreferenced_let_spec_l320_d76_still(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_example(unreferenced_let_spec_outside_shared_source(), [
		'unused',
	], 'RSpec.describe Thing do\n  shared_examples "a thing" do\n    it { expect(1).to eq(1) }\n  end\nend\n')
}

// Ruby let `let(:unused) { create(:thing) }` at line 323.
pub fn ruby_unreferenced_let_spec_l323_d77_unused(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_definition(unreferenced_let_spec_outside_shared_source(), 'unused', 'let', 0)
}

// Ruby it `it { expect(1).to eq(1) }` at line 327.
pub fn ruby_unreferenced_let_spec_l327_d78_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_bool(analyze_unreferenced_lets(unreferenced_let_spec_outside_shared_source()).offenses.len == 1)
}

// Ruby it `it { expect(1).to eq(1) }` at line 335.
pub fn ruby_unreferenced_let_spec_l335_d79_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_bool(analyze_unreferenced_lets(unreferenced_let_spec_outside_shared_source()).corrected.contains('shared_examples "a thing"'))
}

// Ruby it `it "ignores let declarations without a symbol name" do` at line 341.
pub fn ruby_unreferenced_let_spec_l341_d80_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	analysis := analyze_unreferenced_lets(unreferenced_let_spec_dynamic_name_source())
	return unreferenced_let_spec_bool(analysis.definitions.len == 2 && analysis.definitions.all(!it.has_symbol_name) && analysis.offenses.len == 0)
}

// Ruby let `let(name) { create(:thing) }` at line 345.
pub fn ruby_unreferenced_let_spec_l345_d81_thing(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	definitions := analyze_unreferenced_lets(unreferenced_let_spec_dynamic_name_source()).definitions
	return if definitions.len > 0 {
		unreferenced_let_definition_value(definitions[0])
	} else {
		brew_runtime.Value{ type_name: 'NilClass', repr: 'nil' }
	}
}

// Ruby let `let { create(:thing) }` at line 346.
pub fn ruby_unreferenced_let_spec_l346_d82_thing(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	definitions := analyze_unreferenced_lets(unreferenced_let_spec_dynamic_name_source()).definitions
	return if definitions.len > 1 {
		unreferenced_let_definition_value(definitions[1])
	} else {
		brew_runtime.Value{ type_name: 'NilClass', repr: 'nil' }
	}
}

// Ruby it `it "ignores a let call with no block" do` at line 351.
pub fn ruby_unreferenced_let_spec_l351_d83_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	analysis := analyze_unreferenced_lets(unreferenced_let_spec_no_block_source())
	return unreferenced_let_spec_bool(analysis.definitions.len == 1 && !analysis.definitions[0].has_block && analysis.offenses.len == 0)
}

// Ruby let `let(:unused)` at line 354.
pub fn ruby_unreferenced_let_spec_l354_d84_unused(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return unreferenced_let_spec_definition(unreferenced_let_spec_no_block_source(), 'unused', 'let', 0)
}

// Ruby it `it "ignores a let-like call with an explicit receiver" do` at line 359.
pub fn ruby_unreferenced_let_spec_l359_d85_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	analysis := analyze_unreferenced_lets(unreferenced_let_spec_receiver_source())
	return unreferenced_let_spec_bool(analysis.definitions.len == 0 && analysis.offenses.len == 0)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "yaml"
// 5: require "rubocops/unreferenced_let"
// 6:
// 7: RSpec.describe RuboCop::Cop::Homebrew::UnreferencedLet, :config do
// 8:   # `RSpec::Base#on_new_investigation` reads `config["RSpec"]["Language"]` to drive the RSpec DSL
// 9:   # matchers (`shared_group?`, `include?`). A full `brew style` run merges that from rubocop-rspec's
// 10:   # plugin config, but the isolated cop spec does not, so supply it from the gem's `default.yml`.
// 11:   let(:other_cops) do
// 12:     language_matcher_source, = RuboCop::RSpec::Language.instance_method(:include?).source_location
// 13:     language = YAML.safe_load_file(
// 14:       File.expand_path("../../../../config/default.yml", language_matcher_source),
// 15:       permitted_classes: [Regexp, Symbol], aliases: true,
// 16:     ).fetch("RSpec").fetch("Language")
// 17:     { "RSpec" => { "Language" => language } }
// 18:   end
// 19:
// 20:   it "flags and removes unreferenced lazy lets" do
// 21:     expect_offense(<<~RUBY)
// 22:       RSpec.describe Thing do
// 23:         let(:unused) { create(:thing) }
// 24:         ^^^ Remove unreferenced `let(:unused)` -- its name is never used, so the block never runs.
// 25:         let(:also_unused) { create(:other) }
// 26:         ^^^ Remove unreferenced `let(:also_unused)` -- its name is never used, so the block never runs.
// 27:
// 28:         it { expect(1).to eq(1) }
// 29:       end
// 30:     RUBY
// 31:
// 32:     expect_correction(<<~RUBY)
// 33:       RSpec.describe Thing do
// 34:
// 35:         it { expect(1).to eq(1) }
// 36:       end
// 37:     RUBY
// 38:   end
// 39:
// 40:   it "removes a preceding Sorbet signature along with the let" do
// 41:     expect_offense(<<~RUBY)
// 42:       RSpec.describe Thing do
// 43:         sig { returns(Integer) }
// 44:         let(:unused) { 1 }
// 45:         ^^^ Remove unreferenced `let(:unused)` -- its name is never used, so the block never runs.
// 46:
// 47:         it { expect(1).to eq(1) }
// 48:       end
// 49:     RUBY
// 50:
// 51:     expect_correction(<<~RUBY)
// 52:       RSpec.describe Thing do
// 53:         it { expect(1).to eq(1) }
// 54:       end
// 55:     RUBY
// 56:   end
// 57:
// 58:   it "flags an unreferenced let written as a numbered-parameter block" do
// 59:     expect_offense(<<~RUBY)
// 60:       RSpec.describe Thing do
// 61:         let(:unused) { create(_1) }
// 62:         ^^^ Remove unreferenced `let(:unused)` -- its name is never used, so the block never runs.
// 63:       end
// 64:     RUBY
// 65:
// 66:     expect_correction(<<~RUBY)
// 67:       RSpec.describe Thing do
// 68:       end
// 69:     RUBY
// 70:   end
// 71:
// 72:   it "removes an explanatory comment attached directly above the let" do
// 73:     expect_offense(<<~RUBY)
// 74:       RSpec.describe Thing do
// 75:         let(:kept) { 1 }
// 76:
// 77:         # allows us to see the output
// 78:         let(:unused) { false }
// 79:         ^^^ Remove unreferenced `let(:unused)` -- its name is never used, so the block never runs.
// 80:
// 81:         it { expect(kept).to eq(1) }
// 82:       end
// 83:     RUBY
// 84:
// 85:     # The comment + let are removed, and the now-duplicate trailing blank is consumed so no
// 86:     # stray blank is left behind.
// 87:     expect_correction(<<~RUBY)
// 88:       RSpec.describe Thing do
// 89:         let(:kept) { 1 }
// 90:
// 91:         it { expect(kept).to eq(1) }
// 92:       end
// 93:     RUBY
// 94:   end
// 95:
// 96:   it "consumes a trailing blank at a block-body edge but keeps the blank after a final let" do
// 97:     expect_offense(<<~RUBY)
// 98:       RSpec.describe Thing do
// 99:         let(:kept) { 1 }
// 100:         let(:unused) { 2 }
// 101:         ^^^ Remove unreferenced `let(:unused)` -- its name is never used, so the block never runs.
// 102:
// 103:         it { expect(kept).to eq(1) }
// 104:       end
// 105:     RUBY
// 106:
// 107:     # `let(:kept)` precedes the removal, so the blank after it (the final-let separator) stays.
// 108:     expect_correction(<<~RUBY)
// 109:       RSpec.describe Thing do
// 110:         let(:kept) { 1 }
// 111:
// 112:         it { expect(kept).to eq(1) }
// 113:       end
// 114:     RUBY
// 115:   end
// 116:
// 117:   it "does not absorb a rubocop directive comment above the let" do
// 118:     expect_offense(<<~RUBY)
// 119:       RSpec.describe Thing do
// 120:         # rubocop:disable Style/Something
// 121:         let(:unused) { false }
// 122:         ^^^ Remove unreferenced `let(:unused)` -- its name is never used, so the block never runs.
// 123:         # rubocop:enable Style/Something
// 124:       end
// 125:     RUBY
// 126:
// 127:     expect_correction(<<~RUBY)
// 128:       RSpec.describe Thing do
// 129:         # rubocop:disable Style/Something
// 130:         # rubocop:enable Style/Something
// 131:       end
// 132:     RUBY
// 133:   end
// 134:
// 135:   it "does not flag an eager let! (out of scope)" do
// 136:     expect_no_offenses(<<~RUBY)
// 137:       RSpec.describe Thing do
// 138:         let!(:unused) { create(:thing) }
// 139:
// 140:         it { expect(1).to eq(1) }
// 141:       end
// 142:     RUBY
// 143:   end
// 144:
// 145:   it "does not flag a referenced lazy let" do
// 146:     expect_no_offenses(<<~RUBY)
// 147:       RSpec.describe Thing do
// 148:         let(:thing) { create(:thing) }
// 149:
// 150:         it { expect(thing).to be_present }
// 151:       end
// 152:     RUBY
// 153:   end
// 154:
// 155:   it "does not flag `let(:cop_config)` (a rubocop-rspec framework contract)" do
// 156:     expect_no_offenses(<<~RUBY)
// 157:       RSpec.describe RuboCop::Cop::Homebrew::SomeCop, :config do
// 158:         let(:cop_config) { { "Enabled" => true } }
// 159:
// 160:         it { expect(1).to eq(1) }
// 161:       end
// 162:     RUBY
// 163:   end
// 164:
// 165:   it "does not flag a let referenced via dynamic dispatch" do
// 166:     expect_no_offenses(<<~RUBY)
// 167:       RSpec.describe Thing do
// 168:         let(:thing) { create(:thing) }
// 169:
// 170:         it { expect(send(:thing)).to be_present }
// 171:       end
// 172:     RUBY
// 173:   end
// 174:
// 175:   it "does not flag a let referenced only as a symbol literal (data-table dispatch)" do
// 176:     expect_no_offenses(<<~RUBY)
// 177:       RSpec.describe Thing do
// 178:         let(:special_formula) { build(:formula) }
// 179:
// 180:         it "dispatches by name" do
// 181:           [[:special_formula, :pending]].each do |name, _state|
// 182:             expect(send(name)).to be_present
// 183:           end
// 184:         end
// 185:       end
// 186:     RUBY
// 187:   end
// 188:
// 189:   it "does not flag a let referenced only as a string literal (string dispatch)" do
// 190:     expect_no_offenses(<<~RUBY)
// 191:       RSpec.describe Thing do
// 192:         let(:special_formula) { build(:formula) }
// 193:
// 194:         it { expect(send("special_formula")).to be_present }
// 195:       end
// 196:     RUBY
// 197:   end
// 198:
// 199:   it "does not flag a let referenced only inside a heredoc body" do
// 200:     expect_no_offenses(<<~RUBY)
// 201:       RSpec.describe Thing do
// 202:         let(:cutoff_date) { Date.today }
// 203:         let(:query) do
// 204:           <<~SQL
// 205:             SELECT * FROM things WHERE created_at < cutoff_date
// 206:           SQL
// 207:         end
// 208:
// 209:         it { expect(described_class.run(query)).to be_present }
// 210:       end
// 211:     RUBY
// 212:   end
// 213:
// 214:   it "skips every let in a file that dispatches through an interpolated string" do
// 215:     expect_no_offenses(<<~RUBY)
// 216:       RSpec.describe Thing do
// 217:         let(:expected_dental_value) { 1 }
// 218:
// 219:         it "dispatches by interpolated name" do
// 220:           %w[dental vision].each do |type|
// 221:             expect(described_class.for(type)).to eq(send("expected_\#{type}_value"))
// 222:           end
// 223:         end
// 224:       end
// 225:     RUBY
// 226:   end
// 227:
// 228:   it "still flags a dead let in a file whose only send target is a static string" do
// 229:     expect_offense(<<~RUBY)
// 230:       RSpec.describe Thing do
// 231:         let(:unused) { create(:thing) }
// 232:         ^^^ Remove unreferenced `let(:unused)` -- its name is never used, so the block never runs.
// 233:
// 234:         it { expect(send("other")).to be_present }
// 235:       end
// 236:     RUBY
// 237:
// 238:     expect_correction(<<~RUBY)
// 239:       RSpec.describe Thing do
// 240:         it { expect(send("other")).to be_present }
// 241:       end
// 242:     RUBY
// 243:   end
// 244:
// 245:   it "does not crash on a let whose block contains an invalid-UTF-8 string literal" do
// 246:     expect_offense(<<~'RUBY')
// 247:       RSpec.describe Thing do
// 248:         let(:unused) { String.new("\xc2invalid", encoding: "UTF-8") }
// 249:         ^^^ Remove unreferenced `let(:unused)` -- its name is never used, so the block never runs.
// 250:
// 251:         it { expect(1).to eq(1) }
// 252:       end
// 253:     RUBY
// 254:
// 255:     expect_correction(<<~RUBY)
// 256:       RSpec.describe Thing do
// 257:         it { expect(1).to eq(1) }
// 258:       end
// 259:     RUBY
// 260:   end
// 261:
// 262:   it "does not flag a name defined by more than one let/let! (override / super chain)" do
// 263:     expect_no_offenses(<<~RUBY)
// 264:       RSpec.describe Thing do
// 265:         let(:value) { 1 }
// 266:
// 267:         context "nested" do
// 268:           let!(:value) { 2 }
// 269:
// 270:           it { expect(1).to eq(1) }
// 271:         end
// 272:       end
// 273:     RUBY
// 274:   end
// 275:
// 276:   it "does not flag a let overridden by a subject of the same name (super chain)" do
// 277:     expect_no_offenses(<<~RUBY)
// 278:       RSpec.describe Thing do
// 279:         let(:described) { build(:thing) }
// 280:
// 281:         context "when active" do
// 282:           subject(:described) { super().tap(&:activate) }
// 283:
// 284:           it { is_expected.to be_active }
// 285:         end
// 286:       end
// 287:     RUBY
// 288:   end
// 289:
// 290:   it "does not flag an unreferenced subject (only lazy let is in scope)" do
// 291:     expect_no_offenses(<<~RUBY)
// 292:       RSpec.describe Thing do
// 293:         subject(:unused) { build(:thing) }
// 294:
// 295:         it { expect(1).to eq(1) }
// 296:       end
// 297:     RUBY
// 298:   end
// 299:
// 300:   it "skips every let in a file that consumes shared examples" do
// 301:     expect_no_offenses(<<~RUBY)
// 302:       RSpec.describe Thing do
// 303:         let(:unused) { create(:thing) }
// 304:
// 305:         it_behaves_like "a thing"
// 306:       end
// 307:     RUBY
// 308:   end
// 309:
// 310:   it "skips a let declared inside a shared example definition" do
// 311:     expect_no_offenses(<<~RUBY)
// 312:       RSpec.shared_examples "a thing" do
// 313:         let(:unused_inner) { create(:thing) }
// 314:
// 315:         it { expect(1).to eq(1) }
// 316:       end
// 317:     RUBY
// 318:   end
// 319:
// 320:   it "still flags an unreferenced let declared outside a shared example definition" do
// 321:     expect_offense(<<~RUBY)
// 322:       RSpec.describe Thing do
// 323:         let(:unused) { create(:thing) }
// 324:         ^^^ Remove unreferenced `let(:unused)` -- its name is never used, so the block never runs.
// 325:
// 326:         shared_examples "a thing" do
// 327:           it { expect(1).to eq(1) }
// 328:         end
// 329:       end
// 330:     RUBY
// 331:
// 332:     expect_correction(<<~RUBY)
// 333:       RSpec.describe Thing do
// 334:         shared_examples "a thing" do
// 335:           it { expect(1).to eq(1) }
// 336:         end
// 337:       end
// 338:     RUBY
// 339:   end
// 340:
// 341:   it "ignores let declarations without a symbol name" do
// 342:     expect_no_offenses(<<~RUBY)
// 343:       RSpec.describe Thing do
// 344:         name = :dynamic
// 345:         let(name) { create(:thing) }
// 346:         let { create(:thing) }
// 347:       end
// 348:     RUBY
// 349:   end
// 350:
// 351:   it "ignores a let call with no block" do
// 352:     expect_no_offenses(<<~RUBY)
// 353:       RSpec.describe Thing do
// 354:         let(:unused)
// 355:       end
// 356:     RUBY
// 357:   end
// 358:
// 359:   it "ignores a let-like call with an explicit receiver" do
// 360:     expect_no_offenses(<<~RUBY)
// 361:       RSpec.describe Thing do
// 362:         config.let(:unused) { create(:thing) }
// 363:       end
// 364:     RUBY
// 365:   end
// 366: end
