module patchelf

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/patchelf-1.6.2/lib/patchelf/logger.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum PatchElfLogLevel {
	debug
	info
	warn
	error
}

pub struct PatchElfLogger {
pub mut:
	level PatchElfLogLevel
}

pub fn patch_elf_log_level(name string) ?PatchElfLogLevel {
	return match name.trim_string_left(':').to_lower() {
		'debug', '0' { .debug }
		'info', '1' { .info }
		'warn', '2' { .warn }
		'error', '3' { .error }
		else { none }
	}
}

pub fn format_patch_elf_log(level PatchElfLogLevel, message string, color bool) string {
	severity := level.str().to_upper()
	return '[${patch_elf_colorize(severity, level.str(), color)}] ${message}\n'
}

pub fn (logger &PatchElfLogger) write(level PatchElfLogLevel, message string, color bool) ?string {
	if int(level) < int(logger.level) {
		return none
	}
	return format_patch_elf_log(level, message, color)
}

pub fn (logger &PatchElfLogger) log_to_stderr(level PatchElfLogLevel, message string) {
	line := logger.write(level, message, patch_elf_color_enabled()) or { return }
	eprint(line)
}

// Ruby define_method `define_method(sym) do |msg|` at line 19.
pub fn ruby_logger_l19_d1_sym(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('PatchELF::Logger method requires a message')
	}
	mut logger := PatchElfLogger{}
	if args.len > 1 {
		operation := args[0].as_string().trim_string_left(':')
		if operation == 'level=' {
			logger.level = patch_elf_log_level(args[1].as_string()) or {
				panic('unknown PatchELF logger level ${args[1].as_string()}')
			}
		} else {
			level := patch_elf_log_level(operation) or {
				panic('unknown PatchELF logger operation ${operation}')
			}
			logger.log_to_stderr(level, args[1].as_string())
		}
	} else {
		logger.log_to_stderr(.info, args[0].as_string())
	}
	return brew_runtime.object_value('NilClass', 'nil')
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: require 'logger'
// 4:
// 5: require 'patchelf/helper'
// 6:
// 7: module PatchELF
// 8:   # A logger for internal usage.
// 9:   module Logger
// 10:     module_function
// 11:
// 12:     @logger = ::Logger.new($stderr).tap do |log|
// 13:       log.formatter = proc do |severity, _datetime, _progname, msg|
// 14:         "[#{PatchELF::Helper.colorize(severity, severity.downcase.to_sym)}] #{msg}\n"
// 15:       end
// 16:     end
// 17:
// 18:     %i[debug info warn error level=].each do |sym|
// 19:       define_method(sym) do |msg|
// 20:         @logger.__send__(sym, msg)
// 21:         nil
// 22:       end
// 23:     end
// 24:   end
// 25: end
