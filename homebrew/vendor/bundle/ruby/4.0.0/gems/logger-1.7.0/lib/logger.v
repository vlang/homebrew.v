module lib

import ruby
import os
import sync
import time

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/logger-1.7.0/lib/logger.rb`.
// The original source is retained below until every stub has a typed V body.
pub const logger_debug = 0
pub const logger_info = 1
pub const logger_warn = 2
pub const logger_error = 3
pub const logger_fatal = 4
pub const logger_unknown = 5
pub const logger_version = '1.7.0'

const severity_labels = ['DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL', 'ANY']
const logger_datetime_format = '%Y-%m-%dT%H:%M:%S.%6N'

pub type LoggerFormatter = fn(string, time.Time, string, ruby.Value) string

pub struct LoggerOptions {
pub:
	level                int
	progname             string
	datetime_format      string
	formatter            ?LoggerFormatter
	shift_age            int
	shift_period         string
	shift_size           u64 = 1_048_576
	shift_period_suffix  string = '%Y%m%d'
	binmode              bool
	reraise_write_errors bool
	skip_header          bool
}

pub struct Logger {
pub mut:
	base_level           int
	progname             string
	datetime_format      string
	formatter            ?LoggerFormatter
	logdev               string
	shift_age            int
	shift_period         string
	shift_size           u64
	shift_period_suffix  string
	binmode              bool
	reraise_write_errors bool
	skip_header          bool
	closed               bool
	next_rotate_time     time.Time
mut:
	level_overrides map[u64][]int
	monitor         sync.Mutex
}

pub fn new_logger(logdev string, options LoggerOptions) !Logger {
	mut logger := Logger{
		base_level: options.level
		progname: options.progname
		datetime_format: options.datetime_format
		formatter: options.formatter
		logdev: logdev
		shift_age: options.shift_age
		shift_period: options.shift_period
		shift_size: options.shift_size
		shift_period_suffix: options.shift_period_suffix
		binmode: options.binmode
		reraise_write_errors: options.reraise_write_errors
		skip_header: options.skip_header
	}
	if logdev.len > 0 && logdev != os.path_devnull {
		logger.open_logfile()!
		if options.shift_period.len > 0 {
			base := if os.exists(logdev) {
				time.unix(os.file_last_mod_unix(logdev))
			} else {
				time.now()
			}
			logger.next_rotate_time = logger_next_rotate_time(base, options.shift_period)!
		}
	}
	return logger
}

pub fn (logger &Logger) level() int {
	key := sync.thread_id()
	if key in logger.level_overrides && logger.level_overrides[key].len > 0 {
		return logger.level_overrides[key].last()
	}
	return logger.base_level
}

pub fn (mut logger Logger) set_level(severity int) int {
	logger.base_level = severity
	return severity
}

pub fn (mut logger Logger) with_level(severity int, action fn(mut Logger)) {
	key := sync.thread_id()
	mut overrides := logger.level_overrides[key].clone()
	overrides << severity
	logger.level_overrides[key] = overrides
	defer {
		mut restored := logger.level_overrides[key].clone()
		restored.delete_last()
		if restored.len == 0 {
			logger.level_overrides.delete(key)
		} else {
			logger.level_overrides[key] = restored
		}
	}
	action(mut logger)
}

pub fn (logger &Logger) debug_enabled() bool {
	return logger.level() <= logger_debug
}

pub fn (logger &Logger) info_enabled() bool {
	return logger.level() <= logger_info
}

pub fn (logger &Logger) warn_enabled() bool {
	return logger.level() <= logger_warn
}

pub fn (logger &Logger) error_enabled() bool {
	return logger.level() <= logger_error
}

pub fn (logger &Logger) fatal_enabled() bool {
	return logger.level() <= logger_fatal
}

pub fn (mut logger Logger) debug_bang() int {
	return logger.set_level(logger_debug)
}

pub fn (mut logger Logger) info_bang() int {
	return logger.set_level(logger_info)
}

pub fn (mut logger Logger) warn_bang() int {
	return logger.set_level(logger_warn)
}

pub fn (mut logger Logger) error_bang() int {
	return logger.set_level(logger_error)
}

pub fn (mut logger Logger) fatal_bang() int {
	return logger.set_level(logger_fatal)
}

pub fn (logger &Logger) format_severity(severity int) string {
	if severity >= 0 && severity < severity_labels.len {
		return severity_labels[severity]
	}
	return 'ANY'
}

fn format_logger_time(value time.Time, format string) string {
	selected := if format.len > 0 { format } else { logger_datetime_format }
	placeholder := '__LOGGER_MICROSECONDS__'
	return value.strftime(selected.replace('%6N', placeholder)).replace(placeholder, '${value.nanosecond / 1_000:06}')
}

fn logger_message_string(message ruby.Value) string {
	if message.type_name == 'String' {
		return message.as_string()
	}
	if message.type_name == 'Exception' {
		text := message.attribute('message') or { message.as_string() }
		class_name := message.attribute('class') or { 'Exception' }
		backtrace := message.attribute('backtrace') or { '' }
		return '${text} (${class_name})\n${backtrace}'
	}
	return message.as_string()
}

fn (logger &Logger) default_format_message(severity string, at time.Time, progname string, message ruby.Value) string {
	initial := if severity.len > 0 { severity[..1] } else { '' }
	return '${initial}, [${format_logger_time(at, logger.datetime_format)} #${os.getpid()}] ${severity:5} -- ${progname}: ${logger_message_string(message)}\n'
}

pub fn (logger &Logger) format_message(severity string, at time.Time, progname string, message ruby.Value) string {
	if formatter := logger.formatter {
		return formatter(severity, at, progname, message)
	}
	return logger.default_format_message(severity, at, progname, message)
}

fn (mut logger Logger) open_logfile() ! {
	if logger.logdev.len == 0 {
		return
	}
	parent := os.dir(logger.logdev)
	if parent.len > 0 && parent != '.' {
		os.mkdir_all(parent)!
	}
	is_new := !os.exists(logger.logdev)
	mut file := os.open_append(logger.logdev)!
	if is_new && !logger.skip_header {
		file.write_string('# Logfile created on ${time.now()} by logger.rb/v${logger_version}\n')!
	}
	file.flush()
	file.close()
}

pub fn (mut logger Logger) reopen(logdev string, shift_age int, shift_size u64, shift_period string, shift_period_suffix string, binmode bool) !&Logger {
	target := if logdev.len > 0 { logdev } else { logger.logdev }
	if target.len == 0 {
		return &logger
	}
	logger.logdev = target
	logger.shift_age = shift_age
	logger.shift_size = if shift_size > 0 { shift_size } else { logger.shift_size }
	logger.shift_period = shift_period
	if shift_period_suffix.len > 0 {
		logger.shift_period_suffix = shift_period_suffix
	}
	logger.binmode = binmode
	logger.closed = false
	logger.open_logfile()!
	if shift_period.len > 0 {
		logger.next_rotate_time = logger_next_rotate_time(time.now(), shift_period)!
	}
	return &logger
}

pub fn (mut logger Logger) add(severity int, message ?ruby.Value, entry_progname ?string) bool {
	if logger.logdev.len == 0 || logger.closed || severity < logger.level() {
		return true
	}
	mut progname := logger.progname
	if supplied_progname := entry_progname {
		progname = supplied_progname
	}
	mut actual_message := ruby.string_value(progname)
	if supplied_message := message {
		actual_message = supplied_message
	} else if _ := entry_progname {
		// Ruby uses the explicit progname as the message, then restores the
		// logger's default program name.
		actual_message = ruby.string_value(progname)
		progname = logger.progname
	}
	line := logger.format_message(logger.format_severity(severity), time.now(), progname, actual_message)
	logger.monitor.lock()
	defer {
		logger.monitor.unlock()
	}
	logger.rotate_if_needed() or {
		if logger.reraise_write_errors { panic(err) }
		eprintln('log shifting failed. ${err}')
	}
	mut file := os.open_append(logger.logdev) or {
		if logger.reraise_write_errors { panic(err) }
		eprintln('log writing failed. ${err}')
		return true
	}
	file.write_string(line) or {
		file.close()
		if logger.reraise_write_errors { panic(err) }
		eprintln('log writing failed. ${err}')
		return true
	}
	file.flush()
	file.close()
	return true
}

pub fn (mut logger Logger) add_lazy(severity int, entry_progname ?string, producer fn() ruby.Value) bool {
	if logger.logdev.len == 0 || logger.closed || severity < logger.level() {
		return true
	}
	return logger.add(severity, producer(), entry_progname)
}

pub fn (mut logger Logger) log(severity int, message ?ruby.Value, progname ?string) bool {
	return logger.add(severity, message, progname)
}

pub fn (mut logger Logger) write_raw(message string) int {
	if logger.logdev.len == 0 || logger.closed {
		return 0
	}
	mut file := os.open_append(logger.logdev) or { return 0 }
	written := file.write_string(message) or {
		file.close()
		return 0
	}
	file.flush()
	file.close()
	return written
}

pub fn (mut logger Logger) debug(message ?ruby.Value, progname ?string) bool {
	return logger.add(logger_debug, message, progname)
}

pub fn (mut logger Logger) info(message ?ruby.Value, progname ?string) bool {
	return logger.add(logger_info, message, progname)
}

pub fn (mut logger Logger) warn(message ?ruby.Value, progname ?string) bool {
	return logger.add(logger_warn, message, progname)
}

pub fn (mut logger Logger) error(message ?ruby.Value, progname ?string) bool {
	return logger.add(logger_error, message, progname)
}

pub fn (mut logger Logger) fatal(message ?ruby.Value, progname ?string) bool {
	return logger.add(logger_fatal, message, progname)
}

pub fn (mut logger Logger) unknown(message ?ruby.Value, progname ?string) bool {
	return logger.add(logger_unknown, message, progname)
}

pub fn (mut logger Logger) close() {
	logger.closed = true
}

fn (mut logger Logger) rotate_if_needed() ! {
	if logger.shift_age > 0 && os.file_size(logger.logdev) > logger.shift_size {
		mut index := logger.shift_age - 3
		for index >= 0 {
			from := '${logger.logdev}.${index}'
			if os.exists(from) {
				os.rename(from, '${logger.logdev}.${index + 1}')!
			}
			index--
		}
		logger.rotate_to('${logger.logdev}.0')!
		return
	}
	if logger.shift_period.len > 0 && time.now().unix() >= logger.next_rotate_time.unix() {
		now := time.now()
		logger.next_rotate_time = logger_next_rotate_time(now, logger.shift_period)!
		period_end := logger_previous_period_end(now, logger.shift_period)!
		suffix := period_end.strftime(logger.shift_period_suffix)
		mut rotated := '${logger.logdev}.${suffix}'
		if os.exists(rotated) {
			for index in 1 .. 100 {
				rotated = '${logger.logdev}.${suffix}.${index}'
				if !os.exists(rotated) {
					break
				}
			}
		}
		logger.rotate_to(rotated)!
	}
}

fn (mut logger Logger) rotate_to(rotated string) ! {
	metadata := os.stat(logger.logdev)!
	os.rename(logger.logdev, rotated)!
	logger.open_logfile()!
	os.chmod(logger.logdev, int(metadata.mode)) or {}
	os.chown(logger.logdev, int(metadata.uid), int(metadata.gid)) or {}
}

fn logger_midnight(value time.Time) time.Time {
	return time.new(time.Time{
		year: value.year
		month: value.month
		day: value.day
		is_local: value.is_local
	})
}

fn logger_next_rotate_time(now time.Time, shift_age string) !time.Time {
	return match shift_age.to_lower() {
		'daily' { logger_midnight(now).add_days(1) }
		'weekly' { logger_midnight(now).add_days(7 - now.day_of_week() % 7) }
		'monthly' {
			probe := time.new(time.Time{
				year: now.year
				month: now.month
				day: 1
				is_local: now.is_local
			}).add_days(32)
			time.new(time.Time{
				year: probe.year
				month: probe.month
				day: 1
				is_local: now.is_local
			})
		}
		'now', 'everytime' { now }
		else {
			return error('invalid :shift_age `${shift_age}`, should be daily, weekly, monthly, or everytime')
		}
	}
}

fn logger_previous_period_end(now time.Time, shift_age string) !time.Time {
	if shift_age in ['now', 'everytime'] {
		return now
	}
	seconds_in_day := 86_400
	base := match shift_age.to_lower() {
		'daily' { logger_midnight(now).add_seconds(-seconds_in_day / 2) }
		'weekly' {
			logger_midnight(now).add_seconds(-(seconds_in_day * (now.day_of_week() % 7) + seconds_in_day / 2))
		}
		'monthly' {
			time.new(time.Time{
				year: now.year
				month: now.month
				day: 1
				is_local: now.is_local
			}).add_seconds(-seconds_in_day / 2)
		}
		else {
			return error('invalid :shift_age `${shift_age}`, should be daily, weekly, monthly, or everytime')
		}
	}
	return time.new(time.Time{
		year: base.year
		month: base.month
		day: base.day
		hour: 23
		minute: 59
		second: 59
		is_local: now.is_local
	})
}

fn coerce_logger_severity(value ruby.Value) !int {
	if value.type_name == 'Integer' {
		return int(value.as_int()!)
	}
	return match value.as_string().to_lower() {
		'debug' { logger_debug }
		'info' { logger_info }
		'warn' { logger_warn }
		'error' { logger_error }
		'fatal' { logger_fatal }
		'unknown' { logger_unknown }
		else { error('invalid log level: ${value.as_string()}') }
	}
}

fn logger_from_value(value ruby.Value) Logger {
	return Logger{
		base_level: (value.attribute('level') or { '0' }).int()
		progname: value.attribute('progname') or { '' }
		datetime_format: value.attribute('datetime_format') or { '' }
		logdev: value.attribute('logdev') or { '' }
		shift_age: (value.attribute('shift_age') or { '0' }).int()
		shift_period: value.attribute('shift_period') or { '' }
		shift_size: u64((value.attribute('shift_size') or { '1048576' }).i64())
		shift_period_suffix: value.attribute('shift_period_suffix') or { '%Y%m%d' }
		binmode: (value.attribute('binmode') or { 'false' }).bool()
		reraise_write_errors: (value.attribute('reraise_write_errors') or { 'false' }).bool()
		skip_header: (value.attribute('skip_header') or { 'false' }).bool()
		closed: (value.attribute('closed') or { 'false' }).bool()
		next_rotate_time: time.unix((value.attribute('next_rotate_time') or { '0' }).i64())
	}
}

fn logger_value(logger &Logger) ruby.Value {
	return ruby.structured_value('Logger', '#<Logger>', {
		'level':                logger.base_level.str()
		'progname':             logger.progname
		'datetime_format':      logger.datetime_format
		'logdev':               logger.logdev
		'shift_age':            logger.shift_age.str()
		'shift_period':         logger.shift_period
		'shift_size':           logger.shift_size.str()
		'shift_period_suffix':  logger.shift_period_suffix
		'binmode':              logger.binmode.str()
		'reraise_write_errors': logger.reraise_write_errors.str()
		'skip_header':          logger.skip_header.str()
		'closed':               logger.closed.str()
		'next_rotate_time':     logger.next_rotate_time.unix().str()
	})
}

fn wrapper_logger(args []ruby.Value) Logger {
	if args.len == 0 { panic('Logger method requires a logger') }
	return logger_from_value(args[0])
}

fn wrapper_optional_value(args []ruby.Value, index int) ?ruby.Value {
	if args.len <= index || args[index].type_name == 'NilClass' {
		return none
	}
	return args[index]
}

fn wrapper_optional_string(args []ruby.Value, index int) ?string {
	if args.len <= index || args[index].type_name == 'NilClass' {
		return none
	}
	return args[index].as_string()
}

fn logger_shorthand(args []ruby.Value, severity int) ruby.Value {
	if args.len == 0 { panic('Logger severity method requires a logger') }
	mut logger := logger_from_value(args[0])
	// Ruby's shorthand argument is a progname and its block supplies the
	// message. Boundary callers may pass the block result as the second value.
	message := wrapper_optional_value(args, 1)
	return ruby.bool_value(logger.add(severity, message, none))
}

// Ruby method `level` at line 383.
pub fn ruby_logger_l383_d1_level(args ...ruby.Value) ruby.Value {
	return ruby.int_value(wrapper_logger(args).level())
}

// Ruby method `level=(severity)` at line 399.
pub fn ruby_logger_l399_d2_level(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('Logger#level= requires a logger and severity') }
	mut logger := logger_from_value(args[0])
	logger.set_level(coerce_logger_severity(args[1]) or { panic(err) })
	return logger_value(&logger)
}

// Ruby method `with_level(severity)` at line 408.
pub fn ruby_logger_l408_d3_with_level(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('Logger#with_level requires a logger and severity') }
	// Boundary calls carry an already evaluated block result. The typed API
	// above performs the scoped override while executing its callback.
	coerce_logger_severity(args[1]) or { panic(err) }
	return if args.len > 2 { args[2] } else { args[0] }
}

// Ruby attr_accessor `attr_accessor :progname` at line 422.
pub fn ruby_logger_l422_d4_progname(args ...ruby.Value) ruby.Value {
	return ruby.string_value(wrapper_logger(args).progname)
}

// Ruby attr_accessor `attr_accessor :progname` at line 422.
pub fn ruby_logger_l422_d5_progname(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('Logger#progname= requires a logger and program name') }
	mut logger := logger_from_value(args[0])
	logger.progname = args[1].as_string()
	return logger_value(&logger)
}

// Ruby method `datetime_format=(datetime_format)` at line 432.
pub fn ruby_logger_l432_d6_datetime_format(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('Logger#datetime_format= requires a logger and format') }
	mut logger := logger_from_value(args[0])
	logger.datetime_format = args[1].as_string()
	return logger_value(&logger)
}

// Ruby method `datetime_format` at line 438.
pub fn ruby_logger_l438_d7_datetime_format(args ...ruby.Value) ruby.Value {
	return ruby.string_value(wrapper_logger(args).datetime_format)
}

// Ruby attr_accessor `attr_accessor :formatter` at line 473.
pub fn ruby_logger_l473_d8_formatter(args ...ruby.Value) ruby.Value {
	logger := wrapper_logger(args)
	if _ := logger.formatter {
		return ruby.object_value('Proc', '#<Proc:Logger::formatter>')
	}
	return ruby.object_value('NilClass', 'nil')
}

// Ruby attr_accessor `attr_accessor :formatter` at line 473.
pub fn ruby_logger_l473_d9_formatter(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('Logger#formatter= requires a logger and formatter') }
	// Function values cannot cross Value; typed callers set `Logger.formatter`
	// directly. Retain the logger state for nil/default boundary assignments.
	return args[0]
}

// Ruby alias `alias sev_threshold level` at line 475.
pub fn ruby_logger_l475_d10_sev_threshold(args ...ruby.Value) ruby.Value {
	return ruby_logger_l383_d1_level(...args)
}

// Ruby alias `alias sev_threshold= level=` at line 476.
pub fn ruby_logger_l476_d11_sev_threshold(args ...ruby.Value) ruby.Value {
	return ruby_logger_l399_d2_level(...args)
}

// Ruby method `debug?; level <= DEBUG; end` at line 482.
pub fn ruby_logger_l482_d12_debug(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(wrapper_logger(args).debug_enabled())
}

// Ruby method `debug!; self.level = DEBUG; end` at line 487.
pub fn ruby_logger_l487_d13_debug(args ...ruby.Value) ruby.Value {
	mut logger := wrapper_logger(args)
	logger.debug_bang()
	return logger_value(&logger)
}

// Ruby method `info?; level <= INFO; end` at line 493.
pub fn ruby_logger_l493_d14_info(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(wrapper_logger(args).info_enabled())
}

// Ruby method `info!; self.level = INFO; end` at line 498.
pub fn ruby_logger_l498_d15_info(args ...ruby.Value) ruby.Value {
	mut logger := wrapper_logger(args)
	logger.info_bang()
	return logger_value(&logger)
}

// Ruby method `warn?; level <= WARN; end` at line 504.
pub fn ruby_logger_l504_d16_warn(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(wrapper_logger(args).warn_enabled())
}

// Ruby method `warn!; self.level = WARN; end` at line 509.
pub fn ruby_logger_l509_d17_warn(args ...ruby.Value) ruby.Value {
	mut logger := wrapper_logger(args)
	logger.warn_bang()
	return logger_value(&logger)
}

// Ruby method `error?; level <= ERROR; end` at line 515.
pub fn ruby_logger_l515_d18_error(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(wrapper_logger(args).error_enabled())
}

// Ruby method `error!; self.level = ERROR; end` at line 520.
pub fn ruby_logger_l520_d19_error(args ...ruby.Value) ruby.Value {
	mut logger := wrapper_logger(args)
	logger.error_bang()
	return logger_value(&logger)
}

// Ruby method `fatal?; level <= FATAL; end` at line 526.
pub fn ruby_logger_l526_d20_fatal(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(wrapper_logger(args).fatal_enabled())
}

// Ruby method `fatal!; self.level = FATAL; end` at line 531.
pub fn ruby_logger_l531_d21_fatal(args ...ruby.Value) ruby.Value {
	mut logger := wrapper_logger(args)
	logger.fatal_bang()
	return logger_value(&logger)
}

// Ruby method `initialize(logdev, shift_age = 0, shift_size = 1048576, level: DEBUG,` at line 598.
pub fn ruby_logger_l598_d22_initialize(args ...ruby.Value) ruby.Value {
	logdev := if args.len > 0 { args[0].as_string() } else { '' }
	shift_age_value := if args.len > 1 { args[1] } else { ruby.int_value(0) }
	shift_age := if shift_age_value.type_name == 'Integer' {
		int(shift_age_value.as_int() or { 0 })
	} else {
		0
	}
	shift_period := if shift_age_value.type_name == 'Integer' {
		''
	} else {
		shift_age_value.as_string()
	}
	shift_size := if args.len > 2 { u64(args[2].as_int() or { 1_048_576 }) } else { 1_048_576 }
	level := if args.len > 3 {
		coerce_logger_severity(args[3]) or { panic(err) }
	} else {
		logger_debug
	}
	progname := if args.len > 4 { args[4].as_string() } else { '' }
	logger := new_logger(logdev, LoggerOptions{
		level: level
		progname: progname
		shift_age: shift_age
		shift_period: shift_period
		shift_size: shift_size
	}) or { panic(err) }
	return logger_value(&logger)
}

// Ruby method `reopen(logdev = nil, shift_age = nil, shift_size = nil, shift_period_suffix: nil, binmode: nil)` at line 642.
pub fn ruby_logger_l642_d23_reopen(args ...ruby.Value) ruby.Value {
	mut logger := wrapper_logger(args)
	logdev := if args.len > 1 { args[1].as_string() } else { '' }
	shift_age := if args.len > 2 {
		int(args[2].as_int() or { logger.shift_age })
	} else {
		logger.shift_age
	}
	shift_size := if args.len > 3 {
		u64(args[3].as_int() or { i64(logger.shift_size) })
	} else {
		logger.shift_size
	}
	shift_period := if args.len > 4 { args[4].as_string() } else { logger.shift_period }
	binmode := if args.len > 5 { args[5].as_bool() or { logger.binmode } } else { logger.binmode }
	logger.reopen(logdev, shift_age, shift_size, shift_period, logger.shift_period_suffix, binmode) or { panic(err) }
	return logger_value(&logger)
}

// Ruby method `add(severity, message = nil, progname = nil)` at line 675.
pub fn ruby_logger_l675_d24_add(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('Logger#add requires a logger and severity') }
	mut logger := logger_from_value(args[0])
	severity := int(args[1].as_int() or { logger_unknown })
	return ruby.bool_value(logger.add(severity, wrapper_optional_value(args, 2), wrapper_optional_string(args, 3)))
}

// Ruby alias `alias log add` at line 695.
pub fn ruby_logger_l695_d25_log(args ...ruby.Value) ruby.Value {
	return ruby_logger_l675_d24_add(...args)
}

// Ruby method `<<(msg)` at line 708.
pub fn ruby_logger_l708_d26_anonymous(args ...ruby.Value) ruby.Value {
	if args.len < 2 { panic('Logger#<< requires a logger and message') }
	mut logger := logger_from_value(args[0])
	return ruby.int_value(logger.write_raw(args[1].as_string()))
}

// Ruby method `debug(progname = nil, &block)` at line 714.
pub fn ruby_logger_l714_d27_debug(args ...ruby.Value) ruby.Value {
	return logger_shorthand(args, logger_debug)
}

// Ruby method `info(progname = nil, &block)` at line 720.
pub fn ruby_logger_l720_d28_info(args ...ruby.Value) ruby.Value {
	return logger_shorthand(args, logger_info)
}

// Ruby method `warn(progname = nil, &block)` at line 726.
pub fn ruby_logger_l726_d29_warn(args ...ruby.Value) ruby.Value {
	return logger_shorthand(args, logger_warn)
}

// Ruby method `error(progname = nil, &block)` at line 732.
pub fn ruby_logger_l732_d30_error(args ...ruby.Value) ruby.Value {
	return logger_shorthand(args, logger_error)
}

// Ruby method `fatal(progname = nil, &block)` at line 738.
pub fn ruby_logger_l738_d31_fatal(args ...ruby.Value) ruby.Value {
	return logger_shorthand(args, logger_fatal)
}

// Ruby method `unknown(progname = nil, &block)` at line 744.
pub fn ruby_logger_l744_d32_unknown(args ...ruby.Value) ruby.Value {
	return logger_shorthand(args, logger_unknown)
}

// Ruby method `close` at line 755.
pub fn ruby_logger_l755_d33_close(args ...ruby.Value) ruby.Value {
	mut logger := wrapper_logger(args)
	logger.close()
	return logger_value(&logger)
}

// Ruby method `format_severity(severity)` at line 764.
pub fn ruby_logger_l764_d34_format_severity(args ...ruby.Value) ruby.Value {
	if args.len == 0 { panic('Logger#format_severity requires a severity') }
	if args.len == 1 {
		return ruby.string_value(Logger{}.format_severity(int(args[0].as_int() or { logger_unknown })))
	}
	return ruby.string_value(wrapper_logger(args).format_severity(int(args[1].as_int() or {
		logger_unknown
	})))
}

// Ruby method `level_override` at line 769.
pub fn ruby_logger_l769_d35_level_override(args ...ruby.Value) ruby.Value {
	logger := wrapper_logger(args)
	overrides := logger.level_overrides[sync.thread_id()]
	return ruby.array_value(overrides.map(ruby.int_value(it)))
}

// Ruby method `level_key` at line 782.
pub fn ruby_logger_l782_d36_level_key(args ...ruby.Value) ruby.Value {
	return ruby.int_value(i64(sync.thread_id()))
}

// Ruby method `format_message(severity, datetime, progname, msg)` at line 786.
pub fn ruby_logger_l786_d37_format_message(args ...ruby.Value) ruby.Value {
	if args.len < 5 {
		panic('Logger#format_message requires a logger, severity, time, progname, and message')
	}
	logger := logger_from_value(args[0])
	at := if args[2].type_name == 'Integer' {
		time.unix(args[2].as_int() or { 0 })
	} else {
		time.parse_iso8601(args[2].as_string()) or { panic(err) }
	}
	return ruby.string_value(logger.format_message(args[1].as_string(), at, args[3].as_string(), args[4]))
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # logger.rb - simple logging utility
// 3: # Copyright (C) 2000-2003, 2005, 2008, 2011  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.
// 4: #
// 5: # Documentation:: NAKAMURA, Hiroshi and Gavin Sinclair
// 6: # License::
// 7: #   You can redistribute it and/or modify it under the same terms of Ruby's
// 8: #   license; either the dual license version in 2003, or any later version.
// 9: # Revision:: $Id$
// 10: #
// 11: # A simple system for logging messages.  See Logger for more documentation.
// 12:
// 13: require 'fiber'
// 14: require 'monitor'
// 15: require 'rbconfig'
// 16:
// 17: require_relative 'logger/version'
// 18: require_relative 'logger/formatter'
// 19: require_relative 'logger/log_device'
// 20: require_relative 'logger/severity'
// 21: require_relative 'logger/errors'
// 22:
// 23: # \Class \Logger provides a simple but sophisticated logging utility that
// 24: # you can use to create one or more
// 25: # {event logs}[https://en.wikipedia.org/wiki/Logging_(software)#Event_logs]
// 26: # for your program.
// 27: # Each such log contains a chronological sequence of entries
// 28: # that provides a record of the program's activities.
// 29: #
// 30: # == About the Examples
// 31: #
// 32: # All examples on this page assume that \Logger has been required:
// 33: #
// 34: #   require 'logger'
// 35: #
// 36: # == Synopsis
// 37: #
// 38: # Create a log with Logger.new:
// 39: #
// 40: #   # Single log file.
// 41: #   logger = Logger.new('t.log')
// 42: #   # Size-based rotated logging: 3 10-megabyte files.
// 43: #   logger = Logger.new('t.log', 3, 10485760)
// 44: #   # Period-based rotated logging: daily (also allowed: 'weekly', 'monthly').
// 45: #   logger = Logger.new('t.log', 'daily')
// 46: #   # Log to an IO stream.
// 47: #   logger = Logger.new($stdout)
// 48: #
// 49: # Add entries (level, message) with Logger#add:
// 50: #
// 51: #   logger.add(Logger::DEBUG, 'Maximal debugging info')
// 52: #   logger.add(Logger::INFO, 'Non-error information')
// 53: #   logger.add(Logger::WARN, 'Non-error warning')
// 54: #   logger.add(Logger::ERROR, 'Non-fatal error')
// 55: #   logger.add(Logger::FATAL, 'Fatal error')
// 56: #   logger.add(Logger::UNKNOWN, 'Most severe')
// 57: #
// 58: # Close the log with Logger#close:
// 59: #
// 60: #   logger.close
// 61: #
// 62: # == Entries
// 63: #
// 64: # You can add entries with method Logger#add:
// 65: #
// 66: #   logger.add(Logger::DEBUG, 'Maximal debugging info')
// 67: #   logger.add(Logger::INFO, 'Non-error information')
// 68: #   logger.add(Logger::WARN, 'Non-error warning')
// 69: #   logger.add(Logger::ERROR, 'Non-fatal error')
// 70: #   logger.add(Logger::FATAL, 'Fatal error')
// 71: #   logger.add(Logger::UNKNOWN, 'Most severe')
// 72: #
// 73: # These shorthand methods also add entries:
// 74: #
// 75: #   logger.debug('Maximal debugging info')
// 76: #   logger.info('Non-error information')
// 77: #   logger.warn('Non-error warning')
// 78: #   logger.error('Non-fatal error')
// 79: #   logger.fatal('Fatal error')
// 80: #   logger.unknown('Most severe')
// 81: #
// 82: # When you call any of these methods,
// 83: # the entry may or may not be written to the log,
// 84: # depending on the entry's severity and on the log level;
// 85: # see {Log Level}[rdoc-ref:Logger@Log+Level]
// 86: #
// 87: # An entry always has:
// 88: #
// 89: # - A severity (the required argument to #add).
// 90: # - An automatically created timestamp.
// 91: #
// 92: # And may also have:
// 93: #
// 94: # - A message.
// 95: # - A program name.
// 96: #
// 97: # Example:
// 98: #
// 99: #   logger = Logger.new($stdout)
// 100: #   logger.add(Logger::INFO, 'My message.', 'mung')
// 101: #   # => I, [2022-05-07T17:21:46.536234 #20536]  INFO -- mung: My message.
// 102: #
// 103: # The default format for an entry is:
// 104: #
// 105: #   "%s, [%s #%d] %5s -- %s: %s\n"
// 106: #
// 107: # where the values to be formatted are:
// 108: #
// 109: # - \Severity (one letter).
// 110: # - Timestamp.
// 111: # - Process id.
// 112: # - \Severity (word).
// 113: # - Program name.
// 114: # - Message.
// 115: #
// 116: # You can use a different entry format by:
// 117: #
// 118: # - Setting a custom format proc (affects following entries);
// 119: #   see {formatter=}[Logger.html#attribute-i-formatter].
// 120: # - Calling any of the methods above with a block
// 121: #   (affects only the one entry).
// 122: #   Doing so can have two benefits:
// 123: #
// 124: #   - Context: the block can evaluate the entire program context
// 125: #     and create a context-dependent message.
// 126: #   - Performance: the block is not evaluated unless the log level
// 127: #     permits the entry actually to be written:
// 128: #
// 129: #       logger.error { my_slow_message_generator }
// 130: #
// 131: #     Contrast this with the string form, where the string is
// 132: #     always evaluated, regardless of the log level:
// 133: #
// 134: #       logger.error("#{my_slow_message_generator}")
// 135: #
// 136: # === \Severity
// 137: #
// 138: # The severity of a log entry has two effects:
// 139: #
// 140: # - Determines whether the entry is selected for inclusion in the log;
// 141: #   see {Log Level}[rdoc-ref:Logger@Log+Level].
// 142: # - Indicates to any log reader (whether a person or a program)
// 143: #   the relative importance of the entry.
// 144: #
// 145: # === Timestamp
// 146: #
// 147: # The timestamp for a log entry is generated automatically
// 148: # when the entry is created.
// 149: #
// 150: # The logged timestamp is formatted by method
// 151: # {Time#strftime}[https://docs.ruby-lang.org/en/master/Time.html#method-i-strftime]
// 152: # using this format string:
// 153: #
// 154: #   '%Y-%m-%dT%H:%M:%S.%6N'
// 155: #
// 156: # Example:
// 157: #
// 158: #   logger = Logger.new($stdout)
// 159: #   logger.add(Logger::INFO)
// 160: #   # => I, [2022-05-07T17:04:32.318331 #20536]  INFO -- : nil
// 161: #
// 162: # You can set a different format using method #datetime_format=.
// 163: #
// 164: # === Message
// 165: #
// 166: # The message is an optional argument to an entry method:
// 167: #
// 168: #   logger = Logger.new($stdout)
// 169: #   logger.add(Logger::INFO, 'My message')
// 170: #   # => I, [2022-05-07T18:15:37.647581 #20536]  INFO -- : My message
// 171: #
// 172: # For the default entry formatter, <tt>Logger::Formatter</tt>,
// 173: # the message object may be:
// 174: #
// 175: # - A string: used as-is.
// 176: # - An Exception: <tt>message.message</tt> is used.
// 177: # - Anything else: <tt>message.inspect</tt> is used.
// 178: #
// 179: # *Note*: Logger::Formatter does not escape or sanitize
// 180: # the message passed to it.
// 181: # Developers should be aware that malicious data (user input)
// 182: # may be in the message, and should explicitly escape untrusted data.
// 183: #
// 184: # You can use a custom formatter to escape message data;
// 185: # see the example at {formatter=}[Logger.html#attribute-i-formatter].
// 186: #
// 187: # === Program Name
// 188: #
// 189: # The program name is an optional argument to an entry method:
// 190: #
// 191: #   logger = Logger.new($stdout)
// 192: #   logger.add(Logger::INFO, 'My message', 'mung')
// 193: #   # => I, [2022-05-07T18:17:38.084716 #20536]  INFO -- mung: My message
// 194: #
// 195: # The default program name for a new logger may be set in the call to
// 196: # Logger.new via optional keyword argument +progname+:
// 197: #
// 198: #   logger = Logger.new('t.log', progname: 'mung')
// 199: #
// 200: # The default program name for an existing logger may be set
// 201: # by a call to method #progname=:
// 202: #
// 203: #   logger.progname = 'mung'
// 204: #
// 205: # The current program name may be retrieved with method
// 206: # {progname}[Logger.html#attribute-i-progname]:
// 207: #
// 208: #   logger.progname # => "mung"
// 209: #
// 210: # == Log Level
// 211: #
// 212: # The log level setting determines whether an entry is actually
// 213: # written to the log, based on the entry's severity.
// 214: #
// 215: # These are the defined severities (least severe to most severe):
// 216: #
// 217: #   logger = Logger.new($stdout)
// 218: #   logger.add(Logger::DEBUG, 'Maximal debugging info')
// 219: #   # => D, [2022-05-07T17:57:41.776220 #20536] DEBUG -- : Maximal debugging info
// 220: #   logger.add(Logger::INFO, 'Non-error information')
// 221: #   # => I, [2022-05-07T17:59:14.349167 #20536]  INFO -- : Non-error information
// 222: #   logger.add(Logger::WARN, 'Non-error warning')
// 223: #   # => W, [2022-05-07T18:00:45.337538 #20536]  WARN -- : Non-error warning
// 224: #   logger.add(Logger::ERROR, 'Non-fatal error')
// 225: #   # => E, [2022-05-07T18:02:41.592912 #20536] ERROR -- : Non-fatal error
// 226: #   logger.add(Logger::FATAL, 'Fatal error')
// 227: #   # => F, [2022-05-07T18:05:24.703931 #20536] FATAL -- : Fatal error
// 228: #   logger.add(Logger::UNKNOWN, 'Most severe')
// 229: #   # => A, [2022-05-07T18:07:54.657491 #20536]   ANY -- : Most severe
// 230: #
// 231: # The default initial level setting is Logger::DEBUG, the lowest level,
// 232: # which means that all entries are to be written, regardless of severity:
// 233: #
// 234: #   logger = Logger.new($stdout)
// 235: #   logger.level # => 0
// 236: #   logger.add(0, "My message")
// 237: #   # => D, [2022-05-11T15:10:59.773668 #20536] DEBUG -- : My message
// 238: #
// 239: # You can specify a different setting in a new logger
// 240: # using keyword argument +level+ with an appropriate value:
// 241: #
// 242: #   logger = Logger.new($stdout, level: Logger::ERROR)
// 243: #   logger = Logger.new($stdout, level: 'error')
// 244: #   logger = Logger.new($stdout, level: :error)
// 245: #   logger.level # => 3
// 246: #
// 247: # With this level, entries with severity Logger::ERROR and higher
// 248: # are written, while those with lower severities are not written:
// 249: #
// 250: #   logger = Logger.new($stdout, level: Logger::ERROR)
// 251: #   logger.add(3)
// 252: #   # => E, [2022-05-11T15:17:20.933362 #20536] ERROR -- : nil
// 253: #   logger.add(2) # Silent.
// 254: #
// 255: # You can set the log level for an existing logger
// 256: # with method #level=:
// 257: #
// 258: #   logger.level = Logger::ERROR
// 259: #
// 260: # These shorthand methods also set the level:
// 261: #
// 262: #   logger.debug! # => 0
// 263: #   logger.info!  # => 1
// 264: #   logger.warn!  # => 2
// 265: #   logger.error! # => 3
// 266: #   logger.fatal! # => 4
// 267: #
// 268: # You can retrieve the log level with method #level.
// 269: #
// 270: #   logger.level = Logger::ERROR
// 271: #   logger.level # => 3
// 272: #
// 273: # These methods return whether a given
// 274: # level is to be written:
// 275: #
// 276: #   logger.level = Logger::ERROR
// 277: #   logger.debug? # => false
// 278: #   logger.info?  # => false
// 279: #   logger.warn?  # => false
// 280: #   logger.error? # => true
// 281: #   logger.fatal? # => true
// 282: #
// 283: # == Log File Rotation
// 284: #
// 285: # By default, a log file is a single file that grows indefinitely
// 286: # (until explicitly closed); there is no file rotation.
// 287: #
// 288: # To keep log files to a manageable size,
// 289: # you can use _log_ _file_ _rotation_, which uses multiple log files:
// 290: #
// 291: # - Each log file has entries for a non-overlapping
// 292: #   time interval.
// 293: # - Only the most recent log file is open and active;
// 294: #   the others are closed and inactive.
// 295: #
// 296: # === Size-Based Rotation
// 297: #
// 298: # For size-based log file rotation, call Logger.new with:
// 299: #
// 300: # - Argument +logdev+ as a file path.
// 301: # - Argument +shift_age+ with a positive integer:
// 302: #   the number of log files to be in the rotation.
// 303: # - Argument +shift_size+ as a positive integer:
// 304: #   the maximum size (in bytes) of each log file;
// 305: #   defaults to 1048576 (1 megabyte).
// 306: #
// 307: # Examples:
// 308: #
// 309: #   logger = Logger.new('t.log', 3)           # Three 1-megabyte files.
// 310: #   logger = Logger.new('t.log', 5, 10485760) # Five 10-megabyte files.
// 311: #
// 312: # For these examples, suppose:
// 313: #
// 314: #   logger = Logger.new('t.log', 3)
// 315: #
// 316: # Logging begins in the new log file, +t.log+;
// 317: # the log file is "full" and ready for rotation
// 318: # when a new entry would cause its size to exceed +shift_size+.
// 319: #
// 320: # The first time +t.log+ is full:
// 321: #
// 322: # - +t.log+ is closed and renamed to +t.log.0+.
// 323: # - A new file +t.log+ is opened.
// 324: #
// 325: # The second time +t.log+ is full:
// 326: #
// 327: # - +t.log.0 is renamed as +t.log.1+.
// 328: # - +t.log+ is closed and renamed to +t.log.0+.
// 329: # - A new file +t.log+ is opened.
// 330: #
// 331: # Each subsequent time that +t.log+ is full,
// 332: # the log files are rotated:
// 333: #
// 334: # - +t.log.1+ is removed.
// 335: # - +t.log.0 is renamed as +t.log.1+.
// 336: # - +t.log+ is closed and renamed to +t.log.0+.
// 337: # - A new file +t.log+ is opened.
// 338: #
// 339: # === Periodic Rotation
// 340: #
// 341: # For periodic rotation, call Logger.new with:
// 342: #
// 343: # - Argument +logdev+ as a file path.
// 344: # - Argument +shift_age+ as a string period indicator.
// 345: #
// 346: # Examples:
// 347: #
// 348: #   logger = Logger.new('t.log', 'daily')   # Rotate log files daily.
// 349: #   logger = Logger.new('t.log', 'weekly')  # Rotate log files weekly.
// 350: #   logger = Logger.new('t.log', 'monthly') # Rotate log files monthly.
// 351: #
// 352: # Example:
// 353: #
// 354: #   logger = Logger.new('t.log', 'daily')
// 355: #
// 356: # When the given period expires:
// 357: #
// 358: # - The base log file, +t.log+ is closed and renamed
// 359: #   with a date-based suffix such as +t.log.20220509+.
// 360: # - A new log file +t.log+ is opened.
// 361: # - Nothing is removed.
// 362: #
// 363: # The default format for the suffix is <tt>'%Y%m%d'</tt>,
// 364: # which produces a suffix similar to the one above.
// 365: # You can set a different format using create-time option
// 366: # +shift_period_suffix+;
// 367: # see details and suggestions at
// 368: # {Time#strftime}[https://docs.ruby-lang.org/en/master/Time.html#method-i-strftime].
// 369: #
// 370: class Logger
// 371:   _, name, rev = %w$Id$
// 372:   if name
// 373:     name = name.chomp(",v")
// 374:   else
// 375:     name = File.basename(__FILE__)
// 376:   end
// 377:   rev ||= "v#{VERSION}"
// 378:   ProgName = "#{name}/#{rev}"
// 379:
// 380:   include Severity
// 381:
// 382:   # Logging severity threshold (e.g. <tt>Logger::INFO</tt>).
// 383:   def level
// 384:     level_override[level_key] || @level
// 385:   end
// 386:
// 387:   # Sets the log level; returns +severity+.
// 388:   # See {Log Level}[rdoc-ref:Logger@Log+Level].
// 389:   #
// 390:   # Argument +severity+ may be an integer, a string, or a symbol:
// 391:   #
// 392:   #   logger.level = Logger::ERROR # => 3
// 393:   #   logger.level = 3             # => 3
// 394:   #   logger.level = 'error'       # => "error"
// 395:   #   logger.level = :error        # => :error
// 396:   #
// 397:   # Logger#sev_threshold= is an alias for Logger#level=.
// 398:   #
// 399:   def level=(severity)
// 400:     @level = Severity.coerce(severity)
// 401:   end
// 402:
// 403:   # Adjust the log level during the block execution for the current Fiber only
// 404:   #
// 405:   #   logger.with_level(:debug) do
// 406:   #     logger.debug { "Hello" }
// 407:   #   end
// 408:   def with_level(severity)
// 409:     prev, level_override[level_key] = level, Severity.coerce(severity)
// 410:     begin
// 411:       yield
// 412:     ensure
// 413:       if prev
// 414:         level_override[level_key] = prev
// 415:       else
// 416:         level_override.delete(level_key)
// 417:       end
// 418:     end
// 419:   end
// 420:
// 421:   # Program name to include in log messages.
// 422:   attr_accessor :progname
// 423:
// 424:   # Sets the date-time format.
// 425:   #
// 426:   # Argument +datetime_format+ should be either of these:
// 427:   #
// 428:   # - A string suitable for use as a format for method
// 429:   #   {Time#strftime}[https://docs.ruby-lang.org/en/master/Time.html#method-i-strftime].
// 430:   # - +nil+: the logger uses <tt>'%Y-%m-%dT%H:%M:%S.%6N'</tt>.
// 431:   #
// 432:   def datetime_format=(datetime_format)
// 433:     @default_formatter.datetime_format = datetime_format
// 434:   end
// 435:
// 436:   # Returns the date-time format; see #datetime_format=.
// 437:   #
// 438:   def datetime_format
// 439:     @default_formatter.datetime_format
// 440:   end
// 441:
// 442:   # Sets or retrieves the logger entry formatter proc.
// 443:   #
// 444:   # When +formatter+ is +nil+, the logger uses Logger::Formatter.
// 445:   #
// 446:   # When +formatter+ is a proc, a new entry is formatted by the proc,
// 447:   # which is called with four arguments:
// 448:   #
// 449:   # - +severity+: The severity of the entry.
// 450:   # - +time+: A Time object representing the entry's timestamp.
// 451:   # - +progname+: The program name for the entry.
// 452:   # - +msg+: The message for the entry (string or string-convertible object).
// 453:   #
// 454:   # The proc should return a string containing the formatted entry.
// 455:   #
// 456:   # This custom formatter uses
// 457:   # {String#dump}[https://docs.ruby-lang.org/en/master/String.html#method-i-dump]
// 458:   # to escape the message string:
// 459:   #
// 460:   #   logger = Logger.new($stdout, progname: 'mung')
// 461:   #   original_formatter = logger.formatter || Logger::Formatter.new
// 462:   #   logger.formatter = proc { |severity, time, progname, msg|
// 463:   #     original_formatter.call(severity, time, progname, msg.dump)
// 464:   #   }
// 465:   #   logger.add(Logger::INFO, "hello \n ''")
// 466:   #   logger.add(Logger::INFO, "\f\x00\xff\\\"")
// 467:   #
// 468:   # Output:
// 469:   #
// 470:   #   I, [2022-05-13T13:16:29.637488 #8492]  INFO -- mung: "hello \n ''"
// 471:   #   I, [2022-05-13T13:16:29.637610 #8492]  INFO -- mung: "\f\x00\xFF\\\""
// 472:   #
// 473:   attr_accessor :formatter
// 474:
// 475:   alias sev_threshold level
// 476:   alias sev_threshold= level=
// 477:
// 478:   # Returns +true+ if the log level allows entries with severity
// 479:   # Logger::DEBUG to be written, +false+ otherwise.
// 480:   # See {Log Level}[rdoc-ref:Logger@Log+Level].
// 481:   #
// 482:   def debug?; level <= DEBUG; end
// 483:
// 484:   # Sets the log level to Logger::DEBUG.
// 485:   # See {Log Level}[rdoc-ref:Logger@Log+Level].
// 486:   #
// 487:   def debug!; self.level = DEBUG; end
// 488:
// 489:   # Returns +true+ if the log level allows entries with severity
// 490:   # Logger::INFO to be written, +false+ otherwise.
// 491:   # See {Log Level}[rdoc-ref:Logger@Log+Level].
// 492:   #
// 493:   def info?; level <= INFO; end
// 494:
// 495:   # Sets the log level to Logger::INFO.
// 496:   # See {Log Level}[rdoc-ref:Logger@Log+Level].
// 497:   #
// 498:   def info!; self.level = INFO; end
// 499:
// 500:   # Returns +true+ if the log level allows entries with severity
// 501:   # Logger::WARN to be written, +false+ otherwise.
// 502:   # See {Log Level}[rdoc-ref:Logger@Log+Level].
// 503:   #
// 504:   def warn?; level <= WARN; end
// 505:
// 506:   # Sets the log level to Logger::WARN.
// 507:   # See {Log Level}[rdoc-ref:Logger@Log+Level].
// 508:   #
// 509:   def warn!; self.level = WARN; end
// 510:
// 511:   # Returns +true+ if the log level allows entries with severity
// 512:   # Logger::ERROR to be written, +false+ otherwise.
// 513:   # See {Log Level}[rdoc-ref:Logger@Log+Level].
// 514:   #
// 515:   def error?; level <= ERROR; end
// 516:
// 517:   # Sets the log level to Logger::ERROR.
// 518:   # See {Log Level}[rdoc-ref:Logger@Log+Level].
// 519:   #
// 520:   def error!; self.level = ERROR; end
// 521:
// 522:   # Returns +true+ if the log level allows entries with severity
// 523:   # Logger::FATAL to be written, +false+ otherwise.
// 524:   # See {Log Level}[rdoc-ref:Logger@Log+Level].
// 525:   #
// 526:   def fatal?; level <= FATAL; end
// 527:
// 528:   # Sets the log level to Logger::FATAL.
// 529:   # See {Log Level}[rdoc-ref:Logger@Log+Level].
// 530:   #
// 531:   def fatal!; self.level = FATAL; end
// 532:
// 533:   # :call-seq:
// 534:   #    Logger.new(logdev, shift_age = 0, shift_size = 1048576, **options)
// 535:   #
// 536:   # With the single argument +logdev+,
// 537:   # returns a new logger with all default options:
// 538:   #
// 539:   #   Logger.new('t.log') # => #<Logger:0x000001e685dc6ac8>
// 540:   #
// 541:   # Argument +logdev+ must be one of:
// 542:   #
// 543:   # - A string filepath: entries are to be written
// 544:   #   to the file at that path; if the file at that path exists,
// 545:   #   new entries are appended.
// 546:   # - An IO stream (typically <tt>$stdout</tt>, <tt>$stderr</tt>. or
// 547:   #   an open file): entries are to be written to the given stream.
// 548:   # - +nil+ or +File::NULL+: no entries are to be written.
// 549:   #
// 550:   # Argument +shift_age+ must be one of:
// 551:   #
// 552:   # - The number of log files to be in the rotation.
// 553:   #   See {Size-Based Rotation}[rdoc-ref:Logger@Size-Based+Rotation].
// 554:   # - A string period indicator.
// 555:   #   See {Periodic Rotation}[rdoc-ref:Logger@Periodic+Rotation].
// 556:   #
// 557:   # Argument +shift_size+ is the maximum size (in bytes) of each log file.
// 558:   # See {Size-Based Rotation}[rdoc-ref:Logger@Size-Based+Rotation].
// 559:   #
// 560:   # Examples:
// 561:   #
// 562:   #   Logger.new('t.log')
// 563:   #   Logger.new($stdout)
// 564:   #
// 565:   # The keyword options are:
// 566:   #
// 567:   # - +level+: sets the log level; default value is Logger::DEBUG.
// 568:   #   See {Log Level}[rdoc-ref:Logger@Log+Level]:
// 569:   #
// 570:   #     Logger.new('t.log', level: Logger::ERROR)
// 571:   #
// 572:   # - +progname+: sets the default program name; default is +nil+.
// 573:   #   See {Program Name}[rdoc-ref:Logger@Program+Name]:
// 574:   #
// 575:   #     Logger.new('t.log', progname: 'mung')
// 576:   #
// 577:   # - +formatter+: sets the entry formatter; default is +nil+.
// 578:   #   See {formatter=}[Logger.html#attribute-i-formatter].
// 579:   #
// 580:   # - +datetime_format+: sets the format for entry timestamp;
// 581:   #   default is +nil+.
// 582:   #   See #datetime_format=.
// 583:   #
// 584:   # - +binmode+: sets whether the logger writes in binary mode;
// 585:   #   default is +false+.
// 586:   #
// 587:   # - +shift_period_suffix+: sets the format for the filename suffix
// 588:   #   for periodic log file rotation; default is <tt>'%Y%m%d'</tt>.
// 589:   #   See {Periodic Rotation}[rdoc-ref:Logger@Periodic+Rotation].
// 590:   #
// 591:   # - +reraise_write_errors+: An array of exception classes, which will
// 592:   #   be reraised if there is an error when writing to the log device.
// 593:   #   The default is to swallow all exceptions raised.
// 594:   # - +skip_header+: If +true+, prevents the logger from writing a header
// 595:   #   when creating a new log file. The default is +false+, meaning
// 596:   #   the header will be written as usual.
// 597:   #
// 598:   def initialize(logdev, shift_age = 0, shift_size = 1048576, level: DEBUG,
// 599:                  progname: nil, formatter: nil, datetime_format: nil,
// 600:                  binmode: false, shift_period_suffix: '%Y%m%d',
// 601:                  reraise_write_errors: [], skip_header: false)
// 602:     self.level = level
// 603:     self.progname = progname
// 604:     @default_formatter = Formatter.new
// 605:     self.datetime_format = datetime_format
// 606:     self.formatter = formatter
// 607:     @logdev = nil
// 608:     @level_override = {}
// 609:     if logdev && logdev != File::NULL
// 610:       @logdev = LogDevice.new(logdev, shift_age: shift_age,
// 611:         shift_size: shift_size,
// 612:         shift_period_suffix: shift_period_suffix,
// 613:         binmode: binmode,
// 614:         reraise_write_errors: reraise_write_errors,
// 615:         skip_header: skip_header)
// 616:     end
// 617:   end
// 618:
// 619:   # Sets the logger's output stream:
// 620:   #
// 621:   # - If +logdev+ is +nil+, reopens the current output stream.
// 622:   # - If +logdev+ is a filepath, opens the indicated file for append.
// 623:   # - If +logdev+ is an IO stream
// 624:   #   (usually <tt>$stdout</tt>, <tt>$stderr</tt>, or an open File object),
// 625:   #   opens the stream for append.
// 626:   #
// 627:   # Example:
// 628:   #
// 629:   #   logger = Logger.new('t.log')
// 630:   #   logger.add(Logger::ERROR, 'one')
// 631:   #   logger.close
// 632:   #   logger.add(Logger::ERROR, 'two') # Prints 'log writing failed. closed stream'
// 633:   #   logger.reopen
// 634:   #   logger.add(Logger::ERROR, 'three')
// 635:   #   logger.close
// 636:   #   File.readlines('t.log')
// 637:   #   # =>
// 638:   #   # ["# Logfile created on 2022-05-12 14:21:19 -0500 by logger.rb/v1.5.0\n",
// 639:   #   #  "E, [2022-05-12T14:21:27.596726 #22428] ERROR -- : one\n",
// 640:   #   #  "E, [2022-05-12T14:23:05.847241 #22428] ERROR -- : three\n"]
// 641:   #
// 642:   def reopen(logdev = nil, shift_age = nil, shift_size = nil, shift_period_suffix: nil, binmode: nil)
// 643:     @logdev&.reopen(logdev, shift_age: shift_age, shift_size: shift_size,
// 644:                     shift_period_suffix: shift_period_suffix, binmode: binmode)
// 645:     self
// 646:   end
// 647:
// 648:   # Creates a log entry, which may or may not be written to the log,
// 649:   # depending on the entry's severity and on the log level.
// 650:   # See {Log Level}[rdoc-ref:Logger@Log+Level]
// 651:   # and {Entries}[rdoc-ref:Logger@Entries] for details.
// 652:   #
// 653:   # Examples:
// 654:   #
// 655:   #   logger = Logger.new($stdout, progname: 'mung')
// 656:   #   logger.add(Logger::INFO)
// 657:   #   logger.add(Logger::ERROR, 'No good')
// 658:   #   logger.add(Logger::ERROR, 'No good', 'gnum')
// 659:   #
// 660:   # Output:
// 661:   #
// 662:   #   I, [2022-05-12T16:25:31.469726 #36328]  INFO -- mung: mung
// 663:   #   E, [2022-05-12T16:25:55.349414 #36328] ERROR -- mung: No good
// 664:   #   E, [2022-05-12T16:26:35.841134 #36328] ERROR -- gnum: No good
// 665:   #
// 666:   # These convenience methods have implicit severity:
// 667:   #
// 668:   # - #debug.
// 669:   # - #info.
// 670:   # - #warn.
// 671:   # - #error.
// 672:   # - #fatal.
// 673:   # - #unknown.
// 674:   #
// 675:   def add(severity, message = nil, progname = nil)
// 676:     severity ||= UNKNOWN
// 677:     if @logdev.nil? or severity < level
// 678:       return true
// 679:     end
// 680:     if progname.nil?
// 681:       progname = @progname
// 682:     end
// 683:     if message.nil?
// 684:       if block_given?
// 685:         message = yield
// 686:       else
// 687:         message = progname
// 688:         progname = @progname
// 689:       end
// 690:     end
// 691:     @logdev.write(
// 692:       format_message(format_severity(severity), Time.now, progname, message))
// 693:     true
// 694:   end
// 695:   alias log add
// 696:
// 697:   # Writes the given +msg+ to the log with no formatting;
// 698:   # returns the number of characters written,
// 699:   # or +nil+ if no log device exists:
// 700:   #
// 701:   #   logger = Logger.new($stdout)
// 702:   #   logger << 'My message.' # => 10
// 703:   #
// 704:   # Output:
// 705:   #
// 706:   #   My message.
// 707:   #
// 708:   def <<(msg)
// 709:     @logdev&.write(msg)
// 710:   end
// 711:
// 712:   # Equivalent to calling #add with severity <tt>Logger::DEBUG</tt>.
// 713:   #
// 714:   def debug(progname = nil, &block)
// 715:     add(DEBUG, nil, progname, &block)
// 716:   end
// 717:
// 718:   # Equivalent to calling #add with severity <tt>Logger::INFO</tt>.
// 719:   #
// 720:   def info(progname = nil, &block)
// 721:     add(INFO, nil, progname, &block)
// 722:   end
// 723:
// 724:   # Equivalent to calling #add with severity <tt>Logger::WARN</tt>.
// 725:   #
// 726:   def warn(progname = nil, &block)
// 727:     add(WARN, nil, progname, &block)
// 728:   end
// 729:
// 730:   # Equivalent to calling #add with severity <tt>Logger::ERROR</tt>.
// 731:   #
// 732:   def error(progname = nil, &block)
// 733:     add(ERROR, nil, progname, &block)
// 734:   end
// 735:
// 736:   # Equivalent to calling #add with severity <tt>Logger::FATAL</tt>.
// 737:   #
// 738:   def fatal(progname = nil, &block)
// 739:     add(FATAL, nil, progname, &block)
// 740:   end
// 741:
// 742:   # Equivalent to calling #add with severity <tt>Logger::UNKNOWN</tt>.
// 743:   #
// 744:   def unknown(progname = nil, &block)
// 745:     add(UNKNOWN, nil, progname, &block)
// 746:   end
// 747:
// 748:   # Closes the logger; returns +nil+:
// 749:   #
// 750:   #   logger = Logger.new('t.log')
// 751:   #   logger.close       # => nil
// 752:   #   logger.info('foo') # Prints "log writing failed. closed stream"
// 753:   #
// 754:   # Related: Logger#reopen.
// 755:   def close
// 756:     @logdev&.close
// 757:   end
// 758:
// 759: private
// 760:
// 761:   # \Severity label for logging (max 5 chars).
// 762:   SEV_LABEL = %w(DEBUG INFO WARN ERROR FATAL ANY).freeze
// 763:
// 764:   def format_severity(severity)
// 765:     SEV_LABEL[severity] || 'ANY'
// 766:   end
// 767:
// 768:   # Guarantee the existence of this ivar even when subclasses don't call the superclass constructor.
// 769:   def level_override
// 770:     unless defined?(@level_override)
// 771:       bad = self.class.instance_method(:initialize)
// 772:       file, line = bad.source_location
// 773:       Kernel.warn <<~";;;", uplevel: 2
// 774:         Logger not initialized properly
// 775:         #{file}:#{line}: info: #{bad.owner}\##{bad.name}: \
// 776:         does not call super probably
// 777:       ;;;
// 778:     end
// 779:     @level_override ||= {}
// 780:   end
// 781:
// 782:   def level_key
// 783:     Fiber.current
// 784:   end
// 785:
// 786:   def format_message(severity, datetime, progname, msg)
// 787:     (@formatter || @default_formatter).call(severity, datetime, progname, msg)
// 788:   end
// 789: end
