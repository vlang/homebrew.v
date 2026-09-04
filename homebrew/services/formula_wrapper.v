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

// Ruby method `name` at line 42.
pub fn formula_wrapper_name(wrapper &FormulaWrapper) string {
	return wrapper.formula.name
}

// Ruby method `timed?` at line 54.
pub fn formula_wrapper_timed(wrapper &FormulaWrapper) bool {
	return wrapper.formula.has_service && wrapper.formula.service.timed
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

// Ruby method `dest_dir` at line 131.
pub fn formula_wrapper_dest_dir(wrapper &FormulaWrapper) string {
	return if wrapper.system.root { wrapper.system.boot_path } else { wrapper.system.user_path }
}

// Ruby method `dest` at line 137.
pub fn formula_wrapper_dest(wrapper &FormulaWrapper) string {
	return os.join_path(formula_wrapper_dest_dir(wrapper), basename(formula_wrapper_service_file(wrapper)))
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

// Ruby method `boot_path_service_file_present?` at line 373.
pub fn formula_wrapper_boot_path_service_file_present(wrapper &FormulaWrapper) bool {
	return wrapper.system.boot_path != '' && os.exists(os.join_path(wrapper.system.boot_path, basename(formula_wrapper_service_file(wrapper))))
}

// Ruby method `user_path_service_file_present?` at line 381.
pub fn formula_wrapper_user_path_service_file_present(wrapper &FormulaWrapper) bool {
	return wrapper.system.user_path != '' && os.exists(os.join_path(wrapper.system.user_path, basename(formula_wrapper_service_file(wrapper))))
}
