module mac

import brew_runtime

// Translated from Homebrew/brew `test/os/mac/pkgconfig_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `pc_version(library)` at line 18.
pub fn ruby_pkgconfig_spec_l18_d1_pc_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pc_version', ...args)
}

// Ruby let `let(:sdk) { MacOS.sdk_path }` at line 35.
pub fn ruby_pkgconfig_spec_l35_d2_sdk(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sdk', ...args)
}

// Ruby it `it "returns the correct version for bzip2" do` at line 37.
pub fn ruby_pkgconfig_spec_l37_d3_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns the correct version for libcurl" do` at line 59.
pub fn ruby_pkgconfig_spec_l59_d4_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns the correct version for libexslt" do` at line 68.
pub fn ruby_pkgconfig_spec_l68_d5_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns the correct version for libffi" do` at line 79.
pub fn ruby_pkgconfig_spec_l79_d6_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns the correct version for libxml-2.0" do` at line 90.
pub fn ruby_pkgconfig_spec_l90_d7_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns the correct version for libxslt" do` at line 99.
pub fn ruby_pkgconfig_spec_l99_d8_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns the correct version for ncurses" do` at line 108.
pub fn ruby_pkgconfig_spec_l108_d9_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns the correct version for sqlite3" do` at line 121.
pub fn ruby_pkgconfig_spec_l121_d10_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns the correct version for zlib" do` at line 130.
pub fn ruby_pkgconfig_spec_l130_d11_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: # These tests assume the needed SDKs are correctly installed, i.e. `brew doctor` passes.
// 5: # The CLT version installed should be the latest available for the running OS.
// 6: # The tests do not check other OS versions beyond than the one the tests are being run on.
// 7: #
// 8: # It is not possible to automatically check the following libraries for version updates:
// 9: #
// 10: # - libedit (incorrect LIBEDIT_MAJOR/MINOR in histedit.h)
// 11: # - uuid (not a standalone library)
// 12: #
// 13: # Additionally, libffi version detection cannot be performed on systems running Mojave or earlier.
// 14: # TODO: we no longer support Mojave or earlier, so we can fix this now.
// 15: #
// 16: # For indeterminable cases, consult https://opensource.apple.com for the version used.
// 17: RSpec.describe "pkg-config", :needs_ci, type: :system do
// 18:   def pc_version(library)
// 19:     path = HOMEBREW_LIBRARY_PATH/"os/mac/pkgconfig/#{MacOS.version}/#{library}.pc"
// 20:     version = File.foreach(path)
// 21:                   .lazy
// 22:                   .grep(/^Version:\s*?(.+)$/) { Regexp.last_match(1) }
// 23:                   .first
// 24:                   .strip
// 25:     if (match = version.match(/^\${(.+?)}$/))
// 26:       version = File.foreach(path)
// 27:                     .lazy
// 28:                     .grep(/^#{match.captures.first}\s*?=\s*?(.+)$/) { Regexp.last_match(1) }
// 29:                     .first
// 30:                     .strip
// 31:     end
// 32:     version
// 33:   end
// 34:
// 35:   let(:sdk) { MacOS.sdk_path }
// 36:
// 37:   it "returns the correct version for bzip2" do
// 38:     version = File.foreach("#{sdk}/usr/include/bzlib.h")
// 39:                   .lazy
// 40:                   .grep(%r{^\s*bzip2/libbzip2 version (\S+) of }) { Regexp.last_match(1) }
// 41:                   .first
// 42:
// 43:     expect(pc_version("bzip2")).to eq(version)
// 44:   end
// 45:
// 46:   # TODO: uncomment this when GitHub Actions has completed their macOS-26-arm64 expat 2.7.4 rollout
// 47:   # it "returns the correct version for expat" do
// 48:   #   version = File.foreach("#{sdk}/usr/include/expat.h")
// 49:   #                 .lazy
// 50:   #                 .grep(/^\s*#\s*define XML_(MAJOR|MINOR|MICRO)_VERSION (\d+)$/) do
// 51:   #                   { Regexp.last_match(1).downcase => Regexp.last_match(2) }
// 52:   #                 end
// 53:   #                 .reduce(:merge!)
// 54:   #   version = "#{version["major"]}.#{version["minor"]}.#{version["micro"]}"
// 55:
// 56:   #   expect(pc_version("expat")).to eq(version)
// 57:   # end
// 58:
// 59:   it "returns the correct version for libcurl" do
// 60:     version = File.foreach("#{sdk}/usr/include/curl/curlver.h")
// 61:                   .lazy
// 62:                   .grep(/^#define LIBCURL_VERSION "(.*?)"$/) { Regexp.last_match(1) }
// 63:                   .first
// 64:
// 65:     expect(pc_version("libcurl")).to eq(version)
// 66:   end
// 67:
// 68:   it "returns the correct version for libexslt" do
// 69:     version = File.foreach("#{sdk}/usr/include/libexslt/exsltconfig.h")
// 70:                   .lazy
// 71:                   .grep(/^#define LIBEXSLT_VERSION (\d+)$/) { Regexp.last_match(1) }
// 72:                   .first
// 73:                   .rjust(6, "0")
// 74:     version = "#{version[-6..-5].to_i}.#{version[-4..-3].to_i}.#{version[-2..].to_i}"
// 75:
// 76:     expect(pc_version("libexslt")).to eq(version)
// 77:   end
// 78:
// 79:   it "returns the correct version for libffi" do
// 80:     version = File.foreach("#{sdk}/usr/include/ffi/ffi.h")
// 81:                   .lazy
// 82:                   .grep(/^\s*libffi (\S+)\s+(?:- Copyright |$)/) { Regexp.last_match(1) }
// 83:                   .first
// 84:
// 85:     skip "Cannot detect system libffi version." if version == "PyOBJC"
// 86:
// 87:     expect(pc_version("libffi")).to eq(version)
// 88:   end
// 89:
// 90:   it "returns the correct version for libxml-2.0" do
// 91:     version = File.foreach("#{sdk}/usr/include/libxml2/libxml/xmlversion.h")
// 92:                   .lazy
// 93:                   .grep(/^#define LIBXML_DOTTED_VERSION "(.*?)"$/) { Regexp.last_match(1) }
// 94:                   .first
// 95:
// 96:     expect(pc_version("libxml-2.0")).to eq(version)
// 97:   end
// 98:
// 99:   it "returns the correct version for libxslt" do
// 100:     version = File.foreach("#{sdk}/usr/include/libxslt/xsltconfig.h")
// 101:                   .lazy
// 102:                   .grep(/^#define LIBXSLT_DOTTED_VERSION "(.*?)"$/) { Regexp.last_match(1) }
// 103:                   .first
// 104:
// 105:     expect(pc_version("libxslt")).to eq(version)
// 106:   end
// 107:
// 108:   it "returns the correct version for ncurses" do
// 109:     version = File.foreach("#{sdk}/usr/include/ncurses.h")
// 110:                   .lazy
// 111:                   .grep(/^#define NCURSES_VERSION_(MAJOR|MINOR|PATCH) (\d+)$/) do
// 112:                     { Regexp.last_match(1).downcase => Regexp.last_match(2) }
// 113:                   end
// 114:                   .reduce(:merge!)
// 115:     version = "#{version["major"]}.#{version["minor"]}.#{version["patch"]}"
// 116:
// 117:     expect(pc_version("ncurses")).to eq(version)
// 118:     expect(pc_version("ncursesw")).to eq(version)
// 119:   end
// 120:
// 121:   it "returns the correct version for sqlite3" do
// 122:     version = File.foreach("#{sdk}/usr/include/sqlite3.h")
// 123:                   .lazy
// 124:                   .grep(/^#define SQLITE_VERSION\s+?"(.*?)"$/) { Regexp.last_match(1) }
// 125:                   .first
// 126:
// 127:     expect(pc_version("sqlite3")).to eq(version)
// 128:   end
// 129:
// 130:   it "returns the correct version for zlib" do
// 131:     version = File.foreach("#{sdk}/usr/include/zlib.h")
// 132:                   .lazy
// 133:                   .grep(/^#define ZLIB_VERSION "(.*?)"$/) { Regexp.last_match(1) }
// 134:                   .first
// 135:
// 136:     expect(pc_version("zlib")).to eq(version)
// 137:   end
// 138: end
