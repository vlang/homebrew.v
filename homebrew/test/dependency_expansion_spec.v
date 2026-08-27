module test

import brew_runtime

// Translated from Homebrew/brew `test/dependency_expansion_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:foo) { build_dep(:foo) }` at line 7.
pub fn ruby_dependency_expansion_spec_l7_d1_foo(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('foo', ...args)
}

// Ruby let `let(:bar) { build_dep(:bar) }` at line 8.
pub fn ruby_dependency_expansion_spec_l8_d2_bar(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('bar', ...args)
}

// Ruby let `let(:baz) { build_dep(:baz) }` at line 9.
pub fn ruby_dependency_expansion_spec_l9_d3_baz(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('baz', ...args)
}

// Ruby let `let(:qux) { build_dep(:qux) }` at line 10.
pub fn ruby_dependency_expansion_spec_l10_d4_qux(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('qux', ...args)
}

// Ruby let `let(:deps) { [foo, bar, baz, qux] }` at line 11.
pub fn ruby_dependency_expansion_spec_l11_d5_deps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('deps', ...args)
}

// Ruby let `let(:formula) { instance_double(Formula, deps:, name: "f") }` at line 12.
pub fn ruby_dependency_expansion_spec_l12_d6_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula', ...args)
}

// Ruby method `build_dep(name, tags = [], deps = [])` at line 14.
pub fn ruby_dependency_expansion_spec_l14_d7_build_dep(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('build_dep', ...args)
}

// Ruby it `it "yields dependent and dependency pairs" do` at line 22.
pub fn ruby_dependency_expansion_spec_l22_d8_yields(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('yields', ...args)
}

// Ruby it `it "returns the dependencies" do` at line 32.
pub fn ruby_dependency_expansion_spec_l32_d9_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "prunes all when given a block with PRUNE" do` at line 36.
pub fn ruby_dependency_expansion_spec_l36_d10_prunes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prunes', ...args)
}

// Ruby it `it "can prune selectively" do` at line 40.
pub fn ruby_dependency_expansion_spec_l40_d11_can(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('can', ...args)
}

// Ruby it `it "preserves dependency order" do` at line 48.
pub fn ruby_dependency_expansion_spec_l48_d12_preserves(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('preserves', ...args)
}

// Ruby it `it "skips optionals by default" do` at line 55.
pub fn ruby_dependency_expansion_spec_l55_d13_skips(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skips', ...args)
}

// Ruby it `it "keeps recommended dependencies by default" do` at line 61.
pub fn ruby_dependency_expansion_spec_l61_d14_keeps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('keeps', ...args)
}

// Ruby it `it "merges repeated dependencies with differing options" do` at line 67.
pub fn ruby_dependency_expansion_spec_l67_d15_merges(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('merges', ...args)
}

// Ruby it `it "merges tags without duplicating them" do` at line 78.
pub fn ruby_dependency_expansion_spec_l78_d16_merges(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('merges', ...args)
}

// Ruby it `it "skips parent but yields children with SKIP" do` at line 86.
pub fn ruby_dependency_expansion_spec_l86_d17_skips(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skips', ...args)
}

// Ruby it `it "keeps dependency but prunes recursive dependencies with KEEP_BUT_PRUNE_RECURSIVE_DEPS" do` at line 103.
pub fn ruby_dependency_expansion_spec_l103_d18_keeps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('keeps', ...args)
}

// Ruby it `it "reuses formulae from the provided formula cache" do` at line 115.
pub fn ruby_dependency_expansion_spec_l115_d19_reuses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reuses', ...args)
}

// Ruby it `it "does not reuse formulae for uses_from_macos dependencies with different bounds" do` at line 136.
pub fn ruby_dependency_expansion_spec_l136_d20_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "returns only the dependencies given as a collection as second argument" do` at line 158.
pub fn ruby_dependency_expansion_spec_l158_d21_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "doesn't raise an error when a dependency is cyclic" do` at line 163.
pub fn ruby_dependency_expansion_spec_l163_d22_doesn(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('doesn', ...args)
}

// Ruby it `it "cleans the expand stack" do` at line 172.
pub fn ruby_dependency_expansion_spec_l172_d23_cleans(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cleans', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "dependency"
// 5:
// 6: RSpec.describe Dependency do
// 7:   let(:foo) { build_dep(:foo) }
// 8:   let(:bar) { build_dep(:bar) }
// 9:   let(:baz) { build_dep(:baz) }
// 10:   let(:qux) { build_dep(:qux) }
// 11:   let(:deps) { [foo, bar, baz, qux] }
// 12:   let(:formula) { instance_double(Formula, deps:, name: "f") }
// 13:
// 14:   def build_dep(name, tags = [], deps = [])
// 15:     dep = Dependency.new(name.to_s, tags)
// 16:     allow(dep).to receive(:to_formula).and_return \
// 17:       instance_double(Formula, deps:, name:, full_name: name)
// 18:     dep
// 19:   end
// 20:
// 21:   describe "::expand" do
// 22:     it "yields dependent and dependency pairs" do
// 23:       i = 0
// 24:       described_class.expand(formula) do |dependent, dep|
// 25:         expect(dependent).to eq(formula)
// 26:         expect(deps[i]).to eq(dep)
// 27:         i += 1
// 28:         nil
// 29:       end
// 30:     end
// 31:
// 32:     it "returns the dependencies" do
// 33:       expect(described_class.expand(formula)).to eq(deps)
// 34:     end
// 35:
// 36:     it "prunes all when given a block with PRUNE" do
// 37:       expect(described_class.expand(formula) { next Dependable::PRUNE }).to be_empty
// 38:     end
// 39:
// 40:     it "can prune selectively" do
// 41:       deps = described_class.expand(formula) do |_, dep|
// 42:         next Dependable::PRUNE if dep.name == "foo"
// 43:       end
// 44:
// 45:       expect(deps).to eq([bar, baz, qux])
// 46:     end
// 47:
// 48:     it "preserves dependency order" do
// 49:       allow(foo).to receive(:to_formula).and_return \
// 50:         instance_double(Formula, name: "foo", full_name: "foo", deps: [qux, baz])
// 51:       expect(described_class.expand(formula)).to eq([qux, baz, foo, bar])
// 52:     end
// 53:   end
// 54:
// 55:   it "skips optionals by default" do
// 56:     deps = [build_dep(:foo, [:optional]), bar, baz, qux]
// 57:     f = instance_double(Formula, deps:, build: instance_double(BuildOptions, with?: false), name: "f")
// 58:     expect(described_class.expand(f)).to eq([bar, baz, qux])
// 59:   end
// 60:
// 61:   it "keeps recommended dependencies by default" do
// 62:     deps = [build_dep(:foo, [:recommended]), bar, baz, qux]
// 63:     f = instance_double(Formula, deps:, build: instance_double(BuildOptions, with?: true), name: "f")
// 64:     expect(described_class.expand(f)).to eq(deps)
// 65:   end
// 66:
// 67:   it "merges repeated dependencies with differing options" do
// 68:     foo2 = build_dep(:foo, ["option"])
// 69:     baz2 = build_dep(:baz, ["option"])
// 70:     deps << foo2 << baz2
// 71:     deps = [foo2, bar, baz2, qux]
// 72:     deps.zip(described_class.expand(formula)) do |expected, actual|
// 73:       expect(expected.tags).to eq(T.must(actual).tags)
// 74:       expect(expected).to eq(actual)
// 75:     end
// 76:   end
// 77:
// 78:   it "merges tags without duplicating them" do
// 79:     foo2 = build_dep(:foo, ["option"])
// 80:     foo3 = build_dep(:foo, ["option"])
// 81:     deps << foo2 << foo3
// 82:
// 83:     expect(T.must(described_class.expand(formula).first).tags).to eq(%w[option])
// 84:   end
// 85:
// 86:   it "skips parent but yields children with SKIP" do
// 87:     f = instance_double(
// 88:       Formula,
// 89:       name: "f",
// 90:       deps: [
// 91:         build_dep(:foo, [], [bar, baz]),
// 92:         build_dep(:foo, [], [baz]),
// 93:       ],
// 94:     )
// 95:
// 96:     deps = described_class.expand(f) do |_dependent, dep|
// 97:       next Dependable::SKIP if %w[foo qux].include? dep.name
// 98:     end
// 99:
// 100:     expect(deps).to eq([bar, baz])
// 101:   end
// 102:
// 103:   it "keeps dependency but prunes recursive dependencies with KEEP_BUT_PRUNE_RECURSIVE_DEPS" do
// 104:     foo = build_dep(:foo, [:test], bar)
// 105:     baz = build_dep(:baz, [:test])
// 106:     f = instance_double(Formula, name: "f", deps: [foo, baz])
// 107:
// 108:     deps = described_class.expand(f) do |_dependent, dep|
// 109:       next Dependable::KEEP_BUT_PRUNE_RECURSIVE_DEPS if dep.test?
// 110:     end
// 111:
// 112:     expect(deps).to eq([foo, baz])
// 113:   end
// 114:
// 115:   it "reuses formulae from the provided formula cache" do
// 116:     shared_formula = instance_double(Formula, deps: [], name: "shared", full_name: "shared")
// 117:     shared_dep = described_class.new("shared")
// 118:     repeated_shared_dep = described_class.new("shared")
// 119:     expect(shared_dep).to receive(:to_formula).once.and_return(shared_formula)
// 120:     expect(repeated_shared_dep).not_to receive(:to_formula)
// 121:     f = instance_double(
// 122:       Formula,
// 123:       name:      "f",
// 124:       full_name: "f",
// 125:       deps:      [
// 126:         build_dep(:foo, [], [shared_dep]),
// 127:         build_dep(:bar, [], [repeated_shared_dep]),
// 128:       ],
// 129:     )
// 130:
// 131:     deps = described_class.expand(f, cache_key: "formula-cache-spec", formula_cache: {})
// 132:
// 133:     expect(deps.map(&:name)).to eq(%w[shared foo bar])
// 134:   end
// 135:
// 136:   it "does not reuse formulae for uses_from_macos dependencies with different bounds" do
// 137:     first_formula = instance_double(Formula, deps: [], name: "shared", full_name: "shared")
// 138:     second_formula = instance_double(Formula, deps: [], name: "shared", full_name: "shared")
// 139:     first_dep = UsesFromMacOSDependency.new("shared", [], bounds: { since: :ventura })
// 140:     second_dep = UsesFromMacOSDependency.new("shared", [], bounds: { since: :sonoma })
// 141:     expect(first_dep).to receive(:to_formula).once.and_return(first_formula)
// 142:     expect(second_dep).to receive(:to_formula).once.and_return(second_formula)
// 143:     f = instance_double(
// 144:       Formula,
// 145:       name:      "f",
// 146:       full_name: "f",
// 147:       deps:      [
// 148:         build_dep(:foo, [], [first_dep]),
// 149:         build_dep(:bar, [], [second_dep]),
// 150:       ],
// 151:     )
// 152:
// 153:     deps = described_class.expand(f, cache_key: "uses-from-macos-formula-cache-spec", formula_cache: {})
// 154:
// 155:     expect(deps.map(&:name)).to eq(%w[shared foo bar])
// 156:   end
// 157:
// 158:   it "returns only the dependencies given as a collection as second argument" do
// 159:     expect(formula.deps).to eq([foo, bar, baz, qux])
// 160:     expect(described_class.expand(formula, [bar, baz])).to eq([bar, baz])
// 161:   end
// 162:
// 163:   it "doesn't raise an error when a dependency is cyclic" do
// 164:     foo = build_dep(:foo)
// 165:     bar = build_dep(:bar, [], [foo])
// 166:     allow(foo).to receive(:to_formula).and_return \
// 167:       instance_double(Formula, deps: [bar], name: foo.name, full_name: foo.name)
// 168:     f = instance_double(Formula, name: "f", full_name: "f", deps: [foo, bar])
// 169:     expect { described_class.expand(f) }.not_to raise_error
// 170:   end
// 171:
// 172:   it "cleans the expand stack" do
// 173:     foo = build_dep(:foo)
// 174:     allow(foo).to receive(:to_formula).and_raise(FormulaUnavailableError, foo.name)
// 175:     f = instance_double(Formula, name: "f", deps: [foo])
// 176:     expect { described_class.expand(f) }.to raise_error(FormulaUnavailableError)
// 177:     expect(described_class.expand_stack).to be_empty
// 178:   end
// 179: end
