module cask

import ruby
import homebrew.cask as base_cask

pub struct MacQuarantineCask {
pub:
	url      string
	homepage string
}

pub struct MacQuarantineFfi {
pub:
	detected               bool
	path_string_created    bool = true
	path_url_created       bool = true
	agent_name_created     bool = true
	data_url_created       bool = true
	origin_url_created     bool = true
	dictionary_created     bool = true
	property_written       bool = true
	designated_requirement ?string
	requirement_match      ?bool
}

pub struct MacQuarantineWrite {
pub:
	path       string
	agent_name string
	data_url   string
	origin_url string
	action     bool
}

pub struct MacQuarantineWriteOutcome {
pub:
	present bool
	write   MacQuarantineWrite
}

pub type MacCopyXattrs = fn (string, string) !

pub fn mac_quarantine_check_support(xattr_available bool) base_cask.QuarantineSupport {
	return base_cask.QuarantineSupport{
		kind: if xattr_available { .quarantine_available } else { .xattr_broken }
	}
}

pub fn mac_quarantine_signing_identity(_ string,
	requirement ?string) ?base_cask.QuarantineSigningIdentity {
	value := requirement or { return none }
	return base_cask.QuarantineSigningIdentity{ requirement: value }
}

pub fn mac_quarantine_signing_identity_match(_ string, _ base_cask.QuarantineSigningIdentity,
	matched ?bool) ?bool {
	return matched
}

pub fn mac_quarantine_cask(cask ?MacQuarantineCask, download_path ?string, action bool,
	ffi MacQuarantineFfi) !MacQuarantineWriteOutcome {
	item := cask or { return MacQuarantineWriteOutcome{} }
	path := download_path or { return MacQuarantineWriteOutcome{} }
	if ffi.detected {
		return MacQuarantineWriteOutcome{}
	}
	if !ffi.path_string_created {
		return error('Failed to create CFString for path: ${path}')
	}
	if !ffi.path_url_created {
		return error('Failed to create CFURL for path: ${path}')
	}
	if !ffi.agent_name_created || !ffi.data_url_created || !ffi.origin_url_created {
		return error('Failed to create CFString for quarantine properties: ${path}')
	}
	if !ffi.dictionary_created {
		return error('Failed to create quarantine dictionary: ${path}')
	}
	if !ffi.property_written {
		return error('Failed to set quarantine properties for URL: ${path}')
	}
	return MacQuarantineWriteOutcome{
		present: true
		write: MacQuarantineWrite{
			path: path
			agent_name: 'Homebrew Cask'
			data_url: item.url
			origin_url: item.homepage
			action: action
		}
	}
}

pub fn mac_quarantine_copy_xattrs(from string, to string, writable bool,
	ruby_executable string, ruby_args []string, load_path string, library_path string,
	copier MacCopyXattrs, command base_cask.QuarantineCommandRunner) !base_cask.QuarantineCommand {
	if writable {
		copier(from, to)!
		return base_cask.QuarantineCommand{}
	}
	script := ruby.join_path(library_path, 'cask/utils/copy_xattrs.rb')
	mut args := ruby_args.clone()
	args << ['-I', load_path, script, from, to]
	plan := base_cask.QuarantineCommand{
		executable: ruby_executable
		args: args
		sudo: true
	}
	result := command(plan)!
	if !result.success() {
		return error(result.stderr)
	}
	return plan
}

fn mac_ffi_from_values(args []ruby.Value) MacQuarantineFfi {
	mut values := map[string]ruby.Value{}
	for value in args {
		if value.type_name == 'Hash' {
			values = value.map_data.clone()
		}
	}
	return MacQuarantineFfi{
		detected: values['detected'] or { ruby.bool_value(false) }.bool_data
		path_string_created: values['path_string_created'] or { ruby.bool_value(true) }.bool_data
		path_url_created: values['path_url_created'] or { ruby.bool_value(true) }.bool_data
		agent_name_created: values['agent_name_created'] or { ruby.bool_value(true) }.bool_data
		data_url_created: values['data_url_created'] or { ruby.bool_value(true) }.bool_data
		origin_url_created: values['origin_url_created'] or { ruby.bool_value(true) }.bool_data
		dictionary_created: values['dictionary_created'] or { ruby.bool_value(true) }.bool_data
		property_written: values['property_written'] or { ruby.bool_value(true) }.bool_data
		designated_requirement: if requirement := values['requirement'] {
			requirement.as_string()
		} else {
			none
		}
		requirement_match: if matched := values['matched'] {
			matched.bool_data
		} else {
			none
		}
	}
}

fn mac_value_string(args []ruby.Value, key string, position int) ?string {
	mut current := 0
	for value in args {
		if value.type_name == 'Hash' {
			if raw := value.map_data[key] {
				return raw.as_string()
			}
			continue
		}
		if current == position {
			return value.as_string()
		}
		current++
	}
	return none
}

fn mac_quarantine_error(message string) ruby.Value {
	return ruby.structured_value('CaskQuarantineError', message, {
		'message': message
	})
}

// Translated from Homebrew/brew `extend/os/mac/cask/quarantine.rb`.
