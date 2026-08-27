module node

import brew_runtime

// Translated from Homebrew/brew `test/language/node/shebang_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:file) { Tempfile.new("node-shebang") }` at line 8.
pub fn ruby_shebang_spec_l8_d1_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('file', ...args)
}

// Ruby let `let(:broken_file) { Tempfile.new("node-shebang") }` at line 9.
pub fn ruby_shebang_spec_l9_d2_broken_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('broken_file', ...args)
}

// Ruby let `let(:f) do` at line 10.
pub fn ruby_shebang_spec_l10_d3_f(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('f', ...args)
}

// Ruby it `it "can be used to replace Node shebangs" do` at line 61.
pub fn ruby_shebang_spec_l61_d4_can(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('can', ...args)
}

// Ruby it `it "can fix broken shebang like `#!node`" do` at line 73.
pub fn ruby_shebang_spec_l73_d5_can(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('can', ...args)
}

// Ruby it `it "errors if formula doesn't depend on node" do` at line 86.
pub fn ruby_shebang_spec_l86_d6_errors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('errors', ...args)
}

// Ruby it `it "errors if formula depends on more than one node" do` at line 91.
pub fn ruby_shebang_spec_l91_d7_errors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('errors', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "language/node"
// 5: require "utils/shebang"
// 6:
// 7: RSpec.describe Language::Node::Shebang do
// 8:   let(:file) { Tempfile.new("node-shebang") }
// 9:   let(:broken_file) { Tempfile.new("node-shebang") }
// 10:   let(:f) do
// 11:     f = {}
// 12:
// 13:     f[:node18] = formula "node@18" do
// 14:       T.bind(self, T.class_of(Formula))
// 15:       url "https://brew.sh/node-18.0.0.tgz"
// 16:     end
// 17:
// 18:     f[:versioned_node_dep] = formula "foo" do
// 19:       T.bind(self, T.class_of(Formula))
// 20:       url "https://brew.sh/foo-1.0.tgz"
// 21:
// 22:       depends_on "node@18"
// 23:     end
// 24:
// 25:     f[:no_deps] = formula "foo" do
// 26:       T.bind(self, T.class_of(Formula))
// 27:       url "https://brew.sh/foo-1.0.tgz"
// 28:     end
// 29:
// 30:     f[:multiple_deps] = formula "foo" do
// 31:       T.bind(self, T.class_of(Formula))
// 32:       url "https://brew.sh/foo-1.0.tgz"
// 33:
// 34:       depends_on "node"
// 35:       depends_on "node@18"
// 36:     end
// 37:
// 38:     f
// 39:   end
// 40:
// 41:   before do
// 42:     file.write <<~EOS
// 43:       #!/usr/bin/env node
// 44:       a
// 45:       b
// 46:       c
// 47:     EOS
// 48:     file.flush
// 49:     broken_file.write <<~EOS
// 50:       #!node
// 51:       a
// 52:       b
// 53:       c
// 54:     EOS
// 55:     broken_file.flush
// 56:   end
// 57:
// 58:   after { [file, broken_file].each(&:unlink) }
// 59:
// 60:   describe "#detected_node_shebang" do
// 61:     it "can be used to replace Node shebangs" do
// 62:       allow(Formulary).to receive(:factory).with(f[:node18].name).and_return(f[:node18])
// 63:       Utils::Shebang.rewrite_shebang described_class.detected_node_shebang(f[:versioned_node_dep]), file.path
// 64:
// 65:       expect(File.read(file)).to eq <<~EOS
// 66:         #!#{HOMEBREW_PREFIX/"opt/node@18/bin/node"}
// 67:         a
// 68:         b
// 69:         c
// 70:       EOS
// 71:     end
// 72:
// 73:     it "can fix broken shebang like `#!node`" do
// 74:       allow(Formulary).to receive(:factory).with(f[:node18].name).and_return(f[:node18])
// 75:       Utils::Shebang.rewrite_shebang described_class.detected_node_shebang(f[:versioned_node_dep]),
// 76:                                      broken_file.path
// 77:
// 78:       expect(File.read(broken_file)).to eq <<~EOS
// 79:         #!#{HOMEBREW_PREFIX/"opt/node@18/bin/node"}
// 80:         a
// 81:         b
// 82:         c
// 83:       EOS
// 84:     end
// 85:
// 86:     it "errors if formula doesn't depend on node" do
// 87:       expect { Utils::Shebang.rewrite_shebang described_class.detected_node_shebang(f[:no_deps]), file.path }
// 88:         .to raise_error(ShebangDetectionError, "Cannot detect Node shebang: formula does not depend on Node.")
// 89:     end
// 90:
// 91:     it "errors if formula depends on more than one node" do
// 92:       expect { Utils::Shebang.rewrite_shebang described_class.detected_node_shebang(f[:multiple_deps]), file.path }
// 93:         .to raise_error(ShebangDetectionError, "Cannot detect Node shebang: formula has multiple Node dependencies.")
// 94:     end
// 95:   end
// 96: end
