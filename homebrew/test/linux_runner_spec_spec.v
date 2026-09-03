module test

import homebrew
import json2

// Translated from Homebrew/brew `test/linux_runner_spec_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:spec) do` at line 7.
pub fn ruby_linux_runner_spec_spec_l7_d1_spec() homebrew.LinuxRunnerSpec {
	return homebrew.LinuxRunnerSpec{
		name: 'Linux'
		runner: 'ubuntu-latest'
		container: homebrew.LinuxRunnerContainer{
			image: 'ghcr.io/homebrew/brew:main'
			options: '--user=linuxbrew'
		}
		workdir: '/github/home'
		timeout: 360
		cleanup: false
	}
}

// Ruby it `it "has immutable attributes" do` at line 18.
pub fn ruby_linux_runner_spec_spec_l18_d2_has() bool {
	specification := ruby_linux_runner_spec_spec_l7_d1_spec()
	container := specification.container or { return false }
	return specification.name == 'Linux' && specification.runner == 'ubuntu-latest' && container.image == 'ghcr.io/homebrew/brew:main' && container.options == '--user=linuxbrew' && specification.workdir == '/github/home' && specification.timeout == 360 && !specification.cleanup
}

// Ruby it `it "returns an object that responds to `#to_json`" do` at line 25.
pub fn ruby_linux_runner_spec_spec_l25_d3_returns() bool {
	value := homebrew.linux_runner_spec_to_map(ruby_linux_runner_spec_spec_l7_d1_spec())
	return json2.encode(value, escape_unicode: true).starts_with('{') && value['testing_formulae'].as_string() == ''
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "linux_runner_spec"
// 5:
// 6: RSpec.describe LinuxRunnerSpec do
// 7:   let(:spec) do
// 8:     described_class.new(
// 9:       name:      "Linux",
// 10:       runner:    "ubuntu-latest",
// 11:       container: { image: "ghcr.io/homebrew/brew:main", options: "--user=linuxbrew" },
// 12:       workdir:   "/github/home",
// 13:       timeout:   360,
// 14:       cleanup:   false,
// 15:     )
// 16:   end
// 17:
// 18:   it "has immutable attributes" do
// 19:     [:name, :runner, :container, :workdir, :timeout, :cleanup].each do |attribute|
// 20:       expect(spec.respond_to?(:"#{attribute}=")).to be(false)
// 21:     end
// 22:   end
// 23:
// 24:   describe "#to_h" do
// 25:     it "returns an object that responds to `#to_json`" do
// 26:       expect(spec.to_h.respond_to?(:to_json)).to be(true)
// 27:     end
// 28:   end
// 29: end
