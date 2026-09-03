module homebrew

import os
import strconv

pub enum ServiceOS {
	macos
	linux
}

pub enum ServiceRunType {
	immediate
	interval
	cron
}

pub enum ServiceProcessType {
	background
	standard
	interactive
	adaptive
}

pub enum ServiceRunValueKind {
	none
	scalar
	array
}

pub struct ServiceRunValue {
pub:
	kind   ServiceRunValueKind
	values []string
}

pub struct ServiceRunParams {
pub:
	direct      ServiceRunValue
	macos       ServiceRunValue
	linux       ServiceRunValue
	conditional bool
}

pub struct ServiceFormulaPaths {
pub:
	name         string
	prefix       string
	cellar       string
	home         string
	bin          string
	etc          string
	libexec      string
	opt_bin      string
	opt_libexec  string
	opt_pkgshare string
	opt_prefix   string
	opt_sbin     string
	var          string
}

pub fn new_service_formula_paths(name string, prefix string, cellar string,
	home string) ServiceFormulaPaths {
	opt_prefix := os.join_path(prefix, 'opt', name)
	return ServiceFormulaPaths{
		name: name
		prefix: prefix
		cellar: cellar
		home: home
		bin: os.join_path(cellar, name, '1.0', 'bin')
		etc: os.join_path(prefix, 'etc')
		libexec: os.join_path(cellar, name, '1.0', 'libexec')
		opt_bin: os.join_path(opt_prefix, 'bin')
		opt_libexec: os.join_path(opt_prefix, 'libexec')
		opt_pkgshare: os.join_path(opt_prefix, 'share', name)
		opt_prefix: opt_prefix
		opt_sbin: os.join_path(opt_prefix, 'sbin')
		var: os.join_path(prefix, 'var')
	}
}

pub struct ServiceKeepAlive {
pub:
	has_always          bool
	always              bool
	has_successful_exit bool
	successful_exit     bool
	has_crashed         bool
	crashed             bool
	path                string
}

pub struct ServiceKeepAliveInput {
pub:
	set          bool
	boolean      ?bool
	value        ServiceKeepAlive
	invalid_keys []string
}

pub struct ServiceSocket {
pub:
	host     string
	port     string
	protocol string
}

pub struct ServiceSocketsInput {
pub:
	set    bool
	scalar ServiceStringValue
	values map[string]string
}

pub struct ServiceEnvironment {
pub:
	values map[string]string
	order  []string
}

pub struct ServiceEnvironmentResult {
pub:
	environment ServiceEnvironment
	warnings    []string
}

pub struct ServiceStringValue {
pub:
	present bool
	value   string
}

pub struct ServiceIntValue {
pub:
	present bool
	value   int
}

pub struct ServiceEnumInput {
pub:
	set   bool
	value string
}

pub struct ServiceNameInput {
pub:
	macos ?string
	linux ?string
}

pub struct ServiceHash {
pub:
	has_name                  bool
	name                      map[string]string
	has_run                   bool
	run                       ServiceRunParams
	has_run_type              bool
	run_type                  string
	has_interval              bool
	interval                  int
	cron                      string
	has_keep_alive            bool
	keep_alive                ServiceKeepAlive
	has_launch_only_once      bool
	launch_only_once          bool
	has_require_root          bool
	require_root              bool
	has_environment_variables bool
	environment_variables     ServiceEnvironment
	working_dir               string
	root_dir                  string
	input_path                string
	log_path                  string
	error_log_path            string
	has_restart_delay         bool
	restart_delay             int
	has_throttle_interval     bool
	throttle_interval         int
	has_stop_timeout          bool
	stop_timeout              int
	has_nice                  bool
	nice                      int
	process_type              string
	has_macos_legacy_timers   bool
	macos_legacy_timers       bool
	has_sockets               bool
	sockets                   map[string]string
	sockets_scalar            bool
	invalid_run               bool
}

pub struct BrewService {
pub:
	formula ServiceFormulaPaths
pub mut:
	plist_name            string
	service_name          string
	cron                  map[string]string
	environment_variables ServiceEnvironment
	error_log_path        ?string
	input_path            ?string
	interval              ?int
	keep_alive            ServiceKeepAlive
	launch_only_once      bool
	log_path              ?string
	macos_legacy_timers   bool
	nice                  ?int
	process_type          ?ServiceProcessType
	require_root          bool
	restart_delay         ?int
	throttle_interval     ?int
	root_dir              ?string
	run                   []string
	run_at_load           bool
	run_params            ServiceRunParams
	run_type              ServiceRunType
	sockets               map[string]ServiceSocket
	stop_timeout          ?int
	working_dir           ?string
}

pub fn new_brew_service(formula ServiceFormulaPaths) !BrewService {
	service := BrewService{
		formula: formula
		plist_name: 'homebrew.mxcl.${formula.name}'
		service_name: 'homebrew.${formula.name}'
		cron: map[string]string{}
		environment_variables: ServiceEnvironment{
			values: map[string]string{}
		}
		run_at_load: true
		run_type: .immediate
		sockets: map[string]ServiceSocket{}
	}
	service_validate(service)!
	return service
}

pub fn service_validate(service &BrewService) ! {
	if service_nice_requires_root(service) {
		return error('Service#nice: require_root true is required for negative nice values')
	}
}

pub fn service_nice_requires_root(service &BrewService) bool {
	nice := service.nice or { return false }
	return nice < 0 && !service.require_root
}

fn service_run_value(values []string, scalar bool) ServiceRunValue {
	return ServiceRunValue{
		kind: if scalar { .scalar } else { .array }
		values: values.clone()
	}
}

pub fn service_set_run(mut service BrewService, direct ServiceRunValue, macos ServiceRunValue,
	linux ServiceRunValue, system ServiceOS) []string {
	if direct.kind != .none {
		service.run_params = ServiceRunParams{ direct: direct }
	} else if macos.kind != .none || linux.kind != .none {
		service.run_params = ServiceRunParams{
			macos: macos
			linux: linux
			conditional: true
		}
	} else {
		return service.run.clone()
	}
	selected := if direct.kind != .none {
		direct
	} else if system == .macos {
		macos
	} else {
		linux
	}
	service.run = if selected.kind == .none { [] } else { selected.values.clone() }
	return service.run.clone()
}

fn service_expand_path(path string, home string) string {
	if path == '~' {
		return home
	}
	if path.starts_with('~/') {
		return os.join_path(home, path[2..])
	}
	return path
}

pub fn service_command(service &BrewService) []string {
	return service.run.map(service_expand_path(it, service.formula.home))
}

pub fn service_keep_alive(mut service BrewService, input ServiceKeepAliveInput) !ServiceKeepAlive {
	if !input.set {
		return service.keep_alive
	}
	if input.invalid_keys.len > 0 {
		return error('Service#keep_alive only allows: [:always, :successful_exit, :crashed, :path]')
	}
	if boolean := input.boolean {
		service.keep_alive = ServiceKeepAlive{ has_always: true, always: boolean }
	} else {
		service.keep_alive = input.value
	}
	return service.keep_alive
}

pub fn service_keep_alive_enabled(service &BrewService) bool {
	keep_alive := service.keep_alive
	has_value := keep_alive.has_always || keep_alive.has_successful_exit || keep_alive.has_crashed || keep_alive.path != ''
	return has_value && !(keep_alive.has_always && !keep_alive.always)
}

fn service_valid_ipv4(host string) bool {
	parts := host.split('.')
	if parts.len != 4 {
		return false
	}
	for part in parts {
		if part == '' || !part.bytes().all(it >= `0` && it <= `9`) {
			return false
		}
		value := strconv.atoi(part) or { return false }
		if value < 0 || value > 255 {
			return false
		}
	}
	return true
}

fn service_valid_ipv6_piece(piece string) bool {
	return piece.len >= 1 && piece.len <= 4 && piece.bytes().all((it >= `0` && it <= `9`) || (it >= `a` && it <= `f`) || (it >= `A` && it <= `F`))
}

fn service_valid_ipv6(host string) bool {
	if !host.contains(':') || host.count('::') > 1 {
		return false
	}
	compressed := host.contains('::')
	parts := host.split(':')
	mut groups := 0
	for index, part in parts {
		if part == '' {
			if !compressed && index != 0 && index != parts.len - 1 {
				return false
			}
			continue
		}
		if part.contains('.') {
			if index != parts.len - 1 || !service_valid_ipv4(part) {
				return false
			}
			groups += 2
		} else if service_valid_ipv6_piece(part) {
			groups++
		} else {
			return false
		}
	}
	return if compressed { groups < 8 } else { groups == 8 }
}

fn service_valid_ip(host string) bool {
	return service_valid_ipv4(host) || service_valid_ipv6(host)
}

pub fn service_sockets(mut service BrewService, input ServiceSocketsInput) !map[string]ServiceSocket {
	if !input.set {
		return service.sockets.clone()
	}
	values := if input.scalar.present {
		{
			'listeners': input.scalar.value
		}
	} else {
		input.values
	}
	mut parsed := map[string]ServiceSocket{}
	for name, socket_string in values {
		scheme_index := socket_string.index('://') or {
			return error('Service#sockets a formatted socket definition as <type>://<host>:<port>')
		}
		protocol := socket_string[..scheme_index]
		address := socket_string[scheme_index + 3..]
		colon := address.last_index(':') or {
			return error('Service#sockets a formatted socket definition as <type>://<host>:<port>')
		}
		host := address[..colon]
		port := address[colon + 1..]
		if protocol == '' || !protocol.bytes().all((it >= `a` && it <= `z`) || (it >= `A` && it <= `Z`)) || host == '' || port == '' || !port.bytes().all(it >= `0` && it <= `9`) {
			return error('Service#sockets a formatted socket definition as <type>://<host>:<port>')
		}
		if !service_valid_ip(host) {
			return error('Service#sockets expects a valid ipv4 or ipv6 host address')
		}
		parsed[name] = ServiceSocket{ host: host, port: port, protocol: protocol }
	}
	service.sockets = parsed.clone()
	return parsed
}

pub fn service_default_cron_values() map[string]string {
	return {
		'Month':   '*'
		'Day':     '*'
		'Weekday': '*'
		'Hour':    '*'
		'Minute':  '*'
	}
}

pub fn service_parse_cron(statement string) !map[string]string {
	mut parsed := service_default_cron_values()
	match statement {
		'@hourly' {
			parsed['Minute'] = '0'
		}
		'@daily' {
			parsed['Minute'] = '0'
			parsed['Hour'] = '0'
		}
		'@weekly' {
			parsed['Minute'] = '0'
			parsed['Hour'] = '0'
			parsed['Weekday'] = '0'
		}
		'@monthly' {
			parsed['Minute'] = '0'
			parsed['Hour'] = '0'
			parsed['Day'] = '1'
		}
		'@yearly', '@annually' {
			parsed['Minute'] = '0'
			parsed['Hour'] = '0'
			parsed['Day'] = '1'
			parsed['Month'] = '1'
		}
		else {
			parts := statement.fields()
			if parts.len != 5 {
				return error('Service#parse_cron expects a valid cron syntax')
			}
			for index, selector in ['Minute', 'Hour', 'Day', 'Month', 'Weekday'] {
				if parts[index] != '*' {
					parsed[selector] = strconv.atoi(parts[index])!.str()
				}
			}
		}
	}
	return parsed
}

pub fn service_effective_environment_variables(service &BrewService,
	user_config_home string, effective_uid int) ServiceEnvironmentResult {
	mut values := service.environment_variables.values.clone()
	mut order := service.environment_variables.order.clone()
	mut warnings := []string{}
	env_file := os.join_path(user_config_home, 'services', '${service.formula.name}.env')
	if !os.is_file(env_file) {
		return ServiceEnvironmentResult{ environment: ServiceEnvironment{ values: values, order: order } }
	}
	if effective_uid == 0 {
		warnings << 'Skipping ${env_file}: user env overrides are not supported for root services.'
		return ServiceEnvironmentResult{ environment: ServiceEnvironment{ values: values, order: order }, warnings: warnings }
	}
	mode := int(os.stat(env_file) or {
		return ServiceEnvironmentResult{ environment: ServiceEnvironment{ values: values, order: order } }
	}.get_mode().bitmask())
	if mode & 0o002 != 0 {
		warnings << 'Skipping ${env_file}: file is world-writable.'
		return ServiceEnvironmentResult{ environment: ServiceEnvironment{ values: values, order: order }, warnings: warnings }
	}
	if mode & 0o020 != 0 {
		warnings << 'Skipping ${env_file}: file is group-writable.'
		return ServiceEnvironmentResult{ environment: ServiceEnvironment{ values: values, order: order }, warnings: warnings }
	}
	contents := os.read_file(env_file) or { '' }
	for raw_line in contents.split_into_lines() {
		line := raw_line.trim_space()
		if line == '' || line.starts_with('#') {
			continue
		}
		equals := line.index('=') or {
			warnings << 'Skipping invalid line in ${env_file}: ${line}'
			continue
		}
		key := line[..equals].trim_space()
		if key == '' {
			warnings << 'Skipping invalid line in ${env_file}: ${line}'
			continue
		}
		if key !in values {
			order << key
		}
		values[key] = line[equals + 1..].trim_space()
	}
	return ServiceEnvironmentResult{
		environment: ServiceEnvironment{ values: values, order: order }
		warnings: warnings
	}
}

fn service_shell_quote(value string) string {
	if value == '' {
		return "''"
	}
	mut quoted := ''
	for character in value.runes() {
		if (character >= `A` && character <= `Z`) || (character >= `a` && character <= `z`) || (character >= `0` && character <= `9`) || character in [
			`_`,
			`-`,
			`.`,
			`,`,
			`:`,
			`/`,
			`@`,
			`~`,
			`+`,
		] {
			quoted += character.str()
		} else if character == `\n` {
			quoted += "'\n'"
		} else {
			quoted += '\\${character.str()}'
		}
	}
	return quoted
}

pub fn service_manual_command(service &BrewService, user_config_home string,
	effective_uid int) string {
	effective := service_effective_environment_variables(service, user_config_home, effective_uid)
	mut command := []string{}
	for key in effective.environment.order {
		if key != 'PATH' {
			command << '${key}="${effective.environment.values[key]}"'
		}
	}
	command << service_command(service).map(service_shell_quote(it))
	return command.join(' ')
}

pub fn service_path_dir(path ?string, home string) ?string {
	value := path or { return none }
	if value == '' || (!value.starts_with('/') && !value.starts_with('~')) {
		return none
	}
	return os.norm_path(service_expand_path(value, home))
}

pub fn service_path_parent_dir(path ?string, home string) ?string {
	value := service_path_dir(path, home) or { return none }
	return os.dir(value)
}

pub fn service_path_dirs(service &BrewService) []string {
	mut paths := []string{}
	for candidate in [service_path_dir(service.working_dir, service.formula.home),
		service_path_dir(service.root_dir, service.formula.home),
		service_path_parent_dir(service.input_path, service.formula.home),
		service_path_parent_dir(service.log_path, service.formula.home),
		service_path_parent_dir(service.error_log_path, service.formula.home)] {
		if value := candidate {
			if value !in paths {
				paths << value
			}
		}
	}
	return paths
}

fn service_xml_escape(value string) string {
	return value.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
}

fn service_plist_key(key string) string {
	return '\t<key>${key}</key>\n'
}

fn service_plist_string(key string, value string) string {
	return '${service_plist_key(key)}\t<string>${service_xml_escape(value)}</string>\n'
}

fn service_plist_integer(key string, value int) string {
	return '${service_plist_key(key)}\t<integer>${value}</integer>\n'
}

fn service_plist_boolean(key string, value bool) string {
	return '${service_plist_key(key)}\t<${if value { 'true' } else { 'false' }}/>' + '\n'
}

fn service_plist_string_array(key string, values []string) string {
	mut output := '${service_plist_key(key)}\t<array>\n'
	for value in values {
		output += '\t\t<string>${service_xml_escape(value)}</string>\n'
	}
	return output + '\t</array>\n'
}

fn service_plist_environment(environment ServiceEnvironment) string {
	mut keys := environment.values.keys()
	keys.sort()
	mut output := '${service_plist_key('EnvironmentVariables')}\t<dict>\n'
	for key in keys {
		output += '\t\t<key>${service_xml_escape(key)}</key>\n'
		output += '\t\t<string>${service_xml_escape(environment.values[key])}</string>\n'
	}
	return output + '\t</dict>\n'
}

fn service_plist_keep_alive(keep_alive ServiceKeepAlive) string {
	if keep_alive.has_always && keep_alive.always {
		return service_plist_boolean('KeepAlive', true)
	}
	mut key := ''
	mut boolean := false
	mut path := ''
	if keep_alive.has_successful_exit {
		key = 'SuccessfulExit'
		boolean = keep_alive.successful_exit
	} else if keep_alive.has_crashed {
		key = 'Crashed'
		boolean = keep_alive.crashed
	} else if keep_alive.path != '' {
		key = 'PathState'
		path = keep_alive.path
	}
	if key == '' {
		return ''
	}
	mut output := '${service_plist_key('KeepAlive')}\t<dict>\n\t\t<key>${key}</key>\n'
	if path != '' {
		output += '\t\t<string>${service_xml_escape(path)}</string>\n'
	} else {
		output += '\t\t<${if boolean { 'true' } else { 'false' }}/>\n'
	}
	return output + '\t</dict>\n'
}

fn service_plist_sockets(sockets map[string]ServiceSocket) string {
	mut names := sockets.keys()
	names.sort()
	mut output := '${service_plist_key('Sockets')}\t<dict>\n'
	for name in names {
		socket := sockets[name]
		output += '\t\t<key>${service_xml_escape(name)}</key>\n\t\t<dict>\n'
		output += '\t\t\t<key>SockNodeName</key>\n\t\t\t<string>${service_xml_escape(socket.host)}</string>\n'
		output += '\t\t\t<key>SockProtocol</key>\n\t\t\t<string>${service_xml_escape(socket.protocol.to_upper())}</string>\n'
		output += '\t\t\t<key>SockServiceName</key>\n\t\t\t<string>${service_xml_escape(socket.port)}</string>\n'
		output += '\t\t</dict>\n'
	}
	return output + '\t</dict>\n'
}

fn service_plist_cron(cron map[string]string) string {
	mut keys := cron.keys().filter(cron[it] != '*')
	keys.sort()
	mut output := '${service_plist_key('StartCalendarInterval')}\t<dict>\n'
	for key in keys {
		output += '\t\t<key>${key}</key>\n\t\t<integer>${cron[key]}</integer>\n'
	}
	return output + '\t</dict>\n'
}

pub fn service_to_plist(service &BrewService, user_config_home string,
	effective_uid int) string {
	effective := service_effective_environment_variables(service, user_config_home, effective_uid)
	mut body := ''
	if effective.environment.values.len > 0 {
		body += service_plist_environment(effective.environment)
	}
	if value := service.stop_timeout {
		body += service_plist_integer('ExitTimeOut', value)
	}
	if service_keep_alive_enabled(service) {
		body += service_plist_keep_alive(service.keep_alive)
	}
	body += service_plist_string('Label', service.plist_name)
	if service.launch_only_once {
		body += service_plist_boolean('LaunchOnlyOnce', true)
	}
	if service.macos_legacy_timers {
		body += service_plist_boolean('LegacyTimers', true)
	}
	body += service_plist_string_array('LimitLoadToSessionType', ['Aqua', 'Background', 'LoginWindow',
		'StandardIO', 'System'])
	if value := service.nice {
		body += service_plist_integer('Nice', value)
	}
	if process_type := service.process_type {
		name := process_type.str()
		body += service_plist_string('ProcessType', name[..1].to_upper() + name[1..])
	}
	body += service_plist_string_array('ProgramArguments', service_command(service))
	if value := service.root_dir {
		body += service_plist_string('RootDirectory', service_expand_path(value, service.formula.home))
	}
	body += service_plist_boolean('RunAtLoad', service.run_at_load)
	if service.sockets.len > 0 {
		body += service_plist_sockets(service.sockets)
	}
	if value := service.error_log_path {
		body += service_plist_string('StandardErrorPath', service_expand_path(value, service.formula.home))
	}
	if value := service.input_path {
		body += service_plist_string('StandardInPath', service_expand_path(value, service.formula.home))
	}
	if value := service.log_path {
		body += service_plist_string('StandardOutPath', service_expand_path(value, service.formula.home))
	}
	if service.cron.len > 0 && service.run_type == .cron {
		body += service_plist_cron(service.cron)
	}
	if value := service.interval {
		if service.run_type == .interval {
			body += service_plist_integer('StartInterval', value)
		}
	}
	if value := service.throttle_interval {
		body += service_plist_integer('ThrottleInterval', value)
	}
	if value := service.restart_delay {
		body += service_plist_integer('TimeOut', value)
	}
	if value := service.working_dir {
		body += service_plist_string('WorkingDirectory', service_expand_path(value, service.formula.home))
	}
	return '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n<plist version="1.0">\n<dict>\n${body}</dict>\n</plist>\n'
}

fn service_systemd_quote(value string) string {
	mut result := '"'
	for character in value.runes() {
		result += match character {
			`\a` { '\\a' }
			`\b` { '\\b' }
			`\f` { '\\f' }
			`\n` { '\\n' }
			`\r` { '\\r' }
			`\t` { '\\t' }
			`\v` { '\\v' }
			`\\` { '\\\\' }
			`"` { '\\"' }
			else { character.str() }
		}
	}
	return result + '"'
}

pub fn service_to_systemd_unit(service &BrewService, user_config_home string,
	effective_uid int) string {
	command := service_command(service).map(service_systemd_quote(it)).join(' ')
	mut options := []string{}
	options << 'Type=${if service.launch_only_once { 'oneshot' } else { 'simple' }}'
	options << 'ExecStart=${command}'
	keep_alive := service.keep_alive
	if (keep_alive.has_always && keep_alive.always) || (keep_alive.has_crashed && keep_alive.crashed) {
		options << 'Restart=on-failure'
	} else if keep_alive.has_successful_exit && keep_alive.successful_exit {
		options << 'Restart=on-success'
	}
	if value := service.restart_delay {
		options << 'RestartSec=${value}'
	}
	if value := service.stop_timeout {
		options << 'TimeoutStopSec=${value}'
	}
	if value := service.nice {
		options << 'Nice=${value}'
	}
	if value := service.working_dir {
		options << 'WorkingDirectory=${service_expand_path(value, service.formula.home)}'
	}
	if value := service.root_dir {
		options << 'RootDirectory=${service_expand_path(value, service.formula.home)}'
	}
	if value := service.input_path {
		options << 'StandardInput=file:${service_expand_path(value, service.formula.home)}'
	}
	if value := service.log_path {
		options << 'StandardOutput=append:${service_expand_path(value, service.formula.home)}'
	}
	if value := service.error_log_path {
		options << 'StandardError=append:${service_expand_path(value, service.formula.home)}'
	}
	effective := service_effective_environment_variables(service, user_config_home, effective_uid)
	for key in effective.environment.order {
		options << 'Environment="${key}=${effective.environment.values[key]}"'
	}
	return '[Unit]\nDescription=Homebrew generated unit for ${service.formula.name}\n\n[Install]\nWantedBy=default.target\n\n[Service]\n${options.join('\n')}\n'
}

pub fn service_cron_weekday_to_systemd_weekday(cron_weekday string) string {
	if cron_weekday == '*' {
		return ''
	}
	weekday := strconv.atoi(cron_weekday) or { 0 }
	if weekday < 0 || weekday > 7 {
		return ''
	}
	return ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][weekday % 7] + ' '
}

fn service_two_digit(value string) string {
	number := value.int().str()
	return if number.len < 2 { '0${number}' } else { number }
}

pub fn service_to_systemd_timer(service &BrewService) string {
	mut options := []string{}
	if service.run_type == .cron {
		options << 'Persistent=true'
	}
	if service.run_type == .interval {
		if interval := service.interval {
			options << 'OnUnitActiveSec=${interval}'
		}
	}
	if service.run_type == .cron {
		minutes_value := service.cron['Minute'] or { '*' }
		hours_value := service.cron['Hour'] or { '*' }
		minutes := if minutes_value == '*' { '*' } else { service_two_digit(minutes_value) }
		hours := if hours_value == '*' { '*' } else { service_two_digit(hours_value) }
		weekday := service.cron['Weekday'] or { '*' }
		month := service.cron['Month'] or { '*' }
		day := service.cron['Day'] or { '*' }
		options << 'OnCalendar=${service_cron_weekday_to_systemd_weekday(weekday)}*-${month}-${day} ${hours}:${minutes}:00'
	}
	return '[Unit]\nDescription=Homebrew generated timer for ${service.formula.name}\n\n[Install]\nWantedBy=timers.target\n\n[Timer]\nUnit=${service.service_name}.service\n${options.join('\n')}\n'
}

fn service_run_value_replace(value ServiceRunValue, prefix string, cellar string,
	home string) ServiceRunValue {
	return ServiceRunValue{
		kind: value.kind
		values: value.values.map(service_replace_placeholders(it, prefix, cellar, home))
	}
}

pub fn service_to_hash(service &BrewService) ServiceHash {
	mut names := map[string]string{}
	if service.plist_name != 'homebrew.mxcl.${service.formula.name}' {
		names['macos'] = service.plist_name
	}
	if service.service_name != 'homebrew.${service.formula.name}' {
		names['linux'] = service.service_name
	}
	if service.run_params.direct.kind == .none && !service.run_params.conditional {
		return ServiceHash{ has_name: names.len > 0, name: names }
	}
	mut cron_string := ''
	if service.cron.len > 0 {
		cron_string = ['Minute', 'Hour', 'Day', 'Month', 'Weekday'].map(service.cron[it] or { '' }).filter(it != '').join(' ')
	}
	mut sockets := map[string]string{}
	for name, socket in service.sockets {
		sockets[name] = '${socket.protocol}://${socket.host}:${socket.port}'
	}
	keep_alive := service.keep_alive
	has_keep_alive := keep_alive.has_always || keep_alive.has_successful_exit || keep_alive.has_crashed || keep_alive.path != ''
	return ServiceHash{
		has_name: names.len > 0
		name: names
		has_run: true
		run: service.run_params
		has_run_type: true
		run_type: service.run_type.str()
		has_interval: service.interval != none
		interval: service.interval or { 0 }
		cron: cron_string
		has_keep_alive: has_keep_alive
		keep_alive: keep_alive
		has_launch_only_once: service.launch_only_once
		launch_only_once: service.launch_only_once
		has_require_root: service.require_root
		require_root: service.require_root
		has_environment_variables: service.environment_variables.values.len > 0
		environment_variables: service.environment_variables
		working_dir: service.working_dir or { '' }
		root_dir: service.root_dir or { '' }
		input_path: service.input_path or { '' }
		log_path: service.log_path or { '' }
		error_log_path: service.error_log_path or { '' }
		has_restart_delay: service.restart_delay != none
		restart_delay: service.restart_delay or { 0 }
		has_throttle_interval: service.throttle_interval != none
		throttle_interval: service.throttle_interval or { 0 }
		has_stop_timeout: service.stop_timeout != none
		stop_timeout: service.stop_timeout or { 0 }
		has_nice: service.nice != none
		nice: service.nice or { 0 }
		process_type: if process_type := service.process_type { process_type.str() } else { '' }
		has_macos_legacy_timers: service.macos_legacy_timers
		macos_legacy_timers: service.macos_legacy_timers
		has_sockets: sockets.len > 0
		sockets: sockets
		sockets_scalar: sockets.len == 1 && 'listeners' in sockets
	}
}

pub fn service_replace_placeholders(value string, prefix string, cellar string,
	home string) string {
	return value.replace('\$HOMEBREW_PREFIX', prefix).replace('\$HOMEBREW_CELLAR', cellar).replace('/\$HOME', home)
}

pub fn service_from_hash(api_hash ServiceHash, prefix string, cellar string,
	home string) !ServiceHash {
	if api_hash.invalid_run {
		return error('Unexpected run command')
	}
	if !api_hash.has_run {
		return ServiceHash{ has_name: api_hash.has_name, name: api_hash.name.clone() }
	}
	mut environment_values := map[string]string{}
	for key, value in api_hash.environment_variables.values {
		environment_values[key] = service_replace_placeholders(value, prefix, cellar, home)
	}
	return ServiceHash{
		...api_hash
		name: api_hash.name.clone()
		run: ServiceRunParams{
			direct: service_run_value_replace(api_hash.run.direct, prefix, cellar, home)
			macos: service_run_value_replace(api_hash.run.macos, prefix, cellar, home)
			linux: service_run_value_replace(api_hash.run.linux, prefix, cellar, home)
			conditional: api_hash.run.conditional
		}
		environment_variables: ServiceEnvironment{
			values: environment_values
			order: api_hash.environment_variables.order.clone()
		}
		working_dir: service_replace_placeholders(api_hash.working_dir, prefix, cellar, home)
		root_dir: service_replace_placeholders(api_hash.root_dir, prefix, cellar, home)
		input_path: service_replace_placeholders(api_hash.input_path, prefix, cellar, home)
		log_path: service_replace_placeholders(api_hash.log_path, prefix, cellar, home)
		error_log_path: service_replace_placeholders(api_hash.error_log_path, prefix, cellar, home)
		sockets: api_hash.sockets.clone()
	}
}

// Translated from Homebrew/brew `service.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :plist_name, :service_name` at line 36.
pub fn ruby_service_l36_d1_plist_name(service &BrewService) string {
	return service.plist_name
}

// Ruby attr_reader `attr_reader :plist_name, :service_name` at line 36.
pub fn ruby_service_l36_d2_service_name(service &BrewService) string {
	return service.service_name
}

// Ruby method `initialize(formula, &block)` at line 39.
pub fn ruby_service_l39_d3_initialize(formula ServiceFormulaPaths) !BrewService {
	return new_brew_service(formula)
}

// Ruby method `nice_requires_root?` at line 71.
pub fn ruby_service_l71_d4_nice_requires_root(service &BrewService) bool {
	return service_nice_requires_root(service)
}

// Ruby method `f` at line 76.
pub fn ruby_service_l76_d5_f(service &BrewService) ServiceFormulaPaths {
	return service.formula
}

// Ruby method `default_plist_name` at line 81.
pub fn ruby_service_l81_d6_default_plist_name(service &BrewService) string {
	return 'homebrew.mxcl.${service.formula.name}'
}

// Ruby method `default_service_name` at line 86.
pub fn ruby_service_l86_d7_default_service_name(service &BrewService) string {
	return 'homebrew.${service.formula.name}'
}

// Ruby method `name(macos: nil, linux: nil)` at line 96.
pub fn ruby_service_l96_d8_name(mut service BrewService, input ServiceNameInput) ! {
	macos := input.macos
	linux := input.linux
	if macos == none && linux == none {
		return error('Service#name expects at least one String')
	}
	if value := macos {
		service.plist_name = value
	}
	if value := linux {
		service.service_name = value
	}
}

// Ruby method `run(command = nil, macos: nil, linux: nil)` at line 113.
pub fn ruby_service_l113_d9_run(mut service BrewService, params ServiceRunParams,
	system ServiceOS) []string {
	return service_set_run(mut service, params.direct, params.macos, params.linux, system)
}

// Ruby method `working_dir(path = T.unsafe(nil))` at line 136.
pub fn ruby_service_l136_d10_working_dir(mut service BrewService, path ?string) ?string {
	if value := path {
		service.working_dir = value
	}
	return service.working_dir
}

// Ruby method `root_dir(path = T.unsafe(nil))` at line 148.
pub fn ruby_service_l148_d11_root_dir(mut service BrewService, path ?string) ?string {
	if value := path {
		service.root_dir = value
	}
	return service.root_dir
}

// Ruby method `input_path(path = T.unsafe(nil))` at line 160.
pub fn ruby_service_l160_d12_input_path(mut service BrewService, path ?string) ?string {
	if value := path {
		service.input_path = value
	}
	return service.input_path
}

// Ruby method `log_path(path = T.unsafe(nil))` at line 172.
pub fn ruby_service_l172_d13_log_path(mut service BrewService, path ?string) ?string {
	if value := path {
		service.log_path = value
	}
	return service.log_path
}

// Ruby method `error_log_path(path = T.unsafe(nil))` at line 184.
pub fn ruby_service_l184_d14_error_log_path(mut service BrewService, path ?string) ?string {
	if value := path {
		service.error_log_path = value
	}
	return service.error_log_path
}

// Ruby method `keep_alive(value = T.unsafe(nil))` at line 199.
pub fn ruby_service_l199_d15_keep_alive(mut service BrewService,
	input ServiceKeepAliveInput) !ServiceKeepAlive {
	return service_keep_alive(mut service, input)
}

// Ruby method `require_root(value = T.unsafe(nil))` at line 219.
pub fn ruby_service_l219_d16_require_root(mut service BrewService, value ?bool) bool {
	if update := value {
		service.require_root = update
	}
	return service.require_root
}

// Ruby method `requires_root?` at line 229.
pub fn ruby_service_l229_d17_requires_root(service &BrewService) bool {
	return service.require_root
}

// Ruby method `run_at_load(value = T.unsafe(nil))` at line 237.
pub fn ruby_service_l237_d18_run_at_load(mut service BrewService, value ?bool) bool {
	if update := value {
		service.run_at_load = update
	}
	return service.run_at_load
}

// Ruby method `sockets(value = T.unsafe(nil))` at line 252.
pub fn ruby_service_l252_d19_sockets(mut service BrewService,
	input ServiceSocketsInput) !map[string]ServiceSocket {
	return service_sockets(mut service, input)
}

// Ruby method `keep_alive?` at line 278.
pub fn ruby_service_l278_d20_keep_alive(service &BrewService) bool {
	return service_keep_alive_enabled(service)
}

// Ruby method `launch_only_once(value = T.unsafe(nil))` at line 286.
pub fn ruby_service_l286_d21_launch_only_once(mut service BrewService, value ?bool) bool {
	if update := value {
		service.launch_only_once = update
	}
	return service.launch_only_once
}

// Ruby method `restart_delay(value = T.unsafe(nil))` at line 298.
pub fn ruby_service_l298_d22_restart_delay(mut service BrewService, value ?int) ?int {
	if update := value {
		service.restart_delay = update
	}
	return service.restart_delay
}

// Ruby method `throttle_interval(value = T.unsafe(nil))` at line 310.
pub fn ruby_service_l310_d23_throttle_interval(mut service BrewService, value ?int) ?int {
	if update := value {
		service.throttle_interval = update
	}
	return service.throttle_interval
}

// Ruby method `stop_timeout(value = T.unsafe(nil))` at line 320.
pub fn ruby_service_l320_d24_stop_timeout(mut service BrewService,
	value ?int) !ServiceIntValue {
	if update := value {
		if update < 0 {
			return error('Service#stop_timeout must be a non-negative integer')
		}
		service.stop_timeout = update
	}
	current := service.stop_timeout or { return ServiceIntValue{} }
	return ServiceIntValue{ present: true, value: current }
}

// Ruby method `process_type(value = T.unsafe(nil))` at line 333.
pub fn ruby_service_l333_d25_process_type(mut service BrewService,
	input ServiceEnumInput) !string {
	if !input.set {
		return if value := service.process_type { value.str() } else { '' }
	}
	service.process_type = match input.value {
		'background' { ServiceProcessType.background }
		'standard' { ServiceProcessType.standard }
		'interactive' { ServiceProcessType.interactive }
		'adaptive' { ServiceProcessType.adaptive }
		else {
			return error("Service#process_type allows: 'background'/'standard'/'interactive'/'adaptive'")
		}
	}
	return input.value
}

// Ruby method `run_type(value = T.unsafe(nil))` at line 350.
pub fn ruby_service_l350_d26_run_type(mut service BrewService,
	input ServiceEnumInput) !string {
	if !input.set {
		return service.run_type.str()
	}
	service.run_type = match input.value {
		'immediate' { ServiceRunType.immediate }
		'interval' { ServiceRunType.interval }
		'cron' { ServiceRunType.cron }
		else {
			return error("Service#run_type allows: 'immediate'/'interval'/'cron'")
		}
	}
	return input.value
}

// Ruby method `interval(value = T.unsafe(nil))` at line 365.
pub fn ruby_service_l365_d27_interval(mut service BrewService, value ?int) ?int {
	if update := value {
		service.interval = update
	}
	return service.interval
}

// Ruby method `cron(value = T.unsafe(nil))` at line 377.
pub fn ruby_service_l377_d28_cron(mut service BrewService, value ?string) !map[string]string {
	if update := value {
		service.cron = service_parse_cron(update)!
	}
	return service.cron.clone()
}

// Ruby method `default_cron_values` at line 386.
pub fn ruby_service_l386_d29_default_cron_values() map[string]string {
	return service_default_cron_values()
}

// Ruby method `parse_cron(cron_statement)` at line 397.
pub fn ruby_service_l397_d30_parse_cron(cron_statement string) !map[string]string {
	return service_parse_cron(cron_statement)
}

// Ruby method `environment_variables(variables = {})` at line 435.
pub fn ruby_service_l435_d31_environment_variables(mut service BrewService,
	variables ServiceEnvironment) ServiceEnvironment {
	service.environment_variables = ServiceEnvironment{
		values: variables.values.clone()
		order: variables.order.clone()
	}
	return service.environment_variables
}

// Ruby method `effective_environment_variables` at line 443.
pub fn ruby_service_l443_d32_effective_environment_variables(service &BrewService,
	user_config_home string, effective_uid int) ServiceEnvironmentResult {
	return service_effective_environment_variables(service, user_config_home, effective_uid)
}

// Ruby method `macos_legacy_timers(value = T.unsafe(nil))` at line 494.
pub fn ruby_service_l494_d33_macos_legacy_timers(mut service BrewService,
	value ?bool) bool {
	if update := value {
		service.macos_legacy_timers = update
	}
	return service.macos_legacy_timers
}

// Ruby method `nice(value = T.unsafe(nil))` at line 508.
pub fn ruby_service_l508_d34_nice(mut service BrewService, value ?int) !ServiceIntValue {
	if update := value {
		if update < -20 || update > 19 {
			return error('Service#nice value should be in -20..19')
		}
		service.nice = update
	}
	current := service.nice or { return ServiceIntValue{} }
	return ServiceIntValue{ present: true, value: current }
}

// Ruby delegate `delegate [:bin, :etc, :libexec, :opt_bin, :opt_libexec, :opt_pkgshare, :opt_prefix, :opt_sbin, :var] => :@formula` at line 516.
pub fn ruby_service_l516_d35_etc(service &BrewService) string {
	return service.formula.etc
}

// Ruby delegate `delegate [:bin, :etc, :libexec, :opt_bin, :opt_libexec, :opt_pkgshare, :opt_prefix, :opt_sbin, :var] => :@formula` at line 516.
pub fn ruby_service_l516_d36_libexec(service &BrewService) string {
	return service.formula.libexec
}

// Ruby delegate `delegate [:bin, :etc, :libexec, :opt_bin, :opt_libexec, :opt_pkgshare, :opt_prefix, :opt_sbin, :var] => :@formula` at line 516.
pub fn ruby_service_l516_d37_opt_bin(service &BrewService) string {
	return service.formula.opt_bin
}

// Ruby delegate `delegate [:bin, :etc, :libexec, :opt_bin, :opt_libexec, :opt_pkgshare, :opt_prefix, :opt_sbin, :var] => :@formula` at line 516.
pub fn ruby_service_l516_d38_opt_libexec(service &BrewService) string {
	return service.formula.opt_libexec
}

// Ruby delegate `delegate [:bin, :etc, :libexec, :opt_bin, :opt_libexec, :opt_pkgshare, :opt_prefix, :opt_sbin, :var] => :@formula` at line 516.
pub fn ruby_service_l516_d39_opt_pkgshare(service &BrewService) string {
	return service.formula.opt_pkgshare
}

// Ruby delegate `delegate [:bin, :etc, :libexec, :opt_bin, :opt_libexec, :opt_pkgshare, :opt_prefix, :opt_sbin, :var] => :@formula` at line 516.
pub fn ruby_service_l516_d40_opt_prefix(service &BrewService) string {
	return service.formula.opt_prefix
}

// Ruby delegate `delegate [:bin, :etc, :libexec, :opt_bin, :opt_libexec, :opt_pkgshare, :opt_prefix, :opt_sbin, :var] => :@formula` at line 516.
pub fn ruby_service_l516_d41_opt_sbin(service &BrewService) string {
	return service.formula.opt_sbin
}

// Ruby delegate `delegate [:bin, :etc, :libexec, :opt_bin, :opt_libexec, :opt_pkgshare, :opt_prefix, :opt_sbin, :var] => :@formula` at line 516.
pub fn ruby_service_l516_d42_var(service &BrewService) string {
	return service.formula.var
}

// Ruby method `std_service_path_env` at line 520.
pub fn ruby_service_l520_d43_std_service_path_env(service &BrewService) string {
	return '${service.formula.prefix}/bin:${service.formula.prefix}/sbin:/usr/bin:/bin:/usr/sbin:/sbin'
}

// Ruby method `command` at line 525.
pub fn ruby_service_l525_d44_command(service &BrewService) []string {
	return service_command(service)
}

// Ruby method `command?` at line 530.
pub fn ruby_service_l530_d45_command(service &BrewService) bool {
	return service.run.len > 0
}

// Ruby method `path_dirs` at line 535.
pub fn ruby_service_l535_d46_path_dirs(service &BrewService) []string {
	return service_path_dirs(service)
}

// Ruby method `manual_command` at line 550.
pub fn ruby_service_l550_d47_manual_command(service &BrewService, user_config_home string,
	effective_uid int) string {
	return service_manual_command(service, user_config_home, effective_uid)
}

// Ruby method `timed?` at line 560.
pub fn ruby_service_l560_d48_timed(service &BrewService) bool {
	return service.run_type in [.cron, .interval]
}

// Ruby method `to_plist` at line 566.
pub fn ruby_service_l566_d49_to_plist(service &BrewService, user_config_home string,
	effective_uid int) string {
	return service_to_plist(service, user_config_home, effective_uid)
}

// Ruby method `to_systemd_unit` at line 632.
pub fn ruby_service_l632_d50_to_systemd_unit(service &BrewService, user_config_home string,
	effective_uid int) string {
	return service_to_systemd_unit(service, user_config_home, effective_uid)
}

// Ruby method `cron_weekday_to_systemd_weekday(cron_weekday)` at line 676.
pub fn ruby_service_l676_d51_cron_weekday_to_systemd_weekday(cron_weekday string) string {
	return service_cron_weekday_to_systemd_weekday(cron_weekday)
}

// Ruby method `to_systemd_timer` at line 688.
pub fn ruby_service_l688_d52_to_systemd_timer(service &BrewService) string {
	return service_to_systemd_timer(service)
}

// Ruby method `to_hash` at line 715.
pub fn ruby_service_l715_d53_to_hash(service &BrewService) ServiceHash {
	return service_to_hash(service)
}

// Ruby method `self.from_hash(api_hash)` at line 771.
pub fn ruby_service_l771_d54_self_from_hash(api_hash ServiceHash, prefix string, cellar string,
	home string) !ServiceHash {
	return service_from_hash(api_hash, prefix, cellar, home)
}

// Ruby method `self.replace_placeholders(string)` at line 839.
pub fn ruby_service_l839_d55_self_replace_placeholders(value string, prefix string,
	cellar string, home string) string {
	return service_replace_placeholders(value, prefix, cellar, home)
}

// Ruby method `path_dir(path)` at line 847.
pub fn ruby_service_l847_d56_path_dir(path ?string, home string) ?string {
	return service_path_dir(path, home)
}

// Ruby method `path_parent_dir(path)` at line 855.
pub fn ruby_service_l855_d57_path_parent_dir(path ?string, home string) ?string {
	return service_path_parent_dir(path, home)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "ipaddr"
// 5: require "on_system"
// 6: require "utils/path"
// 7: require "utils/service"
// 8:
// 9: module Homebrew
// 10:   # The {Service} class implements the DSL methods used in a formula's
// 11:   # `service` block and stores related instance variables. Most of these methods
// 12:   # also return the related instance variable when no argument is provided.
// 13:   class Service
// 14:     extend Forwardable
// 15:     include OnSystem::MacOSAndLinux
// 16:     include Utils::Output::Mixin
// 17:     include Utils::Path
// 18:
// 19:     RUN_TYPE_IMMEDIATE = :immediate
// 20:     RUN_TYPE_INTERVAL = :interval
// 21:     RUN_TYPE_CRON = :cron
// 22:
// 23:     PROCESS_TYPE_BACKGROUND = :background
// 24:     PROCESS_TYPE_STANDARD = :standard
// 25:     PROCESS_TYPE_INTERACTIVE = :interactive
// 26:     PROCESS_TYPE_ADAPTIVE = :adaptive
// 27:
// 28:     KEEP_ALIVE_KEYS = [:always, :successful_exit, :crashed, :path].freeze
// 29:     NICE_RANGE = T.let(-20..19, T::Range[Integer])
// 30:     SOCKET_STRING_REGEX = %r{^(?<type>[a-z]+)://(?<host>.+):(?<port>[0-9]+)$}i
// 31:
// 32:     RunParam = T.type_alias { T.nilable(T.any(T::Array[T.any(String, Pathname)], String, Pathname)) }
// 33:     Sockets = T.type_alias { T::Hash[Symbol, { host: String, port: String, type: String }] }
// 34:
// 35:     sig { returns(String) }
// 36:     attr_reader :plist_name, :service_name
// 37:
// 38:     sig { params(formula: Formula, block: T.nilable(T.proc.bind(Homebrew::Service).void)).void }
// 39:     def initialize(formula, &block)
// 40:       @cron = T.let({}, T::Hash[Symbol, T.any(Integer, String)])
// 41:       @environment_variables = T.let({}, T::Hash[Symbol, String])
// 42:       @error_log_path = T.let(nil, T.nilable(String))
// 43:       @formula = formula
// 44:       @input_path = T.let(nil, T.nilable(String))
// 45:       @interval = T.let(nil, T.nilable(Integer))
// 46:       @keep_alive = T.let({}, T::Hash[Symbol, T.untyped])
// 47:       @launch_only_once = T.let(false, T::Boolean)
// 48:       @log_path = T.let(nil, T.nilable(String))
// 49:       @macos_legacy_timers = T.let(false, T::Boolean)
// 50:       @nice = T.let(nil, T.nilable(Integer))
// 51:       @plist_name = T.let(default_plist_name, String)
// 52:       @process_type = T.let(nil, T.nilable(Symbol))
// 53:       @require_root = T.let(false, T::Boolean)
// 54:       @restart_delay = T.let(nil, T.nilable(Integer))
// 55:       @throttle_interval = T.let(nil, T.nilable(Integer))
// 56:       @root_dir = T.let(nil, T.nilable(String))
// 57:       @run = T.let([], T::Array[String])
// 58:       @run_at_load = T.let(true, T::Boolean)
// 59:       @run_params = T.let(nil, T.any(RunParam, T::Hash[Symbol, RunParam]))
// 60:       @run_type = T.let(RUN_TYPE_IMMEDIATE, Symbol)
// 61:       @service_name = T.let(default_service_name, String)
// 62:       @sockets = T.let({}, Sockets)
// 63:       @stop_timeout = T.let(nil, T.nilable(Integer))
// 64:       @working_dir = T.let(nil, T.nilable(String))
// 65:       instance_eval(&block) if block
// 66:
// 67:       raise TypeError, "Service#nice: require_root true is required for negative nice values" if nice_requires_root?
// 68:     end
// 69:
// 70:     sig { returns(T::Boolean) }
// 71:     def nice_requires_root?
// 72:       @nice&.negative? == true && !requires_root?
// 73:     end
// 74:
// 75:     sig { returns(Formula) }
// 76:     def f
// 77:       @formula
// 78:     end
// 79:
// 80:     sig { returns(String) }
// 81:     def default_plist_name
// 82:       "homebrew.mxcl.#{@formula.name}"
// 83:     end
// 84:
// 85:     sig { returns(String) }
// 86:     def default_service_name
// 87:       "homebrew.#{@formula.name}"
// 88:     end
// 89:
// 90:     # A hash with the `launchd` service name on macOS and/or the `systemd`
// 91:     # service name on Linux. Homebrew generates a default name for the service
// 92:     # file if this is not present.
// 93:     #
// 94:     # @api public
// 95:     sig { params(macos: T.nilable(String), linux: T.nilable(String)).void }
// 96:     def name(macos: nil, linux: nil)
// 97:       raise TypeError, "Service#name expects at least one String" if [macos, linux].none?(String)
// 98:
// 99:       @plist_name = macos if macos
// 100:       @service_name = linux if linux
// 101:     end
// 102:
// 103:     # The command to execute: an array with arguments or a path.
// 104:     #
// 105:     # @api public
// 106:     sig {
// 107:       params(
// 108:         command: T.nilable(RunParam),
// 109:         macos:   T.nilable(RunParam),
// 110:         linux:   T.nilable(RunParam),
// 111:       ).returns(T.nilable(T::Array[String]))
// 112:     }
// 113:     def run(command = nil, macos: nil, linux: nil)
// 114:       # Save parameters for serialization
// 115:       if command
// 116:         @run_params = command
// 117:       elsif macos || linux
// 118:         @run_params = { macos:, linux: }.compact
// 119:       end
// 120:
// 121:       command ||= on_system_conditional(macos:, linux:)
// 122:       case command
// 123:       when nil
// 124:         @run
// 125:       when String, Pathname
// 126:         @run = [command.to_s]
// 127:       when Array
// 128:         @run = command.map(&:to_s)
// 129:       end
// 130:     end
// 131:
// 132:     # Directory to operate from.
// 133:     #
// 134:     # @api public
// 135:     sig { params(path: T.any(String, Pathname)).returns(T.nilable(String)) }
// 136:     def working_dir(path = T.unsafe(nil))
// 137:       if path
// 138:         @working_dir = path.to_s
// 139:       else
// 140:         @working_dir
// 141:       end
// 142:     end
// 143:
// 144:     # Directory to use as a chroot for the process.
// 145:     #
// 146:     # @api public
// 147:     sig { params(path: T.any(String, Pathname)).returns(T.nilable(String)) }
// 148:     def root_dir(path = T.unsafe(nil))
// 149:       if path
// 150:         @root_dir = path.to_s
// 151:       else
// 152:         @root_dir
// 153:       end
// 154:     end
// 155:
// 156:     # Path to use as input for the process.
// 157:     #
// 158:     # @api public
// 159:     sig { params(path: T.any(String, Pathname)).returns(T.nilable(String)) }
// 160:     def input_path(path = T.unsafe(nil))
// 161:       if path
// 162:         @input_path = path.to_s
// 163:       else
// 164:         @input_path
// 165:       end
// 166:     end
// 167:
// 168:     # Path to write `stdout` to.
// 169:     #
// 170:     # @api public
// 171:     sig { params(path: T.any(String, Pathname)).returns(T.nilable(String)) }
// 172:     def log_path(path = T.unsafe(nil))
// 173:       if path
// 174:         @log_path = path.to_s
// 175:       else
// 176:         @log_path
// 177:       end
// 178:     end
// 179:
// 180:     # Path to write `stderr` to.
// 181:     #
// 182:     # @api public
// 183:     sig { params(path: T.any(String, Pathname)).returns(T.nilable(String)) }
// 184:     def error_log_path(path = T.unsafe(nil))
// 185:       if path
// 186:         @error_log_path = path.to_s
// 187:       else
// 188:         @error_log_path
// 189:       end
// 190:     end
// 191:
// 192:     # Sets contexts in which the service will keep the process running.
// 193:     #
// 194:     # @api public
// 195:     sig {
// 196:       params(value: T.any(T::Boolean, T::Hash[Symbol, T.untyped]))
// 197:         .returns(T.nilable(T::Hash[Symbol, T.untyped]))
// 198:     }
// 199:     def keep_alive(value = T.unsafe(nil))
// 200:       case value
// 201:       when nil
// 202:         @keep_alive
// 203:       when true, false
// 204:         @keep_alive = { always: value }
// 205:       when Hash
// 206:         unless (value.keys - KEEP_ALIVE_KEYS).empty?
// 207:           raise TypeError, "Service#keep_alive only allows: #{KEEP_ALIVE_KEYS}"
// 208:         end
// 209:
// 210:         @keep_alive = value
// 211:       end
// 212:     end
// 213:
// 214:     # Whether the service requires root access. If true, Homebrew hints at using
// 215:     # `sudo` on various occasions, but does not enforce it.
// 216:     #
// 217:     # @api public
// 218:     sig { params(value: T::Boolean).returns(T::Boolean) }
// 219:     def require_root(value = T.unsafe(nil))
// 220:       if value.nil?
// 221:         @require_root
// 222:       else
// 223:         @require_root = value
// 224:       end
// 225:     end
// 226:
// 227:     # Returns a `Boolean` describing if a service requires root access.
// 228:     sig { returns(T::Boolean) }
// 229:     def requires_root?
// 230:       @require_root.present? && @require_root == true
// 231:     end
// 232:
// 233:     # Whether the command should run when the service is loaded.
// 234:     #
// 235:     # @api public
// 236:     sig { params(value: T::Boolean).returns(T.nilable(T::Boolean)) }
// 237:     def run_at_load(value = T.unsafe(nil))
// 238:       if value.nil?
// 239:         @run_at_load
// 240:       else
// 241:         @run_at_load = value
// 242:       end
// 243:     end
// 244:
// 245:     # Socket that is created as an access point to the service.
// 246:     #
// 247:     # @api public
// 248:     sig {
// 249:       params(value: T.any(String, T::Hash[Symbol, String]))
// 250:         .returns(T::Hash[Symbol, T::Hash[Symbol, String]])
// 251:     }
// 252:     def sockets(value = T.unsafe(nil))
// 253:       return @sockets if value.nil?
// 254:
// 255:       value_hash = case value
// 256:       when String
// 257:         { listeners: value }
// 258:       when Hash
// 259:         value
// 260:       end
// 261:
// 262:       @sockets = T.must(value_hash).transform_values do |socket_string|
// 263:         match = socket_string.match(SOCKET_STRING_REGEX)
// 264:         raise TypeError, "Service#sockets a formatted socket definition as <type>://<host>:<port>" unless match
// 265:
// 266:         begin
// 267:           IPAddr.new(match[:host])
// 268:         rescue IPAddr::InvalidAddressError
// 269:           raise TypeError, "Service#sockets expects a valid ipv4 or ipv6 host address"
// 270:         end
// 271:
// 272:         { host: match[:host], port: match[:port], type: match[:type] }
// 273:       end
// 274:     end
// 275:
// 276:     # Returns a `Boolean` describing if a service is set to be kept alive.
// 277:     sig { returns(T::Boolean) }
// 278:     def keep_alive?
// 279:       !@keep_alive.empty? && @keep_alive[:always] != false
// 280:     end
// 281:
// 282:     # Whether the command should only run once.
// 283:     #
// 284:     # @api public
// 285:     sig { params(value: T::Boolean).returns(T::Boolean) }
// 286:     def launch_only_once(value = T.unsafe(nil))
// 287:       if value.nil?
// 288:         @launch_only_once
// 289:       else
// 290:         @launch_only_once = value
// 291:       end
// 292:     end
// 293:
// 294:     # Number of seconds to delay before restarting a process.
// 295:     #
// 296:     # @api public
// 297:     sig { params(value: Integer).returns(T.nilable(Integer)) }
// 298:     def restart_delay(value = T.unsafe(nil))
// 299:       if value
// 300:         @restart_delay = value
// 301:       else
// 302:         @restart_delay
// 303:       end
// 304:     end
// 305:
// 306:     # Minimum seconds to wait before invocations (macOS default is `10`).
// 307:     #
// 308:     # @api public
// 309:     sig { params(value: Integer).returns(T.nilable(Integer)) }
// 310:     def throttle_interval(value = T.unsafe(nil))
// 311:       return @throttle_interval if value.nil?
// 312:
// 313:       @throttle_interval = value
// 314:     end
// 315:
// 316:     # Number of seconds to wait before forcibly stopping a process.
// 317:     #
// 318:     # @api public
// 319:     sig { params(value: Integer).returns(T.nilable(Integer)) }
// 320:     def stop_timeout(value = T.unsafe(nil))
// 321:       return @stop_timeout if value.nil?
// 322:
// 323:       raise TypeError, "Service#stop_timeout must be a non-negative integer" if value.negative?
// 324:
// 325:       @stop_timeout = value
// 326:     end
// 327:
// 328:     # Type of process to manage: `:background`, `:standard`, `:interactive` or
// 329:     # `:adaptive`.
// 330:     #
// 331:     # @api public
// 332:     sig { params(value: Symbol).returns(T.nilable(Symbol)) }
// 333:     def process_type(value = T.unsafe(nil))
// 334:       case value
// 335:       when nil
// 336:         @process_type
// 337:       when :background, :standard, :interactive, :adaptive
// 338:         @process_type = value
// 339:       when Symbol
// 340:         raise TypeError, "Service#process_type allows: " \
// 341:                          "'#{PROCESS_TYPE_BACKGROUND}'/'#{PROCESS_TYPE_STANDARD}'/" \
// 342:                          "'#{PROCESS_TYPE_INTERACTIVE}'/'#{PROCESS_TYPE_ADAPTIVE}'"
// 343:       end
// 344:     end
// 345:
// 346:     # The type of service: `:immediate`, `:interval` or `:cron`.
// 347:     #
// 348:     # @api public
// 349:     sig { params(value: Symbol).returns(T.nilable(Symbol)) }
// 350:     def run_type(value = T.unsafe(nil))
// 351:       case value
// 352:       when nil
// 353:         @run_type
// 354:       when :immediate, :interval, :cron
// 355:         @run_type = value
// 356:       when Symbol
// 357:         raise TypeError, "Service#run_type allows: '#{RUN_TYPE_IMMEDIATE}'/'#{RUN_TYPE_INTERVAL}'/'#{RUN_TYPE_CRON}'"
// 358:       end
// 359:     end
// 360:
// 361:     # Controls the start interval, required for the `:interval` type.
// 362:     #
// 363:     # @api public
// 364:     sig { params(value: Integer).returns(T.nilable(Integer)) }
// 365:     def interval(value = T.unsafe(nil))
// 366:       if value
// 367:         @interval = value
// 368:       else
// 369:         @interval
// 370:       end
// 371:     end
// 372:
// 373:     # Controls the trigger times, required for the `:cron` type.
// 374:     #
// 375:     # @api public
// 376:     sig { params(value: String).returns(T::Hash[Symbol, T.any(Integer, String)]) }
// 377:     def cron(value = T.unsafe(nil))
// 378:       if value
// 379:         @cron = parse_cron(value)
// 380:       else
// 381:         @cron
// 382:       end
// 383:     end
// 384:
// 385:     sig { returns(T::Hash[Symbol, T.any(Integer, String)]) }
// 386:     def default_cron_values
// 387:       {
// 388:         Month:   "*",
// 389:         Day:     "*",
// 390:         Weekday: "*",
// 391:         Hour:    "*",
// 392:         Minute:  "*",
// 393:       }
// 394:     end
// 395:
// 396:     sig { params(cron_statement: String).returns(T::Hash[Symbol, T.any(Integer, String)]) }
// 397:     def parse_cron(cron_statement)
// 398:       parsed = default_cron_values
// 399:
// 400:       case cron_statement
// 401:       when "@hourly"
// 402:         parsed[:Minute] = 0
// 403:       when "@daily"
// 404:         parsed[:Minute] = 0
// 405:         parsed[:Hour] = 0
// 406:       when "@weekly"
// 407:         parsed[:Minute] = 0
// 408:         parsed[:Hour] = 0
// 409:         parsed[:Weekday] = 0
// 410:       when "@monthly"
// 411:         parsed[:Minute] = 0
// 412:         parsed[:Hour] = 0
// 413:         parsed[:Day] = 1
// 414:       when "@yearly", "@annually"
// 415:         parsed[:Minute] = 0
// 416:         parsed[:Hour] = 0
// 417:         parsed[:Day] = 1
// 418:         parsed[:Month] = 1
// 419:       else
// 420:         cron_parts = cron_statement.split
// 421:         raise TypeError, "Service#parse_cron expects a valid cron syntax" if cron_parts.length != 5
// 422:
// 423:         [:Minute, :Hour, :Day, :Month, :Weekday].each_with_index do |selector, index|
// 424:           parsed[selector] = Integer(cron_parts.fetch(index)) if cron_parts.fetch(index) != "*"
// 425:         end
// 426:       end
// 427:
// 428:       parsed
// 429:     end
// 430:
// 431:     # Hash of variables to set.
// 432:     #
// 433:     # @api public
// 434:     sig { params(variables: T::Hash[Symbol, T.any(Pathname, String)]).returns(T.nilable(T::Hash[Symbol, String])) }
// 435:     def environment_variables(variables = {})
// 436:       @environment_variables = variables.transform_values(&:to_s)
// 437:     end
// 438:
// 439:     # Returns the effective environment variables with user overrides merged
// 440:     # in from `$HOMEBREW_USER_CONFIG_HOME/services/<formula>.env`.  User
// 441:     # overrides take precedence over formula-defined variables.
// 442:     sig { returns(T::Hash[Symbol, String]) }
// 443:     def effective_environment_variables
// 444:       env_vars = @environment_variables.dup
// 445:
// 446:       env_file = Pathname.new("#{ENV.fetch("HOMEBREW_USER_CONFIG_HOME")}/services/#{@formula.name}.env")
// 447:       return env_vars unless env_file.file?
// 448:
// 449:       # User env overrides are not supported for root services.
// 450:       # `sudo -E` can preserve a caller-controlled HOME, and TOCTOU
// 451:       # between symlink resolution, permission checks, and reading makes
// 452:       # it impossible to safely validate a user-owned override file when
// 453:       # generating a root service definition.
// 454:       if Process.euid.zero?
// 455:         opoo "Skipping #{env_file}: user env overrides are not supported for root services."
// 456:         return env_vars
// 457:       end
// 458:
// 459:       if env_file.world_writable?
// 460:         opoo "Skipping #{env_file}: file is world-writable."
// 461:         return env_vars
// 462:       end
// 463:
// 464:       if env_file.stat.mode.anybits?(020)
// 465:         opoo "Skipping #{env_file}: file is group-writable."
// 466:         return env_vars
// 467:       end
// 468:
// 469:       # Read each line, strip whitespace, and remove blank lines and
// 470:       # comments (lines starting with `#`). Then parse remaining lines
// 471:       # as KEY=value pairs, warning on lines missing a `=` separator.
// 472:       overrides = env_file.each_line
// 473:                           .map(&:strip)
// 474:                           .reject { |line| line.empty? || line.start_with?("#") }
// 475:                           .each_with_object({}) do |line, hash|
// 476:                             key, value = line.split("=", 2)
// 477:                             if key.blank? || value.nil?
// 478:                               opoo "Skipping invalid line in #{env_file}: #{line}"
// 479:                               next
// 480:                             end
// 481:
// 482:                             hash[key.strip] = value.strip
// 483:                           end
// 484:
// 485:       overrides.each { |key, value| env_vars[key.to_sym] = value }
// 486:
// 487:       env_vars
// 488:     end
// 489:
// 490:     # Timers created by `launchd` jobs are coalesced unless this is set.
// 491:     #
// 492:     # @api public
// 493:     sig { params(value: T::Boolean).returns(T::Boolean) }
// 494:     def macos_legacy_timers(value = T.unsafe(nil))
// 495:       if value.nil?
// 496:         @macos_legacy_timers
// 497:       else
// 498:         @macos_legacy_timers = value
// 499:       end
// 500:     end
// 501:
// 502:     # Default scheduling priority (nice level), from `-20` highest to `19`
// 503:     # lowest. **Note:** Negative nice values (higher priority) require
// 504:     # `require_root: true` to be set.
// 505:     #
// 506:     # @api public
// 507:     sig { params(value: Integer).returns(T.nilable(Integer)) }
// 508:     def nice(value = T.unsafe(nil))
// 509:       return @nice if value.nil?
// 510:
// 511:       raise TypeError, "Service#nice value should be in #{NICE_RANGE}" unless NICE_RANGE.cover?(value)
// 512:
// 513:       @nice = value
// 514:     end
// 515:
// 516:     delegate [:bin, :etc, :libexec, :opt_bin, :opt_libexec, :opt_pkgshare, :opt_prefix, :opt_sbin, :var] => :@formula
// 517:
// 518:     # @api internal
// 519:     sig { returns(String) }
// 520:     def std_service_path_env
// 521:       "#{HOMEBREW_PREFIX}/bin:#{HOMEBREW_PREFIX}/sbin:/usr/bin:/bin:/usr/sbin:/sbin"
// 522:     end
// 523:
// 524:     sig { returns(T::Array[String]) }
// 525:     def command
// 526:       @run.map(&:to_s).map { |arg| arg.start_with?("~") ? File.expand_path(arg) : arg }
// 527:     end
// 528:
// 529:     sig { returns(T::Boolean) }
// 530:     def command?
// 531:       !@run.empty?
// 532:     end
// 533:
// 534:     sig { returns(T::Array[Pathname]) }
// 535:     def path_dirs
// 536:       [
// 537:         path_dir(@working_dir),
// 538:         path_dir(@root_dir),
// 539:       ].push(
// 540:         path_parent_dir(@input_path),
// 541:         path_parent_dir(@log_path),
// 542:         path_parent_dir(@error_log_path),
// 543:       )
// 544:        .compact
// 545:        .uniq
// 546:     end
// 547:
// 548:     # Returns the `String` command to run manually instead of the service.
// 549:     sig { returns(String) }
// 550:     def manual_command
// 551:       env_vars = effective_environment_variables.except(:PATH)
// 552:                                                 .map { |k, v| "#{k}=\"#{v}\"" }
// 553:
// 554:       env_vars.concat(command.map { |arg| Utils::Shell.sh_quote(arg) })
// 555:       env_vars.join(" ")
// 556:     end
// 557:
// 558:     # Returns a `Boolean` describing if a service is timed.
// 559:     sig { returns(T::Boolean) }
// 560:     def timed?
// 561:       @run_type == RUN_TYPE_CRON || @run_type == RUN_TYPE_INTERVAL
// 562:     end
// 563:
// 564:     # Returns a `String` plist.
// 565:     sig { returns(String) }
// 566:     def to_plist
// 567:       # command needs to be first because it initializes all other values
// 568:       base = {
// 569:         Label:            plist_name,
// 570:         ProgramArguments: command,
// 571:         RunAtLoad:        @run_at_load == true,
// 572:       }
// 573:
// 574:       base[:LaunchOnlyOnce] = @launch_only_once if @launch_only_once == true
// 575:       base[:LegacyTimers] = @macos_legacy_timers if @macos_legacy_timers == true
// 576:       base[:ExitTimeOut] = @stop_timeout if @stop_timeout.present?
// 577:       base[:TimeOut] = @restart_delay if @restart_delay.present?
// 578:       base[:ThrottleInterval] = @throttle_interval if @throttle_interval.present?
// 579:       base[:ProcessType] = @process_type.to_s.capitalize if @process_type.present?
// 580:       base[:Nice] = @nice if @nice.present?
// 581:       base[:StartInterval] = @interval if @interval.present? && @run_type == RUN_TYPE_INTERVAL
// 582:       base[:WorkingDirectory] = File.expand_path(@working_dir) if @working_dir.present?
// 583:       base[:RootDirectory] = File.expand_path(@root_dir) if @root_dir.present?
// 584:       base[:StandardInPath] = File.expand_path(@input_path) if @input_path.present?
// 585:       base[:StandardOutPath] = File.expand_path(@log_path) if @log_path.present?
// 586:       base[:StandardErrorPath] = File.expand_path(@error_log_path) if @error_log_path.present?
// 587:       if (env_vars = effective_environment_variables).present?
// 588:         base[:EnvironmentVariables] = env_vars
// 589:       end
// 590:
// 591:       if keep_alive?
// 592:         if (always = @keep_alive[:always].presence)
// 593:           base[:KeepAlive] = always
// 594:         elsif @keep_alive.key?(:successful_exit)
// 595:           base[:KeepAlive] = { SuccessfulExit: @keep_alive[:successful_exit] }
// 596:         elsif @keep_alive.key?(:crashed)
// 597:           base[:KeepAlive] = { Crashed: @keep_alive[:crashed] }
// 598:         elsif @keep_alive.key?(:path) && @keep_alive[:path].present?
// 599:           base[:KeepAlive] = { PathState: @keep_alive[:path].to_s }
// 600:         end
// 601:       end
// 602:
// 603:       unless @sockets.empty?
// 604:         base[:Sockets] = {}
// 605:         @sockets.each do |name, info|
// 606:           base[:Sockets][name] = {
// 607:             SockNodeName:    info[:host],
// 608:             SockServiceName: info[:port],
// 609:             SockProtocol:    info[:type].upcase,
// 610:           }
// 611:         end
// 612:       end
// 613:
// 614:       if !@cron.empty? && @run_type == RUN_TYPE_CRON
// 615:         base[:StartCalendarInterval] = @cron.reject { |_, value| value == "*" }
// 616:       end
// 617:
// 618:       # Adding all session types has as the primary effect that if you initialise it through e.g. a Background session
// 619:       # and you later "physically" sign in to the owning account (Aqua session), things shouldn't flip out.
// 620:       # Also, we're not checking @process_type here because that is used to indicate process priority and not
// 621:       # necessarily if it should run in a specific session type. Like database services could run with ProcessType
// 622:       # Interactive so they have no resource limitations enforced upon them, but they aren't really interactive in the
// 623:       # general sense.
// 624:       base[:LimitLoadToSessionType] = %w[Aqua Background LoginWindow StandardIO System]
// 625:
// 626:       require "plist"
// 627:       base.to_plist
// 628:     end
// 629:
// 630:     # Returns a `String` systemd unit.
// 631:     sig { returns(String) }
// 632:     def to_systemd_unit
// 633:       # command needs to be first because it initializes all other values
// 634:       cmd = command.map { |arg| Utils::Service.systemd_quote(arg) }
// 635:                    .join(" ")
// 636:
// 637:       options = []
// 638:       options << "Type=#{(@launch_only_once == true) ? "oneshot" : "simple"}"
// 639:       options << "ExecStart=#{cmd}"
// 640:
// 641:       if @keep_alive.present?
// 642:         if @keep_alive[:always].present? || @keep_alive[:crashed].present?
// 643:           # Use on-failure instead of always to allow manual stops via systemctl
// 644:           options << "Restart=on-failure"
// 645:         elsif @keep_alive[:successful_exit].present?
// 646:           options << "Restart=on-success"
// 647:         end
// 648:       end
// 649:       options << "RestartSec=#{restart_delay}" if @restart_delay.present?
// 650:       options << "TimeoutStopSec=#{@stop_timeout}" if @stop_timeout.present?
// 651:       options << "Nice=#{@nice}" if @nice.present?
// 652:       options << "WorkingDirectory=#{File.expand_path(@working_dir)}" if @working_dir.present?
// 653:       options << "RootDirectory=#{File.expand_path(@root_dir)}" if @root_dir.present?
// 654:       options << "StandardInput=file:#{File.expand_path(@input_path)}" if @input_path.present?
// 655:       options << "StandardOutput=append:#{File.expand_path(@log_path)}" if @log_path.present?
// 656:       options << "StandardError=append:#{File.expand_path(@error_log_path)}" if @error_log_path.present?
// 657:       if (env_vars = effective_environment_variables).present?
// 658:         options += env_vars.map do |k, v|
// 659:           "Environment=\"#{k}=#{v}\""
// 660:         end
// 661:       end
// 662:
// 663:       <<~SYSTEMD
// 664:         [Unit]
// 665:         Description=Homebrew generated unit for #{@formula.name}
// 666:
// 667:         [Install]
// 668:         WantedBy=default.target
// 669:
// 670:         [Service]
// 671:         #{options.join("\n")}
// 672:       SYSTEMD
// 673:     end
// 674:
// 675:     sig { params(cron_weekday: T.nilable(T.any(Integer, String))).returns(String) }
// 676:     def cron_weekday_to_systemd_weekday(cron_weekday)
// 677:       if cron_weekday != "*" &&
// 678:          (weekday_number = cron_weekday&.to_i) &&
// 679:          (0..7).cover?(weekday_number)
// 680:         "#{Date::ABBR_DAYNAMES[weekday_number % 7]} "
// 681:       else
// 682:         ""
// 683:       end
// 684:     end
// 685:
// 686:     # Returns a `String` systemd unit timer.
// 687:     sig { returns(String) }
// 688:     def to_systemd_timer
// 689:       options = []
// 690:       options << "Persistent=true" if @run_type == RUN_TYPE_CRON
// 691:       options << "OnUnitActiveSec=#{@interval}" if @run_type == RUN_TYPE_INTERVAL
// 692:
// 693:       if @run_type == RUN_TYPE_CRON
// 694:         minutes = (@cron[:Minute] == "*") ? "*" : format("%02d", @cron[:Minute])
// 695:         hours   = (@cron[:Hour] == "*") ? "*" : format("%02d", @cron[:Hour])
// 696:         options << "OnCalendar=#{cron_weekday_to_systemd_weekday(@cron[:Weekday])}" \
// 697:                    "*-#{@cron[:Month]}-#{@cron[:Day]} #{hours}:#{minutes}:00"
// 698:       end
// 699:
// 700:       <<~SYSTEMD
// 701:         [Unit]
// 702:         Description=Homebrew generated timer for #{@formula.name}
// 703:
// 704:         [Install]
// 705:         WantedBy=timers.target
// 706:
// 707:         [Timer]
// 708:         Unit=#{service_name}.service
// 709:         #{options.join("\n")}
// 710:       SYSTEMD
// 711:     end
// 712:
// 713:     # Prepare the service hash for inclusion in the formula API JSON.
// 714:     sig { returns(T::Hash[Symbol, T.untyped]) }
// 715:     def to_hash
// 716:       name_params = {
// 717:         macos: (plist_name if plist_name != default_plist_name),
// 718:         linux: (service_name if service_name != default_service_name),
// 719:       }.compact
// 720:
// 721:       return { name: name_params }.compact_blank if @run_params.blank?
// 722:
// 723:       cron_string = if @cron.present?
// 724:         [:Minute, :Hour, :Day, :Month, :Weekday]
// 725:           .filter_map { |key| @cron[key].to_s.presence }
// 726:           .join(" ")
// 727:       end
// 728:
// 729:       sockets_var = unless @sockets.empty?
// 730:         @sockets.transform_values { |info| "#{info[:type]}://#{info[:host]}:#{info[:port]}" }
// 731:                 .then do |sockets_hash|
// 732:                   # TODO: Remove this code when all users are running on versions of Homebrew
// 733:                   #       that can process sockets hashes (this commit or later).
// 734:                   if sockets_hash.size == 1 && sockets_hash.key?(:listeners)
// 735:                     # When original #sockets argument was a string: `sockets "tcp://127.0.0.1:80"`
// 736:                     sockets_hash.fetch(:listeners)
// 737:                   else
// 738:                     # When original #sockets argument was a hash: `sockets http: "tcp://0.0.0.0:80"`
// 739:                     sockets_hash
// 740:                   end
// 741:                 end
// 742:       end
// 743:
// 744:       {
// 745:         name:                  name_params.presence,
// 746:         run:                   @run_params,
// 747:         run_type:              @run_type,
// 748:         interval:              @interval,
// 749:         cron:                  cron_string.presence,
// 750:         keep_alive:            @keep_alive,
// 751:         launch_only_once:      @launch_only_once,
// 752:         require_root:          @require_root,
// 753:         environment_variables: @environment_variables.presence,
// 754:         working_dir:           @working_dir,
// 755:         root_dir:              @root_dir,
// 756:         input_path:            @input_path,
// 757:         log_path:              @log_path,
// 758:         error_log_path:        @error_log_path,
// 759:         restart_delay:         @restart_delay,
// 760:         throttle_interval:     @throttle_interval,
// 761:         stop_timeout:          @stop_timeout,
// 762:         nice:                  @nice,
// 763:         process_type:          @process_type,
// 764:         macos_legacy_timers:   @macos_legacy_timers,
// 765:         sockets:               sockets_var,
// 766:       }.compact_blank
// 767:     end
// 768:
// 769:     # Turn the service API hash values back into what is expected by the formula DSL.
// 770:     sig { params(api_hash: T::Hash[String, T.untyped]).returns(T::Hash[Symbol, T.untyped]) }
// 771:     def self.from_hash(api_hash)
// 772:       hash = {}
// 773:       hash[:name] = api_hash["name"].transform_keys(&:to_sym) if api_hash.key?("name")
// 774:
// 775:       # The service hash might not have a "run" command if it only documents
// 776:       # an existing service file with the "name" command.
// 777:       return hash unless api_hash.key?("run")
// 778:
// 779:       hash[:run] =
// 780:         case api_hash["run"]
// 781:         when String, Pathname
// 782:           replace_placeholders(api_hash["run"])
// 783:         when Array
// 784:           api_hash["run"].map { replace_placeholders(it) }
// 785:         when Hash
// 786:           api_hash["run"].to_h do |key, elem|
// 787:             run_cmd = if elem.is_a?(Array)
// 788:               elem.map { replace_placeholders(it) }
// 789:             else
// 790:               replace_placeholders(elem)
// 791:             end
// 792:
// 793:             [key.to_sym, run_cmd]
// 794:           end
// 795:         else
// 796:           raise ArgumentError, "Unexpected run command: #{api_hash["run"]}"
// 797:         end
// 798:
// 799:       if api_hash.key?("environment_variables")
// 800:         hash[:environment_variables] = api_hash["environment_variables"].to_h do |key, value|
// 801:           [key.to_sym, replace_placeholders(value)]
// 802:         end
// 803:       end
// 804:
// 805:       %w[run_type process_type].each do |key|
// 806:         next unless (value = api_hash[key])
// 807:
// 808:         hash[key.to_sym] = value.to_sym
// 809:       end
// 810:
// 811:       %w[working_dir root_dir input_path log_path error_log_path].each do |key|
// 812:         next unless (value = api_hash[key])
// 813:
// 814:         hash[key.to_sym] = replace_placeholders(value)
// 815:       end
// 816:
// 817:       %w[interval cron launch_only_once require_root restart_delay throttle_interval stop_timeout nice
// 818:          macos_legacy_timers].each do |key|
// 819:         next if (value = api_hash[key]).nil?
// 820:
// 821:         hash[key.to_sym] = value
// 822:       end
// 823:
// 824:       %w[sockets keep_alive].each do |key|
// 825:         next unless (value = api_hash[key])
// 826:
// 827:         hash[key.to_sym] = if value.is_a?(Hash)
// 828:           value.transform_keys(&:to_sym)
// 829:         else
// 830:           value
// 831:         end
// 832:       end
// 833:
// 834:       hash
// 835:     end
// 836:
// 837:     # Replace API path placeholders with local paths.
// 838:     sig { params(string: T.any(String, Pathname)).returns(String) }
// 839:     def self.replace_placeholders(string)
// 840:       string.to_s
// 841:             .gsub(HOMEBREW_PREFIX_PLACEHOLDER, HOMEBREW_PREFIX)
// 842:             .gsub(HOMEBREW_CELLAR_PLACEHOLDER, HOMEBREW_CELLAR)
// 843:             .gsub(HOMEBREW_HOME_PLACEHOLDER, Dir.home)
// 844:     end
// 845:
// 846:     sig { params(path: T.nilable(String)).returns(T.nilable(Pathname)) }
// 847:     def path_dir(path)
// 848:       return if path.blank?
// 849:       return unless path.start_with?("/", "~")
// 850:
// 851:       Pathname.new(File.expand_path(path))
// 852:     end
// 853:
// 854:     sig { params(path: T.nilable(String)).returns(T.nilable(Pathname)) }
// 855:     def path_parent_dir(path)
// 856:       path_dir(path)&.dirname
// 857:     end
// 858:   end
// 859: end
