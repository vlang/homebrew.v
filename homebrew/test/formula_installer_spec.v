module test

import brew_runtime

// Translated from Homebrew/brew `test/formula_installer_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby matcher `matcher :be_poured_from_bottle do` at line 17.
pub fn ruby_formula_installer_spec_l17_d1_be_poured_from_bottle(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('be_poured_from_bottle', ...args)
}

// Ruby method `temporary_install(formula, **options)` at line 21.
pub fn ruby_formula_installer_spec_l21_d2_temporary_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('temporary_install', ...args)
}

// Ruby specify `specify "basic installation" do` at line 53.
pub fn ruby_formula_installer_spec_l53_d3_basic(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('basic', ...args)
}

// Ruby specify `specify "offline installation" do` at line 79.
pub fn ruby_formula_installer_spec_l79_d4_offline(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('offline', ...args)
}

// Ruby specify `specify "Formula is not poured from bottle when compiler specified" do` at line 83.
pub fn ruby_formula_installer_spec_l83_d5_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('Formula', ...args)
}

// Ruby specify `specify "relocated bottle install does not require developer tools on Apple Silicon", :needs_macos do` at line 90.
pub fn ruby_formula_installer_spec_l90_d6_relocated(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('relocated', ...args)
}

// Ruby it `it "runs structured post-install work through the post-install subprocess" do` at line 106.
pub fn ruby_formula_installer_spec_l106_d7_runs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('runs', ...args)
}

// Ruby it `it "runs structured post-install steps inside the formula sandbox" do` at line 149.
pub fn ruby_formula_installer_spec_l149_d8_runs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('runs', ...args)
}

// Ruby it `it "restores bin/brew after a Landlock-sandboxed post-install replaces it" do` at line 173.
pub fn ruby_formula_installer_spec_l173_d9_restores(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('restores', ...args)
}

// Ruby it `it "uses the API formula for structured-only post-installs" do` at line 209.
pub fn ruby_formula_installer_spec_l209_d10_uses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uses', ...args)
}

// Ruby it `it "uses the keg formula for API post-installs with Ruby hooks" do` at line 222.
pub fn ruby_formula_installer_spec_l222_d11_uses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uses', ...args)
}

// Ruby let `let(:f) do` at line 238.
pub fn ruby_formula_installer_spec_l238_d12_f(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('f', ...args)
}

// Ruby let `let(:installer) { Class.new(described_class).new(f) }` at line 249.
pub fn ruby_formula_installer_spec_l249_d13_installer(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installer', ...args)
}

// Ruby let `let(:downloader) { instance_double(AbstractDownloadStrategy, basename: "missing-bottle-tab", stage: nil) }` at line 250.
pub fn ruby_formula_installer_spec_l250_d14_downloader(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('downloader', ...args)
}

// Ruby let `let(:downloadable) { instance_double(Resource, downloader:) }` at line 251.
pub fn ruby_formula_installer_spec_l251_d15_downloadable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('downloadable', ...args)
}

// Ruby let `let(:tab) do` at line 252.
pub fn ruby_formula_installer_spec_l252_d16_tab(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tab', ...args)
}

// Ruby let `let(:keg) { instance_double(Keg) }` at line 255.
pub fn ruby_formula_installer_spec_l255_d17_keg(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('keg', ...args)
}

// Ruby it `it "preserves the skip-linkage decision for the default bottle domain" do` at line 266.
pub fn ruby_formula_installer_spec_l266_d18_preserves(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('preserves', ...args)
}

// Ruby it `it "relocates dynamic linkage without metadata from a bottle mirror" do` at line 272.
pub fn ruby_formula_installer_spec_l272_d19_relocates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('relocates', ...args)
}

// Ruby it `it "explains how a bottle mirror can provide metadata once per invocation" do` at line 280.
pub fn ruby_formula_installer_spec_l280_d20_explains(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('explains', ...args)
}

// Ruby let `let(:f) do` at line 292.
pub fn ruby_formula_installer_spec_l292_d21_f(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('f', ...args)
}

// Ruby let `let(:config_file) { HOMEBREW_PREFIX/"etc/bottle-config.conf" }` at line 298.
pub fn ruby_formula_installer_spec_l298_d22_config_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('config_file', ...args)
}

// Ruby it `it "stores new prefix config where install_etc_var restores it from" do` at line 312.
pub fn ruby_formula_installer_spec_l312_d23_stores(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stores', ...args)
}

// Ruby it `it "does not install an untapped dependency tap" do` at line 325.
pub fn ruby_formula_installer_spec_l325_d24_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "does not enqueue cached bottle manifests" do` at line 342.
pub fn ruby_formula_installer_spec_l342_d25_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "enqueues invalid cached bottle manifests" do` at line 368.
pub fn ruby_formula_installer_spec_l368_d26_enqueues(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('enqueues', ...args)
}

// Ruby let `let(:formula) { TestballBottle.new }` at line 401.
pub fn ruby_formula_installer_spec_l401_d27_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula', ...args)
}

// Ruby let `let(:installer) { described_class.new(formula) }` at line 402.
pub fn ruby_formula_installer_spec_l402_d28_installer(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installer', ...args)
}

// Ruby let `let(:download_queue) { instance_double(Homebrew::DownloadQueue) }` at line 403.
pub fn ruby_formula_installer_spec_l403_d29_download_queue(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('download_queue', ...args)
}

// Ruby let `let(:bottle) { instance_double(Bottle, cached_download: HOMEBREW_CACHE/"downloads/testball-bottle") }` at line 404.
pub fn ruby_formula_installer_spec_l404_d30_bottle(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('bottle', ...args)
}

// Ruby it `it "starts a bottle download before enqueueing dependencies after the prelude" do` at line 416.
pub fn ruby_formula_installer_spec_l416_d31_starts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('starts', ...args)
}

// Ruby it `it "resolves dependencies before enqueueing a bottle without the prelude" do` at line 428.
pub fn ruby_formula_installer_spec_l428_d32_resolves(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('resolves', ...args)
}

// Ruby it `it "does not requeue a bottle already enqueued by the prelude fetch" do` at line 437.
pub fn ruby_formula_installer_spec_l437_d33_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "links non-keg-only formulae when link_keg is false" do` at line 450.
pub fn ruby_formula_installer_spec_l450_d34_links(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('links', ...args)
}

// Ruby it `it "links non-keg-only dependencies even when they were not previously linked" do` at line 459.
pub fn ruby_formula_installer_spec_l459_d35_links(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('links', ...args)
}

// Ruby it `it "reports an outdated dependency as upgrading" do` at line 497.
pub fn ruby_formula_installer_spec_l497_d36_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby let `let(:test_formula) do` at line 528.
pub fn ruby_formula_installer_spec_l528_d37_test_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('test_formula', ...args)
}

// Ruby let `let(:conflicting_formula) do` at line 536.
pub fn ruby_formula_installer_spec_l536_d38_conflicting_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('conflicting_formula', ...args)
}

// Ruby it `it "does not raise an error" do` at line 553.
pub fn ruby_formula_installer_spec_l553_d39_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "raises an error if linking keg" do` at line 565.
pub fn ruby_formula_installer_spec_l565_d40_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "does not raise an error with force set" do` at line 570.
pub fn ruby_formula_installer_spec_l570_d41_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "does not raise an error with skip_link set" do` at line 575.
pub fn ruby_formula_installer_spec_l575_d42_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "does not raise an error if not linking keg" do` at line 580.
pub fn ruby_formula_installer_spec_l580_d43_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "ignores conflicts that name the formula being installed" do` at line 587.
pub fn ruby_formula_installer_spec_l587_d44_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ignores', ...args)
}

// Ruby it `it "marks only outdated dependencies as upgradable in the header" do` at line 603.
pub fn ruby_formula_installer_spec_l603_d45_marks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('marks', ...args)
}

// Ruby it `it "does not render the first dependency name bolder than the rest" do` at line 627.
pub fn ruby_formula_installer_spec_l627_d46_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "shows the formula header after installing a single dependency" do` at line 650.
pub fn ruby_formula_installer_spec_l650_d47_shows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('shows', ...args)
}

// Ruby it `it "checks equal dependency satisfaction once per expansion" do` at line 666.
pub fn ruby_formula_installer_spec_l666_d48_checks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('checks', ...args)
}

// Ruby it `it "checks uses_from_macos dependencies with different bounds separately" do` at line 700.
pub fn ruby_formula_installer_spec_l700_d49_checks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('checks', ...args)
}

// Ruby let `let(:base_name) { "homebrew-versioned-formula" }` at line 736.
pub fn ruby_formula_installer_spec_l736_d50_base_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('base_name', ...args)
}

// Ruby let `let(:formula_name) { "#{base_name}@1.0" }` at line 737.
pub fn ruby_formula_installer_spec_l737_d51_formula_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_name', ...args)
}

// Ruby let `let(:keg_only_formula) do` at line 738.
pub fn ruby_formula_installer_spec_l738_d52_keg_only_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('keg_only_formula', ...args)
}

// Ruby it `it "does not link by default when it is not installed on request" do` at line 751.
pub fn ruby_formula_installer_spec_l751_d53_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "links by default when no sibling variants are installed" do` at line 757.
pub fn ruby_formula_installer_spec_l757_d54_links(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('links', ...args)
}

// Ruby it `it "does not link by default when any version is already installed" do` at line 763.
pub fn ruby_formula_installer_spec_l763_d55_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "links when explicitly requested" do` at line 771.
pub fn ruby_formula_installer_spec_l771_d56_links(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('links', ...args)
}

// Ruby it `it "does not link by default when another @-versioned formula is installed" do` at line 779.
pub fn ruby_formula_installer_spec_l779_d57_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "does not link by default when the unversioned sibling is installed" do` at line 793.
pub fn ruby_formula_installer_spec_l793_d58_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "does not link by default when the unversioned sibling is keg-only" do` at line 806.
pub fn ruby_formula_installer_spec_l806_d59_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "does not link by default when the -full variant is installed" do` at line 819.
pub fn ruby_formula_installer_spec_l819_d60_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "does not link by default when the non-full variant is installed" do` at line 833.
pub fn ruby_formula_installer_spec_l833_d61_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby let `let(:versioned_formula) do` at line 855.
pub fn ruby_formula_installer_spec_l855_d62_versioned_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('versioned_formula', ...args)
}

// Ruby let `let(:other_version) do` at line 862.
pub fn ruby_formula_installer_spec_l862_d63_other_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('other_version', ...args)
}

// Ruby let `let(:keg) do` at line 869.
pub fn ruby_formula_installer_spec_l869_d64_keg(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('keg', ...args)
}

// Ruby it `it "only optlinks when default linking is disabled by an installed sibling" do` at line 881.
pub fn ruby_formula_installer_spec_l881_d65_only(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('only', ...args)
}

// Ruby it `it "unlinks siblings before linking when explicitly requested" do` at line 892.
pub fn ruby_formula_installer_spec_l892_d66_unlinks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('unlinks', ...args)
}

// Ruby let `let(:base_name) { "homebrew-versioned-formula" }` at line 905.
pub fn ruby_formula_installer_spec_l905_d67_base_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('base_name', ...args)
}

// Ruby let `let(:formula_name) { "#{base_name}@1.0" }` at line 906.
pub fn ruby_formula_installer_spec_l906_d68_formula_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_name', ...args)
}

// Ruby let `let(:keg_only_formula) do` at line 907.
pub fn ruby_formula_installer_spec_l907_d69_keg_only_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('keg_only_formula', ...args)
}

// Ruby it `it "explains why a versioned formula was installed but not linked" do` at line 915.
pub fn ruby_formula_installer_spec_l915_d70_explains(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('explains', ...args)
}

// Ruby it `it "raises on direct cyclic dependency" do` at line 935.
pub fn ruby_formula_installer_spec_l935_d71_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "raises on indirect cyclic dependency" do` at line 956.
pub fn ruby_formula_installer_spec_l956_d72_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "raises on pinned dependency" do` at line 987.
pub fn ruby_formula_installer_spec_l987_d73_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "raises on forbidden license on formula" do` at line 1025.
pub fn ruby_formula_installer_spec_l1025_d74_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "raises on forbidden license on formula with contact instructions" do` at line 1046.
pub fn ruby_formula_installer_spec_l1046_d75_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "raises on forbidden license on dependency" do` at line 1069.
pub fn ruby_formula_installer_spec_l1069_d76_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "raises on forbidden symbol license on formula" do` at line 1100.
pub fn ruby_formula_installer_spec_l1100_d77_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby let `let(:homebrew_forbidden) { Tap.fetch("homebrew/forbidden") }` at line 1128.
pub fn ruby_formula_installer_spec_l1128_d78_homebrew_forbidden(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('homebrew_forbidden', ...args)
}

// Ruby let `let(:allowed_third_party) { Tap.fetch("nothomebrew/allowed") }` at line 1129.
pub fn ruby_formula_installer_spec_l1129_d79_allowed_third_party(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('allowed_third_party', ...args)
}

// Ruby let `let(:disallowed_third_party) { Tap.fetch("nothomebrew/notallowed") }` at line 1130.
pub fn ruby_formula_installer_spec_l1130_d80_disallowed_third_party(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('disallowed_third_party', ...args)
}

// Ruby let `let(:allowed_taps_set) { [allowed_third_party.name] }` at line 1131.
pub fn ruby_formula_installer_spec_l1131_d81_allowed_taps_set(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('allowed_taps_set', ...args)
}

// Ruby let `let(:forbidden_taps_set) { [homebrew_forbidden.name] }` at line 1132.
pub fn ruby_formula_installer_spec_l1132_d82_forbidden_taps_set(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('forbidden_taps_set', ...args)
}

// Ruby it `it "raises on forbidden tap on formula" do` at line 1134.
pub fn ruby_formula_installer_spec_l1134_d83_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "raises on not allowed third-party tap on formula" do` at line 1156.
pub fn ruby_formula_installer_spec_l1156_d84_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "does not raise on allowed tap on formula" do` at line 1178.
pub fn ruby_formula_installer_spec_l1178_d85_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "raises on forbidden tap on dependency" do` at line 1198.
pub fn ruby_formula_installer_spec_l1198_d86_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "raises on forbidden formula" do` at line 1232.
pub fn ruby_formula_installer_spec_l1232_d87_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "raises on forbidden dependency" do` at line 1250.
pub fn ruby_formula_installer_spec_l1250_d88_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby let `let(:deno_formula) do` at line 1281.
pub fn ruby_formula_installer_spec_l1281_d89_deno_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('deno_formula', ...args)
}

// Ruby let `let(:formula_struct) do` at line 1287.
pub fn ruby_formula_installer_spec_l1287_d90_formula_struct(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_struct', ...args)
}

// Ruby let `let(:installer) do` at line 1304.
pub fn ruby_formula_installer_spec_l1304_d91_installer(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installer', ...args)
}

// Ruby it `it "uses API bottle metadata to enqueue the manifest and bottle" do` at line 1320.
pub fn ruby_formula_installer_spec_l1320_d92_uses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uses', ...args)
}

// Ruby it `it "enqueues only the bottle manifest when fetching metadata" do` at line 1330.
pub fn ruby_formula_installer_spec_l1330_d93_enqueues(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('enqueues', ...args)
}

// Ruby it `it "enqueues the bottle without repeating metadata work after a metadata-only run" do` at line 1336.
pub fn ruby_formula_installer_spec_l1336_d94_enqueues(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('enqueues', ...args)
}

// Ruby it `it "does not repeat source download prelude work" do` at line 1348.
pub fn ruby_formula_installer_spec_l1348_d95_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "raises on forbidden formula tap before fetching the source from the API" do` at line 1365.
pub fn ruby_formula_installer_spec_l1365_d96_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "raises on forbidden formula before fetching the source from the API" do` at line 1389.
pub fn ruby_formula_installer_spec_l1389_d97_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby specify `specify "install fails with BuildError when a system() call fails" do` at line 1409.
pub fn ruby_formula_installer_spec_l1409_d98_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby specify `specify "install fails with a RuntimeError when` at line 1418.
pub fn ruby_formula_installer_spec_l1418_d99_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby subject `subject(:formula_installer) { described_class.new(Testball.new) }` at line 1427.
pub fn ruby_formula_installer_spec_l1427_d100_formula_installer(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_installer', ...args)
}

// Ruby it `it "shows audit problems if HOMEBREW_DEVELOPER is set" do` at line 1429.
pub fn ruby_formula_installer_spec_l1429_d101_shows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('shows', ...args)
}

// Ruby it `it "works if service is set" do` at line 1441.
pub fn ruby_formula_installer_spec_l1441_d102_works(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('works', ...args)
}

// Ruby it `it "works if timed service is set" do` at line 1467.
pub fn ruby_formula_installer_spec_l1467_d103_works(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('works', ...args)
}

// Ruby it `it "returns without definition" do` at line 1497.
pub fn ruby_formula_installer_spec_l1497_d104_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "attempts source download when formula is loaded from API" do` at line 1515.
pub fn ruby_formula_installer_spec_l1515_d105_attempts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('attempts', ...args)
}

// Ruby it `it "raises when formula is loaded from API and source download fails" do` at line 1540.
pub fn ruby_formula_installer_spec_l1540_d106_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "exposes local formula and trust paths to the sandbox" do` at line 1555.
pub fn ruby_formula_installer_spec_l1555_d107_exposes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('exposes', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "formula"
// 5: require "formula_installer"
// 6: require "keg"
// 7: require "sandbox"
// 8: require "tab"
// 9: require "trust"
// 10: require "cmd/install"
// 11: require "test/support/fixtures/testball"
// 12: require "test/support/fixtures/testball_bottle"
// 13: require "test/support/fixtures/failball"
// 14: require "test/support/fixtures/failball_offline_install"
// 15:
// 16: RSpec.describe FormulaInstaller do
// 17:   matcher :be_poured_from_bottle do
// 18:     match(&:poured_from_bottle)
// 19:   end
// 20:
// 21:   def temporary_install(formula, **options)
// 22:     expect(formula).not_to be_latest_version_installed
// 23:
// 24:     installer = FormulaInstaller.new(formula, **options)
// 25:
// 26:     with_env(HOMEBREW_NO_INSTALL_FROM_API: "1") do
// 27:       installer.fetch
// 28:       installer.install
// 29:     end
// 30:
// 31:     keg = Keg.new(formula.prefix)
// 32:
// 33:     expect(formula).to be_latest_version_installed
// 34:
// 35:     begin
// 36:       Tab.clear_cache
// 37:       expect(keg.tab).not_to be_poured_from_bottle
// 38:
// 39:       yield formula if block_given?
// 40:     ensure
// 41:       Tab.clear_cache
// 42:       keg.unlink
// 43:       keg.uninstall
// 44:       formula.clear_cache
// 45:       # there will be log files when sandbox is enable.
// 46:       FileUtils.rm_r(formula.logs) if formula.logs.directory?
// 47:     end
// 48:
// 49:     expect(keg).not_to exist
// 50:     expect(formula).not_to be_latest_version_installed
// 51:   end
// 52:
// 53:   specify "basic installation" do
// 54:     temporary_install(Testball.new) do |f|
// 55:       # Test that things made it into the Keg
// 56:       # "readme" is empty, so it should not be installed
// 57:       expect(f.prefix/"readme").not_to exist
// 58:
// 59:       expect(f.bin).to be_a_directory
// 60:       expect(f.bin.children.count).to eq(3)
// 61:
// 62:       expect(f.libexec).to be_a_directory
// 63:       expect(f.libexec.children.count).to eq(1)
// 64:
// 65:       expect(f.prefix/"main.c").not_to exist
// 66:       expect(f.prefix/"license").not_to exist
// 67:
// 68:       # Test that things make it into the Cellar
// 69:       keg = Keg.new f.prefix
// 70:       keg.link
// 71:
// 72:       bin = HOMEBREW_PREFIX/"bin"
// 73:       expect(bin).to be_a_directory
// 74:       expect(bin.children.count).to eq(3)
// 75:       expect(f.prefix/".brew/testball.rb").to be_readable
// 76:     end
// 77:   end
// 78:
// 79:   specify "offline installation" do
// 80:     expect { temporary_install(FailballOfflineInstall.new) }.to raise_error(BuildError) if Sandbox.available?
// 81:   end
// 82:
// 83:   specify "Formula is not poured from bottle when compiler specified" do
// 84:     temporary_install(TestballBottle.new, cc: "clang") do |f|
// 85:       tab = Tab.for_formula(f)
// 86:       expect(tab.compiler).to eq("clang")
// 87:     end
// 88:   end
// 89:
// 90:   specify "relocated bottle install does not require developer tools on Apple Silicon", :needs_macos do
// 91:     formula = TestballBottle.new
// 92:     installer = described_class.new(formula)
// 93:
// 94:     allow(installer).to receive_messages(lock: nil, pour_bottle?: true, quiet?: true)
// 95:     allow(Hardware::CPU).to receive(:arm?).and_return(true)
// 96:     allow(formula.bottle_specification).to receive(:skip_relocation?).and_return(false)
// 97:     expect(Homebrew::Diagnostic::Checks).not_to receive(:new)
// 98:     allow(installer).to receive(:check_conflicts).and_raise("stopped after preinstall checks")
// 99:
// 100:     expect do
// 101:       installer.install
// 102:     end.to raise_error("stopped after preinstall checks")
// 103:   end
// 104:
// 105:   describe "#finish" do
// 106:     it "runs structured post-install work through the post-install subprocess" do
// 107:       formula = formula "finish-install-steps" do
// 108:         T.bind(self, T.class_of(Formula))
// 109:         url "foo-1.0"
// 110:       end
// 111:       installer = described_class.new(formula)
// 112:       tab = instance_double(Tab)
// 113:       keg = instance_double(Keg, tab:)
// 114:
// 115:       allow(Keg).to receive(:new).with(formula.prefix).and_return(keg)
// 116:       allow(installer).to receive_messages(
// 117:         build_bottle?:               false,
// 118:         caveats:                     nil,
// 119:         debug_symbols?:              false,
// 120:         fix_dynamic_linkage:         nil,
// 121:         install_service:             nil,
// 122:         link:                        nil,
// 123:         link_manual_command_warning: nil,
// 124:         only_deps?:                  false,
// 125:         quiet?:                      true,
// 126:         show_summary_heading?:       false,
// 127:         skip_post_install?:          false,
// 128:         summary:                     "summary",
// 129:         verbose?:                    false,
// 130:       )
// 131:       allow(formula).to receive_messages(post_install_steps_defined?: true, post_install_defined?: false,
// 132:                                          runtime_dependencies: [])
// 133:       allow(CacheStoreDatabase).to receive(:use).with(:linkage)
// 134:       allow(Homebrew::EnvConfig).to receive(:sbom?).and_return(false)
// 135:       allow(Homebrew::Install).to receive(:global_post_install)
// 136:       allow(Tab).to receive_messages(clear_cache: nil, runtime_deps_hash: [])
// 137:       allow(tab).to receive(:runtime_dependencies=)
// 138:       allow(tab).to receive(:write)
// 139:
// 140:       expect(formula).to receive(:install_etc_var).ordered
// 141:       expect(formula).not_to receive(:run_post_install_steps)
// 142:       expect(installer).to receive(:post_install).ordered
// 143:
// 144:       installer.finish
// 145:     end
// 146:   end
// 147:
// 148:   describe "#post_install" do
// 149:     it "runs structured post-install steps inside the formula sandbox" do
// 150:       formula = formula("sandboxed-install-steps") do
// 151:         T.bind(self, T.class_of(Formula))
// 152:         url "foo-1.0"
// 153:
// 154:         post_install_steps do
// 155:           touch "state", base: :var
// 156:         end
// 157:       end
// 158:       installer = described_class.new(formula)
// 159:       sandbox = instance_double(Sandbox).as_null_object
// 160:
// 161:       allow(installer).to receive(:post_install_formula_path).and_return(formula.path)
// 162:       allow(formula).to receive_messages(logs: mktmpdir, network_access_allowed?: false)
// 163:       allow(Sandbox).to receive_messages(new: sandbox, use_for?: true)
// 164:       expect(Sandbox).to receive(:with_preserved_brew_file).and_yield
// 165:       expect(sandbox).to receive(:add_install_hook_rules).with(network_access_allowed: false)
// 166:       expect(sandbox).to receive(:run) do |*args|
// 167:         expect(args).to include(HOMEBREW_LIBRARY_PATH/"postinstall.rb", formula.path)
// 168:       end
// 169:
// 170:       installer.post_install
// 171:     end
// 172:
// 173:     it "restores bin/brew after a Landlock-sandboxed post-install replaces it" do
// 174:       prefix = mktmpdir
// 175:       stub_const("HOMEBREW_PREFIX", prefix)
// 176:       brew_file = prefix/"bin/brew"
// 177:       original_brew_file = prefix/"Homebrew/bin/brew"
// 178:       original_brew_file.dirname.mkpath
// 179:       original_brew_file.write "#!/bin/sh\n"
// 180:       brew_file.dirname.mkpath
// 181:       brew_file.make_relative_symlink original_brew_file
// 182:       original_target = brew_file.readlink
// 183:       original_directory_mode = brew_file.dirname.stat.mode & 07777
// 184:       formula = formula("replace-brew-postinstall") do
// 185:         T.bind(self, T.class_of(Formula))
// 186:         url "foo-1.0"
// 187:       end
// 188:       installer = described_class.new(formula)
// 189:       sandbox = instance_double(Sandbox).as_null_object
// 190:
// 191:       allow(installer).to receive(:post_install_formula_path).and_return(formula.path)
// 192:       allow(formula).to receive_messages(logs: mktmpdir, network_access_allowed?: true)
// 193:       allow(Sandbox).to receive_messages(full_write_isolation?: false, new: sandbox, use_for?: true)
// 194:       allow(sandbox).to receive(:run) do
// 195:         FileUtils.rm_f brew_file
// 196:         brew_file.write "malicious\n"
// 197:         brew_file.dirname.chmod 0500
// 198:       end
// 199:
// 200:       installer.post_install
// 201:
// 202:       expect(brew_file).to be_a_symlink
// 203:       expect(brew_file.readlink).to eq(original_target)
// 204:       expect(brew_file.dirname.stat.mode & 07777).to eq(original_directory_mode)
// 205:     end
// 206:   end
// 207:
// 208:   describe "#post_install_formula_path" do
// 209:     it "uses the API formula for structured-only post-installs" do
// 210:       formula = formula("api-install-steps") do
// 211:         T.bind(self, T.class_of(Formula))
// 212:         url "foo-1.0"
// 213:       end
// 214:       installer = described_class.new(formula)
// 215:
// 216:       allow(formula).to receive_messages(any_installed_prefix: mktmpdir, loaded_from_api?: true,
// 217:                                          post_install_defined?: false)
// 218:
// 219:       expect(installer.post_install_formula_path).to eq(formula.full_name)
// 220:     end
// 221:
// 222:     it "uses the keg formula for API post-installs with Ruby hooks" do
// 223:       formula = formula("api-post-install-hook") do
// 224:         T.bind(self, T.class_of(Formula))
// 225:         url "foo-1.0"
// 226:       end
// 227:       installer = described_class.new(formula)
// 228:       installed_prefix = mktmpdir
// 229:
// 230:       allow(formula).to receive_messages(any_installed_prefix: installed_prefix, loaded_from_api?: true,
// 231:                                          post_install_defined?: true)
// 232:
// 233:       expect(installer.post_install_formula_path).to eq(installed_prefix/".brew/api-post-install-hook.rb")
// 234:     end
// 235:   end
// 236:
// 237:   describe "#pour" do
// 238:     let(:f) do
// 239:       formula("missing-bottle-tab") do
// 240:         T.bind(self, T.class_of(Formula))
// 241:         url "https://brew.sh/missing-bottle-tab-1.0.tar.gz"
// 242:
// 243:         bottle do
// 244:           sha256 cellar: :any_skip_relocation,
// 245:                  Utils::Bottles.tag.to_sym => "d7b9f4e8bf83608b71fe958a99f19f2e5e68bb2582965d32e41759c24f1aef97"
// 246:         end
// 247:       end
// 248:     end
// 249:     let(:installer) { Class.new(described_class).new(f) }
// 250:     let(:downloader) { instance_double(AbstractDownloadStrategy, basename: "missing-bottle-tab", stage: nil) }
// 251:     let(:downloadable) { instance_double(Resource, downloader:) }
// 252:     let(:tab) do
// 253:       instance_double(Tab, changed_files: nil, source: { "versions" => {} }, write: nil).as_null_object
// 254:     end
// 255:     let(:keg) { instance_double(Keg) }
// 256:
// 257:     before do
// 258:       allow(installer).to receive(:downloadable).and_return(downloadable)
// 259:       allow(Utils::Bottles).to receive(:load_tab).with(f).and_return(tab)
// 260:       allow(Tab).to receive(:clear_cache)
// 261:       allow(Keg).to receive(:new).with(f.prefix).and_return(keg)
// 262:       allow(keg).to receive(:replace_placeholders_with_locations)
// 263:       allow(f.bottle_specification).to receive(:skip_relocation?).with(tab:).and_return(true)
// 264:     end
// 265:
// 266:     it "preserves the skip-linkage decision for the default bottle domain" do
// 267:       expect(keg).to receive(:replace_placeholders_with_locations).with(nil, skip_linkage: true)
// 268:
// 269:       installer.pour
// 270:     end
// 271:
// 272:     it "relocates dynamic linkage without metadata from a bottle mirror" do
// 273:       ENV["HOMEBREW_BOTTLE_DOMAIN"] = "https://mirror.example.com"
// 274:
// 275:       expect(keg).to receive(:replace_placeholders_with_locations).with(nil, skip_linkage: false)
// 276:
// 277:       installer.pour
// 278:     end
// 279:
// 280:     it "explains how a bottle mirror can provide metadata once per invocation" do
// 281:       ENV["HOMEBREW_BOTTLE_DOMAIN"] = "https://mirror.example.com"
// 282:
// 283:       expect { 2.times { installer.pour } }
// 284:         .to output(satisfy do |stderr|
// 285:           stderr.scan("OCI registry proxy").one? &&
// 286:             stderr.include?("sh.brew.tab") && stderr.include?("HOMEBREW_ARTIFACT_DOMAIN")
// 287:         end).to_stderr
// 288:     end
// 289:   end
// 290:
// 291:   describe "#build_bottle_postinstall" do
// 292:     let(:f) do
// 293:       formula "bottle-config" do
// 294:         T.bind(self, T.class_of(Formula))
// 295:         url "foo-1.0"
// 296:       end
// 297:     end
// 298:     let(:config_file) { HOMEBREW_PREFIX/"etc/bottle-config.conf" }
// 299:
// 300:     before do
// 301:       FileUtils.rm_rf f.rack
// 302:       FileUtils.rm_f config_file
// 303:       FileUtils.rm_f Pathname("#{config_file}.default")
// 304:     end
// 305:
// 306:     after do
// 307:       FileUtils.rm_rf f.rack
// 308:       FileUtils.rm_f config_file
// 309:       FileUtils.rm_f Pathname("#{config_file}.default")
// 310:     end
// 311:
// 312:     it "stores new prefix config where install_etc_var restores it from" do
// 313:       installer = described_class.new(f)
// 314:       installer.build_bottle_preinstall
// 315:       config_file.dirname.mkpath
// 316:       config_file.write "new\n"
// 317:
// 318:       installer.build_bottle_postinstall
// 319:
// 320:       expect((f.bottle_prefix/"etc/bottle-config.conf").read).to eq("new\n")
// 321:     end
// 322:   end
// 323:
// 324:   describe "#verify_deps_exist" do
// 325:     it "does not install an untapped dependency tap" do
// 326:       formula = Testball.new
// 327:       installer = described_class.new(formula)
// 328:       tap = instance_double(Tap, user: "user", repository: "repo", to_s: "user/repo", installed?: false)
// 329:
// 330:       allow(installer).to receive(:compute_dependencies).and_raise(TapFormulaUnavailableError.new(tap, "foo"))
// 331:
// 332:       expect(tap).not_to receive(:ensure_installed!)
// 333:
// 334:       expect { installer.verify_deps_exist }
// 335:         .to raise_error(TapFormulaUnavailableError, /If you trust this tap/) { |error|
// 336:           expect(error.dependent).to eq(formula.full_name)
// 337:         }
// 338:     end
// 339:   end
// 340:
// 341:   describe "#fetch_bottle_tab" do
// 342:     it "does not enqueue cached bottle manifests" do
// 343:       formula = formula("deno") do
// 344:         T.bind(self, T.class_of(Formula))
// 345:         url "https://brew.sh/deno-2.7.11.tar.gz"
// 346:
// 347:         bottle do
// 348:           root_url HOMEBREW_BOTTLE_DEFAULT_DOMAIN
// 349:           sha256 cellar: :any_skip_relocation,
// 350:                  Utils::Bottles.tag.to_sym => "d7b9f4e8bf83608b71fe958a99f19f2e5e68bb2582965d32e41759c24f1aef97"
// 351:         end
// 352:       end
// 353:       installer = described_class.new(formula)
// 354:       installer.download_queue = instance_double(Homebrew::DownloadQueue)
// 355:       manifest_resource = formula.bottle&.github_packages_manifest_resource
// 356:       cached_download = manifest_resource&.cached_download
// 357:
// 358:       allow(manifest_resource).to receive(:downloaded?).and_return(true)
// 359:       expect(manifest_resource).to receive(:verify_download_integrity).with(cached_download) do
// 360:         expect(Context.current.quiet?).to be(true)
// 361:       end
// 362:       expect(manifest_resource).not_to receive(:clear_cache)
// 363:       expect(installer.download_queue).not_to receive(:enqueue)
// 364:
// 365:       installer.fetch_bottle_tab(enqueue: true)
// 366:     end
// 367:
// 368:     it "enqueues invalid cached bottle manifests" do
// 369:       formula = formula("deno") do
// 370:         T.bind(self, T.class_of(Formula))
// 371:         url "https://brew.sh/deno-2.7.11.tar.gz"
// 372:
// 373:         bottle do
// 374:           root_url HOMEBREW_BOTTLE_DEFAULT_DOMAIN
// 375:           sha256 cellar: :any_skip_relocation,
// 376:                  Utils::Bottles.tag.to_sym => "d7b9f4e8bf83608b71fe958a99f19f2e5e68bb2582965d32e41759c24f1aef97"
// 377:         end
// 378:       end
// 379:       installer = described_class.new(formula)
// 380:       installer.download_queue = instance_double(Homebrew::DownloadQueue)
// 381:       manifest_resource = formula.bottle&.github_packages_manifest_resource
// 382:
// 383:       allow(manifest_resource).to receive(:downloaded?).and_return(true)
// 384:       manifest_resource&.manifest_annotations = {}
// 385:       expect(manifest_resource).to receive(:verify_download_integrity) do
// 386:         expect(Context.current.quiet?).to be(true)
// 387:         raise Resource::BottleManifest::Error
// 388:       end
// 389:       expect(installer.download_queue).to receive(:enqueue).with(manifest_resource)
// 390:
// 391:       installer.fetch_bottle_tab(enqueue: true)
// 392:
// 393:       # Read the raw ivar: the private memoising reader would re-parse the manifest.
// 394:       # rubocop:disable Homebrew/NoInstanceVariableAccessInTests
// 395:       expect(manifest_resource&.instance_variable_get(:@manifest_annotations)).to be_nil
// 396:       # rubocop:enable Homebrew/NoInstanceVariableAccessInTests
// 397:     end
// 398:   end
// 399:
// 400:   describe "#enqueue_fetch" do
// 401:     let(:formula) { TestballBottle.new }
// 402:     let(:installer) { described_class.new(formula) }
// 403:     let(:download_queue) { instance_double(Homebrew::DownloadQueue) }
// 404:     let(:bottle) { instance_double(Bottle, cached_download: HOMEBREW_CACHE/"downloads/testball-bottle") }
// 405:
// 406:     before do
// 407:       installer.download_queue = download_queue
// 408:
// 409:       allow(Homebrew::EnvConfig).to receive(:verify_attestations?).and_return(false)
// 410:       allow(installer).to receive(:previously_fetched_formula)
// 411:       allow(installer).to receive(:pour_bottle?).with(output_warning: true).and_return(true)
// 412:       allow(installer).to receive(:downloadable).and_return(bottle)
// 413:       allow(installer).to receive(:fetch_bottle_tab)
// 414:     end
// 415:
// 416:     it "starts a bottle download before enqueueing dependencies after the prelude" do
// 417:       installer.ran_prelude = true
// 418:
// 419:       expect(download_queue).to receive(:enqueue)
// 420:         .with(bottle, check_attestation: false, stage: false).ordered
// 421:       expect(installer).to receive(:fetch_dependencies).ordered
// 422:       expect(download_queue).to receive(:enqueue)
// 423:         .with(bottle, check_attestation: false).ordered
// 424:
// 425:       installer.enqueue_fetch
// 426:     end
// 427:
// 428:     it "resolves dependencies before enqueueing a bottle without the prelude" do
// 429:       expect(installer).to receive(:fetch_dependencies).ordered
// 430:       expect(installer).to receive(:fetch_bottle_tab).with(enqueue: true).ordered
// 431:       expect(download_queue).to receive(:enqueue)
// 432:         .with(bottle, check_attestation: false).ordered
// 433:
// 434:       installer.enqueue_fetch
// 435:     end
// 436:
// 437:     it "does not requeue a bottle already enqueued by the prelude fetch" do
// 438:       allow(installer).to receive(:pour_bottle?).and_return(true)
// 439:       expect(download_queue).to receive(:enqueue)
// 440:         .with(bottle, check_attestation: false, stage: true).once
// 441:       installer.prelude_fetch
// 442:
// 443:       expect(installer).to receive(:fetch_dependencies)
// 444:
// 445:       installer.enqueue_fetch
// 446:     end
// 447:   end
// 448:
// 449:   describe "linking defaults" do
// 450:     it "links non-keg-only formulae when link_keg is false" do
// 451:       ordinary_formula = formula "homebrew-link-default" do
// 452:         T.bind(self, T.class_of(Formula))
// 453:         url "foo-1.0"
// 454:       end
// 455:
// 456:       expect(described_class.new(ordinary_formula, link_keg: false).link_keg).to be true
// 457:     end
// 458:
// 459:     it "links non-keg-only dependencies even when they were not previously linked" do
// 460:       dependency_formula = formula "homebrew-link-default-dependency" do
// 461:         T.bind(self, T.class_of(Formula))
// 462:         url "foo-1.0"
// 463:       end
// 464:       dependency = instance_double(Dependency, to_formula: dependency_formula, name: dependency_formula.name,
// 465:                                                options: Options.new)
// 466:       installer = described_class.new(Testball.new)
// 467:       # Sorbet doesn't like `T.let(nil, T.nilable(described_class))`, but the
// 468:       # RuboCop will always autocorrect to that.
// 469:       # rubocop:disable RSpec/DescribedClass
// 470:       child_installer = T.let(nil, T.nilable(FormulaInstaller))
// 471:       # rubocop:enable RSpec/DescribedClass
// 472:
// 473:       allow(dependency_formula).to receive_messages(
// 474:         linked_keg:                Pathname("/tmp/nonexistent-linked-keg"),
// 475:         latest_version_installed?: false,
// 476:         tap:                       nil,
// 477:         any_version_installed?:    false,
// 478:       )
// 479:       allow(installer).to receive(:oh1)
// 480:       allow(described_class).to receive(:new).and_wrap_original do |original, formula, **kwargs|
// 481:         instance = original.call(formula, **kwargs)
// 482:         next instance if formula != dependency_formula
// 483:
// 484:         child_installer = instance
// 485:         allow(instance).to receive_messages(prelude: true, install: true, finish: true)
// 486:         instance
// 487:       end
// 488:
// 489:       installer.install_dependency(dependency)
// 490:
// 491:       expect(child_installer).not_to be_installed_on_request
// 492:       expect(child_installer&.link_keg).to be true
// 493:     end
// 494:   end
// 495:
// 496:   describe "#install_dependency" do
// 497:     it "reports an outdated dependency as upgrading" do
// 498:       dependency_formula = formula "outdated-dependency" do
// 499:         T.bind(self, T.class_of(Formula))
// 500:         url "foo-1.0"
// 501:       end
// 502:       dependency = instance_double(Dependency, to_formula: dependency_formula, name: dependency_formula.name,
// 503:                                                options: Options.new)
// 504:       installer = described_class.new(Testball.new)
// 505:
// 506:       allow(dependency_formula).to receive_messages(
// 507:         linked_keg:                Pathname("/tmp/nonexistent-linked-keg"),
// 508:         latest_version_installed?: false,
// 509:         tap:                       nil,
// 510:         any_version_installed?:    true,
// 511:         outdated?:                 true,
// 512:       )
// 513:       expect(installer).to receive(:oh1)
// 514:         .with("Upgrading testball dependency: #{Formatter.identifier(dependency_formula.name)}")
// 515:       allow(described_class).to receive(:new).and_wrap_original do |original, formula, **kwargs|
// 516:         instance = original.call(formula, **kwargs)
// 517:         next instance if formula != dependency_formula
// 518:
// 519:         allow(instance).to receive_messages(prelude: true, install: true, finish: true)
// 520:         instance
// 521:       end
// 522:
// 523:       installer.install_dependency(dependency)
// 524:     end
// 525:   end
// 526:
// 527:   describe "#check_conflicts" do
// 528:     let(:test_formula) do
// 529:       formula "testball" do
// 530:         T.bind(self, T.class_of(Formula))
// 531:         url "https://brew.sh/testball-0.1.tar.gz"
// 532:         conflicts_with "other"
// 533:       end
// 534:     end
// 535:
// 536:     let(:conflicting_formula) do
// 537:       formula "other" do
// 538:         T.bind(self, T.class_of(Formula))
// 539:         url "https://brew.sh/other-0.1.tar.gz"
// 540:         conflicts_with "testball"
// 541:       end
// 542:     end
// 543:
// 544:     before { allow(Formulary).to receive(:factory).with("other").and_return(conflicting_formula) }
// 545:
// 546:     context "when conflicting formula is installed but not linked" do
// 547:       before do
// 548:         linked_keg = instance_double(Pathname, exist?: false)
// 549:         opt_prefix = instance_double(Pathname, exist?: true)
// 550:         allow(conflicting_formula).to receive_messages(linked_keg:, opt_prefix:)
// 551:       end
// 552:
// 553:       it "does not raise an error" do
// 554:         installer = described_class.new(test_formula, link_keg: true)
// 555:         expect { installer.check_conflicts }.not_to raise_error
// 556:       end
// 557:     end
// 558:
// 559:     context "when conflicting formula is installed" do
// 560:       before do
// 561:         linked_keg = opt_prefix = instance_double(Pathname, exist?: true)
// 562:         allow(conflicting_formula).to receive_messages(linked_keg:, opt_prefix:)
// 563:       end
// 564:
// 565:       it "raises an error if linking keg" do
// 566:         installer = described_class.new(test_formula, link_keg: true)
// 567:         expect { installer.check_conflicts }.to raise_error(FormulaConflictError)
// 568:       end
// 569:
// 570:       it "does not raise an error with force set" do
// 571:         installer = described_class.new(test_formula, link_keg: true, force: true)
// 572:         expect { installer.check_conflicts }.not_to raise_error
// 573:       end
// 574:
// 575:       it "does not raise an error with skip_link set" do
// 576:         installer = described_class.new(test_formula, link_keg: true, skip_link: true)
// 577:         expect { installer.check_conflicts }.not_to raise_error
// 578:       end
// 579:
// 580:       it "does not raise an error if not linking keg" do
// 581:         allow(test_formula).to receive(:keg_only?).and_return(true)
// 582:         installer = described_class.new(test_formula, link_keg: false, installed_on_request: false)
// 583:         expect { installer.check_conflicts }.not_to raise_error
// 584:       end
// 585:     end
// 586:
// 587:     it "ignores conflicts that name the formula being installed" do
// 588:       f = formula("terraform", tap: Tap.fetch("thirdparty", "selfconflict")) do
// 589:         T.bind(self, T.class_of(Formula))
// 590:         url "foo-1.0"
// 591:         conflicts_with "terraform"
// 592:       end
// 593:
// 594:       expect(Formulary).not_to receive(:factory)
// 595:
// 596:       described_class.new(f).check_conflicts
// 597:     ensure
// 598:       FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 599:     end
// 600:   end
// 601:
// 602:   describe "#install_dependencies" do
// 603:     it "marks only outdated dependencies as upgradable in the header" do
// 604:       outdated = formula "outdated-dependency" do
// 605:         T.bind(self, T.class_of(Formula))
// 606:         url "foo-1.0"
// 607:       end
// 608:       uninstalled = formula "uninstalled-dependency" do
// 609:         T.bind(self, T.class_of(Formula))
// 610:         url "foo-1.0"
// 611:       end
// 612:       allow(outdated).to receive_messages(any_version_installed?: true, outdated?: true)
// 613:       allow(uninstalled).to receive_messages(any_version_installed?: false, outdated?: false)
// 614:       deps = [
// 615:         instance_double(Dependency, to_formula: outdated, name: outdated.name, to_s: outdated.name),
// 616:         instance_double(Dependency, to_formula: uninstalled, name: uninstalled.name, to_s: uninstalled.name),
// 617:       ]
// 618:       installer = described_class.new(Testball.new)
// 619:       allow(installer).to receive(:install_dependency)
// 620:       allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 621:       allow(Homebrew::EnvConfig).to receive(:no_emoji?).and_return(true)
// 622:
// 623:       expect { installer.install_dependencies(deps) }
// 624:         .to output(/outdated-dependency.*\(upgradable\).*and.*uninstalled-dependency[^(]*$/m).to_stdout
// 625:     end
// 626:
// 627:     it "does not render the first dependency name bolder than the rest" do
// 628:       ENV["HOMEBREW_COLOR"] = "1"
// 629:       dep_a = formula("dep-a") do
// 630:         T.bind(self, T.class_of(Formula))
// 631:         url "foo-1.0"
// 632:       end
// 633:       dep_b = formula("dep-b") do
// 634:         T.bind(self, T.class_of(Formula))
// 635:         url "foo-1.0"
// 636:       end
// 637:       [dep_a, dep_b].each { |f| allow(f).to receive_messages(any_version_installed?: true, outdated?: true) }
// 638:       deps = [
// 639:         instance_double(Dependency, to_formula: dep_a, name: dep_a.name, to_s: dep_a.name),
// 640:         instance_double(Dependency, to_formula: dep_b, name: dep_b.name, to_s: dep_b.name),
// 641:       ]
// 642:       installer = described_class.new(Testball.new)
// 643:       allow(installer).to receive(:install_dependency)
// 644:       allow_any_instance_of(StringIO).to receive(:tty?).and_return(true)
// 645:
// 646:       expect { installer.install_dependencies(deps) }
// 647:         .to output(/:\e\[0m /).to_stdout
// 648:     end
// 649:
// 650:     it "shows the formula header after installing a single dependency" do
// 651:       dep = formula("single-dep") do
// 652:         T.bind(self, T.class_of(Formula))
// 653:         url "foo-1.0"
// 654:       end
// 655:       deps = [instance_double(Dependency, to_formula: dep, name: dep.name, to_s: dep.name)]
// 656:       installer = described_class.new(Testball.new)
// 657:       allow(installer).to receive(:install_dependency)
// 658:
// 659:       installer.install_dependencies(deps)
// 660:
// 661:       expect(installer.show_header?).to be(true)
// 662:     end
// 663:   end
// 664:
// 665:   describe "#expand_dependencies_for_formula" do
// 666:     it "checks equal dependency satisfaction once per expansion" do
// 667:       shared_formula = instance_double(Formula, deps: [], name: "shared", full_name: "shared")
// 668:       shared_dep = Dependency.new("shared")
// 669:       repeated_shared_dep = Dependency.new("shared")
// 670:       expect(shared_dep).to receive(:satisfied?).once.and_return(false)
// 671:       expect(repeated_shared_dep).not_to receive(:satisfied?)
// 672:       allow(shared_dep).to receive(:to_formula).and_return(shared_formula)
// 673:       allow(repeated_shared_dep).to receive(:to_formula).and_return(shared_formula)
// 674:
// 675:       first_parent = Dependency.new("first-parent")
// 676:       first_parent_formula = instance_double(Formula, deps: [shared_dep], name: "first-parent",
// 677:                                                      full_name: "first-parent")
// 678:       allow(first_parent).to receive_messages(satisfied?: false, to_formula: first_parent_formula)
// 679:
// 680:       second_parent = Dependency.new("second-parent")
// 681:       second_parent_formula = instance_double(Formula, deps: [repeated_shared_dep], name: "second-parent",
// 682:                                                       full_name: "second-parent")
// 683:       allow(second_parent).to receive_messages(satisfied?: false, to_formula: second_parent_formula)
// 684:
// 685:       f = formula "homebrew-expand-dependencies-cache" do
// 686:         T.bind(self, T.class_of(Formula))
// 687:         url "foo-1.0"
// 688:       end
// 689:       allow(f).to receive(:deps).and_return([first_parent, second_parent])
// 690:
// 691:       installer = described_class.new(f)
// 692:       build_options = BuildOptions.new(Options.new, Options.new)
// 693:       allow(installer).to receive_messages(effective_build_options_for: build_options, install_bottle_for?: false)
// 694:
// 695:       deps = installer.expand_dependencies_for_formula(f)
// 696:
// 697:       expect(deps.map(&:name)).to eq(%w[shared first-parent second-parent])
// 698:     end
// 699:
// 700:     it "checks uses_from_macos dependencies with different bounds separately" do
// 701:       shared_formula = instance_double(Formula, deps: [], name: "shared", full_name: "shared")
// 702:       first_dep = UsesFromMacOSDependency.new("shared", [], bounds: { since: :ventura })
// 703:       second_dep = UsesFromMacOSDependency.new("shared", [], bounds: { since: :sonoma })
// 704:       expect(first_dep).to receive(:satisfied?).once.and_return(false)
// 705:       expect(second_dep).to receive(:satisfied?).once.and_return(false)
// 706:       allow(first_dep).to receive(:to_formula).and_return(shared_formula)
// 707:       allow(second_dep).to receive(:to_formula).and_return(shared_formula)
// 708:
// 709:       first_parent = Dependency.new("first-parent")
// 710:       first_parent_formula = instance_double(Formula, deps: [first_dep], name: "first-parent",
// 711:                                                      full_name: "first-parent")
// 712:       allow(first_parent).to receive_messages(satisfied?: false, to_formula: first_parent_formula)
// 713:
// 714:       second_parent = Dependency.new("second-parent")
// 715:       second_parent_formula = instance_double(Formula, deps: [second_dep], name: "second-parent",
// 716:                                                       full_name: "second-parent")
// 717:       allow(second_parent).to receive_messages(satisfied?: false, to_formula: second_parent_formula)
// 718:
// 719:       f = formula "homebrew-expand-uses-from-macos-dependencies-cache" do
// 720:         T.bind(self, T.class_of(Formula))
// 721:         url "foo-1.0"
// 722:       end
// 723:       allow(f).to receive(:deps).and_return([first_parent, second_parent])
// 724:
// 725:       installer = described_class.new(f)
// 726:       build_options = BuildOptions.new(Options.new, Options.new)
// 727:       allow(installer).to receive_messages(effective_build_options_for: build_options, install_bottle_for?: false)
// 728:
// 729:       deps = installer.expand_dependencies_for_formula(f)
// 730:
// 731:       expect(deps.map(&:name)).to eq(%w[shared first-parent second-parent])
// 732:     end
// 733:   end
// 734:
// 735:   describe "versioned keg-only linking defaults" do
// 736:     let(:base_name) { "homebrew-versioned-formula" }
// 737:     let(:formula_name) { "#{base_name}@1.0" }
// 738:     let(:keg_only_formula) do
// 739:       formula formula_name do
// 740:         T.bind(self, T.class_of(Formula))
// 741:         url "foo-1.0"
// 742:         keg_only :versioned_formula
// 743:       end
// 744:     end
// 745:
// 746:     before do
// 747:       allow(keg_only_formula).to receive_messages(any_version_installed?:  false,
// 748:                                                   link_overwrite_formulae: [])
// 749:     end
// 750:
// 751:     it "does not link by default when it is not installed on request" do
// 752:       fi = described_class.new(keg_only_formula)
// 753:
// 754:       expect(fi.link_keg).to be false
// 755:     end
// 756:
// 757:     it "links by default when no sibling variants are installed" do
// 758:       fi = described_class.new(keg_only_formula, installed_on_request: true)
// 759:
// 760:       expect(fi.link_keg).to be true
// 761:     end
// 762:
// 763:     it "does not link by default when any version is already installed" do
// 764:       allow(keg_only_formula).to receive(:any_version_installed?).and_return(true)
// 765:
// 766:       fi = described_class.new(keg_only_formula)
// 767:
// 768:       expect(fi.link_keg).to be false
// 769:     end
// 770:
// 771:     it "links when explicitly requested" do
// 772:       allow(keg_only_formula).to receive(:any_version_installed?).and_return(true)
// 773:
// 774:       fi = described_class.new(keg_only_formula, link_keg: true)
// 775:
// 776:       expect(fi.link_keg).to be true
// 777:     end
// 778:
// 779:     it "does not link by default when another @-versioned formula is installed" do
// 780:       other_version = formula "#{base_name}@2.0" do
// 781:         T.bind(self, T.class_of(Formula))
// 782:         url "foo-2.0"
// 783:         keg_only :versioned_formula
// 784:       end
// 785:       allow(other_version).to receive(:any_version_installed?).and_return(true)
// 786:       allow(keg_only_formula).to receive(:link_overwrite_formulae).and_return([other_version])
// 787:
// 788:       fi = described_class.new(keg_only_formula)
// 789:
// 790:       expect(fi.link_keg).to be false
// 791:     end
// 792:
// 793:     it "does not link by default when the unversioned sibling is installed" do
// 794:       unversioned_formula = formula base_name do
// 795:         T.bind(self, T.class_of(Formula))
// 796:         url "foo-1.0"
// 797:       end
// 798:       allow(unversioned_formula).to receive(:any_version_installed?).and_return(true)
// 799:       allow(keg_only_formula).to receive(:link_overwrite_formulae).and_return([unversioned_formula])
// 800:
// 801:       fi = described_class.new(keg_only_formula)
// 802:
// 803:       expect(fi.link_keg).to be false
// 804:     end
// 805:
// 806:     it "does not link by default when the unversioned sibling is keg-only" do
// 807:       unversioned_formula = formula base_name do
// 808:         T.bind(self, T.class_of(Formula))
// 809:         url "foo-1.0"
// 810:         keg_only "some reason"
// 811:       end
// 812:       allow(keg_only_formula).to receive(:link_overwrite_formulae).and_return([unversioned_formula])
// 813:
// 814:       fi = described_class.new(keg_only_formula)
// 815:
// 816:       expect(fi.link_keg).to be false
// 817:     end
// 818:
// 819:     it "does not link by default when the -full variant is installed" do
// 820:       full_variant = formula "#{base_name}-full" do
// 821:         T.bind(self, T.class_of(Formula))
// 822:         url "foo-full-1.0"
// 823:         keg_only :versioned_formula
// 824:       end
// 825:       allow(full_variant).to receive(:any_version_installed?).and_return(true)
// 826:       allow(keg_only_formula).to receive(:link_overwrite_formulae).and_return([full_variant])
// 827:
// 828:       fi = described_class.new(keg_only_formula)
// 829:
// 830:       expect(fi.link_keg).to be false
// 831:     end
// 832:
// 833:     it "does not link by default when the non-full variant is installed" do
// 834:       full_formula = formula "#{base_name}-full" do
// 835:         T.bind(self, T.class_of(Formula))
// 836:         url "foo-full-1.0"
// 837:         keg_only :versioned_formula
// 838:       end
// 839:       non_full_variant = formula base_name do
// 840:         T.bind(self, T.class_of(Formula))
// 841:         url "foo-1.0"
// 842:         keg_only :versioned_formula
// 843:       end
// 844:       allow(non_full_variant).to receive(:any_version_installed?).and_return(true)
// 845:       allow(full_formula).to receive_messages(any_version_installed?:  false,
// 846:                                               link_overwrite_formulae: [non_full_variant])
// 847:
// 848:       fi = described_class.new(full_formula)
// 849:
// 850:       expect(fi.link_keg).to be false
// 851:     end
// 852:   end
// 853:
// 854:   describe "#link" do
// 855:     let(:versioned_formula) do
// 856:       formula "homebrew-versioned-formula@1.0" do
// 857:         T.bind(self, T.class_of(Formula))
// 858:         url "foo-1.0"
// 859:         keg_only :versioned_formula
// 860:       end
// 861:     end
// 862:     let(:other_version) do
// 863:       formula "homebrew-versioned-formula" do
// 864:         T.bind(self, T.class_of(Formula))
// 865:         url "foo-2.0"
// 866:         keg_only :versioned_formula
// 867:       end
// 868:     end
// 869:     let(:keg) do
// 870:       instance_double(Keg, linked?: false)
// 871:     end
// 872:
// 873:     before do
// 874:       allow(Formula).to receive(:clear_cache)
// 875:       allow(Cask::Caskroom).to receive(:path).and_return(Pathname("/tmp/nonexistent-caskroom"))
// 876:       allow(versioned_formula).to receive_messages(link_overwrite_formulae: [other_version],
// 877:                                                    any_version_installed?:  false)
// 878:       allow(other_version).to receive(:any_version_installed?).and_return(true)
// 879:     end
// 880:
// 881:     it "only optlinks when default linking is disabled by an installed sibling" do
// 882:       installer = described_class.new(versioned_formula)
// 883:
// 884:       expect(installer.link_keg).to be false
// 885:       expect(Homebrew::Unlink).not_to receive(:unlink_link_overwrite_formulae)
// 886:       expect(keg).to receive(:optlink).with(verbose: false, overwrite: false)
// 887:       expect(keg).not_to receive(:link)
// 888:
// 889:       installer.link(keg)
// 890:     end
// 891:
// 892:     it "unlinks siblings before linking when explicitly requested" do
// 893:       installer = described_class.new(versioned_formula, link_keg: true)
// 894:
// 895:       expect(installer.link_keg).to be true
// 896:       expect(Homebrew::Unlink).to receive(:unlink_link_overwrite_formulae).with(versioned_formula,
// 897:                                                                                 verbose: false).ordered
// 898:       expect(keg).to receive(:link).with(verbose: false, overwrite: false).ordered
// 899:
// 900:       installer.link(keg)
// 901:     end
// 902:   end
// 903:
// 904:   describe "#link_manual_command_warning" do
// 905:     let(:base_name) { "homebrew-versioned-formula" }
// 906:     let(:formula_name) { "#{base_name}@1.0" }
// 907:     let(:keg_only_formula) do
// 908:       formula formula_name do
// 909:         T.bind(self, T.class_of(Formula))
// 910:         url "foo-1.0"
// 911:         keg_only :versioned_formula
// 912:       end
// 913:     end
// 914:
// 915:     it "explains why a versioned formula was installed but not linked" do
// 916:       unversioned_formula = formula base_name do
// 917:         T.bind(self, T.class_of(Formula))
// 918:         url "foo-1.0"
// 919:       end
// 920:       allow(unversioned_formula).to receive_messages(any_version_installed?: true, linked?: true)
// 921:       allow(keg_only_formula).to receive_messages(any_version_installed?: false, linked?: false,
// 922:                                                   link_overwrite_formulae: [unversioned_formula])
// 923:
// 924:       installer = described_class.new(keg_only_formula, installed_on_request: true)
// 925:
// 926:       expect(installer.link_manual_command_warning).to eq <<~EOS
// 927:         #{formula_name} was installed but not linked because #{base_name} is already linked.
// 928:         To link this version, run:
// 929:           brew link #{formula_name}
// 930:       EOS
// 931:     end
// 932:   end
// 933:
// 934:   describe "#check_install_sanity" do
// 935:     it "raises on direct cyclic dependency" do
// 936:       ENV["HOMEBREW_DEVELOPER"] = "1"
// 937:
// 938:       dep_name = "homebrew-test-cyclic"
// 939:       dep_path = CoreTap.instance.new_formula_path(dep_name)
// 940:       dep_path.write <<~RUBY
// 941:         class #{Formulary.class_s(dep_name)} < Formula
// 942:           url "foo"
// 943:           version "0.1"
// 944:           depends_on "#{dep_name}"
// 945:         end
// 946:       RUBY
// 947:       f = Formulary.factory(dep_name)
// 948:
// 949:       fi = described_class.new(f)
// 950:
// 951:       expect do
// 952:         fi.check_install_sanity
// 953:       end.to raise_error(CannotInstallFormulaError)
// 954:     end
// 955:
// 956:     it "raises on indirect cyclic dependency" do
// 957:       ENV["HOMEBREW_DEVELOPER"] = "1"
// 958:
// 959:       formula1_name = "homebrew-test-formula1"
// 960:       formula2_name = "homebrew-test-formula2"
// 961:       formula1_path = CoreTap.instance.new_formula_path(formula1_name)
// 962:       formula1_path.write <<~RUBY
// 963:         class #{Formulary.class_s(formula1_name)} < Formula
// 964:           url "foo"
// 965:           version "0.1"
// 966:           depends_on "#{formula2_name}"
// 967:         end
// 968:       RUBY
// 969:       formula1 = Formulary.factory(formula1_name)
// 970:
// 971:       formula2_path = CoreTap.instance.new_formula_path(formula2_name)
// 972:       formula2_path.write <<~RUBY
// 973:         class #{Formulary.class_s(formula2_name)} < Formula
// 974:           url "foo"
// 975:           version "0.1"
// 976:           depends_on "#{formula1_name}"
// 977:         end
// 978:       RUBY
// 979:
// 980:       fi = described_class.new(formula1)
// 981:
// 982:       expect do
// 983:         fi.check_install_sanity
// 984:       end.to raise_error(CannotInstallFormulaError)
// 985:     end
// 986:
// 987:     it "raises on pinned dependency" do
// 988:       dep_name = "homebrew-test-dependency"
// 989:       dep_path = CoreTap.instance.new_formula_path(dep_name)
// 990:       dep_path.write <<~RUBY
// 991:         class #{Formulary.class_s(dep_name)} < Formula
// 992:           url "foo"
// 993:           version "0.2"
// 994:         end
// 995:       RUBY
// 996:
// 997:       dependency = Formulary.factory(dep_name)
// 998:
// 999:       dependent = formula do
// 1000:         T.bind(self, T.class_of(Formula))
// 1001:         url "foo"
// 1002:         version "0.5"
// 1003:         depends_on dependency.name.to_s
// 1004:       end
// 1005:
// 1006:       (dependency.prefix("0.1")/"bin"/"a").mkpath
// 1007:       HOMEBREW_PINNED_KEGS.mkpath
// 1008:       FileUtils.ln_s dependency.prefix("0.1"), HOMEBREW_PINNED_KEGS/dep_name
// 1009:
// 1010:       dependency_keg = Keg.new(dependency.prefix("0.1"))
// 1011:       dependency_keg.link
// 1012:
// 1013:       expect(dependency_keg).to be_linked
// 1014:       expect(dependency).to be_pinned
// 1015:
// 1016:       fi = described_class.new(dependent)
// 1017:
// 1018:       expect do
// 1019:         fi.check_install_sanity
// 1020:       end.to raise_error(CannotInstallFormulaError)
// 1021:     end
// 1022:   end
// 1023:
// 1024:   describe "#forbidden_license_check" do
// 1025:     it "raises on forbidden license on formula" do
// 1026:       ENV["HOMEBREW_FORBIDDEN_LICENSES"] = "AGPL-3.0"
// 1027:
// 1028:       f_name = "homebrew-forbidden-license"
// 1029:       f_path = CoreTap.instance.new_formula_path(f_name)
// 1030:       f_path.write <<~RUBY
// 1031:         class #{Formulary.class_s(f_name)} < Formula
// 1032:           url "foo"
// 1033:           version "0.1"
// 1034:           license "AGPL-3.0"
// 1035:         end
// 1036:       RUBY
// 1037:
// 1038:       f = Formulary.factory(f_name)
// 1039:       fi = described_class.new(f)
// 1040:
// 1041:       expect do
// 1042:         fi.forbidden_license_check
// 1043:       end.to raise_error(CannotInstallFormulaError, /#{f_name}'s licenses are all forbidden/)
// 1044:     end
// 1045:
// 1046:     it "raises on forbidden license on formula with contact instructions" do
// 1047:       ENV["HOMEBREW_FORBIDDEN_LICENSES"] = "AGPL-3.0"
// 1048:       ENV["HOMEBREW_FORBIDDEN_OWNER"] = owner = "your dog"
// 1049:       ENV["HOMEBREW_FORBIDDEN_OWNER_CONTACT"] = contact = "Woof loudly to get this unblocked."
// 1050:
// 1051:       f_name = "homebrew-forbidden-license"
// 1052:       f_path = CoreTap.instance.new_formula_path(f_name)
// 1053:       f_path.write <<~RUBY
// 1054:         class #{Formulary.class_s(f_name)} < Formula
// 1055:           url "foo"
// 1056:           version "0.1"
// 1057:           license "AGPL-3.0"
// 1058:         end
// 1059:       RUBY
// 1060:
// 1061:       f = Formulary.factory(f_name)
// 1062:       fi = described_class.new(f)
// 1063:
// 1064:       expect do
// 1065:         fi.forbidden_license_check
// 1066:       end.to raise_error(CannotInstallFormulaError, /#{owner}.+\n#{contact}/m)
// 1067:     end
// 1068:
// 1069:     it "raises on forbidden license on dependency" do
// 1070:       ENV["HOMEBREW_FORBIDDEN_LICENSES"] = "GPL-3.0"
// 1071:
// 1072:       dep_name = "homebrew-forbidden-dependency-license"
// 1073:       dep_path = CoreTap.instance.new_formula_path(dep_name)
// 1074:       dep_path.write <<~RUBY
// 1075:         class #{Formulary.class_s(dep_name)} < Formula
// 1076:           url "foo"
// 1077:           version "0.1"
// 1078:           license "GPL-3.0"
// 1079:         end
// 1080:       RUBY
// 1081:
// 1082:       f_name = "homebrew-forbidden-dependent-license"
// 1083:       f_path = CoreTap.instance.new_formula_path(f_name)
// 1084:       f_path.write <<~RUBY
// 1085:         class #{Formulary.class_s(f_name)} < Formula
// 1086:           url "foo"
// 1087:           version "0.1"
// 1088:           depends_on "#{dep_name}"
// 1089:         end
// 1090:       RUBY
// 1091:
// 1092:       f = Formulary.factory(f_name)
// 1093:       fi = described_class.new(f)
// 1094:
// 1095:       expect do
// 1096:         fi.forbidden_license_check
// 1097:       end.to raise_error(CannotInstallFormulaError, /dependency on #{dep_name} where all/)
// 1098:     end
// 1099:
// 1100:     it "raises on forbidden symbol license on formula" do
// 1101:       ENV["HOMEBREW_FORBIDDEN_LICENSES"] = "public_domain"
// 1102:
// 1103:       f_name = "homebrew-forbidden-license"
// 1104:       f_path = CoreTap.instance.new_formula_path(f_name)
// 1105:       f_path.write <<~RUBY
// 1106:         class #{Formulary.class_s(f_name)} < Formula
// 1107:           url "foo"
// 1108:           version "0.1"
// 1109:           license :public_domain
// 1110:         end
// 1111:       RUBY
// 1112:
// 1113:       f = Formulary.factory(f_name)
// 1114:       fi = described_class.new(f)
// 1115:
// 1116:       expect do
// 1117:         fi.forbidden_license_check
// 1118:       end.to raise_error(CannotInstallFormulaError, /#{f_name}'s licenses are all forbidden/)
// 1119:     end
// 1120:   end
// 1121:
// 1122:   describe "#forbidden_tap_check" do
// 1123:     before do
// 1124:       allow(Tap).to receive_messages(allowed_taps: allowed_taps_set, forbidden_taps: forbidden_taps_set)
// 1125:       allow(Homebrew::Trust).to receive(:trusted_tap?).and_return(true)
// 1126:     end
// 1127:
// 1128:     let(:homebrew_forbidden) { Tap.fetch("homebrew/forbidden") }
// 1129:     let(:allowed_third_party) { Tap.fetch("nothomebrew/allowed") }
// 1130:     let(:disallowed_third_party) { Tap.fetch("nothomebrew/notallowed") }
// 1131:     let(:allowed_taps_set) { [allowed_third_party.name] }
// 1132:     let(:forbidden_taps_set) { [homebrew_forbidden.name] }
// 1133:
// 1134:     it "raises on forbidden tap on formula" do
// 1135:       f_tap = homebrew_forbidden
// 1136:       f_name = "homebrew-forbidden-tap"
// 1137:       f_path = homebrew_forbidden.new_formula_path(f_name)
// 1138:       f_path.parent.mkpath
// 1139:       f_path.write <<~RUBY
// 1140:         class #{Formulary.class_s(f_name)} < Formula
// 1141:           url "foo"
// 1142:           version "0.1"
// 1143:         end
// 1144:       RUBY
// 1145:
// 1146:       f = Formulary.factory("#{f_tap}/#{f_name}")
// 1147:       fi = described_class.new(f)
// 1148:
// 1149:       expect do
// 1150:         fi.forbidden_tap_check
// 1151:       end.to raise_error(CannotInstallFormulaError, /has the tap #{f_tap}/)
// 1152:     ensure
// 1153:       FileUtils.rm_r(f_path.parent.parent)
// 1154:     end
// 1155:
// 1156:     it "raises on not allowed third-party tap on formula" do
// 1157:       f_tap = disallowed_third_party
// 1158:       f_name = "homebrew-not-allowed-tap"
// 1159:       f_path = disallowed_third_party.new_formula_path(f_name)
// 1160:       f_path.parent.mkpath
// 1161:       f_path.write <<~RUBY
// 1162:         class #{Formulary.class_s(f_name)} < Formula
// 1163:           url "foo"
// 1164:           version "0.1"
// 1165:         end
// 1166:       RUBY
// 1167:
// 1168:       f = Formulary.factory("#{f_tap}/#{f_name}")
// 1169:       fi = described_class.new(f)
// 1170:
// 1171:       expect do
// 1172:         fi.forbidden_tap_check
// 1173:       end.to raise_error(CannotInstallFormulaError, /has the tap #{f_tap}/)
// 1174:     ensure
// 1175:       FileUtils.rm_r(f_path.parent.parent.parent)
// 1176:     end
// 1177:
// 1178:     it "does not raise on allowed tap on formula" do
// 1179:       f_tap = allowed_third_party
// 1180:       f_name = "homebrew-allowed-tap"
// 1181:       f_path = allowed_third_party.new_formula_path(f_name)
// 1182:       f_path.parent.mkpath
// 1183:       f_path.write <<~RUBY
// 1184:         class #{Formulary.class_s(f_name)} < Formula
// 1185:           url "foo"
// 1186:           version "0.1"
// 1187:         end
// 1188:       RUBY
// 1189:
// 1190:       f = Formulary.factory("#{f_tap}/#{f_name}")
// 1191:       fi = described_class.new(f)
// 1192:
// 1193:       expect { fi.forbidden_tap_check }.not_to raise_error
// 1194:     ensure
// 1195:       FileUtils.rm_r(f_path.parent.parent.parent)
// 1196:     end
// 1197:
// 1198:     it "raises on forbidden tap on dependency" do
// 1199:       dep_tap = homebrew_forbidden
// 1200:       dep_name = "homebrew-forbidden-dependency-tap"
// 1201:       dep_path = homebrew_forbidden.new_formula_path(dep_name)
// 1202:       dep_path.parent.mkpath
// 1203:       dep_path.write <<~RUBY
// 1204:         class #{Formulary.class_s(dep_name)} < Formula
// 1205:           url "foo"
// 1206:           version "0.1"
// 1207:         end
// 1208:       RUBY
// 1209:
// 1210:       f_name = "homebrew-forbidden-dependent-tap"
// 1211:       f_path = CoreTap.instance.new_formula_path(f_name)
// 1212:       f_path.write <<~RUBY
// 1213:         class #{Formulary.class_s(f_name)} < Formula
// 1214:           url "foo"
// 1215:           version "0.1"
// 1216:           depends_on "#{dep_name}"
// 1217:         end
// 1218:       RUBY
// 1219:
// 1220:       f = Formulary.factory(f_name)
// 1221:       fi = described_class.new(f)
// 1222:
// 1223:       expect do
// 1224:         fi.forbidden_tap_check
// 1225:       end.to raise_error(CannotInstallFormulaError, /from the #{dep_tap} tap but/)
// 1226:     ensure
// 1227:       FileUtils.rm_r(dep_path.parent.parent)
// 1228:     end
// 1229:   end
// 1230:
// 1231:   describe "#forbidden_formula_check" do
// 1232:     it "raises on forbidden formula" do
// 1233:       ENV["HOMEBREW_FORBIDDEN_FORMULAE"] = f_name = "homebrew-forbidden-formula"
// 1234:       f_path = CoreTap.instance.new_formula_path(f_name)
// 1235:       f_path.write <<~RUBY
// 1236:         class #{Formulary.class_s(f_name)} < Formula
// 1237:           url "foo"
// 1238:           version "0.1"
// 1239:         end
// 1240:       RUBY
// 1241:
// 1242:       f = Formulary.factory(f_name)
// 1243:       fi = described_class.new(f)
// 1244:
// 1245:       expect do
// 1246:         fi.forbidden_formula_check
// 1247:       end.to raise_error(CannotInstallFormulaError, /#{f_name} was forbidden/)
// 1248:     end
// 1249:
// 1250:     it "raises on forbidden dependency" do
// 1251:       ENV["HOMEBREW_FORBIDDEN_FORMULAE"] = dep_name = "homebrew-forbidden-dependency-formula"
// 1252:       dep_path = CoreTap.instance.new_formula_path(dep_name)
// 1253:       dep_path.write <<~RUBY
// 1254:         class #{Formulary.class_s(dep_name)} < Formula
// 1255:           url "foo"
// 1256:           version "0.1"
// 1257:         end
// 1258:       RUBY
// 1259:
// 1260:       f_name = "homebrew-forbidden-dependent-formula"
// 1261:       f_path = CoreTap.instance.new_formula_path(f_name)
// 1262:       f_path.write <<~RUBY
// 1263:         class #{Formulary.class_s(f_name)} < Formula
// 1264:           url "foo"
// 1265:           version "0.1"
// 1266:           depends_on "#{dep_name}"
// 1267:         end
// 1268:       RUBY
// 1269:
// 1270:       f = Formulary.factory(f_name)
// 1271:       fi = described_class.new(f)
// 1272:
// 1273:       expect do
// 1274:         fi.forbidden_formula_check
// 1275:       end.to raise_error(CannotInstallFormulaError, /#{dep_name} formula was forbidden/)
// 1276:     end
// 1277:   end
// 1278:
// 1279:   describe "#prelude_fetch" do
// 1280:     context "with an API-loaded bottled formula" do
// 1281:       let(:deno_formula) do
// 1282:         formula("deno") do
// 1283:           T.bind(self, T.class_of(Formula))
// 1284:           url "https://brew.sh/deno-2.7.11.tar.gz"
// 1285:         end
// 1286:       end
// 1287:       let(:formula_struct) do
// 1288:         Homebrew::API::FormulaStruct.new(
// 1289:           bottle_checksums:     [
// 1290:             {
// 1291:               cellar:                  :any_skip_relocation,
// 1292:               Utils::Bottles.tag.to_sym => "d7b9f4e8bf83608b71fe958a99f19f2e5e68bb2582965d32e41759c24f1aef97",
// 1293:             },
// 1294:           ],
// 1295:           bottle_present:       true,
// 1296:           desc:                 "deno",
// 1297:           homepage:             "https://brew.sh",
// 1298:           license:              "MIT",
// 1299:           ruby_source_checksum: "abc123",
// 1300:           stable_present:       true,
// 1301:           stable_version:       "2.7.11",
// 1302:         )
// 1303:       end
// 1304:       let(:installer) do
// 1305:         installer = described_class.new(deno_formula, ignore_deps: true)
// 1306:         installer.download_queue = instance_double(Homebrew::DownloadQueue)
// 1307:         installer
// 1308:       end
// 1309:
// 1310:       before do
// 1311:         allow(deno_formula).to receive_messages(
// 1312:           bottle_tag?:               true,
// 1313:           core_formula?:             true,
// 1314:           loaded_from_internal_api?: true,
// 1315:           pour_bottle?:              true,
// 1316:         )
// 1317:         allow(Homebrew::API::Internal).to receive(:formula_struct).with("deno").and_return(formula_struct)
// 1318:       end
// 1319:
// 1320:       it "uses API bottle metadata to enqueue the manifest and bottle" do
// 1321:         expect(deno_formula).not_to receive(:bottle_for_tag)
// 1322:         expect(deno_formula).not_to receive(:bottle)
// 1323:         expect(installer.download_queue).to receive(:enqueue).with(an_instance_of(Resource::BottleManifest))
// 1324:         expect(installer.download_queue).to receive(:enqueue)
// 1325:           .with(an_instance_of(Bottle), check_attestation: false, stage: true)
// 1326:
// 1327:         installer.prelude_fetch
// 1328:       end
// 1329:
// 1330:       it "enqueues only the bottle manifest when fetching metadata" do
// 1331:         expect(installer.download_queue).to receive(:enqueue).with(an_instance_of(Resource::BottleManifest))
// 1332:
// 1333:         installer.prelude_fetch(metadata_only: true)
// 1334:       end
// 1335:
// 1336:       it "enqueues the bottle without repeating metadata work after a metadata-only run" do
// 1337:         expect(installer.download_queue).to receive(:enqueue).with(an_instance_of(Resource::BottleManifest)).once
// 1338:
// 1339:         installer.prelude_fetch(metadata_only: true)
// 1340:
// 1341:         expect(installer.download_queue).to receive(:enqueue)
// 1342:           .with(an_instance_of(Bottle), check_attestation: false, stage: true)
// 1343:
// 1344:         installer.prelude_fetch
// 1345:       end
// 1346:     end
// 1347:
// 1348:     it "does not repeat source download prelude work" do
// 1349:       f = formula("homebrew-prelude-fetch-once") do
// 1350:         T.bind(self, T.class_of(Formula))
// 1351:         url "https://brew.sh/prelude-fetch-once-0.1.tar.gz"
// 1352:       end
// 1353:       allow(f).to receive(:loaded_from_api?).and_return(true)
// 1354:       fi = described_class.new(f, ignore_deps: true)
// 1355:       fi.download_queue = instance_double(Homebrew::DownloadQueue)
// 1356:
// 1357:       expect(Homebrew::API::Formula).to receive(:source_download)
// 1358:         .with(f, download_queue: fi.download_queue, enqueue: true)
// 1359:         .once
// 1360:
// 1361:       fi.prelude_fetch
// 1362:       fi.prelude_fetch
// 1363:     end
// 1364:
// 1365:     it "raises on forbidden formula tap before fetching the source from the API" do
// 1366:       homebrew_forbidden = Tap.fetch("homebrew/forbidden")
// 1367:       allow(Tap).to receive_messages(allowed_taps: [], forbidden_taps: [homebrew_forbidden.name])
// 1368:       f_name = "homebrew-forbidden-fail-fast-tap"
// 1369:       f_path = homebrew_forbidden.new_formula_path(f_name)
// 1370:       f_path.parent.mkpath
// 1371:       f_path.write <<~RUBY
// 1372:         class #{Formulary.class_s(f_name)} < Formula
// 1373:           url "foo"
// 1374:           version "0.1"
// 1375:         end
// 1376:       RUBY
// 1377:
// 1378:       f = Formulary.factory("#{homebrew_forbidden}/#{f_name}")
// 1379:       allow(f).to receive(:loaded_from_api?).and_return(true)
// 1380:       fi = described_class.new(f)
// 1381:
// 1382:       expect(Homebrew::API::Formula).not_to receive(:source_download)
// 1383:
// 1384:       expect { fi.prelude_fetch }.to raise_error(CannotInstallFormulaError, /has the tap #{homebrew_forbidden}/)
// 1385:     ensure
// 1386:       FileUtils.rm_r(f_path.parent.parent)
// 1387:     end
// 1388:
// 1389:     it "raises on forbidden formula before fetching the source from the API" do
// 1390:       ENV["HOMEBREW_FORBIDDEN_FORMULAE"] = f_name = "homebrew-forbidden-fail-fast-formula"
// 1391:       f_path = CoreTap.instance.new_formula_path(f_name)
// 1392:       f_path.write <<~RUBY
// 1393:         class #{Formulary.class_s(f_name)} < Formula
// 1394:           url "foo"
// 1395:           version "0.1"
// 1396:         end
// 1397:       RUBY
// 1398:
// 1399:       f = Formulary.factory(f_name)
// 1400:       allow(f).to receive(:loaded_from_api?).and_return(true)
// 1401:       fi = described_class.new(f)
// 1402:
// 1403:       expect(Homebrew::API::Formula).not_to receive(:source_download)
// 1404:
// 1405:       expect { fi.prelude_fetch }.to raise_error(CannotInstallFormulaError, /was forbidden/)
// 1406:     end
// 1407:   end
// 1408:
// 1409:   specify "install fails with BuildError when a system() call fails" do
// 1410:     ENV["HOMEBREW_TEST_NO_EXIT_CLEANUP"] = "1"
// 1411:     ENV["FAILBALL_BUILD_ERROR"] = "1"
// 1412:
// 1413:     expect do
// 1414:       temporary_install(Failball.new)
// 1415:     end.to raise_error(BuildError)
// 1416:   end
// 1417:
// 1418:   specify "install fails with a RuntimeError when #install raises" do
// 1419:     ENV["HOMEBREW_TEST_NO_EXIT_CLEANUP"] = "1"
// 1420:
// 1421:     expect do
// 1422:       temporary_install(Failball.new)
// 1423:     end.to raise_error(RuntimeError)
// 1424:   end
// 1425:
// 1426:   describe "#caveats" do
// 1427:     subject(:formula_installer) { described_class.new(Testball.new) }
// 1428:
// 1429:     it "shows audit problems if HOMEBREW_DEVELOPER is set" do
// 1430:       ENV["HOMEBREW_DEVELOPER"] = "1"
// 1431:       with_env(HOMEBREW_NO_INSTALL_FROM_API: "1") do
// 1432:         formula_installer.fetch
// 1433:         formula_installer.install
// 1434:       end
// 1435:       expect(formula_installer).to receive(:audit_installed).and_call_original
// 1436:       formula_installer.caveats
// 1437:     end
// 1438:   end
// 1439:
// 1440:   describe "#install_service" do
// 1441:     it "works if service is set" do
// 1442:       formula = Testball.new
// 1443:       service = Homebrew::Service.new(formula)
// 1444:       launchd_service_path = formula.launchd_service_path
// 1445:       service_path = formula.systemd_service_path
// 1446:       formula.opt_prefix.mkpath
// 1447:
// 1448:       expect(formula).to receive(:service?).and_return(true)
// 1449:       expect(formula).to receive(:service).at_least(:once).and_return(service)
// 1450:       expect(formula).to receive(:launchd_service_path).and_call_original
// 1451:       expect(formula).to receive(:systemd_service_path).and_call_original
// 1452:
// 1453:       expect(service).to receive(:timed?).and_return(false)
// 1454:       expect(service).to receive(:command?).and_return(true)
// 1455:       expect(service).to receive(:to_plist).and_return("plist")
// 1456:       expect(service).to receive(:to_systemd_unit).and_return("unit")
// 1457:
// 1458:       installer = described_class.new(formula)
// 1459:       expect do
// 1460:         installer.install_service
// 1461:       end.not_to output(/Error: Failed to install service files/).to_stderr
// 1462:
// 1463:       expect(launchd_service_path).to exist
// 1464:       expect(service_path).to exist
// 1465:     end
// 1466:
// 1467:     it "works if timed service is set" do
// 1468:       formula = Testball.new
// 1469:       service = Homebrew::Service.new(formula)
// 1470:       launchd_service_path = formula.launchd_service_path
// 1471:       service_path = formula.systemd_service_path
// 1472:       timer_path = formula.systemd_timer_path
// 1473:       formula.opt_prefix.mkpath
// 1474:
// 1475:       expect(formula).to receive(:service?).and_return(true)
// 1476:       expect(formula).to receive(:service).at_least(:once).and_return(service)
// 1477:       expect(formula).to receive(:launchd_service_path).and_call_original
// 1478:       expect(formula).to receive(:systemd_service_path).and_call_original
// 1479:       expect(formula).to receive(:systemd_timer_path).and_call_original
// 1480:
// 1481:       expect(service).to receive(:timed?).and_return(true)
// 1482:       expect(service).to receive(:command?).and_return(true)
// 1483:       expect(service).to receive(:to_plist).and_return("plist")
// 1484:       expect(service).to receive(:to_systemd_unit).and_return("unit")
// 1485:       expect(service).to receive(:to_systemd_timer).and_return("timer")
// 1486:
// 1487:       installer = described_class.new(formula)
// 1488:       expect do
// 1489:         installer.install_service
// 1490:       end.not_to output(/Error: Failed to install service files/).to_stderr
// 1491:
// 1492:       expect(launchd_service_path).to exist
// 1493:       expect(service_path).to exist
// 1494:       expect(timer_path).to exist
// 1495:     end
// 1496:
// 1497:     it "returns without definition" do
// 1498:       formula = Testball.new
// 1499:       path = formula.launchd_service_path
// 1500:       formula.opt_prefix.mkpath
// 1501:
// 1502:       expect(formula).to receive(:service?).and_return(nil)
// 1503:       expect(formula).not_to receive(:launchd_service_path)
// 1504:
// 1505:       installer = described_class.new(formula)
// 1506:       expect do
// 1507:         installer.install_service
// 1508:       end.not_to output(/Error: Failed to install service files/).to_stderr
// 1509:
// 1510:       expect(path).not_to exist
// 1511:     end
// 1512:   end
// 1513:
// 1514:   describe "#build" do
// 1515:     it "attempts source download when formula is loaded from API" do
// 1516:       formula = Testball.new
// 1517:       allow(formula).to receive(:loaded_from_api?).and_return(true)
// 1518:
// 1519:       source_formula = Testball.new
// 1520:       allow(source_formula).to receive(:loaded_from_api?).and_return(false)
// 1521:
// 1522:       expect(Homebrew::API::Formula).to receive(:source_download_formula)
// 1523:         .with(formula)
// 1524:         .and_return(source_formula)
// 1525:
// 1526:       installer = described_class.new(formula)
// 1527:
// 1528:       # Stub out the actual build subprocess since we only care about the guard
// 1529:       allow(installer).to receive(:build_argv).and_return([])
// 1530:       allow(Sandbox).to receive(:run_or_fork)
// 1531:       allow(source_formula).to receive_messages(logs: mktmpdir, update_head_version: nil, prefix: mktmpdir,
// 1532:                                                 network_access_allowed?: true)
// 1533:       allow(Keg).to receive(:new).and_return(instance_double(Keg, empty_installation?: false))
// 1534:
// 1535:       installer.build
// 1536:
// 1537:       expect(installer.formula).to eq(source_formula)
// 1538:     end
// 1539:
// 1540:     it "raises when formula is loaded from API and source download fails" do
// 1541:       formula = Testball.new
// 1542:       allow(formula).to receive(:loaded_from_api?).and_return(true)
// 1543:
// 1544:       expect(Homebrew::API::Formula).to receive(:source_download_formula)
// 1545:         .with(formula)
// 1546:         .and_raise(CannotInstallFormulaError, "source code not found")
// 1547:
// 1548:       installer = described_class.new(formula)
// 1549:
// 1550:       expect do
// 1551:         installer.build
// 1552:       end.to raise_error(CannotInstallFormulaError, /source code not found/)
// 1553:     end
// 1554:
// 1555:     it "exposes local formula and trust paths to the sandbox" do
// 1556:       formula_path = mktmpdir/"homebrew-local-formula.rb"
// 1557:       FileUtils.touch formula_path
// 1558:       formula = formula("homebrew-local-formula", path: formula_path) do
// 1559:         T.bind(self, T.class_of(Formula))
// 1560:         url "foo"
// 1561:         version "1.0"
// 1562:       end
// 1563:       installer = described_class.new(formula)
// 1564:       sandbox = instance_double(Sandbox)
// 1565:
// 1566:       allow(installer).to receive(:build_argv).and_return([])
// 1567:       allow(Sandbox).to receive_messages(available?: true, new: sandbox)
// 1568:       allow(sandbox).to receive_messages(record_log: nil, allow_read_if_exists: nil, allow_write_temp_and_cache: nil,
// 1569:                                          allow_write_log: nil, allow_cvs: nil, allow_fossil: nil,
// 1570:                                          allow_write_xcode: nil, allow_write_cellar: nil, deny_read_home: nil,
// 1571:                                          run: nil)
// 1572:       allow(formula).to receive_messages(logs: mktmpdir, update_head_version: nil, prefix: mktmpdir,
// 1573:                                          network_access_allowed?: true)
// 1574:       allow(Keg).to receive(:new).and_return(instance_double(Keg, empty_installation?: false))
// 1575:
// 1576:       expect(sandbox).to receive(:allow_read_if_exists).with(path: formula_path).ordered
// 1577:       expect(sandbox).to receive(:allow_read_if_exists).with(path: Homebrew::Trust.trust_file).ordered
// 1578:
// 1579:       with_env(HOMEBREW_REQUIRE_TAP_TRUST: "1") do
// 1580:         installer.build
// 1581:       end
// 1582:     end
// 1583:   end
// 1584: end
