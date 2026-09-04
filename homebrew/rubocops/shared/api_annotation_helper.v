module shared

import ruby
import os

// Translated from Homebrew/brew `rubocops/shared/api_annotation_helper.rb`.
pub const official_taps = ['homebrew-core', 'homebrew-cask']

pub const api_source_files = ['formula.rb', 'cask/cask.rb', 'cask/dsl.rb', 'utils/path.rb']

pub fn formula_cookbook_methods() map[string]string {
	return {
		'cd':                    'extend/pathname.rb'
		'change_make_var!':      'utils/string_inreplace_extension.rb'
		'compatibility_version': 'formula.rb'
		'conflicts_with':        'formula.rb'
		'depends_on':            'formula.rb'
		'deprecated_option':     'formula.rb'
		'desc':                  'formula.rb'
		'change_dylib_id':       'formula.rb'
		'env_script_all_files':  'extend/pathname.rb'
		'fails_with':            'formula.rb'
		'post_install_steps':    'formula.rb'
		'head':                  'formula.rb'
		'homepage':              'formula.rb'
		'install_symlink':       'extend/pathname.rb'
		'keg_only':              'formula.rb'
		'libexec':               'formula.rb'
		'license':               'formula.rb'
		'option':                'formula.rb'
		'patch':                 'formula.rb'
		'resource':              'formula.rb'
		'revision':              'formula.rb'
		'sha256':                'formula.rb'
		'stable':                'formula.rb'
		'test':                  'formula.rb'
		'testpath':              'formula.rb'
		'url':                   'formula.rb'
		'uses_from_macos':       'formula.rb'
		'version':               'formula.rb'
		'version_scheme':        'formula.rb'
		'write_env_script':      'extend/pathname.rb'
		'write_exec_script':     'extend/pathname.rb'
		'write_jar_script':      'extend/pathname.rb'
	}
}

pub fn cask_cookbook_methods() map[string]string {
	return {
		'after_comma':          'cask/dsl/version.rb'
		'app':                  'cask/dsl.rb'
		'appdir':               'cask/dsl.rb'
		'arch':                 'cask/dsl.rb'
		'artifact':             'cask/dsl.rb'
		'auto_updates':         'cask/dsl.rb'
		'before_comma':         'cask/dsl/version.rb'
		'binary':               'cask/dsl.rb'
		'caveats':              'cask/dsl.rb'
		'chomp':                'cask/dsl/version.rb'
		'conflicts_with':       'cask/dsl.rb'
		'container':            'cask/dsl.rb'
		'csv':                  'cask/dsl/version.rb'
		'depends_on':           'cask/dsl.rb'
		'deprecate!':           'cask/dsl.rb'
		'desc':                 'cask/dsl.rb'
		'disable!':             'cask/dsl.rb'
		'dots_to_hyphens':      'cask/dsl/version.rb'
		'font':                 'cask/dsl.rb'
		'homepage':             'cask/dsl.rb'
		'hyphens_to_dots':      'cask/dsl/version.rb'
		'installer':            'cask/dsl.rb'
		'language':             'cask/dsl.rb'
		'livecheck':            'cask/dsl.rb'
		'major':                'cask/dsl/version.rb'
		'major_minor':          'cask/dsl/version.rb'
		'major_minor_patch':    'cask/dsl/version.rb'
		'manpage':              'cask/dsl.rb'
		'minor':                'cask/dsl/version.rb'
		'minor_patch':          'cask/dsl/version.rb'
		'name':                 'cask/dsl.rb'
		'no_autobump!':         'cask/dsl.rb'
		'no_dividers':          'cask/dsl/version.rb'
		'no_dots':              'cask/dsl/version.rb'
		'no_hyphens':           'cask/dsl/version.rb'
		'no_underscores':       'cask/dsl/version.rb'
		'patch':                'cask/dsl/version.rb'
		'pkg':                  'cask/dsl.rb'
		'postflight':           'cask/dsl.rb'
		'preflight':            'cask/dsl.rb'
		'rename':               'cask/dsl.rb'
		'service':              'cask/dsl.rb'
		'sha256':               'cask/dsl.rb'
		'stage_only':           'cask/dsl.rb'
		'staged_path':          'cask/dsl.rb'
		'suite':                'cask/dsl.rb'
		'to_s':                 'cask/cask.rb'
		'token':                'cask/cask.rb'
		'uninstall':            'cask/dsl.rb'
		'uninstall_postflight': 'cask/dsl.rb'
		'uninstall_preflight':  'cask/dsl.rb'
		'url':                  'cask/dsl.rb'
		'version':              'cask/dsl.rb'
		'zap':                  'cask/dsl.rb'
	}
}

pub fn service_cookbook_methods() []string {
	return ['cron', 'environment_variables', 'error_log_path', 'input_path', 'interval', 'keep_alive',
		'launch_only_once', 'log_path', 'macos_legacy_timers', 'name', 'nice', 'process_type',
		'require_root', 'restart_delay', 'root_dir', 'run', 'run_at_load', 'run_type', 'sockets',
		'stop_timeout', 'throttle_interval', 'working_dir']
}

pub fn api_annotation_method_name(line string) ?string {
	trimmed := line.trim_space()
	mut rest := ''
	if trimmed.starts_with('def self.') {
		rest = trimmed.all_after('def self.')
	} else if trimmed.starts_with('def ') {
		rest = trimmed.all_after('def ')
	} else if trimmed.starts_with('attr_reader :') {
		rest = trimmed.all_after('attr_reader :')
	} else if trimmed.starts_with('attr_accessor :') {
		rest = trimmed.all_after('attr_accessor :')
	} else if trimmed.starts_with('delegate ') {
		rest = trimmed.all_after('delegate ')
	} else {
		return none
	}
	mut name := ''
	mut index := 0
	for index < rest.len {
		character := rest[index]
		if character.is_alnum() || character == `_` {
			name += character.ascii_str()
			index++
		} else {
			break
		}
	}
	if index < rest.len && rest[index] in [`!`, `?`] {
		name += rest[index].ascii_str()
	}
	if name == '' {
		return none
	}
	return name
}

pub fn methods_with_api_level_source(source string, level string) []string {
	lines := source.split_into_lines()
	mut methods := []string{}
	for index, line in lines {
		if line.trim_space() != '# @api ${level}' {
			continue
		}
		for offset := 1; offset <= 5; offset++ {
			if index + offset >= lines.len {
				break
			}
			target := lines[index + offset].trim_space()
			if target == '' {
				break
			}
			if method := api_annotation_method_name(target) {
				if method !in methods {
					methods << method
				}
				break
			}
		}
	}
	return methods
}

pub fn methods_with_api_level(source_path string, level string) []string {
	if !os.exists(source_path) {
		return []
	}
	return methods_with_api_level_source(os.read_file(source_path) or { return [] }, level)
}

pub fn api_annotation_homebrew_dir() string {
	return os.dir(os.dir(os.dir(@FILE)))
}
