module test

import brew_runtime

// Translated from Homebrew/brew `test/exceptions_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:error) do` at line 8.
pub fn ruby_exceptions_spec_l8_d1_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('error', ...args)
}

// Ruby it `it(:to_s) do` at line 15.
pub fn ruby_exceptions_spec_l15_d2_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby subject `subject(:error) { described_class.new("foo") }` at line 25.
pub fn ruby_exceptions_spec_l25_d3_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('error', ...args)
}

// Ruby it `it(:to_s) { expect(error.to_s).to eq("No such keg: end  context "with a tap" do subject(:error) { described_class.new("foo", tap:) }  let(:tap) { instance_double(Tap, to_s: "u/r") }  it(:to_s) { expect(error.to_s).to eq("No such keg: end end  describe FormulaValidationError do subject(:error) { described_class.new("foo", "sha257", "magic") }  it(:to_s) do expect(error.to_s).to eq(%q(invalid attribute for formula 'foo': sha257 ("magic"))) end end  describe TapFormulaOrCaskUnavailableError do subject(:error) { described_class.new(tap, "foo") }  let(:tap) { instance_double(Tap, user: "u", repository: "r", to_s: "u/r", installed?: false) }  it(:to_s) { expect(error.to_s).to match(%r{If you trust this tap, tap it explicitly and then try again:\n  brew tap u/r}) } end  describe FormulaUnavailableError do subject(:error) { described_class.new("foo") }  describe "#dependent_s" do it "returns nil if there is no dependent" do expect(error.dependent_s).to be_nil end  it "returns nil if it depended on by itself" do error.dependent = "foo" expect(error.dependent_s).to be_nil end  it "returns a string if there is a dependent" do error.dependent = "foobar" expect(error.dependent_s).to eq(" (dependency of foobar)") end end  context "without a dependent" do it(:to_s) { expect(error.to_s).to match(/^No available formula with the name "foo"\./) } end  context "with a dependent" do before do error.dependent = "foobar" end  it(:to_s) do expect(error.to_s).to match(/^No available formula with the name "foo" \(dependency of foobar\)\./) end end end  describe TapFormulaUnavailableError do subject(:error) { described_class.new(tap, "foo") }  let(:tap) { instance_double(Tap, user: "u", repository: "r", to_s: "u/r", installed?: false) }  it(:to_s) { expect(error.to_s).to match(%r{If you trust this tap, tap it explicitly and then try again:\n  brew tap u/r}) } end  describe FormulaClassUnavailableError do subject(:error) { described_class.new("foo", "foo.rb", "Foo", list) }  let(:mod) do Module.new do const_set :Bar, Class.new(Requirement) const_set :Baz, Class.new(Formula) end end  context "when there are no classes" do let(:list) { [] }  it(:to_s) do expect(error.to_s).to include("Expected to find class Foo, but found no classes.") end end  context "when the class is not derived from Formula" do # The constant lives on the dynamically built test module. # rubocop:disable Sorbet/ConstantsFromStrings let(:list) { [mod.const_get(:Bar)] } # rubocop:enable Sorbet/ConstantsFromStrings  it(:to_s) do expect(error.to_s).to include("Expected to find class Foo, but only found: Bar (not derived from Formula!).")` at line 27.
pub fn ruby_exceptions_spec_l27_d4_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby subject `subject(:error) { described_class.new("foo", tap:) }` at line 31.
pub fn ruby_exceptions_spec_l31_d5_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('error', ...args)
}

// Ruby let `let(:tap) { instance_double(Tap, to_s: "u/r") }` at line 33.
pub fn ruby_exceptions_spec_l33_d6_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tap', ...args)
}

// Ruby it `it(:to_s) { expect(error.to_s).to eq("No such keg: end end  describe FormulaValidationError do subject(:error) { described_class.new("foo", "sha257", "magic") }  it(:to_s) do expect(error.to_s).to eq(%q(invalid attribute for formula 'foo': sha257 ("magic"))) end end  describe TapFormulaOrCaskUnavailableError do subject(:error) { described_class.new(tap, "foo") }  let(:tap) { instance_double(Tap, user: "u", repository: "r", to_s: "u/r", installed?: false) }  it(:to_s) { expect(error.to_s).to match(%r{If you trust this tap, tap it explicitly and then try again:\n  brew tap u/r}) } end  describe FormulaUnavailableError do subject(:error) { described_class.new("foo") }  describe "#dependent_s" do it "returns nil if there is no dependent" do expect(error.dependent_s).to be_nil end  it "returns nil if it depended on by itself" do error.dependent = "foo" expect(error.dependent_s).to be_nil end  it "returns a string if there is a dependent" do error.dependent = "foobar" expect(error.dependent_s).to eq(" (dependency of foobar)") end end  context "without a dependent" do it(:to_s) { expect(error.to_s).to match(/^No available formula with the name "foo"\./) } end  context "with a dependent" do before do error.dependent = "foobar" end  it(:to_s) do expect(error.to_s).to match(/^No available formula with the name "foo" \(dependency of foobar\)\./) end end end  describe TapFormulaUnavailableError do subject(:error) { described_class.new(tap, "foo") }  let(:tap) { instance_double(Tap, user: "u", repository: "r", to_s: "u/r", installed?: false) }  it(:to_s) { expect(error.to_s).to match(%r{If you trust this tap, tap it explicitly and then try again:\n  brew tap u/r}) } end  describe FormulaClassUnavailableError do subject(:error) { described_class.new("foo", "foo.rb", "Foo", list) }  let(:mod) do Module.new do const_set :Bar, Class.new(Requirement) const_set :Baz, Class.new(Formula) end end  context "when there are no classes" do let(:list) { [] }  it(:to_s) do expect(error.to_s).to include("Expected to find class Foo, but found no classes.") end end  context "when the class is not derived from Formula" do # The constant lives on the dynamically built test module. # rubocop:disable Sorbet/ConstantsFromStrings let(:list) { [mod.const_get(:Bar)] } # rubocop:enable Sorbet/ConstantsFromStrings  it(:to_s) do expect(error.to_s).to include("Expected to find class Foo, but only found: Bar (not derived from Formula!).") end end  context "when the class is derived from Formula" do # The constant lives on the dynamically built test module. # rubocop:disable Sorbet/ConstantsFromStrings let(:list) { [mod.const_get(:Baz)] } # rubocop:enable Sorbet/ConstantsFromStrings` at line 35.
pub fn ruby_exceptions_spec_l35_d7_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby subject `subject(:error) { described_class.new("foo", "sha257", "magic") }` at line 40.
pub fn ruby_exceptions_spec_l40_d8_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('error', ...args)
}

// Ruby it `it(:to_s) do` at line 42.
pub fn ruby_exceptions_spec_l42_d9_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby subject `subject(:error) { described_class.new(tap, "foo") }` at line 48.
pub fn ruby_exceptions_spec_l48_d10_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('error', ...args)
}

// Ruby let `let(:tap) { instance_double(Tap, user: "u", repository: "r", to_s: "u/r", installed?: false) }` at line 50.
pub fn ruby_exceptions_spec_l50_d11_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tap', ...args)
}

// Ruby it `it(:to_s) {` at line 52.
pub fn ruby_exceptions_spec_l52_d12_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby subject `subject(:error) { described_class.new("foo") }` at line 58.
pub fn ruby_exceptions_spec_l58_d13_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('error', ...args)
}

// Ruby it `it "returns nil if there is no dependent" do` at line 61.
pub fn ruby_exceptions_spec_l61_d14_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns nil if it depended on by itself" do` at line 65.
pub fn ruby_exceptions_spec_l65_d15_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns a string if there is a dependent" do` at line 70.
pub fn ruby_exceptions_spec_l70_d16_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it(:to_s) { expect(error.to_s).to match(/^No available formula with the name "foo"\./) }` at line 77.
pub fn ruby_exceptions_spec_l77_d17_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby it `it(:to_s) do` at line 85.
pub fn ruby_exceptions_spec_l85_d18_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby subject `subject(:error) { described_class.new(tap, "foo") }` at line 92.
pub fn ruby_exceptions_spec_l92_d19_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('error', ...args)
}

// Ruby let `let(:tap) { instance_double(Tap, user: "u", repository: "r", to_s: "u/r", installed?: false) }` at line 94.
pub fn ruby_exceptions_spec_l94_d20_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tap', ...args)
}

// Ruby it `it(:to_s) {` at line 96.
pub fn ruby_exceptions_spec_l96_d21_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby subject `subject(:error) { described_class.new("foo", "foo.rb", "Foo", list) }` at line 102.
pub fn ruby_exceptions_spec_l102_d22_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('error', ...args)
}

// Ruby let `let(:mod) do` at line 104.
pub fn ruby_exceptions_spec_l104_d23_mod(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('mod', ...args)
}

// Ruby let `let(:list) { [] }` at line 112.
pub fn ruby_exceptions_spec_l112_d24_list(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('list', ...args)
}

// Ruby it `it(:to_s) do` at line 114.
pub fn ruby_exceptions_spec_l114_d25_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby let `let(:list) { [mod.const_get(:Bar)] }` at line 122.
pub fn ruby_exceptions_spec_l122_d26_list(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('list', ...args)
}

// Ruby it `it(:to_s) do` at line 125.
pub fn ruby_exceptions_spec_l125_d27_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby let `let(:list) { [mod.const_get(:Baz)] }` at line 133.
pub fn ruby_exceptions_spec_l133_d28_list(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('list', ...args)
}

// Ruby it `it(:to_s) { expect(error.to_s).to include("Expected to find class Foo, but only found: Baz.") }` at line 136.
pub fn ruby_exceptions_spec_l136_d29_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby subject `subject(:error) { described_class.new("foo", formula_error) }` at line 141.
pub fn ruby_exceptions_spec_l141_d30_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('error', ...args)
}

// Ruby let `let(:formula_error) { LoadError.new("bar") }` at line 143.
pub fn ruby_exceptions_spec_l143_d31_formula_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_error', ...args)
}

// Ruby it `it(:to_s) { expect(error.to_s).to eq("foo: bar") }` at line 145.
pub fn ruby_exceptions_spec_l145_d32_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby subject `subject(:error) { described_class.new("foo") }` at line 149.
pub fn ruby_exceptions_spec_l149_d33_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('error', ...args)
}

// Ruby it `it(:to_s) { expect(error.to_s).to eq("No available tap foo.\nRun brew tap-new foo to create a new foo tap!\n") }` at line 151.
pub fn ruby_exceptions_spec_l151_d34_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby subject `subject(:error) { described_class.new("foo") }` at line 155.
pub fn ruby_exceptions_spec_l155_d35_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('error', ...args)
}

// Ruby it `it(:to_s) { expect(error.to_s).to eq("Tap foo already tapped.\n") }` at line 157.
pub fn ruby_exceptions_spec_l157_d36_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby subject `subject(:error) { described_class.new(formula, "badprg", ["arg1", 2, Pathname.new("arg3"), :arg4], {}) }` at line 161.
pub fn ruby_exceptions_spec_l161_d37_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('error', ...args)
}

// Ruby let `let(:formula) { instance_double(Formula, name: "foo") }` at line 163.
pub fn ruby_exceptions_spec_l163_d38_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula', ...args)
}

// Ruby it `it(:to_s) { expect(error.to_s).to eq("Failed executing: badprg arg1 2 arg3 arg4") }` at line 165.
pub fn ruby_exceptions_spec_l165_d39_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby subject `subject(:error) { described_class.new(Pathname("foo")) }` at line 169.
pub fn ruby_exceptions_spec_l169_d40_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('error', ...args)
}

// Ruby it `it(:to_s) { expect(error.to_s).to include("has already locked foo") }` at line 171.
pub fn ruby_exceptions_spec_l171_d41_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby subject `subject(:error) { described_class.new(formula) }` at line 175.
pub fn ruby_exceptions_spec_l175_d42_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('error', ...args)
}

// Ruby let `let(:formula) { instance_double(Formula, full_name: "foo/bar") }` at line 177.
pub fn ruby_exceptions_spec_l177_d43_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula', ...args)
}

// Ruby it `it(:to_s) { expect(error.to_s).to eq("Formula installation already attempted: foo/bar") }` at line 179.
pub fn ruby_exceptions_spec_l179_d44_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby subject `subject(:error) { described_class.new(formula, [conflict]) }` at line 183.
pub fn ruby_exceptions_spec_l183_d45_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('error', ...args)
}

// Ruby let `let(:formula) { instance_double(Formula, full_name: "foo/qux") }` at line 185.
pub fn ruby_exceptions_spec_l185_d46_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula', ...args)
}

// Ruby let `let(:conflict) { instance_double(Formula::FormulaConflict, name: "bar", reason: "I decided to") }` at line 186.
pub fn ruby_exceptions_spec_l186_d47_conflict(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('conflict', ...args)
}

// Ruby it `it(:to_s) { expect(error.to_s).to include("Please `brew unlink bar` before continuing.") }` at line 188.
pub fn ruby_exceptions_spec_l188_d48_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby subject `subject(:error) { described_class.new(formula) }` at line 192.
pub fn ruby_exceptions_spec_l192_d49_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('error', ...args)
}

// Ruby let `let(:formula) { instance_double(Formula, full_name: "foo") }` at line 194.
pub fn ruby_exceptions_spec_l194_d50_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula', ...args)
}

// Ruby it `it(:to_s) { expect(error.to_s).to include("foo cannot be built with any available compilers.") }` at line 196.
pub fn ruby_exceptions_spec_l196_d51_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby subject `subject(:error) { described_class.new("file:///tmp/foo") }` at line 201.
pub fn ruby_exceptions_spec_l201_d52_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('error', ...args)
}

// Ruby it `it(:to_s) { expect(error.to_s).to eq("File cannot be read: /tmp/foo") }` at line 203.
pub fn ruby_exceptions_spec_l203_d53_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby subject `subject(:error) { described_class.new("https://brew.sh") }` at line 207.
pub fn ruby_exceptions_spec_l207_d54_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('error', ...args)
}

// Ruby it `it(:to_s) { expect(error.to_s).to eq("Download failed: https://brew.sh") }` at line 209.
pub fn ruby_exceptions_spec_l209_d55_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby subject `subject(:error) { described_class.new(["badprg", "arg1", "arg2"], status:) }` at line 214.
pub fn ruby_exceptions_spec_l214_d56_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('error', ...args)
}

// Ruby let `let(:status) { instance_double(Process::Status, exitstatus: 17, termsig: nil) }` at line 216.
pub fn ruby_exceptions_spec_l216_d57_status(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('status', ...args)
}

// Ruby it `it(:to_s) { expect(error.to_s).to eq("Failure while executing; `badprg arg1 arg2` exited with 17.") }` at line 218.
pub fn ruby_exceptions_spec_l218_d58_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby subject `subject(:error) { described_class.new("/file.tar.gz", expected_checksum, actual_checksum) }` at line 222.
pub fn ruby_exceptions_spec_l222_d59_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('error', ...args)
}

// Ruby let `let(:expected_checksum) { instance_double(Checksum, to_s: "deadbeef") }` at line 224.
pub fn ruby_exceptions_spec_l224_d60_expected_checksum(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('expected_checksum', ...args)
}

// Ruby let `let(:actual_checksum) { instance_double(Checksum, to_s: "deadcafe") }` at line 225.
pub fn ruby_exceptions_spec_l225_d61_actual_checksum(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('actual_checksum', ...args)
}

// Ruby it `it(:to_s) { expect(error.to_s).to include("SHA-256 mismatch") }` at line 227.
pub fn ruby_exceptions_spec_l227_d62_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby it `it "does not add an HTML hint for non-HTML downloads" do` at line 229.
pub fn ruby_exceptions_spec_l229_d63_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "adds an HTML hint when the download is an HTML page" do` at line 239.
pub fn ruby_exceptions_spec_l239_d64_adds(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('adds', ...args)
}

// Ruby subject `subject(:error) { described_class.new(formula, resource) }` at line 251.
pub fn ruby_exceptions_spec_l251_d65_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('error', ...args)
}

// Ruby let `let(:formula) { instance_double(Formula, full_name: "bar") }` at line 253.
pub fn ruby_exceptions_spec_l253_d66_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula', ...args)
}

// Ruby let `let(:resource) { instance_double(Resource, inspect: "<resource foo>") }` at line 254.
pub fn ruby_exceptions_spec_l254_d67_resource(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('resource', ...args)
}

// Ruby it `it(:to_s) { expect(error.to_s).to eq("bar does not define resource <resource foo>") }` at line 256.
pub fn ruby_exceptions_spec_l256_d68_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby subject `subject(:error) { described_class.new(resource) }` at line 260.
pub fn ruby_exceptions_spec_l260_d69_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('error', ...args)
}

// Ruby let `let(:resource) { instance_double(Resource, inspect: "<resource foo>") }` at line 262.
pub fn ruby_exceptions_spec_l262_d70_resource(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('resource', ...args)
}

// Ruby it `it(:to_s) { expect(error.to_s).to eq("Resource <resource foo> is defined more than once") }` at line 264.
pub fn ruby_exceptions_spec_l264_d71_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby subject `subject(:error) { described_class.new("/foo.bottle.tar.gz", "foo/1.0/.brew/foo.rb") }` at line 268.
pub fn ruby_exceptions_spec_l268_d72_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('error', ...args)
}

// Ruby let `let(:formula) { instance_double(Formula, full_name: "foo") }` at line 270.
pub fn ruby_exceptions_spec_l270_d73_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula', ...args)
}

// Ruby it `it(:to_s) { expect(error.to_s).to include("This bottle does not contain the formula file") }` at line 272.
pub fn ruby_exceptions_spec_l272_d74_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby subject `subject(:error) { described_class.new(["-s"]) }` at line 276.
pub fn ruby_exceptions_spec_l276_d75_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('error', ...args)
}

// Ruby it `it(:to_s) { expect(error.to_s).to match(/flag:\s+-s\nrequires building tools/) }` at line 278.
pub fn ruby_exceptions_spec_l278_d76_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "exceptions"
// 5:
// 6: RSpec.describe "Exception" do
// 7:   describe MultipleVersionsInstalledError do
// 8:     subject(:error) do
// 9:       described_class.new <<~EOS
// 10:         foo has multiple installed versions
// 11:         Run `brew uninstall --force foo` to remove all versions.
// 12:       EOS
// 13:     end
// 14:
// 15:     it(:to_s) do
// 16:       expect(error.to_s).to eq <<~EOS
// 17:         foo has multiple installed versions
// 18:         Run `brew uninstall --force foo` to remove all versions.
// 19:       EOS
// 20:     end
// 21:   end
// 22:
// 23:   describe NoSuchKegError do
// 24:     context "without a tap" do
// 25:       subject(:error) { described_class.new("foo") }
// 26:
// 27:       it(:to_s) { expect(error.to_s).to eq("No such keg: #{HOMEBREW_CELLAR}/foo") }
// 28:     end
// 29:
// 30:     context "with a tap" do
// 31:       subject(:error) { described_class.new("foo", tap:) }
// 32:
// 33:       let(:tap) { instance_double(Tap, to_s: "u/r") }
// 34:
// 35:       it(:to_s) { expect(error.to_s).to eq("No such keg: #{HOMEBREW_CELLAR}/foo from tap u/r") }
// 36:     end
// 37:   end
// 38:
// 39:   describe FormulaValidationError do
// 40:     subject(:error) { described_class.new("foo", "sha257", "magic") }
// 41:
// 42:     it(:to_s) do
// 43:       expect(error.to_s).to eq(%q(invalid attribute for formula 'foo': sha257 ("magic")))
// 44:     end
// 45:   end
// 46:
// 47:   describe TapFormulaOrCaskUnavailableError do
// 48:     subject(:error) { described_class.new(tap, "foo") }
// 49:
// 50:     let(:tap) { instance_double(Tap, user: "u", repository: "r", to_s: "u/r", installed?: false) }
// 51:
// 52:     it(:to_s) {
// 53:       expect(error.to_s).to match(%r{If you trust this tap, tap it explicitly and then try again:\n  brew tap u/r})
// 54:     }
// 55:   end
// 56:
// 57:   describe FormulaUnavailableError do
// 58:     subject(:error) { described_class.new("foo") }
// 59:
// 60:     describe "#dependent_s" do
// 61:       it "returns nil if there is no dependent" do
// 62:         expect(error.dependent_s).to be_nil
// 63:       end
// 64:
// 65:       it "returns nil if it depended on by itself" do
// 66:         error.dependent = "foo"
// 67:         expect(error.dependent_s).to be_nil
// 68:       end
// 69:
// 70:       it "returns a string if there is a dependent" do
// 71:         error.dependent = "foobar"
// 72:         expect(error.dependent_s).to eq(" (dependency of foobar)")
// 73:       end
// 74:     end
// 75:
// 76:     context "without a dependent" do
// 77:       it(:to_s) { expect(error.to_s).to match(/^No available formula with the name "foo"\./) }
// 78:     end
// 79:
// 80:     context "with a dependent" do
// 81:       before do
// 82:         error.dependent = "foobar"
// 83:       end
// 84:
// 85:       it(:to_s) do
// 86:         expect(error.to_s).to match(/^No available formula with the name "foo" \(dependency of foobar\)\./)
// 87:       end
// 88:     end
// 89:   end
// 90:
// 91:   describe TapFormulaUnavailableError do
// 92:     subject(:error) { described_class.new(tap, "foo") }
// 93:
// 94:     let(:tap) { instance_double(Tap, user: "u", repository: "r", to_s: "u/r", installed?: false) }
// 95:
// 96:     it(:to_s) {
// 97:       expect(error.to_s).to match(%r{If you trust this tap, tap it explicitly and then try again:\n  brew tap u/r})
// 98:     }
// 99:   end
// 100:
// 101:   describe FormulaClassUnavailableError do
// 102:     subject(:error) { described_class.new("foo", "foo.rb", "Foo", list) }
// 103:
// 104:     let(:mod) do
// 105:       Module.new do
// 106:         const_set :Bar, Class.new(Requirement)
// 107:         const_set :Baz, Class.new(Formula)
// 108:       end
// 109:     end
// 110:
// 111:     context "when there are no classes" do
// 112:       let(:list) { [] }
// 113:
// 114:       it(:to_s) do
// 115:         expect(error.to_s).to include("Expected to find class Foo, but found no classes.")
// 116:       end
// 117:     end
// 118:
// 119:     context "when the class is not derived from Formula" do
// 120:       # The constant lives on the dynamically built test module.
// 121:       # rubocop:disable Sorbet/ConstantsFromStrings
// 122:       let(:list) { [mod.const_get(:Bar)] }
// 123:       # rubocop:enable Sorbet/ConstantsFromStrings
// 124:
// 125:       it(:to_s) do
// 126:         expect(error.to_s).to include("Expected to find class Foo, but only found: Bar (not derived from Formula!).")
// 127:       end
// 128:     end
// 129:
// 130:     context "when the class is derived from Formula" do
// 131:       # The constant lives on the dynamically built test module.
// 132:       # rubocop:disable Sorbet/ConstantsFromStrings
// 133:       let(:list) { [mod.const_get(:Baz)] }
// 134:       # rubocop:enable Sorbet/ConstantsFromStrings
// 135:
// 136:       it(:to_s) { expect(error.to_s).to include("Expected to find class Foo, but only found: Baz.") }
// 137:     end
// 138:   end
// 139:
// 140:   describe FormulaUnreadableError do
// 141:     subject(:error) { described_class.new("foo", formula_error) }
// 142:
// 143:     let(:formula_error) { LoadError.new("bar") }
// 144:
// 145:     it(:to_s) { expect(error.to_s).to eq("foo: bar") }
// 146:   end
// 147:
// 148:   describe TapUnavailableError do
// 149:     subject(:error) { described_class.new("foo") }
// 150:
// 151:     it(:to_s) { expect(error.to_s).to eq("No available tap foo.\nRun brew tap-new foo to create a new foo tap!\n") }
// 152:   end
// 153:
// 154:   describe TapAlreadyTappedError do
// 155:     subject(:error) { described_class.new("foo") }
// 156:
// 157:     it(:to_s) { expect(error.to_s).to eq("Tap foo already tapped.\n") }
// 158:   end
// 159:
// 160:   describe BuildError do
// 161:     subject(:error) { described_class.new(formula, "badprg", ["arg1", 2, Pathname.new("arg3"), :arg4], {}) }
// 162:
// 163:     let(:formula) { instance_double(Formula, name: "foo") }
// 164:
// 165:     it(:to_s) { expect(error.to_s).to eq("Failed executing: badprg arg1 2 arg3 arg4") }
// 166:   end
// 167:
// 168:   describe OperationInProgressError do
// 169:     subject(:error) { described_class.new(Pathname("foo")) }
// 170:
// 171:     it(:to_s) { expect(error.to_s).to include("has already locked foo") }
// 172:   end
// 173:
// 174:   describe FormulaInstallationAlreadyAttemptedError do
// 175:     subject(:error) { described_class.new(formula) }
// 176:
// 177:     let(:formula) { instance_double(Formula, full_name: "foo/bar") }
// 178:
// 179:     it(:to_s) { expect(error.to_s).to eq("Formula installation already attempted: foo/bar") }
// 180:   end
// 181:
// 182:   describe FormulaConflictError do
// 183:     subject(:error) { described_class.new(formula, [conflict]) }
// 184:
// 185:     let(:formula) { instance_double(Formula, full_name: "foo/qux") }
// 186:     let(:conflict) { instance_double(Formula::FormulaConflict, name: "bar", reason: "I decided to") }
// 187:
// 188:     it(:to_s) { expect(error.to_s).to include("Please `brew unlink bar` before continuing.") }
// 189:   end
// 190:
// 191:   describe CompilerSelectionError do
// 192:     subject(:error) { described_class.new(formula) }
// 193:
// 194:     let(:formula) { instance_double(Formula, full_name: "foo") }
// 195:
// 196:     it(:to_s) { expect(error.to_s).to include("foo cannot be built with any available compilers.") }
// 197:   end
// 198:
// 199:   describe CurlDownloadStrategyError do
// 200:     context "when the file does not exist" do
// 201:       subject(:error) { described_class.new("file:///tmp/foo") }
// 202:
// 203:       it(:to_s) { expect(error.to_s).to eq("File cannot be read: /tmp/foo") }
// 204:     end
// 205:
// 206:     context "when the download failed" do
// 207:       subject(:error) { described_class.new("https://brew.sh") }
// 208:
// 209:       it(:to_s) { expect(error.to_s).to eq("Download failed: https://brew.sh") }
// 210:     end
// 211:   end
// 212:
// 213:   describe ErrorDuringExecution do
// 214:     subject(:error) { described_class.new(["badprg", "arg1", "arg2"], status:) }
// 215:
// 216:     let(:status) { instance_double(Process::Status, exitstatus: 17, termsig: nil) }
// 217:
// 218:     it(:to_s) { expect(error.to_s).to eq("Failure while executing; `badprg arg1 arg2` exited with 17.") }
// 219:   end
// 220:
// 221:   describe ChecksumMismatchError do
// 222:     subject(:error) { described_class.new("/file.tar.gz", expected_checksum, actual_checksum) }
// 223:
// 224:     let(:expected_checksum) { instance_double(Checksum, to_s: "deadbeef") }
// 225:     let(:actual_checksum) { instance_double(Checksum, to_s: "deadcafe") }
// 226:
// 227:     it(:to_s) { expect(error.to_s).to include("SHA-256 mismatch") }
// 228:
// 229:     it "does not add an HTML hint for non-HTML downloads" do
// 230:       Tempfile.create("brew-checksum-test") do |file|
// 231:         file.binmode
// 232:         file.write("PK\x03\x04binary-content")
// 233:         file.flush
// 234:         message = described_class.new(Pathname(file.path), expected_checksum, actual_checksum).to_s
// 235:         expect(message).not_to include("HTML/XML")
// 236:       end
// 237:     end
// 238:
// 239:     it "adds an HTML hint when the download is an HTML page" do
// 240:       Tempfile.create("brew-checksum-test") do |file|
// 241:         file.binmode
// 242:         file.write('<!doctype html><html lang="en"><head><title>Oh noes!</title>')
// 243:         file.flush
// 244:         message = described_class.new(Pathname(file.path), expected_checksum, actual_checksum).to_s
// 245:         expect(message).to include("HTML/XML, not a binary")
// 246:       end
// 247:     end
// 248:   end
// 249:
// 250:   describe ResourceMissingError do
// 251:     subject(:error) { described_class.new(formula, resource) }
// 252:
// 253:     let(:formula) { instance_double(Formula, full_name: "bar") }
// 254:     let(:resource) { instance_double(Resource, inspect: "<resource foo>") }
// 255:
// 256:     it(:to_s) { expect(error.to_s).to eq("bar does not define resource <resource foo>") }
// 257:   end
// 258:
// 259:   describe DuplicateResourceError do
// 260:     subject(:error) { described_class.new(resource) }
// 261:
// 262:     let(:resource) { instance_double(Resource, inspect: "<resource foo>") }
// 263:
// 264:     it(:to_s) { expect(error.to_s).to eq("Resource <resource foo> is defined more than once") }
// 265:   end
// 266:
// 267:   describe BottleFormulaUnavailableError do
// 268:     subject(:error) { described_class.new("/foo.bottle.tar.gz", "foo/1.0/.brew/foo.rb") }
// 269:
// 270:     let(:formula) { instance_double(Formula, full_name: "foo") }
// 271:
// 272:     it(:to_s) { expect(error.to_s).to include("This bottle does not contain the formula file") }
// 273:   end
// 274:
// 275:   describe BuildFlagsError do
// 276:     subject(:error) { described_class.new(["-s"]) }
// 277:
// 278:     it(:to_s) { expect(error.to_s).to match(/flag:\s+-s\nrequires building tools/) }
// 279:   end
// 280: end
