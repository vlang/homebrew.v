module bundle

import ruby
import homebrew.bundle as bundle_trust

// Translated from Homebrew/brew `test/bundle/trust_spec.rb`.
// The original source is retained below until every stub has a typed V body.
const trust_spec_custom_remote = 'https://gitlab.com/other/repo'

pub fn trust_spec_brew_entry(full_name string) bundle_trust.BrewfileEntry {
	return bundle_trust.BrewfileEntry{
		entry_type: .brew
		name: full_name
		options: bundle_trust.BrewfileTrustOptions{
			trusted: true
		}
	}
}

pub fn trust_spec_cask_entry(full_name string) bundle_trust.BrewfileEntry {
	return bundle_trust.BrewfileEntry{
		entry_type: .cask
		name: full_name
		options: bundle_trust.BrewfileTrustOptions{
			trusted: true
		}
	}
}

pub fn trust_spec_tap_entry(name string, clone_target string, trusted bool,
	trusted_items map[string][]string) bundle_trust.BrewfileEntry {
	return bundle_trust.BrewfileEntry{
		entry_type: .tap
		name: name
		options: bundle_trust.BrewfileTrustOptions{
			trusted: trusted
			trusted_items: trusted_items.clone()
			clone_target: clone_target
		}
	}
}

fn trust_spec_targets(entries []bundle_trust.BrewfileEntry,
	installed map[string]string) ![]bundle_trust.TrustTarget {
	return bundle_trust.bundle_trust_entries(entries, bundle_trust.BundleTrustContext{
		installed_tap_remotes: installed
	})
}

fn trust_spec_target(target_type bundle_trust.TrustTargetType,
	name string) bundle_trust.TrustTarget {
	return bundle_trust.TrustTarget{
		target_type: target_type
		name: name
	}
}

fn trust_spec_argument(args []ruby.Value, index int, fallback string) string {
	if index >= args.len || args[index].type_name == 'NilClass' {
		return fallback
	}
	return args[index].as_string()
}

fn trust_spec_boundary_options(args []ruby.Value) (bool, map[string][]string) {
	if args.len < 3 {
		return false, map[string][]string{}
	}
	value := args[2]
	if value.type_name == 'Bool' {
		return value.as_bool() or { false }, map[string][]string{}
	}
	if value.type_name != 'Hash' {
		return false, map[string][]string{}
	}
	mut items := map[string][]string{}
	for key, item in value.as_map() or { map[string]ruby.Value{} } {
		items[key] = if item.type_name == 'Array' {
			(item.as_array() or { [] }).map(it.as_string())
		} else {
			[item.as_string()]
		}
	}
	return false, items
}

// Ruby method `brew_entry(full_name)` at line 12.
pub fn ruby_trust_spec_l12_d1_brew_entry(args ...ruby.Value) ruby.Value {
	return bundle_trust.brewfile_entry_value(trust_spec_brew_entry(trust_spec_argument(args, 0, 'defaultremote/foo/bar')))
}

// Ruby method `cask_entry(full_name)` at line 16.
pub fn ruby_trust_spec_l16_d2_cask_entry(args ...ruby.Value) ruby.Value {
	return bundle_trust.brewfile_entry_value(trust_spec_cask_entry(trust_spec_argument(args, 0, 'defaultremote/foo/baz')))
}

// Ruby method `tap_entry(name, clone_target = nil, **options)` at line 20.
pub fn ruby_trust_spec_l20_d3_tap_entry(args ...ruby.Value) ruby.Value {
	name := trust_spec_argument(args, 0, 'thirdparty/custom')
	clone_target := trust_spec_argument(args, 1, '')
	trusted, trusted_items := trust_spec_boundary_options(args)
	return bundle_trust.brewfile_entry_value(trust_spec_tap_entry(name, clone_target, trusted, trusted_items))
}

// Ruby method `install_tap(name, remote)` at line 25.
pub fn ruby_trust_spec_l25_d4_install_tap(args ...ruby.Value) ruby.Value {
	name := trust_spec_argument(args, 0, 'thirdparty/custom')
	remote := trust_spec_argument(args, 1, trust_spec_custom_remote)
	return ruby.structured_value('InstalledTap', name, {
		'name':   bundle_trust.sanitize_bundle_tap_name(name)
		'remote': remote
	})
}

// Ruby it `it "keeps a default-remote tap formula as its tap-qualified name" do` at line 33.
pub fn ruby_trust_spec_l33_d5_keeps(args ...ruby.Value) ruby.Value {
	targets := trust_spec_targets([trust_spec_brew_entry('defaultremote/foo/bar')], {}) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(targets == [
		trust_spec_target(.formula, 'defaultremote/foo/bar'),
	])
}

// Ruby it `it "ignores an unqualified brew name that maps to no tap" do` at line 38.
pub fn ruby_trust_spec_l38_d6_ignores(args ...ruby.Value) ruby.Value {
	targets := trust_spec_targets([trust_spec_brew_entry('wget')], {}) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(targets.len == 0)
}

// Ruby it `it "normalises a brew entry to the remote declared by its tap, before the tap is cloned" do` at line 42.
pub fn ruby_trust_spec_l42_d7_normalises(args ...ruby.Value) ruby.Value {
	targets := trust_spec_targets([
		trust_spec_tap_entry('thirdparty/custom', trust_spec_custom_remote, false, {}),
		trust_spec_brew_entry('thirdparty/custom/bar'),
	], {}) or { return ruby.bool_value(false) }
	return ruby.bool_value(targets == [
		trust_spec_target(.formula, '${trust_spec_custom_remote}/bar'),
	])
}

// Ruby it `it "normalises a cask entry to the remote declared by its tap" do` at line 51.
pub fn ruby_trust_spec_l51_d8_normalises(args ...ruby.Value) ruby.Value {
	targets := trust_spec_targets([
		trust_spec_tap_entry('thirdparty/custom', trust_spec_custom_remote, false, {}),
		trust_spec_cask_entry('thirdparty/custom/baz'),
	], {}) or { return ruby.bool_value(false) }
	return ruby.bool_value(targets == [
		trust_spec_target(.cask, '${trust_spec_custom_remote}/baz'),
	])
}

// Ruby it `it "normalises a cask entry written with the homebrew- tap prefix to its declared remote" do` at line 60.
pub fn ruby_trust_spec_l60_d9_normalises(args ...ruby.Value) ruby.Value {
	targets := trust_spec_targets([
		trust_spec_tap_entry('thirdparty/homebrew-custom', trust_spec_custom_remote, false, {}),
		trust_spec_cask_entry('thirdparty/homebrew-custom/baz'),
	], {}) or { return ruby.bool_value(false) }
	return ruby.bool_value(targets == [
		trust_spec_target(.cask, '${trust_spec_custom_remote}/baz'),
	])
}

// Ruby it `it "resolves a brew entry independently of the Brewfile order of its tap entry" do` at line 70.
pub fn ruby_trust_spec_l70_d10_resolves(args ...ruby.Value) ruby.Value {
	brew := trust_spec_brew_entry('thirdparty/custom/bar')
	tap := trust_spec_tap_entry('thirdparty/custom', trust_spec_custom_remote, false, {})
	first := trust_spec_targets([brew, tap], {}) or { return ruby.bool_value(false) }
	second := trust_spec_targets([tap, brew], {}) or { return ruby.bool_value(false) }
	return ruby.bool_value(first == second)
}

// Ruby it `it "collapses a tap trusted-hash item and a brew entry for the same custom-remote item" do` at line 77.
pub fn ruby_trust_spec_l77_d11_collapses(args ...ruby.Value) ruby.Value {
	targets := trust_spec_targets([
		trust_spec_tap_entry('thirdparty/custom', trust_spec_custom_remote, false, {
			'formula': ['bar']
		}),
		trust_spec_brew_entry('thirdparty/custom/bar'),
	], {}) or { return ruby.bool_value(false) }
	return ruby.bool_value(targets == [
		trust_spec_target(.formula, '${trust_spec_custom_remote}/bar'),
	])
}

// Ruby it `it "keeps whole-tap trust keyed to a declared custom remote, not the aliased default it resembles" do` at line 86.
pub fn ruby_trust_spec_l86_d12_keeps(args ...ruby.Value) ruby.Value {
	remote := 'https://github.com/other/homebrew-project'
	targets := trust_spec_targets([
		trust_spec_tap_entry('thirdparty/custom', remote, true, {}),
	], {}) or { return ruby.bool_value(false) }
	return ruby.bool_value(targets == [trust_spec_target(.tap, remote)])
}

// Ruby it `it "treats default-remote clone targets in any URL form as the plain tap name" do` at line 94.
pub fn ruby_trust_spec_l94_d13_treats(args ...ruby.Value) ruby.Value {
	for remote in ['https://github.com/defaultremote/homebrew-foo',
		'git@github.com:defaultremote/homebrew-foo.git',
		'https://github.com/defaultremote/homebrew-foo.git',
		'https://github.com/defaultremote/homebrew-foo/'] {
		targets := trust_spec_targets([
			trust_spec_tap_entry('defaultremote/foo', remote, false, {}),
			trust_spec_brew_entry('defaultremote/foo/bar'),
		], {}) or { return ruby.bool_value(false) }
		if targets != [trust_spec_target(.formula, 'defaultremote/foo/bar')] {
			return ruby.bool_value(false)
		}
	}
	return ruby.bool_value(true)
}

// Ruby it `it "produces the same entry whether or not the declared custom-remote tap is installed" do` at line 110.
pub fn ruby_trust_spec_l110_d14_produces(args ...ruby.Value) ruby.Value {
	entries := [
		trust_spec_tap_entry('thirdparty/custom', trust_spec_custom_remote, false, {}),
		trust_spec_brew_entry('thirdparty/custom/bar'),
	]
	untapped := trust_spec_targets(entries, {}) or { return ruby.bool_value(false) }
	installed := trust_spec_targets(entries, {
		'thirdparty/custom': trust_spec_custom_remote
	}) or { return ruby.bool_value(false) }
	return ruby.bool_value(untapped == [
		trust_spec_target(.formula, '${trust_spec_custom_remote}/bar'),
	] && installed == untapped)
}

// Ruby it `it "keys a custom-remote brew entry identically whether its remote is declared or installed" do` at line 128.
pub fn ruby_trust_spec_l128_d15_keys(args ...ruby.Value) ruby.Value {
	remote := 'https://gitlab.com/other/repo.git'
	declared := trust_spec_targets([
		trust_spec_tap_entry('thirdparty/custom', remote, false, {}),
		trust_spec_brew_entry('thirdparty/custom/bar'),
	], {}) or { return ruby.bool_value(false) }
	installed := trust_spec_targets([trust_spec_brew_entry('thirdparty/custom/bar')], {
		'thirdparty/custom': remote
	}) or { return ruby.bool_value(false) }
	return ruby.bool_value(declared == [
		trust_spec_target(.formula, '${remote}/bar'),
	] && installed == declared)
}

// Ruby it `it "uses the installed remote for an installed custom tap with no declared clone target" do` at line 144.
pub fn ruby_trust_spec_l144_d16_uses(args ...ruby.Value) ruby.Value {
	installed := {
		'thirdparty/custom': trust_spec_custom_remote
	}
	tap_target := trust_spec_targets([
		trust_spec_tap_entry('thirdparty/custom', '', true, {}),
	], installed) or { return ruby.bool_value(false) }
	item_target := trust_spec_targets([
		trust_spec_tap_entry('thirdparty/custom', '', false, {
			'formula': ['bar']
		}),
	], installed) or { return ruby.bool_value(false) }
	return ruby.bool_value(tap_target == [
		trust_spec_target(.tap, trust_spec_custom_remote),
	] && item_target == [
		trust_spec_target(.formula, '${trust_spec_custom_remote}/bar'),
	])
}

// Ruby it `it "raises on unsupported trusted keys" do` at line 155.
pub fn ruby_trust_spec_l155_d17_raises(args ...ruby.Value) ruby.Value {
	entry := trust_spec_tap_entry('thirdparty/custom', '', false, {
		'bogus': ['bar']
	})
	if _ := trust_spec_targets([entry], {}) {
		return ruby.bool_value(false)
	} else {
		return ruby.bool_value(err.code() == 64 && err.msg().contains('Unsupported trusted keys: bogus'))
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle"
// 5: require "bundle/trust"
// 6: require "bundle/dsl"
// 7: require "tap"
// 8: require "trust"
// 9:
// 10: RSpec.describe Homebrew::Bundle::Trust do
// 11:   describe ".entries" do
// 12:     def brew_entry(full_name)
// 13:       Homebrew::Bundle::Dsl::Entry.new(:brew, full_name, { trusted: true })
// 14:     end
// 15:
// 16:     def cask_entry(full_name)
// 17:       Homebrew::Bundle::Dsl::Entry.new(:cask, full_name, { trusted: true })
// 18:     end
// 19:
// 20:     def tap_entry(name, clone_target = nil, **options)
// 21:       options[:clone_target] = clone_target if clone_target
// 22:       Homebrew::Bundle::Dsl::Entry.new(:tap, name, options)
// 23:     end
// 24:
// 25:     def install_tap(name, remote)
// 26:       tap = Tap.fetch(name)
// 27:       tap.path.mkpath
// 28:       system "git", "-C", tap.path.to_s, "init"
// 29:       system "git", "-C", tap.path.to_s, "remote", "add", "origin", remote
// 30:       tap
// 31:     end
// 32:
// 33:     it "keeps a default-remote tap formula as its tap-qualified name" do
// 34:       expect(described_class.entries([brew_entry("defaultremote/foo/bar")]))
// 35:         .to eq([[:formula, "defaultremote/foo/bar"]])
// 36:     end
// 37:
// 38:     it "ignores an unqualified brew name that maps to no tap" do
// 39:       expect(described_class.entries([brew_entry("wget")])).to be_empty
// 40:     end
// 41:
// 42:     it "normalises a brew entry to the remote declared by its tap, before the tap is cloned" do
// 43:       result = described_class.entries([
// 44:         tap_entry("thirdparty/custom", "https://gitlab.com/other/repo"),
// 45:         brew_entry("thirdparty/custom/bar"),
// 46:       ])
// 47:
// 48:       expect(result).to eq([[:formula, "https://gitlab.com/other/repo/bar"]])
// 49:     end
// 50:
// 51:     it "normalises a cask entry to the remote declared by its tap" do
// 52:       result = described_class.entries([
// 53:         tap_entry("thirdparty/custom", "https://gitlab.com/other/repo"),
// 54:         cask_entry("thirdparty/custom/baz"),
// 55:       ])
// 56:
// 57:       expect(result).to eq([[:cask, "https://gitlab.com/other/repo/baz"]])
// 58:     end
// 59:
// 60:     it "normalises a cask entry written with the homebrew- tap prefix to its declared remote" do
// 61:       brewfile = <<~BREWFILE
// 62:         tap "thirdparty/homebrew-custom", "https://gitlab.com/other/repo"
// 63:         cask "thirdparty/homebrew-custom/baz", trusted: true
// 64:       BREWFILE
// 65:       entries = Homebrew::Bundle::Dsl.new(StringIO.new(brewfile)).entries
// 66:
// 67:       expect(described_class.entries(entries)).to eq([[:cask, "https://gitlab.com/other/repo/baz"]])
// 68:     end
// 69:
// 70:     it "resolves a brew entry independently of the Brewfile order of its tap entry" do
// 71:       brew = brew_entry("thirdparty/custom/bar")
// 72:       tap = tap_entry("thirdparty/custom", "https://gitlab.com/other/repo")
// 73:
// 74:       expect(described_class.entries([brew, tap])).to eq(described_class.entries([tap, brew]))
// 75:     end
// 76:
// 77:     it "collapses a tap trusted-hash item and a brew entry for the same custom-remote item" do
// 78:       result = described_class.entries([
// 79:         tap_entry("thirdparty/custom", "https://gitlab.com/other/repo", trusted: { formula: "bar" }),
// 80:         brew_entry("thirdparty/custom/bar"),
// 81:       ])
// 82:
// 83:       expect(result).to eq([[:formula, "https://gitlab.com/other/repo/bar"]])
// 84:     end
// 85:
// 86:     it "keeps whole-tap trust keyed to a declared custom remote, not the aliased default it resembles" do
// 87:       result = described_class.entries([
// 88:         tap_entry("thirdparty/custom", "https://github.com/other/homebrew-project", trusted: true),
// 89:       ])
// 90:
// 91:       expect(result).to eq([[:tap, "https://github.com/other/homebrew-project"]])
// 92:     end
// 93:
// 94:     it "treats default-remote clone targets in any URL form as the plain tap name" do
// 95:       [
// 96:         "https://github.com/defaultremote/homebrew-foo",
// 97:         "git@github.com:defaultremote/homebrew-foo.git",
// 98:         "https://github.com/defaultremote/homebrew-foo.git",
// 99:         "https://github.com/defaultremote/homebrew-foo/",
// 100:       ].each do |remote|
// 101:         result = described_class.entries([
// 102:           tap_entry("defaultremote/foo", remote),
// 103:           brew_entry("defaultremote/foo/bar"),
// 104:         ])
// 105:
// 106:         expect(result).to eq([[:formula, "defaultremote/foo/bar"]])
// 107:       end
// 108:     end
// 109:
// 110:     it "produces the same entry whether or not the declared custom-remote tap is installed" do
// 111:       entries = [
// 112:         tap_entry("thirdparty/custom", "https://gitlab.com/other/repo"),
// 113:         brew_entry("thirdparty/custom/bar"),
// 114:       ]
// 115:
// 116:       untapped = described_class.entries(entries)
// 117:       install_tap("thirdparty/custom", "https://gitlab.com/other/repo")
// 118:       installed = described_class.entries(entries)
// 119:
// 120:       expect(untapped).to eq([[:formula, "https://gitlab.com/other/repo/bar"]])
// 121:       expect(installed).to eq(untapped)
// 122:     ensure
// 123:       FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 124:     end
// 125:
// 126:     # Keyed verbatim (here including `.git`) so bundle, installed-name `brew trust`, and the items.sh
// 127:     # shell filter all match the same raw origin; normalising only the declared remote would diverge.
// 128:     it "keys a custom-remote brew entry identically whether its remote is declared or installed" do
// 129:       remote = "https://gitlab.com/other/repo.git"
// 130:
// 131:       declared = described_class.entries([
// 132:         tap_entry("thirdparty/custom", remote),
// 133:         brew_entry("thirdparty/custom/bar"),
// 134:       ])
// 135:       install_tap("thirdparty/custom", remote)
// 136:       installed = described_class.entries([brew_entry("thirdparty/custom/bar")])
// 137:
// 138:       expect(declared).to eq([[:formula, "https://gitlab.com/other/repo.git/bar"]])
// 139:       expect(installed).to eq(declared)
// 140:     ensure
// 141:       FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 142:     end
// 143:
// 144:     it "uses the installed remote for an installed custom tap with no declared clone target" do
// 145:       install_tap("thirdparty/custom", "https://gitlab.com/other/repo")
// 146:
// 147:       expect(described_class.entries([tap_entry("thirdparty/custom", trusted: true)]))
// 148:         .to eq([[:tap, "https://gitlab.com/other/repo"]])
// 149:       expect(described_class.entries([tap_entry("thirdparty/custom", trusted: { formula: "bar" })]))
// 150:         .to eq([[:formula, "https://gitlab.com/other/repo/bar"]])
// 151:     ensure
// 152:       FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 153:     end
// 154:
// 155:     it "raises on unsupported trusted keys" do
// 156:       expect do
// 157:         described_class.entries([tap_entry("thirdparty/custom", trusted: { bogus: "bar" })])
// 158:       end.to raise_error(UsageError, /Unsupported trusted keys/)
// 159:     end
// 160:   end
// 161: end
