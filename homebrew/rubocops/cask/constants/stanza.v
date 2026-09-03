module constants

// Translated from Homebrew/brew `rubocops/cask/constants/stanza.rb` at
// df30fd34cc7132abfb8dbe3b1d046e3d48a57d00.

// MacOSVersion::SYMBOLS is insertion ordered from newest to oldest in the pinned
// source. ON_SYSTEM_METHODS preserves that order.
pub const on_system_methods = ['on_arm', 'on_intel', 'on_golden_gate', 'on_tahoe', 'on_sequoia',
	'on_sonoma', 'on_ventura', 'on_monterey', 'on_big_sur', 'on_catalina', 'on_macos', 'on_linux']

// Cask stanza ordering intentionally puts the oldest macOS block first because
// that is the more common ordering in casks.
pub const on_system_methods_stanza_order = ['on_arm', 'on_intel', 'on_catalina', 'on_big_sur',
	'on_monterey', 'on_ventura', 'on_sonoma', 'on_sequoia', 'on_tahoe', 'on_golden_gate', 'on_macos',
	'on_linux']

pub const stanza_order = ['arch', 'on_arch_conditional', 'os', 'on_system_conditional', 'version',
	'sha256', 'on_arm', 'on_intel', 'on_catalina', 'on_big_sur', 'on_monterey', 'on_ventura',
	'on_sonoma', 'on_sequoia', 'on_tahoe', 'on_golden_gate', 'on_macos', 'on_linux', 'language',
	'url', 'appcast', 'name', 'desc', 'homepage', 'livecheck', 'no_autobump!', 'deprecate!',
	'disable!', 'auto_updates', 'conflicts_with', 'depends_on', 'container', 'rename', 'suite',
	'app', 'app_image', 'pkg', 'generated_script', 'installer', 'binary', 'command_wrapper', 'manpage',
	'bash_completion', 'fish_completion', 'zsh_completion', 'generate_completions_from_executable',
	'colorpicker', 'dictionary', 'font', 'input_method', 'internet_plugin', 'keyboard_layout',
	'prefpane', 'qlplugin', 'mdimporter', 'screen_saver', 'service', 'audio_unit_plugin', 'vst_plugin',
	'vst3_plugin', 'artifact', 'stage_only', 'preflight_steps', 'preflight', 'postflight_steps',
	'postflight', 'uninstall_preflight_steps', 'uninstall_preflight', 'uninstall_postflight_steps',
	'uninstall_postflight', 'uninstall', 'zap', 'caveats']

pub const uninstall_methods_order = ['early_script', 'launchctl', 'quit', 'signal', 'login_item',
	'kext', 'script', 'pkgutil', 'delete', 'trash', 'rmdir']

pub fn stanza_groups() [][]string {
	return [
		['arch', 'on_arch_conditional', 'os', 'on_system_conditional'],
		['version', 'sha256'],
		on_system_methods_stanza_order.clone(),
		['language'],
		['url', 'appcast', 'name', 'desc', 'homepage'],
		['livecheck'],
		['no_autobump!'],
		['deprecate!', 'disable!'],
		['auto_updates', 'conflicts_with', 'depends_on', 'container'],
		['rename'],
		['suite', 'app', 'app_image', 'pkg', 'generated_script', 'installer', 'binary',
			'command_wrapper', 'manpage', 'bash_completion', 'fish_completion', 'zsh_completion',
			'generate_completions_from_executable', 'colorpicker', 'dictionary', 'font',
			'input_method', 'internet_plugin', 'keyboard_layout', 'prefpane', 'qlplugin', 'mdimporter',
			'screen_saver', 'service', 'audio_unit_plugin', 'vst_plugin', 'vst3_plugin', 'artifact',
			'stage_only'],
		['preflight_steps', 'preflight'],
		['postflight_steps', 'postflight'],
		['uninstall_preflight_steps', 'uninstall_preflight'],
		['uninstall_postflight_steps', 'uninstall_postflight'],
		['uninstall'],
		['zap'],
		['caveats'],
	]
}

pub fn stanza_group_hash() map[string][]string {
	mut groups_by_stanza := map[string][]string{}
	for group in stanza_groups() {
		for stanza in group {
			groups_by_stanza[stanza] = group.clone()
		}
	}
	return groups_by_stanza
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cask
// 6:     # Constants available globally for use in all cask cops.
// 7:     module Constants
// 8:       ON_SYSTEM_METHODS = T.let(
// 9:         [:arm, :intel, *MacOSVersion::SYMBOLS.keys, :macos, :linux].map { |option| :"on_#{option}" }.freeze,
// 10:         T::Array[Symbol],
// 11:       )
// 12:       ON_SYSTEM_METHODS_STANZA_ORDER = T.let(
// 13:         [
// 14:           :arm,
// 15:           :intel,
// 16:           *MacOSVersion::SYMBOLS.reverse_each.to_h.keys, # Oldest OS blocks first since that's more common in Casks.
// 17:           :macos,
// 18:           :linux,
// 19:         ].map { |option, _| :"on_#{option}" }.freeze,
// 20:         T::Array[Symbol],
// 21:       )
// 22:
// 23:       STANZA_GROUPS = T.let(
// 24:         [
// 25:           [:arch, :on_arch_conditional, :os, :on_system_conditional],
// 26:           [:version, :sha256],
// 27:           ON_SYSTEM_METHODS_STANZA_ORDER,
// 28:           [:language],
// 29:           [:url, :appcast, :name, :desc, :homepage],
// 30:           [:livecheck],
// 31:           [:no_autobump!],
// 32:           [:deprecate!, :disable!],
// 33:           [
// 34:             :auto_updates,
// 35:             :conflicts_with,
// 36:             :depends_on,
// 37:             :container,
// 38:           ],
// 39:           [
// 40:             :rename,
// 41:           ],
// 42:           [
// 43:             :suite,
// 44:             :app,
// 45:             :app_image,
// 46:             :pkg,
// 47:             :generated_script,
// 48:             :installer,
// 49:             :binary,
// 50:             :command_wrapper,
// 51:             :manpage,
// 52:             :bash_completion,
// 53:             :fish_completion,
// 54:             :zsh_completion,
// 55:             :generate_completions_from_executable,
// 56:             :colorpicker,
// 57:             :dictionary,
// 58:             :font,
// 59:             :input_method,
// 60:             :internet_plugin,
// 61:             :keyboard_layout,
// 62:             :prefpane,
// 63:             :qlplugin,
// 64:             :mdimporter,
// 65:             :screen_saver,
// 66:             :service,
// 67:             :audio_unit_plugin,
// 68:             :vst_plugin,
// 69:             :vst3_plugin,
// 70:             :artifact,
// 71:             :stage_only,
// 72:           ],
// 73:           [:preflight_steps, :preflight],
// 74:           [:postflight_steps, :postflight],
// 75:           [:uninstall_preflight_steps, :uninstall_preflight],
// 76:           [:uninstall_postflight_steps, :uninstall_postflight],
// 77:           [:uninstall],
// 78:           [:zap],
// 79:           [:caveats],
// 80:         ].freeze,
// 81:         T::Array[T::Array[Symbol]],
// 82:       )
// 83:
// 84:       STANZA_GROUP_HASH = T.let(
// 85:         STANZA_GROUPS.each_with_object({}) do |stanza_group, hash|
// 86:           stanza_group.each { |stanza| hash[stanza] = stanza_group }
// 87:         end.freeze,
// 88:         T::Hash[Symbol, T::Array[Symbol]],
// 89:       )
// 90:
// 91:       STANZA_ORDER = T.let(STANZA_GROUPS.flatten.freeze, T::Array[Symbol])
// 92:
// 93:       UNINSTALL_METHODS_ORDER = [
// 94:         :early_script,
// 95:         :launchctl,
// 96:         :quit,
// 97:         :signal,
// 98:         :login_item,
// 99:         :kext,
// 100:         :script,
// 101:         :pkgutil,
// 102:         :delete,
// 103:         :trash,
// 104:         :rmdir,
// 105:       ].freeze
// 106:     end
// 107:   end
// 108: end
