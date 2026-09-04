module livecheck

import ruby
import homebrew.livecheck as livecheck_core

const livecheck_options_spec_names = ['compressed', 'cookies', 'header', 'homebrew_curl', 'post_form',
	'post_json', 'referer', 'user_agent']

// Translated from Homebrew/brew `test/livecheck/options_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:options) { described_class }` at line 7.
pub fn ruby_options_spec_l7_d1_options(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Class', 'Homebrew::Livecheck::Options')
}

// Ruby let `let(:cookies) { { "cookie_key" => "cookie_value" } }` at line 9.
pub fn ruby_options_spec_l9_d2_cookies(args ...ruby.Value) ruby.Value {
	return ruby.map_value({
		'cookie_key': ruby.string_value('cookie_value')
	})
}

// Ruby let `let(:header_string) { "Accept: */*" }` at line 10.
pub fn ruby_options_spec_l10_d3_header_string(args ...ruby.Value) ruby.Value {
	return ruby.string_value('Accept: */*')
}

// Ruby let `let(:referer_url) { "https://example.com/referer" }` at line 11.
pub fn ruby_options_spec_l11_d4_referer_url(args ...ruby.Value) ruby.Value {
	return ruby.string_value('https://example.com/referer')
}

// Ruby let `let(:post_hash) do` at line 12.
pub fn ruby_options_spec_l12_d5_post_hash(args ...ruby.Value) ruby.Value {
	return ruby.map_value({
		'empty':   ruby.string_value('')
		'boolean': ruby.string_value('true')
		'number':  ruby.string_value('1')
		'string':  ruby.string_value('a + b = c')
	})
}

// Ruby let `let(:args) do` at line 20.
pub fn ruby_options_spec_l20_d6_args(args ...ruby.Value) ruby.Value {
	post_hash := ruby_options_spec_l12_d5_post_hash()
	return ruby.map_value({
		'compressed':    ruby.bool_value(false)
		'cookies':       ruby_options_spec_l9_d2_cookies()
		'header':        ruby_options_spec_l10_d3_header_string()
		'homebrew_curl': ruby.bool_value(true)
		'post_form':     post_hash
		'post_json':     post_hash
		'referer':       ruby_options_spec_l11_d4_referer_url()
		'user_agent':    ruby.Value{ type_name: 'Symbol', repr: 'browser' }
	})
}

// Ruby let `let(:other_args) do` at line 32.
pub fn ruby_options_spec_l32_d7_other_args(args ...ruby.Value) ruby.Value {
	return ruby.map_value({
		'post_form': ruby.map_value({
			'something': ruby.string_value('else')
		})
	})
}

// Ruby let `let(:merged_hash) { args.merge(other_args) }` at line 37.
pub fn ruby_options_spec_l37_d8_merged_hash(args ...ruby.Value) ruby.Value {
	mut values := ruby_options_spec_l20_d6_args().map_data.clone()
	for key, value in ruby_options_spec_l32_d7_other_args().map_data {
		values[key] = value
	}
	return ruby.map_value(values)
}

// Ruby let `let(:base_options) { options.new(**args) }` at line 38.
pub fn ruby_options_spec_l38_d9_base_options(args ...ruby.Value) ruby.Value {
	return livecheck_core.livecheck_options_value(livecheck_core.new_livecheck_options(ruby_options_spec_l20_d6_args().map_data))
}

// Ruby let `let(:other_options) { options.new(**other_args) }` at line 39.
pub fn ruby_options_spec_l39_d10_other_options(args ...ruby.Value) ruby.Value {
	return livecheck_core.livecheck_options_value(livecheck_core.new_livecheck_options(ruby_options_spec_l32_d7_other_args().map_data))
}

// Ruby let `let(:merged_options) { options.new(**merged_hash) }` at line 40.
pub fn ruby_options_spec_l40_d11_merged_options(args ...ruby.Value) ruby.Value {
	return livecheck_core.livecheck_options_value(livecheck_core.new_livecheck_options(ruby_options_spec_l37_d8_merged_hash().map_data))
}

// Ruby it `it "returns a Hash of the options that are provided as arguments to the `url` DSL method" do` at line 43.
pub fn ruby_options_spec_l43_d12_returns(args ...ruby.Value) ruby.Value {
	values := livecheck_core.new_livecheck_options(map[string]ruby.Value{}).url_options()
	if values.len != livecheck_options_spec_names.len {
		return ruby.bool_value(false)
	}
	for name in livecheck_options_spec_names {
		value := values[name] or { return ruby.bool_value(false) }
		if value.type_name != 'NilClass' {
			return ruby.bool_value(false)
		}
	}
	return ruby.bool_value(true)
}

// Ruby it `it "returns a Hash of all instance variables" do` at line 58.
pub fn ruby_options_spec_l58_d13_returns(args ...ruby.Value) ruby.Value {
	empty := livecheck_core.new_livecheck_options(map[string]ruby.Value{})
	with_args := livecheck_core.new_livecheck_options(ruby_options_spec_l20_d6_args().map_data)
	return ruby.bool_value(empty.values.len == 0 && livecheck_options_maps_equal(with_args.values, ruby_options_spec_l20_d6_args().map_data))
}

// Ruby it `it "returns a Hash of all instance variables, using String keys" do` at line 67.
pub fn ruby_options_spec_l67_d14_returns(args ...ruby.Value) ruby.Value {
	empty_hash := livecheck_core.ruby_options_l54_d2_to_hash(livecheck_core.livecheck_options_value(livecheck_core.new_livecheck_options(map[string]ruby.Value{})))
	args_hash := livecheck_core.ruby_options_l54_d2_to_hash(ruby_options_spec_l38_d9_base_options())
	return ruby.bool_value(empty_hash.map_data.len == 0 && livecheck_options_maps_equal(args_hash.map_data, ruby_options_spec_l20_d6_args().map_data))
}

// Ruby it `it "returns an Options object with merged values" do` at line 76.
pub fn ruby_options_spec_l76_d15_returns(args ...ruby.Value) ruby.Value {
	base := livecheck_core.new_livecheck_options(ruby_options_spec_l20_d6_args().map_data)
	other := livecheck_core.new_livecheck_options(ruby_options_spec_l32_d7_other_args().map_data)
	merged := livecheck_core.new_livecheck_options(ruby_options_spec_l37_d8_merged_hash().map_data)
	return ruby.bool_value(base.merge(other).equals(merged) && base.merge(livecheck_core.new_livecheck_options(ruby_options_spec_l32_d7_other_args().map_data)).equals(merged) && base.merge(base).equals(base) && base.merge(livecheck_core.new_livecheck_options(map[string]ruby.Value{})).equals(base))
}

// Ruby it `it "merges values from `other` into `self` and returns `self`" do` at line 89.
pub fn ruby_options_spec_l89_d16_merges(args ...ruby.Value) ruby.Value {
	other := livecheck_core.new_livecheck_options(ruby_options_spec_l32_d7_other_args().map_data)
	merged := livecheck_core.new_livecheck_options(ruby_options_spec_l37_d8_merged_hash().map_data)
	mut o1 := livecheck_core.new_livecheck_options(ruby_options_spec_l20_d6_args().map_data)
	r1 := o1.merge_in_place(other)
	mut o2 := livecheck_core.new_livecheck_options(ruby_options_spec_l20_d6_args().map_data)
	r2 := o2.merge_in_place(livecheck_core.new_livecheck_options(ruby_options_spec_l32_d7_other_args().map_data))
	mut o3 := livecheck_core.new_livecheck_options(ruby_options_spec_l20_d6_args().map_data)
	r3 := o3.merge_in_place(livecheck_core.new_livecheck_options(ruby_options_spec_l20_d6_args().map_data))
	mut o4 := livecheck_core.new_livecheck_options(ruby_options_spec_l20_d6_args().map_data)
	r4 := o4.merge_in_place(livecheck_core.new_livecheck_options(ruby_options_spec_l20_d6_args().map_data))
	mut o5 := livecheck_core.new_livecheck_options(ruby_options_spec_l20_d6_args().map_data)
	r5 := o5.merge_in_place(livecheck_core.new_livecheck_options(map[string]ruby.Value{}))
	mut o6 := livecheck_core.new_livecheck_options(ruby_options_spec_l20_d6_args().map_data)
	r6 := o6.merge_in_place(livecheck_core.new_livecheck_options(map[string]ruby.Value{}))
	base := livecheck_core.new_livecheck_options(ruby_options_spec_l20_d6_args().map_data)
	return ruby.bool_value(r1.equals(merged) && o1.equals(merged) && r2.equals(merged) && o2.equals(merged) && r3.equals(base) && o3.equals(base) && r4.equals(base) && o4.equals(base) && r5.equals(base) && o5.equals(base) && r6.equals(base) && o6.equals(base))
}

// Ruby it `it "skips over hash values without a corresponding Options value" do` at line 115.
pub fn ruby_options_spec_l115_d17_skips(args ...ruby.Value) ruby.Value {
	base := livecheck_core.new_livecheck_options(ruby_options_spec_l20_d6_args().map_data)
	mut o1 := base
	result := o1.merge_in_place(livecheck_core.new_livecheck_options({
		'nonexistent': ruby.bool_value(true)
	}))
	return ruby.bool_value(result.equals(base) && o1.equals(base) && 'nonexistent' !in o1.values)
}

// Ruby it `it "returns true if all instance variables are the same" do` at line 123.
pub fn ruby_options_spec_l123_d18_returns(args ...ruby.Value) ruby.Value {
	first := livecheck_core.new_livecheck_options(ruby_options_spec_l20_d6_args().map_data)
	second := livecheck_core.new_livecheck_options(ruby_options_spec_l20_d6_args().map_data)
	empty := livecheck_core.new_livecheck_options(map[string]ruby.Value{})
	return ruby.bool_value(first.equals(second) && empty.equals(livecheck_core.new_livecheck_options(map[string]ruby.Value{})))
}

// Ruby it `it "returns false if any instance variables differ" do` at line 133.
pub fn ruby_options_spec_l133_d19_returns(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(!livecheck_core.new_livecheck_options(map[string]ruby.Value{}).equals(livecheck_core.new_livecheck_options(ruby_options_spec_l20_d6_args().map_data)))
}

// Ruby it `it "returns false if other object is not the same class" do` at line 137.
pub fn ruby_options_spec_l137_d20_returns(args ...ruby.Value) ruby.Value {
	result := livecheck_core.ruby_options_l108_d6_anonymous(livecheck_core.livecheck_options_value(livecheck_core.new_livecheck_options(map[string]ruby.Value{})), ruby.Value{ type_name: 'Symbol', repr: 'other' })
	return ruby.bool_value(result.type_name == 'Bool' && !result.bool_data)
}

// Ruby specify `specify do` at line 143.
pub fn ruby_options_spec_l143_d21_do(args ...ruby.Value) ruby.Value {
	empty := livecheck_core.ruby_options_l124_d8_empty(livecheck_core.livecheck_options_value(livecheck_core.new_livecheck_options(map[string]ruby.Value{})))
	present := livecheck_core.ruby_options_l124_d8_empty(ruby_options_spec_l38_d9_base_options())
	return ruby.bool_value(empty.type_name == 'Bool' && empty.bool_data && present.type_name == 'Bool' && !present.bool_data)
}

// Ruby specify `specify do` at line 150.
pub fn ruby_options_spec_l150_d22_do(args ...ruby.Value) ruby.Value {
	empty := livecheck_core.ruby_options_l128_d9_present(livecheck_core.livecheck_options_value(livecheck_core.new_livecheck_options(map[string]ruby.Value{})))
	present := livecheck_core.ruby_options_l128_d9_present(ruby_options_spec_l38_d9_base_options())
	return ruby.bool_value(empty.type_name == 'Bool' && !empty.bool_data && present.type_name == 'Bool' && present.bool_data)
}

fn livecheck_options_maps_equal(left map[string]ruby.Value, right map[string]ruby.Value) bool {
	if left.len != right.len {
		return false
	}
	for key, value in left {
		other := right[key] or { return false }
		if !livecheck_options_values_equal(value, other) {
			return false
		}
	}
	return true
}

fn livecheck_options_values_equal(left ruby.Value, right ruby.Value) bool {
	if left.type_name != right.type_name || left.repr != right.repr || left.bool_data != right.bool_data || left.int_data != right.int_data || left.string_array_data != right.string_array_data || left.array_data.len != right.array_data.len || left.map_data.len != right.map_data.len {
		return false
	}
	for index, value in left.array_data {
		if !livecheck_options_values_equal(value, right.array_data[index]) {
			return false
		}
	}
	return livecheck_options_maps_equal(left.map_data, right.map_data)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "livecheck/options"
// 5:
// 6: RSpec.describe Homebrew::Livecheck::Options do
// 7:   subject(:options) { described_class }
// 8:
// 9:   let(:cookies) { { "cookie_key" => "cookie_value" } }
// 10:   let(:header_string) { "Accept: */*" }
// 11:   let(:referer_url) { "https://example.com/referer" }
// 12:   let(:post_hash) do
// 13:     {
// 14:       empty:   "",
// 15:       boolean: "true",
// 16:       number:  "1",
// 17:       string:  "a + b = c",
// 18:     }
// 19:   end
// 20:   let(:args) do
// 21:     {
// 22:       compressed:    false,
// 23:       cookies:       cookies,
// 24:       header:        header_string,
// 25:       homebrew_curl: true,
// 26:       post_form:     post_hash,
// 27:       post_json:     post_hash,
// 28:       referer:       referer_url,
// 29:       user_agent:    :browser,
// 30:     }
// 31:   end
// 32:   let(:other_args) do
// 33:     {
// 34:       post_form: { something: "else" },
// 35:     }
// 36:   end
// 37:   let(:merged_hash) { args.merge(other_args) }
// 38:   let(:base_options) { options.new(**args) }
// 39:   let(:other_options) { options.new(**other_args) }
// 40:   let(:merged_options) { options.new(**merged_hash) }
// 41:
// 42:   describe "#url_options" do
// 43:     it "returns a Hash of the options that are provided as arguments to the `url` DSL method" do
// 44:       expect(options.new.url_options).to eq({
// 45:         compressed:    nil,
// 46:         cookies:       nil,
// 47:         header:        nil,
// 48:         homebrew_curl: nil,
// 49:         post_form:     nil,
// 50:         post_json:     nil,
// 51:         referer:       nil,
// 52:         user_agent:    nil,
// 53:       })
// 54:     end
// 55:   end
// 56:
// 57:   describe "#to_h" do
// 58:     it "returns a Hash of all instance variables" do
// 59:       # `T::Struct.serialize` omits `nil` values
// 60:       expect(options.new.to_h).to eq({})
// 61:
// 62:       expect(options.new(**args).to_h).to eq(args)
// 63:     end
// 64:   end
// 65:
// 66:   describe "#to_hash" do
// 67:     it "returns a Hash of all instance variables, using String keys" do
// 68:       # `T::Struct.serialize` omits `nil` values
// 69:       expect(options.new.to_hash).to eq({})
// 70:
// 71:       expect(options.new(**args).to_hash).to eq(args.transform_keys(&:to_s))
// 72:     end
// 73:   end
// 74:
// 75:   describe "#merge" do
// 76:     it "returns an Options object with merged values" do
// 77:       expect(options.new(**args).merge(other_args))
// 78:         .to eq(options.new(**merged_hash))
// 79:       expect(options.new(**args).merge(options.new(**other_args)))
// 80:         .to eq(options.new(**merged_hash))
// 81:       expect(options.new(**args).merge(args))
// 82:         .to eq(options.new(**args))
// 83:       expect(options.new(**args).merge({}))
// 84:         .to eq(options.new(**args))
// 85:     end
// 86:   end
// 87:
// 88:   describe "#merge!" do
// 89:     it "merges values from `other` into `self` and returns `self`" do
// 90:       o1 = options.new(**args)
// 91:       expect(o1.merge!(other_options)).to eq(merged_options)
// 92:       expect(o1).to eq(merged_options)
// 93:
// 94:       o2 = options.new(**args)
// 95:       expect(o2.merge!(other_args)).to eq(merged_options)
// 96:       expect(o2).to eq(merged_options)
// 97:
// 98:       o3 = options.new(**args)
// 99:       expect(o3.merge!(base_options)).to eq(base_options)
// 100:       expect(o3).to eq(base_options)
// 101:
// 102:       o4 = options.new(**args)
// 103:       expect(o4.merge!(args)).to eq(base_options)
// 104:       expect(o4).to eq(base_options)
// 105:
// 106:       o5 = options.new(**args)
// 107:       expect(o5.merge!(options.new)).to eq(base_options)
// 108:       expect(o5).to eq(base_options)
// 109:
// 110:       o6 = options.new(**args)
// 111:       expect(o6.merge!({})).to eq(base_options)
// 112:       expect(o6).to eq(base_options)
// 113:     end
// 114:
// 115:     it "skips over hash values without a corresponding Options value" do
// 116:       o1 = options.new(**args)
// 117:       expect(o1.merge!({ nonexistent: true })).to eq(base_options)
// 118:       expect(o1).to eq(base_options)
// 119:     end
// 120:   end
// 121:
// 122:   describe "#==" do
// 123:     it "returns true if all instance variables are the same" do
// 124:       obj_with_args1 = options.new(**args)
// 125:       obj_with_args2 = options.new(**args)
// 126:       expect(obj_with_args1 == obj_with_args2).to be true
// 127:
// 128:       default_obj1 = options.new
// 129:       default_obj2 = options.new
// 130:       expect(default_obj1 == default_obj2).to be true
// 131:     end
// 132:
// 133:     it "returns false if any instance variables differ" do
// 134:       expect(options.new == options.new(**args)).to be false
// 135:     end
// 136:
// 137:     it "returns false if other object is not the same class" do
// 138:       expect(options.new == :other).to be false
// 139:     end
// 140:   end
// 141:
// 142:   describe "#empty?" do
// 143:     specify do
// 144:       expect(options.new.empty?).to be true
// 145:       expect(options.new(**args).empty?).to be false
// 146:     end
// 147:   end
// 148:
// 149:   describe "#present?" do
// 150:     specify do
// 151:       expect(options.new.present?).to be false
// 152:       expect(options.new(**args).present?).to be true
// 153:     end
// 154:   end
// 155: end
