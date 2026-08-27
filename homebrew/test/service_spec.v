module test

import brew_runtime

// Translated from Homebrew/brew `test/service_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:name) { "formula_name" }` at line 8.
pub fn ruby_service_spec_l8_d1_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby method `stub_formula(&block)` at line 10.
pub fn ruby_service_spec_l10_d2_stub_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stub_formula', ...args)
}

// Ruby method `stub_formula_with_service_sockets(sockets_var)` at line 19.
pub fn ruby_service_spec_l19_d3_stub_formula_with_service_sockets(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stub_formula_with_service_sockets', ...args)
}

// Ruby it `it "returns valid std_service_path_env" do` at line 30.
pub fn ruby_service_spec_l30_d4_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "is available in service blocks" do` at line 50.
pub fn ruby_service_spec_l50_d5_is(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('is', ...args)
}

// Ruby it `it "throws for unexpected type" do` at line 63.
pub fn ruby_service_spec_l63_d6_throws(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('throws', ...args)
}

// Ruby it `it "accepts a valid throttle_interval value" do` at line 79.
pub fn ruby_service_spec_l79_d7_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "includes throttle_interval value in plist output" do` at line 91.
pub fn ruby_service_spec_l91_d8_includes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('includes', ...args)
}

// Ruby it `it "includes throttle_interval value of zero in plist output" do` at line 107.
pub fn ruby_service_spec_l107_d9_includes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('includes', ...args)
}

// Ruby it `it "does not include throttle_interval in plist when not set" do` at line 121.
pub fn ruby_service_spec_l121_d10_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "accepts a valid stop_timeout value" do` at line 135.
pub fn ruby_service_spec_l135_d11_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "throws for negative stop_timeout" do` at line 147.
pub fn ruby_service_spec_l147_d12_throws(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('throws', ...args)
}

// Ruby it `it "includes ExitTimeOut in plist output" do` at line 159.
pub fn ruby_service_spec_l159_d13_includes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('includes', ...args)
}

// Ruby it `it "does not include ExitTimeOut in plist when not set" do` at line 172.
pub fn ruby_service_spec_l172_d14_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "includes TimeoutStopSec in systemd unit output" do` at line 184.
pub fn ruby_service_spec_l184_d15_includes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('includes', ...args)
}

// Ruby it `it "does not include TimeoutStopSec in systemd unit when not set" do` at line 197.
pub fn ruby_service_spec_l197_d16_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "accepts a valid nice level" do` at line 211.
pub fn ruby_service_spec_l211_d17_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "throws error for negative nice values without require_root" do` at line 223.
pub fn ruby_service_spec_l223_d18_throws(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('throws', ...args)
}

// Ruby it `it "allows negative nice values when require_root is set" do` at line 235.
pub fn ruby_service_spec_l235_d19_allows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('allows', ...args)
}

// Ruby it `it "does not require require_root for positive nice values" do` at line 249.
pub fn ruby_service_spec_l249_d20_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "accepts nice value of zero" do` at line 262.
pub fn ruby_service_spec_l262_d21_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "includes nice value in plist output" do` at line 275.
pub fn ruby_service_spec_l275_d22_includes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('includes', ...args)
}

// Ruby it `it "includes nice value in systemd unit output" do` at line 289.
pub fn ruby_service_spec_l289_d23_includes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('includes', ...args)
}

// Ruby it `it "does not include nice in plist when not set" do` at line 303.
pub fn ruby_service_spec_l303_d24_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "does not include nice in systemd unit when not set" do` at line 315.
pub fn ruby_service_spec_l315_d25_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "throws for nice too low" do` at line 327.
pub fn ruby_service_spec_l327_d26_throws(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('throws', ...args)
}

// Ruby it `it "throws for nice too high" do` at line 339.
pub fn ruby_service_spec_l339_d27_throws(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('throws', ...args)
}

// Ruby it `it "throws for unexpected keys" do` at line 353.
pub fn ruby_service_spec_l353_d28_throws(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('throws', ...args)
}

// Ruby it `it "returns status when set" do` at line 369.
pub fn ruby_service_spec_l369_d29_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns status when not set" do` at line 381.
pub fn ruby_service_spec_l381_d30_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "throws for unexpected type" do` at line 394.
pub fn ruby_service_spec_l394_d31_throws(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('throws', ...args)
}

// Ruby let `let(:sockets_type_error_message) { "Service#sockets a formatted socket definition as <type>://<host>:<port>" }` at line 410.
pub fn ruby_service_spec_l410_d32_sockets_type_error_message(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sockets_type_error_message', ...args)
}

// Ruby it `it "throws for missing type" do` at line 412.
pub fn ruby_service_spec_l412_d33_throws(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('throws', ...args)
}

// Ruby it `it "throws for missing host" do` at line 421.
pub fn ruby_service_spec_l421_d34_throws(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('throws', ...args)
}

// Ruby it `it "throws for missing port" do` at line 430.
pub fn ruby_service_spec_l430_d35_throws(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('throws', ...args)
}

// Ruby it `it "throws for invalid host" do` at line 439.
pub fn ruby_service_spec_l439_d36_throws(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('throws', ...args)
}

// Ruby it `it "returns valid manual_command" do` at line 452.
pub fn ruby_service_spec_l452_d37_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns valid manual_command without variables" do` at line 470.
pub fn ruby_service_spec_l470_d38_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns directories needed by service paths" do` at line 490.
pub fn ruby_service_spec_l490_d39_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns valid plist" do` at line 513.
pub fn ruby_service_spec_l513_d40_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns valid plist with socket" do` at line 602.
pub fn ruby_service_spec_l602_d41_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns valid plist with multiple sockets" do` at line 649.
pub fn ruby_service_spec_l649_d42_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns valid partial plist" do` at line 708.
pub fn ruby_service_spec_l708_d43_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns valid partial plist with run_at_load being false" do` at line 745.
pub fn ruby_service_spec_l745_d44_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns valid interval plist" do` at line 783.
pub fn ruby_service_spec_l783_d45_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns valid cron plist" do` at line 823.
pub fn ruby_service_spec_l823_d46_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns valid keepalive-exit plist" do` at line 868.
pub fn ruby_service_spec_l868_d47_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns valid keepalive-crashed plist" do` at line 910.
pub fn ruby_service_spec_l910_d48_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns valid keepalive-path plist" do` at line 952.
pub fn ruby_service_spec_l952_d49_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "expands paths" do` at line 994.
pub fn ruby_service_spec_l994_d50_expands(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('expands', ...args)
}

// Ruby it `it "returns valid unit" do` at line 1040.
pub fn ruby_service_spec_l1040_d51_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns valid partial oneshot unit" do` at line 1089.
pub fn ruby_service_spec_l1089_d52_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "expands paths" do` at line 1114.
pub fn ruby_service_spec_l1114_d53_expands(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('expands', ...args)
}

// Ruby it `it "returns valid unit with keep_alive crashed" do` at line 1139.
pub fn ruby_service_spec_l1139_d54_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns valid unit with keep_alive successful_exit" do` at line 1164.
pub fn ruby_service_spec_l1164_d55_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns valid unit with stop_timeout" do` at line 1189.
pub fn ruby_service_spec_l1189_d56_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns valid unit without restart when keep_alive is false" do` at line 1214.
pub fn ruby_service_spec_l1214_d57_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns valid timer" do` at line 1240.
pub fn ruby_service_spec_l1240_d58_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns valid partial timer" do` at line 1265.
pub fn ruby_service_spec_l1265_d59_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "throws on incomplete cron" do` at line 1289.
pub fn ruby_service_spec_l1289_d60_throws(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('throws', ...args)
}

// Ruby it `it "returns valid cron timers" do` at line 1304.
pub fn ruby_service_spec_l1304_d61_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns false for immediate" do` at line 1344.
pub fn ruby_service_spec_l1344_d62_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns true for interval" do` at line 1356.
pub fn ruby_service_spec_l1356_d63_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns true when keep_alive set to hash" do` at line 1370.
pub fn ruby_service_spec_l1370_d64_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns true when keep_alive set to true" do` at line 1382.
pub fn ruby_service_spec_l1382_d65_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns false when keep_alive not set" do` at line 1394.
pub fn ruby_service_spec_l1394_d66_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns false when keep_alive set to false" do` at line 1405.
pub fn ruby_service_spec_l1405_d67_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns @run data" do` at line 1419.
pub fn ruby_service_spec_l1419_d68_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns @run data" do` at line 1439.
pub fn ruby_service_spec_l1439_d69_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns empty for macOS-only commands" do` at line 1452.
pub fn ruby_service_spec_l1452_d70_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns the Linux command when both OS commands are defined" do` at line 1465.
pub fn ruby_service_spec_l1465_d71_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns @run data" do` at line 1486.
pub fn ruby_service_spec_l1486_d72_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns empty for Linux-only commands" do` at line 1499.
pub fn ruby_service_spec_l1499_d73_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns the macOS command when both OS commands are defined" do` at line 1512.
pub fn ruby_service_spec_l1512_d74_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby let `let(:serialized_hash) do` at line 1528.
pub fn ruby_service_spec_l1528_d75_serialized_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('serialized_hash', ...args)
}

// Ruby it `it "replaces local paths with placeholders" do` at line 1544.
pub fn ruby_service_spec_l1544_d76_replaces(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('replaces', ...args)
}

// Ruby let `let(:serialized_hash) do` at line 1564.
pub fn ruby_service_spec_l1564_d77_serialized_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('serialized_hash', ...args)
}

// Ruby let `let(:deserialized_hash) do` at line 1580.
pub fn ruby_service_spec_l1580_d78_deserialized_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('deserialized_hash', ...args)
}

// Ruby it `it "replaces placeholders with local paths" do` at line 1596.
pub fn ruby_service_spec_l1596_d79_replaces(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('replaces', ...args)
}

// Ruby it `it "handles String argument correctly" do` at line 1601.
pub fn ruby_service_spec_l1601_d80_handles(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('handles', ...args)
}

// Ruby it `it "handles Array argument correctly" do` at line 1609.
pub fn ruby_service_spec_l1609_d81_handles(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('handles', ...args)
}

// Ruby it `it "handles Hash argument correctly" do` at line 1617.
pub fn ruby_service_spec_l1617_d82_handles(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('handles', ...args)
}

// Ruby it `it "handles stop_timeout argument correctly" do` at line 1631.
pub fn ruby_service_spec_l1631_d83_handles(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('handles', ...args)
}

// Ruby it `it "returns formula vars when no env override file exists" do` at line 1644.
pub fn ruby_service_spec_l1644_d84_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "merges user env overrides with formula vars" do` at line 1656.
pub fn ruby_service_spec_l1656_d85_merges(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('merges', ...args)
}

// Ruby it `it "user env overrides take precedence over formula vars" do` at line 1677.
pub fn ruby_service_spec_l1677_d86_user(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('user', ...args)
}

// Ruby it `it "ignores comments and blank lines in env file" do` at line 1698.
pub fn ruby_service_spec_l1698_d87_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ignores', ...args)
}

// Ruby it `it "skips lines without = and strips whitespace around =" do` at line 1723.
pub fn ruby_service_spec_l1723_d88_skips(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skips', ...args)
}

// Ruby it `it "includes user env overrides in to_plist" do` at line 1753.
pub fn ruby_service_spec_l1753_d89_includes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('includes', ...args)
}

// Ruby it `it "includes user env overrides in to_systemd_unit" do` at line 1777.
pub fn ruby_service_spec_l1777_d90_includes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('includes', ...args)
}

// Ruby it `it "skips world-writable env files" do` at line 1799.
pub fn ruby_service_spec_l1799_d91_skips(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skips', ...args)
}

// Ruby it `it "skips group-writable env files" do` at line 1820.
pub fn ruby_service_spec_l1820_d92_skips(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skips', ...args)
}

// Ruby it `it "follows symlinks to a safe target" do` at line 1841.
pub fn ruby_service_spec_l1841_d93_follows(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('follows', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "formula"
// 5: require "service"
// 6:
// 7: RSpec.describe Homebrew::Service do
// 8:   let(:name) { "formula_name" }
// 9:
// 10:   def stub_formula(&block)
// 11:     formula(name) do
// 12:       T.bind(self, T.class_of(Formula))
// 13:       url "https://brew.sh/test-1.0.tbz"
// 14:
// 15:       instance_eval(&block) if block
// 16:     end
// 17:   end
// 18:
// 19:   def stub_formula_with_service_sockets(sockets_var)
// 20:     stub_formula do
// 21:       T.bind(self, T.class_of(Formula))
// 22:       service do
// 23:         run opt_bin/"beanstalkd"
// 24:         sockets sockets_var
// 25:       end
// 26:     end
// 27:   end
// 28:
// 29:   describe "#std_service_path_env" do
// 30:     it "returns valid std_service_path_env" do
// 31:       f = stub_formula do
// 32:         T.bind(self, T.class_of(Formula))
// 33:         service do
// 34:           run opt_bin/"beanstalkd"
// 35:           run_type :immediate
// 36:           environment_variables PATH: std_service_path_env
// 37:           error_log_path var/"log/beanstalkd.error.log"
// 38:           log_path var/"log/beanstalkd.log"
// 39:           working_dir var
// 40:           keep_alive true
// 41:         end
// 42:       end
// 43:
// 44:       path = f.service.std_service_path_env
// 45:       expect(path).to eq("#{HOMEBREW_PREFIX}/bin:#{HOMEBREW_PREFIX}/sbin:/usr/bin:/bin:/usr/sbin:/sbin")
// 46:     end
// 47:   end
// 48:
// 49:   describe "#formula_opt_bin" do
// 50:     it "is available in service blocks" do
// 51:       f = stub_formula do
// 52:         T.bind(self, T.class_of(Formula))
// 53:         service do
// 54:           run formula_opt_bin("foo")/"foo"
// 55:         end
// 56:       end
// 57:
// 58:       expect(f.service.run).to eq([(HOMEBREW_PREFIX/"opt/foo/bin/foo").to_s])
// 59:     end
// 60:   end
// 61:
// 62:   describe "#process_type" do
// 63:     it "throws for unexpected type" do
// 64:       f = stub_formula do
// 65:         T.bind(self, T.class_of(Formula))
// 66:         service do
// 67:           run opt_bin/"beanstalkd"
// 68:           process_type :cow
// 69:         end
// 70:       end
// 71:
// 72:       expect do
// 73:         f.service.manual_command
// 74:       end.to raise_error TypeError, "Service#process_type allows: 'background'/'standard'/'interactive'/'adaptive'"
// 75:     end
// 76:   end
// 77:
// 78:   describe "#throttle_interval" do
// 79:     it "accepts a valid throttle_interval value" do
// 80:       f = stub_formula do
// 81:         T.bind(self, T.class_of(Formula))
// 82:         service do
// 83:           run opt_bin/"beanstalkd"
// 84:           throttle_interval 5
// 85:         end
// 86:       end
// 87:
// 88:       expect(f.service.throttle_interval).to be(5)
// 89:     end
// 90:
// 91:     it "includes throttle_interval value in plist output" do
// 92:       f = stub_formula do
// 93:         T.bind(self, T.class_of(Formula))
// 94:         service do
// 95:           run opt_bin/"beanstalkd"
// 96:           throttle_interval 15
// 97:         end
// 98:       end
// 99:
// 100:       plist = f.service.to_plist
// 101:       expect(plist).to include("<key>ThrottleInterval</key>")
// 102:       expect(plist).to include("<integer>15</integer>")
// 103:     end
// 104:
// 105:     # Launchd says that it ignores ThrottleInterval values of zero but it's not actually true.
// 106:     # https://gist.github.com/dabrahams/4092951#:~:text=Set%20%3CThrottleInterval%3E%20to,than%2010%20seconds.
// 107:     it "includes throttle_interval value of zero in plist output" do
// 108:       f = stub_formula do
// 109:         T.bind(self, T.class_of(Formula))
// 110:         service do
// 111:           run opt_bin/"beanstalkd"
// 112:           throttle_interval 0
// 113:         end
// 114:       end
// 115:
// 116:       plist = f.service.to_plist
// 117:       expect(plist).to include("<key>ThrottleInterval</key>")
// 118:       expect(plist).to include("<integer>0</integer>")
// 119:     end
// 120:
// 121:     it "does not include throttle_interval in plist when not set" do
// 122:       f = stub_formula do
// 123:         T.bind(self, T.class_of(Formula))
// 124:         service do
// 125:           run opt_bin/"beanstalkd"
// 126:         end
// 127:       end
// 128:
// 129:       plist = f.service.to_plist
// 130:       expect(plist).not_to include("<key>ThrottleInterval</key>")
// 131:     end
// 132:   end
// 133:
// 134:   describe "#stop_timeout" do
// 135:     it "accepts a valid stop_timeout value" do
// 136:       f = stub_formula do
// 137:         T.bind(self, T.class_of(Formula))
// 138:         service do
// 139:           run opt_bin/"beanstalkd"
// 140:           stop_timeout 10
// 141:         end
// 142:       end
// 143:
// 144:       expect(f.service.stop_timeout).to be(10)
// 145:     end
// 146:
// 147:     it "throws for negative stop_timeout" do
// 148:       expect do
// 149:         stub_formula do
// 150:           T.bind(self, T.class_of(Formula))
// 151:           service do
// 152:             run opt_bin/"beanstalkd"
// 153:             stop_timeout(-5)
// 154:           end
// 155:         end.service
// 156:       end.to raise_error TypeError, "Service#stop_timeout must be a non-negative integer"
// 157:     end
// 158:
// 159:     it "includes ExitTimeOut in plist output" do
// 160:       f = stub_formula do
// 161:         T.bind(self, T.class_of(Formula))
// 162:         service do
// 163:           run opt_bin/"beanstalkd"
// 164:           stop_timeout 15
// 165:         end
// 166:       end
// 167:
// 168:       plist = f.service.to_plist
// 169:       expect(plist).to include("<key>ExitTimeOut</key>\n\t<integer>15</integer>")
// 170:     end
// 171:
// 172:     it "does not include ExitTimeOut in plist when not set" do
// 173:       f = stub_formula do
// 174:         T.bind(self, T.class_of(Formula))
// 175:         service do
// 176:           run opt_bin/"beanstalkd"
// 177:         end
// 178:       end
// 179:
// 180:       plist = f.service.to_plist
// 181:       expect(plist).not_to include("<key>ExitTimeOut</key>")
// 182:     end
// 183:
// 184:     it "includes TimeoutStopSec in systemd unit output" do
// 185:       f = stub_formula do
// 186:         T.bind(self, T.class_of(Formula))
// 187:         service do
// 188:           run opt_bin/"beanstalkd"
// 189:           stop_timeout 20
// 190:         end
// 191:       end
// 192:
// 193:       unit = f.service.to_systemd_unit
// 194:       expect(unit).to include("TimeoutStopSec=20")
// 195:     end
// 196:
// 197:     it "does not include TimeoutStopSec in systemd unit when not set" do
// 198:       f = stub_formula do
// 199:         T.bind(self, T.class_of(Formula))
// 200:         service do
// 201:           run opt_bin/"beanstalkd"
// 202:         end
// 203:       end
// 204:
// 205:       unit = f.service.to_systemd_unit
// 206:       expect(unit).not_to include("TimeoutStopSec=")
// 207:     end
// 208:   end
// 209:
// 210:   describe "#nice" do
// 211:     it "accepts a valid nice level" do
// 212:       f = stub_formula do
// 213:         T.bind(self, T.class_of(Formula))
// 214:         service do
// 215:           run opt_bin/"beanstalkd"
// 216:           nice 5
// 217:         end
// 218:       end
// 219:
// 220:       expect(f.service.nice).to be(5)
// 221:     end
// 222:
// 223:     it "throws error for negative nice values without require_root" do
// 224:       expect do
// 225:         stub_formula do
// 226:           T.bind(self, T.class_of(Formula))
// 227:           service do
// 228:             run opt_bin/"beanstalkd"
// 229:             nice(-10)
// 230:           end
// 231:         end.service
// 232:       end.to raise_error TypeError, "Service#nice: require_root true is required for negative nice values"
// 233:     end
// 234:
// 235:     it "allows negative nice values when require_root is set" do
// 236:       f = stub_formula do
// 237:         T.bind(self, T.class_of(Formula))
// 238:         service do
// 239:           run opt_bin/"beanstalkd"
// 240:           require_root true
// 241:           nice(-10)
// 242:         end
// 243:       end
// 244:
// 245:       expect(f.service.requires_root?).to be(true)
// 246:       expect { f.service.to_plist }.not_to raise_error
// 247:     end
// 248:
// 249:     it "does not require require_root for positive nice values" do
// 250:       f = stub_formula do
// 251:         T.bind(self, T.class_of(Formula))
// 252:         service do
// 253:           run opt_bin/"beanstalkd"
// 254:           nice 10
// 255:         end
// 256:       end
// 257:
// 258:       expect(f.service.requires_root?).to be(false)
// 259:       expect { f.service.to_plist }.not_to raise_error
// 260:     end
// 261:
// 262:     it "accepts nice value of zero" do
// 263:       f = stub_formula do
// 264:         T.bind(self, T.class_of(Formula))
// 265:         service do
// 266:           run opt_bin/"beanstalkd"
// 267:           nice 0
// 268:         end
// 269:       end
// 270:
// 271:       expect(f.service.nice).to be(0)
// 272:       expect(f.service.requires_root?).to be(false)
// 273:     end
// 274:
// 275:     it "includes nice value in plist output" do
// 276:       f = stub_formula do
// 277:         T.bind(self, T.class_of(Formula))
// 278:         service do
// 279:           run opt_bin/"beanstalkd"
// 280:           nice 5
// 281:         end
// 282:       end
// 283:
// 284:       plist = f.service.to_plist
// 285:       expect(plist).to include("<key>Nice</key>")
// 286:       expect(plist).to include("<integer>5</integer>")
// 287:     end
// 288:
// 289:     it "includes nice value in systemd unit output" do
// 290:       f = stub_formula do
// 291:         T.bind(self, T.class_of(Formula))
// 292:         service do
// 293:           run opt_bin/"beanstalkd"
// 294:           require_root true
// 295:           nice(-5)
// 296:         end
// 297:       end
// 298:
// 299:       unit = f.service.to_systemd_unit
// 300:       expect(unit).to include("Nice=-5")
// 301:     end
// 302:
// 303:     it "does not include nice in plist when not set" do
// 304:       f = stub_formula do
// 305:         T.bind(self, T.class_of(Formula))
// 306:         service do
// 307:           run opt_bin/"beanstalkd"
// 308:         end
// 309:       end
// 310:
// 311:       plist = f.service.to_plist
// 312:       expect(plist).not_to include("<key>Nice</key>")
// 313:     end
// 314:
// 315:     it "does not include nice in systemd unit when not set" do
// 316:       f = stub_formula do
// 317:         T.bind(self, T.class_of(Formula))
// 318:         service do
// 319:           run opt_bin/"beanstalkd"
// 320:         end
// 321:       end
// 322:
// 323:       unit = f.service.to_systemd_unit
// 324:       expect(unit).not_to include("Nice=")
// 325:     end
// 326:
// 327:     it "throws for nice too low" do
// 328:       expect do
// 329:         stub_formula do
// 330:           T.bind(self, T.class_of(Formula))
// 331:           service do
// 332:             run opt_bin/"beanstalkd"
// 333:             nice(-21)
// 334:           end
// 335:         end.service
// 336:       end.to raise_error TypeError, "Service#nice value should be in -20..19"
// 337:     end
// 338:
// 339:     it "throws for nice too high" do
// 340:       expect do
// 341:         stub_formula do
// 342:           T.bind(self, T.class_of(Formula))
// 343:           service do
// 344:             run opt_bin/"beanstalkd"
// 345:             nice 20
// 346:           end
// 347:         end.service
// 348:       end.to raise_error TypeError, "Service#nice value should be in -20..19"
// 349:     end
// 350:   end
// 351:
// 352:   describe "#keep_alive" do
// 353:     it "throws for unexpected keys" do
// 354:       f = stub_formula do
// 355:         T.bind(self, T.class_of(Formula))
// 356:         service do
// 357:           run opt_bin/"beanstalkd"
// 358:           keep_alive test: "key"
// 359:         end
// 360:       end
// 361:
// 362:       expect do
// 363:         f.service.manual_command
// 364:       end.to raise_error TypeError, "Service#keep_alive only allows: [:always, :successful_exit, :crashed, :path]"
// 365:     end
// 366:   end
// 367:
// 368:   describe "#requires_root?" do
// 369:     it "returns status when set" do
// 370:       f = stub_formula do
// 371:         T.bind(self, T.class_of(Formula))
// 372:         service do
// 373:           run opt_bin/"beanstalkd"
// 374:           require_root true
// 375:         end
// 376:       end
// 377:
// 378:       expect(f.service.requires_root?).to be(true)
// 379:     end
// 380:
// 381:     it "returns status when not set" do
// 382:       f = stub_formula do
// 383:         T.bind(self, T.class_of(Formula))
// 384:         service do
// 385:           run opt_bin/"beanstalkd"
// 386:         end
// 387:       end
// 388:
// 389:       expect(f.service.requires_root?).to be(false)
// 390:     end
// 391:   end
// 392:
// 393:   describe "#run_type" do
// 394:     it "throws for unexpected type" do
// 395:       f = stub_formula do
// 396:         T.bind(self, T.class_of(Formula))
// 397:         service do
// 398:           run opt_bin/"beanstalkd"
// 399:           run_type :cow
// 400:         end
// 401:       end
// 402:
// 403:       expect do
// 404:         f.service.manual_command
// 405:       end.to raise_error TypeError, "Service#run_type allows: 'immediate'/'interval'/'cron'"
// 406:     end
// 407:   end
// 408:
// 409:   describe "#sockets" do
// 410:     let(:sockets_type_error_message) { "Service#sockets a formatted socket definition as <type>://<host>:<port>" }
// 411:
// 412:     it "throws for missing type" do
// 413:       [
// 414:         stub_formula_with_service_sockets("127.0.0.1:80"),
// 415:         stub_formula_with_service_sockets({ socket: "127.0.0.1:80" }),
// 416:       ].each do |f|
// 417:         expect { f.service.manual_command }.to raise_error TypeError, sockets_type_error_message
// 418:       end
// 419:     end
// 420:
// 421:     it "throws for missing host" do
// 422:       [
// 423:         stub_formula_with_service_sockets("tcp://:80"),
// 424:         stub_formula_with_service_sockets({ socket: "tcp://:80" }),
// 425:       ].each do |f|
// 426:         expect { f.service.manual_command }.to raise_error TypeError, sockets_type_error_message
// 427:       end
// 428:     end
// 429:
// 430:     it "throws for missing port" do
// 431:       [
// 432:         stub_formula_with_service_sockets("tcp://127.0.0.1"),
// 433:         stub_formula_with_service_sockets({ socket: "tcp://127.0.0.1" }),
// 434:       ].each do |f|
// 435:         expect { f.service.manual_command }.to raise_error TypeError, sockets_type_error_message
// 436:       end
// 437:     end
// 438:
// 439:     it "throws for invalid host" do
// 440:       [
// 441:         stub_formula_with_service_sockets("tcp://300.0.0.1:80"),
// 442:         stub_formula_with_service_sockets({ socket: "tcp://300.0.0.1:80" }),
// 443:       ].each do |f|
// 444:         expect do
// 445:           f.service.manual_command
// 446:         end.to raise_error TypeError, "Service#sockets expects a valid ipv4 or ipv6 host address"
// 447:       end
// 448:     end
// 449:   end
// 450:
// 451:   describe "#manual_command" do
// 452:     it "returns valid manual_command" do
// 453:       f = stub_formula do
// 454:         T.bind(self, T.class_of(Formula))
// 455:         service do
// 456:           run "#{HOMEBREW_PREFIX}/bin/beanstalkd"
// 457:           run_type :immediate
// 458:           environment_variables PATH: std_service_path_env, ETC_DIR: etc/"beanstalkd"
// 459:           error_log_path var/"log/beanstalkd.error.log"
// 460:           log_path var/"log/beanstalkd.log"
// 461:           working_dir var
// 462:           keep_alive true
// 463:         end
// 464:       end
// 465:
// 466:       path = f.service.manual_command
// 467:       expect(path).to eq("ETC_DIR=\"#{HOMEBREW_PREFIX}/etc/beanstalkd\" #{HOMEBREW_PREFIX}/bin/beanstalkd")
// 468:     end
// 469:
// 470:     it "returns valid manual_command without variables" do
// 471:       f = stub_formula do
// 472:         T.bind(self, T.class_of(Formula))
// 473:         service do
// 474:           run opt_bin/"beanstalkd"
// 475:           run_type :immediate
// 476:           environment_variables PATH: std_service_path_env
// 477:           error_log_path var/"log/beanstalkd.error.log"
// 478:           log_path var/"log/beanstalkd.log"
// 479:           working_dir var
// 480:           keep_alive true
// 481:         end
// 482:       end
// 483:
// 484:       path = f.service.manual_command
// 485:       expect(path).to eq("#{HOMEBREW_PREFIX}/opt/formula_name/bin/beanstalkd")
// 486:     end
// 487:   end
// 488:
// 489:   describe "#path_dirs" do
// 490:     it "returns directories needed by service paths" do
// 491:       f = stub_formula do
// 492:         T.bind(self, T.class_of(Formula))
// 493:         service do
// 494:           run [opt_bin/"beanstalkd", "-l", var/"run/beanstalkd.sock", "relative/path"]
// 495:           error_log_path var/"log/beanstalkd.error.log"
// 496:           log_path var/"log/beanstalkd.log"
// 497:           input_path var/"in/beanstalkd"
// 498:           root_dir var/"root"
// 499:           working_dir var/"work"
// 500:         end
// 501:       end
// 502:
// 503:       expect(f.service.path_dirs).to contain_exactly(
// 504:         HOMEBREW_PREFIX/"var/log",
// 505:         HOMEBREW_PREFIX/"var/in",
// 506:         HOMEBREW_PREFIX/"var/root",
// 507:         HOMEBREW_PREFIX/"var/work",
// 508:       )
// 509:     end
// 510:   end
// 511:
// 512:   describe "#to_plist" do
// 513:     it "returns valid plist" do
// 514:       f = stub_formula do
// 515:         T.bind(self, T.class_of(Formula))
// 516:         service do
// 517:           run [opt_bin/"beanstalkd", "test"]
// 518:           run_type :immediate
// 519:           environment_variables PATH: std_service_path_env, FOO: "BAR", ETC_DIR: etc/"beanstalkd"
// 520:           error_log_path var/"log/beanstalkd.error.log"
// 521:           log_path var/"log/beanstalkd.log"
// 522:           input_path var/"in/beanstalkd"
// 523:           require_root true
// 524:           root_dir var
// 525:           working_dir var
// 526:           keep_alive true
// 527:           launch_only_once true
// 528:           process_type :interactive
// 529:           restart_delay 30
// 530:           throttle_interval 5
// 531:           stop_timeout 60
// 532:           nice 5
// 533:           interval 5
// 534:           macos_legacy_timers true
// 535:         end
// 536:       end
// 537:
// 538:       plist = f.service.to_plist
// 539:       plist_expect = <<~XML
// 540:         <?xml version="1.0" encoding="UTF-8"?>
// 541:         <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
// 542:         <plist version="1.0">
// 543:         <dict>
// 544:         \t<key>EnvironmentVariables</key>
// 545:         \t<dict>
// 546:         \t\t<key>ETC_DIR</key>
// 547:         \t\t<string>#{HOMEBREW_PREFIX}/etc/beanstalkd</string>
// 548:         \t\t<key>FOO</key>
// 549:         \t\t<string>BAR</string>
// 550:         \t\t<key>PATH</key>
// 551:         \t\t<string>#{HOMEBREW_PREFIX}/bin:#{HOMEBREW_PREFIX}/sbin:/usr/bin:/bin:/usr/sbin:/sbin</string>
// 552:         \t</dict>
// 553:         \t<key>ExitTimeOut</key>
// 554:         \t<integer>60</integer>
// 555:         \t<key>KeepAlive</key>
// 556:         \t<true/>
// 557:         \t<key>Label</key>
// 558:         \t<string>homebrew.mxcl.formula_name</string>
// 559:         \t<key>LaunchOnlyOnce</key>
// 560:         \t<true/>
// 561:         \t<key>LegacyTimers</key>
// 562:         \t<true/>
// 563:         \t<key>LimitLoadToSessionType</key>
// 564:         \t<array>
// 565:         \t\t<string>Aqua</string>
// 566:         \t\t<string>Background</string>
// 567:         \t\t<string>LoginWindow</string>
// 568:         \t\t<string>StandardIO</string>
// 569:         \t\t<string>System</string>
// 570:         \t</array>
// 571:         \t<key>Nice</key>
// 572:         \t<integer>5</integer>
// 573:         \t<key>ProcessType</key>
// 574:         \t<string>Interactive</string>
// 575:         \t<key>ProgramArguments</key>
// 576:         \t<array>
// 577:         \t\t<string>#{HOMEBREW_PREFIX}/opt/formula_name/bin/beanstalkd</string>
// 578:         \t\t<string>test</string>
// 579:         \t</array>
// 580:         \t<key>RootDirectory</key>
// 581:         \t<string>#{HOMEBREW_PREFIX}/var</string>
// 582:         \t<key>RunAtLoad</key>
// 583:         \t<true/>
// 584:         \t<key>StandardErrorPath</key>
// 585:         \t<string>#{HOMEBREW_PREFIX}/var/log/beanstalkd.error.log</string>
// 586:         \t<key>StandardInPath</key>
// 587:         \t<string>#{HOMEBREW_PREFIX}/var/in/beanstalkd</string>
// 588:         \t<key>StandardOutPath</key>
// 589:         \t<string>#{HOMEBREW_PREFIX}/var/log/beanstalkd.log</string>
// 590:         \t<key>ThrottleInterval</key>
// 591:         \t<integer>5</integer>
// 592:         \t<key>TimeOut</key>
// 593:         \t<integer>30</integer>
// 594:         \t<key>WorkingDirectory</key>
// 595:         \t<string>#{HOMEBREW_PREFIX}/var</string>
// 596:         </dict>
// 597:         </plist>
// 598:       XML
// 599:       expect(plist).to eq(plist_expect)
// 600:     end
// 601:
// 602:     it "returns valid plist with socket" do
// 603:       plist_expect = <<~XML
// 604:         <?xml version="1.0" encoding="UTF-8"?>
// 605:         <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
// 606:         <plist version="1.0">
// 607:         <dict>
// 608:         \t<key>Label</key>
// 609:         \t<string>homebrew.mxcl.formula_name</string>
// 610:         \t<key>LimitLoadToSessionType</key>
// 611:         \t<array>
// 612:         \t\t<string>Aqua</string>
// 613:         \t\t<string>Background</string>
// 614:         \t\t<string>LoginWindow</string>
// 615:         \t\t<string>StandardIO</string>
// 616:         \t\t<string>System</string>
// 617:         \t</array>
// 618:         \t<key>ProgramArguments</key>
// 619:         \t<array>
// 620:         \t\t<string>#{HOMEBREW_PREFIX}/opt/formula_name/bin/beanstalkd</string>
// 621:         \t</array>
// 622:         \t<key>RunAtLoad</key>
// 623:         \t<true/>
// 624:         \t<key>Sockets</key>
// 625:         \t<dict>
// 626:         \t\t<key>listeners</key>
// 627:         \t\t<dict>
// 628:         \t\t\t<key>SockNodeName</key>
// 629:         \t\t\t<string>127.0.0.1</string>
// 630:         \t\t\t<key>SockProtocol</key>
// 631:         \t\t\t<string>TCP</string>
// 632:         \t\t\t<key>SockServiceName</key>
// 633:         \t\t\t<string>80</string>
// 634:         \t\t</dict>
// 635:         \t</dict>
// 636:         </dict>
// 637:         </plist>
// 638:       XML
// 639:
// 640:       [
// 641:         stub_formula_with_service_sockets("tcp://127.0.0.1:80"),
// 642:         stub_formula_with_service_sockets({ listeners: "tcp://127.0.0.1:80" }),
// 643:       ].each do |f|
// 644:         plist = f.service.to_plist
// 645:         expect(plist).to eq(plist_expect)
// 646:       end
// 647:     end
// 648:
// 649:     it "returns valid plist with multiple sockets" do
// 650:       f = stub_formula do
// 651:         T.bind(self, T.class_of(Formula))
// 652:         service do
// 653:           run [opt_bin/"beanstalkd", "test"]
// 654:           sockets socket: "tcp://0.0.0.0:80", socket_tls: "tcp://0.0.0.0:443"
// 655:         end
// 656:       end
// 657:
// 658:       plist = f.service.to_plist
// 659:       plist_expect = <<~XML
// 660:         <?xml version="1.0" encoding="UTF-8"?>
// 661:         <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
// 662:         <plist version="1.0">
// 663:         <dict>
// 664:         \t<key>Label</key>
// 665:         \t<string>homebrew.mxcl.formula_name</string>
// 666:         \t<key>LimitLoadToSessionType</key>
// 667:         \t<array>
// 668:         \t\t<string>Aqua</string>
// 669:         \t\t<string>Background</string>
// 670:         \t\t<string>LoginWindow</string>
// 671:         \t\t<string>StandardIO</string>
// 672:         \t\t<string>System</string>
// 673:         \t</array>
// 674:         \t<key>ProgramArguments</key>
// 675:         \t<array>
// 676:         \t\t<string>#{HOMEBREW_PREFIX}/opt/formula_name/bin/beanstalkd</string>
// 677:         \t\t<string>test</string>
// 678:         \t</array>
// 679:         \t<key>RunAtLoad</key>
// 680:         \t<true/>
// 681:         \t<key>Sockets</key>
// 682:         \t<dict>
// 683:         \t\t<key>socket</key>
// 684:         \t\t<dict>
// 685:         \t\t\t<key>SockNodeName</key>
// 686:         \t\t\t<string>0.0.0.0</string>
// 687:         \t\t\t<key>SockProtocol</key>
// 688:         \t\t\t<string>TCP</string>
// 689:         \t\t\t<key>SockServiceName</key>
// 690:         \t\t\t<string>80</string>
// 691:         \t\t</dict>
// 692:         \t\t<key>socket_tls</key>
// 693:         \t\t<dict>
// 694:         \t\t\t<key>SockNodeName</key>
// 695:         \t\t\t<string>0.0.0.0</string>
// 696:         \t\t\t<key>SockProtocol</key>
// 697:         \t\t\t<string>TCP</string>
// 698:         \t\t\t<key>SockServiceName</key>
// 699:         \t\t\t<string>443</string>
// 700:         \t\t</dict>
// 701:         \t</dict>
// 702:         </dict>
// 703:         </plist>
// 704:       XML
// 705:       expect(plist).to eq(plist_expect)
// 706:     end
// 707:
// 708:     it "returns valid partial plist" do
// 709:       f = stub_formula do
// 710:         T.bind(self, T.class_of(Formula))
// 711:         service do
// 712:           run opt_bin/"beanstalkd"
// 713:           run_type :immediate
// 714:         end
// 715:       end
// 716:
// 717:       plist = f.service.to_plist
// 718:       plist_expect = <<~XML
// 719:         <?xml version="1.0" encoding="UTF-8"?>
// 720:         <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
// 721:         <plist version="1.0">
// 722:         <dict>
// 723:         \t<key>Label</key>
// 724:         \t<string>homebrew.mxcl.formula_name</string>
// 725:         \t<key>LimitLoadToSessionType</key>
// 726:         \t<array>
// 727:         \t\t<string>Aqua</string>
// 728:         \t\t<string>Background</string>
// 729:         \t\t<string>LoginWindow</string>
// 730:         \t\t<string>StandardIO</string>
// 731:         \t\t<string>System</string>
// 732:         \t</array>
// 733:         \t<key>ProgramArguments</key>
// 734:         \t<array>
// 735:         \t\t<string>#{HOMEBREW_PREFIX}/opt/formula_name/bin/beanstalkd</string>
// 736:         \t</array>
// 737:         \t<key>RunAtLoad</key>
// 738:         \t<true/>
// 739:         </dict>
// 740:         </plist>
// 741:       XML
// 742:       expect(plist).to eq(plist_expect)
// 743:     end
// 744:
// 745:     it "returns valid partial plist with run_at_load being false" do
// 746:       f = stub_formula do
// 747:         T.bind(self, T.class_of(Formula))
// 748:         service do
// 749:           run opt_bin/"beanstalkd"
// 750:           run_type :immediate
// 751:           run_at_load false
// 752:         end
// 753:       end
// 754:
// 755:       plist = f.service.to_plist
// 756:       plist_expect = <<~XML
// 757:         <?xml version="1.0" encoding="UTF-8"?>
// 758:         <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
// 759:         <plist version="1.0">
// 760:         <dict>
// 761:         \t<key>Label</key>
// 762:         \t<string>homebrew.mxcl.formula_name</string>
// 763:         \t<key>LimitLoadToSessionType</key>
// 764:         \t<array>
// 765:         \t\t<string>Aqua</string>
// 766:         \t\t<string>Background</string>
// 767:         \t\t<string>LoginWindow</string>
// 768:         \t\t<string>StandardIO</string>
// 769:         \t\t<string>System</string>
// 770:         \t</array>
// 771:         \t<key>ProgramArguments</key>
// 772:         \t<array>
// 773:         \t\t<string>#{HOMEBREW_PREFIX}/opt/formula_name/bin/beanstalkd</string>
// 774:         \t</array>
// 775:         \t<key>RunAtLoad</key>
// 776:         \t<false/>
// 777:         </dict>
// 778:         </plist>
// 779:       XML
// 780:       expect(plist).to eq(plist_expect)
// 781:     end
// 782:
// 783:     it "returns valid interval plist" do
// 784:       f = stub_formula do
// 785:         T.bind(self, T.class_of(Formula))
// 786:         service do
// 787:           run opt_bin/"beanstalkd"
// 788:           run_type :interval
// 789:           interval 5
// 790:         end
// 791:       end
// 792:
// 793:       plist = f.service.to_plist
// 794:       plist_expect = <<~XML
// 795:         <?xml version="1.0" encoding="UTF-8"?>
// 796:         <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
// 797:         <plist version="1.0">
// 798:         <dict>
// 799:         \t<key>Label</key>
// 800:         \t<string>homebrew.mxcl.formula_name</string>
// 801:         \t<key>LimitLoadToSessionType</key>
// 802:         \t<array>
// 803:         \t\t<string>Aqua</string>
// 804:         \t\t<string>Background</string>
// 805:         \t\t<string>LoginWindow</string>
// 806:         \t\t<string>StandardIO</string>
// 807:         \t\t<string>System</string>
// 808:         \t</array>
// 809:         \t<key>ProgramArguments</key>
// 810:         \t<array>
// 811:         \t\t<string>#{HOMEBREW_PREFIX}/opt/formula_name/bin/beanstalkd</string>
// 812:         \t</array>
// 813:         \t<key>RunAtLoad</key>
// 814:         \t<true/>
// 815:         \t<key>StartInterval</key>
// 816:         \t<integer>5</integer>
// 817:         </dict>
// 818:         </plist>
// 819:       XML
// 820:       expect(plist).to eq(plist_expect)
// 821:     end
// 822:
// 823:     it "returns valid cron plist" do
// 824:       f = stub_formula do
// 825:         T.bind(self, T.class_of(Formula))
// 826:         service do
// 827:           run opt_bin/"beanstalkd"
// 828:           run_type :cron
// 829:           cron "@daily"
// 830:         end
// 831:       end
// 832:
// 833:       plist = f.service.to_plist
// 834:       plist_expect = <<~XML
// 835:         <?xml version="1.0" encoding="UTF-8"?>
// 836:         <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
// 837:         <plist version="1.0">
// 838:         <dict>
// 839:         \t<key>Label</key>
// 840:         \t<string>homebrew.mxcl.formula_name</string>
// 841:         \t<key>LimitLoadToSessionType</key>
// 842:         \t<array>
// 843:         \t\t<string>Aqua</string>
// 844:         \t\t<string>Background</string>
// 845:         \t\t<string>LoginWindow</string>
// 846:         \t\t<string>StandardIO</string>
// 847:         \t\t<string>System</string>
// 848:         \t</array>
// 849:         \t<key>ProgramArguments</key>
// 850:         \t<array>
// 851:         \t\t<string>#{HOMEBREW_PREFIX}/opt/formula_name/bin/beanstalkd</string>
// 852:         \t</array>
// 853:         \t<key>RunAtLoad</key>
// 854:         \t<true/>
// 855:         \t<key>StartCalendarInterval</key>
// 856:         \t<dict>
// 857:         \t\t<key>Hour</key>
// 858:         \t\t<integer>0</integer>
// 859:         \t\t<key>Minute</key>
// 860:         \t\t<integer>0</integer>
// 861:         \t</dict>
// 862:         </dict>
// 863:         </plist>
// 864:       XML
// 865:       expect(plist).to eq(plist_expect)
// 866:     end
// 867:
// 868:     it "returns valid keepalive-exit plist" do
// 869:       f = stub_formula do
// 870:         T.bind(self, T.class_of(Formula))
// 871:         service do
// 872:           run opt_bin/"beanstalkd"
// 873:           keep_alive successful_exit: false
// 874:         end
// 875:       end
// 876:
// 877:       plist = f.service.to_plist
// 878:       plist_expect = <<~XML
// 879:         <?xml version="1.0" encoding="UTF-8"?>
// 880:         <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
// 881:         <plist version="1.0">
// 882:         <dict>
// 883:         \t<key>KeepAlive</key>
// 884:         \t<dict>
// 885:         \t\t<key>SuccessfulExit</key>
// 886:         \t\t<false/>
// 887:         \t</dict>
// 888:         \t<key>Label</key>
// 889:         \t<string>homebrew.mxcl.formula_name</string>
// 890:         \t<key>LimitLoadToSessionType</key>
// 891:         \t<array>
// 892:         \t\t<string>Aqua</string>
// 893:         \t\t<string>Background</string>
// 894:         \t\t<string>LoginWindow</string>
// 895:         \t\t<string>StandardIO</string>
// 896:         \t\t<string>System</string>
// 897:         \t</array>
// 898:         \t<key>ProgramArguments</key>
// 899:         \t<array>
// 900:         \t\t<string>#{HOMEBREW_PREFIX}/opt/formula_name/bin/beanstalkd</string>
// 901:         \t</array>
// 902:         \t<key>RunAtLoad</key>
// 903:         \t<true/>
// 904:         </dict>
// 905:         </plist>
// 906:       XML
// 907:       expect(plist).to eq(plist_expect)
// 908:     end
// 909:
// 910:     it "returns valid keepalive-crashed plist" do
// 911:       f = stub_formula do
// 912:         T.bind(self, T.class_of(Formula))
// 913:         service do
// 914:           run opt_bin/"beanstalkd"
// 915:           keep_alive crashed: true
// 916:         end
// 917:       end
// 918:
// 919:       plist = f.service.to_plist
// 920:       plist_expect = <<~XML
// 921:         <?xml version="1.0" encoding="UTF-8"?>
// 922:         <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
// 923:         <plist version="1.0">
// 924:         <dict>
// 925:         \t<key>KeepAlive</key>
// 926:         \t<dict>
// 927:         \t\t<key>Crashed</key>
// 928:         \t\t<true/>
// 929:         \t</dict>
// 930:         \t<key>Label</key>
// 931:         \t<string>homebrew.mxcl.formula_name</string>
// 932:         \t<key>LimitLoadToSessionType</key>
// 933:         \t<array>
// 934:         \t\t<string>Aqua</string>
// 935:         \t\t<string>Background</string>
// 936:         \t\t<string>LoginWindow</string>
// 937:         \t\t<string>StandardIO</string>
// 938:         \t\t<string>System</string>
// 939:         \t</array>
// 940:         \t<key>ProgramArguments</key>
// 941:         \t<array>
// 942:         \t\t<string>#{HOMEBREW_PREFIX}/opt/formula_name/bin/beanstalkd</string>
// 943:         \t</array>
// 944:         \t<key>RunAtLoad</key>
// 945:         \t<true/>
// 946:         </dict>
// 947:         </plist>
// 948:       XML
// 949:       expect(plist).to eq(plist_expect)
// 950:     end
// 951:
// 952:     it "returns valid keepalive-path plist" do
// 953:       f = stub_formula do
// 954:         T.bind(self, T.class_of(Formula))
// 955:         service do
// 956:           run opt_bin/"beanstalkd"
// 957:           keep_alive path: opt_pkgshare/"test-path"
// 958:         end
// 959:       end
// 960:
// 961:       plist = f.service.to_plist
// 962:       plist_expect = <<~XML
// 963:         <?xml version="1.0" encoding="UTF-8"?>
// 964:         <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
// 965:         <plist version="1.0">
// 966:         <dict>
// 967:         \t<key>KeepAlive</key>
// 968:         \t<dict>
// 969:         \t\t<key>PathState</key>
// 970:         \t\t<string>#{HOMEBREW_PREFIX}/opt/formula_name/share/formula_name/test-path</string>
// 971:         \t</dict>
// 972:         \t<key>Label</key>
// 973:         \t<string>homebrew.mxcl.formula_name</string>
// 974:         \t<key>LimitLoadToSessionType</key>
// 975:         \t<array>
// 976:         \t\t<string>Aqua</string>
// 977:         \t\t<string>Background</string>
// 978:         \t\t<string>LoginWindow</string>
// 979:         \t\t<string>StandardIO</string>
// 980:         \t\t<string>System</string>
// 981:         \t</array>
// 982:         \t<key>ProgramArguments</key>
// 983:         \t<array>
// 984:         \t\t<string>#{HOMEBREW_PREFIX}/opt/formula_name/bin/beanstalkd</string>
// 985:         \t</array>
// 986:         \t<key>RunAtLoad</key>
// 987:         \t<true/>
// 988:         </dict>
// 989:         </plist>
// 990:       XML
// 991:       expect(plist).to eq(plist_expect)
// 992:     end
// 993:
// 994:     it "expands paths" do
// 995:       f = stub_formula do
// 996:         T.bind(self, T.class_of(Formula))
// 997:         service do
// 998:           run [opt_sbin/"sleepwatcher", "-V", "-s", "~/.sleep", "-w", "~/.wakeup"]
// 999:           working_dir "~"
// 1000:         end
// 1001:       end
// 1002:
// 1003:       plist = f.service.to_plist
// 1004:       plist_expect = <<~XML
// 1005:         <?xml version="1.0" encoding="UTF-8"?>
// 1006:         <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
// 1007:         <plist version="1.0">
// 1008:         <dict>
// 1009:         \t<key>Label</key>
// 1010:         \t<string>homebrew.mxcl.formula_name</string>
// 1011:         \t<key>LimitLoadToSessionType</key>
// 1012:         \t<array>
// 1013:         \t\t<string>Aqua</string>
// 1014:         \t\t<string>Background</string>
// 1015:         \t\t<string>LoginWindow</string>
// 1016:         \t\t<string>StandardIO</string>
// 1017:         \t\t<string>System</string>
// 1018:         \t</array>
// 1019:         \t<key>ProgramArguments</key>
// 1020:         \t<array>
// 1021:         \t\t<string>#{HOMEBREW_PREFIX}/opt/formula_name/sbin/sleepwatcher</string>
// 1022:         \t\t<string>-V</string>
// 1023:         \t\t<string>-s</string>
// 1024:         \t\t<string>#{Dir.home}/.sleep</string>
// 1025:         \t\t<string>-w</string>
// 1026:         \t\t<string>#{Dir.home}/.wakeup</string>
// 1027:         \t</array>
// 1028:         \t<key>RunAtLoad</key>
// 1029:         \t<true/>
// 1030:         \t<key>WorkingDirectory</key>
// 1031:         \t<string>#{Dir.home}</string>
// 1032:         </dict>
// 1033:         </plist>
// 1034:       XML
// 1035:       expect(plist).to eq(plist_expect)
// 1036:     end
// 1037:   end
// 1038:
// 1039:   describe "#to_systemd_unit" do
// 1040:     it "returns valid unit" do
// 1041:       f = stub_formula do
// 1042:         T.bind(self, T.class_of(Formula))
// 1043:         service do
// 1044:           run [opt_bin/"beanstalkd", "test"]
// 1045:           run_type :immediate
// 1046:           environment_variables PATH: std_service_path_env, FOO: "BAR"
// 1047:           error_log_path var/"log/beanstalkd.error.log"
// 1048:           log_path var/"log/beanstalkd.log"
// 1049:           input_path var/"in/beanstalkd"
// 1050:           require_root true
// 1051:           root_dir var
// 1052:           working_dir var
// 1053:           keep_alive true
// 1054:           process_type :interactive
// 1055:           restart_delay 30
// 1056:           stop_timeout 45
// 1057:           nice(-15)
// 1058:           macos_legacy_timers true
// 1059:         end
// 1060:       end
// 1061:
// 1062:       unit = f.service.to_systemd_unit
// 1063:       std_path = "#{HOMEBREW_PREFIX}/bin:#{HOMEBREW_PREFIX}/sbin:/usr/bin:/bin:/usr/sbin:/sbin"
// 1064:       unit_expect = <<~SYSTEMD
// 1065:         [Unit]
// 1066:         Description=Homebrew generated unit for formula_name
// 1067:
// 1068:         [Install]
// 1069:         WantedBy=default.target
// 1070:
// 1071:         [Service]
// 1072:         Type=simple
// 1073:         ExecStart="#{HOMEBREW_PREFIX}/opt/#{name}/bin/beanstalkd" "test"
// 1074:         Restart=on-failure
// 1075:         RestartSec=30
// 1076:         TimeoutStopSec=45
// 1077:         Nice=-15
// 1078:         WorkingDirectory=#{HOMEBREW_PREFIX}/var
// 1079:         RootDirectory=#{HOMEBREW_PREFIX}/var
// 1080:         StandardInput=file:#{HOMEBREW_PREFIX}/var/in/beanstalkd
// 1081:         StandardOutput=append:#{HOMEBREW_PREFIX}/var/log/beanstalkd.log
// 1082:         StandardError=append:#{HOMEBREW_PREFIX}/var/log/beanstalkd.error.log
// 1083:         Environment="PATH=#{std_path}"
// 1084:         Environment="FOO=BAR"
// 1085:       SYSTEMD
// 1086:       expect(unit).to eq(unit_expect)
// 1087:     end
// 1088:
// 1089:     it "returns valid partial oneshot unit" do
// 1090:       f = stub_formula do
// 1091:         T.bind(self, T.class_of(Formula))
// 1092:         service do
// 1093:           run opt_bin/"beanstalkd"
// 1094:           run_type :immediate
// 1095:           launch_only_once true
// 1096:         end
// 1097:       end
// 1098:
// 1099:       unit = f.service.to_systemd_unit
// 1100:       unit_expect = <<~SYSTEMD
// 1101:         [Unit]
// 1102:         Description=Homebrew generated unit for formula_name
// 1103:
// 1104:         [Install]
// 1105:         WantedBy=default.target
// 1106:
// 1107:         [Service]
// 1108:         Type=oneshot
// 1109:         ExecStart="#{HOMEBREW_PREFIX}/opt/#{name}/bin/beanstalkd"
// 1110:       SYSTEMD
// 1111:       expect(unit).to eq(unit_expect)
// 1112:     end
// 1113:
// 1114:     it "expands paths" do
// 1115:       f = stub_formula do
// 1116:         T.bind(self, T.class_of(Formula))
// 1117:         service do
// 1118:           run opt_bin/"beanstalkd"
// 1119:           working_dir "~"
// 1120:         end
// 1121:       end
// 1122:
// 1123:       unit = f.service.to_systemd_unit
// 1124:       unit_expect = <<~SYSTEMD
// 1125:         [Unit]
// 1126:         Description=Homebrew generated unit for formula_name
// 1127:
// 1128:         [Install]
// 1129:         WantedBy=default.target
// 1130:
// 1131:         [Service]
// 1132:         Type=simple
// 1133:         ExecStart="#{HOMEBREW_PREFIX}/opt/#{name}/bin/beanstalkd"
// 1134:         WorkingDirectory=#{Dir.home}
// 1135:       SYSTEMD
// 1136:       expect(unit).to eq(unit_expect)
// 1137:     end
// 1138:
// 1139:     it "returns valid unit with keep_alive crashed" do
// 1140:       f = stub_formula do
// 1141:         T.bind(self, T.class_of(Formula))
// 1142:         service do
// 1143:           run opt_bin/"beanstalkd"
// 1144:           keep_alive crashed: true
// 1145:         end
// 1146:       end
// 1147:
// 1148:       unit = f.service.to_systemd_unit
// 1149:       unit_expect = <<~SYSTEMD
// 1150:         [Unit]
// 1151:         Description=Homebrew generated unit for formula_name
// 1152:
// 1153:         [Install]
// 1154:         WantedBy=default.target
// 1155:
// 1156:         [Service]
// 1157:         Type=simple
// 1158:         ExecStart="#{HOMEBREW_PREFIX}/opt/#{name}/bin/beanstalkd"
// 1159:         Restart=on-failure
// 1160:       SYSTEMD
// 1161:       expect(unit).to eq(unit_expect)
// 1162:     end
// 1163:
// 1164:     it "returns valid unit with keep_alive successful_exit" do
// 1165:       f = stub_formula do
// 1166:         T.bind(self, T.class_of(Formula))
// 1167:         service do
// 1168:           run opt_bin/"beanstalkd"
// 1169:           keep_alive successful_exit: true
// 1170:         end
// 1171:       end
// 1172:
// 1173:       unit = f.service.to_systemd_unit
// 1174:       unit_expect = <<~SYSTEMD
// 1175:         [Unit]
// 1176:         Description=Homebrew generated unit for formula_name
// 1177:
// 1178:         [Install]
// 1179:         WantedBy=default.target
// 1180:
// 1181:         [Service]
// 1182:         Type=simple
// 1183:         ExecStart="#{HOMEBREW_PREFIX}/opt/#{name}/bin/beanstalkd"
// 1184:         Restart=on-success
// 1185:       SYSTEMD
// 1186:       expect(unit).to eq(unit_expect)
// 1187:     end
// 1188:
// 1189:     it "returns valid unit with stop_timeout" do
// 1190:       f = stub_formula do
// 1191:         T.bind(self, T.class_of(Formula))
// 1192:         service do
// 1193:           run opt_bin/"beanstalkd"
// 1194:           stop_timeout 25
// 1195:         end
// 1196:       end
// 1197:
// 1198:       unit = f.service.to_systemd_unit
// 1199:       unit_expect = <<~SYSTEMD
// 1200:         [Unit]
// 1201:         Description=Homebrew generated unit for formula_name
// 1202:
// 1203:         [Install]
// 1204:         WantedBy=default.target
// 1205:
// 1206:         [Service]
// 1207:         Type=simple
// 1208:         ExecStart="#{HOMEBREW_PREFIX}/opt/#{name}/bin/beanstalkd"
// 1209:         TimeoutStopSec=25
// 1210:       SYSTEMD
// 1211:       expect(unit).to eq(unit_expect)
// 1212:     end
// 1213:
// 1214:     it "returns valid unit without restart when keep_alive is false" do
// 1215:       f = stub_formula do
// 1216:         T.bind(self, T.class_of(Formula))
// 1217:         service do
// 1218:           run opt_bin/"beanstalkd"
// 1219:           keep_alive false
// 1220:         end
// 1221:       end
// 1222:
// 1223:       unit = f.service.to_systemd_unit
// 1224:       unit_expect = <<~SYSTEMD
// 1225:         [Unit]
// 1226:         Description=Homebrew generated unit for formula_name
// 1227:
// 1228:         [Install]
// 1229:         WantedBy=default.target
// 1230:
// 1231:         [Service]
// 1232:         Type=simple
// 1233:         ExecStart="#{HOMEBREW_PREFIX}/opt/#{name}/bin/beanstalkd"
// 1234:       SYSTEMD
// 1235:       expect(unit).to eq(unit_expect)
// 1236:     end
// 1237:   end
// 1238:
// 1239:   describe "#to_systemd_timer" do
// 1240:     it "returns valid timer" do
// 1241:       f = stub_formula do
// 1242:         T.bind(self, T.class_of(Formula))
// 1243:         service do
// 1244:           run [opt_bin/"beanstalkd", "test"]
// 1245:           run_type :interval
// 1246:           interval 5
// 1247:         end
// 1248:       end
// 1249:
// 1250:       unit = f.service.to_systemd_timer
// 1251:       unit_expect = <<~SYSTEMD
// 1252:         [Unit]
// 1253:         Description=Homebrew generated timer for formula_name
// 1254:
// 1255:         [Install]
// 1256:         WantedBy=timers.target
// 1257:
// 1258:         [Timer]
// 1259:         Unit=homebrew.formula_name.service
// 1260:         OnUnitActiveSec=5
// 1261:       SYSTEMD
// 1262:       expect(unit).to eq(unit_expect)
// 1263:     end
// 1264:
// 1265:     it "returns valid partial timer" do
// 1266:       f = stub_formula do
// 1267:         T.bind(self, T.class_of(Formula))
// 1268:         service do
// 1269:           run opt_bin/"beanstalkd"
// 1270:           run_type :immediate
// 1271:         end
// 1272:       end
// 1273:
// 1274:       unit = f.service.to_systemd_timer
// 1275:       unit_expect = <<~SYSTEMD
// 1276:         [Unit]
// 1277:         Description=Homebrew generated timer for formula_name
// 1278:
// 1279:         [Install]
// 1280:         WantedBy=timers.target
// 1281:
// 1282:         [Timer]
// 1283:         Unit=homebrew.formula_name.service
// 1284:
// 1285:       SYSTEMD
// 1286:       expect(unit).to eq(unit_expect)
// 1287:     end
// 1288:
// 1289:     it "throws on incomplete cron" do
// 1290:       f = stub_formula do
// 1291:         T.bind(self, T.class_of(Formula))
// 1292:         service do
// 1293:           run opt_bin/"beanstalkd"
// 1294:           run_type :cron
// 1295:           cron "1 2 3 4"
// 1296:         end
// 1297:       end
// 1298:
// 1299:       expect do
// 1300:         f.service.to_systemd_timer
// 1301:       end.to raise_error TypeError, "Service#parse_cron expects a valid cron syntax"
// 1302:     end
// 1303:
// 1304:     it "returns valid cron timers" do
// 1305:       styles = {
// 1306:         "@hourly":   "*-*-* *:00:00",
// 1307:         "@daily":    "*-*-* 00:00:00",
// 1308:         "@weekly":   "Sun *-*-* 00:00:00",
// 1309:         "@monthly":  "*-*-1 00:00:00",
// 1310:         "@yearly":   "*-1-1 00:00:00",
// 1311:         "@annually": "*-1-1 00:00:00",
// 1312:         "5 5 5 5 5": "Fri *-5-5 05:05:00",
// 1313:       }
// 1314:
// 1315:       styles.each do |cron, calendar|
// 1316:         f = stub_formula do
// 1317:           T.bind(self, T.class_of(Formula))
// 1318:           service do
// 1319:             run opt_bin/"beanstalkd"
// 1320:             run_type :cron
// 1321:             cron cron.to_s
// 1322:           end
// 1323:         end
// 1324:
// 1325:         unit = f.service.to_systemd_timer
// 1326:         unit_expect = <<~SYSTEMD
// 1327:           [Unit]
// 1328:           Description=Homebrew generated timer for formula_name
// 1329:
// 1330:           [Install]
// 1331:           WantedBy=timers.target
// 1332:
// 1333:           [Timer]
// 1334:           Unit=homebrew.formula_name.service
// 1335:           Persistent=true
// 1336:           OnCalendar=#{calendar}
// 1337:         SYSTEMD
// 1338:         expect(unit).to eq(unit_expect)
// 1339:       end
// 1340:     end
// 1341:   end
// 1342:
// 1343:   describe "#timed?" do
// 1344:     it "returns false for immediate" do
// 1345:       f = stub_formula do
// 1346:         T.bind(self, T.class_of(Formula))
// 1347:         service do
// 1348:           run [opt_bin/"beanstalkd", "test"]
// 1349:           run_type :immediate
// 1350:         end
// 1351:       end
// 1352:
// 1353:       expect(f.service.timed?).to be(false)
// 1354:     end
// 1355:
// 1356:     it "returns true for interval" do
// 1357:       f = stub_formula do
// 1358:         T.bind(self, T.class_of(Formula))
// 1359:         service do
// 1360:           run [opt_bin/"beanstalkd", "test"]
// 1361:           run_type :interval
// 1362:         end
// 1363:       end
// 1364:
// 1365:       expect(f.service.timed?).to be(true)
// 1366:     end
// 1367:   end
// 1368:
// 1369:   describe "#keep_alive?" do
// 1370:     it "returns true when keep_alive set to hash" do
// 1371:       f = stub_formula do
// 1372:         T.bind(self, T.class_of(Formula))
// 1373:         service do
// 1374:           run [opt_bin/"beanstalkd", "test"]
// 1375:           keep_alive crashed: true
// 1376:         end
// 1377:       end
// 1378:
// 1379:       expect(f.service.keep_alive?).to be(true)
// 1380:     end
// 1381:
// 1382:     it "returns true when keep_alive set to true" do
// 1383:       f = stub_formula do
// 1384:         T.bind(self, T.class_of(Formula))
// 1385:         service do
// 1386:           run [opt_bin/"beanstalkd", "test"]
// 1387:           keep_alive true
// 1388:         end
// 1389:       end
// 1390:
// 1391:       expect(f.service.keep_alive?).to be(true)
// 1392:     end
// 1393:
// 1394:     it "returns false when keep_alive not set" do
// 1395:       f = stub_formula do
// 1396:         T.bind(self, T.class_of(Formula))
// 1397:         service do
// 1398:           run [opt_bin/"beanstalkd", "test"]
// 1399:         end
// 1400:       end
// 1401:
// 1402:       expect(f.service.keep_alive?).to be(false)
// 1403:     end
// 1404:
// 1405:     it "returns false when keep_alive set to false" do
// 1406:       f = stub_formula do
// 1407:         T.bind(self, T.class_of(Formula))
// 1408:         service do
// 1409:           run [opt_bin/"beanstalkd", "test"]
// 1410:           keep_alive false
// 1411:         end
// 1412:       end
// 1413:
// 1414:       expect(f.service.keep_alive?).to be(false)
// 1415:     end
// 1416:   end
// 1417:
// 1418:   describe "#command" do
// 1419:     it "returns @run data" do
// 1420:       f = stub_formula do
// 1421:         T.bind(self, T.class_of(Formula))
// 1422:         service do
// 1423:           run [opt_bin/"beanstalkd", "test"]
// 1424:           run_type :immediate
// 1425:         end
// 1426:       end
// 1427:
// 1428:       command = f.service.command
// 1429:       expect(command).to eq(["#{HOMEBREW_PREFIX}/opt/#{name}/bin/beanstalkd", "test"])
// 1430:     end
// 1431:
// 1432:     context "when simulating Linux" do
// 1433:       around do |example|
// 1434:         Homebrew::SimulateSystem.with(os: :linux) do
// 1435:           example.run
// 1436:         end
// 1437:       end
// 1438:
// 1439:       it "returns @run data" do
// 1440:         f = stub_formula do
// 1441:           T.bind(self, T.class_of(Formula))
// 1442:           service do
// 1443:             run linux: [opt_bin/"beanstalkd", "test"]
// 1444:             run_type :immediate
// 1445:           end
// 1446:         end
// 1447:
// 1448:         command = f.service.command
// 1449:         expect(command).to eq(["#{HOMEBREW_PREFIX}/opt/#{name}/bin/beanstalkd", "test"])
// 1450:       end
// 1451:
// 1452:       it "returns empty for macOS-only commands" do
// 1453:         f = stub_formula do
// 1454:           T.bind(self, T.class_of(Formula))
// 1455:           service do
// 1456:             run macos: [opt_bin/"beanstalkd", "test"]
// 1457:             run_type :immediate
// 1458:           end
// 1459:         end
// 1460:
// 1461:         command = f.service.command
// 1462:         expect(command).to be_empty
// 1463:       end
// 1464:
// 1465:       it "returns the Linux command when both OS commands are defined" do
// 1466:         f = stub_formula do
// 1467:           T.bind(self, T.class_of(Formula))
// 1468:           service do
// 1469:             run macos: [opt_bin/"beanstalkd", "test", "macos"], linux: [opt_bin/"beanstalkd", "test", "linux"]
// 1470:             run_type :immediate
// 1471:           end
// 1472:         end
// 1473:
// 1474:         command = f.service.command
// 1475:         expect(command).to eq(["#{HOMEBREW_PREFIX}/opt/#{name}/bin/beanstalkd", "test", "linux"])
// 1476:       end
// 1477:     end
// 1478:
// 1479:     context "when simulating macOS" do
// 1480:       around do |example|
// 1481:         Homebrew::SimulateSystem.with(os: :macos) do
// 1482:           example.run
// 1483:         end
// 1484:       end
// 1485:
// 1486:       it "returns @run data" do
// 1487:         f = stub_formula do
// 1488:           T.bind(self, T.class_of(Formula))
// 1489:           service do
// 1490:             run macos: [opt_bin/"beanstalkd", "test"]
// 1491:             run_type :immediate
// 1492:           end
// 1493:         end
// 1494:
// 1495:         command = f.service.command
// 1496:         expect(command).to eq(["#{HOMEBREW_PREFIX}/opt/#{name}/bin/beanstalkd", "test"])
// 1497:       end
// 1498:
// 1499:       it "returns empty for Linux-only commands" do
// 1500:         f = stub_formula do
// 1501:           T.bind(self, T.class_of(Formula))
// 1502:           service do
// 1503:             run linux: [opt_bin/"beanstalkd", "test"]
// 1504:             run_type :immediate
// 1505:           end
// 1506:         end
// 1507:
// 1508:         command = f.service.command
// 1509:         expect(command).to be_empty
// 1510:       end
// 1511:
// 1512:       it "returns the macOS command when both OS commands are defined" do
// 1513:         f = stub_formula do
// 1514:           T.bind(self, T.class_of(Formula))
// 1515:           service do
// 1516:             run macos: [opt_bin/"beanstalkd", "test", "macos"], linux: [opt_bin/"beanstalkd", "test", "linux"]
// 1517:             run_type :immediate
// 1518:           end
// 1519:         end
// 1520:
// 1521:         command = f.service.command
// 1522:         expect(command).to eq(["#{HOMEBREW_PREFIX}/opt/#{name}/bin/beanstalkd", "test", "macos"])
// 1523:       end
// 1524:     end
// 1525:   end
// 1526:
// 1527:   describe "#to_hash" do
// 1528:     let(:serialized_hash) do
// 1529:       {
// 1530:         environment_variables: {
// 1531:           PATH: "$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:/usr/bin:/bin:/usr/sbin:/sbin",
// 1532:         },
// 1533:         run:                   [Pathname("$HOMEBREW_PREFIX/opt/formula_name/bin/beanstalkd"), "test"],
// 1534:         run_type:              :immediate,
// 1535:         working_dir:           "/$HOME",
// 1536:         cron:                  "0 0 * * 0",
// 1537:         stop_timeout:          15,
// 1538:         sockets:               "tcp://0.0.0.0:80",
// 1539:       }
// 1540:     end
// 1541:
// 1542:     # NOTE: The calls to `Formula.generating_hash!` and `Formula.generated_hash!`
// 1543:     #       are not idempotent so they can only be used in one test.
// 1544:     it "replaces local paths with placeholders" do
// 1545:       f = stub_formula do
// 1546:         T.bind(self, T.class_of(Formula))
// 1547:         service do
// 1548:           run [opt_bin/"beanstalkd", "test"]
// 1549:           environment_variables PATH: std_service_path_env
// 1550:           working_dir Dir.home
// 1551:           cron "@weekly"
// 1552:           stop_timeout 15
// 1553:           sockets "tcp://0.0.0.0:80"
// 1554:         end
// 1555:       end
// 1556:
// 1557:       Formula.generating_hash!
// 1558:       expect(f.service.to_hash).to eq(serialized_hash)
// 1559:       Formula.generated_hash!
// 1560:     end
// 1561:   end
// 1562:
// 1563:   describe ".from_hash" do
// 1564:     let(:serialized_hash) do
// 1565:       {
// 1566:         "name"                  => {
// 1567:           "linux" => "custom.systemd.name",
// 1568:           "macos" => "custom.launchd.name",
// 1569:         },
// 1570:         "environment_variables" => {
// 1571:           "PATH" => "$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:/usr/bin:/bin:/usr/sbin:/sbin",
// 1572:         },
// 1573:         "run"                   => ["$HOMEBREW_PREFIX/opt/formula_name/bin/beanstalkd", "test"],
// 1574:         "run_type"              => "immediate",
// 1575:         "working_dir"           => HOMEBREW_HOME_PLACEHOLDER,
// 1576:         "keep_alive"            => { "successful_exit" => false },
// 1577:       }
// 1578:     end
// 1579:
// 1580:     let(:deserialized_hash) do
// 1581:       {
// 1582:         name:                  {
// 1583:           linux: "custom.systemd.name",
// 1584:           macos: "custom.launchd.name",
// 1585:         },
// 1586:         environment_variables: {
// 1587:           PATH: "#{HOMEBREW_PREFIX}/bin:#{HOMEBREW_PREFIX}/sbin:/usr/bin:/bin:/usr/sbin:/sbin",
// 1588:         },
// 1589:         run:                   ["#{HOMEBREW_PREFIX}/opt/formula_name/bin/beanstalkd", "test"],
// 1590:         run_type:              :immediate,
// 1591:         working_dir:           Dir.home,
// 1592:         keep_alive:            { successful_exit: false },
// 1593:       }
// 1594:     end
// 1595:
// 1596:     it "replaces placeholders with local paths" do
// 1597:       expect(described_class.from_hash(serialized_hash)).to eq(deserialized_hash)
// 1598:     end
// 1599:
// 1600:     describe "run command" do
// 1601:       it "handles String argument correctly" do
// 1602:         expect(described_class.from_hash({
// 1603:           "run" => "$HOMEBREW_PREFIX/opt/formula_name/bin/beanstalkd",
// 1604:         })).to eq({
// 1605:           run: "#{HOMEBREW_PREFIX}/opt/formula_name/bin/beanstalkd",
// 1606:         })
// 1607:       end
// 1608:
// 1609:       it "handles Array argument correctly" do
// 1610:         expect(described_class.from_hash({
// 1611:           "run" => ["$HOMEBREW_PREFIX/opt/formula_name/bin/beanstalkd", "--option"],
// 1612:         })).to eq({
// 1613:           run: ["#{HOMEBREW_PREFIX}/opt/formula_name/bin/beanstalkd", "--option"],
// 1614:         })
// 1615:       end
// 1616:
// 1617:       it "handles Hash argument correctly" do
// 1618:         expect(described_class.from_hash({
// 1619:           "run" => {
// 1620:             "linux" => "$HOMEBREW_PREFIX/opt/formula_name/bin/beanstalkd",
// 1621:             "macos" => ["$HOMEBREW_PREFIX/opt/formula_name/bin/beanstalkd", "--option"],
// 1622:           },
// 1623:         })).to eq({
// 1624:           run: {
// 1625:             linux: "#{HOMEBREW_PREFIX}/opt/formula_name/bin/beanstalkd",
// 1626:             macos: ["#{HOMEBREW_PREFIX}/opt/formula_name/bin/beanstalkd", "--option"],
// 1627:           },
// 1628:         })
// 1629:       end
// 1630:
// 1631:       it "handles stop_timeout argument correctly" do
// 1632:         expect(described_class.from_hash({
// 1633:           "run"          => "$HOMEBREW_PREFIX/opt/formula_name/bin/beanstalkd",
// 1634:           "stop_timeout" => 30,
// 1635:         })).to eq({
// 1636:           run:          "#{HOMEBREW_PREFIX}/opt/formula_name/bin/beanstalkd",
// 1637:           stop_timeout: 30,
// 1638:         })
// 1639:       end
// 1640:     end
// 1641:   end
// 1642:
// 1643:   describe "#effective_environment_variables" do
// 1644:     it "returns formula vars when no env override file exists" do
// 1645:       f = stub_formula do
// 1646:         service do
// 1647:           run opt_bin/"beanstalkd"
// 1648:           environment_variables FOO: "BAR"
// 1649:         end
// 1650:       end
// 1651:
// 1652:       vars = f.service.effective_environment_variables
// 1653:       expect(vars).to eq({ FOO: "BAR" })
// 1654:     end
// 1655:
// 1656:     it "merges user env overrides with formula vars" do
// 1657:       f = stub_formula do
// 1658:         service do
// 1659:           run opt_bin/"beanstalkd"
// 1660:           environment_variables FOO: "BAR"
// 1661:         end
// 1662:       end
// 1663:
// 1664:       with_env(HOMEBREW_USER_CONFIG_HOME: Dir.mktmpdir) do
// 1665:         services_dir = Pathname.new(ENV.fetch("HOMEBREW_USER_CONFIG_HOME")) / "services"
// 1666:         services_dir.mkpath
// 1667:         env_file = services_dir / "formula_name.env"
// 1668:         env_file.write <<~ENV
// 1669:           OLLAMA_HOST=0.0.0.0
// 1670:         ENV
// 1671:
// 1672:         vars = f.service.effective_environment_variables
// 1673:         expect(vars).to eq({ FOO: "BAR", OLLAMA_HOST: "0.0.0.0" })
// 1674:       end
// 1675:     end
// 1676:
// 1677:     it "user env overrides take precedence over formula vars" do
// 1678:       f = stub_formula do
// 1679:         service do
// 1680:           run opt_bin/"beanstalkd"
// 1681:           environment_variables FOO: "BAR"
// 1682:         end
// 1683:       end
// 1684:
// 1685:       with_env(HOMEBREW_USER_CONFIG_HOME: Dir.mktmpdir) do
// 1686:         services_dir = Pathname.new(ENV.fetch("HOMEBREW_USER_CONFIG_HOME")) / "services"
// 1687:         services_dir.mkpath
// 1688:         env_file = services_dir / "formula_name.env"
// 1689:         env_file.write <<~ENV
// 1690:           FOO=QUX
// 1691:         ENV
// 1692:
// 1693:         vars = f.service.effective_environment_variables
// 1694:         expect(vars).to eq({ FOO: "QUX" })
// 1695:       end
// 1696:     end
// 1697:
// 1698:     it "ignores comments and blank lines in env file" do
// 1699:       f = stub_formula do
// 1700:         service do
// 1701:           run opt_bin/"beanstalkd"
// 1702:           environment_variables FOO: "BAR"
// 1703:         end
// 1704:       end
// 1705:
// 1706:       with_env(HOMEBREW_USER_CONFIG_HOME: Dir.mktmpdir) do
// 1707:         services_dir = Pathname.new(ENV.fetch("HOMEBREW_USER_CONFIG_HOME")) / "services"
// 1708:         services_dir.mkpath
// 1709:         env_file = services_dir / "formula_name.env"
// 1710:         env_file.write <<~ENV
// 1711:           # This is a comment
// 1712:
// 1713:           OLLAMA_HOST=0.0.0.0
// 1714:           # Another comment
// 1715:           OLLAMA_ORIGINS=*
// 1716:         ENV
// 1717:
// 1718:         vars = f.service.effective_environment_variables
// 1719:         expect(vars).to eq({ FOO: "BAR", OLLAMA_HOST: "0.0.0.0", OLLAMA_ORIGINS: "*" })
// 1720:       end
// 1721:     end
// 1722:
// 1723:     it "skips lines without = and strips whitespace around =" do
// 1724:       f = stub_formula do
// 1725:         service do
// 1726:           run opt_bin/"beanstalkd"
// 1727:         end
// 1728:       end
// 1729:
// 1730:       with_env(HOMEBREW_USER_CONFIG_HOME: Dir.mktmpdir) do
// 1731:         services_dir = Pathname.new(ENV.fetch("HOMEBREW_USER_CONFIG_HOME")) / "services"
// 1732:         services_dir.mkpath
// 1733:         env_file = services_dir / "formula_name.env"
// 1734:         env_file.write <<~ENV
// 1735:           # comment
// 1736:           MALFORMED_LINE
// 1737:           FOO = BAR
// 1738:           BLANK_KEY = value
// 1739:           KEY_WITH_NO_VALUE
// 1740:           NORMAL=BAZ
// 1741:           KEY_EMPTY_VALUE=
// 1742:         ENV
// 1743:
// 1744:         expect { f.service.effective_environment_variables }
// 1745:           .to output(/invalid line.*MALFORMED_LINE/).to_stderr
// 1746:         expect { f.service.effective_environment_variables }
// 1747:           .to output(/invalid line.*KEY_WITH_NO_VALUE/).to_stderr
// 1748:         vars = f.service.effective_environment_variables
// 1749:         expect(vars).to eq({ FOO: "BAR", BLANK_KEY: "value", NORMAL: "BAZ", KEY_EMPTY_VALUE: "" })
// 1750:       end
// 1751:     end
// 1752:
// 1753:     it "includes user env overrides in to_plist" do
// 1754:       f = stub_formula do
// 1755:         service do
// 1756:           run [opt_bin/"beanstalkd", "test"]
// 1757:           environment_variables FOO: "BAR"
// 1758:         end
// 1759:       end
// 1760:
// 1761:       with_env(HOMEBREW_USER_CONFIG_HOME: Dir.mktmpdir) do
// 1762:         services_dir = Pathname.new(ENV.fetch("HOMEBREW_USER_CONFIG_HOME")) / "services"
// 1763:         services_dir.mkpath
// 1764:         env_file = services_dir / "formula_name.env"
// 1765:         env_file.write <<~ENV
// 1766:           OLLAMA_HOST=0.0.0.0
// 1767:         ENV
// 1768:
// 1769:         plist = f.service.to_plist
// 1770:         expect(plist).to include("<key>OLLAMA_HOST</key>")
// 1771:         expect(plist).to include("<string>0.0.0.0</string>")
// 1772:         expect(plist).to include("<key>FOO</key>")
// 1773:         expect(plist).to include("<string>BAR</string>")
// 1774:       end
// 1775:     end
// 1776:
// 1777:     it "includes user env overrides in to_systemd_unit" do
// 1778:       f = stub_formula do
// 1779:         service do
// 1780:           run opt_bin/"beanstalkd"
// 1781:           environment_variables FOO: "BAR"
// 1782:         end
// 1783:       end
// 1784:
// 1785:       with_env(HOMEBREW_USER_CONFIG_HOME: Dir.mktmpdir) do
// 1786:         services_dir = Pathname.new(ENV.fetch("HOMEBREW_USER_CONFIG_HOME")) / "services"
// 1787:         services_dir.mkpath
// 1788:         env_file = services_dir / "formula_name.env"
// 1789:         env_file.write <<~ENV
// 1790:           OLLAMA_HOST=0.0.0.0
// 1791:         ENV
// 1792:
// 1793:         unit = f.service.to_systemd_unit
// 1794:         expect(unit).to include("Environment=\"FOO=BAR\"")
// 1795:         expect(unit).to include("Environment=\"OLLAMA_HOST=0.0.0.0\"")
// 1796:       end
// 1797:     end
// 1798:
// 1799:     it "skips world-writable env files" do
// 1800:       f = stub_formula do
// 1801:         service do
// 1802:           run opt_bin/"beanstalkd"
// 1803:           environment_variables FOO: "BAR"
// 1804:         end
// 1805:       end
// 1806:
// 1807:       with_env(HOMEBREW_USER_CONFIG_HOME: Dir.mktmpdir) do
// 1808:         services_dir = Pathname.new(ENV.fetch("HOMEBREW_USER_CONFIG_HOME")) / "services"
// 1809:         services_dir.mkpath
// 1810:         env_file = services_dir / "formula_name.env"
// 1811:         env_file.write "OLLAMA_HOST=0.0.0.0"
// 1812:         File.chmod 0666, env_file
// 1813:
// 1814:         expect { f.service.effective_environment_variables }.to output(/world-writable/).to_stderr
// 1815:         vars = f.service.effective_environment_variables
// 1816:         expect(vars).to eq({ FOO: "BAR" })
// 1817:       end
// 1818:     end
// 1819:
// 1820:     it "skips group-writable env files" do
// 1821:       f = stub_formula do
// 1822:         service do
// 1823:           run opt_bin/"beanstalkd"
// 1824:           environment_variables FOO: "BAR"
// 1825:         end
// 1826:       end
// 1827:
// 1828:       with_env(HOMEBREW_USER_CONFIG_HOME: Dir.mktmpdir) do
// 1829:         services_dir = Pathname.new(ENV.fetch("HOMEBREW_USER_CONFIG_HOME")) / "services"
// 1830:         services_dir.mkpath
// 1831:         env_file = services_dir / "formula_name.env"
// 1832:         env_file.write "OLLAMA_HOST=0.0.0.0"
// 1833:         File.chmod 0664, env_file
// 1834:
// 1835:         expect { f.service.effective_environment_variables }.to output(/group-writable/).to_stderr
// 1836:         vars = f.service.effective_environment_variables
// 1837:         expect(vars).to eq({ FOO: "BAR" })
// 1838:       end
// 1839:     end
// 1840:
// 1841:     it "follows symlinks to a safe target" do
// 1842:       f = stub_formula do
// 1843:         service do
// 1844:           run opt_bin/"beanstalkd"
// 1845:           environment_variables FOO: "BAR"
// 1846:         end
// 1847:       end
// 1848:
// 1849:       with_env(HOMEBREW_USER_CONFIG_HOME: Dir.mktmpdir) do
// 1850:         services_dir = Pathname.new(ENV.fetch("HOMEBREW_USER_CONFIG_HOME")) / "services"
// 1851:         services_dir.mkpath
// 1852:         target = services_dir / "actual.env"
// 1853:         target.write "OLLAMA_HOST=0.0.0.0"
// 1854:         File.chmod 0644, target
// 1855:
// 1856:         symlink = services_dir / "formula_name.env"
// 1857:         File.symlink(target, symlink)
// 1858:
// 1859:         vars = f.service.effective_environment_variables
// 1860:         expect(vars).to eq({ FOO: "BAR", OLLAMA_HOST: "0.0.0.0" })
// 1861:       end
// 1862:     end
// 1863:   end
// 1864: end
