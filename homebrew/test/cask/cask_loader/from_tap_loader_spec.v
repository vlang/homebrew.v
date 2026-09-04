module cask_loader

import ruby
import homebrew.cask
import os
import time

// Translated from Homebrew/brew `test/cask/cask_loader/from_tap_loader_spec.rb`.
// The original source is retained below for exact boundary auditing.

const from_tap_loader_spec_cask_name = 'testball'

fn from_tap_loader_spec_default_root(label string) string {
	return os.join_path(os.temp_dir(), 'brew-v-from-tap-loader-${label}-${os.getpid()}-${time.now().unix_micro()}')
}

fn from_tap_loader_spec_root(args []ruby.Value, label string) string {
	return if args.len > 0 { args[0].as_string() } else { from_tap_loader_spec_default_root(label) }
}

pub fn from_tap_loader_spec_tap(root string, sharded bool) cask.CaskLoaderTap {
	path := os.join_path(root, 'homebrew-cask')
	cask_dir := os.join_path(path, 'Casks')
	mut files_by_name := map[string]string{}
	if sharded {
		files_by_name[from_tap_loader_spec_cask_name] = from_tap_loader_spec_cask_path(root, true)
	}
	return cask.CaskLoaderTap{
		name: 'homebrew/cask'
		path: path
		cask_dir: cask_dir
		formula_dir: os.join_path(path, 'Formula')
		installed: true
		core_cask_tap: true
		cask_files_by_name: files_by_name
	}
}

pub fn from_tap_loader_spec_cask_path(root string, sharded bool) string {
	cask_dir := os.join_path(root, 'homebrew-cask', 'Casks')
	if sharded {
		return os.join_path(cask_dir, from_tap_loader_spec_cask_name[..1], '${from_tap_loader_spec_cask_name}.rb')
	}
	return os.join_path(cask_dir, '${from_tap_loader_spec_cask_name}.rb')
}

pub fn from_tap_loader_spec_load(root string, sharded bool) !cask.CaskLoaderCask {
	path := from_tap_loader_spec_cask_path(root, sharded)
	os.mkdir_all(os.dir(path))!
	os.write_file(path, "cask '${from_tap_loader_spec_cask_name}' do\n  url 'https://brew.sh/'\nend\n")!
	tap := from_tap_loader_spec_tap(root, sharded)
	lookup := cask.CaskLoaderLookupContext{
		core_cask_tap: tap
		taps: [tap]
	}
	mut loader := cask.ruby_cask_loader_l336_d25_initialize('homebrew/cask/${from_tap_loader_spec_cask_name}', lookup)!
	return cask.ruby_cask_loader_l347_d26_load(mut loader, cask.CaskLoaderConfig{}, cask.CaskLoaderLoadContext{
		lookup: lookup
		evaluation: cask.CaskLoaderEvaluation{
			valid: true
			cask: cask.CaskLoaderCask{
				token: from_tap_loader_spec_cask_name
				url: 'https://brew.sh/'
			}
		}
		trusted: true
	})
}

pub fn from_tap_loader_spec_unavailable(root string) bool {
	tap := from_tap_loader_spec_tap(root, false)
	lookup := cask.CaskLoaderLookupContext{
		core_cask_tap: tap
		taps: [tap]
	}
	mut loader := cask.ruby_cask_loader_l336_d25_initialize('foo/bar/baz', lookup) or {
		return false
	}
	cask.ruby_cask_loader_l347_d26_load(mut loader, cask.CaskLoaderConfig{}, cask.CaskLoaderLoadContext{
		lookup: lookup
		trusted: true
	}) or { return err.msg().contains('CaskUnavailableError') }
	return false
}

// Ruby let `let(:tap) { CoreCaskTap.instance }` at line 5.
pub fn ruby_from_tap_loader_spec_l5_d1_tap(args ...ruby.Value) ruby.Value {
	root := from_tap_loader_spec_root(args, 'tap')
	tap := from_tap_loader_spec_tap(root, false)
	return ruby.structured_value('CoreCaskTap', tap.name, {
		'name':     tap.name
		'path':     tap.path
		'cask_dir': tap.cask_dir
	})
}

// Ruby let `let(:cask_name) { "testball" }` at line 6.
pub fn ruby_from_tap_loader_spec_l6_d2_cask_name(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(from_tap_loader_spec_cask_name)
}

// Ruby let `let(:cask_full_name) { "homebrew/cask/#{cask_name}" }` at line 7.
pub fn ruby_from_tap_loader_spec_l7_d3_cask_full_name(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('homebrew/cask/${from_tap_loader_spec_cask_name}')
}

// Ruby let `let(:cask_path) { tap.cask_dir/"#{cask_name}.rb" }` at line 8.
pub fn ruby_from_tap_loader_spec_l8_d4_cask_path(args ...ruby.Value) ruby.Value {
	root := from_tap_loader_spec_root(args, 'path')
	return ruby.object_value('Pathname', from_tap_loader_spec_cask_path(root, false))
}

// Ruby it `it "returns a Cask" do` at line 20.
pub fn ruby_from_tap_loader_spec_l20_d5_returns(args ...ruby.Value) ruby.Value {
	root := from_tap_loader_spec_root(args, 'flat-load')
	loaded := from_tap_loader_spec_load(root, false) or { return ruby.bool_value(false) }
	return ruby.bool_value(loaded.token == from_tap_loader_spec_cask_name
		&& loaded.url == 'https://brew.sh/' && loaded.has_tap && loaded.tap.name == 'homebrew/cask'
		&& loaded.sourcefile_path == from_tap_loader_spec_cask_path(root, false))
}

// Ruby it `it "raises an error if the Cask cannot be found" do` at line 24.
pub fn ruby_from_tap_loader_spec_l24_d6_raises(args ...ruby.Value) ruby.Value {
	root := from_tap_loader_spec_root(args, 'unavailable')
	return ruby.bool_value(from_tap_loader_spec_unavailable(root))
}

// Ruby let `let(:cask_path) { tap.cask_dir/cask_name[0]/"#{cask_name}.rb" }` at line 29.
pub fn ruby_from_tap_loader_spec_l29_d7_cask_path(args ...ruby.Value) ruby.Value {
	root := from_tap_loader_spec_root(args, 'sharded-path')
	return ruby.object_value('Pathname', from_tap_loader_spec_cask_path(root, true))
}

// Ruby it `it "returns a Cask" do` at line 31.
pub fn ruby_from_tap_loader_spec_l31_d8_returns(args ...ruby.Value) ruby.Value {
	root := from_tap_loader_spec_root(args, 'sharded-load')
	loaded := from_tap_loader_spec_load(root, true) or { return ruby.bool_value(false) }
	return ruby.bool_value(loaded.token == from_tap_loader_spec_cask_name
		&& loaded.url == 'https://brew.sh/' && loaded.has_tap && loaded.tap.name == 'homebrew/cask'
		&& loaded.sourcefile_path == from_tap_loader_spec_cask_path(root, true))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::CaskLoader::FromTapLoader do
// 5:   let(:tap) { CoreCaskTap.instance }
// 6:   let(:cask_name) { "testball" }
// 7:   let(:cask_full_name) { "homebrew/cask/#{cask_name}" }
// 8:   let(:cask_path) { tap.cask_dir/"#{cask_name}.rb" }
// 9:
// 10:   describe "#load" do
// 11:     before do
// 12:       cask_path.parent.mkpath
// 13:       cask_path.write <<~RUBY
// 14:         cask '#{cask_name}' do
// 15:           url 'https://brew.sh/'
// 16:         end
// 17:       RUBY
// 18:     end
// 19:
// 20:     it "returns a Cask" do
// 21:       expect(described_class.new(cask_full_name).load(config: nil)).to be_a(Cask::Cask)
// 22:     end
// 23:
// 24:     it "raises an error if the Cask cannot be found" do
// 25:       expect { described_class.new("foo/bar/baz").load(config: nil) }.to raise_error(Cask::CaskUnavailableError)
// 26:     end
// 27:
// 28:     context "with sharded Cask directory", :no_api do
// 29:       let(:cask_path) { tap.cask_dir/cask_name[0]/"#{cask_name}.rb" }
// 30:
// 31:       it "returns a Cask" do
// 32:         expect(described_class.new(cask_full_name).load(config: nil)).to be_a(Cask::Cask)
// 33:       end
// 34:     end
// 35:   end
// 36: end
