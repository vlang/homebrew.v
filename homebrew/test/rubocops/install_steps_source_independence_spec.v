module rubocops

import homebrew.rubocops as install_source_core

// Translated from Homebrew/brew `test/rubocops/install_steps_source_independence_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "rejects formula source lookups" do` at line 7.
pub fn ruby_install_steps_source_independence_spec_l7_d1_rejects() bool {
	source := 'Formula["foo"]\nFormulary.factory("foo")\nformula_class = Formula'
	return install_source_core.audit_install_steps_source_independence(source).len == 3
}

// Ruby it `it "rejects formula resources" do` at line 18.
pub fn ruby_install_steps_source_independence_spec_l18_d2_rejects() bool {
	source := 'context.resource("setuptools")\nResource.new("pip")'
	return install_source_core.audit_install_steps_source_independence(source).len == 2
}

// Ruby it `it "rejects direct downloads" do` at line 27.
pub fn ruby_install_steps_source_independence_spec_l27_d3_rejects() bool {
	source := 'Utils::Curl.curl_download("https://example.com/input")\nURI.open("https://example.com/input")'
	return install_source_core.audit_install_steps_source_independence(source).len == 2
}

// Ruby it `it "accepts bottled paths and archives" do` at line 41.
pub fn ruby_install_steps_source_independence_spec_l41_d4_accepts() bool {
	source := 'archive = context_path("libexec")/"post-install-resources/input.tar.gz"\nUnpackStrategy.detect(archive).extract(to: temporary_path)\nUtils::Path.formula_opt_bin("glib")/"gio-querymodules"'
	return install_source_core.audit_install_steps_source_independence(source).len == 0
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/install_steps_source_independence"
// 5:
// 6: RSpec.describe RuboCop::Cop::Homebrew::InstallStepsSourceIndependence, :config do
// 7:   it "rejects formula source lookups" do
// 8:     expect_offense <<~RUBY
// 9:       Formula["foo"]
// 10:       ^^^^^^^^^^^^^^ Install-step runners must use bottled files and API context without loading formula source or resources.
// 11:       Formulary.factory("foo")
// 12:       ^^^^^^^^^^^^^^^^^^^^^^^^ Install-step runners must use bottled files and API context without loading formula source or resources.
// 13:       formula_class = Formula
// 14:                       ^^^^^^^ Install-step runners must use bottled files and API context without loading formula source or resources.
// 15:     RUBY
// 16:   end
// 17:
// 18:   it "rejects formula resources" do
// 19:     expect_offense <<~RUBY
// 20:       context.resource("setuptools")
// 21:       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Install-step runners must use bottled files and API context without loading formula source or resources.
// 22:       Resource.new("pip")
// 23:       ^^^^^^^^^^^^^^^^^^^ Install-step runners must use bottled files and API context without loading formula source or resources.
// 24:     RUBY
// 25:   end
// 26:
// 27:   it "rejects direct downloads" do
// 28:     source = 'Utils::Curl.curl_download("https://example.com/input")'
// 29:     expect_offense(<<~RUBY, source:)
// 30:       #{source}
// 31:       ^{source} Install-step runners must use bottled files and API context without loading formula source or resources.
// 32:     RUBY
// 33:
// 34:     source = 'URI.open("https://example.com/input")'
// 35:     expect_offense(<<~RUBY, source:)
// 36:       #{source}
// 37:       ^{source} Install-step runners must use bottled files and API context without loading formula source or resources.
// 38:     RUBY
// 39:   end
// 40:
// 41:   it "accepts bottled paths and archives" do
// 42:     expect_no_offenses <<~RUBY
// 43:       archive = context_path("libexec")/"post-install-resources/input.tar.gz"
// 44:       UnpackStrategy.detect(archive).extract(to: temporary_path)
// 45:       Utils::Path.formula_opt_bin("glib")/"gio-querymodules"
// 46:     RUBY
// 47:   end
// 48: end
