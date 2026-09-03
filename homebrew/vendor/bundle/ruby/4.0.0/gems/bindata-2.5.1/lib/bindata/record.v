module bindata

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/bindata-2.5.1/lib/bindata/record.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct RecordMetadata {
pub:
	dsl_parser    string = 'struct'
	arg_processor string = 'record'
	registered    bool
}

pub fn record_metadata() RecordMetadata {
	return RecordMetadata{}
}

pub fn merge_record_dsl_parameters(parameters map[string]brew_runtime.Value, dsl_parameters map[string]brew_runtime.Value) map[string]brew_runtime.Value {
	mut merged := parameters.clone()
	for name, value in dsl_parameters {
		merged[name] = value
	}
	return merged
}

// Ruby method `sanitize_parameters!(obj_class, params)` at line 19.
pub fn ruby_record_l19_d1_sanitize_parameters(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		panic('RecordArgProcessor#sanitize_parameters! requires a receiver, object class and parameters')
	}
	parameters := args[2].as_map() or { panic(err) }
	merged := brew_runtime.map_value(merge_record_dsl_parameters(parameters, args[1].map_data))
	return ruby_struct_l368_d41_sanitize_parameters(args[0], args[1], merged)
}

// Original Ruby source (line-for-line):
// 1: require 'bindata/dsl'
// 2: require 'bindata/struct'
// 3:
// 4: module BinData
// 5:   # A Record is a declarative wrapper around Struct.
// 6:   #
// 7:   # See +Struct+ for more info.
// 8:   class Record < BinData::Struct
// 9:     extend DSLMixin
// 10:
// 11:     unregister_self
// 12:     dsl_parser    :struct
// 13:     arg_processor :record
// 14:   end
// 15:
// 16:   class RecordArgProcessor < StructArgProcessor
// 17:     include MultiFieldArgSeparator
// 18:
// 19:     def sanitize_parameters!(obj_class, params)
// 20:       super(obj_class, params.merge!(obj_class.dsl_params))
// 21:     end
// 22:   end
// 23: end
