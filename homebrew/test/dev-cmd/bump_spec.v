module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `test/dev-cmd/bump_spec.rb`.
// The original source is retained below until every stub has a typed V body.

const bump_spec_now = i64(2_000_000_000)

fn bump_spec_versions_value(versions BumpVersions) brew_runtime.Value {
	return brew_runtime.map_value({
		'general': brew_runtime.string_value(versions.general)
		'arm':     brew_runtime.string_value(versions.arm)
		'intel':   brew_runtime.string_value(versions.intel)
	})
}

fn bump_spec_basic_formula() BumpPackage {
	return BumpPackage{
		kind: .formula
		name: 'basic_formula'
		full_name: 'homebrew/core/basic_formula'
		version: '1.2.3'
		current_versions: {
			'general': '1.2.3'
		}
		latest_versions: {
			'general': '1.2.3'
		}
		allow_bump: true
		livecheck_defined: true
	}
}

fn bump_spec_basic_cask() BumpPackage {
	return BumpPackage{
		kind: .cask
		name: 'basic-cask'
		full_name: 'homebrew/cask/basic-cask'
		version: '1.2.3'
		current_versions: {
			'general': '1.2.3'
		}
		latest_versions: {
			'general': '1.2.3'
		}
		allow_bump: true
		livecheck_defined: true
	}
}

fn bump_spec_arch_cask(name string, arches []string) BumpPackage {
	return BumpPackage{
		kind: .cask
		name: name
		full_name: 'homebrew/cask/${name}'
		version: '1.2.3'
		current_versions: {
			'general': '1.2.3'
		}
		latest_versions: {
			'general': '1.2.4'
		}
		allow_bump: true
		on_system_blocks: true
		supported_archs: arches
		livecheck_defined: true
	}
}

fn bump_spec_message_strings() []string {
	return ['error: message', 'skipped', 'skipped - deprecated', 'unable to get versions',
		'unable to get throttled versions']
}

// Ruby subject `subject(:bump) { described_class.new(["test"]) }` at line 9.
pub fn ruby_bump_spec_l9_d1_bump(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.map_value({
		'named': brew_runtime.string_array_value(['test'])
	})
}

// Ruby let `let(:f_basic) do` at line 11.
pub fn ruby_bump_spec_l11_d2_f_basic(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return bump_package_value(bump_spec_basic_formula())
}

// Ruby let `let(:c_basic) do` at line 18.
pub fn ruby_bump_spec_l18_d3_c_basic(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return bump_package_value(bump_spec_basic_cask())
}

// Ruby let `let(:c_latest) do` at line 28.
pub fn ruby_bump_spec_l28_d4_c_latest(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return bump_package_value(BumpPackage{
		kind: .cask
		name: 'latest-cask'
		full_name: 'homebrew/cask/latest-cask'
		version: 'latest'
		latest_cask: true
	})
}

// Ruby it `it "returns no data and prints a message for HEAD-only formulae" do` at line 45.
pub fn ruby_bump_spec_l45_d5_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	skip, message := skip_ineligible_bump(BumpPackage{
		kind: .formula
		name: 'headonly'
		head_only: true
	})
	return brew_runtime.bool_value(skip && message.contains('HEAD-only'))
}

// Ruby it `it "gives an error for `--tap` with official taps" do` at line 60.
pub fn ruby_bump_spec_l60_d6_gives(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := run_bump(BumpRunRequest{
		options: BumpOptions{ tap: 'homebrew/core' }
		taps: [BumpTap{ name: 'homebrew/core', official: true }]
	}, bump_spec_now)
	return brew_runtime.structured_value('UsageError', result.error, {
		'message': result.error
	})
}

// Ruby it `it "prints a legible message for casks using `version :latest`" do` at line 68.
pub fn ruby_bump_spec_l68_d7_prints(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	skip, message := skip_ineligible_bump(BumpPackage{
		kind: .cask
		latest_cask: true
	})
	return brew_runtime.bool_value(skip
		&& message == 'Cask uses `version :latest` so `brew bump` cannot check it.')
}

// Ruby it `it "returns a hash with `:multiple_versions` and `:newer_than_upstream` values" do` at line 76.
pub fn ruby_bump_spec_l76_d8_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	general := BumpVersions{ general: '1.2.3' }
	split := BumpVersions{ arm: '1.2.3', intel: '1.2.2' }
	higher := BumpVersions{ arm: '1.2.4', intel: '1.2.2' }
	skipped := BumpVersions{ general: 'skipped' }
	mixed := BumpVersions{ arm: '1.2.3', intel: 'skipped' }
	same_general := compare_bump_versions(general, general)
	same_split := compare_bump_versions(split, split)
	merge := compare_bump_versions(split, general)
	divide := compare_bump_versions(general, split)
	divide_higher := compare_bump_versions(general, higher)
	divide_mixed := compare_bump_versions(general, mixed)
	message := compare_bump_versions(general, skipped)
	return brew_runtime.bool_value(!same_general.multiple_current && !same_general.multiple_new
		&& !(same_general.newer_than_upstream['general'] or { false })
		&& same_split.multiple_current && same_split.multiple_new
		&& !(same_split.newer_than_upstream['arm'] or { false })
		&& merge.multiple_current && !merge.multiple_new
		&& !divide.multiple_current && divide.multiple_new
		&& !(divide_higher.newer_than_upstream['general'] or { false })
		&& !(divide_mixed.newer_than_upstream['general'] or { false })
		&& !(message.newer_than_upstream['general'] or { false }))
}

// Ruby subject `subject(:bump) { described_class.new(["--open-pr", "test"]) }` at line 157.
pub fn ruby_bump_spec_l157_d9_bump(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.map_value({
		'open_pr': brew_runtime.bool_value(true)
		'named':   brew_runtime.string_array_value(['test'])
	})
}

// Ruby it `it "passes arch-specific version arguments when a cask moves from one version to arch-specific versions" do` at line 164.
pub fn ruby_bump_spec_l164_d10_passes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	current := BumpVersions{ general: '1.2.3' }
	proposed := BumpVersions{ arm: '1.2.5', intel: '1.2.4' }
	comparison := compare_bump_versions(current, proposed)
	return brew_runtime.bool_value(version_args_for_bump(current, proposed, comparison, 'basic-cask') == [
		'--version-arm=1.2.5',
		'--version-intel=1.2.4',
	])
}

// Ruby it `it "passes arch-specific version arguments when an arch-specific cask moves to one version" do` at line 195.
pub fn ruby_bump_spec_l195_d11_passes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	current := BumpVersions{ arm: '1.2.3', intel: '1.2.2' }
	proposed := BumpVersions{ general: '1.2.4' }
	comparison := compare_bump_versions(current, proposed)
	return brew_runtime.bool_value(version_args_for_bump(current, proposed, comparison, 'basic-cask') == [
		'--version-arm=1.2.4',
		'--version-intel=1.2.4',
	])
}

// Ruby it `it "notes when a newer upstream version was skipped due to release cooldown" do` at line 226.
pub fn ruby_bump_spec_l226_d12_notes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	mut package := bump_spec_basic_formula()
	package = BumpPackage{
		...package
		latest_versions: {
			'general': '1.2.4'
		}
		livecheck_strategy: 'RubyGems'
		releases: [
			BumpRelease{ version: '1.2.4', released_at: bump_spec_now - 3600 },
			BumpRelease{ version: '1.2.3', released_at: bump_spec_now - 8 * 86_400 },
		]
	}
	display := retrieve_display_and_open_pr(package, 'basic_formula', [], false, BumpOptions{}, bump_spec_now)
	return brew_runtime.bool_value(display.lines.any(it.contains('release cooldown')))
}

// Ruby let `let(:c_arm_only) do` at line 257.
pub fn ruby_bump_spec_l257_d13_c_arm_only(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return bump_package_value(bump_spec_arch_cask('arm-only-cask', ['arm']))
}

// Ruby let `let(:c_intel_only) do` at line 274.
pub fn ruby_bump_spec_l274_d14_c_intel_only(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return bump_package_value(bump_spec_arch_cask('intel-only-cask', ['intel']))
}

// Ruby let `let(:c_multi_arch) do` at line 291.
pub fn ruby_bump_spec_l291_d15_c_multi_arch(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return bump_package_value(bump_spec_arch_cask('multi-arch-cask', ['arm', 'intel']))
}

// Ruby it `it "simulates only arm and consolidates to a general version when `depends_on arch:` restricts to arm-only" do` at line 307.
pub fn ruby_bump_spec_l307_d16_simulates(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	info := retrieve_bump_versions(bump_spec_arch_cask('arm-only-cask', ['arm']), [], 'arm-only-cask', BumpOptions{}, bump_spec_now)
	return brew_runtime.bool_value(info.new_version == BumpVersions{ general: '1.2.4' })
}

// Ruby it `it "simulates only intel and consolidates to a general version when `depends_on arch:` restricts to intel-only" do` at line 318.
pub fn ruby_bump_spec_l318_d17_simulates(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	info := retrieve_bump_versions(bump_spec_arch_cask('intel-only-cask', ['intel']), [], 'intel-only-cask', BumpOptions{}, bump_spec_now)
	return brew_runtime.bool_value(info.new_version == BumpVersions{ general: '1.2.4' })
}

// Ruby it `it "records the upstream version skipped due to release cooldown" do` at line 329.
pub fn ruby_bump_spec_l329_d18_records(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	mut package := bump_spec_basic_formula()
	package = BumpPackage{
		...package
		latest_versions: {
			'general': '1.2.4'
		}
		livecheck_strategy: 'RubyGems'
		releases: [BumpRelease{ version: '1.2.4', released_at: bump_spec_now - 3600 },
			BumpRelease{ version: '1.2.3', released_at: bump_spec_now - 8 * 86_400 }]
	}
	info := retrieve_bump_versions(package, [], 'basic_formula', BumpOptions{}, bump_spec_now)
	return brew_runtime.bool_value(info.cooldown_skipped_versions == {
		'general': '1.2.4'
	})
}

// Ruby it `it "records cooldown-skipped versions per architecture" do` at line 338.
pub fn ruby_bump_spec_l338_d19_records(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	mut package := bump_spec_arch_cask('multi-arch-cask', ['arm', 'intel'])
	package = BumpPackage{
		...package
		latest_versions: {
			'arm':   '1.2.5'
			'intel': '1.2.4'
		}
		livecheck_strategy: 'RubyGems'
		releases: [BumpRelease{ version: '1.2.5', released_at: bump_spec_now - 1800 },
			BumpRelease{ version: '1.2.4', released_at: bump_spec_now - 3600 },
			BumpRelease{ version: '1.2.3', released_at: bump_spec_now - 8 * 86_400 }]
	}
	info := retrieve_bump_versions(package, [], 'multi-arch-cask', BumpOptions{}, bump_spec_now)
	return brew_runtime.bool_value(info.cooldown_skipped_versions == {
		'arm':   '1.2.5'
		'intel': '1.2.4'
	})
}

// Ruby let `let(:version) { Version.new("1.2.3") }` at line 355.
pub fn ruby_bump_spec_l355_d20_version(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.object_value('Version', '1.2.3')
}

// Ruby let `let(:cask_version) { Cask::DSL::Version.new("1.2.3,4") }` at line 356.
pub fn ruby_bump_spec_l356_d21_cask_version(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.object_value('Cask::DSL::Version', '1.2.3,4')
}

// Ruby let `let(:message_strings) do` at line 357.
pub fn ruby_bump_spec_l357_d22_message_strings(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_array_value(bump_spec_message_strings())
}

// Ruby it `it "returns false when value is not a `Cask::DSL::Version` or string" do` at line 367.
pub fn ruby_bump_spec_l367_d23_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(!ruby_bump_l698_d7_message(brew_runtime.object_value('Version', '1.2.3')).bool_data && !ruby_bump_l698_d7_message(brew_runtime.object_value('NilClass', 'nil')).bool_data)
}

// Ruby it `it "returns false when `Cask::DSL::Version` or string is not a message" do` at line 372.
pub fn ruby_bump_spec_l372_d24_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(!ruby_bump_l698_d7_message(brew_runtime.object_value('Cask::DSL::Version', '1.2.3,4')).bool_data && !ruby_bump_l698_d7_message(brew_runtime.string_value('Not a message string')).bool_data)
}

// Ruby it `it "returns true when `Cask::DSL::Version` or string is a message" do` at line 377.
pub fn ruby_bump_spec_l377_d25_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	for message in bump_spec_message_strings() {
		if !ruby_bump_l698_d7_message(brew_runtime.object_value('Cask::DSL::Version', message)).bool_data
			|| !ruby_bump_l698_d7_message(brew_runtime.string_value(message)).bool_data {
			return brew_runtime.bool_value(false)
		}
	}
	return brew_runtime.bool_value(true)
}

// Ruby let `let(:current_general) { Homebrew::BumpVersionParser.new(general: "1.2.5") }` at line 386.
pub fn ruby_bump_spec_l386_d26_current_general(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return bump_spec_versions_value(BumpVersions{ general: '1.2.5' })
}

// Ruby let `let(:new_split) do` at line 387.
pub fn ruby_bump_spec_l387_d27_new_split(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return bump_spec_versions_value(BumpVersions{ arm: '1.2.6', intel: '1.2.5' })
}

// Ruby let `let(:current_split) do` at line 393.
pub fn ruby_bump_spec_l393_d28_current_split(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return bump_spec_versions_value(BumpVersions{ arm: '1.2.3', intel: '1.2.2' })
}

// Ruby let `let(:new_general) { Homebrew::BumpVersionParser.new(general: "1.2.4") }` at line 399.
pub fn ruby_bump_spec_l399_d29_new_general(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return bump_spec_versions_value(BumpVersions{ general: '1.2.4' })
}

// Ruby it `it "emits only changed arch arguments when a general cask version becomes arch-specific" do` at line 401.
pub fn ruby_bump_spec_l401_d30_emits(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(version_args_for_bump(BumpVersions{ general: '1.2.5' }, BumpVersions{ arm: '1.2.6', intel: '1.2.5' }, BumpVersionComparison{
		multiple_new: true
	}, 'foo') == ['--version-arm=1.2.6'])
}

// Ruby it `it "emits arch arguments for both architectures when split cask versions merge" do` at line 410.
pub fn ruby_bump_spec_l410_d31_emits(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(version_args_for_bump(BumpVersions{
		arm: '1.2.3'
		intel: '1.2.2'
	}, BumpVersions{ general: '1.2.4' }, BumpVersionComparison{
		multiple_current: true
	}, 'foo') == ['--version-arm=1.2.4', '--version-intel=1.2.4'])
}

// Ruby it `it "keeps existing split-to-split routing" do` at line 419.
pub fn ruby_bump_spec_l419_d32_keeps(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(version_args_for_bump(BumpVersions{
		arm: '1.2.3'
		intel: '1.2.2'
	}, BumpVersions{ arm: '1.2.4', intel: '1.2.2' }, BumpVersionComparison{
		multiple_current: true
		multiple_new: true
	}, 'foo') == ['--version-arm=1.2.4'])
}

// Ruby it `it "keeps existing general version routing" do` at line 433.
pub fn ruby_bump_spec_l433_d33_keeps(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(version_args_for_bump(BumpVersions{ general: '1.2.5' }, BumpVersions{ general: '1.2.4' }, BumpVersionComparison{}, 'foo') == [
		'--version=1.2.4',
	])
}

// Ruby it `it "ignores message versions in arch-specific routing" do` at line 442.
pub fn ruby_bump_spec_l442_d34_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.bool_value(version_args_for_bump(BumpVersions{ general: '1.2.5' }, BumpVersions{ arm: '1.2.6', intel: 'skipped' }, BumpVersionComparison{
		multiple_new: true
	}, 'foo') == ['--version-arm=1.2.6'])
}

// Ruby it `it "uses RubyGems version creation times" do` at line 458.
pub fn ruby_bump_spec_l458_d35_uses(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	selected := version_with_release_cooldown(BumpCooldownInfo{
		latest: '1.2.4'
		strategy: 'RubyGems'
		original_url: 'https://rubygems.org/downloads/example-package-1.2.3.gem'
		releases: [
			BumpRelease{ version: '1.2.4', released_at: bump_spec_now - 3600 },
			BumpRelease{ version: '1.2.3', released_at: bump_spec_now - 8 * 86_400 },
		]
		now: bump_spec_now
	}, '1.2.2')
	return brew_runtime.bool_value(selected == '1.2.3')
}

// Ruby it `it "uses platform-specific RubyGems releases for native gems" do` at line 506.
pub fn ruby_bump_spec_l506_d36_uses(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	selected := version_with_release_cooldown(BumpCooldownInfo{
		latest: '1.2.4'
		strategy: 'RubyGems'
		original_url: 'https://rubygems.org/downloads/example-package-1.2.3-arm64-darwin.gem'
		releases: [
			BumpRelease{ version: '1.2.4', released_at: bump_spec_now - 3600, platform: 'arm64-darwin' },
			BumpRelease{ version: '1.2.3', released_at: bump_spec_now - 8 * 86_400, platform: 'arm64-darwin' },
			BumpRelease{ version: '1.2.4', released_at: bump_spec_now - 30 * 86_400 },
		]
		now: bump_spec_now
	}, '1.2.2')
	return brew_runtime.bool_value(selected == '1.2.3')
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "bump_version_parser"
// 6: require "dev-cmd/bump"
// 7:
// 8: RSpec.describe Homebrew::DevCmd::Bump do
// 9:   subject(:bump) { described_class.new(["test"]) }
// 10:
// 11:   let(:f_basic) do
// 12:     formula("basic_formula") do
// 13:       T.bind(self, T.class_of(Formula))
// 14:       desc "Basic formula"
// 15:       url "https://brew.sh/test-1.2.3.tgz"
// 16:     end
// 17:   end
// 18:   let(:c_basic) do
// 19:     Cask::CaskLoader.load(+<<-RUBY)
// 20:       cask "basic_cask" do
// 21:         version "1.2.3"
// 22:
// 23:         name "Basic Cask"
// 24:         desc "Basic cask"
// 25:       end
// 26:     RUBY
// 27:   end
// 28:   let(:c_latest) do
// 29:     Cask::CaskLoader.load(+<<-RUBY)
// 30:       cask "latest_cask" do
// 31:         version :latest
// 32:         sha256 :no_check
// 33:
// 34:         url "https://brew.sh/test.dmg"
// 35:         name "Latest Cask"
// 36:         desc "Latest cask"
// 37:         homepage "https://brew.sh"
// 38:       end
// 39:     RUBY
// 40:   end
// 41:
// 42:   it_behaves_like "parseable arguments"
// 43:
// 44:   describe "formula", :integration_test, :needs_homebrew_curl, :needs_network do
// 45:     it "returns no data and prints a message for HEAD-only formulae" do
// 46:       content = <<~RUBY
// 47:         desc "HEAD-only test formula"
// 48:         homepage "https://brew.sh"
// 49:         head "https://github.com/Homebrew/brew.git", branch: "main"
// 50:       RUBY
// 51:       setup_test_formula("headonly", content)
// 52:
// 53:       expect { brew "bump", "headonly" }
// 54:         .to output(/Formula is HEAD-only./).to_stdout
// 55:         .and not_to_output.to_stderr
// 56:         .and be_a_success
// 57:     end
// 58:   end
// 59:
// 60:   it "gives an error for `--tap` with official taps" do
// 61:     allow(Homebrew).to receive(:install_bundler_gems!)
// 62:
// 63:     expect { described_class.new(["--tap", "Homebrew/core"]).run }
// 64:       .to raise_error(UsageError, /`--tap` requires `--auto` for official taps/)
// 65:   end
// 66:
// 67:   describe "::skip_ineligible_formulae!" do
// 68:     it "prints a legible message for casks using `version :latest`" do
// 69:       expect { expect(bump.skip_ineligible_formulae!(c_latest)).to be(true) }
// 70:         .to output(/Cask uses `version :latest` so `brew bump` cannot check it\./).to_stdout
// 71:         .and not_to_output.to_stderr
// 72:     end
// 73:   end
// 74:
// 75:   describe "::compare_versions" do
// 76:     it "returns a hash with `:multiple_versions` and `:newer_than_upstream` values" do
// 77:       general_version = Homebrew::BumpVersionParser.new(general: Version.new("1.2.3"))
// 78:       arm_intel_version = Homebrew::BumpVersionParser.new(
// 79:         arm:   Version.new("1.2.3"),
// 80:         intel: Version.new("1.2.2"),
// 81:       )
// 82:       arm_intel_version_higher = Homebrew::BumpVersionParser.new(
// 83:         arm:   Version.new("1.2.4"),
// 84:         intel: Version.new("1.2.2"),
// 85:       )
// 86:
// 87:       # Message strings are naively parsed as cask versions but this should be
// 88:       # reworked so we can easily distinguish messages from real cask versions
// 89:       skipped = Homebrew::BumpVersionParser.new(
// 90:         general: Cask::DSL::Version.new("skipped"),
// 91:       )
// 92:       arm_version_intel_skipped = Homebrew::BumpVersionParser.new(
// 93:         arm:   Version.new("1.2.3"),
// 94:         intel: Cask::DSL::Version.new("skipped"),
// 95:       )
// 96:       unable_to_get_versions = Homebrew::BumpVersionParser.new(
// 97:         general: Cask::DSL::Version.new("unable to get versions"),
// 98:       )
// 99:       unable_to_get_throttled_versions = Homebrew::BumpVersionParser.new(
// 100:         general: Cask::DSL::Version.new("unable to get throttled versions"),
// 101:       )
// 102:
// 103:       # Compare the same version types when shared by current/new versions
// 104:       expect(bump.compare_versions(general_version, general_version, f_basic)).to eq({
// 105:         multiple_versions:   { current: false, new: false },
// 106:         newer_than_upstream: { general: false },
// 107:       })
// 108:       expect(bump.compare_versions(general_version, general_version, c_basic)).to eq({
// 109:         multiple_versions:   { current: false, new: false },
// 110:         newer_than_upstream: { general: false },
// 111:       })
// 112:       expect(bump.compare_versions(arm_intel_version, arm_intel_version, c_basic)).to eq({
// 113:         multiple_versions:   { current: true, new: true },
// 114:         newer_than_upstream: { arm: false, intel: false },
// 115:       })
// 116:
// 117:       # Compare current versions to new version when the current version differs
// 118:       # by arch but the new version does not
// 119:       expect(bump.compare_versions(arm_intel_version, general_version, c_basic)).to eq({
// 120:         multiple_versions:   { current: true, new: false },
// 121:         newer_than_upstream: { arm: false, intel: false },
// 122:       })
// 123:
// 124:       # Compare current version to the highest new version when the
// 125:       # current version does not differ by arch but the new version does
// 126:       expect(bump.compare_versions(general_version, arm_intel_version, c_basic)).to eq({
// 127:         multiple_versions:   { current: false, new: true },
// 128:         newer_than_upstream: { general: false },
// 129:       })
// 130:       expect(bump.compare_versions(general_version, arm_intel_version_higher, c_basic)).to eq({
// 131:         multiple_versions:   { current: false, new: true },
// 132:         newer_than_upstream: { general: false },
// 133:       })
// 134:       expect(bump.compare_versions(general_version, arm_version_intel_skipped, c_basic)).to eq({
// 135:         multiple_versions:   { current: false, new: true },
// 136:         newer_than_upstream: { general: false },
// 137:       })
// 138:
// 139:       # Default to `false` when the new version is a message rather than a
// 140:       # version
// 141:       expect(bump.compare_versions(general_version, skipped, c_basic)).to eq({
// 142:         multiple_versions:   { current: false, new: false },
// 143:         newer_than_upstream: { general: false },
// 144:       })
// 145:       expect(bump.compare_versions(general_version, unable_to_get_versions, c_basic)).to eq({
// 146:         multiple_versions:   { current: false, new: false },
// 147:         newer_than_upstream: { general: false },
// 148:       })
// 149:       expect(bump.compare_versions(general_version, unable_to_get_throttled_versions, c_basic)).to eq({
// 150:         multiple_versions:   { current: false, new: false },
// 151:         newer_than_upstream: { general: false },
// 152:       })
// 153:     end
// 154:   end
// 155:
// 156:   describe "::retrieve_and_display_info_and_open_pr" do
// 157:     subject(:bump) { described_class.new(["--open-pr", "test"]) }
// 158:
// 159:     before do
// 160:       allow(bump).to receive(:retrieve_pull_requests)
// 161:       allow(GitHub).to receive(:too_many_open_prs?).and_return(false)
// 162:     end
// 163:
// 164:     it "passes arch-specific version arguments when a cask moves from one version to arch-specific versions" do
// 165:       version_info = Homebrew::DevCmd::Bump::VersionBumpInfo.new(
// 166:         type:                          :cask,
// 167:         deprecated:                    { general: false },
// 168:         multiple_versions:             { current: false, new: true },
// 169:         version_name:                  "cask version:   ",
// 170:         current_version:               Homebrew::BumpVersionParser.new(general: Version.new("1.2.3")),
// 171:         new_version:                   Homebrew::BumpVersionParser.new(
// 172:           arm:   Version.new("1.2.5"),
// 173:           intel: Version.new("1.2.4"),
// 174:         ),
// 175:         repology_latest:               "not found",
// 176:         newer_than_upstream:           { general: false },
// 177:         duplicate_pull_requests:       nil,
// 178:         maybe_duplicate_pull_requests: nil,
// 179:       )
// 180:       allow(bump).to receive(:retrieve_versions_by_arch).and_return(version_info)
// 181:
// 182:       expect(bump).to receive(:system).with(
// 183:         HOMEBREW_BREW_FILE,
// 184:         "bump-cask-pr",
// 185:         "basic-cask",
// 186:         "--version-arm=1.2.5",
// 187:         "--version-intel=1.2.4",
// 188:         "--no-browse",
// 189:         "--message=Created by `brew bump`",
// 190:       ).and_return(true)
// 191:
// 192:       bump.retrieve_and_display_info_and_open_pr(c_basic, "basic-cask", [], ambiguous_cask: false)
// 193:     end
// 194:
// 195:     it "passes arch-specific version arguments when an arch-specific cask moves to one version" do
// 196:       version_info = Homebrew::DevCmd::Bump::VersionBumpInfo.new(
// 197:         type:                          :cask,
// 198:         deprecated:                    { arm: false, intel: false },
// 199:         multiple_versions:             { current: true, new: false },
// 200:         version_name:                  "cask version:   ",
// 201:         current_version:               Homebrew::BumpVersionParser.new(
// 202:           arm:   Version.new("1.2.3"),
// 203:           intel: Version.new("1.2.2"),
// 204:         ),
// 205:         new_version:                   Homebrew::BumpVersionParser.new(general: Version.new("1.2.4")),
// 206:         repology_latest:               "not found",
// 207:         newer_than_upstream:           { arm: false, intel: false },
// 208:         duplicate_pull_requests:       nil,
// 209:         maybe_duplicate_pull_requests: nil,
// 210:       )
// 211:       allow(bump).to receive(:retrieve_versions_by_arch).and_return(version_info)
// 212:
// 213:       expect(bump).to receive(:system).with(
// 214:         HOMEBREW_BREW_FILE,
// 215:         "bump-cask-pr",
// 216:         "basic-cask",
// 217:         "--version-arm=1.2.4",
// 218:         "--version-intel=1.2.4",
// 219:         "--no-browse",
// 220:         "--message=Created by `brew bump`",
// 221:       ).and_return(true)
// 222:
// 223:       bump.retrieve_and_display_info_and_open_pr(c_basic, "basic-cask", [], ambiguous_cask: false)
// 224:     end
// 225:
// 226:     it "notes when a newer upstream version was skipped due to release cooldown" do
// 227:       version_info = Homebrew::DevCmd::Bump::VersionBumpInfo.new(
// 228:         type:                          :formula,
// 229:         deprecated:                    { general: false },
// 230:         multiple_versions:             { current: false, new: false },
// 231:         version_name:                  "formula version:",
// 232:         current_version:               Homebrew::BumpVersionParser.new(general: Version.new("1.2.3")),
// 233:         new_version:                   Homebrew::BumpVersionParser.new(general: Version.new("1.2.3")),
// 234:         repology_latest:               "not found",
// 235:         newer_than_upstream:           { general: false },
// 236:         cooldown_skipped_versions:     { general: Version.new("1.2.4") },
// 237:         duplicate_pull_requests:       nil,
// 238:         maybe_duplicate_pull_requests: nil,
// 239:       )
// 240:       allow(bump).to receive(:retrieve_versions_by_arch).and_return(version_info)
// 241:
// 242:       expect { bump.retrieve_and_display_info_and_open_pr(f_basic, "basic_formula", [], ambiguous_cask: false) }
// 243:         .to output(<<~EOS).to_stdout
// 244:           ==> basic_formula has a new version in release cooldown
// 245:           Current formula version:  1.2.3
// 246:           Latest livecheck version: 1.2.4 (released less than 1 day ago)
// 247:           Bump-ready version:       1.2.3
// 248:         EOS
// 249:     end
// 250:   end
// 251:
// 252:   describe "::retrieve_versions_by_arch" do
// 253:     before do
// 254:       allow(bump).to receive(:retrieve_pull_requests)
// 255:     end
// 256:
// 257:     let(:c_arm_only) do
// 258:       Cask::CaskLoader.load(+<<-RUBY)
// 259:         cask "arm_only_cask" do
// 260:           arch arm: "arm64", intel: "x64"
// 261:
// 262:           version "1.2.3"
// 263:           sha256 :no_check
// 264:
// 265:           url "https://brew.sh/test-\#{arch}.dmg"
// 266:           name "Arm Only Cask"
// 267:           desc "Arm only cask"
// 268:           homepage "https://brew.sh"
// 269:
// 270:           depends_on arch: :arm64
// 271:         end
// 272:       RUBY
// 273:     end
// 274:     let(:c_intel_only) do
// 275:       Cask::CaskLoader.load(+<<-RUBY)
// 276:         cask "intel_only_cask" do
// 277:           arch arm: "arm64", intel: "x64"
// 278:
// 279:           version "1.2.3"
// 280:           sha256 :no_check
// 281:
// 282:           url "https://brew.sh/test-\#{arch}.dmg"
// 283:           name "Intel Only Cask"
// 284:           desc "Intel only cask"
// 285:           homepage "https://brew.sh"
// 286:
// 287:           depends_on arch: :x86_64
// 288:         end
// 289:       RUBY
// 290:     end
// 291:     let(:c_multi_arch) do
// 292:       Cask::CaskLoader.load(+<<-RUBY)
// 293:         cask "multi_arch_cask" do
// 294:           arch arm: "arm64", intel: "x64"
// 295:
// 296:           version "1.2.3"
// 297:           sha256 :no_check
// 298:
// 299:           url "https://brew.sh/test-\#{arch}.dmg"
// 300:           name "Multi Arch Cask"
// 301:           desc "Multi arch cask"
// 302:           homepage "https://brew.sh"
// 303:         end
// 304:       RUBY
// 305:     end
// 306:
// 307:     it "simulates only arm and consolidates to a general version when `depends_on arch:` restricts to arm-only" do
// 308:       allow(c_arm_only).to receive(:sourcefile_path).and_return(Pathname("arm_only_cask.rb"))
// 309:       allow(Cask::CaskLoader).to receive(:load).and_return(c_arm_only)
// 310:       expect(bump).to receive(:livecheck_result).once.and_return([Version.new("1.2.4"), nil])
// 311:
// 312:       version_info = bump.retrieve_versions_by_arch(
// 313:         formula_or_cask: c_arm_only, repositories: [], name: "arm-only-cask",
// 314:       )
// 315:       expect(version_info.new_version).to eq(Homebrew::BumpVersionParser.new(general: Version.new("1.2.4")))
// 316:     end
// 317:
// 318:     it "simulates only intel and consolidates to a general version when `depends_on arch:` restricts to intel-only" do
// 319:       allow(c_intel_only).to receive(:sourcefile_path).and_return(Pathname("intel_only_cask.rb"))
// 320:       allow(Cask::CaskLoader).to receive(:load).and_return(c_intel_only)
// 321:       expect(bump).to receive(:livecheck_result).once.and_return([Version.new("1.2.4"), nil])
// 322:
// 323:       version_info = bump.retrieve_versions_by_arch(
// 324:         formula_or_cask: c_intel_only, repositories: [], name: "intel-only-cask",
// 325:       )
// 326:       expect(version_info.new_version).to eq(Homebrew::BumpVersionParser.new(general: Version.new("1.2.4")))
// 327:     end
// 328:
// 329:     it "records the upstream version skipped due to release cooldown" do
// 330:       expect(bump).to receive(:livecheck_result).once.and_return([Version.new("1.2.3"), Version.new("1.2.4")])
// 331:
// 332:       version_info = bump.retrieve_versions_by_arch(
// 333:         formula_or_cask: f_basic, repositories: [], name: "basic_formula",
// 334:       )
// 335:       expect(version_info.cooldown_skipped_versions).to eq({ general: Version.new("1.2.4") })
// 336:     end
// 337:
// 338:     it "records cooldown-skipped versions per architecture" do
// 339:       allow(c_multi_arch).to receive(:sourcefile_path).and_return(Pathname("multi_arch_cask.rb"))
// 340:       allow(Cask::CaskLoader).to receive(:load).and_return(c_multi_arch)
// 341:       expect(bump).to receive(:livecheck_result).twice.and_return(
// 342:         [Version.new("1.2.3"), Version.new("1.2.4")],
// 343:         [Version.new("1.2.3"), Version.new("1.2.5")],
// 344:       )
// 345:
// 346:       version_info = bump.retrieve_versions_by_arch(
// 347:         formula_or_cask: c_multi_arch, repositories: [], name: "multi-arch-cask",
// 348:       )
// 349:       expect(version_info.cooldown_skipped_versions).to eq({ arm:   Version.new("1.2.5"),
// 350:                                                              intel: Version.new("1.2.4") })
// 351:     end
// 352:   end
// 353:
// 354:   describe "::message?" do
// 355:     let(:version) { Version.new("1.2.3") }
// 356:     let(:cask_version) { Cask::DSL::Version.new("1.2.3,4") }
// 357:     let(:message_strings) do
// 358:       [
// 359:         "error: message",
// 360:         "skipped",
// 361:         "skipped - deprecated",
// 362:         "unable to get versions",
// 363:         "unable to get throttled versions",
// 364:       ]
// 365:     end
// 366:
// 367:     it "returns false when value is not a `Cask::DSL::Version` or string" do
// 368:       expect(bump.message?(version)).to be(false)
// 369:       expect(bump.message?(nil)).to be(false)
// 370:     end
// 371:
// 372:     it "returns false when `Cask::DSL::Version` or string is not a message" do
// 373:       expect(bump.message?(cask_version)).to be(false)
// 374:       expect(bump.message?("Not a message string")).to be(false)
// 375:     end
// 376:
// 377:     it "returns true when `Cask::DSL::Version` or string is a message" do
// 378:       message_strings.each do |message_string|
// 379:         expect(bump.message?(Cask::DSL::Version.new(message_string))).to be(true)
// 380:         expect(bump.message?(message_string)).to be(true)
// 381:       end
// 382:     end
// 383:   end
// 384:
// 385:   describe "::version_args_for_bump" do
// 386:     let(:current_general) { Homebrew::BumpVersionParser.new(general: "1.2.5") }
// 387:     let(:new_split) do
// 388:       Homebrew::BumpVersionParser.new(
// 389:         arm:   "1.2.6",
// 390:         intel: "1.2.5",
// 391:       )
// 392:     end
// 393:     let(:current_split) do
// 394:       Homebrew::BumpVersionParser.new(
// 395:         arm:   "1.2.3",
// 396:         intel: "1.2.2",
// 397:       )
// 398:     end
// 399:     let(:new_general) { Homebrew::BumpVersionParser.new(general: "1.2.4") }
// 400:
// 401:     it "emits only changed arch arguments when a general cask version becomes arch-specific" do
// 402:       expect(
// 403:         bump.version_args_for_bump(current_version:   current_general,
// 404:                                    new_version:       new_split,
// 405:                                    multiple_versions: { current: false, new: true },
// 406:                                    name:              "foo"),
// 407:       ).to eq(["--version-arm=1.2.6"])
// 408:     end
// 409:
// 410:     it "emits arch arguments for both architectures when split cask versions merge" do
// 411:       expect(
// 412:         bump.version_args_for_bump(current_version:   current_split,
// 413:                                    new_version:       new_general,
// 414:                                    multiple_versions: { current: true, new: false },
// 415:                                    name:              "foo"),
// 416:       ).to eq(["--version-arm=1.2.4", "--version-intel=1.2.4"])
// 417:     end
// 418:
// 419:     it "keeps existing split-to-split routing" do
// 420:       new_split = Homebrew::BumpVersionParser.new(
// 421:         arm:   "1.2.4",
// 422:         intel: "1.2.2",
// 423:       )
// 424:
// 425:       expect(
// 426:         bump.version_args_for_bump(current_version:   current_split,
// 427:                                    new_version:       new_split,
// 428:                                    multiple_versions: { current: true, new: true },
// 429:                                    name:              "foo"),
// 430:       ).to eq(["--version-arm=1.2.4"])
// 431:     end
// 432:
// 433:     it "keeps existing general version routing" do
// 434:       expect(
// 435:         bump.version_args_for_bump(current_version:   current_general,
// 436:                                    new_version:       new_general,
// 437:                                    multiple_versions: { current: false, new: false },
// 438:                                    name:              "foo"),
// 439:       ).to eq(["--version=1.2.4"])
// 440:     end
// 441:
// 442:     it "ignores message versions in arch-specific routing" do
// 443:       new_split = Homebrew::BumpVersionParser.new(
// 444:         arm:   "1.2.6",
// 445:         intel: "skipped",
// 446:       )
// 447:
// 448:       expect(
// 449:         bump.version_args_for_bump(current_version:   current_general,
// 450:                                    new_version:       new_split,
// 451:                                    multiple_versions: { current: false, new: true },
// 452:                                    name:              "foo"),
// 453:       ).to eq(["--version-arm=1.2.6"])
// 454:     end
// 455:   end
// 456:
// 457:   describe "::version_with_cooldown" do
// 458:     it "uses RubyGems version creation times" do
// 459:       version_info = {
// 460:         latest: "1.2.4",
// 461:         meta:   {
// 462:           strategy: "RubyGems",
// 463:           url:      {
// 464:             original: "https://rubygems.org/downloads/example-package-1.2.3.gem",
// 465:             strategy: "https://rubygems.org/api/v1/versions/example-package/latest.json",
// 466:           },
// 467:         },
// 468:       }
// 469:       content = <<~JSON
// 470:         [
// 471:           {
// 472:             "created_at": "2026-04-04T00:00:00.000Z",
// 473:             "number": "1.2.4",
// 474:             "platform": "ruby",
// 475:             "prerelease": false
// 476:           },
// 477:           {
// 478:             "created_at": "2026-04-02T00:00:00.000Z",
// 479:             "number": "1.2.3",
// 480:             "platform": "ruby",
// 481:             "prerelease": false
// 482:           }
// 483:         ]
// 484:       JSON
// 485:
// 486:       allow(DateTime).to receive(:now).and_return(DateTime.parse("2026-04-04T12:00:00Z"))
// 487:       allow(Utils::Curl).to receive(:curl_output)
// 488:         .with(
// 489:           "--compressed",
// 490:           "--fail-with-body",
// 491:           "--location",
// 492:           "--max-redirs",
// 493:           "5",
// 494:           "--silent",
// 495:           "https://rubygems.org/api/v1/versions/example-package.json",
// 496:           connect_timeout: 15,
// 497:           max_time:        55,
// 498:           retries:         0,
// 499:           timeout:         60,
// 500:         )
// 501:         .and_return([content, "", instance_double(Process::Status, success?: true)])
// 502:
// 503:       expect(bump.version_with_cooldown(version_info, Version.new("1.2.2"))).to eq(Version.new("1.2.3"))
// 504:     end
// 505:
// 506:     it "uses platform-specific RubyGems releases for native gems" do
// 507:       version_info = {
// 508:         latest: "1.2.4",
// 509:         meta:   {
// 510:           strategy: "RubyGems",
// 511:           url:      {
// 512:             original: "https://rubygems.org/downloads/example-package-1.2.3-arm64-darwin.gem",
// 513:             strategy: "https://rubygems.org/api/v1/versions/example-package/latest.json",
// 514:           },
// 515:         },
// 516:       }
// 517:       content = <<~JSON
// 518:         [
// 519:           {
// 520:             "created_at": "2026-04-04T00:00:00.000Z",
// 521:             "number": "1.2.4",
// 522:             "platform": "arm64-darwin",
// 523:             "prerelease": false
// 524:           },
// 525:           {
// 526:             "created_at": "2026-04-02T00:00:00.000Z",
// 527:             "number": "1.2.3",
// 528:             "platform": "arm64-darwin",
// 529:             "prerelease": false
// 530:           },
// 531:           {
// 532:             "created_at": "2026-03-01T00:00:00.000Z",
// 533:             "number": "1.2.4",
// 534:             "platform": "ruby",
// 535:             "prerelease": false
// 536:           },
// 537:           {
// 538:             "created_at": "2026-02-01T00:00:00.000Z",
// 539:             "number": "1.2.3",
// 540:             "platform": "ruby",
// 541:             "prerelease": false
// 542:           }
// 543:         ]
// 544:       JSON
// 545:
// 546:       allow(DateTime).to receive(:now).and_return(DateTime.parse("2026-04-04T12:00:00Z"))
// 547:       allow(Utils::Curl).to receive(:curl_output)
// 548:         .with(
// 549:           "--compressed",
// 550:           "--fail-with-body",
// 551:           "--location",
// 552:           "--max-redirs",
// 553:           "5",
// 554:           "--silent",
// 555:           "https://rubygems.org/api/v1/versions/example-package.json",
// 556:           connect_timeout: 15,
// 557:           max_time:        55,
// 558:           retries:         0,
// 559:           timeout:         60,
// 560:         )
// 561:         .and_return([content, "", instance_double(Process::Status, success?: true)])
// 562:
// 563:       expect(bump.version_with_cooldown(version_info, Version.new("1.2.2"))).to eq(Version.new("1.2.3"))
// 564:     end
// 565:   end
// 566: end
