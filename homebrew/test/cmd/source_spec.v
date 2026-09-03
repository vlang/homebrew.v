module cmd

import brew_runtime
import homebrew.cmd as production_cmd
import os
import time

// Translated from Homebrew/brew `test/cmd/source_spec.rb`.
// The original source is retained below until every stub has a typed V body.

const source_spec_pypi_numpy_url = 'https://files.pythonhosted.org/packages/24/62/ae72ff66c0f1fd959925b4c11f8c2dea61f47f6acaea75a08512cdfe3fed/numpy-2.4.1.tar.gz'
const source_spec_pypi_foobar_url = 'https://files.pythonhosted.org/packages/00/00/000000000000000000000000000000000000000000000000000000000000/foobar-0.0.1.tar.gz'
const source_spec_npm_vite_url = 'https://registry.npmjs.org/vite/-/vite-1.2.3.tgz'
const source_spec_npm_scoped_vite_url = 'https://registry.npmjs.org/@org/vite/-/vite-1.2.3.tgz'

fn source_spec_http_get(url string) !production_cmd.SourceHttpResult {
	return match url {
		'https://pypi.org/pypi/numpy/json' {
			production_cmd.SourceHttpResult{
				body: '{"info":{"project_urls":{"Repository":"https://github.com/numpy/numpy"}}}'
				success: true
			}
		}
		'https://pypi.org/pypi/foobar/json' {
			production_cmd.SourceHttpResult{
				body: '{"info":{"project_urls":{}}}'
				success: true
			}
		}
		'https://registry.npmjs.org/vite/latest', 'https://registry.npmjs.org/%40org%2Fvite/latest' {
			production_cmd.SourceHttpResult{
				body: '{"repository":{"url":"git+https://github.com/vitejs/vite.git"}}'
				success: true
			}
		}
		else { production_cmd.SourceHttpResult{} }
	}
}

fn source_spec_bool(value bool) brew_runtime.Value {
	return brew_runtime.bool_value(value)
}

fn source_spec_run_browser(root string, url string) bool {
	browser := os.join_path(root, 'browser')
	os.mkdir_all(root) or { return false }
	os.write_file(browser, '#!/bin/sh\nprintf \'%s\\n\' "\$1"\n') or { return false }
	os.chmod(browser, 0o755) or { return false }
	result := os.execute('${os.quoted_path(browser)} ${os.quoted_path(url)}')
	return result.exit_code == 0 && result.output == '${url}\n'
}

// Ruby it `it "opens the Homebrew repo when no formula is specified", :integration_test do` at line 10.
pub fn ruby_source_spec_l10_d1_opens(args ...brew_runtime.Value) brew_runtime.Value {
	root := if args.len > 0 && args[0].as_string() != '' {
		args[0].as_string()
	} else {
		os.join_path(os.temp_dir(), 'brew-v-source-browser-${os.getpid()}-${time.now().unix_micro()}')
	}
	cleanup := args.len == 0
	defer {
		if cleanup {
			os.rmdir_all(root) or {}
		}
	}
	plan := production_cmd.plan_source_command([], source_spec_http_get)
	return source_spec_bool(plan.messages.len == 0 && plan.warnings.len == 0
		&& plan.repo_urls == [production_cmd.source_homebrew_repository]
		&& source_spec_run_browser(root, plan.repo_urls[0]))
}

// Ruby it `it "extracts repository URL from GitHub URL" do` at line 18.
pub fn ruby_source_spec_l18_d2_extracts(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return source_spec_bool(production_cmd.source_github_repo_url('https://github.com/Homebrew/brew.git') or {
		''
	} == 'https://github.com/Homebrew/brew')
}

// Ruby it `it "handles GitHub archive URLs" do` at line 23.
pub fn ruby_source_spec_l23_d3_handles(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return source_spec_bool(production_cmd.source_github_repo_url('https://github.com/Homebrew/testball/archive/refs/tags/v0.1.tar.gz') or {
		''
	} == 'https://github.com/Homebrew/testball')
}

// Ruby it `it "returns nil for non-GitHub URLs" do` at line 28.
pub fn ruby_source_spec_l28_d4_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return source_spec_bool(production_cmd.source_github_repo_url('https://example.com/repo.git') == none)
}

// Ruby it `it "extracts repository URL from GitLab URL with nested groups" do` at line 35.
pub fn ruby_source_spec_l35_d5_extracts(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return source_spec_bool(production_cmd.source_gitlab_repo_url('https://gitlab.com/group/subgroup/project/-/archive/v1.0/project-v1.0.tar.gz') or {
		''
	} == 'https://gitlab.com/group/subgroup/project')
}

// Ruby it `it "handles GitLab .git URLs" do` at line 40.
pub fn ruby_source_spec_l40_d6_handles(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return source_spec_bool(production_cmd.source_gitlab_repo_url('https://gitlab.com/user/repo.git') or {
		''
	} == 'https://gitlab.com/user/repo')
}

// Ruby it `it "returns nil for non-GitLab URLs" do` at line 45.
pub fn ruby_source_spec_l45_d7_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return source_spec_bool(production_cmd.source_gitlab_repo_url('https://example.com/repo.git') == none)
}

// Ruby it `it "extracts repository URL from Bitbucket URL" do` at line 52.
pub fn ruby_source_spec_l52_d8_extracts(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return source_spec_bool(production_cmd.source_bitbucket_repo_url('https://bitbucket.org/user/repo/get/v1.0.tar.gz') or {
		''
	} == 'https://bitbucket.org/user/repo')
}

// Ruby it `it "handles Bitbucket .git URLs" do` at line 57.
pub fn ruby_source_spec_l57_d9_handles(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return source_spec_bool(production_cmd.source_bitbucket_repo_url('https://bitbucket.org/user/repo.git') or {
		''
	} == 'https://bitbucket.org/user/repo')
}

// Ruby it `it "returns nil for non-Bitbucket URLs" do` at line 62.
pub fn ruby_source_spec_l62_d10_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return source_spec_bool(production_cmd.source_bitbucket_repo_url('https://example.com/repo.git') == none)
}

// Ruby it `it "extracts repository URL from Codeberg URL" do` at line 69.
pub fn ruby_source_spec_l69_d11_extracts(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return source_spec_bool(production_cmd.source_codeberg_repo_url('https://codeberg.org/user/repo/archive/v1.0.tar.gz') or {
		''
	} == 'https://codeberg.org/user/repo')
}

// Ruby it `it "handles Codeberg .git URLs" do` at line 74.
pub fn ruby_source_spec_l74_d12_handles(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return source_spec_bool(production_cmd.source_codeberg_repo_url('https://codeberg.org/user/repo.git') or {
		''
	} == 'https://codeberg.org/user/repo')
}

// Ruby it `it "returns nil for non-Codeberg URLs" do` at line 79.
pub fn ruby_source_spec_l79_d13_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return source_spec_bool(production_cmd.source_codeberg_repo_url('https://example.com/repo.git') == none)
}

// Ruby it `it "extracts repository URL from SourceHut URL" do` at line 86.
pub fn ruby_source_spec_l86_d14_extracts(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return source_spec_bool(production_cmd.source_sourcehut_repo_url('https://git.sr.ht/~user/repo/archive/v1.0.tar.gz') or {
		''
	} == 'https://sr.ht/~user/repo')
}

// Ruby it `it "handles sr.ht URLs without git subdomain" do` at line 91.
pub fn ruby_source_spec_l91_d15_handles(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return source_spec_bool(production_cmd.source_sourcehut_repo_url('https://sr.ht/~user/repo') or {
		''
	} == 'https://sr.ht/~user/repo')
}

// Ruby it `it "returns nil for non-SourceHut URLs" do` at line 96.
pub fn ruby_source_spec_l96_d16_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return source_spec_bool(production_cmd.source_sourcehut_repo_url('https://example.com/repo.git') == none)
}

// Ruby it `it "finds repository for PyPI URL" do` at line 103.
pub fn ruby_source_spec_l103_d17_finds(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return source_spec_bool(production_cmd.source_pypi_repo_url(source_spec_pypi_numpy_url, source_spec_http_get) or { '' } == 'https://github.com/numpy/numpy')
}

// Ruby it `it "returns nil for PyPI package without project information" do` at line 127.
pub fn ruby_source_spec_l127_d18_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return source_spec_bool(production_cmd.source_pypi_repo_url(source_spec_pypi_foobar_url, source_spec_http_get) == none)
}

// Ruby it `it "returns nil for non-PyPI URLs" do` at line 149.
pub fn ruby_source_spec_l149_d19_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return source_spec_bool(production_cmd.source_pypi_repo_url('https://example.com/repo.git', source_spec_http_get) == none)
}

// Ruby it `it "finds repository for npm URL" do` at line 156.
pub fn ruby_source_spec_l156_d20_finds(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	for url in [source_spec_npm_vite_url, source_spec_npm_scoped_vite_url] {
		if production_cmd.source_npm_repo_url(url, source_spec_http_get) or { '' } != 'https://github.com/vitejs/vite.git' {
			return source_spec_bool(false)
		}
	}
	return source_spec_bool(true)
}

// Ruby it `it "returns nil for npm package without repository information" do` at line 178.
pub fn ruby_source_spec_l178_d21_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return source_spec_bool(production_cmd.source_npm_repo_url(source_spec_npm_vite_url, fn (_ string) !production_cmd.SourceHttpResult {
		return production_cmd.SourceHttpResult{
			body: '{}'
			success: true
		}
	}) == none)
}

// Ruby it `it "returns nil for non-npm URLs" do` at line 192.
pub fn ruby_source_spec_l192_d22_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return source_spec_bool(production_cmd.source_npm_repo_url('https://example.com/repo.git', source_spec_http_get) == none)
}

// Ruby it `it "returns GitHub repo URL for GitHub URLs" do` at line 199.
pub fn ruby_source_spec_l199_d23_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return source_spec_bool(production_cmd.source_url_to_repo('https://github.com/Homebrew/brew', source_spec_http_get) or { '' } == 'https://github.com/Homebrew/brew')
}

// Ruby it `it "returns GitLab repo URL for GitLab URLs" do` at line 204.
pub fn ruby_source_spec_l204_d24_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return source_spec_bool(production_cmd.source_url_to_repo('https://gitlab.com/user/repo.git', source_spec_http_get) or { '' } == 'https://gitlab.com/user/repo')
}

// Ruby it `it "returns nil for unsupported URLs" do` at line 209.
pub fn ruby_source_spec_l209_d25_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return source_spec_bool(production_cmd.source_url_to_repo('https://example.com/repo.tar.gz', source_spec_http_get) == none)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/source"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::Source do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "opens the Homebrew repo when no formula is specified", :integration_test do
// 11:     expect { brew "source", "HOMEBREW_BROWSER" => "echo" }
// 12:       .to output(%r{https://github\.com/Homebrew/brew}).to_stdout
// 13:       .and not_to_output.to_stderr
// 14:       .and be_a_success
// 15:   end
// 16:
// 17:   describe "#github_repo_url" do
// 18:     it "extracts repository URL from GitHub URL" do
// 19:       expect(described_class.new([]).github_repo_url("https://github.com/Homebrew/brew.git"))
// 20:         .to eq("https://github.com/Homebrew/brew")
// 21:     end
// 22:
// 23:     it "handles GitHub archive URLs" do
// 24:       expect(described_class.new([]).github_repo_url("https://github.com/Homebrew/testball/archive/refs/tags/v0.1.tar.gz"))
// 25:         .to eq("https://github.com/Homebrew/testball")
// 26:     end
// 27:
// 28:     it "returns nil for non-GitHub URLs" do
// 29:       expect(described_class.new([]).github_repo_url("https://example.com/repo.git"))
// 30:         .to be_nil
// 31:     end
// 32:   end
// 33:
// 34:   describe "#gitlab_repo_url" do
// 35:     it "extracts repository URL from GitLab URL with nested groups" do
// 36:       expect(described_class.new([]).gitlab_repo_url("https://gitlab.com/group/subgroup/project/-/archive/v1.0/project-v1.0.tar.gz"))
// 37:         .to eq("https://gitlab.com/group/subgroup/project")
// 38:     end
// 39:
// 40:     it "handles GitLab .git URLs" do
// 41:       expect(described_class.new([]).gitlab_repo_url("https://gitlab.com/user/repo.git"))
// 42:         .to eq("https://gitlab.com/user/repo")
// 43:     end
// 44:
// 45:     it "returns nil for non-GitLab URLs" do
// 46:       expect(described_class.new([]).gitlab_repo_url("https://example.com/repo.git"))
// 47:         .to be_nil
// 48:     end
// 49:   end
// 50:
// 51:   describe "#bitbucket_repo_url" do
// 52:     it "extracts repository URL from Bitbucket URL" do
// 53:       expect(described_class.new([]).bitbucket_repo_url("https://bitbucket.org/user/repo/get/v1.0.tar.gz"))
// 54:         .to eq("https://bitbucket.org/user/repo")
// 55:     end
// 56:
// 57:     it "handles Bitbucket .git URLs" do
// 58:       expect(described_class.new([]).bitbucket_repo_url("https://bitbucket.org/user/repo.git"))
// 59:         .to eq("https://bitbucket.org/user/repo")
// 60:     end
// 61:
// 62:     it "returns nil for non-Bitbucket URLs" do
// 63:       expect(described_class.new([]).bitbucket_repo_url("https://example.com/repo.git"))
// 64:         .to be_nil
// 65:     end
// 66:   end
// 67:
// 68:   describe "#codeberg_repo_url" do
// 69:     it "extracts repository URL from Codeberg URL" do
// 70:       expect(described_class.new([]).codeberg_repo_url("https://codeberg.org/user/repo/archive/v1.0.tar.gz"))
// 71:         .to eq("https://codeberg.org/user/repo")
// 72:     end
// 73:
// 74:     it "handles Codeberg .git URLs" do
// 75:       expect(described_class.new([]).codeberg_repo_url("https://codeberg.org/user/repo.git"))
// 76:         .to eq("https://codeberg.org/user/repo")
// 77:     end
// 78:
// 79:     it "returns nil for non-Codeberg URLs" do
// 80:       expect(described_class.new([]).codeberg_repo_url("https://example.com/repo.git"))
// 81:         .to be_nil
// 82:     end
// 83:   end
// 84:
// 85:   describe "#sourcehut_repo_url" do
// 86:     it "extracts repository URL from SourceHut URL" do
// 87:       expect(described_class.new([]).sourcehut_repo_url("https://git.sr.ht/~user/repo/archive/v1.0.tar.gz"))
// 88:         .to eq("https://sr.ht/~user/repo")
// 89:     end
// 90:
// 91:     it "handles sr.ht URLs without git subdomain" do
// 92:       expect(described_class.new([]).sourcehut_repo_url("https://sr.ht/~user/repo"))
// 93:         .to eq("https://sr.ht/~user/repo")
// 94:     end
// 95:
// 96:     it "returns nil for non-SourceHut URLs" do
// 97:       expect(described_class.new([]).sourcehut_repo_url("https://example.com/repo.git"))
// 98:         .to be_nil
// 99:     end
// 100:   end
// 101:
// 102:   describe "#pypi_repo_url" do
// 103:     it "finds repository for PyPI URL" do
// 104:       expect(Utils::Curl).to receive(:curl_output)
// 105:         .with(*Utils::Curl.curl_args(show_error: false, retries: 2), "https://pypi.org/pypi/numpy/json")
// 106:         .and_return([
// 107:           <<~JSON,
// 108:             {
// 109:               "info": {
// 110:                 "project_urls": {
// 111:                   "Repository": "https://github.com/numpy/numpy"
// 112:                 }
// 113:               }
// 114:             }
// 115:           JSON
// 116:           "",
// 117:           instance_double(Process::Status, success?: true),
// 118:         ])
// 119:
// 120:       expect(described_class.new([])
// 121:         .pypi_repo_url(
// 122:           "https://files.pythonhosted.org/packages/24/62/ae72ff66c0f1fd959925b4c11f8c2dea61f47f6acaea75a08512cdfe3fed/numpy-2.4.1.tar.gz",
// 123:         ))
// 124:         .to eq("https://github.com/numpy/numpy")
// 125:     end
// 126:
// 127:     it "returns nil for PyPI package without project information" do
// 128:       expect(Utils::Curl).to receive(:curl_output)
// 129:         .with(*Utils::Curl.curl_args(show_error: false, retries: 2), "https://pypi.org/pypi/foobar/json")
// 130:         .and_return([
// 131:           <<~JSON,
// 132:             {
// 133:               "info": {
// 134:                 "project_urls": {}
// 135:               }
// 136:             }
// 137:           JSON
// 138:           "",
// 139:           instance_double(Process::Status, success?: true),
// 140:         ])
// 141:
// 142:       expect(described_class.new([])
// 143:         .pypi_repo_url(
// 144:           "https://files.pythonhosted.org/packages/00/00/000000000000000000000000000000000000000000000000000000000000/foobar-0.0.1.tar.gz",
// 145:         ))
// 146:         .to be_nil
// 147:     end
// 148:
// 149:     it "returns nil for non-PyPI URLs" do
// 150:       expect(described_class.new([]).pypi_repo_url("https://example.com/repo.git"))
// 151:         .to be_nil
// 152:     end
// 153:   end
// 154:
// 155:   describe "#npm_repo_url" do
// 156:     it "finds repository for npm URL" do
// 157:       ["vite", "@org/vite"].each do |package|
// 158:         encoded_package = URI.encode_uri_component(package)
// 159:         expect(Utils::Curl).to receive(:curl_output)
// 160:           .with(*Utils::Curl.curl_args(show_error: false, retries: 2), "https://registry.npmjs.org/#{encoded_package}/latest")
// 161:           .and_return([
// 162:             <<~JSON,
// 163:               {
// 164:                 "repository": {
// 165:                   "url": "git+https://github.com/vitejs/vite.git"
// 166:                 }
// 167:               }
// 168:             JSON
// 169:             "",
// 170:             instance_double(Process::Status, success?: true),
// 171:           ])
// 172:
// 173:         expect(described_class.new([]).npm_repo_url("https://registry.npmjs.org/#{package}/-/vite-1.2.3.tgz"))
// 174:           .to eq("https://github.com/vitejs/vite.git")
// 175:       end
// 176:     end
// 177:
// 178:     it "returns nil for npm package without repository information" do
// 179:       expect(Utils::Curl).to receive(:curl_output)
// 180:         .with(*Utils::Curl.curl_args(show_error: false, retries: 2), "https://registry.npmjs.org/vite/latest")
// 181:         .and_return([
// 182:           "{}",
// 183:           "",
// 184:           instance_double(Process::Status, success?: true),
// 185:         ])
// 186:
// 187:       expect(described_class.new([])
// 188:         .npm_repo_url("https://registry.npmjs.org/vite/-/vite-1.2.3.tgz"))
// 189:         .to be_nil
// 190:     end
// 191:
// 192:     it "returns nil for non-npm URLs" do
// 193:       expect(described_class.new([]).npm_repo_url("https://example.com/repo.git"))
// 194:         .to be_nil
// 195:     end
// 196:   end
// 197:
// 198:   describe "#url_to_repo" do
// 199:     it "returns GitHub repo URL for GitHub URLs" do
// 200:       expect(described_class.new([]).url_to_repo("https://github.com/Homebrew/brew"))
// 201:         .to eq("https://github.com/Homebrew/brew")
// 202:     end
// 203:
// 204:     it "returns GitLab repo URL for GitLab URLs" do
// 205:       expect(described_class.new([]).url_to_repo("https://gitlab.com/user/repo.git"))
// 206:         .to eq("https://gitlab.com/user/repo")
// 207:     end
// 208:
// 209:     it "returns nil for unsupported URLs" do
// 210:       expect(described_class.new([]).url_to_repo("https://example.com/repo.tar.gz"))
// 211:         .to be_nil
// 212:     end
// 213:   end
// 214: end
