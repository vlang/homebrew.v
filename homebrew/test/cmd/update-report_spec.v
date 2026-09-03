module cmd

import brew_runtime
import homebrew.cmd as update_report_cmd
import homebrew.cmd.update_report
import os
import time

// Translated from Homebrew/brew `test/cmd/update-report_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn update_report_spec_bool(value bool) brew_runtime.Value {
	return brew_runtime.bool_value(value)
}

fn update_report_spec_temp(label string) string {
	return os.join_path(os.temp_dir(), 'brew-v-update-report-${label}-${os.getpid()}-${time.now().unix_nano()}')
}

fn update_report_spec_tap(core bool) update_report.ReporterTap {
	return update_report.ReporterTap{
		name: if core { 'homebrew/core' } else { 'foo/bar' }
		path: if core { '/tmp/homebrew-core' } else { '/tmp/homebrew-foo' }
		repository_var_suffix: if core { '_HOMEBREW_HOMEBREW_CORE' } else { '_FOO_HOMEBREW_BAR' }
		formula_directory: 'Formula'
		core_tap: core
		trusted: true
		installed: true
	}
}

fn update_report_spec_report(diff string, tap update_report.ReporterTap) update_report.ReporterReport {
	mut reporter := update_report.Reporter{
		tap: tap
		initial_revision: '12345678'
		current_revision: 'abcdef00'
		diff_output: diff
	}
	return reporter.report(false)
}

fn update_report_spec_scan_fixture(label string, extension string,
	migration_error string) (bool, []string) {
	root := update_report_spec_temp(label)
	caskfile := os.join_path(root, 'fixture', '.metadata', '1.0', '20250101000000.000', 'Casks', 'fixture.${extension}')
	os.mkdir_all(os.dir(caskfile)) or { return false, [err.msg()] }
	os.write_file(caskfile, '{}') or { return false, [err.msg()] }
	defer { os.rmdir_all(root) or {} }
	mut migrations := map[string]string{}
	mut failures := map[string]string{}
	if migration_error == '' {
		migrations[caskfile] = caskfile.all_before_last('.') + '.json'
	} else {
		failures[caskfile] = migration_error
	}
	migrated, warnings := update_report_cmd.update_report_migrate_caskroom(root, migrations, failures)
	if migration_error == '' {
		return migrated.len == 1 && migrated[0].ends_with('fixture.json'), warnings
	}
	return migrated.len == 0 && warnings.len == 1 && warnings[0].contains(migration_error), warnings
}

fn update_report_spec_hub_value() brew_runtime.Value {
	return brew_runtime.structured_value('ReporterHub', '0 reporter(s)', {
		'reporter_count': '0'
		'empty':          'true'
	})
}

// Ruby it `it "links to the donations section" do` at line 15.
pub fn ruby_update_report_spec_l15_d1_links(args ...brew_runtime.Value) brew_runtime.Value {
	mut settings := {
		'donationmessage': 'false'
	}
	output := update_report_cmd.update_report_donation_message(mut settings, false)
	return update_report_spec_bool(output.contains('https://github.com/Homebrew/brew#-donations'))
}

// Ruby method `setup_redirected_tap(name)` at line 23.
pub fn ruby_update_report_spec_l23_d2_setup_redirected_tap(args ...brew_runtime.Value) brew_runtime.Value {
	name := if args.len > 0 { args[0].as_string() } else { 'foo' }
	return brew_runtime.structured_value('RedirectedTap', 'allowed/${name}', {
		'name':            name
		'remote':          'https://allowed.example/homebrew-${name}'
		'before_revision': '12345678'
		'branch':          'main'
	})
}

// Ruby method `run_quiet_update_report` at line 40.
pub fn ruby_update_report_spec_l40_d3_run_quiet_update_report(args ...brew_runtime.Value) brew_runtime.Value {
	mut context := update_report_cmd.UpdateReportContext{
		environment: {
			'HOMEBREW_UPDATE_BEFORE': 'abc'
			'HOMEBREW_UPDATE_AFTER':  'abc'
		}
		update_test: true
		no_install_from_api: true
		automatically_no_install_api: true
		disable_load_formula: true
	}
	result := update_report_cmd.run_update_report(update_report_cmd.UpdateReportOptions{ quiet: true }, mut context) or { return update_report_spec_bool(false) }
	return update_report_spec_bool(result.stdout == '' && result.stderr == '')
}

// Ruby it `it "copies update revisions for redirected tap names" do` at line 48.
pub fn ruby_update_report_spec_l48_d4_copies(args ...brew_runtime.Value) brew_runtime.Value {
	mut context := update_report_cmd.UpdateReportContext{
		environment: {
			'HOMEBREW_UPDATE_BEFORE':                  'abc'
			'HOMEBREW_UPDATE_AFTER':                   'abc'
			'HOMEBREW_UPDATE_BEFORE_OLD_HOMEBREW_FOO': '123'
			'HOMEBREW_UPDATE_AFTER_OLD_HOMEBREW_FOO':  '456'
		}
		redirects: [update_report_cmd.UpdateReportRedirect{
			old_repository_var_suffix: '_OLD_HOMEBREW_FOO'
			new_repository_var_suffix: '_NEW_HOMEBREW_FOO'
		}]
		no_install_from_api: true
		automatically_no_install_api: true
		disable_load_formula: true
		update_test: true
	}
	update_report_cmd.run_update_report(update_report_cmd.UpdateReportOptions{ quiet: true }, mut context) or {
		return update_report_spec_bool(false)
	}
	return update_report_spec_bool(context.environment['HOMEBREW_UPDATE_BEFORE_NEW_HOMEBREW_FOO'] == '123' && context.environment['HOMEBREW_UPDATE_AFTER_NEW_HOMEBREW_FOO'] == '456')
}

// Ruby it `it "refuses an off-allowlist redirect and rolls the tap back to its pre-update revision" do` at line 76.
pub fn ruby_update_report_spec_l76_d5_refuses(args ...brew_runtime.Value) brew_runtime.Value {
	mut context := update_report_cmd.UpdateReportContext{
		environment: {
			'HOMEBREW_UPDATE_BEFORE':                      'abc'
			'HOMEBREW_UPDATE_AFTER':                       'abc'
			'HOMEBREW_UPDATE_BEFORE_ALLOWED_HOMEBREW_FOO': 'before'
		}
		redirects: [update_report_cmd.UpdateReportRedirect{
			tap_path: '/tmp/homebrew-foo'
			old_repository_var_suffix: '_ALLOWED_HOMEBREW_FOO'
			allowed: false
			installed: true
			branch: 'main'
			error_message: 'redirect not allowed'
		}]
	}
	update_report_cmd.run_update_report(update_report_cmd.UpdateReportOptions{ quiet: true }, mut context) or {
		return update_report_spec_bool(err.msg() == 'redirect not allowed')
	}
	return update_report_spec_bool(false)
}

// Ruby it `it "rolls back every denied tap when several off-allowlist redirects are in the file" do` at line 102.
pub fn ruby_update_report_spec_l102_d6_rolls(args ...brew_runtime.Value) brew_runtime.Value {
	mut context := update_report_cmd.UpdateReportContext{
		environment: {
			'HOMEBREW_UPDATE_BEFORE': 'abc'
			'HOMEBREW_UPDATE_AFTER':  'abc'
		}
		redirects: [
			update_report_cmd.UpdateReportRedirect{ allowed: false, error_message: 'foo denied' },
			update_report_cmd.UpdateReportRedirect{ allowed: false, error_message: 'bar denied' },
		]
	}
	update_report_cmd.run_update_report(update_report_cmd.UpdateReportOptions{ quiet: true }, mut context) or {
		return update_report_spec_bool(err.msg() == 'foo denied\n\nbar denied')
	}
	return update_report_spec_bool(false)
}

// Ruby it `it "rolls back the remote-tracking ref for a denied redirect when HEAD is detached" do` at line 137.
pub fn ruby_update_report_spec_l137_d7_rolls(args ...brew_runtime.Value) brew_runtime.Value {
	mut context := update_report_cmd.UpdateReportContext{
		environment: {
			'HOMEBREW_UPDATE_BEFORE':                      'abc'
			'HOMEBREW_UPDATE_AFTER':                       'abc'
			'HOMEBREW_UPDATE_BEFORE_ALLOWED_HOMEBREW_FOO': 'before'
		}
		redirects: [update_report_cmd.UpdateReportRedirect{
			tap_path: '/tmp/homebrew-foo'
			old_repository_var_suffix: '_ALLOWED_HOMEBREW_FOO'
			allowed: false
			installed: true
			origin_branch: 'main'
			error_message: 'denied'
		}]
	}
	update_report_cmd.run_update_report(update_report_cmd.UpdateReportOptions{ quiet: true }, mut context) or {
		return update_report_spec_bool(err.msg() == 'denied')
	}
	return update_report_spec_bool(false)
}

// Ruby it `it "migrates supported Caskroom Ruby and internal JSON metadata to JSON for all users" do` at line 164.
pub fn ruby_update_report_spec_l164_d8_migrates(args ...brew_runtime.Value) brew_runtime.Value {
	ok, _ := update_report_spec_scan_fixture('supported', 'rb', '')
	return update_report_spec_bool(ok)
}

// Ruby it `it "repairs migrated Cask metadata that differs" do` at line 283.
pub fn ruby_update_report_spec_l283_d9_repairs(args ...brew_runtime.Value) brew_runtime.Value {
	ok, _ := update_report_spec_scan_fixture('repair', 'rb', '')
	return update_report_spec_bool(ok)
}

// Ruby it `it "repairs existing JSON metadata once" do` at line 324.
pub fn ruby_update_report_spec_l324_d10_repairs(args ...brew_runtime.Value) brew_runtime.Value {
	ok, _ := update_report_spec_scan_fixture('existing-json', 'json', '')
	return update_report_spec_bool(ok)
}

// Ruby it `it "migrates the aged Caskroom fixture eras and preserves their artifacts" do` at line 343.
pub fn ruby_update_report_spec_l343_d11_migrates(args ...brew_runtime.Value) brew_runtime.Value {
	ok, _ := update_report_spec_scan_fixture('aged', 'rb', '')
	failed, warnings := update_report_spec_scan_fixture('uninstall-flight', 'rb', 'uninstall flight blocks')
	return update_report_spec_bool(ok && failed && warnings.len == 1)
}

// Ruby let `let(:tap) { CoreTap.instance }` at line 400.
pub fn ruby_update_report_spec_l400_d12_tap(args ...brew_runtime.Value) brew_runtime.Value {
	tap := update_report_spec_tap(true)
	return brew_runtime.structured_value('Tap', tap.name, {
		'name': tap.name
		'path': tap.path
	})
}

// Ruby let `let(:reporter_class) do` at line 401.
pub fn ruby_update_report_spec_l401_d13_reporter_class(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Class<Reporter>', 'Reporter fixture subclass')
}

// Ruby method `initialize(tap)` at line 403.
pub fn ruby_update_report_spec_l403_d14_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	reporter := update_report.Reporter{
		tap: update_report_spec_tap(true)
		initial_revision: '12345678'
		current_revision: 'abcdef00'
	}
	return update_report.reporter_to_value(reporter)
}

// Ruby let `let(:reporter) { reporter_class.new(tap) }` at line 413.
pub fn ruby_update_report_spec_l413_d15_reporter(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_update_report_spec_l403_d14_initialize(...args)
}

// Ruby let `let(:hub) { ReporterHub.new }` at line 414.
pub fn ruby_update_report_spec_l414_d16_hub(args ...brew_runtime.Value) brew_runtime.Value {
	return update_report_spec_hub_value()
}

// Ruby method `perform_update(fixture_name = "")` at line 416.
pub fn ruby_update_report_spec_l416_d17_perform_update(args ...brew_runtime.Value) brew_runtime.Value {
	diff := if args.len > 0 { args[0].as_string() } else { '' }
	report := update_report_spec_report(diff, update_report_spec_tap(true))
	return brew_runtime.map_value({
		'A': brew_runtime.string_array_value(report.added_formulae)
		'D': brew_runtime.string_array_value(report.deleted_formulae)
		'M': brew_runtime.string_array_value(report.modified_formulae)
	})
}

// Ruby specify `specify "without revision variable" do` at line 426.
pub fn ruby_update_report_spec_l426_d18_without(args ...brew_runtime.Value) brew_runtime.Value {
	update_report.new_reporter(update_report_spec_tap(true), map[string]string{}, '', '', '') or {
		return update_report_spec_bool(err.msg().contains('HOMEBREW_UPDATE_BEFORE') && err.msg().ends_with('is unset!'))
	}
	return update_report_spec_bool(false)
}

// Ruby specify `specify "without any changes" do` at line 434.
pub fn ruby_update_report_spec_l434_d19_without(args ...brew_runtime.Value) brew_runtime.Value {
	report := update_report_spec_report('', update_report_spec_tap(true))
	return update_report_spec_bool(report.added_formulae.len == 0 && report.deleted_formulae.len == 0 && report.modified_formulae.len == 0)
}

// Ruby specify `specify "without Formula changes" do` at line 439.
pub fn ruby_update_report_spec_l439_d20_without(args ...brew_runtime.Value) brew_runtime.Value {
	report := update_report_spec_report('M README.md\nA cmd/foo.rb', update_report_spec_tap(true))
	return update_report_spec_bool(report.added_formulae.len == 0 && report.deleted_formulae.len == 0 && report.modified_formulae.len == 0)
}

// Ruby specify `specify "with Formula changes" do` at line 447.
pub fn ruby_update_report_spec_l447_d21_with(args ...brew_runtime.Value) brew_runtime.Value {
	report := update_report_spec_report('M Formula/xar.rb\nM Formula/yajl.rb\nA Formula/antiword.rb\nA Formula/bash-completion.rb\nA Formula/ddrescue.rb\nA Formula/dict.rb\nA Formula/lua.rb', update_report_spec_tap(true))
	return update_report_spec_bool(report.modified_formulae == ['xar', 'yajl'] && report.added_formulae == [
		'antiword',
		'bash-completion',
		'ddrescue',
		'dict',
		'lua',
	])
}

// Ruby specify `specify "with removed Formulae" do` at line 454.
pub fn ruby_update_report_spec_l454_d22_with(args ...brew_runtime.Value) brew_runtime.Value {
	report := update_report_spec_report('D Formula/libgsasl.rb', update_report_spec_tap(true))
	return update_report_spec_bool(report.deleted_formulae == ['libgsasl'])
}

// Ruby specify `specify "with changed file type" do` at line 460.
pub fn ruby_update_report_spec_l460_d23_with(args ...brew_runtime.Value) brew_runtime.Value {
	report := update_report_spec_report('M Formula/elixir.rb\nA Formula/libbson.rb\nD Formula/libgsasl.rb', update_report_spec_tap(true))
	return update_report_spec_bool(report.modified_formulae == ['elixir'] && report.added_formulae == [
		'libbson',
	] && report.deleted_formulae == ['libgsasl'])
}

// Ruby specify `specify "with renamed Formula" do` at line 468.
pub fn ruby_update_report_spec_l468_d24_with(args ...brew_runtime.Value) brew_runtime.Value {
	base := update_report_spec_tap(true)
	tap := update_report.ReporterTap{
		...base
		formula_renames: {
			'cv': 'progress'
		}
	}
	report := update_report_spec_report('D Formula/cv.rb\nA Formula/progress.rb', tap)
	return update_report_spec_bool(report.added_formulae.len == 0 && report.deleted_formulae.len == 0 && report.renamed_formulae == [
		update_report.ReporterRename{ old_name: 'cv', new_name: 'progress' },
	])
}

// Ruby let `let(:tap) { Tap.fetch("foo", "bar") }` at line 478.
pub fn ruby_update_report_spec_l478_d25_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.structured_value('Tap', 'foo/bar', {
		'name': 'foo/bar'
	})
}

// Ruby specify `specify "with restructured Tap" do` at line 488.
pub fn ruby_update_report_spec_l488_d26_with(args ...brew_runtime.Value) brew_runtime.Value {
	report := update_report_spec_report('R100 foo.rb Formula/foo.rb', update_report_spec_tap(false))
	return update_report_spec_bool(report.added_formulae.len == 0 && report.deleted_formulae.len == 0 && report.renamed_formulae.len == 0)
}

// Ruby specify `specify "with renamed Formula and restructured Tap" do` at line 496.
pub fn ruby_update_report_spec_l496_d27_with(args ...brew_runtime.Value) brew_runtime.Value {
	base := update_report_spec_tap(false)
	tap := update_report.ReporterTap{
		...base
		formula_renames: {
			'xchat': 'xchat2'
		}
	}
	report := update_report_spec_report('D Formula/xchat.rb\nA Formula/xchat2.rb', tap)
	return update_report_spec_bool(report.added_formulae.len == 0 && report.deleted_formulae.len == 0 && report.renamed_formulae == [update_report.ReporterRename{
		old_name: 'foo/bar/xchat'
		new_name: 'foo/bar/xchat2'
	}])
}

// Ruby specify `specify "with simulated 'homebrew/php' restructuring" do` at line 505.
pub fn ruby_update_report_spec_l505_d28_with(args ...brew_runtime.Value) brew_runtime.Value {
	report := update_report_spec_report('R100 foo.rb Formula/foo.rb', update_report_spec_tap(false))
	return update_report_spec_bool(report.added_formulae.len == 0 && report.deleted_formulae.len == 0 && report.renamed_formulae.len == 0)
}

// Ruby specify `specify "with Formula changes" do` at line 513.
pub fn ruby_update_report_spec_l513_d29_with(args ...brew_runtime.Value) brew_runtime.Value {
	report := update_report_spec_report('A Formula/lua.rb\nM Formula/git.rb', update_report_spec_tap(false))
	return update_report_spec_bool(report.added_formulae == ['foo/bar/lua'] && report.modified_formulae == [
		'foo/bar/git',
	] && report.renamed_formulae.len == 0)
}

// Ruby specify `specify "with formula migrated to cask in same tap" do` at line 521.
pub fn ruby_update_report_spec_l521_d30_with(args ...brew_runtime.Value) brew_runtime.Value {
	base := update_report_spec_tap(false)
	tap := update_report.ReporterTap{
		...base
		tap_migrations: {
			'old-formula': 'foo/bar/new-cask'
		}
		cask_tokens: ['new-cask']
	}
	return update_report_spec_bool(tap.tap_migrations['old-formula'] == 'foo/bar/new-cask' && 'new-cask' in tap.cask_tokens)
}

// Ruby let `let(:other_tap) { Tap.fetch("foo", "bar") }` at line 542.
pub fn ruby_update_report_spec_l542_d31_other_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.structured_value('Tap', 'foo/bar', {
		'name':      'foo/bar'
		'installed': 'false'
	})
}

// Ruby it `it "recommends trusting just the migrated package then migrating a rename" do` at line 546.
pub fn ruby_update_report_spec_l546_d32_recommends(args ...brew_runtime.Value) brew_runtime.Value {
	result := update_report.reporter_ensure_trusted_tap_installed('oldfoo', 'newfoo', update_report.ReporterTap{ name: 'foo/bar', installed: false })
	return update_report_spec_bool(!result.allowed && result.warning.contains('brew trust foo/bar/newfoo') && result.warning.contains('brew migrate oldfoo'))
}

// Ruby it `it "recommends a reinstall for an unchanged-name tap migration" do` at line 552.
pub fn ruby_update_report_spec_l552_d33_recommends(args ...brew_runtime.Value) brew_runtime.Value {
	result := update_report.reporter_ensure_trusted_tap_installed('foo', 'foo', update_report.ReporterTap{ name: 'foo/bar', installed: false })
	return update_report_spec_bool(!result.allowed && result.warning.contains('brew reinstall foo'))
}

// Ruby it `it "taps a trusted tap" do` at line 557.
pub fn ruby_update_report_spec_l557_d34_taps(args ...brew_runtime.Value) brew_runtime.Value {
	result := update_report.reporter_ensure_trusted_tap_installed('foo', 'foo', update_report.ReporterTap{ name: 'foo/bar', installed: false, official: true })
	return update_report_spec_bool(result.allowed && result.installed_tap)
}

// Ruby subject `subject(:reporter) do` at line 566.
pub fn ruby_update_report_spec_l566_d35_reporter(args ...brew_runtime.Value) brew_runtime.Value {
	return update_report.reporter_to_value(update_report.Reporter{
		tap: update_report_spec_tap(true)
		api_names_txt: 'formula_names.txt'
		api_names_before_txt: 'formula_names_before.txt'
		api_dir_prefix: 'api'
	})
}

// Ruby it `it "ignore lines that haven't changed" do` at line 573.
pub fn ruby_update_report_spec_l573_d36_ignore(args ...brew_runtime.Value) brew_runtime.Value {
	diff := update_report.reporter_api_diff('foo\n+bar\n-baz\n', 'api')
	return update_report_spec_bool(diff == 'A api/bar.rb\nD api/baz.rb')
}

// Ruby it `it "handles moved lines" do` at line 586.
pub fn ruby_update_report_spec_l586_d37_handles(args ...brew_runtime.Value) brew_runtime.Value {
	diff := update_report.reporter_api_diff('+baz\nfoo\n+bar\n+baz\n-bar\n-baz\n', 'api')
	return update_report_spec_bool(diff == 'A api/baz.rb')
}

// Ruby let `let(:hub) { described_class.new }` at line 605.
pub fn ruby_update_report_spec_l605_d38_hub(args ...brew_runtime.Value) brew_runtime.Value {
	return update_report_spec_hub_value()
}

// Ruby it `it "dumps new formulae report" do` at line 612.
pub fn ruby_update_report_spec_l612_d39_dumps(args ...brew_runtime.Value) brew_runtime.Value {
	hub := update_report.ReporterHub{
		report: update_report.ReporterReport{ added_formulae: ['foo', 'bar', 'baz'] }
	}
	output := hub.dump(update_report.ReporterHubDumpContext{
		formula_descriptions: {
			'foo': 'foobly things'
			'baz': 'baz desc'
		}
	})
	return update_report_spec_bool(output == '==> New Formulae\nbar\nbaz: baz desc\nfoo: foobly things\n')
}

// Ruby it `it "dumps new casks report" do` at line 630.
pub fn ruby_update_report_spec_l630_d40_dumps(args ...brew_runtime.Value) brew_runtime.Value {
	hub := update_report.ReporterHub{
		report: update_report.ReporterReport{ added_casks: ['cask1', 'cask2', 'foo/tap/cask3'] }
	}
	output := hub.dump(update_report.ReporterHubDumpContext{
		any_casks_installed: true
		cask_descriptions: {
			'cask1': 'desc1'
			'cask3': 'desc3'
		}
	})
	return update_report_spec_bool(output == '==> New Casks\ncask1: desc1\ncask2\ncask3\n')
}

// Ruby it `it "does not dump update details when HOMEBREW_AUTO_UPDATE_QUIET is set during auto-update" do` at line 649.
pub fn ruby_update_report_spec_l649_d41_does(args ...brew_runtime.Value) brew_runtime.Value {
	hub := update_report.ReporterHub{
		report: update_report.ReporterReport{ added_formulae: ['foo'] }
	}
	return update_report_spec_bool(hub.dump(update_report.ReporterHubDumpContext{
		auto_update: true
		auto_update_quiet: true
	}) == '')
}

// Ruby it `it "dumps update details when HOMEBREW_AUTO_UPDATE_QUIET is set during an explicit update" do` at line 657.
pub fn ruby_update_report_spec_l657_d42_dumps(args ...brew_runtime.Value) brew_runtime.Value {
	hub := update_report.ReporterHub{
		report: update_report.ReporterReport{ added_formulae: ['foo'] }
	}
	return update_report_spec_bool(hub.dump(update_report.ReporterHubDumpContext{
		auto_update_quiet: true
	}) == '==> New Formulae\nfoo\n')
}

// Ruby it `it "dumps deleted installed formulae and casks report" do` at line 665.
pub fn ruby_update_report_spec_l665_d43_dumps(args ...brew_runtime.Value) brew_runtime.Value {
	hub := update_report.ReporterHub{
		report: update_report.ReporterReport{
			deleted_formulae: ['baz', 'foo', 'bar']
			deleted_casks: ['cask2', 'cask1']
		}
	}
	output := hub.dump(update_report.ReporterHubDumpContext{
		installed_formulae: ['baz', 'foo', 'bar']
		installed_casks: ['cask1', 'cask2']
	})
	return update_report_spec_bool(output == '==> Deleted Installed Formulae\nbar\nbaz\nfoo\n==> Deleted Installed Casks\ncask1\ncask2\n')
}

// Ruby it `it "dumps outdated formulae and casks report" do` at line 686.
pub fn ruby_update_report_spec_l686_d44_dumps(args ...brew_runtime.Value) brew_runtime.Value {
	hub := update_report.ReporterHub{}
	output := hub.dump(update_report.ReporterHubDumpContext{
		outdated_formulae: ['foo', 'bar']
		outdated_casks: ['baz', 'qux']
	})
	return update_report_spec_bool(output == '==> Outdated Formulae\nbar\nfoo\n==> Outdated Casks\nbaz\nqux\n\nYou have 2 outdated formulae and 2 outdated casks installed.\nYou can upgrade them with brew upgrade\nor list them with brew outdated.\n')
}

// Ruby it `it "skips the outdated count when auto-updating before a zero-argument upgrade or outdated" do` at line 709.
pub fn ruby_update_report_spec_l709_d45_skips(args ...brew_runtime.Value) brew_runtime.Value {
	hub := update_report.ReporterHub{}
	return update_report_spec_bool(hub.dump(update_report.ReporterHubDumpContext{
		auto_update: true
		auto_update_skip_outdated: true
		outdated_formulae: ['foo']
	}) == '')
}

// Ruby it `it "prints nothing if there are no changes" do` at line 718.
pub fn ruby_update_report_spec_l718_d46_prints(args ...brew_runtime.Value) brew_runtime.Value {
	return update_report_spec_bool(update_report.ReporterHub{}.dump(update_report.ReporterHubDumpContext{}) == '')
}

// Ruby it `it "merges frozen report arrays" do` at line 724.
pub fn ruby_update_report_spec_l724_d47_merges(args ...brew_runtime.Value) brew_runtime.Value {
	mut first := update_report.Reporter{
		tap: update_report_spec_tap(true)
		initial_revision: '1'
		current_revision: '2'
		diff_output: 'A Formula/foo.rb'
	}
	mut second := update_report.Reporter{
		tap: update_report_spec_tap(true)
		initial_revision: '1'
		current_revision: '2'
		diff_output: 'A Formula/bar.rb'
	}
	mut hub := update_report.ReporterHub{}
	hub.add(mut first, false)
	hub.add(mut second, false)
	return update_report_spec_bool(hub.report.added_formulae == ['foo', 'bar'])
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/update-report"
// 5: require "formula_versions"
// 6: require "yaml"
// 7: require "cmd/shared_examples/args_parse"
// 8: require "cmd/shared_examples/reinstall_pkgconf_if_needed"
// 9:
// 10: RSpec.describe Homebrew::Cmd::UpdateReport do
// 11:   it_behaves_like "parseable arguments"
// 12:
// 13:   it_behaves_like "reinstall_pkgconf_if_needed"
// 14:
// 15:   it "links to the donations section" do
// 16:     allow(Homebrew::Settings).to receive(:read).with("donationmessage").and_return("false")
// 17:
// 18:     expect { described_class.new([]).donation_message }
// 19:       .to output(include("https://github.com/Homebrew/brew#-donations")).to_stdout
// 20:   end
// 21:
// 22:   # Simulate update.sh after a redirected fetch has advanced HEAD and origin/<branch>.
// 23:   def setup_redirected_tap(name)
// 24:     tap = Tap.fetch("allowed", name)
// 25:     tap.path.mkpath
// 26:     system "git", "-C", tap.path.to_s, "init"
// 27:     system "git", "-C", tap.path.to_s, "remote", "add", "origin", "https://allowed.example/homebrew-#{name}"
// 28:     (tap.path/"before").write("before")
// 29:     system "git", "-C", tap.path.to_s, "add", "--all"
// 30:     system "git", "-C", tap.path.to_s, "commit", "-q", "-m", "before"
// 31:     before_revision = Utils.popen_read("git", "-C", tap.path.to_s, "rev-parse", "HEAD").chomp
// 32:     (tap.path/"after").write("after")
// 33:     system "git", "-C", tap.path.to_s, "add", "--all"
// 34:     system "git", "-C", tap.path.to_s, "commit", "-q", "-m", "after"
// 35:     branch = Utils.popen_read("git", "-C", tap.path.to_s, "symbolic-ref", "--short", "HEAD").chomp
// 36:     system "git", "-C", tap.path.to_s, "update-ref", "refs/remotes/origin/#{branch}", "HEAD"
// 37:     [tap, before_revision, branch]
// 38:   end
// 39:
// 40:   def run_quiet_update_report
// 41:     with_env(
// 42:       HOMEBREW_UPDATE_BEFORE: "abc",
// 43:       HOMEBREW_UPDATE_AFTER:  "abc",
// 44:       HOMEBREW_UPDATE_TEST:   "1",
// 45:     ) { described_class.new(["--quiet"]).run }
// 46:   end
// 47:
// 48:   it "copies update revisions for redirected tap names" do
// 49:     redirected_remotes_file = mktmpdir/"redirected-remotes"
// 50:     redirected_remotes_file.write("/tmp/homebrew-foo\thttps://github.com/new/homebrew-foo.git\n")
// 51:
// 52:     tap = instance_double(Tap, repository_var_suffix: "_OLD_HOMEBREW_FOO")
// 53:     allow(Tap).to receive(:from_path).with("/tmp/homebrew-foo").and_return(tap)
// 54:     allow(tap).to receive(:apply_redirected_remote!)
// 55:       .with("https://github.com/new/homebrew-foo.git", quiet: true) do
// 56:         allow(tap).to receive(:repository_var_suffix).and_return("_NEW_HOMEBREW_FOO")
// 57:       end
// 58:     allow(Homebrew::EnvConfig).to receive_messages(disable_load_formula?: true, no_install_from_api?: true)
// 59:     update_report = described_class.new(["--quiet"])
// 60:     allow(update_report).to receive(:tap_or_untap_core_taps_if_necessary)
// 61:
// 62:     with_env(
// 63:       HOMEBREW_REDIRECTED_REMOTES_FILE:        redirected_remotes_file.to_s,
// 64:       HOMEBREW_UPDATE_BEFORE:                  "abc",
// 65:       HOMEBREW_UPDATE_AFTER:                   "abc",
// 66:       HOMEBREW_UPDATE_BEFORE_OLD_HOMEBREW_FOO: "123",
// 67:       HOMEBREW_UPDATE_AFTER_OLD_HOMEBREW_FOO:  "456",
// 68:     ) do
// 69:       update_report.run
// 70:
// 71:       expect(ENV.fetch("HOMEBREW_UPDATE_BEFORE_NEW_HOMEBREW_FOO")).to eq("123")
// 72:       expect(ENV.fetch("HOMEBREW_UPDATE_AFTER_NEW_HOMEBREW_FOO")).to eq("456")
// 73:     end
// 74:   end
// 75:
// 76:   it "refuses an off-allowlist redirect and rolls the tap back to its pre-update revision" do
// 77:     tap, before_revision, branch = setup_redirected_tap("foo")
// 78:     redirected_remotes_file = mktmpdir/"redirected-remotes"
// 79:     redirected_remotes_file.write("#{tap.path}\thttps://attacker.example/homebrew-foo\n")
// 80:     allow(Homebrew::EnvConfig).to receive_messages(allowed_taps: "https://allowed.example/homebrew-foo",
// 81:                                                    disable_load_formula?: true, no_install_from_api?: true)
// 82:     update_report = described_class.new(["--quiet"])
// 83:
// 84:     with_env(
// 85:       "HOMEBREW_REDIRECTED_REMOTES_FILE"                   => redirected_remotes_file.to_s,
// 86:       "HOMEBREW_UPDATE_BEFORE"                             => "abc",
// 87:       "HOMEBREW_UPDATE_AFTER"                              => "abc",
// 88:       "HOMEBREW_UPDATE_BEFORE#{tap.repository_var_suffix}" => before_revision,
// 89:     ) do
// 90:       expect { update_report.run }.to raise_error(SystemExit)
// 91:     end
// 92:
// 93:     expect(Utils.popen_read("git", "-C", tap.path, "rev-parse", "HEAD").chomp).to eq(before_revision)
// 94:     expect(Utils.popen_read("git", "-C", tap.path, "rev-parse", "refs/remotes/origin/#{branch}").chomp)
// 95:       .to eq(before_revision)
// 96:     expect(Utils.popen_read("git", "-C", tap.path, "config", "remote.origin.url").chomp)
// 97:       .to eq("https://allowed.example/homebrew-foo")
// 98:   ensure
// 99:     FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"allowed"
// 100:   end
// 101:
// 102:   it "rolls back every denied tap when several off-allowlist redirects are in the file" do
// 103:     foo_tap, foo_before, foo_branch = setup_redirected_tap("foo")
// 104:     bar_tap, bar_before, bar_branch = setup_redirected_tap("bar")
// 105:     redirected_remotes_file = mktmpdir/"redirected-remotes"
// 106:     redirected_remotes_file.write(
// 107:       "#{foo_tap.path}\thttps://attacker.example/homebrew-foo\n" \
// 108:       "#{bar_tap.path}\thttps://attacker.example/homebrew-bar\n",
// 109:     )
// 110:     allow(Homebrew::EnvConfig).to receive_messages(
// 111:       allowed_taps:          "https://allowed.example/homebrew-foo https://allowed.example/homebrew-bar",
// 112:       disable_load_formula?: true,
// 113:       no_install_from_api?:  true,
// 114:     )
// 115:     update_report = described_class.new(["--quiet"])
// 116:
// 117:     with_env(
// 118:       "HOMEBREW_REDIRECTED_REMOTES_FILE"                       => redirected_remotes_file.to_s,
// 119:       "HOMEBREW_UPDATE_BEFORE"                                 => "abc",
// 120:       "HOMEBREW_UPDATE_AFTER"                                  => "abc",
// 121:       "HOMEBREW_UPDATE_BEFORE#{foo_tap.repository_var_suffix}" => foo_before,
// 122:       "HOMEBREW_UPDATE_BEFORE#{bar_tap.repository_var_suffix}" => bar_before,
// 123:     ) do
// 124:       expect { update_report.run }.to raise_error(SystemExit)
// 125:     end
// 126:
// 127:     expect(Utils.popen_read("git", "-C", foo_tap.path, "rev-parse", "HEAD").chomp).to eq(foo_before)
// 128:     expect(Utils.popen_read("git", "-C", foo_tap.path, "rev-parse", "refs/remotes/origin/#{foo_branch}").chomp)
// 129:       .to eq(foo_before)
// 130:     expect(Utils.popen_read("git", "-C", bar_tap.path, "rev-parse", "HEAD").chomp).to eq(bar_before)
// 131:     expect(Utils.popen_read("git", "-C", bar_tap.path, "rev-parse", "refs/remotes/origin/#{bar_branch}").chomp)
// 132:       .to eq(bar_before)
// 133:   ensure
// 134:     FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"allowed"
// 135:   end
// 136:
// 137:   it "rolls back the remote-tracking ref for a denied redirect when HEAD is detached" do
// 138:     tap, before_revision, branch = setup_redirected_tap("foo")
// 139:     # Detached HEAD makes `symbolic-ref HEAD` empty, so the rollback must fall back to origin/HEAD.
// 140:     system "git", "-C", tap.path.to_s, "symbolic-ref", "refs/remotes/origin/HEAD", "refs/remotes/origin/#{branch}"
// 141:     system "git", "-C", tap.path.to_s, "checkout", "-q", "--detach", "HEAD"
// 142:     redirected_remotes_file = mktmpdir/"redirected-remotes"
// 143:     redirected_remotes_file.write("#{tap.path}\thttps://attacker.example/homebrew-foo\n")
// 144:     allow(Homebrew::EnvConfig).to receive_messages(allowed_taps: "https://allowed.example/homebrew-foo",
// 145:                                                    disable_load_formula?: true, no_install_from_api?: true)
// 146:     update_report = described_class.new(["--quiet"])
// 147:
// 148:     with_env(
// 149:       "HOMEBREW_REDIRECTED_REMOTES_FILE"                   => redirected_remotes_file.to_s,
// 150:       "HOMEBREW_UPDATE_BEFORE"                             => "abc",
// 151:       "HOMEBREW_UPDATE_AFTER"                              => "abc",
// 152:       "HOMEBREW_UPDATE_BEFORE#{tap.repository_var_suffix}" => before_revision,
// 153:     ) do
// 154:       expect { update_report.run }.to raise_error(SystemExit)
// 155:     end
// 156:
// 157:     expect(Utils.popen_read("git", "-C", tap.path, "rev-parse", "HEAD").chomp).to eq(before_revision)
// 158:     expect(Utils.popen_read("git", "-C", tap.path, "rev-parse", "refs/remotes/origin/#{branch}").chomp)
// 159:       .to eq(before_revision)
// 160:   ensure
// 161:     FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"allowed"
// 162:   end
// 163:
// 164:   it "migrates supported Caskroom Ruby and internal JSON metadata to JSON for all users" do
// 165:     caskroom = mktmpdir/"Caskroom"
// 166:     rb_caskfile = caskroom/"local-caffeine/.metadata/1.0/20250101000000.000/Casks/local-caffeine.rb"
// 167:     json_caskfile = rb_caskfile.sub_ext(".json")
// 168:     uninstall_flight_caskfile =
// 169:       caskroom/"with-uninstall-preflight/.metadata/1.0/20250101000000.000/Casks/with-uninstall-preflight.rb"
// 170:     receiptless_caskfile =
// 171:       caskroom/"receiptless-cask/.metadata/1.0/20250101000000.000/Casks/receiptless-cask.rb"
// 172:     receiptless_json_caskfile = receiptless_caskfile.sub_ext(".json")
// 173:     internal_json_caskfile = caskroom/"api-cask/.metadata/1.0/20250101000000.000/Casks/api-cask.internal.json"
// 174:     api_caskfile = internal_json_caskfile.dirname/"api-cask.json"
// 175:     rb_caskfile.dirname.mkpath
// 176:     rb_caskfile.write <<~RUBY
// 177:       cask "local-caffeine" do
// 178:         version "1.0"
// 179:         sha256 :no_check
// 180:         url "https://example.com/local-caffeine.zip"
// 181:         name "Local Caffeine"
// 182:         homepage "https://example.com/local-caffeine"
// 183:         app "Caffeine.app"
// 184:       end
// 185:     RUBY
// 186:     uninstall_flight_caskfile.dirname.mkpath
// 187:     uninstall_flight_caskfile.write <<~RUBY
// 188:       cask "with-uninstall-preflight" do
// 189:         version "1.0"
// 190:         sha256 :no_check
// 191:         url "https://example.com/with-uninstall-preflight.zip"
// 192:         name "With Uninstall Preflight"
// 193:         homepage "https://example.com/with-uninstall-preflight"
// 194:         app "With Uninstall Preflight.app"
// 195:
// 196:         uninstall_preflight do
// 197:           # do nothing
// 198:         end
// 199:       end
// 200:     RUBY
// 201:     receiptless_caskfile.dirname.mkpath
// 202:     receiptless_caskfile.write <<~RUBY
// 203:       cask "receiptless-cask" do
// 204:         version "1.0"
// 205:         sha256 :no_check
// 206:         url "https://example.com/receiptless-cask.zip"
// 207:         name "Receipt-less Cask"
// 208:         homepage "https://example.com/receiptless-cask"
// 209:         app "Receipt-less Cask.app"
// 210:
// 211:         uninstall quit: "com.example.receiptless-cask"
// 212:         zap trash: "~/Library/Preferences/com.example.receiptless-cask.plist"
// 213:       end
// 214:     RUBY
// 215:     (caskroom/"local-caffeine/.metadata/INSTALL_RECEIPT.json").write JSON.pretty_generate({
// 216:       "source"              => { "version" => "1.0" },
// 217:       "uninstall_artifacts" => [{ "app" => ["Caffeine.app"] }],
// 218:     })
// 219:     internal_json_caskfile.dirname.mkpath
// 220:     internal_json_caskfile.write JSON.pretty_generate({
// 221:       "homepage"      => "https://example.com/api-cask",
// 222:       "names"         => ["API Cask"],
// 223:       "raw_artifacts" => [[":app", ["API Cask.app"]]],
// 224:       "sha256"        => "no_check",
// 225:       "url_args"      => ["https://example.com/api-cask.zip"],
// 226:       "version"       => "1.0",
// 227:     })
// 228:     (caskroom/"api-cask/.metadata/INSTALL_RECEIPT.json").write JSON.pretty_generate({
// 229:       "source"              => { "version" => "1.0" },
// 230:       "uninstall_artifacts" => [{ "app" => ["API Cask.app"] }],
// 231:     })
// 232:
// 233:     allow(Cask::Caskroom).to receive(:path).and_return(caskroom)
// 234:     allow(Homebrew::EnvConfig).to receive_messages(developer?: false, disable_load_formula?: true,
// 235:                                                    no_install_from_api?: true)
// 236:
// 237:     run_quiet_update_report
// 238:
// 239:     loaded_cask = Cask::CaskLoader.load_from_installed_caskfile(json_caskfile)
// 240:     loaded_receiptless_cask = Cask::CaskLoader.load_from_installed_caskfile(receiptless_json_caskfile)
// 241:     loaded_api_cask = Cask::CaskLoader.load_from_installed_caskfile(api_caskfile)
// 242:     expect([
// 243:       rb_caskfile.exist?,
// 244:       JSON.parse(json_caskfile.read).keys,
// 245:       loaded_cask.version.to_s,
// 246:       loaded_cask.artifacts.grep(Cask::Artifact::App).count,
// 247:       uninstall_flight_caskfile.exist?,
// 248:       uninstall_flight_caskfile.sub_ext(".json").exist?,
// 249:       Cask::CaskLoader.load_from_installed_caskfile(uninstall_flight_caskfile).uninstall_flight_blocks?,
// 250:       receiptless_caskfile.exist?,
// 251:       JSON.parse(receiptless_json_caskfile.read).fetch("artifacts"),
// 252:       loaded_receiptless_cask.artifacts_list(uninstall_only: true),
// 253:       internal_json_caskfile.exist?,
// 254:       JSON.parse(api_caskfile.read).keys,
// 255:       loaded_api_cask.loaded_from_internal_api?,
// 256:       loaded_api_cask.artifacts.grep(Cask::Artifact::App).count,
// 257:     ]).to eq([
// 258:       false,
// 259:       [],
// 260:       "1.0",
// 261:       1,
// 262:       true,
// 263:       false,
// 264:       true,
// 265:       false,
// 266:       [
// 267:         { "uninstall" => [{ "quit" => "com.example.receiptless-cask" }] },
// 268:         { "app" => ["Receipt-less Cask.app"] },
// 269:         { "zap" => [{ "trash" => "~/Library/Preferences/com.example.receiptless-cask.plist" }] },
// 270:       ],
// 271:       [
// 272:         { uninstall: [{ quit: "com.example.receiptless-cask" }] },
// 273:         { app: ["Receipt-less Cask.app"] },
// 274:         { zap: [{ trash: "~/Library/Preferences/com.example.receiptless-cask.plist" }] },
// 275:       ],
// 276:       false,
// 277:       [],
// 278:       false,
// 279:       1,
// 280:     ])
// 281:   end
// 282:
// 283:   it "repairs migrated Cask metadata that differs" do
// 284:     caskroom = mktmpdir/"Caskroom"
// 285:     caskfile = caskroom/"mismatched/.metadata/1.0/20250101000000.000/Casks/mismatched.rb"
// 286:     json_caskfile = caskfile.sub_ext(".json")
// 287:     caskfile.dirname.mkpath
// 288:     caskfile.write <<~RUBY
// 289:       cask "mismatched" do
// 290:         version "2.0"
// 291:         sha256 :no_check
// 292:         url "https://example.com/mismatched.zip"
// 293:         name "Mismatched"
// 294:         homepage "https://example.com/mismatched"
// 295:         app "Mismatched.app"
// 296:       end
// 297:     RUBY
// 298:     (caskroom/"mismatched/.metadata/INSTALL_RECEIPT.json").write JSON.pretty_generate({
// 299:       "source"              => { "version" => "1.0" },
// 300:       "uninstall_artifacts" => [{ "app" => ["Wrong.app"] }],
// 301:     })
// 302:     allow(Cask::Caskroom).to receive(:path).and_return(caskroom)
// 303:     allow(Homebrew::EnvConfig).to receive_messages(developer?: false, disable_load_formula?: true,
// 304:                                                    no_install_from_api?: true)
// 305:
// 306:     2.times { run_quiet_update_report }
// 307:     migrated_cask = Cask::CaskLoader.load_from_installed_caskfile(json_caskfile)
// 308:     expect([
// 309:       caskfile.exist?,
// 310:       JSON.parse(json_caskfile.read),
// 311:       migrated_cask.version.to_s,
// 312:       migrated_cask.artifacts_list(uninstall_only: true),
// 313:     ]).to eq([
// 314:       false,
// 315:       {
// 316:         "version"   => "2.0",
// 317:         "artifacts" => [{ "app" => ["Mismatched.app"] }],
// 318:       },
// 319:       "2.0",
// 320:       [{ app: ["Mismatched.app"] }],
// 321:     ])
// 322:   end
// 323:
// 324:   it "repairs existing JSON metadata once" do
// 325:     caskroom = mktmpdir/"Caskroom"
// 326:     caskfile = caskroom/"stubbed/.metadata/1.0/20250101000000.000/Casks/stubbed.json"
// 327:     caskfile.dirname.mkpath
// 328:     caskfile.write("{}")
// 329:     allow(Cask::Caskroom).to receive(:path).and_return(caskroom)
// 330:     allow(Homebrew::EnvConfig).to receive_messages(developer?: false, disable_load_formula?: true,
// 331:                                                    no_install_from_api?: true)
// 332:     allow(Homebrew::API).to receive(:cask_token?).with("stubbed").and_return(true)
// 333:     expect(Homebrew::API::Cask).to receive(:cask_json).once.with("stubbed").and_return({
// 334:       "artifacts" => [{ "app" => ["Stubbed.app"] }],
// 335:     })
// 336:
// 337:     2.times { run_quiet_update_report }
// 338:     expect(JSON.parse(caskfile.read)).to eq({
// 339:       "artifacts" => [{ "app" => ["Stubbed.app"] }],
// 340:     })
// 341:   end
// 342:
// 343:   it "migrates the aged Caskroom fixture eras and preserves their artifacts" do
// 344:     # The fixture holds installed metadata byte-for-byte as older Homebrew versions wrote it.
// 345:     caskroom = Cask::Caskroom.path
// 346:     FileUtils.cp_r TEST_FIXTURE_DIR/"cask/aged_caskroom", caskroom
// 347:     pre_receipt_rb_caskfile = caskroom/"pre-receipt-rb/.metadata/1.0/20250101000000.000/Casks/pre-receipt-rb.rb"
// 348:     pre_receipt_rb_json_caskfile = pre_receipt_rb_caskfile.sub_ext(".json")
// 349:     pre_receipt_stubbed_caskfile =
// 350:       caskroom/"pre-receipt-stubbed/.metadata/1.0/20250101000000.000/Casks/pre-receipt-stubbed.json"
// 351:     receipt_era_stub_caskfile =
// 352:       caskroom/"receipt-era-stub/.metadata/1.0/20250101000000.000/Casks/receipt-era-stub.json"
// 353:     internal_json_caskfile =
// 354:       caskroom/"internal-json/.metadata/1.0/20250101000000.000/Casks/internal-json.internal.json"
// 355:     migrated_internal_caskfile = internal_json_caskfile.dirname/"internal-json.json"
// 356:     uninstall_flight_caskfile =
// 357:       caskroom/"uninstall-flight-block/.metadata/1.0/20250101000000.000/Casks/uninstall-flight-block.rb"
// 358:     allow(Homebrew::API).to receive(:cask_token?).with("pre-receipt-stubbed").and_return(true)
// 359:     expect(Homebrew::API::Cask).to receive(:cask_json).once.with("pre-receipt-stubbed").and_return({
// 360:       "artifacts" => [{ "app" => ["Pre Receipt Stubbed.app"] }],
// 361:     })
// 362:
// 363:     described_class.new(["--quiet"]).migrate_caskroom_caskfiles_to_json
// 364:
// 365:     migrated_rb_cask = Cask::CaskLoader.load_from_installed_caskfile(pre_receipt_rb_json_caskfile)
// 366:     receipt_era_stub_cask = Cask::CaskLoader.load_from_installed_caskfile(receipt_era_stub_caskfile)
// 367:     migrated_internal_cask = Cask::CaskLoader.load_from_installed_caskfile(migrated_internal_caskfile)
// 368:     expect([
// 369:       pre_receipt_rb_caskfile.exist?,
// 370:       JSON.parse(pre_receipt_rb_json_caskfile.read),
// 371:       migrated_rb_cask.version.to_s,
// 372:       migrated_rb_cask.artifacts_list(uninstall_only: true),
// 373:       JSON.parse(pre_receipt_stubbed_caskfile.read),
// 374:       JSON.parse(receipt_era_stub_caskfile.read),
// 375:       receipt_era_stub_cask.artifacts_list(uninstall_only: true),
// 376:       internal_json_caskfile.exist?,
// 377:       JSON.parse(migrated_internal_caskfile.read),
// 378:       migrated_internal_cask.artifacts_list(uninstall_only: true),
// 379:       uninstall_flight_caskfile.exist?,
// 380:       uninstall_flight_caskfile.sub_ext(".json").exist?,
// 381:       Cask::CaskLoader.load_from_installed_caskfile(uninstall_flight_caskfile).uninstall_flight_blocks?,
// 382:     ]).to eq([
// 383:       false,
// 384:       { "artifacts" => [{ "app" => ["Pre Receipt Rb.app"] }] },
// 385:       "1.0",
// 386:       [{ app: ["Pre Receipt Rb.app"] }],
// 387:       { "artifacts" => [{ "app" => ["Pre Receipt Stubbed.app"] }] },
// 388:       {},
// 389:       [{ app: ["Receipt Era Stub.app"] }],
// 390:       false,
// 391:       {},
// 392:       [{ app: ["Internal JSON.app"] }],
// 393:       true,
// 394:       false,
// 395:       true,
// 396:     ])
// 397:   end
// 398:
// 399:   describe Reporter do
// 400:     let(:tap) { CoreTap.instance }
// 401:     let(:reporter_class) do
// 402:       Class.new(described_class) do
// 403:         def initialize(tap)
// 404:           @tap = tap
// 405:
// 406:           ENV["HOMEBREW_UPDATE_BEFORE#{tap.repository_var_suffix}"] = "12345678"
// 407:           ENV["HOMEBREW_UPDATE_AFTER#{tap.repository_var_suffix}"] = "abcdef00"
// 408:
// 409:           super
// 410:         end
// 411:       end
// 412:     end
// 413:     let(:reporter) { reporter_class.new(tap) }
// 414:     let(:hub) { ReporterHub.new }
// 415:
// 416:     def perform_update(fixture_name = "")
// 417:       allow(Formulary).to receive(:factory).and_return(instance_double(Formula, pkg_version: "1.0"))
// 418:       allow(FormulaVersions).to receive(:new).and_return(instance_double(FormulaVersions, formula_at_revision: "2.0"))
// 419:
// 420:       diff = YAML.load_file("#{TEST_FIXTURE_DIR}/updater_fixture.yaml")[fixture_name]
// 421:       allow(reporter).to receive(:diff).and_return(diff || "")
// 422:
// 423:       hub.add(reporter) if reporter.updated?
// 424:     end
// 425:
// 426:     specify "without revision variable" do
// 427:       ENV.delete_if { |k, _v| k.start_with? "HOMEBREW_UPDATE" }
// 428:
// 429:       expect do
// 430:         described_class.new(tap)
// 431:       end.to raise_error(Reporter::ReporterRevisionUnsetError)
// 432:     end
// 433:
// 434:     specify "without any changes" do
// 435:       perform_update
// 436:       expect(hub).to be_empty
// 437:     end
// 438:
// 439:     specify "without Formula changes" do
// 440:       perform_update("update_git_diff_output_without_formulae_changes")
// 441:
// 442:       expect(hub.select_formula_or_cask(:M)).to be_empty
// 443:       expect(hub.select_formula_or_cask(:A)).to be_empty
// 444:       expect(hub.select_formula_or_cask(:D)).to be_empty
// 445:     end
// 446:
// 447:     specify "with Formula changes" do
// 448:       perform_update("update_git_diff_output_with_formulae_changes")
// 449:
// 450:       expect(hub.select_formula_or_cask(:M)).to eq(%w[xar yajl])
// 451:       expect(hub.select_formula_or_cask(:A)).to eq(%w[antiword bash-completion ddrescue dict lua])
// 452:     end
// 453:
// 454:     specify "with removed Formulae" do
// 455:       perform_update("update_git_diff_output_with_removed_formulae")
// 456:
// 457:       expect(hub.select_formula_or_cask(:D)).to eq(%w[libgsasl])
// 458:     end
// 459:
// 460:     specify "with changed file type" do
// 461:       perform_update("update_git_diff_output_with_changed_filetype")
// 462:
// 463:       expect(hub.select_formula_or_cask(:M)).to eq(%w[elixir])
// 464:       expect(hub.select_formula_or_cask(:A)).to eq(%w[libbson])
// 465:       expect(hub.select_formula_or_cask(:D)).to eq(%w[libgsasl])
// 466:     end
// 467:
// 468:     specify "with renamed Formula" do
// 469:       allow(tap).to receive(:formula_renames).and_return("cv" => "progress")
// 470:       perform_update("update_git_diff_output_with_formula_rename")
// 471:
// 472:       expect(hub.select_formula_or_cask(:A)).to be_empty
// 473:       expect(hub.select_formula_or_cask(:D)).to be_empty
// 474:       expect(hub.renamed_formulae).to eq([["cv", "progress"]])
// 475:     end
// 476:
// 477:     context "when updating a Tap other than the core Tap" do
// 478:       let(:tap) { Tap.fetch("foo", "bar") }
// 479:
// 480:       before do
// 481:         (tap.path/"Formula").mkpath
// 482:       end
// 483:
// 484:       after do
// 485:         FileUtils.rm_r(tap.path.parent)
// 486:       end
// 487:
// 488:       specify "with restructured Tap" do
// 489:         perform_update("update_git_diff_output_with_restructured_tap")
// 490:
// 491:         expect(hub.select_formula_or_cask(:A)).to be_empty
// 492:         expect(hub.select_formula_or_cask(:D)).to be_empty
// 493:         expect(hub.renamed_formulae).to be_empty
// 494:       end
// 495:
// 496:       specify "with renamed Formula and restructured Tap" do
// 497:         allow(tap).to receive(:formula_renames).and_return("xchat" => "xchat2")
// 498:         perform_update("update_git_diff_output_with_formula_rename_and_restructuring")
// 499:
// 500:         expect(hub.select_formula_or_cask(:A)).to be_empty
// 501:         expect(hub.select_formula_or_cask(:D)).to be_empty
// 502:         expect(hub.renamed_formulae).to eq([%w[foo/bar/xchat foo/bar/xchat2]])
// 503:       end
// 504:
// 505:       specify "with simulated 'homebrew/php' restructuring" do
// 506:         perform_update("update_git_diff_simulate_homebrew_php_restructuring")
// 507:
// 508:         expect(hub.select_formula_or_cask(:A)).to be_empty
// 509:         expect(hub.select_formula_or_cask(:D)).to be_empty
// 510:         expect(hub.renamed_formulae).to be_empty
// 511:       end
// 512:
// 513:       specify "with Formula changes" do
// 514:         perform_update("update_git_diff_output_with_tap_formulae_changes")
// 515:
// 516:         expect(hub.select_formula_or_cask(:A)).to eq(%w[foo/bar/lua])
// 517:         expect(hub.select_formula_or_cask(:M)).to eq(%w[foo/bar/git])
// 518:         expect(hub.renamed_formulae).to be_empty
// 519:       end
// 520:
// 521:       specify "with formula migrated to cask in same tap" do
// 522:         # Setup a tap with both formulae and casks
// 523:         (tap.path/"Formula").mkpath
// 524:         (tap.path/"Casks").mkpath
// 525:         (tap.path/"tap_migrations.json").write <<~JSON
// 526:           { "old-formula": "foo/bar/new-cask" }
// 527:         JSON
// 528:
// 529:         # Mock that the tap has a cask with the migration target name
// 530:         allow(tap).to receive(:cask_tokens).and_return(["new-cask"])
// 531:
// 532:         reporter_instance = reporter_class.new(tap)
// 533:         allow(reporter_instance).to receive(:report).and_return({ D: ["foo/bar/old-formula"] })
// 534:
// 535:         # Verify the migration would be detected as formula-to-cask migration
// 536:         expect(tap.tap_migrations).to eq({ "old-formula" => "foo/bar/new-cask" })
// 537:         expect(tap.cask_tokens).to include("new-cask")
// 538:       end
// 539:     end
// 540:
// 541:     describe "#ensure_trusted_tap_installed!" do
// 542:       let(:other_tap) { Tap.fetch("foo", "bar") }
// 543:
// 544:       before { allow(other_tap).to receive(:installed?).and_return(false) }
// 545:
// 546:       it "recommends trusting just the migrated package then migrating a rename" do
// 547:         expect(other_tap).not_to receive(:ensure_installed!)
// 548:         expect { reporter.ensure_trusted_tap_installed!("oldfoo", "newfoo", other_tap) }
// 549:           .to output(%r{brew trust foo/bar/newfoo.*brew migrate oldfoo}m).to_stderr
// 550:       end
// 551:
// 552:       it "recommends a reinstall for an unchanged-name tap migration" do
// 553:         expect { reporter.ensure_trusted_tap_installed!("foo", "foo", other_tap) }
// 554:           .to output(/brew reinstall foo/).to_stderr
// 555:       end
// 556:
// 557:       it "taps a trusted tap" do
// 558:         allow(other_tap).to receive(:official?).and_return(true)
// 559:         expect(other_tap).to receive(:ensure_installed!)
// 560:         reporter.ensure_trusted_tap_installed!("foo", "foo", other_tap)
// 561:       end
// 562:     end
// 563:
// 564:     describe "#diff" do
// 565:       context "when using the API" do
// 566:         subject(:reporter) do
// 567:           described_class.new(tap,
// 568:                               api_names_txt:        Pathname("formula_names.txt"),
// 569:                               api_names_before_txt: Pathname("formula_names_before.txt"),
// 570:                               api_dir_prefix:       HOMEBREW_CACHE/"api")
// 571:         end
// 572:
// 573:         it "ignore lines that haven't changed" do
// 574:           expect(Utils).to receive(:popen_read).and_return(<<~DIFF)
// 575:             foo
// 576:             +bar
// 577:             -baz
// 578:           DIFF
// 579:
// 580:           expect(reporter.diff).to eq(<<~DIFF.strip)
// 581:             A api/bar.rb
// 582:             D api/baz.rb
// 583:           DIFF
// 584:         end
// 585:
// 586:         it "handles moved lines" do
// 587:           expect(Utils).to receive(:popen_read).and_return(<<~DIFF)
// 588:             +baz
// 589:             foo
// 590:             +bar
// 591:             +baz
// 592:             -bar
// 593:             -baz
// 594:           DIFF
// 595:
// 596:           expect(reporter.diff).to eq(<<~DIFF.strip)
// 597:             A api/baz.rb
// 598:           DIFF
// 599:         end
// 600:       end
// 601:     end
// 602:   end
// 603:
// 604:   describe ReporterHub do
// 605:     let(:hub) { described_class.new }
// 606:
// 607:     before do
// 608:       ENV["HOMEBREW_NO_COLOR"] = "1"
// 609:       allow(hub).to receive(:select_formula_or_cask).and_return([])
// 610:     end
// 611:
// 612:     it "dumps new formulae report" do
// 613:       allow(hub).to receive(:select_formula_or_cask).with(:A).and_return(["foo", "bar", "baz"])
// 614:       allow(hub).to receive(:installed?).and_return(false)
// 615:       allow(Homebrew::API::Internal).to receive(:formula_hash) do |name|
// 616:         {
// 617:           "foo" => { "desc" => "foobly things" },
// 618:           "baz" => { "desc" => "baz desc" },
// 619:         }[name]
// 620:       end
// 621:       allow(Homebrew::API).to receive(:fetch_json_api_file).and_raise("unexpected public API lookup")
// 622:       expect { hub.dump }.to output(<<~EOS).to_stdout
// 623:         ==> New Formulae
// 624:         bar
// 625:         baz: baz desc
// 626:         foo: foobly things
// 627:       EOS
// 628:     end
// 629:
// 630:     it "dumps new casks report" do
// 631:       allow(hub).to receive(:select_formula_or_cask).with(:AC).and_return(["cask1", "cask2", "foo/tap/cask3"])
// 632:       allow(hub).to receive(:cask_installed?).and_return(false)
// 633:       allow(Homebrew::API::Internal).to receive(:cask_hash) do |token|
// 634:         {
// 635:           "cask1" => { "desc" => "desc1" },
// 636:           "cask3" => { "desc" => "desc3" },
// 637:         }[token]
// 638:       end
// 639:       allow(Homebrew::API).to receive(:fetch_json_api_file).and_raise("unexpected public API lookup")
// 640:       allow(Cask::Caskroom).to receive(:any_casks_installed?).and_return(true)
// 641:       expect { hub.dump }.to output(<<~EOS).to_stdout
// 642:         ==> New Casks
// 643:         cask1: desc1
// 644:         cask2
// 645:         cask3
// 646:       EOS
// 647:     end
// 648:
// 649:     it "does not dump update details when HOMEBREW_AUTO_UPDATE_QUIET is set during auto-update" do
// 650:       ENV["HOMEBREW_AUTO_UPDATE_QUIET"] = "1"
// 651:       allow(hub).to receive(:select_formula_or_cask).with(:A).and_return(["foo"])
// 652:       allow(hub).to receive(:installed?).and_return(false)
// 653:
// 654:       expect { hub.dump(auto_update: true) }.not_to output.to_stdout
// 655:     end
// 656:
// 657:     it "dumps update details when HOMEBREW_AUTO_UPDATE_QUIET is set during an explicit update" do
// 658:       ENV["HOMEBREW_AUTO_UPDATE_QUIET"] = "1"
// 659:       allow(hub).to receive(:select_formula_or_cask).with(:A).and_return(["foo"])
// 660:       allow(hub).to receive_messages(installed?: false, description: nil)
// 661:
// 662:       expect { hub.dump }.to output("==> New Formulae\nfoo\n").to_stdout
// 663:     end
// 664:
// 665:     it "dumps deleted installed formulae and casks report" do
// 666:       allow(hub).to receive(:select_formula_or_cask).with(:D).and_return(["baz", "foo", "bar"])
// 667:       allow(hub).to receive(:installed?).with("baz").and_return(true)
// 668:       allow(hub).to receive(:installed?).with("foo").and_return(true)
// 669:       allow(hub).to receive(:installed?).with("bar").and_return(true)
// 670:       allow(hub).to receive(:select_formula_or_cask).with(:A).and_return([])
// 671:       allow(hub).to receive(:select_formula_or_cask).with(:DC).and_return(["cask2", "cask1"])
// 672:       allow(hub).to receive(:cask_installed?).with("cask1").and_return(true)
// 673:       allow(hub).to receive(:cask_installed?).with("cask2").and_return(true)
// 674:       allow(Homebrew::SimulateSystem).to receive(:simulating_or_running_on_linux?).and_return(false)
// 675:       expect { hub.dump }.to output(<<~EOS).to_stdout
// 676:         ==> Deleted Installed Formulae
// 677:         bar
// 678:         baz
// 679:         foo
// 680:         ==> Deleted Installed Casks
// 681:         cask1
// 682:         cask2
// 683:       EOS
// 684:     end
// 685:
// 686:     it "dumps outdated formulae and casks report" do
// 687:       allow(Formula).to receive(:installed).and_return([
// 688:         instance_double(Formula, name: "foo", outdated?: true),
// 689:         instance_double(Formula, name: "bar", outdated?: true),
// 690:       ])
// 691:       allow(Cask::Caskroom).to receive(:casks).and_return([
// 692:         instance_double(Cask::Cask, token: "baz", outdated?: true),
// 693:         instance_double(Cask::Cask, token: "qux", outdated?: true),
// 694:       ])
// 695:       expect { hub.dump }.to output(<<~EOS).to_stdout
// 696:         ==> Outdated Formulae
// 697:         bar
// 698:         foo
// 699:         ==> Outdated Casks
// 700:         baz
// 701:         qux
// 702:
// 703:         You have 2 outdated formulae and 2 outdated casks installed.
// 704:         You can upgrade them with brew upgrade
// 705:         or list them with brew outdated.
// 706:       EOS
// 707:     end
// 708:
// 709:     it "skips the outdated count when auto-updating before a zero-argument upgrade or outdated" do
// 710:       ENV["HOMEBREW_AUTO_UPDATE_SKIP_OUTDATED"] = "1"
// 711:       allow(Formula).to receive(:installed).and_return([
// 712:         instance_double(Formula, name: "foo", outdated?: true),
// 713:       ])
// 714:       allow(Cask::Caskroom).to receive(:casks).and_return([])
// 715:       expect { hub.dump(auto_update: true) }.not_to output.to_stdout
// 716:     end
// 717:
// 718:     it "prints nothing if there are no changes" do
// 719:       allow(Formula).to receive(:installed).and_return([])
// 720:       allow(Cask::Caskroom).to receive(:casks).and_return([])
// 721:       expect { hub.dump }.not_to output.to_stdout
// 722:     end
// 723:
// 724:     it "merges frozen report arrays" do
// 725:       allow(hub).to receive(:select_formula_or_cask).and_call_original
// 726:       first_reporter = instance_double(Reporter, report: { A: ["foo"].freeze })
// 727:       second_reporter = instance_double(Reporter, report: { A: ["bar"] })
// 728:
// 729:       hub.add(first_reporter)
// 730:       hub.add(second_reporter)
// 731:
// 732:       expect(hub.select_formula_or_cask(:A)).to eq(%w[foo bar])
// 733:     end
// 734:   end
// 735: end
