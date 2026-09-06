module language

import ruby
import os

// Translated from Homebrew/brew `language/python.rb`.

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
