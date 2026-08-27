module utility

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/concurrent-ruby-1.3.8/lib/concurrent-ruby/concurrent/utility/native_extension_loader.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `allow_c_extensions?` at line 11.
pub fn ruby_native_extension_loader_l11_d1_allow_c_extensions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('allow_c_extensions?', ...args)
}

// Ruby method `c_extensions_loaded?` at line 15.
pub fn ruby_native_extension_loader_l15_d2_c_extensions_loaded(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('c_extensions_loaded?', ...args)
}

// Ruby method `load_native_extensions` at line 19.
pub fn ruby_native_extension_loader_l19_d3_load_native_extensions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('load_native_extensions', ...args)
}

// Ruby method `load_error_path(error)` at line 38.
pub fn ruby_native_extension_loader_l38_d4_load_error_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('load_error_path', ...args)
}

// Ruby method `set_c_extensions_loaded` at line 46.
pub fn ruby_native_extension_loader_l46_d5_set_c_extensions_loaded(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('set_c_extensions_loaded', ...args)
}

// Ruby method `java_extensions_loaded?` at line 50.
pub fn ruby_native_extension_loader_l50_d6_java_extensions_loaded(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('java_extensions_loaded?', ...args)
}

// Ruby method `set_java_extensions_loaded` at line 54.
pub fn ruby_native_extension_loader_l54_d7_set_java_extensions_loaded(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('set_java_extensions_loaded', ...args)
}

// Ruby method `try_load_c_extension(path)` at line 58.
pub fn ruby_native_extension_loader_l58_d8_try_load_c_extension(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('try_load_c_extension', ...args)
}

// Original Ruby source (line-for-line):
// 1: require 'concurrent/utility/engine'
// 2: # Synchronization::AbstractObject must be defined before loading the extension
// 3: require 'concurrent/synchronization/abstract_object'
// 4:
// 5: module Concurrent
// 6:   # @!visibility private
// 7:   module Utility
// 8:     # @!visibility private
// 9:     module NativeExtensionLoader
// 10:
// 11:       def allow_c_extensions?
// 12:         Concurrent.on_cruby?
// 13:       end
// 14:
// 15:       def c_extensions_loaded?
// 16:         defined?(@c_extensions_loaded) && @c_extensions_loaded
// 17:       end
// 18:
// 19:       def load_native_extensions
// 20:         if Concurrent.on_cruby? && !c_extensions_loaded?
// 21:           ['concurrent/concurrent_ruby_ext',
// 22:            "concurrent/#{RUBY_VERSION[0..2]}/concurrent_ruby_ext"
// 23:           ].each { |p| try_load_c_extension p }
// 24:         end
// 25:
// 26:         if Concurrent.on_jruby? && !java_extensions_loaded?
// 27:           begin
// 28:             require 'concurrent/concurrent_ruby.jar'
// 29:             set_java_extensions_loaded
// 30:           rescue LoadError => e
// 31:             raise e, "Java extensions are required for JRuby.\n" + e.message, e.backtrace
// 32:           end
// 33:         end
// 34:       end
// 35:
// 36:       private
// 37:
// 38:       def load_error_path(error)
// 39:         if error.respond_to? :path
// 40:           error.path
// 41:         else
// 42:           error.message.split(' -- ').last
// 43:         end
// 44:       end
// 45:
// 46:       def set_c_extensions_loaded
// 47:         @c_extensions_loaded = true
// 48:       end
// 49:
// 50:       def java_extensions_loaded?
// 51:         defined?(@java_extensions_loaded) && @java_extensions_loaded
// 52:       end
// 53:
// 54:       def set_java_extensions_loaded
// 55:         @java_extensions_loaded = true
// 56:       end
// 57:
// 58:       def try_load_c_extension(path)
// 59:         require path
// 60:         set_c_extensions_loaded
// 61:       rescue LoadError => e
// 62:         if load_error_path(e) == path
// 63:           # move on with pure-Ruby implementations
// 64:           # TODO (pitr-ch 12-Jul-2018): warning on verbose?
// 65:         else
// 66:           raise e
// 67:         end
// 68:       end
// 69:
// 70:     end
// 71:   end
// 72:
// 73:   # @!visibility private
// 74:   extend Utility::NativeExtensionLoader
// 75: end
// 76:
// 77: Concurrent.load_native_extensions
