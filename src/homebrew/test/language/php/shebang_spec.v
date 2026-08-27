module php

import brew_runtime

// Translated from Homebrew/brew `test/language/php/shebang_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:file) { Tempfile.new("php-shebang") }` at line 8.
pub fn ruby_shebang_spec_l8_d1_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('file', ...args)
}

// Ruby let `let(:broken_file) { Tempfile.new("php-shebang") }` at line 9.
pub fn ruby_shebang_spec_l9_d2_broken_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('broken_file', ...args)
}

// Ruby let `let(:f) do` at line 10.
pub fn ruby_shebang_spec_l10_d3_f(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('f', ...args)
}

// Ruby it `it "can be used to replace PHP shebangs" do` at line 62.
pub fn ruby_shebang_spec_l62_d4_can(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('can', ...args)
}

// Ruby it `it "can fix broken shebang like `#!php`" do` at line 74.
pub fn ruby_shebang_spec_l74_d5_can(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('can', ...args)
}

// Ruby it `it "errors if formula doesn't depend on PHP" do` at line 87.
pub fn ruby_shebang_spec_l87_d6_errors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('errors', ...args)
}

// Ruby it `it "errors if formula depends on more than one php" do` at line 92.
pub fn ruby_shebang_spec_l92_d7_errors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('errors', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "language/php"
// 5: require "utils/shebang"
// 6:
// 7: RSpec.describe Language::PHP::Shebang do
// 8:   let(:file) { Tempfile.new("php-shebang") }
// 9:   let(:broken_file) { Tempfile.new("php-shebang") }
// 10:   let(:f) do
// 11:     f = {}
// 12:
// 13:     f[:php81] = formula "php@8.1" do
// 14:       T.bind(self, T.class_of(Formula))
// 15:       url "https://brew.sh/node-18.0.0.tgz"
// 16:     end
// 17:
// 18:     f[:versioned_php_dep] = formula "foo" do
// 19:       T.bind(self, T.class_of(Formula))
// 20:       url "https://brew.sh/foo-1.0.tgz"
// 21:
// 22:       depends_on "php@8.1"
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
// 34:       depends_on "php"
// 35:       depends_on "php@8.1"
// 36:     end
// 37:
// 38:     f
// 39:   end
// 40:
// 41:   before do
// 42:     file.write <<~EOS
// 43:       #!/usr/bin/env php
// 44:       a
// 45:       b
// 46:       c
// 47:     EOS
// 48:     file.flush
// 49:
// 50:     broken_file.write <<~EOS
// 51:       #!php
// 52:       a
// 53:       b
// 54:       c
// 55:     EOS
// 56:     broken_file.flush
// 57:   end
// 58:
// 59:   after { [file, broken_file].each(&:unlink) }
// 60:
// 61:   describe "#detected_php_shebang" do
// 62:     it "can be used to replace PHP shebangs" do
// 63:       allow(Formulary).to receive(:factory).with(f[:php81].name).and_return(f[:php81])
// 64:       Utils::Shebang.rewrite_shebang described_class.detected_php_shebang(f[:versioned_php_dep]), file.path
// 65:
// 66:       expect(File.read(file)).to eq <<~EOS
// 67:         #!#{HOMEBREW_PREFIX/"opt/php@8.1/bin/php"}
// 68:         a
// 69:         b
// 70:         c
// 71:       EOS
// 72:     end
// 73:
// 74:     it "can fix broken shebang like `#!php`" do
// 75:       allow(Formulary).to receive(:factory).with(f[:php81].name).and_return(f[:php81])
// 76:       Utils::Shebang.rewrite_shebang described_class.detected_php_shebang(f[:versioned_php_dep]),
// 77:                                      broken_file.path
// 78:
// 79:       expect(File.read(broken_file)).to eq <<~EOS
// 80:         #!#{HOMEBREW_PREFIX/"opt/php@8.1/bin/php"}
// 81:         a
// 82:         b
// 83:         c
// 84:       EOS
// 85:     end
// 86:
// 87:     it "errors if formula doesn't depend on PHP" do
// 88:       expect { Utils::Shebang.rewrite_shebang described_class.detected_php_shebang(f[:no_deps]), file.path }
// 89:         .to raise_error(ShebangDetectionError, "Cannot detect PHP shebang: formula does not depend on PHP.")
// 90:     end
// 91:
// 92:     it "errors if formula depends on more than one php" do
// 93:       expect { Utils::Shebang.rewrite_shebang described_class.detected_php_shebang(f[:multiple_deps]), file.path }
// 94:         .to raise_error(ShebangDetectionError, "Cannot detect PHP shebang: formula has multiple PHP dependencies.")
// 95:     end
// 96:   end
// 97: end
