module atomic_reference

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/atomic_reference/atomic_direct_update.rb`.
// The original source is retained below until every stub has a typed V body.
fn direct_update_values(args []ruby.Value) (ruby.Value, bool) {
	if args.len < 2 {
		return nil_boundary_value(), false
	}
	succeeded := if args.len > 2 && args[2].type_name == 'Bool' {
		args[2].as_bool() or { false }
	} else {
		true
	}
	return args[1], succeeded
}

// Ruby method `update` at line 10.
pub fn ruby_atomic_direct_update_l10_d1_update(args ...ruby.Value) ruby.Value {
	new_value, _ := direct_update_values(args)
	return new_value
}

// Ruby method `try_update` at line 15.
pub fn ruby_atomic_direct_update_l15_d2_try_update(args ...ruby.Value) ruby.Value {
	new_value, succeeded := direct_update_values(args)
	return if succeeded { new_value } else { nil_boundary_value() }
}

// Ruby method `try_update!` at line 24.
pub fn ruby_atomic_direct_update_l24_d3_try_update(args ...ruby.Value) ruby.Value {
	new_value, succeeded := direct_update_values(args)
	if !succeeded {
		panic('ConcurrentUpdateError: Update failed')
	}
	return new_value
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/errors'
// 2:
// 3: module Concurrent
// 4:
// 5:   # Define update methods that use direct paths
// 6:   #
// 7:   # @!visibility private
// 8:   # @!macro internal_implementation_note
// 9:   module AtomicDirectUpdate
// 10:     def update
// 11:       true until compare_and_set(old_value = get, new_value = yield(old_value))
// 12:       new_value
// 13:     end
// 14:
// 15:     def try_update
// 16:       old_value = get
// 17:       new_value = yield old_value
// 18:
// 19:       return unless compare_and_set old_value, new_value
// 20:
// 21:       new_value
// 22:     end
// 23:
// 24:     def try_update!
// 25:       old_value = get
// 26:       new_value = yield old_value
// 27:       unless compare_and_set(old_value, new_value)
// 28:         if $VERBOSE
// 29:           raise ConcurrentUpdateError, "Update failed"
// 30:         else
// 31:           raise ConcurrentUpdateError, "Update failed", ConcurrentUpdateError::CONC_UP_ERR_BACKTRACE
// 32:         end
// 33:       end
// 34:       new_value
// 35:     end
// 36:   end
// 37: end
