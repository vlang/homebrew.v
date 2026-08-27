module homebrew

import brew_runtime

// Translated from Homebrew/brew `build_options.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(args, options)` at line 7.
pub fn ruby_build_options_l7_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `with?(val)` at line 34.
pub fn ruby_build_options_l34_d2_with(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('with?', ...args)
}

// Ruby method `without?(val)` at line 60.
pub fn ruby_build_options_l60_d3_without(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('without?', ...args)
}

// Ruby method `bottle?` at line 66.
pub fn ruby_build_options_l66_d4_bottle(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('bottle?', ...args)
}

// Ruby method `head?` at line 87.
pub fn ruby_build_options_l87_d5_head(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('head?', ...args)
}

// Ruby method `stable?` at line 100.
pub fn ruby_build_options_l100_d6_stable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stable?', ...args)
}

// Ruby method `any_args_or_options?` at line 106.
pub fn ruby_build_options_l106_d7_any_args_or_options(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('any_args_or_options?', ...args)
}

// Ruby method `used_options` at line 111.
pub fn ruby_build_options_l111_d8_used_options(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('used_options', ...args)
}

// Ruby method `unused_options` at line 116.
pub fn ruby_build_options_l116_d9_unused_options(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('unused_options', ...args)
}

// Ruby method `include?(name)` at line 123.
pub fn ruby_build_options_l123_d10_include(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('include?', ...args)
}

// Ruby method `option_defined?(name)` at line 128.
pub fn ruby_build_options_l128_d11_option_defined(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('option_defined?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Options for a formula build.
// 5: class BuildOptions
// 6:   sig { params(args: Options, options: Options).void }
// 7:   def initialize(args, options)
// 8:     @args = args
// 9:     @options = options
// 10:   end
// 11:
// 12:   # True if a {Formula} is being built with a specific option.
// 13:   #
// 14:   # ### Examples
// 15:   #
// 16:   # ```ruby
// 17:   # args << "--i-want-spam" if build.with? "spam"
// 18:   # ```
// 19:   #
// 20:   # ```ruby
// 21:   # args << "--qt-gui" if build.with? "qt" # "--with-qt" ==> build.with? "qt"
// 22:   # ```
// 23:   #
// 24:   # If a formula presents a user with a choice, but the choice must be fulfilled:
// 25:   #
// 26:   # ```ruby
// 27:   # if build.with? "example2"
// 28:   #   args << "--with-example2"
// 29:   # else
// 30:   #   args << "--with-example1"
// 31:   # end
// 32:   # ```
// 33:   sig { params(val: T.any(String, Dependable)).returns(T::Boolean) }
// 34:   def with?(val)
// 35:     option_names = if val.is_a?(String)
// 36:       [val]
// 37:     else
// 38:       val.option_names
// 39:     end
// 40:
// 41:     option_names.any? do |name|
// 42:       if option_defined? "with-#{name}"
// 43:         include? "with-#{name}"
// 44:       elsif option_defined? "without-#{name}"
// 45:         !include? "without-#{name}"
// 46:       else
// 47:         false
// 48:       end
// 49:     end
// 50:   end
// 51:
// 52:   # True if a {Formula} is being built without a specific option.
// 53:   #
// 54:   # ### Example
// 55:   #
// 56:   # ```ruby
// 57:   # args << "--no-spam-plz" if build.without? "spam"
// 58:   # ```
// 59:   sig { params(val: T.any(String, Dependable)).returns(T::Boolean) }
// 60:   def without?(val)
// 61:     !with?(val)
// 62:   end
// 63:
// 64:   # True if a {Formula} is being built as a bottle (i.e. binary package).
// 65:   sig { returns(T::Boolean) }
// 66:   def bottle?
// 67:     include? "build-bottle"
// 68:   end
// 69:
// 70:   # True if a {Formula} is being built with {Formula.head} instead of {Formula.stable}.
// 71:   #
// 72:   # ### Examples
// 73:   #
// 74:   # ```ruby
// 75:   # args << "--some-new-stuff" if build.head?
// 76:   # ```
// 77:   #
// 78:   # If there are multiple conditional arguments use a block instead of lines.
// 79:   #
// 80:   # ```ruby
// 81:   # if build.head?
// 82:   #   args << "--i-want-pizza"
// 83:   #   args << "--and-a-cold-beer" if build.with? "cold-beer"
// 84:   # end
// 85:   # ```
// 86:   sig { returns(T::Boolean) }
// 87:   def head?
// 88:     include? "HEAD"
// 89:   end
// 90:
// 91:   # True if a {Formula} is being built with {Formula.stable} instead of {Formula.head}.
// 92:   # This is the default.
// 93:   #
// 94:   # ### Example
// 95:   #
// 96:   # ```ruby
// 97:   # args << "--some-feature" if build.stable?
// 98:   # ```
// 99:   sig { returns(T::Boolean) }
// 100:   def stable?
// 101:     !head?
// 102:   end
// 103:
// 104:   # True if the build has any arguments or options specified.
// 105:   sig { returns(T::Boolean) }
// 106:   def any_args_or_options?
// 107:     !@args.empty? || !@options.empty?
// 108:   end
// 109:
// 110:   sig { returns(Options) }
// 111:   def used_options
// 112:     @options & @args
// 113:   end
// 114:
// 115:   sig { returns(Options) }
// 116:   def unused_options
// 117:     @options - @args
// 118:   end
// 119:
// 120:   private
// 121:
// 122:   sig { params(name: String).returns(T::Boolean) }
// 123:   def include?(name)
// 124:     @args.include?("--#{name}")
// 125:   end
// 126:
// 127:   sig { params(name: String).returns(T::Boolean) }
// 128:   def option_defined?(name)
// 129:     @options.include? name
// 130:   end
// 131: end
