module ffi

import ruby
import os

pub fn security_retained_pointer(status int, pointer NativePointer) ?NativePointer {
	if status != 0 || pointer.is_null() {
		return none
	}
	return core_foundation_autorelease(pointer)
}

pub fn security_static_code(path string, existing_paths []string) ?NativePointer {
	expanded := os.abs_path(path)
	if expanded !in existing_paths && path !in existing_paths {
		return none
	}
	path_string := core_foundation_string_create(expanded, 'UTF-8')
	path_url := core_foundation_url_create(path_string)
	if path_url.is_null() {
		return none
	}
	return security_retained_pointer(0, NativePointer{
		address: stable_pointer_address('SecStaticCode:${expanded}')
		value: expanded
		properties: map[string]string{}
	})
}

pub fn security_designated_requirement(path string, existing_paths []string,
	requirements map[string]string) ?string {
	_ := security_static_code(path, existing_paths) or { return none }
	if path in requirements {
		return requirements[path]
	}
	identifier := os.base(path)
	if identifier == '' {
		return none
	}
	return 'identifier "com.apple.${identifier}" and anchor apple'
}

pub fn security_requirement_match(path string, requirement string, existing_paths []string,
	requirements map[string]string) ?bool {
	designated := security_designated_requirement(path, existing_paths, requirements) or { return none }
	return designated == requirement
}

// Translated from Homebrew/brew `os/mac/ffi/security.rb`.
