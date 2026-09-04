module python

import ruby
import homebrew.utils
import os
import time

// Translated from Homebrew/brew `test/language/python/shebang_spec.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct PythonShebangDependency {
pub:
	name     string
	required bool = true
}

pub struct PythonShebangFixtures {
pub:
	python311            PythonShebangDependency
	versioned_python     []PythonShebangDependency
	no_dependencies      []PythonShebangDependency
	multiple_python_deps []PythonShebangDependency
}

pub fn python_shebang_fixtures() PythonShebangFixtures {
	return PythonShebangFixtures{
		python311: PythonShebangDependency{ name: 'python@3.11' }
		versioned_python: [PythonShebangDependency{ name: 'python@3.11' }]
		multiple_python_deps: [PythonShebangDependency{ name: 'python' },
			PythonShebangDependency{ name: 'python@3.11' }]
	}
}

pub fn python_shebang_rewrite_info(python_path string) !utils.RewriteInfo {
	return utils.new_shebang_rewrite_info(r'^#! ?(?:/usr/bin/(?:env )?)?python(?:[23](?:\.\d{1,2})?)?( |$)', '#! /usr/bin/env pythonx.yyy '.len, '${python_path}\\1')
}

pub fn detected_python_shebang(dependencies []PythonShebangDependency, prefix string,
	use_python_from_path bool) !utils.RewriteInfo {
	if use_python_from_path {
		return python_shebang_rewrite_info('/usr/bin/env python3')
	}
	python_dependencies := dependencies.filter(it.required && (it.name == 'python' || it.name.starts_with('python@')))
	if python_dependencies.len == 0 {
		return error('Cannot detect Python shebang: formula does not depend on Python.')
	}
	if python_dependencies.len > 1 {
		return error('Cannot detect Python shebang: formula has multiple Python dependencies.')
	}
	name := python_dependencies[0].name
	executable := name.replace('@', '')
	return python_shebang_rewrite_info('${prefix.trim_right('/')}/opt/${name}/bin/${executable}')
}

fn python_shebang_contents(broken bool) string {
	interpreter := if broken { '#!python' } else { '#!/usr/bin/python2' }
	return '${interpreter}\na\nb\nc\n'
}

fn python_shebang_temp_path(label string) string {
	return os.join_path(os.temp_dir(), 'brew-v-python-shebang-${label}-${os.getpid()}-${time.now().unix_micro()}')
}

fn python_spec_file(args []ruby.Value, broken bool) ruby.Value {
	path := if args.len > 0 { args[0].as_string() } else { python_shebang_temp_path('file') }
	os.write_file(path, python_shebang_contents(broken)) or {
		return ruby.object_value('IOError', err.msg())
	}
	return ruby.structured_value('Tempfile', path, {
		'path': path
	})
}

fn python_spec_prefix(args []ruby.Value) string {
	return if args.len > 0 { args[0].as_string().trim_right('/') } else { '/opt/homebrew' }
}

fn python_spec_rewrites(prefix string, use_python_from_path bool, broken bool) bool {
	root := python_shebang_temp_path('case')
	os.mkdir_all(root) or { return false }
	defer {
		os.rmdir_all(root) or {}
	}
	path := os.join_path(root, 'script')
	os.write_file(path, python_shebang_contents(broken)) or { return false }
	info := detected_python_shebang(python_shebang_fixtures().versioned_python, prefix, use_python_from_path) or { return false }
	if utils.rewrite_shebang(info, [path]) or { return false } != 1 {
		return false
	}
	expected_interpreter := if use_python_from_path {
		'/usr/bin/env python3'
	} else {
		'${prefix}/opt/python@3.11/bin/python3.11'
	}
	return os.read_file(path) or { return false } == '#!${expected_interpreter}\na\nb\nc\n'
}

// Ruby let `let(:file) { Tempfile.new("python-shebang") }` at line 8.
pub fn ruby_shebang_spec_l8_d1_file(args ...ruby.Value) ruby.Value {
	return python_spec_file(args, false)
}

// Ruby let `let(:broken_file) { Tempfile.new("python-shebang") }` at line 9.
pub fn ruby_shebang_spec_l9_d2_broken_file(args ...ruby.Value) ruby.Value {
	return python_spec_file(args, true)
}

// Ruby let `let(:f) do` at line 10.
pub fn ruby_shebang_spec_l10_d3_f(args ...ruby.Value) ruby.Value {
	return ruby.structured_value('PythonShebangFixtures', 'python@3.11', {
		'python311':            'python@3.11'
		'versioned_python_dep': 'python@3.11'
		'no_deps':              ''
		'multiple_deps':        'python,python@3.11'
	})
}

// Ruby it `it "can be used to replace Python shebangs" do` at line 61.
pub fn ruby_shebang_spec_l61_d4_can(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(python_spec_rewrites(python_spec_prefix(args), false, false))
}

// Ruby it `it "can be pointed to a `python3` in PATH" do` at line 76.
pub fn ruby_shebang_spec_l76_d5_can(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(python_spec_rewrites(python_spec_prefix(args), true, false))
}

// Ruby it `it "can fix broken shebang line `#!python`" do` at line 90.
pub fn ruby_shebang_spec_l90_d6_can(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(python_spec_rewrites(python_spec_prefix(args), true, true))
}

// Ruby it `it "errors if formula doesn't depend on python" do` at line 104.
pub fn ruby_shebang_spec_l104_d7_errors(args ...ruby.Value) ruby.Value {
	if _ := detected_python_shebang(python_shebang_fixtures().no_dependencies, python_spec_prefix(args), false) {
		return ruby.bool_value(false)
	} else {
		return ruby.bool_value(err.msg() == 'Cannot detect Python shebang: formula does not depend on Python.')
	}
}

// Ruby it `it "errors if formula depends on more than one python" do` at line 113.
pub fn ruby_shebang_spec_l113_d8_errors(args ...ruby.Value) ruby.Value {
	if _ := detected_python_shebang(python_shebang_fixtures().multiple_python_deps, python_spec_prefix(args), false) {
		return ruby.bool_value(false)
	} else {
		return ruby.bool_value(err.msg() == 'Cannot detect Python shebang: formula has multiple Python dependencies.')
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "language/python"
// 5: require "utils/shebang"
// 6:
// 7: RSpec.describe Language::Python::Shebang do
// 8:   let(:file) { Tempfile.new("python-shebang") }
// 9:   let(:broken_file) { Tempfile.new("python-shebang") }
// 10:   let(:f) do
// 11:     f = {}
// 12:
// 13:     f[:python311] = formula "python@3.11" do
// 14:       T.bind(self, T.class_of(Formula))
// 15:       url "https://brew.sh/python-1.0.tgz"
// 16:     end
// 17:
// 18:     f[:versioned_python_dep] = formula "foo" do
// 19:       T.bind(self, T.class_of(Formula))
// 20:       url "https://brew.sh/foo-1.0.tgz"
// 21:
// 22:       depends_on "python@3.11"
// 23:     end
// 24:
// 25:     f[:no_deps] = formula "foo" do
// 26:       T.bind(self, T.class_of(Formula))
// 27:       url "https://brew.sh/foo-1.0.tgz"
// 28:     end
// 29:
// 30:     f[:multiple_deps] = formula "foo" do
// 31:       T.bind(self, T.class_of(Formula))
// 32:       url "https://brew.sh/foo-1.0.tgz"
// 33:
// 34:       depends_on "python"
// 35:       depends_on "python@3.11"
// 36:     end
// 37:
// 38:     f
// 39:   end
// 40:
// 41:   before do
// 42:     file.write <<~EOS
// 43:       #!/usr/bin/python2
// 44:       a
// 45:       b
// 46:       c
// 47:     EOS
// 48:     file.flush
// 49:     broken_file.write <<~EOS
// 50:       #!python
// 51:       a
// 52:       b
// 53:       c
// 54:     EOS
// 55:     broken_file.flush
// 56:   end
// 57:
// 58:   after { [file, broken_file].each(&:unlink) }
// 59:
// 60:   describe "#detected_python_shebang" do
// 61:     it "can be used to replace Python shebangs" do
// 62:       allow(Formulary).to receive(:factory).with(f[:python311].name).and_return(f[:python311])
// 63:       Utils::Shebang.rewrite_shebang(
// 64:         described_class.detected_python_shebang(f[:versioned_python_dep],
// 65:                                                 use_python_from_path: false), file.path
// 66:       )
// 67:
// 68:       expect(File.read(file)).to eq <<~EOS
// 69:         #!#{HOMEBREW_PREFIX}/opt/python@3.11/bin/python3.11
// 70:         a
// 71:         b
// 72:         c
// 73:       EOS
// 74:     end
// 75:
// 76:     it "can be pointed to a `python3` in PATH" do
// 77:       Utils::Shebang.rewrite_shebang(
// 78:         described_class.detected_python_shebang(f[:versioned_python_dep],
// 79:                                                 use_python_from_path: true), file.path
// 80:       )
// 81:
// 82:       expect(File.read(file)).to eq <<~EOS
// 83:         #!/usr/bin/env python3
// 84:         a
// 85:         b
// 86:         c
// 87:       EOS
// 88:     end
// 89:
// 90:     it "can fix broken shebang line `#!python`" do
// 91:       Utils::Shebang.rewrite_shebang(
// 92:         described_class.detected_python_shebang(f[:versioned_python_dep],
// 93:                                                 use_python_from_path: true), broken_file.path
// 94:       )
// 95:
// 96:       expect(File.read(broken_file)).to eq <<~EOS
// 97:         #!/usr/bin/env python3
// 98:         a
// 99:         b
// 100:         c
// 101:       EOS
// 102:     end
// 103:
// 104:     it "errors if formula doesn't depend on python" do
// 105:       expect do
// 106:         Utils::Shebang.rewrite_shebang(
// 107:           described_class.detected_python_shebang(f[:no_deps], use_python_from_path: false),
// 108:           file.path,
// 109:         )
// 110:       end.to raise_error(ShebangDetectionError, "Cannot detect Python shebang: formula does not depend on Python.")
// 111:     end
// 112:
// 113:     it "errors if formula depends on more than one python" do
// 114:       expect do
// 115:         Utils::Shebang.rewrite_shebang(
// 116:           described_class.detected_python_shebang(f[:multiple_deps], use_python_from_path: false),
// 117:           file.path,
// 118:         )
// 119:       end.to raise_error(
// 120:         ShebangDetectionError,
// 121:         "Cannot detect Python shebang: formula has multiple Python dependencies.",
// 122:       )
// 123:     end
// 124:   end
// 125: end
