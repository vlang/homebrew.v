module mac

import brew_runtime

// Translated from Homebrew/brew `test/os/mac/mach_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby specify `specify "Sorbet runtime loads MachO before Pathname initialisation", :integration_test do` at line 5.
pub fn ruby_mach_spec_l5_d1_sorbet(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('Sorbet', ...args)
}

// Ruby specify `specify "fat dylib" do` at line 27.
pub fn ruby_mach_spec_l27_d2_fat(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fat', ...args)
}

// Ruby specify `specify "i386 dylib" do` at line 40.
pub fn ruby_mach_spec_l40_d3_i386(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('i386', ...args)
}

// Ruby specify `specify "x86_64 dylib" do` at line 53.
pub fn ruby_mach_spec_l53_d4_x86_64(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('x86_64', ...args)
}

// Ruby specify `specify "Mach-O executable" do` at line 66.
pub fn ruby_mach_spec_l66_d5_mach_o(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('Mach-O', ...args)
}

// Ruby specify `specify "fat bundle" do` at line 79.
pub fn ruby_mach_spec_l79_d6_fat(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fat', ...args)
}

// Ruby specify `specify "i386 bundle" do` at line 92.
pub fn ruby_mach_spec_l92_d7_i386(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('i386', ...args)
}

// Ruby specify `specify "x86_64 bundle" do` at line 105.
pub fn ruby_mach_spec_l105_d8_x86_64(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('x86_64', ...args)
}

// Ruby specify `specify "non-Mach-O" do` at line 118.
pub fn ruby_mach_spec_l118_d9_non_mach_o(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('non-Mach-O', ...args)
}

// Ruby specify `specify "returns nil without rewriting the binary when no rpath matches" do` at line 134.
pub fn ruby_mach_spec_l134_d10_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby let `let(:pn) { MachOPathname.wrap(HOMEBREW_PREFIX/"an_executable") }` at line 143.
pub fn ruby_mach_spec_l143_d11_pn(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pn', ...args)
}

// Ruby specify `specify "simple shebang" do` at line 147.
pub fn ruby_mach_spec_l147_d12_simple(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('simple', ...args)
}

// Ruby specify `specify "shebang with options" do` at line 161.
pub fn ruby_mach_spec_l161_d13_shebang(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('shebang', ...args)
}

// Ruby specify `specify "malformed shebang" do` at line 175.
pub fn ruby_mach_spec_l175_d14_malformed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('malformed', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe MachOShim do
// 5:   specify "Sorbet runtime loads MachO before Pathname initialisation", :integration_test do
// 6:     ruby = <<~RUBY
// 7:       ENV.delete("HOMEBREW_SORBET_RUNTIME")
// 8:
// 9:       require "os/mac/mach"
// 10:       Pathname.prepend(MachOShim)
// 11:       Pathname.new("test")
// 12:
// 13:       abort "MachO is not defined" unless Object.const_defined?(:MachO)
// 14:     RUBY
// 15:
// 16:     _, stderr, status = Open3.capture3(
// 17:       { "HOMEBREW_SORBET_RUNTIME" => "1" },
// 18:       *HOMEBREW_RUBY_EXEC_ARGS,
// 19:       "-I", $LOAD_PATH.join(File::PATH_SEPARATOR),
// 20:       "-rpathname", "-rstandalone/sorbet", "-e", ruby
// 21:     )
// 22:
// 23:     expect(status).to be_success, stderr
// 24:   end
// 25:
// 26:   describe "Pathname tests" do
// 27:     specify "fat dylib" do
// 28:       pn = dylib_path("fat")
// 29:       expect(pn).to be_universal
// 30:       expect(pn).not_to be_i386
// 31:       expect(pn).not_to be_x86_64
// 32:       expect(pn).not_to be_ppc7400
// 33:       expect(pn).not_to be_ppc64
// 34:       expect(pn).to be_dylib
// 35:       expect(pn).not_to be_mach_o_executable
// 36:       expect(pn).not_to be_text_executable
// 37:       expect(pn.arch).to eq(:universal)
// 38:     end
// 39:
// 40:     specify "i386 dylib" do
// 41:       pn = dylib_path("i386")
// 42:       expect(pn).not_to be_universal
// 43:       expect(pn).to be_i386
// 44:       expect(pn).not_to be_x86_64
// 45:       expect(pn).not_to be_ppc7400
// 46:       expect(pn).not_to be_ppc64
// 47:       expect(pn).to be_dylib
// 48:       expect(pn).not_to be_mach_o_executable
// 49:       expect(pn).not_to be_text_executable
// 50:       expect(pn).not_to be_mach_o_bundle
// 51:     end
// 52:
// 53:     specify "x86_64 dylib" do
// 54:       pn = dylib_path("x86_64")
// 55:       expect(pn).not_to be_universal
// 56:       expect(pn).not_to be_i386
// 57:       expect(pn).to be_x86_64
// 58:       expect(pn).not_to be_ppc7400
// 59:       expect(pn).not_to be_ppc64
// 60:       expect(pn).to be_dylib
// 61:       expect(pn).not_to be_mach_o_executable
// 62:       expect(pn).not_to be_text_executable
// 63:       expect(pn).not_to be_mach_o_bundle
// 64:     end
// 65:
// 66:     specify "Mach-O executable" do
// 67:       pn = MachOPathname.wrap("#{TEST_FIXTURE_DIR}/mach/a.out")
// 68:       expect(pn).to be_universal
// 69:       expect(pn).not_to be_i386
// 70:       expect(pn).not_to be_x86_64
// 71:       expect(pn).not_to be_ppc7400
// 72:       expect(pn).not_to be_ppc64
// 73:       expect(pn).not_to be_dylib
// 74:       expect(pn).to be_mach_o_executable
// 75:       expect(pn).not_to be_text_executable
// 76:       expect(pn).not_to be_mach_o_bundle
// 77:     end
// 78:
// 79:     specify "fat bundle" do
// 80:       pn = bundle_path("fat")
// 81:       expect(pn).to be_universal
// 82:       expect(pn).not_to be_i386
// 83:       expect(pn).not_to be_x86_64
// 84:       expect(pn).not_to be_ppc7400
// 85:       expect(pn).not_to be_ppc64
// 86:       expect(pn).not_to be_dylib
// 87:       expect(pn).not_to be_mach_o_executable
// 88:       expect(pn).not_to be_text_executable
// 89:       expect(pn).to be_mach_o_bundle
// 90:     end
// 91:
// 92:     specify "i386 bundle" do
// 93:       pn = bundle_path("i386")
// 94:       expect(pn).not_to be_universal
// 95:       expect(pn).to be_i386
// 96:       expect(pn).not_to be_x86_64
// 97:       expect(pn).not_to be_ppc7400
// 98:       expect(pn).not_to be_ppc64
// 99:       expect(pn).not_to be_dylib
// 100:       expect(pn).not_to be_mach_o_executable
// 101:       expect(pn).not_to be_text_executable
// 102:       expect(pn).to be_mach_o_bundle
// 103:     end
// 104:
// 105:     specify "x86_64 bundle" do
// 106:       pn = bundle_path("x86_64")
// 107:       expect(pn).not_to be_universal
// 108:       expect(pn).not_to be_i386
// 109:       expect(pn).to be_x86_64
// 110:       expect(pn).not_to be_ppc7400
// 111:       expect(pn).not_to be_ppc64
// 112:       expect(pn).not_to be_dylib
// 113:       expect(pn).not_to be_mach_o_executable
// 114:       expect(pn).not_to be_text_executable
// 115:       expect(pn).to be_mach_o_bundle
// 116:     end
// 117:
// 118:     specify "non-Mach-O" do
// 119:       pn = MachOPathname.wrap("#{TEST_FIXTURE_DIR}/tarballs/testball-0.1.tbz")
// 120:       expect(pn).not_to be_universal
// 121:       expect(pn).not_to be_i386
// 122:       expect(pn).not_to be_x86_64
// 123:       expect(pn).not_to be_ppc7400
// 124:       expect(pn).not_to be_ppc64
// 125:       expect(pn).not_to be_dylib
// 126:       expect(pn).not_to be_mach_o_executable
// 127:       expect(pn).not_to be_text_executable
// 128:       expect(pn).not_to be_mach_o_bundle
// 129:       expect(pn.arch).to eq(:dunno)
// 130:     end
// 131:   end
// 132:
// 133:   describe "#delete_rpath" do
// 134:     specify "returns nil without rewriting the binary when no rpath matches" do
// 135:       pn = dylib_path("x86_64")
// 136:       contents = pn.read
// 137:       expect(pn.delete_rpath("/nonexistent", strict: false)).to be_nil
// 138:       expect(pn.read).to eq(contents)
// 139:     end
// 140:   end
// 141:
// 142:   describe "text executables" do
// 143:     let(:pn) { MachOPathname.wrap(HOMEBREW_PREFIX/"an_executable") }
// 144:
// 145:     after { pn.unlink }
// 146:
// 147:     specify "simple shebang" do
// 148:       pn.write "#!/bin/sh"
// 149:       expect(pn).not_to be_universal
// 150:       expect(pn).not_to be_i386
// 151:       expect(pn).not_to be_x86_64
// 152:       expect(pn).not_to be_ppc7400
// 153:       expect(pn).not_to be_ppc64
// 154:       expect(pn).not_to be_dylib
// 155:       expect(pn).not_to be_mach_o_executable
// 156:       expect(pn).to be_text_executable
// 157:       expect(pn.archs).to eq([])
// 158:       expect(pn.arch).to eq(:dunno)
// 159:     end
// 160:
// 161:     specify "shebang with options" do
// 162:       pn.write "#! /usr/bin/perl -w"
// 163:       expect(pn).not_to be_universal
// 164:       expect(pn).not_to be_i386
// 165:       expect(pn).not_to be_x86_64
// 166:       expect(pn).not_to be_ppc7400
// 167:       expect(pn).not_to be_ppc64
// 168:       expect(pn).not_to be_dylib
// 169:       expect(pn).not_to be_mach_o_executable
// 170:       expect(pn).to be_text_executable
// 171:       expect(pn.archs).to eq([])
// 172:       expect(pn.arch).to eq(:dunno)
// 173:     end
// 174:
// 175:     specify "malformed shebang" do
// 176:       pn.write " #!"
// 177:       expect(pn).not_to be_universal
// 178:       expect(pn).not_to be_i386
// 179:       expect(pn).not_to be_x86_64
// 180:       expect(pn).not_to be_ppc7400
// 181:       expect(pn).not_to be_ppc64
// 182:       expect(pn).not_to be_dylib
// 183:       expect(pn).not_to be_mach_o_executable
// 184:       expect(pn).not_to be_text_executable
// 185:       expect(pn.archs).to eq([])
// 186:       expect(pn.arch).to eq(:dunno)
// 187:     end
// 188:   end
// 189: end
