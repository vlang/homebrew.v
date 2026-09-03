module utils

import brew_runtime
import homebrew.utils as shared_audits

// Translated from Homebrew/brew `test/utils/shared_audits_spec.rb`.
// The original source is retained below for exact source traceability.
const shared_audits_spec_eol_json = '{\n  "schema_version" : "1.0.0",\n  "generated_at": "2025-01-02T01:23:45+00:00",\n  "result": {\n    "name": "1.2",\n    "codename": null,\n    "label": "1.2",\n    "releaseDate": "2024-01-01",\n    "isLts": false,\n    "ltsFrom": null,\n    "isEol": true,\n    "eolFrom": "2025-01-01",\n    "isMaintained": false,\n    "latest": {\n      "name": "1.0.0",\n      "date": "2024-01-01",\n      "link": "https://example.com/1.0.0"\n    }\n  }\n}\n'

fn shared_audits_spec_fetch(arguments []string) !shared_audits.SharedAuditsHttpResult {
	url := arguments.last()
	if url.contains('/products/product/releases/cycle') {
		return shared_audits.SharedAuditsHttpResult{
			stdout: shared_audits_spec_eol_json
			success: true
		}
	}
	if url.contains('/products/none/releases/cycle') {
		return shared_audits.SharedAuditsHttpResult{
			stdout: '<html></html>'
			success: true
		}
	}
	return shared_audits.SharedAuditsHttpResult{
		success: false
	}
}

fn shared_audits_spec_state() &shared_audits.SharedAuditsState {
	return shared_audits.new_shared_audits_state(shared_audits.SharedAuditsConfig{
		fetcher: shared_audits_spec_fetch
		today: '2026-07-26'
		now_iso: '2026-07-26T00:00:00Z'
	})
}

fn shared_audits_spec_bool(value bool) brew_runtime.Value {
	return brew_runtime.bool_value(value)
}

// Ruby let `let(:eol_json_text) do` at line 8.
pub fn ruby_shared_audits_spec_l8_d1_eol_json_text(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value(shared_audits_spec_eol_json)
}

// Ruby method `mock_curl_output(stdout: "", success: true)` at line 33.
pub fn ruby_shared_audits_spec_l33_d2_mock_curl_output(args ...brew_runtime.Value) brew_runtime.Value {
	stdout := if args.len > 0 { args[0].as_string() } else { '' }
	success := args.len < 2 || args[1].bool_data
	return brew_runtime.map_value({
		'stdout':  brew_runtime.string_value(stdout)
		'success': brew_runtime.bool_value(success)
	})
}

// Ruby it `it "returns true for a date less than a year ago" do` at line 42.
pub fn ruby_shared_audits_spec_l42_d3_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return shared_audits_spec_bool(shared_audits.shared_audits_homepage_browsed_recently('2025-07-27', '2026-07-26'))
}

// Ruby it `it "returns false for a date a year ago" do` at line 46.
pub fn ruby_shared_audits_spec_l46_d4_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return shared_audits_spec_bool(!shared_audits.shared_audits_homepage_browsed_recently('2025-07-26', '2026-07-26'))
}

// Ruby it `it "returns false for a future date" do` at line 50.
pub fn ruby_shared_audits_spec_l50_d5_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return shared_audits_spec_bool(!shared_audits.shared_audits_homepage_browsed_recently('2026-07-27', '2026-07-26'))
}

// Ruby it `it "returns false without a date" do` at line 54.
pub fn ruby_shared_audits_spec_l54_d6_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return shared_audits_spec_bool(!shared_audits.shared_audits_homepage_browsed_recently(none, '2026-07-26'))
}

// Ruby it `it "returns a parsed JSON object if the product is found" do` at line 60.
pub fn ruby_shared_audits_spec_l60_d7_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	mut state := shared_audits_spec_state()
	data := state.eol_data('product', 'cycle')
	result := data.map_data['result'] or { return shared_audits_spec_bool(false) }
	return shared_audits_spec_bool((result.map_data['isEol'] or { return shared_audits_spec_bool(false) }).bool_data && (result.map_data['eolFrom'] or { return shared_audits_spec_bool(false) }).as_string() == '2025-01-01' && state.eol_data('product', 'cycle').type_name == 'Hash')
}

// Ruby it `it "returns nil if the product is not found" do` at line 66.
pub fn ruby_shared_audits_spec_l66_d8_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	mut state := shared_audits_spec_state()
	return shared_audits_spec_bool(state.eol_data('none', 'cycle').type_name == 'NilClass')
}

// Ruby it `it "returns nil if api call fails" do` at line 71.
pub fn ruby_shared_audits_spec_l71_d9_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	mut state := shared_audits_spec_state()
	return shared_audits_spec_bool(state.eol_data('', '').type_name == 'NilClass')
}

// Ruby it `it "finds tags in archive urls" do` at line 78.
pub fn ruby_shared_audits_spec_l78_d10_finds(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	tag := shared_audits.shared_audits_github_tag_from_url('https://github.com/a/b/archive/refs/tags/v1.2.3.tar.gz') or {
		return shared_audits_spec_bool(false)
	}
	return shared_audits_spec_bool(tag == 'v1.2.3')
}

// Ruby it `it "finds tags in release urls" do` at line 83.
pub fn ruby_shared_audits_spec_l83_d11_finds(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	tag := shared_audits.shared_audits_github_tag_from_url('https://github.com/a/b/releases/download/1.2.3/b-1.2.3.tar.bz2') or {
		return shared_audits_spec_bool(false)
	}
	return shared_audits_spec_bool(tag == '1.2.3')
}

// Ruby it `it "finds tags with slashes" do` at line 88.
pub fn ruby_shared_audits_spec_l88_d12_finds(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	tag := shared_audits.shared_audits_github_tag_from_url('https://github.com/a/b/archive/refs/tags/c/d/e/f/g-v1.2.3.tar.gz') or {
		return shared_audits_spec_bool(false)
	}
	return shared_audits_spec_bool(tag == 'c/d/e/f/g-v1.2.3')
}

// Ruby it `it "finds tags in orgs/repos with special characters" do` at line 93.
pub fn ruby_shared_audits_spec_l93_d13_finds(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	tag := shared_audits.shared_audits_github_tag_from_url('https://github.com/a-b/c-d_e.f/archive/refs/tags/2.5.tar.gz') or {
		return shared_audits_spec_bool(false)
	}
	return shared_audits_spec_bool(tag == '2.5')
}

// Ruby it `it "doesn't find tags in invalid urls" do` at line 100.
pub fn ruby_shared_audits_spec_l100_d14_doesn(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return shared_audits_spec_bool(shared_audits.shared_audits_gitlab_tag_from_url('https://gitlab.com/a/-/archive/v1.2.3/a-v1.2.3.tar.gz') == none)
}

// Ruby it `it "finds tags in basic urls" do` at line 105.
pub fn ruby_shared_audits_spec_l105_d15_finds(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	tag := shared_audits.shared_audits_gitlab_tag_from_url('https://gitlab.com/a/b/-/archive/v1.2.3/b-1.2.3.tar.gz') or {
		return shared_audits_spec_bool(false)
	}
	return shared_audits_spec_bool(tag == 'v1.2.3')
}

// Ruby it `it "finds tags in urls with subgroups" do` at line 110.
pub fn ruby_shared_audits_spec_l110_d16_finds(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	tag := shared_audits.shared_audits_gitlab_tag_from_url('https://gitlab.com/a/b/c/d/e/f/g/-/archive/2.5/g-2.5.tar.gz') or {
		return shared_audits_spec_bool(false)
	}
	return shared_audits_spec_bool(tag == '2.5')
}

// Ruby it `it "finds tags in urls with special characters" do` at line 115.
pub fn ruby_shared_audits_spec_l115_d17_finds(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	tag := shared_audits.shared_audits_gitlab_tag_from_url('https://gitlab.com/a.b/c-d_e/-/archive/2.5/c-d_e-2.5.tar.gz') or {
		return shared_audits_spec_bool(false)
	}
	return shared_audits_spec_bool(tag == '2.5')
}

// Ruby it `it "finds tags in basic urls" do` at line 122.
pub fn ruby_shared_audits_spec_l122_d18_finds(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	tag := shared_audits.shared_audits_forgejo_tag_from_url('https://codeberg.org/Aviac/codeberg-cli/archive/v0.4.11.tar.gz') or {
		return shared_audits_spec_bool(false)
	}
	return shared_audits_spec_bool(tag == 'v0.4.11')
}

// Ruby it `it "finds tags in urls with subgroups" do` at line 127.
pub fn ruby_shared_audits_spec_l127_d19_finds(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	tag := shared_audits.shared_audits_forgejo_tag_from_url('https://codeberg.org/Aviac/codeberg-cli/archive/some/test/1.2.3.tar.gz') or {
		return shared_audits_spec_bool(false)
	}
	return shared_audits_spec_bool(tag == 'some/test/1.2.3')
}

// Ruby it `it "finds tags in orgs/repos with special characters" do` at line 132.
pub fn ruby_shared_audits_spec_l132_d20_finds(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	tag := shared_audits.shared_audits_forgejo_tag_from_url('https://codeberg.org/Aviaca-b_cv/codeberg-cli/archive/v0.4.11.tar.gz') or {
		return shared_audits_spec_bool(false)
	}
	return shared_audits_spec_bool(tag == 'v0.4.11')
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/shared_audits"
// 5: require "utils/curl"
// 6:
// 7: RSpec.describe SharedAudits do
// 8:   let(:eol_json_text) do
// 9:     <<~JSON
// 10:       {
// 11:         "schema_version" : "1.0.0",
// 12:         "generated_at": "2025-01-02T01:23:45+00:00",
// 13:         "result": {
// 14:           "name": "1.2",
// 15:           "codename": null,
// 16:           "label": "1.2",
// 17:           "releaseDate": "2024-01-01",
// 18:           "isLts": false,
// 19:           "ltsFrom": null,
// 20:           "isEol": true,
// 21:           "eolFrom": "2025-01-01",
// 22:           "isMaintained": false,
// 23:           "latest": {
// 24:             "name": "1.0.0",
// 25:             "date": "2024-01-01",
// 26:             "link": "https://example.com/1.0.0"
// 27:           }
// 28:         }
// 29:       }
// 30:     JSON
// 31:   end
// 32:
// 33:   def mock_curl_output(stdout: "", success: true)
// 34:     status = instance_double(Process::Status, success?: success)
// 35:     curl_output = instance_double(SystemCommand::Result, stdout:, status:)
// 36:     allow(Utils::Curl).to receive(:curl_output).and_return curl_output
// 37:   end
// 38:
// 39:   describe "::homepage_browsed_recently?" do
// 40:     before { allow(Date).to receive(:today).and_return(Date.new(2026, 7, 26)) }
// 41:
// 42:     it "returns true for a date less than a year ago" do
// 43:       expect(described_class.homepage_browsed_recently?(Date.new(2025, 7, 27))).to be(true)
// 44:     end
// 45:
// 46:     it "returns false for a date a year ago" do
// 47:       expect(described_class.homepage_browsed_recently?(Date.new(2025, 7, 26))).to be(false)
// 48:     end
// 49:
// 50:     it "returns false for a future date" do
// 51:       expect(described_class.homepage_browsed_recently?(Date.new(2026, 7, 27))).to be(false)
// 52:     end
// 53:
// 54:     it "returns false without a date" do
// 55:       expect(described_class.homepage_browsed_recently?(nil)).to be(false)
// 56:     end
// 57:   end
// 58:
// 59:   describe "::eol_data" do
// 60:     it "returns a parsed JSON object if the product is found" do
// 61:       mock_curl_output stdout: eol_json_text
// 62:       expect(described_class.eol_data("product", "cycle")&.dig("result", "isEol")).to be(true)
// 63:       expect(described_class.eol_data("product", "cycle")&.dig("result", "eolFrom")).to eq("2025-01-01")
// 64:     end
// 65:
// 66:     it "returns nil if the product is not found" do
// 67:       mock_curl_output stdout: "<html></html>"
// 68:       expect(described_class.eol_data("none", "cycle")).to be_nil
// 69:     end
// 70:
// 71:     it "returns nil if api call fails" do
// 72:       mock_curl_output success: false
// 73:       expect(described_class.eol_data("", "")).to be_nil
// 74:     end
// 75:   end
// 76:
// 77:   describe "::github_tag_from_url" do
// 78:     it "finds tags in archive urls" do
// 79:       url = "https://github.com/a/b/archive/refs/tags/v1.2.3.tar.gz"
// 80:       expect(described_class.github_tag_from_url(url)).to eq("v1.2.3")
// 81:     end
// 82:
// 83:     it "finds tags in release urls" do
// 84:       url = "https://github.com/a/b/releases/download/1.2.3/b-1.2.3.tar.bz2"
// 85:       expect(described_class.github_tag_from_url(url)).to eq("1.2.3")
// 86:     end
// 87:
// 88:     it "finds tags with slashes" do
// 89:       url = "https://github.com/a/b/archive/refs/tags/c/d/e/f/g-v1.2.3.tar.gz"
// 90:       expect(described_class.github_tag_from_url(url)).to eq("c/d/e/f/g-v1.2.3")
// 91:     end
// 92:
// 93:     it "finds tags in orgs/repos with special characters" do
// 94:       url = "https://github.com/a-b/c-d_e.f/archive/refs/tags/2.5.tar.gz"
// 95:       expect(described_class.github_tag_from_url(url)).to eq("2.5")
// 96:     end
// 97:   end
// 98:
// 99:   describe "::gitlab_tag_from_url" do
// 100:     it "doesn't find tags in invalid urls" do
// 101:       url = "https://gitlab.com/a/-/archive/v1.2.3/a-v1.2.3.tar.gz"
// 102:       expect(described_class.gitlab_tag_from_url(url)).to be_nil
// 103:     end
// 104:
// 105:     it "finds tags in basic urls" do
// 106:       url = "https://gitlab.com/a/b/-/archive/v1.2.3/b-1.2.3.tar.gz"
// 107:       expect(described_class.gitlab_tag_from_url(url)).to eq("v1.2.3")
// 108:     end
// 109:
// 110:     it "finds tags in urls with subgroups" do
// 111:       url = "https://gitlab.com/a/b/c/d/e/f/g/-/archive/2.5/g-2.5.tar.gz"
// 112:       expect(described_class.gitlab_tag_from_url(url)).to eq("2.5")
// 113:     end
// 114:
// 115:     it "finds tags in urls with special characters" do
// 116:       url = "https://gitlab.com/a.b/c-d_e/-/archive/2.5/c-d_e-2.5.tar.gz"
// 117:       expect(described_class.gitlab_tag_from_url(url)).to eq("2.5")
// 118:     end
// 119:   end
// 120:
// 121:   describe "::forgejo_tag_from_url" do
// 122:     it "finds tags in basic urls" do
// 123:       url = "https://codeberg.org/Aviac/codeberg-cli/archive/v0.4.11.tar.gz"
// 124:       expect(described_class.forgejo_tag_from_url(url)).to eq("v0.4.11")
// 125:     end
// 126:
// 127:     it "finds tags in urls with subgroups" do
// 128:       url = "https://codeberg.org/Aviac/codeberg-cli/archive/some/test/1.2.3.tar.gz"
// 129:       expect(described_class.forgejo_tag_from_url(url)).to eq("some/test/1.2.3")
// 130:     end
// 131:
// 132:     it "finds tags in orgs/repos with special characters" do
// 133:       url = "https://codeberg.org/Aviaca-b_cv/codeberg-cli/archive/v0.4.11.tar.gz"
// 134:       expect(described_class.forgejo_tag_from_url(url)).to eq("v0.4.11")
// 135:     end
// 136:   end
// 137: end
