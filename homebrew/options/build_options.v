module options

// BuildOptions is the set of arguments used for a formula build together with
// the complete set of options declared by that formula.
pub struct BuildOptions {
pub:
	args    Options
	options Options
}

// OptionNameProvider is the typed V counterpart of Homebrew's Dependable
// objects, whose option_names method can map one dependency to multiple names.
pub interface OptionNameProvider {
	option_names() []string
}

// new_build_options translates BuildOptions.new(args, options).
pub fn new_build_options(args Options, options Options) BuildOptions {
	return BuildOptions{
		args:    args
		options: options
	}
}

// with reports whether a named feature is enabled for this build.
pub fn (build BuildOptions) with(name string) bool {
	return build.with_any([name])
}

// with_dependable translates the Dependable branch of BuildOptions#with?.
pub fn (build BuildOptions) with_dependable(value OptionNameProvider) bool {
	return build.with_any(value.option_names())
}

// with_any retains the any? behavior used for Dependable option names.
pub fn (build BuildOptions) with_any(names []string) bool {
	for name in names {
		if build.option_defined('with-${name}') {
			if build.includes('with-${name}') {
				return true
			}
		} else if build.option_defined('without-${name}') && !build.includes('without-${name}') {
			return true
		}
	}
	return false
}

// without is the logical inverse of with, matching BuildOptions#without?.
pub fn (build BuildOptions) without(name string) bool {
	return !build.with(name)
}

pub fn (build BuildOptions) without_dependable(value OptionNameProvider) bool {
	return !build.with_dependable(value)
}

// bottle reports whether --build-bottle was supplied.
pub fn (build BuildOptions) bottle() bool {
	return build.includes('build-bottle')
}

// head reports whether --HEAD was supplied.
pub fn (build BuildOptions) head() bool {
	return build.includes('HEAD')
}

// stable is the inverse of head.
pub fn (build BuildOptions) stable() bool {
	return !build.head()
}

// any_args_or_options retains Ruby's distinction between an entirely empty
// build and one with either supplied arguments or declared formula options.
pub fn (build BuildOptions) any_args_or_options() bool {
	return !build.args.empty() || !build.options.empty()
}

// used_options returns declared options that occur in the build arguments.
pub fn (build BuildOptions) used_options() Options {
	return build.options.intersection(build.args)
}

// unused_options returns declared options absent from the build arguments.
pub fn (build BuildOptions) unused_options() Options {
	return build.options.minus(build.args)
}

pub fn (build BuildOptions) includes(name string) bool {
	return build.args.contains('--${name}')
}

pub fn (build BuildOptions) option_defined(name string) bool {
	return build.options.contains(name)
}
