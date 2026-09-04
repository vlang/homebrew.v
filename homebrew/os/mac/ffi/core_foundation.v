module ffi

import ruby

pub fn core_foundation_autorelease(pointer NativePointer) NativePointer {
	if pointer.is_null() {
		return pointer
	}
	return NativePointer{ ...pointer, free_symbol: 'CFRelease', properties: pointer.properties.clone() }
}

pub fn core_foundation_constant(name string, dereference bool) NativePointer {
	base := stable_pointer_address('CoreFoundation:${name}')
	return NativePointer{
		address: if dereference { base ^ u64(0x9e3779b97f4a7c15) } else { base }
		value: name
		properties: map[string]string{}
	}
}

pub fn core_foundation_string_create(value string, encoding string) NativePointer {
	cf_encoding := match encoding {
		'UTF-8' { '0x08000100' }
		'US-ASCII' { '0x0600' }
		'ASCII-8BIT', 'ISO-8859-1' { '0x0201' }
		else { '0x08000100' }
	}
	return core_foundation_autorelease(NativePointer{
		address: stable_pointer_address('CFString:${cf_encoding}:${value}')
		value: value
		properties: {
			'encoding': cf_encoding
		}
	})
}

pub fn core_foundation_dictionary_create(values map[u64]NativePointer) NativePointer {
	mut properties := map[string]string{}
	for key, value in values {
		properties[key.str()] = value.address.str()
	}
	return core_foundation_autorelease(NativePointer{
		address: stable_pointer_address('CFDictionary:${properties.str()}')
		value: 'dictionary'
		properties: properties
	})
}

pub fn core_foundation_url_create(path NativePointer) NativePointer {
	if path.is_null() {
		return NativePointer{}
	}
	return core_foundation_autorelease(NativePointer{
		address: stable_pointer_address('CFURL:${path.value}')
		value: path.value
		properties: {
			'path_style': 'POSIX'
			'directory':  'false'
		}
	})
}

pub fn core_foundation_url_set_property(mut url NativePointer, key NativePointer,
	value NativePointer) bool {
	if url.is_null() || key.is_null() {
		return false
	}
	url.properties[key.value] = value.value
	return true
}

// Translated from Homebrew/brew `os/mac/ffi/core_foundation.rb`.
