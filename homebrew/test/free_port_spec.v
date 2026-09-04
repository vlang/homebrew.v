module test

import ruby
import homebrew
import net

// Translated from Homebrew/brew `test/free_port_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:instance) { Object.new.extend(described_class) }` at line 8.
pub fn ruby_free_port_spec_l8_d1_instance(args ...ruby.Value) ruby.Value {
	return ruby.object_value('Homebrew::FreePort', 'instance')
}

// Ruby it `it "returns a free TCP/IP port" do` at line 11.
pub fn ruby_free_port_spec_l11_d2_returns(args ...ruby.Value) ruby.Value {
	port := homebrew.free_port() or { return ruby.bool_value(false) }
	if port < 1024 || port > 65535 {
		return ruby.bool_value(false)
	}
	mut server := net.listen_tcp(.ip, '127.0.0.1:${port}') or {
		return ruby.bool_value(false)
	}
	server.close() or { return ruby.bool_value(false) }
	return ruby.bool_value(true)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "socket"
// 5: require "formula_free_port"
// 6:
// 7: RSpec.describe Homebrew::FreePort do
// 8:   subject(:instance) { Object.new.extend(described_class) }
// 9:
// 10:   describe "#free_port" do
// 11:     it "returns a free TCP/IP port" do
// 12:       # IANA recommends:
// 13:       # - User ports:   1024–49151
// 14:       # - Dynamic ports: 49152–65535
// 15:       # For this test we accept any free port in the full 1024–65535 range.
// 16:       # http://www.iana.org/assignments/port-numbers
// 17:       min_port = 1024
// 18:       max_port = 65535
// 19:       port = instance.free_port
// 20:
// 21:       expect(port).to be_between(min_port, max_port)
// 22:       expect { TCPServer.new(port).close }.not_to raise_error
// 23:     end
// 24:   end
// 25: end
