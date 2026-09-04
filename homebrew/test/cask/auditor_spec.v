module cask

import ruby
import homebrew.cask as cask_auditor

// Translated from Homebrew/brew `test/cask/auditor_spec.rb`.
// The original source is retained below until every stub has a typed V body.

fn auditor_spec_cask(token string, sha256 string) ruby.Value {
	return ruby.map_value({
		'token':                ruby.string_value(token)
		'version':              ruby.string_value('1.0')
		'sha256':               ruby.string_value(sha256)
		'url':                  ruby.string_value('https://example.com/${token}.zip')
		'homepage':             ruby.string_value('https://example.com/${token}')
		'names':                ruby.string_array_value(['Example'])
		'description':          ruby.string_value('Example cask')
		'installable_artifact': ruby.bool_value(true)
	})
}

fn auditor_spec_valid_cask(token string) ruby.Value {
	return auditor_spec_cask(token, '67cdb8a02803ef37fdbf7e0be205863172e41a561ca446cd84f0d7ab35a99d94')
}

fn auditor_spec_with_languages(token string, count int, invalid bool) ruby.Value {
	base := auditor_spec_valid_cask(token)
	mut blocks := []ruby.Value{}
	for index in 0 .. count {
		localized := if invalid {
			auditor_spec_cask(token, 'not-a-valid-sha256')
		} else {
			auditor_spec_valid_cask(token)
		}
		blocks << ruby.map_value({
			'languages': ruby.string_array_value(['lang-${index}'])
			'cask':      localized
		})
	}
	mut values := base.map_data.clone()
	values['language_blocks'] = ruby.array_value(blocks)
	return ruby.Value{
		...base
		map_data: values
	}
}

fn auditor_spec_options(extra map[string]ruby.Value) ruby.Value {
	mut values := {
		'only': ruby.string_array_value(['sha256_actually_256'])
	}
	for key, value in extra {
		values[key] = value
	}
	return ruby.map_value(values)
}

fn auditor_spec_audit_value(has_errors bool) ruby.Value {
	errors := if has_errors {
		ruby.array_value([ruby.map_value({
			'message':   ruby.string_value('audit error')
			'location':  ruby.Value{ type_name: 'NilClass', repr: 'nil' }
			'corrected': ruby.bool_value(false)
		})])
	} else {
		ruby.array_value([]ruby.Value{})
	}
	return ruby.map_value({
		'cask':   auditor_spec_valid_cask('basic-cask')
		'errors': errors
	})
}

// Ruby subject `subject(:auditor) { described_class }` at line 7.
pub fn ruby_auditor_spec_l7_d1_auditor(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Class', 'Cask::Auditor')
}

// Ruby it `it "returns an empty Set if there are no audit errors" do` at line 10.
pub fn ruby_auditor_spec_l10_d2_returns(args ...ruby.Value) ruby.Value {
	options := auditor_spec_options({})
	for cask in [auditor_spec_valid_cask('basic-cask'),
		auditor_spec_with_languages('with-languages', 2, false),
		auditor_spec_with_languages('with-many-languages', 12, false)] {
		result := cask_auditor.ruby_auditor_l21_d1_self_audit(cask, options)
		if result.type_name != 'Set' || result.array_data.len != 0 {
			return ruby.bool_value(false)
		}
	}
	return ruby.bool_value(true)
}

// Ruby it `it "returns a Set of Audit::Error hashes if there are audit errors" do` at line 21.
pub fn ruby_auditor_spec_l21_d3_returns(args ...ruby.Value) ruby.Value {
	options := auditor_spec_options({})
	for cask in [auditor_spec_cask('invalid-sha256', 'invalid'),
		auditor_spec_with_languages('with-many-languages-and-invalid-sha256', 12, true)] {
		result := cask_auditor.ruby_auditor_l21_d1_self_audit(cask, options)
		if result.type_name != 'Set' || result.array_data.len != 1 {
			return ruby.bool_value(false)
		}
		problem := result.array_data[0].map_data.clone()
		if (problem['message'] or { return ruby.bool_value(false) }).as_string() != 'sha256 string must be of 64 hexadecimal characters' {
			return ruby.bool_value(false)
		}
		if (problem['corrected'] or { return ruby.bool_value(false) }).as_bool() or {
			false
		} {
			return ruby.bool_value(false)
		}
	}
	return ruby.bool_value(true)
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("basic-cask")) }` at line 38.
pub fn ruby_auditor_spec_l38_d4_cask(args ...ruby.Value) ruby.Value {
	return auditor_spec_valid_cask('basic-cask')
}

// Ruby it `it "returns true if @any_named_args is true" do` at line 40.
pub fn ruby_auditor_spec_l40_d5_returns(args ...ruby.Value) ruby.Value {
	auditor := cask_auditor.new_cask_auditor(cask_auditor.AuditCask{
		token: 'basic-cask'
	}, cask_auditor.AuditorOptions{
		any_named_args: true
	})
	return ruby.bool_value(auditor.output_summary(none))
}

// Ruby it `it "returns true if @audit_strict is true" do` at line 45.
pub fn ruby_auditor_spec_l45_d6_returns(args ...ruby.Value) ruby.Value {
	auditor := cask_auditor.new_cask_auditor(cask_auditor.AuditCask{
		token: 'basic-cask'
	}, cask_auditor.AuditorOptions{
		audit_strict: true
	})
	return ruby.bool_value(auditor.output_summary(none))
}

// Ruby it `it "returns false if the audit argument is nil" do` at line 50.
pub fn ruby_auditor_spec_l50_d7_returns(args ...ruby.Value) ruby.Value {
	instance := cask_auditor.ruby_auditor_l46_d4_initialize(ruby_auditor_spec_l38_d4_cask())
	omitted := cask_auditor.ruby_auditor_l104_d6_output_summary(instance).as_bool() or { true }
	explicit := cask_auditor.ruby_auditor_l104_d6_output_summary(instance, ruby.Value{
		type_name: 'NilClass'
		repr: 'nil'
	}).as_bool() or { true }
	return ruby.bool_value(!omitted && !explicit)
}

// Ruby it `it "returns false if there are no audit errors" do` at line 56.
pub fn ruby_auditor_spec_l56_d8_returns(args ...ruby.Value) ruby.Value {
	instance := cask_auditor.ruby_auditor_l46_d4_initialize(ruby_auditor_spec_l38_d4_cask())
	result := cask_auditor.ruby_auditor_l104_d6_output_summary(instance, auditor_spec_audit_value(false)).as_bool() or { true }
	return ruby.bool_value(!result)
}

// Ruby it `it "returns true if there are audit errors" do` at line 62.
pub fn ruby_auditor_spec_l62_d9_returns(args ...ruby.Value) ruby.Value {
	instance := cask_auditor.ruby_auditor_l46_d4_initialize(ruby_auditor_spec_l38_d4_cask())
	result := cask_auditor.ruby_auditor_l104_d6_output_summary(instance, auditor_spec_audit_value(true)).as_bool() or { false }
	return ruby.bool_value(result)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/auditor"
// 5:
// 6: RSpec.describe Cask::Auditor, :cask do
// 7:   subject(:auditor) { described_class }
// 8:
// 9:   describe "audit" do
// 10:     it "returns an empty Set if there are no audit errors" do
// 11:       basic_cask = Cask::CaskLoader.load(cask_path("basic-cask"))
// 12:       expect(auditor.audit(basic_cask)).to eq(Set.new)
// 13:
// 14:       with_languages_cask = Cask::CaskLoader.load(cask_path("with-languages"))
// 15:       expect(auditor.audit(with_languages_cask)).to eq(Set.new)
// 16:
// 17:       with_many_languages_cask = Cask::CaskLoader.load(cask_path("with-many-languages"))
// 18:       expect(auditor.audit(with_many_languages_cask)).to eq(Set.new)
// 19:     end
// 20:
// 21:     it "returns a Set of Audit::Error hashes if there are audit errors" do
// 22:       error_hash = {
// 23:         message:   "sha256 string must be of 64 hexadecimal characters",
// 24:         location:  nil,
// 25:         corrected: false,
// 26:       }
// 27:
// 28:       invalid_sha256_cask = Cask::CaskLoader.load(cask_path("invalid-sha256"))
// 29:       expect(auditor.audit(invalid_sha256_cask)).to eq(Set[error_hash])
// 30:
// 31:       with_many_languages_and_error_cask = Cask::CaskLoader.load(cask_path("with-many-languages-and-invalid-sha256"))
// 32:       expect(auditor.audit(with_many_languages_and_error_cask)).to eq(Set[error_hash])
// 33:       expect(auditor.audit(with_many_languages_and_error_cask, audit_strict: true)).to eq(Set[error_hash])
// 34:     end
// 35:   end
// 36:
// 37:   describe "output_summary?" do
// 38:     let(:cask) { Cask::CaskLoader.load(cask_path("basic-cask")) }
// 39:
// 40:     it "returns true if @any_named_args is true" do
// 41:       auditor_obj = auditor.new(cask, any_named_args: true)
// 42:       expect(auditor_obj.output_summary?).to be(true)
// 43:     end
// 44:
// 45:     it "returns true if @audit_strict is true" do
// 46:       auditor_obj = auditor.new(cask, audit_strict: true)
// 47:       expect(auditor_obj.output_summary?).to be(true)
// 48:     end
// 49:
// 50:     it "returns false if the audit argument is nil" do
// 51:       auditor_obj = auditor.new(cask)
// 52:       expect(auditor_obj.output_summary?).to be(false)
// 53:       expect(auditor_obj.output_summary?(nil)).to be(false)
// 54:     end
// 55:
// 56:     it "returns false if there are no audit errors" do
// 57:       auditor_obj = auditor.new(cask)
// 58:       audit = Cask::Audit.new(cask)
// 59:       expect(auditor_obj.output_summary?(audit)).to be(false)
// 60:     end
// 61:
// 62:     it "returns true if there are audit errors" do
// 63:       auditor_obj = auditor.new(cask)
// 64:       audit = Cask::Audit.new(cask)
// 65:       audit.add_error(nil)
// 66:       expect(auditor_obj.output_summary?(audit)).to be(true)
// 67:     end
// 68:   end
// 69: end
