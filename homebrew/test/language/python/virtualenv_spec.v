module python

import ruby
import homebrew.language
import os
import time

// Translated from Homebrew/brew `test/language/python/virtualenv_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:venv) { instance_double(Language::Python::Virtualenv::Virtualenv) }` at line 9.
pub fn ruby_virtualenv_spec_l9_d1_venv(args ...ruby.Value) ruby.Value {
	root := virtualenv_spec_root(args, 'venv')
	return virtualenv_spec_virtualenv(virtualenv_spec_formula(root), root, 'python')
}

// Ruby let `let(:f) do` at line 10.
pub fn ruby_virtualenv_spec_l10_d2_f(args ...ruby.Value) ruby.Value {
	return virtualenv_spec_formula(virtualenv_spec_root(args, 'formula'))
}

// Ruby let `let(:r_a) { f.resource("resource-a") }` at line 40.
pub fn ruby_virtualenv_spec_l40_d3_r_a(args ...ruby.Value) ruby.Value {
	return virtualenv_spec_resource_from_args(args, 'resource-a')
}

// Ruby let `let(:r_b) { f.resource("resource-b") }` at line 41.
pub fn ruby_virtualenv_spec_l41_d4_r_b(args ...ruby.Value) ruby.Value {
	return virtualenv_spec_resource_from_args(args, 'resource-b')
}

// Ruby let `let(:r_c) { f.resource("resource-c") }` at line 42.
pub fn ruby_virtualenv_spec_l42_d5_r_c(args ...ruby.Value) ruby.Value {
	return virtualenv_spec_resource_from_args(args, 'resource-c')
}

// Ruby let `let(:r_d) { f.resource("resource-d") }` at line 43.
pub fn ruby_virtualenv_spec_l43_d6_r_d(args ...ruby.Value) ruby.Value {
	return virtualenv_spec_resource_from_args(args, 'resource-d')
}

// Ruby let `let(:buildpath) { Pathname(TEST_TMPDIR) }` at line 44.
pub fn ruby_virtualenv_spec_l44_d7_buildpath(args ...ruby.Value) ruby.Value {
	return ruby.string_value(virtualenv_spec_root(args, 'buildpath'))
}

// Ruby it `it "works with `using: \"python\"` and installs resources in order" do` at line 48.
pub fn ruby_virtualenv_spec_l48_d8_works(args ...ruby.Value) ruby.Value {
	return virtualenv_spec_install_expect(args, 'python', [], [], [], ['resource-a', 'resource-b',
		'resource-c', 'resource-d'])
}

// Ruby it `it "works with `using: \"python@3.12\"` and installs resources in order" do` at line 57.
pub fn ruby_virtualenv_spec_l57_d9_works(args ...ruby.Value) ruby.Value {
	return virtualenv_spec_install_expect(args, 'python@3.12', [], [], [], [
		'resource-a',
		'resource-b',
		'resource-c',
		'resource-d',
	])
}

// Ruby it `it "skips a `without` resource string and installs remaining resources in order" do` at line 66.
pub fn ruby_virtualenv_spec_l66_d10_skips(args ...ruby.Value) ruby.Value {
	return virtualenv_spec_install_expect(args, 'python', ['resource-c'], [], [], [
		'resource-a',
		'resource-b',
		'resource-d',
	])
}

// Ruby it `it "skips all resources in `without` array and installs remaining resources in order" do` at line 73.
pub fn ruby_virtualenv_spec_l73_d11_skips(args ...ruby.Value) ruby.Value {
	return virtualenv_spec_install_expect(args, 'python', ['resource-d', 'resource-a'], [], [], [
		'resource-b',
		'resource-c',
	])
}

// Ruby it `it "errors if `without` resource string does not exist in formula" do` at line 80.
pub fn ruby_virtualenv_spec_l80_d12_errors(args ...ruby.Value) ruby.Value {
	return virtualenv_spec_install_errors(args, ['unknown'], [], [])
}

// Ruby it `it "errors if `without` resource array refers to a resource that does not exist in formula" do` at line 86.
pub fn ruby_virtualenv_spec_l86_d13_errors(args ...ruby.Value) ruby.Value {
	return virtualenv_spec_install_errors(args, ['resource-a', 'unknown'], [], [])
}

// Ruby it `it "installs a `start_with` resource string and then remaining resources in order" do` at line 92.
pub fn ruby_virtualenv_spec_l92_d14_installs(args ...ruby.Value) ruby.Value {
	return virtualenv_spec_install_expect(args, 'python', [], ['resource-c'], [], [
		'resource-c',
		'resource-a',
		'resource-b',
		'resource-d',
	])
}

// Ruby it `it "installs all resources in `start_with` array and then remaining resources in order" do` at line 99.
pub fn ruby_virtualenv_spec_l99_d15_installs(args ...ruby.Value) ruby.Value {
	return virtualenv_spec_install_expect(args, 'python', [], ['resource-d', 'resource-b'], [], [
		'resource-d',
		'resource-b',
		'resource-a',
		'resource-c',
	])
}

// Ruby it `it "errors if `start_with` resource string does not exist in formula" do` at line 106.
pub fn ruby_virtualenv_spec_l106_d16_errors(args ...ruby.Value) ruby.Value {
	return virtualenv_spec_install_errors(args, [], ['unknown'], [])
}

// Ruby it `it "errors if `start_with` resource array refers to a resource that does not exist in formula" do` at line 112.
pub fn ruby_virtualenv_spec_l112_d17_errors(args ...ruby.Value) ruby.Value {
	return virtualenv_spec_install_errors(args, [], ['resource-a', 'unknown'], [])
}

// Ruby it `it "installs an `end_with` resource string as last resource" do` at line 118.
pub fn ruby_virtualenv_spec_l118_d18_installs(args ...ruby.Value) ruby.Value {
	return virtualenv_spec_install_expect(args, 'python', [], [], ['resource-b'], [
		'resource-a',
		'resource-c',
		'resource-d',
		'resource-b',
	])
}

// Ruby it `it "installs all resources in `end_with` array after other resources are installed" do` at line 125.
pub fn ruby_virtualenv_spec_l125_d19_installs(args ...ruby.Value) ruby.Value {
	return virtualenv_spec_install_expect(args, 'python', [], [], ['resource-c', 'resource-b'], [
		'resource-a',
		'resource-d',
		'resource-c',
		'resource-b',
	])
}

// Ruby it `it "errors if `end_with` resource string does not exist in formula" do` at line 132.
pub fn ruby_virtualenv_spec_l132_d20_errors(args ...ruby.Value) ruby.Value {
	return virtualenv_spec_install_errors(args, [], [], ['unknown'])
}

// Ruby it `it "errors if `end_with` resource array refers to a resource that does not exist in formula" do` at line 138.
pub fn ruby_virtualenv_spec_l138_d21_errors(args ...ruby.Value) ruby.Value {
	return virtualenv_spec_install_errors(args, [], [], ['resource-a', 'unknown'])
}

// Ruby it `it "installs resources in correct order when combining `without`, `start_with` and `end_with" do` at line 144.
pub fn ruby_virtualenv_spec_l144_d22_installs(args ...ruby.Value) ruby.Value {
	return virtualenv_spec_install_expect(args, 'python', ['resource-a'], ['resource-d'], [
		'resource-b',
	], ['resource-d', 'resource-c', 'resource-b'])
}

// Ruby subject `subject(:virtualenv) { described_class.new(formula, dir, "python") }` at line 154.
pub fn ruby_virtualenv_spec_l154_d23_virtualenv(args ...ruby.Value) ruby.Value {
	root := virtualenv_spec_root(args, 'virtualenv')
	formula := if args.len > 1 { args[1] } else { virtualenv_spec_formula(root) }
	return virtualenv_spec_virtualenv(formula, root, 'python')
}

// Ruby let `let(:dir) { mktmpdir }` at line 156.
pub fn ruby_virtualenv_spec_l156_d24_dir(args ...ruby.Value) ruby.Value {
	root := virtualenv_spec_root(args, 'dir')
	os.mkdir_all(root) or { return ruby.object_value('IOError', err.msg()) }
	return ruby.string_value(root)
}

// Ruby let `let(:resource) { instance_double(Resource, "resource", stage: true) }` at line 157.
pub fn ruby_virtualenv_spec_l157_d25_resource(args ...ruby.Value) ruby.Value {
	stage_path := if args.len > 0 { args[0].as_string() } else { os.getwd() }
	return virtualenv_spec_resource('resource', '', stage_path)
}

// Ruby let `let(:formula_bin) { dir/"formula_bin" }` at line 158.
pub fn ruby_virtualenv_spec_l158_d26_formula_bin(args ...ruby.Value) ruby.Value {
	return ruby.string_value(os.join_path(virtualenv_spec_root(args, 'dir'), 'formula_bin'))
}

// Ruby let `let(:formula_man) { dir/"formula_man" }` at line 159.
pub fn ruby_virtualenv_spec_l159_d27_formula_man(args ...ruby.Value) ruby.Value {
	return ruby.string_value(os.join_path(virtualenv_spec_root(args, 'dir'), 'formula_man'))
}

// Ruby let `let(:formula) { instance_double(Formula, "formula", resource:, bin: formula_bin, man: formula_man) }` at line 160.
pub fn ruby_virtualenv_spec_l160_d28_formula(args ...ruby.Value) ruby.Value {
	return virtualenv_spec_formula(virtualenv_spec_root(args, 'dir'))
}

// Ruby it `it "creates a venv" do` at line 163.
pub fn ruby_virtualenv_spec_l163_d29_creates(args ...ruby.Value) ruby.Value {
	root := virtualenv_spec_root(args, 'create')
	os.mkdir_all(root) or { return ruby.bool_value(false) }
	defer {
		if args.len == 0 { os.rmdir_all(root) or {} }
	}
	venv := virtualenv_spec_virtualenv(virtualenv_spec_formula(root), root, 'python')
	created := language.ruby_python_l313_d18_create(venv, ruby.bool_value(true), ruby.bool_value(true))
	command := virtualenv_spec_strings(created.map_data['command'] or { ruby.string_array_value([]) })
	return ruby.bool_value(command == ['python', '-m', 'venv', '--system-site-packages',
		'--without-pip', root])
}

// Ruby it `it "creates a venv with pip" do` at line 169.
pub fn ruby_virtualenv_spec_l169_d30_creates(args ...ruby.Value) ruby.Value {
	root := virtualenv_spec_root(args, 'create-pip')
	os.mkdir_all(root) or { return ruby.bool_value(false) }
	defer {
		if args.len == 0 { os.rmdir_all(root) or {} }
	}
	venv := virtualenv_spec_virtualenv(virtualenv_spec_formula(root), root, 'python')
	created := language.ruby_python_l313_d18_create(venv, ruby.bool_value(true), ruby.bool_value(false))
	command := virtualenv_spec_strings(created.map_data['command'] or { ruby.string_array_value([]) })
	return ruby.bool_value(command == ['python', '-m', 'venv', '--system-site-packages',
		root])
}

// Ruby it `it "accepts a string" do` at line 176.
pub fn ruby_virtualenv_spec_l176_d31_accepts(args ...ruby.Value) ruby.Value {
	return virtualenv_spec_pip_expect(args, ruby.string_value('foo'), true, [
		['foo'],
	])
}

// Ruby it `it "accepts a multi-line strings" do` at line 185.
pub fn ruby_virtualenv_spec_l185_d32_accepts(args ...ruby.Value) ruby.Value {
	return virtualenv_spec_pip_expect(args, ruby.string_value('foo\nbar\n'), true, [
		['foo', 'bar'],
	])
}

// Ruby it `it "accepts an array" do` at line 198.
pub fn ruby_virtualenv_spec_l198_d33_accepts(args ...ruby.Value) ruby.Value {
	return virtualenv_spec_pip_expect(args, ruby.string_array_value(['foo', 'bar']), true, [
		['foo'],
		['bar'],
	])
}

// Ruby it `it "accepts a Resource" do` at line 214.
pub fn ruby_virtualenv_spec_l214_d34_accepts(args ...ruby.Value) ruby.Value {
	stage_path := if args.len > 0 { args[0].as_string() } else { os.getwd() }
	return virtualenv_spec_pip_expect(args, virtualenv_spec_resource('test', '', stage_path), true, [
		[stage_path],
	])
}

// Ruby it `it "works without build isolation" do` at line 227.
pub fn ruby_virtualenv_spec_l227_d35_works(args ...ruby.Value) ruby.Value {
	return virtualenv_spec_pip_expect(args, ruby.string_value('foo'), false, [
		['foo'],
	])
}

// Ruby let `let(:src_bin) { dir/"bin" }` at line 238.
pub fn ruby_virtualenv_spec_l238_d36_src_bin(args ...ruby.Value) ruby.Value {
	return ruby.string_value(os.join_path(virtualenv_spec_root(args, 'dir'), 'bin'))
}

// Ruby let `let(:src_man) { dir/"share/man" }` at line 239.
pub fn ruby_virtualenv_spec_l239_d37_src_man(args ...ruby.Value) ruby.Value {
	return ruby.string_value(os.join_path(virtualenv_spec_root(args, 'dir'), 'share/man'))
}

// Ruby let `let(:dest_bin) { formula.bin }` at line 240.
pub fn ruby_virtualenv_spec_l240_d38_dest_bin(args ...ruby.Value) ruby.Value {
	return ruby.string_value(os.join_path(virtualenv_spec_root(args, 'dir'), 'formula_bin'))
}

// Ruby let `let(:dest_man) { formula.man }` at line 241.
pub fn ruby_virtualenv_spec_l241_d39_dest_man(args ...ruby.Value) ruby.Value {
	return ruby.string_value(os.join_path(virtualenv_spec_root(args, 'dir'), 'formula_man'))
}

// Ruby it `it "can link scripts" do` at line 243.
pub fn ruby_virtualenv_spec_l243_d40_can(args ...ruby.Value) ruby.Value {
	root := virtualenv_spec_root(args, 'link-bin')
	defer {
		if args.len == 0 { os.rmdir_all(root) or {} }
	}
	src_bin := os.join_path(root, 'bin')
	dest_bin := os.join_path(root, 'formula_bin')
	os.mkdir_all(src_bin) or { return ruby.bool_value(false) }
	irrelevant := os.join_path(src_bin, 'irrelevant')
	kilroy := os.join_path(src_bin, 'kilroy')
	os.write_file(irrelevant, '') or { return ruby.bool_value(false) }
	os.write_file(kilroy, '') or { return ruby.bool_value(false) }
	formula := virtualenv_spec_formula(root)
	venv := virtualenv_spec_virtualenv(formula, root, 'python')
	result := language.ruby_python_l411_d20_pip_install_and_link(venv, ruby.string_value('foo'), ruby.bool_value(false), ruby.bool_value(true), ruby.string_array_value([
		irrelevant,
	]), ruby.string_array_value([]), ruby.string_array_value([
		irrelevant,
		kilroy,
	]), ruby.string_array_value([]))
	linked := virtualenv_spec_strings(result.map_data['linked_bin'] or { ruby.string_array_value([]) })
	destination := os.join_path(dest_bin, 'kilroy')
	return ruby.bool_value(linked == [destination] && os.is_link(destination) && os.real_path(destination) == os.real_path(kilroy) && !os.exists(os.join_path(dest_bin, 'irrelevant')))
}

// Ruby it `it "can link manpages" do` at line 266.
pub fn ruby_virtualenv_spec_l266_d41_can(args ...ruby.Value) ruby.Value {
	root := virtualenv_spec_root(args, 'link-man')
	defer {
		if args.len == 0 { os.rmdir_all(root) or {} }
	}
	src_man := os.join_path(root, 'share/man')
	man1 := os.join_path(src_man, 'man1')
	man3 := os.join_path(src_man, 'man3')
	man5 := os.join_path(src_man, 'man5')
	for directory in [man1, man3, man5] {
		os.mkdir_all(directory) or { return ruby.bool_value(false) }
	}
	irrelevant1 := os.join_path(man1, 'irrelevant.1')
	irrelevant3 := os.join_path(man3, 'irrelevant.3')
	kilroy1 := os.join_path(man1, 'kilroy.1')
	kilroy5 := os.join_path(man5, 'kilroy.5')
	for path in [irrelevant1, irrelevant3, kilroy1, kilroy5] {
		os.write_file(path, '') or { return ruby.bool_value(false) }
	}
	formula := virtualenv_spec_formula(root)
	venv := virtualenv_spec_virtualenv(formula, root, 'python')
	result := language.ruby_python_l411_d20_pip_install_and_link(venv, ruby.string_value('foo'), ruby.bool_value(true), ruby.bool_value(true), ruby.string_array_value([]), ruby.string_array_value([
		man1,
		irrelevant1,
		man3,
		irrelevant3,
	]), ruby.string_array_value([]), ruby.string_array_value([man1, irrelevant1,
		kilroy1, man3, irrelevant3, man5, kilroy5]))
	linked := virtualenv_spec_strings(result.map_data['linked_man'] or { ruby.string_array_value([]) })
	dest_man := os.join_path(root, 'formula_man')
	dest1 := os.join_path(os.join_path(dest_man, 'man1'), 'kilroy.1')
	dest5 := os.join_path(os.join_path(dest_man, 'man5'), 'kilroy.5')
	return ruby.bool_value(linked == [dest1, dest5] && os.is_link(dest1) && os.is_link(dest5) && os.real_path(dest1) == os.real_path(kilroy1) && !os.exists(os.join_path(os.join_path(dest_man, 'man1'), 'irrelevant.1')) && !os.exists(os.join_path(dest_man, 'man3')))
}

fn virtualenv_spec_value(type_name string, repr string,
	values map[string]ruby.Value) ruby.Value {
	return ruby.Value{
		type_name: type_name
		repr: repr
		map_data: values.clone()
	}
}

fn virtualenv_spec_root(args []ruby.Value, label string) string {
	if args.len > 0 && args[0].type_name == 'String' {
		return args[0].as_string()
	}
	return os.join_path(os.temp_dir(), 'brew-v-python-virtualenv-${label}-${os.getpid()}-${time.now().unix_micro()}')
}

fn virtualenv_spec_resource(name string, url string,
	stage_path string) ruby.Value {
	return virtualenv_spec_value('Resource', name, {
		'name':       ruby.string_value(name)
		'url':        ruby.string_value(url)
		'basename':   ruby.string_value(os.base(url))
		'stage_path': ruby.string_value(stage_path)
	})
}

fn virtualenv_spec_resources(root string) []ruby.Value {
	return [
		virtualenv_spec_resource('resource-a', 'https://brew.sh/resource1.tar.gz', root),
		virtualenv_spec_resource('resource-b', 'https://brew.sh/resource2.tar.gz', root),
		virtualenv_spec_resource('resource-c', 'https://brew.sh/resource3.tar.gz', root),
		virtualenv_spec_resource('resource-d', 'https://brew.sh/resource4.tar.gz', root),
	]
}

fn virtualenv_spec_formula(root string) ruby.Value {
	return virtualenv_spec_value('Formula', 'foo', {
		'name':          ruby.string_value('foo')
		'libexec':       ruby.string_value(os.join_path(root, 'libexec'))
		'buildpath':     ruby.string_value(root)
		'bin':           ruby.string_value(os.join_path(root, 'formula_bin'))
		'man':           ruby.string_value(os.join_path(root, 'formula_man'))
		'resources':     ruby.array_value(virtualenv_spec_resources(root))
		'formula_names': ruby.string_array_value(['python@3.12'])
	})
}

fn virtualenv_spec_resource_from_args(args []ruby.Value,
	name string) ruby.Value {
	formula := if args.len > 0 && args[0].type_name == 'Formula' {
		args[0]
	} else {
		virtualenv_spec_formula(virtualenv_spec_root(args, 'formula'))
	}
	resources := formula.map_data['resources'] or { return ruby.object_value('KeyError', name) }
	for resource in resources.as_array() or { []ruby.Value{} } {
		if resource.repr == name {
			return resource
		}
	}
	return ruby.object_value('KeyError', name)
}

fn virtualenv_spec_virtualenv(formula ruby.Value, root string,
	python string) ruby.Value {
	return language.ruby_python_l293_d15_initialize(formula, ruby.string_value(root), ruby.string_value(python))
}

fn virtualenv_spec_strings(value ruby.Value) []string {
	if strings := value.as_string_array() {
		if strings.len > 0 {
			return strings
		}
	}
	return (value.as_array() or { []ruby.Value{} }).map(it.as_string())
}

fn virtualenv_spec_resource_names(result ruby.Value) []string {
	resources := result.map_data['resources'] or { return []string{} }
	return (resources.as_array() or { []ruby.Value{} }).map(it.repr)
}

fn virtualenv_spec_install_expect(args []ruby.Value, using string, without []string,
	start_with []string, end_with []string, expected []string) ruby.Value {
	root := virtualenv_spec_root(args, 'install')
	formula := virtualenv_spec_formula(root)
	result := language.ruby_python_l229_d12_virtualenv_install_with_resources(formula, ruby.string_value(using), ruby.string_array_value(without), ruby.string_array_value(start_with), ruby.string_array_value(end_with), ruby.bool_value(true), ruby.bool_value(true), ruby.bool_value(true))
	python := if using == 'python@3.12' { 'python3.12' } else { using }
	return ruby.bool_value(result.type_name == 'Language::Python::Virtualenv::Virtualenv' && result.map_data['python'].as_string() == python && virtualenv_spec_resource_names(result) == expected)
}

fn virtualenv_spec_install_errors(args []ruby.Value, without []string,
	start_with []string, end_with []string) ruby.Value {
	root := virtualenv_spec_root(args, 'errors')
	result := language.ruby_python_l229_d12_virtualenv_install_with_resources(virtualenv_spec_formula(root), ruby.string_value('python'), ruby.string_array_value(without), ruby.string_array_value(start_with), ruby.string_array_value(end_with))
	return ruby.bool_value(result.type_name == 'ArgumentError' && result.repr.contains('is not defined in formula or is already used'))
}

fn virtualenv_spec_pip_expect(args []ruby.Value, targets ruby.Value,
	build_isolation bool, expected_targets [][]string) ruby.Value {
	root := virtualenv_spec_root(args, 'pip')
	venv := virtualenv_spec_virtualenv(virtualenv_spec_formula(root), root, 'python')
	commands_value := language.ruby_python_l383_d19_pip_install(venv, targets, ruby.bool_value(build_isolation), ruby.string_array_value([
		'--std-pip-args',
	]))
	commands := commands_value.as_array() or { return ruby.bool_value(false) }
	if commands.len != expected_targets.len {
		return ruby.bool_value(false)
	}
	for index, command_value in commands {
		command := virtualenv_spec_strings(command_value)
		mut expected := ['python', '-m', 'pip', '--python=${os.join_path(root, 'bin/python')}',
			'install', '--std-pip-args']
		expected << expected_targets[index]
		if command != expected {
			return ruby.bool_value(false)
		}
	}
	return ruby.bool_value(true)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "language/python"
// 5: require "resource"
// 6:
// 7: RSpec.describe Language::Python::Virtualenv, :needs_python do
// 8:   describe "#virtualenv_install_with_resources" do
// 9:     let(:venv) { instance_double(Language::Python::Virtualenv::Virtualenv) }
// 10:     let(:f) do
// 11:       virtualenv_module = described_class
// 12:       formula "foo" do
// 13:         T.bind(self, T.class_of(Formula))
// 14:         include virtualenv_module
// 15:
// 16:         T.bind(self, T.class_of(Formula))
// 17:         url "https://brew.sh/foo-1.0.tgz"
// 18:
// 19:         resource "resource-a" do
// 20:           url "https://brew.sh/resource1.tar.gz"
// 21:           sha256 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
// 22:         end
// 23:
// 24:         resource "resource-b" do
// 25:           url "https://brew.sh/resource2.tar.gz"
// 26:           sha256 "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
// 27:         end
// 28:
// 29:         resource "resource-c" do
// 30:           url "https://brew.sh/resource3.tar.gz"
// 31:           sha256 "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"
// 32:         end
// 33:
// 34:         resource "resource-d" do
// 35:           url "https://brew.sh/resource4.tar.gz"
// 36:           sha256 "dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd"
// 37:         end
// 38:       end
// 39:     end
// 40:     let(:r_a) { f.resource("resource-a") }
// 41:     let(:r_b) { f.resource("resource-b") }
// 42:     let(:r_c) { f.resource("resource-c") }
// 43:     let(:r_d) { f.resource("resource-d") }
// 44:     let(:buildpath) { Pathname(TEST_TMPDIR) }
// 45:
// 46:     before { f.buildpath = buildpath }
// 47:
// 48:     it "works with `using: \"python\"` and installs resources in order" do
// 49:       expect(f).to receive(:virtualenv_create).with(
// 50:         f.libexec, "python", { system_site_packages: true, without_pip: true }
// 51:       ).and_return(venv)
// 52:       expect(venv).to receive(:pip_install).with([r_a, r_b, r_c, r_d])
// 53:       expect(venv).to receive(:pip_install_and_link).with(buildpath, { link_manpages: true })
// 54:       f.virtualenv_install_with_resources(using: "python")
// 55:     end
// 56:
// 57:     it "works with `using: \"python@3.12\"` and installs resources in order" do
// 58:       expect(f).to receive(:virtualenv_create).with(
// 59:         f.libexec, "python3.12", { system_site_packages: true, without_pip: true }
// 60:       ).and_return(venv)
// 61:       expect(venv).to receive(:pip_install).with([r_a, r_b, r_c, r_d])
// 62:       expect(venv).to receive(:pip_install_and_link).with(buildpath, { link_manpages: true })
// 63:       f.virtualenv_install_with_resources(using: "python@3.12")
// 64:     end
// 65:
// 66:     it "skips a `without` resource string and installs remaining resources in order" do
// 67:       expect(f).to receive(:virtualenv_create).and_return(venv)
// 68:       expect(venv).to receive(:pip_install).with([r_a, r_b, r_d])
// 69:       expect(venv).to receive(:pip_install_and_link).with(buildpath, { link_manpages: true })
// 70:       f.virtualenv_install_with_resources(using: "python", without: r_c.name)
// 71:     end
// 72:
// 73:     it "skips all resources in `without` array and installs remaining resources in order" do
// 74:       expect(f).to receive(:virtualenv_create).and_return(venv)
// 75:       expect(venv).to receive(:pip_install).with([r_b, r_c])
// 76:       expect(venv).to receive(:pip_install_and_link).with(buildpath, { link_manpages: true })
// 77:       f.virtualenv_install_with_resources(using: "python", without: [r_d.name, r_a.name])
// 78:     end
// 79:
// 80:     it "errors if `without` resource string does not exist in formula" do
// 81:       expect do
// 82:         f.virtualenv_install_with_resources(using: "python", without: "unknown")
// 83:       end.to raise_error(ArgumentError)
// 84:     end
// 85:
// 86:     it "errors if `without` resource array refers to a resource that does not exist in formula" do
// 87:       expect do
// 88:         f.virtualenv_install_with_resources(using: "python", without: [r_a.name, "unknown"])
// 89:       end.to raise_error(ArgumentError)
// 90:     end
// 91:
// 92:     it "installs a `start_with` resource string and then remaining resources in order" do
// 93:       expect(f).to receive(:virtualenv_create).and_return(venv)
// 94:       expect(venv).to receive(:pip_install).with([r_c, r_a, r_b, r_d])
// 95:       expect(venv).to receive(:pip_install_and_link).with(buildpath, { link_manpages: true })
// 96:       f.virtualenv_install_with_resources(using: "python", start_with: r_c.name)
// 97:     end
// 98:
// 99:     it "installs all resources in `start_with` array and then remaining resources in order" do
// 100:       expect(f).to receive(:virtualenv_create).and_return(venv)
// 101:       expect(venv).to receive(:pip_install).with([r_d, r_b, r_a, r_c])
// 102:       expect(venv).to receive(:pip_install_and_link).with(buildpath, { link_manpages: true })
// 103:       f.virtualenv_install_with_resources(using: "python", start_with: [r_d.name, r_b.name])
// 104:     end
// 105:
// 106:     it "errors if `start_with` resource string does not exist in formula" do
// 107:       expect do
// 108:         f.virtualenv_install_with_resources(using: "python", start_with: "unknown")
// 109:       end.to raise_error(ArgumentError)
// 110:     end
// 111:
// 112:     it "errors if `start_with` resource array refers to a resource that does not exist in formula" do
// 113:       expect do
// 114:         f.virtualenv_install_with_resources(using: "python", start_with: [r_a.name, "unknown"])
// 115:       end.to raise_error(ArgumentError)
// 116:     end
// 117:
// 118:     it "installs an `end_with` resource string as last resource" do
// 119:       expect(f).to receive(:virtualenv_create).and_return(venv)
// 120:       expect(venv).to receive(:pip_install).with([r_a, r_c, r_d, r_b])
// 121:       expect(venv).to receive(:pip_install_and_link).with(buildpath, { link_manpages: true })
// 122:       f.virtualenv_install_with_resources(using: "python", end_with: r_b.name)
// 123:     end
// 124:
// 125:     it "installs all resources in `end_with` array after other resources are installed" do
// 126:       expect(f).to receive(:virtualenv_create).and_return(venv)
// 127:       expect(venv).to receive(:pip_install).with([r_a, r_d, r_c, r_b])
// 128:       expect(venv).to receive(:pip_install_and_link).with(buildpath, { link_manpages: true })
// 129:       f.virtualenv_install_with_resources(using: "python", end_with: [r_c.name, r_b.name])
// 130:     end
// 131:
// 132:     it "errors if `end_with` resource string does not exist in formula" do
// 133:       expect do
// 134:         f.virtualenv_install_with_resources(using: "python", end_with: "unknown")
// 135:       end.to raise_error(ArgumentError)
// 136:     end
// 137:
// 138:     it "errors if `end_with` resource array refers to a resource that does not exist in formula" do
// 139:       expect do
// 140:         f.virtualenv_install_with_resources(using: "python", end_with: [r_a.name, "unknown"])
// 141:       end.to raise_error(ArgumentError)
// 142:     end
// 143:
// 144:     it "installs resources in correct order when combining `without`, `start_with` and `end_with" do
// 145:       expect(f).to receive(:virtualenv_create).and_return(venv)
// 146:       expect(venv).to receive(:pip_install).with([r_d, r_c, r_b])
// 147:       expect(venv).to receive(:pip_install_and_link).with(buildpath, { link_manpages: true })
// 148:       f.virtualenv_install_with_resources(using: "python", without: r_a.name,
// 149:                                           start_with: r_d.name, end_with: r_b.name)
// 150:     end
// 151:   end
// 152:
// 153:   describe Language::Python::Virtualenv::Virtualenv do
// 154:     subject(:virtualenv) { described_class.new(formula, dir, "python") }
// 155:
// 156:     let(:dir) { mktmpdir }
// 157:     let(:resource) { instance_double(Resource, "resource", stage: true) }
// 158:     let(:formula_bin) { dir/"formula_bin" }
// 159:     let(:formula_man) { dir/"formula_man" }
// 160:     let(:formula) { instance_double(Formula, "formula", resource:, bin: formula_bin, man: formula_man) }
// 161:
// 162:     describe "#create" do
// 163:       it "creates a venv" do
// 164:         expect(formula).to receive(:system)
// 165:           .with("python", "-m", "venv", "--system-site-packages", "--without-pip", dir)
// 166:         virtualenv.create
// 167:       end
// 168:
// 169:       it "creates a venv with pip" do
// 170:         expect(formula).to receive(:system).with("python", "-m", "venv", "--system-site-packages", dir)
// 171:         virtualenv.create(without_pip: false)
// 172:       end
// 173:     end
// 174:
// 175:     describe "#pip_install" do
// 176:       it "accepts a string" do
// 177:         expect(formula).to receive(:std_pip_args).with(prefix:          false,
// 178:                                                        build_isolation: true).and_return(["--std-pip-args"])
// 179:         expect(formula).to receive(:system)
// 180:           .with("python", "-m", "pip", "--python=#{dir}/bin/python", "install", "--std-pip-args", "foo")
// 181:           .and_return(true)
// 182:         virtualenv.pip_install "foo"
// 183:       end
// 184:
// 185:       it "accepts a multi-line strings" do
// 186:         expect(formula).to receive(:std_pip_args).with(prefix:          false,
// 187:                                                        build_isolation: true).and_return(["--std-pip-args"])
// 188:         expect(formula).to receive(:system)
// 189:           .with("python", "-m", "pip", "--python=#{dir}/bin/python", "install", "--std-pip-args", "foo", "bar")
// 190:           .and_return(true)
// 191:
// 192:         virtualenv.pip_install <<~EOS
// 193:           foo
// 194:           bar
// 195:         EOS
// 196:       end
// 197:
// 198:       it "accepts an array" do
// 199:         expect(formula).to receive(:std_pip_args).with(prefix:          false,
// 200:                                                        build_isolation: true).and_return(["--std-pip-args"])
// 201:         expect(formula).to receive(:system)
// 202:           .with("python", "-m", "pip", "--python=#{dir}/bin/python", "install", "--std-pip-args", "foo")
// 203:           .and_return(true)
// 204:
// 205:         expect(formula).to receive(:std_pip_args).with(prefix:          false,
// 206:                                                        build_isolation: true).and_return(["--std-pip-args"])
// 207:         expect(formula).to receive(:system)
// 208:           .with("python", "-m", "pip", "--python=#{dir}/bin/python", "install", "--std-pip-args", "bar")
// 209:           .and_return(true)
// 210:
// 211:         virtualenv.pip_install ["foo", "bar"]
// 212:       end
// 213:
// 214:       it "accepts a Resource" do
// 215:         res = Resource.new("test")
// 216:
// 217:         expect(res).to receive(:stage).and_yield
// 218:         expect(formula).to receive(:std_pip_args).with(prefix:          false,
// 219:                                                        build_isolation: true).and_return(["--std-pip-args"])
// 220:         expect(formula).to receive(:system)
// 221:           .with("python", "-m", "pip", "--python=#{dir}/bin/python", "install", "--std-pip-args", Pathname.pwd)
// 222:           .and_return(true)
// 223:
// 224:         virtualenv.pip_install res
// 225:       end
// 226:
// 227:       it "works without build isolation" do
// 228:         expect(formula).to receive(:std_pip_args).with(prefix:          false,
// 229:                                                        build_isolation: false).and_return(["--std-pip-args"])
// 230:         expect(formula).to receive(:system)
// 231:           .with("python", "-m", "pip", "--python=#{dir}/bin/python", "install", "--std-pip-args", "foo")
// 232:           .and_return(true)
// 233:         virtualenv.pip_install("foo", build_isolation: false)
// 234:       end
// 235:     end
// 236:
// 237:     describe "#pip_install_and_link" do
// 238:       let(:src_bin) { dir/"bin" }
// 239:       let(:src_man) { dir/"share/man" }
// 240:       let(:dest_bin) { formula.bin }
// 241:       let(:dest_man) { formula.man }
// 242:
// 243:       it "can link scripts" do
// 244:         src_bin.mkpath
// 245:
// 246:         expect(src_bin/"kilroy").not_to exist
// 247:         expect(dest_bin/"kilroy").not_to exist
// 248:
// 249:         FileUtils.touch src_bin/"irrelevant"
// 250:         bin_before = Dir.glob(src_bin/"*")
// 251:         FileUtils.touch src_bin/"kilroy"
// 252:         bin_after = Dir.glob(src_bin/"*")
// 253:
// 254:         expect(virtualenv).to receive(:pip_install).with("foo", { build_isolation: true })
// 255:         expect(Dir).to receive(:[]).with(src_bin/"*").twice.and_return(bin_before, bin_after)
// 256:
// 257:         virtualenv.pip_install_and_link("foo", link_manpages: false)
// 258:
// 259:         expect(src_bin/"kilroy").to exist
// 260:         expect(dest_bin/"kilroy").to exist
// 261:         expect(dest_bin/"kilroy").to be_a_symlink
// 262:         expect((src_bin/"kilroy").realpath).to eq((dest_bin/"kilroy").realpath)
// 263:         expect(dest_bin/"irrelevant").not_to exist
// 264:       end
// 265:
// 266:       it "can link manpages" do
// 267:         (src_man/"man1").mkpath
// 268:         (src_man/"man3").mkpath
// 269:
// 270:         expect(src_man/"man1/kilroy.1").not_to exist
// 271:         expect(dest_man/"man1").not_to exist
// 272:         expect(dest_man/"man3").not_to exist
// 273:         expect(dest_man/"man5").not_to exist
// 274:
// 275:         FileUtils.touch src_man/"man1/irrelevant.1"
// 276:         FileUtils.touch src_man/"man3/irrelevant.3"
// 277:         man_before = Dir.glob(src_man/"**/*")
// 278:         (src_man/"man5").mkpath
// 279:         FileUtils.touch src_man/"man1/kilroy.1"
// 280:         FileUtils.touch src_man/"man5/kilroy.5"
// 281:         man_after = Dir.glob(src_man/"**/*")
// 282:
// 283:         expect(virtualenv).to receive(:pip_install).with("foo", { build_isolation: true })
// 284:         expect(Dir).to receive(:[]).with(src_bin/"*").and_return([])
// 285:         expect(Dir).to receive(:[]).with(src_man/"man*/*").and_return(man_before)
// 286:         expect(Dir).to receive(:[]).with(src_bin/"*").and_return([])
// 287:         expect(Dir).to receive(:[]).with(src_man/"man*/*").and_return(man_after)
// 288:
// 289:         virtualenv.pip_install_and_link("foo", link_manpages: true)
// 290:
// 291:         expect(src_man/"man1/kilroy.1").to exist
// 292:         expect(dest_man/"man1/kilroy.1").to exist
// 293:         expect(dest_man/"man5/kilroy.5").to exist
// 294:         expect(dest_man/"man1/kilroy.1").to be_a_symlink
// 295:         expect((src_man/"man1/kilroy.1").realpath).to eq((dest_man/"man1/kilroy.1").realpath)
// 296:         expect(dest_man/"man1/irrelevant.1").not_to exist
// 297:         expect(dest_man/"man3").not_to exist
// 298:       end
// 299:     end
// 300:   end
// 301: end
