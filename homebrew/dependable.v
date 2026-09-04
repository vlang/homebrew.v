module homebrew

// Translated from Homebrew/brew `dependable.rb`.

pub const dependable_prune = 'prune'
pub const dependable_skip = 'skip'
pub const dependable_keep_but_prune_recursive_deps = 'keep_but_prune_recursive_deps'
pub const dependable_reserved_tags = ['build', 'optional', 'recommended', 'run', 'test', 'linked',
	'implicit', 'no_linkage']

pub fn (dependency Dependency) option_names() []string {
	parts := dependency.name.split('/')
	if parts.len >= 3 {
		return [parts[2..].join('/')]
	}
	return [dependency.name]
}

pub fn (dependency Dependency) build() bool {
	return dependency.has_symbol_tag('build')
}

pub fn (dependency Dependency) optional() bool {
	return dependency.has_symbol_tag('optional')
}

pub fn (dependency Dependency) recommended() bool {
	return dependency.has_symbol_tag('recommended')
}

pub fn (dependency Dependency) test() bool {
	return dependency.has_symbol_tag('test')
}

pub fn (dependency Dependency) implicit() bool {
	return dependency.has_symbol_tag('implicit')
}

pub fn (dependency Dependency) no_linkage() bool {
	return dependency.has_symbol_tag('no_linkage')
}

pub fn (dependency Dependency) required() bool {
	return !dependency.build() && !dependency.test() && !dependency.optional()
		&& !dependency.recommended()
}

pub fn (dependency Dependency) option_tags() []string {
	return dependency.tags.filter(it.kind == .option).map(it.value)
}

pub fn (dependency Dependency) options() Options {
	return new_options(...dependency.option_tags())
}

pub fn (dependency Dependency) prune_from_option(build BuildOptions) bool {
	if !dependency.optional() && !dependency.recommended() {
		return false
	}
	return build.without_dependable(dependency)
}

pub fn (dependency Dependency) prune_if_build_and_not_formula(dependent_name string, formula_name string) bool {
	return dependency.build() && dependent_name != formula_name
}

pub fn (dependency Dependency) prune_if_build_and_dependency_installed(installed bool) bool {
	return dependency.build() && installed
}
