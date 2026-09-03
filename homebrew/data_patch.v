module homebrew

import brew_runtime

// Translated from Homebrew/brew `data_patch.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct DataPatch {
pub:
	strip    string
	has_path bool
	path     string
}

pub fn new_data_patch(strip string) DataPatch {
	return DataPatch{
		strip: strip
	}
}

pub fn (patch DataPatch) with_path(path string) DataPatch {
	return DataPatch{
		strip:    patch.strip
		has_path: true
		path:     path
	}
}

pub fn (patch DataPatch) filename() string {
	return 'embedded DATA patch'
}

// contents returns every byte following the first standalone __END__ line.
pub fn (patch DataPatch) contents() !string {
	if !patch.has_path {
		return error('DATAPatch#contents called before path was set!')
	}
	data := brew_runtime.read_file(patch.path)!
	mut line_start := 0
	for index, character in data.bytes() {
		if character != `\n` {
			continue
		}
		if data[line_start..index] == '__END__' {
			return data[index + 1..]
		}
		line_start = index + 1
	}
	return ''
}

fn data_patch_boundary_value(patch DataPatch) brew_runtime.Value {
	return brew_runtime.structured_value('DATAPatch', patch.filename(), {
		'strip':    patch.strip
		'has_path': patch.has_path.str()
		'path':     patch.path
	})
}

fn data_patch_from_boundary(value brew_runtime.Value) DataPatch {
	if value.type_name != 'DATAPatch' {
		panic('expected DATAPatch, got ${value.type_name}')
	}
	return DataPatch{
		strip:    value.attribute('strip') or { panic(err) }
		has_path: (value.attribute('has_path') or { panic(err) }) == 'true'
		path:     value.attribute('path') or { panic(err) }
	}
}

// Ruby attr_accessor `attr_accessor :path` at line 9.
pub fn ruby_data_patch_l9_d1_path(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('DATAPatch#path requires a receiver')
	}
	patch := data_patch_from_boundary(args[0])
	return if patch.has_path {
		brew_runtime.string_value(patch.path)
	} else {
		brew_runtime.object_value('NilClass', '')
	}
}

// Ruby attr_accessor `attr_accessor :path` at line 9.
pub fn ruby_data_patch_l9_d2_path(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('DATAPatch#path= requires a receiver and path')
	}
	return data_patch_boundary_value(data_patch_from_boundary(args[0]).with_path(args[1].as_string()))
}

// Ruby method `initialize(strip)` at line 12.
pub fn ruby_data_patch_l12_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('DATAPatch#initialize requires a strip value')
	}
	return data_patch_boundary_value(new_data_patch(args[0].as_string()))
}

// Ruby method `filename = "embedded DATA patch"` at line 18.
pub fn ruby_data_patch_l18_d4_filename(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('DATAPatch#filename requires a receiver')
	}
	return brew_runtime.string_value(data_patch_from_boundary(args[0]).filename())
}

// Ruby method `contents` at line 21.
pub fn ruby_data_patch_l21_d5_contents(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('DATAPatch#contents requires a receiver')
	}
	return brew_runtime.string_value(data_patch_from_boundary(args[0]).contents() or { panic(err) })
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "embedded_patch"
// 5:
// 6: # A patch at the `__END__` of a formula file.
// 7: class DATAPatch < EmbeddedPatch
// 8:   sig { returns(T.nilable(Pathname)) }
// 9:   attr_accessor :path
// 10:
// 11:   sig { params(strip: T.any(String, Symbol)).void }
// 12:   def initialize(strip)
// 13:     super
// 14:     @path = T.let(nil, T.nilable(Pathname))
// 15:   end
// 16:
// 17:   sig { override.returns(String) }
// 18:   def filename = "embedded DATA patch"
// 19:
// 20:   sig { override.returns(String) }
// 21:   def contents
// 22:     path = self.path
// 23:     raise ArgumentError, "DATAPatch#contents called before path was set!" unless path
// 24:
// 25:     data = +""
// 26:     path.open("rb") do |f|
// 27:       loop do
// 28:         line = f.gets
// 29:         break if line.nil? || /^__END__$/.match?(line)
// 30:       end
// 31:       while (line = f.gets)
// 32:         data << line
// 33:       end
// 34:     end
// 35:     data.freeze
// 36:   end
// 37: end
