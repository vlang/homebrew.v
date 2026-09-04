module utils

import ruby
import homebrew.utils as production_utils

// Translated from Homebrew/brew `test/utils/repology_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `stub_curl(success:, stdout: "", stderr: "", exit_status: 0)` at line 17.
pub fn ruby_repology_spec_l17_d1_stub_curl(args ...ruby.Value) ruby.Value {
	success := args.len > 0 && (args[0].as_bool() or { false })
	stdout := if args.len > 1 { args[1].as_string() } else { '' }
	stderr := if args.len > 2 { args[2].as_string() } else { '' }
	exit_status := if args.len > 3 { args[3].as_int() or { 0 } } else { 0 }
	return ruby.map_value({
		'success':     ruby.bool_value(success)
		'stdout':      ruby.string_value(stdout)
		'stderr':      ruby.string_value(stderr)
		'exit_status': ruby.int_value(exit_status)
	})
}

// Ruby it `it "URL-encodes the project name and passes --fail" do` at line 21.
pub fn ruby_repology_spec_l21_d2_url_encodes(args ...ruby.Value) ruby.Value {
	_ = args
	result := production_utils.repology_single_package_query('gtk+3', production_utils.repology_homebrew_core, true, production_utils.RepologyCurlResult{ success: true, stdout: '[]' }, false)
	return ruby.bool_value('--fail' in result.arguments
		&& '${production_utils.repology_api_base}/project/gtk%2B3' in result.arguments
		&& result.data.map_data['gtk+3'].type_name == 'Array')
}

// Ruby it `it "returns nil (rather than raising) on HTTP failure" do` at line 30.
pub fn ruby_repology_spec_l30_d3_returns(args ...ruby.Value) ruby.Value {
	_ = args
	result := production_utils.repology_single_package_query('curl', production_utils.repology_homebrew_core, true, production_utils.RepologyCurlResult{
		stderr: 'The requested URL returned error: 503'
		exit_status: 22
	}, false)
	return ruby.bool_value(result.error_output.len > 0 && result.data.type_name == '')
}

// Ruby it `it "returns nil on invalid JSON" do` at line 38.
pub fn ruby_repology_spec_l38_d4_returns(args ...ruby.Value) ruby.Value {
	_ = args
	result := production_utils.repology_single_package_query('curl', production_utils.repology_homebrew_core, true, production_utils.RepologyCurlResult{
		success: true
		stdout: 'not json'
	}, false)
	return ruby.bool_value(result.error_output.len > 0 && result.data.type_name == '')
}

// Ruby it `it "URL-encodes the pagination cursor" do` at line 46.
pub fn ruby_repology_spec_l46_d5_url_encodes(args ...ruby.Value) ruby.Value {
	_ = args
	result := production_utils.repology_query_api('gtk+3', production_utils.repology_homebrew_core, true, production_utils.RepologyCurlResult{
		success: true
		stdout: '{}'
	}, false) or { return ruby.bool_value(false) }
	return ruby.bool_value(result.url == '${production_utils.repology_api_base}/projects/gtk%2B3/?inrepo=${production_utils.repology_homebrew_core}&outdated=1')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/repology"
// 5:
// 6: RSpec.describe Repology do
// 7:   before do
// 8:     allow(Utils::Curl).to receive(:curl_supports_tls13?).and_return(true)
// 9:     allow(Homebrew::EnvConfig).to receive(:developer?).and_return(false)
// 10:   end
// 11:
// 12:   describe ".single_package_query" do
// 13:     sig {
// 14:       params(success: T::Boolean, stdout: String, stderr: String, exit_status: Integer)
// 15:         .returns(T.untyped)
// 16:     }
// 17:     def stub_curl(success:, stdout: "", stderr: "", exit_status: 0)
// 18:       instance_double(SystemCommand::Result, success?: success, stdout:, stderr:, exit_status:)
// 19:     end
// 20:
// 21:     it "URL-encodes the project name and passes --fail" do
// 22:       expect(Utils::Curl).to receive(:curl_output) do |*args, **|
// 23:         expect(args).to include("--fail", "#{Repology::API_BASE}/project/gtk%2B3")
// 24:         stub_curl(success: true, stdout: "[]")
// 25:       end
// 26:       expect(described_class.single_package_query("gtk+3", repository: Repology::HOMEBREW_CORE))
// 27:         .to eq({ "gtk+3" => [] })
// 28:     end
// 29:
// 30:     it "returns nil (rather than raising) on HTTP failure" do
// 31:       allow(Utils::Curl).to receive(:curl_output).and_return(
// 32:         stub_curl(success: false, exit_status: 22, stderr: "The requested URL returned error: 503"),
// 33:       )
// 34:       expect(described_class.single_package_query("curl", repository: Repology::HOMEBREW_CORE))
// 35:         .to be_nil
// 36:     end
// 37:
// 38:     it "returns nil on invalid JSON" do
// 39:       allow(Utils::Curl).to receive(:curl_output).and_return(stub_curl(success: true, stdout: "not json"))
// 40:       expect(described_class.single_package_query("curl", repository: Repology::HOMEBREW_CORE))
// 41:         .to be_nil
// 42:     end
// 43:   end
// 44:
// 45:   describe ".query_api" do
// 46:     it "URL-encodes the pagination cursor" do
// 47:       expect(Utils::Curl).to receive(:curl_output) do |*args, **|
// 48:         expect(args.last).to eq "#{Repology::API_BASE}/projects/gtk%2B3/" \
// 49:                                 "?inrepo=#{Repology::HOMEBREW_CORE}&outdated=1"
// 50:         instance_double(SystemCommand::Result, stdout: "{}")
// 51:       end
// 52:       described_class.query_api("gtk+3", repository: Repology::HOMEBREW_CORE)
// 53:     end
// 54:   end
// 55: end
