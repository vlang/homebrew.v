module concern

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/concern/obligation.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `fulfilled?` at line 20.
pub fn ruby_obligation_l20_d1_fulfilled(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fulfilled?', ...args)
}

// Ruby alias_method `alias_method :realized?, :fulfilled?` at line 23.
pub fn ruby_obligation_l23_d2_realized(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('realized?', ...args)
}

// Ruby method `rejected?` at line 28.
pub fn ruby_obligation_l28_d3_rejected(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rejected?', ...args)
}

// Ruby method `pending?` at line 35.
pub fn ruby_obligation_l35_d4_pending(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('pending?', ...args)
}

// Ruby method `unscheduled?` at line 42.
pub fn ruby_obligation_l42_d5_unscheduled(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('unscheduled?', ...args)
}

// Ruby method `complete?` at line 49.
pub fn ruby_obligation_l49_d6_complete(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('complete?', ...args)
}

// Ruby method `incomplete?` at line 56.
pub fn ruby_obligation_l56_d7_incomplete(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('incomplete?', ...args)
}

// Ruby method `value(timeout = nil)` at line 65.
pub fn ruby_obligation_l65_d8_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('value', ...args)
}

// Ruby method `wait(timeout = nil)` at line 74.
pub fn ruby_obligation_l74_d9_wait(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('wait', ...args)
}

// Ruby method `wait!(timeout = nil)` at line 86.
pub fn ruby_obligation_l86_d10_wait(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('wait!', ...args)
}

// Ruby alias_method `alias_method :no_error!, :wait!` at line 89.
pub fn ruby_obligation_l89_d11_no_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('no_error!', ...args)
}

// Ruby method `value!(timeout = nil)` at line 98.
pub fn ruby_obligation_l98_d12_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('value!', ...args)
}

// Ruby method `state` at line 110.
pub fn ruby_obligation_l110_d13_state(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('state', ...args)
}

// Ruby method `reason` at line 119.
pub fn ruby_obligation_l119_d14_reason(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reason', ...args)
}

// Ruby method `exception(*args)` at line 126.
pub fn ruby_obligation_l126_d15_exception(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('exception', ...args)
}

// Ruby method `get_arguments_from(opts = {})` at line 134.
pub fn ruby_obligation_l134_d16_get_arguments_from(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('get_arguments_from', ...args)
}

// Ruby method `init_obligation` at line 139.
pub fn ruby_obligation_l139_d17_init_obligation(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('init_obligation', ...args)
}

// Ruby method `event` at line 145.
pub fn ruby_obligation_l145_d18_event(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('event', ...args)
}

// Ruby method `set_state(success, value, reason)` at line 150.
pub fn ruby_obligation_l150_d19_set_state(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('set_state', ...args)
}

// Ruby method `state=(value)` at line 161.
pub fn ruby_obligation_l161_d20_state(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('state=', ...args)
}

// Ruby method `compare_and_set_state(next_state, *expected_current)` at line 174.
pub fn ruby_obligation_l174_d21_compare_and_set_state(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('compare_and_set_state', ...args)
}

// Ruby method `if_state(*expected_states)` at line 190.
pub fn ruby_obligation_l190_d22_if_state(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('if_state', ...args)
}

// Ruby method `ns_check_state?(expected)` at line 210.
pub fn ruby_obligation_l210_d23_ns_check_state(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_check_state?', ...args)
}

// Ruby method `ns_set_state(value)` at line 215.
pub fn ruby_obligation_l215_d24_ns_set_state(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ns_set_state', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'thread'
// 2: require 'timeout'
// 3:
// 4: require 'concurrent/atomic/event'
// 5: require 'concurrent/concern/dereferenceable'
// 6:
// 7: module Concurrent
// 8:   module Concern
// 9:
// 10:     module Obligation
// 11:       include Concern::Dereferenceable
// 12:       # NOTE: The Dereferenceable module is going away in 2.0. In the mean time
// 13:       # we need it to place nicely with the synchronization layer. This means
// 14:       # that the including class SHOULD be synchronized and it MUST implement a
// 15:       # `#synchronize` method. Not doing so will lead to runtime errors.
// 16:
// 17:       # Has the obligation been fulfilled?
// 18:       #
// 19:       # @return [Boolean]
// 20:       def fulfilled?
// 21:         state == :fulfilled
// 22:       end
// 23:       alias_method :realized?, :fulfilled?
// 24:
// 25:       # Has the obligation been rejected?
// 26:       #
// 27:       # @return [Boolean]
// 28:       def rejected?
// 29:         state == :rejected
// 30:       end
// 31:
// 32:       # Is obligation completion still pending?
// 33:       #
// 34:       # @return [Boolean]
// 35:       def pending?
// 36:         state == :pending
// 37:       end
// 38:
// 39:       # Is the obligation still unscheduled?
// 40:       #
// 41:       # @return [Boolean]
// 42:       def unscheduled?
// 43:         state == :unscheduled
// 44:       end
// 45:
// 46:       # Has the obligation completed processing?
// 47:       #
// 48:       # @return [Boolean]
// 49:       def complete?
// 50:         [:fulfilled, :rejected].include? state
// 51:       end
// 52:
// 53:       # Is the obligation still awaiting completion of processing?
// 54:       #
// 55:       # @return [Boolean]
// 56:       def incomplete?
// 57:         ! complete?
// 58:       end
// 59:
// 60:       # The current value of the obligation. Will be `nil` while the state is
// 61:       # pending or the operation has been rejected.
// 62:       #
// 63:       # @param [Numeric] timeout the maximum time in seconds to wait.
// 64:       # @return [Object] see Dereferenceable#deref
// 65:       def value(timeout = nil)
// 66:         wait timeout
// 67:         deref
// 68:       end
// 69:
// 70:       # Wait until obligation is complete or the timeout has been reached.
// 71:       #
// 72:       # @param [Numeric] timeout the maximum time in seconds to wait.
// 73:       # @return [Obligation] self
// 74:       def wait(timeout = nil)
// 75:         event.wait(timeout) if timeout != 0 && incomplete?
// 76:         self
// 77:       end
// 78:
// 79:       # Wait until obligation is complete or the timeout is reached. Will re-raise
// 80:       # any exceptions raised during processing (but will not raise an exception
// 81:       # on timeout).
// 82:       #
// 83:       # @param [Numeric] timeout the maximum time in seconds to wait.
// 84:       # @return [Obligation] self
// 85:       # @raise [Exception] raises the reason when rejected
// 86:       def wait!(timeout = nil)
// 87:         wait(timeout).tap { raise self if rejected? }
// 88:       end
// 89:       alias_method :no_error!, :wait!
// 90:
// 91:       # The current value of the obligation. Will be `nil` while the state is
// 92:       # pending or the operation has been rejected. Will re-raise any exceptions
// 93:       # raised during processing (but will not raise an exception on timeout).
// 94:       #
// 95:       # @param [Numeric] timeout the maximum time in seconds to wait.
// 96:       # @return [Object] see Dereferenceable#deref
// 97:       # @raise [Exception] raises the reason when rejected
// 98:       def value!(timeout = nil)
// 99:         wait(timeout)
// 100:         if rejected?
// 101:           raise self
// 102:         else
// 103:           deref
// 104:         end
// 105:       end
// 106:
// 107:       # The current state of the obligation.
// 108:       #
// 109:       # @return [Symbol] the current state
// 110:       def state
// 111:         synchronize { @state }
// 112:       end
// 113:
// 114:       # If an exception was raised during processing this will return the
// 115:       # exception object. Will return `nil` when the state is pending or if
// 116:       # the obligation has been successfully fulfilled.
// 117:       #
// 118:       # @return [Exception] the exception raised during processing or `nil`
// 119:       def reason
// 120:         synchronize { @reason }
// 121:       end
// 122:
// 123:       # @example allows Obligation to be risen
// 124:       #   rejected_ivar = Ivar.new.fail
// 125:       #   raise rejected_ivar
// 126:       def exception(*args)
// 127:         raise 'obligation is not rejected' unless rejected?
// 128:         reason.exception(*args)
// 129:       end
// 130:
// 131:       protected
// 132:
// 133:       # @!visibility private
// 134:       def get_arguments_from(opts = {})
// 135:         [*opts.fetch(:args, [])]
// 136:       end
// 137:
// 138:       # @!visibility private
// 139:       def init_obligation
// 140:         @event = Event.new
// 141:         @value = @reason = nil
// 142:       end
// 143:
// 144:       # @!visibility private
// 145:       def event
// 146:         @event
// 147:       end
// 148:
// 149:       # @!visibility private
// 150:       def set_state(success, value, reason)
// 151:         if success
// 152:           @value = value
// 153:           @state = :fulfilled
// 154:         else
// 155:           @reason = reason
// 156:           @state  = :rejected
// 157:         end
// 158:       end
// 159:
// 160:       # @!visibility private
// 161:       def state=(value)
// 162:         synchronize { ns_set_state(value) }
// 163:       end
// 164:
// 165:       # Atomic compare and set operation
// 166:       # State is set to `next_state` only if `current state == expected_current`.
// 167:       #
// 168:       # @param [Symbol] next_state
// 169:       # @param [Symbol] expected_current
// 170:       #
// 171:       # @return [Boolean] true is state is changed, false otherwise
// 172:       #
// 173:       # @!visibility private
// 174:       def compare_and_set_state(next_state, *expected_current)
// 175:         synchronize do
// 176:           if expected_current.include? @state
// 177:             @state = next_state
// 178:             true
// 179:           else
// 180:             false
// 181:           end
// 182:         end
// 183:       end
// 184:
// 185:       # Executes the block within mutex if current state is included in expected_states
// 186:       #
// 187:       # @return block value if executed, false otherwise
// 188:       #
// 189:       # @!visibility private
// 190:       def if_state(*expected_states)
// 191:         synchronize do
// 192:           raise ArgumentError.new('no block given') unless block_given?
// 193:
// 194:           if expected_states.include? @state
// 195:             yield
// 196:           else
// 197:             false
// 198:           end
// 199:         end
// 200:       end
// 201:
// 202:       protected
// 203:
// 204:       # Am I in the current state?
// 205:       #
// 206:       # @param [Symbol] expected The state to check against
// 207:       # @return [Boolean] true if in the expected state else false
// 208:       #
// 209:       # @!visibility private
// 210:       def ns_check_state?(expected)
// 211:         @state == expected
// 212:       end
// 213:
// 214:       # @!visibility private
// 215:       def ns_set_state(value)
// 216:         @state = value
// 217:       end
// 218:     end
// 219:   end
// 220: end
