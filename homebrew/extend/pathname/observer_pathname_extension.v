module pathname

import brew_runtime

// Translated from Homebrew/brew `extend/pathname/observer_pathname_extension.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `n` at line 15.
pub fn ruby_observer_pathname_extension_l15_d1_n(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('n', ...args)
}

// Ruby attr_writer `attr_writer :n` at line 20.
pub fn ruby_observer_pathname_extension_l20_d2_n(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('n=', ...args)
}

// Ruby method `d` at line 23.
pub fn ruby_observer_pathname_extension_l23_d3_d(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('d', ...args)
}

// Ruby attr_writer `attr_writer :d` at line 28.
pub fn ruby_observer_pathname_extension_l28_d4_d(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('d=', ...args)
}

// Ruby method `reset_counts!` at line 31.
pub fn ruby_observer_pathname_extension_l31_d5_reset_counts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reset_counts!', ...args)
}

// Ruby method `total` at line 38.
pub fn ruby_observer_pathname_extension_l38_d6_total(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('total', ...args)
}

// Ruby method `counts` at line 43.
pub fn ruby_observer_pathname_extension_l43_d7_counts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('counts', ...args)
}

// Ruby method `verbose?` at line 51.
pub fn ruby_observer_pathname_extension_l51_d8_verbose(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('verbose?', ...args)
}

// Ruby method `unlink` at line 68.
pub fn ruby_observer_pathname_extension_l68_d9_unlink(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('unlink', ...args)
}

// Ruby method `mkpath` at line 75.
pub fn ruby_observer_pathname_extension_l75_d10_mkpath(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('mkpath', ...args)
}

// Ruby method `rmdir` at line 81.
pub fn ruby_observer_pathname_extension_l81_d11_rmdir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rmdir', ...args)
}

// Ruby method `make_relative_symlink(src)` at line 88.
pub fn ruby_observer_pathname_extension_l88_d12_make_relative_symlink(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('make_relative_symlink', ...args)
}

// Ruby method `install_info` at line 95.
pub fn ruby_observer_pathname_extension_l95_d13_install_info(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_info', ...args)
}

// Ruby method `uninstall_info` at line 101.
pub fn ruby_observer_pathname_extension_l101_d14_uninstall_info(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uninstall_info', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "context"
// 5:
// 6: module ObserverPathnameExtension
// 7:   extend T::Helpers
// 8:
// 9:   requires_ancestor { Pathname }
// 10:
// 11:   class << self
// 12:     include Context
// 13:
// 14:     sig { returns(Integer) }
// 15:     def n
// 16:       @n ||= 0
// 17:     end
// 18:
// 19:     sig { params(n: Integer).void }
// 20:     attr_writer :n
// 21:
// 22:     sig { returns(Integer) }
// 23:     def d
// 24:       @d ||= 0
// 25:     end
// 26:
// 27:     sig { params(d: Integer).void }
// 28:     attr_writer :d
// 29:
// 30:     sig { void }
// 31:     def reset_counts!
// 32:       @n = T.let(0, T.nilable(Integer))
// 33:       @d = T.let(0, T.nilable(Integer))
// 34:       @put_verbose_trimmed_warning = T.let(false, T.nilable(T::Boolean))
// 35:     end
// 36:
// 37:     sig { returns(Integer) }
// 38:     def total
// 39:       n + d
// 40:     end
// 41:
// 42:     sig { returns([Integer, Integer]) }
// 43:     def counts
// 44:       [n, d]
// 45:     end
// 46:
// 47:     MAXIMUM_VERBOSE_OUTPUT = 100
// 48:     private_constant :MAXIMUM_VERBOSE_OUTPUT
// 49:
// 50:     sig { returns(T::Boolean) }
// 51:     def verbose?
// 52:       return super unless ENV["CI"]
// 53:       return false unless super
// 54:
// 55:       if total < MAXIMUM_VERBOSE_OUTPUT
// 56:         true
// 57:       else
// 58:         unless @put_verbose_trimmed_warning
// 59:           puts "Only the first #{MAXIMUM_VERBOSE_OUTPUT} operations were output."
// 60:           @put_verbose_trimmed_warning = true
// 61:         end
// 62:         false
// 63:       end
// 64:     end
// 65:   end
// 66:
// 67:   sig { void }
// 68:   def unlink
// 69:     super
// 70:     puts "rm #{self}" if ObserverPathnameExtension.verbose?
// 71:     ObserverPathnameExtension.n += 1
// 72:   end
// 73:
// 74:   sig { void }
// 75:   def mkpath
// 76:     super
// 77:     puts "mkdir -p #{self}" if ObserverPathnameExtension.verbose?
// 78:   end
// 79:
// 80:   sig { void }
// 81:   def rmdir
// 82:     super
// 83:     puts "rmdir #{self}" if ObserverPathnameExtension.verbose?
// 84:     ObserverPathnameExtension.d += 1
// 85:   end
// 86:
// 87:   sig { params(src: Pathname).void }
// 88:   def make_relative_symlink(src)
// 89:     super
// 90:     puts "ln -s #{src.relative_path_from(dirname)} #{basename}" if ObserverPathnameExtension.verbose?
// 91:     ObserverPathnameExtension.n += 1
// 92:   end
// 93:
// 94:   sig { void }
// 95:   def install_info
// 96:     super
// 97:     puts "info #{self}" if ObserverPathnameExtension.verbose?
// 98:   end
// 99:
// 100:   sig { void }
// 101:   def uninstall_info
// 102:     super
// 103:     puts "uninfo #{self}" if ObserverPathnameExtension.verbose?
// 104:   end
// 105: end
