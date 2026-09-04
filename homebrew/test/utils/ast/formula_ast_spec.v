module ast

import ruby
import homebrew.utils

const formula_ast_spec_sha = 'f7b1fc772c79c20fddf621ccc791090bc1085fcef4da6cca03399424c66e06ca'

fn formula_ast_value(source string) ruby.Value {
	return utils.ruby_ast_l96_d9_initialize(ruby.string_value(source))
}

fn formula_ast_default_source() string {
	return 'class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n  license all_of: [\n    :public_domain,\n    "MIT",\n    "GPL-3.0-or-later" => { with: "Autoconf-exception-3.0" },\n  ]\nend\n'
}

fn formula_ast_bottle_output() string {
	return '  bottle do\n    sha256 "${formula_ast_spec_sha}" => :sonoma\n  end\n'
}

fn formula_ast_remove_source(license string, middle string) string {
	return 'class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n${license}${middle}end'
}

fn formula_ast_remove_matches(source string, name string, expected string) bool {
	mut formula := utils.FormulaAst{ contents: source }
	utils.ast_formula_remove_stanza(mut formula, name, none)
	return formula.contents == expected
}

fn formula_ast_add_bottle_matches(source string, expected string) bool {
	mut formula := utils.FormulaAst{ contents: source }
	utils.ast_formula_add_bottle(mut formula, formula_ast_bottle_output())
	return formula.contents == expected
}

fn formula_ast_install_source() string {
	return 'class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n\n  def install\n    bin.install "foo"\n  end\nend\n'
}

fn formula_ast_resource_section(name string, sha string) string {
	return 'resource "${name}" do\n  url "https://brew.sh/${name}-1.0.tar.gz"\n  sha256 "${sha}"\nend\n\n'
}

fn formula_ast_method_node(source string) ruby.Value {
	formula := utils.FormulaAst{ contents: source }
	for node in utils.ast_formula_children(formula) {
		if node.kind == 'method_definition' && node.name == 'install' {
			return utils.ast_node_value(node)
		}
	}
	return ruby.object_value('NilClass', 'nil')
}

// Translated from Homebrew/brew `test/utils/ast/formula_ast_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:formula_ast) do` at line 7.
pub fn ruby_formula_ast_spec_l7_d1_formula_ast(args ...ruby.Value) ruby.Value {
	return formula_ast_value(formula_ast_default_source())
}

// Ruby it `it "finds resource block in a formula" do` at line 21.
pub fn ruby_formula_ast_spec_l21_d2_finds(args ...ruby.Value) ruby.Value {
	formula := utils.FormulaAst{ contents: 'class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n\n  resource "foo" do\n    url "https://brew.sh/foo-1.0.tar.gz"\n  end\nend\n' }
	resource := utils.ast_formula_resource(formula, 'foo')
	return ruby.bool_value(resource.children.len > 0 && utils.ast_literal_value(resource.children[0]).as_string() == 'https://brew.sh/foo-1.0.tar.gz')
}

// Ruby it `it "finds resource in `stable` block" do` at line 35.
pub fn ruby_formula_ast_spec_l35_d3_finds(args ...ruby.Value) ruby.Value {
	formula := utils.FormulaAst{ contents: 'class Foo < Formula\n  stable do\n    url "https://brew.sh/foo-1.0.tar.gz"\n\n    resource "foo" do\n      url "https://brew.sh/foo-1.1.tar.gz"\n    end\n  end\n\n  resource "foo" do\n    url "https://brew.sh/foo-1.0.tar.gz"\n  end\nend\n' }
	resource := utils.ast_formula_resource(formula, 'foo')
	return ruby.bool_value(resource.children.len > 0 && utils.ast_literal_value(resource.children[0]).as_string() == 'https://brew.sh/foo-1.1.tar.gz')
}

// Ruby it `it "raises an exception when resource block does not exist" do` at line 55.
pub fn ruby_formula_ast_spec_l55_d4_raises(args ...ruby.Value) ruby.Value {
	formula := utils.FormulaAst{ contents: 'class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\nend\n' }
	resources := utils.ast_formula_stanzas(formula, 'resource', 'block_call')
	return ruby.bool_value(resources.len == 0)
}

// Ruby it `it "replaces the specified stanza in a formula" do` at line 67.
pub fn ruby_formula_ast_spec_l67_d5_replaces(args ...ruby.Value) ruby.Value {
	mut formula := utils.FormulaAst{ contents: formula_ast_default_source() }
	utils.ast_formula_replace_stanza(mut formula, 'license', ruby.object_value('Symbol', ':public_domain'), none)
	expected := 'class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n  license :public_domain\nend\n'
	return ruby.bool_value(formula.contents == expected)
}

// Ruby it `it "adds the specified stanza to a formula" do` at line 79.
pub fn ruby_formula_ast_spec_l79_d6_adds(args ...ruby.Value) ruby.Value {
	mut formula := utils.FormulaAst{ contents: formula_ast_default_source() }
	utils.ast_formula_add_stanza(mut formula, 'revision', ruby.int_value(1), none)
	expected := formula_ast_default_source().replace('\nend\n', '\n  revision 1\nend\n')
	return ruby.bool_value(formula.contents == expected)
}

// Ruby it `it "replaces a stable stanza argument" do` at line 96.
pub fn ruby_formula_ast_spec_l96_d7_replaces(args ...ruby.Value) ruby.Value {
	mut formula := utils.FormulaAst{ contents: formula_ast_default_source() }
	utils.ast_formula_replace_stable_value(mut formula, 'url', ruby.string_value('https://brew.sh/foo-2.0.tar.gz'))
	return ruby.bool_value(formula.contents.contains('url "https://brew.sh/foo-2.0.tar.gz"'))
}

// Ruby subject `subject(:formula_ast) do` at line 113.
pub fn ruby_formula_ast_spec_l113_d8_formula_ast(args ...ruby.Value) ruby.Value {
	return formula_ast_value('class Foo < Formula\n  url "https://brew.sh/foo.git",\n      tag:      "v1.0",\n      revision: "abc123"\nend\n')
}

// Ruby it `it "replaces a stable stanza keyword value" do` at line 123.
pub fn ruby_formula_ast_spec_l123_d9_replaces(args ...ruby.Value) ruby.Value {
	mut formula := utils.FormulaAst{ contents: 'class Foo < Formula\n  url "https://brew.sh/foo.git",\n      tag:      "v1.0",\n      revision: "abc123"\nend\n' }
	utils.ast_formula_replace_stable_hash(mut formula, 'url', 'tag', ruby.string_value('v2.0'))
	utils.ast_formula_replace_stable_hash(mut formula, 'url', 'revision', ruby.string_value('def456'))
	expected := 'class Foo < Formula\n  url "https://brew.sh/foo.git",\n      tag:      "v2.0",\n      revision: "def456"\nend\n'
	return ruby.bool_value(formula.contents == expected)
}

// Ruby it `it "adds multiple stanzas after the specified stanza" do` at line 138.
pub fn ruby_formula_ast_spec_l138_d10_adds(args ...ruby.Value) ruby.Value {
	mut formula := utils.FormulaAst{ contents: formula_ast_default_source() }
	utils.ast_formula_add_stanzas_after(mut formula, 'url', [
		utils.AstStanzaPair{ name: 'mirror', value: ruby.string_value('https://example.com/foo-1.0.tar.gz') },
		utils.AstStanzaPair{ name: 'version', value: ruby.string_value('1.0') },
	], none)
	return ruby.bool_value(formula.contents.contains('url "https://brew.sh/foo-1.0.tar.gz"\n  mirror "https://example.com/foo-1.0.tar.gz"\n  version "1.0"'))
}

// Ruby it `it "adds stanzas after comments following a multi-line stanza" do` at line 155.
pub fn ruby_formula_ast_spec_l155_d11_adds(args ...ruby.Value) ruby.Value {
	mut formula := utils.FormulaAst{ contents: 'class Foo < Formula\n  url "https://brew.sh/foo.git",\n      tag:      "v1.0",\n      revision: "abc"\n  # keep with url\n  license :mit\nend\n' }
	utils.ast_formula_add_stanzas_after(mut formula, 'url', [utils.AstStanzaPair{
		name: 'version'
		value: ruby.string_value('1.0')
	}], none)
	return ruby.bool_value(formula.contents.contains('# keep with url\n  version "1.0"\n  license :mit'))
}

// Ruby subject `subject(:formula_ast) do` at line 182.
pub fn ruby_formula_ast_spec_l182_d12_formula_ast(args ...ruby.Value) ruby.Value {
	return formula_ast_value('class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n\n  resource "bar" do\n    url "https://brew.sh/bar-1.0.tar.gz"\n    mirror "https://example.com/bar-1.0.tar.gz"\n    sha256 "${'e'.repeat(64)}"\n  end\nend\n')
}

// Ruby it `it "replaces resource stanza arguments" do` at line 196.
pub fn ruby_formula_ast_spec_l196_d13_replaces(args ...ruby.Value) ruby.Value {
	mut formula := utils.FormulaAst{ contents: 'class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n\n  resource "bar" do\n    url "https://brew.sh/bar-1.0.tar.gz"\n    mirror "https://example.com/bar-1.0.tar.gz"\n    sha256 "${'e'.repeat(64)}"\n  end\nend\n' }
	utils.ast_formula_replace_resource_value(mut formula, 'bar', 'url', ruby.string_value('https://brew.sh/bar-2.0.tar.gz'), none)
	utils.ast_formula_replace_resource_value(mut formula, 'bar', 'mirror', ruby.string_value('https://example.com/bar-2.0.tar.gz'), none)
	utils.ast_formula_replace_resource_value(mut formula, 'bar', 'sha256', ruby.string_value('f'.repeat(64)), none)
	parent := utils.ast_formula_resource(formula, 'bar')
	utils.ast_formula_add_stanzas_after(mut formula, 'sha256', [utils.AstStanzaPair{
		name: 'version'
		value: ruby.string_value('2.0')
	}], parent)
	return ruby.bool_value(formula.contents.contains('url "https://brew.sh/bar-2.0.tar.gz"\n    mirror "https://example.com/bar-2.0.tar.gz"\n    sha256 "${'f'.repeat(64)}"\n    version "2.0"'))
}

// Ruby it `it "inserts resource stanzas before the install method" do` at line 218.
pub fn ruby_formula_ast_spec_l218_d14_inserts(args ...ruby.Value) ruby.Value {
	mut formula := utils.FormulaAst{ contents: formula_ast_install_source() }
	_ = utils.ast_formula_replace_resources(mut formula, formula_ast_resource_section('bar', 'e'.repeat(64)), true, false)
	return ruby.bool_value(formula.contents.contains('  resource "bar" do') && formula.contents.index('resource "bar"') or { 9999 } < formula.contents.index('def install') or { 0 })
}

// Ruby method `install` at line 223.
pub fn ruby_formula_ast_spec_l223_d15_install(args ...ruby.Value) ruby.Value {
	return formula_ast_method_node(formula_ast_install_source())
}

// Ruby method `install` at line 246.
pub fn ruby_formula_ast_spec_l246_d16_install(args ...ruby.Value) ruby.Value {
	mut formula := utils.FormulaAst{ contents: formula_ast_install_source() }
	_ = utils.ast_formula_replace_resources(mut formula, formula_ast_resource_section('bar', 'e'.repeat(64)), true, false)
	return formula_ast_method_node(formula.contents)
}

// Ruby subject `subject(:formula_ast) do` at line 254.
pub fn ruby_formula_ast_spec_l254_d17_formula_ast(args ...ruby.Value) ruby.Value {
	return formula_ast_value('class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n\n  # RESOURCE-ERROR: Unable to resolve "baz"\n  resource "bar" do\n    url "https://brew.sh/bar-1.0.tar.gz"\n    sha256 "${'e'.repeat(64)}"\n  end\n\n  def install\n    bin.install "foo"\n  end\nend\n')
}

// Ruby method `install` at line 265.
pub fn ruby_formula_ast_spec_l265_d18_install(args ...ruby.Value) ruby.Value {
	return formula_ast_method_node('class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n\n  # RESOURCE-ERROR: Unable to resolve "baz"\n  resource "bar" do\n    url "https://brew.sh/bar-1.0.tar.gz"\n    sha256 "${'e'.repeat(64)}"\n  end\n\n  def install\n    bin.install "foo"\n  end\nend\n')
}

// Ruby it `it "replaces the existing resource stanza group" do` at line 272.
pub fn ruby_formula_ast_spec_l272_d19_replaces(args ...ruby.Value) ruby.Value {
	mut formula := utils.FormulaAst{ contents: 'class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n\n  # RESOURCE-ERROR: Unable to resolve "baz"\n  resource "bar" do\n    url "https://brew.sh/bar-1.0.tar.gz"\n    sha256 "${'e'.repeat(64)}"\n  end\n\n  def install\n    bin.install "foo"\n  end\nend\n' }
	_ = utils.ast_formula_replace_resources(mut formula, formula_ast_resource_section('baz', 'f'.repeat(64)), true, false)
	return ruby.bool_value(!formula.contents.contains('RESOURCE-ERROR') && formula.contents.contains('resource "baz"'))
}

// Ruby method `install` at line 290.
pub fn ruby_formula_ast_spec_l290_d20_install(args ...ruby.Value) ruby.Value {
	return formula_ast_method_node(formula_ast_install_source())
}

// Ruby subject `subject(:formula_ast) do` at line 299.
pub fn ruby_formula_ast_spec_l299_d21_formula_ast(args ...ruby.Value) ruby.Value {
	return formula_ast_value('class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n\n  resource "bar" do\n    url "https://brew.sh/bar-1.0.tar.gz"\n    sha256 "${'e'.repeat(64)}"\n  end\n\n  depends_on "pkg-config" => :build\n\n  resource "baz" do\n    url "https://brew.sh/baz-1.0.tar.gz"\n    sha256 "${'f'.repeat(64)}"\n  end\nend\n')
}

// Ruby it `it "returns :multiple_groups" do` at line 319.
pub fn ruby_formula_ast_spec_l319_d22_returns(args ...ruby.Value) ruby.Value {
	mut formula := utils.FormulaAst{ contents: 'class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n\n  resource "bar" do\n    url "https://brew.sh/bar-1.0.tar.gz"\n  end\n\n  depends_on "pkg-config" => :build\n\n  resource "baz" do\n    url "https://brew.sh/baz-1.0.tar.gz"\n  end\nend\n' }
	result := utils.ast_formula_replace_resources(mut formula, '', true, false) or { '' }
	return ruby.bool_value(result == 'multiple_groups')
}

// Ruby subject `subject(:formula_ast) do` at line 327.
pub fn ruby_formula_ast_spec_l327_d23_formula_ast(args ...ruby.Value) ruby.Value {
	return formula_ast_value('class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n  license :cannot_represent\n\n  bottle do\n    sha256 "${formula_ast_spec_sha}" => :sonoma\n  end\nend')
}

// Ruby let `let(:new_contents) do` at line 340.
pub fn ruby_formula_ast_spec_l340_d24_new_contents(args ...ruby.Value) ruby.Value {
	return ruby.string_value('class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n\n  bottle do\n    sha256 "${formula_ast_spec_sha}" => :sonoma\n  end\nend')
}

// Ruby it `it "removes the line containing the stanza" do` at line 352.
pub fn ruby_formula_ast_spec_l352_d25_removes(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(formula_ast_remove_matches('class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n  license :cannot_represent\n\n  bottle do\n    sha256 "${formula_ast_spec_sha}" => :sonoma\n  end\nend', 'license', 'class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n\n  bottle do\n    sha256 "${formula_ast_spec_sha}" => :sonoma\n  end\nend'))
}

// Ruby subject `subject(:formula_ast) do` at line 359.
pub fn ruby_formula_ast_spec_l359_d26_formula_ast(args ...ruby.Value) ruby.Value {
	return formula_ast_value('class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n  license all_of: [\n    :public_domain,\n    "MIT",\n    "GPL-3.0-or-later" => { with: "Autoconf-exception-3.0" },\n  ]\n\n  bottle do\n    sha256 "${formula_ast_spec_sha}" => :sonoma\n  end\nend')
}

// Ruby let `let(:new_contents) do` at line 376.
pub fn ruby_formula_ast_spec_l376_d27_new_contents(args ...ruby.Value) ruby.Value {
	return ruby_formula_ast_spec_l340_d24_new_contents()
}

// Ruby it `it "removes the lines containing the stanza" do` at line 388.
pub fn ruby_formula_ast_spec_l388_d28_removes(args ...ruby.Value) ruby.Value {
	source := 'class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n  license all_of: [\n    :public_domain,\n    "MIT",\n    "GPL-3.0-or-later" => { with: "Autoconf-exception-3.0" },\n  ]\n\n  bottle do\n    sha256 "${formula_ast_spec_sha}" => :sonoma\n  end\nend'
	return ruby.bool_value(formula_ast_remove_matches(source, 'license', ruby_formula_ast_spec_l340_d24_new_contents().as_string()))
}

// Ruby subject `subject(:formula_ast) do` at line 395.
pub fn ruby_formula_ast_spec_l395_d29_formula_ast(args ...ruby.Value) ruby.Value {
	return formula_ast_value('class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n  license :cannot_represent # comment\n\n  bottle do\n    sha256 "${formula_ast_spec_sha}" => :sonoma\n  end\nend')
}

// Ruby let `let(:new_contents) do` at line 408.
pub fn ruby_formula_ast_spec_l408_d30_new_contents(args ...ruby.Value) ruby.Value {
	return ruby.string_value('class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n   # comment\n\n  bottle do\n    sha256 "${formula_ast_spec_sha}" => :sonoma\n  end\nend')
}

// Ruby it `it "removes the stanza but keeps the comment and its whitespace" do` at line 421.
pub fn ruby_formula_ast_spec_l421_d31_removes(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(formula_ast_remove_matches('class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n  license :cannot_represent # comment\n\n  bottle do\n    sha256 "${formula_ast_spec_sha}" => :sonoma\n  end\nend', 'license', ruby_formula_ast_spec_l408_d30_new_contents().as_string()))
}

// Ruby subject `subject(:formula_ast) do` at line 428.
pub fn ruby_formula_ast_spec_l428_d32_formula_ast(args ...ruby.Value) ruby.Value {
	return formula_ast_value('class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n  license :cannot_represent\n  # comment\n\n  bottle do\n    sha256 "${formula_ast_spec_sha}" => :sonoma\n  end\nend')
}

// Ruby let `let(:new_contents) do` at line 442.
pub fn ruby_formula_ast_spec_l442_d33_new_contents(args ...ruby.Value) ruby.Value {
	return ruby.string_value('class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n  # comment\n\n  bottle do\n    sha256 "${formula_ast_spec_sha}" => :sonoma\n  end\nend')
}

// Ruby it `it "removes the stanza but keeps the comment" do` at line 455.
pub fn ruby_formula_ast_spec_l455_d34_removes(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(formula_ast_remove_matches('class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n  license :cannot_represent\n  # comment\n\n  bottle do\n    sha256 "${formula_ast_spec_sha}" => :sonoma\n  end\nend', 'license', ruby_formula_ast_spec_l442_d33_new_contents().as_string()))
}

// Ruby subject `subject(:formula_ast) do` at line 462.
pub fn ruby_formula_ast_spec_l462_d35_formula_ast(args ...ruby.Value) ruby.Value {
	return formula_ast_value('class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n\n  bottle do\n    sha256 "${formula_ast_spec_sha}" => :sonoma\n  end\n\n  head do\n    url "https://brew.sh/foo.git"\n    branch "develop"\n  end\nend')
}

// Ruby let `let(:new_contents) do` at line 479.
pub fn ruby_formula_ast_spec_l479_d36_new_contents(args ...ruby.Value) ruby.Value {
	return ruby.string_value('class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n\n  head do\n    url "https://brew.sh/foo.git"\n    branch "develop"\n  end\nend')
}

// Ruby it `it "removes the stanza and preceding newline" do` at line 492.
pub fn ruby_formula_ast_spec_l492_d37_removes(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(formula_ast_remove_matches(ruby_formula_ast_spec_l462_d35_formula_ast().repr, 'bottle', ruby_formula_ast_spec_l479_d36_new_contents().as_string()))
}

// Ruby subject `subject(:formula_ast) do` at line 499.
pub fn ruby_formula_ast_spec_l499_d38_formula_ast(args ...ruby.Value) ruby.Value {
	return formula_ast_value('class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n  license :cannot_represent\n\n  bottle do\n    sha256 "${formula_ast_spec_sha}" => :sonoma\n  end\nend')
}

// Ruby let `let(:new_contents) do` at line 512.
pub fn ruby_formula_ast_spec_l512_d39_new_contents(args ...ruby.Value) ruby.Value {
	return ruby.string_value('class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n  license :cannot_represent\nend')
}

// Ruby it `it "removes the stanza and preceding newline" do` at line 521.
pub fn ruby_formula_ast_spec_l521_d40_removes(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(formula_ast_remove_matches(ruby_formula_ast_spec_l499_d38_formula_ast().repr, 'bottle', ruby_formula_ast_spec_l512_d39_new_contents().as_string()))
}

// Ruby let `let(:bottle_output) do` at line 529.
pub fn ruby_formula_ast_spec_l529_d41_bottle_output(args ...ruby.Value) ruby.Value {
	return ruby.string_value(formula_ast_bottle_output())
}

// Ruby subject `subject(:formula_ast) do` at line 538.
pub fn ruby_formula_ast_spec_l538_d42_formula_ast(args ...ruby.Value) ruby.Value {
	return formula_ast_value('class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n  license "MIT"\nend')
}

// Ruby let `let(:new_contents) do` at line 547.
pub fn ruby_formula_ast_spec_l547_d43_new_contents(args ...ruby.Value) ruby.Value {
	return ruby.string_value('class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n  license "MIT"\n\n  bottle do\n    sha256 "${formula_ast_spec_sha}" => :sonoma\n  end\nend')
}

// Ruby it `it "adds `bottle` after `license`" do` at line 560.
pub fn ruby_formula_ast_spec_l560_d44_adds(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(formula_ast_add_bottle_matches(ruby_formula_ast_spec_l538_d42_formula_ast().repr, ruby_formula_ast_spec_l547_d43_new_contents().as_string()))
}

// Ruby subject `subject(:formula_ast) do` at line 567.
pub fn ruby_formula_ast_spec_l567_d45_formula_ast(args ...ruby.Value) ruby.Value {
	return formula_ast_value('class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n  license :cannot_represent\nend')
}

// Ruby let `let(:new_contents) do` at line 576.
pub fn ruby_formula_ast_spec_l576_d46_new_contents(args ...ruby.Value) ruby.Value {
	return ruby.string_value('class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n  license :cannot_represent\n\n  bottle do\n    sha256 "${formula_ast_spec_sha}" => :sonoma\n  end\nend')
}

// Ruby it `it "adds `bottle` after `license`" do` at line 589.
pub fn ruby_formula_ast_spec_l589_d47_adds(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(formula_ast_add_bottle_matches(ruby_formula_ast_spec_l567_d45_formula_ast().repr, ruby_formula_ast_spec_l576_d46_new_contents().as_string()))
}

// Ruby subject `subject(:formula_ast) do` at line 596.
pub fn ruby_formula_ast_spec_l596_d48_formula_ast(args ...ruby.Value) ruby.Value {
	return formula_ast_value('class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n  license all_of: [\n    :public_domain,\n    "MIT",\n    "GPL-3.0-or-later" => { with: "Autoconf-exception-3.0" },\n  ]\nend')
}

// Ruby let `let(:new_contents) do` at line 609.
pub fn ruby_formula_ast_spec_l609_d49_new_contents(args ...ruby.Value) ruby.Value {
	return ruby.string_value('class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n  license all_of: [\n    :public_domain,\n    "MIT",\n    "GPL-3.0-or-later" => { with: "Autoconf-exception-3.0" },\n  ]\n\n  bottle do\n    sha256 "${formula_ast_spec_sha}" => :sonoma\n  end\nend')
}

// Ruby it `it "adds `bottle` after `license`" do` at line 626.
pub fn ruby_formula_ast_spec_l626_d50_adds(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(formula_ast_add_bottle_matches(ruby_formula_ast_spec_l596_d48_formula_ast().repr, ruby_formula_ast_spec_l609_d49_new_contents().as_string()))
}

// Ruby subject `subject(:formula_ast) do` at line 633.
pub fn ruby_formula_ast_spec_l633_d51_formula_ast(args ...ruby.Value) ruby.Value {
	return formula_ast_value('class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n  head "https://brew.sh/foo.git", branch: "develop"\nend')
}

// Ruby let `let(:new_contents) do` at line 642.
pub fn ruby_formula_ast_spec_l642_d52_new_contents(args ...ruby.Value) ruby.Value {
	return ruby.string_value('class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n  head "https://brew.sh/foo.git", branch: "develop"\n\n  bottle do\n    sha256 "${formula_ast_spec_sha}" => :sonoma\n  end\nend')
}

// Ruby it `it "adds `bottle` after `head`" do` at line 655.
pub fn ruby_formula_ast_spec_l655_d53_adds(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(formula_ast_add_bottle_matches(ruby_formula_ast_spec_l633_d51_formula_ast().repr, ruby_formula_ast_spec_l642_d52_new_contents().as_string()))
}

// Ruby subject `subject(:formula_ast) do` at line 662.
pub fn ruby_formula_ast_spec_l662_d54_formula_ast(args ...ruby.Value) ruby.Value {
	return formula_ast_value('class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n\n  head do\n    url "https://brew.sh/foo.git"\n    branch "develop"\n  end\nend')
}

// Ruby let `let(:new_contents) do` at line 675.
pub fn ruby_formula_ast_spec_l675_d55_new_contents(args ...ruby.Value) ruby.Value {
	return ruby.string_value('class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n\n  bottle do\n    sha256 "${formula_ast_spec_sha}" => :sonoma\n  end\n\n  head do\n    url "https://brew.sh/foo.git"\n    branch "develop"\n  end\nend')
}

// Ruby it `it "adds `bottle` before `head`" do` at line 692.
pub fn ruby_formula_ast_spec_l692_d56_adds(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(formula_ast_add_bottle_matches(ruby_formula_ast_spec_l662_d54_formula_ast().repr, ruby_formula_ast_spec_l675_d55_new_contents().as_string()))
}

// Ruby subject `subject(:formula_ast) do` at line 699.
pub fn ruby_formula_ast_spec_l699_d57_formula_ast(args ...ruby.Value) ruby.Value {
	return formula_ast_value('class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz" # comment\nend')
}

// Ruby let `let(:new_contents) do` at line 707.
pub fn ruby_formula_ast_spec_l707_d58_new_contents(args ...ruby.Value) ruby.Value {
	return ruby.string_value('class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz" # comment\n\n  bottle do\n    sha256 "${formula_ast_spec_sha}" => :sonoma\n  end\nend')
}

// Ruby it `it "adds `bottle` after the comment" do` at line 719.
pub fn ruby_formula_ast_spec_l719_d59_adds(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(formula_ast_add_bottle_matches(ruby_formula_ast_spec_l699_d57_formula_ast().repr, ruby_formula_ast_spec_l707_d58_new_contents().as_string()))
}

// Ruby subject `subject(:formula_ast) do` at line 726.
pub fn ruby_formula_ast_spec_l726_d60_formula_ast(args ...ruby.Value) ruby.Value {
	return formula_ast_value('class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n  # comment\nend')
}

// Ruby let `let(:new_contents) do` at line 735.
pub fn ruby_formula_ast_spec_l735_d61_new_contents(args ...ruby.Value) ruby.Value {
	return ruby.string_value('class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n  # comment\n\n  bottle do\n    sha256 "${formula_ast_spec_sha}" => :sonoma\n  end\nend')
}

// Ruby it `it "adds `bottle` after the comment" do` at line 748.
pub fn ruby_formula_ast_spec_l748_d62_adds(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(formula_ast_add_bottle_matches(ruby_formula_ast_spec_l726_d60_formula_ast().repr, ruby_formula_ast_spec_l735_d61_new_contents().as_string()))
}

// Ruby subject `subject(:formula_ast) do` at line 755.
pub fn ruby_formula_ast_spec_l755_d63_formula_ast(args ...ruby.Value) ruby.Value {
	return formula_ast_value('class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n\n  # comment\nend')
}

// Ruby let `let(:new_contents) do` at line 765.
pub fn ruby_formula_ast_spec_l765_d64_new_contents(args ...ruby.Value) ruby.Value {
	return ruby.string_value('class Foo < Formula\n  url "https://brew.sh/foo-1.0.tar.gz"\n\n  bottle do\n    sha256 "${formula_ast_spec_sha}" => :sonoma\n  end\n\n  # comment\nend')
}

// Ruby it `it "adds `bottle` before the comment" do` at line 779.
pub fn ruby_formula_ast_spec_l779_d65_adds(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(formula_ast_add_bottle_matches(ruby_formula_ast_spec_l755_d63_formula_ast().repr, ruby_formula_ast_spec_l765_d64_new_contents().as_string()))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/ast"
// 5:
// 6: RSpec.describe Utils::AST::FormulaAST do
// 7:   subject(:formula_ast) do
// 8:     described_class.new <<~RUBY
// 9:       class Foo < Formula
// 10:         url "https://brew.sh/foo-1.0.tar.gz"
// 11:         license all_of: [
// 12:           :public_domain,
// 13:           "MIT",
// 14:           "GPL-3.0-or-later" => { with: "Autoconf-exception-3.0" },
// 15:         ]
// 16:       end
// 17:     RUBY
// 18:   end
// 19:
// 20:   describe "#resource" do
// 21:     it "finds resource block in a formula" do
// 22:       formula_ast = described_class.new <<~RUBY
// 23:         class Foo < Formula
// 24:           url "https://brew.sh/foo-1.0.tar.gz"
// 25:
// 26:           resource "foo" do
// 27:             url "https://brew.sh/foo-1.0.tar.gz"
// 28:           end
// 29:         end
// 30:       RUBY
// 31:
// 32:       expect(formula_ast.resource("foo").children[2].children[2].value).to eq("https://brew.sh/foo-1.0.tar.gz")
// 33:     end
// 34:
// 35:     it "finds resource in `stable` block" do
// 36:       formula_ast = described_class.new <<~RUBY
// 37:         class Foo < Formula
// 38:           stable do
// 39:             url "https://brew.sh/foo-1.0.tar.gz"
// 40:
// 41:             resource "foo" do
// 42:               url "https://brew.sh/foo-1.1.tar.gz"
// 43:             end
// 44:           end
// 45:
// 46:           resource "foo" do
// 47:             url "https://brew.sh/foo-1.0.tar.gz"
// 48:           end
// 49:         end
// 50:       RUBY
// 51:
// 52:       expect(formula_ast.resource("foo").children[2].children[2].value).to eq("https://brew.sh/foo-1.1.tar.gz")
// 53:     end
// 54:
// 55:     it "raises an exception when resource block does not exist" do
// 56:       formula_ast = described_class.new <<~RUBY
// 57:         class Foo < Formula
// 58:           url "https://brew.sh/foo-1.0.tar.gz"
// 59:         end
// 60:       RUBY
// 61:
// 62:       expect { formula_ast.resource("foo") }.to raise_error("Could not find resource 'foo' block!")
// 63:     end
// 64:   end
// 65:
// 66:   describe "#replace_stanza" do
// 67:     it "replaces the specified stanza in a formula" do
// 68:       formula_ast.replace_stanza(:license, :public_domain)
// 69:       expect(formula_ast.process).to eq <<~RUBY
// 70:         class Foo < Formula
// 71:           url "https://brew.sh/foo-1.0.tar.gz"
// 72:           license :public_domain
// 73:         end
// 74:       RUBY
// 75:     end
// 76:   end
// 77:
// 78:   describe "#add_stanza" do
// 79:     it "adds the specified stanza to a formula" do
// 80:       formula_ast.add_stanza(:revision, 1)
// 81:       expect(formula_ast.process).to eq <<~RUBY
// 82:         class Foo < Formula
// 83:           url "https://brew.sh/foo-1.0.tar.gz"
// 84:           license all_of: [
// 85:             :public_domain,
// 86:             "MIT",
// 87:             "GPL-3.0-or-later" => { with: "Autoconf-exception-3.0" },
// 88:           ]
// 89:           revision 1
// 90:         end
// 91:       RUBY
// 92:     end
// 93:   end
// 94:
// 95:   describe "#replace_stable_stanza_value" do
// 96:     it "replaces a stable stanza argument" do
// 97:       formula_ast.replace_stable_stanza_value(:url, "https://brew.sh/foo-2.0.tar.gz")
// 98:
// 99:       expect(formula_ast.process).to eq <<~RUBY
// 100:         class Foo < Formula
// 101:           url "https://brew.sh/foo-2.0.tar.gz"
// 102:           license all_of: [
// 103:             :public_domain,
// 104:             "MIT",
// 105:             "GPL-3.0-or-later" => { with: "Autoconf-exception-3.0" },
// 106:           ]
// 107:         end
// 108:       RUBY
// 109:     end
// 110:   end
// 111:
// 112:   describe "#replace_stable_stanza_hash_value" do
// 113:     subject(:formula_ast) do
// 114:       described_class.new <<~RUBY
// 115:         class Foo < Formula
// 116:           url "https://brew.sh/foo.git",
// 117:               tag:      "v1.0",
// 118:               revision: "abc123"
// 119:         end
// 120:       RUBY
// 121:     end
// 122:
// 123:     it "replaces a stable stanza keyword value" do
// 124:       formula_ast.replace_stable_stanza_hash_value(:url, :tag, "v2.0")
// 125:       formula_ast.replace_stable_stanza_hash_value(:url, :revision, "def456")
// 126:
// 127:       expect(formula_ast.process).to eq <<~RUBY
// 128:         class Foo < Formula
// 129:           url "https://brew.sh/foo.git",
// 130:               tag:      "v2.0",
// 131:               revision: "def456"
// 132:         end
// 133:       RUBY
// 134:     end
// 135:   end
// 136:
// 137:   describe "#add_stanzas_after" do
// 138:     it "adds multiple stanzas after the specified stanza" do
// 139:       formula_ast.add_stanzas_after(:url, [[:mirror, "https://example.com/foo-1.0.tar.gz"], [:version, "1.0"]])
// 140:
// 141:       expect(formula_ast.process).to eq <<~RUBY
// 142:         class Foo < Formula
// 143:           url "https://brew.sh/foo-1.0.tar.gz"
// 144:           mirror "https://example.com/foo-1.0.tar.gz"
// 145:           version "1.0"
// 146:           license all_of: [
// 147:             :public_domain,
// 148:             "MIT",
// 149:             "GPL-3.0-or-later" => { with: "Autoconf-exception-3.0" },
// 150:           ]
// 151:         end
// 152:       RUBY
// 153:     end
// 154:
// 155:     it "adds stanzas after comments following a multi-line stanza" do
// 156:       formula_ast = described_class.new <<~RUBY
// 157:         class Foo < Formula
// 158:           url "https://brew.sh/foo.git",
// 159:               tag:      "v1.0",
// 160:               revision: "abc"
// 161:           # keep with url
// 162:           license :mit
// 163:         end
// 164:       RUBY
// 165:
// 166:       formula_ast.add_stanzas_after(:url, [[:version, "1.0"]])
// 167:
// 168:       expect(formula_ast.process).to eq <<~RUBY
// 169:         class Foo < Formula
// 170:           url "https://brew.sh/foo.git",
// 171:               tag:      "v1.0",
// 172:               revision: "abc"
// 173:           # keep with url
// 174:           version "1.0"
// 175:           license :mit
// 176:         end
// 177:       RUBY
// 178:     end
// 179:   end
// 180:
// 181:   describe "#replace_resource_stanza_value" do
// 182:     subject(:formula_ast) do
// 183:       described_class.new <<~RUBY
// 184:         class Foo < Formula
// 185:           url "https://brew.sh/foo-1.0.tar.gz"
// 186:
// 187:           resource "bar" do
// 188:             url "https://brew.sh/bar-1.0.tar.gz"
// 189:             mirror "https://example.com/bar-1.0.tar.gz"
// 190:             sha256 "#{"e" * 64}"
// 191:           end
// 192:         end
// 193:       RUBY
// 194:     end
// 195:
// 196:     it "replaces resource stanza arguments" do
// 197:       formula_ast.replace_resource_stanza_value("bar", :url, "https://brew.sh/bar-2.0.tar.gz")
// 198:       formula_ast.replace_resource_stanza_value("bar", :mirror, "https://example.com/bar-2.0.tar.gz")
// 199:       formula_ast.replace_resource_stanza_value("bar", :sha256, "f" * 64)
// 200:       formula_ast.add_stanzas_after(:sha256, [[:version, "2.0"]], parent: formula_ast.resource("bar"))
// 201:
// 202:       expect(formula_ast.process).to eq <<~RUBY
// 203:         class Foo < Formula
// 204:           url "https://brew.sh/foo-1.0.tar.gz"
// 205:
// 206:           resource "bar" do
// 207:             url "https://brew.sh/bar-2.0.tar.gz"
// 208:             mirror "https://example.com/bar-2.0.tar.gz"
// 209:             sha256 "#{"f" * 64}"
// 210:             version "2.0"
// 211:           end
// 212:         end
// 213:       RUBY
// 214:     end
// 215:   end
// 216:
// 217:   describe "#replace_resource_stanzas" do
// 218:     it "inserts resource stanzas before the install method" do
// 219:       formula_ast = described_class.new <<~RUBY
// 220:         class Foo < Formula
// 221:           url "https://brew.sh/foo-1.0.tar.gz"
// 222:
// 223:           def install
// 224:             bin.install "foo"
// 225:           end
// 226:         end
// 227:       RUBY
// 228:
// 229:       formula_ast.replace_resource_stanzas <<~RUBY
// 230:         resource "bar" do
// 231:           url "https://brew.sh/bar-1.0.tar.gz"
// 232:           sha256 "#{"e" * 64}"
// 233:         end
// 234:
// 235:       RUBY
// 236:
// 237:       expect(formula_ast.process).to eq <<~RUBY
// 238:         class Foo < Formula
// 239:           url "https://brew.sh/foo-1.0.tar.gz"
// 240:
// 241:           resource "bar" do
// 242:             url "https://brew.sh/bar-1.0.tar.gz"
// 243:             sha256 "#{"e" * 64}"
// 244:           end
// 245:
// 246:           def install
// 247:             bin.install "foo"
// 248:           end
// 249:         end
// 250:       RUBY
// 251:     end
// 252:
// 253:     context "when resource stanzas already exist" do
// 254:       subject(:formula_ast) do
// 255:         described_class.new <<~RUBY
// 256:           class Foo < Formula
// 257:             url "https://brew.sh/foo-1.0.tar.gz"
// 258:
// 259:             # RESOURCE-ERROR: Unable to resolve "baz"
// 260:             resource "bar" do
// 261:               url "https://brew.sh/bar-1.0.tar.gz"
// 262:               sha256 "#{"e" * 64}"
// 263:             end
// 264:
// 265:             def install
// 266:               bin.install "foo"
// 267:             end
// 268:           end
// 269:         RUBY
// 270:       end
// 271:
// 272:       it "replaces the existing resource stanza group" do
// 273:         formula_ast.replace_resource_stanzas <<~RUBY
// 274:           resource "baz" do
// 275:             url "https://brew.sh/baz-1.0.tar.gz"
// 276:             sha256 "#{"f" * 64}"
// 277:           end
// 278:
// 279:         RUBY
// 280:
// 281:         expect(formula_ast.process).to eq <<~RUBY
// 282:           class Foo < Formula
// 283:             url "https://brew.sh/foo-1.0.tar.gz"
// 284:
// 285:             resource "baz" do
// 286:               url "https://brew.sh/baz-1.0.tar.gz"
// 287:               sha256 "#{"f" * 64}"
// 288:             end
// 289:
// 290:             def install
// 291:               bin.install "foo"
// 292:             end
// 293:           end
// 294:         RUBY
// 295:       end
// 296:     end
// 297:
// 298:     context "when resource stanzas are split into multiple groups" do
// 299:       subject(:formula_ast) do
// 300:         described_class.new <<~RUBY
// 301:           class Foo < Formula
// 302:             url "https://brew.sh/foo-1.0.tar.gz"
// 303:
// 304:             resource "bar" do
// 305:               url "https://brew.sh/bar-1.0.tar.gz"
// 306:               sha256 "#{"e" * 64}"
// 307:             end
// 308:
// 309:             depends_on "pkg-config" => :build
// 310:
// 311:             resource "baz" do
// 312:               url "https://brew.sh/baz-1.0.tar.gz"
// 313:               sha256 "#{"f" * 64}"
// 314:             end
// 315:           end
// 316:         RUBY
// 317:       end
// 318:
// 319:       it "returns :multiple_groups" do
// 320:         expect(formula_ast.replace_resource_stanzas("")).to be(:multiple_groups)
// 321:       end
// 322:     end
// 323:   end
// 324:
// 325:   describe "#remove_stanza" do
// 326:     context "when stanza to be removed is a single line followed by a blank line" do
// 327:       subject(:formula_ast) do
// 328:         described_class.new <<~RUBY.chomp
// 329:           class Foo < Formula
// 330:             url "https://brew.sh/foo-1.0.tar.gz"
// 331:             license :cannot_represent
// 332:
// 333:             bottle do
// 334:               sha256 "f7b1fc772c79c20fddf621ccc791090bc1085fcef4da6cca03399424c66e06ca" => :sonoma
// 335:             end
// 336:           end
// 337:         RUBY
// 338:       end
// 339:
// 340:       let(:new_contents) do
// 341:         <<~RUBY.chomp
// 342:           class Foo < Formula
// 343:             url "https://brew.sh/foo-1.0.tar.gz"
// 344:
// 345:             bottle do
// 346:               sha256 "f7b1fc772c79c20fddf621ccc791090bc1085fcef4da6cca03399424c66e06ca" => :sonoma
// 347:             end
// 348:           end
// 349:         RUBY
// 350:       end
// 351:
// 352:       it "removes the line containing the stanza" do
// 353:         formula_ast.remove_stanza(:license)
// 354:         expect(formula_ast.process).to eq(new_contents)
// 355:       end
// 356:     end
// 357:
// 358:     context "when stanza to be removed is a multiline block followed by a blank line" do
// 359:       subject(:formula_ast) do
// 360:         described_class.new <<~RUBY.chomp
// 361:           class Foo < Formula
// 362:             url "https://brew.sh/foo-1.0.tar.gz"
// 363:             license all_of: [
// 364:               :public_domain,
// 365:               "MIT",
// 366:               "GPL-3.0-or-later" => { with: "Autoconf-exception-3.0" },
// 367:             ]
// 368:
// 369:             bottle do
// 370:               sha256 "f7b1fc772c79c20fddf621ccc791090bc1085fcef4da6cca03399424c66e06ca" => :sonoma
// 371:             end
// 372:           end
// 373:         RUBY
// 374:       end
// 375:
// 376:       let(:new_contents) do
// 377:         <<~RUBY.chomp
// 378:           class Foo < Formula
// 379:             url "https://brew.sh/foo-1.0.tar.gz"
// 380:
// 381:             bottle do
// 382:               sha256 "f7b1fc772c79c20fddf621ccc791090bc1085fcef4da6cca03399424c66e06ca" => :sonoma
// 383:             end
// 384:           end
// 385:         RUBY
// 386:       end
// 387:
// 388:       it "removes the lines containing the stanza" do
// 389:         formula_ast.remove_stanza(:license)
// 390:         expect(formula_ast.process).to eq(new_contents)
// 391:       end
// 392:     end
// 393:
// 394:     context "when stanza to be removed has a comment on the same line" do
// 395:       subject(:formula_ast) do
// 396:         described_class.new <<~RUBY.chomp
// 397:           class Foo < Formula
// 398:             url "https://brew.sh/foo-1.0.tar.gz"
// 399:             license :cannot_represent # comment
// 400:
// 401:             bottle do
// 402:               sha256 "f7b1fc772c79c20fddf621ccc791090bc1085fcef4da6cca03399424c66e06ca" => :sonoma
// 403:             end
// 404:           end
// 405:         RUBY
// 406:       end
// 407:
// 408:       let(:new_contents) do
// 409:         <<~RUBY.chomp
// 410:           class Foo < Formula
// 411:             url "https://brew.sh/foo-1.0.tar.gz"
// 412:              # comment
// 413:
// 414:             bottle do
// 415:               sha256 "f7b1fc772c79c20fddf621ccc791090bc1085fcef4da6cca03399424c66e06ca" => :sonoma
// 416:             end
// 417:           end
// 418:         RUBY
// 419:       end
// 420:
// 421:       it "removes the stanza but keeps the comment and its whitespace" do
// 422:         formula_ast.remove_stanza(:license)
// 423:         expect(formula_ast.process).to eq(new_contents)
// 424:       end
// 425:     end
// 426:
// 427:     context "when stanza to be removed has a comment on the next line" do
// 428:       subject(:formula_ast) do
// 429:         described_class.new <<~RUBY.chomp
// 430:           class Foo < Formula
// 431:             url "https://brew.sh/foo-1.0.tar.gz"
// 432:             license :cannot_represent
// 433:             # comment
// 434:
// 435:             bottle do
// 436:               sha256 "f7b1fc772c79c20fddf621ccc791090bc1085fcef4da6cca03399424c66e06ca" => :sonoma
// 437:             end
// 438:           end
// 439:         RUBY
// 440:       end
// 441:
// 442:       let(:new_contents) do
// 443:         <<~RUBY.chomp
// 444:           class Foo < Formula
// 445:             url "https://brew.sh/foo-1.0.tar.gz"
// 446:             # comment
// 447:
// 448:             bottle do
// 449:               sha256 "f7b1fc772c79c20fddf621ccc791090bc1085fcef4da6cca03399424c66e06ca" => :sonoma
// 450:             end
// 451:           end
// 452:         RUBY
// 453:       end
// 454:
// 455:       it "removes the stanza but keeps the comment" do
// 456:         formula_ast.remove_stanza(:license)
// 457:         expect(formula_ast.process).to eq(new_contents)
// 458:       end
// 459:     end
// 460:
// 461:     context "when stanza to be removed has newlines before and after" do
// 462:       subject(:formula_ast) do
// 463:         described_class.new <<~RUBY.chomp
// 464:           class Foo < Formula
// 465:             url "https://brew.sh/foo-1.0.tar.gz"
// 466:
// 467:             bottle do
// 468:               sha256 "f7b1fc772c79c20fddf621ccc791090bc1085fcef4da6cca03399424c66e06ca" => :sonoma
// 469:             end
// 470:
// 471:             head do
// 472:               url "https://brew.sh/foo.git"
// 473:               branch "develop"
// 474:             end
// 475:           end
// 476:         RUBY
// 477:       end
// 478:
// 479:       let(:new_contents) do
// 480:         <<~RUBY.chomp
// 481:           class Foo < Formula
// 482:             url "https://brew.sh/foo-1.0.tar.gz"
// 483:
// 484:             head do
// 485:               url "https://brew.sh/foo.git"
// 486:               branch "develop"
// 487:             end
// 488:           end
// 489:         RUBY
// 490:       end
// 491:
// 492:       it "removes the stanza and preceding newline" do
// 493:         formula_ast.remove_stanza(:bottle)
// 494:         expect(formula_ast.process).to eq(new_contents)
// 495:       end
// 496:     end
// 497:
// 498:     context "when stanza to be removed is at the end of the formula" do
// 499:       subject(:formula_ast) do
// 500:         described_class.new <<~RUBY.chomp
// 501:           class Foo < Formula
// 502:             url "https://brew.sh/foo-1.0.tar.gz"
// 503:             license :cannot_represent
// 504:
// 505:             bottle do
// 506:               sha256 "f7b1fc772c79c20fddf621ccc791090bc1085fcef4da6cca03399424c66e06ca" => :sonoma
// 507:             end
// 508:           end
// 509:         RUBY
// 510:       end
// 511:
// 512:       let(:new_contents) do
// 513:         <<~RUBY.chomp
// 514:           class Foo < Formula
// 515:             url "https://brew.sh/foo-1.0.tar.gz"
// 516:             license :cannot_represent
// 517:           end
// 518:         RUBY
// 519:       end
// 520:
// 521:       it "removes the stanza and preceding newline" do
// 522:         formula_ast.remove_stanza(:bottle)
// 523:         expect(formula_ast.process).to eq(new_contents)
// 524:       end
// 525:     end
// 526:   end
// 527:
// 528:   describe "#add_bottle_block" do
// 529:     let(:bottle_output) do
// 530:       <<-RUBY
// 531:   bottle do
// 532:     sha256 "f7b1fc772c79c20fddf621ccc791090bc1085fcef4da6cca03399424c66e06ca" => :sonoma
// 533:   end
// 534:       RUBY
// 535:     end
// 536:
// 537:     context "when `license` is a string" do
// 538:       subject(:formula_ast) do
// 539:         described_class.new <<~RUBY.chomp
// 540:           class Foo < Formula
// 541:             url "https://brew.sh/foo-1.0.tar.gz"
// 542:             license "MIT"
// 543:           end
// 544:         RUBY
// 545:       end
// 546:
// 547:       let(:new_contents) do
// 548:         <<~RUBY.chomp
// 549:           class Foo < Formula
// 550:             url "https://brew.sh/foo-1.0.tar.gz"
// 551:             license "MIT"
// 552:
// 553:             bottle do
// 554:               sha256 "f7b1fc772c79c20fddf621ccc791090bc1085fcef4da6cca03399424c66e06ca" => :sonoma
// 555:             end
// 556:           end
// 557:         RUBY
// 558:       end
// 559:
// 560:       it "adds `bottle` after `license`" do
// 561:         formula_ast.add_bottle_block(bottle_output)
// 562:         expect(formula_ast.process).to eq(new_contents)
// 563:       end
// 564:     end
// 565:
// 566:     context "when `license` is a symbol" do
// 567:       subject(:formula_ast) do
// 568:         described_class.new <<~RUBY.chomp
// 569:           class Foo < Formula
// 570:             url "https://brew.sh/foo-1.0.tar.gz"
// 571:             license :cannot_represent
// 572:           end
// 573:         RUBY
// 574:       end
// 575:
// 576:       let(:new_contents) do
// 577:         <<~RUBY.chomp
// 578:           class Foo < Formula
// 579:             url "https://brew.sh/foo-1.0.tar.gz"
// 580:             license :cannot_represent
// 581:
// 582:             bottle do
// 583:               sha256 "f7b1fc772c79c20fddf621ccc791090bc1085fcef4da6cca03399424c66e06ca" => :sonoma
// 584:             end
// 585:           end
// 586:         RUBY
// 587:       end
// 588:
// 589:       it "adds `bottle` after `license`" do
// 590:         formula_ast.add_bottle_block(bottle_output)
// 591:         expect(formula_ast.process).to eq(new_contents)
// 592:       end
// 593:     end
// 594:
// 595:     context "when `license` is multiline" do
// 596:       subject(:formula_ast) do
// 597:         described_class.new <<~RUBY.chomp
// 598:           class Foo < Formula
// 599:             url "https://brew.sh/foo-1.0.tar.gz"
// 600:             license all_of: [
// 601:               :public_domain,
// 602:               "MIT",
// 603:               "GPL-3.0-or-later" => { with: "Autoconf-exception-3.0" },
// 604:             ]
// 605:           end
// 606:         RUBY
// 607:       end
// 608:
// 609:       let(:new_contents) do
// 610:         <<~RUBY.chomp
// 611:           class Foo < Formula
// 612:             url "https://brew.sh/foo-1.0.tar.gz"
// 613:             license all_of: [
// 614:               :public_domain,
// 615:               "MIT",
// 616:               "GPL-3.0-or-later" => { with: "Autoconf-exception-3.0" },
// 617:             ]
// 618:
// 619:             bottle do
// 620:               sha256 "f7b1fc772c79c20fddf621ccc791090bc1085fcef4da6cca03399424c66e06ca" => :sonoma
// 621:             end
// 622:           end
// 623:         RUBY
// 624:       end
// 625:
// 626:       it "adds `bottle` after `license`" do
// 627:         formula_ast.add_bottle_block(bottle_output)
// 628:         expect(formula_ast.process).to eq(new_contents)
// 629:       end
// 630:     end
// 631:
// 632:     context "when `head` is a string" do
// 633:       subject(:formula_ast) do
// 634:         described_class.new <<~RUBY.chomp
// 635:           class Foo < Formula
// 636:             url "https://brew.sh/foo-1.0.tar.gz"
// 637:             head "https://brew.sh/foo.git", branch: "develop"
// 638:           end
// 639:         RUBY
// 640:       end
// 641:
// 642:       let(:new_contents) do
// 643:         <<~RUBY.chomp
// 644:           class Foo < Formula
// 645:             url "https://brew.sh/foo-1.0.tar.gz"
// 646:             head "https://brew.sh/foo.git", branch: "develop"
// 647:
// 648:             bottle do
// 649:               sha256 "f7b1fc772c79c20fddf621ccc791090bc1085fcef4da6cca03399424c66e06ca" => :sonoma
// 650:             end
// 651:           end
// 652:         RUBY
// 653:       end
// 654:
// 655:       it "adds `bottle` after `head`" do
// 656:         formula_ast.add_bottle_block(bottle_output)
// 657:         expect(formula_ast.process).to eq(new_contents)
// 658:       end
// 659:     end
// 660:
// 661:     context "when `head` is a block" do
// 662:       subject(:formula_ast) do
// 663:         described_class.new <<~RUBY.chomp
// 664:           class Foo < Formula
// 665:             url "https://brew.sh/foo-1.0.tar.gz"
// 666:
// 667:             head do
// 668:               url "https://brew.sh/foo.git"
// 669:               branch "develop"
// 670:             end
// 671:           end
// 672:         RUBY
// 673:       end
// 674:
// 675:       let(:new_contents) do
// 676:         <<~RUBY.chomp
// 677:           class Foo < Formula
// 678:             url "https://brew.sh/foo-1.0.tar.gz"
// 679:
// 680:             bottle do
// 681:               sha256 "f7b1fc772c79c20fddf621ccc791090bc1085fcef4da6cca03399424c66e06ca" => :sonoma
// 682:             end
// 683:
// 684:             head do
// 685:               url "https://brew.sh/foo.git"
// 686:               branch "develop"
// 687:             end
// 688:           end
// 689:         RUBY
// 690:       end
// 691:
// 692:       it "adds `bottle` before `head`" do
// 693:         formula_ast.add_bottle_block(bottle_output)
// 694:         expect(formula_ast.process).to eq(new_contents)
// 695:       end
// 696:     end
// 697:
// 698:     context "when there is a comment on the same line" do
// 699:       subject(:formula_ast) do
// 700:         described_class.new <<~RUBY.chomp
// 701:           class Foo < Formula
// 702:             url "https://brew.sh/foo-1.0.tar.gz" # comment
// 703:           end
// 704:         RUBY
// 705:       end
// 706:
// 707:       let(:new_contents) do
// 708:         <<~RUBY.chomp
// 709:           class Foo < Formula
// 710:             url "https://brew.sh/foo-1.0.tar.gz" # comment
// 711:
// 712:             bottle do
// 713:               sha256 "f7b1fc772c79c20fddf621ccc791090bc1085fcef4da6cca03399424c66e06ca" => :sonoma
// 714:             end
// 715:           end
// 716:         RUBY
// 717:       end
// 718:
// 719:       it "adds `bottle` after the comment" do
// 720:         formula_ast.add_bottle_block(bottle_output)
// 721:         expect(formula_ast.process).to eq(new_contents)
// 722:       end
// 723:     end
// 724:
// 725:     context "when the next line is a comment" do
// 726:       subject(:formula_ast) do
// 727:         described_class.new <<~RUBY.chomp
// 728:           class Foo < Formula
// 729:             url "https://brew.sh/foo-1.0.tar.gz"
// 730:             # comment
// 731:           end
// 732:         RUBY
// 733:       end
// 734:
// 735:       let(:new_contents) do
// 736:         <<~RUBY.chomp
// 737:           class Foo < Formula
// 738:             url "https://brew.sh/foo-1.0.tar.gz"
// 739:             # comment
// 740:
// 741:             bottle do
// 742:               sha256 "f7b1fc772c79c20fddf621ccc791090bc1085fcef4da6cca03399424c66e06ca" => :sonoma
// 743:             end
// 744:           end
// 745:         RUBY
// 746:       end
// 747:
// 748:       it "adds `bottle` after the comment" do
// 749:         formula_ast.add_bottle_block(bottle_output)
// 750:         expect(formula_ast.process).to eq(new_contents)
// 751:       end
// 752:     end
// 753:
// 754:     context "when the next line is blank and the one after it is a comment" do
// 755:       subject(:formula_ast) do
// 756:         described_class.new <<~RUBY.chomp
// 757:           class Foo < Formula
// 758:             url "https://brew.sh/foo-1.0.tar.gz"
// 759:
// 760:             # comment
// 761:           end
// 762:         RUBY
// 763:       end
// 764:
// 765:       let(:new_contents) do
// 766:         <<~RUBY.chomp
// 767:           class Foo < Formula
// 768:             url "https://brew.sh/foo-1.0.tar.gz"
// 769:
// 770:             bottle do
// 771:               sha256 "f7b1fc772c79c20fddf621ccc791090bc1085fcef4da6cca03399424c66e06ca" => :sonoma
// 772:             end
// 773:
// 774:             # comment
// 775:           end
// 776:         RUBY
// 777:       end
// 778:
// 779:       it "adds `bottle` before the comment" do
// 780:         formula_ast.add_bottle_block(bottle_output)
// 781:         expect(formula_ast.process).to eq(new_contents)
// 782:       end
// 783:     end
// 784:   end
// 785: end
