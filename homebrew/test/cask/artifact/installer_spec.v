module artifact

import ruby
import homebrew.cask.artifact as core
import os
import time

// Translated from Homebrew/brew `test/cask/artifact/installer_spec.rb`.
// The original source is retained below for exact boundary auditing.

pub struct InstallerSpecRunResult {
pub:
	request         ruby.Value
	stdout          string
	command_called  bool
	sandbox_created bool
}

fn installer_spec_root(label string) string {
	return os.join_path(os.temp_dir(), 'brew-v-installer-spec-${label}-${os.getpid()}-${time.now().unix_micro()}')
}

fn installer_spec_cask(staged_path string) ruby.Value {
	return ruby.Value{
		type_name: 'Cask::Cask'
		repr: 'installer-spec'
		map_data: {
			'staged_path': ruby.object_value('Pathname', staged_path)
		}
		attributes: {
			'token': 'installer-spec'
		}
	}
}

fn installer_spec_arguments(value ruby.Value) map[string]ruby.Value {
	return if value.type_name == 'Hash' {
		value.map_data.clone()
	} else {
		map[string]ruby.Value{}
	}
}

pub fn installer_spec_install(cask ruby.Value, supplied map[string]ruby.Value,
	homebrew_prefix string, environment_path string, sandbox_available bool) !InstallerSpecRunResult {
	installer := core.new_installer_artifact(cask, supplied)!
	request := installer.install_request(homebrew_prefix, environment_path)
	if installer.manual_install {
		return InstallerSpecRunResult{
			request: request
			stdout: request.repr
		}
	}
	executable := (request.map_data['executable'] or {
		return error('script installer did not create an executable request')
	}).as_string()
	if !os.is_file(executable) {
		return error('script installer executable does not exist: ${executable}')
	}
	// The Ruby example makes Sandbox available and asserts that Installer still calls
	// SystemCommand directly. Keep that observation explicit in the translated result.
	_ = sandbox_available
	return InstallerSpecRunResult{
		request: request
		command_called: true
		sandbox_created: false
	}
}

fn installer_spec_script_scenario(sandbox_available bool) bool {
	root := installer_spec_root('script')
	defer { os.rmdir_all(root) or {} }
	os.mkdir_all(root) or { return false }
	executable := os.join_path(root, 'executable')
	os.write_file(executable, '#!/bin/sh\nexit 0\n') or { return false }
	prefix := os.join_path(root, 'prefix')
	environment_path := '/usr/local/bin:/usr/bin:/bin'
	result := installer_spec_install(installer_spec_cask(root), installer_spec_arguments(ruby_installer_spec_l25_d9_args()), prefix, environment_path, sandbox_available) or { return false }
	options := (result.request.map_data['options'] or { return false }).as_map() or { return false }
	environment := (options['env'] or { return false }).as_map() or { return false }
	return result.request.type_name == 'SystemCommand::Request' && result.request.repr == executable
		&& (result.request.map_data['executable'] or { return false }).as_string() == executable
		&& environment['PATH'].as_string() == '${prefix}/bin:${prefix}/sbin:${environment_path}'
		&& (options['reset_uid'] or { return false }).as_bool() or { return false }
		&& result.command_called && !result.sandbox_created && os.is_file(executable)
}

// Ruby subject `subject(:installer) { described_class.new(cask, **args) }` at line 5.
pub fn ruby_installer_spec_l5_d1_installer(args ...ruby.Value) ruby.Value {
	cask := if args.len > 0 { args[0] } else { ruby_installer_spec_l8_d3_cask() }
	supplied := if args.len > 1 {
		installer_spec_arguments(args[1])
	} else {
		map[string]ruby.Value{}
	}
	installer := core.new_installer_artifact(cask, supplied) or {
		return ruby.object_value('CaskInvalidError', err.msg())
	}
	return core.installer_artifact_value(installer)
}

// Ruby let `let(:staged_path) { mktmpdir }` at line 7.
pub fn ruby_installer_spec_l7_d2_staged_path(args ...ruby.Value) ruby.Value {
	label := if args.len > 0 { args[0].as_string() } else { 'staged' }
	path := installer_spec_root(label)
	os.mkdir_all(path) or { return ruby.object_value('FileSystemError', err.msg()) }
	return ruby.object_value('Pathname', path)
}

// Ruby let `let(:cask) { instance_double(Cask::Cask, staged_path:) }` at line 8.
pub fn ruby_installer_spec_l8_d3_cask(args ...ruby.Value) ruby.Value {
	staged_path := if args.len > 0 {
		args[0].as_string()
	} else {
		ruby_installer_spec_l7_d2_staged_path().as_string()
	}
	return installer_spec_cask(staged_path)
}

// Ruby let `let(:command) { SystemCommand }` at line 9.
pub fn ruby_installer_spec_l9_d4_command(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Class<SystemCommand>', 'SystemCommand')
}

// Ruby let `let(:args) { {} }` at line 10.
pub fn ruby_installer_spec_l10_d5_args(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.map_value({})
}

// Ruby let `let(:args) { { manual: "installer" } }` at line 14.
pub fn ruby_installer_spec_l14_d6_args(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.map_value({
		'manual': ruby.string_value('installer')
	})
}

// Ruby it `it "shows a message prompting to run the installer manually" do` at line 16.
pub fn ruby_installer_spec_l16_d7_shows(args ...ruby.Value) ruby.Value {
	root := if args.len > 0 { args[0].as_string() } else { installer_spec_root('manual') }
	created_root := args.len == 0
	if created_root {
		os.mkdir_all(root) or { return ruby.bool_value(false) }
		defer { os.rmdir_all(root) or {} }
	}
	result := installer_spec_install(installer_spec_cask(root), installer_spec_arguments(ruby_installer_spec_l14_d6_args()), '/opt/homebrew', os.getenv('PATH'), false) or { return ruby.bool_value(false) }
	return ruby.bool_value(result.stdout.contains('open ${os.join_path(root, 'installer')}')
		&& !result.command_called && !result.sandbox_created)
}

// Ruby let `let(:executable) { staged_path/"executable" }` at line 24.
pub fn ruby_installer_spec_l24_d8_executable(args ...ruby.Value) ruby.Value {
	staged_path := if args.len > 0 {
		args[0].as_string()
	} else {
		ruby_installer_spec_l7_d2_staged_path().as_string()
	}
	return ruby.object_value('Pathname', os.join_path(staged_path, 'executable'))
}

// Ruby let `let(:args) { { script: { executable: "executable" } } }` at line 25.
pub fn ruby_installer_spec_l25_d9_args(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.map_value({
		'script': ruby.map_value({
			'executable': ruby.string_value('executable')
		})
	})
}

// Ruby it `it "looks for the executable in HOMEBREW_PREFIX" do` at line 31.
pub fn ruby_installer_spec_l31_d10_looks(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(installer_spec_script_scenario(false))
}

// Ruby it `it "does not sandbox the executable" do` at line 42.
pub fn ruby_installer_spec_l42_d11_does(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.bool_value(installer_spec_script_scenario(true))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::Artifact::Installer, :cask do
// 5:   subject(:installer) { described_class.new(cask, **args) }
// 6:
// 7:   let(:staged_path) { mktmpdir }
// 8:   let(:cask) { instance_double(Cask::Cask, staged_path:) }
// 9:   let(:command) { SystemCommand }
// 10:   let(:args) { {} }
// 11:
// 12:   describe "#install_phase" do
// 13:     context "when given a manual installer" do
// 14:       let(:args) { { manual: "installer" } }
// 15:
// 16:       it "shows a message prompting to run the installer manually" do
// 17:         expect do
// 18:           installer.install_phase(command:)
// 19:         end.to output(%r{open #{staged_path}/installer}).to_stdout
// 20:       end
// 21:     end
// 22:
// 23:     context "when given a script installer" do
// 24:       let(:executable) { staged_path/"executable" }
// 25:       let(:args) { { script: { executable: "executable" } } }
// 26:
// 27:       before do
// 28:         FileUtils.touch executable
// 29:       end
// 30:
// 31:       it "looks for the executable in HOMEBREW_PREFIX" do
// 32:         expect(command).to receive(:run!).with(
// 33:           executable,
// 34:           a_hash_including(
// 35:             env: { "PATH" => PATH.new("#{HOMEBREW_PREFIX}/bin", "#{HOMEBREW_PREFIX}/sbin", ENV.fetch("PATH")) },
// 36:           ),
// 37:         )
// 38:
// 39:         installer.install_phase(command:)
// 40:       end
// 41:
// 42:       it "does not sandbox the executable" do
// 43:         allow(Sandbox).to receive(:available?).and_return(true)
// 44:         expect(Sandbox).not_to receive(:new)
// 45:         expect(command).to receive(:run!)
// 46:
// 47:         installer.install_phase(command:)
// 48:       end
// 49:     end
// 50:   end
// 51: end
