module services

import os
import strconv

// Translated from Homebrew/brew `services/formula_wrapper.rb`.
// The retained Ruby source follows these source-shaped typed boundaries.
pub const missing_daemon_manager_exception_message = 'Invalid usage: `brew services` is supported only on macOS or Linux (with systemd)!'

pub enum FormulaWrapperDaemonManager {
	launchctl
	systemctl
	unavailable
}

pub enum FormulaWrapperStatusType {
	launchctl_list
	launchctl_print
	systemctl
}

pub enum FormulaWrapperServiceFileType {
	any
	root
	user
}

pub enum FormulaWrapperStatusSymbol {
	started
	none
	scheduled
	stopped
	error
	unknown
	other
}

pub struct FormulaWrapperService {
pub mut:
	requires_root  bool
	timed          bool
	keep_alive     bool
	path_dirs      []string
	command        []string
	manual_command string
	working_dir    ?string
	root_dir       ?string
	log_path       ?string
	error_log_path ?string
	interval       ?int
	cron           map[string]string
	plist_contents string
	systemd_unit   string
}

pub struct FormulaWrapperFormula {
pub mut:
	name                  string
	plist_name            string
	service_name          string
	launchd_service_path  string
	systemd_service_path  string
	systemd_timer_path    string
	any_version_installed bool
	has_service           bool
	service               FormulaWrapperService
}

pub struct FormulaWrapperSystem {
pub mut:
	manager                    FormulaWrapperDaemonManager
	root                       bool
	boot_path                  string
	user_path                  string
	user                       string
	launchctl_status           StatusOutputSuccessType
	systemctl_status_output    string
	systemctl_child_status_set bool
	systemctl_child_status_ok  bool
	systemctl_quiet_run_result bool
}

pub struct StatusOutputSuccessType {
pub:
	output  string
	success bool
	type_   FormulaWrapperStatusType
}

pub struct FormulaWrapperHash {
pub:
	name         string
	service_name string
	running      bool
	loaded       bool
	schedulable  bool
	pid          ?int
	exit_code    ?int
	user         ?string
	status       FormulaWrapperStatusSymbol
	file         string
	registered   bool
	loaded_file  ?string
pub mut:
	has_service_details bool
	command             string
	working_dir         ?string
	root_dir            ?string
	log_path            ?string
	error_log_path      ?string
	interval            ?int
	has_cron            bool
	cron                map[string]string
}

pub struct FormulaWrapper {
pub:
	formula FormulaWrapperFormula
	system  FormulaWrapperSystem
pub mut:
	has_status_cache                  bool
	status_cache                      StatusOutputSuccessType
	last_quiet_run_target             string
	has_service_file_present_override bool
	service_file_present_override     bool
}

pub interface FormulaWrapperFormulary {
	factory(name string) !FormulaWrapperFormula
}

fn basename(path string) string {
	return os.base(path)
}

fn formula_name_from_path_or_label(path_or_label string) ?string {
	candidate := path_or_label
	start := if index := candidate.last_index('homebrew.mxcl.') {
		index + 'homebrew.mxcl.'.len
	} else if index := candidate.last_index('homebrew.') {
		index + 'homebrew.'.len
	} else {
		return none
	}
	name := candidate[start..]
	if name == '' || !name.bytes().all((it >= `a` && it <= `z`) || (it >= `A` && it <= `Z`) || (it >= `0` && it <= `9`) || it in [
		`_`,
		`+`,
		`-`,
		`.`,
		`@`,
	]) {
		return none
	}
	return name
}

pub fn new_formula_wrapper(formula FormulaWrapperFormula, system FormulaWrapperSystem) !FormulaWrapper {
	if system.manager == .unavailable {
		return error(missing_daemon_manager_exception_message)
	}
	return FormulaWrapper{ formula: formula, system: system }
}

fn digits_after(output string, prefix string) ?int {
	index := output.index(prefix) or { return none }
	mut end := index + prefix.len
	for end < output.len && output[end] >= `0` && output[end] <= `9` {
		end++
	}
	if end == index + prefix.len {
		return none
	}
	return strconv.atoi(output[index + prefix.len..end]) or { none }
}

fn integer_match(output string, prefix string, terminator string, allow_empty bool) ?int {
	index := output.index(prefix) or { return none }
	start := index + prefix.len
	mut end := start
	for end < output.len && output[end] >= `0` && output[end] <= `9` {
		end++
	}
	if end == start && !allow_empty {
		return none
	}
	if !output[end..].starts_with(terminator) {
		return none
	}
	return if end == start { 0 } else { strconv.atoi(output[start..end]) or { none } }
}

fn ruby_chomp(value string) string {
	if value.ends_with('\r\n') {
		return value[..value.len - 2]
	}
	if value.ends_with('\n') || value.ends_with('\r') {
		return value[..value.len - 1]
	}
	return value
}

fn loaded_file_from_output(output string, status_type FormulaWrapperStatusType) ?string {
	match status_type {
		.launchctl_list {
			return none
		}
		.launchctl_print {
			index := output.index('path = ') or { return none }
			return output[index + 7..].all_before('\n')
		}
		.systemctl {
			loaded := output.index('Loaded: ') or { return none }
			open := output.index_after('(', loaded + 8) or { return none }
			semi := output.index_after(';', open + 1) or { return none }
			return output[open + 1..semi]
		}
	}
}

fn plist_username(contents string) ?string {
	key := contents.index('<key>UserName</key>') or { return none }
	open := contents.index_after('<string>', key + 19) or { return none }
	close := contents.index_after('</string>', open + 8) or { return none }
	value := contents[open + 8..close].trim_space()
	return if value == '' { none } else { value }
}

// Ruby attr_reader `attr_reader :formula` at line 15.
pub fn ruby_formula_wrapper_l15_d1_formula(wrapper &FormulaWrapper) FormulaWrapperFormula {
	return wrapper.formula
}

// Ruby method `self.from(path_or_label)` at line 19.
pub fn ruby_formula_wrapper_l19_d2_self_from(path_or_label string, formulary FormulaWrapperFormulary,
	system FormulaWrapperSystem) ?FormulaWrapper {
	name := formula_name_from_path_or_label(path_or_label) or { return none }
	formula := formulary.factory(name) or { return none }
	return new_formula_wrapper(formula, system) or { none }
}

// Ruby method `initialize(formula)` at line 31.
pub fn ruby_formula_wrapper_l31_d3_initialize(formula FormulaWrapperFormula,
	system FormulaWrapperSystem) !FormulaWrapper {
	return new_formula_wrapper(formula, system)
}

// Ruby method `name` at line 42.
pub fn formula_wrapper_name(wrapper &FormulaWrapper) string {
	return wrapper.formula.name
}

// Ruby method `service?` at line 48.
pub fn ruby_formula_wrapper_l48_d5_service(wrapper &FormulaWrapper) bool {
	return wrapper.formula.has_service
}

// Ruby method `timed?` at line 54.
pub fn formula_wrapper_timed(wrapper &FormulaWrapper) bool {
	return wrapper.formula.has_service && wrapper.formula.service.timed
}

// Ruby method `keep_alive?` at line 63.
pub fn ruby_formula_wrapper_l63_d7_keep_alive(wrapper &FormulaWrapper) bool {
	return wrapper.formula.has_service && wrapper.formula.service.keep_alive
}

// Ruby method `path_dirs` at line 71.
pub fn ruby_formula_wrapper_l71_d8_path_dirs(wrapper &FormulaWrapper) []string {
	return if wrapper.formula.has_service {
		wrapper.formula.service.path_dirs.clone()
	} else {
		[]string{}
	}
}

// Ruby method `service_name` at line 80.
pub fn formula_wrapper_service_name(wrapper &FormulaWrapper) string {
	return if wrapper.system.manager == .launchctl {
		wrapper.formula.plist_name
	} else {
		wrapper.formula.service_name
	}
}

// Ruby method `service_file` at line 92.
pub fn formula_wrapper_service_file(wrapper &FormulaWrapper) string {
	return if wrapper.system.manager == .launchctl {
		wrapper.formula.launchd_service_path
	} else {
		wrapper.formula.systemd_service_path
	}
}

// Ruby method `timer_file` at line 103.
pub fn formula_wrapper_timer_file(wrapper &FormulaWrapper) string {
	return wrapper.formula.systemd_timer_path
}

// Ruby method `timer_name` at line 108.
pub fn formula_wrapper_timer_name(wrapper &FormulaWrapper) string {
	return basename(formula_wrapper_timer_file(wrapper))
}

// Ruby method `timer_dest` at line 113.
pub fn ruby_formula_wrapper_l113_d13_timer_dest(wrapper &FormulaWrapper) string {
	return os.join_path(formula_wrapper_dest_dir(wrapper), formula_wrapper_timer_name(wrapper))
}

// Ruby method `service_startup?` at line 119.
pub fn ruby_formula_wrapper_l119_d14_service_startup(wrapper &FormulaWrapper) bool {
	return wrapper.formula.has_service && wrapper.formula.service.requires_root
}

// Ruby method `dest_dir` at line 131.
pub fn formula_wrapper_dest_dir(wrapper &FormulaWrapper) string {
	return if wrapper.system.root { wrapper.system.boot_path } else { wrapper.system.user_path }
}

// Ruby method `dest` at line 137.
pub fn formula_wrapper_dest(wrapper &FormulaWrapper) string {
	return os.join_path(formula_wrapper_dest_dir(wrapper), basename(formula_wrapper_service_file(wrapper)))
}

// Ruby method `installed?` at line 143.
pub fn ruby_formula_wrapper_l143_d17_installed(wrapper &FormulaWrapper) bool {
	return wrapper.formula.any_version_installed
}

// Ruby method `reset_cache!` at line 148.
pub fn formula_wrapper_reset_cache(mut wrapper FormulaWrapper) {
	wrapper.has_status_cache = false
}

// Ruby method `loaded?(cached: false)` at line 154.
pub fn formula_wrapper_loaded(mut wrapper FormulaWrapper, cached bool) bool {
	if wrapper.system.manager == .launchctl {
		if !cached {
			formula_wrapper_reset_cache(mut wrapper)
		}
		return formula_wrapper_status_success(mut wrapper)
	}
	wrapper.last_quiet_run_target = if formula_wrapper_timed(&wrapper) {
		formula_wrapper_timer_name(&wrapper)
	} else {
		basename(formula_wrapper_service_file(&wrapper))
	}
	return wrapper.system.systemctl_quiet_run_result
}

// Ruby method `service_file_present?(type: nil)` at line 166.
pub fn formula_wrapper_service_file_present(wrapper &FormulaWrapper,
	type_ FormulaWrapperServiceFileType) bool {
	if wrapper.has_service_file_present_override {
		return wrapper.service_file_present_override
	}
	return match type_ {
		.root { formula_wrapper_boot_path_service_file_present(wrapper) }
		.user { formula_wrapper_user_path_service_file_present(wrapper) }
		.any {
			formula_wrapper_boot_path_service_file_present(wrapper) || formula_wrapper_user_path_service_file_present(wrapper)
		}
	}
}

// Ruby method `owner` at line 178.
pub fn formula_wrapper_owner(wrapper &FormulaWrapper) ?string {
	if wrapper.system.manager == .launchctl {
		destination := formula_wrapper_dest(wrapper)
		if os.exists(destination) {
			contents := os.read_file(destination) or { '' }
			if username := plist_username(contents) {
				return username
			}
		}
	}
	if formula_wrapper_boot_path_service_file_present(wrapper) {
		return 'root'
	}
	if formula_wrapper_user_path_service_file_present(wrapper) {
		return wrapper.system.user
	}
	return none
}

// Ruby method `pid?` at line 198.
pub fn formula_wrapper_has_pid(mut wrapper FormulaWrapper) bool {
	return formula_wrapper_pid_present_value(formula_wrapper_pid(mut wrapper))
}

pub fn formula_wrapper_pid_present_value(pid ?int) bool {
	value := pid or { return false }
	return value > 0
}

// Ruby method `error?` at line 203.
pub fn formula_wrapper_error(mut wrapper FormulaWrapper) bool {
	return formula_wrapper_error_values(formula_wrapper_pid(mut wrapper), formula_wrapper_exit_code(mut wrapper))
}

pub fn formula_wrapper_error_values(pid ?int, exit_code ?int) bool {
	if formula_wrapper_pid_present_value(pid) {
		return false
	}
	value := exit_code or { return false }
	return value != 0
}

// Ruby method `unknown_status?` at line 210.
pub fn formula_wrapper_unknown_status(mut wrapper FormulaWrapper) bool {
	return formula_wrapper_status_output(mut wrapper).trim_space() == '' && !formula_wrapper_has_pid(mut wrapper)
}

// Ruby method `pid` at line 216.
pub fn formula_wrapper_pid(mut wrapper FormulaWrapper) ?int {
	output := formula_wrapper_status_output(mut wrapper)
	type_ := formula_wrapper_status_type(mut wrapper)
	return match type_ {
		.launchctl_list { integer_match(output, '"PID" = ', ';', true) }
		.launchctl_print { digits_after(output, 'pid = ') }
		.systemctl {
			index := output.index('Main PID: ') or { return none }
			start := index + 'Main PID: '.len
			mut end := start
			for end < output.len && output[end] >= `0` && output[end] <= `9` {
				end++
			}
			if end + 2 > output.len || !output[end..].starts_with(' (') || output[end + 2..].starts_with('code=') {
				return none
			}
			if end == start { 0 } else { strconv.atoi(output[start..end]) or { none } }
		}
	}
}

// Ruby method `exit_code` at line 222.
pub fn formula_wrapper_exit_code(mut wrapper FormulaWrapper) ?int {
	output := formula_wrapper_status_output(mut wrapper)
	return match formula_wrapper_status_type(mut wrapper) {
		.launchctl_list { integer_match(output, '"LastExitStatus" = ', ';', true) }
		.launchctl_print { digits_after(output, 'last exit code = ') }
		.systemctl { integer_match(output, '(code=exited, status=', ')', true) }
	}
}

// Ruby method `loaded_file` at line 227.
pub fn formula_wrapper_loaded_file(mut wrapper FormulaWrapper) ?string {
	return loaded_file_from_output(formula_wrapper_status_output(mut wrapper), formula_wrapper_status_type(mut wrapper))
}

// Ruby method `to_hash` at line 232.
pub fn ruby_formula_wrapper_l232_d28_to_hash(mut wrapper FormulaWrapper) FormulaWrapperHash {
	registered := formula_wrapper_service_file_present(&wrapper, .any)
	mut result := FormulaWrapperHash{
		name: formula_wrapper_name(&wrapper)
		service_name: formula_wrapper_service_name(&wrapper)
		running: formula_wrapper_has_pid(mut wrapper)
		loaded: formula_wrapper_loaded(mut wrapper, true)
		schedulable: formula_wrapper_timed(&wrapper)
		pid: formula_wrapper_pid(mut wrapper)
		exit_code: formula_wrapper_exit_code(mut wrapper)
		user: formula_wrapper_owner(&wrapper)
		status: formula_wrapper_status_symbol(mut wrapper)
		file: if registered {
			formula_wrapper_dest(&wrapper)
		} else {
			formula_wrapper_service_file(&wrapper)
		}
		registered: registered
		loaded_file: formula_wrapper_loaded_file(mut wrapper)
	}
	if !wrapper.formula.has_service || wrapper.formula.service.command.len == 0 {
		return result
	}
	service := wrapper.formula.service
	result.has_service_details = true
	result.command = service.manual_command
	result.working_dir = service.working_dir
	result.root_dir = service.root_dir
	result.log_path = service.log_path
	result.error_log_path = service.error_log_path
	result.interval = service.interval
	result.has_cron = service.cron.len > 0
	result.cron = service.cron.clone()
	return result
}

// Ruby method `service_contents` at line 270.
pub fn ruby_formula_wrapper_l270_d29_service_contents(wrapper &FormulaWrapper) !string {
	if !wrapper.formula.has_service || wrapper.formula.service.command.len == 0 {
		return os.read_file(formula_wrapper_service_file(wrapper))
	}
	return if wrapper.system.manager == .launchctl {
		wrapper.formula.service.plist_contents
	} else {
		wrapper.formula.service.systemd_unit
	}
}

// Ruby method `load_service` at line 286.
pub fn ruby_formula_wrapper_l286_d30_load_service(wrapper &FormulaWrapper) FormulaWrapperService {
	return wrapper.formula.service
}

// Ruby method `status_output_success_type` at line 293.
pub fn formula_wrapper_status_output_success_type(mut wrapper FormulaWrapper) StatusOutputSuccessType {
	if wrapper.has_status_cache {
		return wrapper.status_cache
	}
	wrapper.status_cache = if wrapper.system.manager == .launchctl {
		wrapper.system.launchctl_status
	} else {
		output := ruby_chomp(wrapper.system.systemctl_status_output)
		StatusOutputSuccessType{
			output: output
			success: wrapper.system.systemctl_child_status_set && wrapper.system.systemctl_child_status_ok && output.trim_space() != ''
			type_: .systemctl
		}
	}
	wrapper.has_status_cache = true
	return wrapper.status_cache
}

// Ruby method `status_output` at line 307.
pub fn formula_wrapper_status_output(mut wrapper FormulaWrapper) string {
	return formula_wrapper_status_output_success_type(mut wrapper).output
}

// Ruby method `status_success` at line 312.
pub fn formula_wrapper_status_success(mut wrapper FormulaWrapper) bool {
	return formula_wrapper_status_output_success_type(mut wrapper).success
}

// Ruby method `status_type` at line 317.
pub fn formula_wrapper_status_type(mut wrapper FormulaWrapper) FormulaWrapperStatusType {
	return formula_wrapper_status_output_success_type(mut wrapper).type_
}

// Ruby method `status_symbol` at line 322.
pub fn formula_wrapper_status_symbol(mut wrapper FormulaWrapper) FormulaWrapperStatusSymbol {
	if formula_wrapper_has_pid(mut wrapper) {
		return .started
	}
	if !formula_wrapper_loaded(mut wrapper, true) {
		return .none
	}
	if exit_code := formula_wrapper_exit_code(mut wrapper) {
		if exit_code == 0 {
			return if formula_wrapper_timed(&wrapper) { .scheduled } else { .stopped }
		}
	}
	if formula_wrapper_error(mut wrapper) {
		return .error
	}
	if formula_wrapper_unknown_status(mut wrapper) {
		return .unknown
	}
	return .other
}

// Ruby method `exit_code_regex(status_type)` at line 343.
pub fn ruby_formula_wrapper_l343_d36_exit_code_regex(status_type FormulaWrapperStatusType) string {
	return match status_type {
		.launchctl_list { '"LastExitStatus" = ([0-9]*);' }
		.launchctl_print { 'last exit code = ([0-9]+)' }
		.systemctl { '\\(code=exited, status=([0-9]*)\\)|\\(dead\\)' }
	}
}

// Ruby method `pid_regex(status_type)` at line 353.
pub fn ruby_formula_wrapper_l353_d37_pid_regex(status_type FormulaWrapperStatusType) string {
	return match status_type {
		.launchctl_list { '"PID" = ([0-9]*);' }
		.launchctl_print { 'pid = ([0-9]+)' }
		.systemctl { 'Main PID: ([0-9]*) \\((?!code=)' }
	}
}

// Ruby method `loaded_file_regex(status_type)` at line 363.
pub fn ruby_formula_wrapper_l363_d38_loaded_file_regex(status_type FormulaWrapperStatusType) string {
	return match status_type {
		.launchctl_list { '' }
		.launchctl_print { 'path = (.*)' }
		.systemctl { 'Loaded: .*? \\((.*);' }
	}
}

// Ruby method `boot_path_service_file_present?` at line 373.
pub fn formula_wrapper_boot_path_service_file_present(wrapper &FormulaWrapper) bool {
	return wrapper.system.boot_path != '' && os.exists(os.join_path(wrapper.system.boot_path, basename(formula_wrapper_service_file(wrapper))))
}

// Ruby method `user_path_service_file_present?` at line 381.
pub fn formula_wrapper_user_path_service_file_present(wrapper &FormulaWrapper) bool {
	return wrapper.system.user_path != '' && os.exists(os.join_path(wrapper.system.user_path, basename(formula_wrapper_service_file(wrapper))))
}

// Ruby method `self.path_or_label_regex` at line 389.
pub fn ruby_formula_wrapper_l389_d41_self_path_or_label_regex() string {
	return r'homebrew(?>\.mxcl)?\.([\w+-.@]+)(\.plist|\.service)?\z'
}

// Ruby attr_reader `attr_reader :output` at line 395.
pub fn ruby_formula_wrapper_l395_d42_output(status StatusOutputSuccessType) string {
	return status.output
}

// Ruby attr_reader `attr_reader :success` at line 398.
pub fn ruby_formula_wrapper_l398_d43_success(status StatusOutputSuccessType) bool {
	return status.success
}

// Ruby attr_reader `attr_reader :type` at line 401.
pub fn ruby_formula_wrapper_l401_d44_type(status StatusOutputSuccessType) FormulaWrapperStatusType {
	return status.type_
}

// Ruby method `initialize(output, success, type)` at line 404.
pub fn ruby_formula_wrapper_l404_d45_initialize(output string, success bool,
	type_ FormulaWrapperStatusType) StatusOutputSuccessType {
	return StatusOutputSuccessType{ output: output, success: success, type_: type_ }
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/output"
// 5:
// 6: # Wrapper for a formula to handle service-related stuff like parsing and
// 7: # generating the service/plist files.
// 8: module Homebrew
// 9:   module Services
// 10:     class FormulaWrapper
// 11:       include Utils::Output::Mixin
// 12:
// 13:       # Access the `Formula` instance.
// 14:       sig { returns(Formula) }
// 15:       attr_reader :formula
// 16:
// 17:       # Create a new `Service` instance from either a path or label.
// 18:       sig { params(path_or_label: T.any(Pathname, String)).returns(T.nilable(FormulaWrapper)) }
// 19:       def self.from(path_or_label)
// 20:         return unless path_or_label =~ path_or_label_regex
// 21:
// 22:         begin
// 23:           new(Formulary.factory(T.must(Regexp.last_match(1))))
// 24:         rescue
// 25:           nil
// 26:         end
// 27:       end
// 28:
// 29:       # Initialize a new `Service` instance with supplied formula.
// 30:       sig { params(formula: Formula).void }
// 31:       def initialize(formula)
// 32:         @formula = formula
// 33:         @status_output_success_type = T.let(nil, T.nilable(StatusOutputSuccessType))
// 34:
// 35:         return if System.launchctl? || System.systemctl?
// 36:
// 37:         raise UsageError, System::MISSING_DAEMON_MANAGER_EXCEPTION_MESSAGE
// 38:       end
// 39:
// 40:       # Delegate access to `formula.name`.
// 41:       sig { returns(String) }
// 42:       def name
// 43:         @name ||= T.let(formula.name, T.nilable(String))
// 44:       end
// 45:
// 46:       # Delegate access to `formula.service?`.
// 47:       sig { returns(T::Boolean) }
// 48:       def service?
// 49:         @service ||= T.let(formula.service?, T.nilable(T::Boolean))
// 50:       end
// 51:
// 52:       # Delegate access to `formula.service.timed?`.
// 53:       sig { returns(T::Boolean) }
// 54:       def timed?
// 55:         return @timed unless @timed.nil?
// 56:
// 57:         @timed = T.let(service? && load_service.timed?, T.nilable(T::Boolean))
// 58:         @timed ||= false
// 59:       end
// 60:
// 61:       # Delegate access to `formula.service.keep_alive?`.
// 62:       sig { returns(T::Boolean) }
// 63:       def keep_alive?
// 64:         return @keep_alive unless @keep_alive.nil?
// 65:
// 66:         @keep_alive = T.let(service? && load_service.keep_alive?, T.nilable(T::Boolean))
// 67:         @keep_alive ||= false
// 68:       end
// 69:
// 70:       sig { returns(T::Array[Pathname]) }
// 71:       def path_dirs
// 72:         return [] unless service?
// 73:
// 74:         load_service.path_dirs
// 75:       end
// 76:
// 77:       # service_name delegates with formula.plist_name or formula.service_name
// 78:       # for systemd (e.g., `homebrew.<formula>`).
// 79:       sig { returns(String) }
// 80:       def service_name
// 81:         @service_name ||= T.let(
// 82:           if System.launchctl?
// 83:             formula.plist_name
// 84:           else # System.systemctl?
// 85:             formula.service_name
// 86:           end, T.nilable(String)
// 87:         )
// 88:       end
// 89:
// 90:       # service_file delegates with formula.launchd_service_path or formula.systemd_service_path for systemd.
// 91:       sig { returns(Pathname) }
// 92:       def service_file
// 93:         @service_file ||= T.let(
// 94:           if System.launchctl?
// 95:             formula.launchd_service_path
// 96:           else # System.systemctl?
// 97:             formula.systemd_service_path
// 98:           end, T.nilable(Pathname)
// 99:         )
// 100:       end
// 101:
// 102:       sig { returns(Pathname) }
// 103:       def timer_file
// 104:         @timer_file ||= T.let(formula.systemd_timer_path, T.nilable(Pathname))
// 105:       end
// 106:
// 107:       sig { returns(String) }
// 108:       def timer_name
// 109:         @timer_name ||= T.let(timer_file.basename.to_s, T.nilable(String))
// 110:       end
// 111:
// 112:       sig { returns(Pathname) }
// 113:       def timer_dest
// 114:         dest_dir + timer_file.basename
// 115:       end
// 116:
// 117:       # Whether the service should be launched at startup
// 118:       sig { returns(T::Boolean) }
// 119:       def service_startup?
// 120:         @service_startup ||= T.let(
// 121:           if service?
// 122:             load_service.requires_root?
// 123:           else
// 124:             false
// 125:           end, T.nilable(T::Boolean)
// 126:         )
// 127:       end
// 128:
// 129:       # Path to destination service directory. If run as root, it's `boot_path`, else `user_path`.
// 130:       sig { returns(Pathname) }
// 131:       def dest_dir
// 132:         System.root? ? System.boot_path : System.user_path
// 133:       end
// 134:
// 135:       # Path to destination service. If run as root, it's in `boot_path`, else `user_path`.
// 136:       sig { returns(Pathname) }
// 137:       def dest
// 138:         dest_dir + service_file.basename
// 139:       end
// 140:
// 141:       # Returns `true` if any version of the formula is installed.
// 142:       sig { returns(T::Boolean) }
// 143:       def installed?
// 144:         formula.any_version_installed?
// 145:       end
// 146:
// 147:       sig { void }
// 148:       def reset_cache!
// 149:         @status_output_success_type = nil
// 150:       end
// 151:
// 152:       # Returns `true` if the service is loaded, else false.
// 153:       sig { params(cached: T::Boolean).returns(T::Boolean) }
// 154:       def loaded?(cached: false)
// 155:         if System.launchctl?
// 156:           reset_cache! unless cached
// 157:           status_success
// 158:         else # System.systemctl?
// 159:           System::Systemctl.quiet_run("status", timed? ? timer_name : service_file.basename)
// 160:         end
// 161:       end
// 162:
// 163:       # Returns `true` if service is present (e.g. .plist is present in boot or user service path), else `false`
// 164:       # Accepts `type` with values `:root` for boot path or `:user` for user path.
// 165:       sig { params(type: T.nilable(Symbol)).returns(T::Boolean) }
// 166:       def service_file_present?(type: nil)
// 167:         case type
// 168:         when :root
// 169:           boot_path_service_file_present?
// 170:         when :user
// 171:           user_path_service_file_present?
// 172:         else
// 173:           boot_path_service_file_present? || user_path_service_file_present?
// 174:         end
// 175:       end
// 176:
// 177:       sig { returns(T.nilable(String)) }
// 178:       def owner
// 179:         if System.launchctl? && dest.exist?
// 180:           # read the username from the plist file
// 181:           require "plist"
// 182:           plist = begin
// 183:             Plist.parse_xml(dest.read, marshal: false)
// 184:           rescue
// 185:             nil
// 186:           end
// 187:           plist_username = plist["UserName"] if plist
// 188:
// 189:           return plist_username if plist_username.present?
// 190:         end
// 191:         return "root" if boot_path_service_file_present?
// 192:         return System.user if user_path_service_file_present?
// 193:
// 194:         nil
// 195:       end
// 196:
// 197:       sig { returns(T::Boolean) }
// 198:       def pid?
// 199:         (pid = self.pid).present? && pid.positive?
// 200:       end
// 201:
// 202:       sig { returns(T::Boolean) }
// 203:       def error?
// 204:         return false if pid?
// 205:
// 206:         (exit_code = self.exit_code).present? && !exit_code.zero?
// 207:       end
// 208:
// 209:       sig { returns(T::Boolean) }
// 210:       def unknown_status?
// 211:         status_output.blank? && !pid?
// 212:       end
// 213:
// 214:       # Get current PID of daemon process from status output.
// 215:       sig { returns(T.nilable(Integer)) }
// 216:       def pid
// 217:         Regexp.last_match(1).to_i if status_output =~ pid_regex(status_type)
// 218:       end
// 219:
// 220:       # Get current exit code of daemon process from status output.
// 221:       sig { returns(T.nilable(Integer)) }
// 222:       def exit_code
// 223:         Regexp.last_match(1).to_i if status_output =~ exit_code_regex(status_type)
// 224:       end
// 225:
// 226:       sig { returns(T.nilable(String)) }
// 227:       def loaded_file
// 228:         Regexp.last_match(1) if status_output =~ loaded_file_regex(status_type)
// 229:       end
// 230:
// 231:       sig { returns(T::Hash[Symbol, T.anything]) }
// 232:       def to_hash
// 233:         hash = {
// 234:           name:,
// 235:           service_name:,
// 236:           running:      pid?,
// 237:           loaded:       loaded?(cached: true),
// 238:           schedulable:  timed?,
// 239:           pid:,
// 240:           exit_code:,
// 241:           user:         owner,
// 242:           status:       status_symbol,
// 243:           file:         service_file_present? ? dest : service_file,
// 244:           registered:   service_file_present?,
// 245:           loaded_file:,
// 246:         }
// 247:
// 248:         return hash unless service?
// 249:
// 250:         service = load_service
// 251:
// 252:         return hash if service.command.blank?
// 253:
// 254:         hash[:command] = service.manual_command
// 255:         hash[:working_dir] = service.working_dir
// 256:         hash[:root_dir] = service.root_dir
// 257:         hash[:log_path] = service.log_path
// 258:         hash[:error_log_path] = service.error_log_path
// 259:         hash[:interval] = service.interval
// 260:         hash[:cron] = service.cron.presence
// 261:
// 262:         hash
// 263:       end
// 264:
// 265:       # Generate the service file content (plist or systemd unit),
// 266:       # including any per-service user environment variable overrides,
// 267:       # or read the package-provided service file if the formula's
// 268:       # service block does not define a command.
// 269:       sig { returns(String) }
// 270:       def service_contents
// 271:         if !service? || !load_service.command?
// 272:           service_file.read
// 273:         elsif System.launchctl?
// 274:           load_service.to_plist
// 275:         else
// 276:           load_service.to_systemd_unit
// 277:         end
// 278:       end
// 279:
// 280:       private
// 281:
// 282:       # The purpose of this function is to lazy load the Homebrew::Service class
// 283:       # and avoid nameclashes with the current Service module.
// 284:       # It should be used instead of calling formula.service directly.
// 285:       sig { returns(Homebrew::Service) }
// 286:       def load_service
// 287:         require "formula"
// 288:
// 289:         formula.service
// 290:       end
// 291:
// 292:       sig { returns(StatusOutputSuccessType) }
// 293:       def status_output_success_type
// 294:         @status_output_success_type ||= if System.launchctl?
// 295:           output, success, type = System.launchctl_find_service(service_name)
// 296:           StatusOutputSuccessType.new(output, success, type)
// 297:         else # System.systemctl?
// 298:           cmd = ["status", service_name]
// 299:           output = System::Systemctl.popen_read(*cmd).chomp
// 300:           success = T.cast($CHILD_STATUS.present? && $CHILD_STATUS.success? && output.present?, T::Boolean)
// 301:           odebug [System::Systemctl.executable, System::Systemctl.scope, *cmd].join(" "), output
// 302:           StatusOutputSuccessType.new(output, success, :systemctl)
// 303:         end
// 304:       end
// 305:
// 306:       sig { returns(String) }
// 307:       def status_output
// 308:         status_output_success_type.output
// 309:       end
// 310:
// 311:       sig { returns(T::Boolean) }
// 312:       def status_success
// 313:         status_output_success_type.success
// 314:       end
// 315:
// 316:       sig { returns(Symbol) }
// 317:       def status_type
// 318:         status_output_success_type.type
// 319:       end
// 320:
// 321:       sig { returns(Symbol) }
// 322:       def status_symbol
// 323:         if pid?
// 324:           :started
// 325:         elsif !loaded?(cached: true)
// 326:           :none
// 327:         elsif (exit_code = self.exit_code).present? && exit_code.zero?
// 328:           if timed?
// 329:             :scheduled
// 330:           else
// 331:             :stopped
// 332:           end
// 333:         elsif error?
// 334:           :error
// 335:         elsif unknown_status?
// 336:           :unknown
// 337:         else
// 338:           :other
// 339:         end
// 340:       end
// 341:
// 342:       sig { params(status_type: Symbol).returns(Regexp) }
// 343:       def exit_code_regex(status_type)
// 344:         @exit_code_regex ||= T.let({
// 345:           launchctl_list:  /"LastExitStatus"\ =\ ([0-9]*);/,
// 346:           launchctl_print: /last exit code = ([0-9]+)/,
// 347:           systemctl:       /\(code=exited, status=([0-9]*)\)|\(dead\)/,
// 348:         }, T.nilable(T::Hash[Symbol, Regexp]))
// 349:         @exit_code_regex.fetch(status_type)
// 350:       end
// 351:
// 352:       sig { params(status_type: Symbol).returns(Regexp) }
// 353:       def pid_regex(status_type)
// 354:         @pid_regex ||= T.let({
// 355:           launchctl_list:  /"PID"\ =\ ([0-9]*);/,
// 356:           launchctl_print: /pid = ([0-9]+)/,
// 357:           systemctl:       /Main PID: ([0-9]*) \((?!code=)/,
// 358:         }, T.nilable(T::Hash[Symbol, Regexp]))
// 359:         @pid_regex.fetch(status_type)
// 360:       end
// 361:
// 362:       sig { params(status_type: Symbol).returns(Regexp) }
// 363:       def loaded_file_regex(status_type)
// 364:         @loaded_file_regex ||= T.let({
// 365:           launchctl_list:  //, # not available
// 366:           launchctl_print: /path = (.*)/,
// 367:           systemctl:       /Loaded: .*? \((.*);/,
// 368:         }, T.nilable(T::Hash[Symbol, Regexp]))
// 369:         @loaded_file_regex.fetch(status_type)
// 370:       end
// 371:
// 372:       sig { returns(T::Boolean) }
// 373:       def boot_path_service_file_present?
// 374:         boot_path = System.boot_path
// 375:         return false if boot_path.blank?
// 376:
// 377:         (boot_path + service_file.basename).exist?
// 378:       end
// 379:
// 380:       sig { returns(T::Boolean) }
// 381:       def user_path_service_file_present?
// 382:         user_path = System.user_path
// 383:         return false if user_path.blank?
// 384:
// 385:         (user_path + service_file.basename).exist?
// 386:       end
// 387:
// 388:       sig { returns(Regexp) }
// 389:       private_class_method def self.path_or_label_regex
// 390:         /homebrew(?>\.mxcl)?\.([\w+-.@]+)(\.plist|\.service)?\z/
// 391:       end
// 392:
// 393:       class StatusOutputSuccessType
// 394:         sig { returns(String) }
// 395:         attr_reader :output
// 396:
// 397:         sig { returns(T::Boolean) }
// 398:         attr_reader :success
// 399:
// 400:         sig { returns(Symbol) }
// 401:         attr_reader :type
// 402:
// 403:         sig { params(output: String, success: T::Boolean, type: Symbol).void }
// 404:         def initialize(output, success, type)
// 405:           @output = output
// 406:           @success = success
// 407:           @type = type
// 408:         end
// 409:       end
// 410:     end
// 411:   end
// 412: end
