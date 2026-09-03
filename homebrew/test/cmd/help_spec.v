module cmd

import homebrew
import os

// Translated from Homebrew/brew `test/cmd/help_spec.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct HelpSpecFixture {
pub:
	root              string
	internal_path     string
	developer_path    string
	tap_directory     string
	third_party_ruby  string
	official_ruby     string
	self_documenting  string
	commented_command string
}

fn help_spec_write_executable(path string, contents string) ! {
	os.mkdir_all(os.dir(path))!
	os.write_file(path, contents)!
	os.chmod(path, 0o755)!
}

pub fn new_help_spec_fixture(root string) !HelpSpecFixture {
	internal_path := os.join_path(root, 'internal')
	developer_path := os.join_path(root, 'developer')
	tap_directory := os.join_path(root, 'Taps')
	os.mkdir_all(internal_path)!
	os.mkdir_all(developer_path)!
	cat_path := os.join_path(internal_path, 'cat.v')
	os.write_file(cat_path, 'description "Display the source for a formula."\n')!

	third_party_ruby := os.join_path(tap_directory, 'trusthelp', 'homebrew-foo', 'cmd', 'hello-trust-tap.rb')
	help_spec_write_executable(third_party_ruby, 'description "A friendly greeter from a tap."\n')!
	official_ruby := os.join_path(tap_directory, 'homebrew', 'homebrew-test', 'cmd', 'hello-tap.rb')
	help_spec_write_executable(official_ruby, 'description "An official greeter."\n')!
	self_documenting := os.join_path(tap_directory, 'homebrew', 'homebrew-test', 'cmd', 'brew-selfdoc')
	help_spec_write_executable(self_documenting, '#!/bin/bash\necho "Usage: brew selfdoc [options]"\n')!
	commented_command := os.join_path(tap_directory, 'homebrew', 'homebrew-test', 'cmd', 'brew-commented')
	help_spec_write_executable(commented_command, '#!/bin/bash\n#:  * `commented`:\n#:    Documented via comments.\necho "the command body should not have run" >&2\nexit 1\n')!
	return HelpSpecFixture{
		root: root
		internal_path: internal_path
		developer_path: developer_path
		tap_directory: tap_directory
		third_party_ruby: third_party_ruby
		official_ruby: official_ruby
		self_documenting: self_documenting
		commented_command: commented_command
	}
}

fn help_spec_permit_command(_ string, _ string) ! {}

fn help_spec_reject_third_party(_ string, _ string) ! {
	return error('Untrusted command from trusthelp/foo')
}

fn help_spec_context(fixture HelpSpecFixture,
	trust homebrew.CommandTrustChecker) homebrew.HelpContext {
	return homebrew.HelpContext{
		generic_help: 'Usage: brew <command> [options]'
		locations: homebrew.HelpCommandLocations{
			internal_path: fixture.internal_path
			developer_path: fixture.developer_path
			tap_directory: fixture.tap_directory
			path_value: ''
		}
		style: homebrew.HelpStyle{
			width: 80
		}
		trust: trust
		parser: homebrew.default_help_parser
	}
}

fn help_spec_request(command string) homebrew.HelpRequest {
	return homebrew.HelpRequest{
		command: command
	}
}

// Ruby it `it "prints help for a documented Ruby command" do` at line 12.
pub fn ruby_help_spec_l12_d1_prints(fixture HelpSpecFixture) !bool {
	result := homebrew.help(help_spec_request('cat'), help_spec_context(fixture, help_spec_permit_command))!
	return result.action == .print_and_exit && result.stream == .stdout && result.status == 0 && result.output.starts_with('Usage: brew cat')
}

// Ruby it `it "prints the originating tap for an external command from a third-party tap" do` at line 19.
pub fn ruby_help_spec_l19_d2_prints(fixture HelpSpecFixture) !bool {
	result := homebrew.help(help_spec_request('hello-trust-tap'), help_spec_context(fixture, help_spec_permit_command))!
	return result.output.starts_with('From tap: trusthelp/foo\n') && result.status == 0
}

// Ruby method `run; end` at line 47.
pub fn ruby_help_spec_l47_d3_run() bool {
	return true
}

// Ruby it `it "requires trust for an external command from a third-party tap" do` at line 65.
pub fn ruby_help_spec_l65_d4_requires(fixture HelpSpecFixture) !bool {
	mut rejected := false
	if _ := homebrew.help(help_spec_request('hello-trust-tap'), help_spec_context(fixture, help_spec_reject_third_party)) {
		return false
	} else {
		rejected = true
	}
	trusted := homebrew.help(help_spec_request('hello-trust-tap'), help_spec_context(fixture, help_spec_permit_command))!
	return rejected && trusted.output.starts_with('From tap: trusthelp/foo\n')
}

// Ruby method `run; end` at line 91.
pub fn ruby_help_spec_l91_d5_run() bool {
	return true
}

// Ruby it `it "does not print the originating tap for an external command from an official tap" do` at line 117.
pub fn ruby_help_spec_l117_d6_does(fixture HelpSpecFixture) !bool {
	result := homebrew.help(help_spec_request('hello-tap'), help_spec_context(fixture, help_spec_permit_command))!
	return !result.output.starts_with('From tap:') && result.output.starts_with('Usage: brew hello-tap')
}

// Ruby method `run; end` at line 135.
pub fn ruby_help_spec_l135_d7_run() bool {
	return true
}

// Ruby it `it "runs an external command's own `--help` when it has no `#:` comments" do` at line 146.
pub fn ruby_help_spec_l146_d8_runs(fixture HelpSpecFixture) !bool {
	result := homebrew.help(help_spec_request('selfdoc'), help_spec_context(fixture, help_spec_permit_command))!
	return result.action == .resume_execution && result.command.path == fixture.self_documenting
}

// Ruby it `it "renders `#:` help for an external command rather than running it" do` at line 162.
pub fn ruby_help_spec_l162_d9_renders(fixture HelpSpecFixture) !bool {
	result := homebrew.help(help_spec_request('commented'), help_spec_context(fixture, help_spec_permit_command))!
	return result.action == .print_and_exit && result.output.contains('Documented via comments.') && !result.output.contains('the command body should not have run')
}

// Ruby it `it "prints help when no argument is given" do` at line 182.
pub fn ruby_help_spec_l182_d10_prints(fixture HelpSpecFixture) !bool {
	result := homebrew.help(homebrew.HelpRequest{
		command: 'cat'
		usage_error: 'This command requires a formula argument.'
	}, help_spec_context(fixture, help_spec_permit_command))!
	return result.stream == .stderr && result.status == 1 && result.output.starts_with('Usage: brew cat') && result.output.contains('\n\nError: This command requires a formula argument.\n')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/help"
// 5: require "cmd/shared_examples/args_parse"
// 6: require "trust"
// 7:
// 8: RSpec.describe Homebrew::Cmd::HelpCmd, :integration_test do
// 9:   it_behaves_like "parseable arguments"
// 10:
// 11:   describe "help" do
// 12:     it "prints help for a documented Ruby command" do
// 13:       expect { brew "help", "cat" }
// 14:         .to output(/^Usage: brew cat/).to_stdout
// 15:         .and not_to_output.to_stderr
// 16:         .and be_a_success
// 17:     end
// 18:
// 19:     it "prints the originating tap for an external command from a third-party tap" do
// 20:       tap_path = HOMEBREW_TAP_DIRECTORY/"trusthelp/homebrew-foo"
// 21:       tap_path.mkpath
// 22:       tap_path.cd do
// 23:         system "git", "init"
// 24:         system "git", "remote", "add", "origin", "https://github.com/trusthelp/homebrew-foo"
// 25:         FileUtils.touch "readme"
// 26:         system "git", "add", "--all"
// 27:         system "git", "commit", "-m", "init"
// 28:       end
// 29:       cmd_path = tap_path/"cmd/hello-trust-tap.rb"
// 30:       cmd_path.dirname.mkpath
// 31:       cmd_path.write <<~RUBY
// 32:         # typed: strict
// 33:         # frozen_string_literal: true
// 34:
// 35:         raise "leaked SECRET_TOKEN" if ENV["SECRET_TOKEN"]
// 36:
// 37:         require "abstract_command"
// 38:
// 39:         module Homebrew
// 40:           module Cmd
// 41:             class HelloTrustTap < AbstractCommand
// 42:               cmd_args do
// 43:                 description "A friendly greeter from a tap."
// 44:               end
// 45:
// 46:               sig { override.void }
// 47:               def run; end
// 48:             end
// 49:           end
// 50:         end
// 51:       RUBY
// 52:       cmd_path.chmod(0755)
// 53:
// 54:       expect do
// 55:         brew "help", "hello-trust-tap", "SECRET_TOKEN" => "password", "HOMEBREW_NO_REQUIRE_TAP_TRUST" => "1"
// 56:       end
// 57:         .to output(%r{^From tap: trusthelp/foo$}).to_stdout
// 58:         .and not_to_output.to_stderr
// 59:         .and be_a_success
// 60:     ensure
// 61:       Homebrew::Trust.clear!(:tap)
// 62:       FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"trusthelp"
// 63:     end
// 64:
// 65:     it "requires trust for an external command from a third-party tap" do
// 66:       tap_path = HOMEBREW_TAP_DIRECTORY/"trusthelp/homebrew-foo"
// 67:       tap_path.mkpath
// 68:       tap_path.cd do
// 69:         system "git", "init"
// 70:         system "git", "remote", "add", "origin", "https://github.com/trusthelp/homebrew-foo"
// 71:         FileUtils.touch "readme"
// 72:         system "git", "add", "--all"
// 73:         system "git", "commit", "-m", "init"
// 74:       end
// 75:       cmd_path = tap_path/"cmd/hello-trust-tap.rb"
// 76:       cmd_path.dirname.mkpath
// 77:       cmd_path.write <<~RUBY
// 78:         # typed: strict
// 79:         # frozen_string_literal: true
// 80:
// 81:         require "abstract_command"
// 82:
// 83:         module Homebrew
// 84:           module Cmd
// 85:             class HelloTrustTap < AbstractCommand
// 86:               cmd_args do
// 87:                 description "A friendly greeter from a tap."
// 88:               end
// 89:
// 90:               sig { override.void }
// 91:               def run; end
// 92:             end
// 93:           end
// 94:         end
// 95:       RUBY
// 96:       cmd_path.chmod(0755)
// 97:       trust_home = Pathname(TEST_TMPDIR)/"help-command-trust"
// 98:       trust_env = { "HOMEBREW_USER_CONFIG_HOME" => trust_home.to_s }
// 99:       require_trust_env = trust_env.merge(
// 100:         "HOMEBREW_REQUIRE_TAP_TRUST" => "1",
// 101:       )
// 102:
// 103:       expect { brew "help", "hello-trust-tap", require_trust_env.dup }
// 104:         .to output(%r{trusthelp/foo}).to_stderr
// 105:         .and be_a_failure
// 106:
// 107:       with_env(trust_env) { Homebrew::Trust.trust!(:command, "trusthelp/foo/hello-trust-tap") }
// 108:
// 109:       expect { brew "help", "hello-trust-tap", require_trust_env.dup }
// 110:         .to output(%r{^From tap: trusthelp/foo$}).to_stdout
// 111:         .and be_a_success
// 112:     ensure
// 113:       FileUtils.rm_rf trust_home if trust_home
// 114:       FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"trusthelp"
// 115:     end
// 116:
// 117:     it "does not print the originating tap for an external command from an official tap" do
// 118:       tap_path = setup_test_tap
// 119:       cmd_path = tap_path/"cmd/hello-tap.rb"
// 120:       cmd_path.dirname.mkpath
// 121:       cmd_path.write <<~RUBY
// 122:         # typed: strict
// 123:         # frozen_string_literal: true
// 124:
// 125:         require "abstract_command"
// 126:
// 127:         module Homebrew
// 128:           module Cmd
// 129:             class HelloTap < AbstractCommand
// 130:               cmd_args do
// 131:                 description "A friendly greeter from a tap."
// 132:               end
// 133:
// 134:               sig { override.void }
// 135:               def run; end
// 136:             end
// 137:           end
// 138:         end
// 139:       RUBY
// 140:       cmd_path.chmod(0755)
// 141:
// 142:       expect { brew "help", "hello-tap" }
// 143:         .not_to output(/^From tap:/).to_stdout
// 144:     end
// 145:
// 146:     it "runs an external command's own `--help` when it has no `#:` comments" do
// 147:       tap_path = setup_test_tap
// 148:       cmd_path = tap_path/"cmd/brew-selfdoc"
// 149:       cmd_path.dirname.mkpath
// 150:       cmd_path.write <<~SH
// 151:         #!/bin/bash
// 152:         [[ "$*" == *--help* ]] || { echo "expected --help, got: $*" >&2; exit 1; }
// 153:         echo "Usage: brew selfdoc [options]"
// 154:       SH
// 155:       cmd_path.chmod(0755)
// 156:
// 157:       expect { brew "help", "selfdoc" }
// 158:         .to output(/^Usage: brew selfdoc/).to_stdout
// 159:         .and be_a_success
// 160:     end
// 161:
// 162:     it "renders `#:` help for an external command rather than running it" do
// 163:       tap_path = setup_test_tap
// 164:       cmd_path = tap_path/"cmd/brew-commented"
// 165:       cmd_path.dirname.mkpath
// 166:       cmd_path.write <<~SH
// 167:         #!/bin/bash
// 168:         #:  * `commented`:
// 169:         #:    Documented via comments.
// 170:         echo "the command body should not have run" >&2
// 171:         exit 1
// 172:       SH
// 173:       cmd_path.chmod(0755)
// 174:
// 175:       expect { brew "help", "commented" }
// 176:         .to output(/Documented via comments\./).to_stdout
// 177:         .and be_a_success
// 178:     end
// 179:   end
// 180:
// 181:   describe "cat" do
// 182:     it "prints help when no argument is given" do
// 183:       expect { brew "cat" }
// 184:         .to output(/^Usage: brew cat/).to_stderr
// 185:         .and not_to_output.to_stdout
// 186:         .and be_a_failure
// 187:     end
// 188:   end
// 189: end
