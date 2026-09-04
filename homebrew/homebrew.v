module homebrew

import ruby
import time

// Translated from Homebrew/brew `homebrew.rb`.
// The original source is retained below until every stub has a typed V body.
pub type HomebrewRequireLoader = fn(string) !

pub type HomebrewSystemRunner = fn(HomebrewSystemRequest) !ruby.CommandResult

pub type DumpStatsMatcher = fn(string) bool

pub type DumpStatsMethod = fn() !string

pub struct HomebrewSystemRequest {
pub:
	command     ?string
	argv0       ?string
	arguments   []string
	environment map[string]string
	chdir       ?string
	quiet       bool
}

pub struct DumpStatsState {
pub mut:
	injected_methods []string
	times            map[string]f64
}

fn default_homebrew_system_runner(request HomebrewSystemRequest) !ruby.CommandResult {
	command := request.command or { return ruby.CommandResult{ exit_code: 1 } }
	if request.environment.len > 0 {
		return ruby.run_command_with_environment(command, request.arguments, request.environment)
	}
	return ruby.run_command(command, request.arguments)
}

pub fn homebrew_require(path ?string, loader HomebrewRequireLoader) bool {
	value := path or { return false }
	loader(value) or { return false }
	return true
}

pub fn homebrew_system_with_runner(request HomebrewSystemRequest,
	runner HomebrewSystemRunner) bool {
	result := runner(request) or { return false }
	if !request.quiet && result.output != '' {
		print(result.output)
	}
	return result.exit_code == 0
}

pub fn homebrew_system(request HomebrewSystemRequest) bool {
	return homebrew_system_with_runner(request, default_homebrew_system_runner)
}

pub fn homebrew_safe_system(request HomebrewSystemRequest) ! {
	if homebrew_system(request) {
		return
	}
	command := request.command or { '' }
	mut command_line := [command]
	command_line << request.arguments
	return error('Failure while executing: ${command_line.join(' ')}')
}

pub fn inject_dump_stats(mut state DumpStatsState, method_names []string,
	matcher DumpStatsMatcher) []string {
	mut wrapped := []string{}
	for name in method_names {
		if !matcher(name) || name in state.injected_methods {
			continue
		}
		state.injected_methods << name
		wrapped << name
	}
	return wrapped
}

pub fn run_dump_stats_method(mut state DumpStatsState, name string,
	method DumpStatsMethod) !string {
	started := time.now()
	result := method() or {
		elapsed := f64(time.since(started)) / f64(time.second)
		state.times[name] = (state.times[name] or { 0.0 }) + elapsed
		return err
	}
	elapsed := f64(time.since(started)) / f64(time.second)
	state.times[name] = (state.times[name] or { 0.0 }) + elapsed
	return result
}

// Ruby method `self.require?(path)` at line 10.
pub fn ruby_homebrew_l10_d1_self_require(path ?string, loader HomebrewRequireLoader) bool {
	return homebrew_require(path, loader)
}

// Ruby method `self._system(cmd, argv0 = nil, *args, **options, &_block)` at line 38.
pub fn ruby_homebrew_l38_d2_self_system(request HomebrewSystemRequest) bool {
	return homebrew_system(request)
}

// Ruby method `self.system(cmd, argv0 = nil, *args, **options)` at line 67.
pub fn ruby_homebrew_l67_d3_self_system(request HomebrewSystemRequest) bool {
	return homebrew_system(request)
}

// Ruby method `self.safe_system(cmd, argv0 = nil, *args, **options)` at line 84.
pub fn ruby_homebrew_l84_d4_self_safe_system(request HomebrewSystemRequest) ! {
	homebrew_safe_system(request)!
}

// Ruby method `self.quiet_system(cmd, argv0 = nil, *args)` at line 97.
pub fn ruby_homebrew_l97_d5_self_quiet_system(request HomebrewSystemRequest) bool {
	return homebrew_system(HomebrewSystemRequest{
		...request
		quiet: true
	})
}

// Ruby method `self.inject_dump_stats!(the_module, pattern)` at line 109.
pub fn ruby_homebrew_l109_d6_self_inject_dump_stats(mut state DumpStatsState,
	method_names []string, matcher DumpStatsMatcher) []string {
	return inject_dump_stats(mut state, method_names, matcher)
}

// Ruby define_method `wrapper.define_method(name) do |*args, &block|` at line 118.
pub fn ruby_homebrew_l118_d7_name(mut state DumpStatsState, name string,
	method DumpStatsMethod) !string {
	return run_dump_stats_method(mut state, name, method)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "context"
// 5:
// 6: module Homebrew
// 7:   extend Context
// 8:
// 9:   sig { params(path: T.nilable(T.any(String, Pathname))).returns(T::Boolean) }
// 10:   def self.require?(path)
// 11:     return false if path.nil?
// 12:
// 13:     if defined?(Warnings)
// 14:       # Work around require warning when done repeatedly:
// 15:       # https://bugs.ruby-lang.org/issues/21091
// 16:       Warnings.ignore(/already initialized constant/, /previous definition of/) do
// 17:         require path.to_s
// 18:       end
// 19:     else
// 20:       require path.to_s
// 21:     end
// 22:     true
// 23:   rescue LoadError
// 24:     false
// 25:   end
// 26:
// 27:   # Need to keep this naming as-is for backwards compatibility.
// 28:   # rubocop:disable Naming/PredicateMethod
// 29:   sig {
// 30:     params(
// 31:       cmd:     T.nilable(T.any(Pathname, String, [String, String], T::Hash[String, T.nilable(String)])),
// 32:       argv0:   T.nilable(T.any(Pathname, String, [String, String])),
// 33:       args:    T.any(Pathname, String),
// 34:       options: T.untyped,
// 35:       _block:  T.nilable(T.proc.void),
// 36:     ).returns(T::Boolean)
// 37:   }
// 38:   def self._system(cmd, argv0 = nil, *args, **options, &_block)
// 39:     pid = fork do
// 40:       yield if block_given?
// 41:       args.map!(&:to_s)
// 42:       begin
// 43:         if argv0
// 44:           exec(cmd, argv0, *args, **options)
// 45:         else
// 46:           exec(cmd, *args, **options)
// 47:         end
// 48:       rescue
// 49:         nil
// 50:       end
// 51:       exit! 1 # never gets here unless exec failed
// 52:     end
// 53:     Process.wait(pid)
// 54:     $CHILD_STATUS.success? || false
// 55:   end
// 56:   private_class_method :_system
// 57:   # rubocop:enable Naming/PredicateMethod
// 58:
// 59:   sig {
// 60:     params(
// 61:       cmd:     T.any(Pathname, String, [String, String], T::Hash[String, T.nilable(String)]),
// 62:       argv0:   T.nilable(T.any(Pathname, String, [String, String])),
// 63:       args:    T.any(Pathname, String),
// 64:       options: T.untyped,
// 65:     ).returns(T::Boolean)
// 66:   }
// 67:   def self.system(cmd, argv0 = nil, *args, **options)
// 68:     if verbose?
// 69:       out = (options[:out] == :err) ? $stderr : $stdout
// 70:       out.puts "#{cmd} #{args * " "}".gsub(RUBY_PATH.to_s, "ruby")
// 71:                                      .gsub($LOAD_PATH.join(File::PATH_SEPARATOR).to_s, "$LOAD_PATH")
// 72:     end
// 73:     _system(cmd, argv0, *args, **options)
// 74:   end
// 75:
// 76:   sig {
// 77:     params(
// 78:       cmd:     T.nilable(T.any(Pathname, String, [String, String], T::Hash[String, T.nilable(String)])),
// 79:       argv0:   T.nilable(T.any(Pathname, String, [String, String])),
// 80:       args:    T.nilable(T.any(Pathname, String)),
// 81:       options: T.untyped,
// 82:     ).void
// 83:   }
// 84:   def self.safe_system(cmd, argv0 = nil, *args, **options)
// 85:     return if system(cmd, argv0, *args, **options)
// 86:
// 87:     raise ErrorDuringExecution.new([cmd, argv0, *args], status: $CHILD_STATUS)
// 88:   end
// 89:
// 90:   sig {
// 91:     params(
// 92:       cmd:   T.nilable(T.any(Pathname, String, [String, String], T::Hash[String, T.nilable(String)])),
// 93:       argv0: T.nilable(T.any(String, [String, String])),
// 94:       args:  T.any(Pathname, String),
// 95:     ).returns(T::Boolean)
// 96:   }
// 97:   def self.quiet_system(cmd, argv0 = nil, *args)
// 98:     _system(cmd, argv0, *args) do
// 99:       # Redirect output streams to `/dev/null` instead of closing as some programs
// 100:       # will fail to execute if they can't write to an open stream.
// 101:       $stdout.reopen(File::NULL)
// 102:       $stderr.reopen(File::NULL)
// 103:     end
// 104:   end
// 105:
// 106:   # Uses $times global to share timing data between wrapped methods and the at_exit reporter.
// 107:   # rubocop:disable Style/GlobalVars
// 108:   sig { params(the_module: T::Module[T.anything], pattern: Regexp).void }
// 109:   def self.inject_dump_stats!(the_module, pattern)
// 110:     @injected_dump_stat_modules ||= T.let({}, T.nilable(T::Hash[T::Module[T.anything], T::Array[Symbol]]))
// 111:     @injected_dump_stat_modules[the_module] ||= []
// 112:     injected_methods = @injected_dump_stat_modules.fetch(the_module)
// 113:     wrapper = Module.new
// 114:     the_module.instance_methods.grep(pattern).each do |name|
// 115:       next if injected_methods.include? name
// 116:
// 117:       injected_methods << name
// 118:       wrapper.define_method(name) do |*args, &block|
// 119:         require "time"
// 120:
// 121:         time = Time.now
// 122:
// 123:         begin
// 124:           super(*args, &block)
// 125:         ensure
// 126:           $times[name] ||= 0
// 127:           $times[name] += Time.now - time
// 128:         end
// 129:       end
// 130:     end
// 131:     the_module.prepend(wrapper)
// 132:
// 133:     return unless $times.nil?
// 134:
// 135:     $times = {}
// 136:     at_exit do
// 137:       col_width = [$times.keys.map(&:size).max.to_i + 2, 15].max
// 138:       $times.sort_by { |_k, v| v }.each do |method, time|
// 139:         puts format("%<method>-#{col_width}s %<time>0.4f sec", method: "#{method}:", time:)
// 140:       end
// 141:     end
// 142:   end
// 143:   # rubocop:enable Style/GlobalVars
// 144: end
