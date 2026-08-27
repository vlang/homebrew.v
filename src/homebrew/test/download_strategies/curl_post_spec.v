module download_strategies

import brew_runtime

// Translated from Homebrew/brew `test/download_strategies/curl_post_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:strategy) { described_class.new(url, name, version, **specs) }` at line 7.
pub fn ruby_curl_post_spec_l7_d1_strategy(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('strategy', ...args)
}

// Ruby let `let(:name) { "foo" }` at line 9.
pub fn ruby_curl_post_spec_l9_d2_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby let `let(:url) { "https://example.com/foo.tar.gz" }` at line 10.
pub fn ruby_curl_post_spec_l10_d3_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('url', ...args)
}

// Ruby let `let(:version) { "1.2.3" }` at line 11.
pub fn ruby_curl_post_spec_l11_d4_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('version', ...args)
}

// Ruby let `let(:specs) { {} }` at line 12.
pub fn ruby_curl_post_spec_l12_d5_specs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('specs', ...args)
}

// Ruby let `let(:head_response) do` at line 13.
pub fn ruby_curl_post_spec_l13_d6_head_response(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('head_response', ...args)
}

// Ruby let `let(:specs) do` at line 42.
pub fn ruby_curl_post_spec_l42_d7_specs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('specs', ...args)
}

// Ruby it `it "adds the appropriate curl args" do` at line 52.
pub fn ruby_curl_post_spec_l52_d8_adds(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('adds', ...args)
}

// Ruby let `let(:specs) { { using: :post } }` at line 66.
pub fn ruby_curl_post_spec_l66_d9_specs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('specs', ...args)
}

// Ruby it `it "adds the appropriate curl args" do` at line 68.
pub fn ruby_curl_post_spec_l68_d10_adds(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('adds', ...args)
}

// Ruby let `let(:url) { "https://example.com/foo.tar.gz?form=data" }` at line 82.
pub fn ruby_curl_post_spec_l82_d11_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('url', ...args)
}

// Ruby let `let(:resolved_url) { "http://example.com/foo.tar.gz" }` at line 83.
pub fn ruby_curl_post_spec_l83_d12_resolved_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('resolved_url', ...args)
}

// Ruby let `let(:specs) { { using: :post } }` at line 84.
pub fn ruby_curl_post_spec_l84_d13_specs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('specs', ...args)
}

// Ruby it `it "raises before downloading" do` at line 92.
pub fn ruby_curl_post_spec_l92_d14_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "download_strategy"
// 5:
// 6: RSpec.describe CurlPostDownloadStrategy do
// 7:   subject(:strategy) { described_class.new(url, name, version, **specs) }
// 8:
// 9:   let(:name) { "foo" }
// 10:   let(:url) { "https://example.com/foo.tar.gz" }
// 11:   let(:version) { "1.2.3" }
// 12:   let(:specs) { {} }
// 13:   let(:head_response) do
// 14:     <<~HTTP
// 15:       HTTP/1.1 200\r
// 16:       Content-Disposition: attachment; filename="foo.tar.gz"
// 17:     HTTP
// 18:   end
// 19:
// 20:   describe "#fetch" do
// 21:     before do
// 22:       allow(strategy).to receive(:curl_version).and_return(Version.new("8.6.0"))
// 23:
// 24:       allow(strategy).to receive(:system_command)
// 25:         .with(
// 26:           /curl/,
// 27:           hash_including(args: array_including("--head")),
// 28:         )
// 29:         .twice
// 30:         .and_return(instance_double(
// 31:                       SystemCommand::Result,
// 32:                       success?:    true,
// 33:                       exit_status: instance_double(Process::Status, exitstatus: 0),
// 34:                       stdout:      head_response,
// 35:                     ))
// 36:
// 37:       strategy.temporary_path.dirname.mkpath
// 38:       FileUtils.touch strategy.temporary_path
// 39:     end
// 40:
// 41:     context "with :using and :data specified" do
// 42:       let(:specs) do
// 43:         {
// 44:           using: :post,
// 45:           data:  {
// 46:             form: "data",
// 47:             is:   "good",
// 48:           },
// 49:         }
// 50:       end
// 51:
// 52:       it "adds the appropriate curl args" do
// 53:         expect(strategy).to receive(:system_command)
// 54:           .with(
// 55:             /curl/,
// 56:             hash_including(args: array_including_cons("-d", "form=data").and(array_including_cons("-d", "is=good"))),
// 57:           )
// 58:           .at_least(:once)
// 59:           .and_return(instance_double(SystemCommand::Result, success?: true, stdout: "", assert_success!: nil))
// 60:
// 61:         strategy.fetch
// 62:       end
// 63:     end
// 64:
// 65:     context "with :using but no :data" do
// 66:       let(:specs) { { using: :post } }
// 67:
// 68:       it "adds the appropriate curl args" do
// 69:         expect(strategy).to receive(:system_command)
// 70:           .with(
// 71:             /curl/,
// 72:             hash_including(args: array_including_cons("-X", "POST")),
// 73:           )
// 74:           .at_least(:once)
// 75:           .and_return(instance_double(SystemCommand::Result, success?: true, stdout: "", assert_success!: nil))
// 76:
// 77:         strategy.fetch
// 78:       end
// 79:     end
// 80:
// 81:     context "when a secure URL redirects to an insecure URL" do
// 82:       let(:url) { "https://example.com/foo.tar.gz?form=data" }
// 83:       let(:resolved_url) { "http://example.com/foo.tar.gz" }
// 84:       let(:specs) { { using: :post } }
// 85:
// 86:       before do
// 87:         allow(Homebrew::EnvConfig).to receive(:no_insecure_redirect?).and_return(true)
// 88:         allow(strategy).to receive(:resolve_url_basename_time_file_size)
// 89:           .and_return([resolved_url, "foo.tar.gz", nil, nil, nil, true])
// 90:       end
// 91:
// 92:       it "raises before downloading" do
// 93:         expect(strategy).not_to receive(:curl_download)
// 94:
// 95:         expect { strategy.fetch }
// 96:           .to raise_error(CurlDownloadStrategyError, /HTTPS to HTTP redirect detected/)
// 97:       end
// 98:     end
// 99:   end
// 100: end
