module prof

import brew_runtime

// Translated from Homebrew/brew `prof/vernier_fork_guard.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.without_running_collector(&block)` at line 15.
pub fn ruby_vernier_fork_guard_l15_d1_self_without_running_collector(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.without_running_collector', ...args)
}

// Ruby method `self.stop_running_collector` at line 48.
pub fn ruby_vernier_fork_guard_l48_d2_self_stop_running_collector(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.stop_running_collector', ...args)
}

// Ruby alias_method `alias_method :homebrew_vernier_fork_guard_fork, :fork` at line 67.
pub fn ruby_vernier_fork_guard_l67_d3_homebrew_vernier_fork_guard_fork(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('homebrew_vernier_fork_guard_fork', ...args)
}

// Ruby alias_method `alias_method :homebrew_vernier_fork_guard_exec, :exec` at line 68.
pub fn ruby_vernier_fork_guard_l68_d4_homebrew_vernier_fork_guard_exec(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('homebrew_vernier_fork_guard_exec', ...args)
}

// Ruby method `fork(&block)` at line 70.
pub fn ruby_vernier_fork_guard_l70_d5_fork(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fork', ...args)
}

// Ruby method `exec(...)` at line 76.
pub fn ruby_vernier_fork_guard_l76_d6_exec(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('exec', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "sorbet-runtime"
// 5:
// 6: module Homebrew
// 7:   module VernierForkGuard
// 8:     # This file is required before Homebrew's usual command boot has installed
// 9:     # the global `sig` helper.
// 10:     # rubocop:disable Sorbet/RedundantExtendTSig
// 11:     extend T::Sig
// 12:     # rubocop:enable Sorbet/RedundantExtendTSig
// 13:
// 14:     sig { params(block: T.nilable(T.proc.returns(T.untyped))).returns(T.untyped) }
// 15:     def self.without_running_collector(&block)
// 16:       raise ArgumentError, "block required" unless block
// 17:
// 18:       return yield unless Object.const_defined?(:Vernier)
// 19:
// 20:       # `Vernier::Autorun` is created by `-r vernier/autorun`; Sorbet's RBI for
// 21:       # the gem does not expose it, so keep this lookup dynamic.
// 22:       # rubocop:disable Sorbet/ConstantsFromStrings
// 23:       autorun = T.let(Object.const_get(:Vernier).const_get(:Autorun), T.untyped)
// 24:       # rubocop:enable Sorbet/ConstantsFromStrings
// 25:       return yield unless autorun.running?
// 26:
// 27:       # Vernier registers internal thread hooks and owns native mutexes while the
// 28:       # collector is running. Forking with that state active can leave the child
// 29:       # process stuck before it reaches exec.
// 30:       #
// 31:       # Stopping here loses samples taken during fork setup, but that is a better
// 32:       # tradeoff than hanging the profiled command. The common process helpers use
// 33:       # spawn while `HOMEBREW_SPAWN_SYSTEM` is set, so this remains a fallback.
// 34:       autorun.collector.stop
// 35:       autorun.collector = nil
// 36:       pid = nil
// 37:       begin
// 38:         pid = yield
// 39:       ensure
// 40:         # Restart only in the parent. In the child, `yield` returns nil and exec
// 41:         # should happen immediately through the original fork path.
// 42:         autorun.start if pid && !autorun.running?
// 43:       end
// 44:       pid
// 45:     end
// 46:
// 47:     sig { void }
// 48:     def self.stop_running_collector
// 49:       return unless Object.const_defined?(:Vernier)
// 50:
// 51:       # `Vernier::Autorun` is absent from the gem's RBI, so look it up dynamically.
// 52:       # rubocop:disable Sorbet/ConstantsFromStrings
// 53:       autorun = T.let(Object.const_get(:Vernier).const_get(:Autorun), T.untyped)
// 54:       # rubocop:enable Sorbet/ConstantsFromStrings
// 55:       return unless autorun.running?
// 56:
// 57:       autorun.stop
// 58:     end
// 59:   end
// 60: end
// 61:
// 62: # Keep this monkey-patch local to `brew prof --vernier`: this file is only
// 63: # loaded by that command after `vernier/autorun`.
// 64: Kernel.module_eval <<~RUBY, __FILE__, __LINE__ + 1
// 65:   # These aliases let us wrap direct process replacement paths without changing
// 66:   # unrelated command code paths.
// 67:   alias_method :homebrew_vernier_fork_guard_fork, :fork
// 68:   alias_method :homebrew_vernier_fork_guard_exec, :exec
// 69:
// 70:   def fork(&block)
// 71:     Homebrew::VernierForkGuard.without_running_collector do
// 72:       homebrew_vernier_fork_guard_fork(&block)
// 73:     end
// 74:   end
// 75:
// 76:   def exec(...)
// 77:     # `brew ruby` reaches here in the profiled process. Stop and write the
// 78:     # Vernier result before replacing the process so no SIGPROF state carries
// 79:     # into the new executable.
// 80:     Homebrew::VernierForkGuard.stop_running_collector
// 81:     homebrew_vernier_fork_guard_exec(...)
// 82:   end
// 83: RUBY
