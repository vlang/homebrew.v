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
