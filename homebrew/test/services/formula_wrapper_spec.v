module services

import homebrew.services as formula_wrapper
import os

// Translated from Homebrew/brew `test/services/formula_wrapper_spec.rb`.
// The retained Ruby source follows these concrete source-derived examples.
fn formula_wrapper_spec_service_object() formula_wrapper.FormulaWrapperService {
	return formula_wrapper.FormulaWrapperService{
		command: ['/bin/cmd']
		manual_command: '/bin/cmd'
		cron: map[string]string{}
		plist_contents: 'plist contents'
		systemd_unit: 'unit contents'
	}
}

fn formula_wrapper_spec_formula(has_service bool,
	service formula_wrapper.FormulaWrapperService) formula_wrapper.FormulaWrapperFormula {
	return formula_wrapper.FormulaWrapperFormula{
		name: 'mysql'
		plist_name: 'plist-mysql-test'
		service_name: 'plist-mysql-test'
		launchd_service_path: '/usr/local/opt/mysql/homebrew.mysql.plist'
		systemd_service_path: '/usr/local/opt/mysql/homebrew.mysql.service'
		systemd_timer_path: '/usr/local/opt/mysql/homebrew.mysql.timer'
		any_version_installed: true
		has_service: has_service
		service: service
	}
}

fn formula_wrapper_spec_system(manager formula_wrapper.FormulaWrapperDaemonManager,
	root bool, boot_path string, user_path string) formula_wrapper.FormulaWrapperSystem {
	return formula_wrapper.FormulaWrapperSystem{
		manager: manager
		root: root
		boot_path: boot_path
		user_path: user_path
		user: 'user'
		launchctl_status: formula_wrapper.StatusOutputSuccessType{
			type_: .launchctl_print
		}
	}
}

fn formula_wrapper_spec_wrapper(manager formula_wrapper.FormulaWrapperDaemonManager,
	has_service bool, service formula_wrapper.FormulaWrapperService) !formula_wrapper.FormulaWrapper {
	return formula_wrapper.new_formula_wrapper(formula_wrapper_spec_formula(has_service, service), formula_wrapper_spec_system(manager, false, '/Library/LaunchDaemons', '/tmp_home/Library/LaunchAgents'))
}

fn formula_wrapper_spec_temp_dir(label string) !string {
	path := os.join_path(os.temp_dir(), 'brew-v-formula-wrapper-${os.getpid()}-${label}')
	if os.exists(path) {
		os.rmdir_all(path)!
	}
	os.mkdir_all(path)!
	return path
}

fn formula_wrapper_spec_base_hash_matches(value formula_wrapper.FormulaWrapperHash,
	file string, registered bool) bool {
	if _ := value.pid {
		return false
	}
	if _ := value.exit_code {
		return false
	}
	if _ := value.user {
		return false
	}
	if _ := value.loaded_file {
		return false
	}
	return value.name == 'mysql' && value.service_name == 'plist-mysql-test' && !value.running && !value.loaded && !value.schedulable && value.status == .none && value.file == file && value.registered == registered
}

// Ruby subject `subject(:service) { described_class.new(formula) }` at line 9.
pub fn ruby_formula_wrapper_spec_l9_d1_service() !formula_wrapper.FormulaWrapper {
	return formula_wrapper_spec_wrapper(.launchctl, false, formula_wrapper_spec_service_object())
}

// Ruby let `let(:formula) do` at line 11.
pub fn ruby_formula_wrapper_spec_l11_d2_formula() formula_wrapper.FormulaWrapperFormula {
	return formula_wrapper_spec_formula(false, formula_wrapper_spec_service_object())
}

// Ruby let `let(:service_object) do` at line 23.
pub fn ruby_formula_wrapper_spec_l23_d3_service_object() formula_wrapper.FormulaWrapperService {
	return formula_wrapper_spec_service_object()
}

// Ruby it `it "macOS - outputs the full service file path" do` at line 44.
pub fn ruby_formula_wrapper_spec_l44_d4_macos() !bool {
	wrapper := formula_wrapper_spec_wrapper(.launchctl, false, formula_wrapper_spec_service_object())!
	return formula_wrapper.ruby_formula_wrapper_l92_d10_service_file(&wrapper) == '/usr/local/opt/mysql/homebrew.mysql.plist'
}

// Ruby it `it "systemD - outputs the full service file path" do` at line 49.
pub fn ruby_formula_wrapper_spec_l49_d5_systemd() !bool {
	wrapper := formula_wrapper_spec_wrapper(.systemctl, false, formula_wrapper_spec_service_object())!
	return formula_wrapper.ruby_formula_wrapper_l92_d10_service_file(&wrapper) == '/usr/local/opt/mysql/homebrew.mysql.service'
}

// Ruby it `it "Other - raises an error" do` at line 54.
pub fn ruby_formula_wrapper_spec_l54_d6_other() bool {
	formula_wrapper.new_formula_wrapper(formula_wrapper_spec_formula(false, formula_wrapper_spec_service_object()), formula_wrapper_spec_system(.unavailable, false, '/Library/LaunchDaemons', '/tmp_home/Library/LaunchAgents')) or {
		return err.msg() == formula_wrapper.missing_daemon_manager_exception_message
	}
	return false
}

// Ruby it `it "outputs formula name" do` at line 64.
pub fn ruby_formula_wrapper_spec_l64_d7_outputs() !bool {
	wrapper := ruby_formula_wrapper_spec_l9_d1_service()!
	return formula_wrapper.ruby_formula_wrapper_l42_d4_name(&wrapper) == 'mysql'
}

// Ruby it `it "macOS - generates the plist from the formula service block" do` at line 70.
pub fn ruby_formula_wrapper_spec_l70_d8_macos() !bool {
	wrapper := formula_wrapper_spec_wrapper(.launchctl, true, formula_wrapper_spec_service_object())!
	return formula_wrapper.ruby_formula_wrapper_l270_d29_service_contents(&wrapper)! == 'plist contents'
}

// Ruby it `it "systemD - generates the unit from the formula service block" do` at line 78.
pub fn ruby_formula_wrapper_spec_l78_d9_systemd() !bool {
	wrapper := formula_wrapper_spec_wrapper(.systemctl, true, formula_wrapper_spec_service_object())!
	return formula_wrapper.ruby_formula_wrapper_l270_d29_service_contents(&wrapper)! == 'unit contents'
}

// Ruby it `it "reads the package-provided service file when the service block has no command" do` at line 86.
pub fn ruby_formula_wrapper_spec_l86_d10_reads() !bool {
	directory := formula_wrapper_spec_temp_dir('no-command')!
	defer { os.rmdir_all(directory) or {} }
	path := os.join_path(directory, 'custom.name.plist')
	os.write_file(path, 'package plist')!
	mut formula := formula_wrapper_spec_formula(true, formula_wrapper.FormulaWrapperService{
		cron: map[string]string{}
	})
	formula.launchd_service_path = path
	wrapper := formula_wrapper.new_formula_wrapper(formula, formula_wrapper_spec_system(.launchctl, false, '/Library/LaunchDaemons', '/tmp_home/Library/LaunchAgents'))!
	return formula_wrapper.ruby_formula_wrapper_l270_d29_service_contents(&wrapper)! == 'package plist'
}

// Ruby it `it "reads the package-provided service file when the formula has no service block" do` at line 95.
pub fn ruby_formula_wrapper_spec_l95_d11_reads() !bool {
	directory := formula_wrapper_spec_temp_dir('no-service')!
	defer { os.rmdir_all(directory) or {} }
	path := os.join_path(directory, 'custom.name.plist')
	os.write_file(path, 'package plist')!
	mut formula := formula_wrapper_spec_formula(false, formula_wrapper_spec_service_object())
	formula.launchd_service_path = path
	wrapper := formula_wrapper.new_formula_wrapper(formula, formula_wrapper_spec_system(.launchctl, false, '/Library/LaunchDaemons', '/tmp_home/Library/LaunchAgents'))!
	return formula_wrapper.ruby_formula_wrapper_l270_d29_service_contents(&wrapper)! == 'package plist'
}

// Ruby it `it "macOS - outputs the service name" do` at line 105.
pub fn ruby_formula_wrapper_spec_l105_d12_macos() !bool {
	wrapper := formula_wrapper_spec_wrapper(.launchctl, false, formula_wrapper_spec_service_object())!
	return formula_wrapper.ruby_formula_wrapper_l80_d9_service_name(&wrapper) == 'plist-mysql-test'
}

// Ruby it `it "systemD - outputs the service name" do` at line 110.
pub fn ruby_formula_wrapper_spec_l110_d13_systemd() !bool {
	wrapper := formula_wrapper_spec_wrapper(.systemctl, false, formula_wrapper_spec_service_object())!
	return formula_wrapper.ruby_formula_wrapper_l80_d9_service_name(&wrapper) == 'plist-mysql-test'
}

// Ruby it `it "Other - raises an error" do` at line 115.
pub fn ruby_formula_wrapper_spec_l115_d14_other() bool {
	return ruby_formula_wrapper_spec_l54_d6_other()
}

// Ruby it `it "macOS - user - outputs the destination directory for the service file" do` at line 129.
pub fn ruby_formula_wrapper_spec_l129_d15_macos() !bool {
	wrapper := formula_wrapper_spec_wrapper(.launchctl, false, formula_wrapper_spec_service_object())!
	return formula_wrapper.ruby_formula_wrapper_l131_d15_dest_dir(&wrapper) == '/tmp_home/Library/LaunchAgents'
}

// Ruby it `it "macOS - root - outputs the destination directory for the service file" do` at line 135.
pub fn ruby_formula_wrapper_spec_l135_d16_macos() !bool {
	wrapper := formula_wrapper.new_formula_wrapper(formula_wrapper_spec_formula(false, formula_wrapper_spec_service_object()), formula_wrapper_spec_system(.launchctl, true, '/Library/LaunchDaemons', '/tmp_home/Library/LaunchAgents'))!
	return formula_wrapper.ruby_formula_wrapper_l131_d15_dest_dir(&wrapper) == '/Library/LaunchDaemons'
}

// Ruby it `it "systemD - user - outputs the destination directory for the service file" do` at line 140.
pub fn ruby_formula_wrapper_spec_l140_d17_systemd() !bool {
	wrapper := formula_wrapper.new_formula_wrapper(formula_wrapper_spec_formula(false, formula_wrapper_spec_service_object()), formula_wrapper_spec_system(.systemctl, false, '/usr/lib/systemd/system', '/tmp_home/.config/systemd/user'))!
	return formula_wrapper.ruby_formula_wrapper_l131_d15_dest_dir(&wrapper) == '/tmp_home/.config/systemd/user'
}

// Ruby it `it "systemD - root - outputs the destination directory for the service file" do` at line 146.
pub fn ruby_formula_wrapper_spec_l146_d18_systemd() !bool {
	wrapper := formula_wrapper.new_formula_wrapper(formula_wrapper_spec_formula(false, formula_wrapper_spec_service_object()), formula_wrapper_spec_system(.systemctl, true, '/usr/lib/systemd/system', '/tmp_home/.config/systemd/user'))!
	return formula_wrapper.ruby_formula_wrapper_l131_d15_dest_dir(&wrapper) == '/usr/lib/systemd/system'
}

// Ruby it `it "macOS - outputs the destination for the service file" do` at line 158.
pub fn ruby_formula_wrapper_spec_l158_d19_macos() !bool {
	wrapper := formula_wrapper_spec_wrapper(.launchctl, false, formula_wrapper_spec_service_object())!
	return formula_wrapper.ruby_formula_wrapper_l137_d16_dest(&wrapper) == '/tmp_home/Library/LaunchAgents/homebrew.mysql.plist'
}

// Ruby it `it "systemD - outputs the destination for the service file" do` at line 163.
pub fn ruby_formula_wrapper_spec_l163_d20_systemd() !bool {
	wrapper := formula_wrapper.new_formula_wrapper(formula_wrapper_spec_formula(false, formula_wrapper_spec_service_object()), formula_wrapper_spec_system(.systemctl, false, '/usr/lib/systemd/system', '/tmp_home/.config/systemd/user'))!
	return formula_wrapper.ruby_formula_wrapper_l137_d16_dest(&wrapper) == '/tmp_home/.config/systemd/user/homebrew.mysql.service'
}

// Ruby it `it "outputs if the service formula is installed" do` at line 170.
pub fn ruby_formula_wrapper_spec_l170_d21_outputs() !bool {
	wrapper := ruby_formula_wrapper_spec_l9_d1_service()!
	return formula_wrapper.ruby_formula_wrapper_l143_d17_installed(&wrapper)
}

// Ruby it `it "macOS - outputs if the service is loaded" do` at line 176.
pub fn ruby_formula_wrapper_spec_l176_d22_macos() !bool {
	mut wrapper := ruby_formula_wrapper_spec_l9_d1_service()!
	return !formula_wrapper.ruby_formula_wrapper_l154_d19_loaded(mut wrapper, false)
}

// Ruby it `it "systemD - outputs if the service is loaded" do` at line 182.
pub fn ruby_formula_wrapper_spec_l182_d23_systemd() !bool {
	mut wrapper := formula_wrapper_spec_wrapper(.systemctl, false, formula_wrapper_spec_service_object())!
	return !formula_wrapper.ruby_formula_wrapper_l154_d19_loaded(mut wrapper, false)
}

// Ruby it `it "systemD - checks timer status for timed services" do` at line 189.
pub fn ruby_formula_wrapper_spec_l189_d24_systemd() !bool {
	mut service := formula_wrapper_spec_service_object()
	service.timed = true
	mut system := formula_wrapper_spec_system(.systemctl, false, '/usr/lib/systemd/system', '/tmp_home/.config/systemd/user')
	system.systemctl_quiet_run_result = true
	mut wrapper := formula_wrapper.new_formula_wrapper(formula_wrapper_spec_formula(true, service), system)!
	return formula_wrapper.ruby_formula_wrapper_l154_d19_loaded(mut wrapper, false) && wrapper.last_quiet_run_target == 'homebrew.mysql.timer'
}

// Ruby it `it "Other - raises an error" do` at line 199.
pub fn ruby_formula_wrapper_spec_l199_d25_other() bool {
	return ruby_formula_wrapper_spec_l54_d6_other()
}

// Ruby it `it "reads the user from a launchd plist" do` at line 209.
pub fn ruby_formula_wrapper_spec_l209_d26_reads() !bool {
	directory := formula_wrapper_spec_temp_dir('plist-owner')!
	defer { os.rmdir_all(directory) or {} }
	path := os.join_path(directory, 'homebrew.mysql.plist')
	os.write_file(path, '<?xml version="1.0" encoding="UTF-8"?>\n<plist version="1.0"><dict><key>UserName</key><string>_serviced</string></dict></plist>')!
	wrapper := formula_wrapper.new_formula_wrapper(formula_wrapper_spec_formula(false, formula_wrapper_spec_service_object()), formula_wrapper_spec_system(.launchctl, false, '/Library/LaunchDaemons', directory))!
	owner := formula_wrapper.ruby_formula_wrapper_l178_d21_owner(&wrapper) or { return false }
	return owner == '_serviced'
}

// Ruby it `it "root if file present" do` at line 226.
pub fn ruby_formula_wrapper_spec_l226_d27_root() !bool {
	directory := formula_wrapper_spec_temp_dir('root-owner')!
	defer { os.rmdir_all(directory) or {} }
	os.write_file(os.join_path(directory, 'homebrew.mysql.plist'), '')!
	wrapper := formula_wrapper.new_formula_wrapper(formula_wrapper_spec_formula(false, formula_wrapper_spec_service_object()), formula_wrapper_spec_system(.launchctl, false, directory, ''))!
	owner := formula_wrapper.ruby_formula_wrapper_l178_d21_owner(&wrapper) or { return false }
	return owner == 'root'
}

// Ruby it `it "user if file present" do` at line 231.
pub fn ruby_formula_wrapper_spec_l231_d28_user() !bool {
	directory := formula_wrapper_spec_temp_dir('user-owner')!
	defer { os.rmdir_all(directory) or {} }
	os.write_file(os.join_path(directory, 'homebrew.mysql.plist'), '')!
	wrapper := formula_wrapper.new_formula_wrapper(formula_wrapper_spec_formula(false, formula_wrapper_spec_service_object()), formula_wrapper_spec_system(.launchctl, false, '', directory))!
	owner := formula_wrapper.ruby_formula_wrapper_l178_d21_owner(&wrapper) or { return false }
	return owner == 'user'
}

// Ruby it `it "nil if no file present" do` at line 238.
pub fn ruby_formula_wrapper_spec_l238_d29_nil() !bool {
	wrapper := formula_wrapper.new_formula_wrapper(formula_wrapper_spec_formula(false, formula_wrapper_spec_service_object()), formula_wrapper_spec_system(.launchctl, false, '', ''))!
	if _ := formula_wrapper.ruby_formula_wrapper_l178_d21_owner(&wrapper) {
		return false
	}
	return true
}

// Ruby it `it "macOS - outputs if the service file is present" do` at line 246.
pub fn ruby_formula_wrapper_spec_l246_d30_macos() !bool {
	wrapper := ruby_formula_wrapper_spec_l9_d1_service()!
	return !formula_wrapper.ruby_formula_wrapper_l166_d20_service_file_present(&wrapper, .any)
}

// Ruby it `it "macOS - outputs if the service file is present for root" do` at line 251.
pub fn ruby_formula_wrapper_spec_l251_d31_macos() !bool {
	wrapper := ruby_formula_wrapper_spec_l9_d1_service()!
	return !formula_wrapper.ruby_formula_wrapper_l166_d20_service_file_present(&wrapper, .root)
}

// Ruby it `it "macOS - outputs if the service file is present for user" do` at line 256.
pub fn ruby_formula_wrapper_spec_l256_d32_macos() !bool {
	wrapper := ruby_formula_wrapper_spec_l9_d1_service()!
	return !formula_wrapper.ruby_formula_wrapper_l166_d20_service_file_present(&wrapper, .user)
}

// Ruby it `it "macOS - outputs the service file owner" do` at line 263.
pub fn ruby_formula_wrapper_spec_l263_d33_macos() !bool {
	wrapper := formula_wrapper.new_formula_wrapper(formula_wrapper_spec_formula(false, formula_wrapper_spec_service_object()), formula_wrapper_spec_system(.launchctl, false, '', ''))!
	if _ := formula_wrapper.ruby_formula_wrapper_l178_d21_owner(&wrapper) {
		return false
	}
	return true
}

// Ruby it `it "outputs false because there is not PID" do` at line 270.
pub fn ruby_formula_wrapper_spec_l270_d34_outputs() bool {
	return !formula_wrapper.formula_wrapper_pid_present_value(none)
}

// Ruby it `it "outputs false because there is a PID and it is zero" do` at line 275.
pub fn ruby_formula_wrapper_spec_l275_d35_outputs() bool {
	return !formula_wrapper.formula_wrapper_pid_present_value(0)
}

// Ruby it `it "outputs true because there is a PID and it is positive" do` at line 280.
pub fn ruby_formula_wrapper_spec_l280_d36_outputs() bool {
	return formula_wrapper.formula_wrapper_pid_present_value(12)
}

// Ruby it `it "outputs false because there is a PID and it is negative" do` at line 286.
pub fn ruby_formula_wrapper_spec_l286_d37_outputs() bool {
	return !formula_wrapper.formula_wrapper_pid_present_value(-1)
}

// Ruby it `it "outputs nil because there is not pid" do` at line 293.
pub fn ruby_formula_wrapper_spec_l293_d38_outputs() !bool {
	mut wrapper := formula_wrapper_spec_wrapper(.systemctl, false, formula_wrapper_spec_service_object())!
	if _ := formula_wrapper.ruby_formula_wrapper_l216_d25_pid(mut wrapper) {
		return false
	}
	return true
}

// Ruby it `it "outputs false because there is no PID or exit code" do` at line 299.
pub fn ruby_formula_wrapper_spec_l299_d39_outputs() bool {
	return !formula_wrapper.formula_wrapper_error_values(none, none)
}

// Ruby it `it "outputs false because there is a PID but no exit" do` at line 304.
pub fn ruby_formula_wrapper_spec_l304_d40_outputs() bool {
	return !formula_wrapper.formula_wrapper_error_values(12, none)
}

// Ruby it `it "outputs false because there is a PID and a zero exit code" do` at line 309.
pub fn ruby_formula_wrapper_spec_l309_d41_outputs() bool {
	return !formula_wrapper.formula_wrapper_error_values(12, 0)
}

// Ruby it `it "outputs false because there is a PID and a positive exit code" do` at line 314.
pub fn ruby_formula_wrapper_spec_l314_d42_outputs() bool {
	return !formula_wrapper.formula_wrapper_error_values(12, 1)
}

// Ruby it `it "outputs false because there is no PID and a zero exit code" do` at line 319.
pub fn ruby_formula_wrapper_spec_l319_d43_outputs() bool {
	return !formula_wrapper.formula_wrapper_error_values(none, 0)
}

// Ruby it `it "outputs true because there is no PID and a positive exit code" do` at line 324.
pub fn ruby_formula_wrapper_spec_l324_d44_outputs() bool {
	return formula_wrapper.formula_wrapper_error_values(none, 1)
}

// Ruby it `it "outputs true because there is no PID and a negative exit code" do` at line 330.
pub fn ruby_formula_wrapper_spec_l330_d45_outputs() bool {
	return formula_wrapper.formula_wrapper_error_values(none, -1)
}

// Ruby it `it "outputs nil because there is no exit code" do` at line 337.
pub fn ruby_formula_wrapper_spec_l337_d46_outputs() !bool {
	mut wrapper := formula_wrapper_spec_wrapper(.systemctl, false, formula_wrapper_spec_service_object())!
	if _ := formula_wrapper.ruby_formula_wrapper_l222_d26_exit_code(mut wrapper) {
		return false
	}
	return true
}

// Ruby it `it "outputs true because there is no PID" do` at line 343.
pub fn ruby_formula_wrapper_spec_l343_d47_outputs() !bool {
	mut wrapper := formula_wrapper_spec_wrapper(.systemctl, false, formula_wrapper_spec_service_object())!
	return formula_wrapper.ruby_formula_wrapper_l210_d24_unknown_status(mut wrapper)
}

// Ruby it `it "returns true if timed service" do` at line 349.
pub fn ruby_formula_wrapper_spec_l349_d48_returns() !bool {
	mut service := formula_wrapper_spec_service_object()
	service.timed = true
	wrapper := formula_wrapper_spec_wrapper(.launchctl, true, service)!
	return formula_wrapper.ruby_formula_wrapper_l54_d6_timed(&wrapper)
}

// Ruby it `it "returns false if no timed service" do` at line 357.
pub fn ruby_formula_wrapper_spec_l357_d49_returns() !bool {
	wrapper := formula_wrapper_spec_wrapper(.launchctl, true, formula_wrapper_spec_service_object())!
	return !formula_wrapper.ruby_formula_wrapper_l54_d6_timed(&wrapper)
}

// Ruby it `it "returns false if no service" do` at line 367.
pub fn ruby_formula_wrapper_spec_l367_d50_returns() !bool {
	wrapper := formula_wrapper_spec_wrapper(.launchctl, false, formula_wrapper_spec_service_object())!
	return !formula_wrapper.ruby_formula_wrapper_l54_d6_timed(&wrapper)
}

// Ruby it `it "returns true if service needs to stay alive" do` at line 375.
pub fn ruby_formula_wrapper_spec_l375_d51_returns() !bool {
	mut service := formula_wrapper_spec_service_object()
	service.keep_alive = true
	wrapper := formula_wrapper_spec_wrapper(.launchctl, true, service)!
	return formula_wrapper.ruby_formula_wrapper_l63_d7_keep_alive(&wrapper)
}

// Ruby it `it "returns false if service does not need to stay alive" do` at line 384.
pub fn ruby_formula_wrapper_spec_l384_d52_returns() !bool {
	wrapper := formula_wrapper_spec_wrapper(.launchctl, true, formula_wrapper_spec_service_object())!
	return !formula_wrapper.ruby_formula_wrapper_l63_d7_keep_alive(&wrapper)
}

// Ruby it `it "returns false if no service" do` at line 393.
pub fn ruby_formula_wrapper_spec_l393_d53_returns() !bool {
	wrapper := formula_wrapper_spec_wrapper(.launchctl, false, formula_wrapper_spec_service_object())!
	return !formula_wrapper.ruby_formula_wrapper_l63_d7_keep_alive(&wrapper)
}

// Ruby it `it "outputs false since there is no startup" do` at line 401.
pub fn ruby_formula_wrapper_spec_l401_d54_outputs() !bool {
	wrapper := formula_wrapper_spec_wrapper(.launchctl, false, formula_wrapper_spec_service_object())!
	return !formula_wrapper.ruby_formula_wrapper_l119_d14_service_startup(&wrapper)
}

// Ruby it `it "outputs true since there is a startup service" do` at line 405.
pub fn ruby_formula_wrapper_spec_l405_d55_outputs() !bool {
	mut service := formula_wrapper_spec_service_object()
	service.requires_root = true
	wrapper := formula_wrapper_spec_wrapper(.launchctl, true, service)!
	return formula_wrapper.ruby_formula_wrapper_l119_d14_service_startup(&wrapper)
}

// Ruby it `it "represents non-service values" do` at line 414.
pub fn ruby_formula_wrapper_spec_l414_d56_represents() !bool {
	mut wrapper := formula_wrapper.new_formula_wrapper(formula_wrapper_spec_formula(false, formula_wrapper_spec_service_object()), formula_wrapper_spec_system(.launchctl, false, '', ''))!
	wrapper.has_service_file_present_override = true
	wrapper.service_file_present_override = false
	value := formula_wrapper.ruby_formula_wrapper_l232_d28_to_hash(mut wrapper)
	return formula_wrapper_spec_base_hash_matches(value, '/usr/local/opt/mysql/homebrew.mysql.plist', false) && !value.has_service_details
}

// Ruby it `it "represents running non-service values" do` at line 435.
pub fn ruby_formula_wrapper_spec_l435_d57_represents() !bool {
	mut wrapper := formula_wrapper.new_formula_wrapper(formula_wrapper_spec_formula(false, formula_wrapper_spec_service_object()), formula_wrapper_spec_system(.launchctl, false, '', '/tmp_home/Library/LaunchAgents'))!
	wrapper.has_service_file_present_override = true
	wrapper.service_file_present_override = true
	value := formula_wrapper.ruby_formula_wrapper_l232_d28_to_hash(mut wrapper)
	return formula_wrapper_spec_base_hash_matches(value, '/tmp_home/Library/LaunchAgents/homebrew.mysql.plist', true) && !value.has_service_details
}

// Ruby it `it "represents service values" do` at line 457.
pub fn ruby_formula_wrapper_spec_l457_d58_represents() !bool {
	mut wrapper := formula_wrapper.new_formula_wrapper(formula_wrapper_spec_formula(true, formula_wrapper_spec_service_object()), formula_wrapper_spec_system(.launchctl, false, '', '/tmp_home/Library/LaunchAgents'))!
	wrapper.has_service_file_present_override = true
	wrapper.service_file_present_override = true
	value := formula_wrapper.ruby_formula_wrapper_l232_d28_to_hash(mut wrapper)
	if _ := value.working_dir {
		return false
	}
	if _ := value.root_dir {
		return false
	}
	if _ := value.log_path {
		return false
	}
	if _ := value.error_log_path {
		return false
	}
	if _ := value.interval {
		return false
	}
	return formula_wrapper_spec_base_hash_matches(value, '/tmp_home/Library/LaunchAgents/homebrew.mysql.plist', true) && value.has_service_details && value.command == '/bin/cmd' && !value.has_cron
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "services/system"
// 5: require "services/formula_wrapper"
// 6: require "tempfile"
// 7:
// 8: RSpec.describe Homebrew::Services::FormulaWrapper, :needs_daemon_manager do
// 9:   subject(:service) { described_class.new(formula) }
// 10:
// 11:   let(:formula) do
// 12:     instance_double(Formula,
// 13:                     name:                   "mysql",
// 14:                     plist_name:             "plist-mysql-test",
// 15:                     service_name:           "plist-mysql-test",
// 16:                     launchd_service_path:   Pathname.new("/usr/local/opt/mysql/homebrew.mysql.plist"),
// 17:                     systemd_service_path:   Pathname.new("/usr/local/opt/mysql/homebrew.mysql.service"),
// 18:                     systemd_timer_path:     Pathname.new("/usr/local/opt/mysql/homebrew.mysql.timer"),
// 19:                     opt_prefix:             Pathname.new("/usr/local/opt/mysql"),
// 20:                     any_version_installed?: true,
// 21:                     service?:               false)
// 22:   end
// 23:   let(:service_object) do
// 24:     instance_double(Homebrew::Service,
// 25:                     requires_root?: false,
// 26:                     timed?:         false,
// 27:                     keep_alive?:    false,
// 28:                     command:        "/bin/cmd",
// 29:                     manual_command: "/bin/cmd",
// 30:                     working_dir:    nil,
// 31:                     root_dir:       nil,
// 32:                     log_path:       nil,
// 33:                     error_log_path: nil,
// 34:                     interval:       nil,
// 35:                     cron:           nil)
// 36:   end
// 37:
// 38:   before do
// 39:     allow(formula).to receive(:service).and_return(service_object)
// 40:     ENV["HOME"] = "/tmp_home"
// 41:   end
// 42:
// 43:   describe "#service_file" do
// 44:     it "macOS - outputs the full service file path" do
// 45:       allow(Homebrew::Services::System).to receive(:launchctl?).and_return(true)
// 46:       expect(service.service_file.to_s).to eq("/usr/local/opt/mysql/homebrew.mysql.plist")
// 47:     end
// 48:
// 49:     it "systemD - outputs the full service file path" do
// 50:       allow(Homebrew::Services::System).to receive_messages(launchctl?: false, systemctl?: true)
// 51:       expect(service.service_file.to_s).to eq("/usr/local/opt/mysql/homebrew.mysql.service")
// 52:     end
// 53:
// 54:     it "Other - raises an error" do
// 55:       allow(Homebrew::Services::System).to receive_messages(launchctl?: false, systemctl?: false)
// 56:       expect do
// 57:         service.service_file
// 58:       end.to raise_error(UsageError,
// 59:                          "Invalid usage: `brew services` is supported only on macOS or Linux (with systemd)!")
// 60:     end
// 61:   end
// 62:
// 63:   describe "#name" do
// 64:     it "outputs formula name" do
// 65:       expect(service.name).to eq("mysql")
// 66:     end
// 67:   end
// 68:
// 69:   describe "#service_contents" do
// 70:     it "macOS - generates the plist from the formula service block" do
// 71:       allow(Homebrew::Services::System).to receive(:launchctl?).and_return(true)
// 72:       allow(service).to receive(:service?).and_return(true)
// 73:       allow(service_object).to receive_messages(command?: true, to_plist: "plist contents")
// 74:
// 75:       expect(service.service_contents).to eq("plist contents")
// 76:     end
// 77:
// 78:     it "systemD - generates the unit from the formula service block" do
// 79:       allow(Homebrew::Services::System).to receive_messages(launchctl?: false, systemctl?: true)
// 80:       allow(service).to receive(:service?).and_return(true)
// 81:       allow(service_object).to receive_messages(command?: true, to_systemd_unit: "unit contents")
// 82:
// 83:       expect(service.service_contents).to eq("unit contents")
// 84:     end
// 85:
// 86:     it "reads the package-provided service file when the service block has no command" do
// 87:       service_file = mktmpdir/"custom.name.plist"
// 88:       service_file.write("package plist")
// 89:       allow(service).to receive_messages(service?: true, service_file:)
// 90:       allow(service_object).to receive(:command?).and_return(false)
// 91:
// 92:       expect(service.service_contents).to eq("package plist")
// 93:     end
// 94:
// 95:     it "reads the package-provided service file when the formula has no service block" do
// 96:       service_file = mktmpdir/"custom.name.plist"
// 97:       service_file.write("package plist")
// 98:       allow(service).to receive(:service_file).and_return(service_file)
// 99:
// 100:       expect(service.service_contents).to eq("package plist")
// 101:     end
// 102:   end
// 103:
// 104:   describe "#service_name" do
// 105:     it "macOS - outputs the service name" do
// 106:       allow(Homebrew::Services::System).to receive(:launchctl?).and_return(true)
// 107:       expect(service.service_name).to eq("plist-mysql-test")
// 108:     end
// 109:
// 110:     it "systemD - outputs the service name" do
// 111:       allow(Homebrew::Services::System).to receive_messages(launchctl?: false, systemctl?: true)
// 112:       expect(service.service_name).to eq("plist-mysql-test")
// 113:     end
// 114:
// 115:     it "Other - raises an error" do
// 116:       allow(Homebrew::Services::System).to receive_messages(launchctl?: false, systemctl?: false)
// 117:       expect do
// 118:         service.service_name
// 119:       end.to raise_error(UsageError,
// 120:                          "Invalid usage: `brew services` is supported only on macOS or Linux (with systemd)!")
// 121:     end
// 122:   end
// 123:
// 124:   describe "#dest_dir" do
// 125:     before do
// 126:       allow(Homebrew::Services::System).to receive_messages(launchctl?: false, systemctl?: false)
// 127:     end
// 128:
// 129:     it "macOS - user - outputs the destination directory for the service file" do
// 130:       ENV["HOME"] = "/tmp_home"
// 131:       allow(Homebrew::Services::System).to receive_messages(root?: false, launchctl?: true)
// 132:       expect(service.dest_dir.to_s).to eq("/tmp_home/Library/LaunchAgents")
// 133:     end
// 134:
// 135:     it "macOS - root - outputs the destination directory for the service file" do
// 136:       allow(Homebrew::Services::System).to receive_messages(launchctl?: true, root?: true)
// 137:       expect(service.dest_dir.to_s).to eq("/Library/LaunchDaemons")
// 138:     end
// 139:
// 140:     it "systemD - user - outputs the destination directory for the service file" do
// 141:       ENV["HOME"] = "/tmp_home"
// 142:       allow(Homebrew::Services::System).to receive_messages(root?: false, launchctl?: false, systemctl?: true)
// 143:       expect(service.dest_dir.to_s).to eq("/tmp_home/.config/systemd/user")
// 144:     end
// 145:
// 146:     it "systemD - root - outputs the destination directory for the service file" do
// 147:       allow(Homebrew::Services::System).to receive_messages(root?: true, launchctl?: false, systemctl?: true)
// 148:       expect(service.dest_dir.to_s).to eq("/usr/lib/systemd/system")
// 149:     end
// 150:   end
// 151:
// 152:   describe "#dest" do
// 153:     before do
// 154:       ENV["HOME"] = "/tmp_home"
// 155:       allow(Homebrew::Services::System).to receive_messages(launchctl?: false, systemctl?: false)
// 156:     end
// 157:
// 158:     it "macOS - outputs the destination for the service file" do
// 159:       allow(Homebrew::Services::System).to receive(:launchctl?).and_return(true)
// 160:       expect(service.dest.to_s).to eq("/tmp_home/Library/LaunchAgents/homebrew.mysql.plist")
// 161:     end
// 162:
// 163:     it "systemD - outputs the destination for the service file" do
// 164:       allow(Homebrew::Services::System).to receive(:systemctl?).and_return(true)
// 165:       expect(service.dest.to_s).to eq("/tmp_home/.config/systemd/user/homebrew.mysql.service")
// 166:     end
// 167:   end
// 168:
// 169:   describe "#installed?" do
// 170:     it "outputs if the service formula is installed" do
// 171:       expect(service.installed?).to be(true)
// 172:     end
// 173:   end
// 174:
// 175:   describe "#loaded?" do
// 176:     it "macOS - outputs if the service is loaded" do
// 177:       allow(Homebrew::Services::System).to receive_messages(launchctl?: true, systemctl?: false)
// 178:       allow(Utils).to receive(:safe_popen_read)
// 179:       expect(service.loaded?).to be(false)
// 180:     end
// 181:
// 182:     it "systemD - outputs if the service is loaded" do
// 183:       allow(Homebrew::Services::System).to receive_messages(launchctl?: false, systemctl?: true)
// 184:       allow(Homebrew::Services::System::Systemctl).to receive(:quiet_run).and_return(false)
// 185:       allow(Utils).to receive(:safe_popen_read)
// 186:       expect(service.loaded?).to be(false)
// 187:     end
// 188:
// 189:     it "systemD - checks timer status for timed services" do
// 190:       allow(Homebrew::Services::System).to receive_messages(launchctl?: false, systemctl?: true)
// 191:       allow(service).to receive(:timed?).and_return(true)
// 192:       expect(Homebrew::Services::System::Systemctl).to receive(:quiet_run)
// 193:         .with("status", "homebrew.mysql.timer")
// 194:         .and_return(true)
// 195:
// 196:       expect(service.loaded?).to be(true)
// 197:     end
// 198:
// 199:     it "Other - raises an error" do
// 200:       allow(Homebrew::Services::System).to receive_messages(launchctl?: false, systemctl?: false)
// 201:       expect do
// 202:         service.loaded?
// 203:       end.to raise_error(UsageError,
// 204:                          "Invalid usage: `brew services` is supported only on macOS or Linux (with systemd)!")
// 205:     end
// 206:   end
// 207:
// 208:   describe "#owner" do
// 209:     it "reads the user from a launchd plist" do
// 210:       plist = mktmpdir/"homebrew.test.plist"
// 211:       plist.write <<~XML
// 212:         <?xml version="1.0" encoding="UTF-8"?>
// 213:         <plist version="1.0">
// 214:           <dict>
// 215:             <key>UserName</key>
// 216:             <string>_serviced</string>
// 217:           </dict>
// 218:         </plist>
// 219:       XML
// 220:       allow(Homebrew::Services::System).to receive(:launchctl?).and_return(true)
// 221:       allow(service).to receive(:dest).and_return(plist)
// 222:
// 223:       expect(service.owner).to eq("_serviced")
// 224:     end
// 225:
// 226:     it "root if file present" do
// 227:       allow(service).to receive(:boot_path_service_file_present?).and_return(true)
// 228:       expect(service.owner).to eq("root")
// 229:     end
// 230:
// 231:     it "user if file present" do
// 232:       allow(service).to receive_messages(boot_path_service_file_present?: false,
// 233:                                          user_path_service_file_present?: true)
// 234:       allow(Homebrew::Services::System).to receive(:user).and_return("user")
// 235:       expect(service.owner).to eq("user")
// 236:     end
// 237:
// 238:     it "nil if no file present" do
// 239:       allow(service).to receive_messages(boot_path_service_file_present?: false,
// 240:                                          user_path_service_file_present?: false)
// 241:       expect(service.owner).to be_nil
// 242:     end
// 243:   end
// 244:
// 245:   describe "#service_file_present?" do
// 246:     it "macOS - outputs if the service file is present" do
// 247:       allow(Homebrew::Services::System).to receive_messages(launchctl?: true, systemctl?: false)
// 248:       expect(service.service_file_present?).to be(false)
// 249:     end
// 250:
// 251:     it "macOS - outputs if the service file is present for root" do
// 252:       allow(Homebrew::Services::System).to receive_messages(launchctl?: true, systemctl?: false)
// 253:       expect(service.service_file_present?(type: :root)).to be(false)
// 254:     end
// 255:
// 256:     it "macOS - outputs if the service file is present for user" do
// 257:       allow(Homebrew::Services::System).to receive_messages(launchctl?: true, systemctl?: false)
// 258:       expect(service.service_file_present?(type: :user)).to be(false)
// 259:     end
// 260:   end
// 261:
// 262:   describe "#owner?" do
// 263:     it "macOS - outputs the service file owner" do
// 264:       allow(Homebrew::Services::System).to receive_messages(launchctl?: true, systemctl?: false)
// 265:       expect(service.owner).to be_nil
// 266:     end
// 267:   end
// 268:
// 269:   describe "#pid?" do
// 270:     it "outputs false because there is not PID" do
// 271:       allow(service).to receive(:pid).and_return(nil)
// 272:       expect(service.pid?).to be(false)
// 273:     end
// 274:
// 275:     it "outputs false because there is a PID and it is zero" do
// 276:       allow(service).to receive(:pid).and_return(0)
// 277:       expect(service.pid?).to be(false)
// 278:     end
// 279:
// 280:     it "outputs true because there is a PID and it is positive" do
// 281:       allow(service).to receive(:pid).and_return(12)
// 282:       expect(service.pid?).to be(true)
// 283:     end
// 284:
// 285:     # This should never happen in practice, as PIDs cannot be negative.
// 286:     it "outputs false because there is a PID and it is negative" do
// 287:       allow(service).to receive(:pid).and_return(-1)
// 288:       expect(service.pid?).to be(false)
// 289:     end
// 290:   end
// 291:
// 292:   describe "#pid", :needs_systemd do
// 293:     it "outputs nil because there is not pid" do
// 294:       expect(service.pid).to be_nil
// 295:     end
// 296:   end
// 297:
// 298:   describe "#error?" do
// 299:     it "outputs false because there is no PID or exit code" do
// 300:       allow(service).to receive_messages(pid: nil, exit_code: nil)
// 301:       expect(service.error?).to be(false)
// 302:     end
// 303:
// 304:     it "outputs false because there is a PID but no exit" do
// 305:       allow(service).to receive_messages(pid: 12, exit_code: nil)
// 306:       expect(service.error?).to be(false)
// 307:     end
// 308:
// 309:     it "outputs false because there is a PID and a zero exit code" do
// 310:       allow(service).to receive_messages(pid: 12, exit_code: 0)
// 311:       expect(service.error?).to be(false)
// 312:     end
// 313:
// 314:     it "outputs false because there is a PID and a positive exit code" do
// 315:       allow(service).to receive_messages(pid: 12, exit_code: 1)
// 316:       expect(service.error?).to be(false)
// 317:     end
// 318:
// 319:     it "outputs false because there is no PID and a zero exit code" do
// 320:       allow(service).to receive_messages(pid: nil, exit_code: 0)
// 321:       expect(service.error?).to be(false)
// 322:     end
// 323:
// 324:     it "outputs true because there is no PID and a positive exit code" do
// 325:       allow(service).to receive_messages(pid: nil, exit_code: 1)
// 326:       expect(service.error?).to be(true)
// 327:     end
// 328:
// 329:     # This should never happen in practice, as exit codes cannot be negative.
// 330:     it "outputs true because there is no PID and a negative exit code" do
// 331:       allow(service).to receive_messages(pid: nil, exit_code: -1)
// 332:       expect(service.error?).to be(true)
// 333:     end
// 334:   end
// 335:
// 336:   describe "#exit_code", :needs_systemd do
// 337:     it "outputs nil because there is no exit code" do
// 338:       expect(service.exit_code).to be_nil
// 339:     end
// 340:   end
// 341:
// 342:   describe "#unknown_status?", :needs_systemd do
// 343:     it "outputs true because there is no PID" do
// 344:       expect(service.unknown_status?).to be(true)
// 345:     end
// 346:   end
// 347:
// 348:   describe "#timed?" do
// 349:     it "returns true if timed service" do
// 350:       service_stub = instance_double(Homebrew::Service, timed?: true)
// 351:       allow(service).to receive_messages(service?: true, load_service: service_stub)
// 352:       allow(service_stub).to receive(:timed?).and_return(true)
// 353:
// 354:       expect(service.timed?).to be(true)
// 355:     end
// 356:
// 357:     it "returns false if no timed service" do
// 358:       service_stub = instance_double(Homebrew::Service, timed?: false)
// 359:
// 360:       allow(service).to receive(:service?).once.and_return(true)
// 361:       allow(service).to receive(:load_service).once.and_return(service_stub)
// 362:       allow(service_stub).to receive(:timed?).and_return(false)
// 363:
// 364:       expect(service.timed?).to be(false)
// 365:     end
// 366:
// 367:     it "returns false if no service" do
// 368:       allow(service).to receive(:service?).once.and_return(false)
// 369:
// 370:       expect(service.timed?).to be(false)
// 371:     end
// 372:   end
// 373:
// 374:   describe "#keep_alive?" do
// 375:     it "returns true if service needs to stay alive" do
// 376:       service_stub = instance_double(Homebrew::Service, keep_alive?: true)
// 377:
// 378:       allow(service).to receive(:service?).once.and_return(true)
// 379:       allow(service).to receive(:load_service).once.and_return(service_stub)
// 380:
// 381:       expect(service.keep_alive?).to be(true)
// 382:     end
// 383:
// 384:     it "returns false if service does not need to stay alive" do
// 385:       service_stub = instance_double(Homebrew::Service, keep_alive?: false)
// 386:
// 387:       allow(service).to receive(:service?).once.and_return(true)
// 388:       allow(service).to receive(:load_service).once.and_return(service_stub)
// 389:
// 390:       expect(service.keep_alive?).to be(false)
// 391:     end
// 392:
// 393:     it "returns false if no service" do
// 394:       allow(service).to receive(:service?).once.and_return(false)
// 395:
// 396:       expect(service.keep_alive?).to be(false)
// 397:     end
// 398:   end
// 399:
// 400:   describe "#service_startup?" do
// 401:     it "outputs false since there is no startup" do
// 402:       expect(service.service_startup?).to be(false)
// 403:     end
// 404:
// 405:     it "outputs true since there is a startup service" do
// 406:       allow(service).to receive(:service?).once.and_return(true)
// 407:       allow(service).to receive(:load_service).and_return(instance_double(Homebrew::Service, requires_root?: true))
// 408:
// 409:       expect(service.service_startup?).to be(true)
// 410:     end
// 411:   end
// 412:
// 413:   describe "#to_hash" do
// 414:     it "represents non-service values" do
// 415:       allow(Homebrew::Services::System).to receive_messages(launchctl?: true, systemctl?: false)
// 416:       allow_any_instance_of(described_class).to receive_messages(service?:              false,
// 417:                                                                  service_file_present?: false)
// 418:       expected = {
// 419:         exit_code:    nil,
// 420:         file:         Pathname.new("/usr/local/opt/mysql/homebrew.mysql.plist"),
// 421:         loaded:       false,
// 422:         loaded_file:  nil,
// 423:         name:         "mysql",
// 424:         pid:          nil,
// 425:         registered:   false,
// 426:         running:      false,
// 427:         schedulable:  false,
// 428:         service_name: "plist-mysql-test",
// 429:         status:       :none,
// 430:         user:         nil,
// 431:       }
// 432:       expect(service.to_hash).to eq(expected)
// 433:     end
// 434:
// 435:     it "represents running non-service values" do
// 436:       ENV["HOME"] = "/tmp_home"
// 437:       allow(Homebrew::Services::System).to receive_messages(launchctl?: true, systemctl?: false)
// 438:       expect(service).to receive(:service?).twice.and_return(false)
// 439:       expect(service).to receive(:service_file_present?).twice.and_return(true)
// 440:       expected = {
// 441:         exit_code:    nil,
// 442:         file:         Pathname.new("/tmp_home/Library/LaunchAgents/homebrew.mysql.plist"),
// 443:         loaded:       false,
// 444:         loaded_file:  nil,
// 445:         name:         "mysql",
// 446:         pid:          nil,
// 447:         registered:   true,
// 448:         running:      false,
// 449:         schedulable:  false,
// 450:         service_name: "plist-mysql-test",
// 451:         status:       :none,
// 452:         user:         nil,
// 453:       }
// 454:       expect(service.to_hash).to eq(expected)
// 455:     end
// 456:
// 457:     it "represents service values" do
// 458:       ENV["HOME"] = "/tmp_home"
// 459:       allow(Homebrew::Services::System).to receive_messages(launchctl?: true, systemctl?: false)
// 460:       expect(service).to receive(:service?).twice.and_return(true)
// 461:       expect(service).to receive(:service_file_present?).twice.and_return(true)
// 462:       expect(service).to receive(:load_service).twice.and_return(service_object)
// 463:       expected = {
// 464:         command:        "/bin/cmd",
// 465:         cron:           nil,
// 466:         error_log_path: nil,
// 467:         exit_code:      nil,
// 468:         file:           Pathname.new("/tmp_home/Library/LaunchAgents/homebrew.mysql.plist"),
// 469:         interval:       nil,
// 470:         loaded:         false,
// 471:         loaded_file:    nil,
// 472:         log_path:       nil,
// 473:         name:           "mysql",
// 474:         pid:            nil,
// 475:         registered:     true,
// 476:         root_dir:       nil,
// 477:         running:        false,
// 478:         schedulable:    false,
// 479:         service_name:   "plist-mysql-test",
// 480:         status:         :none,
// 481:         user:           nil,
// 482:         working_dir:    nil,
// 483:       }
// 484:       expect(service.to_hash).to eq(expected)
// 485:     end
// 486:   end
// 487: end
