module ffi

pub struct XattrStore {
pub mut:
	values map[string]map[string]string
}

pub fn xattr_error(operation string, path string, attribute ?string, errno int) IError {
	target := attribute or { path }
	return error('${operation} for ${target}: errno ${errno}')
}

pub fn list_xattrs(store &XattrStore, path string) ![]string {
	if path !in store.values {
		return []
	}
	attributes := store.values[path].clone()
	return attributes.keys()
}

pub fn get_xattr(store &XattrStore, path string, attribute string) !string {
	if path !in store.values {
		return xattr_error('getxattr', path, attribute, 1)
	}
	attributes := store.values[path].clone()
	return attributes[attribute] or { return xattr_error('getxattr', path, attribute, 1) }
}

pub fn set_xattr(mut store XattrStore, path string, attribute string, value string) ! {
	mut attributes := if path in store.values {
		store.values[path].clone()
	} else {
		map[string]string{}
	}
	attributes[attribute] = value
	store.values[path] = attributes.clone()
}

pub fn remove_xattr(mut store XattrStore, path string, attribute string) ! {
	if path !in store.values {
		return xattr_error('removexattr', path, attribute, 1)
	}
	mut attributes := store.values[path].clone()
	if attribute !in attributes {
		return xattr_error('removexattr', path, attribute, 1)
	}
	attributes.delete(attribute)
	store.values[path] = attributes.clone()
}

pub fn copy_xattrs(mut store XattrStore, source string, destination string) ! {
	destination_attributes := list_xattrs(&store, destination)!
	for attribute in destination_attributes {
		remove_xattr(mut store, destination, attribute)!
	}
	source_attributes := list_xattrs(&store, source)!
	for attribute in source_attributes {
		set_xattr(mut store, destination, attribute, get_xattr(&store, source, attribute)!)!
	}
}

// Translated from Homebrew/brew `os/mac/ffi/xattr.rb`.
