module test

import ruby
import homebrew

// Translated from Homebrew/brew `test/software_spec_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn software_spec_test_owner() homebrew.SoftwareSpecOwner {
	return homebrew.SoftwareSpecOwner{
		kind: .cask
		name: 'some_name'
		full_name: 'some_name'
		tap: 'homebrew/core'
	}
}

fn software_spec_test_resource(name string, url string) homebrew.Resource {
	mut resource := homebrew.new_resource(name)
	resource.set_url(url, map[string]string{}) or { panic(err) }
	return resource
}

fn software_spec_test_result(value bool) ruby.Value {
	return ruby.bool_value(value)
}

// Ruby subject `subject(:spec) { described_class.new }` at line 7.
pub fn ruby_software_spec_spec_l7_d1_spec(args ...ruby.Value) ruby.Value {
	return homebrew.software_spec_boundary_value(homebrew.new_software_spec([]string{}))
}

// Ruby let `let(:owner) { instance_double(Cask::Cask, name: "some_name", full_name: "some_name", tap: "homebrew/core") }` at line 9.
pub fn ruby_software_spec_spec_l9_d2_owner(args ...ruby.Value) ruby.Value {
	owner := software_spec_test_owner()
	return ruby.structured_value('Cask::Cask', owner.full_name, {
		'name':      owner.name
		'full_name': owner.full_name
		'tap':       owner.tap
	})
}

// Ruby alias_matcher `alias_matcher :have_defined_resource, :be_resource_defined` at line 11.
pub fn ruby_software_spec_spec_l11_d3_have_defined_resource(args ...ruby.Value) ruby.Value {
	if args.len >= 2 && args[0].type_name == 'SoftwareSpec' {
		return software_spec_test_result(homebrew.software_spec_from_boundary(args[0]).resource_defined(args[1].as_string()))
	}
	return ruby.structured_value('MatcherAlias', 'have_defined_resource', {
		'alias':  'have_defined_resource'
		'target': 'be_resource_defined'
	})
}

// Ruby alias_matcher `alias_matcher :have_defined_option, :be_option_defined` at line 12.
pub fn ruby_software_spec_spec_l12_d4_have_defined_option(args ...ruby.Value) ruby.Value {
	if args.len >= 2 && args[0].type_name == 'SoftwareSpec' {
		return software_spec_test_result(homebrew.software_spec_from_boundary(args[0]).option_defined(args[1].as_string()))
	}
	return ruby.structured_value('MatcherAlias', 'have_defined_option', {
		'alias':  'have_defined_option'
		'target': 'be_option_defined'
	})
}

// Ruby it `it "defines a resource" do` at line 15.
pub fn ruby_software_spec_spec_l15_d5_defines(args ...ruby.Value) ruby.Value {
	mut spec := homebrew.new_software_spec([]string{})
	mut resource := software_spec_test_resource('foo', 'foo-1.0')
	spec.define_resource('foo', mut resource) or { return software_spec_test_result(false) }
	return software_spec_test_result(spec.resource_defined('foo'))
}

// Ruby it `it "sets itself to be the resource's owner" do` at line 20.
pub fn ruby_software_spec_spec_l20_d6_sets(args ...ruby.Value) ruby.Value {
	mut spec := homebrew.new_software_spec([]string{})
	mut resource := software_spec_test_resource('foo', 'foo-1.0')
	spec.define_resource('foo', mut resource) or { return software_spec_test_result(false) }
	spec.set_owner(software_spec_test_owner())
	return software_spec_test_result((spec.resource('foo') or {
		return software_spec_test_result(false)
	}).owner_name == 'some_name')
}

// Ruby it `it "receives the owner's version if it has no own version" do` at line 28.
pub fn ruby_software_spec_spec_l28_d7_receives(args ...ruby.Value) ruby.Value {
	mut spec := homebrew.new_software_spec([]string{})
	spec.set_url('foo-42', map[string]string{}) or { return software_spec_test_result(false) }
	mut resource := software_spec_test_resource('bar', 'bar')
	spec.define_resource('bar', mut resource) or { return software_spec_test_result(false) }
	spec.set_owner(software_spec_test_owner())
	version := (spec.resource('bar') or { return software_spec_test_result(false) }).version() or {
		return software_spec_test_result(false)
	}
	return software_spec_test_result(version.to_s() == '42')
}

// Ruby it `it "raises an error when duplicate resources are defined" do` at line 36.
pub fn ruby_software_spec_spec_l36_d8_raises(args ...ruby.Value) ruby.Value {
	mut spec := homebrew.new_software_spec([]string{})
	mut first := software_spec_test_resource('foo', 'foo-1.0')
	spec.define_resource('foo', mut first) or { return software_spec_test_result(false) }
	mut duplicate := software_spec_test_resource('foo', 'foo-1.0')
	spec.define_resource('foo', mut duplicate) or {
		return software_spec_test_result(err.msg().contains('DuplicateResourceError'))
	}
	return software_spec_test_result(false)
}

// Ruby it `it "raises an error when accessing missing resources" do` at line 43.
pub fn ruby_software_spec_spec_l43_d9_raises(args ...ruby.Value) ruby.Value {
	mut spec := homebrew.new_software_spec([]string{})
	spec.set_owner(software_spec_test_owner())
	spec.resource('foo') or {
		return software_spec_test_result(err.msg().contains('ResourceMissingError'))
	}
	return software_spec_test_result(false)
}

// Ruby it `it "sets the owner" do` at line 52.
pub fn ruby_software_spec_spec_l52_d10_sets(args ...ruby.Value) ruby.Value {
	mut spec := homebrew.new_software_spec([]string{})
	owner := software_spec_test_owner()
	spec.set_owner(owner)
	stored := spec.owner() or { return software_spec_test_result(false) }
	return software_spec_test_result(stored == owner)
}

// Ruby it `it "sets the name" do` at line 57.
pub fn ruby_software_spec_spec_l57_d11_sets(args ...ruby.Value) ruby.Value {
	mut spec := homebrew.new_software_spec([]string{})
	spec.set_owner(software_spec_test_owner())
	return software_spec_test_result((spec.name() or { '' }) == 'some_name')
}

// Ruby it `it "defines an option" do` at line 64.
pub fn ruby_software_spec_spec_l64_d12_defines(args ...ruby.Value) ruby.Value {
	mut spec := homebrew.new_software_spec([]string{})
	spec.add_option('foo', '') or { return software_spec_test_result(false) }
	return software_spec_test_result(spec.option_defined('foo'))
}

// Ruby it `it "raises an error when it begins with dashes" do` at line 69.
pub fn ruby_software_spec_spec_l69_d13_raises(args ...ruby.Value) ruby.Value {
	mut spec := homebrew.new_software_spec([]string{})
	spec.add_option('--foo', '') or {
		return software_spec_test_result(err.msg().contains('must not start with dashes'))
	}
	return software_spec_test_result(false)
}

// Ruby it `it "raises an error when name is empty" do` at line 75.
pub fn ruby_software_spec_spec_l75_d14_raises(args ...ruby.Value) ruby.Value {
	mut spec := homebrew.new_software_spec([]string{})
	spec.add_option('', '') or {
		return software_spec_test_result(err.msg().contains('option name is required'))
	}
	return software_spec_test_result(false)
}

// Ruby it `it "supports options with descriptions" do` at line 81.
pub fn ruby_software_spec_spec_l81_d15_supports(args ...ruby.Value) ruby.Value {
	mut spec := homebrew.new_software_spec([]string{})
	spec.add_option('bar', 'description') or { return software_spec_test_result(false) }
	return software_spec_test_result(spec.options().to_array()[0].description == 'description')
}

// Ruby it `it "defaults to an empty string when no description is given" do` at line 86.
pub fn ruby_software_spec_spec_l86_d16_defaults(args ...ruby.Value) ruby.Value {
	mut spec := homebrew.new_software_spec([]string{})
	spec.add_option('foo', '') or { return software_spec_test_result(false) }
	return software_spec_test_result(spec.options().to_array()[0].description == '')
}

// Ruby it `it "allows specifying deprecated options" do` at line 93.
pub fn ruby_software_spec_spec_l93_d17_allows(args ...ruby.Value) ruby.Value {
	mut spec := homebrew.new_software_spec([]string{})
	spec.add_deprecated_options(['foo'], ['bar']) or { return software_spec_test_result(false) }
	options := spec.deprecated_options()
	return software_spec_test_result(options.len == 1 && options[0].old == 'foo' && options[0].current == 'bar')
}

// Ruby it `it "allows specifying deprecated options as a Hash from an Array/String to an Array/String" do` at line 100.
pub fn ruby_software_spec_spec_l100_d18_allows(args ...ruby.Value) ruby.Value {
	mut spec := homebrew.new_software_spec([]string{})
	spec.add_deprecated_options(['foo1', 'foo2'], ['bar1']) or {
		return software_spec_test_result(false)
	}
	spec.add_deprecated_options(['foo3'], ['bar2', 'bar3']) or {
		return software_spec_test_result(false)
	}
	options := spec.deprecated_options()
	return software_spec_test_result(options.len == 4 && options.any(it.old == 'foo1' && it.current == 'bar1') && options.any(it.old == 'foo2' && it.current == 'bar1') && options.any(it.old == 'foo3' && it.current == 'bar2') && options.any(it.old == 'foo3' && it.current == 'bar3'))
}

// Ruby it `it "raises an error when empty" do` at line 108.
pub fn ruby_software_spec_spec_l108_d19_raises(args ...ruby.Value) ruby.Value {
	mut spec := homebrew.new_software_spec([]string{})
	spec.add_deprecated_options([]string{}, []string{}) or {
		return software_spec_test_result(err.msg().contains('must not be empty'))
	}
	return software_spec_test_result(false)
}

// Ruby it `it "allows specifying dependencies" do` at line 116.
pub fn ruby_software_spec_spec_l116_d20_allows(args ...ruby.Value) ruby.Value {
	mut spec := homebrew.new_software_spec([]string{})
	spec.depends_on('foo', []string{})
	return software_spec_test_result(spec.deps().len == 1 && spec.deps()[0].name == 'foo')
}

// Ruby it `it "allows specifying requirements with keyword syntax" do` at line 121.
pub fn ruby_software_spec_spec_l121_d21_allows(args ...ruby.Value) ruby.Value {
	mut spec := homebrew.new_software_spec([]string{})
	spec.add_requirement(homebrew.SoftwareSpecRequirement{
		kind: .macos
		tags: ['sonoma']
		comparator: '>='
	}, false) or { return software_spec_test_result(false) }
	requirements := spec.requirements()
	return software_spec_test_result(requirements.len == 1 && requirements[0].kind == .macos && requirements[0].tags == [
		'sonoma',
	])
}

// Ruby it `it "allows specifying optional dependencies" do` at line 126.
pub fn ruby_software_spec_spec_l126_d22_allows(args ...ruby.Value) ruby.Value {
	mut spec := homebrew.new_software_spec([]string{})
	spec.depends_on('foo', [':optional'])
	return software_spec_test_result(spec.option_defined('with-foo'))
}

// Ruby it `it "allows specifying recommended dependencies" do` at line 131.
pub fn ruby_software_spec_spec_l131_d23_allows(args ...ruby.Value) ruby.Value {
	mut spec := homebrew.new_software_spec([]string{})
	spec.depends_on('bar', [':recommended'])
	return software_spec_test_result(spec.option_defined('without-bar'))
}

// Ruby it `it "allows specifying dependencies" do` at line 145.
pub fn ruby_software_spec_spec_l145_d24_allows(args ...ruby.Value) ruby.Value {
	mut spec := homebrew.new_software_spec([]string{})
	spec.uses_from_macos('foo', []string{}, map[string]string{})
	deps := spec.deps_for_system('linux')
	return software_spec_test_result(spec.declared_deps().len == 1 && deps.len == 1 && deps[0].name == 'foo' && deps[0].uses_from_macos_dependency())
}

// Ruby it `it "works with tags" do` at line 155.
pub fn ruby_software_spec_spec_l155_d25_works(args ...ruby.Value) ruby.Value {
	mut spec := homebrew.new_software_spec([]string{})
	spec.uses_from_macos('foo', [':build'], map[string]string{})
	deps := spec.deps_for_system('linux')
	return software_spec_test_result(deps.len == 1 && deps[0].name == 'foo' && deps[0].build() && deps[0].uses_from_macos_dependency())
}

// Ruby it `it "handles dependencies when simulating generic macOS" do` at line 166.
pub fn ruby_software_spec_spec_l166_d26_handles(args ...ruby.Value) ruby.Value {
	mut spec := homebrew.new_software_spec([]string{})
	spec.uses_from_macos('foo', []string{}, map[string]string{})
	declared := spec.declared_deps()
	return software_spec_test_result(spec.deps_for_system('macos').len == 0 && declared.len == 1 && declared[0].name == 'foo' && declared[0].tags.len == 0)
}

// Ruby it `it "handles dependencies with tags when simulating generic macOS" do` at line 178.
pub fn ruby_software_spec_spec_l178_d27_handles(args ...ruby.Value) ruby.Value {
	mut spec := homebrew.new_software_spec([]string{})
	spec.uses_from_macos('foo', [':build'], map[string]string{})
	declared := spec.declared_deps()
	return software_spec_test_result(spec.deps_for_system('macos').len == 0 && declared.len == 1 && declared[0].name == 'foo' && declared[0].build())
}

// Ruby it `it "ignores OS version specifications" do` at line 190.
pub fn ruby_software_spec_spec_l190_d28_ignores(args ...ruby.Value) ruby.Value {
	mut spec := homebrew.new_software_spec([]string{})
	spec.uses_from_macos('foo', []string{}, {
		'since': 'sequoia'
	})
	spec.uses_from_macos('bar', [':build'], {
		'since': 'sequoia'
	})
	deps := spec.deps_for_system('linux')
	return software_spec_test_result(deps.len == 2 && deps[0].name == 'foo' && deps[1].name == 'bar' && deps[1].build())
}

// Ruby it `it "adds a macOS dependency if the OS version meets requirements" do` at line 213.
pub fn ruby_software_spec_spec_l213_d29_adds(args ...ruby.Value) ruby.Value {
	mut spec := homebrew.new_software_spec([]string{})
	spec.uses_from_macos('foo', []string{}, {
		'since': 'sonoma'
	})
	return software_spec_test_result(spec.deps_for_system('sonoma').len == 0 && spec.declared_deps().len == 1)
}

// Ruby it `it "adds a macOS dependency if the OS version doesn't meet requirements" do` at line 222.
pub fn ruby_software_spec_spec_l222_d30_adds(args ...ruby.Value) ruby.Value {
	mut spec := homebrew.new_software_spec([]string{})
	spec.uses_from_macos('foo', []string{}, {
		'since': 'sequoia'
	})
	deps := spec.deps_for_system('sonoma')
	return software_spec_test_result(deps.len == 1 && deps[0].name == 'foo')
}

// Ruby it `it "works with tags" do` at line 232.
pub fn ruby_software_spec_spec_l232_d31_works(args ...ruby.Value) ruby.Value {
	mut spec := homebrew.new_software_spec([]string{})
	spec.uses_from_macos('foo', [':build'], {
		'since': 'sequoia'
	})
	deps := spec.deps_for_system('sonoma')
	return software_spec_test_result(deps.len == 1 && deps[0].name == 'foo' && deps[0].build())
}

// Ruby it `it "doesn't add an effective dependency if no OS version is specified" do` at line 246.
pub fn ruby_software_spec_spec_l246_d32_doesn(args ...ruby.Value) ruby.Value {
	mut spec := homebrew.new_software_spec([]string{})
	spec.uses_from_macos('foo', []string{}, map[string]string{})
	spec.uses_from_macos('bar', [':build'], map[string]string{})
	declared := spec.declared_deps()
	return software_spec_test_result(spec.deps_for_system('sonoma').len == 0 && declared.len == 2 && declared[0].name == 'foo' && declared[1].build())
}

// Ruby it `it "treats invalid OS versions as macOS-provided dependencies" do` at line 265.
pub fn ruby_software_spec_spec_l265_d33_treats(args ...ruby.Value) ruby.Value {
	mut spec := homebrew.new_software_spec([]string{})
	spec.uses_from_macos('foo', []string{}, {
		'since': 'bar'
	})
	return software_spec_test_result(spec.deps_for_system('sonoma').len == 0 && spec.declared_deps().len == 1)
}

// Ruby specify `specify "explicit options override defaupt depends_on option description" do` at line 274.
pub fn ruby_software_spec_spec_l274_d34_explicit(args ...ruby.Value) ruby.Value {
	mut spec := homebrew.new_software_spec([]string{})
	spec.add_option('with-foo', 'blah') or { return software_spec_test_result(false) }
	spec.depends_on('foo', [':optional'])
	return software_spec_test_result(spec.options().to_array()[0].description == 'blah')
}

// Ruby it `it "adds a patch" do` at line 281.
pub fn ruby_software_spec_spec_l281_d35_adds(args ...ruby.Value) ruby.Value {
	mut spec := homebrew.new_software_spec([]string{})
	spec.add_patch('p1', 'DATA')
	patches := spec.patches()
	return software_spec_test_result(patches.len == 1 && patches[0].strip == 'p1')
}

// Ruby it `it "doesn't add a patch with no url" do` at line 287.
pub fn ruby_software_spec_spec_l287_d36_doesn(args ...ruby.Value) ruby.Value {
	mut spec := homebrew.new_software_spec([]string{})
	spec.add_patch('p1', '')
	return software_spec_test_result(spec.patches().len == 0)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "software_spec"
// 5:
// 6: RSpec.describe SoftwareSpec do
// 7:   subject(:spec) { described_class.new }
// 8:
// 9:   let(:owner) { instance_double(Cask::Cask, name: "some_name", full_name: "some_name", tap: "homebrew/core") }
// 10:
// 11:   alias_matcher :have_defined_resource, :be_resource_defined
// 12:   alias_matcher :have_defined_option, :be_option_defined
// 13:
// 14:   describe "#resource" do
// 15:     it "defines a resource" do
// 16:       spec.resource("foo") { url "foo-1.0" }
// 17:       expect(spec).to have_defined_resource("foo")
// 18:     end
// 19:
// 20:     it "sets itself to be the resource's owner" do
// 21:       spec.resource("foo") { url "foo-1.0" }
// 22:       spec.owner = owner
// 23:       spec.resources.each_value do |r|
// 24:         expect(r.owner).to eq(spec)
// 25:       end
// 26:     end
// 27:
// 28:     it "receives the owner's version if it has no own version" do
// 29:       spec.url("foo-42")
// 30:       spec.resource("bar") { url "bar" }
// 31:       spec.owner = owner
// 32:
// 33:       expect(spec.resource("bar").version).to eq("42")
// 34:     end
// 35:
// 36:     it "raises an error when duplicate resources are defined" do
// 37:       spec.resource("foo") { url "foo-1.0" }
// 38:       expect do
// 39:         spec.resource("foo") { url "foo-1.0" }
// 40:       end.to raise_error(DuplicateResourceError)
// 41:     end
// 42:
// 43:     it "raises an error when accessing missing resources" do
// 44:       spec.owner = owner
// 45:       expect do
// 46:         spec.resource("foo")
// 47:       end.to raise_error(ResourceMissingError)
// 48:     end
// 49:   end
// 50:
// 51:   describe "#owner" do
// 52:     it "sets the owner" do
// 53:       spec.owner = owner
// 54:       expect(spec.owner).to eq(owner)
// 55:     end
// 56:
// 57:     it "sets the name" do
// 58:       spec.owner = owner
// 59:       expect(spec.name).to eq(owner.name)
// 60:     end
// 61:   end
// 62:
// 63:   describe "#option" do
// 64:     it "defines an option" do
// 65:       spec.option("foo")
// 66:       expect(spec).to have_defined_option("foo")
// 67:     end
// 68:
// 69:     it "raises an error when it begins with dashes" do
// 70:       expect do
// 71:         spec.option("--foo")
// 72:       end.to raise_error(ArgumentError)
// 73:     end
// 74:
// 75:     it "raises an error when name is empty" do
// 76:       expect do
// 77:         spec.option("")
// 78:       end.to raise_error(ArgumentError)
// 79:     end
// 80:
// 81:     it "supports options with descriptions" do
// 82:       spec.option("bar", "description")
// 83:       expect(spec.options.first.description).to eq("description")
// 84:     end
// 85:
// 86:     it "defaults to an empty string when no description is given" do
// 87:       spec.option("foo")
// 88:       expect(spec.options.first.description).to eq("")
// 89:     end
// 90:   end
// 91:
// 92:   describe "#deprecated_option" do
// 93:     it "allows specifying deprecated options" do
// 94:       spec.deprecated_option("foo" => "bar")
// 95:       expect(spec.deprecated_options).not_to be_empty
// 96:       expect(spec.deprecated_options.first.old).to eq("foo")
// 97:       expect(spec.deprecated_options.first.current).to eq("bar")
// 98:     end
// 99:
// 100:     it "allows specifying deprecated options as a Hash from an Array/String to an Array/String" do
// 101:       spec.deprecated_option(["foo1", "foo2"] => "bar1", "foo3" => ["bar2", "bar3"])
// 102:       expect(spec.deprecated_options).to include(DeprecatedOption.new("foo1", "bar1"))
// 103:       expect(spec.deprecated_options).to include(DeprecatedOption.new("foo2", "bar1"))
// 104:       expect(spec.deprecated_options).to include(DeprecatedOption.new("foo3", "bar2"))
// 105:       expect(spec.deprecated_options).to include(DeprecatedOption.new("foo3", "bar3"))
// 106:     end
// 107:
// 108:     it "raises an error when empty" do
// 109:       expect do
// 110:         spec.deprecated_option({})
// 111:       end.to raise_error(ArgumentError)
// 112:     end
// 113:   end
// 114:
// 115:   describe "#depends_on" do
// 116:     it "allows specifying dependencies" do
// 117:       spec.depends_on("foo")
// 118:       expect(spec.deps.first.name).to eq("foo")
// 119:     end
// 120:
// 121:     it "allows specifying requirements with keyword syntax" do
// 122:       spec.depends_on macos: :sonoma
// 123:       expect(spec.requirements.first).to eq(MacOSRequirement.new([:sonoma]))
// 124:     end
// 125:
// 126:     it "allows specifying optional dependencies" do
// 127:       spec.depends_on "foo" => :optional
// 128:       expect(spec).to have_defined_option("with-foo")
// 129:     end
// 130:
// 131:     it "allows specifying recommended dependencies" do
// 132:       spec.depends_on "bar" => :recommended
// 133:       expect(spec).to have_defined_option("without-bar")
// 134:     end
// 135:   end
// 136:
// 137:   describe "#uses_from_macos" do
// 138:     context "when simulating Linux" do
// 139:       around do |example|
// 140:         Homebrew::SimulateSystem.with(os: :linux) do
// 141:           example.run
// 142:         end
// 143:       end
// 144:
// 145:       it "allows specifying dependencies" do
// 146:         spec.uses_from_macos("foo")
// 147:
// 148:         expect(spec.declared_deps).not_to be_empty
// 149:         expect(spec.deps).not_to be_empty
// 150:         expect(spec.deps.first.name).to eq("foo")
// 151:         expect(spec.deps.first).to be_uses_from_macos
// 152:         expect(spec.deps.first).not_to be_use_macos_install
// 153:       end
// 154:
// 155:       it "works with tags" do
// 156:         spec.uses_from_macos("foo" => :build)
// 157:
// 158:         expect(spec.declared_deps).not_to be_empty
// 159:         expect(spec.deps).not_to be_empty
// 160:         expect(spec.deps.first.name).to eq("foo")
// 161:         expect(spec.deps.first.tags).to include(:build)
// 162:         expect(spec.deps.first).to be_uses_from_macos
// 163:         expect(spec.deps.first).not_to be_use_macos_install
// 164:       end
// 165:
// 166:       it "handles dependencies when simulating generic macOS" do
// 167:         Homebrew::SimulateSystem.with(os: :macos) do
// 168:           spec.uses_from_macos("foo")
// 169:
// 170:           expect(spec.deps).to be_empty
// 171:           expect(spec.declared_deps.first.name).to eq("foo")
// 172:           expect(spec.declared_deps.first.tags).to be_empty
// 173:           expect(spec.declared_deps.first).to be_uses_from_macos
// 174:           expect(spec.declared_deps.first).to be_use_macos_install
// 175:         end
// 176:       end
// 177:
// 178:       it "handles dependencies with tags when simulating generic macOS" do
// 179:         Homebrew::SimulateSystem.with(os: :macos) do
// 180:           spec.uses_from_macos("foo" => :build)
// 181:
// 182:           expect(spec.deps).to be_empty
// 183:           expect(spec.declared_deps.first.name).to eq("foo")
// 184:           expect(spec.declared_deps.first.tags).to include(:build)
// 185:           expect(spec.declared_deps.first).to be_uses_from_macos
// 186:           expect(spec.declared_deps.first).to be_use_macos_install
// 187:         end
// 188:       end
// 189:
// 190:       it "ignores OS version specifications" do
// 191:         spec.uses_from_macos("foo", since: :sequoia)
// 192:         spec.uses_from_macos("bar" => :build, :since => :sequoia)
// 193:
// 194:         expect(spec.deps.count).to eq 2
// 195:         expect(spec.deps.first.name).to eq("foo")
// 196:         expect(spec.deps.first).to be_uses_from_macos
// 197:         expect(spec.deps.first).not_to be_use_macos_install
// 198:         expect(spec.deps.last.name).to eq("bar")
// 199:         expect(spec.deps.last.tags).to include(:build)
// 200:         expect(spec.deps.last).to be_uses_from_macos
// 201:         expect(spec.deps.last).not_to be_use_macos_install
// 202:         expect(spec.declared_deps.count).to eq 2
// 203:       end
// 204:     end
// 205:
// 206:     context "when simulating Sonoma" do
// 207:       around do |example|
// 208:         Homebrew::SimulateSystem.with(os: :sonoma) do
// 209:           example.run
// 210:         end
// 211:       end
// 212:
// 213:       it "adds a macOS dependency if the OS version meets requirements" do
// 214:         spec.uses_from_macos("foo", since: :sonoma)
// 215:
// 216:         expect(spec.deps).to be_empty
// 217:         expect(spec.declared_deps).not_to be_empty
// 218:         expect(spec.declared_deps.first).to be_uses_from_macos
// 219:         expect(spec.declared_deps.first).to be_use_macos_install
// 220:       end
// 221:
// 222:       it "adds a macOS dependency if the OS version doesn't meet requirements" do
// 223:         spec.uses_from_macos("foo", since: :sequoia)
// 224:
// 225:         expect(spec.declared_deps).not_to be_empty
// 226:         expect(spec.deps).not_to be_empty
// 227:         expect(spec.deps.first.name).to eq("foo")
// 228:         expect(spec.deps.first).to be_uses_from_macos
// 229:         expect(spec.deps.first).not_to be_use_macos_install
// 230:       end
// 231:
// 232:       it "works with tags" do
// 233:         spec.uses_from_macos("foo" => :build, :since => :sequoia)
// 234:
// 235:         expect(spec.declared_deps).not_to be_empty
// 236:         expect(spec.deps).not_to be_empty
// 237:
// 238:         dep = spec.deps.first
// 239:
// 240:         expect(dep.name).to eq("foo")
// 241:         expect(dep.tags).to include(:build)
// 242:         expect(dep).to be_uses_from_macos
// 243:         expect(dep).not_to be_use_macos_install
// 244:       end
// 245:
// 246:       it "doesn't add an effective dependency if no OS version is specified" do
// 247:         spec.uses_from_macos("foo")
// 248:         spec.uses_from_macos("bar" => :build)
// 249:
// 250:         expect(spec.deps).to be_empty
// 251:         expect(spec.declared_deps).not_to be_empty
// 252:
// 253:         dep = spec.declared_deps.first
// 254:         expect(dep.name).to eq("foo")
// 255:         expect(dep).to be_uses_from_macos
// 256:         expect(dep).to be_use_macos_install
// 257:
// 258:         dep = spec.declared_deps.last
// 259:         expect(dep.name).to eq("bar")
// 260:         expect(dep.tags).to include(:build)
// 261:         expect(dep).to be_uses_from_macos
// 262:         expect(dep).to be_use_macos_install
// 263:       end
// 264:
// 265:       it "treats invalid OS versions as macOS-provided dependencies" do
// 266:         spec.uses_from_macos("foo", since: :bar)
// 267:
// 268:         expect(spec.deps).to be_empty
// 269:         expect(spec.declared_deps.first).to be_use_macos_install
// 270:       end
// 271:     end
// 272:   end
// 273:
// 274:   specify "explicit options override defaupt depends_on option description" do
// 275:     spec.option("with-foo", "blah")
// 276:     spec.depends_on("foo" => :optional)
// 277:     expect(spec.options.first.description).to eq("blah")
// 278:   end
// 279:
// 280:   describe "#patch" do
// 281:     it "adds a patch" do
// 282:       spec.patch(:p1, :DATA)
// 283:       expect(spec.patches.count).to eq(1)
// 284:       expect(spec.patches.first.strip).to eq(:p1)
// 285:     end
// 286:
// 287:     it "doesn't add a patch with no url" do
// 288:       spec.patch do
// 289:         sha256 "7852a7a365f518b12a1afd763a6a80ece88ac7aeea3c9023aa6c1fe46ac5a1ae"
// 290:       end
// 291:       expect(spec.patches.empty?).to be true
// 292:     end
// 293:   end
// 294: end
