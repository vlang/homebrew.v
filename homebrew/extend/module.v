module extend

// Translated from Homebrew/brew `extend/module.rb`.

pub fn module_excludes(included_modules []string, module_name string) bool {
	return module_name !in included_modules
}
