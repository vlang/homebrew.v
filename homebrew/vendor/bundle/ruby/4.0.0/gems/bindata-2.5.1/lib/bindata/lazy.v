module bindata

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/lazy.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(obj)` at line 24.
pub fn ruby_lazy_l24_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `lazy_eval(val, overrides = nil)` at line 28.
pub fn ruby_lazy_l28_d2_lazy_eval(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('lazy_eval', ...args)
}

// Ruby method `parent` at line 40.
pub fn ruby_lazy_l40_d3_parent(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('parent', ...args)
}

// Ruby method `index` at line 50.
pub fn ruby_lazy_l50_d4_index(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('index', ...args)
}

// Ruby method `method_missing(symbol, *args)` at line 65.
pub fn ruby_lazy_l65_d5_method_missing(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('method_missing', ...args)
}

// Ruby method `eval_symbol_in_parent_context(symbol, args)` at line 78.
pub fn ruby_lazy_l78_d6_eval_symbol_in_parent_context(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('eval_symbol_in_parent_context', ...args)
}

// Ruby method `resolve_symbol_in_parent_context(symbol, args)` at line 83.
pub fn ruby_lazy_l83_d7_resolve_symbol_in_parent_context(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('resolve_symbol_in_parent_context', ...args)
}

// Ruby method `recursively_eval(val, args)` at line 95.
pub fn ruby_lazy_l95_d8_recursively_eval(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('recursively_eval', ...args)
}

// Ruby method `callable?(obj)` at line 105.
pub fn ruby_lazy_l105_d9_callable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('callable?', ...args)
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
