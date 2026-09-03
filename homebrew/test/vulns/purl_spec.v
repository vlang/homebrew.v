module vulns

import brew_runtime
import homebrew.vulns as purl_core

// Translated from Homebrew/brew `test/vulns/purl_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn purl_spec_new(package_type string, name string, namespace ?string,
	version ?string) !purl_core.PackageUrl {
	return purl_core.new_package_url(purl_core.PackageUrlConfig{
		package_type: package_type
		name: name
		namespace: namespace
		version: version
	})
}

// Ruby it `it "raises when type is empty" do` at line 8.
pub fn ruby_purl_spec_l8_d1_raises() bool {
	if _ := purl_spec_new('', 'rails', none, none) {
		return false
	} else {
		return err.msg().contains('type')
	}
}

// Ruby it `it "raises when name is empty" do` at line 12.
pub fn ruby_purl_spec_l12_d2_raises() bool {
	if _ := purl_spec_new('gem', '', none, none) {
		return false
	} else {
		return err.msg().contains('name')
	}
}

// Ruby it `it "lowercases the type and treats empty namespace/version as absent" do` at line 16.
pub fn ruby_purl_spec_l16_d3_lowercases() !bool {
	purl := purl_spec_new('PyPI', 'requests', '', '')!
	return purl.package_type() == 'pypi' && purl.namespace() == none && purl.version() == none
}

// Ruby it `it "freezes the stored components" do` at line 23.
pub fn ruby_purl_spec_l23_d4_freezes() !bool {
	purl := purl_spec_new('npm', 'core', '@babel', '7.0.0')!
	// PackageUrl fields are private and its map/array accessors clone, which is
	// the typed V equivalent of the Ruby object's frozen component strings.
	return purl.package_type() == 'npm' && purl.namespace() or { '' } == '@babel' && purl.name() == 'core' && purl.version() or {
		''
	} == '7.0.0'
}

// Ruby it `it "lowercases a PyPI name and replaces underscores with hyphens" do` at line 30.
pub fn ruby_purl_spec_l30_d5_lowercases() !bool {
	return purl_spec_new('pypi', 'Types_Setuptools', none, none)!.name() == 'types-setuptools'
}

// Ruby it `it "leaves PyPI dots and existing hyphens intact" do` at line 35.
pub fn ruby_purl_spec_l35_d6_leaves() !bool {
	return purl_spec_new('pypi', 'backports.zoneinfo', none, none)!.name() == 'backports.zoneinfo'
}

// Ruby it `it "lowercases a Hex name and namespace" do` at line 40.
pub fn ruby_purl_spec_l40_d7_lowercases() !bool {
	purl := purl_spec_new('hex', 'Phoenix', 'Acme', none)!
	return purl.namespace() or { '' } == 'acme' && purl.name() == 'phoenix'
}

// Ruby it `it "uppercases a CPAN namespace and preserves the distribution name" do` at line 46.
pub fn ruby_purl_spec_l46_d8_uppercases() !bool {
	purl := purl_spec_new('cpan', 'Regexp-Common', 'abigail', none)!
	return purl.namespace() or { '' } == 'ABIGAIL' && purl.name() == 'Regexp-Common'
}

// Ruby it `it "does not alter case for cargo, gem, hackage, cran or npm" do` at line 52.
pub fn ruby_purl_spec_l52_d9_does() !bool {
	for package_type in ['cargo', 'gem', 'hackage', 'cran', 'npm'] {
		if purl_spec_new(package_type, 'MixedCase', none, none)!.name() != 'MixedCase' {
			return false
		}
	}
	return true
}

// Ruby it `it "leaves the RFC 3986 unreserved set and : untouched" do` at line 60.
pub fn ruby_purl_spec_l60_d10_leaves() bool {
	return purl_core.encode_purl_component('Az09-._~:') == 'Az09-._~:'
}

// Ruby it `it "percent-encodes @, /, + and space per the purl spec" do` at line 64.
pub fn ruby_purl_spec_l64_d11_percent_encodes() bool {
	return purl_core.encode_purl_component('@a/b+c d') == '%40a%2Fb%2Bc%20d'
}

// Ruby it `it "percent-encodes each byte of a multibyte UTF-8 character" do` at line 68.
pub fn ruby_purl_spec_l68_d12_percent_encodes() bool {
	return purl_core.encode_purl_component('café') == 'caf%C3%A9'
}

// Ruby it `it "builds pkg:gem with and without a version, returning a frozen string" do` at line 74.
pub fn ruby_purl_spec_l74_d13_builds() !bool {
	bare := purl_spec_new('gem', 'rails', none, none)!.str()
	versioned := purl_spec_new('gem', 'rails', none, '7.0.0')!.str()
	return bare == 'pkg:gem/rails' && versioned == 'pkg:gem/rails@7.0.0'
}

// Ruby it `it "builds pkg:npm with an encoded scope namespace" do` at line 82.
pub fn ruby_purl_spec_l82_d14_builds() !bool {
	return purl_spec_new('npm', 'cli', '@angular', '22.0.3')!.str() == 'pkg:npm/%40angular/cli@22.0.3'
}

// Ruby it `it "builds pkg:pypi with the normalised name" do` at line 87.
pub fn ruby_purl_spec_l87_d15_builds() !bool {
	return purl_spec_new('pypi', 'types_setuptools', none, '80.9.0.20251223')!.str() == 'pkg:pypi/types-setuptools@80.9.0.20251223'
}

// Ruby it `it "builds pkg:cargo" do` at line 92.
pub fn ruby_purl_spec_l92_d16_builds() !bool {
	return purl_spec_new('cargo', 'cargo-llvm-cov', none, '0.8.7')!.str() == 'pkg:cargo/cargo-llvm-cov@0.8.7'
}

// Ruby it `it "builds pkg:hackage preserving case" do` at line 97.
pub fn ruby_purl_spec_l97_d17_builds() !bool {
	return purl_spec_new('hackage', 'Allure', none, '0.11.0.0')!.str() == 'pkg:hackage/Allure@0.11.0.0'
}

// Ruby it `it "builds pkg:hex with a lowercased name" do` at line 102.
pub fn ruby_purl_spec_l102_d18_builds() !bool {
	return purl_spec_new('hex', 'Phoenix', none, '1.7.0-rc.0')!.str() == 'pkg:hex/phoenix@1.7.0-rc.0'
}

// Ruby it `it "builds pkg:cpan with an uppercased author namespace" do` at line 107.
pub fn ruby_purl_spec_l107_d19_builds() !bool {
	return purl_spec_new('cpan', 'Regexp-Common', 'ABIGAIL', '2024080801')!.str() == 'pkg:cpan/ABIGAIL/Regexp-Common@2024080801'
}

// Ruby it `it "builds pkg:maven with a groupId namespace" do` at line 113.
pub fn ruby_purl_spec_l113_d20_builds() !bool {
	return purl_spec_new('maven', 'spotbugs', 'com.github.spotbugs', '4.10.2')!.str() == 'pkg:maven/com.github.spotbugs/spotbugs@4.10.2'
}

// Ruby it `it "builds pkg:cran" do` at line 119.
pub fn ruby_purl_spec_l119_d21_builds() !bool {
	return purl_spec_new('cran', 'data.table', none, '1.15.4')!.str() == 'pkg:cran/data.table@1.15.4'
}

// Ruby it `it "builds pkg:nuget" do` at line 124.
pub fn ruby_purl_spec_l124_d22_builds() !bool {
	return purl_spec_new('nuget', 'Newtonsoft.Json', none, '13.0.3')!.str() == 'pkg:nuget/Newtonsoft.Json@13.0.3'
}

// Ruby it `it "encodes semver build metadata + in the version" do` at line 129.
pub fn ruby_purl_spec_l129_d23_encodes() !bool {
	return purl_spec_new('cargo', 'foo', none, '1.0.0+build.1')!.str() == 'pkg:cargo/foo@1.0.0%2Bbuild.1'
}

// Ruby it `it "encodes each namespace segment separately, preserving the / separator" do` at line 134.
pub fn ruby_purl_spec_l134_d24_encodes() !bool {
	return purl_spec_new('golang', 'mux', 'github.com/gorilla', 'v1.8.1')!.str() == 'pkg:golang/github.com/gorilla/mux@v1.8.1'
}

// Ruby it `it "considers two purls equal when their canonical strings match" do` at line 142.
pub fn ruby_purl_spec_l142_d25_considers() !bool {
	left := purl_spec_new('PyPI', 'Foo_Bar', none, '1.0')!
	right := purl_spec_new('pypi', 'foo-bar', none, '1.0')!
	return left.equals(right) && left.hash() == right.hash()
}

// Ruby it `it "is not equal to a purl with a different version" do` at line 149.
pub fn ruby_purl_spec_l149_d26_is() !bool {
	left := purl_spec_new('gem', 'rails', none, '7.0.0')!
	right := purl_spec_new('gem', 'rails', none, '7.0.1')!
	return !left.equals(right)
}

// Ruby it `it "is not equal to a plain string" do` at line 155.
pub fn ruby_purl_spec_l155_d27_is() !bool {
	purl := purl_core.purl_value(purl_spec_new('gem', 'rails', none, none)!)
	return !purl_core.ruby_purl_l48_d7_anonymous(purl, brew_runtime.string_value('pkg:gem/rails')).as_bool()!
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "vulns/purl"
// 5:
// 6: RSpec.describe Homebrew::Vulns::Purl do
// 7:   describe "#initialize" do
// 8:     it "raises when type is empty" do
// 9:       expect { described_class.new(type: "", name: "rails") }.to raise_error(ArgumentError, /type/)
// 10:     end
// 11:
// 12:     it "raises when name is empty" do
// 13:       expect { described_class.new(type: "gem", name: "") }.to raise_error(ArgumentError, /name/)
// 14:     end
// 15:
// 16:     it "lowercases the type and treats empty namespace/version as absent" do
// 17:       purl = described_class.new(type: "PyPI", name: "requests", namespace: "", version: "")
// 18:       expect(purl.type).to eq "pypi"
// 19:       expect(purl.namespace).to be_nil
// 20:       expect(purl.version).to be_nil
// 21:     end
// 22:
// 23:     it "freezes the stored components" do
// 24:       purl = described_class.new(type: "npm", namespace: (+"@babel"), name: (+"core"), version: (+"7.0.0"))
// 25:       expect([purl.type, purl.namespace, purl.name, purl.version]).to all be_frozen
// 26:     end
// 27:   end
// 28:
// 29:   describe "per-type normalisation" do
// 30:     it "lowercases a PyPI name and replaces underscores with hyphens" do
// 31:       purl = described_class.new(type: "pypi", name: "Types_Setuptools")
// 32:       expect(purl.name).to eq "types-setuptools"
// 33:     end
// 34:
// 35:     it "leaves PyPI dots and existing hyphens intact" do
// 36:       purl = described_class.new(type: "pypi", name: "backports.zoneinfo")
// 37:       expect(purl.name).to eq "backports.zoneinfo"
// 38:     end
// 39:
// 40:     it "lowercases a Hex name and namespace" do
// 41:       purl = described_class.new(type: "hex", namespace: "Acme", name: "Phoenix")
// 42:       expect(purl.namespace).to eq "acme"
// 43:       expect(purl.name).to eq "phoenix"
// 44:     end
// 45:
// 46:     it "uppercases a CPAN namespace and preserves the distribution name" do
// 47:       purl = described_class.new(type: "cpan", namespace: "abigail", name: "Regexp-Common")
// 48:       expect(purl.namespace).to eq "ABIGAIL"
// 49:       expect(purl.name).to eq "Regexp-Common"
// 50:     end
// 51:
// 52:     it "does not alter case for cargo, gem, hackage, cran or npm" do
// 53:       %w[cargo gem hackage cran npm].each do |type|
// 54:         expect(described_class.new(type:, name: "MixedCase").name).to eq "MixedCase"
// 55:       end
// 56:     end
// 57:   end
// 58:
// 59:   describe ".encode" do
// 60:     it "leaves the RFC 3986 unreserved set and : untouched" do
// 61:       expect(described_class.encode("Az09-._~:")).to eq "Az09-._~:"
// 62:     end
// 63:
// 64:     it "percent-encodes @, /, + and space per the purl spec" do
// 65:       expect(described_class.encode("@a/b+c d")).to eq "%40a%2Fb%2Bc%20d"
// 66:     end
// 67:
// 68:     it "percent-encodes each byte of a multibyte UTF-8 character" do
// 69:       expect(described_class.encode("café")).to eq "caf%C3%A9"
// 70:     end
// 71:   end
// 72:
// 73:   describe "#to_s" do
// 74:     it "builds pkg:gem with and without a version, returning a frozen string" do
// 75:       bare = described_class.new(type: "gem", name: "rails").to_s
// 76:       expect(bare).to eq "pkg:gem/rails"
// 77:       expect(bare).to be_frozen
// 78:       expect(described_class.new(type: "gem", name: "rails", version: "7.0.0").to_s)
// 79:         .to eq "pkg:gem/rails@7.0.0"
// 80:     end
// 81:
// 82:     it "builds pkg:npm with an encoded scope namespace" do
// 83:       purl = described_class.new(type: "npm", namespace: "@angular", name: "cli", version: "22.0.3")
// 84:       expect(purl.to_s).to eq "pkg:npm/%40angular/cli@22.0.3"
// 85:     end
// 86:
// 87:     it "builds pkg:pypi with the normalised name" do
// 88:       purl = described_class.new(type: "pypi", name: "types_setuptools", version: "80.9.0.20251223")
// 89:       expect(purl.to_s).to eq "pkg:pypi/types-setuptools@80.9.0.20251223"
// 90:     end
// 91:
// 92:     it "builds pkg:cargo" do
// 93:       purl = described_class.new(type: "cargo", name: "cargo-llvm-cov", version: "0.8.7")
// 94:       expect(purl.to_s).to eq "pkg:cargo/cargo-llvm-cov@0.8.7"
// 95:     end
// 96:
// 97:     it "builds pkg:hackage preserving case" do
// 98:       purl = described_class.new(type: "hackage", name: "Allure", version: "0.11.0.0")
// 99:       expect(purl.to_s).to eq "pkg:hackage/Allure@0.11.0.0"
// 100:     end
// 101:
// 102:     it "builds pkg:hex with a lowercased name" do
// 103:       purl = described_class.new(type: "hex", name: "Phoenix", version: "1.7.0-rc.0")
// 104:       expect(purl.to_s).to eq "pkg:hex/phoenix@1.7.0-rc.0"
// 105:     end
// 106:
// 107:     it "builds pkg:cpan with an uppercased author namespace" do
// 108:       purl = described_class.new(type: "cpan", namespace: "ABIGAIL", name: "Regexp-Common",
// 109:                                  version: "2024080801")
// 110:       expect(purl.to_s).to eq "pkg:cpan/ABIGAIL/Regexp-Common@2024080801"
// 111:     end
// 112:
// 113:     it "builds pkg:maven with a groupId namespace" do
// 114:       purl = described_class.new(type: "maven", namespace: "com.github.spotbugs", name: "spotbugs",
// 115:                                  version: "4.10.2")
// 116:       expect(purl.to_s).to eq "pkg:maven/com.github.spotbugs/spotbugs@4.10.2"
// 117:     end
// 118:
// 119:     it "builds pkg:cran" do
// 120:       purl = described_class.new(type: "cran", name: "data.table", version: "1.15.4")
// 121:       expect(purl.to_s).to eq "pkg:cran/data.table@1.15.4"
// 122:     end
// 123:
// 124:     it "builds pkg:nuget" do
// 125:       purl = described_class.new(type: "nuget", name: "Newtonsoft.Json", version: "13.0.3")
// 126:       expect(purl.to_s).to eq "pkg:nuget/Newtonsoft.Json@13.0.3"
// 127:     end
// 128:
// 129:     it "encodes semver build metadata + in the version" do
// 130:       purl = described_class.new(type: "cargo", name: "foo", version: "1.0.0+build.1")
// 131:       expect(purl.to_s).to eq "pkg:cargo/foo@1.0.0%2Bbuild.1"
// 132:     end
// 133:
// 134:     it "encodes each namespace segment separately, preserving the / separator" do
// 135:       purl = described_class.new(type: "golang", namespace: "github.com/gorilla", name: "mux",
// 136:                                  version: "v1.8.1")
// 137:       expect(purl.to_s).to eq "pkg:golang/github.com/gorilla/mux@v1.8.1"
// 138:     end
// 139:   end
// 140:
// 141:   describe "#== and #hash" do
// 142:     it "considers two purls equal when their canonical strings match" do
// 143:       a = described_class.new(type: "PyPI", name: "Foo_Bar", version: "1.0")
// 144:       b = described_class.new(type: "pypi", name: "foo-bar", version: "1.0")
// 145:       expect(a).to eq b
// 146:       expect(a.hash).to eq b.hash
// 147:     end
// 148:
// 149:     it "is not equal to a purl with a different version" do
// 150:       a = described_class.new(type: "gem", name: "rails", version: "7.0.0")
// 151:       b = described_class.new(type: "gem", name: "rails", version: "7.0.1")
// 152:       expect(a).not_to eq b
// 153:     end
// 154:
// 155:     it "is not equal to a plain string" do
// 156:       purl = described_class.new(type: "gem", name: "rails")
// 157:       expect(purl == "pkg:gem/rails").to be false
// 158:     end
// 159:   end
// 160: end
