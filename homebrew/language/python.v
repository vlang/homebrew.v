module language

import ruby
import os

// Translated from Homebrew/brew `language/python.rb`.

fn python_error(type_name string, message string) ruby.Value {
	return ruby.object_value(type_name, message)
}

fn python_nil() ruby.Value {
	return ruby.object_value('NilClass', '')
}

fn python_value_with_map(type_name string, representation string,
	values map[string]ruby.Value) ruby.Value {
	return ruby.Value{
		type_name: type_name
		repr: representation
		map_data: values.clone()
	}
}

fn python_homebrew_prefix() string {
	configured := ruby.environment_value('HOMEBREW_PREFIX').trim_right('/')
	return if configured != '' { configured } else { '/opt/homebrew' }
}

fn python_homebrew_cellar() string {
	configured := ruby.environment_value('HOMEBREW_CELLAR').trim_right('/')
	return if configured != '' {
		configured
	} else {
		os.join_path(python_homebrew_prefix(), 'Cellar')
	}
}

fn python_major_minor_from_output(output string) ?string {
	bytes := output.bytes()
	if bytes.len < 3 {
		return none
	}
	for index in 0 .. bytes.len - 2 {
		if bytes[index] < `0` || bytes[index] > `9` || bytes[index + 1] != `.` {
			continue
		}
		mut end := index + 2
		for end < bytes.len && bytes[end] >= `0` && bytes[end] <= `9` {
			end++
		}
		if end > index + 2 {
			return output[index..end]
		}
	}
	return none
}

fn python_site_packages(python string, version_output string) string {
	if python == 'pypy' || python == 'pypy3' {
		return 'site-packages'
	}
	mut version := python_major_minor_from_output(version_output) or { '' }
	if version == '' {
		if at := python.index('python') {
			candidate := python[at + 'python'.len..].trim_left('@')
			if candidate.contains('.') {
				version = candidate
			}
		}
	}
	if version == '' {
		result := ruby.run_command(python, ['--version'])
		version = python_major_minor_from_output(result.output) or { '' }
	}
	return 'lib/python${version}/site-packages'
}

fn python_value_strings(value ruby.Value) []string {
	if value.type_name == 'NilClass' || value.type_name == '' {
		return []string{}
	}
	if value.type_name == 'String' {
		return [value.as_string()]
	}
	if strings := value.as_string_array() {
		if strings.len > 0 {
			return strings
		}
	}
	if values := value.as_array() {
		return values.map(it.as_string())
	}
	return [value.as_string()]
}

fn python_value_values(value ruby.Value) []ruby.Value {
	if values := value.as_array() {
		return values
	}
	return []ruby.Value{}
}

fn python_value_map(value ruby.Value) map[string]ruby.Value {
	return value.as_map() or { map[string]ruby.Value{} }
}

fn python_value_field(value ruby.Value, name string) string {
	if nested := value.map_data[name] {
		return nested.as_string()
	}
	if attribute := value.attributes[name] {
		return attribute
	}
	return ''
}

fn python_value_bool_field(value ruby.Value, name string, default_value bool) bool {
	if nested := value.map_data[name] {
		return nested.as_bool() or { nested.as_string() == 'true' }
	}
	if attribute := value.attributes[name] {
		return attribute == 'true'
	}
	return default_value
}

fn python_iteration_value(python string, version string, pythonpath string) ruby.Value {
	return python_value_with_map('PythonIteration', python, {
		'python':     ruby.string_value(python)
		'version':    if version == '' {
			python_nil()
		} else {
			ruby.object_value('Version', version)
		}
		'pythonpath': if pythonpath == '' {
			python_nil()
		} else {
			ruby.string_value(pythonpath)
		}
	})
}

fn python_directory_writable(path string) bool {
	probe := os.join_path(path, '.brew-v-python-writable-${os.getpid()}')
	os.write_file(probe, '') or { return false }
	os.rm(probe) or { return false }
	return true
}

fn python_version_at_least(version string, major int, minor int) bool {
	parts := version.split('.')
	if parts.len < 2 {
		return false
	}
	return parts[0].int() > major || (parts[0].int() == major && parts[1].int() >= minor)
}

fn python_virtualenv_value(formula ruby.Value, root string,
	python string) ruby.Value {
	return python_value_with_map('Language::Python::Virtualenv::Virtualenv', root, {
		'formula': ruby.Value{
			type_name: formula.type_name
			repr: formula.repr
			bool_data: formula.bool_data
			int_data: formula.int_data
			float_data: formula.float_data
			string_array_data: formula.string_array_data.clone()
			array_data: formula.array_data.clone()
			map_data: formula.map_data.clone()
			attributes: formula.attributes.clone()
		}
		'root':    ruby.string_value(root)
		'python':  ruby.string_value(python)
	})
}

fn python_virtualenv_site_packages(virtualenv ruby.Value) string {
	root := python_value_field(virtualenv, 'root')
	python := python_value_field(virtualenv, 'python')
	version_output := python_value_field(virtualenv, 'python_version_output')
	return os.join_path(root, python_site_packages(python, version_output))
}

fn python_dependency_pruned(dependency ruby.Value, formula ruby.Value,
	python string) bool {
	if python_value_bool_field(dependency, 'build', false) || python_value_bool_field(dependency, 'test', false) {
		return true
	}
	if python_value_bool_field(dependency, 'uses_from_macos', false) {
		return true
	}
	name := python_value_field(dependency, 'name')
	if name in python_names([]) {
		return true
	}
	if python_value_bool_field(dependency, 'optional', false) || python_value_bool_field(dependency, 'recommended', false) {
		formula_map := formula.as_map() or { formula.map_data.clone() }
		return name !in python_value_strings(formula_map['build_with'] or { python_nil() })
	}
	_ = python
	return false
}

fn python_name_from_full_name(name string) string {
	parts := name.split('/')
	return if parts.len > 0 { parts[parts.len - 1] } else { name }
}

fn python_names(formula_names []string) []string {
	mut names := ['python', 'python3', 'pypy', 'pypy3']
	for name in formula_names {
		if name.starts_with('python@') && name !in names {
			names << name
		}
	}
	return names
}

fn python_resource_name(resource ruby.Value) string {
	name := python_value_field(resource, 'name')
	return if name != '' { name } else { resource.repr }
}

fn python_slice_resources(resources map[string]ruby.Value,
	names []string) !(map[string]ruby.Value, []ruby.Value) {
	mut remaining := resources.clone()
	mut selected := []ruby.Value{}
	for name in names {
		if name !in remaining {
			return error('Resource "${name}" is not defined in formula or is already used.')
		}
		selected << remaining[name]
		remaining.delete(name)
	}
	return remaining, selected
}

fn python_order_resources(resources []ruby.Value, without []string, start_with []string,
	end_with []string) ![]ruby.Value {
	mut resources_hash := map[string]ruby.Value{}
	mut resource_order := []string{}
	for resource in resources {
		name := python_resource_name(resource)
		resources_hash[name] = resource
		resource_order << name
	}
	remaining_after_without, _ := python_slice_resources(resources_hash, without)!
	remaining_after_start, start := python_slice_resources(remaining_after_without, start_with)!
	remaining, end := python_slice_resources(remaining_after_start, end_with)!
	mut ordered := start.clone()
	for name in resource_order {
		if name in remaining {
			ordered << remaining[name]
		}
	}
	ordered << end
	return ordered
}

fn python_robustify_virtualenv(root string, cellar string, prefix string) ! {
	if !os.exists(root) {
		return
	}
	python_rewrite_cellar_symlinks(root, cellar, prefix)!
	python_rewrite_orig_prefix_files(root, cellar, prefix)!
	lib64 := os.join_path(root, 'lib64')
	if !os.exists(lib64) {
		os.symlink('lib', lib64)!
	}
	cfg_file := os.join_path(root, 'pyvenv.cfg')
	if os.is_file(cfg_file) {
		cfg := os.read_file(cfg_file)!
		rewritten := python_rewrite_pyvenv_cfg(cfg, cellar, prefix)
		if rewritten != cfg {
			ruby.atomic_write_file(cfg_file, rewritten)!
		}
	}
	bin := os.join_path(root, 'bin')
	if os.is_dir(bin) {
		for name in os.ls(bin)! {
			if name.to_lower().starts_with('activate') {
				os.rm(os.join_path(bin, name))!
			}
		}
	}
}

fn python_walk(root string) []string {
	mut paths := []string{}
	if !os.is_dir(root) {
		return paths
	}
	entries := os.ls(root) or { return paths }
	for entry in entries {
		path := os.join_path(root, entry)
		paths << path
		if os.is_dir(path) && !os.is_link(path) {
			paths << python_walk(path)
		}
	}
	return paths
}

fn python_cellar_formula(path string, cellar string) ?(string, string) {
	prefix := '${cellar.trim_right('/')}/python'
	if !path.starts_with(prefix) {
		return none
	}
	rest := path[prefix.len..]
	formula := if rest.starts_with('@') { 'python@${rest[1..].all_before('/')}' } else { 'python' }
	formula_prefix := '${cellar.trim_right('/')}/${formula}/'
	if !path.starts_with(formula_prefix) {
		return none
	}
	version_and_rest := path[formula_prefix.len..]
	slash := version_and_rest.index('/') or { return none }
	return formula, version_and_rest[slash + 1..]
}

fn python_rewrite_cellar_symlinks(root string, cellar string, prefix string) ! {
	for path in python_walk(root) {
		if !os.is_link(path) {
			continue
		}
		target := os.real_path(path)
		if formula, suffix := python_cellar_formula(target, cellar) {
			new_target := os.join_path(os.join_path(os.join_path(prefix, 'opt'), formula), suffix)
			os.rm(path)!
			os.symlink(new_target, path)!
		}
	}
}

fn python_rewrite_orig_prefix_files(root string, cellar string, prefix string) ! {
	lib := os.join_path(root, 'lib')
	for path in python_walk(lib) {
		if os.base(path) != 'orig-prefix.txt' || !os.is_file(path) {
			continue
		}
		contents := os.read_file(path)!
		if formula, suffix := python_cellar_formula(contents, cellar) {
			rewritten := os.join_path(os.join_path(os.join_path(prefix, 'opt'), formula), suffix)
			ruby.atomic_write_file(path, rewritten)!
		}
	}
}

fn python_rewrite_pyvenv_cfg(contents string, cellar string, prefix string) string {
	mut output := []string{}
	for line in contents.split('\n') {
		mut rewritten := line
		if equals := line.index('=') {
			value := line[equals + 1..].trim_space()
			if value.contains('/bin') {
				if formula, _ := python_cellar_formula(value, cellar) {
					rewritten = '${line[..equals + 1]} ${os.join_path(os.join_path(os.join_path(prefix, 'opt'), formula), 'bin')}'
				}
			}
		}
		output << rewritten
	}
	return output.join('\n')
}

fn python_targets(value ruby.Value) []ruby.Value {
	if value.type_name == 'Array' {
		return python_value_values(value)
	}
	return [value]
}

fn python_multiline_targets(contents string) []string {
	mut lines := contents.split('\n')
	if lines.len > 0 && lines[lines.len - 1] == '' {
		lines.delete(lines.len - 1)
	}
	return lines.map(it.trim_space())
}

fn python_is_pure_py3_wheel(url string) bool {
	return (url.contains('-py3') || url.contains('.py3')) && url.contains('-none-any.whl')
}

fn python_std_pip_args(build_isolation bool) []string {
	mut args := ['--verbose', '--no-deps', '--no-binary=:all:', '--ignore-installed', '--no-compile',
		'--uploaded-prior-to=P1D']
	if !build_isolation {
		args << '--no-build-isolation'
	}
	return args
}

fn python_pip_command_value(virtualenv ruby.Value, targets []string,
	std_args []string) ruby.Value {
	python := python_value_field(virtualenv, 'python')
	root := python_value_field(virtualenv, 'root')
	mut command := [python, '-m', 'pip', '--python=${os.join_path(root, 'bin/python')}', 'install']
	command << std_args
	command << targets
	return ruby.string_array_value(command)
}

fn python_glob_files(root string, recursive bool) []string {
	if !os.is_dir(root) {
		return []string{}
	}
	mut paths := if recursive { python_walk(root) } else { []string{} }
	if !recursive {
		for name in os.ls(root) or { return []string{} } {
			paths << os.join_path(root, name)
		}
	}
	paths.sort()
	return paths
}

fn python_difference(after []string, before []string) []string {
	mut result := []string{}
	for value in after {
		if value !in before {
			result << value
		}
	}
	return result
}

fn python_install_symlink(source string, destination string) ! {
	os.mkdir_all(os.dir(destination))!
	if os.exists(destination) || os.is_link(destination) {
		return
	}
	os.symlink(source, destination)!
}
