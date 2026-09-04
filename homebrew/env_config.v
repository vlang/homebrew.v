module homebrew

import os

// Translated from Homebrew/brew `env_config.rb`.
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
pub fn env_config_env_method_name(env string, entry EnvConfigEntry) string {
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
pub fn env_config_hidden(entry EnvConfigEntry) bool {
	return entry.hidden || entry.odeprecated || entry.odisabled
}

// Ruby method `default_description(env)` at line 817.
pub fn env_config_default_description(env string, state &EnvConfigState) ?string {
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
pub fn env_config_non_default_variable(env string, state &EnvConfigState) !bool {
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
pub fn env_config_user_set_variable(env string, state &EnvConfigState) bool {
	value := state.values[env] or { return false }
	if env_config_blank(value) {
		return false
	}
	if !env.starts_with('HOMEBREW_') {
		return true
	}
	return env in (state.values['HOMEBREW_USER_SET_VARS'] or { '' }).fields()
}

// Ruby define_method `define_method(method_name) do` at line 891.
pub fn env_config_boolean_value(env string, mut state EnvConfigState) !bool {
	entry := env_config_entries(&state)[env] or { return error('unknown environment variable ${env}') }
	if entry.disabled_by != '' && env_config_boolean_value(entry.disabled_by, mut state)! {
		return false
	}
	value := env_config_env_value(env, entry, mut state)!
	if entry.default_boolean && (!value.present || env_config_blank(value.value)) {
		return true
	}
	return value.present && !env_config_blank(value.value) && (entry.boolean_mode == .set || !env_config_falsey(value.value))
}

// Ruby define_method `define_method(method_name) do` at line 903.
pub fn env_config_string_value(env string, mut state EnvConfigState) !string {
	entry := env_config_entries(&state)[env] or { return error('unknown environment variable ${env}') }
	value := env_config_env_value(env, entry, mut state)!
	if value.present && !env_config_blank(value.value) {
		return value.value
	}
	return entry.default_value
}

// Ruby define_method `define_method(method_name) do` at line 912.
pub fn env_config_optional_value(env string, mut state EnvConfigState) !EnvConfigValue {
	entry := env_config_entries(&state)[env] or { return error('unknown environment variable ${env}') }
	value := env_config_env_value(env, entry, mut state)!
	if !value.present || env_config_blank(value.value) {
		return EnvConfigValue{}
	}
	return value
}

// Ruby method `env_value(env, hash)` at line 919.
pub fn env_config_env_value(env string, entry EnvConfigEntry, mut state EnvConfigState) !EnvConfigValue {
	env_value := state.values[env] or { return EnvConfigValue{} }
	if !env_config_blank(env_value) && (!entry.default_boolean || !env_config_falsey(env_value)) {
		env_config_odeprecated_env(env, entry, mut state)!
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
pub fn env_config_odeprecated_env(env string, entry EnvConfigEntry, mut state EnvConfigState) !EnvConfigDeprecationOutcome {
	if (!entry.odeprecated && !entry.odisabled) || !env_config_env_deprecation_applies(entry, &state) {
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
pub fn env_config_env_deprecation_applies(entry EnvConfigEntry, state &EnvConfigState) bool {
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

// Ruby method `cask_opts` at line 975.
pub fn env_config_cask_opts(state &EnvConfigState) ![]string {
	return env_config_shellsplit(state.values['HOMEBREW_CASK_OPTS'] or { '' })
}
