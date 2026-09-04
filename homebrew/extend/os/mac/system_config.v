module mac

import ruby

pub struct MacSystemConfig {
pub:
	clang                string
	clang_build          string
	xcode_installed      bool
	xcode_version        string
	xcode_prefix         string
	xcode_default_prefix bool = true
	clt_installed        bool
	clt_version          string
	arm64                bool
	physical_arm64       bool
	in_rosetta2          bool
	metal_success        bool
	metal_output         string
	macos_full_version   string
	kernel               string
	base_sections        []string
}

pub fn mac_describe_clang(config MacSystemConfig) string {
	if config.clang == '' {
		return 'N/A'
	}
	build := if config.clang_build == '' { '(parse error)' } else { config.clang_build }
	return '${config.clang} build ${build}'
}

pub fn mac_system_xcode(config MacSystemConfig) ?string {
	if !config.xcode_installed {
		return none
	}
	return if config.xcode_default_prefix {
		config.xcode_version
	} else {
		'${config.xcode_version} => ${config.xcode_prefix}'
	}
}

pub fn mac_system_clt(config MacSystemConfig) ?string {
	if !config.clt_installed {
		return none
	}
	return config.clt_version
}

pub fn mac_metal_toolchain(config MacSystemConfig) ?string {
	if !config.arm64 || !(config.xcode_installed || config.clt_installed) || !config.metal_success {
		return none
	}
	marker := 'MetalToolchain-v'
	if !config.metal_output.contains(marker) {
		return none
	}
	version := config.metal_output.all_after(marker).fields()[0]
	parts := version.split('.')
	if parts.len < 4 {
		return none
	}
	letter_value := parts[1].int()
	if letter_value < 1 || letter_value > 26 {
		return none
	}
	letter := rune(`A` + letter_value - 1).str()
	return '${parts[0]}.${parts[3]} (${parts[0]}${letter}${parts[2]})'
}

pub fn macos_config_lines(config MacSystemConfig) []string {
	mut lines := ['macOS: ${config.macos_full_version}-${config.kernel}']
	lines << 'CLT: ${mac_system_clt(config) or { 'N/A' }}'
	lines << 'Xcode: ${mac_system_xcode(config) or { 'N/A' }}'
	if config.arm64 && config.xcode_installed && version_at_least(config.xcode_version, '26.0') {
		lines << 'Metal Toolchain: ${mac_metal_toolchain(config) or { 'N/A' }}'
	}
	if config.physical_arm64 { lines << 'Rosetta 2: ${config.in_rosetta2}' }
	return lines
}

fn version_at_least(current string, required string) bool {
	a := current.split('.').map(it.int())
	b := required.split('.').map(it.int())
	maximum := if a.len > b.len { a.len } else { b.len }
	for index in 0 .. maximum {
		av := if index < a.len { a[index] } else { 0 }
		bv := if index < b.len { b[index] } else { 0 }
		if av != bv {
			return av > bv
		}
	}
	return true
}

pub fn mac_config_sections(config MacSystemConfig) []string {
	mut sections := config.base_sections.clone()
	sections << 'macos_config'
	return sections
}

fn mac_system_config_value(config &MacSystemConfig) ruby.Value {
	return ruby.structured_value('SystemConfig', '', {
		'mac_system_config_address': u64(voidptr(config)).str()
	})
}

fn mac_system_config_from_value(value ruby.Value) &MacSystemConfig {
	return unsafe { &MacSystemConfig(voidptr(value.attributes['mac_system_config_address'].u64())) }
}

pub fn mac_system_config_boundary(config &MacSystemConfig) ruby.Value {
	return mac_system_config_value(config)
}

// Translated from Homebrew/brew `extend/os/mac/system_config.rb`.
