module bundle

import ruby
import homebrew
import homebrew.bundle as production_bundle
import os
import time

// Translated from Homebrew/brew `test/bundle/bundle_spec.rb`.
// The original source is retained below until every stub has a typed V body.

fn bundle_spec_root(args []ruby.Value, label string) string {
	if args.len > 0 && args[0].as_string() != '' {
		return args[0].as_string()
	}
	return os.join_path(os.temp_dir(), 'brew-v-bundle-spec-${label}-${os.getpid()}-${time.now().unix_micro()}')
}

fn bundle_spec_runtime(root string) &homebrew.BundleRuntime {
	return homebrew.new_bundle_runtime(homebrew.BundleRuntimeConfig{
		prefix: os.join_path(root, 'prefix')
		library: os.join_path(root, 'library')
		brew_file: '/bin/sh'
	})
}

fn bundle_spec_dsl(content string) !production_bundle.BundleDsl {
	return production_bundle.parse_bundle_dsl('/fake/Brewfile', content)
}

fn bundle_spec_mark_formula(name string, installed bool,
	marked bool) &homebrew.BundleRuntime {
	mut runtime := bundle_spec_runtime('')
	if installed {
		runtime.installed_formulae = [name]
		runtime.tabs[name] = homebrew.BundleTabState{
			exists: true
			installed_on_request: marked
		}
	}
	runtime.mark_as_installed_on_request([
		homebrew.BundleEntry{
			entry_type: 'brew'
			name: name
		},
	])
	return runtime
}

// Ruby it `it "omits all stdout output if verbose is false" do` at line 9.
pub fn ruby_bundle_spec_l9_d1_omits(args ...ruby.Value) ruby.Value {
	mut runtime := bundle_spec_runtime(bundle_spec_root(args, 'quiet-success'))
	success := runtime.run_system('/bin/echo', ['foo'], false)
	return ruby.bool_value(success && runtime.output.len == 0)
}

// Ruby it `it "emits all stdout output if verbose is true" do` at line 13.
pub fn ruby_bundle_spec_l13_d2_emits(args ...ruby.Value) ruby.Value {
	mut runtime := bundle_spec_runtime(bundle_spec_root(args, 'verbose-success'))
	success := runtime.run_system('/bin/echo', ['foo'], true)
	return ruby.bool_value(success && runtime.output == ['foo\n'])
}

// Ruby it `it "emits all stdout output even if verbose is false" do` at line 19.
pub fn ruby_bundle_spec_l19_d3_emits(args ...ruby.Value) ruby.Value {
	mut runtime := bundle_spec_runtime(bundle_spec_root(args, 'quiet-failure'))
	success := runtime.run_system('/bin/sh', ['-c', 'echo foo && false'], false)
	return ruby.bool_value(!success && runtime.output == ['foo\n'])
}

// Ruby it `it "emits all stdout output only once if verbose is true" do` at line 26.
pub fn ruby_bundle_spec_l26_d4_emits(args ...ruby.Value) ruby.Value {
	mut runtime := bundle_spec_runtime(bundle_spec_root(args, 'verbose-once'))
	success := runtime.run_system('/bin/sh', ['-c', 'echo foo && true'], true)
	return ruby.bool_value(success && runtime.output == ['foo\n'])
}

// Ruby it `it "finds it when present" do` at line 35.
pub fn ruby_bundle_spec_l35_d5_finds(args ...ruby.Value) ruby.Value {
	root := bundle_spec_root(args, 'cask')
	prefix := os.join_path(root, 'prefix')
	library := os.join_path(root, 'library')
	os.mkdir_all(os.join_path(prefix, 'Caskroom')) or { return ruby.bool_value(false) }
	os.mkdir_all(os.join_path(library, 'Taps', 'homebrew', 'homebrew-cask')) or {
		return ruby.bool_value(false)
	}
	mut runtime := homebrew.new_bundle_runtime(homebrew.BundleRuntimeConfig{
		prefix: prefix
		library: library
		no_install_from_api: true
	})
	return ruby.bool_value(runtime.is_cask_installed())
}

// Ruby subject `subject(:mark_installed!) { described_class.mark_as_installed_on_request!(entries) }` at line 45.
pub fn ruby_bundle_spec_l45_d6_mark_installed(args ...ruby.Value) ruby.Value {
	name := if args.len > 0 && args[0].as_string() != '' {
		args[0].as_string()
	} else {
		'myformula'
	}
	_ = bundle_spec_mark_formula(name, true, false)
	return ruby.object_value('NilClass', 'nil')
}

// Ruby let `let(:brewfile_content) { "brew 'myformula'" }` at line 47.
pub fn ruby_bundle_spec_l47_d7_brewfile_content(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value("brew 'myformula'")
}

// Ruby let `let(:entries) { dsl.entries }` at line 48.
pub fn ruby_bundle_spec_l48_d8_entries(args ...ruby.Value) ruby.Value {
	content := if args.len > 0 && args[0].as_string() != '' {
		args[0].as_string()
	} else {
		ruby_bundle_spec_l47_d7_brewfile_content().as_string()
	}
	dsl := bundle_spec_dsl(content) or { return ruby.array_value([]) }
	return ruby.array_value(dsl.entries.map(production_bundle.bundle_dsl_entry_value(it)))
}

// Ruby let `let(:dsl) { Homebrew::Bundle::Dsl.new(Pathname.new("/fake/Brewfile")) }` at line 49.
pub fn ruby_bundle_spec_l49_d9_dsl(args ...ruby.Value) ruby.Value {
	content := if args.len > 0 && args[0].as_string() != '' {
		args[0].as_string()
	} else {
		ruby_bundle_spec_l47_d7_brewfile_content().as_string()
	}
	dsl := bundle_spec_dsl(content) or {
		return ruby.object_value('RuntimeError', err.msg())
	}
	return production_bundle.bundle_dsl_value(dsl)
}

// Ruby let `let(:tabfile) { Pathname.new("/fake/INSTALL_RECEIPT.json") }` at line 50.
pub fn ruby_bundle_spec_l50_d10_tabfile(args ...ruby.Value) ruby.Value {
	root := if args.len > 0 && args[0].as_string() != '' { args[0].as_string() } else { '/fake' }
	return ruby.object_value('Pathname', os.join_path(root, 'INSTALL_RECEIPT.json'))
}

// Ruby let `let(:tab) { instance_double(Tab, installed_on_request: false, tabfile:) }` at line 59.
pub fn ruby_bundle_spec_l59_d11_tab(args ...ruby.Value) ruby.Value {
	path := ruby_bundle_spec_l50_d10_tabfile(...args).as_string()
	return ruby.structured_value('Tab', path, {
		'installed_on_request': 'false'
		'tabfile':              path
	})
}

// Ruby it `it "sets installed_on_request=true and writes" do` at line 66.
pub fn ruby_bundle_spec_l66_d12_sets(args ...ruby.Value) ruby.Value {
	_ = args
	runtime := bundle_spec_mark_formula('myformula', true, false)
	return ruby.bool_value(runtime.tabs['myformula'].installed_on_request
		&& runtime.brew_tab_updates.len == 0)
}

// Ruby let `let(:brewfile_content) { "brew 'notinstalled'" }` at line 74.
pub fn ruby_bundle_spec_l74_d13_brewfile_content(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value("brew 'notinstalled'")
}

// Ruby it `it "skips the formula" do` at line 80.
pub fn ruby_bundle_spec_l80_d14_skips(args ...ruby.Value) ruby.Value {
	_ = args
	runtime := bundle_spec_mark_formula('notinstalled', false, false)
	return ruby.bool_value(runtime.tabs.len == 0 && runtime.brew_tab_updates.len == 0)
}

// Ruby let `let(:brewfile_content) { "brew 'alreadymarked'" }` at line 87.
pub fn ruby_bundle_spec_l87_d15_brewfile_content(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value("brew 'alreadymarked'")
}

// Ruby let `let(:tab) { instance_double(Tab, installed_on_request: true, tabfile:) }` at line 88.
pub fn ruby_bundle_spec_l88_d16_tab(args ...ruby.Value) ruby.Value {
	path := ruby_bundle_spec_l50_d10_tabfile(...args).as_string()
	return ruby.structured_value('Tab', path, {
		'installed_on_request': 'true'
		'tabfile':              path
	})
}

// Ruby it `it "skips writing" do` at line 95.
pub fn ruby_bundle_spec_l95_d17_skips(args ...ruby.Value) ruby.Value {
	_ = args
	runtime := bundle_spec_mark_formula('alreadymarked', true, true)
	return ruby.bool_value(runtime.tabs['alreadymarked'].installed_on_request
		&& runtime.brew_tab_updates.len == 0)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle"
// 5: require "bundle/dsl"
// 6:
// 7: RSpec.describe Homebrew::Bundle do
// 8:   context "when the system call succeeds" do
// 9:     it "omits all stdout output if verbose is false" do
// 10:       expect { described_class.system "echo", "foo", verbose: false }.not_to output.to_stdout_from_any_process
// 11:     end
// 12:
// 13:     it "emits all stdout output if verbose is true" do
// 14:       expect { described_class.system "echo", "foo", verbose: true }.to output("foo\n").to_stdout_from_any_process
// 15:     end
// 16:   end
// 17:
// 18:   context "when the system call fails" do
// 19:     it "emits all stdout output even if verbose is false" do
// 20:       expect do
// 21:         described_class.system "/bin/bash", "-c", "echo foo && false",
// 22:                                verbose: false
// 23:       end.to output("foo\n").to_stdout_from_any_process
// 24:     end
// 25:
// 26:     it "emits all stdout output only once if verbose is true" do
// 27:       expect do
// 28:         described_class.system "/bin/bash", "-c", "echo foo && true",
// 29:                                verbose: true
// 30:       end.to output("foo\n").to_stdout_from_any_process
// 31:     end
// 32:   end
// 33:
// 34:   context "when checking for homebrew/cask", :needs_macos do
// 35:     it "finds it when present" do
// 36:       allow(File).to receive(:directory?).with("#{HOMEBREW_PREFIX}/Caskroom").and_return(true)
// 37:       allow(File).to receive(:directory?)
// 38:         .with("#{HOMEBREW_LIBRARY}/Taps/homebrew/homebrew-cask")
// 39:         .and_return(true)
// 40:       expect(described_class.cask_installed?).to be(true)
// 41:     end
// 42:   end
// 43:
// 44:   describe ".mark_as_installed_on_request!", :no_api do
// 45:     subject(:mark_installed!) { described_class.mark_as_installed_on_request!(entries) }
// 46:
// 47:     let(:brewfile_content) { "brew 'myformula'" }
// 48:     let(:entries) { dsl.entries }
// 49:     let(:dsl) { Homebrew::Bundle::Dsl.new(Pathname.new("/fake/Brewfile")) }
// 50:     let(:tabfile) { Pathname.new("/fake/INSTALL_RECEIPT.json") }
// 51:
// 52:     before do
// 53:       allow(DevelopmentTools).to receive_messages(needs_libc_formula?: false, needs_compiler_formula?: false)
// 54:       allow_any_instance_of(Pathname).to receive(:read).and_return(brewfile_content)
// 55:       allow(tabfile).to receive_messages(blank?: false, exist?: true)
// 56:     end
// 57:
// 58:     context "when formula is installed but not marked as installed_on_request" do
// 59:       let(:tab) { instance_double(Tab, installed_on_request: false, tabfile:) }
// 60:
// 61:       before do
// 62:         allow(Formula).to receive(:installed_formula_names).and_return(["myformula"])
// 63:         allow(Tab).to receive(:for_name).with("myformula").and_return(tab)
// 64:       end
// 65:
// 66:       it "sets installed_on_request=true and writes" do
// 67:         expect(tab).to receive(:installed_on_request=).with(true)
// 68:         expect(tab).to receive(:write)
// 69:         mark_installed!
// 70:       end
// 71:     end
// 72:
// 73:     context "when formula is not installed" do
// 74:       let(:brewfile_content) { "brew 'notinstalled'" }
// 75:
// 76:       before do
// 77:         allow(Formula).to receive(:installed_formula_names).and_return([])
// 78:       end
// 79:
// 80:       it "skips the formula" do
// 81:         expect(Tab).not_to receive(:for_name)
// 82:         mark_installed!
// 83:       end
// 84:     end
// 85:
// 86:     context "when formula is already marked as installed_on_request" do
// 87:       let(:brewfile_content) { "brew 'alreadymarked'" }
// 88:       let(:tab) { instance_double(Tab, installed_on_request: true, tabfile:) }
// 89:
// 90:       before do
// 91:         allow(Formula).to receive(:installed_formula_names).and_return(["alreadymarked"])
// 92:         allow(Tab).to receive(:for_name).with("alreadymarked").and_return(tab)
// 93:       end
// 94:
// 95:       it "skips writing" do
// 96:         expect(tab).not_to receive(:installed_on_request=)
// 97:         expect(tab).not_to receive(:write)
// 98:         mark_installed!
// 99:       end
// 100:     end
// 101:   end
// 102: end
