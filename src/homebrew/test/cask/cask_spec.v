module cask

import brew_runtime

// Translated from Homebrew/brew `test/cask/cask_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:cask) { described_class.new("versioned-cask") }` at line 5.
pub fn ruby_cask_spec_l5_d1_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby method `write_info_plist(path, short_version: nil, bundle_version: nil, contents: nil)` at line 7.
pub fn ruby_cask_spec_l7_d2_write_info_plist(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('write_info_plist', ...args)
}

// Ruby method `write_auto_updates_cask(path, version:, artifacts:, token: "auto-updates-bundle-check")` at line 41.
pub fn ruby_cask_spec_l41_d3_write_auto_updates_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('write_auto_updates_cask', ...args)
}

// Ruby it `it "skips untrusted tap casks when trust is enabled" do` at line 60.
pub fn ruby_cask_spec_l60_d4_skips(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skips', ...args)
}

// Ruby it `it "allows all casks when trust is disabled" do` at line 80.
pub fn ruby_cask_spec_l80_d5_allows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('allows', ...args)
}

// Ruby it `it "skips invalid casks instead of aborting" do` at line 89.
pub fn ruby_cask_spec_l89_d6_skips(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skips', ...args)
}

// Ruby it `it "matches` at line 116.
pub fn ruby_cask_spec_l116_d7_matches(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('matches', ...args)
}

// Ruby it `it "uses the last unique version" do` at line 126.
pub fn ruby_cask_spec_l126_d8_uses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uses', ...args)
}

// Ruby it `it "ignores and replaces a dangling pin" do` at line 148.
pub fn ruby_cask_spec_l148_d9_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ignores', ...args)
}

// Ruby it `it "replaces a regular file pin record" do` at line 163.
pub fn ruby_cask_spec_l163_d10_replaces(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('replaces', ...args)
}

// Ruby let `let(:tap_path) { CoreCaskTap.instance.path }` at line 177.
pub fn ruby_cask_spec_l177_d11_tap_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tap_path', ...args)
}

// Ruby let `let(:file_dirname) { Pathname.new(__FILE__).dirname }` at line 178.
pub fn ruby_cask_spec_l178_d12_file_dirname(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('file_dirname', ...args)
}

// Ruby let `let(:relative_tap_path) { tap_path.relative_path_from(file_dirname) }` at line 179.
pub fn ruby_cask_spec_l179_d13_relative_tap_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('relative_tap_path', ...args)
}

// Ruby it `it "returns an instance of the Cask for the given token" do` at line 181.
pub fn ruby_cask_spec_l181_d14_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns an instance of the Cask from a specific file location" do` at line 187.
pub fn ruby_cask_spec_l187_d15_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns an instance of the Cask from a JSON file" do` at line 195.
pub fn ruby_cask_spec_l195_d16_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns an instance of the Cask from an internal JSON file" do` at line 203.
pub fn ruby_cask_spec_l203_d17_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns an instance of the Cask from a URL", :needs_utils_curl do` at line 211.
pub fn ruby_cask_spec_l211_d18_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "raises an error when failing to download a Cask from a URL", :needs_utils_curl do` at line 217.
pub fn ruby_cask_spec_l217_d19_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "returns an instance of the Cask from a relative file location" do` at line 223.
pub fn ruby_cask_spec_l223_d20_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "uses exact match when loading by token" do` at line 229.
pub fn ruby_cask_spec_l229_d21_uses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uses', ...args)
}

// Ruby it `it "raises an error when attempting to load a Cask that doesn't exist" do` at line 234.
pub fn ruby_cask_spec_l234_d22_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "proposes a versioned metadata directory name for each instance" do` at line 242.
pub fn ruby_cask_spec_l242_d23_proposes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('proposes', ...args)
}

// Ruby it `it "ignores the Casks that have auto_updates true (without --greedy)" do` at line 251.
pub fn ruby_cask_spec_l251_d24_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ignores', ...args)
}

// Ruby it `it "ignores the Casks that have version :latest (without --greedy)" do` at line 257.
pub fn ruby_cask_spec_l257_d25_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ignores', ...args)
}

// Ruby subject `subject { cask.outdated_version }` at line 264.
pub fn ruby_cask_spec_l264_d26_subject_dynamic(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('subject_dynamic', ...args)
}

// Ruby let `let(:cask) { described_class.new("basic-cask") }` at line 266.
pub fn ruby_cask_spec_l266_d27_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby it `it {` at line 271.
pub fn ruby_cask_spec_l271_d28_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('{', ...args)
}

// Ruby let `let(:dir) { Pathname(mktmpdir) }` at line 294.
pub fn ruby_cask_spec_l294_d29_dir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dir', ...args)
}

// Ruby let `let(:cask_file) { dir/"auto-updates-bundle-check.rb" }` at line 295.
pub fn ruby_cask_spec_l295_d30_cask_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_file', ...args)
}

// Ruby let `let(:artifacts) { ['app "MyFancyApp.app"'] }` at line 296.
pub fn ruby_cask_spec_l296_d31_artifacts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('artifacts', ...args)
}

// Ruby it `it "is outdated when the installed short version is lower than the tap version" do` at line 302.
pub fn ruby_cask_spec_l302_d32_is(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('is', ...args)
}

// Ruby it `it "is not outdated when auto-update upgrades are disabled" do` at line 311.
pub fn ruby_cask_spec_l311_d33_is(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('is', ...args)
}

// Ruby it `it "is not outdated when the short version matches and the bundle version is lower than a CSV candidate" do` at line 321.
pub fn ruby_cask_spec_l321_d34_is(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('is', ...args)
}

// Ruby it `it "is not outdated when the short version matches and the bundle version matches any CSV candidate" do` at line 330.
pub fn ruby_cask_spec_l330_d35_is(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('is', ...args)
}

// Ruby it `it "is not outdated when the installed short version is higher than the tap version" do` at line 339.
pub fn ruby_cask_spec_l339_d36_is(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('is', ...args)
}

// Ruby it `it "is not outdated when the installed cask version already matches the tap version" do` at line 348.
pub fn ruby_cask_spec_l348_d37_is(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('is', ...args)
}

// Ruby it `it "is not outdated when the installed short version directly matches the tap version" do` at line 357.
pub fn ruby_cask_spec_l357_d38_is(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('is', ...args)
}

// Ruby it `it "is not outdated when the installed bundle version directly matches the tap version" do` at line 366.
pub fn ruby_cask_spec_l366_d39_is(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('is', ...args)
}

// Ruby it `it "is not outdated when the installed short and bundle versions combine to the tap version" do` at line 375.
pub fn ruby_cask_spec_l375_d40_is(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('is', ...args)
}

// Ruby it `it "is not outdated when the combined installed version is higher than the tap version" do` at line 384.
pub fn ruby_cask_spec_l384_d41_is(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('is', ...args)
}

// Ruby it `it "is not outdated when the installed short version matches a CSV build candidate" do` at line 393.
pub fn ruby_cask_spec_l393_d42_is(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('is', ...args)
}

// Ruby it `it "is not outdated when the short version matches and the bundle version is higher than all CSV candidates" do` at line 402.
pub fn ruby_cask_spec_l402_d43_is(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('is', ...args)
}

// Ruby it `it "matches a bundle version candidate that is not first in the CSV list" do` at line 411.
pub fn ruby_cask_spec_l411_d44_matches(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('matches', ...args)
}

// Ruby it `it "is not outdated when the app bundle metadata cannot be read" do` at line 421.
pub fn ruby_cask_spec_l421_d45_is(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('is', ...args)
}

// Ruby it `it "falls back to the bundle version when the short version is missing" do` at line 429.
pub fn ruby_cask_spec_l429_d46_falls(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('falls', ...args)
}

// Ruby it `it "ignores bad bundle versions when the short version is missing" do` at line 438.
pub fn ruby_cask_spec_l438_d47_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ignores', ...args)
}

// Ruby it `it "is not outdated when plist version segment counts differ from the tap version" do` at line 447.
pub fn ruby_cask_spec_l447_d48_is(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('is', ...args)
}

// Ruby let `let(:cask) { described_class.new("basic-cask") }` at line 458.
pub fn ruby_cask_spec_l458_d49_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby subject `subject { cask.outdated_version(greedy:) }` at line 465.
pub fn ruby_cask_spec_l465_d50_subject_dynamic(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('subject_dynamic', ...args)
}

// Ruby it `it {` at line 467.
pub fn ruby_cask_spec_l467_d51_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('{', ...args)
}

// Ruby it `it "is the cask token" do` at line 509.
pub fn ruby_cask_spec_l509_d52_is(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('is', ...args)
}

// Ruby it `it "returns the fully-qualified name of the cask" do` at line 516.
pub fn ruby_cask_spec_l516_d53_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns the cask token" do` at line 525.
pub fn ruby_cask_spec_l525_d54_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby subject `subject(:cask) { Cask::CaskLoader.load("many-artifacts") }` at line 544.
pub fn ruby_cask_spec_l544_d55_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby it `it "returns all artifacts when no options are given" do` at line 546.
pub fn ruby_cask_spec_l546_d56_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns only uninstall artifacts when uninstall_only is true" do` at line 567.
pub fn ruby_cask_spec_l567_d57_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby subject `subject(:cask) { Cask::CaskLoader.load("many-renames") }` at line 587.
pub fn ruby_cask_spec_l587_d58_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby it `it "returns the correct rename list" do` at line 589.
pub fn ruby_cask_spec_l589_d59_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby matcher `matcher :have_uninstall_flight_blocks do` at line 598.
pub fn ruby_cask_spec_l598_d60_have_uninstall_flight_blocks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('have_uninstall_flight_blocks', ...args)
}

// Ruby it `it "returns true when there are uninstall_preflight blocks" do` at line 604.
pub fn ruby_cask_spec_l604_d61_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns true when there are uninstall_postflight blocks" do` at line 609.
pub fn ruby_cask_spec_l609_d62_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns false when there are only preflight blocks" do` at line 614.
pub fn ruby_cask_spec_l614_d63_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns false when there are only postflight blocks" do` at line 619.
pub fn ruby_cask_spec_l619_d64_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns false when there are no flight blocks" do` at line 624.
pub fn ruby_cask_spec_l624_d65_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "uses explicit OS dependencies and defaults to Linux support" do` at line 631.
pub fn ruby_cask_spec_l631_d66_uses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uses', ...args)
}

// Ruby it `it "returns false for casks with bare depends_on :linux" do` at line 644.
pub fn ruby_cask_spec_l644_d67_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "includes pinned cask details" do` at line 650.
pub fn ruby_cask_spec_l650_d68_includes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('includes', ...args)
}

// Ruby let `let(:expected_json) do` at line 664.
pub fn ruby_cask_spec_l664_d69_expected_json(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('expected_json', ...args)
}

// Ruby it `it "returns expected hash" do` at line 669.
pub fn ruby_cask_spec_l669_d70_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns expected hash" do` at line 684.
pub fn ruby_cask_spec_l684_d71_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby let `let(:cask) { Cask::CaskLoader.load("on-linux-asymmetric") }` at line 697.
pub fn ruby_cask_spec_l697_d72_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby it `it "yields with the cask refreshed for a supported tag" do` at line 699.
pub fn ruby_cask_spec_l699_d73_yields(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('yields', ...args)
}

// Ruby it `it "yields for a Linux architecture whose checksum is missing" do` at line 704.
pub fn ruby_cask_spec_l704_d74_yields(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('yields', ...args)
}

// Ruby it `it "returns nil for a tag the cask cannot be refreshed for" do` at line 709.
pub fn ruby_cask_spec_l709_d75_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby let! `let!(:original_macos_version) { MacOS.full_version.to_s }` at line 724.
pub fn ruby_cask_spec_l724_d76_original_macos_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('original_macos_version', ...args)
}

// Ruby let `let(:expected_versions_variations) do` at line 725.
pub fn ruby_cask_spec_l725_d77_expected_versions_variations(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('expected_versions_variations', ...args)
}

// Ruby let `let(:expected_sha256_variations) do` at line 774.
pub fn ruby_cask_spec_l774_d78_expected_sha256_variations(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('expected_sha256_variations', ...args)
}

// Ruby let `let(:expected_sha256_variations_os) do` at line 819.
pub fn ruby_cask_spec_l819_d79_expected_sha256_variations_os(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('expected_sha256_variations_os', ...args)
}

// Ruby it `it "returns language variations with a deterministic default" do` at line 875.
pub fn ruby_cask_spec_l875_d80_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "preserves the cask configuration while generating language variations" do` at line 898.
pub fn ruby_cask_spec_l898_d81_preserves(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('preserves', ...args)
}

// Ruby it `it "returns the correct variations hash for a cask with multiple versions" do` at line 909.
pub fn ruby_cask_spec_l909_d82_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns the correct variations hash for a cask different sha256s on each arch" do` at line 917.
pub fn ruby_cask_spec_l917_d83_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns the correct variations hash for a cask different sha256s on each arch and os" do` at line 925.
pub fn ruby_cask_spec_l925_d84_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "emits variations without checksums for Linux architectures a cask omits" do` at line 933.
pub fn ruby_cask_spec_l933_d85_emits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('emits', ...args)
}

// Ruby it `it "emits Linux variations for a cask with Linux checksums but no `os` stanza" do` at line 943.
pub fn ruby_cask_spec_l943_d86_emits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('emits', ...args)
}

// Ruby it `it "emits Linux variations with checksums for a Linux-only cask" do` at line 950.
pub fn ruby_cask_spec_l950_d87_emits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('emits', ...args)
}

// Ruby it `it "emits Linux variations for a cask with `on_linux` content but no `os` stanza" do` at line 960.
pub fn ruby_cask_spec_l960_d88_emits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('emits', ...args)
}

// Ruby let `let(:platform_tags) do` at line 983.
pub fn ruby_cask_spec_l983_d89_platform_tags(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('platform_tags', ...args)
}

// Ruby let `let(:macos_platforms) { [:sonoma, :arm64_sonoma, :monterey, :arm64_monterey, :catalina] }` at line 994.
pub fn ruby_cask_spec_l994_d90_macos_platforms(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('macos_platforms', ...args)
}

// Ruby it `it "records platforms allowed by scoped macOS requirements" do` at line 1000.
pub fn ruby_cask_spec_l1000_d91_records(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('records', ...args)
}

// Ruby it `it "excludes platforms without complete download data" do` at line 1008.
pub fn ruby_cask_spec_l1008_d92_excludes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('excludes', ...args)
}

// Ruby it `it "excludes platforms rejected by architecture requirements" do` at line 1014.
pub fn ruby_cask_spec_l1014_d93_excludes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('excludes', ...args)
}

// Ruby it `it "does not infer macOS support from artifact types" do` at line 1031.
pub fn ruby_cask_spec_l1031_d94_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "does not infer macOS support from manual installers" do` at line 1043.
pub fn ruby_cask_spec_l1043_d95_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "does not infer Linux support from artifact types" do` at line 1055.
pub fn ruby_cask_spec_l1055_d96_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "excludes Linux for casks with a bare macOS dependency" do` at line 1067.
pub fn ruby_cask_spec_l1067_d97_excludes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('excludes', ...args)
}

// Ruby it `it "excludes macOS for casks with a bare Linux dependency" do` at line 1079.
pub fn ruby_cask_spec_l1079_d98_excludes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('excludes', ...args)
}

// Ruby it `it "includes stage-only casks" do` at line 1091.
pub fn ruby_cask_spec_l1091_d99_includes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('includes', ...args)
}

// Ruby it `it "records no supported platforms for a cask without an installable artifact" do` at line 1103.
pub fn ruby_cask_spec_l1103_d100_records(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('records', ...args)
}

// Ruby it `it "records every platform when a cask has no platform variations" do` at line 1115.
pub fn ruby_cask_spec_l1115_d101_records(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('records', ...args)
}

// Ruby it `it "records top-level platform requirements without variations" do` at line 1126.
pub fn ruby_cask_spec_l1126_d102_records(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('records', ...args)
}

// Ruby it `it "serializes architecture-varying and universal casks with the same macOS requirement" do` at line 1139.
pub fn ruby_cask_spec_l1139_d103_serializes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('serializes', ...args)
}

// Ruby it `it "isolates macOS requirement comparisons between casks" do` at line 1174.
pub fn ruby_cask_spec_l1174_d104_isolates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('isolates', ...args)
}

// Ruby it `it "returns the correct hash placeholders" do` at line 1198.
pub fn ruby_cask_spec_l1198_d105_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby let `let(:expected_json) do` at line 1212.
pub fn ruby_cask_spec_l1212_d106_expected_json(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('expected_json', ...args)
}

// Ruby it `it "returns expected hash with variations" do` at line 1217.
pub fn ruby_cask_spec_l1217_d107_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "does not include macOS dependency in Linux variations" do` at line 1231.
pub fn ruby_cask_spec_l1231_d108_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::Cask, :cask do
// 5:   let(:cask) { described_class.new("versioned-cask") }
// 6:
// 7:   def write_info_plist(path, short_version: nil, bundle_version: nil, contents: nil)
// 8:     info_plist = path/"Contents/Info.plist"
// 9:     info_plist.dirname.mkpath
// 10:
// 11:     if contents
// 12:       info_plist.write(contents)
// 13:       return
// 14:     end
// 15:
// 16:     entries = []
// 17:     if short_version
// 18:       entries << <<~PLIST.chomp
// 19:         <key>CFBundleShortVersionString</key>
// 20:         <string>#{short_version}</string>
// 21:       PLIST
// 22:     end
// 23:     if bundle_version
// 24:       entries << <<~PLIST.chomp
// 25:         <key>CFBundleVersion</key>
// 26:         <string>#{bundle_version}</string>
// 27:       PLIST
// 28:     end
// 29:
// 30:     info_plist.write <<~PLIST
// 31:       <?xml version="1.0" encoding="UTF-8"?>
// 32:       <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "https://www.apple.com/DTDs/PropertyList-1.0.dtd">
// 33:       <plist version="1.0">
// 34:       <dict>
// 35:       #{entries.join("\n")}
// 36:       </dict>
// 37:       </plist>
// 38:     PLIST
// 39:   end
// 40:
// 41:   def write_auto_updates_cask(path, version:, artifacts:, token: "auto-updates-bundle-check")
// 42:     path.write <<~RUBY
// 43:       cask "#{token}" do
// 44:         version "#{version}"
// 45:         sha256 "5633c3a0f2e572cbf021507dec78c50998b398c343232bdfc7e26221d0a5db4d"
// 46:
// 47:         url "file://#{TEST_FIXTURE_DIR}/cask/MyFancyApp.zip"
// 48:         homepage "https://brew.sh/MyFancyApp"
// 49:
// 50:         auto_updates true
// 51:
// 52:         #{artifacts.join("\n  ")}
// 53:       end
// 54:     RUBY
// 55:
// 56:     Cask::CaskLoader.load(path)
// 57:   end
// 58:
// 59:   describe ".all" do
// 60:     it "skips untrusted tap casks when trust is enabled" do
// 61:       tap = Tap.fetch("thirdparty", "foo")
// 62:       cask_path = tap.cask_dir/"untrusted.rb"
// 63:       cask_path.dirname.mkpath
// 64:       cask_path.write <<~RUBY
// 65:         raise "untrusted cask evaluated"
// 66:       RUBY
// 67:
// 68:       allow(CoreCaskTap.instance).to receive(:cask_tokens).and_return([])
// 69:       allow(Tap).to receive(:reject).and_return([tap])
// 70:       expect(Cask::CaskLoader).not_to receive(:load).with(cask_path)
// 71:
// 72:       with_env(HOMEBREW_REQUIRE_TAP_TRUST: "1") do
// 73:         expect { expect(described_class.all(eval_all: true)).to eq([]) }
// 74:           .to output(%r{Skipping thirdparty/foo because it is not trusted}).to_stderr
// 75:       end
// 76:     ensure
// 77:       FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 78:     end
// 79:
// 80:     it "allows all casks when trust is disabled" do
// 81:       allow(CoreCaskTap.instance).to receive(:cask_tokens).and_return([])
// 82:       allow(Tap).to receive(:reject).and_return([])
// 83:
// 84:       with_env(HOMEBREW_NO_REQUIRE_TAP_TRUST: "1") do
// 85:         expect(described_class.all).to eq([])
// 86:       end
// 87:     end
// 88:
// 89:     it "skips invalid casks instead of aborting" do
// 90:       tap = Tap.fetch("thirdparty", "foo")
// 91:       cask_path = tap.cask_dir/"mismatch.rb"
// 92:       cask_path.dirname.mkpath
// 93:       cask_path.write <<~RUBY
// 94:         cask "not-mismatch" do
// 95:           version "1.0"
// 96:           sha256 :no_check
// 97:           url "https://example.com/foo.zip"
// 98:           name "Foo"
// 99:           app "Foo.app"
// 100:         end
// 101:       RUBY
// 102:
// 103:       allow(CoreCaskTap.instance).to receive(:cask_tokens).and_return([])
// 104:       allow(Tap).to receive(:reject).and_return([tap])
// 105:
// 106:       with_env(HOMEBREW_NO_REQUIRE_TAP_TRUST: "1") do
// 107:         expect { expect(described_class.all).to eq([]) }
// 108:           .to output(/Cask 'mismatch' definition is invalid/).to_stderr
// 109:       end
// 110:     ensure
// 111:       FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 112:     end
// 113:   end
// 114:
// 115:   describe "#any_version_installed?" do
// 116:     it "matches #installed?" do
// 117:       allow(cask).to receive(:installed?).and_return(true)
// 118:
// 119:       expect(cask.any_version_installed?).to be true
// 120:     end
// 121:   end
// 122:
// 123:   context "when multiple versions are installed" do
// 124:     describe "#installed_version" do
// 125:       context "when there are duplicate versions" do
// 126:         it "uses the last unique version" do
// 127:           Dir.mktmpdir do |dir|
// 128:             allow(Cask::Caskroom).to receive(:path).and_return(Pathname(dir))
// 129:             [
// 130:               ["1.2.2", "0999"],
// 131:               ["1.2.3", "1000"],
// 132:               ["1.2.2", "1001"],
// 133:             ].each do |version, timestamp|
// 134:               casks_dir = Pathname(dir)/"versioned-cask/.metadata/#{version}/#{timestamp}/Casks"
// 135:               casks_dir.mkpath
// 136:               # Installed caskfile must exist to count as installed.
// 137:               (casks_dir/"versioned-cask.rb").write("cask \"versioned-cask\"\n")
// 138:             end
// 139:
// 140:             expect(cask.installed_version).to eq("1.2.2")
// 141:           end
// 142:         end
// 143:       end
// 144:     end
// 145:   end
// 146:
// 147:   describe "#pinned?" do
// 148:     it "ignores and replaces a dangling pin" do
// 149:       HOMEBREW_PINNED_CASKS.mkpath
// 150:       cask.pin_path.make_relative_symlink(cask.caskroom_path/"missing")
// 151:
// 152:       expect(cask).not_to be_pinned
// 153:       expect(cask.pinned_version).to be_nil
// 154:
// 155:       allow(cask).to receive(:installed_version).and_return("1.0")
// 156:       (cask.caskroom_path/"1.0").mkpath
// 157:       cask.pin
// 158:
// 159:       expect(cask).to be_pinned
// 160:       expect(cask.pinned_version).to eq("1.0")
// 161:     end
// 162:
// 163:     it "replaces a regular file pin record" do
// 164:       HOMEBREW_PINNED_CASKS.mkpath
// 165:       cask.pin_path.write("not a symlink")
// 166:       allow(cask).to receive(:installed_version).and_return("1.0")
// 167:       (cask.caskroom_path/"1.0").mkpath
// 168:
// 169:       cask.pin
// 170:
// 171:       expect(cask).to be_pinned
// 172:       expect(cask.pin_path).to be_a_symlink
// 173:     end
// 174:   end
// 175:
// 176:   describe "load" do
// 177:     let(:tap_path) { CoreCaskTap.instance.path }
// 178:     let(:file_dirname) { Pathname.new(__FILE__).dirname }
// 179:     let(:relative_tap_path) { tap_path.relative_path_from(file_dirname) }
// 180:
// 181:     it "returns an instance of the Cask for the given token" do
// 182:       c = Cask::CaskLoader.load("local-caffeine")
// 183:       expect(c).to be_a(described_class)
// 184:       expect(c.token).to eq("local-caffeine")
// 185:     end
// 186:
// 187:     it "returns an instance of the Cask from a specific file location" do
// 188:       c = Cask::CaskLoader.load("#{tap_path}/Casks/local-caffeine.rb")
// 189:       expect(c).to be_a(described_class)
// 190:       expect(c).not_to be_loaded_from_api
// 191:       expect(c).not_to be_loaded_from_internal_api
// 192:       expect(c.token).to eq("local-caffeine")
// 193:     end
// 194:
// 195:     it "returns an instance of the Cask from a JSON file" do
// 196:       c = Cask::CaskLoader.load("#{TEST_FIXTURE_DIR}/cask/caffeine.json")
// 197:       expect(c).to be_a(described_class)
// 198:       expect(c).to be_loaded_from_api
// 199:       expect(c).not_to be_loaded_from_internal_api
// 200:       expect(c.token).to eq("caffeine")
// 201:     end
// 202:
// 203:     it "returns an instance of the Cask from an internal JSON file" do
// 204:       c = Cask::CaskLoader.load("#{TEST_FIXTURE_DIR}/cask/caffeine.internal.json")
// 205:       expect(c).to be_a(described_class)
// 206:       expect(c).to be_loaded_from_api
// 207:       expect(c).to be_loaded_from_internal_api
// 208:       expect(c.token).to eq("caffeine")
// 209:     end
// 210:
// 211:     it "returns an instance of the Cask from a URL", :needs_utils_curl do
// 212:       c = Cask::CaskLoader.load("file://#{tap_path}/Casks/local-caffeine.rb")
// 213:       expect(c).to be_a(described_class)
// 214:       expect(c.token).to eq("local-caffeine")
// 215:     end
// 216:
// 217:     it "raises an error when failing to download a Cask from a URL", :needs_utils_curl do
// 218:       expect do
// 219:         Cask::CaskLoader.load("file://#{tap_path}/Casks/notacask.rb")
// 220:       end.to raise_error(Cask::CaskUnavailableError)
// 221:     end
// 222:
// 223:     it "returns an instance of the Cask from a relative file location" do
// 224:       c = Cask::CaskLoader.load(relative_tap_path/"Casks/local-caffeine.rb")
// 225:       expect(c).to be_a(described_class)
// 226:       expect(c.token).to eq("local-caffeine")
// 227:     end
// 228:
// 229:     it "uses exact match when loading by token" do
// 230:       expect(Cask::CaskLoader.load("test-opera").token).to eq("test-opera")
// 231:       expect(Cask::CaskLoader.load("test-opera-mail").token).to eq("test-opera-mail")
// 232:     end
// 233:
// 234:     it "raises an error when attempting to load a Cask that doesn't exist" do
// 235:       expect do
// 236:         Cask::CaskLoader.load("notacask")
// 237:       end.to raise_error(Cask::CaskUnavailableError)
// 238:     end
// 239:   end
// 240:
// 241:   describe "metadata" do
// 242:     it "proposes a versioned metadata directory name for each instance" do
// 243:       cask_token = "local-caffeine"
// 244:       c = Cask::CaskLoader.load(cask_token)
// 245:       metadata_timestamped_path = Cask::Caskroom.path.join(cask_token, ".metadata", c.version)
// 246:       expect(c.metadata_versioned_path.to_s).to eq(metadata_timestamped_path.to_s)
// 247:     end
// 248:   end
// 249:
// 250:   describe "outdated" do
// 251:     it "ignores the Casks that have auto_updates true (without --greedy)" do
// 252:       c = Cask::CaskLoader.load("auto-updates")
// 253:       expect(c).not_to be_outdated
// 254:       expect(c.outdated_version).to be_nil
// 255:     end
// 256:
// 257:     it "ignores the Casks that have version :latest (without --greedy)" do
// 258:       c = Cask::CaskLoader.load("version-latest-string")
// 259:       expect(c).not_to be_outdated
// 260:       expect(c.outdated_version).to be_nil
// 261:     end
// 262:
// 263:     describe "versioned casks" do
// 264:       subject { cask.outdated_version }
// 265:
// 266:       let(:cask) { described_class.new("basic-cask") }
// 267:
// 268:       shared_examples "versioned casks" do |tap_version, expectations|
// 269:         test_each(expectations) do |(installed_version, expected_output)|
// 270:           context "when version #{installed_version.inspect} is installed and the tap version is #{tap_version}" do
// 271:             it {
// 272:               allow(cask).to receive_messages(installed_version:,
// 273:                                               version:           Cask::DSL::Version.new(tap_version))
// 274:               expect(cask).to receive(:outdated_version).and_call_original
// 275:               expect(subject).to eq expected_output
// 276:             }
// 277:           end
// 278:         end
// 279:       end
// 280:
// 281:       describe "installed version is equal to tap version => not outdated" do
// 282:         include_examples "versioned casks", "1.2.3",
// 283:                          "1.2.3" => nil
// 284:       end
// 285:
// 286:       describe "installed version is different than tap version => outdated" do
// 287:         include_examples "versioned casks", "1.2.4",
// 288:                          "1.2.3" => "1.2.3",
// 289:                          "1.2.4" => nil
// 290:       end
// 291:     end
// 292:
// 293:     describe "auto-updating versioned casks with bundle metadata" do
// 294:       let(:dir) { Pathname(mktmpdir) }
// 295:       let(:cask_file) { dir/"auto-updates-bundle-check.rb" }
// 296:       let(:artifacts) { ['app "MyFancyApp.app"'] }
// 297:
// 298:       before do
// 299:         allow(Homebrew::EnvConfig).to receive(:upgrade_auto_updates_casks?).and_return(true)
// 300:       end
// 301:
// 302:       it "is outdated when the installed short version is lower than the tap version" do
// 303:         tap_version = "2.61"
// 304:         cask = write_auto_updates_cask(cask_file, version: tap_version, artifacts:)
// 305:         allow(cask).to receive(:installed_version).and_return("2.57")
// 306:         write_info_plist(cask.config.appdir/"MyFancyApp.app", short_version: "2.57", bundle_version: "2057")
// 307:
// 308:         expect(cask.outdated_version).to eq("2.57")
// 309:       end
// 310:
// 311:       it "is not outdated when auto-update upgrades are disabled" do
// 312:         allow(Homebrew::EnvConfig).to receive(:upgrade_auto_updates_casks?).and_return(false)
// 313:         tap_version = "2.61"
// 314:         cask = write_auto_updates_cask(cask_file, version: tap_version, artifacts:)
// 315:         allow(cask).to receive(:installed_version).and_return("2.57")
// 316:         write_info_plist(cask.config.appdir/"MyFancyApp.app", short_version: "2.57", bundle_version: "2057")
// 317:
// 318:         expect(cask.outdated_version).to be_nil
// 319:       end
// 320:
// 321:       it "is not outdated when the short version matches and the bundle version is lower than a CSV candidate" do
// 322:         tap_version = "2.61,3000"
// 323:         cask = write_auto_updates_cask(cask_file, version: tap_version, artifacts:)
// 324:         allow(cask).to receive(:installed_version).and_return("2.57")
// 325:         write_info_plist(cask.config.appdir/"MyFancyApp.app", short_version: "2.61", bundle_version: "2057")
// 326:
// 327:         expect(cask.outdated_version).to be_nil
// 328:       end
// 329:
// 330:       it "is not outdated when the short version matches and the bundle version matches any CSV candidate" do
// 331:         tap_version = "2.61,3000,2057"
// 332:         cask = write_auto_updates_cask(cask_file, version: tap_version, artifacts:)
// 333:         allow(cask).to receive(:installed_version).and_return("2.57")
// 334:         write_info_plist(cask.config.appdir/"MyFancyApp.app", short_version: "2.61", bundle_version: "2057")
// 335:
// 336:         expect(cask.outdated_version).to be_nil
// 337:       end
// 338:
// 339:       it "is not outdated when the installed short version is higher than the tap version" do
// 340:         tap_version = "2.61"
// 341:         cask = write_auto_updates_cask(cask_file, version: tap_version, artifacts:)
// 342:         allow(cask).to receive(:installed_version).and_return("2.57")
// 343:         write_info_plist(cask.config.appdir/"MyFancyApp.app", short_version: "2.62", bundle_version: "2057")
// 344:
// 345:         expect(cask.outdated_version).to be_nil
// 346:       end
// 347:
// 348:       it "is not outdated when the installed cask version already matches the tap version" do
// 349:         tap_version = "2.61"
// 350:         cask = write_auto_updates_cask(cask_file, version: tap_version, artifacts:)
// 351:         allow(cask).to receive(:installed_version).and_return("2.61")
// 352:         write_info_plist(cask.config.appdir/"MyFancyApp.app", short_version: "2.57", bundle_version: "2057")
// 353:
// 354:         expect(cask.outdated_version).to be_nil
// 355:       end
// 356:
// 357:       it "is not outdated when the installed short version directly matches the tap version" do
// 358:         tap_version = "2.61"
// 359:         cask = write_auto_updates_cask(cask_file, version: tap_version, artifacts:)
// 360:         allow(cask).to receive(:installed_version).and_return("2.57")
// 361:         write_info_plist(cask.config.appdir/"MyFancyApp.app", short_version: "2.61", bundle_version: "2057")
// 362:
// 363:         expect(cask.outdated_version).to be_nil
// 364:       end
// 365:
// 366:       it "is not outdated when the installed bundle version directly matches the tap version" do
// 367:         tap_version = "2057"
// 368:         cask = write_auto_updates_cask(cask_file, version: tap_version, artifacts:)
// 369:         allow(cask).to receive(:installed_version).and_return("2.57")
// 370:         write_info_plist(cask.config.appdir/"MyFancyApp.app", short_version: "2.61", bundle_version: "2057")
// 371:
// 372:         expect(cask.outdated_version).to be_nil
// 373:       end
// 374:
// 375:       it "is not outdated when the installed short and bundle versions combine to the tap version" do
// 376:         tap_version = "2.61-2057"
// 377:         cask = write_auto_updates_cask(cask_file, version: tap_version, artifacts:)
// 378:         allow(cask).to receive(:installed_version).and_return("2.57-2056")
// 379:         write_info_plist(cask.config.appdir/"MyFancyApp.app", short_version: "2.61", bundle_version: "2057")
// 380:
// 381:         expect(cask.outdated_version).to be_nil
// 382:       end
// 383:
// 384:       it "is not outdated when the combined installed version is higher than the tap version" do
// 385:         tap_version = "2.61-2057"
// 386:         cask = write_auto_updates_cask(cask_file, version: tap_version, artifacts:)
// 387:         allow(cask).to receive(:installed_version).and_return("2.57-2056")
// 388:         write_info_plist(cask.config.appdir/"MyFancyApp.app", short_version: "2.61", bundle_version: "2058")
// 389:
// 390:         expect(cask.outdated_version).to be_nil
// 391:       end
// 392:
// 393:       it "is not outdated when the installed short version matches a CSV build candidate" do
// 394:         tap_version = "2.61,2057"
// 395:         cask = write_auto_updates_cask(cask_file, version: tap_version, artifacts:)
// 396:         allow(cask).to receive(:installed_version).and_return("2.57")
// 397:         write_info_plist(cask.config.appdir/"MyFancyApp.app", short_version: "2057", bundle_version: "3000")
// 398:
// 399:         expect(cask.outdated_version).to be_nil
// 400:       end
// 401:
// 402:       it "is not outdated when the short version matches and the bundle version is higher than all CSV candidates" do
// 403:         tap_version = "2.61,2056,2055"
// 404:         cask = write_auto_updates_cask(cask_file, version: tap_version, artifacts:)
// 405:         allow(cask).to receive(:installed_version).and_return("2.57")
// 406:         write_info_plist(cask.config.appdir/"MyFancyApp.app", short_version: "2.61", bundle_version: "2057")
// 407:
// 408:         expect(cask.outdated_version).to be_nil
// 409:       end
// 410:
// 411:       it "matches a bundle version candidate that is not first in the CSV list" do
// 412:         tap_version = "2.61,3000,2057"
// 413:         cask = write_auto_updates_cask(cask_file, version: tap_version, artifacts:)
// 414:         allow(cask).to receive(:installed_version).and_return("2.57")
// 415:         write_info_plist(cask.config.appdir/"MyFancyApp.app", short_version: "2.61", bundle_version: "2057")
// 416:
// 417:         expect(cask.version.csv.first).not_to eq("2057")
// 418:         expect(cask.outdated_version).to be_nil
// 419:       end
// 420:
// 421:       it "is not outdated when the app bundle metadata cannot be read" do
// 422:         tap_version = "2.61"
// 423:         cask = write_auto_updates_cask(cask_file, version: tap_version, artifacts:)
// 424:         allow(cask).to receive(:installed_version).and_return("2.57")
// 425:
// 426:         expect(cask.outdated_version).to be_nil
// 427:       end
// 428:
// 429:       it "falls back to the bundle version when the short version is missing" do
// 430:         tap_version = "2.61,3000"
// 431:         cask = write_auto_updates_cask(cask_file, version: tap_version, artifacts:)
// 432:         allow(cask).to receive(:installed_version).and_return("2.57")
// 433:         write_info_plist(cask.config.appdir/"MyFancyApp.app", bundle_version: "2057")
// 434:
// 435:         expect(cask.outdated_version).to eq("2.57")
// 436:       end
// 437:
// 438:       it "ignores bad bundle versions when the short version is missing" do
// 439:         tap_version = "2026.406.0"
// 440:         cask = write_auto_updates_cask(cask_file, version: tap_version, artifacts:)
// 441:         allow(cask).to receive(:installed_version).and_return("2025.816.0")
// 442:         write_info_plist(cask.config.appdir/"MyFancyApp.app", bundle_version: "0.0")
// 443:
// 444:         expect(cask.outdated_version).to be_nil
// 445:       end
// 446:
// 447:       it "is not outdated when plist version segment counts differ from the tap version" do
// 448:         tap_version = "1.0"
// 449:         cask = write_auto_updates_cask(cask_file, version: tap_version, artifacts:)
// 450:         allow(cask).to receive(:installed_version).and_return("0.9")
// 451:         write_info_plist(cask.config.appdir/"MyFancyApp.app", short_version: "1", bundle_version: "200")
// 452:
// 453:         expect(cask.outdated_version).to be_nil
// 454:       end
// 455:     end
// 456:
// 457:     describe ":latest casks" do
// 458:       let(:cask) { described_class.new("basic-cask") }
// 459:
// 460:       shared_examples ":latest cask" do |greedy, outdated_sha, tap_version, expectations|
// 461:         test_each(expectations) do |(installed_version, expected_output)|
// 462:           context "when versions #{installed_version} are installed and the " \
// 463:                   "tap version is #{tap_version}, #{"not " unless greedy}greedy " \
// 464:                   "and sha is #{"not " unless outdated_sha}outdated" do
// 465:             subject { cask.outdated_version(greedy:) }
// 466:
// 467:             it {
// 468:               allow(cask).to receive_messages(installed_version:,
// 469:                                               version:                Cask::DSL::Version.new(tap_version),
// 470:                                               outdated_download_sha?: outdated_sha)
// 471:               expect(cask).to receive(:outdated_version).and_call_original
// 472:               expect(subject).to eq expected_output
// 473:             }
// 474:           end
// 475:         end
// 476:       end
// 477:
// 478:       describe ":latest version installed, :latest version in tap" do
// 479:         include_examples ":latest cask", false, false, "latest",
// 480:                          "latest" => nil
// 481:         include_examples ":latest cask", true, false, "latest",
// 482:                          "latest" => nil
// 483:         include_examples ":latest cask", true, true, "latest",
// 484:                          "latest" => "latest"
// 485:       end
// 486:
// 487:       describe "numbered version installed, :latest version in tap" do
// 488:         include_examples ":latest cask", false, false, "latest",
// 489:                          "1.2.3" => nil
// 490:         include_examples ":latest cask", true, false, "latest",
// 491:                          "1.2.3" => nil
// 492:         include_examples ":latest cask", true, true, "latest",
// 493:                          "1.2.3" => "1.2.3"
// 494:       end
// 495:
// 496:       describe "latest version installed, numbered version in tap" do
// 497:         include_examples ":latest cask", false, false, "1.2.3",
// 498:                          "latest" => "latest"
// 499:         include_examples ":latest cask", true, false, "1.2.3",
// 500:                          "latest" => "latest"
// 501:         include_examples ":latest cask", true, true, "1.2.3",
// 502:                          "latest" => "latest"
// 503:       end
// 504:     end
// 505:   end
// 506:
// 507:   describe "full_name" do
// 508:     context "when it is a core cask" do
// 509:       it "is the cask token" do
// 510:         c = Cask::CaskLoader.load("local-caffeine")
// 511:         expect(c.full_name).to eq("local-caffeine")
// 512:       end
// 513:     end
// 514:
// 515:     context "when it is from a non-core tap" do
// 516:       it "returns the fully-qualified name of the cask" do
// 517:         c = with_env(HOMEBREW_NO_REQUIRE_TAP_TRUST: "1") do
// 518:           Cask::CaskLoader.load("third-party/tap/third-party-cask")
// 519:         end
// 520:         expect(c.full_name).to eq("third-party/tap/third-party-cask")
// 521:       end
// 522:     end
// 523:
// 524:     context "when it is from no known tap" do
// 525:       it "returns the cask token" do
// 526:         file = Tempfile.new(%w[tapless-cask .rb])
// 527:
// 528:         begin
// 529:           cask_name = File.basename(file.path, ".rb")
// 530:           file.write "cask '#{cask_name}'"
// 531:           file.close
// 532:
// 533:           c = Cask::CaskLoader.load(file.path)
// 534:           expect(c.full_name).to eq(cask_name)
// 535:         ensure
// 536:           file.close
// 537:           file.unlink
// 538:         end
// 539:       end
// 540:     end
// 541:   end
// 542:
// 543:   describe "#artifacts_list" do
// 544:     subject(:cask) { Cask::CaskLoader.load("many-artifacts") }
// 545:
// 546:     it "returns all artifacts when no options are given" do
// 547:       expected_artifacts = [
// 548:         { uninstall_preflight: nil },
// 549:         { preflight: nil },
// 550:         { uninstall: [{
// 551:           rmdir: "#{TEST_TMPDIR}/empty_directory_path",
// 552:           trash: ["#{TEST_TMPDIR}/foo", "#{TEST_TMPDIR}/bar"],
// 553:         }] },
// 554:         { pkg: ["ManyArtifacts/ManyArtifacts.pkg"] },
// 555:         { app: ["ManyArtifacts/ManyArtifacts.app"], target: "#{TEST_TMPDIR}/cask-appdir/ManyArtifacts.app" },
// 556:         { uninstall_postflight: nil },
// 557:         { postflight: nil },
// 558:         { zap: [{
// 559:           rmdir: ["~/Library/Caches/ManyArtifacts", "~/Library/Application Support/ManyArtifacts"],
// 560:           trash: "~/Library/Logs/ManyArtifacts.log",
// 561:         }] },
// 562:       ]
// 563:
// 564:       expect(cask.artifacts_list).to eq(expected_artifacts)
// 565:     end
// 566:
// 567:     it "returns only uninstall artifacts when uninstall_only is true" do
// 568:       expected_artifacts = [
// 569:         { uninstall_preflight: nil },
// 570:         { uninstall: [{
// 571:           rmdir: "#{TEST_TMPDIR}/empty_directory_path",
// 572:           trash: ["#{TEST_TMPDIR}/foo", "#{TEST_TMPDIR}/bar"],
// 573:         }] },
// 574:         { app: ["ManyArtifacts/ManyArtifacts.app"] },
// 575:         { uninstall_postflight: nil },
// 576:         { zap: [{
// 577:           rmdir: ["~/Library/Caches/ManyArtifacts", "~/Library/Application Support/ManyArtifacts"],
// 578:           trash: "~/Library/Logs/ManyArtifacts.log",
// 579:         }] },
// 580:       ]
// 581:
// 582:       expect(cask.artifacts_list(uninstall_only: true)).to eq(expected_artifacts)
// 583:     end
// 584:   end
// 585:
// 586:   describe "#rename_list" do
// 587:     subject(:cask) { Cask::CaskLoader.load("many-renames") }
// 588:
// 589:     it "returns the correct rename list" do
// 590:       expect(cask.rename_list).to eq([
// 591:         { from: "Foobar.app", to: "Foo.app" },
// 592:         { from: "Foo.app", to: "Bar.app" },
// 593:       ])
// 594:     end
// 595:   end
// 596:
// 597:   describe "#uninstall_flight_blocks?" do
// 598:     matcher :have_uninstall_flight_blocks do
// 599:       match do |actual|
// 600:         actual.uninstall_flight_blocks? == true
// 601:       end
// 602:     end
// 603:
// 604:     it "returns true when there are uninstall_preflight blocks" do
// 605:       cask = Cask::CaskLoader.load("with-uninstall-preflight")
// 606:       expect(cask).to have_uninstall_flight_blocks
// 607:     end
// 608:
// 609:     it "returns true when there are uninstall_postflight blocks" do
// 610:       cask = Cask::CaskLoader.load("with-uninstall-postflight")
// 611:       expect(cask).to have_uninstall_flight_blocks
// 612:     end
// 613:
// 614:     it "returns false when there are only preflight blocks" do
// 615:       cask = Cask::CaskLoader.load("with-preflight")
// 616:       expect(cask).not_to have_uninstall_flight_blocks
// 617:     end
// 618:
// 619:     it "returns false when there are only postflight blocks" do
// 620:       cask = Cask::CaskLoader.load("with-postflight")
// 621:       expect(cask).not_to have_uninstall_flight_blocks
// 622:     end
// 623:
// 624:     it "returns false when there are no flight blocks" do
// 625:       cask = Cask::CaskLoader.load("local-caffeine")
// 626:       expect(cask).not_to have_uninstall_flight_blocks
// 627:     end
// 628:   end
// 629:
// 630:   describe "#supports_linux?" do
// 631:     it "uses explicit OS dependencies and defaults to Linux support" do
// 632:       expect(Cask::CaskLoader.load("with-depends-on-macos-bare").supports_linux?).to be false
// 633:       expect(Cask::CaskLoader.load("with-depends-on-maximum-macos").supports_linux?).to be false
// 634:       expect(Cask::CaskLoader.load("with-depends-on-macos-in-on-macos").supports_linux?).to be true
// 635:       expect(Cask::CaskLoader.load("with-depends-on-linux-bare").supports_linux?).to be true
// 636:
// 637:       expect(Cask::CaskLoader.load("with-non-executable-binary").supports_linux?).to be true
// 638:       expect(Cask::CaskLoader.load("basic-cask").supports_linux?).to be true
// 639:       expect(Cask::CaskLoader.load("with-installer-manual").supports_linux?).to be true
// 640:     end
// 641:   end
// 642:
// 643:   describe "#supports_macos?" do
// 644:     it "returns false for casks with bare depends_on :linux" do
// 645:       expect(Cask::CaskLoader.load("with-depends-on-linux-bare").supports_macos?).to be false
// 646:     end
// 647:   end
// 648:
// 649:   describe "#outdated_info" do
// 650:     it "includes pinned cask details" do
// 651:       cask = Cask::CaskLoader.load("local-caffeine")
// 652:       allow(cask).to receive_messages(outdated_version: "1.2.2", pinned?: true, pinned_version: "1.2.2")
// 653:
// 654:       expect(cask.outdated_info(false, true, false, false, false))
// 655:         .to eq("local-caffeine (1.2.2) != 1.2.3 [pinned at 1.2.2]")
// 656:       expect(cask.outdated_info(false, false, true, false, false)).to include(
// 657:         pinned:         true,
// 658:         pinned_version: "1.2.2",
// 659:       )
// 660:     end
// 661:   end
// 662:
// 663:   describe "#to_h" do
// 664:     let(:expected_json) do
// 665:       (TEST_FIXTURE_DIR/"cask/everything.json").read.strip.gsub("$APPDIR", "#{TEST_TMPDIR}/cask-appdir")
// 666:     end
// 667:
// 668:     context "when loaded from cask file" do
// 669:       it "returns expected hash" do
// 670:         allow(MacOS).to receive(:version).and_return(MacOSVersion.new("14"))
// 671:
// 672:         cask = Cask::CaskLoader.load("everything")
// 673:
// 674:         expect(cask.tap).to receive(:git_head).and_return("abcdef1234567890abcdef1234567890abcdef12")
// 675:
// 676:         hash = cask.to_h
// 677:
// 678:         expect(hash).to be_a(Hash)
// 679:         expect(JSON.pretty_generate(hash)).to eq(expected_json)
// 680:       end
// 681:     end
// 682:
// 683:     context "when loaded from json file" do
// 684:       it "returns expected hash" do
// 685:         expect(Homebrew::API::Cask).not_to receive(:source_download)
// 686:         hash = Cask::CaskLoader::FromAPILoader.new(
// 687:           "everything", from_json: JSON.parse(expected_json)
// 688:         ).load(config: nil).to_h
// 689:
// 690:         expect(hash).to be_a(Hash)
// 691:         expect(JSON.pretty_generate(hash)).to eq(expected_json)
// 692:       end
// 693:     end
// 694:   end
// 695:
// 696:   describe "#refresh_for_tag" do
// 697:     let(:cask) { Cask::CaskLoader.load("on-linux-asymmetric") }
// 698:
// 699:     it "yields with the cask refreshed for a supported tag" do
// 700:       tag = Utils::Bottles::Tag.new(system: :sonoma, arch: :intel)
// 701:       expect(cask.refresh_for_tag(tag) { cask.url.to_s }).to include("caffeine-intel-darwin")
// 702:     end
// 703:
// 704:     it "yields for a Linux architecture whose checksum is missing" do
// 705:       tag = Utils::Bottles::Tag.new(system: :linux, arch: :arm)
// 706:       expect(cask.refresh_for_tag(tag) { cask.url.to_s }).to include("caffeine-arm-linux")
// 707:     end
// 708:
// 709:     it "returns nil for a tag the cask cannot be refreshed for" do
// 710:       invalid_on_linux_cask = described_class.new("on-linux-invalid") do
// 711:         on_macos do
// 712:           version "1.2.3"
// 713:         end
// 714:         sha256 :no_check
// 715:         url "https://brew.sh/foo-#{version.major_minor}.zip"
// 716:       end
// 717:
// 718:       tag = Utils::Bottles::Tag.new(system: :linux, arch: :arm)
// 719:       expect(invalid_on_linux_cask.refresh_for_tag(tag) { invalid_on_linux_cask.url }).to be_nil
// 720:     end
// 721:   end
// 722:
// 723:   describe "#to_hash_with_variations" do
// 724:     let!(:original_macos_version) { MacOS.full_version.to_s }
// 725:     let(:expected_versions_variations) do
// 726:       <<~JSON
// 727:         {
// 728:           "golden_gate": {
// 729:             "url": "file://#{TEST_FIXTURE_DIR}/cask/caffeine/darwin/1.2.3/intel.zip"
// 730:           },
// 731:           "tahoe": {
// 732:             "url": "file://#{TEST_FIXTURE_DIR}/cask/caffeine/darwin/1.2.3/intel.zip"
// 733:           },
// 734:           "sequoia": {
// 735:             "url": "file://#{TEST_FIXTURE_DIR}/cask/caffeine/darwin/1.2.3/intel.zip"
// 736:           },
// 737:           "sonoma": {
// 738:             "url": "file://#{TEST_FIXTURE_DIR}/cask/caffeine/darwin/1.2.3/intel.zip"
// 739:           },
// 740:           "ventura": {
// 741:             "url": "file://#{TEST_FIXTURE_DIR}/cask/caffeine/darwin/1.2.3/intel.zip"
// 742:           },
// 743:           "monterey": {
// 744:             "url": "file://#{TEST_FIXTURE_DIR}/cask/caffeine/darwin/1.2.3/intel.zip"
// 745:           },
// 746:           "big_sur": {
// 747:             "url": "file://#{TEST_FIXTURE_DIR}/cask/caffeine/darwin/1.2.0/intel.zip",
// 748:             "version": "1.2.0",
// 749:             "sha256": "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 750:           },
// 751:           "arm64_big_sur": {
// 752:             "url": "file://#{TEST_FIXTURE_DIR}/cask/caffeine/darwin-arm64/1.2.0/arm.zip",
// 753:             "version": "1.2.0",
// 754:             "sha256": "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 755:           },
// 756:           "catalina": {
// 757:             "url": "file://#{TEST_FIXTURE_DIR}/cask/caffeine/darwin/1.0.0/intel.zip",
// 758:             "version": "1.0.0",
// 759:             "sha256": "1866dfa833b123bb8fe7fa7185ebf24d28d300d0643d75798bc23730af734216"
// 760:           },
// 761:           "x86_64_linux": {
// 762:             "url": "file://#{TEST_FIXTURE_DIR}/cask/caffeine/darwin//intel.zip",
// 763:             "version": null,
// 764:             "sha256": null
// 765:           },
// 766:           "arm64_linux": {
// 767:             "url": "file://#{TEST_FIXTURE_DIR}/cask/caffeine/darwin-arm64//arm.zip",
// 768:             "version": null,
// 769:             "sha256": null
// 770:           }
// 771:         }
// 772:       JSON
// 773:     end
// 774:     let(:expected_sha256_variations) do
// 775:       <<~JSON
// 776:         {
// 777:           "golden_gate": {
// 778:             "url": "file://#{TEST_FIXTURE_DIR}/cask/caffeine-intel.zip",
// 779:             "sha256": "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 780:           },
// 781:           "tahoe": {
// 782:             "url": "file://#{TEST_FIXTURE_DIR}/cask/caffeine-intel.zip",
// 783:             "sha256": "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 784:           },
// 785:           "sequoia": {
// 786:             "url": "file://#{TEST_FIXTURE_DIR}/cask/caffeine-intel.zip",
// 787:             "sha256": "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 788:           },
// 789:           "sonoma": {
// 790:             "url": "file://#{TEST_FIXTURE_DIR}/cask/caffeine-intel.zip",
// 791:             "sha256": "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 792:           },
// 793:           "ventura": {
// 794:             "url": "file://#{TEST_FIXTURE_DIR}/cask/caffeine-intel.zip",
// 795:             "sha256": "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 796:           },
// 797:           "monterey": {
// 798:             "url": "file://#{TEST_FIXTURE_DIR}/cask/caffeine-intel.zip",
// 799:             "sha256": "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 800:           },
// 801:           "big_sur": {
// 802:             "url": "file://#{TEST_FIXTURE_DIR}/cask/caffeine-intel.zip",
// 803:             "sha256": "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 804:           },
// 805:           "catalina": {
// 806:             "url": "file://#{TEST_FIXTURE_DIR}/cask/caffeine-intel.zip",
// 807:             "sha256": "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 808:           },
// 809:           "x86_64_linux": {
// 810:             "url": "file://#{TEST_FIXTURE_DIR}/cask/caffeine-intel.zip",
// 811:             "sha256": null
// 812:           },
// 813:           "arm64_linux": {
// 814:             "sha256": null
// 815:           }
// 816:         }
// 817:       JSON
// 818:     end
// 819:     let(:expected_sha256_variations_os) do
// 820:       <<~JSON
// 821:         {
// 822:           "golden_gate": {
// 823:             "url": "file://#{TEST_FIXTURE_DIR}/cask/caffeine-intel-darwin.zip",
// 824:             "sha256": "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 825:           },
// 826:           "tahoe": {
// 827:             "url": "file://#{TEST_FIXTURE_DIR}/cask/caffeine-intel-darwin.zip",
// 828:             "sha256": "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 829:           },
// 830:           "sequoia": {
// 831:             "url": "file://#{TEST_FIXTURE_DIR}/cask/caffeine-intel-darwin.zip",
// 832:             "sha256": "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 833:           },
// 834:           "sonoma": {
// 835:             "url": "file://#{TEST_FIXTURE_DIR}/cask/caffeine-intel-darwin.zip",
// 836:             "sha256": "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 837:           },
// 838:           "ventura": {
// 839:             "url": "file://#{TEST_FIXTURE_DIR}/cask/caffeine-intel-darwin.zip",
// 840:             "sha256": "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 841:           },
// 842:           "monterey": {
// 843:             "url": "file://#{TEST_FIXTURE_DIR}/cask/caffeine-intel-darwin.zip",
// 844:             "sha256": "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 845:           },
// 846:           "big_sur": {
// 847:             "url": "file://#{TEST_FIXTURE_DIR}/cask/caffeine-intel-darwin.zip",
// 848:             "sha256": "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 849:           },
// 850:           "catalina": {
// 851:             "url": "file://#{TEST_FIXTURE_DIR}/cask/caffeine-intel-darwin.zip",
// 852:             "sha256": "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 853:           },
// 854:           "x86_64_linux": {
// 855:             "url": "file://#{TEST_FIXTURE_DIR}/cask/caffeine-intel-linux.zip",
// 856:             "sha256": "8c62a2b791cf5f0da6066a0a4b6e85f62949cd60975da062df44adf887f4370b"
// 857:           },
// 858:           "arm64_linux": {
// 859:             "url": "file://#{TEST_FIXTURE_DIR}/cask/caffeine-arm-linux.zip"
// 860:           }
// 861:         }
// 862:       JSON
// 863:     end
// 864:
// 865:     before do
// 866:       # For consistency, always run on Monterey and ARM
// 867:       MacOS.full_version = "12"
// 868:       allow(Hardware::CPU).to receive(:type).and_return(:arm)
// 869:     end
// 870:
// 871:     after do
// 872:       MacOS.full_version = original_macos_version
// 873:     end
// 874:
// 875:     it "returns language variations with a deterministic default" do
// 876:       hash = JSON.parse(JSON.generate(Cask::CaskLoader.load("with-languages").to_hash_with_variations))
// 877:
// 878:       expect(hash.slice("url", "sha256", "language_variations")).to eq({
// 879:         "url"                 => "file://#{TEST_FIXTURE_DIR}/cask/caffeine.zip",
// 880:         "sha256"              => "67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94",
// 881:         "language_variations" => [
// 882:           {
// 883:             "languages" => ["zh"],
// 884:             "default"   => false,
// 885:             "value"     => "zh-CN",
// 886:             "url"       => "file://#{TEST_FIXTURE_DIR}/cask/container.tar.gz",
// 887:             "sha256"    => "fab685fabf73d5a9382581ce8698fce9408f5feaa49fa10d9bc6c510493300f5",
// 888:             "artifacts" => [{
// 889:               "app"    => ["Container.app"],
// 890:               "target" => "#{TEST_TMPDIR}/cask-appdir/Container.app",
// 891:             }],
// 892:           },
// 893:           { "languages" => ["en-US"], "default" => true, "value" => "en-US" },
// 894:         ],
// 895:       })
// 896:     end
// 897:
// 898:     it "preserves the cask configuration while generating language variations" do
// 899:       appdir = Pathname(TEST_TMPDIR)/"configured-appdir"
// 900:       config = Cask::Config.from_json({ default: { appdir:, languages: ["en-US"] } }.to_json)
// 901:       hash = Cask::CaskLoader.load("with-languages", config:).to_hash_with_variations
// 902:
// 903:       expect([
// 904:         hash.dig("artifacts", 0, :target),
// 905:         hash.dig("language_variations", 0, "artifacts", 0, :target),
// 906:       ]).to eq([appdir/"Caffeine.app", appdir/"Container.app"].map(&:to_s))
// 907:     end
// 908:
// 909:     it "returns the correct variations hash for a cask with multiple versions" do
// 910:       c = Cask::CaskLoader.load("multiple-versions")
// 911:       h = c.to_hash_with_variations
// 912:
// 913:       expect(h).to be_a(Hash)
// 914:       expect(JSON.pretty_generate(h["variations"])).to eq expected_versions_variations.strip
// 915:     end
// 916:
// 917:     it "returns the correct variations hash for a cask different sha256s on each arch" do
// 918:       c = Cask::CaskLoader.load("sha256-arch")
// 919:       h = c.to_hash_with_variations
// 920:
// 921:       expect(h).to be_a(Hash)
// 922:       expect(JSON.pretty_generate(h["variations"])).to eq expected_sha256_variations.strip
// 923:     end
// 924:
// 925:     it "returns the correct variations hash for a cask different sha256s on each arch and os" do
// 926:       c = Cask::CaskLoader.load("sha256-os")
// 927:       h = c.to_hash_with_variations
// 928:
// 929:       expect(h).to be_a(Hash)
// 930:       expect(JSON.pretty_generate(h["variations"])).to eq expected_sha256_variations_os.strip
// 931:     end
// 932:
// 933:     it "emits variations without checksums for Linux architectures a cask omits" do
// 934:       c = Cask::CaskLoader.load("on-linux-asymmetric")
// 935:       h = JSON.parse(JSON.generate(c.to_hash_with_variations))
// 936:
// 937:       expect(h["variations"]["arm64_linux"]).to include(
// 938:         "depends_on" => { "arch" => [{ "type" => "intel", "bits" => 64 }] },
// 939:         "sha256"     => nil,
// 940:       )
// 941:     end
// 942:
// 943:     it "emits Linux variations for a cask with Linux checksums but no `os` stanza" do
// 944:       c = Cask::CaskLoader.load("sha256-linux")
// 945:       h = c.to_hash_with_variations
// 946:
// 947:       expect(h["variations"]).to include(:x86_64_linux, :arm64_linux)
// 948:     end
// 949:
// 950:     it "emits Linux variations with checksums for a Linux-only cask" do
// 951:       c = Cask::CaskLoader.load("sha256-linux-only")
// 952:       h = c.to_hash_with_variations
// 953:
// 954:       expect(h["variations"].slice(:x86_64_linux, :arm64_linux).transform_values { |v| v["sha256"].to_s }).to eq(
// 955:         x86_64_linux: "244d413861cecb3707cfbcc5c4346d5367daa827da5ea08fb3f3bc2b6276d239",
// 956:         arm64_linux:  "9a1c0967baa46828930ccbbc88668d1b0db07e6edf778800ed4da073c00054f8",
// 957:       )
// 958:     end
// 959:
// 960:     it "emits Linux variations for a cask with `on_linux` content but no `os` stanza" do
// 961:       c = Cask::CaskLoader.load("on-linux-blocks")
// 962:       h = JSON.parse(JSON.generate(c.to_hash_with_variations))
// 963:
// 964:       app_image_artifacts = [{
// 965:         "app_image" => ["Caffeine.AppImage"],
// 966:         "target"    => "#{TEST_TMPDIR}/cask-appimagedir/Caffeine.AppImage",
// 967:       }]
// 968:       expect(h["variations"].slice("x86_64_linux", "arm64_linux").transform_values do |v|
// 969:         v.slice("sha256", "artifacts")
// 970:       end).to eq(
// 971:         "x86_64_linux" => {
// 972:           "sha256"    => "244d413861cecb3707cfbcc5c4346d5367daa827da5ea08fb3f3bc2b6276d239",
// 973:           "artifacts" => app_image_artifacts,
// 974:         },
// 975:         "arm64_linux"  => {
// 976:           "sha256"    => "9a1c0967baa46828930ccbbc88668d1b0db07e6edf778800ed4da073c00054f8",
// 977:           "artifacts" => app_image_artifacts,
// 978:         },
// 979:       )
// 980:     end
// 981:
// 982:     context "when recording supported platforms" do
// 983:       let(:platform_tags) do
// 984:         [
// 985:           Utils::Bottles::Tag.new(system: :sonoma, arch: :intel),
// 986:           Utils::Bottles::Tag.new(system: :sonoma, arch: :arm),
// 987:           Utils::Bottles::Tag.new(system: :monterey, arch: :intel),
// 988:           Utils::Bottles::Tag.new(system: :monterey, arch: :arm),
// 989:           Utils::Bottles::Tag.new(system: :catalina, arch: :intel),
// 990:           Utils::Bottles::Tag.new(system: :linux, arch: :intel),
// 991:           Utils::Bottles::Tag.new(system: :linux, arch: :arm),
// 992:         ]
// 993:       end
// 994:       let(:macos_platforms) { [:sonoma, :arm64_sonoma, :monterey, :arm64_monterey, :catalina] }
// 995:
// 996:       before do
// 997:         stub_const("OnSystem::VALID_OS_ARCH_TAGS", platform_tags)
// 998:       end
// 999:
// 1000:       it "records platforms allowed by scoped macOS requirements" do
// 1001:         c = Cask::CaskLoader.load("with-depends-on-macos-in-on-macos")
// 1002:
// 1003:         expect(c.to_hash_with_variations["supported_platforms"]).to eq(
// 1004:           [:sonoma, :arm64_sonoma, :monterey, :arm64_monterey, :x86_64_linux, :arm64_linux],
// 1005:         )
// 1006:       end
// 1007:
// 1008:       it "excludes platforms without complete download data" do
// 1009:         c = Cask::CaskLoader.load("multiple-versions")
// 1010:
// 1011:         expect(c.to_hash_with_variations["supported_platforms"]).to eq(macos_platforms)
// 1012:       end
// 1013:
// 1014:       it "excludes platforms rejected by architecture requirements" do
// 1015:         c = described_class.new("architecture-restricted") do
// 1016:           version :latest
// 1017:           arch arm: "arm64", intel: "x86_64"
// 1018:           sha256 :no_check
// 1019:           url "https://brew.sh/#{arch}.zip"
// 1020:           on_linux do
// 1021:             depends_on arch: :x86_64
// 1022:           end
// 1023:           binary "foo"
// 1024:         end
// 1025:
// 1026:         expect(c.to_hash_with_variations["supported_platforms"]).to eq(
// 1027:           [*macos_platforms, :x86_64_linux],
// 1028:         )
// 1029:       end
// 1030:
// 1031:       it "does not infer macOS support from artifact types" do
// 1032:         c = described_class.new("macos-artifact") do
// 1033:           version :latest
// 1034:           arch arm: "arm64", intel: "x86_64"
// 1035:           sha256 :no_check
// 1036:           url "https://brew.sh/#{arch}.zip"
// 1037:           app "Foo.app"
// 1038:         end
// 1039:
// 1040:         expect(c.to_hash_with_variations["supported_platforms"]).to eq(platform_tags.map(&:to_sym))
// 1041:       end
// 1042:
// 1043:       it "does not infer macOS support from manual installers" do
// 1044:         c = described_class.new("manual-installer") do
// 1045:           version :latest
// 1046:           arch arm: "arm64", intel: "x86_64"
// 1047:           sha256 :no_check
// 1048:           url "https://brew.sh/#{arch}.zip"
// 1049:           installer manual: "Foo.app"
// 1050:         end
// 1051:
// 1052:         expect(c.to_hash_with_variations["supported_platforms"]).to eq(platform_tags.map(&:to_sym))
// 1053:       end
// 1054:
// 1055:       it "does not infer Linux support from artifact types" do
// 1056:         c = described_class.new("linux-artifact") do
// 1057:           version :latest
// 1058:           arch arm: "arm64", intel: "x86_64"
// 1059:           sha256 :no_check
// 1060:           url "https://brew.sh/#{arch}.zip"
// 1061:           app_image "Foo.AppImage"
// 1062:         end
// 1063:
// 1064:         expect(c.to_hash_with_variations["supported_platforms"]).to eq(platform_tags.map(&:to_sym))
// 1065:       end
// 1066:
// 1067:       it "excludes Linux for casks with a bare macOS dependency" do
// 1068:         c = described_class.new("macos-only") do
// 1069:           version :latest
// 1070:           sha256 :no_check
// 1071:           url "https://brew.sh/foo.zip"
// 1072:           depends_on :macos
// 1073:           app "Foo.app"
// 1074:         end
// 1075:
// 1076:         expect(c.to_hash_with_variations["supported_platforms"]).to eq(macos_platforms)
// 1077:       end
// 1078:
// 1079:       it "excludes macOS for casks with a bare Linux dependency" do
// 1080:         c = described_class.new("linux-only") do
// 1081:           version :latest
// 1082:           sha256 :no_check
// 1083:           url "https://brew.sh/foo.zip"
// 1084:           depends_on :linux
// 1085:           app_image "Foo.AppImage"
// 1086:         end
// 1087:
// 1088:         expect(c.to_hash_with_variations["supported_platforms"]).to eq([:x86_64_linux, :arm64_linux])
// 1089:       end
// 1090:
// 1091:       it "includes stage-only casks" do
// 1092:         c = described_class.new("stage-only") do
// 1093:           version :latest
// 1094:           arch arm: "arm64", intel: "x86_64"
// 1095:           sha256 :no_check
// 1096:           url "https://brew.sh/#{arch}.zip"
// 1097:           stage_only true
// 1098:         end
// 1099:
// 1100:         expect(c.to_hash_with_variations["supported_platforms"]).to eq(platform_tags.map(&:to_sym))
// 1101:       end
// 1102:
// 1103:       it "records no supported platforms for a cask without an installable artifact" do
// 1104:         c = described_class.new("zap-only") do
// 1105:           version :latest
// 1106:           arch arm: "arm64", intel: "x86_64"
// 1107:           sha256 :no_check
// 1108:           url "https://brew.sh/#{arch}.zip"
// 1109:           zap trash: "~/Library/Caches/brew-test"
// 1110:         end
// 1111:
// 1112:         expect(c.to_hash_with_variations["supported_platforms"]).to eq([])
// 1113:       end
// 1114:
// 1115:       it "records every platform when a cask has no platform variations" do
// 1116:         c = described_class.new("no-platform-variations") do
// 1117:           version :latest
// 1118:           sha256 :no_check
// 1119:           url "https://brew.sh/foo.zip"
// 1120:           binary "foo"
// 1121:         end
// 1122:
// 1123:         expect(c.to_hash_with_variations["supported_platforms"]).to eq(platform_tags.map(&:to_sym))
// 1124:       end
// 1125:
// 1126:       it "records top-level platform requirements without variations" do
// 1127:         c = described_class.new("top-level-platform-requirements") do
// 1128:           version :latest
// 1129:           sha256 :no_check
// 1130:           url "https://brew.sh/foo.zip"
// 1131:           depends_on macos: :monterey
// 1132:           depends_on arch: :x86_64
// 1133:           binary "foo"
// 1134:         end
// 1135:
// 1136:         expect(c.to_hash_with_variations["supported_platforms"]).to eq([:sonoma, :monterey])
// 1137:       end
// 1138:
// 1139:       it "serializes architecture-varying and universal casks with the same macOS requirement" do
// 1140:         tags = OnSystem::ALL_OS_ARCH_COMBINATIONS.filter_map do |os, arch|
// 1141:           tag = Utils::Bottles::Tag.new(system: os, arch:)
// 1142:           tag if tag.valid_combination?
// 1143:         end
// 1144:         stub_const("OnSystem::VALID_OS_ARCH_TAGS", tags)
// 1145:
// 1146:         architecture_varying = described_class.new("architecture-varying") do
// 1147:           arch arm: "ARM64", intel: "64"
// 1148:           version "1.2.3"
// 1149:           sha256 arm:   "a" * 64,
// 1150:                  intel: "b" * 64
// 1151:           url "https://brew.sh/#{arch}.zip"
// 1152:           depends_on macos: :big_sur
// 1153:           app "Foo.app"
// 1154:         end
// 1155:         universal = described_class.new("universal") do
// 1156:           version :latest
// 1157:           sha256 :no_check
// 1158:           url "https://brew.sh/foo.zip"
// 1159:           depends_on macos: :big_sur
// 1160:           app "Foo.app"
// 1161:         end
// 1162:
// 1163:         architecture_varying.to_hash_with_variations
// 1164:         supported_platforms = Timeout.timeout(5) do
// 1165:           universal.to_hash_with_variations["supported_platforms"]
// 1166:         end
// 1167:
// 1168:         expected_platforms = tags.filter_map do |tag|
// 1169:           tag.to_sym if tag.macos? && tag.system != :catalina
// 1170:         end
// 1171:         expect(supported_platforms).to eq(expected_platforms)
// 1172:       end
// 1173:
// 1174:       it "isolates macOS requirement comparisons between casks" do
// 1175:         supported_platforms = [:monterey, :sonoma].map do |minimum_macos|
// 1176:           c = described_class.new("requires-#{minimum_macos}") do
// 1177:             version :latest
// 1178:             sha256 :no_check
// 1179:             url "https://brew.sh/foo.zip"
// 1180:             depends_on macos: minimum_macos
// 1181:             binary "foo"
// 1182:           end
// 1183:
// 1184:           c.to_hash_with_variations["supported_platforms"]
// 1185:         end
// 1186:
// 1187:         expect(supported_platforms).to eq(
// 1188:           [
// 1189:             [:sonoma, :arm64_sonoma, :monterey, :arm64_monterey],
// 1190:             [:sonoma, :arm64_sonoma],
// 1191:           ],
// 1192:         )
// 1193:       end
// 1194:     end
// 1195:
// 1196:     # NOTE: The calls to `Cask.generating_hash!` and `Cask.generated_hash!`
// 1197:     #       are not idempotent so they can only be used in one test.
// 1198:     it "returns the correct hash placeholders" do
// 1199:       described_class.generating_hash!
// 1200:       expect(described_class).to be_generating_hash
// 1201:       c = Cask::CaskLoader.load("placeholders")
// 1202:       h = c.to_hash_with_variations
// 1203:       described_class.generated_hash!
// 1204:       expect(described_class).not_to be_generating_hash
// 1205:
// 1206:       expect(h).to be_a(Hash)
// 1207:       expect(h["artifacts"].first[:binary].first).to eq "$APPDIR/some/path"
// 1208:       expect(h["caveats"]).to eq "$HOMEBREW_PREFIX and /$HOME\n"
// 1209:     end
// 1210:
// 1211:     context "when loaded from json file" do
// 1212:       let(:expected_json) do
// 1213:         (TEST_FIXTURE_DIR/"cask/everything-with-variations.json").read.strip
// 1214:           .gsub("$APPDIR", "#{TEST_TMPDIR}/cask-appdir")
// 1215:       end
// 1216:
// 1217:       it "returns expected hash with variations" do
// 1218:         expect(Homebrew::API::Cask).not_to receive(:source_download)
// 1219:         cask = Cask::CaskLoader::FromAPILoader.new("everything-with-variations", from_json: JSON.parse(expected_json))
// 1220:                                               .load(config: nil)
// 1221:
// 1222:         hash = cask.to_hash_with_variations
// 1223:
// 1224:         expect(cask.loaded_from_api?).to be true
// 1225:         expect(cask.loaded_from_internal_api?).to be false
// 1226:         expect(hash).to be_a(Hash)
// 1227:         expect(JSON.pretty_generate(hash)).to eq(expected_json)
// 1228:       end
// 1229:     end
// 1230:
// 1231:     it "does not include macOS dependency in Linux variations" do
// 1232:       c = Cask::CaskLoader.load("sha256-os")
// 1233:       h = c.to_hash_with_variations
// 1234:
// 1235:       [:x86_64_linux, :arm64_linux].each do |tag|
// 1236:         merged = Homebrew::API.merge_variations(h.deep_dup, bottle_tag: Utils::Bottles::Tag.from_symbol(tag))
// 1237:         expect(merged["depends_on"]).not_to include("macos") if merged["depends_on"].present?
// 1238:       end
// 1239:     end
// 1240:   end
// 1241: end
