module mac

import ruby

pub struct MacDevelopmentTools {
pub mut:
	locate_cache map[string]string
	xcrun_calls  []string
	ld64_cached  bool
	ld64_version string
pub:
	base_tools                    map[string]string
	xcrun_results                 map[string]string
	executable_paths              []string
	xcode_installed               bool
	clt_installed                 bool
	ld64_output                   string
	ld64_success                  bool
	system_curl_too_old           bool
	clt_installation_instructions string
	xcode_version                 string
	clt_version                   string
	preferred_perl_version        string
	base_build_info               map[string]string
}

pub fn new_mac_development_tools() &MacDevelopmentTools {
	return &MacDevelopmentTools{
		locate_cache: map[string]string{}
		xcrun_calls: []string{}
	}
}

pub fn (tools MacDevelopmentTools) installed() bool {
	return tools.xcode_installed || tools.clt_installed
}

pub fn (mut tools MacDevelopmentTools) locate(tool string) ?string {
	if tool in tools.locate_cache {
		cached := tools.locate_cache[tool]
		return if cached == '' { none } else { cached }
	}
	if base := tools.base_tools[tool] {
		if base != '' {
			tools.locate_cache[tool] = base
			return base
		}
	}
	if !tools.installed() {
		tools.locate_cache[tool] = ''
		return none
	}
	tools.xcrun_calls << '/usr/bin/xcrun -no-cache -find ${tool}'
	path := (tools.xcrun_results[tool] or { '' }).trim_right('\n')
	if path == '' || path !in tools.executable_paths {
		tools.locate_cache[tool] = ''
		return none
	}
	tools.locate_cache[tool] = path
	return path
}

fn ld64_json_version(output string) string {
	marker := '"version"'
	if !output.contains(marker) {
		return ''
	}
	rest := output.all_after(marker).all_after(':').trim_space()
	return rest.trim_left('"').all_before('"').trim_space()
}

pub fn (mut tools MacDevelopmentTools) parsed_ld64_version() string {
	if tools.ld64_cached {
		return tools.ld64_version
	}
	tools.ld64_cached = true
	tools.ld64_version = if tools.ld64_success { ld64_json_version(tools.ld64_output) } else { '' }
	return tools.ld64_version
}

pub fn (tools MacDevelopmentTools) build_system_info() map[string]string {
	mut result := tools.base_build_info.clone()
	result['xcode'] = tools.xcode_version
	result['clt'] = tools.clt_version
	result['preferred_perl'] = tools.preferred_perl_version
	return result
}

fn development_tools_value(tools &MacDevelopmentTools) ruby.Value {
	return ruby.structured_value('DevelopmentTools', '', {
		'mac_development_tools_address': u64(voidptr(tools)).str()
	})
}

fn development_tools_from_value(value ruby.Value) &MacDevelopmentTools {
	return unsafe { &MacDevelopmentTools(voidptr(value.attributes['mac_development_tools_address'].u64())) }
}

pub fn mac_development_tools_boundary(tools &MacDevelopmentTools) ruby.Value {
	return development_tools_value(tools)
}

// Translated from Homebrew/brew `extend/os/mac/development_tools.rb`.

// Ruby method `locate(tool)` at line 15.
pub fn ruby_development_tools_l15_d1_locate(args ...ruby.Value) ruby.Value {
	mut tools := development_tools_from_value(args[0])
	path := tools.locate(args[1].as_string()) or {
		return ruby.object_value('NilClass', 'nil')
	}
	return ruby.string_value(path)
}
