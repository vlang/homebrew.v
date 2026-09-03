module utils

import homebrew.utils as homebrew_utils

// Translated from Homebrew/brew `test/utils/topological_hash_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "returns a topologically sorted array" do` at line 8.
pub fn ruby_topological_hash_spec_l8_d1_returns() !bool {
	mut graph := homebrew_utils.new_topological_hash()
	graph.set('1', ['2', '3'])
	graph.set('2', ['3'])
	graph.set('3', [])
	graph.set('4', [])
	return graph.tsort()! == ['3', '2', '1', '4']
}

// Ruby it `it "returns an array of arrays" do` at line 19.
pub fn ruby_topological_hash_spec_l19_d2_returns() !bool {
	mut graph := homebrew_utils.new_topological_hash()
	graph.set('1', ['2'])
	graph.set('2', ['3', '4'])
	graph.set('3', ['2'])
	graph.set('4', [])
	return graph.strongly_connected_components()! == [['4'], ['2', '3'], ['1']]
}

// Ruby it `it "returns a topological hash" do` at line 30.
pub fn ruby_topological_hash_spec_l30_d3_returns() !bool {
	formula1 := homebrew_utils.TopologicalPackage{
		name: 'homebrew-test-formula1'
		kind: .formula
	}
	formula2 := homebrew_utils.TopologicalPackage{
		name: 'homebrew-test-formula2'
		kind: .formula
		formula_dependencies: [homebrew_utils.TopologicalDependency{
			name: formula1.name
		}]
	}
	formula3 := homebrew_utils.TopologicalPackage{
		name: 'homebrew-test-formula3'
		kind: .formula
		formula_dependencies: [homebrew_utils.TopologicalDependency{
			name: 'homebrew-test-formula4'
		}]
	}
	formula4 := homebrew_utils.TopologicalPackage{
		name: 'homebrew-test-formula4'
		kind: .formula
		formula_dependencies: [homebrew_utils.TopologicalDependency{
			name: formula3.name
		}]
	}
	cask1 := homebrew_utils.TopologicalPackage{
		name: 'homebrew-test-cask1'
		kind: .cask
	}
	cask2 := homebrew_utils.TopologicalPackage{
		name: 'homebrew-test-cask2'
		kind: .cask
		formula_dependencies: [homebrew_utils.TopologicalDependency{
			name: formula1.name
		}]
		cask_dependencies: [cask1.name]
	}
	cask3 := homebrew_utils.TopologicalPackage{
		name: 'homebrew-test-cask3'
		kind: .cask
		cask_dependencies: [cask2.name]
	}
	packages := [formula1, formula2, formula3, formula4, cask1, cask2, cask3]
	mut catalog := map[string]homebrew_utils.TopologicalPackage{}
	for package in packages {
		catalog[package.name] = package
	}
	graph := homebrew_utils.graph_package_dependencies(packages, catalog)!
	if graph.each_child(formula1.name)! != [] || graph.each_child(formula2.name)! != [
		formula1.name,
	] || graph.each_child(formula3.name)! != [formula4.name] || graph.each_child(formula4.name)! != [
		formula3.name,
	] || graph.each_child(cask1.name)! != [] || graph.each_child(cask2.name)! != [
		formula1.name,
		cask1.name,
	] || graph.each_child(cask3.name)! != [cask2.name] {
		return false
	}
	expected := [formula1.name, cask1.name, cask2.name, cask3.name, formula2.name]
	first := homebrew_utils.graph_package_dependencies([cask3, cask2, cask1, formula2, formula1], catalog)!
	if first.tsort()! != expected {
		return false
	}
	second := homebrew_utils.graph_package_dependencies([cask3, formula2], catalog)!
	if second.tsort()! != expected {
		return false
	}
	cyclic := homebrew_utils.graph_package_dependencies([formula3, formula4], catalog)!
	cyclic.tsort() or { return true }
	return false
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/topological_hash"
// 5:
// 6: RSpec.describe Utils::TopologicalHash do
// 7:   describe "#tsort" do
// 8:     it "returns a topologically sorted array" do
// 9:       hash = described_class.new
// 10:       hash[1] = [2, 3]
// 11:       hash[2] = [3]
// 12:       hash[3] = []
// 13:       hash[4] = []
// 14:       expect(hash.tsort).to eq [3, 2, 1, 4]
// 15:     end
// 16:   end
// 17:
// 18:   describe "#strongly_connected_components" do
// 19:     it "returns an array of arrays" do
// 20:       hash = described_class.new
// 21:       hash[1] = [2]
// 22:       hash[2] = [3, 4]
// 23:       hash[3] = [2]
// 24:       hash[4] = []
// 25:       expect(hash.strongly_connected_components).to eq [[4], [2, 3], [1]]
// 26:     end
// 27:   end
// 28:
// 29:   describe "::graph_package_dependencies" do
// 30:     it "returns a topological hash" do
// 31:       formula1 = formula "homebrew-test-formula1" do
// 32:         T.bind(self, T.class_of(Formula))
// 33:         url "foo"
// 34:         version "0.5"
// 35:       end
// 36:
// 37:       formula2 = formula "homebrew-test-formula2" do
// 38:         T.bind(self, T.class_of(Formula))
// 39:         url "foo"
// 40:         version "0.5"
// 41:         depends_on "homebrew-test-formula1"
// 42:       end
// 43:
// 44:       formula3 = formula "homebrew-test-formula3" do
// 45:         T.bind(self, T.class_of(Formula))
// 46:         url "foo"
// 47:         version "0.5"
// 48:         depends_on "homebrew-test-formula4"
// 49:       end
// 50:
// 51:       formula4 = formula "homebrew-test-formula4" do
// 52:         T.bind(self, T.class_of(Formula))
// 53:         url "foo"
// 54:         version "0.5"
// 55:         depends_on "homebrew-test-formula3"
// 56:       end
// 57:
// 58:       cask1 = Cask::Cask.new("homebrew-test-cask1") do
// 59:         url "foo"
// 60:         version "1.2.3"
// 61:       end
// 62:
// 63:       cask2 = Cask::Cask.new("homebrew-test-cask2") do
// 64:         url "foo"
// 65:         version "1.2.3"
// 66:         depends_on cask: "homebrew-test-cask1"
// 67:         depends_on formula: "homebrew-test-formula1"
// 68:       end
// 69:
// 70:       cask3 = Cask::Cask.new("homebrew-test-cask3") do
// 71:         url "foo"
// 72:         version "1.2.3"
// 73:         depends_on cask: "homebrew-test-cask2"
// 74:       end
// 75:
// 76:       stub_formula_loader formula1
// 77:       stub_formula_loader formula2
// 78:       stub_formula_loader formula3
// 79:       stub_formula_loader formula4
// 80:
// 81:       stub_cask_loader cask1
// 82:       stub_cask_loader cask2
// 83:       stub_cask_loader cask3
// 84:
// 85:       packages = [formula1, formula2, formula3, formula4, cask1, cask2, cask3]
// 86:       expect(described_class.graph_package_dependencies(packages)).to eq({
// 87:         formula1 => [],
// 88:         formula2 => [formula1],
// 89:         formula3 => [formula4],
// 90:         formula4 => [formula3],
// 91:         cask1    => [],
// 92:         cask2    => [formula1, cask1],
// 93:         cask3    => [cask2],
// 94:       })
// 95:
// 96:       sorted = [formula1, cask1, cask2, cask3, formula2]
// 97:       expect(described_class.graph_package_dependencies([cask3, cask2, cask1, formula2,
// 98:                                                          formula1]).tsort).to eq sorted
// 99:       expect(described_class.graph_package_dependencies([cask3, formula2]).tsort).to eq sorted
// 100:
// 101:       expect { described_class.graph_package_dependencies([formula3, formula4]).tsort }.to raise_error TSort::Cyclic
// 102:     end
// 103:   end
// 104: end
