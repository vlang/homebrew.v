module homebrew

// Translated from Homebrew/brew `pypi_packages.rb`.

// PypiPackagesConfig contains the keyword arguments accepted by PypiPackages.
// Arrays are copied into the model so callers cannot mutate its state later.
pub struct PypiPackagesConfig {
pub:
	package_name     ?string
	extra_packages   []string
	exclude_packages []string
	dependencies     []string
}

// PypiPackages is the immutable representation of the `pypi_packages` DSL data.
// An empty package name is intentionally different from none: the former tells
// Homebrew to skip the formula's main package while still processing extras.
pub struct PypiPackages {
	package_name_value     ?string
	extra_package_values   []string
	exclude_package_values []string
	dependency_values      []string
}

pub fn new_pypi_packages(config PypiPackagesConfig) PypiPackages {
	return PypiPackages{
		package_name_value: config.package_name
		extra_package_values: config.extra_packages.clone()
		exclude_package_values: config.exclude_packages.clone()
		dependency_values: config.dependencies.clone()
	}
}

pub fn (packages PypiPackages) package_name() ?string {
	return packages.package_name_value
}

pub fn (packages PypiPackages) extra_packages() []string {
	return packages.extra_package_values.clone()
}

pub fn (packages PypiPackages) exclude_packages() []string {
	return packages.exclude_package_values.clone()
}

pub fn (packages PypiPackages) dependencies() []string {
	return packages.dependency_values.clone()
}

fn (packages PypiPackages) to_config() PypiPackagesConfig {
	return PypiPackagesConfig{
		package_name: packages.package_name()
		extra_packages: packages.extra_packages()
		exclude_packages: packages.exclude_packages()
		dependencies: packages.dependencies()
	}
}
