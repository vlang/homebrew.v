module atomic

import brew_runtime
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/atomic/locals.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum LocalScopeKind {
	thread
	fiber
}

pub struct LocalSlot {
pub:
	value brew_runtime.Value
}

pub struct LocalFetchResult {
pub:
	found bool
	value brew_runtime.Value
}

@[heap]
pub struct LocalStorage {
	mutex &sync.Mutex
pub:
	scope LocalScopeKind
mut:
	free_indices []int
	next_index   int
	allocated    map[int]bool
	contexts     map[u64]bool
	values       map[string]LocalSlot
}

pub fn new_local_storage(scope LocalScopeKind) &LocalStorage {
	return &LocalStorage{
		mutex: sync.new_mutex()
		scope: scope
	}
}

pub fn new_thread_locals() &LocalStorage {
	return new_local_storage(.thread)
}

pub fn new_fiber_locals() &LocalStorage {
	return new_local_storage(.fiber)
}

fn local_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

fn (storage &LocalStorage) execution_context_id() u64 {
	// Normal V builds expose a stable current OS-thread id but no public stable
	// current coroutine/fiber id. Spawned V execution contexts therefore remain
	// isolated; two experimental coroutines on one OS thread cannot be separated.
	return sync.thread_id()
}

fn local_slot_key(context_id u64, index int) string {
	return '${context_id}:${index}'
}

pub fn (mut storage LocalStorage) synchronize(action fn() !brew_runtime.Value) !brew_runtime.Value {
	storage.mutex.lock()
	defer {
		storage.mutex.unlock()
	}
	return action()!
}

pub fn (mut storage LocalStorage) weak_synchronize(action fn() !brew_runtime.Value) !brew_runtime.Value {
	// V maps are not safe for concurrent mutation, including from cleanup code,
	// so the CRuby no-lock fast path is represented by the same mutex boundary.
	return storage.synchronize(action)
}

pub fn (mut storage LocalStorage) allocate_index() int {
	storage.mutex.lock()
	defer {
		storage.mutex.unlock()
	}
	index := if storage.free_indices.len == 0 {
		storage.next_index++
		storage.next_index
	} else {
		storage.free_indices.pop()
	}
	storage.allocated[index] = true
	return index
}

pub fn (mut storage LocalStorage) free_index(index int) {
	storage.mutex.lock()
	defer {
		storage.mutex.unlock()
	}
	if index !in storage.allocated || !storage.allocated[index] {
		return
	}
	for context_id in storage.contexts.keys() {
		storage.values.delete(local_slot_key(context_id, index))
	}
	storage.allocated[index] = false
	storage.free_indices << index
}

pub fn (mut storage LocalStorage) fetch(index int) LocalFetchResult {
	context_id := storage.execution_context_id()
	storage.mutex.lock()
	defer {
		storage.mutex.unlock()
	}
	key := local_slot_key(context_id, index)
	if key !in storage.values {
		return LocalFetchResult{
			found: false
			value: local_nil_value()
		}
	}
	return LocalFetchResult{
		found: true
		value: storage.values[key].value
	}
}

pub fn (mut storage LocalStorage) set(index int, value brew_runtime.Value) brew_runtime.Value {
	context_id := storage.execution_context_id()
	storage.mutex.lock()
	storage.contexts[context_id] = true
	storage.values[local_slot_key(context_id, index)] = LocalSlot{
		value: value
	}
	storage.mutex.unlock()
	return value
}

pub fn (mut storage LocalStorage) current_locals() ?[]brew_runtime.Value {
	context_id := storage.execution_context_id()
	storage.mutex.lock()
	defer {
		storage.mutex.unlock()
	}
	if context_id !in storage.contexts {
		return none
	}
	mut locals := []brew_runtime.Value{len: storage.next_index + 1, init: local_nil_value()}
	for index in 1 .. storage.next_index + 1 {
		key := local_slot_key(context_id, index)
		if key in storage.values {
			locals[index] = storage.values[key].value
		}
	}
	return locals
}

pub fn (mut storage LocalStorage) current_locals_or_create() []brew_runtime.Value {
	context_id := storage.execution_context_id()
	storage.mutex.lock()
	storage.contexts[context_id] = true
	mut locals := []brew_runtime.Value{len: storage.next_index + 1, init: local_nil_value()}
	for index in 1 .. storage.next_index + 1 {
		key := local_slot_key(context_id, index)
		if key in storage.values {
			locals[index] = storage.values[key].value
		}
	}
	storage.mutex.unlock()
	return locals
}

pub fn (mut storage LocalStorage) clear_context(context_id u64) {
	storage.mutex.lock()
	for index in 1 .. storage.next_index + 1 {
		storage.values.delete(local_slot_key(context_id, index))
	}
	storage.contexts.delete(context_id)
	storage.mutex.unlock()
}

pub fn (mut storage LocalStorage) clear_current_context() {
	storage.clear_context(storage.execution_context_id())
}

pub fn (mut storage LocalStorage) allocated_count() int {
	storage.mutex.lock()
	defer {
		storage.mutex.unlock()
	}
	mut count := 0
	for allocated in storage.allocated.values() {
		if allocated {
			count++
		}
	}
	return count
}

pub fn (mut storage LocalStorage) context_count() int {
	storage.mutex.lock()
	defer {
		storage.mutex.unlock()
	}
	return storage.contexts.len
}

pub enum LocalFinalizerKind {
	index
	context
}

@[heap]
pub struct LocalFinalizer {
	storage &LocalStorage
	mutex   &sync.Mutex
	kind    LocalFinalizerKind
	value   u64
mut:
	run bool
}

pub fn new_local_index_finalizer(storage &LocalStorage, index int) &LocalFinalizer {
	return &LocalFinalizer{
		storage: storage
		mutex: sync.new_mutex()
		kind: .index
		value: u64(index)
	}
}

pub fn new_local_context_finalizer(storage &LocalStorage, context_id u64) &LocalFinalizer {
	return &LocalFinalizer{
		storage: storage
		mutex: sync.new_mutex()
		kind: .context
		value: context_id
	}
}

pub fn (mut finalizer LocalFinalizer) call() {
	finalizer.mutex.lock()
	if finalizer.run {
		finalizer.mutex.unlock()
		return
	}
	finalizer.run = true
	finalizer.mutex.unlock()
	mut storage := finalizer.storage
	match finalizer.kind {
		.index { storage.free_index(int(finalizer.value)) }
		.context { storage.clear_context(finalizer.value) }
	}
}

pub type LocalDefaultBlock = fn() !brew_runtime.Value

pub type LocalBindingBlock = fn() !brew_runtime.Value

fn empty_local_default_block() !brew_runtime.Value {
	return local_nil_value()
}

fn local_value_truthy(value brew_runtime.Value) bool {
	if value.type_name == 'NilClass' {
		return false
	}
	if value.type_name == 'Bool' {
		return value.as_bool() or { false }
	}
	return true
}

@[heap]
pub struct LocalVariable {
mut:
	storage                &LocalStorage
	index                  int
	default_value          brew_runtime.Value
	default_block          LocalDefaultBlock @[required]
	has_default_block      bool
	boundary_default_value brew_runtime.Value
	has_boundary_default   bool
	freed                  bool
}

pub fn new_local_variable(mut storage LocalStorage, default_value brew_runtime.Value) &LocalVariable {
	index := storage.allocate_index()
	return &LocalVariable{
		storage: &storage
		index: index
		default_value: default_value
		default_block: empty_local_default_block
	}
}

pub fn new_local_variable_with_default_block(mut storage LocalStorage, default_value brew_runtime.Value, default_block LocalDefaultBlock) !&LocalVariable {
	if local_value_truthy(default_value) {
		return error('Cannot use both value and block as default value')
	}
	index := storage.allocate_index()
	return &LocalVariable{
		storage: &storage
		index: index
		default_value: local_nil_value()
		default_block: default_block
		has_default_block: true
	}
}

fn new_local_variable_with_boundary_default(mut storage LocalStorage, default_value brew_runtime.Value, block_value brew_runtime.Value) !&LocalVariable {
	if local_value_truthy(default_value) {
		return error('Cannot use both value and block as default value')
	}
	index := storage.allocate_index()
	return &LocalVariable{
		storage: &storage
		index: index
		default_value: local_nil_value()
		default_block: empty_local_default_block
		boundary_default_value: block_value
		has_boundary_default: true
	}
}

pub fn (mut variable LocalVariable) default_current() !brew_runtime.Value {
	if variable.freed {
		return error('local variable has been freed')
	}
	if variable.has_default_block {
		value := variable.default_block()!
		return variable.storage.set(variable.index, value)
	}
	if variable.has_boundary_default {
		return variable.storage.set(variable.index, variable.boundary_default_value)
	}
	return variable.default_value
}

pub fn (mut variable LocalVariable) value() !brew_runtime.Value {
	if variable.freed {
		return error('local variable has been freed')
	}
	result := variable.storage.fetch(variable.index)
	if result.found {
		return result.value
	}
	return variable.default_current()
}

pub fn (mut variable LocalVariable) set(value brew_runtime.Value) !brew_runtime.Value {
	if variable.freed {
		return error('local variable has been freed')
	}
	return variable.storage.set(variable.index, value)
}

pub fn (mut variable LocalVariable) bind(value brew_runtime.Value, action LocalBindingBlock) !brew_runtime.Value {
	old_value := variable.value()!
	variable.set(value)!
	defer {
		variable.set(old_value) or {}
	}
	return action()!
}

pub fn (mut variable LocalVariable) free() {
	if variable.freed {
		return
	}
	variable.storage.free_index(variable.index)
	variable.freed = true
}

pub fn (mut variable LocalVariable) clear_current_context() {
	variable.storage.clear_current_context()
}

pub fn (variable &LocalVariable) slot_index() int {
	return variable.index
}

fn local_storage_boundary(storage &LocalStorage, type_name string) brew_runtime.Value {
	return brew_runtime.structured_value(type_name, '#<Concurrent::${type_name}>', {
		'local_storage_address': u64(voidptr(storage)).str()
	})
}

fn local_storage_boundary_receiver(args []brew_runtime.Value) &LocalStorage {
	if args.len == 0 {
		panic('local storage method requires a receiver')
	}
	address := (args[0].attribute('local_storage_address') or {
		panic('${args[0].type_name} has no translated local storage state')
	}).u64()
	return unsafe { &LocalStorage(voidptr(address)) }
}

fn local_finalizer_boundary(finalizer &LocalFinalizer) brew_runtime.Value {
	return brew_runtime.structured_value('Proc', '#<Proc>', {
		'local_finalizer_address': u64(voidptr(finalizer)).str()
	})
}

// Ruby method `initialize` at line 36.
pub fn ruby_locals_l36_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	scope := if args.len > 0 && args[0].as_string().to_lower() == 'fiber' {
		LocalScopeKind.fiber
	} else {
		LocalScopeKind.thread
	}
	return local_storage_boundary(new_local_storage(scope), 'AbstractLocals')
}

// Ruby method `synchronize` at line 43.
pub fn ruby_locals_l43_d2_synchronize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return local_nil_value()
	}
	mut storage := local_storage_boundary_receiver(args)
	storage.mutex.lock()
	defer { storage.mutex.unlock() }
	return args[1]
}

// Ruby method `weak_synchronize` at line 48.
pub fn ruby_locals_l48_d3_weak_synchronize(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_locals_l43_d2_synchronize(...args)
}

// Ruby alias_method `alias_method :weak_synchronize, :synchronize` at line 52.
pub fn ruby_locals_l52_d4_weak_synchronize(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_locals_l43_d2_synchronize(...args)
}

// Ruby method `next_index(local)` at line 55.
pub fn ruby_locals_l55_d5_next_index(args ...brew_runtime.Value) brew_runtime.Value {
	mut storage := local_storage_boundary_receiver(args)
	return brew_runtime.int_value(storage.allocate_index())
}

// Ruby method `free_index(index)` at line 71.
pub fn ruby_locals_l71_d6_free_index(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('free_index requires an index')
	}
	mut storage := local_storage_boundary_receiver(args)
	storage.free_index(int(args[1].as_int() or { panic(err) }))
	return local_nil_value()
}

// Ruby method `fetch(index)` at line 89.
pub fn ruby_locals_l89_d7_fetch(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('fetch requires an index')
	}
	mut storage := local_storage_boundary_receiver(args)
	result := storage.fetch(int(args[1].as_int() or { panic(err) }))
	if result.found {
		return result.value
	}
	return if args.len > 2 { args[2] } else { local_nil_value() }
}

// Ruby method `set(index, value)` at line 102.
pub fn ruby_locals_l102_d8_set(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('set requires an index and value')
	}
	mut storage := local_storage_boundary_receiver(args)
	return storage.set(int(args[1].as_int() or { panic(err) }), args[2])
}

// Ruby method `local_finalizer(index)` at line 112.
pub fn ruby_locals_l112_d9_local_finalizer(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('local_finalizer requires an index')
	}
	storage := local_storage_boundary_receiver(args)
	return local_finalizer_boundary(new_local_index_finalizer(storage, int(args[1].as_int() or { panic(err) })))
}

// Ruby method `thread_fiber_finalizer(array_object_id)` at line 119.
pub fn ruby_locals_l119_d10_thread_fiber_finalizer(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('thread_fiber_finalizer requires an array object id')
	}
	storage := local_storage_boundary_receiver(args)
	return local_finalizer_boundary(new_local_context_finalizer(storage, u64(args[1].as_int() or { panic(err) })))
}

// Ruby method `locals` at line 128.
pub fn ruby_locals_l128_d11_locals(args ...brew_runtime.Value) brew_runtime.Value {
	panic('NotImplementedError: AbstractLocals#locals')
}

// Ruby method `locals!` at line 133.
pub fn ruby_locals_l133_d12_locals(args ...brew_runtime.Value) brew_runtime.Value {
	panic('NotImplementedError: AbstractLocals#locals!')
}

// Ruby method `locals` at line 142.
pub fn ruby_locals_l142_d13_locals(args ...brew_runtime.Value) brew_runtime.Value {
	mut storage := local_storage_boundary_receiver(args)
	locals := storage.current_locals() or { return local_nil_value() }
	return brew_runtime.array_value(locals)
}

// Ruby method `locals!` at line 146.
pub fn ruby_locals_l146_d14_locals(args ...brew_runtime.Value) brew_runtime.Value {
	mut storage := local_storage_boundary_receiver(args)
	return brew_runtime.array_value(storage.current_locals_or_create())
}

// Ruby method `locals` at line 167.
pub fn ruby_locals_l167_d15_locals(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_locals_l142_d13_locals(...args)
}

// Ruby method `locals!` at line 171.
pub fn ruby_locals_l171_d16_locals(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_locals_l146_d14_locals(...args)
}

// Original Ruby source (line-for-line):
// 1: require 'fiber'
// 2: require 'concurrent/utility/engine'
// 3: require 'concurrent/constants'
// 4:
// 5: module Concurrent
// 6:   # @!visibility private
// 7:   # @!macro internal_implementation_note
// 8:   #
// 9:   # An abstract implementation of local storage, with sub-classes for
// 10:   # per-thread and per-fiber locals.
// 11:   #
// 12:   # Each execution context (EC, thread or fiber) has a lazily initialized array
// 13:   # of local variable values. Each time a new local variable is created, we
// 14:   # allocate an "index" for it.
// 15:   #
// 16:   # For example, if the allocated index is 1, that means slot #1 in EVERY EC's
// 17:   # locals array will be used for the value of that variable.
// 18:   #
// 19:   # The good thing about using a per-EC structure to hold values, rather than
// 20:   # a global, is that no synchronization is needed when reading and writing
// 21:   # those values (since the structure is only ever accessed by a single
// 22:   # thread).
// 23:   #
// 24:   # Of course, when a local variable is GC'd, 1) we need to recover its index
// 25:   # for use by other new local variables (otherwise the locals arrays could
// 26:   # get bigger and bigger with time), and 2) we need to null out all the
// 27:   # references held in the now-unused slots (both to avoid blocking GC of those
// 28:   # objects, and also to prevent "stale" values from being passed on to a new
// 29:   # local when the index is reused).
// 30:   #
// 31:   # Because we need to null out freed slots, we need to keep references to
// 32:   # ALL the locals arrays, so we can null out the appropriate slots in all of
// 33:   # them. This is why we need to use a finalizer to clean up the locals array
// 34:   # when the EC goes out of scope.
// 35:   class AbstractLocals
// 36:     def initialize
// 37:       @free = []
// 38:       @lock = Mutex.new
// 39:       @all_arrays = {}
// 40:       @next = 0
// 41:     end
// 42:
// 43:     def synchronize
// 44:       @lock.synchronize { yield }
// 45:     end
// 46:
// 47:     if Concurrent.on_cruby?
// 48:       def weak_synchronize
// 49:         yield
// 50:       end
// 51:     else
// 52:       alias_method :weak_synchronize, :synchronize
// 53:     end
// 54:
// 55:     def next_index(local)
// 56:       index = synchronize do
// 57:         if @free.empty?
// 58:           @next += 1
// 59:         else
// 60:           @free.pop
// 61:         end
// 62:       end
// 63:
// 64:       # When the local goes out of scope, we should free the associated index
// 65:       # and all values stored into it.
// 66:       ObjectSpace.define_finalizer(local, local_finalizer(index))
// 67:
// 68:       index
// 69:     end
// 70:
// 71:     def free_index(index)
// 72:       weak_synchronize do
// 73:         # The cost of GC'ing a TLV is linear in the number of ECs using local
// 74:         # variables. But that is natural! More ECs means more storage is used
// 75:         # per local variable. So naturally more CPU time is required to free
// 76:         # more storage.
// 77:         #
// 78:         # DO NOT use each_value which might conflict with new pair assignment
// 79:         # into the hash in #set method.
// 80:         @all_arrays.values.each do |locals|
// 81:           locals[index] = nil
// 82:         end
// 83:
// 84:         # free index has to be published after the arrays are cleared:
// 85:         @free << index
// 86:       end
// 87:     end
// 88:
// 89:     def fetch(index)
// 90:       locals = self.locals
// 91:       value = locals ? locals[index] : nil
// 92:
// 93:       if nil == value
// 94:         yield
// 95:       elsif NULL.equal?(value)
// 96:         nil
// 97:       else
// 98:         value
// 99:       end
// 100:     end
// 101:
// 102:     def set(index, value)
// 103:       locals = self.locals!
// 104:       locals[index] = (nil == value ? NULL : value)
// 105:
// 106:       value
// 107:     end
// 108:
// 109:     private
// 110:
// 111:     # When the local goes out of scope, clean up that slot across all locals currently assigned.
// 112:     def local_finalizer(index)
// 113:       proc do
// 114:         free_index(index)
// 115:       end
// 116:     end
// 117:
// 118:     # When a thread/fiber goes out of scope, remove the array from @all_arrays.
// 119:     def thread_fiber_finalizer(array_object_id)
// 120:       proc do
// 121:         weak_synchronize do
// 122:           @all_arrays.delete(array_object_id)
// 123:         end
// 124:       end
// 125:     end
// 126:
// 127:     # Returns the locals for the current scope, or nil if none exist.
// 128:     def locals
// 129:       raise NotImplementedError
// 130:     end
// 131:
// 132:     # Returns the locals for the current scope, creating them if necessary.
// 133:     def locals!
// 134:       raise NotImplementedError
// 135:     end
// 136:   end
// 137:
// 138:   # @!visibility private
// 139:   # @!macro internal_implementation_note
// 140:   # An array-backed storage of indexed variables per thread.
// 141:   class ThreadLocals < AbstractLocals
// 142:     def locals
// 143:       Thread.current.thread_variable_get(:concurrent_thread_locals)
// 144:     end
// 145:
// 146:     def locals!
// 147:       thread = Thread.current
// 148:       locals = thread.thread_variable_get(:concurrent_thread_locals)
// 149:
// 150:       unless locals
// 151:         locals = thread.thread_variable_set(:concurrent_thread_locals, [])
// 152:         weak_synchronize do
// 153:           @all_arrays[locals.object_id] = locals
// 154:         end
// 155:         # When the thread goes out of scope, we should delete the associated locals:
// 156:         ObjectSpace.define_finalizer(thread, thread_fiber_finalizer(locals.object_id))
// 157:       end
// 158:
// 159:       locals
// 160:     end
// 161:   end
// 162:
// 163:   # @!visibility private
// 164:   # @!macro internal_implementation_note
// 165:   # An array-backed storage of indexed variables per fiber.
// 166:   class FiberLocals < AbstractLocals
// 167:     def locals
// 168:       Thread.current[:concurrent_fiber_locals]
// 169:     end
// 170:
// 171:     def locals!
// 172:       thread = Thread.current
// 173:       locals = thread[:concurrent_fiber_locals]
// 174:
// 175:       unless locals
// 176:         locals = thread[:concurrent_fiber_locals] = []
// 177:         weak_synchronize do
// 178:           @all_arrays[locals.object_id] = locals
// 179:         end
// 180:         # When the fiber goes out of scope, we should delete the associated locals:
// 181:         ObjectSpace.define_finalizer(Fiber.current, thread_fiber_finalizer(locals.object_id))
// 182:       end
// 183:
// 184:       locals
// 185:     end
// 186:   end
// 187:
// 188:   private_constant :AbstractLocals, :ThreadLocals, :FiberLocals
// 189: end
