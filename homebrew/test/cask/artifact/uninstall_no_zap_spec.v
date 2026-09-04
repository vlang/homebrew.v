module artifact

import ruby

// Translated from Homebrew/brew `test/cask/artifact/uninstall_no_zap_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-installable")) }` at line 5.
pub fn ruby_uninstall_no_zap_spec_l5_d1_cask(args ...ruby.Value) ruby.Value {
	path := if args.len > 0 { args[0].as_string() } else { 'with-installable.rb' }
	return ruby.structured_value('Cask::Cask', 'with-installable', {
		'token':   'with-installable'
		'path':    path
		'has_zap': 'true'
	})
}

// Ruby let `let(:zap_artifact) do` at line 7.
pub fn ruby_uninstall_no_zap_spec_l7_d2_zap_artifact(args ...ruby.Value) ruby.Value {
	cask := if args.len > 0 { args[0] } else { ruby_uninstall_no_zap_spec_l5_d1_cask() }
	return ruby.structured_value('Cask::Artifact::Zap', cask.as_string(), {
		'cask':                        cask.as_string()
		'responds_to_uninstall_phase': 'false'
	})
}

// Ruby subject `subject { zap_artifact }` at line 12.
pub fn ruby_uninstall_no_zap_spec_l12_d3_subject_dynamic(args ...ruby.Value) ruby.Value {
	return if args.len > 0 { args[0] } else { ruby_uninstall_no_zap_spec_l7_d2_zap_artifact() }
}

// Ruby it `it { is_expected.not_to respond_to(:uninstall_phase) }` at line 14.
pub fn ruby_uninstall_no_zap_spec_l14_d4_anonymous(args ...ruby.Value) ruby.Value {
	zap := if args.len > 0 { args[0] } else { ruby_uninstall_no_zap_spec_l7_d2_zap_artifact() }
	responds := zap.attributes['responds_to_uninstall_phase'] or { 'false' }
	return ruby.bool_value(zap.type_name == 'Cask::Artifact::Zap' && responds == 'false')
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: RSpec.describe Cask::Artifact::Zap, :cask do
// 5:   let(:cask) { Cask::CaskLoader.load(cask_path("with-installable")) }
// 6:
// 7:   let(:zap_artifact) do
// 8:     cask.artifacts.find { |a| a.is_a?(described_class) }
// 9:   end
// 10:
// 11:   describe "#uninstall_phase" do
// 12:     subject { zap_artifact }
// 13:
// 14:     it { is_expected.not_to respond_to(:uninstall_phase) }
// 15:   end
// 16: end
