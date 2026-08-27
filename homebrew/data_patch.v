module homebrew

import brew_runtime

// Translated from Homebrew/brew `data_patch.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_accessor `attr_accessor :path` at line 9.
pub fn ruby_data_patch_l9_d1_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('path', ...args)
}

// Ruby attr_accessor `attr_accessor :path` at line 9.
pub fn ruby_data_patch_l9_d2_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('path=', ...args)
}

// Ruby method `initialize(strip)` at line 12.
pub fn ruby_data_patch_l12_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `filename = "embedded DATA patch"` at line 18.
pub fn ruby_data_patch_l18_d4_filename(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('filename', ...args)
}

// Ruby method `contents` at line 21.
pub fn ruby_data_patch_l21_d5_contents(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('contents', ...args)
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
