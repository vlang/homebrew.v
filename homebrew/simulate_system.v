module homebrew

import ruby

// Translated from Homebrew/brew `simulate_system.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :arch` at line 13.
pub fn ruby_simulate_system_l13_d1_arch(args ...ruby.Value) ruby.Value {
	state := simulation_from_args(args)
	return optional_symbol_value(state.simulated_arch)
}

// Ruby attr_reader `attr_reader :os` at line 16.
pub fn ruby_simulate_system_l16_d2_os(args ...ruby.Value) ruby.Value {
	state := simulation_from_args(args)
	return optional_symbol_value(state.simulated_os)
}

// Ruby method `arch_symbols` at line 19.
pub fn ruby_simulate_system_l19_d3_arch_symbols(args ...ruby.Value) ruby.Value {
	return ruby.structured_value('Hash', '{arm64: arm, x86_64: intel}', arch_symbols())
}

// Ruby method `with(os: T.unsafe(nil), arch: T.unsafe(nil), &_block)` at line 30.
pub fn ruby_simulate_system_l30_d4_with(args ...ruby.Value) ruby.Value {
	mut state := simulation_from_args(args)
	if args.len > 1 && args[1].as_string().len > 0 {
		state.set_os(args[1].as_string()) or { panic(err) }
	}
	if args.len > 2 && args[2].as_string().len > 0 {
		state.set_arch(args[2].as_string()) or { panic(err) }
	}
	if state.simulated_os.len == 0 && state.simulated_arch.len == 0 {
		panic('At least one of `os` or `arch` must be specified.')
	}
	return simulation_value(state)
}

// Ruby method `with_tag(tag, &block)` at line 53.
pub fn ruby_simulate_system_l53_d5_with_tag(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Invalid tag')
	}
	tag := SimulationTag{
		system: args[0].attribute('system') or { '' }
		arch:   args[0].attribute('arch') or { '' }
	}
	state := simulation_from_args(args[1..])
	return simulation_value(state.with_tag(tag) or { panic(err) })
}

// Ruby method `os=(new_os)` at line 60.
pub fn ruby_simulate_system_l60_d6_os(args ...ruby.Value) ruby.Value {
	value := if args.len > 0 { args[0].as_string() } else { '' }
	mut state := SystemSimulation{}
	state.set_os(value) or { panic(err) }
	return ruby.object_value('Symbol', value)
}

// Ruby method `arch=(new_arch)` at line 68.
pub fn ruby_simulate_system_l68_d7_arch(args ...ruby.Value) ruby.Value {
	value := if args.len > 0 { args[0].as_string() } else { '' }
	mut state := SystemSimulation{}
	state.set_arch(value) or { panic(err) }
	return ruby.object_value('Symbol', value)
}

// Ruby method `clear` at line 75.
pub fn ruby_simulate_system_l75_d8_clear(args ...ruby.Value) ruby.Value {
	mut state := simulation_from_args(args)
	state.clear()
	return simulation_value(state)
}

// Ruby method `simulating?` at line 80.
pub fn ruby_simulate_system_l80_d9_simulating(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(simulation_from_args(args).simulating())
}

// Ruby method `simulating_or_running_on_macos?` at line 85.
pub fn ruby_simulate_system_l85_d10_simulating_or_running_on_macos(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(simulation_from_args(args).simulating_or_running_on_macos())
}

// Ruby method `simulating_or_running_on_linux?` at line 90.
pub fn ruby_simulate_system_l90_d11_simulating_or_running_on_linux(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(simulation_from_args(args).simulating_or_running_on_linux())
}

// Ruby method `current_arch` at line 95.
pub fn ruby_simulate_system_l95_d12_current_arch(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Symbol', simulation_from_args(args).current_arch())
}

// Ruby method `current_os` at line 100.
pub fn ruby_simulate_system_l100_d13_current_os(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Symbol', simulation_from_args(args).current_os())
}

// Ruby method `current_tag` at line 105.
pub fn ruby_simulate_system_l105_d14_current_tag(args ...ruby.Value) ruby.Value {
	state := simulation_from_args(args)
	tag := state.current_tag()
	return ruby.structured_value('Utils::Bottles::Tag', '${tag.arch}_${tag.system}', {
		'system': tag.system
		'arch':   tag.arch
	})
}

pub struct SystemSimulation {
pub mut:
	simulated_os   string
	simulated_arch string
pub:
	host_os   string
	host_arch string
}

pub struct SimulationTag {
pub:
	system string
	arch   string
}

pub fn new_system_simulation(host_os string, host_arch string) SystemSimulation {
	return SystemSimulation{
		host_os:   host_os
		host_arch: host_arch
	}
}

pub fn arch_symbols() map[string]string {
	return {
		'arm64':  'arm'
		'x86_64': 'intel'
	}
}

pub fn (mut state SystemSimulation) set_os(value string) ! {
	if value !in ['macos', 'linux'] && value !in macos_symbol_versions() {
		return error('Unknown OS: ${value}')
	}
	state.simulated_os = value
}

pub fn (mut state SystemSimulation) set_arch(value string) ! {
	if value !in ['arm', 'intel'] {
		return error('New arch must be :arm or :intel')
	}
	state.simulated_arch = value
}

pub fn (mut state SystemSimulation) clear() {
	state.simulated_os = ''
	state.simulated_arch = ''
}

pub fn (state SystemSimulation) simulating() bool {
	return state.simulated_os.len > 0 || state.simulated_arch.len > 0
}

pub fn (state SystemSimulation) simulating_or_running_on_macos() bool {
	return state.simulated_os == 'macos' || state.simulated_os in macos_symbol_versions()
}

pub fn (state SystemSimulation) simulating_or_running_on_linux() bool {
	return state.simulated_os == 'linux'
}

pub fn (state SystemSimulation) current_arch() string {
	return if state.simulated_arch.len > 0 { state.simulated_arch } else { state.host_arch }
}

pub fn (state SystemSimulation) current_os() string {
	return if state.simulated_os.len > 0 { state.simulated_os } else { state.host_os }
}

pub fn (state SystemSimulation) current_tag() SimulationTag {
	return SimulationTag{
		system: state.current_os()
		arch:   state.current_arch()
	}
}

pub fn (state SystemSimulation) with_tag(tag SimulationTag) !SystemSimulation {
	mut scoped := state
	scoped.set_os(tag.system)!
	scoped.set_arch(tag.arch)!
	return scoped
}

pub fn with_simulation[T](state SystemSimulation, os_value string, arch_value string,
	block fn (SystemSimulation) !T) !T {
	if os_value.len == 0 && arch_value.len == 0 {
		return error('At least one of `os` or `arch` must be specified.')
	}
	mut scoped := state
	if os_value.len > 0 && os_value != state.current_os() {
		scoped.set_os(os_value)!
	}
	if arch_value.len > 0 && arch_value != state.current_arch() {
		scoped.set_arch(arch_value)!
	}
	return block(scoped)
}

fn simulation_value(state SystemSimulation) ruby.Value {
	return ruby.structured_value('Homebrew::SimulateSystem', '', {
		'os':        state.simulated_os
		'arch':      state.simulated_arch
		'host_os':   state.host_os
		'host_arch': state.host_arch
	})
}

fn simulation_from_args(args []ruby.Value) SystemSimulation {
	if args.len == 0 || args[0].type_name != 'Homebrew::SimulateSystem' {
		return new_system_simulation('generic', '')
	}
	return SystemSimulation{
		simulated_os:   args[0].attributes['os']
		simulated_arch: args[0].attributes['arch']
		host_os:        args[0].attributes['host_os']
		host_arch:      args[0].attributes['host_arch']
	}
}

fn optional_symbol_value(value string) ruby.Value {
	return if value.len > 0 {
		ruby.object_value('Symbol', value)
	} else {
		ruby.object_value('Nil', '')
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "hardware"
// 5: require "macos_version"
// 6: require "utils/bottles"
// 7:
// 8: module Homebrew
// 9:   # Helper module for simulating different system configurations.
// 10:   class SimulateSystem
// 11:     class << self
// 12:       sig { returns(T.nilable(Symbol)) }
// 13:       attr_reader :arch
// 14:
// 15:       sig { returns(T.nilable(Symbol)) }
// 16:       attr_reader :os
// 17:
// 18:       sig { returns(T::Hash[Symbol, Symbol]) }
// 19:       def arch_symbols
// 20:         { arm64: :arm, x86_64: :intel }.freeze
// 21:       end
// 22:
// 23:       sig {
// 24:         type_parameters(:U).params(
// 25:           os:     Symbol,
// 26:           arch:   Symbol,
// 27:           _block: T.proc.returns(T.type_parameter(:U)),
// 28:         ).returns(T.type_parameter(:U))
// 29:       }
// 30:       def with(os: T.unsafe(nil), arch: T.unsafe(nil), &_block)
// 31:         raise ArgumentError, "At least one of `os` or `arch` must be specified." if !os && !arch
// 32:
// 33:         old_os = self.os
// 34:         old_arch = self.arch
// 35:
// 36:         begin
// 37:           self.os = os if os && os != current_os
// 38:           self.arch = arch if arch && arch != current_arch
// 39:
// 40:           yield
// 41:         ensure
// 42:           @os = old_os
// 43:           @arch = old_arch
// 44:         end
// 45:       end
// 46:
// 47:       sig {
// 48:         type_parameters(:U).params(
// 49:           tag:   Utils::Bottles::Tag,
// 50:           block: T.proc.returns(T.type_parameter(:U)),
// 51:         ).returns(T.type_parameter(:U))
// 52:       }
// 53:       def with_tag(tag, &block)
// 54:         raise ArgumentError, "Invalid tag: #{tag}" unless tag.valid_combination?
// 55:
// 56:         with(os: tag.system, arch: tag.arch, &block)
// 57:       end
// 58:
// 59:       sig { params(new_os: Symbol).void }
// 60:       def os=(new_os)
// 61:         os_options = [:macos, :linux, *MacOSVersion::SYMBOLS.keys]
// 62:         raise "Unknown OS: #{new_os}" unless os_options.include?(new_os)
// 63:
// 64:         @os = T.let(new_os, T.nilable(Symbol))
// 65:       end
// 66:
// 67:       sig { params(new_arch: Symbol).void }
// 68:       def arch=(new_arch)
// 69:         raise "New arch must be :arm or :intel" unless OnSystem::ARCH_OPTIONS.include?(new_arch)
// 70:
// 71:         @arch = T.let(new_arch, T.nilable(Symbol))
// 72:       end
// 73:
// 74:       sig { void }
// 75:       def clear
// 76:         @os = @arch = nil
// 77:       end
// 78:
// 79:       sig { returns(T::Boolean) }
// 80:       def simulating?
// 81:         os.present? || arch.present?
// 82:       end
// 83:
// 84:       sig { returns(T::Boolean) }
// 85:       def simulating_or_running_on_macos?
// 86:         [:macos, *MacOSVersion::SYMBOLS.keys].include?(os)
// 87:       end
// 88:
// 89:       sig { returns(T::Boolean) }
// 90:       def simulating_or_running_on_linux?
// 91:         os == :linux
// 92:       end
// 93:
// 94:       sig { returns(Symbol) }
// 95:       def current_arch
// 96:         @arch || Hardware::CPU.type
// 97:       end
// 98:
// 99:       sig { returns(Symbol) }
// 100:       def current_os
// 101:         os || :generic
// 102:       end
// 103:
// 104:       sig { returns(Utils::Bottles::Tag) }
// 105:       def current_tag
// 106:         Utils::Bottles::Tag.new(
// 107:           system: current_os,
// 108:           arch:   current_arch,
// 109:         )
// 110:       end
// 111:     end
// 112:   end
// 113: end
// 114:
// 115: require "extend/os/simulate_system"
