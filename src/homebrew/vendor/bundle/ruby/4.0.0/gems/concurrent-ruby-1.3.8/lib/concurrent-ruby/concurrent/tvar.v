module concurrent

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/tvar.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(value)` at line 16.
pub fn ruby_tvar_l16_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `value` at line 22.
pub fn ruby_tvar_l22_d2_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('value', ...args)
}

// Ruby method `value=(value)` at line 29.
pub fn ruby_tvar_l29_d3_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('value=', ...args)
}

// Ruby method `unsafe_value # :nodoc:` at line 36.
pub fn ruby_tvar_l36_d4_unsafe_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('unsafe_value', ...args)
}

// Ruby method `unsafe_value=(value) # :nodoc:` at line 41.
pub fn ruby_tvar_l41_d5_unsafe_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('unsafe_value=', ...args)
}

// Ruby method `unsafe_lock # :nodoc:` at line 46.
pub fn ruby_tvar_l46_d6_unsafe_lock(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('unsafe_lock', ...args)
}

// Ruby method `atomically` at line 82.
pub fn ruby_tvar_l82_d7_atomically(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('atomically', ...args)
}

// Ruby method `abort_transaction` at line 139.
pub fn ruby_tvar_l139_d8_abort_transaction(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('abort_transaction', ...args)
}

// Ruby method `leave_transaction` at line 144.
pub fn ruby_tvar_l144_d9_leave_transaction(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('leave_transaction', ...args)
}

// Ruby method `initialize` at line 162.
pub fn ruby_tvar_l162_d10_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `read(tvar)` at line 166.
pub fn ruby_tvar_l166_d11_read(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('read', ...args)
}

// Ruby method `write(tvar, value)` at line 171.
pub fn ruby_tvar_l171_d12_write(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('write', ...args)
}

// Ruby method `open(tvar)` at line 177.
pub fn ruby_tvar_l177_d13_open(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('open', ...args)
}

// Ruby method `abort` at line 192.
pub fn ruby_tvar_l192_d14_abort(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('abort', ...args)
}

// Ruby method `commit` at line 196.
pub fn ruby_tvar_l196_d15_commit(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('commit', ...args)
}

// Ruby method `unlock` at line 206.
pub fn ruby_tvar_l206_d16_unlock(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('unlock', ...args)
}

// Ruby method `self.current` at line 212.
pub fn ruby_tvar_l212_d17_self_current(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.current', ...args)
}

// Ruby method `self.current=(transaction)` at line 216.
pub fn ruby_tvar_l216_d18_self_current(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.current=', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'set'
// 2: require 'concurrent/synchronization/object'
// 3:
// 4: module Concurrent
// 5:
// 6:   # A `TVar` is a transactional variable - a single-element container that
// 7:   # is used as part of a transaction - see `Concurrent::atomically`.
// 8:   #
// 9:   # @!macro thread_safe_variable_comparison
// 10:   #
// 11:   # {include:file:docs-source/tvar.md}
// 12:   class TVar < Synchronization::Object
// 13:     safe_initialization!
// 14:
// 15:     # Create a new `TVar` with an initial value.
// 16:     def initialize(value)
// 17:       @value = value
// 18:       @lock = Mutex.new
// 19:     end
// 20:
// 21:     # Get the value of a `TVar`.
// 22:     def value
// 23:       Concurrent::atomically do
// 24:         Transaction::current.read(self)
// 25:       end
// 26:     end
// 27:
// 28:     # Set the value of a `TVar`.
// 29:     def value=(value)
// 30:       Concurrent::atomically do
// 31:         Transaction::current.write(self, value)
// 32:       end
// 33:     end
// 34:
// 35:     # @!visibility private
// 36:     def unsafe_value # :nodoc:
// 37:       @value
// 38:     end
// 39:
// 40:     # @!visibility private
// 41:     def unsafe_value=(value) # :nodoc:
// 42:       @value = value
// 43:     end
// 44:
// 45:     # @!visibility private
// 46:     def unsafe_lock # :nodoc:
// 47:       @lock
// 48:     end
// 49:
// 50:   end
// 51:
// 52:   # Run a block that reads and writes `TVar`s as a single atomic transaction.
// 53:   # With respect to the value of `TVar` objects, the transaction is atomic, in
// 54:   # that it either happens or it does not, consistent, in that the `TVar`
// 55:   # objects involved will never enter an illegal state, and isolated, in that
// 56:   # transactions never interfere with each other. You may recognise these
// 57:   # properties from database transactions.
// 58:   #
// 59:   # There are some very important and unusual semantics that you must be aware of:
// 60:   #
// 61:   # * Most importantly, the block that you pass to atomically may be executed
// 62:   #     more than once. In most cases your code should be free of
// 63:   #     side-effects, except for via TVar.
// 64:   #
// 65:   # * If an exception escapes an atomically block it will abort the transaction.
// 66:   #
// 67:   # * It is undefined behaviour to use callcc or Fiber with atomically.
// 68:   #
// 69:   # * If you create a new thread within an atomically, it will not be part of
// 70:   #     the transaction. Creating a thread counts as a side-effect.
// 71:   #
// 72:   # Transactions within transactions are flattened to a single transaction.
// 73:   #
// 74:   # @example
// 75:   #   a = new TVar(100_000)
// 76:   #   b = new TVar(100)
// 77:   #
// 78:   #   Concurrent::atomically do
// 79:   #     a.value -= 10
// 80:   #     b.value += 10
// 81:   #   end
// 82:   def atomically
// 83:     raise ArgumentError.new('no block given') unless block_given?
// 84:
// 85:     # Get the current transaction
// 86:
// 87:     transaction = Transaction::current
// 88:
// 89:     # Are we not already in a transaction (not nested)?
// 90:
// 91:     if transaction.nil?
// 92:       # New transaction
// 93:
// 94:       begin
// 95:         # Retry loop
// 96:
// 97:         loop do
// 98:
// 99:           # Create a new transaction
// 100:
// 101:           transaction = Transaction.new
// 102:           Transaction::current = transaction
// 103:
// 104:           # Run the block, aborting on exceptions
// 105:
// 106:           begin
// 107:             result = yield
// 108:           rescue Transaction::AbortError => e
// 109:             transaction.abort
// 110:             result = Transaction::ABORTED
// 111:           rescue Transaction::LeaveError => e
// 112:             transaction.abort
// 113:             break result
// 114:           rescue => e
// 115:             transaction.abort
// 116:             raise e
// 117:           end
// 118:           # If we can commit, break out of the loop
// 119:
// 120:           if result != Transaction::ABORTED
// 121:             if transaction.commit
// 122:               break result
// 123:             end
// 124:           end
// 125:         end
// 126:       ensure
// 127:         # Clear the current transaction
// 128:
// 129:         Transaction::current = nil
// 130:       end
// 131:     else
// 132:       # Nested transaction - flatten it and just run the block
// 133:
// 134:       yield
// 135:     end
// 136:   end
// 137:
// 138:   # Abort a currently running transaction - see `Concurrent::atomically`.
// 139:   def abort_transaction
// 140:     raise Transaction::AbortError.new
// 141:   end
// 142:
// 143:   # Leave a transaction without committing or aborting - see `Concurrent::atomically`.
// 144:   def leave_transaction
// 145:     raise Transaction::LeaveError.new
// 146:   end
// 147:
// 148:   module_function :atomically, :abort_transaction, :leave_transaction
// 149:
// 150:   private
// 151:
// 152:   # @!visibility private
// 153:   class Transaction
// 154:
// 155:     ABORTED = ::Object.new
// 156:
// 157:     OpenEntry = Struct.new(:value, :modified)
// 158:
// 159:     AbortError = Class.new(StandardError)
// 160:     LeaveError = Class.new(StandardError)
// 161:
// 162:     def initialize
// 163:       @open_tvars = {}
// 164:     end
// 165:
// 166:     def read(tvar)
// 167:       entry = open(tvar)
// 168:       entry.value
// 169:     end
// 170:
// 171:     def write(tvar, value)
// 172:       entry = open(tvar)
// 173:       entry.modified = true
// 174:       entry.value = value
// 175:     end
// 176:
// 177:     def open(tvar)
// 178:       entry = @open_tvars[tvar]
// 179:
// 180:       unless entry
// 181:         unless tvar.unsafe_lock.try_lock
// 182:           Concurrent::abort_transaction
// 183:         end
// 184:
// 185:         entry = OpenEntry.new(tvar.unsafe_value, false)
// 186:         @open_tvars[tvar] = entry
// 187:       end
// 188:
// 189:       entry
// 190:     end
// 191:
// 192:     def abort
// 193:       unlock
// 194:     end
// 195:
// 196:     def commit
// 197:       @open_tvars.each do |tvar, entry|
// 198:         if entry.modified
// 199:           tvar.unsafe_value = entry.value
// 200:         end
// 201:       end
// 202:
// 203:       unlock
// 204:     end
// 205:
// 206:     def unlock
// 207:       @open_tvars.each_key do |tvar|
// 208:         tvar.unsafe_lock.unlock
// 209:       end
// 210:     end
// 211:
// 212:     def self.current
// 213:       Thread.current[:current_tvar_transaction]
// 214:     end
// 215:
// 216:     def self.current=(transaction)
// 217:       Thread.current[:current_tvar_transaction] = transaction
// 218:     end
// 219:
// 220:   end
// 221:
// 222: end
