module shared_context

// Translated from Homebrew/brew `test/support/helper/spec/shared_context/homebrew_cask.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/config"
// 5: require "cask/cache"
// 6:
// 7: require "test/support/helper/cask/install_helper"
// 8: require "test/support/helper/cask/never_sudo_system_command"
// 9:
// 10: module Cask
// 11:   class Config
// 12:     DEFAULT_DIRS_PATHNAMES = {
// 13:       appdir:               Pathname(TEST_TMPDIR)/"cask-appdir",
// 14:       appimagedir:          Pathname(TEST_TMPDIR)/"cask-appimagedir",
// 15:       keyboard_layoutdir:   Pathname(TEST_TMPDIR)/"cask-keyboard-layoutdir",
// 16:       prefpanedir:          Pathname(TEST_TMPDIR)/"cask-prefpanedir",
// 17:       qlplugindir:          Pathname(TEST_TMPDIR)/"cask-qlplugindir",
// 18:       mdimporterdir:        Pathname(TEST_TMPDIR)/"cask-mdimporter",
// 19:       dictionarydir:        Pathname(TEST_TMPDIR)/"cask-dictionarydir",
// 20:       fontdir:              Pathname(TEST_TMPDIR)/"cask-fontdir",
// 21:       colorpickerdir:       Pathname(TEST_TMPDIR)/"cask-colorpickerdir",
// 22:       servicedir:           Pathname(TEST_TMPDIR)/"cask-servicedir",
// 23:       input_methoddir:      Pathname(TEST_TMPDIR)/"cask-input_methoddir",
// 24:       internet_plugindir:   Pathname(TEST_TMPDIR)/"cask-internet_plugindir",
// 25:       audio_unit_plugindir: Pathname(TEST_TMPDIR)/"cask-audio_unit_plugindir",
// 26:       vst_plugindir:        Pathname(TEST_TMPDIR)/"cask-vst_plugindir",
// 27:       vst3_plugindir:       Pathname(TEST_TMPDIR)/"cask-vst3_plugindir",
// 28:       screen_saverdir:      Pathname(TEST_TMPDIR)/"cask-screen_saverdir",
// 29:     }.freeze
// 30:
// 31:     remove_const :DEFAULT_DIRS
// 32:     DEFAULT_DIRS = DEFAULT_DIRS_PATHNAMES.transform_values(&:to_s).freeze
// 33:   end
// 34: end
// 35:
// 36: # These shared contexts starting with `when` don't make sense.
// 37: RSpec.shared_context "Homebrew Cask", :needs_macos do # rubocop:disable RSpec/ContextWording
// 38:   T.bind(self, T.class_of(RSpec::Core::ExampleGroup))
// 39:
// 40:   around do |example|
// 41:     third_party_tap = Tap.fetch("third-party", "tap")
// 42:
// 43:     begin
// 44:       Cask::Config::DEFAULT_DIRS_PATHNAMES.each_value(&:mkpath)
// 45:
// 46:       CoreCaskTap.instance.tap do |tap|
// 47:         fixture_cask_dir = TEST_FIXTURE_DIR/"cask/Casks"
// 48:         fixture_cask_dir.glob("**/*.rb").each do |fixture_cask_path|
// 49:           relative_cask_path = fixture_cask_path.relative_path_from(fixture_cask_dir)
// 50:
// 51:           # These are only used manually in tests since they
// 52:           # would otherwise conflict with other casks.
// 53:           next if relative_cask_path.dirname.basename.to_s == "outdated"
// 54:
// 55:           cask_dir = (tap.cask_dir/relative_cask_path.dirname).tap(&:mkpath)
// 56:           FileUtils.ln_sf fixture_cask_path, cask_dir
// 57:         end
// 58:
// 59:         tap.clear_cache
// 60:       end
// 61:
// 62:       third_party_tap.tap do |tap|
// 63:         tap.path.parent.mkpath
// 64:         FileUtils.ln_sf TEST_FIXTURE_DIR/"third-party", tap.path
// 65:
// 66:         tap.clear_cache
// 67:       end
// 68:
// 69:       example.run
// 70:     ensure
// 71:       FileUtils.rm_rf Cask::Config::DEFAULT_DIRS_PATHNAMES.values
// 72:       FileUtils.rm_rf [Cask::Config.new.binarydir, Cask::Caskroom.path, Cask::Cache.path]
// 73:       FileUtils.rm_rf CoreCaskTap.instance.path
// 74:       FileUtils.rm_rf third_party_tap.path
// 75:       FileUtils.rm_rf third_party_tap.path.parent
// 76:     end
// 77:   end
// 78: end
// 79:
// 80: RSpec.configure do |config|
// 81:   config.include_context "Homebrew Cask", :cask
// 82: end
