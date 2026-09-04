module concurrent

import ruby
import sync
import time

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/ivar.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum IVarState {
	unscheduled
	pending
	processing
	fulfilled
	rejected
	cancelled
}

pub type IVarTask = fn([]ruby.Value) !ruby.Value

pub type IVarCompletion = fn(bool, ruby.Value, string)

pub type IVarObserver = fn(i64, ruby.Value, string)

pub type IVarCopy = fn(ruby.Value) ruby.Value

pub struct IVarOptions {
pub:
	dup_on_deref    bool
	freeze_on_deref bool
	copy_on_deref   ?IVarCopy
	args            []ruby.Value
}

struct IVarObserverEntry {
	id       string
	callback IVarObserver @[required]
}

@[heap]
struct IVarData {
	mutex     &sync.Mutex
	condition &sync.Cond
mut:
	state     IVarState
	value     ruby.Value
	reason    string
	observers []IVarObserverEntry
}

@[heap]
pub struct IVar {
	options IVarOptions
mut:
	data &IVarData
}

pub fn new_ivar() &IVar {
	return new_ivar_with_options(IVarOptions{})
}

pub fn new_ivar_with_options(options IVarOptions) &IVar {
	mutex := sync.new_mutex()
	return &IVar{
		data: &IVarData{
			mutex: mutex
			condition: sync.new_cond(mutex)
			state: .pending
			value: ivar_nil_value()
		}
		options: options
	}
}

pub fn new_fulfilled_ivar(value ruby.Value, options IVarOptions) &IVar {
	mut ivar := new_ivar_with_options(options)
	ivar.complete_without_notification(true, value, '') or { panic(err) }
	return ivar
}

fn ivar_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn ivar_state_complete(state IVarState) bool {
	return state in [.fulfilled, .rejected]
}

fn ivar_state_from_string(value string) IVarState {
	return match value.trim_left(':') {
		'unscheduled' { .unscheduled }
		'pending' { .pending }
		'processing' { .processing }
		'fulfilled' { .fulfilled }
		'rejected' { .rejected }
		'cancelled' { .cancelled }
		else { panic('ArgumentError: unknown IVar state `${value}`') }
	}
}

fn ivar_duplicate_value(value ruby.Value) ruby.Value {
	return ruby.Value{
		type_name: value.type_name
		repr: value.repr
		bool_data: value.bool_data
		int_data: value.int_data
		float_data: value.float_data
		string_array_data: value.string_array_data.clone()
		array_data: value.array_data.clone()
		map_data: value.map_data.clone()
		attributes: value.attributes.clone()
	}
}

fn ivar_apply_options(value ruby.Value, options IVarOptions) ruby.Value {
	if value.type_name == 'NilClass' {
		return value
	}
	mut result := value
	if copy_fn := options.copy_on_deref {
		result = copy_fn(result)
	}
	if options.dup_on_deref {
		result = ivar_duplicate_value(result)
	}
	// Boundary values are immutable, so freeze_on_deref needs no additional V operation.
	return result
}

pub fn (mut ivar IVar) state() IVarState {
	ivar.data.mutex.lock()
	state := ivar.data.state
	ivar.data.mutex.unlock()
	return state
}

pub fn (mut ivar IVar) fulfilled() bool {
	return ivar.state() == .fulfilled
}

pub fn (mut ivar IVar) rejected() bool {
	return ivar.state() == .rejected
}

pub fn (mut ivar IVar) pending() bool {
	return ivar.state() == .pending
}

pub fn (mut ivar IVar) unscheduled() bool {
	return ivar.state() == .unscheduled
}

pub fn (mut ivar IVar) is_complete() bool {
	return ivar_state_complete(ivar.state())
}

pub fn (mut ivar IVar) is_incomplete() bool {
	return !ivar.is_complete()
}

pub fn (mut ivar IVar) reason() string {
	ivar.data.mutex.lock()
	reason := ivar.data.reason
	ivar.data.mutex.unlock()
	return reason
}

pub fn (mut ivar IVar) wait(timeout ?time.Duration) bool {
	ivar.data.mutex.lock()
	defer {
		ivar.data.mutex.unlock()
	}
	if ivar_state_complete(ivar.data.state) {
		return true
	}
	if duration := timeout {
		if duration <= 0 {
			return false
		}
		deadline := time.sys_mono_now() + u64(duration)
		for !ivar_state_complete(ivar.data.state) {
			now := time.sys_mono_now()
			if now >= deadline {
				return false
			}
			remaining := deadline - now
			sleep_for := if remaining < u64(time.millisecond) {
				time.Duration(remaining)
			} else {
				time.millisecond
			}
			ivar.data.mutex.unlock()
			time.sleep(sleep_for)
			ivar.data.mutex.lock()
		}
		return true
	}
	for !ivar_state_complete(ivar.data.state) {
		ivar.data.condition.wait()
	}
	return true
}

pub fn (mut ivar IVar) value(timeout ?time.Duration) ruby.Value {
	ivar.wait(timeout)
	ivar.data.mutex.lock()
	value := if ivar.data.state == .fulfilled {
		ivar_apply_options(ivar.data.value, ivar.options)
	} else {
		ivar_nil_value()
	}
	ivar.data.mutex.unlock()
	return value
}

pub fn (mut ivar IVar) value_or_error(timeout ?time.Duration) !ruby.Value {
	ivar.wait(timeout)
	ivar.data.mutex.lock()
	defer {
		ivar.data.mutex.unlock()
	}
	if ivar.data.state == .rejected {
		return error(ivar.data.reason)
	}
	return if ivar.data.state == .fulfilled {
		ivar_apply_options(ivar.data.value, ivar.options)
	} else {
		ivar_nil_value()
	}
}

pub fn (mut ivar IVar) compare_and_set_state(next_state IVarState, expected []IVarState) bool {
	ivar.data.mutex.lock()
	defer {
		ivar.data.mutex.unlock()
	}
	if ivar.data.state !in expected {
		return false
	}
	ivar.data.state = next_state
	return true
}

pub fn (mut ivar IVar) set_state(state IVarState) {
	ivar.data.mutex.lock()
	ivar.data.state = state
	ivar.data.mutex.unlock()
}

pub fn (mut ivar IVar) add_observer(id string, callback IVarObserver) string {
	if id.len == 0 {
		panic('ArgumentError: should pass observer as a first argument or block')
	}
	ivar.data.mutex.lock()
	if ivar_state_complete(ivar.data.state) {
		value := if ivar.data.state == .fulfilled {
			ivar_apply_options(ivar.data.value, ivar.options)
		} else {
			ivar_nil_value()
		}
		reason := ivar.data.reason
		ivar.data.mutex.unlock()
		callback(time.now().unix_nano(), value, reason)
		return id
	}
	entry := IVarObserverEntry{
		id: id
		callback: callback
	}
	mut replaced := false
	for index, observer in ivar.data.observers {
		if observer.id == id {
			ivar.data.observers[index] = entry
			replaced = true
			break
		}
	}
	if !replaced {
		ivar.data.observers << entry
	}
	ivar.data.mutex.unlock()
	return id
}

pub fn (mut ivar IVar) notify_observers(value ruby.Value, reason string) {
	ivar.data.mutex.lock()
	observers := ivar.data.observers.clone()
	ivar.data.observers.clear()
	ivar.data.mutex.unlock()
	completed_at := time.now().unix_nano()
	for observer in observers {
		observer.callback(completed_at, value, reason)
	}
}

pub fn (mut ivar IVar) set(value ruby.Value) !&IVar {
	if !ivar.compare_and_set_state(.processing, [.pending]) {
		return error('MultipleAssignmentError')
	}
	ivar.complete_without_notification(true, value, '')!
	ivar.notify_observers(ivar.value(time.Duration(0)), '')
	return ivar
}

pub fn (mut ivar IVar) set_from_task(task IVarTask) !&IVar {
	if !ivar.compare_and_set_state(.processing, [.pending]) {
		return error('MultipleAssignmentError')
	}
	value := task([]) or {
		ivar.complete_without_notification(false, ivar_nil_value(), err.msg())!
		ivar.notify_observers(ivar_nil_value(), err.msg())
		return ivar
	}
	ivar.complete_without_notification(true, value, '')!
	ivar.notify_observers(ivar.value(time.Duration(0)), '')
	return ivar
}

pub fn (mut ivar IVar) fail(reason string) !&IVar {
	ivar.complete(false, ivar_nil_value(), if reason.len > 0 { reason } else { 'StandardError' })!
	return ivar
}

pub fn (mut ivar IVar) try_set(value ruby.Value) bool {
	ivar.set(value) or { return false }
	return true
}

pub fn (mut ivar IVar) safe_execute(task IVarTask, args []ruby.Value, completion ?IVarCompletion) bool {
	if !ivar.compare_and_set_state(.processing, [.pending]) {
		return false
	}
	value := task(args) or {
		ivar.complete(false, ivar_nil_value(), err.msg()) or { panic(err) }
		if callback := completion {
			callback(false, ivar_nil_value(), err.msg())
		}
		return true
	}
	ivar.complete(true, value, '') or { panic(err) }
	if callback := completion {
		callback(true, value, '')
	}
	return true
}

pub fn (mut ivar IVar) complete(success bool, value ruby.Value, reason string) !&IVar {
	ivar.complete_without_notification(success, value, reason)!
	notification_value := if success { ivar.value(time.Duration(0)) } else { ivar_nil_value() }
	ivar.notify_observers(notification_value, reason)
	return ivar
}

pub fn (mut ivar IVar) complete_without_notification(success bool, value ruby.Value, reason string) !&IVar {
	ivar.data.mutex.lock()
	if ivar_state_complete(ivar.data.state) {
		ivar.data.mutex.unlock()
		return error('MultipleAssignmentError')
	}
	if success {
		ivar.data.value = value
		ivar.data.reason = ''
		ivar.data.state = .fulfilled
	} else {
		ivar.data.value = ivar_nil_value()
		ivar.data.reason = reason
		ivar.data.state = .rejected
	}
	ivar.data.condition.broadcast()
	ivar.data.mutex.unlock()
	return ivar
}

fn ivar_boundary_value(ivar &IVar) ruby.Value {
	return ruby.structured_value('Concurrent::IVar', '#<Concurrent::IVar>', {
		'ivar_address': u64(voidptr(ivar)).str()
	})
}

fn ivar_boundary_receiver(args []ruby.Value) &IVar {
	if args.len == 0 {
		panic('IVar method requires a receiver')
	}
	address := (args[0].attribute('ivar_address') or {
		panic('${args[0].type_name} has no translated IVar state')
	}).u64()
	return unsafe { &IVar(voidptr(address)) }
}

fn ivar_boundary_reason(value ruby.Value) string {
	return if value.type_name == 'NilClass' { '' } else { value.as_string() }
}

// Ruby method `initialize(value = NULL, opts = {}, &block)` at line 62.
pub fn ruby_ivar_l62_d1_initialize(args ...ruby.Value) ruby.Value {
	ivar := if args.len > 0 {
		new_fulfilled_ivar(args[0], IVarOptions{})
	} else {
		new_ivar()
	}
	return ivar_boundary_value(ivar)
}

// Ruby method `add_observer(observer = nil, func = :update, &block)` at line 81.
pub fn ruby_ivar_l81_d2_add_observer(args ...ruby.Value) ruby.Value {
	mut ivar := ivar_boundary_receiver(args)
	if args.len < 2 || args[1].type_name == 'NilClass' {
		panic('ArgumentError: should pass observer as a first argument or block')
	}
	// A boundary Value cannot carry a V callback; the typed add_observer API performs delivery.
	if ivar.is_complete() {
		ivar.value(time.Duration(0))
		ivar.reason()
	}
	return args[1]
}

// Ruby method `set(value = NULL)` at line 113.
pub fn ruby_ivar_l113_d3_set(args ...ruby.Value) ruby.Value {
	mut ivar := ivar_boundary_receiver(args)
	if args.len < 2 {
		panic('ArgumentError: must set with either a value or a block')
	}
	ivar.set(args[1]) or { panic(err) }
	return args[0]
}

// Ruby method `fail(reason = StandardError.new)` at line 135.
pub fn ruby_ivar_l135_d4_fail(args ...ruby.Value) ruby.Value {
	mut ivar := ivar_boundary_receiver(args)
	reason := if args.len > 1 { ivar_boundary_reason(args[1]) } else { 'StandardError' }
	ivar.fail(reason) or { panic(err) }
	return args[0]
}

// Ruby method `try_set(value = NULL, &block)` at line 145.
pub fn ruby_ivar_l145_d5_try_set(args ...ruby.Value) ruby.Value {
	mut ivar := ivar_boundary_receiver(args)
	if args.len < 2 {
		panic('ArgumentError: must set with either a value or a block')
	}
	return ruby.bool_value(ivar.try_set(args[1]))
}

// Ruby method `ns_initialize(value, opts)` at line 155.
pub fn ruby_ivar_l155_d6_ns_initialize(args ...ruby.Value) ruby.Value {
	return ruby_ivar_l62_d1_initialize(...args)
}

// Ruby method `safe_execute(task, args = [])` at line 168.
pub fn ruby_ivar_l168_d7_safe_execute(args ...ruby.Value) ruby.Value {
	mut ivar := ivar_boundary_receiver(args)
	if args.len < 2 {
		panic('ArgumentError: no task result given')
	}
	if args[1].type_name.ends_with('Error') {
		if ivar.compare_and_set_state(.processing, [.pending]) {
			ivar.complete(false, ivar_nil_value(), args[1].as_string()) or { panic(err) }
		}
	} else if ivar.compare_and_set_state(.processing, [.pending]) {
		ivar.complete(true, args[1], '') or { panic(err) }
	}
	return args[0]
}

// Ruby method `complete(success, value, reason)` at line 177.
pub fn ruby_ivar_l177_d8_complete(args ...ruby.Value) ruby.Value {
	mut ivar := ivar_boundary_receiver(args)
	if args.len < 4 {
		panic('complete requires success, value, and reason')
	}
	ivar.complete(args[1].as_bool() or { panic(err) }, args[2], ivar_boundary_reason(args[3])) or {
		panic(err)
	}
	return args[0]
}

// Ruby method `complete_without_notification(success, value, reason)` at line 184.
pub fn ruby_ivar_l184_d9_complete_without_notification(args ...ruby.Value) ruby.Value {
	mut ivar := ivar_boundary_receiver(args)
	if args.len < 4 {
		panic('complete_without_notification requires success, value, and reason')
	}
	ivar.complete_without_notification(args[1].as_bool() or { panic(err) }, args[2], ivar_boundary_reason(args[3])) or { panic(err) }
	return args[0]
}

// Ruby method `notify_observers(value, reason)` at line 190.
pub fn ruby_ivar_l190_d10_notify_observers(args ...ruby.Value) ruby.Value {
	mut ivar := ivar_boundary_receiver(args)
	value := if args.len > 1 { args[1] } else { ivar_nil_value() }
	reason := if args.len > 2 { ivar_boundary_reason(args[2]) } else { '' }
	ivar.notify_observers(value, reason)
	return args[0]
}

// Ruby method `ns_complete_without_notification(success, value, reason)` at line 195.
pub fn ruby_ivar_l195_d11_ns_complete_without_notification(args ...ruby.Value) ruby.Value {
	return ruby_ivar_l184_d9_complete_without_notification(...args)
}

// Ruby method `check_for_block_or_value!(block_given, value) # :nodoc:` at line 202.
pub fn ruby_ivar_l202_d12_check_for_block_or_value(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('check_for_block_or_value! requires block_given and value')
	}
	block_given := args[0].as_bool() or { panic(err) }
	value_missing := args[1].type_name == 'Concurrent::NULL'
	if (block_given && !value_missing) || (!block_given && value_missing) {
		panic('ArgumentError: must set with either a value or a block')
	}
	return ruby.object_value('NilClass', 'nil')
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/constants'
// 2: require 'concurrent/errors'
// 3: require 'concurrent/collection/copy_on_write_observer_set'
// 4: require 'concurrent/concern/obligation'
// 5: require 'concurrent/concern/observable'
// 6: require 'concurrent/executor/safe_task_executor'
// 7: require 'concurrent/synchronization/lockable_object'
// 8:
// 9: module Concurrent
// 10:
// 11:   # An `IVar` is like a future that you can assign. As a future is a value that
// 12:   # is being computed that you can wait on, an `IVar` is a value that is waiting
// 13:   # to be assigned, that you can wait on. `IVars` are single assignment and
// 14:   # deterministic.
// 15:   #
// 16:   # Then, express futures as an asynchronous computation that assigns an `IVar`.
// 17:   # The `IVar` becomes the primitive on which [futures](Future) and
// 18:   # [dataflow](Dataflow) are built.
// 19:   #
// 20:   # An `IVar` is a single-element container that is normally created empty, and
// 21:   # can only be set once. The I in `IVar` stands for immutable. Reading an
// 22:   # `IVar` normally blocks until it is set. It is safe to set and read an `IVar`
// 23:   # from different threads.
// 24:   #
// 25:   # If you want to have some parallel task set the value in an `IVar`, you want
// 26:   # a `Future`. If you want to create a graph of parallel tasks all executed
// 27:   # when the values they depend on are ready you want `dataflow`. `IVar` is
// 28:   # generally a low-level primitive.
// 29:   #
// 30:   # ## Examples
// 31:   #
// 32:   # Create, set and get an `IVar`
// 33:   #
// 34:   # ```ruby
// 35:   # ivar = Concurrent::IVar.new
// 36:   # ivar.set 14
// 37:   # ivar.value #=> 14
// 38:   # ivar.set 2 # would now be an error
// 39:   # ```
// 40:   #
// 41:   # ## See Also
// 42:   #
// 43:   # 1. For the theory: Arvind, R. Nikhil, and K. Pingali.
// 44:   #    [I-Structures: Data structures for parallel computing](http://dl.acm.org/citation.cfm?id=69562).
// 45:   #    In Proceedings of Workshop on Graph Reduction, 1986.
// 46:   # 2. For recent application:
// 47:   #    [DataDrivenFuture in Habanero Java from Rice](http://www.cs.rice.edu/~vs3/hjlib/doc/edu/rice/hj/api/HjDataDrivenFuture.html).
// 48:   class IVar < Synchronization::LockableObject
// 49:     include Concern::Obligation
// 50:     include Concern::Observable
// 51:
// 52:     # Create a new `IVar` in the `:pending` state with the (optional) initial value.
// 53:     #
// 54:     # @param [Object] value the initial value
// 55:     # @param [Hash] opts the options to create a message with
// 56:     # @option opts [String] :dup_on_deref (false) call `#dup` before returning
// 57:     #   the data
// 58:     # @option opts [String] :freeze_on_deref (false) call `#freeze` before
// 59:     #   returning the data
// 60:     # @option opts [String] :copy_on_deref (nil) call the given `Proc` passing
// 61:     #   the internal value and returning the value returned from the proc
// 62:     def initialize(value = NULL, opts = {}, &block)
// 63:       if value != NULL && block_given?
// 64:         raise ArgumentError.new('provide only a value or a block')
// 65:       end
// 66:       super(&nil)
// 67:       synchronize { ns_initialize(value, opts, &block) }
// 68:     end
// 69:
// 70:     # Add an observer on this object that will receive notification on update.
// 71:     #
// 72:     # Upon completion the `IVar` will notify all observers in a thread-safe way.
// 73:     # The `func` method of the observer will be called with three arguments: the
// 74:     # `Time` at which the `Future` completed the asynchronous operation, the
// 75:     # final `value` (or `nil` on rejection), and the final `reason` (or `nil` on
// 76:     # fulfillment).
// 77:     #
// 78:     # @param [Object] observer the object that will be notified of changes
// 79:     # @param [Symbol] func symbol naming the method to call when this
// 80:     #   `Observable` has changes`
// 81:     def add_observer(observer = nil, func = :update, &block)
// 82:       raise ArgumentError.new('cannot provide both an observer and a block') if observer && block
// 83:       direct_notification = false
// 84:
// 85:       if block
// 86:         observer = block
// 87:         func = :call
// 88:       end
// 89:
// 90:       synchronize do
// 91:         if event.set?
// 92:           direct_notification = true
// 93:         else
// 94:           observers.add_observer(observer, func)
// 95:         end
// 96:       end
// 97:
// 98:       observer.send(func, Time.now, self.value, reason) if direct_notification
// 99:       observer
// 100:     end
// 101:
// 102:     # @!macro ivar_set_method
// 103:     #   Set the `IVar` to a value and wake or notify all threads waiting on it.
// 104:     #
// 105:     #   @!macro ivar_set_parameters_and_exceptions
// 106:     #     @param [Object] value the value to store in the `IVar`
// 107:     #     @yield A block operation to use for setting the value
// 108:     #     @raise [ArgumentError] if both a value and a block are given
// 109:     #     @raise [Concurrent::MultipleAssignmentError] if the `IVar` has already
// 110:     #       been set or otherwise completed
// 111:     #
// 112:     #   @return [IVar] self
// 113:     def set(value = NULL)
// 114:       check_for_block_or_value!(block_given?, value)
// 115:       raise MultipleAssignmentError unless compare_and_set_state(:processing, :pending)
// 116:
// 117:       begin
// 118:         value = yield if block_given?
// 119:         complete_without_notification(true, value, nil)
// 120:       rescue => ex
// 121:         complete_without_notification(false, nil, ex)
// 122:       end
// 123:
// 124:       notify_observers(self.value, reason)
// 125:       self
// 126:     end
// 127:
// 128:     # @!macro ivar_fail_method
// 129:     #   Set the `IVar` to failed due to some error and wake or notify all threads waiting on it.
// 130:     #
// 131:     #   @param [Object] reason for the failure
// 132:     #   @raise [Concurrent::MultipleAssignmentError] if the `IVar` has already
// 133:     #     been set or otherwise completed
// 134:     #   @return [IVar] self
// 135:     def fail(reason = StandardError.new)
// 136:       complete(false, nil, reason)
// 137:     end
// 138:
// 139:     # Attempt to set the `IVar` with the given value or block. Return a
// 140:     # boolean indicating the success or failure of the set operation.
// 141:     #
// 142:     # @!macro ivar_set_parameters_and_exceptions
// 143:     #
// 144:     # @return [Boolean] true if the value was set else false
// 145:     def try_set(value = NULL, &block)
// 146:       set(value, &block)
// 147:       true
// 148:     rescue MultipleAssignmentError
// 149:       false
// 150:     end
// 151:
// 152:     protected
// 153:
// 154:     # @!visibility private
// 155:     def ns_initialize(value, opts)
// 156:       value = yield if block_given?
// 157:       init_obligation
// 158:       self.observers = Collection::CopyOnWriteObserverSet.new
// 159:       set_deref_options(opts)
// 160:
// 161:       @state = :pending
// 162:       if value != NULL
// 163:         ns_complete_without_notification(true, value, nil)
// 164:       end
// 165:     end
// 166:
// 167:     # @!visibility private
// 168:     def safe_execute(task, args = [])
// 169:       if compare_and_set_state(:processing, :pending)
// 170:         success, val, reason = SafeTaskExecutor.new(task, rescue_exception: true).execute(*@args)
// 171:         complete(success, val, reason)
// 172:         yield(success, val, reason) if block_given?
// 173:       end
// 174:     end
// 175:
// 176:     # @!visibility private
// 177:     def complete(success, value, reason)
// 178:       complete_without_notification(success, value, reason)
// 179:       notify_observers(self.value, reason)
// 180:       self
// 181:     end
// 182:
// 183:     # @!visibility private
// 184:     def complete_without_notification(success, value, reason)
// 185:       synchronize { ns_complete_without_notification(success, value, reason) }
// 186:       self
// 187:     end
// 188:
// 189:     # @!visibility private
// 190:     def notify_observers(value, reason)
// 191:       observers.notify_and_delete_observers{ [Time.now, value, reason] }
// 192:     end
// 193:
// 194:     # @!visibility private
// 195:     def ns_complete_without_notification(success, value, reason)
// 196:       raise MultipleAssignmentError if [:fulfilled, :rejected].include? @state
// 197:       set_state(success, value, reason)
// 198:       event.set
// 199:     end
// 200:
// 201:     # @!visibility private
// 202:     def check_for_block_or_value!(block_given, value) # :nodoc:
// 203:       if (block_given && value != NULL) || (! block_given && value == NULL)
// 204:         raise ArgumentError.new('must set with either a value or a block')
// 205:       end
// 206:     end
// 207:   end
// 208: end
