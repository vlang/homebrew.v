module strategy

import brew_runtime

// Translated from Homebrew/brew `test/livecheck/strategy/header_match_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:header_match) { described_class }` at line 7.
pub fn ruby_header_match_spec_l7_d1_header_match(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('header_match', ...args)
}

// Ruby let `let(:http_url) { "https://brew.sh/blog/" }` at line 9.
pub fn ruby_header_match_spec_l9_d2_http_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('http_url', ...args)
}

// Ruby let `let(:non_http_url) { "ftp://brew.sh/" }` at line 10.
pub fn ruby_header_match_spec_l10_d3_non_http_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('non_http_url', ...args)
}

// Ruby let `let(:regexes) do` at line 11.
pub fn ruby_header_match_spec_l11_d4_regexes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('regexes', ...args)
}

// Ruby let `let(:headers) do` at line 18.
pub fn ruby_header_match_spec_l18_d5_headers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('headers', ...args)
}

// Ruby let `let(:matches) do` at line 50.
pub fn ruby_header_match_spec_l50_d6_matches(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('matches', ...args)
}

// Ruby it `it "returns true for an HTTP URL" do` at line 61.
pub fn ruby_header_match_spec_l61_d7_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns false for a non-HTTP URL" do` at line 65.
pub fn ruby_header_match_spec_l65_d8_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns an empty array if headers hash is empty" do` at line 71.
pub fn ruby_header_match_spec_l71_d9_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns an empty array if checked headers do not contain versions" do` at line 75.
pub fn ruby_header_match_spec_l75_d10_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns an array of version strings when given headers" do` at line 79.
pub fn ruby_header_match_spec_l79_d11_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns an array of version strings when given headers and a block" do` at line 96.
pub fn ruby_header_match_spec_l96_d12_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "allows a nil return from a block" do` at line 151.
pub fn ruby_header_match_spec_l151_d13_allows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('allows', ...args)
}

// Ruby it `it "errors on an invalid return type from a block" do` at line 158.
pub fn ruby_header_match_spec_l158_d14_errors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('errors', ...args)
}

// Ruby it `it "errors if the first block argument uses an unhandled name" do` at line 167.
pub fn ruby_header_match_spec_l167_d15_errors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('errors', ...args)
}

// Ruby let `let(:content) do` at line 177.
pub fn ruby_header_match_spec_l177_d16_content(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('content', ...args)
}

// Ruby let `let(:match_data) do` at line 181.
pub fn ruby_header_match_spec_l181_d17_match_data(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('match_data', ...args)
}

// Ruby it `it "finds versions in fetched content" do` at line 195.
pub fn ruby_header_match_spec_l195_d18_finds(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('finds', ...args)
}

// Ruby it `it "finds versions in provided content" do` at line 201.
pub fn ruby_header_match_spec_l201_d19_finds(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('finds', ...args)
}

// Ruby it `it "returns default match_data when url is blank" do` at line 221.
pub fn ruby_header_match_spec_l221_d20_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns default match_data when content is blank" do` at line 226.
pub fn ruby_header_match_spec_l226_d21_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "livecheck/strategy"
// 5:
// 6: RSpec.describe Homebrew::Livecheck::Strategy::HeaderMatch do
// 7:   subject(:header_match) { described_class }
// 8:
// 9:   let(:http_url) { "https://brew.sh/blog/" }
// 10:   let(:non_http_url) { "ftp://brew.sh/" }
// 11:   let(:regexes) do
// 12:     {
// 13:       archive: /filename=brew[._-]v?(\d+(?:\.\d+)+)\.t/i,
// 14:       latest:  %r{.*?/tag/v?(\d+(?:\.\d+)+)$}i,
// 15:       loose:   /v?(\d+(?:\.\d+)+)/i,
// 16:     }
// 17:   end
// 18:   let(:headers) do
// 19:     headers = {
// 20:       content_disposition: {
// 21:         "date"                => "Fri, 01 Jan 2021 01:23:45 GMT",
// 22:         "content-type"        => "application/x-gzip",
// 23:         "content-length"      => "120",
// 24:         "content-disposition" => "attachment; filename=brew-1.2.3.tar.gz",
// 25:       },
// 26:       location:            {
// 27:         "date"           => "Fri, 01 Jan 2021 01:23:45 GMT",
// 28:         "content-type"   => "text/html; charset=utf-8",
// 29:         "location"       => "https://github.com/Homebrew/brew/releases/tag/1.2.4",
// 30:         "content-length" => "117",
// 31:       },
// 32:     }
// 33:     headers[:content_disposition_and_location] = headers[:content_disposition].merge(headers[:location])
// 34:     headers[:no_version] = headers[:content_disposition_and_location].merge({
// 35:       "content-disposition" => "attachment; filename=brew.tar.gz",
// 36:       "location"            => http_url,
// 37:     })
// 38:
// 39:     # Location headers shouldn't appear more than once in an HTTP response but
// 40:     # this is intended to exercise related logic in `versions_from_content`.
// 41:     headers[:location_array] = headers[:location].merge({
// 42:       "location" => [
// 43:         "https://example.com/",
// 44:         "https://github.com/Homebrew/brew/releases/tag/1.2.4",
// 45:       ],
// 46:     })
// 47:
// 48:     headers
// 49:   end
// 50:   let(:matches) do
// 51:     matches = {
// 52:       content_disposition: ["1.2.3"],
// 53:       location:            ["1.2.4"],
// 54:     }
// 55:     matches[:content_disposition_and_location] = matches[:content_disposition] + matches[:location]
// 56:
// 57:     matches
// 58:   end
// 59:
// 60:   describe "::match?" do
// 61:     it "returns true for an HTTP URL" do
// 62:       expect(header_match.match?(http_url)).to be true
// 63:     end
// 64:
// 65:     it "returns false for a non-HTTP URL" do
// 66:       expect(header_match.match?(non_http_url)).to be false
// 67:     end
// 68:   end
// 69:
// 70:   describe "::versions_from_content" do
// 71:     it "returns an empty array if headers hash is empty" do
// 72:       expect(header_match.versions_from_content([{}])).to eq([])
// 73:     end
// 74:
// 75:     it "returns an empty array if checked headers do not contain versions" do
// 76:       expect(header_match.versions_from_content([headers[:no_version]])).to eq([])
// 77:     end
// 78:
// 79:     it "returns an array of version strings when given headers" do
// 80:       expect(header_match.versions_from_content([headers[:content_disposition]])).to eq(matches[:content_disposition])
// 81:       expect(header_match.versions_from_content([headers[:location]])).to eq(matches[:location])
// 82:       expect(header_match.versions_from_content([headers[:content_disposition_and_location]]))
// 83:         .to eq(matches[:content_disposition_and_location])
// 84:       expect(header_match.versions_from_content([headers[:location_array]]))
// 85:         .to eq(matches[:location])
// 86:
// 87:       expect(header_match.versions_from_content([headers[:content_disposition]], regexes[:archive]))
// 88:         .to eq(matches[:content_disposition])
// 89:       expect(header_match.versions_from_content([headers[:location]], regexes[:latest])).to eq(matches[:location])
// 90:       expect(header_match.versions_from_content([headers[:content_disposition_and_location]], regexes[:latest]))
// 91:         .to eq(matches[:location])
// 92:       expect(header_match.versions_from_content([headers[:location_array]], regexes[:latest]))
// 93:         .to eq(matches[:location])
// 94:     end
// 95:
// 96:     it "returns an array of version strings when given headers and a block" do
// 97:       # Returning a string from block, no regex.
// 98:       expect(
// 99:         header_match.versions_from_content([headers[:location]]) do |headers|
// 100:           v = Version.parse(headers["location"], detected_from_url: true)
// 101:           v.null? ? nil : v.to_s
// 102:         end,
// 103:       ).to eq(matches[:location])
// 104:       expect(
// 105:         header_match.versions_from_content([headers[:location]]) do |all_headers|
// 106:           location = all_headers[0]&.[]("location")
// 107:           next unless location
// 108:
// 109:           v = Version.parse(location, detected_from_url: true)
// 110:           v.null? ? nil : v.to_s
// 111:         end,
// 112:       ).to eq(matches[:location])
// 113:
// 114:       # Returning a string from block, explicit regex.
// 115:       expect(
// 116:         header_match.versions_from_content([headers[:location]], regexes[:latest]) do |headers, regex|
// 117:           headers["location"] ? headers["location"][regex, 1] : nil
// 118:         end,
// 119:       ).to eq(matches[:location])
// 120:       expect(
// 121:         header_match.versions_from_content([headers[:location]], regexes[:latest]) do |all_headers, regex|
// 122:           location = all_headers[0]&.[]("location")
// 123:           location ? location[regex, 1] : nil
// 124:         end,
// 125:       ).to eq(matches[:location])
// 126:
// 127:       # Returning an array of strings from block.
// 128:       #
// 129:       # NOTE: Strategies runs `#compact` on an array from a block, so nil values
// 130:       #       are filtered out without needing to use `#compact` in the block.
// 131:       expect(
// 132:         header_match.versions_from_content(
// 133:           [headers[:content_disposition_and_location]],
// 134:           regexes[:loose],
// 135:         ) do |headers, regex|
// 136:           headers.transform_values { |header| header[regex, 1] }.values
// 137:         end,
// 138:       ).to eq(matches[:content_disposition_and_location])
// 139:       expect(
// 140:         header_match.versions_from_content(
// 141:           [headers[:content_disposition_and_location]],
// 142:           regexes[:loose],
// 143:         ) do |all_headers, regex|
// 144:           all_headers.map do |headers|
// 145:             headers.transform_values { |header| header[regex, 1] }.values
// 146:           end.flatten
// 147:         end,
// 148:       ).to eq(matches[:content_disposition_and_location])
// 149:     end
// 150:
// 151:     it "allows a nil return from a block" do
// 152:       expect(header_match.versions_from_content([headers[:location]]) do |headers|
// 153:         _ = headers # To appease `brew style` without modifying arg name
// 154:         next
// 155:       end).to eq([])
// 156:     end
// 157:
// 158:     it "errors on an invalid return type from a block" do
// 159:       expect do
// 160:         header_match.versions_from_content([headers[:location]]) do |headers|
// 161:           _ = headers # To appease `brew style` without modifying arg name
// 162:           123
// 163:         end
// 164:       end.to raise_error(TypeError, Homebrew::Livecheck::Strategy::INVALID_BLOCK_RETURN_VALUE_MSG)
// 165:     end
// 166:
// 167:     it "errors if the first block argument uses an unhandled name" do
// 168:       expect { header_match.versions_from_content([headers[:location]]) { |something| something } }
// 169:         .to raise_error(
// 170:           ArgumentError,
// 171:           "First argument of HeaderMatch `strategy` block must be `headers` or `all_headers`",
// 172:         )
// 173:     end
// 174:   end
// 175:
// 176:   describe "::find_versions" do
// 177:     let(:content) do
// 178:       require "json"
// 179:       JSON.generate([headers[:location]])
// 180:     end
// 181:     let(:match_data) do
// 182:       base = {
// 183:         matches: matches[:location].to_h { |v| [v, Version.new(v)] },
// 184:         regex:   nil,
// 185:         url:     http_url,
// 186:       }
// 187:
// 188:       {
// 189:         fetched:        base.merge({ content: }),
// 190:         cached:         base.merge({ cached: true }),
// 191:         cached_default: base.merge({ matches: {}, cached: true }),
// 192:       }
// 193:     end
// 194:
// 195:     it "finds versions in fetched content" do
// 196:       allow(Homebrew::Livecheck::Strategy).to receive(:page_headers).and_return([headers[:location]])
// 197:
// 198:       expect(header_match.find_versions(url: http_url)).to eq(match_data[:fetched])
// 199:     end
// 200:
// 201:     it "finds versions in provided content" do
// 202:       expect(header_match.find_versions(url: http_url, content:))
// 203:         .to eq(match_data[:cached])
// 204:
// 205:       # This `strategy` block is unnecessary but it's intended to test using a
// 206:       # regex in a `strategy` block.
// 207:       expect(
// 208:         header_match.find_versions(
// 209:           url:     http_url,
// 210:           regex:   regexes[:latest],
// 211:           content:,
// 212:         ) do |headers, regex|
// 213:           match = headers["location"]&.match(regex)
// 214:           next if match.blank?
// 215:
// 216:           match[1]
// 217:         end,
// 218:       ).to eq(match_data[:cached].merge({ regex: regexes[:latest] }))
// 219:     end
// 220:
// 221:     it "returns default match_data when url is blank" do
// 222:       expect(header_match.find_versions(url: "", content:))
// 223:         .to eq(match_data[:cached_default].merge({ url: "" }))
// 224:     end
// 225:
// 226:     it "returns default match_data when content is blank" do
// 227:       expect(header_match.find_versions(url: http_url, content: "[]"))
// 228:         .to eq(match_data[:cached_default])
// 229:       expect(header_match.find_versions(url: http_url, content: "[{}]"))
// 230:         .to eq(match_data[:cached_default])
// 231:     end
// 232:   end
// 233: end
