module language

import brew_runtime
import homebrew.utils
import os

// Translated from Homebrew/brew `language/python.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.major_minor_version(python)` at line 16.
pub fn ruby_python_l16_d1_self_major_minor_version(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 || args[0].as_string() == '' {
		return python_error('ArgumentError', 'python is required')
	}
	output := if args.len > 1 {
		args[1].as_string()
	} else {
		brew_runtime.run_command(args[0].as_string(), ['--version']).output
	}
	version := python_major_minor_from_output(output) or { return python_nil() }
	return brew_runtime.object_value('Version', version)
}

// Ruby method `self.homebrew_site_packages(python = "python3.7")` at line 24.
pub fn ruby_python_l24_d2_self_homebrew_site_packages(args ...brew_runtime.Value) brew_runtime.Value {
	python := if args.len > 0 { args[0].as_string() } else { 'python3.7' }
	prefix := if args.len > 1 { args[1].as_string() } else { python_homebrew_prefix() }
	version_output := if args.len > 2 { args[2].as_string() } else { '' }
	return brew_runtime.string_value(os.join_path(prefix, python_site_packages(python, version_output)))
}

// Ruby method `self.site_packages(python = "python3.7")` at line 29.
pub fn ruby_python_l29_d3_self_site_packages(args ...brew_runtime.Value) brew_runtime.Value {
	python := if args.len > 0 { args[0].as_string() } else { 'python3.7' }
	version_output := if args.len > 1 { args[1].as_string() } else { '' }
	return brew_runtime.string_value(python_site_packages(python, version_output))
}

// Ruby method `self.each_python(build, &block)` at line 43.
pub fn ruby_python_l43_d4_self_each_python(args ...brew_runtime.Value) brew_runtime.Value {
	build := if args.len > 0 { args[0] } else { brew_runtime.map_value({}) }
	build_map := build.as_map() or { map[string]brew_runtime.Value{} }
	without := python_value_strings(build_map['without'] or { python_nil() })
	latest := python_value_map(build_map['latest_installed'] or { python_nil() })
	versions := python_value_map(build_map['versions'] or { python_nil() })
	prefix := if args.len > 1 { args[1].as_string() } else { python_homebrew_prefix() }
	original_pythonpath := os.getenv_opt('PYTHONPATH')
	defer {
		if value := original_pythonpath {
			os.setenv('PYTHONPATH', value, true)
		} else {
			os.unsetenv('PYTHONPATH')
		}
	}
	formulae := ['python@3', 'pypy', 'pypy3']
	interpreters := ['python3', 'pypy', 'pypy3']
	mut yielded := []brew_runtime.Value{}
	for index, formula_name in formulae {
		if formula_name in without {
			continue
		}
		python := interpreters[index]
		output := (versions[python] or { brew_runtime.string_value('') }).as_string()
		version := python_major_minor_from_output(output) or { '' }
		latest_installed := (latest[formula_name] or { brew_runtime.bool_value(false) }).as_bool() or {
			false
		}
		pythonpath := if latest_installed {
			''
		} else {
			os.join_path(prefix, python_site_packages(python, output))
		}
		if pythonpath == '' {
			os.unsetenv('PYTHONPATH')
		} else {
			os.setenv('PYTHONPATH', pythonpath, true)
		}
		yielded << python_iteration_value(python, version, pythonpath)
	}
	return brew_runtime.array_value(yielded)
}

// Ruby method `self.reads_brewed_pth_files?(python)` at line 64.
pub fn ruby_python_l64_d5_self_reads_brewed_pth_files(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	python := args[0].as_string()
	site_packages := if args.len > 1 {
		args[1].as_string()
	} else {
		os.join_path(python_homebrew_prefix(), python_site_packages(python, ''))
	}
	if !os.is_dir(site_packages) || !python_directory_writable(site_packages) {
		return brew_runtime.bool_value(false)
	}
	probe_file := os.join_path(site_packages, 'homebrew-pth-probe.pth')
	os.write_file(probe_file, 'import site; site.homebrew_was_here = True') or {
		return brew_runtime.bool_value(false)
	}
	defer {
		if os.exists(probe_file) {
			os.rm(probe_file) or {}
		}
	}
	if args.len > 2 && args[2].type_name == 'Bool' {
		return brew_runtime.bool_value(args[2].as_bool() or { false })
	}
	result := brew_runtime.run_command(python, ['-c', 'import site; assert(site.homebrew_was_here)'])
	return brew_runtime.bool_value(result.exit_code == 0)
}

// Ruby method `self.user_site_packages(python)` at line 78.
pub fn ruby_python_l78_d6_self_user_site_packages(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return python_error('ArgumentError', 'python is required')
	}
	output := if args.len > 1 {
		args[1].as_string()
	} else {
		brew_runtime.run_command(args[0].as_string(), ['-c',
			'import site; print(site.getusersitepackages())']).output
	}
	return brew_runtime.string_value(output.trim_space())
}

// Ruby method `self.in_sys_path?(python, path)` at line 83.
pub fn ruby_python_l83_d7_self_in_sys_path(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.bool_value(false)
	}
	path := os.real_path(args[1].as_string())
	if args.len > 2 {
		paths := python_value_strings(args[2])
		return brew_runtime.bool_value(paths.any(os.real_path(it) == path))
	}
	script := 'import os, sys\n[os.path.realpath(p) for p in sys.path].index(os.path.realpath("${args[1].as_string()}"))\n'
	result := brew_runtime.run_command(args[0].as_string(), ['-c', script])
	return brew_runtime.bool_value(result.exit_code == 0)
}

// Ruby method `python_shebang_rewrite_info(python_path)` at line 107.
pub fn ruby_python_l107_d8_python_shebang_rewrite_info(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return python_error('ArgumentError', 'python path is required')
	}
	info := utils.new_shebang_rewrite_info(r'^#! ?(?:/usr/bin/(?:env )?)?python(?:[23](?:\.\d{1,2})?)?( |$)', '#! /usr/bin/env pythonx.yyy '.len, '${args[0].as_string()}\\1') or {
		return python_error('ArgumentError', err.msg())
	}
	return utils.rewrite_info_value(info)
}

// Ruby method `detected_python_shebang(formula = T.cast(self, Formula), use_python_from_path: false)` at line 116.
pub fn ruby_python_l116_d9_detected_python_shebang(args ...brew_runtime.Value) brew_runtime.Value {
	formula := if args.len > 0 { args[0] } else { brew_runtime.map_value({}) }
	use_python_from_path := if args.len > 1 { args[1].as_bool() or { false } } else { false }
	if use_python_from_path {
		return ruby_python_l107_d8_python_shebang_rewrite_info(brew_runtime.string_value('/usr/bin/env python3'))
	}
	formula_map := formula.as_map() or { formula.map_data.clone() }
	dependencies := python_value_values(formula_map['deps'] or { python_nil() })
	mut python_dependencies := []string{}
	for dependency in dependencies {
		name := python_value_field(dependency, 'name')
		required := python_value_bool_field(dependency, 'required', true)
		if required && (name == 'python' || name.starts_with('python@')) {
			python_dependencies << name
		}
	}
	if python_dependencies.len == 0 {
		return python_error('ShebangDetectionError', 'Cannot detect Python shebang: formula does not depend on Python.')
	}
	if python_dependencies.len > 1 {
		return python_error('ShebangDetectionError', 'Cannot detect Python shebang: formula has multiple Python dependencies.')
	}
	prefix := if args.len > 2 { args[2].as_string() } else { python_homebrew_prefix() }
	name := python_dependencies[0]
	path := os.join_path(os.join_path(os.join_path(prefix, 'opt'), name), 'bin/${name.replace('@', '')}')
	return ruby_python_l107_d8_python_shebang_rewrite_info(brew_runtime.string_value(path))
}

// Ruby method `virtualenv_create(venv_root, python = "python", formula = T.cast(self, Formula),` at line 159.
pub fn ruby_python_l159_d10_virtualenv_create(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return python_error('ArgumentError', 'venv_root is required')
	}
	root := args[0].as_string()
	python := if args.len > 1 && args[1].as_string() != '' { args[1].as_string() } else { 'python' }
	formula := if args.len > 2 { args[2] } else { brew_runtime.map_value({}) }
	system_site_packages := if args.len > 3 { args[3].as_bool() or { true } } else { true }
	without_pip := if args.len > 4 { args[4].as_bool() or { true } } else { true }
	if !without_pip {
		version_output := if args.len > 5 { args[5].as_string() } else { '' }
		version := if version_output != '' {
			python_major_minor_from_output(version_output) or { '' }
		} else {
			version_value := ruby_python_l16_d1_self_major_minor_version(brew_runtime.string_value(python))
			if version_value.type_name == 'Version' { version_value.as_string() } else { '' }
		}
		if version == '' || python_version_at_least(version, 3, 12) {
			return python_error('ArgumentError', "virtualenv_create's without_pip is deprecated starting with Python 3.12")
		}
	}
	mut virtualenv := python_virtualenv_value(formula, root, python)
	virtualenv = ruby_python_l313_d18_create(virtualenv, brew_runtime.bool_value(system_site_packages), brew_runtime.bool_value(without_pip))
	if virtualenv.type_name.ends_with('Error') {
		return virtualenv
	}
	formula_map := formula.as_map() or { formula.map_data.clone() }
	recursive_dependencies := python_value_values(formula_map['recursive_dependencies'] or {
		python_nil()
	})
	mut pth_contents := ''
	for dependency in recursive_dependencies {
		if python_dependency_pruned(dependency, formula, python) {
			continue
		}
		opt_prefix := python_value_field(dependency, 'opt_prefix')
		if opt_prefix == '' {
			continue
		}
		version_output := python_value_field(dependency, 'python_version_output')
		dep_site_packages := os.join_path(opt_prefix, python_site_packages(python, version_output))
		if os.exists(dep_site_packages) {
			pth_contents += "import site; site.addsitedir('${dep_site_packages}')\n"
		}
	}
	if pth_contents != '' {
		site_packages := python_virtualenv_site_packages(virtualenv)
		os.mkdir_all(site_packages) or { return python_error('IOError', err.msg()) }
		os.write_file(os.join_path(site_packages, 'homebrew_deps.pth'), pth_contents) or {
			return python_error('IOError', err.msg())
		}
	}
	return virtualenv
}

// Ruby method `needs_python?(python)` at line 205.
pub fn ruby_python_l205_d11_needs_python(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.bool_value(false)
	}
	formula := args[0]
	python := args[1].as_string()
	formula_map := formula.as_map() or { formula.map_data.clone() }
	build_with := python_value_strings(formula_map['build_with'] or { python_nil() })
	if python in build_with {
		return brew_runtime.bool_value(true)
	}
	mut dependables := python_value_values(formula_map['requirements'] or { python_nil() })
	dependables << python_value_values(formula_map['deps'] or { python_nil() })
	for dependable in dependables {
		if python_name_from_full_name(python_value_field(dependable, 'name')) == python && python_value_bool_field(dependable, 'required', true) {
			return brew_runtime.bool_value(true)
		}
	}
	return brew_runtime.bool_value(false)
}

// Ruby method `virtualenv_install_with_resources(using: nil, system_site_packages: true, without_pip: true,` at line 229.
pub fn ruby_python_l229_d12_virtualenv_install_with_resources(args ...brew_runtime.Value) brew_runtime.Value {
	formula := if args.len > 0 { args[0] } else { brew_runtime.map_value({}) }
	using := if args.len > 1 { args[1].as_string() } else { '' }
	without := if args.len > 2 { python_value_strings(args[2]) } else { []string{} }
	start_with := if args.len > 3 { python_value_strings(args[3]) } else { []string{} }
	end_with := if args.len > 4 { python_value_strings(args[4]) } else { []string{} }
	system_site_packages := if args.len > 5 { args[5].as_bool() or { true } } else { true }
	without_pip := if args.len > 6 { args[6].as_bool() or { true } } else { true }
	link_manpages := if args.len > 7 { args[7].as_bool() or { true } } else { true }
	formula_map := formula.as_map() or { formula.map_data.clone() }
	mut python := using
	if python == '' {
		mut wanted := []string{}
		for candidate in python_names(python_value_strings(formula_map['formula_names'] or {
			python_nil()
		})) {
			if ruby_python_l205_d11_needs_python(formula, brew_runtime.string_value(candidate)).as_bool() or {
				false} {
				wanted << candidate
			}
		}
		if wanted.len == 0 {
			return python_error('FormulaUnknownPythonError', python_value_field(formula, 'name'))
		}
		if wanted.len > 1 {
			return python_error('FormulaAmbiguousPythonError', python_value_field(formula, 'name'))
		}
		python = if wanted[0] == 'python' { 'python3' } else { wanted[0] }
	}
	resources := python_value_values(formula_map['resources'] or { python_nil() })
	ordered := python_order_resources(resources, without, start_with, end_with) or {
		return python_error('ArgumentError', err.msg())
	}
	root := python_value_field(formula, 'libexec')
	buildpath := python_value_field(formula, 'buildpath')
	mut virtualenv := ruby_python_l159_d10_virtualenv_create(brew_runtime.string_value(root), brew_runtime.string_value(python.replace('@', '')), formula, brew_runtime.bool_value(system_site_packages), brew_runtime.bool_value(without_pip))
	if virtualenv.type_name.ends_with('Error') {
		return virtualenv
	}
	install_commands := ruby_python_l383_d19_pip_install(virtualenv, brew_runtime.array_value(ordered), brew_runtime.bool_value(true))
	link_result := ruby_python_l411_d20_pip_install_and_link(virtualenv, brew_runtime.string_value(buildpath), brew_runtime.bool_value(link_manpages), brew_runtime.bool_value(true))
	mut values := virtualenv.map_data.clone()
	values['resources'] = brew_runtime.array_value(ordered)
	values['pip_install'] = install_commands
	values['pip_install_and_link'] = link_result
	return python_value_with_map('Language::Python::Virtualenv::Virtualenv', root, values)
}

// Ruby method `python_names` at line 261.
pub fn ruby_python_l261_d13_python_names(args ...brew_runtime.Value) brew_runtime.Value {
	formula_names := if args.len > 0 { python_value_strings(args[0]) } else { []string{} }
	return brew_runtime.string_array_value(python_names(formula_names))
}

// Ruby method `slice_resources!(resources_hash, resource_names)` at line 273.
pub fn ruby_python_l273_d14_slice_resources(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return python_error('ArgumentError', 'resources_hash and resource_names are required')
	}
	resources := args[0].as_map() or { return python_error('TypeError', err.msg()) }
	names := python_value_strings(args[1])
	remaining, selected := python_slice_resources(resources, names) or {
		return python_error('ArgumentError', err.msg())
	}
	return python_value_with_map('PythonResourceSlice', selected.map(it.repr).str(), {
		'remaining': brew_runtime.map_value(remaining)
		'selected':  brew_runtime.array_value(selected)
	})
}

// Ruby method `initialize(formula, venv_root, python)` at line 293.
pub fn ruby_python_l293_d15_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		return python_error('ArgumentError', 'formula, venv_root and python are required')
	}
	return python_virtualenv_value(args[0], args[1].as_string(), args[2].as_string())
}

// Ruby method `root` at line 300.
pub fn ruby_python_l300_d16_root(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return python_error('ArgumentError', 'virtualenv is required')
	}
	return brew_runtime.string_value(python_value_field(args[0], 'root'))
}

// Ruby method `site_packages` at line 305.
pub fn ruby_python_l305_d17_site_packages(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return python_error('ArgumentError', 'virtualenv is required')
	}
	return brew_runtime.string_value(python_virtualenv_site_packages(args[0]))
}

// Ruby method `create(system_site_packages: true, without_pip: true)` at line 313.
pub fn ruby_python_l313_d18_create(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return python_error('ArgumentError', 'virtualenv is required')
	}
	virtualenv := args[0]
	root := python_value_field(virtualenv, 'root')
	python := python_value_field(virtualenv, 'python')
	system_site_packages := if args.len > 1 { args[1].as_bool() or { true } } else { true }
	without_pip := if args.len > 2 { args[2].as_bool() or { true } } else { true }
	mut values := virtualenv.map_data.clone()
	if os.exists(os.join_path(root, 'bin/python')) {
		values['command'] = brew_runtime.string_array_value([])
		return python_value_with_map(virtualenv.type_name, virtualenv.repr, values)
	}
	mut command := [python, '-m', 'venv']
	if system_site_packages {
		command << '--system-site-packages'
	}
	if without_pip {
		command << '--without-pip'
	}
	command << root
	values['command'] = brew_runtime.string_array_value(command)
	python_robustify_virtualenv(root, python_homebrew_cellar(), python_homebrew_prefix()) or {
		return python_error('IOError', err.msg())
	}
	return python_value_with_map(virtualenv.type_name, virtualenv.repr, values)
}

// Ruby method `pip_install(targets, build_isolation: true)` at line 383.
pub fn ruby_python_l383_d19_pip_install(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return python_error('ArgumentError', 'virtualenv and targets are required')
	}
	virtualenv := args[0]
	targets := python_targets(args[1])
	build_isolation := if args.len > 2 { args[2].as_bool() or { true } } else { true }
	std_args := if args.len > 3 {
		python_value_strings(args[3])
	} else {
		python_std_pip_args(build_isolation)
	}
	mut commands := []brew_runtime.Value{}
	for target in targets {
		if target.type_name == 'Resource' {
			stage_path := python_value_field(target, 'stage_path')
			mut install_target := if stage_path != '' {
				stage_path
			} else {
				brew_runtime.current_directory()
			}
			url := python_value_field(target, 'url')
			basename := python_value_field(target, 'basename')
			if python_is_pure_py3_wheel(url) && basename != '' {
				install_target = os.join_path(install_target, basename)
			}
			commands << python_pip_command_value(virtualenv, [install_target], std_args)
			continue
		}
		if target.type_name == 'String' && target.as_string().contains('\n') {
			commands << python_pip_command_value(virtualenv, python_multiline_targets(target.as_string()), std_args)
		} else {
			commands << python_pip_command_value(virtualenv, [target.as_string()], std_args)
		}
	}
	return brew_runtime.array_value(commands)
}

// Ruby method `pip_install_and_link(targets, link_manpages: true, build_isolation: true)` at line 411.
pub fn ruby_python_l411_d20_pip_install_and_link(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return python_error('ArgumentError', 'virtualenv and targets are required')
	}
	virtualenv := args[0]
	link_manpages := if args.len > 2 { args[2].as_bool() or { true } } else { true }
	build_isolation := if args.len > 3 { args[3].as_bool() or { true } } else { true }
	root := python_value_field(virtualenv, 'root')
	bin_root := os.join_path(root, 'bin')
	man_root := os.join_path(root, 'share/man')
	bin_before := if args.len > 4 {
		python_value_strings(args[4])
	} else {
		python_glob_files(bin_root, false)
	}
	man_before := if link_manpages && args.len > 5 {
		python_value_strings(args[5])
	} else if link_manpages {
		python_glob_files(man_root, true)
	} else {
		[]string{}
	}
	install_commands := ruby_python_l383_d19_pip_install(virtualenv, args[1], brew_runtime.bool_value(build_isolation))
	bin_after := if args.len > 6 {
		python_value_strings(args[6])
	} else {
		python_glob_files(bin_root, false)
	}
	man_after := if link_manpages && args.len > 7 {
		python_value_strings(args[7])
	} else if link_manpages {
		python_glob_files(man_root, true)
	} else {
		[]string{}
	}
	formula := virtualenv.map_data['formula'] or { python_nil() }
	destination_bin := python_value_field(formula, 'bin')
	destination_man := python_value_field(formula, 'man')
	mut linked_bin := []string{}
	for path in python_difference(bin_after, bin_before) {
		if destination_bin != '' {
			destination := os.join_path(destination_bin, os.base(path))
			python_install_symlink(path, destination) or { return python_error('IOError', err.msg()) }
			linked_bin << destination
		}
	}
	mut linked_man := []string{}
	if link_manpages {
		for path in python_difference(man_after, man_before) {
			if os.is_dir(path) || destination_man == '' {
				continue
			}
			section := os.base(os.dir(path))
			destination := os.join_path(os.join_path(destination_man, section), os.base(path))
			python_install_symlink(path, destination) or { return python_error('IOError', err.msg()) }
			linked_man << destination
		}
	}
	return python_value_with_map('PythonPipInstallAndLink', root, {
		'commands':   install_commands
		'linked_bin': brew_runtime.string_array_value(linked_bin)
		'linked_man': brew_runtime.string_array_value(linked_man)
	})
}

// Ruby method `do_install(targets, build_isolation: true)` at line 437.
pub fn ruby_python_l437_d21_do_install(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return python_error('ArgumentError', 'virtualenv and targets are required')
	}
	build_isolation := if args.len > 2 { args[2].as_bool() or { true } } else { true }
	std_args := if args.len > 3 {
		python_value_strings(args[3])
	} else {
		python_std_pip_args(build_isolation)
	}
	return python_pip_command_value(args[0], python_value_strings(args[1]), std_args)
}

fn python_error(type_name string, message string) brew_runtime.Value {
	return brew_runtime.object_value(type_name, message)
}

fn python_nil() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', '')
}

fn python_value_with_map(type_name string, representation string,
	values map[string]brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: type_name
		repr: representation
		map_data: values.clone()
	}
}

fn python_homebrew_prefix() string {
	configured := brew_runtime.environment_value('HOMEBREW_PREFIX').trim_right('/')
	return if configured != '' { configured } else { '/opt/homebrew' }
}

fn python_homebrew_cellar() string {
	configured := brew_runtime.environment_value('HOMEBREW_CELLAR').trim_right('/')
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
		result := brew_runtime.run_command(python, ['--version'])
		version = python_major_minor_from_output(result.output) or { '' }
	}
	return 'lib/python${version}/site-packages'
}

fn python_value_strings(value brew_runtime.Value) []string {
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

fn python_value_values(value brew_runtime.Value) []brew_runtime.Value {
	if values := value.as_array() {
		return values
	}
	return []brew_runtime.Value{}
}

fn python_value_map(value brew_runtime.Value) map[string]brew_runtime.Value {
	return value.as_map() or { map[string]brew_runtime.Value{} }
}

fn python_value_field(value brew_runtime.Value, name string) string {
	if nested := value.map_data[name] {
		return nested.as_string()
	}
	if attribute := value.attributes[name] {
		return attribute
	}
	return ''
}

fn python_value_bool_field(value brew_runtime.Value, name string, default_value bool) bool {
	if nested := value.map_data[name] {
		return nested.as_bool() or { nested.as_string() == 'true' }
	}
	if attribute := value.attributes[name] {
		return attribute == 'true'
	}
	return default_value
}

fn python_iteration_value(python string, version string, pythonpath string) brew_runtime.Value {
	return python_value_with_map('PythonIteration', python, {
		'python':     brew_runtime.string_value(python)
		'version':    if version == '' {
			python_nil()
		} else {
			brew_runtime.object_value('Version', version)
		}
		'pythonpath': if pythonpath == '' {
			python_nil()
		} else {
			brew_runtime.string_value(pythonpath)
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

fn python_virtualenv_value(formula brew_runtime.Value, root string,
	python string) brew_runtime.Value {
	return python_value_with_map('Language::Python::Virtualenv::Virtualenv', root, {
		'formula': brew_runtime.Value{
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
		'root':    brew_runtime.string_value(root)
		'python':  brew_runtime.string_value(python)
	})
}

fn python_virtualenv_site_packages(virtualenv brew_runtime.Value) string {
	root := python_value_field(virtualenv, 'root')
	python := python_value_field(virtualenv, 'python')
	version_output := python_value_field(virtualenv, 'python_version_output')
	return os.join_path(root, python_site_packages(python, version_output))
}

fn python_dependency_pruned(dependency brew_runtime.Value, formula brew_runtime.Value,
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

fn python_resource_name(resource brew_runtime.Value) string {
	name := python_value_field(resource, 'name')
	return if name != '' { name } else { resource.repr }
}

fn python_slice_resources(resources map[string]brew_runtime.Value,
	names []string) !(map[string]brew_runtime.Value, []brew_runtime.Value) {
	mut remaining := resources.clone()
	mut selected := []brew_runtime.Value{}
	for name in names {
		if name !in remaining {
			return error('Resource "${name}" is not defined in formula or is already used.')
		}
		selected << remaining[name]
		remaining.delete(name)
	}
	return remaining, selected
}

fn python_order_resources(resources []brew_runtime.Value, without []string, start_with []string,
	end_with []string) ![]brew_runtime.Value {
	mut resources_hash := map[string]brew_runtime.Value{}
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
			brew_runtime.atomic_write_file(cfg_file, rewritten)!
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
			brew_runtime.atomic_write_file(path, rewritten)!
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

fn python_targets(value brew_runtime.Value) []brew_runtime.Value {
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

fn python_pip_command_value(virtualenv brew_runtime.Value, targets []string,
	std_args []string) brew_runtime.Value {
	python := python_value_field(virtualenv, 'python')
	root := python_value_field(virtualenv, 'root')
	mut command := [python, '-m', 'pip', '--python=${os.join_path(root, 'bin/python')}', 'install']
	command << std_args
	command << targets
	return brew_runtime.string_array_value(command)
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

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils"
// 5: require "utils/output"
// 6: require "utils/path"
// 7:
// 8: module Language
// 9:   # Helper functions for Python formulae.
// 10:   #
// 11:   # @api public
// 12:   module Python
// 13:     extend ::Utils::Output::Mixin
// 14:
// 15:     sig { params(python: T.any(String, Pathname)).returns(T.nilable(Version)) }
// 16:     def self.major_minor_version(python)
// 17:       version = `#{python} --version 2>&1`.chomp[/(\d\.\d+)/, 1]
// 18:       return unless version
// 19:
// 20:       Version.new(version)
// 21:     end
// 22:
// 23:     sig { params(python: T.any(String, Pathname)).returns(Pathname) }
// 24:     def self.homebrew_site_packages(python = "python3.7")
// 25:       HOMEBREW_PREFIX/site_packages(python)
// 26:     end
// 27:
// 28:     sig { params(python: T.any(String, Pathname)).returns(String) }
// 29:     def self.site_packages(python = "python3.7")
// 30:       if (python == "pypy") || (python == "pypy3")
// 31:         "site-packages"
// 32:       else
// 33:         "lib/python#{major_minor_version python}/site-packages"
// 34:       end
// 35:     end
// 36:
// 37:     sig {
// 38:       params(
// 39:         build: T.any(BuildOptions, Tab),
// 40:         block: T.nilable(T.proc.params(python: String, version: T.nilable(Version)).void),
// 41:       ).void
// 42:     }
// 43:     def self.each_python(build, &block)
// 44:       original_pythonpath = ENV.fetch("PYTHONPATH", nil)
// 45:       pythons = { "python@3" => "python3",
// 46:                   "pypy"     => "pypy",
// 47:                   "pypy3"    => "pypy3" }
// 48:       pythons.each do |python_formula, python|
// 49:         python_formula = Formulary.factory(python_formula)
// 50:         next if build.without? python_formula.to_s
// 51:
// 52:         version = major_minor_version python
// 53:         ENV["PYTHONPATH"] = if python_formula.latest_version_installed?
// 54:           nil
// 55:         else
// 56:           homebrew_site_packages(python).to_s
// 57:         end
// 58:         block&.call python, version
// 59:       end
// 60:       ENV["PYTHONPATH"] = original_pythonpath
// 61:     end
// 62:
// 63:     sig { params(python: T.any(String, Pathname)).returns(T::Boolean) }
// 64:     def self.reads_brewed_pth_files?(python)
// 65:       return false unless homebrew_site_packages(python).directory?
// 66:       return false unless homebrew_site_packages(python).writable?
// 67:
// 68:       probe_file = homebrew_site_packages(python)/"homebrew-pth-probe.pth"
// 69:       begin
// 70:         probe_file.atomic_write("import site; site.homebrew_was_here = True")
// 71:         with_homebrew_path { quiet_system python, "-c", "import site; assert(site.homebrew_was_here)" }
// 72:       ensure
// 73:         probe_file.unlink if probe_file.exist?
// 74:       end
// 75:     end
// 76:
// 77:     sig { params(python: T.any(String, Pathname)).returns(Pathname) }
// 78:     def self.user_site_packages(python)
// 79:       Pathname.new(`#{python} -c "import site; print(site.getusersitepackages())"`.chomp)
// 80:     end
// 81:
// 82:     sig { params(python: T.any(String, Pathname), path: T.any(String, Pathname)).returns(T::Boolean) }
// 83:     def self.in_sys_path?(python, path)
// 84:       script = <<~PYTHON
// 85:         import os, sys
// 86:         [os.path.realpath(p) for p in sys.path].index(os.path.realpath("#{path}"))
// 87:       PYTHON
// 88:       quiet_system python, "-c", script
// 89:     end
// 90:
// 91:     # Mixin module for {Formula} adding shebang rewrite features.
// 92:     module Shebang
// 93:       extend T::Helpers
// 94:
// 95:       requires_ancestor { Formula }
// 96:
// 97:       module_function
// 98:
// 99:       # A regex to match potential shebang permutations.
// 100:       PYTHON_SHEBANG_REGEX = %r{\A#! ?(?:/usr/bin/(?:env )?)?python(?:[23](?:\.\d{1,2})?)?( |$)}
// 101:
// 102:       # The length of the longest shebang matching `SHEBANG_REGEX`.
// 103:       PYTHON_SHEBANG_MAX_LENGTH = T.let("#! /usr/bin/env pythonx.yyy ".length, Integer)
// 104:
// 105:       # @private
// 106:       sig { params(python_path: T.any(String, Pathname)).returns(Utils::Shebang::RewriteInfo) }
// 107:       def python_shebang_rewrite_info(python_path)
// 108:         Utils::Shebang::RewriteInfo.new(
// 109:           PYTHON_SHEBANG_REGEX,
// 110:           PYTHON_SHEBANG_MAX_LENGTH,
// 111:           "#{python_path}\\1",
// 112:         )
// 113:       end
// 114:
// 115:       sig { params(formula: Formula, use_python_from_path: T::Boolean).returns(Utils::Shebang::RewriteInfo) }
// 116:       def detected_python_shebang(formula = T.cast(self, Formula), use_python_from_path: false)
// 117:         python_path = if use_python_from_path
// 118:           "/usr/bin/env python3"
// 119:         else
// 120:           python_deps = formula.deps.select(&:required?).map(&:name).grep(/^python(@.+)?$/)
// 121:           raise ShebangDetectionError.new("Python", "formula does not depend on Python") if python_deps.empty?
// 122:           if python_deps.length > 1
// 123:             raise ShebangDetectionError.new("Python", "formula has multiple Python dependencies")
// 124:           end
// 125:
// 126:           python_dep = python_deps.first
// 127:           Utils::Path.formula_opt_bin(python_dep)/python_dep.sub("@", "")
// 128:         end
// 129:
// 130:         python_shebang_rewrite_info(python_path)
// 131:       end
// 132:     end
// 133:
// 134:     # Mixin module for {Formula} adding virtualenv support features.
// 135:     module Virtualenv
// 136:       extend T::Helpers
// 137:
// 138:       requires_ancestor { Formula }
// 139:
// 140:       # Instantiates, creates and yields a {Virtualenv} object for use from
// 141:       # {Formula#install}, which provides helper methods for instantiating and
// 142:       # installing packages into a Python virtualenv.
// 143:       #
// 144:       # @param venv_root [Pathname, String] the path to the root of the virtualenv
// 145:       #   (often `libexec/"venv"`)
// 146:       # @param python [String, Pathname] which interpreter to use (e.g. `"python3"`
// 147:       #   or `"python3.x"`)
// 148:       # @param formula [Formula] the active {Formula}
// 149:       # @return [Virtualenv] a {Virtualenv} instance
// 150:       sig {
// 151:         params(
// 152:           venv_root:            T.any(String, Pathname),
// 153:           python:               T.any(String, Pathname),
// 154:           formula:              Formula,
// 155:           system_site_packages: T::Boolean,
// 156:           without_pip:          T::Boolean,
// 157:         ).returns(Virtualenv)
// 158:       }
// 159:       def virtualenv_create(venv_root, python = "python", formula = T.cast(self, Formula),
// 160:                             system_site_packages: true, without_pip: true)
// 161:         # Limit deprecation to 3.12+ for now (or if we can't determine the version).
// 162:         # Some used this argument for `setuptools`, which we no longer bundle since 3.12.
// 163:         unless without_pip
// 164:           python_version = Language::Python.major_minor_version(python)
// 165:           if python_version.nil? || python_version.null? || python_version >= "3.12"
// 166:             raise ArgumentError, "virtualenv_create's without_pip is deprecated starting with Python 3.12"
// 167:           end
// 168:         end
// 169:
// 170:         ENV.refurbish_args
// 171:         venv = Virtualenv.new formula, venv_root, python
// 172:         venv.create(system_site_packages:, without_pip:)
// 173:
// 174:         # Find any Python bindings provided by recursive dependencies
// 175:         pth_contents = []
// 176:         formula.recursive_dependencies do |dependent, dep|
// 177:           next Dependable::PRUNE if dep.build? || dep.test?
// 178:           # Apply default filter
// 179:           next Dependable::PRUNE if (dep.optional? || dep.recommended?) && !T.cast(dependent,
// 180:                                                                                    Formula).build.with?(dep)
// 181:           # Do not add the main site-package provided by the brewed
// 182:           # Python formula, to keep the virtual-env's site-package pristine
// 183:           next Dependable::PRUNE if python_names.include? dep.name
// 184:           # Skip uses_from_macos dependencies as these imply no Python bindings
// 185:           next Dependable::PRUNE if dep.uses_from_macos?
// 186:
// 187:           dep_site_packages = dep.to_formula.opt_prefix/Language::Python.site_packages(python)
// 188:           next Dependable::PRUNE unless dep_site_packages.exist?
// 189:
// 190:           pth_contents << "import site; site.addsitedir('#{dep_site_packages}')\n"
// 191:           nil # Return nil to satisfy T.nilable(Symbol) block sig (Array from << would violate it).
// 192:         end
// 193:         (venv.site_packages/"homebrew_deps.pth").write pth_contents.join unless pth_contents.empty?
// 194:
// 195:         venv
// 196:       end
// 197:
// 198:       # Returns true if a formula option for the specified python is currently
// 199:       # active or if the specified python is required by the formula. Valid
// 200:       # inputs are `"python"`, `"python2"` and `:python3`. Note that
// 201:       # `"with-python"`, `"without-python"`, `"with-python@2"` and `"without-python@2"`
// 202:       # formula options are handled correctly even if not associated with any
// 203:       # corresponding depends_on statement.
// 204:       sig { params(python: String).returns(T::Boolean) }
// 205:       def needs_python?(python)
// 206:         return true if build.with?(python)
// 207:
// 208:         (requirements.to_a | deps).any? { |r| Utils.name_from_full_name(r.name) == python && r.required? }
// 209:       end
// 210:
// 211:       # Helper method for the common case of installing a Python application.
// 212:       # Creates a virtualenv in `libexec`, installs all `resource`s defined
// 213:       # on the formula and then installs the formula. An options hash may be
// 214:       # passed (e.g. `:using => "python"`) to override the default, guessed
// 215:       # formula preference for python or python@x.y, or to resolve an ambiguous
// 216:       # case where it's not clear whether python or python@x.y should be the
// 217:       # default guess.
// 218:       sig {
// 219:         params(
// 220:           using:                T.nilable(String),
// 221:           system_site_packages: T::Boolean,
// 222:           without_pip:          T::Boolean,
// 223:           link_manpages:        T::Boolean,
// 224:           without:              T.nilable(T.any(String, T::Array[String])),
// 225:           start_with:           T.nilable(T.any(String, T::Array[String])),
// 226:           end_with:             T.nilable(T.any(String, T::Array[String])),
// 227:         ).returns(Virtualenv)
// 228:       }
// 229:       def virtualenv_install_with_resources(using: nil, system_site_packages: true, without_pip: true,
// 230:                                             link_manpages: true, without: nil, start_with: nil, end_with: nil)
// 231:         python = using
// 232:         if python.nil?
// 233:           wanted = python_names.select { |py| needs_python?(py) }
// 234:           raise FormulaUnknownPythonError, self if wanted.empty?
// 235:           raise FormulaAmbiguousPythonError, self if wanted.size > 1
// 236:
// 237:           python = wanted.fetch(0)
// 238:           python = "python3" if python == "python"
// 239:         end
// 240:
// 241:         venv_resources = if without.nil? && start_with.nil? && end_with.nil?
// 242:           resources
// 243:         else
// 244:           remaining_resources = resources.to_h { |resource| [resource.name, resource] }
// 245:
// 246:           slice_resources!(remaining_resources, Array(without))
// 247:           start_with_resources = slice_resources!(remaining_resources, Array(start_with))
// 248:           end_with_resources = slice_resources!(remaining_resources, Array(end_with))
// 249:
// 250:           start_with_resources + remaining_resources.values + end_with_resources
// 251:         end
// 252:
// 253:         venv = virtualenv_create(libexec, python.delete("@"), system_site_packages:,
// 254:                                                               without_pip:)
// 255:         venv.pip_install venv_resources
// 256:         venv.pip_install_and_link(T.must(buildpath), link_manpages:)
// 257:         venv
// 258:       end
// 259:
// 260:       sig { returns(T::Array[String]) }
// 261:       def python_names
// 262:         %w[python python3 pypy pypy3] + Formula.names.select { |name| name.start_with? "python@" }
// 263:       end
// 264:
// 265:       private
// 266:
// 267:       sig {
// 268:         params(
// 269:           resources_hash: T::Hash[String, Resource],
// 270:           resource_names: T::Array[String],
// 271:         ).returns(T::Array[Resource])
// 272:       }
// 273:       def slice_resources!(resources_hash, resource_names)
// 274:         resource_names.map do |resource_name|
// 275:           resources_hash.delete(resource_name) do
// 276:             raise ArgumentError, "Resource \"#{resource_name}\" is not defined in formula or is already used."
// 277:           end
// 278:         end
// 279:       end
// 280:
// 281:       # Convenience wrapper for creating and installing packages into Python
// 282:       # virtualenvs.
// 283:       class Virtualenv
// 284:         # Initializes a Virtualenv instance. This does not create the virtualenv
// 285:         # on disk; {#create} does that.
// 286:         #
// 287:         # @param formula [Formula] the active {Formula}
// 288:         # @param venv_root [Pathname, String] the path to the root of the
// 289:         #   virtualenv
// 290:         # @param python [String, Pathname] which interpreter to use, e.g.
// 291:         #   "python" or "python2"
// 292:         sig { params(formula: Formula, venv_root: T.any(String, Pathname), python: T.any(String, Pathname)).void }
// 293:         def initialize(formula, venv_root, python)
// 294:           @formula = formula
// 295:           @venv_root = T.let(Pathname(venv_root), Pathname)
// 296:           @python = python
// 297:         end
// 298:
// 299:         sig { returns(Pathname) }
// 300:         def root
// 301:           @venv_root
// 302:         end
// 303:
// 304:         sig { returns(Pathname) }
// 305:         def site_packages
// 306:           @venv_root/Language::Python.site_packages(@python)
// 307:         end
// 308:
// 309:         # Obtains a copy of the virtualenv library and creates a new virtualenv on disk.
// 310:         #
// 311:         # @return [void]
// 312:         sig { params(system_site_packages: T::Boolean, without_pip: T::Boolean).void }
// 313:         def create(system_site_packages: true, without_pip: true)
// 314:           return if (@venv_root/"bin/python").exist?
// 315:
// 316:           args = ["-m", "venv"]
// 317:           args << "--system-site-packages" if system_site_packages
// 318:           args << "--without-pip" if without_pip
// 319:           @formula.system @python, *args, @venv_root
// 320:
// 321:           # Robustify symlinks to survive python patch upgrades
// 322:           @venv_root.find do |f|
// 323:             next unless f.symlink?
// 324:             next unless f.readlink.expand_path.to_s.start_with? HOMEBREW_CELLAR
// 325:
// 326:             rp = f.realpath.to_s
// 327:             version = rp.match %r{^#{HOMEBREW_CELLAR}/python@(.*?)/}o
// 328:             version = "@#{version.captures.first}" unless version.nil?
// 329:
// 330:             new_target = rp.sub(
// 331:               %r{#{HOMEBREW_CELLAR}/python#{version}/[^/]+},
// 332:               Utils::Path.formula_opt_prefix("python#{version}").to_s,
// 333:             )
// 334:             f.unlink
// 335:             f.make_symlink new_target
// 336:           end
// 337:
// 338:           Pathname.glob(@venv_root/"lib/python*/orig-prefix.txt").each do |prefix_file|
// 339:             prefix_path = prefix_file.read
// 340:
// 341:             version = prefix_path.match %r{^#{HOMEBREW_CELLAR}/python@(.*?)/}o
// 342:             version = "@#{version.captures.first}" unless version.nil?
// 343:
// 344:             prefix_path.sub!(
// 345:               %r{^#{HOMEBREW_CELLAR}/python#{version}/[^/]+},
// 346:               Utils::Path.formula_opt_prefix("python#{version}").to_s,
// 347:             )
// 348:             prefix_file.atomic_write prefix_path
// 349:           end
// 350:
// 351:           # Reduce some differences between macOS and Linux venv
// 352:           lib64 = @venv_root/"lib64"
// 353:           lib64.make_symlink "lib" unless lib64.exist?
// 354:           if (cfg_file = @venv_root/"pyvenv.cfg").exist?
// 355:             cfg = cfg_file.read
// 356:             framework = "Frameworks/Python.framework/Versions"
// 357:             cfg.match(%r{= *(#{HOMEBREW_CELLAR}/(python@[\d.]+)/[^/]+(?:/#{framework}/[\d.]+)?/bin)}) do |match|
// 358:               cfg.sub! match[1].to_s, Utils::Path.formula_opt_bin(T.must(match[2])).to_s
// 359:               cfg_file.atomic_write cfg
// 360:             end
// 361:           end
// 362:
// 363:           # Remove unnecessary activate scripts
// 364:           (@venv_root/"bin").glob("[Aa]ctivate*").map(&:unlink)
// 365:         end
// 366:
// 367:         # Installs packages represented by `targets` into the virtualenv.
// 368:         #
// 369:         # @param targets [String, Pathname, Resource,
// 370:         #   Array<String, Pathname, Resource>] (A) token(s) passed to `pip`
// 371:         #   representing the object to be installed. This can be a directory
// 372:         #   containing a setup.py, a {Resource} which will be staged and
// 373:         #   installed, or a package identifier to be fetched from PyPI.
// 374:         #   Multiline strings are allowed and treated as though they represent
// 375:         #   the contents of a `requirements.txt`.
// 376:         # @return [void]
// 377:         sig {
// 378:           params(
// 379:             targets:         T.any(String, Pathname, Resource, T::Array[T.any(String, Pathname, Resource)]),
// 380:             build_isolation: T::Boolean,
// 381:           ).void
// 382:         }
// 383:         def pip_install(targets, build_isolation: true)
// 384:           targets = Array(targets)
// 385:           targets.each do |t|
// 386:             if t.is_a?(Resource)
// 387:               t.stage do
// 388:                 target = Pathname.pwd
// 389:                 target /= t.downloader.basename if t.url&.match?("[.-]py3[^-]*-none-any.whl$")
// 390:                 do_install(target, build_isolation:)
// 391:               end
// 392:             else
// 393:               t = t.lines.map(&:strip) if t.is_a?(String) && t.include?("\n")
// 394:               do_install(t, build_isolation:)
// 395:             end
// 396:           end
// 397:         end
// 398:
// 399:         # Installs packages represented by `targets` into the virtualenv, but
// 400:         # unlike {#pip_install} also links new scripts to {Formula#bin}.
// 401:         #
// 402:         # @param (see #pip_install)
// 403:         # @return (see #pip_install)
// 404:         sig {
// 405:           params(
// 406:             targets:         T.any(String, Pathname, Resource, T::Array[T.any(String, Pathname, Resource)]),
// 407:             link_manpages:   T::Boolean,
// 408:             build_isolation: T::Boolean,
// 409:           ).void
// 410:         }
// 411:         def pip_install_and_link(targets, link_manpages: true, build_isolation: true)
// 412:           bin_before = Dir[@venv_root/"bin/*"].to_set
// 413:           man_before = Dir[@venv_root/"share/man/man*/*"].to_set if link_manpages
// 414:
// 415:           pip_install(targets, build_isolation:)
// 416:
// 417:           bin_after = Dir[@venv_root/"bin/*"].to_set
// 418:           bin_to_link = (bin_after - bin_before).to_a
// 419:           @formula.bin.install_symlink(bin_to_link)
// 420:           return unless link_manpages
// 421:
// 422:           man_after = Dir[@venv_root/"share/man/man*/*"].to_set
// 423:           man_to_link = (man_after - man_before).to_a
// 424:           man_to_link.each do |manpage|
// 425:             (@formula.man/Pathname.new(manpage).dirname.basename).install_symlink manpage
// 426:           end
// 427:         end
// 428:
// 429:         private
// 430:
// 431:         sig {
// 432:           params(
// 433:             targets:         T.any(String, Pathname, T::Array[T.any(String, Pathname)]),
// 434:             build_isolation: T::Boolean,
// 435:           ).void
// 436:         }
// 437:         def do_install(targets, build_isolation: true)
// 438:           targets = Array(targets)
// 439:           args = @formula.std_pip_args(prefix: false, build_isolation:)
// 440:           @formula.system @python, "-m", "pip", "--python=#{@venv_root}/bin/python", "install", *args, *targets
// 441:         end
// 442:       end
// 443:     end
// 444:   end
// 445: end
