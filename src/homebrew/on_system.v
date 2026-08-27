module homebrew

import brew_runtime

// Translated from Homebrew/brew `on_system.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.arch_condition_met?(arch)` at line 20.
pub fn ruby_on_system_l20_d1_self_arch_condition_met(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.arch_condition_met?', ...args)
}

// Ruby method `self.os_condition_met?(os_name, or_condition = nil)` at line 27.
pub fn ruby_on_system_l27_d2_self_os_condition_met(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.os_condition_met?', ...args)
}

// Ruby method `self.condition_from_method_name(method_name)` at line 56.
pub fn ruby_on_system_l56_d3_self_condition_from_method_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.condition_from_method_name', ...args)
}

// Ruby method `self.setup_arch_methods(base)` at line 61.
pub fn ruby_on_system_l61_d4_self_setup_arch_methods(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.setup_arch_methods', ...args)
}

// Ruby define_method `base.define_method(:"on_#{arch}") do |&block|` at line 63.
pub fn ruby_on_system_l63_d5_on_arch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_#{arch}', ...args)
}

// Ruby define_method `base.define_method(:on_arch_conditional) do |arm: nil, intel: nil|` at line 76.
pub fn ruby_on_system_l76_d6_on_arch_conditional(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_arch_conditional', ...args)
}

// Ruby method `self.setup_base_os_methods(base)` at line 88.
pub fn ruby_on_system_l88_d7_self_setup_base_os_methods(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.setup_base_os_methods', ...args)
}

// Ruby define_method `base.define_method(:"on_#{base_os}") do |&block|` at line 90.
pub fn ruby_on_system_l90_d8_on_base_os(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_#{base_os}', ...args)
}

// Ruby define_method `base.define_method(:on_system) do |linux, macos:, &block|` at line 106.
pub fn ruby_on_system_l106_d9_on_system(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_system', ...args)
}

// Ruby define_method `base.define_method(:on_system_conditional) do |macos: nil, linux: nil|` at line 128.
pub fn ruby_on_system_l128_d10_on_system_conditional(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_system_conditional', ...args)
}

// Ruby method `self.setup_macos_methods(base)` at line 140.
pub fn ruby_on_system_l140_d11_self_setup_macos_methods(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.setup_macos_methods', ...args)
}

// Ruby define_method `base.define_method(:"on_#{os_name}") do |or_condition = nil, &block|` at line 142.
pub fn ruby_on_system_l142_d12_on_os_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_#{os_name}', ...args)
}

// Ruby method `self.included(_base)` at line 169.
pub fn ruby_on_system_l169_d13_self_included(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.included', ...args)
}

// Ruby method `self.included(base)` at line 175.
pub fn ruby_on_system_l175_d14_self_included(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.included', ...args)
}

// Ruby method `self.included(base)` at line 184.
pub fn ruby_on_system_l184_d15_self_included(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.included', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "simulate_system"
// 5:
// 6: module OnSystem
// 7:   ARCH_OPTIONS = [:intel, :arm].freeze
// 8:   BASE_OS_OPTIONS = [:macos, :linux].freeze
// 9:   ALL_OS_OPTIONS = T.let([*MacOSVersion::SYMBOLS.keys, :linux].freeze, T::Array[Symbol])
// 10:   ALL_OS_ARCH_COMBINATIONS = T.let(ALL_OS_OPTIONS.product(ARCH_OPTIONS).freeze, T::Array[[Symbol, Symbol]])
// 11:
// 12:   VALID_OS_ARCH_TAGS = T.let(ALL_OS_ARCH_COMBINATIONS.filter_map do |os, arch|
// 13:     tag = Utils::Bottles::Tag.new(system: os, arch:)
// 14:     next unless tag.valid_combination?
// 15:
// 16:     tag
// 17:   end.freeze, T::Array[Utils::Bottles::Tag])
// 18:
// 19:   sig { params(arch: Symbol).returns(T::Boolean) }
// 20:   def self.arch_condition_met?(arch)
// 21:     raise ArgumentError, "Invalid arch condition: #{arch.inspect}" if ARCH_OPTIONS.exclude?(arch)
// 22:
// 23:     arch == Homebrew::SimulateSystem.current_arch
// 24:   end
// 25:
// 26:   sig { params(os_name: Symbol, or_condition: T.nilable(Symbol)).returns(T::Boolean) }
// 27:   def self.os_condition_met?(os_name, or_condition = nil)
// 28:     if BASE_OS_OPTIONS.include?(os_name)
// 29:       return Homebrew::SimulateSystem.public_send(:"simulating_or_running_on_#{os_name}?")
// 30:     end
// 31:
// 32:     raise ArgumentError, "Invalid OS condition: #{os_name.inspect}" unless MacOSVersion::SYMBOLS.key?(os_name)
// 33:
// 34:     if or_condition.present? && [:or_newer, :or_older].exclude?(or_condition)
// 35:       raise ArgumentError, "Invalid OS `or_*` condition: #{or_condition.inspect}"
// 36:     end
// 37:
// 38:     return false if Homebrew::SimulateSystem.simulating_or_running_on_linux?
// 39:
// 40:     base_os = MacOSVersion.from_symbol(os_name)
// 41:     current_os = if Homebrew::SimulateSystem.current_os == :macos
// 42:       # Assume the oldest macOS version when simulating a generic macOS version
// 43:       # Version::NULL is always treated as less than any other version.
// 44:       Version::NULL
// 45:     else
// 46:       MacOSVersion.from_symbol(Homebrew::SimulateSystem.current_os)
// 47:     end
// 48:
// 49:     return current_os >= base_os if or_condition == :or_newer
// 50:     return current_os <= base_os if or_condition == :or_older
// 51:
// 52:     current_os == base_os
// 53:   end
// 54:
// 55:   sig { params(method_name: Symbol).returns(Symbol) }
// 56:   def self.condition_from_method_name(method_name)
// 57:     method_name.to_s.sub(/^on_/, "").to_sym
// 58:   end
// 59:
// 60:   sig { params(base: T::Class[T.anything]).void }
// 61:   def self.setup_arch_methods(base)
// 62:     ARCH_OPTIONS.each do |arch|
// 63:       base.define_method(:"on_#{arch}") do |&block|
// 64:         @on_system_blocks_exist = T.let(true, T.nilable(TrueClass))
// 65:
// 66:         return unless OnSystem.arch_condition_met? OnSystem.condition_from_method_name(T.must(__method__))
// 67:
// 68:         @called_in_on_system_block = true
// 69:         result = block.call
// 70:         @called_in_on_system_block = false
// 71:
// 72:         result
// 73:       end
// 74:     end
// 75:
// 76:     base.define_method(:on_arch_conditional) do |arm: nil, intel: nil|
// 77:       @on_system_blocks_exist = T.let(true, T.nilable(TrueClass))
// 78:
// 79:       if OnSystem.arch_condition_met? :arm
// 80:         arm
// 81:       elsif OnSystem.arch_condition_met? :intel
// 82:         intel
// 83:       end
// 84:     end
// 85:   end
// 86:
// 87:   sig { params(base: T::Class[T.anything]).void }
// 88:   def self.setup_base_os_methods(base)
// 89:     BASE_OS_OPTIONS.each do |base_os|
// 90:       base.define_method(:"on_#{base_os}") do |&block|
// 91:         @on_system_blocks_exist = T.let(true, T.nilable(TrueClass))
// 92:         @on_os_blocks_exist = T.let(true, T.nilable(TrueClass))
// 93:
// 94:         return unless OnSystem.os_condition_met? OnSystem.condition_from_method_name(T.must(__method__))
// 95:
// 96:         @called_in_on_system_block = true
// 97:         @called_in_on_os_block = T.let(true, T.nilable(T::Boolean))
// 98:         result = block.call
// 99:         @called_in_on_system_block = false
// 100:         @called_in_on_os_block = false
// 101:
// 102:         result
// 103:       end
// 104:     end
// 105:
// 106:     base.define_method(:on_system) do |linux, macos:, &block|
// 107:       @on_system_blocks_exist = T.let(true, T.nilable(TrueClass))
// 108:       @on_os_blocks_exist = T.let(true, T.nilable(TrueClass))
// 109:
// 110:       raise ArgumentError, "The first argument to `on_system` must be `:linux`" if linux != :linux
// 111:
// 112:       os_version, or_condition = if macos.to_s.include?("_or_")
// 113:         macos.to_s.split(/_(?=or_)/).map(&:to_sym)
// 114:       else
// 115:         [macos.to_sym, nil]
// 116:       end
// 117:       return if !OnSystem.os_condition_met?(os_version, or_condition) && !OnSystem.os_condition_met?(:linux)
// 118:
// 119:       @called_in_on_system_block = true
// 120:       @called_in_on_os_block = T.let(true, T.nilable(T::Boolean))
// 121:       result = block.call
// 122:       @called_in_on_system_block = false
// 123:       @called_in_on_os_block = false
// 124:
// 125:       result
// 126:     end
// 127:
// 128:     base.define_method(:on_system_conditional) do |macos: nil, linux: nil|
// 129:       @on_system_blocks_exist = T.let(true, T.nilable(TrueClass))
// 130:
// 131:       if OnSystem.os_condition_met?(:macos) && macos.present?
// 132:         macos
// 133:       elsif OnSystem.os_condition_met?(:linux) && linux.present?
// 134:         linux
// 135:       end
// 136:     end
// 137:   end
// 138:
// 139:   sig { params(base: T::Class[T.anything]).void }
// 140:   def self.setup_macos_methods(base)
// 141:     MacOSVersion::SYMBOLS.each_key do |os_name|
// 142:       base.define_method(:"on_#{os_name}") do |or_condition = nil, &block|
// 143:         @on_system_blocks_exist = T.let(true, T.nilable(TrueClass))
// 144:         @on_os_blocks_exist = T.let(true, T.nilable(TrueClass))
// 145:
// 146:         os_condition = OnSystem.condition_from_method_name T.must(__method__)
// 147:         return unless OnSystem.os_condition_met? os_condition, or_condition
// 148:
// 149:         @on_system_block_min_os = T.let(
// 150:           if or_condition == :or_older
// 151:             @called_in_on_system_block ? @on_system_block_min_os : MacOSVersion.new(HOMEBREW_MACOS_OLDEST_ALLOWED)
// 152:           else
// 153:             MacOSVersion.from_symbol(os_condition)
// 154:           end,
// 155:           T.nilable(MacOSVersion),
// 156:         )
// 157:         @called_in_on_system_block = T.let(true, T.nilable(T::Boolean))
// 158:         @called_in_on_os_block = T.let(true, T.nilable(T::Boolean))
// 159:         result = block.call
// 160:         @called_in_on_system_block = false
// 161:         @called_in_on_os_block = false
// 162:
// 163:         result
// 164:       end
// 165:     end
// 166:   end
// 167:
// 168:   sig { params(_base: T::Class[T.anything]).void }
// 169:   def self.included(_base)
// 170:     raise "Do not include `OnSystem` directly. Instead, include `OnSystem::MacOSAndLinux` or `OnSystem::MacOSOnly`"
// 171:   end
// 172:
// 173:   module MacOSAndLinux
// 174:     sig { params(base: T::Class[T.anything]).void }
// 175:     def self.included(base)
// 176:       OnSystem.setup_arch_methods(base)
// 177:       OnSystem.setup_base_os_methods(base)
// 178:       OnSystem.setup_macos_methods(base)
// 179:     end
// 180:   end
// 181:
// 182:   module MacOSOnly
// 183:     sig { params(base: T::Class[T.anything]).void }
// 184:     def self.included(base)
// 185:       OnSystem.setup_arch_methods(base)
// 186:       OnSystem.setup_macos_methods(base)
// 187:     end
// 188:   end
// 189: end
