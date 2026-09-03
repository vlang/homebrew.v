module cask

import brew_runtime
import os

// Translated from Homebrew/brew `test/support/helper/cask/install_helper.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct InstallHelperCask {
pub:
	token            string
	caskroom_path    string
	staged_path      string
	caskfile_path    string
	receipt_path     string
	appdir           string
	app_targets      []string
	caskfile_content string
	receipt_content  string
}

pub struct InstallHelperResult {
pub:
	token                string
	downloaded           bool
	primary_extracted    bool
	caskfile_saved       bool
	receipt_written      bool
	installed_on_request bool
	created_directories  []string
}

fn install_helper_write(path string, contents string) ! {
	if path == '' {
		return
	}
	os.mkdir_all(os.dir(path))!
	os.write_file(path, contents)!
}

pub fn cask_install_without_artifacts(cask_definition InstallHelperCask,
	save_caskfile bool) !InstallHelperResult {
	if save_caskfile {
		install_helper_write(cask_definition.caskfile_path, cask_definition.caskfile_content)!
	}
	return InstallHelperResult{
		token: cask_definition.token
		downloaded: true
		primary_extracted: true
		caskfile_saved: save_caskfile
	}
}

pub fn cask_stub_installation(cask_definition InstallHelperCask,
	create_app_dirs bool) !InstallHelperResult {
	mut created := []string{}
	for directory in [cask_definition.caskroom_path, cask_definition.staged_path] {
		if directory == '' {
			continue
		}
		os.mkdir_all(directory)!
		created << directory
	}
	install_helper_write(cask_definition.caskfile_path, cask_definition.caskfile_content)!
	receipt := if cask_definition.receipt_content == '' {
		'{"installed_on_request":true}\n'
	} else {
		cask_definition.receipt_content
	}
	install_helper_write(cask_definition.receipt_path, receipt)!
	if create_app_dirs {
		for target in cask_definition.app_targets {
			basename := os.base(target)
			if basename == '' || cask_definition.appdir == '' {
				continue
			}
			directory := os.join_path(cask_definition.appdir, basename)
			os.mkdir_all(directory)!
			created << directory
		}
	}
	return InstallHelperResult{
		token: cask_definition.token
		caskfile_saved: cask_definition.caskfile_path != ''
		receipt_written: cask_definition.receipt_path != ''
		installed_on_request: true
		created_directories: created
	}
}

pub fn cask_install_with_caskfile(cask_definition InstallHelperCask) !InstallHelperResult {
	install_helper_write(cask_definition.caskfile_path, cask_definition.caskfile_content)!
	return InstallHelperResult{
		token: cask_definition.token
		caskfile_saved: cask_definition.caskfile_path != ''
	}
}

fn install_helper_cask_from_value(value brew_runtime.Value) InstallHelperCask {
	return InstallHelperCask{
		token: if value.attributes['token'] != '' {
			value.attributes['token']
		} else {
			value.as_string()
		}
		caskroom_path: value.attributes['caskroom_path']
		staged_path: value.attributes['staged_path']
		caskfile_path: value.attributes['caskfile_path']
		receipt_path: value.attributes['receipt_path']
		appdir: value.attributes['appdir']
		app_targets: value.attributes['app_targets'].split(',').filter(it != '')
		caskfile_content: value.attributes['caskfile_content']
		receipt_content: value.attributes['receipt_content']
	}
}

fn install_helper_result_value(result InstallHelperResult) brew_runtime.Value {
	return brew_runtime.structured_value('Cask::Installer', result.token, {
		'downloaded':           result.downloaded.str()
		'primary_extracted':    result.primary_extracted.str()
		'caskfile_saved':       result.caskfile_saved.str()
		'receipt_written':      result.receipt_written.str()
		'installed_on_request': result.installed_on_request.str()
		'created_directories':  result.created_directories.join(',')
	})
}

// Ruby method `self.install_without_artifacts(cask)` at line 9.
pub fn ruby_install_helper_l9_d1_self_install_without_artifacts(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return install_helper_result_value(cask_install_without_artifacts(install_helper_cask_from_value(args[0]), false) or { panic(err) })
}

// Ruby method `self.install_without_artifacts_with_caskfile(cask)` at line 16.
pub fn ruby_install_helper_l16_d2_self_install_without_artifacts_with_caskfile(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return install_helper_result_value(cask_install_without_artifacts(install_helper_cask_from_value(args[0]), true) or { panic(err) })
}

// Ruby method `self.stub_cask_installation(cask, create_app_dirs: true)` at line 31.
pub fn ruby_install_helper_l31_d3_self_stub_cask_installation(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	create_app_dirs := args.len < 2 || (args[1].as_bool() or { true })
	return install_helper_result_value(cask_stub_installation(install_helper_cask_from_value(args[0]), create_app_dirs) or { panic(err) })
}

// Ruby method `install_without_artifacts(cask)` at line 56.
pub fn ruby_install_helper_l56_d4_install_without_artifacts(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_install_helper_l9_d1_self_install_without_artifacts(...args)
}

// Ruby method `install_with_caskfile(cask)` at line 63.
pub fn ruby_install_helper_l63_d5_install_with_caskfile(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return install_helper_result_value(cask_install_with_caskfile(install_helper_cask_from_value(args[0])) or {
		panic(err)
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/installer"
// 5:
// 6: module InstallHelper
// 7:   module_function
// 8:
// 9:   def self.install_without_artifacts(cask)
// 10:     Cask::Installer.new(cask).tap do |i|
// 11:       i.download
// 12:       i.extract_primary_container
// 13:     end
// 14:   end
// 15:
// 16:   def self.install_without_artifacts_with_caskfile(cask)
// 17:     Cask::Installer.new(cask).tap do |i|
// 18:       i.download
// 19:       i.extract_primary_container
// 20:       i.save_caskfile
// 21:     end
// 22:   end
// 23:
// 24:   # Creates a minimal stub installation without downloading or extracting.
// 25:   # This is useful for tests that only need to check installation state
// 26:   # (installed?, installed_version) and artifact paths without performing
// 27:   # actual file operations.
// 28:   #
// 29:   # @param cask [Cask::Cask] the cask to stub install
// 30:   # @param create_app_dirs [Boolean] whether to create stub app directories in appdir
// 31:   def self.stub_cask_installation(cask, create_app_dirs: true)
// 32:     # Create the caskroom path
// 33:     cask.caskroom_path.mkpath
// 34:
// 35:     # Create the staged_path (version directory)
// 36:     cask.staged_path.mkpath
// 37:
// 38:     # Create metadata directory structure and save the caskfile and receipt
// 39:     # This makes installed? and installed_version work
// 40:     Cask::Installer.new(cask).save_caskfile
// 41:     tab = Cask::Tab.create(cask)
// 42:     tab.installed_on_request = true
// 43:     tab.write
// 44:
// 45:     return unless create_app_dirs
// 46:
// 47:     # Create stub app directories in appdir so path existence checks pass
// 48:     cask.artifacts.each do |artifact|
// 49:       next unless artifact.is_a?(Cask::Artifact::App)
// 50:
// 51:       target_path = Pathname(cask.config.appdir).join(artifact.target.basename)
// 52:       target_path.mkpath
// 53:     end
// 54:   end
// 55:
// 56:   def install_without_artifacts(cask)
// 57:     Cask::Installer.new(cask).tap do |i|
// 58:       i.download
// 59:       i.extract_primary_container
// 60:     end
// 61:   end
// 62:
// 63:   def install_with_caskfile(cask)
// 64:     Cask::Installer.new(cask).tap(&:save_caskfile)
// 65:   end
// 66: end
