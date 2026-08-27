module homebrew

import brew_runtime

// Translated from Homebrew/brew `debrew.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `install` at line 11.
pub fn ruby_debrew_l11_d1_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby method `patch` at line 16.
pub fn ruby_debrew_l16_d2_patch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('patch', ...args)
}

// Ruby method `test` at line 24.
pub fn ruby_debrew_l24_d3_test(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('test', ...args)
}

// Ruby attr_accessor `attr_accessor :prompt` at line 37.
pub fn ruby_debrew_l37_d4_prompt(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prompt', ...args)
}

// Ruby attr_accessor `attr_accessor :prompt` at line 37.
pub fn ruby_debrew_l37_d5_prompt(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prompt=', ...args)
}

// Ruby attr_accessor `attr_accessor :entries` at line 40.
pub fn ruby_debrew_l40_d6_entries(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('entries', ...args)
}

// Ruby attr_accessor `attr_accessor :entries` at line 40.
pub fn ruby_debrew_l40_d7_entries(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('entries=', ...args)
}

// Ruby method `initialize` at line 43.
pub fn ruby_debrew_l43_d8_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `choice(name, &action)` at line 48.
pub fn ruby_debrew_l48_d9_choice(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('choice', ...args)
}

// Ruby method `self.choose(&_block)` at line 53.
pub fn ruby_debrew_l53_d10_self_choose(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.choose', ...args)
}

// Ruby attr_reader `attr_reader :debugged_exceptions` at line 88.
pub fn ruby_debrew_l88_d11_debugged_exceptions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('debugged_exceptions', ...args)
}

// Ruby method `active? = !@mutex.nil?` at line 91.
pub fn ruby_debrew_l91_d12_active(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('active?', ...args)
}

// Ruby method `self.debrew(&block)` at line 99.
pub fn ruby_debrew_l99_d13_self_debrew(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.debrew', ...args)
}

// Ruby method `self.debug(exception)` at line 107.
pub fn ruby_debrew_l107_d14_self_debug(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.debug', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "ignorable"
// 5:
// 6: # Helper module for debugging formulae.
// 7: module Debrew
// 8:   # Module for allowing to debug formulae.
// 9:   module Formula
// 10:     sig { void }
// 11:     def install
// 12:       Debrew.debrew { super }
// 13:     end
// 14:
// 15:     sig { void }
// 16:     def patch
// 17:       Debrew.debrew { super }
// 18:     end
// 19:
// 20:     sig {
// 21:       # TODO: replace `returns(BasicObject)` with `void` after dropping `return false` handling in test
// 22:       returns(BasicObject)
// 23:     }
// 24:     def test
// 25:       Debrew.debrew { super }
// 26:     end
// 27:   end
// 28:
// 29:   # Module for displaying a debugging menu.
// 30:   class Menu
// 31:     class Entry < T::Struct
// 32:       const :name, String
// 33:       const :action, T.proc.void
// 34:     end
// 35:
// 36:     sig { returns(T.nilable(String)) }
// 37:     attr_accessor :prompt
// 38:
// 39:     sig { returns(T::Array[Entry]) }
// 40:     attr_accessor :entries
// 41:
// 42:     sig { void }
// 43:     def initialize
// 44:       @entries = T.let([], T::Array[Entry])
// 45:     end
// 46:
// 47:     sig { params(name: Symbol, action: T.proc.void).void }
// 48:     def choice(name, &action)
// 49:       entries << Entry.new(name: name.to_s, action:)
// 50:     end
// 51:
// 52:     sig { params(_block: T.proc.params(menu: Menu).void).void }
// 53:     def self.choose(&_block)
// 54:       menu = new
// 55:       yield menu
// 56:
// 57:       choice = T.let(nil, T.nilable(Entry))
// 58:       while choice.nil?
// 59:         menu.entries.each_with_index { |e, i| puts "#{i + 1}. #{e.name}" }
// 60:         print menu.prompt unless menu.prompt.nil?
// 61:
// 62:         input = $stdin.gets || exit
// 63:         input.chomp!
// 64:
// 65:         i = input.to_i
// 66:         if i.positive?
// 67:           choice = menu.entries[i - 1]
// 68:         else
// 69:           possible = menu.entries.select { |e| e.name.start_with?(input) }
// 70:
// 71:           case possible.size
// 72:           when 0 then puts "No such option"
// 73:           when 1 then choice = possible.first
// 74:           else puts "Multiple options match: #{possible.map(&:name).join(" ")}"
// 75:           end
// 76:         end
// 77:       end
// 78:
// 79:       choice.action.call
// 80:     end
// 81:   end
// 82:
// 83:   @mutex = T.let(nil, T.nilable(Mutex))
// 84:   @debugged_exceptions = T.let(Set.new, T::Set[Exception])
// 85:
// 86:   class << self
// 87:     sig { returns(T::Set[Exception]) }
// 88:     attr_reader :debugged_exceptions
// 89:
// 90:     sig { returns(T::Boolean) }
// 91:     def active? = !@mutex.nil?
// 92:   end
// 93:
// 94:   sig {
// 95:     type_parameters(:U)
// 96:       .params(block: T.proc.returns(T.type_parameter(:U)))
// 97:       .returns(T.type_parameter(:U))
// 98:   }
// 99:   def self.debrew(&block)
// 100:     @mutex = Mutex.new
// 101:     Ignorable.hook_raise(on_ignorable: ->(e) { e.is_a?(SystemExit) ? :raise : debug(e) }, &block)
// 102:   ensure
// 103:     @mutex = nil
// 104:   end
// 105:
// 106:   sig { params(exception: Exception).returns(Symbol) }
// 107:   def self.debug(exception)
// 108:     raise(exception) if !active? || !debugged_exceptions.add?(exception) || !@mutex&.try_lock
// 109:
// 110:     begin
// 111:       puts exception.backtrace&.first
// 112:       puts Formatter.error(exception, label: exception.class.name)
// 113:
// 114:       loop do
// 115:         Menu.choose do |menu|
// 116:           menu.prompt = "Choose an action: "
// 117:
// 118:           menu.choice(:raise) { raise(exception) }
// 119:           menu.choice(:ignore) { return :ignore } if exception.is_a?(Ignorable::ExceptionMixin)
// 120:           menu.choice(:backtrace) { puts exception.backtrace }
// 121:
// 122:           if exception.is_a?(Ignorable::ExceptionMixin)
// 123:             menu.choice(:irb) do
// 124:               puts "When you exit this IRB session, execution will continue."
// 125:               set_trace_func proc { |event, _, _, id, binding, klass|
// 126:                 if klass == Object && id == :raise && event == "return"
// 127:                   set_trace_func(nil)
// 128:                   @mutex.synchronize do
// 129:                     require "debrew/irb"
// 130:                     IRB.start_within(binding)
// 131:                   end
// 132:                 end
// 133:               }
// 134:
// 135:               return :ignore
// 136:             end
// 137:           end
// 138:
// 139:           menu.choice(:shell) do
// 140:             puts "When you exit this shell, you will return to the menu."
// 141:             interactive_shell
// 142:           end
// 143:         end
// 144:       end
// 145:     ensure
// 146:       @mutex.unlock
// 147:     end
// 148:   end
// 149: end
