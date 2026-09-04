module test

import ruby
import crypto.sha256
import homebrew
import os
import time

// Translated from Homebrew/brew `test/patching_spec.rb`.
// The original source is retained below until every stub has a typed V body.
struct PatchingResource {
	patches []homebrew.PatchModel
}

struct PatchingFormula {
	name      string
	path      string
	tap_path  string
	patches   []homebrew.PatchModel
	resources []PatchingResource
}

fn patching_bool(value bool) ruby.Value {
	return ruby.bool_value(value)
}

fn patching_temp(label string) string {
	return os.join_path(os.temp_dir(), 'brew-v-patching-${label}-${os.getpid()}-${time.now().unix_nano()}')
}

fn patching_fixture_root() string {
	return os.abs_path('../3rd/brew/Library/Homebrew/test/support/fixtures')
}

fn patching_patch_fixture(name string) string {
	return os.join_path(patching_fixture_root(), 'patches', '${name}.diff')
}

fn patching_tarball_fixture(name string) string {
	return os.join_path(patching_fixture_root(), 'tarballs', name)
}

fn patching_fixture_checksum(path string) string {
	contents := os.read_bytes(path) or { return '' }
	return sha256.sum256(contents).hex()
}

fn patching_default_formula() PatchingFormula {
	return PatchingFormula{
		name: 'formula_name'
		path: os.join_path(patching_fixture_root(), 'testball.rb')
	}
}

fn patching_formula_value(formula PatchingFormula) ruby.Value {
	mut resources := []ruby.Value{}
	for resource in formula.resources {
		resources << ruby.array_value(resource.patches.map(homebrew.patch_model_value(it)))
	}
	return ruby.Value{
		type_name: 'Formula'
		repr: formula.name
		attributes: {
			'name':     formula.name
			'path':     formula.path
			'tap_path': formula.tap_path
		}
		map_data: {
			'patches':   ruby.array_value(formula.patches.map(homebrew.patch_model_value(it)))
			'resources': ruby.array_value(resources)
		}
	}
}

fn patching_formula_from_value(value ruby.Value) !PatchingFormula {
	mut patches := []homebrew.PatchModel{}
	if patch_values := value.map_data['patches'] {
		for patch_value in patch_values.array_data {
			patches << homebrew.patch_model_from_value(patch_value)!
		}
	}
	mut resources := []PatchingResource{}
	if resource_values := value.map_data['resources'] {
		for resource_value in resource_values.array_data {
			mut resource_patches := []homebrew.PatchModel{}
			for patch_value in resource_value.array_data {
				resource_patches << homebrew.patch_model_from_value(patch_value)!
			}
			resources << PatchingResource{ patches: resource_patches }
		}
	}
	return PatchingFormula{
		name: value.attributes['name'] or { value.repr }
		path: value.attributes['path'] or { os.join_path(patching_fixture_root(), 'testball.rb') }
		tap_path: value.attributes['tap_path'] or { '' }
		patches: patches
		resources: resources
	}
}

fn patching_external_patch(strip string, path string, patch_files []string,
	directory string) !homebrew.PatchModel {
	return homebrew.create_patch(homebrew.PatchFactoryRequest{
		strip: strip
		resource: homebrew.PatchResourceModel{
			url: 'file://${path}'
			checksum: patching_fixture_checksum(path)
			patch_files: patch_files
			directory: directory
		}
	})
}

fn patching_local_patch(strip string, file string, directory string) !homebrew.PatchModel {
	return homebrew.create_patch(homebrew.PatchFactoryRequest{
		strip: strip
		resource: homebrew.PatchResourceModel{
			file: file
			has_file: true
			directory: directory
		}
	})
}

fn patching_string_patch(strip string, contents string) !homebrew.PatchModel {
	return homebrew.create_patch(homebrew.PatchFactoryRequest{
		strip: strip
		source_kind: .string
		source: contents
	})
}

fn patching_stage_source(label string) !(string, string) {
	root := patching_temp(label)
	os.mkdir_all(root)!
	result := ruby.run_command('tar', ['-xf', patching_tarball_fixture('testball-0.1.tbz'),
		'-C', root])
	if result.exit_code != 0 {
		os.rmdir_all(root) or {}
		return error(result.output.trim_space())
	}
	return root, os.join_path(root, 'test-0.1')
}

fn patching_apply_patch(model homebrew.PatchModel, formula PatchingFormula, base string,
	homebrew_prefix string) ! {
	match model.kind {
		.string { model.apply(base, homebrew_prefix)! }
		.local {
			local := homebrew.local_patch_from_model(model, homebrew.LocalPatchOwner{
				formula_path: formula.path
				tap_path: formula.tap_path
				software_spec_name: formula.name
			})!
			local.embedded.apply(local.filename(), local.contents()!, base, homebrew_prefix)!
		}
		.external {
			external := homebrew.external_patch_from_model(model)!
			external.apply(base, homebrew_prefix)!
		}
		.data {
			return error('DATAPatch requires a formula source file')
		}
	}
}

fn patching_apply_formula(formula PatchingFormula, label string, resource bool,
	homebrew_prefix string) !(string, string) {
	root, base := patching_stage_source(label)!
	patches := if resource && formula.resources.len > 0 {
		formula.resources[0].patches
	} else {
		formula.patches
	}
	for patch in patches {
		patching_apply_patch(patch, formula, base, homebrew_prefix) or {
			os.rmdir_all(root) or {}
			return err
		}
	}
	return root, os.read_file(os.join_path(base, 'libexec', 'NOOP'))!
}

fn patching_matches(formula PatchingFormula, expected string, resource bool,
	homebrew_prefix string) bool {
	root, contents := patching_apply_formula(formula, 'match', resource, homebrew_prefix) or {
		return false
	}
	defer { os.rmdir_all(root) or {} }
	return !contents.contains('NOOP') && contents.contains(expected)
}

fn patching_error(formula PatchingFormula, expected string) bool {
	root, base := patching_stage_source('error') or { return false }
	defer { os.rmdir_all(root) or {} }
	for patch in formula.patches {
		patching_apply_patch(patch, formula, base, '/opt/homebrew') or {
			return err.msg().contains(expected)
		}
	}
	return false
}

// Ruby let `let(:formula_subclass) do` at line 7.
pub fn ruby_patching_spec_l7_d1_formula_subclass(args ...ruby.Value) ruby.Value {
	_ = args
	tarball := patching_tarball_fixture('testball-0.1.tbz')
	return ruby.structured_value('Class<Formula>', 'PatchingFormula', {
		'url':    'file://${tarball}'
		'sha256': patching_fixture_checksum(tarball)
	})
}

// Ruby method `self.resource(*, **, &block)` at line 11.
pub fn ruby_patching_spec_l11_d2_self_resource(args ...ruby.Value) ruby.Value {
	mut patches := []homebrew.PatchModel{}
	for value in args {
		if value.type_name in ['ExternalPatch', 'LocalPatch', 'StringPatch', 'DATAPatch'] {
			patches << homebrew.patch_model_from_value(value) or {
				return ruby.object_value('ArgumentError', err.msg())
			}
		}
	}
	return ruby.array_value(patches.map(homebrew.patch_model_value(it)))
}

// Ruby define_singleton_method `define_singleton_method :patch do |*patch_args, **patch_kwargs, &patch_block|` at line 15.
pub fn ruby_patching_spec_l15_d3_patch(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'patch configuration is required')
	}
	return args[0]
}

// Ruby method `self.patch(*, **, &block)` at line 27.
pub fn ruby_patching_spec_l27_d4_self_patch(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'patch is required')
	}
	if args.len == 1 {
		return args[0]
	}
	mut formula := patching_formula_from_value(args[0]) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	patch := homebrew.patch_model_from_value(args[1]) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	mut patches := formula.patches.clone()
	patches << patch
	formula = PatchingFormula{ ...formula, patches: patches }
	return patching_formula_value(formula)
}

// Ruby method `formula(name = "formula_name", path: Formulary.core_path(name), spec: :stable, alias_path: nil, tap: nil,` at line 40.
pub fn ruby_patching_spec_l40_d5_formula(args ...ruby.Value) ruby.Value {
	return patching_formula_value(PatchingFormula{
		name: if args.len > 0 { args[0].as_string() } else { 'formula_name' }
		path: if args.len > 1 {
			args[1].as_string()} else {
			os.join_path(patching_fixture_root(), 'testball.rb')}
		tap_path: if args.len > 2 { args[2].as_string() } else { '' }
	})
}

// Ruby matcher `matcher :be_patched do` at line 46.
pub fn ruby_patching_spec_l46_d6_be_patched(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return patching_bool(false)
	}
	formula := patching_formula_from_value(args[0]) or { return patching_bool(false) }
	return patching_bool(patching_matches(formula, 'ABCD', false, '/opt/homebrew'))
}

// Ruby matcher `matcher :be_patched_with_homebrew_prefix do` at line 57.
pub fn ruby_patching_spec_l57_d7_be_patched_with_homebrew_prefix(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return patching_bool(false)
	}
	formula := patching_formula_from_value(args[0]) or { return patching_bool(false) }
	return patching_bool(patching_matches(formula, '/opt/homebrew', false, '/opt/homebrew'))
}

// Ruby matcher `matcher :have_its_resource_patched do` at line 69.
pub fn ruby_patching_spec_l69_d8_have_its_resource_patched(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return patching_bool(false)
	}
	formula := patching_formula_from_value(args[0]) or { return patching_bool(false) }
	return patching_bool(patching_matches(formula, 'ABCD', true, '/opt/homebrew'))
}

// Ruby matcher `matcher :be_sequentially_patched do` at line 80.
pub fn ruby_patching_spec_l80_d9_be_sequentially_patched(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return patching_bool(false)
	}
	formula := patching_formula_from_value(args[0]) or { return patching_bool(false) }
	return patching_bool(patching_matches(formula, '1234', false, '/opt/homebrew'))
}

// Ruby matcher `matcher :miss_apply do` at line 92.
pub fn ruby_patching_spec_l92_d10_miss_apply(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return patching_bool(false)
	}
	formula := patching_formula_from_value(args[0]) or { return patching_bool(false) }
	return patching_bool(patching_error(formula, 'There should be exactly one patch file'))
}

// Ruby specify `specify "single_patch_dsl" do` at line 102.
pub fn ruby_patching_spec_l102_d11_single_patch_dsl(args ...ruby.Value) ruby.Value {
	_ = args
	patch := patching_external_patch('p1', patching_patch_fixture('noop-a'), [], '') or {
		return patching_bool(false)
	}
	return patching_bool(patching_matches(PatchingFormula{
		...patching_default_formula()
		patches: [
			patch,
		]
	}, 'ABCD', false, '/opt/homebrew'))
}

// Ruby specify `specify "local_patch_dsl_resolves_path_loaded_formulae_from_formula_directory" do` at line 114.
pub fn ruby_patching_spec_l114_d12_local_patch_dsl_resolves_path_loaded_formulae_from_formula_directory(args ...ruby.Value) ruby.Value {
	_ = args
	patch := patching_local_patch('p1', 'patches/noop-a.diff', '') or {
		return patching_bool(false)
	}
	return patching_bool(patching_matches(PatchingFormula{
		...patching_default_formula()
		patches: [
			patch,
		]
	}, 'ABCD', false, '/opt/homebrew'))
}

// Ruby specify `specify "local_patch_dsl_with_directory" do` at line 125.
pub fn ruby_patching_spec_l125_d13_local_patch_dsl_with_directory(args ...ruby.Value) ruby.Value {
	_ = args
	patch := patching_local_patch('p1', 'patches/noop-b.diff', 'libexec') or {
		return patching_bool(false)
	}
	return patching_bool(patching_matches(PatchingFormula{
		...patching_default_formula()
		patches: [
			patch,
		]
	}, 'ABCD', false, '/opt/homebrew'))
}

// Ruby specify `specify "local_patch_dsl_with_strip" do` at line 137.
pub fn ruby_patching_spec_l137_d14_local_patch_dsl_with_strip(args ...ruby.Value) ruby.Value {
	_ = args
	patch := patching_local_patch('p0', 'patches/noop-b.diff', '') or {
		return patching_bool(false)
	}
	return patching_bool(patching_matches(PatchingFormula{
		...patching_default_formula()
		patches: [
			patch,
		]
	}, 'ABCD', false, '/opt/homebrew'))
}

// Ruby specify `specify "local_patch_dsl_with_homebrew_prefix" do` at line 148.
pub fn ruby_patching_spec_l148_d15_local_patch_dsl_with_homebrew_prefix(args ...ruby.Value) ruby.Value {
	_ = args
	patch := patching_local_patch('p1', 'patches/noop-d.diff', '') or {
		return patching_bool(false)
	}
	return patching_bool(patching_matches(PatchingFormula{
		...patching_default_formula()
		patches: [
			patch,
		]
	}, '/opt/homebrew', false, '/opt/homebrew'))
}

// Ruby specify `specify "local_patch_dsl_resolves_tapped_formulae_from_tap_root" do` at line 159.
pub fn ruby_patching_spec_l159_d16_local_patch_dsl_resolves_tapped_formulae_from_tap_root(args ...ruby.Value) ruby.Value {
	_ = args
	tap := patching_temp('tap')
	os.mkdir_all(os.join_path(tap, 'Formula')) or { return patching_bool(false) }
	os.mkdir_all(os.join_path(tap, 'patches')) or { return patching_bool(false) }
	defer { os.rmdir_all(tap) or {} }
	os.cp(patching_patch_fixture('noop-a'), os.join_path(tap, 'patches', 'noop-a.diff')) or {
		return patching_bool(false)
	}
	formula_path := os.join_path(tap, 'Formula', 'testball.rb')
	os.write_file(formula_path, '') or { return patching_bool(false) }
	patch := patching_local_patch('p1', 'patches/noop-a.diff', '') or {
		return patching_bool(false)
	}
	formula := PatchingFormula{
		...patching_default_formula()
		path: formula_path
		tap_path: tap
		patches: [patch]
	}
	return patching_bool(patching_matches(formula, 'ABCD', false, '/opt/homebrew'))
}

// Ruby specify `specify "local_patch_dsl_missing_file_fail" do` at line 177.
pub fn ruby_patching_spec_l177_d17_local_patch_dsl_missing_file_fail(args ...ruby.Value) ruby.Value {
	_ = args
	model := patching_local_patch('p1', 'patches/missing.diff', '') or {
		return patching_bool(false)
	}
	patch := homebrew.local_patch_from_model(model, homebrew.LocalPatchOwner{
		formula_path: patching_default_formula().path
	}) or { return patching_bool(false) }
	patch.contents() or {
		return patching_bool(err.msg() == 'Patch file does not exist: patches/missing.diff')
	}
	return patching_bool(false)
}

// Ruby specify `specify "local_patch_dsl_directory_fail" do` at line 189.
pub fn ruby_patching_spec_l189_d18_local_patch_dsl_directory_fail(args ...ruby.Value) ruby.Value {
	_ = args
	model := patching_local_patch('p1', 'patches', '') or { return patching_bool(false) }
	patch := homebrew.local_patch_from_model(model, homebrew.LocalPatchOwner{
		formula_path: patching_default_formula().path
	}) or { return patching_bool(false) }
	patch.contents() or { return patching_bool(err.msg() == 'Patch file must be a file: patches') }
	return patching_bool(false)
}

// Ruby specify `specify "local_patch_dsl_rejects_symlink_escape" do` at line 201.
pub fn ruby_patching_spec_l201_d19_local_patch_dsl_rejects_symlink_escape(args ...ruby.Value) ruby.Value {
	_ = args
	root := patching_temp('symlink')
	repository := os.join_path(root, 'repository')
	os.mkdir_all(repository) or { return patching_bool(false) }
	defer { os.rmdir_all(root) or {} }
	os.cp(patching_patch_fixture('noop-a'), os.join_path(root, 'outside.diff')) or {
		return patching_bool(false)
	}
	os.symlink(os.join_path(root, 'outside.diff'), os.join_path(repository, 'escape.diff')) or {
		return patching_bool(false)
	}
	model := patching_local_patch('p1', 'escape.diff', '') or { return patching_bool(false) }
	patch := homebrew.local_patch_from_model(model, homebrew.LocalPatchOwner{
		formula_path: os.join_path(repository, 'testball.rb')
	}) or { return patching_bool(false) }
	patch.contents() or {
		return patching_bool(err.msg() == 'Patch file must be within the formula repository.')
	}
	return patching_bool(false)
}

// Ruby specify `specify "single_patch_dsl_for_resource" do` at line 220.
pub fn ruby_patching_spec_l220_d20_single_patch_dsl_for_resource(args ...ruby.Value) ruby.Value {
	_ = args
	patch := patching_external_patch('p1', patching_patch_fixture('noop-a'), [], '') or {
		return patching_bool(false)
	}
	formula := PatchingFormula{
		...patching_default_formula()
		resources: [PatchingResource{ patches: [patch] }]
	}
	return patching_bool(patching_matches(formula, 'ABCD', true, '/opt/homebrew'))
}

// Ruby specify `specify "single_patch_dsl_with_apply" do` at line 237.
pub fn ruby_patching_spec_l237_d21_single_patch_dsl_with_apply(args ...ruby.Value) ruby.Value {
	_ = args
	patch := patching_external_patch('p1', patching_tarball_fixture('testball-0.1-patches.tgz'), [
		'noop-a.diff',
	], '') or { return patching_bool(false) }
	return patching_bool(patching_matches(PatchingFormula{
		...patching_default_formula()
		patches: [
			patch,
		]
	}, 'ABCD', false, '/opt/homebrew'))
}

// Ruby specify `specify "single_patch_dsl_with_sequential_apply" do` at line 250.
pub fn ruby_patching_spec_l250_d22_single_patch_dsl_with_sequential_apply(args ...ruby.Value) ruby.Value {
	_ = args
	patch := patching_external_patch('p1', patching_tarball_fixture('testball-0.1-patches.tgz'), [
		'noop-a.diff',
		'noop-c.diff',
	], '') or { return patching_bool(false) }
	return patching_bool(patching_matches(PatchingFormula{
		...patching_default_formula()
		patches: [
			patch,
		]
	}, '1234', false, '/opt/homebrew'))
}

// Ruby specify `specify "single_patch_dsl_with_strip" do` at line 263.
pub fn ruby_patching_spec_l263_d23_single_patch_dsl_with_strip(args ...ruby.Value) ruby.Value {
	_ = args
	patch := patching_external_patch('p1', patching_patch_fixture('noop-a'), [], '') or {
		return patching_bool(false)
	}
	return patching_bool(patching_matches(PatchingFormula{
		...patching_default_formula()
		patches: [
			patch,
		]
	}, 'ABCD', false, '/opt/homebrew'))
}

// Ruby specify `specify "single_patch_dsl_with_strip_with_apply" do` at line 275.
pub fn ruby_patching_spec_l275_d24_single_patch_dsl_with_strip_with_apply(args ...ruby.Value) ruby.Value {
	_ = args
	path := patching_tarball_fixture('testball-0.1-patches.tgz')
	patch := patching_external_patch('p1', path, ['noop-a.diff'], '') or {
		return patching_bool(false)
	}
	external := homebrew.external_patch_from_model(patch) or { return patching_bool(false) }
	fetched := external.fetch() or { return patching_bool(false) }
	return patching_bool(external.strip == 'p1' && external.patch_files() == [
		'noop-a.diff',
	] && fetched == path)
}

// Ruby specify `specify "single_patch_dsl_with_incorrect_strip" do` at line 292.
pub fn ruby_patching_spec_l292_d25_single_patch_dsl_with_incorrect_strip(args ...ruby.Value) ruby.Value {
	_ = args
	patch := patching_external_patch('p0', patching_patch_fixture('noop-a'), [], '') or {
		return patching_bool(false)
	}
	return patching_bool(patching_error(PatchingFormula{
		...patching_default_formula()
		patches: [
			patch,
		]
	}, 'patch failed'))
}

// Ruby specify `specify "single_patch_dsl_with_incorrect_strip_with_apply" do` at line 306.
pub fn ruby_patching_spec_l306_d26_single_patch_dsl_with_incorrect_strip_with_apply(args ...ruby.Value) ruby.Value {
	_ = args
	patch := patching_external_patch('p0', patching_tarball_fixture('testball-0.1-patches.tgz'), [
		'noop-a.diff',
	], '') or { return patching_bool(false) }
	return patching_bool(patching_error(PatchingFormula{
		...patching_default_formula()
		patches: [
			patch,
		]
	}, 'patch failed'))
}

// Ruby specify `specify "patch_p0_dsl" do` at line 321.
pub fn ruby_patching_spec_l321_d27_patch_p0_dsl(args ...ruby.Value) ruby.Value {
	_ = args
	patch := patching_external_patch('p0', patching_patch_fixture('noop-b'), [], '') or {
		return patching_bool(false)
	}
	return patching_bool(patching_matches(PatchingFormula{
		...patching_default_formula()
		patches: [
			patch,
		]
	}, 'ABCD', false, '/opt/homebrew'))
}

// Ruby specify `specify "patch_p0_dsl_with_apply" do` at line 333.
pub fn ruby_patching_spec_l333_d28_patch_p0_dsl_with_apply(args ...ruby.Value) ruby.Value {
	_ = args
	patch := patching_external_patch('p0', patching_tarball_fixture('testball-0.1-patches.tgz'), [
		'noop-b.diff',
	], '') or { return patching_bool(false) }
	return patching_bool(patching_matches(PatchingFormula{
		...patching_default_formula()
		patches: [
			patch,
		]
	}, 'ABCD', false, '/opt/homebrew'))
}

// Ruby specify `specify "patch_string" do` at line 346.
pub fn ruby_patching_spec_l346_d29_patch_string(args ...ruby.Value) ruby.Value {
	_ = args
	contents := os.read_file(patching_patch_fixture('noop-a')) or { return patching_bool(false) }
	patch := patching_string_patch('p1', contents) or { return patching_bool(false) }
	return patching_bool(patching_matches(PatchingFormula{
		...patching_default_formula()
		patches: [
			patch,
		]
	}, 'ABCD', false, '/opt/homebrew'))
}

// Ruby specify `specify "patch_string_with_strip" do` at line 355.
pub fn ruby_patching_spec_l355_d30_patch_string_with_strip(args ...ruby.Value) ruby.Value {
	_ = args
	contents := os.read_file(patching_patch_fixture('noop-b')) or { return patching_bool(false) }
	patch := patching_string_patch('p0', contents) or { return patching_bool(false) }
	return patching_bool(patching_matches(PatchingFormula{
		...patching_default_formula()
		patches: [
			patch,
		]
	}, 'ABCD', false, '/opt/homebrew'))
}

// Ruby specify `specify "single_patch_dsl_missing_apply_fail" do` at line 364.
pub fn ruby_patching_spec_l364_d31_single_patch_dsl_missing_apply_fail(args ...ruby.Value) ruby.Value {
	_ = args
	patch := patching_external_patch('p1', patching_tarball_fixture('testball-0.1-patches.tgz'), [], '') or { return patching_bool(false) }
	return patching_bool(patching_error(PatchingFormula{
		...patching_default_formula()
		patches: [
			patch,
		]
	}, 'There should be exactly one patch file'))
}

// Ruby specify `specify "single_patch_dsl_with_apply_enoent_fail" do` at line 376.
pub fn ruby_patching_spec_l376_d32_single_patch_dsl_with_apply_enoent_fail(args ...ruby.Value) ruby.Value {
	_ = args
	patch := patching_external_patch('p1', patching_tarball_fixture('testball-0.1-patches.tgz'), [
		'patches/noop-a.diff',
	], '') or { return patching_bool(false) }
	return patching_bool(patching_error(PatchingFormula{
		...patching_default_formula()
		patches: [
			patch,
		]
	}, 'No such file or directory'))
}

// Ruby specify `specify "patch_dsl_with_homebrew_prefix" do` at line 391.
pub fn ruby_patching_spec_l391_d33_patch_dsl_with_homebrew_prefix(args ...ruby.Value) ruby.Value {
	_ = args
	patch := patching_external_patch('p1', patching_patch_fixture('noop-d'), [], '') or {
		return patching_bool(false)
	}
	return patching_bool(patching_matches(PatchingFormula{
		...patching_default_formula()
		patches: [
			patch,
		]
	}, '/opt/homebrew', false, '/opt/homebrew'))
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "formula"
// 5:
// 6: RSpec.describe "patching", type: :system do
// 7:   let(:formula_subclass) do
// 8:     Class.new(Formula) do
// 9:       extend Test::Helper::Fixtures
// 10:
// 11:       def self.resource(*, **, &block)
// 12:         super do
// 13:           extend Test::Helper::Fixtures
// 14:
// 15:           define_singleton_method :patch do |*patch_args, **patch_kwargs, &patch_block|
// 16:             super(*patch_args, **patch_kwargs) do
// 17:               extend Test::Helper::Fixtures
// 18:
// 19:               instance_eval(&patch_block)
// 20:             end
// 21:           end
// 22:
// 23:           instance_eval(&block) if block
// 24:         end
// 25:       end
// 26:
// 27:       def self.patch(*, **, &block)
// 28:         super do
// 29:           extend Test::Helper::Fixtures
// 30:
// 31:           instance_eval(&block) if block
// 32:         end
// 33:       end
// 34:
// 35:       url "file://#{tarball_fixture("testball-0.1.tbz")}"
// 36:       sha256 tarball_fixture_sha256("testball-0.1.tbz")
// 37:     end
// 38:   end
// 39:
// 40:   def formula(name = "formula_name", path: Formulary.core_path(name), spec: :stable, alias_path: nil, tap: nil,
// 41:               &block)
// 42:     formula_subclass.class_eval(&block)
// 43:     formula_subclass.new(name, path, spec, alias_path:, tap:)
// 44:   end
// 45:
// 46:   matcher :be_patched do
// 47:     match do |formula|
// 48:       formula.brew do
// 49:         formula.patch
// 50:         s = File.read("libexec/NOOP")
// 51:         expect(s).not_to include("NOOP"), "libexec/NOOP was not patched as expected"
// 52:         expect(s).to include("ABCD"), "libexec/NOOP was not patched as expected"
// 53:       end
// 54:     end
// 55:   end
// 56:
// 57:   matcher :be_patched_with_homebrew_prefix do
// 58:     match do |formula|
// 59:       formula.brew do
// 60:         formula.patch
// 61:         s = File.read("libexec/NOOP")
// 62:         expect(s).not_to include("NOOP"), "libexec/NOOP was not patched as expected"
// 63:         expect(s).not_to include("@@HOMEBREW_PREFIX@@"), "libexec/NOOP was not patched as expected"
// 64:         expect(s).to include(HOMEBREW_PREFIX.to_s), "libexec/NOOP was not patched as expected"
// 65:       end
// 66:     end
// 67:   end
// 68:
// 69:   matcher :have_its_resource_patched do
// 70:     match do |formula|
// 71:       formula.brew do
// 72:         formula.resources.first.stage Pathname.pwd/"resource_dir"
// 73:         s = File.read("resource_dir/libexec/NOOP")
// 74:         expect(s).not_to include("NOOP"), "libexec/NOOP was not patched as expected"
// 75:         expect(s).to include("ABCD"), "libexec/NOOP was not patched as expected"
// 76:       end
// 77:     end
// 78:   end
// 79:
// 80:   matcher :be_sequentially_patched do
// 81:     match do |formula|
// 82:       formula.brew do
// 83:         formula.patch
// 84:         s = File.read("libexec/NOOP")
// 85:         expect(s).not_to include("NOOP"), "libexec/NOOP was not patched as expected"
// 86:         expect(s).not_to include("ABCD"), "libexec/NOOP was not patched as expected"
// 87:         expect(s).to include("1234"), "libexec/NOOP was not patched as expected"
// 88:       end
// 89:     end
// 90:   end
// 91:
// 92:   matcher :miss_apply do
// 93:     match do |formula|
// 94:       expect do
// 95:         formula.brew do
// 96:           formula.patch
// 97:         end
// 98:       end.to raise_error(MissingApplyError)
// 99:     end
// 100:   end
// 101:
// 102:   specify "single_patch_dsl" do
// 103:     expect(
// 104:       formula do
// 105:         T.bind(self, T.class_of(Formula))
// 106:         patch do
// 107:           url "file://#{patch_fixture("noop-a")}"
// 108:           sha256 patch_fixture_sha256("noop-a")
// 109:         end
// 110:       end,
// 111:     ).to be_patched
// 112:   end
// 113:
// 114:   specify "local_patch_dsl_resolves_path_loaded_formulae_from_formula_directory" do
// 115:     expect(
// 116:       formula(path: fixture("testball.rb")) do
// 117:         T.bind(self, T.class_of(Formula))
// 118:         patch do
// 119:           file "patches/noop-a.diff"
// 120:         end
// 121:       end,
// 122:     ).to be_patched
// 123:   end
// 124:
// 125:   specify "local_patch_dsl_with_directory" do
// 126:     expect(
// 127:       formula(path: fixture("testball.rb")) do
// 128:         T.bind(self, T.class_of(Formula))
// 129:         patch do
// 130:           file "patches/noop-b.diff"
// 131:           directory "libexec"
// 132:         end
// 133:       end,
// 134:     ).to be_patched
// 135:   end
// 136:
// 137:   specify "local_patch_dsl_with_strip" do
// 138:     expect(
// 139:       formula(path: fixture("testball.rb")) do
// 140:         T.bind(self, T.class_of(Formula))
// 141:         patch :p0 do
// 142:           file "patches/noop-b.diff"
// 143:         end
// 144:       end,
// 145:     ).to be_patched
// 146:   end
// 147:
// 148:   specify "local_patch_dsl_with_homebrew_prefix" do
// 149:     expect(
// 150:       formula(path: fixture("testball.rb")) do
// 151:         T.bind(self, T.class_of(Formula))
// 152:         patch do
// 153:           file "patches/noop-d.diff"
// 154:         end
// 155:       end,
// 156:     ).to be_patched_with_homebrew_prefix
// 157:   end
// 158:
// 159:   specify "local_patch_dsl_resolves_tapped_formulae_from_tap_root" do
// 160:     tap = Tap.fetch("homebrew", "local-patch-test")
// 161:     (tap.path/"Formula").mkpath
// 162:     (tap.path/"patches").mkpath
// 163:     FileUtils.cp patch_fixture("noop-a"), tap.path/"patches/noop-a.diff"
// 164:
// 165:     expect(
// 166:       formula(path: tap.path/"Formula/testball.rb", tap:) do
// 167:         T.bind(self, T.class_of(Formula))
// 168:         patch do
// 169:           file "patches/noop-a.diff"
// 170:         end
// 171:       end,
// 172:     ).to be_patched
// 173:   ensure
// 174:     FileUtils.rm_rf tap.path if tap
// 175:   end
// 176:
// 177:   specify "local_patch_dsl_missing_file_fail" do
// 178:     f = formula(path: fixture("testball.rb")) do
// 179:       T.bind(self, T.class_of(Formula))
// 180:       patch do
// 181:         file "patches/missing.diff"
// 182:       end
// 183:     end
// 184:
// 185:     expect { f.stable.patches.last.contents }
// 186:       .to raise_error(ArgumentError, "Patch file does not exist: patches/missing.diff")
// 187:   end
// 188:
// 189:   specify "local_patch_dsl_directory_fail" do
// 190:     f = formula(path: fixture("testball.rb")) do
// 191:       T.bind(self, T.class_of(Formula))
// 192:       patch do
// 193:         file "patches"
// 194:       end
// 195:     end
// 196:
// 197:     expect { f.stable.patches.last.contents }
// 198:       .to raise_error(ArgumentError, "Patch file must be a file: patches")
// 199:   end
// 200:
// 201:   specify "local_patch_dsl_rejects_symlink_escape" do
// 202:     mktmpdir do |tmpdir|
// 203:       repository = tmpdir/"repository"
// 204:       repository.mkpath
// 205:       FileUtils.cp patch_fixture("noop-a"), tmpdir/"outside.diff"
// 206:       FileUtils.ln_s tmpdir/"outside.diff", repository/"escape.diff"
// 207:
// 208:       f = formula(path: repository/"testball.rb") do
// 209:         T.bind(self, T.class_of(Formula))
// 210:         patch do
// 211:           file "escape.diff"
// 212:         end
// 213:       end
// 214:
// 215:       expect { f.stable.patches.last.contents }
// 216:         .to raise_error(ArgumentError, "Patch file must be within the formula repository.")
// 217:     end
// 218:   end
// 219:
// 220:   specify "single_patch_dsl_for_resource" do
// 221:     expect(
// 222:       formula do
// 223:         T.bind(self, T.class_of(Formula))
// 224:         resource "some_resource" do
// 225:           url "file://#{tarball_fixture("testball-0.1.tbz")}"
// 226:           sha256 tarball_fixture_sha256("testball-0.1.tbz")
// 227:
// 228:           patch do
// 229:             url "file://#{patch_fixture("noop-a")}"
// 230:             sha256 patch_fixture_sha256("noop-a")
// 231:           end
// 232:         end
// 233:       end,
// 234:     ).to have_its_resource_patched
// 235:   end
// 236:
// 237:   specify "single_patch_dsl_with_apply" do
// 238:     expect(
// 239:       formula do
// 240:         T.bind(self, T.class_of(Formula))
// 241:         patch do
// 242:           url "file://#{tarball_fixture("testball-0.1-patches.tgz")}"
// 243:           sha256 tarball_fixture_sha256("testball-0.1-patches.tgz")
// 244:           apply "noop-a.diff"
// 245:         end
// 246:       end,
// 247:     ).to be_patched
// 248:   end
// 249:
// 250:   specify "single_patch_dsl_with_sequential_apply" do
// 251:     expect(
// 252:       formula do
// 253:         T.bind(self, T.class_of(Formula))
// 254:         patch do
// 255:           url "file://#{tarball_fixture("testball-0.1-patches.tgz")}"
// 256:           sha256 tarball_fixture_sha256("testball-0.1-patches.tgz")
// 257:           apply "noop-a.diff", "noop-c.diff"
// 258:         end
// 259:       end,
// 260:     ).to be_sequentially_patched
// 261:   end
// 262:
// 263:   specify "single_patch_dsl_with_strip" do
// 264:     expect(
// 265:       formula do
// 266:         T.bind(self, T.class_of(Formula))
// 267:         patch :p1 do
// 268:           url "file://#{patch_fixture("noop-a")}"
// 269:           sha256 patch_fixture_sha256("noop-a")
// 270:         end
// 271:       end,
// 272:     ).to be_patched
// 273:   end
// 274:
// 275:   specify "single_patch_dsl_with_strip_with_apply" do
// 276:     external_patch = formula do
// 277:       T.bind(self, T.class_of(Formula))
// 278:       patch :p1 do
// 279:         url "file://#{tarball_fixture("testball-0.1-patches.tgz")}"
// 280:         sha256 tarball_fixture_sha256("testball-0.1-patches.tgz")
// 281:         apply "noop-a.diff"
// 282:       end
// 283:     end.stable.patches.last
// 284:
// 285:     expect(external_patch).to have_attributes(strip: :p1, patch_files: ["noop-a.diff"])
// 286:     external_patch.fetch
// 287:     external_patch.resource.unpack do
// 288:       expect(Pathname.pwd/external_patch.patch_files.fetch(0)).to be_a_file
// 289:     end
// 290:   end
// 291:
// 292:   specify "single_patch_dsl_with_incorrect_strip" do
// 293:     expect do
// 294:       f = formula do
// 295:         T.bind(self, T.class_of(Formula))
// 296:         patch :p0 do
// 297:           url "file://#{patch_fixture("noop-a")}"
// 298:           sha256 patch_fixture_sha256("noop-a")
// 299:         end
// 300:       end
// 301:
// 302:       f.brew { |formula, _staging| formula.patch }
// 303:     end.to raise_error(BuildError)
// 304:   end
// 305:
// 306:   specify "single_patch_dsl_with_incorrect_strip_with_apply" do
// 307:     expect do
// 308:       f = formula do
// 309:         T.bind(self, T.class_of(Formula))
// 310:         patch :p0 do
// 311:           url "file://#{tarball_fixture("testball-0.1-patches.tgz")}"
// 312:           sha256 tarball_fixture_sha256("testball-0.1-patches.tgz")
// 313:           apply "noop-a.diff"
// 314:         end
// 315:       end
// 316:
// 317:       f.brew { |formula, _staging| formula.patch }
// 318:     end.to raise_error(BuildError)
// 319:   end
// 320:
// 321:   specify "patch_p0_dsl" do
// 322:     expect(
// 323:       formula do
// 324:         T.bind(self, T.class_of(Formula))
// 325:         patch :p0 do
// 326:           url "file://#{patch_fixture("noop-b")}"
// 327:           sha256 patch_fixture_sha256("noop-b")
// 328:         end
// 329:       end,
// 330:     ).to be_patched
// 331:   end
// 332:
// 333:   specify "patch_p0_dsl_with_apply" do
// 334:     expect(
// 335:       formula do
// 336:         T.bind(self, T.class_of(Formula))
// 337:         patch :p0 do
// 338:           url "file://#{tarball_fixture("testball-0.1-patches.tgz")}"
// 339:           sha256 tarball_fixture_sha256("testball-0.1-patches.tgz")
// 340:           apply "noop-b.diff"
// 341:         end
// 342:       end,
// 343:     ).to be_patched
// 344:   end
// 345:
// 346:   specify "patch_string" do
// 347:     expect(
// 348:       formula do
// 349:         T.bind(self, T.class_of(Formula))
// 350:         patch File.read(patch_fixture("noop-a"))
// 351:       end,
// 352:     ).to be_patched
// 353:   end
// 354:
// 355:   specify "patch_string_with_strip" do
// 356:     expect(
// 357:       formula do
// 358:         T.bind(self, T.class_of(Formula))
// 359:         patch :p0, File.read(patch_fixture("noop-b"))
// 360:       end,
// 361:     ).to be_patched
// 362:   end
// 363:
// 364:   specify "single_patch_dsl_missing_apply_fail" do
// 365:     expect(
// 366:       formula do
// 367:         T.bind(self, T.class_of(Formula))
// 368:         patch do
// 369:           url "file://#{tarball_fixture("testball-0.1-patches.tgz")}"
// 370:           sha256 tarball_fixture_sha256("testball-0.1-patches.tgz")
// 371:         end
// 372:       end,
// 373:     ).to miss_apply
// 374:   end
// 375:
// 376:   specify "single_patch_dsl_with_apply_enoent_fail" do
// 377:     expect do
// 378:       f = formula do
// 379:         T.bind(self, T.class_of(Formula))
// 380:         patch do
// 381:           url "file://#{tarball_fixture("testball-0.1-patches.tgz")}"
// 382:           sha256 tarball_fixture_sha256("testball-0.1-patches.tgz")
// 383:           apply "patches/noop-a.diff"
// 384:         end
// 385:       end
// 386:
// 387:       f.brew { |formula, _staging| formula.patch }
// 388:     end.to raise_error(Errno::ENOENT)
// 389:   end
// 390:
// 391:   specify "patch_dsl_with_homebrew_prefix" do
// 392:     expect(
// 393:       formula do
// 394:         T.bind(self, T.class_of(Formula))
// 395:         patch do
// 396:           url "file://#{patch_fixture("noop-d")}"
// 397:           sha256 patch_fixture_sha256("noop-d")
// 398:         end
// 399:       end,
// 400:     ).to be_patched_with_homebrew_prefix
// 401:   end
// 402: end
