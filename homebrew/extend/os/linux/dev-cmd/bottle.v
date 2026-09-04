module dev_cmd

// Translated from Homebrew/brew `extend/os/linux/dev-cmd/bottle.rb`.
pub fn linux_formula_ignores(formula_name string, cellar string, prefix string,
	base_ignores []string) []string {
	mut ignores := base_ignores.clone()
	if formula_name == 'gcc' || formula_name.starts_with('gcc@') {
		ignores << '${cellar}/gcc|${prefix}/opt/gcc'
	} else if formula_name == 'binutils' || formula_name.starts_with('binutils@') {
		ignores << '${cellar}/binutils'
	}
	return ignores
}
