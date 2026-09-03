module util

import brew_runtime
import sync

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/thread_safe/util/striped64.rb`.
// The original source is retained below until every stub has a typed V body.
pub type Striped64Update = fn(i64) !i64

pub type Striped64BusyAction = fn() !

@[heap]
pub struct Striped64Cell {
mut:
	lock  sync.Mutex
	value i64
}

struct Striped64CellSlot {
mut:
	set  bool
	cell &Striped64Cell = unsafe { nil }
}

@[heap]
pub struct Striped64CellTable {
pub:
	size int
mut:
	lock  sync.RwMutex
	slots []Striped64CellSlot
}

@[heap]
pub struct Striped64 {
mut:
	lock       sync.Mutex
	cells      &Striped64CellTable = unsafe { nil }
	has_cells  bool
	base       i64
	busy       bool
	hash_codes map[u64]i64
}

pub fn new_striped64_cell(value i64) &Striped64Cell {
	return &Striped64Cell{
		value: value
	}
}

pub fn (mut cell Striped64Cell) get() i64 {
	cell.lock.lock()
	value := cell.value
	cell.lock.unlock()
	return value
}

pub fn (mut cell Striped64Cell) set(value i64) i64 {
	cell.lock.lock()
	cell.value = value
	cell.lock.unlock()
	return value
}

pub fn (mut cell Striped64Cell) add(value i64) i64 {
	cell.lock.lock()
	cell.value += value
	result := cell.value
	cell.lock.unlock()
	return result
}

pub fn (mut cell Striped64Cell) compare_and_set(expected i64, prospect i64) bool {
	cell.lock.lock()
	if cell.value != expected {
		cell.lock.unlock()
		return false
	}
	cell.value = prospect
	cell.lock.unlock()
	return true
}

pub fn (mut cell Striped64Cell) cas_computed(update Striped64Update) !bool {
	cell.lock.lock()
	current := cell.value
	prospect := update(current) or {
		cell.lock.unlock()
		return err
	}
	cell.value = prospect
	cell.lock.unlock()
	return true
}

pub fn new_striped64_cell_table(size int) !&Striped64CellTable {
	if size <= 0 || (size & (size - 1)) != 0 {
		return error('size must be a power of 2 (${size} provided)')
	}
	return &Striped64CellTable{
		size: size
		slots: []Striped64CellSlot{len: size}
	}
}

pub fn (table &Striped64CellTable) hash_to_index(hash i64) int {
	return int((i64(table.size) - 1) & hash)
}

pub fn (mut table Striped64CellTable) get(index int) ?&Striped64Cell {
	if index < 0 || index >= table.size {
		return none
	}
	table.lock.rlock()
	if !table.slots[index].set {
		table.lock.runlock()
		return none
	}
	cell := table.slots[index].cell
	table.lock.runlock()
	return cell
}

pub fn (mut table Striped64CellTable) get_by_hash(hash i64) ?&Striped64Cell {
	return table.get(table.hash_to_index(hash))
}

pub fn (mut table Striped64CellTable) set(index int, cell &Striped64Cell) ! {
	if index < 0 || index >= table.size {
		return error('index ${index} outside cell table of size ${table.size}')
	}
	table.lock.lock()
	table.slots[index].cell = cell
	table.slots[index].set = true
	table.lock.unlock()
}

pub fn (mut table Striped64CellTable) set_by_hash(hash i64, cell &Striped64Cell) ! {
	table.set(table.hash_to_index(hash), cell)!
}

pub fn (mut table Striped64CellTable) next_in_size_table() !&Striped64CellTable {
	mut next := new_striped64_cell_table(table.size * 2)!
	table.lock.rlock()
	for index, slot in table.slots {
		if slot.set {
			next.slots[index] = Striped64CellSlot{
				set: true
				cell: slot.cell
			}
		}
	}
	table.lock.runlock()
	return next
}

pub fn new_striped64() &Striped64 {
	return &Striped64{
		hash_codes: map[u64]i64{}
	}
}

pub fn (mut striped Striped64) cells_snapshot() ?&Striped64CellTable {
	striped.lock.lock()
	if !striped.has_cells {
		striped.lock.unlock()
		return none
	}
	table := striped.cells
	striped.lock.unlock()
	return table
}

pub fn (mut striped Striped64) set_cells(table &Striped64CellTable) &Striped64CellTable {
	striped.lock.lock()
	striped.cells = table
	striped.has_cells = true
	striped.lock.unlock()
	return table
}

pub fn (mut striped Striped64) clear_cells() {
	striped.lock.lock()
	striped.cells = unsafe { nil }
	striped.has_cells = false
	striped.lock.unlock()
}

pub fn (mut striped Striped64) compare_and_set_cells(expected_address u64, prospect_address u64) bool {
	striped.lock.lock()
	current_address := if striped.has_cells { u64(voidptr(striped.cells)) } else { u64(0) }
	if current_address != expected_address {
		striped.lock.unlock()
		return false
	}
	if prospect_address == 0 {
		striped.cells = unsafe { nil }
		striped.has_cells = false
	} else {
		striped.cells = unsafe { &Striped64CellTable(voidptr(prospect_address)) }
		striped.has_cells = true
	}
	striped.lock.unlock()
	return true
}

pub fn (mut striped Striped64) base_value() i64 {
	striped.lock.lock()
	value := striped.base
	striped.lock.unlock()
	return value
}

pub fn (mut striped Striped64) set_base(value i64) i64 {
	striped.lock.lock()
	striped.base = value
	striped.lock.unlock()
	return value
}

pub fn (mut striped Striped64) add_base(value i64) i64 {
	striped.lock.lock()
	striped.base += value
	result := striped.base
	striped.lock.unlock()
	return result
}

pub fn (mut striped Striped64) compare_and_set_base(expected i64, prospect i64) bool {
	striped.lock.lock()
	if striped.base != expected {
		striped.lock.unlock()
		return false
	}
	striped.base = prospect
	striped.lock.unlock()
	return true
}

pub fn (mut striped Striped64) cas_base_computed(update Striped64Update) !bool {
	striped.lock.lock()
	current := striped.base
	prospect := update(current) or {
		striped.lock.unlock()
		return err
	}
	striped.base = prospect
	striped.lock.unlock()
	return true
}

pub fn (mut striped Striped64) busy_value() bool {
	striped.lock.lock()
	value := striped.busy
	striped.lock.unlock()
	return value
}

pub fn (mut striped Striped64) set_busy(value bool) bool {
	striped.lock.lock()
	striped.busy = value
	striped.lock.unlock()
	return value
}

pub fn (mut striped Striped64) compare_and_set_busy(expected bool, prospect bool) bool {
	striped.lock.lock()
	if striped.busy != expected {
		striped.lock.unlock()
		return false
	}
	striped.busy = prospect
	striped.lock.unlock()
	return true
}

pub fn (mut striped Striped64) is_free() bool {
	return !striped.busy_value()
}

pub fn (mut striped Striped64) hash_code() i64 {
	context := sync.thread_id()
	striped.lock.lock()
	if context in striped.hash_codes {
		value := striped.hash_codes[context]
		striped.lock.unlock()
		return value
	}
	mut value := initial_xorshift_seed() or { i64(context) | 1 }
	if value == 0 {
		value = 1
	}
	striped.hash_codes[context] = value
	striped.lock.unlock()
	return value
}

pub fn (mut striped Striped64) set_hash_code(value i64) i64 {
	striped.lock.lock()
	striped.hash_codes[sync.thread_id()] = value
	striped.lock.unlock()
	return value
}

pub fn (mut striped Striped64) internal_reset(initial_value i64) {
	striped.set_base(initial_value)
	if mut table := striped.cells_snapshot() {
		for index in 0 .. table.size {
			if mut cell := table.get(index) {
				cell.set(initial_value)
			}
		}
	}
}

pub fn (mut striped Striped64) try_initialize_cells(value i64, hash i64) !bool {
	striped.lock.lock()
	if striped.busy || striped.has_cells {
		striped.lock.unlock()
		return false
	}
	striped.busy = true
	mut table := new_striped64_cell_table(2) or {
		striped.busy = false
		striped.lock.unlock()
		return err
	}
	table.set_by_hash(hash, new_striped64_cell(value)) or {
		striped.busy = false
		striped.lock.unlock()
		return err
	}
	striped.cells = table
	striped.has_cells = true
	striped.busy = false
	striped.lock.unlock()
	return true
}

pub fn (mut striped Striped64) expand_table_unless_stale(current &Striped64CellTable) !bool {
	striped.lock.lock()
	if striped.busy || !striped.has_cells || striped.cells != current {
		striped.lock.unlock()
		return false
	}
	striped.busy = true
	mut current_mut := unsafe { current }
	next := current_mut.next_in_size_table() or {
		striped.busy = false
		striped.lock.unlock()
		return err
	}
	striped.cells = next
	striped.busy = false
	striped.lock.unlock()
	return true
}

pub fn (mut striped Striped64) try_to_install_new_cell(cell &Striped64Cell, hash i64) !bool {
	striped.lock.lock()
	if striped.busy || !striped.has_cells {
		striped.lock.unlock()
		return false
	}
	striped.busy = true
	mut table := striped.cells
	index := table.hash_to_index(hash)
	if _ := table.get(index) {
		striped.busy = false
		striped.lock.unlock()
		return false
	}
	table.set(index, cell) or {
		striped.busy = false
		striped.lock.unlock()
		return err
	}
	striped.busy = false
	striped.lock.unlock()
	return true
}

pub fn (mut striped Striped64) try_in_busy(action Striped64BusyAction) !bool {
	if !striped.compare_and_set_busy(false, true) {
		return false
	}
	action() or {
		striped.set_busy(false)
		return err
	}
	striped.set_busy(false)
	return true
}

pub fn (mut striped Striped64) retry_update(value i64, hash_code i64, was_uncontended bool, update Striped64Update) ! {
	mut hash := hash_code
	mut uncontended := was_uncontended
	mut collided := false
	for {
		if mut current_cells := striped.cells_snapshot() {
			if mut cell := current_cells.get_by_hash(hash) {
				if !uncontended {
					uncontended = true
				} else if cell.cas_computed(update)! {
					break
				} else if current_cells.size >= 16 {
					collided = false
				} else if collided && striped.expand_table_unless_stale(current_cells)! {
					collided = false
					continue
				} else {
					collided = true
				}
			} else if striped.busy_value() {
				collided = false
			} else if striped.try_to_install_new_cell(new_striped64_cell(value), hash)! {
				break
			} else {
				continue
			}
			hash = xorshift_64(hash)
		} else {
			if striped.try_initialize_cells(value, hash)! {
				break
			}
			if striped.cas_base_computed(update)! {
				break
			}
		}
	}
	striped.set_hash_code(hash)
}

// Adder is the only source subclass of Striped64 in this vendored version. This
// boundary helper is the concrete form of its `current_value + x` retry block.
pub fn (mut striped Striped64) retry_add(value i64, hash_code i64, was_uncontended bool) ! {
	mut hash := hash_code
	mut uncontended := was_uncontended
	for {
		if mut current_cells := striped.cells_snapshot() {
			if mut cell := current_cells.get_by_hash(hash) {
				if !uncontended {
					uncontended = true
				} else {
					cell.add(value)
					break
				}
			} else if !striped.busy_value() && striped.try_to_install_new_cell(new_striped64_cell(value), hash)! {
				break
			}
			hash = xorshift_64(hash)
		} else if striped.try_initialize_cells(value, hash)! {
			break
		} else {
			striped.add_base(value)
			break
		}
	}
	striped.set_hash_code(hash)
}

fn striped64_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

fn striped64_cell_boundary(cell &Striped64Cell) brew_runtime.Value {
	return brew_runtime.structured_value('Concurrent::ThreadSafe::Util::Striped64::Cell', '#<Striped64::Cell>', {
		'striped64_cell_address': u64(voidptr(cell)).str()
	})
}

fn striped64_cell_from_value(value brew_runtime.Value) &Striped64Cell {
	address := (value.attribute('striped64_cell_address') or {
		panic('${value.type_name} has no translated Striped64::Cell state')
	}).u64()
	return unsafe { &Striped64Cell(voidptr(address)) }
}

fn striped64_table_boundary(table &Striped64CellTable) brew_runtime.Value {
	return brew_runtime.structured_value('Concurrent::ThreadSafe::Util::PowerOfTwoTuple', '#<PowerOfTwoTuple size=${table.size}>', {
		'striped64_table_address': u64(voidptr(table)).str()
		'size':                    table.size.str()
	})
}

fn striped64_table_address(value brew_runtime.Value) u64 {
	if value.type_name == 'NilClass' {
		return 0
	}
	return (value.attribute('striped64_table_address') or {
		panic('${value.type_name} has no translated Striped64 cell-table state')
	}).u64()
}

fn striped64_boundary(striped &Striped64) brew_runtime.Value {
	return brew_runtime.structured_value('Concurrent::ThreadSafe::Util::Striped64', '#<Striped64>', {
		'striped64_address': u64(voidptr(striped)).str()
	})
}

fn striped64_from_args(args []brew_runtime.Value) &Striped64 {
	if args.len == 0 {
		panic('Striped64 method requires a receiver')
	}
	address := (args[0].attribute('striped64_address') or {
		panic('${args[0].type_name} has no translated Striped64 state')
	}).u64()
	return unsafe { &Striped64(voidptr(address)) }
}

// Ruby alias_method `alias_method :cas, :compare_and_set` at line 89.
pub fn ruby_striped64_l89_d1_cas(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('Striped64::Cell#cas requires old and new values')
	}
	mut cell := striped64_cell_from_value(args[0])
	return brew_runtime.bool_value(cell.compare_and_set(args[1].as_int() or { panic(err) }, args[2].as_int() or { panic(err) }))
}

// Ruby method `cas_computed` at line 91.
pub fn ruby_striped64_l91_d2_cas_computed(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Striped64::Cell#cas_computed requires a translated computed value')
	}
	mut cell := striped64_cell_from_value(args[0])
	current := cell.get()
	return brew_runtime.bool_value(cell.compare_and_set(current, args[1].as_int() or { panic(err) }))
}

// Ruby method `self.padding` at line 96.
pub fn ruby_striped64_l96_d3_self_padding(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_array_value([
		'padding_0',
		'padding_1',
		'padding_2',
		'padding_3',
		'padding_4',
		'padding_5',
		'padding_6',
		'padding_7',
		'padding_8',
		'padding_9',
		'padding_10',
		'padding_11',
	])
}

// Ruby attr_reader `attr_reader :padding_0, :padding_1, :padding_2, :padding_3, :padding_4, :padding_5, :padding_6, :padding_7, :padding_8, :padding_9, :padding_10, :padding_11` at line 100.
pub fn ruby_striped64_l100_d4_padding_0(args ...brew_runtime.Value) brew_runtime.Value {
	return striped64_nil_value()
}

// Ruby attr_reader `attr_reader :padding_0, :padding_1, :padding_2, :padding_3, :padding_4, :padding_5, :padding_6, :padding_7, :padding_8, :padding_9, :padding_10, :padding_11` at line 100.
pub fn ruby_striped64_l100_d5_padding_1(args ...brew_runtime.Value) brew_runtime.Value {
	return striped64_nil_value()
}

// Ruby attr_reader `attr_reader :padding_0, :padding_1, :padding_2, :padding_3, :padding_4, :padding_5, :padding_6, :padding_7, :padding_8, :padding_9, :padding_10, :padding_11` at line 100.
pub fn ruby_striped64_l100_d6_padding_2(args ...brew_runtime.Value) brew_runtime.Value {
	return striped64_nil_value()
}

// Ruby attr_reader `attr_reader :padding_0, :padding_1, :padding_2, :padding_3, :padding_4, :padding_5, :padding_6, :padding_7, :padding_8, :padding_9, :padding_10, :padding_11` at line 100.
pub fn ruby_striped64_l100_d7_padding_3(args ...brew_runtime.Value) brew_runtime.Value {
	return striped64_nil_value()
}

// Ruby attr_reader `attr_reader :padding_0, :padding_1, :padding_2, :padding_3, :padding_4, :padding_5, :padding_6, :padding_7, :padding_8, :padding_9, :padding_10, :padding_11` at line 100.
pub fn ruby_striped64_l100_d8_padding_4(args ...brew_runtime.Value) brew_runtime.Value {
	return striped64_nil_value()
}

// Ruby attr_reader `attr_reader :padding_0, :padding_1, :padding_2, :padding_3, :padding_4, :padding_5, :padding_6, :padding_7, :padding_8, :padding_9, :padding_10, :padding_11` at line 100.
pub fn ruby_striped64_l100_d9_padding_5(args ...brew_runtime.Value) brew_runtime.Value {
	return striped64_nil_value()
}

// Ruby attr_reader `attr_reader :padding_0, :padding_1, :padding_2, :padding_3, :padding_4, :padding_5, :padding_6, :padding_7, :padding_8, :padding_9, :padding_10, :padding_11` at line 100.
pub fn ruby_striped64_l100_d10_padding_6(args ...brew_runtime.Value) brew_runtime.Value {
	return striped64_nil_value()
}

// Ruby attr_reader `attr_reader :padding_0, :padding_1, :padding_2, :padding_3, :padding_4, :padding_5, :padding_6, :padding_7, :padding_8, :padding_9, :padding_10, :padding_11` at line 100.
pub fn ruby_striped64_l100_d11_padding_7(args ...brew_runtime.Value) brew_runtime.Value {
	return striped64_nil_value()
}

// Ruby attr_reader `attr_reader :padding_0, :padding_1, :padding_2, :padding_3, :padding_4, :padding_5, :padding_6, :padding_7, :padding_8, :padding_9, :padding_10, :padding_11` at line 100.
pub fn ruby_striped64_l100_d12_padding_8(args ...brew_runtime.Value) brew_runtime.Value {
	return striped64_nil_value()
}

// Ruby attr_reader `attr_reader :padding_0, :padding_1, :padding_2, :padding_3, :padding_4, :padding_5, :padding_6, :padding_7, :padding_8, :padding_9, :padding_10, :padding_11` at line 100.
pub fn ruby_striped64_l100_d13_padding_9(args ...brew_runtime.Value) brew_runtime.Value {
	return striped64_nil_value()
}

// Ruby attr_reader `attr_reader :padding_0, :padding_1, :padding_2, :padding_3, :padding_4, :padding_5, :padding_6, :padding_7, :padding_8, :padding_9, :padding_10, :padding_11` at line 100.
pub fn ruby_striped64_l100_d14_padding_10(args ...brew_runtime.Value) brew_runtime.Value {
	return striped64_nil_value()
}

// Ruby attr_reader `attr_reader :padding_0, :padding_1, :padding_2, :padding_3, :padding_4, :padding_5, :padding_6, :padding_7, :padding_8, :padding_9, :padding_10, :padding_11` at line 100.
pub fn ruby_striped64_l100_d15_padding_11(args ...brew_runtime.Value) brew_runtime.Value {
	return striped64_nil_value()
}

// Ruby attr_volatile `attr_volatile :cells, :base, :busy` at line 106.
pub fn ruby_striped64_l106_d16_cells(args ...brew_runtime.Value) brew_runtime.Value {
	mut striped := striped64_from_args(args)
	return if table := striped.cells_snapshot() {
		striped64_table_boundary(table)
	} else {
		striped64_nil_value()
	}
}

// Ruby attr_volatile `attr_volatile :cells, :base, :busy` at line 106.
pub fn ruby_striped64_l106_d17_cells(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Striped64#cells= requires a value')
	}
	mut striped := striped64_from_args(args)
	address := striped64_table_address(args[1])
	if address == 0 {
		striped.clear_cells()
	} else {
		striped.set_cells(unsafe { &Striped64CellTable(voidptr(address)) })
	}
	return args[1]
}

// Ruby attr_volatile `attr_volatile :cells, :base, :busy` at line 106.
pub fn ruby_striped64_l106_d18_compare_and_set_cells(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('Striped64#compare_and_set_cells requires old and new values')
	}
	mut striped := striped64_from_args(args)
	return brew_runtime.bool_value(striped.compare_and_set_cells(striped64_table_address(args[1]), striped64_table_address(args[2])))
}

// Ruby attr_volatile `attr_volatile :cells, :base, :busy` at line 106.
pub fn ruby_striped64_l106_d19_cas_cells(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_striped64_l106_d18_compare_and_set_cells(...args)
}

// Ruby attr_volatile `attr_volatile :cells, :base, :busy` at line 106.
pub fn ruby_striped64_l106_d20_lazy_set_cells(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_striped64_l106_d17_cells(...args)
}

// Ruby attr_volatile `attr_volatile :cells, :base, :busy` at line 106.
pub fn ruby_striped64_l106_d21_base(args ...brew_runtime.Value) brew_runtime.Value {
	mut striped := striped64_from_args(args)
	return brew_runtime.int_value(striped.base_value())
}

// Ruby attr_volatile `attr_volatile :cells, :base, :busy` at line 106.
pub fn ruby_striped64_l106_d22_base(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Striped64#base= requires a value')
	}
	mut striped := striped64_from_args(args)
	return brew_runtime.int_value(striped.set_base(args[1].as_int() or { panic(err) }))
}

// Ruby attr_volatile `attr_volatile :cells, :base, :busy` at line 106.
pub fn ruby_striped64_l106_d23_compare_and_set_base(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('Striped64#compare_and_set_base requires old and new values')
	}
	mut striped := striped64_from_args(args)
	return brew_runtime.bool_value(striped.compare_and_set_base(args[1].as_int() or { panic(err) }, args[2].as_int() or { panic(err) }))
}

// Ruby attr_volatile `attr_volatile :cells, :base, :busy` at line 106.
pub fn ruby_striped64_l106_d24_cas_base(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_striped64_l106_d23_compare_and_set_base(...args)
}

// Ruby attr_volatile `attr_volatile :cells, :base, :busy` at line 106.
pub fn ruby_striped64_l106_d25_lazy_set_base(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_striped64_l106_d22_base(...args)
}

// Ruby attr_volatile `attr_volatile :cells, :base, :busy` at line 106.
pub fn ruby_striped64_l106_d26_busy(args ...brew_runtime.Value) brew_runtime.Value {
	mut striped := striped64_from_args(args)
	return brew_runtime.bool_value(striped.busy_value())
}

// Ruby attr_volatile `attr_volatile :cells, :base, :busy` at line 106.
pub fn ruby_striped64_l106_d27_busy(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Striped64#busy= requires a value')
	}
	mut striped := striped64_from_args(args)
	return brew_runtime.bool_value(striped.set_busy(args[1].as_bool() or { panic(err) }))
}

// Ruby attr_volatile `attr_volatile :cells, :base, :busy` at line 106.
pub fn ruby_striped64_l106_d28_compare_and_set_busy(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('Striped64#compare_and_set_busy requires old and new values')
	}
	mut striped := striped64_from_args(args)
	return brew_runtime.bool_value(striped.compare_and_set_busy(args[1].as_bool() or { panic(err) }, args[2].as_bool() or { panic(err) }))
}

// Ruby attr_volatile `attr_volatile :cells, :base, :busy` at line 106.
pub fn ruby_striped64_l106_d29_cas_busy(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_striped64_l106_d28_compare_and_set_busy(...args)
}

// Ruby attr_volatile `attr_volatile :cells, :base, :busy` at line 106.
pub fn ruby_striped64_l106_d30_lazy_set_busy(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_striped64_l106_d27_busy(...args)
}

// Ruby alias_method `alias_method :busy?, :busy` at line 110.
pub fn ruby_striped64_l110_d31_busy(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_striped64_l106_d26_busy(...args)
}

// Ruby method `initialize` at line 112.
pub fn ruby_striped64_l112_d32_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return striped64_boundary(new_striped64())
}

// Ruby method `retry_update(x, hash_code, was_uncontended) # :yields: current_value` at line 131.
pub fn ruby_striped64_l131_d33_retry_update(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 4 {
		panic('Striped64#retry_update requires value, hash, and contention state')
	}
	mut striped := striped64_from_args(args)
	striped.retry_add(args[1].as_int() or { panic(err) }, args[2].as_int() or { panic(err) }, args[3].as_bool() or { panic(err) }) or { panic(err) }
	return striped64_nil_value()
}

// Ruby method `hash_code` at line 176.
pub fn ruby_striped64_l176_d34_hash_code(args ...brew_runtime.Value) brew_runtime.Value {
	mut striped := striped64_from_args(args)
	return brew_runtime.int_value(striped.hash_code())
}

// Ruby method `hash_code=(hash)` at line 180.
pub fn ruby_striped64_l180_d35_hash_code(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Striped64#hash_code= requires a value')
	}
	mut striped := striped64_from_args(args)
	return brew_runtime.int_value(striped.set_hash_code(args[1].as_int() or { panic(err) }))
}

// Ruby method `internal_reset(initial_value)` at line 185.
pub fn ruby_striped64_l185_d36_internal_reset(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Striped64#internal_reset requires a value')
	}
	mut striped := striped64_from_args(args)
	striped.internal_reset(args[1].as_int() or { panic(err) })
	return striped64_nil_value()
}

// Ruby method `cas_base_computed` at line 195.
pub fn ruby_striped64_l195_d37_cas_base_computed(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Striped64#cas_base_computed requires a translated computed value')
	}
	mut striped := striped64_from_args(args)
	current := striped.base_value()
	return brew_runtime.bool_value(striped.compare_and_set_base(current, args[1].as_int() or { panic(err) }))
}

// Ruby method `free?` at line 199.
pub fn ruby_striped64_l199_d38_free(args ...brew_runtime.Value) brew_runtime.Value {
	mut striped := striped64_from_args(args)
	return brew_runtime.bool_value(striped.is_free())
}

// Ruby method `try_initialize_cells(x, hash)` at line 203.
pub fn ruby_striped64_l203_d39_try_initialize_cells(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('Striped64#try_initialize_cells requires value and hash')
	}
	mut striped := striped64_from_args(args)
	return brew_runtime.bool_value(striped.try_initialize_cells(args[1].as_int() or { panic(err) }, args[2].as_int() or { panic(err) }) or { panic(err) })
}

// Ruby method `expand_table_unless_stale(current_cells)` at line 215.
pub fn ruby_striped64_l215_d40_expand_table_unless_stale(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Striped64#expand_table_unless_stale requires a table')
	}
	mut striped := striped64_from_args(args)
	address := striped64_table_address(args[1])
	if address == 0 {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(striped.expand_table_unless_stale(unsafe {
		&Striped64CellTable(voidptr(address))
	}) or { panic(err) })
}

// Ruby method `try_to_install_new_cell(new_cell, hash)` at line 225.
pub fn ruby_striped64_l225_d41_try_to_install_new_cell(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('Striped64#try_to_install_new_cell requires cell and hash')
	}
	mut striped := striped64_from_args(args)
	return brew_runtime.bool_value(striped.try_to_install_new_cell(striped64_cell_from_value(args[1]), args[2].as_int() or { panic(err) }) or { panic(err) })
}

// Ruby method `try_in_busy` at line 234.
pub fn ruby_striped64_l234_d42_try_in_busy(args ...brew_runtime.Value) brew_runtime.Value {
	mut striped := striped64_from_args(args)
	if !striped.compare_and_set_busy(false, true) {
		return brew_runtime.bool_value(false)
	}
	striped.set_busy(false)
	return brew_runtime.bool_value(true)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/thread_safe/util'
// 2: require 'concurrent/thread_safe/util/power_of_two_tuple'
// 3: require 'concurrent/thread_safe/util/volatile'
// 4: require 'concurrent/thread_safe/util/xor_shift_random'
// 5:
// 6: module Concurrent
// 7:
// 8:   # @!visibility private
// 9:   module ThreadSafe
// 10:
// 11:     # @!visibility private
// 12:     module Util
// 13:
// 14:       # A Ruby port of the Doug Lea's jsr166e.Striped64 class version 1.6
// 15:       # available in public domain.
// 16:       #
// 17:       # Original source code available here:
// 18:       # http://gee.cs.oswego.edu/cgi-bin/viewcvs.cgi/jsr166/src/jsr166e/Striped64.java?revision=1.6
// 19:       #
// 20:       # Class holding common representation and mechanics for classes supporting
// 21:       # dynamic striping on 64bit values.
// 22:       #
// 23:       # This class maintains a lazily-initialized table of atomically updated
// 24:       # variables, plus an extra +base+ field. The table size is a power of two.
// 25:       # Indexing uses masked per-thread hash codes. Nearly all methods on this
// 26:       # class are private, accessed directly by subclasses.
// 27:       #
// 28:       # Table entries are of class +Cell+; a variant of AtomicLong padded to
// 29:       # reduce cache contention on most processors. Padding is overkill for most
// 30:       # Atomics because they are usually irregularly scattered in memory and thus
// 31:       # don't interfere much with each other. But Atomic objects residing in
// 32:       # arrays will tend to be placed adjacent to each other, and so will most
// 33:       # often share cache lines (with a huge negative performance impact) without
// 34:       # this precaution.
// 35:       #
// 36:       # In part because +Cell+s are relatively large, we avoid creating them until
// 37:       # they are needed. When there is no contention, all updates are made to the
// 38:       # +base+ field. Upon first contention (a failed CAS on +base+ update), the
// 39:       # table is initialized to size 2. The table size is doubled upon further
// 40:       # contention until reaching the nearest power of two greater than or equal
// 41:       # to the number of CPUS. Table slots remain empty (+nil+) until they are
// 42:       # needed.
// 43:       #
// 44:       # A single spinlock (+busy+) is used for initializing and resizing the
// 45:       # table, as well as populating slots with new +Cell+s. There is no need for
// 46:       # a blocking lock: When the lock is not available, threads try other slots
// 47:       # (or the base). During these retries, there is increased contention and
// 48:       # reduced locality, which is still better than alternatives.
// 49:       #
// 50:       # Per-thread hash codes are initialized to random values. Contention and/or
// 51:       # table collisions are indicated by failed CASes when performing an update
// 52:       # operation (see method +retry_update+). Upon a collision, if the table size
// 53:       # is less than the capacity, it is doubled in size unless some other thread
// 54:       # holds the lock. If a hashed slot is empty, and lock is available, a new
// 55:       # +Cell+ is created. Otherwise, if the slot exists, a CAS is tried. Retries
// 56:       # proceed by "double hashing", using a secondary hash (XorShift) to try to
// 57:       # find a free slot.
// 58:       #
// 59:       # The table size is capped because, when there are more threads than CPUs,
// 60:       # supposing that each thread were bound to a CPU, there would exist a
// 61:       # perfect hash function mapping threads to slots that eliminates collisions.
// 62:       # When we reach capacity, we search for this mapping by randomly varying the
// 63:       # hash codes of colliding threads. Because search is random, and collisions
// 64:       # only become known via CAS failures, convergence can be slow, and because
// 65:       # threads are typically not bound to CPUS forever, may not occur at all.
// 66:       # However, despite these limitations, observed contention rates are
// 67:       # typically low in these cases.
// 68:       #
// 69:       # It is possible for a +Cell+ to become unused when threads that once hashed
// 70:       # to it terminate, as well as in the case where doubling the table causes no
// 71:       # thread to hash to it under expanded mask. We do not try to detect or
// 72:       # remove such cells, under the assumption that for long-running instances,
// 73:       # observed contention levels will recur, so the cells will eventually be
// 74:       # needed again; and for short-lived ones, it does not matter.
// 75:       #
// 76:       # @!visibility private
// 77:       class Striped64
// 78:
// 79:         # Padded variant of AtomicLong supporting only raw accesses plus CAS.
// 80:         # The +value+ field is placed between pads, hoping that the JVM doesn't
// 81:         # reorder them.
// 82:         #
// 83:         # Optimisation note: It would be possible to use a release-only
// 84:         # form of CAS here, if it were provided.
// 85:         #
// 86:         # @!visibility private
// 87:         class Cell < Concurrent::AtomicReference
// 88:
// 89:           alias_method :cas, :compare_and_set
// 90:
// 91:           def cas_computed
// 92:             cas(current_value = value, yield(current_value))
// 93:           end
// 94:
// 95:           # @!visibility private
// 96:           def self.padding
// 97:             # TODO: this only adds padding after the :value slot, need to find a way to add padding before the slot
// 98:             # TODO (pitr-ch 28-Jul-2018): the padding instance vars may not be created
// 99:             # hide from yardoc in a method
// 100:             attr_reader :padding_0, :padding_1, :padding_2, :padding_3, :padding_4, :padding_5, :padding_6, :padding_7, :padding_8, :padding_9, :padding_10, :padding_11
// 101:           end
// 102:           padding
// 103:         end
// 104:
// 105:         extend Volatile
// 106:         attr_volatile :cells, # Table of cells. When non-null, size is a power of 2.
// 107:           :base,  # Base value, used mainly when there is no contention, but also as a fallback during table initialization races. Updated via CAS.
// 108:           :busy   # Spinlock (locked via CAS) used when resizing and/or creating Cells.
// 109:
// 110:         alias_method :busy?, :busy
// 111:
// 112:         def initialize
// 113:           super()
// 114:           self.busy = false
// 115:           self.base = 0
// 116:         end
// 117:
// 118:         # Handles cases of updates involving initialization, resizing,
// 119:         # creating new Cells, and/or contention. See above for
// 120:         # explanation. This method suffers the usual non-modularity
// 121:         # problems of optimistic retry code, relying on rechecked sets of
// 122:         # reads.
// 123:         #
// 124:         # Arguments:
// 125:         # [+x+]
// 126:         #   the value
// 127:         # [+hash_code+]
// 128:         #   hash code used
// 129:         # [+x+]
// 130:         #   false if CAS failed before call
// 131:         def retry_update(x, hash_code, was_uncontended) # :yields: current_value
// 132:           hash     = hash_code
// 133:           collided = false # True if last slot nonempty
// 134:           while true
// 135:             if current_cells = cells
// 136:               if !(cell = current_cells.volatile_get_by_hash(hash))
// 137:                 if busy?
// 138:                   collided = false
// 139:                 else # Try to attach new Cell
// 140:                   if try_to_install_new_cell(Cell.new(x), hash) # Optimistically create and try to insert new cell
// 141:                     break
// 142:                   else
// 143:                     redo # Slot is now non-empty
// 144:                   end
// 145:                 end
// 146:               elsif !was_uncontended # CAS already known to fail
// 147:                 was_uncontended = true # Continue after rehash
// 148:               elsif cell.cas_computed {|current_value| yield current_value}
// 149:                 break
// 150:               elsif current_cells.size >= CPU_COUNT || cells != current_cells # At max size or stale
// 151:                 collided = false
// 152:               elsif collided && expand_table_unless_stale(current_cells)
// 153:                 collided = false
// 154:                 redo # Retry with expanded table
// 155:               else
// 156:                 collided = true
// 157:               end
// 158:               hash = XorShiftRandom.xorshift(hash)
// 159:
// 160:             elsif try_initialize_cells(x, hash) || cas_base_computed {|current_base| yield current_base}
// 161:               break
// 162:             end
// 163:           end
// 164:           self.hash_code = hash
// 165:         end
// 166:
// 167:         private
// 168:         # Static per-thread hash code key. Shared across all instances to
// 169:         # reduce Thread locals pollution and because adjustments due to
// 170:         # collisions in one table are likely to be appropriate for
// 171:         # others.
// 172:         THREAD_LOCAL_KEY = "#{name}.hash_code".to_sym
// 173:
// 174:         # A thread-local hash code accessor. The code is initially
// 175:         # random, but may be set to a different value upon collisions.
// 176:         def hash_code
// 177:           Thread.current[THREAD_LOCAL_KEY] ||= XorShiftRandom.get
// 178:         end
// 179:
// 180:         def hash_code=(hash)
// 181:           Thread.current[THREAD_LOCAL_KEY] = hash
// 182:         end
// 183:
// 184:         # Sets base and all +cells+ to the given value.
// 185:         def internal_reset(initial_value)
// 186:           current_cells = cells
// 187:           self.base     = initial_value
// 188:           if current_cells
// 189:             current_cells.each do |cell|
// 190:               cell.value = initial_value if cell
// 191:             end
// 192:           end
// 193:         end
// 194:
// 195:         def cas_base_computed
// 196:           cas_base(current_base = base, yield(current_base))
// 197:         end
// 198:
// 199:         def free?
// 200:           !busy?
// 201:         end
// 202:
// 203:         def try_initialize_cells(x, hash)
// 204:           if free? && !cells
// 205:             try_in_busy do
// 206:               unless cells # Recheck under lock
// 207:                 new_cells = PowerOfTwoTuple.new(2)
// 208:                 new_cells.volatile_set_by_hash(hash, Cell.new(x))
// 209:                 self.cells = new_cells
// 210:               end
// 211:             end
// 212:           end
// 213:         end
// 214:
// 215:         def expand_table_unless_stale(current_cells)
// 216:           try_in_busy do
// 217:             if current_cells == cells # Recheck under lock
// 218:               new_cells = current_cells.next_in_size_table
// 219:               current_cells.each_with_index {|x, i| new_cells.volatile_set(i, x)}
// 220:               self.cells = new_cells
// 221:             end
// 222:           end
// 223:         end
// 224:
// 225:         def try_to_install_new_cell(new_cell, hash)
// 226:           try_in_busy do
// 227:             # Recheck under lock
// 228:             if (current_cells = cells) && !current_cells.volatile_get(i = current_cells.hash_to_index(hash))
// 229:               current_cells.volatile_set(i, new_cell)
// 230:             end
// 231:           end
// 232:         end
// 233:
// 234:         def try_in_busy
// 235:           if cas_busy(false, true)
// 236:             begin
// 237:               yield
// 238:             ensure
// 239:               self.busy = false
// 240:             end
// 241:           end
// 242:         end
// 243:       end
// 244:     end
// 245:   end
// 246: end
