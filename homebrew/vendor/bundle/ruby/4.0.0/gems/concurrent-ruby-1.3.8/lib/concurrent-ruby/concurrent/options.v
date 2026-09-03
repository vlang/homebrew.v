module concurrent

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/options.rb`.
// The original source is retained below until every stub has a typed V body.
pub fn executor_from_identifier(identifier brew_runtime.Value) !brew_runtime.Value {
	name := identifier.as_string().trim_left(':').to_lower()
	return match name {
		'fast' { brew_runtime.object_value('Concurrent::ExecutorService', 'global_fast_executor') }
		'io' { brew_runtime.object_value('Concurrent::ExecutorService', 'global_io_executor') }
		'immediate' {
			brew_runtime.object_value('Concurrent::ImmediateExecutor', 'global_immediate_executor')
		}
		else {
			if identifier.type_name.ends_with('ExecutorService') || identifier.type_name == 'Concurrent::ImmediateExecutor' {
				identifier
			} else {
				return error("executor not recognized by '${identifier.as_string()}'")
			}
		}
	}
}

pub fn executor_from_options(options map[string]brew_runtime.Value) !brew_runtime.Value {
	if 'executor' !in options || options['executor'].type_name == 'NilClass' {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return executor_from_identifier(options['executor'])!
}

// Ruby method `self.executor_from_options(opts = {}) # :nodoc:` at line 19.
pub fn ruby_options_l19_d1_self_executor_from_options(args ...brew_runtime.Value) brew_runtime.Value {
	options := if args.len == 0 {
		map[string]brew_runtime.Value{}
	} else {
		args[0].as_map() or {
			panic(err)
		}
	}
	return executor_from_options(options) or { panic(err) }
}

// Ruby method `self.executor(executor_identifier)` at line 27.
pub fn ruby_options_l27_d2_self_executor(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Concurrent::Options.executor requires an identifier')
	}
	return executor_from_identifier(args[0]) or { panic(err) }
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/configuration'
// 2:
// 3: module Concurrent
// 4:
// 5:   # @!visibility private
// 6:   module Options
// 7:
// 8:     # Get the requested `Executor` based on the values set in the options hash.
// 9:     #
// 10:     # @param [Hash] opts the options defining the requested executor
// 11:     # @option opts [Executor] :executor when set use the given `Executor` instance.
// 12:     #   Three special values are also supported: `:fast` returns the global fast executor,
// 13:     #   `:io` returns the global io executor, and `:immediate` returns a new
// 14:     #   `ImmediateExecutor` object.
// 15:     #
// 16:     # @return [Executor, nil] the requested thread pool, or nil when no option specified
// 17:     #
// 18:     # @!visibility private
// 19:     def self.executor_from_options(opts = {}) # :nodoc:
// 20:       if identifier = opts.fetch(:executor, nil)
// 21:         executor(identifier)
// 22:       else
// 23:         nil
// 24:       end
// 25:     end
// 26:
// 27:     def self.executor(executor_identifier)
// 28:       case executor_identifier
// 29:       when :fast
// 30:         Concurrent.global_fast_executor
// 31:       when :io
// 32:         Concurrent.global_io_executor
// 33:       when :immediate
// 34:         Concurrent.global_immediate_executor
// 35:       when Concurrent::ExecutorService
// 36:         executor_identifier
// 37:       else
// 38:         raise ArgumentError, "executor not recognized by '#{executor_identifier}'"
// 39:       end
// 40:     end
// 41:   end
// 42: end
