module perl

import ruby
import homebrew.utils
import os
import time

// Translated from Homebrew/brew `test/language/perl/shebang_spec.rb`.
// The original source is retained below until every stub has a typed V body.
const perl_spec_preferred_version = '5.30'

pub struct PerlShebangDependency {
pub:
	name              string
	required          bool = true
	uses_from_macos   bool
	use_macos_install bool
}

pub struct PerlShebangFixtures {
pub:
	perl            PerlShebangDependency
	depends_on      []PerlShebangDependency
	uses_from_macos []PerlShebangDependency
	no_dependencies []PerlShebangDependency
}

fn perl_platform_uses_macos_install() bool {
	$if macos {
		return true
	} $else {
		return false
	}
}

pub fn perl_shebang_fixtures() PerlShebangFixtures {
	return PerlShebangFixtures{
		perl: PerlShebangDependency{ name: 'perl' }
		depends_on: [PerlShebangDependency{ name: 'perl' }]
		uses_from_macos: [PerlShebangDependency{
			name: 'perl'
			uses_from_macos: true
			use_macos_install: perl_platform_uses_macos_install()
		}]
	}
}

pub fn perl_shebang_rewrite_info(perl_path string) !utils.RewriteInfo {
	return utils.new_shebang_rewrite_info(r'^#! ?(?:/usr/bin/(?:env )?)?perl( |$)', '#! /usr/bin/env perl '.len, '${perl_path}\\1')
}

pub fn detected_perl_shebang(dependencies []PerlShebangDependency, prefix string,
	preferred_version string) !utils.RewriteInfo {
	perl_dependencies := dependencies.filter(it.required && it.name == 'perl')
	if perl_dependencies.len == 0 {
		return error('Cannot detect Perl shebang: formula does not depend on Perl.')
	}
	use_brewed_perl := perl_dependencies.any(!it.uses_from_macos || !it.use_macos_install)
	perl_path := if use_brewed_perl {
		'${prefix.trim_right('/')}/opt/perl/bin/perl'
	} else {
		'/usr/bin/perl${preferred_version}'
	}
	return perl_shebang_rewrite_info(perl_path)
}

fn perl_shebang_contents(broken bool) string {
	interpreter := if broken { '#!perl' } else { '#!/usr/bin/env perl' }
	return '${interpreter}\na\nb\nc\n'
}

fn perl_shebang_temp_path(label string) string {
	return os.join_path(os.temp_dir(), 'brew-v-perl-shebang-${label}-${os.getpid()}-${time.now().unix_micro()}')
}

fn perl_spec_file(args []ruby.Value, broken bool) ruby.Value {
	path := if args.len > 0 { args[0].as_string() } else { perl_shebang_temp_path('file') }
	os.write_file(path, perl_shebang_contents(broken)) or {
		return ruby.object_value('IOError', err.msg())
	}
	return ruby.structured_value('Tempfile', path, {
		'path': path
	})
}

fn perl_spec_prefix(args []ruby.Value) string {
	return if args.len > 0 { args[0].as_string().trim_right('/') } else { '/opt/homebrew' }
}

fn perl_spec_rewrites(prefix string, dependencies []PerlShebangDependency, broken bool) bool {
	root := perl_shebang_temp_path('case')
	os.mkdir_all(root) or { return false }
	defer {
		os.rmdir_all(root) or {}
	}
	path := os.join_path(root, 'script')
	os.write_file(path, perl_shebang_contents(broken)) or { return false }
	info := detected_perl_shebang(dependencies, prefix, perl_spec_preferred_version) or {
		return false
	}
	if utils.rewrite_shebang(info, [path]) or { return false } != 1 {
		return false
	}
	use_brewed_perl := dependencies.any(!it.uses_from_macos || !it.use_macos_install)
	expected_interpreter := if use_brewed_perl {
		'${prefix}/opt/perl/bin/perl'
	} else {
		'/usr/bin/perl${perl_spec_preferred_version}'
	}
	return os.read_file(path) or { return false } == '#!${expected_interpreter}\na\nb\nc\n'
}

// Ruby let `let(:file) { Tempfile.new("perl-shebang") }` at line 8.
pub fn ruby_shebang_spec_l8_d1_file(args ...ruby.Value) ruby.Value {
	return perl_spec_file(args, false)
}

// Ruby let `let(:broken_file) { Tempfile.new("perl-shebang") }` at line 9.
pub fn ruby_shebang_spec_l9_d2_broken_file(args ...ruby.Value) ruby.Value {
	return perl_spec_file(args, true)
}

// Ruby let `let(:f) do` at line 10.
pub fn ruby_shebang_spec_l10_d3_f(args ...ruby.Value) ruby.Value {
	return ruby.structured_value('PerlShebangFixtures', 'perl', {
		'perl':            'perl'
		'depends_on':      'perl'
		'uses_from_macos': 'perl'
		'no_deps':         ''
	})
}

// Ruby it `it "can be used to replace Perl shebangs when depends_on \"perl\" is used" do` at line 60.
pub fn ruby_shebang_spec_l60_d4_can(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(perl_spec_rewrites(perl_spec_prefix(args), perl_shebang_fixtures().depends_on, false))
}

// Ruby it `it "can be used to replace Perl shebangs when uses_from_macos \"perl\" is used" do` at line 72.
pub fn ruby_shebang_spec_l72_d5_can(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(perl_spec_rewrites(perl_spec_prefix(args), perl_shebang_fixtures().uses_from_macos, false))
}

// Ruby it `it "can fix broken shebang like `#!perl`" do` at line 90.
pub fn ruby_shebang_spec_l90_d6_can(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(perl_spec_rewrites(perl_spec_prefix(args), perl_shebang_fixtures().uses_from_macos, true))
}

// Ruby it `it "errors if formula doesn't depend on perl" do` at line 109.
pub fn ruby_shebang_spec_l109_d7_errors(args ...ruby.Value) ruby.Value {
	if _ := detected_perl_shebang(perl_shebang_fixtures().no_dependencies, perl_spec_prefix(args), perl_spec_preferred_version) {
		return ruby.bool_value(false)
	} else {
		return ruby.bool_value(err.msg() == 'Cannot detect Perl shebang: formula does not depend on Perl.')
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "language/perl"
// 5: require "utils/shebang"
// 6:
// 7: RSpec.describe Language::Perl::Shebang do
// 8:   let(:file) { Tempfile.new("perl-shebang") }
// 9:   let(:broken_file) { Tempfile.new("perl-shebang") }
// 10:   let(:f) do
// 11:     f = {}
// 12:
// 13:     f[:perl] = formula "perl" do
// 14:       T.bind(self, T.class_of(Formula))
// 15:       url "https://brew.sh/perl-1.0.tgz"
// 16:     end
// 17:
// 18:     f[:depends_on] = formula "foo" do
// 19:       T.bind(self, T.class_of(Formula))
// 20:       url "https://brew.sh/foo-1.0.tgz"
// 21:
// 22:       depends_on "perl"
// 23:     end
// 24:
// 25:     f[:uses_from_macos] = formula "foo" do
// 26:       T.bind(self, T.class_of(Formula))
// 27:       url "https://brew.sh/foo-1.0.tgz"
// 28:
// 29:       uses_from_macos "perl"
// 30:     end
// 31:
// 32:     f[:no_deps] = formula "foo" do
// 33:       T.bind(self, T.class_of(Formula))
// 34:       url "https://brew.sh/foo-1.0.tgz"
// 35:     end
// 36:
// 37:     f
// 38:   end
// 39:
// 40:   before do
// 41:     file.write <<~EOS
// 42:       #!/usr/bin/env perl
// 43:       a
// 44:       b
// 45:       c
// 46:     EOS
// 47:     file.flush
// 48:     broken_file.write <<~EOS
// 49:       #!perl
// 50:       a
// 51:       b
// 52:       c
// 53:     EOS
// 54:     broken_file.flush
// 55:   end
// 56:
// 57:   after { [file, broken_file].each(&:unlink) }
// 58:
// 59:   describe "#detected_perl_shebang" do
// 60:     it "can be used to replace Perl shebangs when depends_on \"perl\" is used" do
// 61:       allow(Formulary).to receive(:factory).with(f[:perl].name).and_return(f[:perl])
// 62:       Utils::Shebang.rewrite_shebang described_class.detected_perl_shebang(f[:depends_on]), file.path
// 63:
// 64:       expect(File.read(file)).to eq <<~EOS
// 65:         #!#{HOMEBREW_PREFIX}/opt/perl/bin/perl
// 66:         a
// 67:         b
// 68:         c
// 69:       EOS
// 70:     end
// 71:
// 72:     it "can be used to replace Perl shebangs when uses_from_macos \"perl\" is used" do
// 73:       allow(Formulary).to receive(:factory).with(f[:perl].name).and_return(f[:perl])
// 74:       Utils::Shebang.rewrite_shebang described_class.detected_perl_shebang(f[:uses_from_macos]), file.path
// 75:
// 76:       expected_shebang = if OS.mac?
// 77:         "/usr/bin/perl#{MacOS.preferred_perl_version}"
// 78:       else
// 79:         HOMEBREW_PREFIX/"opt/perl/bin/perl"
// 80:       end
// 81:
// 82:       expect(File.read(file)).to eq <<~EOS
// 83:         #!#{expected_shebang}
// 84:         a
// 85:         b
// 86:         c
// 87:       EOS
// 88:     end
// 89:
// 90:     it "can fix broken shebang like `#!perl`" do
// 91:       allow(Formulary).to receive(:factory).with(f[:perl].name).and_return(f[:perl])
// 92:       Utils::Shebang.rewrite_shebang described_class.detected_perl_shebang(f[:uses_from_macos]),
// 93:                                      broken_file.path
// 94:
// 95:       expected_shebang = if OS.mac?
// 96:         "/usr/bin/perl#{MacOS.preferred_perl_version}"
// 97:       else
// 98:         HOMEBREW_PREFIX/"opt/perl/bin/perl"
// 99:       end
// 100:
// 101:       expect(File.read(broken_file)).to eq <<~EOS
// 102:         #!#{expected_shebang}
// 103:         a
// 104:         b
// 105:         c
// 106:       EOS
// 107:     end
// 108:
// 109:     it "errors if formula doesn't depend on perl" do
// 110:       expect { Utils::Shebang.rewrite_shebang described_class.detected_perl_shebang(f[:no_deps]), file.path }
// 111:         .to raise_error(ShebangDetectionError, "Cannot detect Perl shebang: formula does not depend on Perl.")
// 112:     end
// 113:   end
// 114: end
