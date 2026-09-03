module homebrew

import os

// Translated from Homebrew/brew `env_config.rb`.
// The original source is retained below for source parity.
pub enum EnvConfigBooleanMode {
	none
	falsey_values
	set
}

pub struct EnvConfigEntry {
pub:
	description        string
	default_text       string
	has_default        bool
	default_value      string
	default_is_boolean bool
	default_boolean    bool
	boolean_mode       EnvConfigBooleanMode
	disabled_by        string
	hidden             bool
	odeprecated        bool
	odisabled          bool
	replacement        string
	replacement_env    bool
	commands           []string
	subcommands        []string
}

pub struct EnvBundleExtension {
pub:
	type_name              string
	banner_name            string
	cleanup_supported      bool
	dump_disable_supported bool
}

pub struct EnvConfigDeprecation {
pub:
	environment string
	replacement string
	disabled    bool
}

pub struct EnvConfigDeprecationOutcome {
pub:
	applies     bool
	deprecation EnvConfigDeprecation
}

pub struct EnvConfigValue {
pub:
	present bool
	value   string
}

pub struct EnvConfigBundleJobs {
pub:
	present  bool
	value    string
	warnings []string
}

pub struct EnvConfigState {
pub:
	cpu_cores                    int = 1
	home_directory               string
	api_default_domain           string = 'https://formulae.brew.sh/api'
	bottle_default_domain        string = 'https://ghcr.io/v2/homebrew/core'
	brew_default_git_remote      string = 'https://github.com/Homebrew/brew'
	core_default_git_remote      string = 'https://github.com/Homebrew/homebrew-core'
	default_cache                string
	default_logs                 string
	default_temp                 string
	user_config_home             string
	raise_deprecation_exceptions bool
pub mut:
	values            map[string]string
	settings          map[string]string
	warned_deprecated []string
	deprecations      []EnvConfigDeprecation
}

const env_config_falsy_values = ['false', 'no', 'off', 'nil', '0']

pub fn env_config_bundle_extensions() []EnvBundleExtension {
	return [
		EnvBundleExtension{ type_name: 'cargo', banner_name: 'Cargo packages', cleanup_supported: true, dump_disable_supported: true },
		EnvBundleExtension{ type_name: 'flatpak', banner_name: 'Flatpak packages', cleanup_supported: true, dump_disable_supported: true },
		EnvBundleExtension{ type_name: 'go', banner_name: 'Go packages', cleanup_supported: true, dump_disable_supported: true },
		EnvBundleExtension{ type_name: 'krew', banner_name: 'Krew plugins', cleanup_supported: true, dump_disable_supported: true },
		EnvBundleExtension{ type_name: 'mas', banner_name: 'Mac App Store dependencies', cleanup_supported: true, dump_disable_supported: true },
		EnvBundleExtension{ type_name: 'npm', banner_name: 'npm packages', cleanup_supported: true, dump_disable_supported: true },
		EnvBundleExtension{ type_name: 'uv', banner_name: 'uv tools', cleanup_supported: true, dump_disable_supported: true },
		EnvBundleExtension{ type_name: 'vscode', banner_name: 'VSCode (and forks/variants) extensions', cleanup_supported: true, dump_disable_supported: true },
		EnvBundleExtension{ type_name: 'winget', banner_name: 'WinGet packages', cleanup_supported: true, dump_disable_supported: true },
	]
}

pub fn env_config_names_for_extensions(extensions []EnvBundleExtension) []string {
	mut names := [
		'HOMEBREW_ALLOWED_TAPS',
		'HOMEBREW_API_AUTO_UPDATE_SECS',
		'HOMEBREW_API_DOMAIN',
		'HOMEBREW_ARCH',
		'HOMEBREW_ARTIFACT_DOMAIN',
		'HOMEBREW_ARTIFACT_DOMAIN_NO_FALLBACK',
		'HOMEBREW_ASK',
		'HOMEBREW_AUTO_UPDATE_QUIET',
		'HOMEBREW_AUTO_UPDATE_SECS',
		'HOMEBREW_AVOID_NESTED_SANDBOXING',
		'HOMEBREW_BAT',
		'HOMEBREW_BAT_CONFIG_PATH',
		'HOMEBREW_BAT_THEME',
		'HOMEBREW_BOTTLE_DOMAIN',
		'HOMEBREW_BREW_GIT_REMOTE',
		'HOMEBREW_BROWSER',
		'HOMEBREW_BUNDLE_DESCRIBE',
		'HOMEBREW_BUNDLE_DUMP_DESCRIBE',
		'HOMEBREW_BUNDLE_FORCE_INSTALL_CLEANUP',
		'HOMEBREW_BUNDLE_INSTALL_CLEANUP',
		'HOMEBREW_BUNDLE_JOBS',
		'HOMEBREW_BUNDLE_NO_DESCRIBE',
		'HOMEBREW_BUNDLE_NO_JOBS',
		'HOMEBREW_BUNDLE_NO_SECRETS',
		'HOMEBREW_BUNDLE_SECRETS',
		'HOMEBREW_BUNDLE_USER_CACHE',
		'HOMEBREW_CACHE',
		'HOMEBREW_CASK_OPTS',
		'HOMEBREW_CASK_OPTS_BINARIES',
		'HOMEBREW_CASK_OPTS_REQUIRE_SHA',
		'HOMEBREW_CLEANUP_MAX_AGE_DAYS',
		'HOMEBREW_CLEANUP_PERIODIC_FULL_DAYS',
		'HOMEBREW_COLOR',
		'HOMEBREW_CORE_GIT_REMOTE',
		'HOMEBREW_CURLRC',
		'HOMEBREW_CURL_PATH',
		'HOMEBREW_CURL_RETRIES',
		'HOMEBREW_CURL_VERBOSE',
		'HOMEBREW_DEBUG',
		'HOMEBREW_DEVELOPER',
		'HOMEBREW_DISABLE_DEBREW',
		'HOMEBREW_DISABLE_LOAD_FORMULA',
		'HOMEBREW_DISPLAY',
		'HOMEBREW_DISPLAY_INSTALL_TIMES',
		'HOMEBREW_DOCKER_REGISTRY_BASIC_AUTH_TOKEN',
		'HOMEBREW_DOCKER_REGISTRY_TOKEN',
		'HOMEBREW_DOWNLOAD_CONCURRENCY',
		'HOMEBREW_EDITOR',
		'HOMEBREW_ENV_SYNC_STRICT',
		'HOMEBREW_EVAL_ALL',
		'HOMEBREW_FAIL_LOG_LINES',
		'HOMEBREW_FORBIDDEN_CASKS',
		'HOMEBREW_FORBIDDEN_CASK_ARTIFACTS',
		'HOMEBREW_FORBIDDEN_FORMULAE',
		'HOMEBREW_FORBIDDEN_LICENSES',
		'HOMEBREW_FORBIDDEN_OWNER',
		'HOMEBREW_FORBIDDEN_OWNER_CONTACT',
		'HOMEBREW_FORBIDDEN_TAPS',
		'HOMEBREW_FORBID_CASKS',
		'HOMEBREW_FORBID_PACKAGES_FROM_PATHS',
		'HOMEBREW_FORCE_API_AUTO_UPDATE',
		'HOMEBREW_FORCE_BREWED_CA_CERTIFICATES',
		'HOMEBREW_FORCE_BREWED_CURL',
		'HOMEBREW_FORCE_BREWED_GIT',
		'HOMEBREW_FORCE_BREW_WRAPPER',
		'HOMEBREW_FORCE_BREW_WRAPPER_HELP_MESSAGE',
		'HOMEBREW_FORCE_VENDOR_RUBY',
		'HOMEBREW_FORMULA_BUILD_NETWORK',
		'HOMEBREW_FORMULA_POSTINSTALL_NETWORK',
		'HOMEBREW_FORMULA_TEST_NETWORK',
		'HOMEBREW_GITHUB_API_TOKEN',
		'HOMEBREW_GITHUB_PACKAGES_TOKEN',
		'HOMEBREW_GITHUB_PACKAGES_USER',
		'HOMEBREW_GIT_COMMITTER_EMAIL',
		'HOMEBREW_GIT_COMMITTER_NAME',
		'HOMEBREW_GIT_EMAIL',
		'HOMEBREW_GIT_NAME',
		'HOMEBREW_GIT_PATH',
		'HOMEBREW_INSTALL_BADGE',
		'HOMEBREW_LIVECHECK_AUTOBUMP',
		'HOMEBREW_LIVECHECK_WATCHLIST',
		'HOMEBREW_LOCK_CONTEXT',
		'HOMEBREW_LOGS',
		'HOMEBREW_MAKE_JOBS',
		'HOMEBREW_NO_ANALYTICS',
		'HOMEBREW_NO_ASK',
		'HOMEBREW_NO_AUTOREMOVE',
		'HOMEBREW_NO_AUTO_UPDATE',
		'HOMEBREW_NO_BOOTSNAP',
		'HOMEBREW_NO_CLEANUP_FORMULAE',
		'HOMEBREW_NO_COLOR',
		'HOMEBREW_NO_EMOJI',
		'HOMEBREW_NO_ENV_HINTS',
		'HOMEBREW_NO_EVAL_ENV_SCRUBBING',
		'HOMEBREW_NO_FORCE_BREW_WRAPPER',
		'HOMEBREW_NO_GITHUB_API',
		'HOMEBREW_NO_INSECURE_REDIRECT',
		'HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK',
		'HOMEBREW_NO_INSTALL_CLEANUP',
		'HOMEBREW_NO_INSTALL_FROM_API',
		'HOMEBREW_NO_INSTALL_UPGRADE',
		'HOMEBREW_NO_PATH_SHADOW_CHECK',
		'HOMEBREW_NO_REQUIRE_TAP_TRUST',
		'HOMEBREW_NO_SANDBOX_CASK',
		'HOMEBREW_NO_SANDBOX_LINUX',
		'HOMEBREW_NO_UPDATE_REPORT_NEW',
		'HOMEBREW_NO_UPGRADE_AUTO_UPDATES_CASKS',
		'HOMEBREW_NO_UPGRADE_QUIT_CASKS',
		'HOMEBREW_NO_VERIFY_ATTESTATIONS',
		'HOMEBREW_PIP_INDEX_URL',
		'HOMEBREW_PRY',
		'HOMEBREW_REQUIRE_TAP_TRUST',
		'HOMEBREW_SANDBOX_LINUX',
		'HOMEBREW_SBOM',
		'HOMEBREW_SIMULATE_MACOS_ON_LINUX',
		'HOMEBREW_SKIP_OR_LATER_BOTTLES',
		'HOMEBREW_SORBET_RECURSIVE',
		'HOMEBREW_SORBET_RUNTIME',
		'HOMEBREW_SSH_CONFIG_PATH',
		'HOMEBREW_SUDO_THROUGH_SUDO_USER',
		'HOMEBREW_SVN',
		'HOMEBREW_SYSTEM_ENV_TAKES_PRIORITY',
		'HOMEBREW_TEMP',
		'HOMEBREW_UPDATE_TO_TAG',
		'HOMEBREW_UPGRADE_AUTO_UPDATES_CASKS',
		'HOMEBREW_UPGRADE_GREEDY',
		'HOMEBREW_UPGRADE_GREEDY_CASKS',
		'HOMEBREW_USE_INTERNAL_API',
		'HOMEBREW_VERBOSE',
		'HOMEBREW_VERBOSE_USING_DOTS',
		'HOMEBREW_VERIFY_ATTESTATIONS',
		'SUDO_ASKPASS',
		'all_proxy',
		'ftp_proxy',
		'http_proxy',
		'https_proxy',
		'no_proxy',
	]
	for command in ['cleanup', 'dump'] {
		for core_type in ['brew', 'cask', 'tap'] {
			names << 'HOMEBREW_BUNDLE_${command.to_upper()}_NO_${core_type.to_upper()}'
		}
		for extension in extensions {
			if (command == 'cleanup' && extension.cleanup_supported) || (command == 'dump' && extension.dump_disable_supported) {
				names << 'HOMEBREW_BUNDLE_${command.to_upper()}_NO_${extension.type_name.to_upper()}'
			}
		}
	}
	names.sort()
	return names
}

pub fn env_config_names() []string {
	return env_config_names_for_extensions(env_config_bundle_extensions())
}

pub fn env_config_entries_for_extensions(state &EnvConfigState, extensions []EnvBundleExtension) map[string]EnvConfigEntry {
	mut entries := map[string]EnvConfigEntry{}
	for name in env_config_names_for_extensions(extensions) {
		entries[name] = EnvConfigEntry{}
	}
	for command in ['cleanup', 'dump'] {
		verb := if command == 'cleanup' { 'clean up' } else { 'dump' }
		mut types := {
			'brew': 'formula dependencies'
			'cask': 'cask dependencies'
			'tap':  'tap dependencies'
		}
		for extension in extensions {
			if (command == 'cleanup' && extension.cleanup_supported) || (command == 'dump' && extension.dump_disable_supported) {
				types[extension.type_name] = extension.banner_name
			}
		}
		for type_name, description in types {
			name := 'HOMEBREW_BUNDLE_${command.to_upper()}_NO_${type_name.to_upper()}'
			entries[name] = EnvConfigEntry{
				description: 'If set, `brew bundle ${command}` will not ${verb} ${description}.'
				boolean_mode: .falsey_values
			}
		}
	}
	falsey_booleans := [
		'HOMEBREW_AUTO_UPDATE_QUIET',
		'HOMEBREW_BAT',
		'HOMEBREW_BUNDLE_DESCRIBE',
		'HOMEBREW_BUNDLE_DUMP_DESCRIBE',
		'HOMEBREW_BUNDLE_FORCE_INSTALL_CLEANUP',
		'HOMEBREW_BUNDLE_INSTALL_CLEANUP',
		'HOMEBREW_BUNDLE_NO_DESCRIBE',
		'HOMEBREW_BUNDLE_NO_JOBS',
		'HOMEBREW_BUNDLE_NO_SECRETS',
		'HOMEBREW_BUNDLE_SECRETS',
		'HOMEBREW_CURL_VERBOSE',
		'HOMEBREW_DISABLE_DEBREW',
		'HOMEBREW_DISABLE_LOAD_FORMULA',
		'HOMEBREW_DISPLAY_INSTALL_TIMES',
		'HOMEBREW_ENV_SYNC_STRICT',
		'HOMEBREW_EVAL_ALL',
		'HOMEBREW_FORBID_CASKS',
		'HOMEBREW_FORCE_API_AUTO_UPDATE',
		'HOMEBREW_LIVECHECK_AUTOBUMP',
		'HOMEBREW_NO_AUTOREMOVE',
		'HOMEBREW_NO_EVAL_ENV_SCRUBBING',
		'HOMEBREW_NO_GITHUB_API',
		'HOMEBREW_NO_INSECURE_REDIRECT',
		'HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK',
		'HOMEBREW_NO_INSTALL_UPGRADE',
		'HOMEBREW_NO_PATH_SHADOW_CHECK',
		'HOMEBREW_NO_SANDBOX_CASK',
		'HOMEBREW_NO_UPDATE_REPORT_NEW',
		'HOMEBREW_NO_UPGRADE_QUIT_CASKS',
		'HOMEBREW_PRY',
		'HOMEBREW_SIMULATE_MACOS_ON_LINUX',
		'HOMEBREW_SKIP_OR_LATER_BOTTLES',
		'HOMEBREW_SORBET_RECURSIVE',
		'HOMEBREW_SUDO_THROUGH_SUDO_USER',
		'HOMEBREW_UPGRADE_GREEDY',
		'HOMEBREW_VERBOSE_USING_DOTS',
	]
	for name in falsey_booleans {
		entries[name] = EnvConfigEntry{
			...entries[name]
			boolean_mode: .falsey_values
		}
	}
	set_booleans := [
		'HOMEBREW_ARTIFACT_DOMAIN_NO_FALLBACK',
		'HOMEBREW_ASK',
		'HOMEBREW_AVOID_NESTED_SANDBOXING',
		'HOMEBREW_COLOR',
		'HOMEBREW_DEBUG',
		'HOMEBREW_DEVELOPER',
		'HOMEBREW_FORBID_PACKAGES_FROM_PATHS',
		'HOMEBREW_FORCE_BREWED_CA_CERTIFICATES',
		'HOMEBREW_FORCE_BREWED_CURL',
		'HOMEBREW_FORCE_BREWED_GIT',
		'HOMEBREW_FORCE_VENDOR_RUBY',
		'HOMEBREW_NO_ANALYTICS',
		'HOMEBREW_NO_ASK',
		'HOMEBREW_NO_AUTO_UPDATE',
		'HOMEBREW_NO_BOOTSNAP',
		'HOMEBREW_NO_COLOR',
		'HOMEBREW_NO_EMOJI',
		'HOMEBREW_NO_ENV_HINTS',
		'HOMEBREW_NO_FORCE_BREW_WRAPPER',
		'HOMEBREW_NO_INSTALL_CLEANUP',
		'HOMEBREW_NO_INSTALL_FROM_API',
		'HOMEBREW_NO_REQUIRE_TAP_TRUST',
		'HOMEBREW_NO_SANDBOX_LINUX',
		'HOMEBREW_NO_UPGRADE_AUTO_UPDATES_CASKS',
		'HOMEBREW_NO_VERIFY_ATTESTATIONS',
		'HOMEBREW_REQUIRE_TAP_TRUST',
		'HOMEBREW_SANDBOX_LINUX',
		'HOMEBREW_SBOM',
		'HOMEBREW_SORBET_RUNTIME',
		'HOMEBREW_SYSTEM_ENV_TAKES_PRIORITY',
		'HOMEBREW_UPDATE_TO_TAG',
		'HOMEBREW_UPGRADE_AUTO_UPDATES_CASKS',
		'HOMEBREW_USE_INTERNAL_API',
		'HOMEBREW_VERBOSE',
		'HOMEBREW_VERIFY_ATTESTATIONS',
	]
	for name in set_booleans {
		entries[name] = EnvConfigEntry{
			...entries[name]
			boolean_mode: .set
		}
	}
	mut literal_defaults := {
		'HOMEBREW_API_AUTO_UPDATE_SECS':       '450'
		'HOMEBREW_API_DOMAIN':                 state.api_default_domain
		'HOMEBREW_ARCH':                       'native'
		'HOMEBREW_BOTTLE_DOMAIN':              state.bottle_default_domain
		'HOMEBREW_BREW_GIT_REMOTE':            state.brew_default_git_remote
		'HOMEBREW_BUNDLE_JOBS':                'auto'
		'HOMEBREW_CACHE':                      state.default_cache
		'HOMEBREW_CLEANUP_MAX_AGE_DAYS':       '120'
		'HOMEBREW_CLEANUP_PERIODIC_FULL_DAYS': '30'
		'HOMEBREW_CORE_GIT_REMOTE':            state.core_default_git_remote
		'HOMEBREW_CURL_PATH':                  'curl'
		'HOMEBREW_CURL_RETRIES':               '3'
		'HOMEBREW_DOWNLOAD_CONCURRENCY':       'auto'
		'HOMEBREW_FAIL_LOG_LINES':             '15'
		'HOMEBREW_FORBIDDEN_OWNER':            'you'
		'HOMEBREW_GIT_PATH':                   'git'
		'HOMEBREW_INSTALL_BADGE':              '🍺'
		'HOMEBREW_LIVECHECK_WATCHLIST':        os.join_path(state.user_config_home, 'livecheck_watchlist.txt')
		'HOMEBREW_LOGS':                       state.default_logs
		'HOMEBREW_MAKE_JOBS':                  state.cpu_cores.str()
		'HOMEBREW_PIP_INDEX_URL':              'https://pypi.org/simple'
		'HOMEBREW_SSH_CONFIG_PATH':            os.join_path(state.home_directory, '.ssh', 'config')
		'HOMEBREW_TEMP':                       state.default_temp
	}
	literal_defaults['HOMEBREW_AUTO_UPDATE_SECS'] = if !env_config_blank(state.values['HOMEBREW_NO_INSTALL_FROM_API'] or { '' }) || !env_config_blank(state.values['HOMEBREW_AUTO_UPDATE_TAP'] or { '' }) {
		'300'
	} else if !env_config_blank(state.values['HOMEBREW_DEV_CMD_RUN'] or { '' }) {
		'3600'
	} else {
		'86400'
	}
	for name, value in literal_defaults {
		entries[name] = EnvConfigEntry{
			...entries[name]
			has_default: true
			default_value: value
		}
	}
	for name in ['HOMEBREW_ASK', 'HOMEBREW_BUNDLE_DESCRIBE', 'HOMEBREW_BUNDLE_NO_SECRETS',
		'HOMEBREW_REQUIRE_TAP_TRUST', 'HOMEBREW_SANDBOX_LINUX', 'HOMEBREW_SBOM',
		'HOMEBREW_UPGRADE_AUTO_UPDATES_CASKS'] {
		entries[name] = EnvConfigEntry{
			...entries[name]
			has_default: true
			default_is_boolean: true
			default_boolean: true
			default_value: 'true'
		}
	}
	entries['HOMEBREW_FORBID_PACKAGES_FROM_PATHS'] = EnvConfigEntry{
		...entries['HOMEBREW_FORBID_PACKAGES_FROM_PATHS']
		has_default: true
		default_is_boolean: true
		default_boolean: env_config_blank(state.values['HOMEBREW_TESTS'] or { '' }) && env_config_blank(state.values['HOMEBREW_DEVELOPER'] or { '' })
		default_value: (env_config_blank(state.values['HOMEBREW_TESTS'] or { '' }) && env_config_blank(state.values['HOMEBREW_DEVELOPER'] or { '' })).str()
	}
	disabled_by := {
		'HOMEBREW_ASK':                        'HOMEBREW_NO_ASK'
		'HOMEBREW_BUNDLE_DESCRIBE':            'HOMEBREW_BUNDLE_NO_DESCRIBE'
		'HOMEBREW_BUNDLE_NO_SECRETS':          'HOMEBREW_BUNDLE_SECRETS'
		'HOMEBREW_COLOR':                      'HOMEBREW_NO_COLOR'
		'HOMEBREW_REQUIRE_TAP_TRUST':          'HOMEBREW_NO_REQUIRE_TAP_TRUST'
		'HOMEBREW_SANDBOX_LINUX':              'HOMEBREW_NO_SANDBOX_LINUX'
		'HOMEBREW_UPGRADE_AUTO_UPDATES_CASKS': 'HOMEBREW_NO_UPGRADE_AUTO_UPDATES_CASKS'
		'HOMEBREW_VERIFY_ATTESTATIONS':        'HOMEBREW_NO_VERIFY_ATTESTATIONS'
	}
	for name, inverse in disabled_by {
		entries[name] = EnvConfigEntry{
			...entries[name]
			disabled_by: inverse
		}
	}
	for name in ['HOMEBREW_ASK', 'HOMEBREW_BUNDLE_DESCRIBE', 'HOMEBREW_BUNDLE_DUMP_DESCRIBE',
		'HOMEBREW_BUNDLE_NO_SECRETS', 'HOMEBREW_CASK_OPTS_BINARIES', 'HOMEBREW_CASK_OPTS_REQUIRE_SHA',
		'HOMEBREW_EVAL_ALL', 'HOMEBREW_NO_EVAL_ENV_SCRUBBING', 'HOMEBREW_NO_SANDBOX_CASK',
		'HOMEBREW_PRY', 'HOMEBREW_SANDBOX_LINUX', 'HOMEBREW_UPGRADE_AUTO_UPDATES_CASKS',
		'HOMEBREW_USE_INTERNAL_API'] {
		entries[name] = EnvConfigEntry{
			...entries[name]
			odeprecated: true
		}
	}
	entries['HOMEBREW_BUNDLE_DUMP_DESCRIBE'] = EnvConfigEntry{
		...entries['HOMEBREW_BUNDLE_DUMP_DESCRIBE']
		replacement: 'HOMEBREW_BUNDLE_DESCRIBE'
		replacement_env: true
	}
	replacements := {
		'HOMEBREW_ASK':                        'the default behaviour'
		'HOMEBREW_BUNDLE_DESCRIBE':            'the default behaviour'
		'HOMEBREW_BUNDLE_NO_SECRETS':          'the default behaviour'
		'HOMEBREW_CASK_OPTS_BINARIES':         'HOMEBREW_CASK_OPTS'
		'HOMEBREW_CASK_OPTS_REQUIRE_SHA':      'HOMEBREW_CASK_OPTS'
		'HOMEBREW_EVAL_ALL':                   'HOMEBREW_REQUIRE_TAP_TRUST or HOMEBREW_NO_REQUIRE_TAP_TRUST'
		'HOMEBREW_PRY':                        'the default IRB backend (Pry is largely unmaintained upstream)'
		'HOMEBREW_UPGRADE_AUTO_UPDATES_CASKS': 'the default behaviour'
		'HOMEBREW_USE_INTERNAL_API':           'the default behaviour'
	}
	for name, replacement in replacements {
		entries[name] = EnvConfigEntry{
			...entries[name]
			replacement: replacement
		}
	}
	for name in ['HOMEBREW_BUNDLE_INSTALL_CLEANUP', 'HOMEBREW_SBOM'] {
		entries[name] = EnvConfigEntry{
			...entries[name]
			hidden: true
		}
	}
	default_texts := {
		'HOMEBREW_API_DOMAIN':                 '`https://formulae.brew.sh/api`.'
		'HOMEBREW_AUTO_UPDATE_SECS':           '`86400` (24 hours), `3600` (1 hour) if a developer command has been run or `300` (5 minutes) if `\$HOMEBREW_NO_INSTALL_FROM_API` is set.'
		'HOMEBREW_BAT_CONFIG_PATH':            '`\$BAT_CONFIG_PATH`.'
		'HOMEBREW_BAT_THEME':                  '`\$BAT_THEME`.'
		'HOMEBREW_BOTTLE_DOMAIN':              '`https://ghcr.io/v2/homebrew/core`.'
		'HOMEBREW_BROWSER':                    "`\$BROWSER` or the OS's default browser."
		'HOMEBREW_CACHE':                      'macOS: `~/Library/Caches/Homebrew`, Linux: `\$XDG_CACHE_HOME/Homebrew` or `~/.cache/Homebrew`.'
		'HOMEBREW_CORE_GIT_REMOTE':            '`https://github.com/Homebrew/homebrew-core`.'
		'HOMEBREW_DISPLAY':                    '`\$DISPLAY`.'
		'HOMEBREW_EDITOR':                     '`\$EDITOR` or `\$VISUAL`.'
		'HOMEBREW_FORBID_PACKAGES_FROM_PATHS': 'true unless `\$HOMEBREW_DEVELOPER` is set.'
		'HOMEBREW_INSTALL_BADGE':              'The "Beer Mug" emoji.'
		'HOMEBREW_LIVECHECK_WATCHLIST':        '`\${XDG_CONFIG_HOME}/homebrew/livecheck_watchlist.txt` if `\$XDG_CONFIG_HOME` is set or `~/.homebrew/livecheck_watchlist.txt` otherwise.'
		'HOMEBREW_LOGS':                       'macOS: `~/Library/Logs/Homebrew`, Linux: `\${XDG_CACHE_HOME}/Homebrew/Logs` or `~/.cache/Homebrew/Logs`.'
		'HOMEBREW_MAKE_JOBS':                  'The number of available CPU cores.'
		'HOMEBREW_NO_COLOR':                   '`\$NO_COLOR`.'
		'HOMEBREW_PIP_INDEX_URL':              '`https://pypi.org/simple`.'
		'HOMEBREW_SSH_CONFIG_PATH':            '`~/.ssh/config`'
		'HOMEBREW_SVN':                        'A Homebrew-built Subversion (if installed), or the system-provided binary.'
		'HOMEBREW_TEMP':                       'macOS: `/private/tmp`, Linux: `/var/tmp`.'
	}
	for name, text in default_texts {
		entries[name] = EnvConfigEntry{
			...entries[name]
			default_text: text
		}
	}
	return entries
}

pub fn env_config_entries(state &EnvConfigState) map[string]EnvConfigEntry {
	return env_config_entries_for_extensions(state, env_config_bundle_extensions())
}

pub fn env_config_analytics_variables() []string {
	return env_config_names().filter(it != 'HOMEBREW_NO_ANALYTICS')
}

fn env_config_blank(value string) bool {
	return value.trim_space() == ''
}

fn env_config_falsey(value string) bool {
	return value.to_lower() in env_config_falsy_values
}

pub fn env_config_shellsplit(value string) ![]string {
	mut result := []string{}
	mut current := []u8{}
	mut quote := u8(0)
	mut token_started := false
	mut index := 0
	bytes := value.bytes()
	for index < bytes.len {
		character := bytes[index]
		if quote == `'` {
			if character == `'` {
				quote = 0
			} else {
				current << character
			}
			token_started = true
			index++
			continue
		}
		if quote == `"` {
			if character == `"` {
				quote = 0
				index++
				continue
			}
			if character == `\\` && index + 1 < bytes.len {
				next := bytes[index + 1]
				if next in [`$`, u8(96), `"`, `\\`, `\n`] {
					if next != `\n` {
						current << next
					}
					index += 2
					continue
				}
			}
			current << character
			token_started = true
			index++
			continue
		}
		if character.is_space() {
			if token_started {
				result << current.bytestr()
				current = []
				token_started = false
			}
			index++
			continue
		}
		if character == `'` || character == `"` {
			quote = character
			token_started = true
			index++
			continue
		}
		if character == `\\` {
			if index + 1 >= bytes.len {
				return error('Unmatched escape character')
			}
			if bytes[index + 1] != `\n` {
				current << bytes[index + 1]
				token_started = true
			}
			index += 2
			continue
		}
		current << character
		token_started = true
		index++
	}
	if quote != 0 {
		return error('Unmatched quote')
	}
	if token_started {
		result << current.bytestr()
	}
	return result
}

// Ruby method `env_method_name(env, hash)` at line 801.
pub fn ruby_env_config_l801_d1_env_method_name(env string, entry EnvConfigEntry) string {
	mut generated_name := env
	if generated_name.starts_with('HOMEBREW_') {
		generated_name = generated_name['HOMEBREW_'.len..]
	}
	generated_name = generated_name.to_lower()
	if entry.boolean_mode != .none {
		generated_name += '?'
	}
	return generated_name
}

// Ruby method `hidden?(hash)` at line 810.
pub fn ruby_env_config_l810_d2_hidden(entry EnvConfigEntry) bool {
	return entry.hidden || entry.odeprecated || entry.odisabled
}

// Ruby method `default_description(env)` at line 817.
pub fn ruby_env_config_l817_d3_default_description(env string, state &EnvConfigState) ?string {
	entries := env_config_entries(state)
	entry := entries[env] or { return none }
	if entry.default_text != '' {
		return entry.default_text
	}
	if entry.has_default && entry.default_value != '' {
		return '`${entry.default_value}`.'
	}
	return none
}

// Ruby method `non_default_variable?(env)` at line 848.
pub fn ruby_env_config_l848_d4_non_default_variable(env string, state &EnvConfigState) !bool {
	value := state.values[env] or { return false }
	if env_config_blank(value) {
		return false
	}
	entries := env_config_entries(state)
	entry := entries[env] or { return error('unknown environment variable ${env}') }
	if entry.boolean_mode != .none {
		enabled := entry.boolean_mode == .set || !env_config_falsey(value)
		return enabled != entry.default_boolean
	}
	return value != entry.default_value
}

// Ruby method `user_set_variable?(env)` at line 868.
pub fn ruby_env_config_l868_d5_user_set_variable(env string, state &EnvConfigState) bool {
	value := state.values[env] or { return false }
	if env_config_blank(value) {
		return false
	}
	if !env.starts_with('HOMEBREW_') {
		return true
	}
	return env in (state.values['HOMEBREW_USER_SET_VARS'] or { '' }).fields()
}

// Ruby method `non_default_variables` at line 876.
pub fn ruby_env_config_l876_d6_non_default_variables(state &EnvConfigState) ![]string {
	entries := env_config_entries(state)
	mut variables := []string{}
	for env, _ in state.values {
		if env in entries && ruby_env_config_l868_d5_user_set_variable(env, state) && ruby_env_config_l848_d4_non_default_variable(env, state)! {
			variables << env
		}
	}
	variables.sort()
	return variables
}

// Ruby define_method `define_method(method_name) do` at line 891.
pub fn ruby_env_config_l891_d7_method_name(env string, mut state EnvConfigState) !bool {
	entry := env_config_entries(&state)[env] or { return error('unknown environment variable ${env}') }
	if entry.disabled_by != '' && ruby_env_config_l891_d7_method_name(entry.disabled_by, mut state)! {
		return false
	}
	value := ruby_env_config_l919_d10_env_value(env, entry, mut state)!
	if entry.default_boolean && (!value.present || env_config_blank(value.value)) {
		return true
	}
	return value.present && !env_config_blank(value.value) && (entry.boolean_mode == .set || !env_config_falsey(value.value))
}

// Ruby define_method `define_method(method_name) do` at line 903.
pub fn ruby_env_config_l903_d8_method_name(env string, mut state EnvConfigState) !string {
	entry := env_config_entries(&state)[env] or { return error('unknown environment variable ${env}') }
	value := ruby_env_config_l919_d10_env_value(env, entry, mut state)!
	if value.present && !env_config_blank(value.value) {
		return value.value
	}
	return entry.default_value
}

// Ruby define_method `define_method(method_name) do` at line 912.
pub fn ruby_env_config_l912_d9_method_name(env string, mut state EnvConfigState) !EnvConfigValue {
	entry := env_config_entries(&state)[env] or { return error('unknown environment variable ${env}') }
	value := ruby_env_config_l919_d10_env_value(env, entry, mut state)!
	if !value.present || env_config_blank(value.value) {
		return EnvConfigValue{}
	}
	return value
}

// Ruby method `env_value(env, hash)` at line 919.
pub fn ruby_env_config_l919_d10_env_value(env string, entry EnvConfigEntry, mut state EnvConfigState) !EnvConfigValue {
	env_value := state.values[env] or { return EnvConfigValue{} }
	if !env_config_blank(env_value) && (!entry.default_boolean || !env_config_falsey(env_value)) {
		ruby_env_config_l934_d11_odeprecated_env(env, entry, mut state)!
	}
	if entry.replacement_env && entry.replacement != '' && entry.replacement !in state.values {
		state.values[entry.replacement] = env_value
	}
	return EnvConfigValue{
		present: true
		value: env_value
	}
}

// Ruby method `odeprecated_env(env, hash)` at line 934.
pub fn ruby_env_config_l934_d11_odeprecated_env(env string, entry EnvConfigEntry, mut state EnvConfigState) !EnvConfigDeprecationOutcome {
	if (!entry.odeprecated && !entry.odisabled) || !ruby_env_config_l946_d12_env_deprecation_applies(entry, &state) {
		return EnvConfigDeprecationOutcome{}
	}
	if !state.raise_deprecation_exceptions && env_config_blank(state.values['HOMEBREW_TESTS'] or { '' }) && env in state.warned_deprecated {
		return EnvConfigDeprecationOutcome{}
	}
	if env !in state.warned_deprecated {
		state.warned_deprecated << env
	}
	deprecation := EnvConfigDeprecation{
		environment: env
		replacement: entry.replacement
		disabled: entry.odisabled
	}
	state.deprecations << deprecation
	if state.raise_deprecation_exceptions {
		kind := if entry.odisabled { 'disabled' } else { 'deprecated' }
		return error('${env} is ${kind}${if entry.replacement != '' {
			'; use \${entry.replacement} instead'
		} else {
			''
		}}')
	}
	return EnvConfigDeprecationOutcome{
		applies: true
		deprecation: deprecation
	}
}

// Ruby method `env_deprecation_applies?(hash)` at line 946.
pub fn ruby_env_config_l946_d12_env_deprecation_applies(entry EnvConfigEntry, state &EnvConfigState) bool {
	command := state.values['HOMEBREW_COMMAND'] or { '' }
	if entry.commands.len > 0 && !env_config_blank(command) && command !in entry.commands {
		return false
	}
	subcommand := state.values['HOMEBREW_SUBCOMMAND'] or { '' }
	if entry.subcommands.len > 0 && !env_config_blank(subcommand) && subcommand !in entry.subcommands {
		return false
	}
	return true
}

// Ruby method `bottle_domain_custom?` at line 959.
pub fn ruby_env_config_l959_d13_bottle_domain_custom(mut state EnvConfigState) !bool {
	return ruby_env_config_l903_d8_method_name('HOMEBREW_BOTTLE_DOMAIN', mut state)! != state.bottle_default_domain
}

// Ruby method `make_jobs` at line 964.
pub fn ruby_env_config_l964_d14_make_jobs(state &EnvConfigState) string {
	jobs := (state.values['HOMEBREW_MAKE_JOBS'] or { '' }).int()
	if jobs > 0 {
		return jobs.str()
	}
	return state.cpu_cores.str()
}

// Ruby method `cask_opts` at line 975.
pub fn ruby_env_config_l975_d15_cask_opts(state &EnvConfigState) ![]string {
	return env_config_shellsplit(state.values['HOMEBREW_CASK_OPTS'] or { '' })
}

// Ruby method `self.cask_opts_binaries?` at line 980.
pub fn ruby_env_config_l980_d16_self_cask_opts_binaries(mut state EnvConfigState) !bool {
	opts := ruby_env_config_l975_d15_cask_opts(&state)!
	for index := opts.len - 1; index >= 0; index-- {
		if opts[index] == '--binaries' {
			return true
		}
		if opts[index] == '--no-binaries' {
			return false
		}
	}
	value := ruby_env_config_l912_d9_method_name('HOMEBREW_CASK_OPTS_BINARIES', mut state)!
	if value.present {
		return !env_config_falsey(value.value)
	}
	return true
}

// Ruby method `cask_opts_require_sha?` at line 994.
pub fn ruby_env_config_l994_d17_cask_opts_require_sha(mut state EnvConfigState) !bool {
	if '--require-sha' in ruby_env_config_l975_d15_cask_opts(&state)! {
		return true
	}
	value := ruby_env_config_l912_d9_method_name('HOMEBREW_CASK_OPTS_REQUIRE_SHA', mut state)!
	return value.present && !env_config_falsey(value.value)
}

// Ruby method `bundle_jobs` at line 1003.
pub fn ruby_env_config_l1003_d18_bundle_jobs(state &EnvConfigState) EnvConfigBundleJobs {
	no_jobs := state.values['HOMEBREW_BUNDLE_NO_JOBS'] or { '' }
	if !env_config_blank(no_jobs) && !env_config_falsey(no_jobs) {
		return EnvConfigBundleJobs{}
	}
	default_jobs := 'auto'
	jobs := state.values['HOMEBREW_BUNDLE_JOBS'] or { '' }
	mut warnings := []string{}
	if jobs == default_jobs {
		warnings << 'HOMEBREW_BUNDLE_JOBS=${default_jobs} is now the default and no longer needs to be set.'
	}
	return EnvConfigBundleJobs{
		present: true
		value: if env_config_blank(jobs) { default_jobs } else { jobs }
		warnings: warnings
	}
}

// Ruby method `forbid_packages_from_paths?` at line 1016.
pub fn ruby_env_config_l1016_d19_forbid_packages_from_paths(state &EnvConfigState) bool {
	if !env_config_blank(state.values['HOMEBREW_INTERNAL_ALLOW_PACKAGES_FROM_PATHS'] or { '' }) {
		return false
	}
	if !env_config_blank(state.values['HOMEBREW_FORBID_PACKAGES_FROM_PATHS'] or { '' }) {
		return true
	}
	return env_config_blank(state.values['HOMEBREW_TESTS'] or { '' }) && env_config_blank(state.values['HOMEBREW_DEVELOPER'] or { '' })
}

// Ruby method `automatically_set_no_install_from_api?` at line 1029.
pub fn ruby_env_config_l1029_d20_automatically_set_no_install_from_api(state &EnvConfigState) bool {
	return !env_config_blank(state.values['HOMEBREW_AUTOMATICALLY_SET_NO_INSTALL_FROM_API'] or { '' })
}

// Ruby method `devcmdrun?` at line 1034.
pub fn ruby_env_config_l1034_d21_devcmdrun(state &EnvConfigState) bool {
	return (state.settings['devcmdrun'] or { '' }) == 'true'
}

// Ruby method `download_concurrency` at line 1039.
pub fn ruby_env_config_l1039_d22_download_concurrency(state &EnvConfigState) int {
	configured := state.values['HOMEBREW_DOWNLOAD_CONCURRENCY'] or { 'auto' }
	concurrency := if configured == 'auto' { state.cpu_cores * 2 } else { configured.int() }
	return if concurrency < 1 { 1 } else { concurrency }
}

// Ruby method `tap_trust_configured?` at line 1053.
pub fn ruby_env_config_l1053_d23_tap_trust_configured(mut state EnvConfigState) !bool {
	return ruby_env_config_l891_d7_method_name('HOMEBREW_REQUIRE_TAP_TRUST', mut state)! || ruby_env_config_l891_d7_method_name('HOMEBREW_NO_REQUIRE_TAP_TRUST', mut state)!
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/output"
// 5: require "bundle/extensions"
// 6:
// 7: module Homebrew
// 8:   # Helper module for querying Homebrew-specific environment variables.
// 9:   #
// 10:   # @api internal
// 11:   module EnvConfig
// 12:     include Utils::Output::Mixin
// 13:     extend Utils::Output::Mixin
// 14:
// 15:     module_function
// 16:
// 17:     BUNDLE_CORE_TYPES = T.let({
// 18:       brew: "formula dependencies",
// 19:       cask: "cask dependencies",
// 20:       tap:  "tap dependencies",
// 21:     }.freeze, T::Hash[Symbol, String])
// 22:
// 23:     BUNDLE_DISABLE_ENVS = T.let(
// 24:       {
// 25:         cleanup: [BUNDLE_CORE_TYPES, Homebrew::Bundle.extensions.select(&:cleanup_supported?).to_h do |extension|
// 26:           [extension.type, extension.banner_name]
// 27:         end],
// 28:         dump:    [BUNDLE_CORE_TYPES, Homebrew::Bundle.extensions.select(&:dump_disable_supported?).to_h do |extension|
// 29:           [extension.type, extension.banner_name]
// 30:         end],
// 31:       }.flat_map do |command, type_descriptions|
// 32:         type_descriptions.reduce(&:merge).map do |type, description|
// 33:           verb = (command == :cleanup) ? "clean up" : "dump"
// 34:           [
// 35:             :"HOMEBREW_BUNDLE_#{command.upcase}_NO_#{type.to_s.upcase}",
// 36:             {
// 37:               description: "If set, `brew bundle #{command}` will not #{verb} #{description}.",
// 38:               boolean:     true,
// 39:             },
// 40:           ]
// 41:         end
// 42:       end.sort.to_h.freeze,
// 43:       T::Hash[Symbol, T::Hash[Symbol, T.untyped]],
// 44:     )
// 45:
// 46:     ENVS = T.let({
// 47:       HOMEBREW_ALLOWED_TAPS:                     {
// 48:         description: "A space-separated list of taps. Homebrew will refuse to install a " \
// 49:                      "formula unless it and all of its dependencies are in an official tap " \
// 50:                      "or in a tap on this list. Each entry is a `user/repository` name " \
// 51:                      "(which matches only taps using the default GitHub remote) or a remote " \
// 52:                      "URL (required to match taps with a custom remote).",
// 53:       },
// 54:       HOMEBREW_API_AUTO_UPDATE_SECS:             {
// 55:         description: "Check Homebrew's API for new formulae or cask data every " \
// 56:                      "`$HOMEBREW_API_AUTO_UPDATE_SECS` seconds. Alternatively, disable API auto-update " \
// 57:                      "checks entirely with `$HOMEBREW_NO_AUTO_UPDATE`.",
// 58:         default:     450,
// 59:       },
// 60:       HOMEBREW_API_DOMAIN:                       {
// 61:         description:  "Use this URL as the download mirror for Homebrew JSON API. " \
// 62:                       "If metadata files at that URL are temporarily unavailable, " \
// 63:                       "the default API domain will be used as a fallback mirror.",
// 64:         default_text: "`https://formulae.brew.sh/api`.",
// 65:         default:      HOMEBREW_API_DEFAULT_DOMAIN,
// 66:       },
// 67:       HOMEBREW_ARCH:                             {
// 68:         description: "Linux only: Pass this value to a type name representing the compiler's `-march` option.",
// 69:         default:     "native",
// 70:       },
// 71:       HOMEBREW_ARTIFACT_DOMAIN:                  {
// 72:         description: "Prefix all download URLs, including those for bottles, with this value. " \
// 73:                      "For example, `export HOMEBREW_ARTIFACT_DOMAIN=http://localhost:8080` will cause a " \
// 74:                      "formula with the URL `https://example.com/foo.tar.gz` to instead download from " \
// 75:                      "`http://localhost:8080/https://example.com/foo.tar.gz`. " \
// 76:                      "Bottle URLs however, have their domain replaced with this prefix. " \
// 77:                      "This results in e.g. " \
// 78:                      "`https://ghcr.io/v2/homebrew/core/gettext/manifests/0.21` " \
// 79:                      "to instead be downloaded from " \
// 80:                      "`http://localhost:8080/v2/homebrew/core/gettext/manifests/0.21`. " \
// 81:                      "If the value already contains a `/v2` path (e.g. an OCI registry proxying " \
// 82:                      "GitHub Packages under a repository prefix such as " \
// 83:                      "`https://mirror.example.com/v2/ghcr-io`), the `v2` path is not duplicated, " \
// 84:                      "resulting in e.g. " \
// 85:                      "`https://mirror.example.com/v2/ghcr-io/homebrew/core/gettext/manifests/0.21`.",
// 86:       },
// 87:       HOMEBREW_ARTIFACT_DOMAIN_NO_FALLBACK:      {
// 88:         description: "When `$HOMEBREW_ARTIFACT_DOMAIN` and `$HOMEBREW_ARTIFACT_DOMAIN_NO_FALLBACK` are both set, " \
// 89:                      "if the request to `$HOMEBREW_ARTIFACT_DOMAIN` fails then Homebrew will error rather than " \
// 90:                      "trying any other/default URLs.",
// 91:         boolean:     :set,
// 92:       },
// 93:       HOMEBREW_ASK:                              {
// 94:         description: "Ask mode is the default for `brew install`, `brew upgrade` and " \
// 95:                      "`brew reinstall` commands. Ask mode prints the plan before proceeding and prompts only " \
// 96:                      "if the plan includes dependencies, dependants or packages other than named arguments. " \
// 97:                      "Otherwise, it only prints the plan. The confirmation prompt is skipped without a TTY.",
// 98:         boolean:     :set,
// 99:         disabled_by: :HOMEBREW_NO_ASK,
// 100:         default:     true,
// 101:         replacement: "the default behaviour",
// 102:         odeprecated: true,
// 103:       },
// 104:       HOMEBREW_AUTO_UPDATE_QUIET:                {
// 105:         description: "If set, the auto-update run before commands like `brew install`, `brew upgrade` or " \
// 106:                      "`brew tap` will not show information about new, outdated or deleted formulae and casks.",
// 107:         boolean:     true,
// 108:       },
// 109:       HOMEBREW_AUTO_UPDATE_SECS:                 {
// 110:         description:  "Run `brew update` once every `$HOMEBREW_AUTO_UPDATE_SECS` seconds before some commands, " \
// 111:                       "e.g. `brew install`, `brew upgrade` or `brew tap`. Alternatively, " \
// 112:                       "disable auto-update entirely with `$HOMEBREW_NO_AUTO_UPDATE`.",
// 113:         default_text: "`86400` (24 hours), `3600` (1 hour) if a developer command has been run " \
// 114:                       "or `300` (5 minutes) if `$HOMEBREW_NO_INSTALL_FROM_API` is set.",
// 115:         # Keep in sync with the auto-update defaults in Library/Homebrew/brew.sh.
// 116:         default:      lambda {
// 117:           if ENV["HOMEBREW_NO_INSTALL_FROM_API"].present? || ENV["HOMEBREW_AUTO_UPDATE_TAP"].present?
// 118:             300
// 119:           elsif ENV["HOMEBREW_DEV_CMD_RUN"].present?
// 120:             3600
// 121:           else
// 122:             86400
// 123:           end
// 124:         },
// 125:       },
// 126:       HOMEBREW_AVOID_NESTED_SANDBOXING:          {
// 127:         description: "If set, skip Homebrew's sandbox when it is itself running inside another " \
// 128:                      "sandbox, for an unprivileged user outside the default prefix. This trades " \
// 129:                      "Homebrew's build-time network and filesystem denial for trust in the outer " \
// 130:                      "sandbox. Homebrew errors out if the prefix or group makes skipping " \
// 131:                      "unsupported.",
// 132:         boolean:     :set,
// 133:       },
// 134:       HOMEBREW_BAT:                              {
// 135:         description: "If set, use `bat` for the `brew cat` command.",
// 136:         boolean:     true,
// 137:       },
// 138:       HOMEBREW_BAT_CONFIG_PATH:                  {
// 139:         description:  "Use this as the `bat` configuration file.",
// 140:         default_text: "`$BAT_CONFIG_PATH`.",
// 141:       },
// 142:       HOMEBREW_BAT_THEME:                        {
// 143:         description:  "Use this as the `bat` theme for syntax highlighting.",
// 144:         default_text: "`$BAT_THEME`.",
// 145:       },
// 146:       HOMEBREW_BOTTLE_DOMAIN:                    {
// 147:         description:  "Use this URL as the download mirror for bottles and their manifests. " \
// 148:                       "If a bottle or manifest is unavailable at the mirror, " \
// 149:                       "the default bottle domain will be used as a fallback. " \
// 150:                       "Prefer `$HOMEBREW_ARTIFACT_DOMAIN` for a mirror that transparently proxies all " \
// 151:                       "Homebrew downloads. " \
// 152:                       "For example, `export HOMEBREW_BOTTLE_DOMAIN=http://localhost:8080` will cause all bottles " \
// 153:                       "to download from the prefix `http://localhost:8080/`.",
// 154:         default_text: "`https://ghcr.io/v2/homebrew/core`.",
// 155:         default:      HOMEBREW_BOTTLE_DEFAULT_DOMAIN,
// 156:       },
// 157:       HOMEBREW_BREW_GIT_REMOTE:                  {
// 158:         description: "Use this URL as the Homebrew/brew `git`(1) remote.",
// 159:         default:     HOMEBREW_BREW_DEFAULT_GIT_REMOTE,
// 160:       },
// 161:       HOMEBREW_BROWSER:                          {
// 162:         description:  "Use this as the browser when opening project homepages.",
// 163:         default_text: "`$BROWSER` or the OS's default browser.",
// 164:       },
// 165:       **BUNDLE_DISABLE_ENVS.select { |env,| env < :HOMEBREW_BUNDLE_DESCRIBE },
// 166:       HOMEBREW_BUNDLE_DESCRIBE:                  {
// 167:         description: "If set, add a description comment above each line in `brew bundle dump` and " \
// 168:                      "`brew bundle add`, unless the dependency does not have a description. This is the default " \
// 169:                      "unless `$HOMEBREW_BUNDLE_NO_DESCRIBE` is set.",
// 170:         boolean:     true,
// 171:         disabled_by: :HOMEBREW_BUNDLE_NO_DESCRIBE,
// 172:         default:     true,
// 173:         replacement: "the default behaviour",
// 174:         odeprecated: true,
// 175:       },
// 176:       HOMEBREW_BUNDLE_DUMP_DESCRIBE:             {
// 177:         description: "If set, add a description comment above each line in `brew bundle dump` " \
// 178:                      "unless the dependency does not have a description. Use `$HOMEBREW_BUNDLE_DESCRIBE` instead.",
// 179:         boolean:     true,
// 180:         replacement: :HOMEBREW_BUNDLE_DESCRIBE,
// 181:         odeprecated: true,
// 182:       },
// 183:       **BUNDLE_DISABLE_ENVS.select { |env,| env > :HOMEBREW_BUNDLE_DESCRIBE },
// 184:       HOMEBREW_BUNDLE_FORCE_INSTALL_CLEANUP:     {
// 185:         description: "If set, run `brew bundle cleanup --force` after `brew bundle install`.",
// 186:         boolean:     true,
// 187:       },
// 188:       HOMEBREW_BUNDLE_INSTALL_CLEANUP:           {
// 189:         description: "If set, run `brew bundle cleanup` after `brew bundle install`.",
// 190:         boolean:     true,
// 191:         hidden:      true,
// 192:       },
// 193:       HOMEBREW_BUNDLE_JOBS:                      {
// 194:         # `HOMEBREW_BUNDLE_JOBS=auto` is the default.
// 195:         description: "Use this value as the number of formula installations to run in parallel for " \
// 196:                      "`brew bundle install`. Use `auto` for the number of CPU cores (max 4).",
// 197:         default:     "auto",
// 198:       },
// 199:       HOMEBREW_BUNDLE_NO_DESCRIBE:               {
// 200:         description: "If set, do not enable bundle description comments from `$HOMEBREW_BUNDLE_DESCRIBE` or " \
// 201:                      "the default. This does not disable an explicit `--describe`.",
// 202:         boolean:     true,
// 203:       },
// 204:       HOMEBREW_BUNDLE_NO_JOBS:                   {
// 205:         description: "If set, do not enable parallel jobs from `$HOMEBREW_BUNDLE_JOBS` or its default. " \
// 206:                      "This does not disable an explicit `--jobs`.",
// 207:         boolean:     true,
// 208:       },
// 209:       HOMEBREW_BUNDLE_NO_SECRETS:                {
// 210:         description: "If set, `brew bundle exec`, `brew bundle env` and `brew bundle sh` will attempt to remove " \
// 211:                      "secrets from the environment. This is the default unless `$HOMEBREW_BUNDLE_SECRETS` is set.",
// 212:         boolean:     true,
// 213:         disabled_by: :HOMEBREW_BUNDLE_SECRETS,
// 214:         default:     true,
// 215:         replacement: "the default behaviour",
// 216:         odeprecated: true,
// 217:       },
// 218:       HOMEBREW_BUNDLE_SECRETS:                   {
// 219:         description: "If set, do not enable the default secret scrubbing. " \
// 220:                      "This does not disable an explicit `--no-secrets`.",
// 221:         boolean:     true,
// 222:       },
// 223:       HOMEBREW_BUNDLE_USER_CACHE:                {
// 224:         description: "If set, use this directory as the `bundle`(1) user cache.",
// 225:       },
// 226:       HOMEBREW_CACHE:                            {
// 227:         description:  "Use this directory as the download cache.",
// 228:         default_text: "macOS: `~/Library/Caches/Homebrew`, " \
// 229:                       "Linux: `$XDG_CACHE_HOME/Homebrew` or `~/.cache/Homebrew`.",
// 230:         default:      HOMEBREW_DEFAULT_CACHE,
// 231:       },
// 232:       HOMEBREW_CASK_OPTS:                        {
// 233:         description: "Append these options to all `cask` commands. All `--*dir` options, " \
// 234:                      "`--language`, `--require-sha` and `--no-binaries` are supported. " \
// 235:                      "For example, you might add something like the following to your " \
// 236:                      "`~/.profile`, `~/.bash_profile`, or `~/.zshenv`:" \
// 237:                      "\n\n    `export HOMEBREW_CASK_OPTS=\"--appdir=${HOME}/Applications --fontdir=/Library/Fonts\"`",
// 238:       },
// 239:       HOMEBREW_CASK_OPTS_BINARIES:               {
// 240:         description: "Enable linking of helper executables for casks. Use " \
// 241:                      "`$HOMEBREW_CASK_OPTS` instead.",
// 242:         replacement: "HOMEBREW_CASK_OPTS",
// 243:         odeprecated: true,
// 244:       },
// 245:       HOMEBREW_CASK_OPTS_REQUIRE_SHA:            {
// 246:         description: "Require all casks to have a checksum. Use `$HOMEBREW_CASK_OPTS` instead.",
// 247:         replacement: "HOMEBREW_CASK_OPTS",
// 248:         odeprecated: true,
// 249:       },
// 250:       HOMEBREW_CLEANUP_MAX_AGE_DAYS:             {
// 251:         description: "Cleanup all cached files older than this many days.",
// 252:         default:     120,
// 253:       },
// 254:       HOMEBREW_CLEANUP_PERIODIC_FULL_DAYS:       {
// 255:         description: "If set, `brew install`, `brew upgrade` and `brew reinstall` will cleanup all formulae " \
// 256:                      "when this number of days has passed.",
// 257:         default:     30,
// 258:       },
// 259:       HOMEBREW_COLOR:                            {
// 260:         description: "If set, force colour output on non-TTY outputs.",
// 261:         boolean:     :set,
// 262:         disabled_by: :HOMEBREW_NO_COLOR,
// 263:       },
// 264:       HOMEBREW_CORE_GIT_REMOTE:                  {
// 265:         description:  "Use this URL as the Homebrew/homebrew-core `git`(1) remote.",
// 266:         default_text: "`https://github.com/Homebrew/homebrew-core`.",
// 267:         default:      HOMEBREW_CORE_DEFAULT_GIT_REMOTE,
// 268:       },
// 269:       HOMEBREW_CURLRC:                           {
// 270:         description: "If set to an absolute path (i.e. beginning with `/`), pass it with `--config` when invoking " \
// 271:                      "`curl`(1). " \
// 272:                      "If set but _not_ a valid path, do not pass `--disable`, which disables the " \
// 273:                      "use of `.curlrc`.",
// 274:       },
// 275:       HOMEBREW_CURL_PATH:                        {
// 276:         description: "Linux only: Set this value to a new enough `curl` executable for Homebrew to use.",
// 277:         default:     "curl",
// 278:       },
// 279:       HOMEBREW_CURL_RETRIES:                     {
// 280:         description: "Pass the given retry count to `--retry` when invoking `curl`(1).",
// 281:         default:     3,
// 282:       },
// 283:       HOMEBREW_CURL_VERBOSE:                     {
// 284:         description: "If set, pass `--verbose` when invoking `curl`(1).",
// 285:         boolean:     true,
// 286:       },
// 287:       HOMEBREW_DEBUG:                            {
// 288:         description: "If set, always assume `--debug` when running commands.",
// 289:         boolean:     :set,
// 290:       },
// 291:       HOMEBREW_DEVELOPER:                        {
// 292:         description: "If set, tweak behaviour to be more relevant for Homebrew developers (active or " \
// 293:                      "budding) by e.g. turning warnings into errors.",
// 294:         boolean:     :set,
// 295:       },
// 296:       HOMEBREW_DISABLE_DEBREW:                   {
// 297:         description: "If set, the interactive formula debugger available via `--debug` will be disabled.",
// 298:         boolean:     true,
// 299:       },
// 300:       HOMEBREW_DISABLE_LOAD_FORMULA:             {
// 301:         description: "If set, refuse to load formulae. This is useful when formulae are not trusted (such " \
// 302:                      "as in pull requests).",
// 303:         boolean:     true,
// 304:       },
// 305:       HOMEBREW_DISPLAY:                          {
// 306:         description:  "Use this X11 display when opening a page in a browser, for example with " \
// 307:                       "`brew home`. Primarily useful on Linux.",
// 308:         default_text: "`$DISPLAY`.",
// 309:       },
// 310:       HOMEBREW_DISPLAY_INSTALL_TIMES:            {
// 311:         description: "If set, print install times for each formula at the end of the run.",
// 312:         boolean:     true,
// 313:       },
// 314:       HOMEBREW_DOCKER_REGISTRY_BASIC_AUTH_TOKEN: {
// 315:         description: "Use this base64 encoded username and password for authenticating with a Docker registry " \
// 316:                      "proxying GitHub Packages. If set to `none`, no authentication header will be sent. " \
// 317:                      "This can be used, if remote `$HOMEBREW_ARTIFACT_DOMAIN` does not support any authentication. " \
// 318:                      "If `$HOMEBREW_DOCKER_REGISTRY_TOKEN` is set, it will be used instead.",
// 319:       },
// 320:       HOMEBREW_DOCKER_REGISTRY_TOKEN:            {
// 321:         description: "Use this bearer token for authenticating with a Docker registry proxying GitHub Packages. " \
// 322:                      "Preferred over `$HOMEBREW_DOCKER_REGISTRY_BASIC_AUTH_TOKEN`.",
// 323:       },
// 324:       HOMEBREW_DOWNLOAD_CONCURRENCY:             {
// 325:         description: "Homebrew will download in parallel using this many concurrent connections. " \
// 326:                      "The default, `auto`, will use twice the number of available CPU cores " \
// 327:                      "(what our benchmarks showed to produce the best performance). " \
// 328:                      "If set to `1`, Homebrew will download in serial.",
// 329:         default:     "auto",
// 330:       },
// 331:       HOMEBREW_EDITOR:                           {
// 332:         description:  "Use this editor when editing a single formula, or several formulae in the " \
// 333:                       "same directory." \
// 334:                       "\n\n    *Note:* `brew edit` will open all of Homebrew as discontinuous files " \
// 335:                       "and directories. Visual Studio Code can handle this correctly in project mode, but many " \
// 336:                       "editors will do strange things in this case.",
// 337:         default_text: "`$EDITOR` or `$VISUAL`.",
// 338:       },
// 339:       HOMEBREW_ENV_SYNC_STRICT:                  {
// 340:         description: "If set, `brew *env-sync` will only sync the exact installed versions of formulae.",
// 341:         boolean:     true,
// 342:       },
// 343:       HOMEBREW_EVAL_ALL:                         {
// 344:         description: "If set, `brew` commands evaluate all trusted formulae and casks, " \
// 345:                      "executing their arbitrary code. Use `$HOMEBREW_REQUIRE_TAP_TRUST` or " \
// 346:                      "`$HOMEBREW_NO_REQUIRE_TAP_TRUST` instead.",
// 347:         boolean:     true,
// 348:         replacement: "HOMEBREW_REQUIRE_TAP_TRUST or HOMEBREW_NO_REQUIRE_TAP_TRUST",
// 349:         odeprecated: true,
// 350:       },
// 351:       HOMEBREW_FAIL_LOG_LINES:                   {
// 352:         description: "Output this many lines of output on formula `system` failures.",
// 353:         default:     15,
// 354:       },
// 355:       HOMEBREW_FORBIDDEN_CASKS:                  {
// 356:         description: "A space-separated list of casks. Homebrew will refuse to install a " \
// 357:                      "cask if it or any of its dependencies is on this list.",
// 358:       },
// 359:       HOMEBREW_FORBIDDEN_CASK_ARTIFACTS:         {
// 360:         description: "A space-separated list of cask artifact types (e.g. `pkg installer`) that should be " \
// 361:                      "forbidden during cask installation. " \
// 362:                      "Valid values: `pkg`, `installer`, `binary`, `uninstall`, `zap`, `app`, `suite`, " \
// 363:                      "`artifact`, `prefpane`, `qlplugin`, `dictionary`, `font`, `service`, `colorpicker`, " \
// 364:                      "`inputmethod`, `internetplugin`, `audiounitplugin`, `vstplugin`, `vst3plugin`, " \
// 365:                      "`screensaver`, `keyboardlayout`, `mdimporter`, `preflight`, `postflight`, " \
// 366:                      "`manpage`, `bashcompletion`, `fishcompletion`, `zshcompletion`, `stageonly`.",
// 367:       },
// 368:       HOMEBREW_FORBIDDEN_FORMULAE:               {
// 369:         description: "A space-separated list of formulae. Homebrew will refuse to install a " \
// 370:                      "formula or cask if it or any of its dependencies is on this list.",
// 371:       },
// 372:       HOMEBREW_FORBIDDEN_LICENSES:               {
// 373:         description: "A space-separated list of SPDX licence identifiers. Homebrew will refuse to install a " \
// 374:                      "formula if it or any of its dependencies has a licence on this list.",
// 375:       },
// 376:       HOMEBREW_FORBIDDEN_OWNER:                  {
// 377:         description: "The person who has set any `$HOMEBREW_FORBIDDEN_*` variables.",
// 378:         default:     "you",
// 379:       },
// 380:       HOMEBREW_FORBIDDEN_OWNER_CONTACT:          {
// 381:         description: "How to contact the `$HOMEBREW_FORBIDDEN_OWNER`, if set and necessary.",
// 382:       },
// 383:       HOMEBREW_FORBIDDEN_TAPS:                   {
// 384:         description: "A space-separated list of taps. Homebrew will refuse to install a " \
// 385:                      "formula if it or any of its dependencies is in a tap on this list. " \
// 386:                      "Each entry is a `user/repository` name (which matches only taps using " \
// 387:                      "the default GitHub remote) or a remote URL (required to match taps " \
// 388:                      "with a custom remote).",
// 389:       },
// 390:       HOMEBREW_FORBID_CASKS:                     {
// 391:         description: "If set, Homebrew will refuse to install any casks.",
// 392:         boolean:     true,
// 393:       },
// 394:       HOMEBREW_FORBID_PACKAGES_FROM_PATHS:       {
// 395:         description:  "If set, Homebrew will refuse to read formulae or casks provided from file paths, " \
// 396:                       "e.g. `brew install ./package.rb`.",
// 397:         boolean:      :set,
// 398:         default_text: "true unless `$HOMEBREW_DEVELOPER` is set.",
// 399:         # Keep in sync with forbid_packages_from_paths? below.
// 400:         default:      -> { ENV["HOMEBREW_TESTS"].blank? && ENV["HOMEBREW_DEVELOPER"].blank? },
// 401:       },
// 402:       HOMEBREW_FORCE_API_AUTO_UPDATE:            {
// 403:         description: "If set, update the Homebrew API formula or cask data even if " \
// 404:                      "`$HOMEBREW_NO_AUTO_UPDATE` is set.",
// 405:         boolean:     true,
// 406:       },
// 407:       HOMEBREW_FORCE_BREWED_CA_CERTIFICATES:     {
// 408:         description: "If set, always use a Homebrew-installed `ca-certificates` rather than the system version. " \
// 409:                      "Automatically set if the system version is too old.",
// 410:         boolean:     :set,
// 411:       },
// 412:       HOMEBREW_FORCE_BREWED_CURL:                {
// 413:         description: "If set, always use a Homebrew-installed `curl`(1) rather than the system version. " \
// 414:                      "Automatically set if the system version of `curl` is too old.",
// 415:         boolean:     :set,
// 416:       },
// 417:       HOMEBREW_FORCE_BREWED_GIT:                 {
// 418:         description: "If set, always use a Homebrew-installed `git`(1) rather than the system version. " \
// 419:                      "Automatically set if the system version of `git` is too old.",
// 420:         boolean:     :set,
// 421:       },
// 422:       HOMEBREW_FORCE_BREW_WRAPPER:               {
// 423:         description: "If set, require `brew` to be invoked by the value of " \
// 424:                      "`$HOMEBREW_FORCE_BREW_WRAPPER` for non-trivial `brew` commands.",
// 425:       },
// 426:       HOMEBREW_FORCE_BREW_WRAPPER_HELP_MESSAGE:  {
// 427:         description: "If set, appended to the `$HOMEBREW_FORCE_BREW_WRAPPER` error message to provide " \
// 428:                      "additional help or context to the user.",
// 429:       },
// 430:       HOMEBREW_FORCE_VENDOR_RUBY:                {
// 431:         description: "If set, always use Homebrew's vendored, relocatable Ruby version even if the system version " \
// 432:                      "of Ruby is new enough.",
// 433:         boolean:     :set,
// 434:       },
// 435:       HOMEBREW_FORMULA_BUILD_NETWORK:            {
// 436:         description: "If set, controls network access to the sandbox for formulae builds. Overrides any " \
// 437:                      "controls set through DSL usage inside formulae. Must be `allow` or `deny`. If no value is " \
// 438:                      "set through this environment variable or DSL usage, the default behaviour is `allow`.",
// 439:       },
// 440:       HOMEBREW_FORMULA_POSTINSTALL_NETWORK:      {
// 441:         description: "If set, controls network access to the sandbox for formulae postinstall. Overrides any " \
// 442:                      "controls set through DSL usage inside formulae. Must be `allow` or `deny`. If no value is " \
// 443:                      "set through this environment variable or DSL usage, the default behaviour is `allow`.",
// 444:       },
// 445:       HOMEBREW_FORMULA_TEST_NETWORK:             {
// 446:         description: "If set, controls network access to the sandbox for formulae test. Overrides any " \
// 447:                      "controls set through DSL usage inside formulae. Must be `allow` or `deny`. If no value is " \
// 448:                      "set through this environment variable or DSL usage, the default behaviour is `allow`.",
// 449:       },
// 450:       HOMEBREW_GITHUB_API_TOKEN:                 {
// 451:         description: "Use this personal access token for the GitHub API, for features such as " \
// 452:                      "`brew search`. You can create one at <https://github.com/settings/tokens>. If set, " \
// 453:                      "GitHub will allow you a greater number of API requests. For more information, see: " \
// 454:                      "<https://docs.github.com/en/rest/overview/rate-limits-for-the-rest-api>" \
// 455:                      "\n\n    *Note:* Homebrew doesn't require permissions for any of the scopes, but some " \
// 456:                      "developer commands may require additional permissions.",
// 457:       },
// 458:       HOMEBREW_GITHUB_PACKAGES_TOKEN:            {
// 459:         description: "Use this GitHub personal access token when accessing the GitHub Packages Registry " \
// 460:                      "(where bottles may be stored).",
// 461:       },
// 462:       HOMEBREW_GITHUB_PACKAGES_USER:             {
// 463:         description: "Use this username when accessing the GitHub Packages Registry (where bottles may be stored).",
// 464:       },
// 465:       HOMEBREW_GIT_COMMITTER_EMAIL:              {
// 466:         description: "Set the Git committer email to this value.",
// 467:       },
// 468:       HOMEBREW_GIT_COMMITTER_NAME:               {
// 469:         description: "Set the Git committer name to this value.",
// 470:       },
// 471:       HOMEBREW_GIT_EMAIL:                        {
// 472:         description: "Set the Git author name and, if `$HOMEBREW_GIT_COMMITTER_EMAIL` is unset, committer email to " \
// 473:                      "this value.",
// 474:       },
// 475:       HOMEBREW_GIT_NAME:                         {
// 476:         description: "Set the Git author name and, if `$HOMEBREW_GIT_COMMITTER_NAME` is unset, committer name to " \
// 477:                      "this value.",
// 478:       },
// 479:       HOMEBREW_GIT_PATH:                         {
// 480:         description: "Linux only: Set this value to a new enough `git` executable for Homebrew to use.",
// 481:         default:     "git",
// 482:       },
// 483:       HOMEBREW_INSTALL_BADGE:                    {
// 484:         description:  "Print this text before the installation summary of each successful build.",
// 485:         default_text: 'The "Beer Mug" emoji.',
// 486:         default:      "🍺",
// 487:       },
// 488:       HOMEBREW_LIVECHECK_AUTOBUMP:               {
// 489:         description: "If set, `brew livecheck` will include data for packages that are autobumped by BrewTestBot.",
// 490:         boolean:     true,
// 491:       },
// 492:       HOMEBREW_LIVECHECK_WATCHLIST:              {
// 493:         description:  "Consult this file for the list of formulae to check by default when no formula argument " \
// 494:                       "is passed to `brew livecheck`.",
// 495:         default_text: "`${XDG_CONFIG_HOME}/homebrew/livecheck_watchlist.txt` if `$XDG_CONFIG_HOME` is set " \
// 496:                       "or `~/.homebrew/livecheck_watchlist.txt` otherwise.",
// 497:         default:      "#{ENV.fetch("HOMEBREW_USER_CONFIG_HOME")}/livecheck_watchlist.txt",
// 498:       },
// 499:       HOMEBREW_LOCK_CONTEXT:                     {
// 500:         description: "If set, Homebrew will add this output as additional context for locking errors. " \
// 501:                      "This is useful when running `brew` in the background.",
// 502:       },
// 503:       HOMEBREW_LOGS:                             {
// 504:         description:  "Use this directory to store log files.",
// 505:         default_text: "macOS: `~/Library/Logs/Homebrew`, " \
// 506:                       "Linux: `${XDG_CACHE_HOME}/Homebrew/Logs` or `~/.cache/Homebrew/Logs`.",
// 507:         default:      HOMEBREW_DEFAULT_LOGS,
// 508:       },
// 509:       HOMEBREW_MAKE_JOBS:                        {
// 510:         description:  "Use this value as the number of parallel jobs to run when building with `make`(1).",
// 511:         default_text: "The number of available CPU cores.",
// 512:         default:      lambda {
// 513:           require "os"
// 514:           require "hardware"
// 515:           Hardware::CPU.cores
// 516:         },
// 517:       },
// 518:       HOMEBREW_NO_ANALYTICS:                     {
// 519:         description: "If set, do not send analytics. Google Analytics were destroyed. " \
// 520:                      "For more information, see: <https://docs.brew.sh/Analytics>",
// 521:         boolean:     :set,
// 522:       },
// 523:       HOMEBREW_NO_ASK:                           {
// 524:         description: "If set, do not enable default ask mode. This does not disable an explicit `--ask`.",
// 525:         boolean:     :set,
// 526:       },
// 527:       HOMEBREW_NO_AUTOREMOVE:                    {
// 528:         description: "If set, calls to `brew cleanup` and `brew uninstall` will not automatically " \
// 529:                      "remove unused formula dependents.",
// 530:         boolean:     true,
// 531:       },
// 532:       HOMEBREW_NO_AUTO_UPDATE:                   {
// 533:         description: "If set, do not automatically update before running some commands, e.g. " \
// 534:                      "`brew install`, `brew upgrade` or `brew tap`. Preferably, " \
// 535:                      "run this less often by setting `$HOMEBREW_AUTO_UPDATE_SECS` to a value higher than the " \
// 536:                      "default. Note that setting this and e.g. tapping new taps may result in a broken  " \
// 537:                      "configuration. Please ensure you always run `brew update` before reporting any issues.",
// 538:         boolean:     :set,
// 539:       },
// 540:       HOMEBREW_NO_BOOTSNAP:                      {
// 541:         description: "If set, do not use Bootsnap to speed up repeated `brew` calls.",
// 542:         boolean:     :set,
// 543:       },
// 544:       HOMEBREW_NO_CLEANUP_FORMULAE:              {
// 545:         description: "A comma-separated list of formulae. Homebrew will refuse to clean up " \
// 546:                      "or autoremove a formula if it appears on this list.",
// 547:       },
// 548:       HOMEBREW_NO_COLOR:                         {
// 549:         description:  "If set, do not print text with colour added.",
// 550:         default_text: "`$NO_COLOR`.",
// 551:         boolean:      :set,
// 552:       },
// 553:       HOMEBREW_NO_EMOJI:                         {
// 554:         description: "If set, do not print `$HOMEBREW_INSTALL_BADGE` on a successful build.",
// 555:         boolean:     :set,
// 556:       },
// 557:       HOMEBREW_NO_ENV_HINTS:                     {
// 558:         description: "If set, do not print any hints about changing Homebrew's behaviour with environment variables.",
// 559:         boolean:     :set,
// 560:       },
// 561:       HOMEBREW_NO_EVAL_ENV_SCRUBBING:            {
// 562:         # odeprecated: remove in a later release
// 563:         description: "If set, sensitive environment variables are available while evaluating " \
// 564:                      "formulae and casks. `$HOMEBREW_GITHUB_API_TOKEN` is still available during evaluation " \
// 565:                      "when this is unset. This setting will be removed in a later release.",
// 566:         boolean:     true,
// 567:         odeprecated: true,
// 568:       },
// 569:       HOMEBREW_NO_FORCE_BREW_WRAPPER:            {
// 570:         description: "`Deprecated:` If set, disables `$HOMEBREW_FORCE_BREW_WRAPPER` behaviour, even if set.",
// 571:         boolean:     :set,
// 572:       },
// 573:       HOMEBREW_NO_GITHUB_API:                    {
// 574:         description: "If set, do not use the GitHub API, e.g. for searches or fetching relevant issues " \
// 575:                      "after a failed install.",
// 576:         boolean:     true,
// 577:       },
// 578:       HOMEBREW_NO_INSECURE_REDIRECT:             {
// 579:         description: "If set, forbid redirects from secure HTTPS to insecure HTTP." \
// 580:                      "\n\n    *Note:* while ensuring your downloads are fully secure, this is likely to cause " \
// 581:                      "sources for certain formulae hosted by SourceForge, GNU or GNOME to fail to download.",
// 582:         boolean:     true,
// 583:       },
// 584:       HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK:    {
// 585:         description: "If set, do not check for broken linkage of dependents or outdated dependents after " \
// 586:                      "installing, upgrading or reinstalling formulae. This will result in fewer dependents " \
// 587:                      "(and their dependencies) being upgraded or reinstalled but may result in more breakage " \
// 588:                      "from running `brew install` <formula> or `brew upgrade` <formula>.",
// 589:         boolean:     true,
// 590:       },
// 591:       HOMEBREW_NO_INSTALL_CLEANUP:               {
// 592:         description: "If set, `brew install`, `brew upgrade` and `brew reinstall` will never automatically " \
// 593:                      "cleanup installed/upgraded/reinstalled formulae or all formulae every " \
// 594:                      "`$HOMEBREW_CLEANUP_PERIODIC_FULL_DAYS` days. Alternatively, `$HOMEBREW_NO_CLEANUP_FORMULAE` " \
// 595:                      "allows specifying specific formulae to not clean up.",
// 596:         boolean:     :set,
// 597:       },
// 598:       HOMEBREW_NO_INSTALL_FROM_API:              {
// 599:         description: "If set, do not install formulae and casks in homebrew/core and homebrew/cask taps using " \
// 600:                      "Homebrew's API and instead use (large, slow) local checkouts of these repositories.",
// 601:         boolean:     :set,
// 602:       },
// 603:       HOMEBREW_NO_INSTALL_UPGRADE:               {
// 604:         description: "If set, `brew install` <formula|cask> will not upgrade <formula|cask> if it is installed but " \
// 605:                      "outdated.",
// 606:         boolean:     true,
// 607:       },
// 608:       HOMEBREW_NO_PATH_SHADOW_CHECK:             {
// 609:         description: "If set, `brew info` and `brew install` will not warn when a formula's executables are " \
// 610:                      "shadowed by other commands earlier on `$PATH`.",
// 611:         boolean:     true,
// 612:       },
// 613:       HOMEBREW_NO_REQUIRE_TAP_TRUST:             {
// 614:         # odeprecated: remove in a later release after tap trust checks are the default.
// 615:         description: "If set, do not require non-official tap formulae, casks or commands to be trusted. " \
// 616:                      "This is not recommended and will be removed in a later release. Also enables commands " \
// 617:                      "that evaluate all formulae and casks.",
// 618:         boolean:     :set,
// 619:       },
// 620:       HOMEBREW_NO_SANDBOX_CASK:                  {
// 621:         description: "If set, disable sandboxing for cask artifacts that generate files by running " \
// 622:                      "executables.",
// 623:         boolean:     true,
// 624:         odeprecated: true,
// 625:       },
// 626:       HOMEBREW_NO_SANDBOX_LINUX:                 {
// 627:         description: "If set, disable the Linux sandbox.",
// 628:         boolean:     :set,
// 629:       },
// 630:       HOMEBREW_NO_UPDATE_REPORT_NEW:             {
// 631:         description: "If set, `brew update` will not show the list of newly added formulae/casks.",
// 632:         boolean:     true,
// 633:       },
// 634:       HOMEBREW_NO_UPGRADE_AUTO_UPDATES_CASKS:    {
// 635:         description: "If set, `brew upgrade` will not automatically upgrade casks with `auto_updates true`. " \
// 636:                      "Does not affect `--greedy` or `--greedy-auto-updates` upgrades.",
// 637:         boolean:     :set,
// 638:       },
// 639:       HOMEBREW_NO_UPGRADE_QUIT_CASKS:            {
// 640:         description: "If set, `brew upgrade` will not quit running applications for casks during upgrades.",
// 641:         boolean:     true,
// 642:       },
// 643:       HOMEBREW_NO_VERIFY_ATTESTATIONS:           {
// 644:         description: "If set, Homebrew will not verify cryptographic attestations of build provenance for bottles " \
// 645:                      "from homebrew-core.",
// 646:         boolean:     :set,
// 647:       },
// 648:       HOMEBREW_PIP_INDEX_URL:                    {
// 649:         description:  "If set, `brew install` <formula> will use this URL to download PyPI package resources.",
// 650:         default_text: "`https://pypi.org/simple`.",
// 651:         default:      "https://pypi.org/simple",
// 652:       },
// 653:       HOMEBREW_PRY:                              {
// 654:         description: "This variable no longer has any effect because Pry is largely unmaintained upstream.",
// 655:         boolean:     true,
// 656:         odeprecated: true,
// 657:         replacement: "the default IRB backend (Pry is largely unmaintained upstream)",
// 658:       },
// 659:       HOMEBREW_REQUIRE_TAP_TRUST:                {
// 660:         # odeprecated: make tap trust checks default in a later release.
// 661:         description: "If set, require non-official tap formulae, casks and commands to be trusted with " \
// 662:                      "`brew trust` before Homebrew loads them. This is the default unless " \
// 663:                      "`$HOMEBREW_NO_REQUIRE_TAP_TRUST` is set. Also enables commands that evaluate all formulae " \
// 664:                      "and casks.",
// 665:         boolean:     :set,
// 666:         disabled_by: :HOMEBREW_NO_REQUIRE_TAP_TRUST,
// 667:         default:     true,
// 668:       },
// 669:       HOMEBREW_SANDBOX_LINUX:                    {
// 670:         description: "The Landlock sandbox is the default for formula installation and testing " \
// 671:                      "on Linux unless `$HOMEBREW_NO_SANDBOX_LINUX` is set.",
// 672:         boolean:     :set,
// 673:         disabled_by: :HOMEBREW_NO_SANDBOX_LINUX,
// 674:         default:     true,
// 675:         odeprecated: true,
// 676:       },
// 677:       HOMEBREW_SBOM:                             {
// 678:         description: "Write SBOM files for source installs.",
// 679:         boolean:     :set,
// 680:         default:     true,
// 681:         hidden:      true,
// 682:       },
// 683:       HOMEBREW_SIMULATE_MACOS_ON_LINUX:          {
// 684:         description: "If set, running Homebrew on Linux will simulate certain macOS code paths. This is useful " \
// 685:                      "when auditing macOS formulae while on Linux.",
// 686:         boolean:     true,
// 687:       },
// 688:       HOMEBREW_SKIP_OR_LATER_BOTTLES:            {
// 689:         description: "If set along with `$HOMEBREW_DEVELOPER`, do not use bottles from older versions " \
// 690:                      "of macOS. This is useful in development on new macOS versions.",
// 691:         boolean:     true,
// 692:       },
// 693:       HOMEBREW_SORBET_RECURSIVE:                 {
// 694:         description: "If set along with `$HOMEBREW_SORBET_RUNTIME`, enable recursive typechecking using Sorbet. " \
// 695:                      "Automatically enabled when running `brew tests`.",
// 696:         boolean:     true,
// 697:       },
// 698:       HOMEBREW_SORBET_RUNTIME:                   {
// 699:         description: "If set, enable runtime typechecking using Sorbet. " \
// 700:                      "Set by default when running `brew test`, `brew test-bot` or `brew tests`.",
// 701:         boolean:     :set,
// 702:       },
// 703:       HOMEBREW_SSH_CONFIG_PATH:                  {
// 704:         description:  "If set, Homebrew will use the given config file instead of `~/.ssh/config` when " \
// 705:                       "fetching Git repositories over SSH.",
// 706:         default_text: "`~/.ssh/config`",
// 707:         default:      -> { "#{Dir.home}/.ssh/config" },
// 708:       },
// 709:       HOMEBREW_SUDO_THROUGH_SUDO_USER:           {
// 710:         description: "If set, Homebrew will use the `$SUDO_USER` environment variable to define the user to " \
// 711:                      "`sudo`(8) through when running `sudo`(8).",
// 712:         boolean:     true,
// 713:       },
// 714:       HOMEBREW_SVN:                              {
// 715:         description:  "Use this as the `svn`(1) binary.",
// 716:         default_text: "A Homebrew-built Subversion (if installed), or the system-provided binary.",
// 717:       },
// 718:       HOMEBREW_SYSTEM_ENV_TAKES_PRIORITY:        {
// 719:         description: "If set in Homebrew's system-wide environment file (`/etc/homebrew/brew.env`), " \
// 720:                      "the system-wide environment file will be loaded last to override any prefix or user settings.",
// 721:         boolean:     :set,
// 722:       },
// 723:       HOMEBREW_TEMP:                             {
// 724:         description:  "Use this path as the temporary directory for building packages. Changing " \
// 725:                       "this may be needed if your system temporary directory and Homebrew prefix are on " \
// 726:                       "different volumes, as macOS has trouble moving symlinks across volumes when the target " \
// 727:                       "does not yet exist. This issue typically occurs when using FileVault or custom SSD " \
// 728:                       "configurations.",
// 729:         default_text: "macOS: `/private/tmp`, Linux: `/var/tmp`.",
// 730:         default:      HOMEBREW_DEFAULT_TEMP,
// 731:       },
// 732:       HOMEBREW_UPDATE_TO_TAG:                    {
// 733:         description: "If set, always use the latest stable tag (even if developer commands " \
// 734:                      "have been run).",
// 735:         boolean:     :set,
// 736:       },
// 737:       HOMEBREW_UPGRADE_AUTO_UPDATES_CASKS:       {
// 738:         description: "If set, `brew upgrade` will automatically upgrade casks with `auto_updates true` when " \
// 739:                      "Homebrew detects that the version in the app bundle is older than the version in the tap. " \
// 740:                      "Does not affect `--greedy` or `--greedy-auto-updates` upgrades. This is the default unless " \
// 741:                      "`$HOMEBREW_NO_UPGRADE_AUTO_UPDATES_CASKS` is set.",
// 742:         boolean:     :set,
// 743:         disabled_by: :HOMEBREW_NO_UPGRADE_AUTO_UPDATES_CASKS,
// 744:         default:     true,
// 745:         replacement: "the default behaviour",
// 746:         odeprecated: true,
// 747:       },
// 748:       HOMEBREW_UPGRADE_GREEDY:                   {
// 749:         description: "If set, pass `--greedy` to all cask upgrade commands.",
// 750:         boolean:     true,
// 751:       },
// 752:       HOMEBREW_UPGRADE_GREEDY_CASKS:             {
// 753:         description: "A space-separated list of casks. Homebrew will act as " \
// 754:                      "if `--greedy` was passed when upgrading any cask on this list.",
// 755:       },
// 756:       HOMEBREW_USE_INTERNAL_API:                 {
// 757:         description: "If set, fetch formula and cask data from Homebrew's internal API. This is now the default.",
// 758:         boolean:     :set,
// 759:         replacement: "the default behaviour",
// 760:         odeprecated: true,
// 761:       },
// 762:       HOMEBREW_VERBOSE:                          {
// 763:         description: "If set, always assume `--verbose` when running commands.",
// 764:         boolean:     :set,
// 765:       },
// 766:       HOMEBREW_VERBOSE_USING_DOTS:               {
// 767:         description: "If set, verbose output will print a `.` no more than once a minute. This can be " \
// 768:                      "useful to avoid long-running Homebrew commands being killed due to no output.",
// 769:         boolean:     true,
// 770:       },
// 771:       HOMEBREW_VERIFY_ATTESTATIONS:              {
// 772:         description: "If set, Homebrew will use the `gh` tool to verify cryptographic attestations " \
// 773:                      "of build provenance for bottles from homebrew-core.",
// 774:         boolean:     :set,
// 775:         disabled_by: :HOMEBREW_NO_VERIFY_ATTESTATIONS,
// 776:       },
// 777:       SUDO_ASKPASS:                              {
// 778:         description: "If set, pass the `-A` option when calling `sudo`(8).",
// 779:       },
// 780:       all_proxy:                                 {
// 781:         description: "Use this SOCKS5 proxy for `curl`(1), `git`(1) and `svn`(1) when downloading through Homebrew.",
// 782:       },
// 783:       ftp_proxy:                                 {
// 784:         description: "Use this FTP proxy for `curl`(1), `git`(1) and `svn`(1) when downloading through Homebrew.",
// 785:       },
// 786:       http_proxy:                                {
// 787:         description: "Use this HTTP proxy for `curl`(1), `git`(1) and `svn`(1) when downloading through Homebrew.",
// 788:       },
// 789:       https_proxy:                               {
// 790:         description: "Use this HTTPS proxy for `curl`(1), `git`(1) and `svn`(1) when downloading through Homebrew.",
// 791:       },
// 792:       no_proxy:                                  {
// 793:         description: "A comma-separated list of hostnames and domain names excluded " \
// 794:                      "from proxying by `curl`(1), `git`(1) and `svn`(1) when downloading through Homebrew.",
// 795:       },
// 796:     }.freeze, T::Hash[Symbol, T::Hash[Symbol, T.untyped]])
// 797:
// 798:     ANALYTICS_VARIABLES = T.let((ENVS.keys - [:HOMEBREW_NO_ANALYTICS]).freeze, T::Array[Symbol])
// 799:
// 800:     sig { params(env: Symbol, hash: T::Hash[Symbol, T.untyped]).returns(String) }
// 801:     def env_method_name(env, hash)
// 802:       method_name = env.to_s
// 803:                        .sub(/^HOMEBREW_/, "")
// 804:                        .downcase
// 805:       method_name = "#{method_name}?" if hash[:boolean]
// 806:       method_name
// 807:     end
// 808:
// 809:     sig { params(hash: T::Hash[Symbol, T.untyped]).returns(T::Boolean) }
// 810:     def hidden?(hash)
// 811:       !!(hash[:hidden] || hash[:odeprecated] || hash[:odisabled])
// 812:     end
// 813:
// 814:     # The default value as human text, e.g. for the manpage or analytics:
// 815:     # `default_text` summarises defaults that vary by platform or machine.
// 816:     sig { params(env: Symbol).returns(T.nilable(String)) }
// 817:     def default_description(env)
// 818:       hash = ENVS[env]
// 819:       return if hash.nil?
// 820:
// 821:       default_text = hash[:default_text]
// 822:       return default_text if default_text
// 823:
// 824:       default = hash[:default]
// 825:       "`#{default}`." if default
// 826:     end
// 827:
// 828:     # Defaults and parsing that cannot be expressed by the generated helpers.
// 829:     CUSTOM_IMPLEMENTATIONS = T.let(Set.new([
// 830:       :HOMEBREW_BUNDLE_JOBS,
// 831:       :HOMEBREW_CASK_OPTS,
// 832:       :HOMEBREW_DOWNLOAD_CONCURRENCY,
// 833:       :HOMEBREW_FORBID_PACKAGES_FROM_PATHS,
// 834:       :HOMEBREW_MAKE_JOBS,
// 835:     ]).freeze, T::Set[Symbol])
// 836:
// 837:     # This tracks process-local warnings, so it must remain mutable.
// 838:     WARNED_DEPRECATED_ENVS = T.let(Set.new, T::Set[String]) # rubocop:disable Style/MutableConstant
// 839:
// 840:     # Boolean env vars have two generated parsing modes. Use `boolean: true`
// 841:     # for Ruby-only toggles that accept explicit false values like `0` or
// 842:     # `false`. Use `boolean: :set` for toggles used by Bash or with inverse
// 843:     # `_NO_` variants, where any non-empty value must mean enabled. Use
// 844:     # `disabled_by:` when one boolean env var should override another.
// 845:     FALSY_VALUES = %w[false no off nil 0].freeze
// 846:
// 847:     sig { params(env: Symbol).returns(T::Boolean) }
// 848:     def non_default_variable?(env)
// 849:       value = ENV.fetch(env.to_s, nil)
// 850:       # Blank values behave like unset in the generated accessors.
// 851:       return false if value.blank?
// 852:
// 853:       config = ENVS.fetch(env)
// 854:       default = config.fetch(:default, config[:boolean] ? false : nil)
// 855:       default = default.call if default.respond_to?(:call)
// 856:       if config[:boolean]
// 857:         enabled = config[:boolean] == :set || FALSY_VALUES.exclude?(value.downcase)
// 858:         enabled != default
// 859:       else
// 860:         value != default.to_s
// 861:       end
// 862:     end
// 863:
// 864:     # Whether the user set this variable rather than Homebrew exporting
// 865:     # it itself, e.g. `HOMEBREW_EDITOR` from `EDITOR`. The matching Bash
// 866:     # records `HOMEBREW_USER_SET_VARS` in `bin/brew` before any exports.
// 867:     sig { params(env: Symbol).returns(T::Boolean) }
// 868:     def user_set_variable?(env)
// 869:       return false if ENV.fetch(env.to_s, nil).blank?
// 870:       return true unless env.to_s.start_with?("HOMEBREW_")
// 871:
// 872:       ENV.fetch("HOMEBREW_USER_SET_VARS", "").split.include?(env.to_s)
// 873:     end
// 874:
// 875:     sig { returns(T::Array[String]) }
// 876:     def non_default_variables
// 877:       ENV.filter_map do |env, _value|
// 878:         env_symbol = env.to_sym
// 879:         env if ENVS.key?(env_symbol) && user_set_variable?(env_symbol) && non_default_variable?(env_symbol)
// 880:       end.sort
// 881:     end
// 882:
// 883:     ENVS.each do |env, hash|
// 884:       # Needs a custom implementation.
// 885:       next if CUSTOM_IMPLEMENTATIONS.include?(env)
// 886:
// 887:       method_name = env_method_name(env, hash)
// 888:       env = env.to_s
// 889:
// 890:       if hash[:boolean]
// 891:         define_method(method_name) do
// 892:           return false if hash[:disabled_by] &&
// 893:                           Homebrew::EnvConfig.public_send(
// 894:                             env_method_name(hash[:disabled_by], ENVS.fetch(hash[:disabled_by])),
// 895:                           )
// 896:
// 897:           env_value = env_value(env, hash)
// 898:           return true if hash[:default] == true && env_value.blank?
// 899:
// 900:           env_value.present? && (hash[:boolean] == :set || FALSY_VALUES.exclude?(env_value.downcase))
// 901:         end
// 902:       elsif hash[:default].present?
// 903:         define_method(method_name) do
// 904:           value = env_value(env, hash).presence
// 905:           next value if value
// 906:
// 907:           default = hash.fetch(:default)
// 908:           default = default.call if default.respond_to?(:call)
// 909:           default.to_s
// 910:         end
// 911:       else
// 912:         define_method(method_name) do
// 913:           env_value(env, hash).presence
// 914:         end
// 915:       end
// 916:     end
// 917:
// 918:     sig { params(env: T.any(String, Symbol), hash: T::Hash[Symbol, T.untyped]).returns(T.nilable(String)) }
// 919:     def env_value(env, hash)
// 920:       env = env.to_s
// 921:       env_value = ENV.fetch(env, nil)
// 922:       return if env_value.nil?
// 923:
// 924:       if env_value.present? && (hash[:default] != true || FALSY_VALUES.exclude?(env_value.downcase))
// 925:         odeprecated_env(env, hash)
// 926:       end
// 927:       if (replacement = hash[:replacement]).is_a?(Symbol)
// 928:         ENV[replacement.to_s] ||= env_value
// 929:       end
// 930:       env_value
// 931:     end
// 932:
// 933:     sig { params(env: String, hash: T::Hash[Symbol, T.untyped]).void }
// 934:     def odeprecated_env(env, hash)
// 935:       return if !hash[:odeprecated] && !hash[:odisabled]
// 936:       return unless env_deprecation_applies?(hash)
// 937:
// 938:       replacement = hash[:replacement] if hash.key?(:replacement)
// 939:       return if !Homebrew.raise_deprecation_exceptions? && ENV["HOMEBREW_TESTS"].blank? &&
// 940:                 !WARNED_DEPRECATED_ENVS.add?(env)
// 941:
// 942:       odeprecated env, replacement, disable: hash.fetch(:odisabled, false)
// 943:     end
// 944:
// 945:     sig { params(hash: T::Hash[Symbol, T.untyped]).returns(T::Boolean) }
// 946:     def env_deprecation_applies?(hash)
// 947:       commands = Array(hash[:commands]).map(&:to_s)
// 948:       command = ENV.fetch("HOMEBREW_COMMAND", nil)
// 949:       return false if commands.present? && command.present? && commands.exclude?(command)
// 950:
// 951:       subcommands = Array(hash[:subcommands]).map(&:to_s)
// 952:       subcommand = ENV.fetch("HOMEBREW_SUBCOMMAND", nil)
// 953:       return false if subcommands.present? && subcommand.present? && subcommands.exclude?(subcommand)
// 954:
// 955:       true
// 956:     end
// 957:
// 958:     sig { returns(T::Boolean) }
// 959:     def bottle_domain_custom?
// 960:       Homebrew::EnvConfig.bottle_domain != HOMEBREW_BOTTLE_DEFAULT_DOMAIN
// 961:     end
// 962:
// 963:     sig { returns(String) }
// 964:     def make_jobs
// 965:       jobs = ENV["HOMEBREW_MAKE_JOBS"].to_i
// 966:       return jobs.to_s if jobs.positive?
// 967:
// 968:       ENVS.fetch(:HOMEBREW_MAKE_JOBS)
// 969:           .fetch(:default)
// 970:           .call
// 971:           .to_s
// 972:     end
// 973:
// 974:     sig { returns(T::Array[String]) }
// 975:     def cask_opts
// 976:       Shellwords.shellsplit(ENV.fetch("HOMEBREW_CASK_OPTS", ""))
// 977:     end
// 978:
// 979:     sig { returns(T::Boolean) }
// 980:     def self.cask_opts_binaries?
// 981:       cask_opts.reverse_each do |opt|
// 982:         return true if opt == "--binaries"
// 983:         return false if opt == "--no-binaries"
// 984:       end
// 985:
// 986:       method_name = :cask_opts_binaries
// 987:       env_value = T.cast(Homebrew::EnvConfig.public_send(method_name), T.nilable(String))
// 988:       return FALSY_VALUES.exclude?(env_value.downcase) if env_value.present?
// 989:
// 990:       true
// 991:     end
// 992:
// 993:     sig { returns(T::Boolean) }
// 994:     def cask_opts_require_sha?
// 995:       return true if cask_opts.include?("--require-sha")
// 996:
// 997:       method_name = :cask_opts_require_sha
// 998:       env_value = T.cast(Homebrew::EnvConfig.public_send(method_name), T.nilable(String))
// 999:       env_value.present? && FALSY_VALUES.exclude?(env_value.downcase)
// 1000:     end
// 1001:
// 1002:     sig { returns(T.nilable(String)) }
// 1003:     def bundle_jobs
// 1004:       if (env_value = ENV.fetch("HOMEBREW_BUNDLE_NO_JOBS", nil)).present? && FALSY_VALUES.exclude?(env_value.downcase)
// 1005:         return
// 1006:       end
// 1007:
// 1008:       default = ENVS.fetch(:HOMEBREW_BUNDLE_JOBS).fetch(:default).to_s
// 1009:       jobs = ENV["HOMEBREW_BUNDLE_JOBS"].presence
// 1010:       opoo "HOMEBREW_BUNDLE_JOBS=#{default} is now the default and no longer needs to be set." if jobs == default
// 1011:
// 1012:       jobs || default
// 1013:     end
// 1014:
// 1015:     sig { returns(T::Boolean) }
// 1016:     def forbid_packages_from_paths?
// 1017:       # Undocumented opt-out for internal use.
// 1018:       return false if ENV["HOMEBREW_INTERNAL_ALLOW_PACKAGES_FROM_PATHS"].present?
// 1019:
// 1020:       return true if ENV["HOMEBREW_FORBID_PACKAGES_FROM_PATHS"].present?
// 1021:
// 1022:       # Provide an opt-out for tests and developers.
// 1023:       # Our testing framework installs formulae from file paths all over the place.
// 1024:       # Keep in sync with the HOMEBREW_FORBID_PACKAGES_FROM_PATHS default above.
// 1025:       ENV["HOMEBREW_TESTS"].blank? && ENV["HOMEBREW_DEVELOPER"].blank?
// 1026:     end
// 1027:
// 1028:     sig { returns(T::Boolean) }
// 1029:     def automatically_set_no_install_from_api?
// 1030:       ENV["HOMEBREW_AUTOMATICALLY_SET_NO_INSTALL_FROM_API"].present?
// 1031:     end
// 1032:
// 1033:     sig { returns(T::Boolean) }
// 1034:     def devcmdrun?
// 1035:       Homebrew::Settings.read("devcmdrun") == "true"
// 1036:     end
// 1037:
// 1038:     sig { returns(Integer) }
// 1039:     def download_concurrency
// 1040:       concurrency = ENV.fetch("HOMEBREW_DOWNLOAD_CONCURRENCY", "auto")
// 1041:       concurrency = if concurrency == "auto"
// 1042:         require "os"
// 1043:         require "hardware"
// 1044:         Hardware::CPU.cores * 2
// 1045:       else
// 1046:         concurrency.to_i
// 1047:       end
// 1048:
// 1049:       [concurrency, 1].max
// 1050:     end
// 1051:
// 1052:     sig { returns(T::Boolean) }
// 1053:     def tap_trust_configured?
// 1054:       Homebrew::EnvConfig.require_tap_trust? || Homebrew::EnvConfig.no_require_tap_trust?
// 1055:     end
// 1056:   end
// 1057: end
