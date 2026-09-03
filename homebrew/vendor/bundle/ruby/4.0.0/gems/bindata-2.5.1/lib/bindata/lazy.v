module bindata

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/lazy.rb`.
// The original source is retained below until every stub has a typed V body.

pub type LazyCallableFn = fn (mut LazyEvaluator) brew_runtime.Value

pub type LazyMethodFn = fn ([]brew_runtime.Value) brew_runtime.Value

@[heap]
pub struct LazyCallable {
mut:
	callback LazyCallableFn @[required]
}

@[heap]
pub struct LazyDataObject {
mut:
	parameters       map[string]brew_runtime.Value
	method_values    map[string]brew_runtime.Value
	method_callbacks map[string]LazyMethodFn
	method_names     []string
	parent           brew_runtime.Value
	has_parent       bool
}

@[heap]
pub struct LazyEvaluator {
mut:
	object        brew_runtime.Value
	overrides     map[string]brew_runtime.Value
	has_overrides bool
}

fn lazy_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

fn lazy_symbol_name(value brew_runtime.Value) string {
	return value.as_string().trim_left(':')
}

pub fn new_lazy_data_object(parameters map[string]brew_runtime.Value, methods map[string]brew_runtime.Value) &LazyDataObject {
	return &LazyDataObject{
		parameters: parameters.clone()
		method_values: methods.clone()
		method_names: methods.keys()
		parent: lazy_nil_value()
		method_callbacks: map[string]LazyMethodFn{}
	}
}

pub fn (mut object LazyDataObject) set_parent(parent brew_runtime.Value) {
	object.parent = parent
	object.has_parent = parent.type_name != 'NilClass'
}

pub fn (mut object LazyDataObject) add_method(name string, callback LazyMethodFn) {
	normalized := name.trim_left(':')
	object.method_callbacks[normalized] = callback
	if normalized !in object.method_names {
		object.method_names << normalized
	}
}

pub fn lazy_data_boundary_value(object &LazyDataObject) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'BinData::LazyDataObject'
		repr: 'BinData::LazyDataObject'
		int_data: i64(u64(voidptr(object)))
		map_data: object.parameters
		attributes: {
			'lazy_data_address': u64(voidptr(object)).str()
			'method_names': object.method_names.join(',')
		}
	}
}

fn lazy_data_from_value(value brew_runtime.Value) ?&LazyDataObject {
	address := value.attributes['lazy_data_address'] or { return none }
	return unsafe { &LazyDataObject(voidptr(address.u64())) }
}

pub fn lazy_callable_value(callback LazyCallableFn) brew_runtime.Value {
	callable := &LazyCallable{
		callback: callback
	}
	return brew_runtime.Value{
		type_name: 'Proc'
		repr: 'proc'
		int_data: i64(u64(voidptr(callable)))
		attributes: {
			'lazy_callable_address': u64(voidptr(callable)).str()
		}
	}
}

fn lazy_callable_from_value(value brew_runtime.Value) ?&LazyCallable {
	address := value.attributes['lazy_callable_address'] or { return none }
	return unsafe { &LazyCallable(voidptr(address.u64())) }
}

pub fn new_lazy_evaluator(object brew_runtime.Value) &LazyEvaluator {
	return &LazyEvaluator{
		object: object
		overrides: map[string]brew_runtime.Value{}
	}
}

pub fn lazy_evaluator_boundary_value(evaluator &LazyEvaluator) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'BinData::LazyEvaluator'
		repr: evaluator.object.repr
		int_data: i64(u64(voidptr(evaluator)))
		map_data: {
			'parent': evaluator.object
		}
		attributes: {
			'lazy_evaluator_address': u64(voidptr(evaluator)).str()
		}
	}
}

fn lazy_evaluator_from_value(value brew_runtime.Value) &LazyEvaluator {
	if address := value.attributes['lazy_evaluator_address'] {
		return unsafe { &LazyEvaluator(voidptr(address.u64())) }
	}
	object := value.map_data['parent'] or { value }
	return new_lazy_evaluator(object)
}

fn lazy_parent_of(value brew_runtime.Value) ?brew_runtime.Value {
	if object := lazy_data_from_value(value) {
		if object.has_parent {
			return object.parent
		}
		return none
	}
	if _ := value.attributes['base_object_address'] {
		object := base_object_from_value(value)
		if object.has_parent {
			return object.parent
		}
	}
	return none
}

fn lazy_has_parameter(value brew_runtime.Value, name string) bool {
	if object := lazy_data_from_value(value) {
		return name in object.parameters
	}
	if _ := value.attributes['base_object_address'] {
		return name in base_object_from_value(value).parameters
	}
	return name in value.map_data
}

fn lazy_parameter(value brew_runtime.Value, name string) brew_runtime.Value {
	if object := lazy_data_from_value(value) {
		return object.parameters[name] or { lazy_nil_value() }
	}
	if _ := value.attributes['base_object_address'] {
		return base_object_from_value(value).parameters[name] or { lazy_nil_value() }
	}
	return value.map_data[name] or { lazy_nil_value() }
}

fn lazy_responds_to(value brew_runtime.Value, name string) bool {
	if object := lazy_data_from_value(value) {
		return name in object.method_names || name in object.method_values || name in object.method_callbacks
	}
	if names := value.attributes['method_names'] {
		if name in names.split(',') {
			return true
		}
	}
	if _ := value.attributes['struct_object_address'] {
		return struct_field_index(struct_object_from_value(value), name) >= 0
	}
	return false
}

fn lazy_values_identical(left brew_runtime.Value, right brew_runtime.Value) bool {
	for key in ['lazy_data_address', 'base_object_address', 'struct_field_address', 'array_element_address'] {
		if address := left.attributes[key] {
			return address == (right.attributes[key] or { '' })
		}
	}
	return left.type_name == right.type_name && left.repr == right.repr
}

fn lazy_call_method(value brew_runtime.Value, name string, args []brew_runtime.Value) brew_runtime.Value {
	if object := lazy_data_from_value(value) {
		if callback := object.method_callbacks[name] {
			return callback(args)
		}
		if result := object.method_values[name] {
			return result
		}
	}
	if _ := value.attributes['struct_object_address'] {
		field := ruby_struct_l213_d23_find_obj_for_name(value, brew_runtime.object_value('Symbol', ':${name}'))
		if field.type_name != 'NilClass' {
			return struct_field_from_value(field).base.snapshot_value
		}
	}
	if name == 'find_index_of' {
		if _ := value.attributes['array_object_address'] {
			mut call_args := [value]
			call_args << args
			return ruby_array_l102_d8_find_index_of(...call_args)
		}
		if object := lazy_data_from_value(value) {
			if children := object.method_values['children'] {
				for index, child in children.array_data {
					if args.len > 0 && lazy_values_identical(child, args[0]) {
						return brew_runtime.int_value(index)
					}
				}
			}
		}
	}
	panic('${value.type_name} does not respond to `${name}`')
}

fn (mut evaluator LazyEvaluator) parent_evaluator() ?&LazyEvaluator {
	parent := lazy_parent_of(evaluator.object) or { return none }
	return new_lazy_evaluator(parent)
}

pub fn (mut evaluator LazyEvaluator) index() brew_runtime.Value {
	if evaluator.has_overrides {
		if index := evaluator.overrides['index'] {
			return index
		}
	}
	mut child := evaluator.object
	mut current := lazy_parent_of(evaluator.object) or { panic('no index found') }
	for {
		if lazy_responds_to(current, 'find_index_of') {
			return lazy_call_method(current, 'find_index_of', [child])
		}
		child = current
		current = lazy_parent_of(current) or { break }
	}
	panic('no index found')
}

fn (mut evaluator LazyEvaluator) resolve_symbol_in_parent_context(name string, args []brew_runtime.Value) brew_runtime.Value {
	parent := lazy_parent_of(evaluator.object) or { panic('undefined method `${name}`') }
	if lazy_has_parameter(parent, name) {
		return lazy_parameter(parent, name)
	}
	if lazy_responds_to(parent, name) {
		return lazy_call_method(parent, name, args)
	}
	return brew_runtime.object_value('Symbol', ':${name}')
}

fn (mut evaluator LazyEvaluator) recursively_eval(value brew_runtime.Value, args []brew_runtime.Value) brew_runtime.Value {
	if value.type_name == 'Symbol' {
		mut parent := evaluator.parent_evaluator() or { panic('undefined method `${lazy_symbol_name(value)}`') }
		return parent.call_symbol(lazy_symbol_name(value), args)
	}
	if callable := lazy_callable_from_value(value) {
		mut parent := evaluator.parent_evaluator() or { panic('callable has no parent context') }
		return callable.callback(mut parent)
	}
	return value
}

fn (mut evaluator LazyEvaluator) call_symbol(name string, args []brew_runtime.Value) brew_runtime.Value {
	if evaluator.has_overrides {
		if value := evaluator.overrides[name] {
			return value
		}
	}
	if name == 'parent' {
		return if mut parent := evaluator.parent_evaluator() {
			lazy_evaluator_boundary_value(parent)
		} else {
			lazy_nil_value()
		}
	}
	if name == 'index' {
		return evaluator.index()
	}
	result := evaluator.resolve_symbol_in_parent_context(name, args)
	return evaluator.recursively_eval(result, args)
}

pub fn (mut evaluator LazyEvaluator) resolve(name string, args ...brew_runtime.Value) brew_runtime.Value {
	return evaluator.call_symbol(name.trim_left(':'), args)
}

pub fn (mut evaluator LazyEvaluator) lazy_eval(value brew_runtime.Value, overrides ?map[string]brew_runtime.Value) brew_runtime.Value {
	if values := overrides {
		evaluator.overrides = normalized_base_parameters(values)
		evaluator.has_overrides = true
	}
	if value.type_name == 'Symbol' {
		return evaluator.call_symbol(lazy_symbol_name(value), [])
	}
	if callable := lazy_callable_from_value(value) {
		return callable.callback(mut evaluator)
	}
	return value
}

// Ruby method `initialize(obj)` at line 24.
pub fn ruby_lazy_l24_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('LazyEvaluator#initialize requires an object')
	}
	return lazy_evaluator_boundary_value(new_lazy_evaluator(args[args.len - 1]))
}

// Ruby method `lazy_eval(val, overrides = nil)` at line 28.
pub fn ruby_lazy_l28_d2_lazy_eval(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('LazyEvaluator#lazy_eval requires a receiver and value')
	}
	mut evaluator := lazy_evaluator_from_value(args[0])
	overrides := if args.len > 2 && args[2].type_name != 'NilClass' {
		?map[string]brew_runtime.Value(args[2].as_map() or { panic(err) })
	} else {
		none
	}
	return evaluator.lazy_eval(args[1], overrides)
}

// Ruby method `parent` at line 40.
pub fn ruby_lazy_l40_d3_parent(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('LazyEvaluator#parent requires a receiver')
	}
	mut evaluator := lazy_evaluator_from_value(args[0])
	return if mut parent := evaluator.parent_evaluator() {
		lazy_evaluator_boundary_value(parent)
	} else {
		lazy_nil_value()
	}
}

// Ruby method `index` at line 50.
pub fn ruby_lazy_l50_d4_index(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('LazyEvaluator#index requires a receiver')
	}
	mut evaluator := lazy_evaluator_from_value(args[0])
	return evaluator.index()
}

// Ruby method `method_missing(symbol, *args)` at line 65.
pub fn ruby_lazy_l65_d5_method_missing(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('LazyEvaluator#method_missing requires a receiver and symbol')
	}
	mut evaluator := lazy_evaluator_from_value(args[0])
	return evaluator.call_symbol(lazy_symbol_name(args[1]), args[2..])
}

// Ruby method `eval_symbol_in_parent_context(symbol, args)` at line 78.
pub fn ruby_lazy_l78_d6_eval_symbol_in_parent_context(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('LazyEvaluator#eval_symbol_in_parent_context requires a receiver and symbol')
	}
	mut evaluator := lazy_evaluator_from_value(args[0])
	call_args := if args.len > 2 && args[2].type_name == 'Array' {
		args[2].as_array() or { panic(err) }
	} else {
		args[2..]
	}
	result := evaluator.resolve_symbol_in_parent_context(lazy_symbol_name(args[1]), call_args)
	return evaluator.recursively_eval(result, call_args)
}

// Ruby method `resolve_symbol_in_parent_context(symbol, args)` at line 83.
pub fn ruby_lazy_l83_d7_resolve_symbol_in_parent_context(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('LazyEvaluator#resolve_symbol_in_parent_context requires a receiver and symbol')
	}
	mut evaluator := lazy_evaluator_from_value(args[0])
	call_args := if args.len > 2 && args[2].type_name == 'Array' {
		args[2].as_array() or { panic(err) }
	} else {
		args[2..]
	}
	return evaluator.resolve_symbol_in_parent_context(lazy_symbol_name(args[1]), call_args)
}

// Ruby method `recursively_eval(val, args)` at line 95.
pub fn ruby_lazy_l95_d8_recursively_eval(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('LazyEvaluator#recursively_eval requires a receiver and value')
	}
	mut evaluator := lazy_evaluator_from_value(args[0])
	call_args := if args.len > 2 && args[2].type_name == 'Array' {
		args[2].as_array() or { panic(err) }
	} else {
		args[2..]
	}
	return evaluator.recursively_eval(args[1], call_args)
}

// Ruby method `callable?(obj)` at line 105.
pub fn ruby_lazy_l105_d9_callable(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	value := args[args.len - 1]
	return brew_runtime.bool_value(value.type_name in ['Proc', 'Method', 'UnboundMethod'] ||
		'lazy_callable_address' in value.attributes)
}

// Original Ruby source (line-for-line):
// 1: module BinData
// 2:   # A LazyEvaluator is bound to a data object.  The evaluator will evaluate
// 3:   # lambdas in the context of this data object.  These lambdas
// 4:   # are those that are passed to data objects as parameters, e.g.:
// 5:   #
// 6:   #    BinData::String.new(value: -> { %w(a test message).join(" ") })
// 7:   #
// 8:   # As a shortcut, :foo is the equivalent of lambda { foo }.
// 9:   #
// 10:   # When evaluating lambdas, unknown methods are resolved in the context of the
// 11:   # parent of the bound data object.  Resolution is attempted firstly as keys
// 12:   # in #parameters, and secondly as methods in this parent.  This
// 13:   # resolution propagates up the chain of parent data objects.
// 14:   #
// 15:   # An evaluation will recurse until it returns a result that is not
// 16:   # a lambda or a symbol.
// 17:   #
// 18:   # This resolution process makes the lambda easier to read as we just write
// 19:   # <tt>field</tt> instead of <tt>obj.field</tt>.
// 20:   class LazyEvaluator
// 21:
// 22:     # Creates a new evaluator.  All lazy evaluation is performed in the
// 23:     # context of +obj+.
// 24:     def initialize(obj)
// 25:       @obj = obj
// 26:     end
// 27:
// 28:     def lazy_eval(val, overrides = nil)
// 29:       @overrides = overrides if overrides
// 30:       if val.is_a? Symbol
// 31:         __send__(val)
// 32:       elsif callable?(val)
// 33:         instance_exec(&val)
// 34:       else
// 35:         val
// 36:       end
// 37:     end
// 38:
// 39:     # Returns a LazyEvaluator for the parent of this data object.
// 40:     def parent
// 41:       if @obj.parent
// 42:         @obj.parent.lazy_evaluator
// 43:       else
// 44:         nil
// 45:       end
// 46:     end
// 47:
// 48:     # Returns the index of this data object inside it's nearest container
// 49:     # array.
// 50:     def index
// 51:       return @overrides[:index] if defined?(@overrides) && @overrides.key?(:index)
// 52:
// 53:       child = @obj
// 54:       parent = @obj.parent
// 55:       while parent
// 56:         if parent.respond_to?(:find_index_of)
// 57:           return parent.find_index_of(child)
// 58:         end
// 59:         child = parent
// 60:         parent = parent.parent
// 61:       end
// 62:       raise NoMethodError, "no index found"
// 63:     end
// 64:
// 65:     def method_missing(symbol, *args)
// 66:       return @overrides[symbol] if defined?(@overrides) && @overrides.key?(symbol)
// 67:
// 68:       if @obj.parent
// 69:         eval_symbol_in_parent_context(symbol, args)
// 70:       else
// 71:         super
// 72:       end
// 73:     end
// 74:
// 75:     #---------------
// 76:     private
// 77:
// 78:     def eval_symbol_in_parent_context(symbol, args)
// 79:       result = resolve_symbol_in_parent_context(symbol, args)
// 80:       recursively_eval(result, args)
// 81:     end
// 82:
// 83:     def resolve_symbol_in_parent_context(symbol, args)
// 84:       obj_parent = @obj.parent
// 85:
// 86:       if obj_parent.has_parameter?(symbol)
// 87:         obj_parent.get_parameter(symbol)
// 88:       elsif obj_parent.safe_respond_to?(symbol, true)
// 89:         obj_parent.__send__(symbol, *args)
// 90:       else
// 91:         symbol
// 92:       end
// 93:     end
// 94:
// 95:     def recursively_eval(val, args)
// 96:       if val.is_a?(Symbol)
// 97:         parent.__send__(val, *args)
// 98:       elsif callable?(val)
// 99:         parent.instance_exec(&val)
// 100:       else
// 101:         val
// 102:       end
// 103:     end
// 104:
// 105:     def callable?(obj)
// 106:       Proc === obj || Method === obj || UnboundMethod === obj
// 107:     end
// 108:   end
// 109: end
