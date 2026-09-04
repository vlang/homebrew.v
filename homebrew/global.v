module homebrew

import ruby

// Translated from Homebrew/brew `global.rb`.
// The original source is retained below until every stub has a typed V body.

// GlobalState is V's explicit equivalent of the mutable singleton instance
// variables on Ruby's Homebrew module. Explicit ownership avoids hidden globals
// while retaining mutation and memoized Messages for a command invocation.
pub struct GlobalState {
pub mut:
	failed                       bool
	raise_deprecation_exceptions bool
	auditing                     bool
	messages                     Messages
	process_euid                 int
	owner_uid                    int
	running_command              string
}

pub fn new_global_state(process_euid int, owner_uid int) GlobalState {
	return GlobalState{
		messages:     new_messages()
		process_euid: process_euid
		owner_uid:    owner_uid
	}
}

pub fn global_state_from_process(original_brew_file string) !GlobalState {
	return new_global_state(ruby.effective_uid(),
		ruby.file_owner_uid(original_brew_file)!)
}

pub fn default_prefix(prefix string) bool {
	return prefix == ruby.environment_value('HOMEBREW_DEFAULT_PREFIX')
}

pub fn (state GlobalState) running_as_root() bool {
	return state.process_euid == 0
}

pub fn (state GlobalState) running_as_root_but_not_owned_by_root() bool {
	return state.running_as_root() && state.owner_uid != 0
}

pub fn auto_update_command() bool {
	return ruby.environment_value('HOMEBREW_AUTO_UPDATE_COMMAND').trim_space() != ''
}

pub fn (mut state GlobalState) set_running_command(cmd string, argv []string) {
	state.running_command = '${cmd} ${argv.join(' ')}'.trim_space()
}

pub fn (state GlobalState) running_command_with_args() string {
	return 'brew ${state.running_command}'.trim_space()
}

// Ruby attr_writer `attr_writer :failed` at line 65.
pub fn ruby_global_l65_d1_failed(mut state GlobalState, failed bool) bool {
	state.failed = failed
	return failed
}

// Ruby attr_writer `attr_writer :raise_deprecation_exceptions` at line 68.
pub fn ruby_global_l68_d2_raise_deprecation_exceptions(mut state GlobalState,
	raise_deprecation_exceptions bool) bool {
	state.raise_deprecation_exceptions = raise_deprecation_exceptions
	return raise_deprecation_exceptions
}

// Ruby attr_writer `attr_writer :auditing` at line 71.
pub fn ruby_global_l71_d3_auditing(mut state GlobalState, auditing bool) bool {
	state.auditing = auditing
	return auditing
}

// Ruby method `default_prefix?(prefix = HOMEBREW_PREFIX)` at line 77.
pub fn ruby_global_l77_d4_default_prefix(prefix string) bool {
	return default_prefix(prefix)
}

// Ruby method `failed?` at line 82.
pub fn ruby_global_l82_d5_failed(state GlobalState) bool {
	return state.failed == true
}

// Ruby method `messages` at line 88.
pub fn ruby_global_l88_d6_messages(state GlobalState) Messages {
	return state.messages.copy()
}

// Ruby method `raise_deprecation_exceptions?` at line 93.
pub fn ruby_global_l93_d7_raise_deprecation_exceptions(state GlobalState) bool {
	return state.raise_deprecation_exceptions == true
}

// Ruby method `auditing?` at line 99.
pub fn ruby_global_l99_d8_auditing(state GlobalState) bool {
	return state.auditing == true
}

// Ruby method `running_as_root?` at line 105.
pub fn ruby_global_l105_d9_running_as_root(state GlobalState) bool {
	return state.running_as_root()
}

// Ruby method `owner_uid` at line 111.
pub fn ruby_global_l111_d10_owner_uid(state GlobalState) int {
	return state.owner_uid
}

// Ruby method `running_as_root_but_not_owned_by_root?` at line 116.
pub fn ruby_global_l116_d11_running_as_root_but_not_owned_by_root(state GlobalState) bool {
	return state.running_as_root_but_not_owned_by_root()
}

// Ruby method `auto_update_command?` at line 121.
pub fn ruby_global_l121_d12_auto_update_command() bool {
	return auto_update_command()
}

// Ruby method `running_command=(cmd)` at line 126.
pub fn ruby_global_l126_d13_running_command(mut state GlobalState, cmd string, argv []string) {
	state.set_running_command(cmd, argv)
}

// Ruby method `running_command_with_args` at line 131.
pub fn ruby_global_l131_d14_running_command_with_args(state GlobalState) string {
	return state.running_command_with_args()
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "startup"
// 5:
// 6: HOMEBREW_HELP_MESSAGE = T.let(ENV.fetch("HOMEBREW_HELP_MESSAGE").freeze, String)
// 7:
// 8: HOMEBREW_API_DEFAULT_DOMAIN = T.let(ENV.fetch("HOMEBREW_API_DEFAULT_DOMAIN").freeze, String)
// 9: HOMEBREW_BOTTLE_DEFAULT_DOMAIN = T.let(ENV.fetch("HOMEBREW_BOTTLE_DEFAULT_DOMAIN").freeze, String)
// 10: HOMEBREW_BREW_DEFAULT_GIT_REMOTE = T.let(ENV.fetch("HOMEBREW_BREW_DEFAULT_GIT_REMOTE").freeze, String)
// 11: HOMEBREW_CORE_DEFAULT_GIT_REMOTE = T.let(ENV.fetch("HOMEBREW_CORE_DEFAULT_GIT_REMOTE").freeze, String)
// 12:
// 13: HOMEBREW_DEFAULT_CACHE = T.let(ENV.fetch("HOMEBREW_DEFAULT_CACHE").freeze, String)
// 14: HOMEBREW_DEFAULT_LOGS = T.let(ENV.fetch("HOMEBREW_DEFAULT_LOGS").freeze, String)
// 15: HOMEBREW_DEFAULT_TEMP = T.let(ENV.fetch("HOMEBREW_DEFAULT_TEMP").freeze, String)
// 16: HOMEBREW_REQUIRED_RUBY_VERSION = T.let(ENV.fetch("HOMEBREW_REQUIRED_RUBY_VERSION").freeze, String)
// 17: HOMEBREW_VERSION = T.let(ENV.fetch("HOMEBREW_VERSION").freeze, String)
// 18:
// 19: HOMEBREW_WWW = "https://brew.sh"
// 20: HOMEBREW_API_WWW = "https://formulae.brew.sh"
// 21: HOMEBREW_DOCS_WWW = "https://docs.brew.sh"
// 22:
// 23: HOMEBREW_SYSTEM = T.let(ENV.fetch("HOMEBREW_SYSTEM").freeze, String)
// 24: HOMEBREW_PROCESSOR = T.let(ENV.fetch("HOMEBREW_PROCESSOR").freeze, String)
// 25: HOMEBREW_PHYSICAL_PROCESSOR = T.let(ENV.fetch("HOMEBREW_PHYSICAL_PROCESSOR").freeze, String)
// 26:
// 27: HOMEBREW_BREWED_CURL_PATH = Pathname.new(ENV.fetch("HOMEBREW_BREWED_CURL_PATH")).freeze
// 28: HOMEBREW_USER_AGENT_CURL = T.let(ENV.fetch("HOMEBREW_USER_AGENT_CURL").freeze, String)
// 29: HOMEBREW_USER_AGENT_FAKE_SAFARI =
// 30:   # Don't update this beyond 10.15.7 until Safari actually updates their
// 31:   # user agent to be beyond 10.15.7 (not the case as-of macOS 26)
// 32:   "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 " \
// 33:   "(KHTML, like Gecko) Version/26.0 Safari/605.1.15"
// 34: HOMEBREW_GITHUB_PACKAGES_AUTH = T.let(ENV.fetch("HOMEBREW_GITHUB_PACKAGES_AUTH", "").freeze, String)
// 35: HOMEBREW_DEFAULT_PREFIX = T.let(ENV.fetch("HOMEBREW_GENERIC_DEFAULT_PREFIX").freeze, String)
// 36:
// 37: HOMEBREW_MACOS_ARM_DEFAULT_PREFIX = T.let(ENV.delete("HOMEBREW_MACOS_ARM_DEFAULT_PREFIX").freeze, T.nilable(String))
// 38: HOMEBREW_LINUX_DEFAULT_PREFIX = T.let(ENV.delete("HOMEBREW_LINUX_DEFAULT_PREFIX").freeze, T.nilable(String))
// 39:
// 40: HOMEBREW_PREFIX_PLACEHOLDER = "$HOMEBREW_PREFIX"
// 41: HOMEBREW_CELLAR_PLACEHOLDER = "$HOMEBREW_CELLAR"
// 42: # Needs a leading slash to avoid `File.expand.path` complaining about non-absolute home.
// 43: HOMEBREW_HOME_PLACEHOLDER = "/$HOME"
// 44: HOMEBREW_CASK_APPDIR_PLACEHOLDER = "$APPDIR"
// 45:
// 46: HOMEBREW_MACOS_NEWEST_UNSUPPORTED = T.let(ENV.fetch("HOMEBREW_MACOS_NEWEST_UNSUPPORTED").freeze, String)
// 47: HOMEBREW_MACOS_NEWEST_SUPPORTED = T.let(ENV.fetch("HOMEBREW_MACOS_NEWEST_SUPPORTED").freeze, String)
// 48: HOMEBREW_MACOS_OLDEST_SUPPORTED = T.let(ENV.fetch("HOMEBREW_MACOS_OLDEST_SUPPORTED").freeze, String)
// 49: HOMEBREW_MACOS_OLDEST_ALLOWED = T.let(ENV.fetch("HOMEBREW_MACOS_OLDEST_ALLOWED").freeze, String)
// 50:
// 51: HOMEBREW_PULL_OR_COMMIT_URL_REGEX =
// 52:   %r[https://github\.com/([\w-]+)/([\w-]+)?/(?:pull/(\d+)|commit/[0-9a-fA-F]{4,40})]
// 53: HOMEBREW_BOTTLES_EXTNAME_REGEX = /\.([a-z0-9_]+)\.bottle\.(?:(\d+)\.)?tar\.gz$/
// 54:
// 55: module Homebrew
// 56:   DEFAULT_PREFIX = T.let(ENV.fetch("HOMEBREW_DEFAULT_PREFIX").freeze, String)
// 57:   DEFAULT_REPOSITORY = T.let(ENV.fetch("HOMEBREW_DEFAULT_REPOSITORY").freeze, String)
// 58:   DEFAULT_CELLAR = T.let("#{DEFAULT_PREFIX}/Cellar".freeze, String)
// 59:   DEFAULT_MACOS_CELLAR = T.let("#{HOMEBREW_DEFAULT_PREFIX}/Cellar".freeze, String)
// 60:   DEFAULT_MACOS_ARM_CELLAR = T.let("#{HOMEBREW_MACOS_ARM_DEFAULT_PREFIX}/Cellar".freeze, String)
// 61:   DEFAULT_LINUX_CELLAR = T.let("#{HOMEBREW_LINUX_DEFAULT_PREFIX}/Cellar".freeze, String)
// 62:
// 63:   class << self
// 64:     sig { params(failed: T::Boolean).returns(T::Boolean) }
// 65:     attr_writer :failed
// 66:
// 67:     sig { params(raise_deprecation_exceptions: T::Boolean).returns(T::Boolean) }
// 68:     attr_writer :raise_deprecation_exceptions
// 69:
// 70:     sig { params(auditing: T::Boolean).returns(T::Boolean) }
// 71:     attr_writer :auditing
// 72:
// 73:     # Check whether Homebrew is using the default prefix.
// 74:     #
// 75:     # @api internal
// 76:     sig { params(prefix: T.any(Pathname, String)).returns(T::Boolean) }
// 77:     def default_prefix?(prefix = HOMEBREW_PREFIX)
// 78:       prefix.to_s == DEFAULT_PREFIX
// 79:     end
// 80:
// 81:     sig { returns(T::Boolean) }
// 82:     def failed?
// 83:       @failed ||= T.let(false, T.nilable(T::Boolean))
// 84:       @failed == true
// 85:     end
// 86:
// 87:     sig { returns(Messages) }
// 88:     def messages
// 89:       @messages ||= T.let(Messages.new, T.nilable(Messages))
// 90:     end
// 91:
// 92:     sig { returns(T::Boolean) }
// 93:     def raise_deprecation_exceptions?
// 94:       @raise_deprecation_exceptions = T.let(@raise_deprecation_exceptions, T.nilable(T::Boolean))
// 95:       @raise_deprecation_exceptions == true
// 96:     end
// 97:
// 98:     sig { returns(T::Boolean) }
// 99:     def auditing?
// 100:       @auditing = T.let(@auditing, T.nilable(T::Boolean))
// 101:       @auditing == true
// 102:     end
// 103:
// 104:     sig { returns(T::Boolean) }
// 105:     def running_as_root?
// 106:       @process_euid ||= T.let(Process.euid, T.nilable(Integer))
// 107:       @process_euid.zero?
// 108:     end
// 109:
// 110:     sig { returns(Integer) }
// 111:     def owner_uid
// 112:       @owner_uid ||= T.let(HOMEBREW_ORIGINAL_BREW_FILE.stat.uid, T.nilable(Integer))
// 113:     end
// 114:
// 115:     sig { returns(T::Boolean) }
// 116:     def running_as_root_but_not_owned_by_root?
// 117:       running_as_root? && !owner_uid.zero?
// 118:     end
// 119:
// 120:     sig { returns(T::Boolean) }
// 121:     def auto_update_command?
// 122:       ENV.fetch("HOMEBREW_AUTO_UPDATE_COMMAND", false).present?
// 123:     end
// 124:
// 125:     sig { params(cmd: T.nilable(String)).void }
// 126:     def running_command=(cmd)
// 127:       @running_command_with_args = T.let("#{cmd} #{ARGV.join(" ")}", T.nilable(String))
// 128:     end
// 129:
// 130:     sig { returns String }
// 131:     def running_command_with_args
// 132:       "brew #{@running_command_with_args}".strip
// 133:     end
// 134:   end
// 135: end
// 136:
// 137: require "PATH"
// 138: ENV["HOMEBREW_PATH"] ||= ENV.fetch("PATH")
// 139: ORIGINAL_PATHS = T.let(PATH.new(ENV.fetch("HOMEBREW_PATH")).filter_map do |p|
// 140:   Pathname.new(p).expand_path
// 141: rescue
// 142:   nil
// 143: end.freeze, T::Array[Pathname])
// 144:
// 145: require "extend/blank"
// 146: require "extend/kernel"
// 147: require "os"
// 148:
// 149: require "extend/array"
// 150: require "cachable"
// 151: require "extend/enumerable"
// 152: require "extend/string"
// 153: require "extend/pathname"
// 154:
// 155: require "exceptions"
// 156:
// 157: require "tap_constants"
// 158: require "official_taps"
