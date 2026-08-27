module vulns

import brew_runtime

// Translated from Homebrew/brew `test/vulns/osv_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `curl_result(stdout:, success: true)` at line 7.
pub fn ruby_osv_spec_l7_d1_curl_result(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('curl_result', ...args)
}

// Ruby method `stub_curl(*results)` at line 11.
pub fn ruby_osv_spec_l11_d2_stub_curl(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stub_curl', ...args)
}

// Ruby let `let(:packages) do` at line 16.
pub fn ruby_osv_spec_l16_d3_packages(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('packages', ...args)
}

// Ruby it `it "returns an array of vuln arrays aligned with the input" do` at line 24.
pub fn ruby_osv_spec_l24_d4_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "posts each package under its given ecosystem, omitting version when nil" do` at line 42.
pub fn ruby_osv_spec_l42_d5_posts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('posts', ...args)
}

// Ruby it `it "returns empty for empty input without hitting the network" do` at line 64.
pub fn ruby_osv_spec_l64_d6_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "splits requests larger than BATCH_SIZE and reassembles results in order" do` at line 69.
pub fn ruby_osv_spec_l69_d7_splits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('splits', ...args)
}

// Ruby it `it "raises ApiError when the results key is missing" do` at line 81.
pub fn ruby_osv_spec_l81_d8_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "raises ApiError when fewer results than queries are returned" do` at line 87.
pub fn ruby_osv_spec_l87_d9_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "raises ApiError when a continuation response is truncated" do` at line 94.
pub fn ruby_osv_spec_l94_d10_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "follows per-result next_page_token, resubmitting only paged queries" do` at line 108.
pub fn ruby_osv_spec_l108_d11_follows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('follows', ...args)
}

// Ruby it `it "raises after MAX_PAGES continuation requests" do` at line 135.
pub fn ruby_osv_spec_l135_d12_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "raises ApiError when curl reports failure" do` at line 144.
pub fn ruby_osv_spec_l144_d13_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "raises ApiError when the response is not valid JSON" do` at line 150.
pub fn ruby_osv_spec_l150_d14_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "fetches a single vulnerability record by id" do` at line 158.
pub fn ruby_osv_spec_l158_d15_fetches(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fetches', ...args)
}

// Ruby it `it "URL-encodes the id in the request path" do` at line 174.
pub fn ruby_osv_spec_l174_d16_url_encodes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('URL-encodes', ...args)
}

// Ruby it `it "raises ApiError when curl reports failure" do` at line 186.
pub fn ruby_osv_spec_l186_d17_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "vulns/osv"
// 5:
// 6: RSpec.describe Homebrew::Vulns::OSV, :needs_utils_curl do
// 7:   def curl_result(stdout:, success: true)
// 8:     instance_double(SystemCommand::Result, stdout:, success?: success, exit_status: success ? 0 : 22, stderr: "")
// 9:   end
// 10:
// 11:   def stub_curl(*results)
// 12:     allow(Utils::Curl).to receive(:curl_output).and_return(*results)
// 13:   end
// 14:
// 15:   describe ".query_batch" do
// 16:     let(:packages) do
// 17:       [
// 18:         { ecosystem: "GIT", name: "https://github.com/a/a", version: "v1" },
// 19:         { ecosystem: "GIT", name: "https://github.com/b/b", version: "v2" },
// 20:         { ecosystem: "GIT", name: "https://github.com/c/c", version: "v3" },
// 21:       ]
// 22:     end
// 23:
// 24:     it "returns an array of vuln arrays aligned with the input" do
// 25:       body = {
// 26:         results: [
// 27:           { vulns: [{ id: "CVE-2024-1111" }] },
// 28:           { vulns: [] },
// 29:           { vulns: [{ id: "CVE-2024-2222" }, { id: "CVE-2024-3333" }] },
// 30:         ],
// 31:       }
// 32:       stub_curl curl_result(stdout: body.to_json)
// 33:
// 34:       results = described_class.query_batch(packages)
// 35:
// 36:       expect(results.size).to eq 3
// 37:       expect(results[0].map { |v| v["id"] }).to eq ["CVE-2024-1111"]
// 38:       expect(results[1]).to eq []
// 39:       expect(results[2].map { |v| v["id"] }).to eq ["CVE-2024-2222", "CVE-2024-3333"]
// 40:     end
// 41:
// 42:     it "posts each package under its given ecosystem, omitting version when nil" do
// 43:       mixed = [
// 44:         { ecosystem: "GIT", name: "https://github.com/a/a", version: "v1" },
// 45:         { ecosystem: "PyPI", name: "requests", version: "2.31.0" },
// 46:         { ecosystem: "Debian", name: "curl", version: nil },
// 47:       ]
// 48:       posted = nil
// 49:       expect(Utils::Curl).to receive(:curl_output) do |*args|
// 50:         expect(args.last).to eq "https://api.osv.dev/v1/querybatch"
// 51:         posted = JSON.parse(args[args.index("--json") + 1])
// 52:         curl_result(stdout: { results: [{}, {}, {}] }.to_json)
// 53:       end
// 54:
// 55:       described_class.query_batch(mixed)
// 56:
// 57:       expect(posted["queries"]).to eq [
// 58:         { "package" => { "name" => "https://github.com/a/a", "ecosystem" => "GIT" }, "version" => "v1" },
// 59:         { "package" => { "name" => "requests", "ecosystem" => "PyPI" }, "version" => "2.31.0" },
// 60:         { "package" => { "name" => "curl", "ecosystem" => "Debian" } },
// 61:       ]
// 62:     end
// 63:
// 64:     it "returns empty for empty input without hitting the network" do
// 65:       expect(Utils::Curl).not_to receive(:curl_output)
// 66:       expect(described_class.query_batch([])).to eq []
// 67:     end
// 68:
// 69:     it "splits requests larger than BATCH_SIZE and reassembles results in order" do
// 70:       stub_const("#{described_class}::BATCH_SIZE", 2)
// 71:       expect(Utils::Curl).to receive(:curl_output).twice.and_return(
// 72:         curl_result(stdout: { results: [{ vulns: [{ id: "A" }] }, { vulns: [{ id: "B" }] }] }.to_json),
// 73:         curl_result(stdout: { results: [{ vulns: [{ id: "C" }] }] }.to_json),
// 74:       )
// 75:
// 76:       results = described_class.query_batch(packages)
// 77:
// 78:       expect(results.map { |r| r.first["id"] }).to eq %w[A B C]
// 79:     end
// 80:
// 81:     it "raises ApiError when the results key is missing" do
// 82:       stub_curl curl_result(stdout: "{}")
// 83:       expect { described_class.query_batch(packages) }
// 84:         .to raise_error(described_class::ApiError, /expected 3 results/)
// 85:     end
// 86:
// 87:     it "raises ApiError when fewer results than queries are returned" do
// 88:       body = { results: [{ vulns: [] }, { vulns: [] }] }
// 89:       stub_curl curl_result(stdout: body.to_json)
// 90:       expect { described_class.query_batch(packages) }
// 91:         .to raise_error(described_class::ApiError, /expected 3 results, got 2/)
// 92:     end
// 93:
// 94:     it "raises ApiError when a continuation response is truncated" do
// 95:       page1 = {
// 96:         results: [
// 97:           { vulns: [{ id: "A1" }], next_page_token: "tok-a" },
// 98:           { vulns: [{ id: "B1" }], next_page_token: "tok-b" },
// 99:           { vulns: [{ id: "C1" }] },
// 100:         ],
// 101:       }
// 102:       page2 = { results: [{ vulns: [{ id: "A2" }] }] }
// 103:       stub_curl(curl_result(stdout: page1.to_json), curl_result(stdout: page2.to_json))
// 104:       expect { described_class.query_batch(packages) }
// 105:         .to raise_error(described_class::ApiError, /expected 2 results, got 1/)
// 106:     end
// 107:
// 108:     it "follows per-result next_page_token, resubmitting only paged queries" do
// 109:       page1 = {
// 110:         results: [
// 111:           { vulns: [{ id: "A1" }] },
// 112:           { vulns: [{ id: "B1" }], next_page_token: "tok-b" },
// 113:           { vulns: [{ id: "C1" }] },
// 114:         ],
// 115:       }
// 116:       page2 = { results: [{ vulns: [{ id: "B2" }, { id: "B3" }] }] }
// 117:       posted = []
// 118:       expect(Utils::Curl).to receive(:curl_output).twice do |*args|
// 119:         posted << JSON.parse(args[args.index("--json") + 1])
// 120:         curl_result(stdout: ((posted.size == 1) ? page1 : page2).to_json)
// 121:       end
// 122:
// 123:       results = described_class.query_batch(packages)
// 124:
// 125:       expect(results[0].map { |v| v["id"] }).to eq %w[A1]
// 126:       expect(results[1].map { |v| v["id"] }).to eq %w[B1 B2 B3]
// 127:       expect(results[2].map { |v| v["id"] }).to eq %w[C1]
// 128:       expect(posted[1]["queries"]).to eq [
// 129:         { "package"    => { "name" => "https://github.com/b/b", "ecosystem" => "GIT" },
// 130:           "version"    => "v2",
// 131:           "page_token" => "tok-b" },
// 132:       ]
// 133:     end
// 134:
// 135:     it "raises after MAX_PAGES continuation requests" do
// 136:       stub_const("#{described_class}::MAX_PAGES", 3)
// 137:       body = { results: [{ vulns: [{ id: "LOOP" }], next_page_token: "again" }] }
// 138:       stub_curl curl_result(stdout: body.to_json)
// 139:
// 140:       expect { described_class.query_batch([packages.first]) }
// 141:         .to raise_error(described_class::ApiError, /more than 3 pages/)
// 142:     end
// 143:
// 144:     it "raises ApiError when curl reports failure" do
// 145:       stub_curl curl_result(stdout: "server on fire", success: false)
// 146:       expect { described_class.query_batch(packages) }
// 147:         .to raise_error(described_class::ApiError, /OSV API/)
// 148:     end
// 149:
// 150:     it "raises ApiError when the response is not valid JSON" do
// 151:       stub_curl curl_result(stdout: "<html>not json</html>")
// 152:       expect { described_class.query_batch(packages) }
// 153:         .to raise_error(described_class::ApiError, /Invalid JSON/)
// 154:     end
// 155:   end
// 156:
// 157:   describe ".vulnerability" do
// 158:     it "fetches a single vulnerability record by id" do
// 159:       body = {
// 160:         id:       "CVE-2024-1234",
// 161:         summary:  "Test vulnerability",
// 162:         details:  "Full details here",
// 163:         severity: [{ type: "CVSS_V3", score: "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H" }],
// 164:       }
// 165:       stub_curl curl_result(stdout: body.to_json)
// 166:
// 167:       vuln = described_class.vulnerability("CVE-2024-1234")
// 168:
// 169:       expect(vuln["id"]).to eq "CVE-2024-1234"
// 170:       expect(vuln["summary"]).to eq "Test vulnerability"
// 171:       expect(vuln["details"]).to eq "Full details here"
// 172:     end
// 173:
// 174:     it "URL-encodes the id in the request path" do
// 175:       requested = nil
// 176:       expect(Utils::Curl).to receive(:curl_output) do |*args|
// 177:         requested = args.last
// 178:         curl_result(stdout: { id: "GO-2024-1/2" }.to_json)
// 179:       end
// 180:
// 181:       described_class.vulnerability("GO-2024-1/2")
// 182:
// 183:       expect(requested).to eq "https://api.osv.dev/v1/vulns/GO-2024-1%2F2"
// 184:     end
// 185:
// 186:     it "raises ApiError when curl reports failure" do
// 187:       stub_curl curl_result(stdout: "not found", success: false)
// 188:       expect { described_class.vulnerability("CVE-0000-0000") }
// 189:         .to raise_error(described_class::ApiError, /OSV API/)
// 190:     end
// 191:   end
// 192: end
