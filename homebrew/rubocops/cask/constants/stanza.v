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
