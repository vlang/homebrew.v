module test

import ruby
import crypto.sha256
import homebrew
import x.json2

// Translated from Homebrew/brew `test/attestation_spec.rb`.
// The original source is retained below until every stub has a typed V body.
const attestation_spec_fake_gh = '/extremely/fake/gh'
const attestation_spec_creds = 'fake-gh-api-token'
const attestation_spec_cached_download = '/fake/cached/download'
const attestation_spec_filename = 'fakebottle--1.0.faketag.bottle.tar.gz'
const attestation_spec_url = 'https://example.com/fakebottle--1.0.faketag.bottle.tar.gz'

fn attestation_spec_bottle(all_tag bool) homebrew.AttestationBottle {
	return homebrew.AttestationBottle{
		name: 'fakebottle'
		cached_download: attestation_spec_cached_download
		filename: attestation_spec_filename
		filename_name: 'fakebottle'
		filename_version: '1.0'
		tag: if all_tag { 'all' } else { 'faketag' }
		url: attestation_spec_url
		resource_name: 'fakebottle'
		default_bottle_domain: 'https://ghcr.io/v2/homebrew/core'
	}
}

fn attestation_spec_json(subjects []string, timestamp string) string {
	mut encoded_subjects := []string{}
	for subject in subjects {
		encoded_subjects << '{"name":${json2.encode(subject)}}'
	}
	return '[{"verificationResult":{"verifiedTimestamps":[{"timestamp":${json2.encode(timestamp)}}],"statement":{"subject":[${encoded_subjects.join(',')}]}}}]'
}

fn attestation_spec_success(stdout string) homebrew.AttestationCommandResult {
	return homebrew.AttestationCommandResult{
		stdout: stdout
	}
}

fn attestation_spec_failure(exit_status int, stderr string) homebrew.AttestationCommandResult {
	return homebrew.AttestationCommandResult{
		exit_status: exit_status
		stderr: stderr
		failed: true
		failure_message: 'Failure while executing `foo` exited with ${exit_status}'
	}
}

fn attestation_spec_normal_result() homebrew.AttestationCommandResult {
	return attestation_spec_success(attestation_spec_json([attestation_spec_filename], '2024-03-13T00:00:00Z'))
}

fn attestation_spec_multi_result() homebrew.AttestationCommandResult {
	return attestation_spec_success(attestation_spec_json(['nonsense', attestation_spec_filename], '2024-03-13T00:00:00Z'))
}

fn attestation_spec_backfill_subject() string {
	return '${sha256.sum256(attestation_spec_url.bytes()).hex()}--${attestation_spec_filename}'
}

fn attestation_spec_backfill_result() homebrew.AttestationCommandResult {
	return attestation_spec_success(attestation_spec_json([
		attestation_spec_backfill_subject(),
	], '2024-03-13T00:00:00Z'))
}

fn attestation_spec_too_new_result() homebrew.AttestationCommandResult {
	return attestation_spec_success(attestation_spec_json([attestation_spec_filename], '2024-03-15T00:00:00Z'))
}

fn attestation_spec_wrong_subject_result() homebrew.AttestationCommandResult {
	return attestation_spec_success(attestation_spec_json(['wrong-subject.tar.gz'], '2024-03-13T00:00:00Z'))
}

fn attestation_spec_runtime(responses []homebrew.AttestationCommandResult) homebrew.AttestationRuntime {
	return homebrew.AttestationRuntime{
		gh_executable_cache: attestation_spec_fake_gh
		responses: responses.clone()
	}
}

fn attestation_spec_check_error(response homebrew.AttestationCommandResult, expected string) bool {
	mut runtime := attestation_spec_runtime([response])
	if _ := homebrew.check_bottle_attestation(mut runtime, attestation_spec_bottle(false), homebrew.attestation_homebrew_core_repo, none, none, attestation_spec_creds, homebrew.attestation_injected_collaborators()) {
		return false
	} else {
		return err.msg().starts_with(expected)
	}
}

fn attestation_spec_command_is_core(command homebrew.AttestationCommand) bool {
	return command.executable == attestation_spec_fake_gh && command.args == [
		'attestation',
		'verify',
		attestation_spec_cached_download,
		'--repo',
		homebrew.attestation_homebrew_core_repo,
		'--format',
		'json',
	] && command.environment == {
		'GH_TOKEN': attestation_spec_creds
		'GH_HOST':  'github.com'
	} && command.secrets == [attestation_spec_creds] && !command.print_stderr
}

// Ruby let `let(:fake_gh) { Pathname.new("/extremely/fake/gh") }` at line 7.
pub fn ruby_attestation_spec_l7_d1_fake_gh(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Pathname', attestation_spec_fake_gh)
}

// Ruby let `let(:fake_gh_creds) { "fake-gh-api-token" }` at line 8.
pub fn ruby_attestation_spec_l8_d2_fake_gh_creds(args ...ruby.Value) ruby.Value {
	return ruby.string_value(attestation_spec_creds)
}

// Ruby let `let(:fake_error_status) { instance_double(Process::Status, exitstatus: 1, termsig: nil) }` at line 9.
pub fn ruby_attestation_spec_l9_d3_fake_error_status(args ...ruby.Value) ruby.Value {
	return ruby.structured_value('Process::Status', 'exit 1', {
		'exitstatus': '1'
		'termsig':    ''
	})
}

// Ruby let `let(:fake_auth_status) { instance_double(Process::Status, exitstatus: 4, termsig: nil) }` at line 10.
pub fn ruby_attestation_spec_l10_d4_fake_auth_status(args ...ruby.Value) ruby.Value {
	return ruby.structured_value('Process::Status', 'exit 4', {
		'exitstatus': '4'
		'termsig':    ''
	})
}

// Ruby let `let(:cached_download) { "/fake/cached/download" }` at line 11.
pub fn ruby_attestation_spec_l11_d5_cached_download(args ...ruby.Value) ruby.Value {
	return ruby.string_value(attestation_spec_cached_download)
}

// Ruby let `let(:fake_bottle_filename) do` at line 12.
pub fn ruby_attestation_spec_l12_d6_fake_bottle_filename(args ...ruby.Value) ruby.Value {
	return ruby.structured_value('Bottle::Filename', attestation_spec_filename, {
		'name':    'fakebottle'
		'version': '1.0'
	})
}

// Ruby let `let(:fake_bottle_url) { "https://example.com/#{fake_bottle_filename}" }` at line 16.
pub fn ruby_attestation_spec_l16_d7_fake_bottle_url(args ...ruby.Value) ruby.Value {
	return ruby.string_value(attestation_spec_url)
}

// Ruby let `let(:fake_bottle_tag) { instance_double(Utils::Bottles::Tag, to_sym: :faketag) }` at line 17.
pub fn ruby_attestation_spec_l17_d8_fake_bottle_tag(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Utils::Bottles::Tag', 'faketag')
}

// Ruby let `let(:fake_all_bottle_tag) { instance_double(Utils::Bottles::Tag, to_sym: :all) }` at line 18.
pub fn ruby_attestation_spec_l18_d9_fake_all_bottle_tag(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Utils::Bottles::Tag', 'all')
}

// Ruby let `let(:fake_bottle) do` at line 19.
pub fn ruby_attestation_spec_l19_d10_fake_bottle(args ...ruby.Value) ruby.Value {
	return homebrew.attestation_bottle_value(attestation_spec_bottle(false))
}

// Ruby let `let(:fake_all_bottle) do` at line 23.
pub fn ruby_attestation_spec_l23_d11_fake_all_bottle(args ...ruby.Value) ruby.Value {
	return homebrew.attestation_bottle_value(attestation_spec_bottle(true))
}

// Ruby let `let(:fake_result_invalid_json) { instance_double(SystemCommand::Result, stdout: "\"invalid JSON") }` at line 27.
pub fn ruby_attestation_spec_l27_d12_fake_result_invalid_json(args ...ruby.Value) ruby.Value {
	return homebrew.attestation_command_result_value(attestation_spec_success('"invalid JSON'))
}

// Ruby let `let(:fake_result_json_resp) do` at line 28.
pub fn ruby_attestation_spec_l28_d13_fake_result_json_resp(args ...ruby.Value) ruby.Value {
	return homebrew.attestation_command_result_value(attestation_spec_normal_result())
}

// Ruby let `let(:fake_result_json_resp_multi_subject) do` at line 37.
pub fn ruby_attestation_spec_l37_d14_fake_result_json_resp_multi_subject(args ...ruby.Value) ruby.Value {
	return homebrew.attestation_command_result_value(attestation_spec_multi_result())
}

// Ruby let `let(:fake_result_json_resp_backfill) do` at line 46.
pub fn ruby_attestation_spec_l46_d15_fake_result_json_resp_backfill(args ...ruby.Value) ruby.Value {
	return homebrew.attestation_command_result_value(attestation_spec_backfill_result())
}

// Ruby let `let(:fake_result_json_resp_too_new) do` at line 58.
pub fn ruby_attestation_spec_l58_d16_fake_result_json_resp_too_new(args ...ruby.Value) ruby.Value {
	return homebrew.attestation_command_result_value(attestation_spec_too_new_result())
}

// Ruby let `let(:fake_json_resp_wrong_sub) do` at line 67.
pub fn ruby_attestation_spec_l67_d17_fake_json_resp_wrong_sub(args ...ruby.Value) ruby.Value {
	return homebrew.attestation_command_result_value(attestation_spec_wrong_subject_result())
}

// Ruby it `it "calls ensure_executable" do` at line 78.
pub fn ruby_attestation_spec_l78_d18_calls(args ...ruby.Value) ruby.Value {
	mut runtime := homebrew.AttestationRuntime{}
	path := homebrew.attestation_gh_executable(mut runtime, homebrew.attestation_injected_collaborators()) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(path == attestation_spec_fake_gh && runtime.ensure_calls == 1)
}

// Ruby let `let(:gh) { Formula["gh"] }` at line 90.
pub fn ruby_attestation_spec_l90_d19_gh(args ...ruby.Value) ruby.Value {
	return ruby.structured_value('Formula', 'gh', {
		'full_name': 'gh'
	})
}

// Ruby let `let(:other) { Formula["other"] }` at line 91.
pub fn ruby_attestation_spec_l91_d20_other(args ...ruby.Value) ruby.Value {
	return ruby.structured_value('Formula', 'other', {
		'full_name': 'other'
	})
}

// Ruby it `it "moves `gh` formulae to the front of the list" do` at line 99.
pub fn ruby_attestation_spec_l99_d21_moves(args ...ruby.Value) ruby.Value {
	gh := homebrew.AttestationFormula{ full_name: 'gh' }
	other := homebrew.AttestationFormula{ full_name: 'other' }
	mut runtime := homebrew.AttestationRuntime{}
	callbacks := homebrew.attestation_injected_collaborators()
	one := homebrew.attestation_sort_formulae_for_install([gh], mut runtime, callbacks) or {
		return ruby.bool_value(false)
	}
	two := homebrew.attestation_sort_formulae_for_install([gh, other], mut runtime, callbacks) or {
		return ruby.bool_value(false)
	}
	moved := homebrew.attestation_sort_formulae_for_install([other, gh], mut runtime, callbacks) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(one == [gh] && two == [gh, other] && moved == [gh, other] && runtime.ensure_calls == 0)
}

// Ruby it `it "checks for the `gh` executable" do` at line 113.
pub fn ruby_attestation_spec_l113_d22_checks(args ...ruby.Value) ruby.Value {
	mut runtime := homebrew.AttestationRuntime{}
	result := homebrew.attestation_sort_formulae_for_install([], mut runtime, homebrew.attestation_injected_collaborators()) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(result.len == 0 && runtime.ensure_calls == 1)
}

// Ruby it `it "checks for the `gh` executable" do` at line 120.
pub fn ruby_attestation_spec_l120_d23_checks(args ...ruby.Value) ruby.Value {
	other := homebrew.AttestationFormula{ full_name: 'other' }
	mut runtime := homebrew.AttestationRuntime{}
	result := homebrew.attestation_sort_formulae_for_install([other], mut runtime, homebrew.attestation_injected_collaborators()) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(result == [other] && runtime.ensure_calls == 1)
}

// Ruby it `it "raises without any gh credentials" do` at line 133.
pub fn ruby_attestation_spec_l133_d24_raises(args ...ruby.Value) ruby.Value {
	mut runtime := attestation_spec_runtime([])
	if _ := homebrew.check_bottle_attestation(mut runtime, attestation_spec_bottle(false), homebrew.attestation_homebrew_core_repo, none, none, '', homebrew.attestation_injected_collaborators()) {
		return ruby.bool_value(false)
	} else {
		return ruby.bool_value(err.msg() == 'GhAuthNeeded: missing credentials' && runtime.commands.len == 0)
	}
}

// Ruby it `it "raises when gh subprocess fails" do` at line 143.
pub fn ruby_attestation_spec_l143_d25_raises(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(attestation_spec_check_error(attestation_spec_failure(1, ''), 'InvalidAttestationError:'))
}

// Ruby it `it "raises auth error when gh subprocess fails with auth exit code" do` at line 160.
pub fn ruby_attestation_spec_l160_d26_raises(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(attestation_spec_check_error(attestation_spec_failure(4, ''), 'GhAuthInvalid: invalid credentials'))
}

// Ruby it `it "raises when gh returns invalid JSON" do` at line 177.
pub fn ruby_attestation_spec_l177_d27_raises(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(attestation_spec_check_error(attestation_spec_success('"invalid JSON'), 'InvalidAttestationError: attestation verification returned malformed JSON'))
}

// Ruby it `it "raises when gh returns other subjects" do` at line 194.
pub fn ruby_attestation_spec_l194_d28_raises(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(attestation_spec_check_error(attestation_spec_wrong_subject_result(), 'InvalidAttestationError: no attestation matches subject: ${attestation_spec_filename}'))
}

// Ruby it `it "checks subject prefix when the bottle is an :all bottle" do` at line 211.
pub fn ruby_attestation_spec_l211_d29_checks(args ...ruby.Value) ruby.Value {
	mut runtime := attestation_spec_runtime([attestation_spec_normal_result()])
	record := homebrew.check_bottle_attestation(mut runtime, attestation_spec_bottle(true), homebrew.attestation_homebrew_core_repo, none, none, attestation_spec_creds, homebrew.attestation_injected_collaborators()) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(record.subjects == [attestation_spec_filename] && attestation_spec_command_is_core(runtime.commands[0]))
}

// Ruby it `it "calls gh with args for homebrew-core" do` at line 235.
pub fn ruby_attestation_spec_l235_d30_calls(args ...ruby.Value) ruby.Value {
	mut runtime := attestation_spec_runtime([attestation_spec_normal_result()])
	record := homebrew.check_core_bottle_attestation(mut runtime, attestation_spec_bottle(false), attestation_spec_creds, true, homebrew.attestation_injected_collaborators()) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(record.subjects == [attestation_spec_filename] && runtime.commands.len == 1 && attestation_spec_command_is_core(runtime.commands[0]))
}

// Ruby it `it "calls gh with args for homebrew-core and handles a multi-subject attestation" do` at line 246.
pub fn ruby_attestation_spec_l246_d31_calls(args ...ruby.Value) ruby.Value {
	mut runtime := attestation_spec_runtime([attestation_spec_multi_result()])
	record := homebrew.check_core_bottle_attestation(mut runtime, attestation_spec_bottle(false), attestation_spec_creds, true, homebrew.attestation_injected_collaborators()) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(record.subjects == ['nonsense', attestation_spec_filename] && runtime.commands.len == 1 && attestation_spec_command_is_core(runtime.commands[0]))
}

// Ruby it `it "calls gh with args for backfill when homebrew-core attestation is missing" do` at line 257.
pub fn ruby_attestation_spec_l257_d32_calls(args ...ruby.Value) ruby.Value {
	mut runtime := attestation_spec_runtime([
		attestation_spec_failure(1, 'HTTP 404: Not Found'),
		attestation_spec_backfill_result(),
	])
	record := homebrew.check_core_bottle_attestation(mut runtime, attestation_spec_bottle(false), attestation_spec_creds, true, homebrew.attestation_injected_collaborators()) or {
		return ruby.bool_value(false)
	}
	if runtime.commands.len != 2 {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(record.subjects == [
		attestation_spec_backfill_subject(),
	] && attestation_spec_command_is_core(runtime.commands[0]) && runtime.commands[1].args == [
		'attestation',
		'verify',
		attestation_spec_cached_download,
		'--repo',
		homebrew.attestation_backfill_repo,
		'--format',
		'json',
	])
}

// Ruby it `it "raises when the backfilled attestation is too new" do` at line 276.
pub fn ruby_attestation_spec_l276_d33_raises(args ...ruby.Value) ruby.Value {
	mut responses := []homebrew.AttestationCommandResult{}
	for _ in 0 .. homebrew.attestation_max_retries + 1 {
		responses << attestation_spec_failure(1, 'HTTP 404: Not Found')
		responses << attestation_spec_too_new_result()
	}
	mut runtime := attestation_spec_runtime(responses)
	if _ := homebrew.check_core_bottle_attestation(mut runtime, attestation_spec_bottle(false), attestation_spec_creds, true, homebrew.attestation_injected_collaborators()) {
		return ruby.bool_value(false)
	} else {
		core_count := runtime.commands.filter(it.args.contains(homebrew.attestation_homebrew_core_repo)).len
		backfill_count := runtime.commands.filter(it.args.contains(homebrew.attestation_backfill_repo)).len
		return ruby.bool_value(err.msg().starts_with('InvalidAttestationError:') && core_count == homebrew.attestation_max_retries + 1 && backfill_count == homebrew.attestation_max_retries + 1 && runtime.sleeps.len == 0)
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "diagnostic"
// 5:
// 6: RSpec.describe Homebrew::Attestation do
// 7:   let(:fake_gh) { Pathname.new("/extremely/fake/gh") }
// 8:   let(:fake_gh_creds) { "fake-gh-api-token" }
// 9:   let(:fake_error_status) { instance_double(Process::Status, exitstatus: 1, termsig: nil) }
// 10:   let(:fake_auth_status) { instance_double(Process::Status, exitstatus: 4, termsig: nil) }
// 11:   let(:cached_download) { "/fake/cached/download" }
// 12:   let(:fake_bottle_filename) do
// 13:     instance_double(Bottle::Filename, name: "fakebottle", version: "1.0",
// 14:    to_s: "fakebottle--1.0.faketag.bottle.tar.gz")
// 15:   end
// 16:   let(:fake_bottle_url) { "https://example.com/#{fake_bottle_filename}" }
// 17:   let(:fake_bottle_tag) { instance_double(Utils::Bottles::Tag, to_sym: :faketag) }
// 18:   let(:fake_all_bottle_tag) { instance_double(Utils::Bottles::Tag, to_sym: :all) }
// 19:   let(:fake_bottle) do
// 20:     instance_double(Bottle, cached_download:, filename: fake_bottle_filename, url: fake_bottle_url,
// 21:                     tag: fake_bottle_tag)
// 22:   end
// 23:   let(:fake_all_bottle) do
// 24:     instance_double(Bottle, cached_download:, filename: fake_bottle_filename, url: fake_bottle_url,
// 25:                     tag: fake_all_bottle_tag)
// 26:   end
// 27:   let(:fake_result_invalid_json) { instance_double(SystemCommand::Result, stdout: "\"invalid JSON") }
// 28:   let(:fake_result_json_resp) do
// 29:     instance_double(SystemCommand::Result,
// 30:                     stdout: JSON.dump([
// 31:                       { verificationResult: {
// 32:                         verifiedTimestamps: [{ timestamp: "2024-03-13T00:00:00Z" }],
// 33:                         statement:          { subject: [{ name: fake_bottle_filename.to_s }] },
// 34:                       } },
// 35:                     ]))
// 36:   end
// 37:   let(:fake_result_json_resp_multi_subject) do
// 38:     instance_double(SystemCommand::Result,
// 39:                     stdout: JSON.dump([
// 40:                       { verificationResult: {
// 41:                         verifiedTimestamps: [{ timestamp: "2024-03-13T00:00:00Z" }],
// 42:                         statement:          { subject: [{ name: "nonsense" }, { name: fake_bottle_filename.to_s }] },
// 43:                       } },
// 44:                     ]))
// 45:   end
// 46:   let(:fake_result_json_resp_backfill) do
// 47:     digest = Digest::SHA256.hexdigest(fake_bottle_url)
// 48:     instance_double(SystemCommand::Result,
// 49:                     stdout: JSON.dump([
// 50:                       { verificationResult: {
// 51:                         verifiedTimestamps: [{ timestamp: "2024-03-13T00:00:00Z" }],
// 52:                         statement:          {
// 53:                           subject: [{ name: "#{digest}--#{fake_bottle_filename}" }],
// 54:                         },
// 55:                       } },
// 56:                     ]))
// 57:   end
// 58:   let(:fake_result_json_resp_too_new) do
// 59:     instance_double(SystemCommand::Result,
// 60:                     stdout: JSON.dump([
// 61:                       { verificationResult: {
// 62:                         verifiedTimestamps: [{ timestamp: "2024-03-15T00:00:00Z" }],
// 63:                         statement:          { subject: [{ name: fake_bottle_filename.to_s }] },
// 64:                       } },
// 65:                     ]))
// 66:   end
// 67:   let(:fake_json_resp_wrong_sub) do
// 68:     instance_double(SystemCommand::Result,
// 69:                     stdout: JSON.dump([
// 70:                       { verificationResult: {
// 71:                         verifiedTimestamps: [{ timestamp: "2024-03-13T00:00:00Z" }],
// 72:                         statement:          { subject: [{ name: "wrong-subject.tar.gz" }] },
// 73:                       } },
// 74:                     ]))
// 75:   end
// 76:
// 77:   describe "::gh_executable" do
// 78:     it "calls ensure_executable" do
// 79:       expect(described_class).to receive(:ensure_executable!)
// 80:         .with("gh", reason: "verifying attestations", latest: true)
// 81:         .and_return(fake_gh)
// 82:
// 83:       described_class.gh_executable
// 84:     end
// 85:   end
// 86:
// 87:   # NOTE: `Homebrew::CLI::NamedArgs` will often return frozen arrays of formulae
// 88:   #       so that's why we test with frozen arrays here.
// 89:   describe "::sort_formulae_for_install", :integration_test do
// 90:     let(:gh) { Formula["gh"] }
// 91:     let(:other) { Formula["other"] }
// 92:
// 93:     before do
// 94:       setup_test_formula("gh")
// 95:       setup_test_formula("other")
// 96:     end
// 97:
// 98:     context "when `gh` is in the formula list" do
// 99:       it "moves `gh` formulae to the front of the list" do
// 100:         expect(described_class).not_to receive(:gh_executable)
// 101:
// 102:         [
// 103:           [[gh], [gh]],
// 104:           [[gh, other], [gh, other]],
// 105:           [[other, gh], [gh, other]],
// 106:         ].each do |input, output|
// 107:           expect(described_class.sort_formulae_for_install(input.freeze)).to eq(output)
// 108:         end
// 109:       end
// 110:     end
// 111:
// 112:     context "when the formula list is empty" do
// 113:       it "checks for the `gh` executable" do
// 114:         expect(described_class).to receive(:gh_executable).once
// 115:         expect(described_class.sort_formulae_for_install([].freeze)).to eq([])
// 116:       end
// 117:     end
// 118:
// 119:     context "when `gh` is not in the formula list" do
// 120:       it "checks for the `gh` executable" do
// 121:         expect(described_class).to receive(:gh_executable).once
// 122:         expect(described_class.sort_formulae_for_install([other].freeze)).to eq([other])
// 123:       end
// 124:     end
// 125:   end
// 126:
// 127:   describe "::check_attestation" do
// 128:     before do
// 129:       allow(described_class).to receive(:gh_executable)
// 130:         .and_return(fake_gh)
// 131:     end
// 132:
// 133:     it "raises without any gh credentials" do
// 134:       expect(GitHub::API).to receive(:credentials)
// 135:         .and_return(nil)
// 136:
// 137:       expect do
// 138:         described_class.check_attestation fake_bottle,
// 139:                                           Homebrew::Attestation::HOMEBREW_CORE_REPO
// 140:       end.to raise_error(Homebrew::Attestation::GhAuthNeeded)
// 141:     end
// 142:
// 143:     it "raises when gh subprocess fails" do
// 144:       expect(GitHub::API).to receive(:credentials)
// 145:         .and_return(fake_gh_creds)
// 146:
// 147:       expect(described_class).to receive(:system_command!)
// 148:         .with(fake_gh, args: ["attestation", "verify", cached_download, "--repo",
// 149:                               Homebrew::Attestation::HOMEBREW_CORE_REPO, "--format", "json"],
// 150:               env: { "GH_TOKEN" => fake_gh_creds, "GH_HOST" => "github.com" }, secrets: [fake_gh_creds],
// 151:               print_stderr: false, chdir: HOMEBREW_TEMP)
// 152:         .and_raise(ErrorDuringExecution.new(["foo"], status: fake_error_status))
// 153:
// 154:       expect do
// 155:         described_class.check_attestation fake_bottle,
// 156:                                           Homebrew::Attestation::HOMEBREW_CORE_REPO
// 157:       end.to raise_error(Homebrew::Attestation::InvalidAttestationError)
// 158:     end
// 159:
// 160:     it "raises auth error when gh subprocess fails with auth exit code" do
// 161:       expect(GitHub::API).to receive(:credentials)
// 162:         .and_return(fake_gh_creds)
// 163:
// 164:       expect(described_class).to receive(:system_command!)
// 165:         .with(fake_gh, args: ["attestation", "verify", cached_download, "--repo",
// 166:                               Homebrew::Attestation::HOMEBREW_CORE_REPO, "--format", "json"],
// 167:               env: { "GH_TOKEN" => fake_gh_creds, "GH_HOST" => "github.com" }, secrets: [fake_gh_creds],
// 168:               print_stderr: false, chdir: HOMEBREW_TEMP)
// 169:         .and_raise(ErrorDuringExecution.new(["foo"], status: fake_auth_status))
// 170:
// 171:       expect do
// 172:         described_class.check_attestation fake_bottle,
// 173:                                           Homebrew::Attestation::HOMEBREW_CORE_REPO
// 174:       end.to raise_error(Homebrew::Attestation::GhAuthInvalid)
// 175:     end
// 176:
// 177:     it "raises when gh returns invalid JSON" do
// 178:       expect(GitHub::API).to receive(:credentials)
// 179:         .and_return(fake_gh_creds)
// 180:
// 181:       expect(described_class).to receive(:system_command!)
// 182:         .with(fake_gh, args: ["attestation", "verify", cached_download, "--repo",
// 183:                               Homebrew::Attestation::HOMEBREW_CORE_REPO, "--format", "json"],
// 184:               env: { "GH_TOKEN" => fake_gh_creds, "GH_HOST" => "github.com" }, secrets: [fake_gh_creds],
// 185:               print_stderr: false, chdir: HOMEBREW_TEMP)
// 186:         .and_return(fake_result_invalid_json)
// 187:
// 188:       expect do
// 189:         described_class.check_attestation fake_bottle,
// 190:                                           Homebrew::Attestation::HOMEBREW_CORE_REPO
// 191:       end.to raise_error(Homebrew::Attestation::InvalidAttestationError)
// 192:     end
// 193:
// 194:     it "raises when gh returns other subjects" do
// 195:       expect(GitHub::API).to receive(:credentials)
// 196:         .and_return(fake_gh_creds)
// 197:
// 198:       expect(described_class).to receive(:system_command!)
// 199:         .with(fake_gh, args: ["attestation", "verify", cached_download, "--repo",
// 200:                               Homebrew::Attestation::HOMEBREW_CORE_REPO, "--format", "json"],
// 201:               env: { "GH_TOKEN" => fake_gh_creds, "GH_HOST" => "github.com" }, secrets: [fake_gh_creds],
// 202:               print_stderr: false, chdir: HOMEBREW_TEMP)
// 203:         .and_return(fake_json_resp_wrong_sub)
// 204:
// 205:       expect do
// 206:         described_class.check_attestation fake_bottle,
// 207:                                           Homebrew::Attestation::HOMEBREW_CORE_REPO
// 208:       end.to raise_error(Homebrew::Attestation::InvalidAttestationError)
// 209:     end
// 210:
// 211:     it "checks subject prefix when the bottle is an :all bottle" do
// 212:       expect(GitHub::API).to receive(:credentials)
// 213:         .and_return(fake_gh_creds)
// 214:
// 215:       expect(described_class).to receive(:system_command!)
// 216:         .with(fake_gh, args: ["attestation", "verify", cached_download, "--repo",
// 217:                               Homebrew::Attestation::HOMEBREW_CORE_REPO, "--format", "json"],
// 218:               env: { "GH_TOKEN" => fake_gh_creds, "GH_HOST" => "github.com" }, secrets: [fake_gh_creds],
// 219:               print_stderr: false, chdir: HOMEBREW_TEMP)
// 220:         .and_return(fake_result_json_resp)
// 221:
// 222:       described_class.check_attestation fake_all_bottle, Homebrew::Attestation::HOMEBREW_CORE_REPO
// 223:     end
// 224:   end
// 225:
// 226:   describe "::check_core_attestation" do
// 227:     before do
// 228:       allow(described_class).to receive(:gh_executable)
// 229:         .and_return(fake_gh)
// 230:
// 231:       allow(GitHub::API).to receive(:credentials)
// 232:         .and_return(fake_gh_creds)
// 233:     end
// 234:
// 235:     it "calls gh with args for homebrew-core" do
// 236:       expect(described_class).to receive(:system_command!)
// 237:         .with(fake_gh, args: ["attestation", "verify", cached_download, "--repo",
// 238:                               Homebrew::Attestation::HOMEBREW_CORE_REPO, "--format", "json"],
// 239:               env: { "GH_TOKEN" => fake_gh_creds, "GH_HOST" => "github.com" }, secrets: [fake_gh_creds],
// 240:               print_stderr: false, chdir: HOMEBREW_TEMP)
// 241:         .and_return(fake_result_json_resp)
// 242:
// 243:       described_class.check_core_attestation fake_bottle
// 244:     end
// 245:
// 246:     it "calls gh with args for homebrew-core and handles a multi-subject attestation" do
// 247:       expect(described_class).to receive(:system_command!)
// 248:         .with(fake_gh, args: ["attestation", "verify", cached_download, "--repo",
// 249:                               Homebrew::Attestation::HOMEBREW_CORE_REPO, "--format", "json"],
// 250:               env: { "GH_TOKEN" => fake_gh_creds, "GH_HOST" => "github.com" }, secrets: [fake_gh_creds],
// 251:               print_stderr: false, chdir: HOMEBREW_TEMP)
// 252:         .and_return(fake_result_json_resp_multi_subject)
// 253:
// 254:       described_class.check_core_attestation fake_bottle
// 255:     end
// 256:
// 257:     it "calls gh with args for backfill when homebrew-core attestation is missing" do
// 258:       expect(described_class).to receive(:system_command!)
// 259:         .with(fake_gh, args: ["attestation", "verify", cached_download, "--repo",
// 260:                               Homebrew::Attestation::HOMEBREW_CORE_REPO, "--format", "json"],
// 261:               env: { "GH_TOKEN" => fake_gh_creds, "GH_HOST" => "github.com" }, secrets: [fake_gh_creds],
// 262:               print_stderr: false, chdir: HOMEBREW_TEMP)
// 263:         .once
// 264:         .and_raise(Homebrew::Attestation::MissingAttestationError)
// 265:
// 266:       expect(described_class).to receive(:system_command!)
// 267:         .with(fake_gh, args: ["attestation", "verify", cached_download, "--repo",
// 268:                               Homebrew::Attestation::BACKFILL_REPO, "--format", "json"],
// 269:               env: { "GH_TOKEN" => fake_gh_creds, "GH_HOST" => "github.com" }, secrets: [fake_gh_creds],
// 270:               print_stderr: false, chdir: HOMEBREW_TEMP)
// 271:         .and_return(fake_result_json_resp_backfill)
// 272:
// 273:       described_class.check_core_attestation fake_bottle
// 274:     end
// 275:
// 276:     it "raises when the backfilled attestation is too new" do
// 277:       expect(described_class).to receive(:system_command!)
// 278:         .with(fake_gh, args: ["attestation", "verify", cached_download, "--repo",
// 279:                               Homebrew::Attestation::HOMEBREW_CORE_REPO, "--format", "json"],
// 280:               env: { "GH_TOKEN" => fake_gh_creds, "GH_HOST" => "github.com" }, secrets: [fake_gh_creds],
// 281:               print_stderr: false, chdir: HOMEBREW_TEMP)
// 282:         .exactly(Homebrew::Attestation::ATTESTATION_MAX_RETRIES + 1)
// 283:         .and_raise(Homebrew::Attestation::MissingAttestationError)
// 284:
// 285:       expect(described_class).to receive(:system_command!)
// 286:         .with(fake_gh, args: ["attestation", "verify", cached_download, "--repo",
// 287:                               Homebrew::Attestation::BACKFILL_REPO, "--format", "json"],
// 288:               env: { "GH_TOKEN" => fake_gh_creds, "GH_HOST" => "github.com" }, secrets: [fake_gh_creds],
// 289:               print_stderr: false, chdir: HOMEBREW_TEMP)
// 290:         .exactly(Homebrew::Attestation::ATTESTATION_MAX_RETRIES + 1)
// 291:         .and_return(fake_result_json_resp_too_new)
// 292:
// 293:       expect do
// 294:         described_class.check_core_attestation fake_bottle
// 295:       end.to raise_error(Homebrew::Attestation::InvalidAttestationError)
// 296:     end
// 297:   end
// 298: end
