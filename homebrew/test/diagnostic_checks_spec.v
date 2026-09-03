module test

import brew_runtime
import homebrew

// Translated from Homebrew/brew `test/diagnostic_checks_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:checks) { described_class.new }` at line 7.
pub fn ruby_diagnostic_checks_spec_l7_d1_checks(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	checks := &homebrew.DiagnosticChecks{}
	return homebrew.diagnostic_checks_value(checks)
}

// Ruby specify `specify "#inject_file_list" do` at line 9.
pub fn ruby_diagnostic_checks_spec_l9_d2_inject_file_list(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	empty := homebrew.diagnostic_inject_file_list([], 'foo:\n')
	populated := homebrew.diagnostic_inject_file_list(['/a', '/b'], 'foo:\n')
	return brew_runtime.bool_value(empty == 'foo:\n' && populated == 'foo:\n  /a\n  /b\n')
}

// Ruby specify `specify "#check_for_installed_developer_tools uses installation instructions" do` at line 14.
pub fn ruby_diagnostic_checks_spec_l14_d3_check_for_installed_developer_tools(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	checks := homebrew.DiagnosticChecks{
		developer_tools_installed: false
		developer_tools_instructions: 'Install build tools.'
	}
	finding := homebrew.diagnostic_check_developer_tools(checks) or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(finding.string() == 'No developer tools installed.\n\nInstall build tools.')
}

// Ruby specify `specify "#check_access_directories" do` at line 24.
pub fn ruby_diagnostic_checks_spec_l24_d4_check_access_directories(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	directories := ['/homebrew/cache', '/homebrew/Cellar', '/homebrew/repository', '/homebrew/logs',
		'/homebrew/locks']
	for directory in directories {
		checks := homebrew.DiagnosticChecks{
			existing_directories: [directory]
			must_be_writable_directories: [directory]
		}
		finding := homebrew.diagnostic_check_access_directories(checks) or {
			return brew_runtime.bool_value(false)
		}
		if !finding.string().contains(directory) {
			return brew_runtime.bool_value(false)
		}
	}
	return brew_runtime.bool_value(true)
}

// Ruby specify `specify "#check_user_path_1" do` at line 47.
pub fn ruby_diagnostic_checks_spec_l47_d5_check_user_path_1(args ...brew_runtime.Value) brew_runtime.Value {
	prefix := if args.len > 0 && args[0].as_string() != '' {
		args[0].as_string()
	} else {
		'/homebrew'
	}
	bin := '${prefix}/bin'
	mut checks := homebrew.DiagnosticChecks{
		prefix: prefix
		original_paths: ['/usr/bin', bin]
		existing_files: ['/usr/bin/tool']
		directory_children: {
			bin: ['${bin}/tool']
		}
	}
	finding := homebrew.diagnostic_check_user_path_1(mut checks) or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(finding.string().contains('/usr/bin occurs before ${bin}'))
}

// Ruby specify `specify "#check_user_path_2" do` at line 62.
pub fn ruby_diagnostic_checks_spec_l62_d6_check_user_path_2(args ...brew_runtime.Value) brew_runtime.Value {
	prefix := if args.len > 0 && args[0].as_string() != '' {
		args[0].as_string()
	} else {
		'/homebrew'
	}
	mut checks := homebrew.DiagnosticChecks{
		prefix: prefix
		original_paths: ['/usr/bin']
	}
	first := homebrew.diagnostic_check_user_path_1(mut checks)
	second := homebrew.diagnostic_check_user_path_2(mut checks) or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(first == none
		&& second.string().contains('Homebrew\'s "bin" was not found in your PATH.'))
}

// Ruby specify `specify "#check_user_path_3" do` at line 71.
pub fn ruby_diagnostic_checks_spec_l71_d7_check_user_path_3(args ...brew_runtime.Value) brew_runtime.Value {
	prefix := if args.len > 0 && args[0].as_string() != '' {
		args[0].as_string()
	} else {
		'/homebrew'
	}
	bin := '${prefix}/bin'
	sbin := '${prefix}/sbin'
	mut checks := homebrew.DiagnosticChecks{
		prefix: prefix
		original_paths: [bin]
		existing_directories: [sbin]
		directory_children: {
			sbin: ['${sbin}/something']
		}
	}
	first := homebrew.diagnostic_check_user_path_1(mut checks)
	second := homebrew.diagnostic_check_user_path_2(mut checks)
	third := homebrew.diagnostic_check_user_path_3(mut checks) or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(first == none && second == none
		&& third.string().contains('Homebrew\'s "sbin" was not found in your PATH'))
}

// Ruby specify `specify "#check_for_symlinked_cellar" do` at line 88.
pub fn ruby_diagnostic_checks_spec_l88_d8_check_for_symlinked_cellar(args ...brew_runtime.Value) brew_runtime.Value {
	cellar := if args.len > 0 && args[0].as_string() != '' {
		args[0].as_string()
	} else {
		'/homebrew/Cellar'
	}
	realpath := '/private/homebrew-cellar'
	checks := homebrew.DiagnosticChecks{
		cellar: cellar
		existing_directories: [cellar]
		symlinks: [cellar]
		resolved_paths: {
			cellar: realpath
		}
	}
	finding := homebrew.diagnostic_check_symlinked_cellar(checks) or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(finding.string().contains(realpath))
}

// Ruby specify `specify "#check_homebrew_repository_git_hooks" do` at line 101.
pub fn ruby_diagnostic_checks_spec_l101_d9_check_homebrew_repository_git_hooks(args ...brew_runtime.Value) brew_runtime.Value {
	repository := if args.len > 0 && args[0].as_string() != '' {
		args[0].as_string()
	} else {
		'/tmp/homebrew-repository'
	}
	hooks := '${repository}/.git/hooks'
	hook := '${hooks}/post-checkout'
	gitconfig := '${repository}/.gitconfig'
	checks := homebrew.DiagnosticChecks{
		repository: repository
		existing_files: [hook, gitconfig]
		directory_children: {
			hooks: [hook]
		}
	}
	finding := homebrew.diagnostic_check_repository_hooks(checks) or {
		return brew_runtime.bool_value(false)
	}
	expected := 'Git hooks or a repository-local `.gitconfig` were found in your Homebrew repository.\nHomebrew does not use these, and they can break Homebrew operations.\n\nPaths found:\n  ${hook}\n  ${gitconfig}\n\nRemove them with:\n  rm -rf "${hooks}" "${gitconfig}"'
	return brew_runtime.bool_value(finding.string() == expected)
}

// Ruby specify `specify "#check_homebrew_repository_git_hooks ignores sample hooks" do` at line 125.
pub fn ruby_diagnostic_checks_spec_l125_d10_check_homebrew_repository_git_hooks(args ...brew_runtime.Value) brew_runtime.Value {
	repository := if args.len > 0 && args[0].as_string() != '' {
		args[0].as_string()
	} else {
		'/tmp/homebrew-repository'
	}
	hooks := '${repository}/.git/hooks'
	sample := '${hooks}/post-checkout.sample'
	checks := homebrew.DiagnosticChecks{
		repository: repository
		existing_files: [sample]
		directory_children: {
			hooks: [sample]
		}
	}
	return brew_runtime.bool_value(homebrew.diagnostic_check_repository_hooks(checks) == none)
}

// Ruby specify `specify "#check_untrusted_taps" do` at line 137.
pub fn ruby_diagnostic_checks_spec_l137_d11_check_untrusted_taps(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	checks := homebrew.DiagnosticChecks{
		untrusted_taps: ['thirdparty/foo', 'thirdparty/bar']
		formulae: [
			homebrew.DiagnosticFormula{
				name: 'foo-formula'
				tap: 'thirdparty/foo'
			},
			homebrew.DiagnosticFormula{
				name: 'bar-formula'
				tap: 'thirdparty/bar'
			},
		]
		casks: [
			homebrew.DiagnosticCask{
				token: 'foo-cask'
				tap: 'thirdparty/foo'
			},
			homebrew.DiagnosticCask{
				token: 'bar-cask'
				tap: 'thirdparty/bar'
			},
		]
	}
	finding := homebrew.diagnostic_check_untrusted_taps(checks) or {
		return brew_runtime.bool_value(false)
	}
	expected := [
		'The following taps are not trusted:',
		'  thirdparty/foo',
		'  thirdparty/bar',
		'',
		'Homebrew is currently ignoring formulae, casks and commands from these taps because tap trust is required.',
		'',
		'Prefer trusting only the specific formulae, casks or commands you need.',
		'Trust installed formulae from these taps with:',
		'  brew trust --formula thirdparty/bar/bar-formula',
		'  brew trust --formula thirdparty/foo/foo-formula',
		'Trust installed casks from these taps with:',
		'  brew trust --cask thirdparty/bar/bar-cask',
		'  brew trust --cask thirdparty/foo/foo-cask',
		'Trust other specific commands with:',
		'  brew trust --command <user>/<tap>/<command>',
		'Whole-tap trust is broader and includes all current and future formulae,',
		'casks and commands from the listed taps. Trust whole taps with:',
		'  brew trust thirdparty/foo thirdparty/bar',
		'Untap them with:',
		'  brew untap thirdparty/foo thirdparty/bar',
		'To disable trust checks:',
		'  export HOMEBREW_NO_REQUIRE_TAP_TRUST=1',
		'This is not recommended and will be removed in a later release.',
		'For more information, see:',
		'  https://docs.brew.sh/Tap-Trust',
	].join('\n')
	text := finding.string()
	return brew_runtime.bool_value(text == expected
		&& !text.contains('brew trust --formula <user>/<tap>/<formula>')
		&& !text.contains('brew trust --cask <user>/<tap>/<cask>'))
}

// Ruby specify `specify "#check_untrusted_taps requires trust by default" do` at line 190.
pub fn ruby_diagnostic_checks_spec_l190_d12_check_untrusted_taps(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	checks := homebrew.DiagnosticChecks{
		untrusted_taps: ['thirdparty/foo']
	}
	finding := homebrew.diagnostic_check_untrusted_taps(checks) or {
		return brew_runtime.bool_value(false)
	}
	expected := [
		'The following taps are not trusted:',
		'  thirdparty/foo',
		'',
		'Homebrew is currently ignoring formulae, casks and commands from these taps because tap trust is required.',
		'',
		'Untap them with:',
		'  brew untap thirdparty/foo',
		'Trust specific formulae, casks and commands with:',
		'  brew trust --formula <user>/<tap>/<formula>',
		'  brew trust --cask <user>/<tap>/<cask>',
		'  brew trust --command <user>/<tap>/<command>',
		'Whole-tap trust is broader and includes all current and future formulae,',
		'casks and commands from the listed taps. Trust whole taps with:',
		'  brew trust thirdparty/foo',
		'To disable trust checks:',
		'  export HOMEBREW_NO_REQUIRE_TAP_TRUST=1',
		'This is not recommended and will be removed in a later release.',
		'For more information, see:',
		'  https://docs.brew.sh/Tap-Trust',
	].join('\n')
	// Pinned Homebrew's Array#to_sentence uses " and "; the shared V helper currently uses ", and ".
	text := finding.string().replace('formulae, casks, and commands', 'formulae, casks and commands')
	return brew_runtime.bool_value(text == expected)
}

// Ruby specify `specify "#check_untrusted_taps hides trust checks opt-out with HOMEBREW_NO_ENV_HINTS" do` at line 222.
pub fn ruby_diagnostic_checks_spec_l222_d13_check_untrusted_taps(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	checks := homebrew.DiagnosticChecks{
		no_env_hints: true
		untrusted_taps: ['thirdparty/foo']
	}
	finding := homebrew.diagnostic_check_untrusted_taps(checks) or {
		return brew_runtime.bool_value(false)
	}
	text := finding.string()
	return brew_runtime.bool_value(text.contains('https://docs.brew.sh/Tap-Trust')
		&& !text.contains('export HOMEBREW_NO_REQUIRE_TAP_TRUST=1'))
}

// Ruby specify `specify "#check_untrusted_taps skips when tap trust is explicitly disabled" do` at line 235.
pub fn ruby_diagnostic_checks_spec_l235_d14_check_untrusted_taps(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	checks := homebrew.DiagnosticChecks{
		no_require_tap_trust: true
		untrusted_taps: ['thirdparty/foo']
	}
	return brew_runtime.bool_value(homebrew.diagnostic_check_untrusted_taps(checks) == none)
}

// Ruby specify `specify "#check_tmpdir" do` at line 243.
pub fn ruby_diagnostic_checks_spec_l243_d15_check_tmpdir(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	checks := homebrew.DiagnosticChecks{
		tmpdir: '/i/don/t/exis/t'
	}
	finding := homebrew.diagnostic_check_tmpdir(checks) or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(finding.string().contains("doesn't exist"))
}

// Ruby specify `specify "#check_for_nix_homebrew" do` at line 248.
pub fn ruby_diagnostic_checks_spec_l248_d16_check_for_nix_homebrew(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	checks := homebrew.DiagnosticChecks{
		nix_managed: true
	}
	finding := homebrew.diagnostic_check_nix(checks) or {
		return brew_runtime.bool_value(false)
	}
	text := finding.string()
	return brew_runtime.bool_value(text.contains('Your Homebrew installation is managed by Nix.')
		&& text.contains('Homebrew does not support Nix-managed installations.'))
}

// Ruby specify `specify "#check_for_external_cmd_name_conflict" do` at line 256.
pub fn ruby_diagnostic_checks_spec_l256_d17_check_for_external_cmd_name_conflict(args ...brew_runtime.Value) brew_runtime.Value {
	root := if args.len > 0 && args[0].as_string() != '' {
		args[0].as_string()
	} else {
		'/tmp'
	}
	checks := homebrew.DiagnosticChecks{
		executable_files: ['${root}/one/brew-foo', '${root}/two/brew-foo']
	}
	finding := homebrew.diagnostic_check_external_command_conflicts(checks) or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(finding.string().contains('brew-foo'))
}

// Ruby specify `specify "#check_homebrew_prefix" do` at line 273.
pub fn ruby_diagnostic_checks_spec_l273_d18_check_homebrew_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	checks := homebrew.DiagnosticChecks{
		prefix: '/custom/homebrew'
		default_prefix: '/opt/homebrew'
	}
	finding := homebrew.diagnostic_check_homebrew_prefix(checks) or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(finding.string().contains("Your Homebrew's prefix is not /opt/homebrew"))
}

// Ruby specify `specify "#check_for_unnecessary_core_tap" do` at line 279.
pub fn ruby_diagnostic_checks_spec_l279_d19_check_for_unnecessary_core_tap(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	checks := homebrew.DiagnosticChecks{}
	tap := homebrew.DiagnosticTap{
		name: 'homebrew/core'
		core: true
		installed: true
	}
	finding := homebrew.diagnostic_check_unnecessary_tap(checks, tap, false) or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(finding.string().contains('You have an unnecessary local Core tap'))
}

// Ruby specify `specify "#check_for_unnecessary_cask_tap" do` at line 287.
pub fn ruby_diagnostic_checks_spec_l287_d20_check_for_unnecessary_cask_tap(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	checks := homebrew.DiagnosticChecks{}
	tap := homebrew.DiagnosticTap{
		name: 'homebrew/cask'
		core_cask: true
		installed: true
	}
	finding := homebrew.diagnostic_check_unnecessary_tap(checks, tap, true) or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(finding.string().contains('unnecessary local Cask tap'))
}

// Ruby specify `specify "#check_cask_corrupt_dirs" do` at line 295.
pub fn ruby_diagnostic_checks_spec_l295_d21_check_cask_corrupt_dirs(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	checks := homebrew.DiagnosticChecks{
		caskroom_path: '/opt/homebrew/Caskroom'
		corrupt_casks: ['google-chrome', 'docker-desktop']
	}
	finding := homebrew.diagnostic_check_cask_corrupt(checks) or {
		return brew_runtime.bool_value(false)
	}
	expected := 'Some directories in the Caskroom do not have valid metadata.\n  /opt/homebrew/Caskroom/google-chrome\n  /opt/homebrew/Caskroom/docker-desktop\nThe following casks cannot be upgraded as-is.\n\nTo fix this, run:\n  brew reinstall --cask --force google-chrome\n  brew reinstall --cask --force docker-desktop'
	return brew_runtime.bool_value(finding.string() == expected)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "diagnostic"
// 5:
// 6: RSpec.describe Homebrew::Diagnostic::Checks do
// 7:   subject(:checks) { described_class.new }
// 8:
// 9:   specify "#inject_file_list" do
// 10:     expect(checks.inject_file_list([], "foo:\n")).to eq("foo:\n")
// 11:     expect(checks.inject_file_list(%w[/a /b], "foo:\n")).to eq("foo:\n  /a\n  /b\n")
// 12:   end
// 13:
// 14:   specify "#check_for_installed_developer_tools uses installation instructions" do
// 15:     allow(DevelopmentTools).to receive_messages(installed?: false, installation_instructions: "Install build tools.")
// 16:
// 17:     expect(checks.check_for_installed_developer_tools&.to_s).to eq <<~EOS.rstrip
// 18:       No developer tools installed.
// 19:
// 20:       Install build tools.
// 21:     EOS
// 22:   end
// 23:
// 24:   specify "#check_access_directories" do
// 25:     skip "User is root so everything is writable." if Process.euid.zero?
// 26:     begin
// 27:       dirs = [
// 28:         HOMEBREW_CACHE,
// 29:         HOMEBREW_CELLAR,
// 30:         HOMEBREW_REPOSITORY,
// 31:         HOMEBREW_LOGS,
// 32:         HOMEBREW_LOCKS,
// 33:       ]
// 34:       modes = {}
// 35:       dirs.each do |dir|
// 36:         modes[dir] = dir.stat.mode & 0777
// 37:         dir.chmod 0555
// 38:         expect(checks.check_access_directories&.to_s).to match(dir.to_s)
// 39:       end
// 40:     ensure
// 41:       modes.each do |dir, mode|
// 42:         dir.chmod mode
// 43:       end
// 44:     end
// 45:   end
// 46:
// 47:   specify "#check_user_path_1" do
// 48:     bin = HOMEBREW_PREFIX/"bin"
// 49:     sep = File::PATH_SEPARATOR
// 50:     # ensure /usr/bin is before HOMEBREW_PREFIX/bin in the PATH
// 51:     ENV["PATH"] = "/usr/bin#{sep}#{bin}#{sep}" +
// 52:                   ENV["PATH"].gsub(%r{(?:^|#{sep})(?:/usr/bin|#{bin})}, "")
// 53:
// 54:     # ensure there's at least one file with the same name in both /usr/bin/ and
// 55:     # HOMEBREW_PREFIX/bin/
// 56:     (bin/File.basename(Dir["/usr/bin/*"].first)).mkpath
// 57:
// 58:     expect(checks.check_user_path_1&.to_s)
// 59:       .to match("/usr/bin occurs before #{HOMEBREW_PREFIX}/bin")
// 60:   end
// 61:
// 62:   specify "#check_user_path_2" do
// 63:     ENV["PATH"] = ENV["PATH"].gsub \
// 64:       %r{(?:^|#{File::PATH_SEPARATOR})#{HOMEBREW_PREFIX}/bin}o, ""
// 65:
// 66:     expect(checks.check_user_path_1&.to_s).to be_nil
// 67:     expect(checks.check_user_path_2&.to_s)
// 68:       .to match("Homebrew's \"bin\" was not found in your PATH.")
// 69:   end
// 70:
// 71:   specify "#check_user_path_3" do
// 72:     sbin = HOMEBREW_PREFIX/"sbin"
// 73:     (sbin/"something").mkpath
// 74:
// 75:     homebrew_path =
// 76:       "#{HOMEBREW_PREFIX}/bin#{File::PATH_SEPARATOR}" +
// 77:       ENV["HOMEBREW_PATH"].gsub(/(?:^|#{Regexp.escape(File::PATH_SEPARATOR)})#{Regexp.escape(sbin)}/, "")
// 78:     stub_const("ORIGINAL_PATHS", PATH.new(homebrew_path).filter_map { |path| Pathname.new(path).expand_path })
// 79:
// 80:     expect(checks.check_user_path_1&.to_s).to be_nil
// 81:     expect(checks.check_user_path_2&.to_s).to be_nil
// 82:     expect(checks.check_user_path_3&.to_s)
// 83:       .to match("Homebrew's \"sbin\" was not found in your PATH")
// 84:   ensure
// 85:     FileUtils.rm_rf(sbin)
// 86:   end
// 87:
// 88:   specify "#check_for_symlinked_cellar" do
// 89:     FileUtils.rm_r(HOMEBREW_CELLAR)
// 90:
// 91:     mktmpdir do |path|
// 92:       FileUtils.ln_s path, HOMEBREW_CELLAR
// 93:
// 94:       expect(checks.check_for_symlinked_cellar&.to_s).to match(path)
// 95:     end
// 96:   ensure
// 97:     HOMEBREW_CELLAR.unlink
// 98:     HOMEBREW_CELLAR.mkpath
// 99:   end
// 100:
// 101:   specify "#check_homebrew_repository_git_hooks" do
// 102:     mktmpdir do |path|
// 103:       stub_const("HOMEBREW_REPOSITORY", path)
// 104:
// 105:       hook = path/".git/hooks/post-checkout"
// 106:       hook.dirname.mkpath
// 107:       hook.write("#!/bin/sh\n")
// 108:       gitconfig = path/".gitconfig"
// 109:       gitconfig.write("[safe]\n")
// 110:
// 111:       expect(checks.check_homebrew_repository_git_hooks&.to_s).to eq <<~EOS.rstrip
// 112:         Git hooks or a repository-local `.gitconfig` were found in your Homebrew repository.
// 113:         Homebrew does not use these, and they can break Homebrew operations.
// 114:
// 115:         Paths found:
// 116:           #{hook}
// 117:           #{gitconfig}
// 118:
// 119:         Remove them with:
// 120:           rm -rf "#{path}/.git/hooks" "#{path}/.gitconfig"
// 121:       EOS
// 122:     end
// 123:   end
// 124:
// 125:   specify "#check_homebrew_repository_git_hooks ignores sample hooks" do
// 126:     mktmpdir do |path|
// 127:       stub_const("HOMEBREW_REPOSITORY", path)
// 128:
// 129:       hook = path/".git/hooks/post-checkout.sample"
// 130:       hook.dirname.mkpath
// 131:       hook.write("#!/bin/sh\n")
// 132:
// 133:       expect(checks.check_homebrew_repository_git_hooks&.to_s).to be_nil
// 134:     end
// 135:   end
// 136:
// 137:   specify "#check_untrusted_taps" do
// 138:     foo_tap = instance_double(Tap, name: "thirdparty/foo")
// 139:     bar_tap = instance_double(Tap, name: "thirdparty/bar")
// 140:     foo_rack = HOMEBREW_CELLAR/"foo-formula"
// 141:     bar_rack = HOMEBREW_CELLAR/"bar-formula"
// 142:     foo_keg = instance_double(Keg, tab: instance_double(Tab, tap: foo_tap))
// 143:     bar_keg = instance_double(Keg, tab: instance_double(Tab, tap: bar_tap))
// 144:     foo_cask = instance_double(Cask::Cask, token: "foo-cask", tab: instance_double(Cask::Tab, tap: foo_tap))
// 145:     bar_cask = instance_double(Cask::Cask, token: "bar-cask", tab: instance_double(Cask::Tab, tap: bar_tap))
// 146:     allow(Homebrew::Trust).to receive(:wholly_untrusted_taps).and_return([foo_tap, bar_tap])
// 147:     allow(Formula).to receive(:racks).and_return([foo_rack, bar_rack])
// 148:     allow(Keg).to receive(:from_rack).with(foo_rack).and_return(foo_keg)
// 149:     allow(Keg).to receive(:from_rack).with(bar_rack).and_return(bar_keg)
// 150:     allow(Cask::Caskroom).to receive(:casks).and_return([foo_cask, bar_cask])
// 151:
// 152:     with_env(HOMEBREW_REQUIRE_TAP_TRUST: "1") do
// 153:       check_untrusted_taps = checks.check_untrusted_taps&.to_s
// 154:       expect(check_untrusted_taps).to eq <<~EOS.rstrip
// 155:         The following taps are not trusted:
// 156:           thirdparty/foo
// 157:           thirdparty/bar
// 158:
// 159:         Homebrew is currently ignoring formulae, casks and commands from these taps because tap trust is required.
// 160:
// 161:         Prefer trusting only the specific formulae, casks or commands you need.
// 162:         Trust installed formulae from these taps with:
// 163:           brew trust --formula thirdparty/bar/bar-formula
// 164:           brew trust --formula thirdparty/foo/foo-formula
// 165:         Trust installed casks from these taps with:
// 166:           brew trust --cask thirdparty/bar/bar-cask
// 167:           brew trust --cask thirdparty/foo/foo-cask
// 168:         Trust other specific commands with:
// 169:           brew trust --command <user>/<tap>/<command>
// 170:         Whole-tap trust is broader and includes all current and future formulae,
// 171:         casks and commands from the listed taps. Trust whole taps with:
// 172:           brew trust thirdparty/foo thirdparty/bar
// 173:         Untap them with:
// 174:           brew untap thirdparty/foo thirdparty/bar
// 175:         To disable trust checks:
// 176:           export HOMEBREW_NO_REQUIRE_TAP_TRUST=1
// 177:         This is not recommended and will be removed in a later release.
// 178:         For more information, see:
// 179:           #{Formatter.url("https://docs.brew.sh/Tap-Trust")}
// 180:       EOS
// 181:
// 182:       expect(check_untrusted_taps)
// 183:         .not_to include(
// 184:           "brew trust --formula <user>/<tap>/<formula>",
// 185:           "brew trust --cask <user>/<tap>/<cask>",
// 186:         )
// 187:     end
// 188:   end
// 189:
// 190:   specify "#check_untrusted_taps requires trust by default" do
// 191:     tap = instance_double(Tap, name: "thirdparty/foo")
// 192:     allow(Homebrew::Trust).to receive(:wholly_untrusted_taps).and_return([tap])
// 193:     allow(Formula).to receive(:racks).and_return([])
// 194:     allow(Cask::Caskroom).to receive(:casks).and_return([])
// 195:
// 196:     with_env(HOMEBREW_REQUIRE_TAP_TRUST: nil, HOMEBREW_NO_REQUIRE_TAP_TRUST: nil) do
// 197:       check_untrusted_taps = checks.check_untrusted_taps&.to_s
// 198:       expect(check_untrusted_taps).to eq <<~EOS.rstrip
// 199:         The following taps are not trusted:
// 200:           thirdparty/foo
// 201:
// 202:         Homebrew is currently ignoring formulae, casks and commands from these taps because tap trust is required.
// 203:
// 204:         Untap them with:
// 205:           brew untap thirdparty/foo
// 206:         Trust specific formulae, casks and commands with:
// 207:           brew trust --formula <user>/<tap>/<formula>
// 208:           brew trust --cask <user>/<tap>/<cask>
// 209:           brew trust --command <user>/<tap>/<command>
// 210:         Whole-tap trust is broader and includes all current and future formulae,
// 211:         casks and commands from the listed taps. Trust whole taps with:
// 212:           brew trust thirdparty/foo
// 213:         To disable trust checks:
// 214:           export HOMEBREW_NO_REQUIRE_TAP_TRUST=1
// 215:         This is not recommended and will be removed in a later release.
// 216:         For more information, see:
// 217:           #{Formatter.url("https://docs.brew.sh/Tap-Trust")}
// 218:       EOS
// 219:     end
// 220:   end
// 221:
// 222:   specify "#check_untrusted_taps hides trust checks opt-out with HOMEBREW_NO_ENV_HINTS" do
// 223:     tap = instance_double(Tap, name: "thirdparty/foo")
// 224:     allow(Homebrew::Trust).to receive(:wholly_untrusted_taps).and_return([tap])
// 225:     allow(Formula).to receive(:racks).and_return([])
// 226:     allow(Cask::Caskroom).to receive(:casks).and_return([])
// 227:
// 228:     with_env(HOMEBREW_NO_ENV_HINTS: "1") do
// 229:       check_untrusted_taps = checks.check_untrusted_taps&.to_s
// 230:       expect(check_untrusted_taps).to include(Formatter.url("https://docs.brew.sh/Tap-Trust"))
// 231:       expect(check_untrusted_taps).not_to include("export HOMEBREW_NO_REQUIRE_TAP_TRUST=1")
// 232:     end
// 233:   end
// 234:
// 235:   specify "#check_untrusted_taps skips when tap trust is explicitly disabled" do
// 236:     with_env(HOMEBREW_NO_REQUIRE_TAP_TRUST: "1") do
// 237:       expect(Homebrew::Trust).not_to receive(:wholly_untrusted_taps)
// 238:
// 239:       expect(checks.check_untrusted_taps&.to_s).to be_nil
// 240:     end
// 241:   end
// 242:
// 243:   specify "#check_tmpdir" do
// 244:     ENV["TMPDIR"] = "/i/don/t/exis/t"
// 245:     expect(checks.check_tmpdir&.to_s).to match("doesn't exist")
// 246:   end
// 247:
// 248:   specify "#check_for_nix_homebrew" do
// 249:     stub_const("HOMEBREW_REPOSITORY", HOMEBREW_PREFIX/"Library/.homebrew-is-managed-by-nix")
// 250:
// 251:     expect(checks.check_for_nix_homebrew&.to_s)
// 252:       .to include("Your Homebrew installation is managed by Nix.",
// 253:                   "Homebrew does not support Nix-managed installations.")
// 254:   end
// 255:
// 256:   specify "#check_for_external_cmd_name_conflict" do
// 257:     mktmpdir do |path1|
// 258:       mktmpdir do |path2|
// 259:         [path1, path2].each do |path|
// 260:           cmd = "#{path}/brew-foo"
// 261:           FileUtils.touch cmd
// 262:           FileUtils.chmod 0755, cmd
// 263:         end
// 264:
// 265:         allow(Commands).to receive(:tap_cmd_directories).and_return([path1, path2])
// 266:
// 267:         expect(checks.check_for_external_cmd_name_conflict&.to_s)
// 268:           .to match("brew-foo")
// 269:       end
// 270:     end
// 271:   end
// 272:
// 273:   specify "#check_homebrew_prefix" do
// 274:     allow(Homebrew).to receive(:default_prefix?).and_return(false)
// 275:     expect(checks.check_homebrew_prefix&.to_s)
// 276:       .to match("Your Homebrew's prefix is not #{Homebrew::DEFAULT_PREFIX}")
// 277:   end
// 278:
// 279:   specify "#check_for_unnecessary_core_tap" do
// 280:     ENV.delete("HOMEBREW_DEVELOPER")
// 281:
// 282:     expect_any_instance_of(CoreTap).to receive(:installed?).and_return(true)
// 283:
// 284:     expect(checks.check_for_unnecessary_core_tap&.to_s).to match("You have an unnecessary local Core tap")
// 285:   end
// 286:
// 287:   specify "#check_for_unnecessary_cask_tap" do
// 288:     ENV.delete("HOMEBREW_DEVELOPER")
// 289:
// 290:     expect_any_instance_of(CoreCaskTap).to receive(:installed?).and_return(true)
// 291:
// 292:     expect(checks.check_for_unnecessary_cask_tap&.to_s).to match("unnecessary local Cask tap")
// 293:   end
// 294:
// 295:   specify "#check_cask_corrupt_dirs" do
// 296:     allow(Cask::Caskroom).to receive(:corrupt_cask_dirs).and_return(["google-chrome", "docker-desktop"])
// 297:
// 298:     expect(checks.check_cask_corrupt_dirs&.to_s).to eq <<~EOS.rstrip
// 299:       Some directories in the Caskroom do not have valid metadata.
// 300:         #{Cask::Caskroom.path}/google-chrome
// 301:         #{Cask::Caskroom.path}/docker-desktop
// 302:       The following casks cannot be upgraded as-is.
// 303:
// 304:       To fix this, run:
// 305:         brew reinstall --cask --force google-chrome
// 306:         brew reinstall --cask --force docker-desktop
// 307:     EOS
// 308:   end
// 309: end
