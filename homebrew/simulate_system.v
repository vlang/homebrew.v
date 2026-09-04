module homebrew

import ruby

// Translated from Homebrew/brew `simulate_system.rb`.

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
		host_os: host_os
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
		arch: state.current_arch()
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
		simulated_os: args[0].attributes['os']
		simulated_arch: args[0].attributes['arch']
		host_os: args[0].attributes['host_os']
		host_arch: args[0].attributes['host_arch']
	}
}

fn optional_symbol_value(value string) ruby.Value {
	return if value.len > 0 {
		ruby.object_value('Symbol', value)
	} else {
		ruby.object_value('Nil', '')
	}
}
