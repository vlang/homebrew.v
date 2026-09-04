module download_strategies

import ruby
import homebrew.download_strategy
import os

// Translated from Homebrew/brew `test/download_strategies/subversion_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:strategy) { described_class.new(url, name, version, **specs) }` at line 8.
pub fn ruby_subversion_spec_l8_d1_strategy(args ...ruby.Value) ruby.Value {
	strategy := subversion_spec_strategy(download_strategy.VCSDownloadMeta{})
	return ruby.structured_value('SubversionDownloadStrategy', strategy.url, {
		'url':             strategy.url
		'cached_location': strategy.cached_location()
	})
}

// Ruby let `let(:name) { "foo" }` at line 10.
pub fn ruby_subversion_spec_l10_d2_name(args ...ruby.Value) ruby.Value {
	return ruby.string_value('foo')
}

// Ruby let `let(:url) { "https://example.com/foo.tar.gz" }` at line 11.
pub fn ruby_subversion_spec_l11_d3_url(args ...ruby.Value) ruby.Value {
	return ruby.string_value('https://example.com/foo.tar.gz')
}

// Ruby let `let(:version) { "1.2.3" }` at line 12.
pub fn ruby_subversion_spec_l12_d4_version(args ...ruby.Value) ruby.Value {
	return ruby.string_value('1.2.3')
}

// Ruby let `let(:specs) { {} }` at line 13.
pub fn ruby_subversion_spec_l13_d5_specs(args ...ruby.Value) ruby.Value {
	return ruby.map_value(map[string]ruby.Value{})
}

// Ruby let `let(:specs) { { trust_cert: true } }` at line 21.
pub fn ruby_subversion_spec_l21_d6_specs(args ...ruby.Value) ruby.Value {
	return ruby.map_value({
		'trust_cert': ruby.bool_value(true)
	})
}

// Ruby it `it "adds the appropriate svn args" do` at line 27.
pub fn ruby_subversion_spec_l27_d7_adds(args ...ruby.Value) ruby.Value {
	strategy := subversion_spec_strategy(download_strategy.VCSDownloadMeta{ trust_cert: true })
	target := os.join_path(os.temp_dir(), 'brew-v-subversion-spec-cert-target')
	arguments := strategy.subversion_fetch_arguments(target, strategy.url, '', false)
	return ruby.bool_value('--trust-server-cert' in arguments && '--non-interactive' in arguments)
}

// Ruby let `let(:specs) { { revision: "10" } }` at line 37.
pub fn ruby_subversion_spec_l37_d8_specs(args ...ruby.Value) ruby.Value {
	return ruby.map_value({
		'revision': ruby.string_value('10')
	})
}

// Ruby it `it "adds svn arguments for :revision" do` at line 39.
pub fn ruby_subversion_spec_l39_d9_adds(args ...ruby.Value) ruby.Value {
	strategy := subversion_spec_strategy(download_strategy.VCSDownloadMeta{ revision: '10' })
	target := os.join_path(os.temp_dir(), 'brew-v-subversion-spec-revision-target')
	arguments := strategy.subversion_fetch_arguments(target, strategy.url, strategy.ref, false)
	index := arguments.index('-r')
	return ruby.bool_value(index >= 0 && index + 1 < arguments.len && arguments[index + 1] == '10')
}

// Ruby let `let(:specs) { { revisions: { trunk: "10", "external" => "11" } } }` at line 49.
pub fn ruby_subversion_spec_l49_d10_specs(args ...ruby.Value) ruby.Value {
	return ruby.map_value({
		'revisions': ruby.map_value({
			'trunk':    ruby.string_value('10')
			'external': ruby.string_value('11')
		})
	})
}

// Ruby it `it "keeps checkout operands after options" do` at line 51.
pub fn ruby_subversion_spec_l51_d11_keeps(args ...ruby.Value) ruby.Value {
	strategy := subversion_spec_strategy(download_strategy.VCSDownloadMeta{
		revisions: {
			'trunk':    '10'
			'external': '11'
		}
	})
	target := os.join_path(os.temp_dir(), 'brew-v-subversion-spec-external-target')
	arguments := strategy.subversion_fetch_arguments(target, '-example', '11', true)
	return ruby.bool_value(arguments == ['checkout', '--quiet', '-r', '11',
		'--ignore-externals', '--', '-example', target])
}

fn subversion_spec_strategy(meta download_strategy.VCSDownloadMeta) download_strategy.VCSDownloadStrategy {
	return download_strategy.new_subversion_download_strategy('https://example.com/foo.tar.gz', 'foo', '1.2.3', meta)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "download_strategy"
// 5: require "utils/svn"
// 6:
// 7: RSpec.describe SubversionDownloadStrategy do
// 8:   subject(:strategy) { described_class.new(url, name, version, **specs) }
// 9:
// 10:   let(:name) { "foo" }
// 11:   let(:url) { "https://example.com/foo.tar.gz" }
// 12:   let(:version) { "1.2.3" }
// 13:   let(:specs) { {} }
// 14:
// 15:   describe "#fetch" do
// 16:     before do
// 17:       allow(strategy).to receive(:repo_url).and_return("#{url}/old")
// 18:     end
// 19:
// 20:     context "with :trust_cert set" do
// 21:       let(:specs) { { trust_cert: true } }
// 22:
// 23:       before do
// 24:         allow(Utils::Svn).to receive(:version).and_return("1.14.5")
// 25:       end
// 26:
// 27:       it "adds the appropriate svn args" do
// 28:         expect(strategy).to receive(:system_command!)
// 29:           .with("svn", hash_including(args: array_including("--trust-server-cert", "--non-interactive")))
// 30:           .and_return(instance_double(SystemCommand::Result))
// 31:
// 32:         strategy.fetch
// 33:       end
// 34:     end
// 35:
// 36:     context "with :revision set" do
// 37:       let(:specs) { { revision: "10" } }
// 38:
// 39:       it "adds svn arguments for :revision" do
// 40:         expect(strategy).to receive(:system_command!)
// 41:           .with("svn", hash_including(args: array_including_cons("-r", "10")))
// 42:           .and_return(instance_double(SystemCommand::Result))
// 43:
// 44:         strategy.fetch
// 45:       end
// 46:     end
// 47:
// 48:     context "with :revisions set" do
// 49:       let(:specs) { { revisions: { trunk: "10", "external" => "11" } } }
// 50:
// 51:       it "keeps checkout operands after options" do
// 52:         external_url = "-example"
// 53:
// 54:         allow(strategy).to receive(:silent_command)
// 55:           .with("svn", args: ["propget", "svn:externals", url])
// 56:           .and_return(instance_double(SystemCommand::Result, stdout: "external #{external_url}\n"))
// 57:
// 58:         expect(strategy).to receive(:system_command!)
// 59:           .with("svn", hash_including(args: ["checkout", "--quiet", "-r", "10", "--ignore-externals", "--", url,
// 60:                                              strategy.cached_location]))
// 61:           .and_return(instance_double(SystemCommand::Result))
// 62:         expect(strategy).to receive(:system_command!)
// 63:           .with("svn", hash_including(args: ["checkout", "--quiet", "-r", "11", "--ignore-externals", "--",
// 64:                                              external_url, strategy.cached_location/"external"]))
// 65:           .and_return(instance_double(SystemCommand::Result))
// 66:
// 67:         strategy.fetch
// 68:       end
// 69:     end
// 70:   end
// 71: end
