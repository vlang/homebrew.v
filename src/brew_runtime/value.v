module brew_runtime

// Value is the temporary boundary type used by source-faithful translations whose
// Ruby types have not been made concrete in V yet.
pub struct Value {
pub:
	type_name string
	repr      string
}

// unimplemented_fn marks a Ruby function whose body still needs a typed V
// translation. Keeping the original function name in the panic makes partial ports
// fail at the exact untranslated boundary.
pub fn unimplemented_fn(name string, args ...Value) Value {
	panic('unimplemented Ruby function `${name}` called with ${args.len} argument(s)')
}
