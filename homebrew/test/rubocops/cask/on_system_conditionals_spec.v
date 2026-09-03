module cask

import homebrew.rubocops.cask as on_system_core

// Translated from Homebrew/brew `test/rubocops/cask/on_system_conditionals_spec.rb`.
// Pinned at df30fd34cc7132abfb8dbe3b1d046e3d48a57d00.

// Ruby it `it "accepts when there are no `on_*` blocks" do` at line 8.
pub fn ruby_on_system_conditionals_spec_l8_d1_accepts() bool {
	source := "cask 'foo' do\n  postflight do\n    foobar\n  end\nend"
	return on_system_core.audit_cask_on_system_conditionals(source).len == 0
}

// Ruby it `it "reports an offense it contains an `on_intel` block" do` at line 18.
pub fn ruby_on_system_conditionals_spec_l18_d2_reports() bool {
	source := "cask 'foo' do\n  postflight do\n    on_intel do\n      foobar\n    end\n  end\nend"
	expected := "cask 'foo' do\n  postflight do\n    if Hardware::CPU.intel?\n      foobar\n    end\n  end\nend"
	problems := on_system_core.audit_cask_on_system_conditionals(source)
	return problems.len == 1 && source[problems[0].begin_pos..problems[0].end_pos] == 'on_intel do' && problems[0].message == 'Instead of using `on_intel` in `postflight do`, use `if Hardware::CPU.intel?`.' && on_system_core.correct_cask_on_system_conditionals(source) == expected
}

// Ruby it `it "reports an offense when it contains an `on_monterey` block" do` at line 41.
pub fn ruby_on_system_conditionals_spec_l41_d3_reports() bool {
	source := "cask 'foo' do\n  postflight do\n    on_monterey do\n      foobar\n    end\n  end\nend"
	expected := "cask 'foo' do\n  postflight do\n    if MacOS.version == :monterey\n      foobar\n    end\n  end\nend"
	problems := on_system_core.audit_cask_on_system_conditionals(source)
	return problems.len == 1 && problems[0].message == 'Instead of using `on_monterey` in `postflight do`, use `if MacOS.version == :monterey`.' && on_system_core.correct_cask_on_system_conditionals(source) == expected
}

// Ruby it `it "reports an offense when it contains an `on_monterey :or_older` block" do` at line 64.
pub fn ruby_on_system_conditionals_spec_l64_d4_reports() bool {
	source := "cask 'foo' do\n  postflight do\n    on_monterey :or_older do\n      foobar\n    end\n  end\nend"
	expected := "cask 'foo' do\n  postflight do\n    if MacOS.version <= :monterey\n      foobar\n    end\n  end\nend"
	problems := on_system_core.audit_cask_on_system_conditionals(source)
	return problems.len == 1 && source[problems[0].begin_pos..problems[0].end_pos] == 'on_monterey :or_older do' && on_system_core.correct_cask_on_system_conditionals(source) == expected
}

// Ruby it `it "accepts when there are no `on_arch` blocks" do` at line 89.
pub fn ruby_on_system_conditionals_spec_l89_d5_accepts() bool {
	source := 'cask \'foo\' do\n  sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"\nend'
	return on_system_core.audit_cask_on_system_conditionals(source).len == 0
}

// Ruby it `it "accepts when the `sha256` stanza is used with keyword arguments" do` at line 97.
pub fn ruby_on_system_conditionals_spec_l97_d6_accepts() bool {
	source := 'cask \'foo\' do\n  sha256 arm:   "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94",\n         intel: "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"\nend'
	return on_system_core.audit_cask_on_system_conditionals(source).len == 0
}

// Ruby it `it "reports an offense when `sha256` has identical values for different architectures" do` at line 106.
pub fn ruby_on_system_conditionals_spec_l106_d7_reports() bool {
	sha := '5f42cb017dd07270409eaee7c3b4a164ffa7c0f21d85c65840c4f81aab21d457'
	source := 'cask \'foo\' do\n  sha256 arm:   "${sha}",\n         intel: "${sha}"\nend'
	problems := on_system_core.audit_cask_on_system_conditionals(source)
	return problems.len == 1 && problems[0].message == on_system_core.on_system_identical_sha_message && source[problems[0].begin_pos..problems[0].end_pos] == 'sha256 arm:   "${sha}",\n         intel: "${sha}"'
}

// Ruby it `it "accepts when there is only one `on_arch` block" do` at line 116.
pub fn ruby_on_system_conditionals_spec_l116_d8_accepts() bool {
	source := 'cask \'foo\' do\n  on_intel do\n    sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"\n  end\nend'
	return on_system_core.audit_cask_on_system_conditionals(source).len == 0
}

// Ruby it `it "reports an offense when `sha256` is specified in all `on_arch` blocks" do` at line 126.
pub fn ruby_on_system_conditionals_spec_l126_d9_reports() bool {
	source := 'cask \'foo\' do\n  on_intel do\n    sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"\n  end\n  on_arm do\n    sha256 "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"\n  end\nend'
	expected := 'cask \'foo\' do\n  sha256 arm: "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b", intel: "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"\nend'
	problems := on_system_core.audit_cask_on_system_conditionals(source)
	return problems.len == 1 && problems[0].message == on_system_core.on_system_sha_only_message && source[problems[0].begin_pos..problems[0].end_pos].starts_with('on_arm do') && on_system_core.correct_cask_on_system_conditionals(source) == expected
}

// Ruby it `it "reports an offense but does not autocorrect when an `on_arch` block includes comments" do` at line 146.
pub fn ruby_on_system_conditionals_spec_l146_d10_reports() bool {
	source := 'cask \'foo\' do\n  on_intel do\n    # comment\n    sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"\n  end\n  on_arm do\n    sha256 "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"\n  end\nend'
	problems := on_system_core.audit_cask_on_system_conditionals(source)
	return problems.len == 1 && problems[0].replacement == '' && on_system_core.correct_cask_on_system_conditionals(source) == source
}

// Ruby it `it "accepts when there is also a `version` stanza inside the `on_arch` blocks with different versions" do` at line 163.
pub fn ruby_on_system_conditionals_spec_l163_d11_accepts() bool {
	source := 'cask \'foo\' do\n  on_intel do\n    version "1.0.0"\n    sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"\n  end\n  on_arm do\n    version "2.0.0"\n    sha256 "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"\n  end\nend'
	return on_system_core.audit_cask_on_system_conditionals(source).len == 0
}

// Ruby it `it "accepts when there is also a `version` stanza inside only a single `on_arch` block" do` at line 178.
pub fn ruby_on_system_conditionals_spec_l178_d12_accepts() bool {
	source := 'cask \'foo\' do\n  on_intel do\n    version "2.0.0"\n    sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"\n  end\n  on_arm do\n    sha256 "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"\n  end\nend'
	return on_system_core.audit_cask_on_system_conditionals(source).len == 0
}

// Ruby it `it "reports an offense when `version` is identical in both arch blocks but `sha256` differs" do` at line 194.
pub fn ruby_on_system_conditionals_spec_l194_d13_reports() bool {
	source := 'cask \'foo\' do\n  on_intel do\n    version "1.0.0"\n    sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"\n  end\n  on_arm do\n    version "1.0.0"\n    sha256 "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"\n  end\nend'
	expected := 'cask \'foo\' do\n  version "1.0.0"\n  sha256 arm: "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b", intel: "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"\nend'
	problems := on_system_core.audit_cask_on_system_conditionals(source)
	return problems.len == 1 && problems[0].message == on_system_core.on_system_identical_version_message && on_system_core.correct_cask_on_system_conditionals(source) == expected
}

// Ruby it `it "reports an offense when both `version` and `sha256` are identical in both arch blocks" do` at line 217.
pub fn ruby_on_system_conditionals_spec_l217_d14_reports() bool {
	sha := '67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94'
	source := 'cask \'foo\' do\n  on_intel do\n    version "1.0.0"\n    sha256 "${sha}"\n  end\n  on_arm do\n    version "1.0.0"\n    sha256 "${sha}"\n  end\nend'
	expected := 'cask \'foo\' do\n  version "1.0.0"\n  sha256 "${sha}"\nend'
	problems := on_system_core.audit_cask_on_system_conditionals(source)
	return problems.len == 1 && on_system_core.correct_cask_on_system_conditionals(source) == expected
}

// Ruby it `it "reports an offense but does not autocorrect when an `on_arch` block includes comments" do` at line 240.
pub fn ruby_on_system_conditionals_spec_l240_d15_reports() bool {
	source := 'cask \'foo\' do\n  on_intel do\n    version "1.0.0"\n    # comment\n    sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"\n  end\n  on_arm do\n    version "1.0.0"\n    sha256 "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"\n  end\nend'
	problems := on_system_core.audit_cask_on_system_conditionals(source)
	return problems.len == 1 && problems[0].replacement == '' && on_system_core.correct_cask_on_system_conditionals(source) == source
}

// Ruby it `it "reports an offense when `on_arch` blocks with identical versions are inside an `on_os` block" do` at line 261.
pub fn ruby_on_system_conditionals_spec_l261_d16_reports() bool {
	source := 'cask \'foo\' do\n  on_sonoma :or_newer do\n    on_intel do\n      version "1.0.0"\n      sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"\n    end\n    on_arm do\n      version "1.0.0"\n      sha256 "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"\n    end\n  end\nend'
	expected := 'cask \'foo\' do\n  on_sonoma :or_newer do\n    version "1.0.0"\n    sha256 arm: "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b", intel: "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"\n  end\nend'
	problems := on_system_core.audit_cask_on_system_conditionals(source)
	return problems.len == 1 && on_system_core.correct_cask_on_system_conditionals(source) == expected
}

// Ruby it `it "reports an offense when `on_arch` blocks with only `sha256` are inside an `on_os` block" do` at line 288.
pub fn ruby_on_system_conditionals_spec_l288_d17_reports() bool {
	source := 'cask \'foo\' do\n  on_sonoma :or_newer do\n    on_intel do\n      sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"\n    end\n    on_arm do\n      sha256 "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"\n    end\n  end\nend'
	expected := 'cask \'foo\' do\n  on_sonoma :or_newer do\n    sha256 arm: "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b", intel: "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"\n  end\nend'
	return on_system_core.audit_cask_on_system_conditionals(source).len == 1 && on_system_core.correct_cask_on_system_conditionals(source) == expected
}

// Ruby it `it "reports offenses for every eligible `on_arch` pair across sibling `on_os` blocks" do` at line 312.
pub fn ruby_on_system_conditionals_spec_l312_d18_reports() bool {
	source := 'cask \'foo\' do\n  on_sonoma :or_newer do\n    on_intel do\n      version "1.0.0"\n      sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"\n    end\n    on_arm do\n      version "1.0.0"\n      sha256 "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"\n    end\n  end\n\n  on_sequoia :or_newer do\n    on_intel do\n      version "2.0.0"\n      sha256 "d72f430f8f4e71cbce4d3648f364f95f8f422bcdd668a8d3260f39ee3f6f3cec"\n    end\n    on_arm do\n      version "2.0.0"\n      sha256 "7686f28e546238da94ce4dc89be623f7dc801f7e44e7011fdb7f3f471675f5ee"\n    end\n  end\nend'
	expected := 'cask \'foo\' do\n  on_sonoma :or_newer do\n    version "1.0.0"\n    sha256 arm: "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b", intel: "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"\n  end\n\n  on_sequoia :or_newer do\n    version "2.0.0"\n    sha256 arm: "7686f28e546238da94ce4dc89be623f7dc801f7e44e7011fdb7f3f471675f5ee", intel: "d72f430f8f4e71cbce4d3648f364f95f8f422bcdd668a8d3260f39ee3f6f3cec"\n  end\nend'
	problems := on_system_core.audit_cask_on_system_conditionals(source)
	return problems.len == 2 && problems.all(it.kind == 'identical_arch_versions') && on_system_core.correct_cask_on_system_conditionals(source) == expected
}

// Ruby it `it "still autocorrects a matching pair when a later `on_os` block has only one arch block" do` at line 356.
pub fn ruby_on_system_conditionals_spec_l356_d19_still() bool {
	source := 'cask \'foo\' do\n  on_sonoma :or_newer do\n    on_intel do\n      version "1.0.0"\n      sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"\n    end\n    on_arm do\n      version "1.0.0"\n      sha256 "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"\n    end\n  end\n\n  on_sequoia :or_newer do\n    on_arm do\n      version "3.0.0"\n      sha256 "5f42cb017dd07270409eaee7c3b4a164ffa7c0f21d85c65840c4f81aab21d457"\n    end\n  end\nend'
	expected := 'cask \'foo\' do\n  on_sonoma :or_newer do\n    version "1.0.0"\n    sha256 arm: "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b", intel: "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"\n  end\n\n  on_sequoia :or_newer do\n    on_arm do\n      version "3.0.0"\n      sha256 "5f42cb017dd07270409eaee7c3b4a164ffa7c0f21d85c65840c4f81aab21d457"\n    end\n  end\nend'
	return on_system_core.audit_cask_on_system_conditionals(source).len == 1 && on_system_core.correct_cask_on_system_conditionals(source) == expected
}

// Ruby it `it "reports an offense when `Hardware::CPU.arm?` is used" do` at line 399.
pub fn ruby_on_system_conditionals_spec_l399_d20_reports() bool {
	source := 'cask \'foo\' do\n  if Hardware::CPU.arm? && other_condition\n    sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"\n  else\n    sha256 "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"\n  end\nend'
	problems := on_system_core.audit_cask_on_system_conditionals(source)
	return problems.len == 1 && source[problems[0].begin_pos..problems[0].end_pos] == 'Hardware::CPU.arm?' && problems[0].message == 'Instead of `Hardware::CPU.arm?`, use `on_arm` and `on_intel` blocks.'
}

// Ruby it `it "reports an offense when `Hardware::CPU.intel?` is used" do` at line 412.
pub fn ruby_on_system_conditionals_spec_l412_d21_reports() bool {
	source := 'cask \'foo\' do\n  if Hardware::CPU.intel? && other_condition\n    sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"\n  else\n    sha256 "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"\n  end\nend'
	problems := on_system_core.audit_cask_on_system_conditionals(source)
	return problems.len == 1 && source[problems[0].begin_pos..problems[0].end_pos] == 'Hardware::CPU.intel?'
}

// Ruby it `it "reports an offense when `Hardware::CPU.arch` is used" do` at line 425.
pub fn ruby_on_system_conditionals_spec_l425_d22_reports() bool {
	source := 'cask \'foo\' do\n  version "1.2.3"\n  sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"\n\n  url "https://example.com/foo-#{version}-#{Hardware::CPU.arch}.zip"\nend'
	problems := on_system_core.audit_cask_on_system_conditionals(source)
	return problems.len == 1 && source[problems[0].begin_pos..problems[0].end_pos] == 'Hardware::CPU.arch'
}

// Ruby it `it "reports an offense when `MacOS.version ==` is used" do` at line 439.
pub fn ruby_on_system_conditionals_spec_l439_d23_reports() bool {
	source := 'cask \'foo\' do\n  if MacOS.version == :catalina\n    version "1.0.0"\n  else\n    version "2.0.0"\n  end\nend'
	problems := on_system_core.audit_cask_on_system_conditionals(source)
	return problems.len == 1 && problems[0].message == 'Instead of `if MacOS.version == :catalina`, use `on_catalina do`.' && source[problems[0].begin_pos..problems[0].end_pos].starts_with('if MacOS.version == :catalina')
}

// Ruby it `it "reports an offense when `MacOS.version <=` is used" do` at line 452.
pub fn ruby_on_system_conditionals_spec_l452_d24_reports() bool {
	source := 'cask \'foo\' do\n  if MacOS.version <= :catalina\n    version "1.0.0"\n  else\n    version "2.0.0"\n  end\nend'
	problems := on_system_core.audit_cask_on_system_conditionals(source)
	return problems.len == 1 && problems[0].message == 'Instead of `if MacOS.version <= :catalina`, use `on_catalina :or_older do`.'
}

// Ruby it `it "reports an offense when `MacOS.version >=` is used" do` at line 465.
pub fn ruby_on_system_conditionals_spec_l465_d25_reports() bool {
	source := 'cask \'foo\' do\n  if MacOS.version >= :catalina\n    version "1.0.0"\n  else\n    version "2.0.0"\n  end\nend'
	problems := on_system_core.audit_cask_on_system_conditionals(source)
	return problems.len == 1 && problems[0].message == 'Instead of `if MacOS.version >= :catalina`, use `on_catalina :or_newer do`.'
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/rubocop-cask"
// 5:
// 6: RSpec.describe RuboCop::Cop::Cask::OnSystemConditionals, :config do
// 7:   context "when auditing `postflight` stanzas" do
// 8:     it "accepts when there are no `on_*` blocks" do
// 9:       expect_no_offenses <<~CASK
// 10:         cask 'foo' do
// 11:           postflight do
// 12:             foobar
// 13:           end
// 14:         end
// 15:       CASK
// 16:     end
// 17:
// 18:     it "reports an offense it contains an `on_intel` block" do
// 19:       expect_offense <<~CASK
// 20:         cask 'foo' do
// 21:           postflight do
// 22:             on_intel do
// 23:             ^^^^^^^^ Instead of using `on_intel` in `postflight do`, use `if Hardware::CPU.intel?`.
// 24:               foobar
// 25:             end
// 26:           end
// 27:         end
// 28:       CASK
// 29:
// 30:       expect_correction <<~CASK
// 31:         cask 'foo' do
// 32:           postflight do
// 33:             if Hardware::CPU.intel?
// 34:               foobar
// 35:             end
// 36:           end
// 37:         end
// 38:       CASK
// 39:     end
// 40:
// 41:     it "reports an offense when it contains an `on_monterey` block" do
// 42:       expect_offense <<~CASK
// 43:         cask 'foo' do
// 44:           postflight do
// 45:             on_monterey do
// 46:             ^^^^^^^^^^^ Instead of using `on_monterey` in `postflight do`, use `if MacOS.version == :monterey`.
// 47:               foobar
// 48:             end
// 49:           end
// 50:         end
// 51:       CASK
// 52:
// 53:       expect_correction <<~CASK
// 54:         cask 'foo' do
// 55:           postflight do
// 56:             if MacOS.version == :monterey
// 57:               foobar
// 58:             end
// 59:           end
// 60:         end
// 61:       CASK
// 62:     end
// 63:
// 64:     it "reports an offense when it contains an `on_monterey :or_older` block" do
// 65:       expect_offense <<~CASK
// 66:         cask 'foo' do
// 67:           postflight do
// 68:             on_monterey :or_older do
// 69:             ^^^^^^^^^^^^^^^^^^^^^ Instead of using `on_monterey :or_older` in `postflight do`, use `if MacOS.version <= :monterey`.
// 70:               foobar
// 71:             end
// 72:           end
// 73:         end
// 74:       CASK
// 75:
// 76:       expect_correction <<~CASK
// 77:         cask 'foo' do
// 78:           postflight do
// 79:             if MacOS.version <= :monterey
// 80:               foobar
// 81:             end
// 82:           end
// 83:         end
// 84:       CASK
// 85:     end
// 86:   end
// 87:
// 88:   context "when auditing `sha256` stanzas inside `on_arch` blocks" do
// 89:     it "accepts when there are no `on_arch` blocks" do
// 90:       expect_no_offenses <<~CASK
// 91:         cask 'foo' do
// 92:           sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 93:         end
// 94:       CASK
// 95:     end
// 96:
// 97:     it "accepts when the `sha256` stanza is used with keyword arguments" do
// 98:       expect_no_offenses <<~CASK
// 99:         cask 'foo' do
// 100:           sha256 arm:   "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94",
// 101:                  intel: "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 102:         end
// 103:       CASK
// 104:     end
// 105:
// 106:     it "reports an offense when `sha256` has identical values for different architectures" do
// 107:       expect_offense <<~CASK
// 108:         cask 'foo' do
// 109:           sha256 arm:   "5f42cb017dd07270409eaee7c3b4a164ffa7c0f21d85c65840c4f81aab21d457",
// 110:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ sha256 values for different architectures should not be identical.
// 111:                  intel: "5f42cb017dd07270409eaee7c3b4a164ffa7c0f21d85c65840c4f81aab21d457"
// 112:         end
// 113:       CASK
// 114:     end
// 115:
// 116:     it "accepts when there is only one `on_arch` block" do
// 117:       expect_no_offenses <<~CASK
// 118:         cask 'foo' do
// 119:           on_intel do
// 120:             sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 121:           end
// 122:         end
// 123:       CASK
// 124:     end
// 125:
// 126:     it "reports an offense when `sha256` is specified in all `on_arch` blocks" do
// 127:       expect_offense <<~CASK
// 128:         cask 'foo' do
// 129:           on_intel do
// 130:             sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 131:           end
// 132:           on_arm do
// 133:           ^^^^^^^^^ Don't nest only the `sha256` stanzas in `on_intel` and `on_arm` blocks
// 134:             sha256 "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 135:           end
// 136:         end
// 137:       CASK
// 138:
// 139:       expect_correction <<~CASK
// 140:         cask 'foo' do
// 141:           sha256 arm: "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b", intel: "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 142:         end
// 143:       CASK
// 144:     end
// 145:
// 146:     it "reports an offense but does not autocorrect when an `on_arch` block includes comments" do
// 147:       expect_offense <<~CASK
// 148:         cask 'foo' do
// 149:           on_intel do
// 150:             # comment
// 151:             sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 152:           end
// 153:           on_arm do
// 154:           ^^^^^^^^^ Don't nest only the `sha256` stanzas in `on_intel` and `on_arm` blocks
// 155:             sha256 "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 156:           end
// 157:         end
// 158:       CASK
// 159:
// 160:       expect_no_corrections
// 161:     end
// 162:
// 163:     it "accepts when there is also a `version` stanza inside the `on_arch` blocks with different versions" do
// 164:       expect_no_offenses <<~CASK
// 165:         cask 'foo' do
// 166:           on_intel do
// 167:             version "1.0.0"
// 168:             sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 169:           end
// 170:           on_arm do
// 171:             version "2.0.0"
// 172:             sha256 "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 173:           end
// 174:         end
// 175:       CASK
// 176:     end
// 177:
// 178:     it "accepts when there is also a `version` stanza inside only a single `on_arch` block" do
// 179:       expect_no_offenses <<~CASK
// 180:         cask 'foo' do
// 181:           on_intel do
// 182:             version "2.0.0"
// 183:             sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 184:           end
// 185:           on_arm do
// 186:             sha256 "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 187:           end
// 188:         end
// 189:       CASK
// 190:     end
// 191:   end
// 192:
// 193:   context "when auditing identical `version` stanzas inside `on_arch` blocks" do
// 194:     it "reports an offense when `version` is identical in both arch blocks but `sha256` differs" do
// 195:       expect_offense <<~CASK
// 196:         cask 'foo' do
// 197:           on_intel do
// 198:             version "1.0.0"
// 199:             sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 200:           end
// 201:           on_arm do
// 202:           ^^^^^^^^^ Don't nest identical `version` stanzas in `on_intel` and `on_arm` blocks
// 203:             version "1.0.0"
// 204:             sha256 "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 205:           end
// 206:         end
// 207:       CASK
// 208:
// 209:       expect_correction <<~CASK
// 210:         cask 'foo' do
// 211:           version "1.0.0"
// 212:           sha256 arm: "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b", intel: "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 213:         end
// 214:       CASK
// 215:     end
// 216:
// 217:     it "reports an offense when both `version` and `sha256` are identical in both arch blocks" do
// 218:       expect_offense <<~CASK
// 219:         cask 'foo' do
// 220:           on_intel do
// 221:             version "1.0.0"
// 222:             sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 223:           end
// 224:           on_arm do
// 225:           ^^^^^^^^^ Don't nest identical `version` stanzas in `on_intel` and `on_arm` blocks
// 226:             version "1.0.0"
// 227:             sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 228:           end
// 229:         end
// 230:       CASK
// 231:
// 232:       expect_correction <<~CASK
// 233:         cask 'foo' do
// 234:           version "1.0.0"
// 235:           sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 236:         end
// 237:       CASK
// 238:     end
// 239:
// 240:     it "reports an offense but does not autocorrect when an `on_arch` block includes comments" do
// 241:       expect_offense <<~CASK
// 242:         cask 'foo' do
// 243:           on_intel do
// 244:             version "1.0.0"
// 245:             # comment
// 246:             sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 247:           end
// 248:           on_arm do
// 249:           ^^^^^^^^^ Don't nest identical `version` stanzas in `on_intel` and `on_arm` blocks
// 250:             version "1.0.0"
// 251:             sha256 "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 252:           end
// 253:         end
// 254:       CASK
// 255:
// 256:       expect_no_corrections
// 257:     end
// 258:   end
// 259:
// 260:   context "when `on_arch` blocks are nested inside `on_os` blocks" do
// 261:     it "reports an offense when `on_arch` blocks with identical versions are inside an `on_os` block" do
// 262:       expect_offense <<~CASK
// 263:         cask 'foo' do
// 264:           on_sonoma :or_newer do
// 265:             on_intel do
// 266:               version "1.0.0"
// 267:               sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 268:             end
// 269:             on_arm do
// 270:             ^^^^^^^^^ Don't nest identical `version` stanzas in `on_intel` and `on_arm` blocks
// 271:               version "1.0.0"
// 272:               sha256 "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 273:             end
// 274:           end
// 275:         end
// 276:       CASK
// 277:
// 278:       expect_correction <<~CASK
// 279:         cask 'foo' do
// 280:           on_sonoma :or_newer do
// 281:             version "1.0.0"
// 282:             sha256 arm: "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b", intel: "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 283:           end
// 284:         end
// 285:       CASK
// 286:     end
// 287:
// 288:     it "reports an offense when `on_arch` blocks with only `sha256` are inside an `on_os` block" do
// 289:       expect_offense <<~CASK
// 290:         cask 'foo' do
// 291:           on_sonoma :or_newer do
// 292:             on_intel do
// 293:               sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 294:             end
// 295:             on_arm do
// 296:             ^^^^^^^^^ Don't nest only the `sha256` stanzas in `on_intel` and `on_arm` blocks
// 297:               sha256 "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 298:             end
// 299:           end
// 300:         end
// 301:       CASK
// 302:
// 303:       expect_correction <<~CASK
// 304:         cask 'foo' do
// 305:           on_sonoma :or_newer do
// 306:             sha256 arm: "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b", intel: "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 307:           end
// 308:         end
// 309:       CASK
// 310:     end
// 311:
// 312:     it "reports offenses for every eligible `on_arch` pair across sibling `on_os` blocks" do
// 313:       expect_offense <<~CASK
// 314:         cask 'foo' do
// 315:           on_sonoma :or_newer do
// 316:             on_intel do
// 317:               version "1.0.0"
// 318:               sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 319:             end
// 320:             on_arm do
// 321:             ^^^^^^^^^ Don't nest identical `version` stanzas in `on_intel` and `on_arm` blocks
// 322:               version "1.0.0"
// 323:               sha256 "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 324:             end
// 325:           end
// 326:
// 327:           on_sequoia :or_newer do
// 328:             on_intel do
// 329:               version "2.0.0"
// 330:               sha256 "d72f430f8f4e71cbce4d3648f364f95f8f422bcdd668a8d3260f39ee3f6f3cec"
// 331:             end
// 332:             on_arm do
// 333:             ^^^^^^^^^ Don't nest identical `version` stanzas in `on_intel` and `on_arm` blocks
// 334:               version "2.0.0"
// 335:               sha256 "7686f28e546238da94ce4dc89be623f7dc801f7e44e7011fdb7f3f471675f5ee"
// 336:             end
// 337:           end
// 338:         end
// 339:       CASK
// 340:
// 341:       expect_correction <<~CASK
// 342:         cask 'foo' do
// 343:           on_sonoma :or_newer do
// 344:             version "1.0.0"
// 345:             sha256 arm: "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b", intel: "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 346:           end
// 347:
// 348:           on_sequoia :or_newer do
// 349:             version "2.0.0"
// 350:             sha256 arm: "7686f28e546238da94ce4dc89be623f7dc801f7e44e7011fdb7f3f471675f5ee", intel: "d72f430f8f4e71cbce4d3648f364f95f8f422bcdd668a8d3260f39ee3f6f3cec"
// 351:           end
// 352:         end
// 353:       CASK
// 354:     end
// 355:
// 356:     it "still autocorrects a matching pair when a later `on_os` block has only one arch block" do
// 357:       expect_offense <<~CASK
// 358:         cask 'foo' do
// 359:           on_sonoma :or_newer do
// 360:             on_intel do
// 361:               version "1.0.0"
// 362:               sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 363:             end
// 364:             on_arm do
// 365:             ^^^^^^^^^ Don't nest identical `version` stanzas in `on_intel` and `on_arm` blocks
// 366:               version "1.0.0"
// 367:               sha256 "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 368:             end
// 369:           end
// 370:
// 371:           on_sequoia :or_newer do
// 372:             on_arm do
// 373:               version "3.0.0"
// 374:               sha256 "5f42cb017dd07270409eaee7c3b4a164ffa7c0f21d85c65840c4f81aab21d457"
// 375:             end
// 376:           end
// 377:         end
// 378:       CASK
// 379:
// 380:       expect_correction <<~CASK
// 381:         cask 'foo' do
// 382:           on_sonoma :or_newer do
// 383:             version "1.0.0"
// 384:             sha256 arm: "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b", intel: "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 385:           end
// 386:
// 387:           on_sequoia :or_newer do
// 388:             on_arm do
// 389:               version "3.0.0"
// 390:               sha256 "5f42cb017dd07270409eaee7c3b4a164ffa7c0f21d85c65840c4f81aab21d457"
// 391:             end
// 392:           end
// 393:         end
// 394:       CASK
// 395:     end
// 396:   end
// 397:
// 398:   context "when auditing loose `Hardware::CPU` method calls" do
// 399:     it "reports an offense when `Hardware::CPU.arm?` is used" do
// 400:       expect_offense <<~CASK
// 401:         cask 'foo' do
// 402:           if Hardware::CPU.arm? && other_condition
// 403:              ^^^^^^^^^^^^^^^^^^ Instead of `Hardware::CPU.arm?`, use `on_arm` and `on_intel` blocks.
// 404:             sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 405:           else
// 406:             sha256 "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 407:           end
// 408:         end
// 409:       CASK
// 410:     end
// 411:
// 412:     it "reports an offense when `Hardware::CPU.intel?` is used" do
// 413:       expect_offense <<~CASK
// 414:         cask 'foo' do
// 415:           if Hardware::CPU.intel? && other_condition
// 416:              ^^^^^^^^^^^^^^^^^^^^ Instead of `Hardware::CPU.intel?`, use `on_arm` and `on_intel` blocks.
// 417:             sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 418:           else
// 419:             sha256 "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 420:           end
// 421:         end
// 422:       CASK
// 423:     end
// 424:
// 425:     it "reports an offense when `Hardware::CPU.arch` is used" do
// 426:       expect_offense <<~'CASK'
// 427:         cask 'foo' do
// 428:           version "1.2.3"
// 429:           sha256 "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94"
// 430:
// 431:           url "https://example.com/foo-#{version}-#{Hardware::CPU.arch}.zip"
// 432:                                                     ^^^^^^^^^^^^^^^^^^ Instead of `Hardware::CPU.arch`, use `on_arm` and `on_intel` blocks.
// 433:         end
// 434:       CASK
// 435:     end
// 436:   end
// 437:
// 438:   context "when auditing loose `MacOS.version` method calls" do
// 439:     it "reports an offense when `MacOS.version ==` is used" do
// 440:       expect_offense <<~CASK
// 441:         cask 'foo' do
// 442:           if MacOS.version == :catalina
// 443:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Instead of `if MacOS.version == :catalina`, use `on_catalina do`.
// 444:             version "1.0.0"
// 445:           else
// 446:             version "2.0.0"
// 447:           end
// 448:         end
// 449:       CASK
// 450:     end
// 451:
// 452:     it "reports an offense when `MacOS.version <=` is used" do
// 453:       expect_offense <<~CASK
// 454:         cask 'foo' do
// 455:           if MacOS.version <= :catalina
// 456:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Instead of `if MacOS.version <= :catalina`, use `on_catalina :or_older do`.
// 457:             version "1.0.0"
// 458:           else
// 459:             version "2.0.0"
// 460:           end
// 461:         end
// 462:       CASK
// 463:     end
// 464:
// 465:     it "reports an offense when `MacOS.version >=` is used" do
// 466:       expect_offense <<~CASK
// 467:         cask 'foo' do
// 468:           if MacOS.version >= :catalina
// 469:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Instead of `if MacOS.version >= :catalina`, use `on_catalina :or_newer do`.
// 470:             version "1.0.0"
// 471:           else
// 472:             version "2.0.0"
// 473:           end
// 474:         end
// 475:       CASK
// 476:     end
// 477:   end
// 478: end
