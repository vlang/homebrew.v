module bindata

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/framework.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize_instance; end` at line 10.
pub fn ruby_framework_l10_d1_initialize_instance(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize_instance', ...args)
}

// Ruby method `initialize_shared_instance; end` at line 18.
pub fn ruby_framework_l18_d2_initialize_shared_instance(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize_shared_instance', ...args)
}

// Ruby method `clear?` at line 21.
pub fn ruby_framework_l21_d3_clear(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('clear?', ...args)
}

// Ruby method `assign(val)` at line 27.
pub fn ruby_framework_l27_d4_assign(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('assign', ...args)
}

// Ruby method `snapshot` at line 32.
pub fn ruby_framework_l32_d5_snapshot(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('snapshot', ...args)
}

// Ruby method `debug_name_of(child) # :nodoc:` at line 38.
pub fn ruby_framework_l38_d6_debug_name_of(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('debug_name_of', ...args)
}

// Ruby method `offset_of(child) # :nodoc:` at line 44.
pub fn ruby_framework_l44_d7_offset_of(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('offset_of', ...args)
}

// Ruby method `bit_aligned?` at line 49.
pub fn ruby_framework_l49_d8_bit_aligned(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('bit_aligned?', ...args)
}

// Ruby method `do_read(io) # :nodoc:` at line 54.
pub fn ruby_framework_l54_d9_do_read(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do_read', ...args)
}

// Ruby method `do_write(io) # :nodoc:` at line 59.
pub fn ruby_framework_l59_d10_do_write(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do_write', ...args)
}

// Ruby method `do_num_bytes # :nodoc:` at line 64.
pub fn ruby_framework_l64_d11_do_num_bytes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('do_num_bytes', ...args)
}

// Original Ruby source (line-for-line):
// 1: module BinData
// 2:   # Error raised when unexpected results occur when reading data from IO.
// 3:   class ValidityError < StandardError; end
// 4:
// 5:   # All methods provided by the framework are to be implemented or overridden
// 6:   # by subclasses of BinData::Base.
// 7:   module Framework
// 8:     # Initializes the state of the object.  All instance variables that
// 9:     # are used by the object must be initialized here.
// 10:     def initialize_instance; end
// 11:
// 12:     # Initialises state that is shared by objects with the same parameters.
// 13:     #
// 14:     # This should only be used when optimising for performance.  Instance
// 15:     # variables set here, and changes to the singleton class will be shared
// 16:     # between all objects that are initialized with the same parameters.
// 17:     # This method is called only once for a particular set of parameters.
// 18:     def initialize_shared_instance; end
// 19:
// 20:     # Returns true if the object has not been changed since creation.
// 21:     def clear?
// 22:       raise NotImplementedError
// 23:     end
// 24:
// 25:     # Assigns the value of +val+ to this data object.  Note that +val+ must
// 26:     # always be deep copied to ensure no aliasing problems can occur.
// 27:     def assign(val)
// 28:       raise NotImplementedError
// 29:     end
// 30:
// 31:     # Returns a snapshot of this data object.
// 32:     def snapshot
// 33:       raise NotImplementedError
// 34:     end
// 35:
// 36:     # Returns the debug name of +child+.  This only needs to be implemented
// 37:     # by objects that contain child objects.
// 38:     def debug_name_of(child) # :nodoc:
// 39:       debug_name
// 40:     end
// 41:
// 42:     # Returns the offset of +child+.  This only needs to be implemented
// 43:     # by objects that contain child objects.
// 44:     def offset_of(child) # :nodoc:
// 45:       0
// 46:     end
// 47:
// 48:     # Is this object aligned on non-byte boundaries?
// 49:     def bit_aligned?
// 50:       false
// 51:     end
// 52:
// 53:     # Reads the data for this data object from +io+.
// 54:     def do_read(io) # :nodoc:
// 55:       raise NotImplementedError
// 56:     end
// 57:
// 58:     # Writes the value for this data to +io+.
// 59:     def do_write(io) # :nodoc:
// 60:       raise NotImplementedError
// 61:     end
// 62:
// 63:     # Returns the number of bytes it will take to write this data.
// 64:     def do_num_bytes # :nodoc:
// 65:       raise NotImplementedError
// 66:     end
// 67:
// 68:     # Set visibility requirements of methods to implement
// 69:     public :clear?, :assign, :snapshot, :debug_name_of, :offset_of
// 70:     protected :initialize_instance, :initialize_shared_instance
// 71:     protected :do_read, :do_write, :do_num_bytes
// 72:   end
// 73: end
