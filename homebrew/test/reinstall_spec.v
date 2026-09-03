module test

import brew_runtime
import homebrew.reinstall as reinstall_core
import os
import time

// Translated from Homebrew/brew `test/reinstall_spec.rb`.
// The original source is retained below until every stub has a typed V body.

fn reinstall_spec_root(example string) string {
	return os.join_path(os.temp_dir(), 'brew-v-reinstall-${example}-${os.getpid()}-${time.now().unix_micro()}')
}

fn reinstall_spec_formula(keg_path string, linked bool) reinstall_core.ReinstallFormula {
	return reinstall_core.ReinstallFormula{
		name: 'testball'
		full_name: 'testball'
		prefix: keg_path
		opt_prefix: keg_path
		resolved_opt_prefix: keg_path
		installed_on_request: true
		keg_linked: linked
	}
}

fn reinstall_spec_write(path string, contents string) ! {
	os.mkdir_all(os.dir(path))!
	os.write_file(path, contents)!
}

// Ruby it `it "leaves the current keg in place until reinstalling", :integration_test do` at line 8.
pub fn ruby_reinstall_spec_l8_d1_leaves(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	root := reinstall_spec_root('context')
	defer {
		os.rmdir_all(root) or {}
	}
	keg_path := os.join_path(root, 'Cellar', 'testball', '0.1')
	reinstall_spec_write(os.join_path(keg_path, 'bin', 'test'), 'current') or {
		return brew_runtime.bool_value(false)
	}
	formula := reinstall_spec_formula(keg_path, true)
	context := reinstall_core.build_install_context(formula, reinstall_core.BuildInstallContextOptions{})
	return brew_runtime.bool_value(context.has_keg && context.keg.path == keg_path
		&& context.link_keg && os.is_dir(formula.prefix) && os.is_dir(formula.opt_prefix)
		&& !os.exists('${keg_path}.reinstall'))
}

// Ruby it `it "restores and relinks a backup keg when reinstalling fails", :integration_test do` at line 25.
pub fn ruby_reinstall_spec_l25_d2_restores(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	root := reinstall_spec_root('restore')
	defer {
		os.rmdir_all(root) or {}
	}
	keg_path := os.join_path(root, 'Cellar', 'testball', '0.1')
	test_file := os.join_path(keg_path, 'bin', 'test')
	reinstall_spec_write(test_file, 'current') or { return brew_runtime.bool_value(false) }
	mut context := reinstall_core.build_install_context(reinstall_spec_formula(keg_path, true), reinstall_core.BuildInstallContextOptions{})
	context.formula_installer.install_error = 'boom'
	reinstall_core.reinstall_formula(mut context) or {
		contents := os.read_file(test_file) or { '' }
		return brew_runtime.bool_value(err.msg() == 'boom' && contents == 'current'
			&& context.keg.linked)
	}
	return brew_runtime.bool_value(false)
}

// Ruby it `it "does not back up the keg when reinstall was already attempted", :integration_test do` at line 42.
pub fn ruby_reinstall_spec_l42_d3_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	root := reinstall_spec_root('attempted')
	defer {
		os.rmdir_all(root) or {}
	}
	keg_path := os.join_path(root, 'Cellar', 'testball', '0.1')
	test_file := os.join_path(keg_path, 'bin', 'test')
	reinstall_spec_write(test_file, 'current') or { return brew_runtime.bool_value(false) }
	mut context := reinstall_core.build_install_context(reinstall_spec_formula(keg_path, true), reinstall_core.BuildInstallContextOptions{})
	context.formula_installer.already_attempted = true
	result := reinstall_core.reinstall_formula(mut context) or {
		return brew_runtime.bool_value(false)
	}
	contents := os.read_file(test_file) or { '' }
	return brew_runtime.bool_value(result.already_attempted && contents == 'current'
		&& context.keg.linked && !os.exists('${keg_path}.reinstall'))
}

// Ruby it `it "removes a stale reinstall backup keg" do` at line 64.
pub fn ruby_reinstall_spec_l64_d4_removes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	root := reinstall_spec_root('stale')
	defer {
		os.rmdir_all(root) or {}
	}
	keg_path := os.join_path(root, 'Cellar', 'testball', '0.1')
	backup := '${keg_path}.reinstall'
	reinstall_spec_write(os.join_path(keg_path, 'bin', 'test'), 'current') or {
		return brew_runtime.bool_value(false)
	}
	reinstall_spec_write(os.join_path(backup, 'bin', 'test'), 'stale') or {
		return brew_runtime.bool_value(false)
	}
	mut keg := reinstall_core.ReinstallKeg{
		name: 'testball'
		path: keg_path
	}
	reinstall_core.backup(mut keg) or { return brew_runtime.bool_value(false) }
	contents := os.read_file(os.join_path(backup, 'bin', 'test')) or { '' }
	return brew_runtime.bool_value(!os.exists(keg_path) && contents == 'current')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "reinstall"
// 5:
// 6: RSpec.describe Homebrew::Reinstall do
// 7:   describe ".build_install_context" do
// 8:     it "leaves the current keg in place until reinstalling", :integration_test do
// 9:       setup_test_formula "testball", tab_attributes: { installed_on_request: true }
// 10:       formula = Formula["testball"]
// 11:       keg = Keg.new(formula.prefix)
// 12:       keg.link
// 13:
// 14:       context = described_class.build_install_context(formula, flags: [])
// 15:
// 16:       expect(context.keg&.to_s).to eq(keg.to_s)
// 17:       expect(context.link_keg).to be(true)
// 18:       expect(formula.prefix).to exist
// 19:       expect(formula.opt_prefix).to be_a_directory
// 20:       expect(Pathname.new("#{keg}.reinstall")).not_to exist
// 21:     end
// 22:   end
// 23:
// 24:   describe ".reinstall_formula" do
// 25:     it "restores and relinks a backup keg when reinstalling fails", :integration_test do
// 26:       setup_test_formula "testball", tab_attributes: { installed_on_request: true }
// 27:       formula = Formula["testball"]
// 28:       keg = Keg.new(formula.prefix)
// 29:       (keg/"bin").mkpath
// 30:       (keg/"bin/test").write("current")
// 31:       keg.link
// 32:
// 33:       context = described_class.build_install_context(formula, flags: [])
// 34:       allow(context.formula_installer).to receive(:install).and_raise(RuntimeError, "boom")
// 35:
// 36:       expect { described_class.reinstall_formula(context) }.to raise_error(RuntimeError, "boom")
// 37:
// 38:       expect((keg/"bin/test").read).to eq("current")
// 39:       expect(keg.linked?).to be(true)
// 40:     end
// 41:
// 42:     it "does not back up the keg when reinstall was already attempted", :integration_test do
// 43:       setup_test_formula "testball", tab_attributes: { installed_on_request: true }
// 44:       formula = Formula["testball"]
// 45:       keg = Keg.new(formula.prefix)
// 46:       (keg/"bin").mkpath
// 47:       (keg/"bin/test").write("current")
// 48:       keg.link
// 49:
// 50:       FormulaInstaller.attempted << formula
// 51:       context = described_class.build_install_context(formula, flags: [])
// 52:
// 53:       described_class.reinstall_formula(context)
// 54:
// 55:       expect((keg/"bin/test").read).to eq("current")
// 56:       expect(keg.linked?).to be(true)
// 57:       expect(Pathname.new("#{keg}.reinstall")).not_to exist
// 58:     ensure
// 59:       FormulaInstaller.attempted.clear
// 60:     end
// 61:   end
// 62:
// 63:   describe ".backup" do
// 64:     it "removes a stale reinstall backup keg" do
// 65:       keg_path = HOMEBREW_CELLAR/"testball/0.1"
// 66:       (keg_path/"bin").mkpath
// 67:       keg = Keg.new(keg_path)
// 68:       backup = Pathname.new("#{keg}.reinstall")
// 69:
// 70:       (keg_path/"bin/test").write("current")
// 71:       (backup/"bin").mkpath
// 72:       (backup/"bin/test").write("stale")
// 73:
// 74:       described_class.backup(keg)
// 75:
// 76:       expect(keg_path).not_to exist
// 77:       expect(backup/"bin/test").to exist
// 78:       expect((backup/"bin/test").read).to eq("current")
// 79:     end
// 80:   end
// 81: end
