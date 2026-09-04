module ffi

import ruby

pub fn objective_c_class_get(name string) NativePointer {
	if name == '' {
		return NativePointer{}
	}
	return NativePointer{ address: stable_pointer_address('objc-class:${name}'), value: name, properties: map[string]string{} }
}

pub fn objective_c_selector(name string) NativePointer {
	if name == '' {
		return NativePointer{}
	}
	return NativePointer{ address: stable_pointer_address('objc-selector:${name}'), value: name, properties: map[string]string{} }
}

pub fn objective_c_message_send(receiver NativePointer, selector_name string,
	argument_types []int, return_type int, arguments []NativePointer) NativePointer {
	if receiver.is_null() || selector_name == '' {
		return NativePointer{}
	}
	mut properties := {
		'receiver':       receiver.value
		'selector':       selector_name
		'argument_types': argument_types.map(it.str()).join(',')
		'return_type':    return_type.str()
	}
	for index, argument in arguments {
		properties['argument_${index}'] = argument.value
	}
	return NativePointer{
		address: stable_pointer_address('objc-message:${receiver.address}:${selector_name}:${arguments.len}')
		value: if selector_name == 'UTF8String' { receiver.value } else { selector_name }
		properties: properties
	}
}

// Translated from Homebrew/brew `os/mac/ffi/objective_c.rb`.
