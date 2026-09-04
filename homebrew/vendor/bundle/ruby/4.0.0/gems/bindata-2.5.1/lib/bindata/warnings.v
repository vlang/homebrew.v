module bindata

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/warnings.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct InitializerOwner {
pub:
	owner           string
	superclass_name string
}

pub fn validate_initializer_owner(details InitializerOwner) ! {
	if details.owner == 'BinData::Base' {
		return
	}
	mut message := "Don't override #initialize on ${details.owner}."
	if details.superclass_name in ['BinData::Base', 'BinData::BasePrimitive'] {
		message += '\nrename #initialize to #initialize_instance.'
	}
	return error(message)
}

pub fn validate_initialize_instance_arguments(argument_count int, caller string) ! {
	if argument_count != 0 {
		return error('${caller} remove the call to super in #initialize_instance')
	}
}

pub fn deprecated_struct_has_key(fields map[string]ruby.Value, key string) bool {
	return key in fields
}

fn initializer_owner_from_value(value ruby.Value) InitializerOwner {
	return InitializerOwner{
		owner: value.attribute('initialize_owner') or { 'BinData::Base' }
		superclass_name: value.attribute('superclass_name') or { '' }
	}
}

// Ruby alias_method `alias_method :initialize_without_warning, :initialize` at line 11.
pub fn ruby_warnings_l11_d1_initialize_without_warning(args ...ruby.Value) ruby.Value {
	return ruby_base_l80_d7_initialize(...args)
}

// Ruby method `initialize_with_warning(*args)` at line 12.
pub fn ruby_warnings_l12_d2_initialize_with_warning(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Base#initialize_with_warning requires a receiver')
	}
	validate_initializer_owner(initializer_owner_from_value(args[0])) or { panic(err) }
	return ruby_warnings_l11_d1_initialize_without_warning(...args)
}

// Ruby alias `alias initialize initialize_with_warning` at line 23.
pub fn ruby_warnings_l23_d3_initialize(args ...ruby.Value) ruby.Value {
	return ruby_warnings_l12_d2_initialize_with_warning(...args)
}

// Ruby method `initialize_instance(*args)` at line 25.
pub fn ruby_warnings_l25_d4_initialize_instance(args ...ruby.Value) ruby.Value {
	argument_count := if args.len > 0 && args[0].type_name.starts_with('BinData::') {
		args.len - 1
	} else {
		args.len
	}
	validate_initialize_instance_arguments(argument_count, 'BinData::Base#initialize_instance') or {
		panic(err)
	}
	return ruby.object_value('NilClass', 'nil')
}

// Ruby alias `alias has_key? key?` at line 34.
pub fn ruby_warnings_l34_d5_has_key(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('Struct#has_key? requires a receiver and key')
	}
	return ruby.bool_value(deprecated_struct_has_key(args[0].map_data, args[1].as_string().trim_left(':')))
}

// Original Ruby source (line-for-line):
// 1: module BinData
// 2:   class Base
// 3:     # Don't override initialize.  If you are defining a new kind of datatype
// 4:     # (list, array, choice etc) then put your initialization code in
// 5:     # #initialize_instance.  BinData objects might be initialized as prototypes
// 6:     # and your initialization code may not be called.
// 7:     #
// 8:     # If you're subclassing BinData::Record, you are definitely doing the wrong
// 9:     # thing.  Read the documentation on how to use BinData.
// 10:     # http://github.com/dmendel/bindata/wiki/Records
// 11:     alias_method :initialize_without_warning, :initialize
// 12:     def initialize_with_warning(*args)
// 13:       owner = method(:initialize).owner
// 14:       if owner != BinData::Base
// 15:         msg = "Don't override #initialize on #{owner}."
// 16:         if %w[BinData::Base BinData::BasePrimitive].include? self.class.superclass.name
// 17:           msg += "\nrename #initialize to #initialize_instance."
// 18:         end
// 19:         fail msg
// 20:       end
// 21:       initialize_without_warning(*args)
// 22:     end
// 23:     alias initialize initialize_with_warning
// 24:
// 25:     def initialize_instance(*args)
// 26:       unless args.empty?
// 27:         fail "#{caller[0]} remove the call to super in #initialize_instance"
// 28:       end
// 29:     end
// 30:   end
// 31:
// 32:   class Struct
// 33:     # has_key? is deprecated
// 34:     alias has_key? key?
// 35:   end
// 36: end
