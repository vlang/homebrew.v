module dev_cmd

import ruby
import homebrew.dev_cmd as production_dev_cmd
import os
import time

// Translated from Homebrew/brew `test/dev-cmd/pr-pull_spec.rb`.
// The original source is retained below until every stub has a typed V body.

fn pr_pull_spec_formula_rebuild() string {
	return 'class Foo < Formula\n' + '  desc "Helpful description"\n' + '  url "https://brew.sh/foo-1.0.tgz"\n' + 'end\n'
}

fn pr_pull_spec_formula_revision() string {
	return 'class Foo < Formula\n' + '  url "https://brew.sh/foo-1.0.tgz"\n' + '  revision 1\n' + 'end\n'
}

fn pr_pull_spec_formula_version() string {
	return 'class Foo < Formula\n' + '  url "https://brew.sh/foo-2.0.tgz"\n' + 'end\n'
}

fn pr_pull_spec_formula() string {
	return 'class Foo < Formula\n' + '  url "https://brew.sh/foo-1.0.tgz"\n' + 'end\n'
}

fn pr_pull_spec_cask_rebuild() string {
	return 'cask "food" do\n' + '  desc "Helpful description"\n' + '  version "1.0"\n' + '  sha256 "a"\n' + '  url "https://brew.sh/food-#{version}.tgz"\n' + 'end\n'
}

fn pr_pull_spec_cask_checksum() string {
	return 'cask "food" do\n' + '  desc "Helpful description"\n' + '  version "1.0"\n' + '  sha256 "b"\n' + '  url "https://brew.sh/food-#{version}.tgz"\n' + 'end\n'
}

fn pr_pull_spec_cask_version() string {
	return 'cask "food" do\n' + '  version "2.0"\n' + '  sha256 "a"\n' + '  url "https://brew.sh/food-#{version}.tgz"\n' + 'end\n'
}

fn pr_pull_spec_cask() string {
	return 'cask "food" do\n' + '  version "1.0"\n' + '  sha256 "a"\n' + '  url "https://brew.sh/food-#{version}.tgz"\n' + 'end\n'
}

fn pr_pull_spec_root(label string) string {
	return os.join_path(os.temp_dir(), 'brew-v-pr-pull-spec-${label}-${os.getpid()}-${time.now().unix_micro()}')
}

fn pr_pull_spec_tap(root string) production_dev_cmd.PrPullTap {
	return production_dev_cmd.PrPullTap{
		name: 'homebrew/foo'
		user: 'Homebrew'
		full_repository: 'homebrew-foo'
		path: root
		formula_dir: os.join_path(root, 'Formula')
		cask_dir: os.join_path(root, 'Casks')
		git_executable: 'git'
	}
}

fn pr_pull_spec_overrides() map[string]production_dev_cmd.PrPullPackage {
	return {
		pr_pull_spec_formula():          production_dev_cmd.PrPullPackage{
			name: 'foo'
			version: '1.0'
		}
		pr_pull_spec_formula_rebuild():  production_dev_cmd.PrPullPackage{
			name: 'foo'
			version: '1.0'
		}
		pr_pull_spec_formula_revision(): production_dev_cmd.PrPullPackage{
			name: 'foo'
			version: '1.0'
			revision: 1
		}
		pr_pull_spec_formula_version():  production_dev_cmd.PrPullPackage{
			name: 'foo'
			version: '2.0'
		}
		pr_pull_spec_cask():             production_dev_cmd.PrPullPackage{
			name: 'food'
			version: '1.0'
			sha256: 'a'
			is_cask: true
		}
		pr_pull_spec_cask_rebuild():     production_dev_cmd.PrPullPackage{
			name: 'food'
			version: '1.0'
			sha256: 'a'
			is_cask: true
		}
		pr_pull_spec_cask_checksum():    production_dev_cmd.PrPullPackage{
			name: 'food'
			version: '1.0'
			sha256: 'b'
			is_cask: true
		}
		pr_pull_spec_cask_version():     production_dev_cmd.PrPullPackage{
			name: 'food'
			version: '2.0'
			sha256: 'a'
			is_cask: true
		}
	}
}

fn pr_pull_spec_exec(argv []string) !string {
	result := os.execute(argv.map(os.quoted_path(it)).join(' '))
	if result.exit_code != 0 {
		return error('${argv.join(' ')} failed: ${result.output}')
	}
	return result.output.trim_space()
}

fn pr_pull_spec_git(root string, argv []string) !string {
	mut command := ['git', '-C', root]
	command << argv
	return pr_pull_spec_exec(command)
}

fn pr_pull_spec_init_repository(root string) ! {
	os.mkdir_all(root)!
	pr_pull_spec_git(root, ['init', '--quiet'])!
	pr_pull_spec_git(root, ['config', 'user.name', 'Brew Test'])!
	pr_pull_spec_git(root, ['config', 'user.email', 'brew@example.com'])!
}

fn pr_pull_spec_write(root string, relative string, contents string) ! {
	path := os.join_path(root, relative)
	os.mkdir_all(os.dir(path))!
	os.write_file(path, contents)!
}

fn pr_pull_spec_commit(root string, relative string, message string, author string) !string {
	pr_pull_spec_git(root, ['add', relative])!
	mut argv := ['commit', '--quiet', '-m', message]
	if author != '' {
		argv << '--author=${author}'
	}
	pr_pull_spec_git(root, argv)!
	return pr_pull_spec_git(root, ['rev-parse', 'HEAD'])
}

fn pr_pull_spec_execute_effects(effects []production_dev_cmd.PrPullEffect) ! {
	for effect in effects {
		if effect.kind in ['safe_system', 'cherry_pick', 'system'] {
			pr_pull_spec_exec(effect.argv)!
		}
	}
}

fn pr_pull_spec_bump_subject(old_contents string, new_contents string, subject_path string,
	reason string, reason_provided bool) string {
	root := os.dir(os.dir(subject_path))
	return production_dev_cmd.determine_pr_pull_bump_subject(production_dev_cmd.PrPullBumpInput{
		tap: pr_pull_spec_tap(root)
		old_contents: old_contents
		new_contents: new_contents
		subject_path: subject_path
		reason: reason
		reason_provided: reason_provided
		overrides: pr_pull_spec_overrides()
	})
}

fn pr_pull_spec_squash_series(root string, relative string, original string, commits []string,
	old_contents string, new_contents string, messages map[string]string, authors []string,
	expected_subject string, expected_coauthor string) !bool {
	tap := pr_pull_spec_tap(root)
	plan := production_dev_cmd.autosquash_pr_pull(production_dev_cmd.PrPullAutosquashInput{
		original_commit: original
		tap: tap
		commits: commits
		commit_files: {
			commits[0]: [relative]
			commits[1]: [relative]
		}
		original_head: commits.last()
	})
	if plan.error != '' || plan.actions.len != 1 || plan.actions[0].kind != 'squash'
		|| plan.actions[0].commits != commits {
		return false
	}
	pr_pull_spec_execute_effects(plan.effects)!
	original_date := pr_pull_spec_git(root, ['show', '-s', '--format=%aI', commits[0]])!
	rewrite := production_dev_cmd.squash_pr_pull_package_commits(production_dev_cmd.PrPullSquashInput{
		commits: commits
		file: relative
		tap: tap
		commit_messages: messages
		authors: authors
		original_date: original_date
		old_contents: old_contents
		new_contents: new_contents
		overrides: pr_pull_spec_overrides()
	})!
	if rewrite.subject != expected_subject {
		return false
	}
	pr_pull_spec_execute_effects(rewrite.effects)!
	message := pr_pull_spec_git(root, ['log', '-1', '--format=%B'])!
	contents := os.read_file(os.join_path(root, relative))!
	return message.contains(expected_subject) && message.contains('Co-authored-by: ${expected_coauthor}')
		&& contents == new_contents
}

// Ruby let `let(:pr_pull) { described_class.new(["foo"]) }` at line 10.
pub fn ruby_pr_pull_spec_l10_d1_pr_pull(args ...ruby.Value) ruby.Value {
	_ = args
	parsed := production_dev_cmd.parse_pr_pull_args(['foo']) or {
		return ruby.object_value('Error', err.msg())
	}
	return ruby.structured_value('Homebrew::DevCmd::PrPull', 'foo', {
		'named': parsed.named.join(',')
	})
}

// Ruby let `let(:formula_rebuild) do` at line 11.
pub fn ruby_pr_pull_spec_l11_d2_formula_rebuild(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(pr_pull_spec_formula_rebuild())
}

// Ruby let `let(:formula_revision) do` at line 19.
pub fn ruby_pr_pull_spec_l19_d3_formula_revision(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(pr_pull_spec_formula_revision())
}

// Ruby let `let(:formula_version) do` at line 27.
pub fn ruby_pr_pull_spec_l27_d4_formula_version(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(pr_pull_spec_formula_version())
}

// Ruby let `let(:formula) do` at line 34.
pub fn ruby_pr_pull_spec_l34_d5_formula(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(pr_pull_spec_formula())
}

// Ruby let `let(:cask_rebuild) do` at line 41.
pub fn ruby_pr_pull_spec_l41_d6_cask_rebuild(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(pr_pull_spec_cask_rebuild())
}

// Ruby let `let(:cask_checksum) do` at line 51.
pub fn ruby_pr_pull_spec_l51_d7_cask_checksum(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(pr_pull_spec_cask_checksum())
}

// Ruby let `let(:cask_version) do` at line 61.
pub fn ruby_pr_pull_spec_l61_d8_cask_version(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(pr_pull_spec_cask_version())
}

// Ruby let `let(:cask) do` at line 70.
pub fn ruby_pr_pull_spec_l70_d9_cask(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(pr_pull_spec_cask())
}

// Ruby let `let(:tap) { Tap.fetch("Homebrew", "foo") }` at line 79.
pub fn ruby_pr_pull_spec_l79_d10_tap(args ...ruby.Value) ruby.Value {
	root := if args.len > 0 { args[0].as_string() } else { '/tmp/homebrew/homebrew-foo' }
	tap := pr_pull_spec_tap(root)
	return ruby.structured_value('Tap', tap.name, {
		'user':       tap.user
		'repository': tap.full_repository
		'path':       tap.path
	})
}

// Ruby let `let(:formula_file) { tap.path/"Formula/foo.rb" }` at line 80.
pub fn ruby_pr_pull_spec_l80_d11_formula_file(args ...ruby.Value) ruby.Value {
	root := if args.len > 0 { args[0].as_string() } else { '/tmp/homebrew/homebrew-foo' }
	return ruby.string_value(os.join_path(root, 'Formula', 'foo.rb'))
}

// Ruby let `let(:cask_file) { tap.cask_dir/"food.rb" }` at line 81.
pub fn ruby_pr_pull_spec_l81_d12_cask_file(args ...ruby.Value) ruby.Value {
	root := if args.len > 0 { args[0].as_string() } else { '/tmp/homebrew/homebrew-foo' }
	return ruby.string_value(os.join_path(root, 'Casks', 'food.rb'))
}

// Ruby let `let(:path) { Pathname(HOMEBREW_TAP_DIRECTORY/"homebrew/homebrew-foo") }` at line 82.
pub fn ruby_pr_pull_spec_l82_d13_path(args ...ruby.Value) ruby.Value {
	root := if args.len > 0 { args[0].as_string() } else { '/tmp/homebrew/homebrew-foo' }
	return ruby.string_value(root)
}

// Ruby it `it "outputs the pull request head SHA" do` at line 89.
pub fn ruby_pr_pull_spec_l89_d14_outputs(args ...ruby.Value) ruby.Value {
	_ = args
	result := production_dev_cmd.check_pr_pull_head_sha(production_dev_cmd.PrPullHeadInput{
		user: 'Homebrew'
		repo: 'foo'
		pull_request: '1'
		commits: ['actual']
	}) or { return ruby.object_value('Error', err.msg()) }
	return ruby.string_value(result.message)
}

// Ruby it `it "squashes a formula or cask correctly" do` at line 99.
pub fn ruby_pr_pull_spec_l99_d15_squashes(args ...ruby.Value) ruby.Value {
	_ = args
	root := pr_pull_spec_root('squash')
	defer { os.rmdir_all(root) or {} }
	pr_pull_spec_init_repository(root) or { return ruby.bool_value(false) }

	formula_file := os.join_path('Formula', 'foo.rb')
	pr_pull_spec_write(root, formula_file, pr_pull_spec_formula()) or {
		return ruby.bool_value(false)
	}
	formula_original := pr_pull_spec_commit(root, formula_file, 'foo 1.0 (new formula)', '') or {
		return ruby.bool_value(false)
	}
	pr_pull_spec_write(root, formula_file, pr_pull_spec_formula_revision()) or {
		return ruby.bool_value(false)
	}
	formula_revision_commit := pr_pull_spec_commit(root, formula_file, 'revision', '') or {
		return ruby.bool_value(false)
	}
	secondary_author := 'Someone Else <me@example.com>'
	pr_pull_spec_write(root, formula_file, pr_pull_spec_formula_version()) or {
		return ruby.bool_value(false)
	}
	formula_version_commit := pr_pull_spec_commit(root, formula_file, 'version', secondary_author) or {
		return ruby.bool_value(false)
	}
	formula_ok := pr_pull_spec_squash_series(root, formula_file, formula_original, [
		formula_revision_commit,
		formula_version_commit,
	], pr_pull_spec_formula(), pr_pull_spec_formula_version(), {
		formula_revision_commit: 'revision'
		formula_version_commit:  'version'
	}, ['Brew Test <brew@example.com>', secondary_author], 'foo 2.0', secondary_author) or {
		return ruby.bool_value(false)
	}
	if !formula_ok {
		return ruby.bool_value(false)
	}

	cask_file := os.join_path('Casks', 'food.rb')
	pr_pull_spec_write(root, cask_file, pr_pull_spec_cask()) or {
		return ruby.bool_value(false)
	}
	cask_original := pr_pull_spec_commit(root, cask_file, 'food 1.0 (new cask)', '') or {
		return ruby.bool_value(false)
	}
	pr_pull_spec_write(root, cask_file, pr_pull_spec_cask_rebuild()) or {
		return ruby.bool_value(false)
	}
	cask_rebuild_commit := pr_pull_spec_commit(root, cask_file, 'rebuild', '') or {
		return ruby.bool_value(false)
	}
	pr_pull_spec_write(root, cask_file, pr_pull_spec_cask_version()) or {
		return ruby.bool_value(false)
	}
	cask_version_commit := pr_pull_spec_commit(root, cask_file, 'version', secondary_author) or {
		return ruby.bool_value(false)
	}
	cask_ok := pr_pull_spec_squash_series(root, cask_file, cask_original, [
		cask_rebuild_commit,
		cask_version_commit,
	], pr_pull_spec_cask(), pr_pull_spec_cask_version(), {
		cask_rebuild_commit: 'rebuild'
		cask_version_commit: 'version'
	}, ['Brew Test <brew@example.com>', secondary_author], 'food 2.0', secondary_author) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(cask_ok)
}

// Ruby let! `let!(:original_hash) do` at line 135.
pub fn ruby_pr_pull_spec_l135_d16_original_hash(args ...ruby.Value) ruby.Value {
	_ = args
	root := pr_pull_spec_root('original')
	defer { os.rmdir_all(root) or {} }
	pr_pull_spec_init_repository(root) or { return ruby.object_value('Error', err.msg()) }
	relative := os.join_path('Formula', 'foo.rb')
	pr_pull_spec_write(root, relative, pr_pull_spec_formula()) or {
		return ruby.object_value('Error', err.msg())
	}
	hash := pr_pull_spec_commit(root, relative, 'foo 1.0 (new formula)', '') or {
		return ruby.object_value('Error', err.msg())
	}
	return ruby.string_value(hash)
}

// Ruby it `it "aborts the cherry-pick when cherry_picked is true" do` at line 156.
pub fn ruby_pr_pull_spec_l156_d17_aborts(args ...ruby.Value) ruby.Value {
	_ = args
	tap := pr_pull_spec_tap('/tmp/homebrew/homebrew-foo')
	result := production_dev_cmd.autosquash_pr_pull(production_dev_cmd.PrPullAutosquashInput{
		original_commit: 'original'
		tap: tap
		commits: ['broken']
		commit_files: {
			'broken': ['README.md']
		}
		original_head: 'head'
		cherry_picked: true
	})
	abort := result.effects.any(it.kind == 'system' && it.argv.len >= 2
		&& it.argv[it.argv.len - 2..] == ['cherry-pick', '--abort'])
	return ruby.bool_value(result.error != '' && abort)
}

// Ruby it `it "does not abort the cherry-pick when cherry_picked is false" do` at line 166.
pub fn ruby_pr_pull_spec_l166_d18_does(args ...ruby.Value) ruby.Value {
	_ = args
	tap := pr_pull_spec_tap('/tmp/homebrew/homebrew-foo')
	result := production_dev_cmd.autosquash_pr_pull(production_dev_cmd.PrPullAutosquashInput{
		original_commit: 'original'
		tap: tap
		commits: ['broken']
		commit_files: {
			'broken': ['README.md']
		}
		original_head: 'head'
		cherry_picked: false
	})
	abort := result.effects.any(it.argv.len >= 2
		&& it.argv[it.argv.len - 2..] == ['cherry-pick', '--abort'])
	return ruby.bool_value(result.error != '' && !abort)
}

// Ruby it `it "signs off a formula or cask" do` at line 179.
pub fn ruby_pr_pull_spec_l179_d19_signs(args ...ruby.Value) ruby.Value {
	_ = args
	root := pr_pull_spec_root('signoff')
	defer { os.rmdir_all(root) or {} }
	pr_pull_spec_init_repository(root) or { return ruby.bool_value(false) }
	formula_file := os.join_path('Formula', 'foo.rb')
	pr_pull_spec_write(root, formula_file, pr_pull_spec_formula()) or {
		return ruby.bool_value(false)
	}
	pr_pull_spec_commit(root, formula_file, 'foo 1.0 (new formula)', '') or {
		return ruby.bool_value(false)
	}
	formula_message := pr_pull_spec_git(root, ['log', '-1', '--format=%B']) or {
		return ruby.bool_value(false)
	}
	formula_result := production_dev_cmd.signoff_pr_pull(production_dev_cmd.PrPullSignoffInput{
		tap: production_dev_cmd.PrPullTap{
			...pr_pull_spec_tap(root)
			commit_message: formula_message
		}
	})
	pr_pull_spec_execute_effects(formula_result.effects) or {
		return ruby.bool_value(false)
	}
	formula_signed := pr_pull_spec_git(root, ['log', '-1', '--format=%B']) or {
		return ruby.bool_value(false)
	}
	if !formula_signed.contains('Signed-off-by: Brew Test <brew@example.com>') {
		return ruby.bool_value(false)
	}

	cask_file := os.join_path('Casks', 'food.rb')
	pr_pull_spec_write(root, cask_file, pr_pull_spec_cask()) or {
		return ruby.bool_value(false)
	}
	pr_pull_spec_commit(root, cask_file, 'food 1.0 (new cask)', '') or {
		return ruby.bool_value(false)
	}
	cask_message := pr_pull_spec_git(root, ['log', '-1', '--format=%B']) or {
		return ruby.bool_value(false)
	}
	cask_result := production_dev_cmd.signoff_pr_pull(production_dev_cmd.PrPullSignoffInput{
		tap: production_dev_cmd.PrPullTap{
			...pr_pull_spec_tap(root)
			commit_message: cask_message
		}
	})
	pr_pull_spec_execute_effects(cask_result.effects) or {
		return ruby.bool_value(false)
	}
	cask_signed := pr_pull_spec_git(root, ['log', '-1', '--format=%B']) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(cask_signed.contains('Signed-off-by: Brew Test <brew@example.com>'))
}

// Ruby it `it "returns a formula" do` at line 202.
pub fn ruby_pr_pull_spec_l202_d20_returns(args ...ruby.Value) ruby.Value {
	_ = args
	root := '/tmp/homebrew/homebrew-foo'
	package := production_dev_cmd.get_pr_pull_package(production_dev_cmd.PrPullPackageInput{
		tap: pr_pull_spec_tap(root)
		name: 'foo'
		path: os.join_path(root, 'Formula', 'foo.rb')
		content: pr_pull_spec_formula()
		overrides: pr_pull_spec_overrides()
	}) or { return ruby.Value{ type_name: 'NilClass' } }
	return ruby.structured_value('Formula', package.name, {
		'version': package.version
	})
}

// Ruby it `it "returns nil for an unknown formula" do` at line 206.
pub fn ruby_pr_pull_spec_l206_d21_returns(args ...ruby.Value) ruby.Value {
	_ = args
	root := '/tmp/homebrew/homebrew-foo'
	_ := production_dev_cmd.get_pr_pull_package(production_dev_cmd.PrPullPackageInput{
		tap: pr_pull_spec_tap(root)
		name: 'foo'
		path: os.join_path(root, 'Formula', 'foo.rb')
		content: ''
		overrides: pr_pull_spec_overrides()
	}) or { return ruby.Value{ type_name: 'NilClass' } }
	return ruby.object_value('Formula', 'unexpected package')
}

// Ruby it `it "returns a cask" do` at line 210.
pub fn ruby_pr_pull_spec_l210_d22_returns(args ...ruby.Value) ruby.Value {
	_ = args
	root := '/tmp/homebrew/homebrew-foo'
	package := production_dev_cmd.get_pr_pull_package(production_dev_cmd.PrPullPackageInput{
		tap: pr_pull_spec_tap(root)
		name: 'foo'
		path: os.join_path(root, 'Casks', 'food.rb')
		content: pr_pull_spec_cask()
		overrides: pr_pull_spec_overrides()
	}) or { return ruby.Value{ type_name: 'NilClass' } }
	return ruby.structured_value('Cask::Cask', package.name, {
		'version': package.version
	})
}

// Ruby it `it "returns nil for an unknown cask" do` at line 214.
pub fn ruby_pr_pull_spec_l214_d23_returns(args ...ruby.Value) ruby.Value {
	_ = args
	root := '/tmp/homebrew/homebrew-foo'
	_ := production_dev_cmd.get_pr_pull_package(production_dev_cmd.PrPullPackageInput{
		tap: pr_pull_spec_tap(root)
		name: 'foo'
		path: os.join_path(root, 'Casks', 'food.rb')
		content: ''
		overrides: pr_pull_spec_overrides()
	}) or { return ruby.Value{ type_name: 'NilClass' } }
	return ruby.object_value('Cask::Cask', 'unexpected package')
}

// Ruby it `it "correctly bumps a new formula" do` at line 220.
pub fn ruby_pr_pull_spec_l220_d24_correctly(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(pr_pull_spec_bump_subject('', pr_pull_spec_formula(), '/tmp/homebrew/homebrew-foo/Formula/foo.rb', '', false))
}

// Ruby it `it "correctly bumps a new cask" do` at line 224.
pub fn ruby_pr_pull_spec_l224_d25_correctly(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(pr_pull_spec_bump_subject('', pr_pull_spec_cask(), '/tmp/homebrew/homebrew-foo/Casks/food.rb', '', false))
}

// Ruby it `it "correctly bumps a formula version" do` at line 228.
pub fn ruby_pr_pull_spec_l228_d26_correctly(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(pr_pull_spec_bump_subject(pr_pull_spec_formula(), pr_pull_spec_formula_version(), '/tmp/homebrew/homebrew-foo/Formula/foo.rb', '', false))
}

// Ruby it `it "correctly bumps a cask version" do` at line 232.
pub fn ruby_pr_pull_spec_l232_d27_correctly(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(pr_pull_spec_bump_subject(pr_pull_spec_cask(), pr_pull_spec_cask_version(), '/tmp/homebrew/homebrew-foo/Casks/food.rb', '', false))
}

// Ruby it `it "correctly bumps a cask checksum" do` at line 236.
pub fn ruby_pr_pull_spec_l236_d28_correctly(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(pr_pull_spec_bump_subject(pr_pull_spec_cask(), pr_pull_spec_cask_checksum(), '/tmp/homebrew/homebrew-foo/Casks/food.rb', '', false))
}

// Ruby it `it "correctly bumps a formula revision with reason" do` at line 240.
pub fn ruby_pr_pull_spec_l240_d29_correctly(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(pr_pull_spec_bump_subject(pr_pull_spec_formula(), pr_pull_spec_formula_revision(), '/tmp/homebrew/homebrew-foo/Formula/foo.rb', 'for fun', true))
}

// Ruby it `it "correctly bumps a formula rebuild" do` at line 246.
pub fn ruby_pr_pull_spec_l246_d30_correctly(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(pr_pull_spec_bump_subject(pr_pull_spec_formula(), pr_pull_spec_formula_rebuild(), '/tmp/homebrew/homebrew-foo/Formula/foo.rb', '', false))
}

// Ruby it `it "correctly bumps a formula deletion" do` at line 250.
pub fn ruby_pr_pull_spec_l250_d31_correctly(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(pr_pull_spec_bump_subject(pr_pull_spec_formula(), '', '/tmp/homebrew/homebrew-foo/Formula/foo.rb', '', false))
}

// Ruby it `it "correctly bumps a cask deletion" do` at line 254.
pub fn ruby_pr_pull_spec_l254_d32_correctly(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(pr_pull_spec_bump_subject(pr_pull_spec_cask(), '', '/tmp/homebrew/homebrew-foo/Casks/food.rb', '', false))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "dev-cmd/pr-pull"
// 5: require "utils/git"
// 6: require "tap"
// 7: require "cmd/shared_examples/args_parse"
// 8:
// 9: RSpec.describe Homebrew::DevCmd::PrPull do
// 10:   let(:pr_pull) { described_class.new(["foo"]) }
// 11:   let(:formula_rebuild) do
// 12:     <<~RUBY
// 13:       class Foo < Formula
// 14:         desc "Helpful description"
// 15:         url "https://brew.sh/foo-1.0.tgz"
// 16:       end
// 17:     RUBY
// 18:   end
// 19:   let(:formula_revision) do
// 20:     <<~RUBY
// 21:       class Foo < Formula
// 22:         url "https://brew.sh/foo-1.0.tgz"
// 23:         revision 1
// 24:       end
// 25:     RUBY
// 26:   end
// 27:   let(:formula_version) do
// 28:     <<~RUBY
// 29:       class Foo < Formula
// 30:         url "https://brew.sh/foo-2.0.tgz"
// 31:       end
// 32:     RUBY
// 33:   end
// 34:   let(:formula) do
// 35:     <<~RUBY
// 36:       class Foo < Formula
// 37:         url "https://brew.sh/foo-1.0.tgz"
// 38:       end
// 39:     RUBY
// 40:   end
// 41:   let(:cask_rebuild) do
// 42:     <<~RUBY
// 43:       cask "food" do
// 44:         desc "Helpful description"
// 45:         version "1.0"
// 46:         sha256 "a"
// 47:         url "https://brew.sh/food-\#{version}.tgz"
// 48:       end
// 49:     RUBY
// 50:   end
// 51:   let(:cask_checksum) do
// 52:     <<~RUBY
// 53:       cask "food" do
// 54:         desc "Helpful description"
// 55:         version "1.0"
// 56:         sha256 "b"
// 57:         url "https://brew.sh/food-\#{version}.tgz"
// 58:       end
// 59:     RUBY
// 60:   end
// 61:   let(:cask_version) do
// 62:     <<~RUBY
// 63:       cask "food" do
// 64:         version "2.0"
// 65:         sha256 "a"
// 66:         url "https://brew.sh/food-\#{version}.tgz"
// 67:       end
// 68:     RUBY
// 69:   end
// 70:   let(:cask) do
// 71:     <<~RUBY
// 72:       cask "food" do
// 73:         version "1.0"
// 74:         sha256 "a"
// 75:         url "https://brew.sh/food-\#{version}.tgz"
// 76:       end
// 77:     RUBY
// 78:   end
// 79:   let(:tap) { Tap.fetch("Homebrew", "foo") }
// 80:   let(:formula_file) { tap.path/"Formula/foo.rb" }
// 81:   let(:cask_file) { tap.cask_dir/"food.rb" }
// 82:   let(:path) { Pathname(HOMEBREW_TAP_DIRECTORY/"homebrew/homebrew-foo") }
// 83:
// 84:   include FileUtils
// 85:
// 86:   it_behaves_like "parseable arguments"
// 87:
// 88:   describe "#check_pull_request_head_sha!" do
// 89:     it "outputs the pull request head SHA" do
// 90:       allow(GitHub).to receive(:pull_request_commits).with("Homebrew", "foo", "1").and_return(["actual"])
// 91:
// 92:       expect do
// 93:         described_class.new(["1"]).check_pull_request_head_sha!("Homebrew", "foo", "1")
// 94:       end.to output(/Pull request #1 head SHA: actual/).to_stdout
// 95:     end
// 96:   end
// 97:
// 98:   describe "#autosquash!" do
// 99:     it "squashes a formula or cask correctly" do
// 100:       secondary_author = "Someone Else <me@example.com>"
// 101:       (tap.path/"Formula").mkpath
// 102:       formula_file.write(formula)
// 103:       cd tap.path do
// 104:         safe_system Utils::Git.git, "init"
// 105:         safe_system Utils::Git.git, "add", formula_file
// 106:         safe_system Utils::Git.git, "commit", "-m", "foo 1.0 (new formula)"
// 107:         original_hash = `git rev-parse HEAD`.chomp
// 108:         File.write(formula_file, formula_revision)
// 109:         safe_system Utils::Git.git, "commit", formula_file, "-m", "revision"
// 110:         File.write(formula_file, formula_version)
// 111:         safe_system Utils::Git.git, "commit", formula_file, "-m", "version", "--author=#{secondary_author}"
// 112:         pr_pull.autosquash!(original_hash, tap:)
// 113:         expect(tap.git_repository.commit_message).to include("foo 2.0")
// 114:         expect(tap.git_repository.commit_message).to include("Co-authored-by: #{secondary_author}")
// 115:       end
// 116:
// 117:       (path/"Casks").mkpath
// 118:       cask_file.write(cask)
// 119:       cd path do
// 120:         safe_system Utils::Git.git, "add", cask_file
// 121:         safe_system Utils::Git.git, "commit", "-m", "food 1.0 (new cask)"
// 122:         original_hash = `git rev-parse HEAD`.chomp
// 123:         File.write(cask_file, cask_rebuild)
// 124:         safe_system Utils::Git.git, "commit", cask_file, "-m", "rebuild"
// 125:         File.write(cask_file, cask_version)
// 126:         safe_system Utils::Git.git, "commit", cask_file, "-m", "version", "--author=#{secondary_author}"
// 127:         pr_pull.autosquash!(original_hash, tap:)
// 128:         git_repo = GitRepository.new(path)
// 129:         expect(git_repo.commit_message).to include("food 2.0")
// 130:         expect(git_repo.commit_message).to include("Co-authored-by: #{secondary_author}")
// 131:       end
// 132:     end
// 133:
// 134:     context "when squashing raises an error" do
// 135:       let!(:original_hash) do
// 136:         (tap.path/"Formula").mkpath
// 137:         formula_file.write(formula)
// 138:         cd(tap.path) do
// 139:           safe_system Utils::Git.git, "init"
// 140:           safe_system Utils::Git.git, "add", formula_file
// 141:           safe_system Utils::Git.git, "commit", "-m", "foo 1.0 (new formula)"
// 142:           `git rev-parse HEAD`.chomp
// 143:         end
// 144:       end
// 145:
// 146:       before do
// 147:         cd tap.path do
// 148:           File.write(formula_file, formula_revision)
// 149:           safe_system Utils::Git.git, "commit", formula_file, "-m", "revision"
// 150:         end
// 151:         allow(Utils::Git).to receive(:cherry_pick!).and_raise(
// 152:           ErrorDuringExecution.new(["git", "cherry-pick"], status: 1),
// 153:         )
// 154:       end
// 155:
// 156:       it "aborts the cherry-pick when cherry_picked is true" do
// 157:         cd(tap.path) do
// 158:           allow(pr_pull).to receive(:system).and_call_original
// 159:           expect(pr_pull).to receive(:system).with("git", "-C", tap.path.to_s, "cherry-pick", "--abort")
// 160:           expect do
// 161:             pr_pull.autosquash!(original_hash, tap:, cherry_picked: true)
// 162:           end.to raise_error(ErrorDuringExecution)
// 163:         end
// 164:       end
// 165:
// 166:       it "does not abort the cherry-pick when cherry_picked is false" do
// 167:         cd(tap.path) do
// 168:           allow(pr_pull).to receive(:system).and_call_original
// 169:           expect(pr_pull).not_to receive(:system).with("git", "-C", tap.path.to_s, "cherry-pick", "--abort")
// 170:           expect do
// 171:             pr_pull.autosquash!(original_hash, tap:, cherry_picked: false)
// 172:           end.to raise_error(ErrorDuringExecution)
// 173:         end
// 174:       end
// 175:     end
// 176:   end
// 177:
// 178:   describe "#signoff!" do
// 179:     it "signs off a formula or cask" do
// 180:       (tap.path/"Formula").mkpath
// 181:       formula_file.write(formula)
// 182:       cd tap.path do
// 183:         safe_system Utils::Git.git, "init"
// 184:         safe_system Utils::Git.git, "add", formula_file
// 185:         safe_system Utils::Git.git, "commit", "-m", "foo 1.0 (new formula)"
// 186:       end
// 187:       pr_pull.signoff!(tap.git_repository)
// 188:       expect(tap.git_repository.commit_message).to include("Signed-off-by:")
// 189:
// 190:       (path/"Casks").mkpath
// 191:       cask_file.write(cask)
// 192:       cd path do
// 193:         safe_system Utils::Git.git, "add", cask_file
// 194:         safe_system Utils::Git.git, "commit", "-m", "food 1.0 (new cask)"
// 195:       end
// 196:       pr_pull.signoff!(tap.git_repository)
// 197:       expect(tap.git_repository.commit_message).to include("Signed-off-by:")
// 198:     end
// 199:   end
// 200:
// 201:   describe "#get_package" do
// 202:     it "returns a formula" do
// 203:       expect(pr_pull.get_package(tap, "foo", formula_file, formula)).to be_a(Formula)
// 204:     end
// 205:
// 206:     it "returns nil for an unknown formula" do
// 207:       expect(pr_pull.get_package(tap, "foo", formula_file, "")).to be_nil
// 208:     end
// 209:
// 210:     it "returns a cask" do
// 211:       expect(pr_pull.get_package(tap, "foo", cask_file, cask)).to be_a(Cask::Cask)
// 212:     end
// 213:
// 214:     it "returns nil for an unknown cask" do
// 215:       expect(pr_pull.get_package(tap, "foo", cask_file, "")).to be_nil
// 216:     end
// 217:   end
// 218:
// 219:   describe "#determine_bump_subject" do
// 220:     it "correctly bumps a new formula" do
// 221:       expect(pr_pull.determine_bump_subject("", formula, formula_file)).to eq("foo 1.0 (new formula)")
// 222:     end
// 223:
// 224:     it "correctly bumps a new cask" do
// 225:       expect(pr_pull.determine_bump_subject("", cask, cask_file)).to eq("food 1.0 (new cask)")
// 226:     end
// 227:
// 228:     it "correctly bumps a formula version" do
// 229:       expect(pr_pull.determine_bump_subject(formula, formula_version, formula_file)).to eq("foo 2.0")
// 230:     end
// 231:
// 232:     it "correctly bumps a cask version" do
// 233:       expect(pr_pull.determine_bump_subject(cask, cask_version, cask_file)).to eq("food 2.0")
// 234:     end
// 235:
// 236:     it "correctly bumps a cask checksum" do
// 237:       expect(pr_pull.determine_bump_subject(cask, cask_checksum, cask_file)).to eq("food: checksum update")
// 238:     end
// 239:
// 240:     it "correctly bumps a formula revision with reason" do
// 241:       expect(pr_pull.determine_bump_subject(
// 242:                formula, formula_revision, formula_file, reason: "for fun"
// 243:              )).to eq("foo: revision for fun")
// 244:     end
// 245:
// 246:     it "correctly bumps a formula rebuild" do
// 247:       expect(pr_pull.determine_bump_subject(formula, formula_rebuild, formula_file)).to eq("foo: rebuild")
// 248:     end
// 249:
// 250:     it "correctly bumps a formula deletion" do
// 251:       expect(pr_pull.determine_bump_subject(formula, "", formula_file)).to eq("foo: delete")
// 252:     end
// 253:
// 254:     it "correctly bumps a cask deletion" do
// 255:       expect(pr_pull.determine_bump_subject(cask, "", cask_file)).to eq("food: delete")
// 256:     end
// 257:   end
// 258: end
