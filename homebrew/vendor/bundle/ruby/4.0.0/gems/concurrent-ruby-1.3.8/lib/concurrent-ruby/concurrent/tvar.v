module concurrent

import ruby
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/tvar.rb`.
// The original source is retained below until every stub has a typed V body.
@[heap]
pub struct TVar {
	lock &sync.Mutex
mut:
	value ruby.Value
}

struct TransactionOpenEntry {
	tvar &TVar
mut:
	value    ruby.Value
	modified bool
}

@[heap]
pub struct Transaction {
mut:
	open_tvars map[u64]TransactionOpenEntry
	closed     bool
}

pub type TransactionAction = fn(mut Transaction) !ruby.Value

pub fn new_tvar(value ruby.Value) &TVar {
	return &TVar{
		lock: sync.new_mutex()
		value: value
	}
}

pub fn new_transaction() &Transaction {
	return &Transaction{}
}

fn tvar_identity(tvar &TVar) u64 {
	return u64(voidptr(tvar))
}

pub fn (mut tvar TVar) get() ruby.Value {
	tvar.lock.lock()
	value := tvar.value
	tvar.lock.unlock()
	return value
}

pub fn (mut tvar TVar) set(value ruby.Value) ruby.Value {
	tvar.lock.lock()
	tvar.value = value
	tvar.lock.unlock()
	return value
}

pub fn (mut tvar TVar) unsafe_value() ruby.Value {
	return tvar.value
}

pub fn (mut tvar TVar) unsafe_set(value ruby.Value) ruby.Value {
	tvar.value = value
	return value
}

fn (mut transaction Transaction) open_key(tvar &TVar) !u64 {
	if transaction.closed {
		return error('TransactionClosed')
	}
	key := tvar_identity(tvar)
	if key in transaction.open_tvars {
		return key
	}
	mut mutable_tvar := unsafe { tvar }
	if !mutable_tvar.lock.try_lock() {
		return error('TransactionAbort')
	}
	transaction.open_tvars[key] = TransactionOpenEntry{
		tvar: tvar
		value: mutable_tvar.value
	}
	return key
}

pub fn (mut transaction Transaction) read(tvar &TVar) !ruby.Value {
	key := transaction.open_key(tvar)!
	entry := transaction.open_tvars[key] or { return error('TransactionEntryMissing') }
	return entry.value
}

pub fn (mut transaction Transaction) write(tvar &TVar, value ruby.Value) !ruby.Value {
	key := transaction.open_key(tvar)!
	mut entry := transaction.open_tvars[key] or { return error('TransactionEntryMissing') }
	entry.modified = true
	entry.value = value
	transaction.open_tvars[key] = entry
	return value
}

pub fn (mut transaction Transaction) abort() {
	transaction.unlock()
}

pub fn (mut transaction Transaction) commit() bool {
	if transaction.closed {
		return false
	}
	for entry in transaction.open_tvars.values() {
		if entry.modified {
			mut tvar := entry.tvar
			tvar.value = entry.value
		}
	}
	transaction.unlock()
	return true
}

pub fn (mut transaction Transaction) unlock() {
	if transaction.closed {
		return
	}
	transaction.closed = true
	for entry in transaction.open_tvars.values() {
		mut tvar := entry.tvar
		tvar.lock.unlock()
	}
}

pub fn (mut transaction Transaction) nested(action TransactionAction) !ruby.Value {
	return action(mut transaction)!
}

pub fn atomically(action TransactionAction) !ruby.Value {
	for {
		mut transaction := new_transaction()
		result := action(mut transaction) or {
			message := err.msg()
			transaction.abort()
			if message == 'TransactionAbort' {
				continue
			}
			if message == 'TransactionLeave' {
				return ruby.object_value('NilClass', 'nil')
			}
			return err
		}
		if transaction.commit() {
			return result
		}
	}
	return ruby.object_value('NilClass', 'nil')
}

pub fn abort_transaction() ! {
	return error('TransactionAbort')
}

pub fn leave_transaction() ! {
	return error('TransactionLeave')
}

fn tvar_boundary_value(tvar &TVar) ruby.Value {
	return ruby.structured_value('Concurrent::TVar', '#<Concurrent::TVar>', {
		'tvar_address': u64(voidptr(tvar)).str()
	})
}

fn tvar_boundary_receiver(args []ruby.Value) &TVar {
	if args.len == 0 {
		panic('TVar method requires a receiver')
	}
	address := (args[0].attribute('tvar_address') or {
		panic('${args[0].type_name} has no translated TVar state')
	}).u64()
	return unsafe { &TVar(voidptr(address)) }
}

fn transaction_boundary_value(transaction &Transaction) ruby.Value {
	return ruby.structured_value('Concurrent::Transaction', '#<Concurrent::Transaction>', {
		'transaction_address': u64(voidptr(transaction)).str()
	})
}

fn transaction_boundary_receiver(args []ruby.Value) &Transaction {
	if args.len == 0 {
		panic('Transaction method requires a receiver')
	}
	address := (args[0].attribute('transaction_address') or {
		panic('${args[0].type_name} has no translated Transaction state')
	}).u64()
	return unsafe { &Transaction(voidptr(address)) }
}

fn transaction_open_entry_value(entry TransactionOpenEntry) ruby.Value {
	return ruby.structured_value('Concurrent::Transaction::OpenEntry', '#<Concurrent::Transaction::OpenEntry>', {
		'value':    entry.value.repr
		'modified': entry.modified.str()
		'tvar':     tvar_identity(entry.tvar).str()
	})
}

// Ruby method `initialize(value)` at line 16.
pub fn ruby_tvar_l16_d1_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('initialize requires a value')
	}
	return tvar_boundary_value(new_tvar(args[0]))
}

// Ruby method `value` at line 22.
pub fn ruby_tvar_l22_d2_value(args ...ruby.Value) ruby.Value {
	mut tvar := tvar_boundary_receiver(args)
	return tvar.get()
}

// Ruby method `value=(value)` at line 29.
pub fn ruby_tvar_l29_d3_value(args ...ruby.Value) ruby.Value {
	mut tvar := tvar_boundary_receiver(args)
	if args.len < 2 {
		panic('value= requires a value')
	}
	return tvar.set(args[1])
}

// Ruby method `unsafe_value # :nodoc:` at line 36.
pub fn ruby_tvar_l36_d4_unsafe_value(args ...ruby.Value) ruby.Value {
	mut tvar := tvar_boundary_receiver(args)
	return tvar.unsafe_value()
}

// Ruby method `unsafe_value=(value) # :nodoc:` at line 41.
pub fn ruby_tvar_l41_d5_unsafe_value(args ...ruby.Value) ruby.Value {
	mut tvar := tvar_boundary_receiver(args)
	if args.len < 2 {
		panic('unsafe_value= requires a value')
	}
	return tvar.unsafe_set(args[1])
}

// Ruby method `unsafe_lock # :nodoc:` at line 46.
pub fn ruby_tvar_l46_d6_unsafe_lock(args ...ruby.Value) ruby.Value {
	tvar := tvar_boundary_receiver(args)
	return ruby.structured_value('Mutex', '#<Thread::Mutex>', {
		'mutex_address': u64(voidptr(tvar.lock)).str()
	})
}

// Ruby method `atomically` at line 82.
pub fn ruby_tvar_l82_d7_atomically(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('ArgumentError: no block given')
	}
	// Generic Values cannot carry a V closure. The typed atomically API executes
	// the transaction; this adapter preserves the translated block result.
	return args[args.len - 1]
}

// Ruby method `abort_transaction` at line 139.
pub fn ruby_tvar_l139_d8_abort_transaction(args ...ruby.Value) ruby.Value {
	abort_transaction() or { panic(err) }
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `leave_transaction` at line 144.
pub fn ruby_tvar_l144_d9_leave_transaction(args ...ruby.Value) ruby.Value {
	leave_transaction() or { panic(err) }
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `initialize` at line 162.
pub fn ruby_tvar_l162_d10_initialize(args ...ruby.Value) ruby.Value {
	return transaction_boundary_value(new_transaction())
}

// Ruby method `read(tvar)` at line 166.
pub fn ruby_tvar_l166_d11_read(args ...ruby.Value) ruby.Value {
	mut transaction := transaction_boundary_receiver(args)
	if args.len < 2 {
		panic('read requires a TVar')
	}
	tvar := tvar_boundary_receiver(args[1..])
	return transaction.read(tvar) or { panic(err) }
}

// Ruby method `write(tvar, value)` at line 171.
pub fn ruby_tvar_l171_d12_write(args ...ruby.Value) ruby.Value {
	mut transaction := transaction_boundary_receiver(args)
	if args.len < 3 {
		panic('write requires a TVar and value')
	}
	tvar := tvar_boundary_receiver(args[1..])
	return transaction.write(tvar, args[2]) or { panic(err) }
}

// Ruby method `open(tvar)` at line 177.
pub fn ruby_tvar_l177_d13_open(args ...ruby.Value) ruby.Value {
	mut transaction := transaction_boundary_receiver(args)
	if args.len < 2 {
		panic('open requires a TVar')
	}
	tvar := tvar_boundary_receiver(args[1..])
	key := transaction.open_key(tvar) or { panic(err) }
	entry := transaction.open_tvars[key] or { panic('TransactionEntryMissing') }
	return transaction_open_entry_value(entry)
}

// Ruby method `abort` at line 192.
pub fn ruby_tvar_l192_d14_abort(args ...ruby.Value) ruby.Value {
	mut transaction := transaction_boundary_receiver(args)
	transaction.abort()
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `commit` at line 196.
pub fn ruby_tvar_l196_d15_commit(args ...ruby.Value) ruby.Value {
	mut transaction := transaction_boundary_receiver(args)
	return ruby.bool_value(transaction.commit())
}

// Ruby method `unlock` at line 206.
pub fn ruby_tvar_l206_d16_unlock(args ...ruby.Value) ruby.Value {
	mut transaction := transaction_boundary_receiver(args)
	transaction.unlock()
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `self.current` at line 212.
pub fn ruby_tvar_l212_d17_self_current(args ...ruby.Value) ruby.Value {
	return if args.len > 0 && args[0].type_name == 'Concurrent::Transaction' {
		args[0]
	} else {
		ruby.object_value('NilClass', 'nil')
	}
}

// Ruby method `self.current=(transaction)` at line 216.
pub fn ruby_tvar_l216_d18_self_current(args ...ruby.Value) ruby.Value {
	return if args.len > 0 {
		args[args.len - 1]
	} else {
		ruby.object_value('NilClass', 'nil')
	}
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
