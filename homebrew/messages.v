module homebrew

// Translated from Homebrew/brew `messages.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct CaveatMessage {
pub:
	package string
	caveats string
}

pub struct InstallTime {
pub:
	package string
	time    f64
}

// Messages is the typed V translation of Ruby's mutable end-of-command message
// collector. The ordered array plus membership check preserves Set insertion
// order for completions without introducing a second collection type.
pub struct Messages {
pub mut:
	caveats               []CaveatMessage
	completions_and_elisp []string
	package_count         int
	install_times         []InstallTime
}

pub fn new_messages() Messages {
	return Messages{}
}

pub fn (messages Messages) copy() Messages {
	return Messages{
		caveats:               messages.caveats.clone()
		completions_and_elisp: messages.completions_and_elisp.clone()
		package_count:         messages.package_count
		install_times:         messages.install_times.clone()
	}
}

pub fn (mut messages Messages) record_caveats(package string, caveats string) {
	messages.caveats << CaveatMessage{
		package: package
		caveats: caveats
	}
}

pub fn (mut messages Messages) record_completions_and_elisp(completions []string) {
	for completion in completions {
		if completion !in messages.completions_and_elisp {
			messages.completions_and_elisp << completion
		}
	}
}

pub fn (mut messages Messages) package_installed(package string, elapsed_time f64) {
	messages.package_count++
	messages.install_times << InstallTime{
		package: package
		time:    elapsed_time
	}
}

pub fn (messages Messages) display_messages(force_caveats bool, display_times bool) string {
	mut sections := []string{}
	caveats := messages.display_caveats(force_caveats)
	if caveats != '' {
		sections << caveats
	}
	if display_times {
		times := messages.display_install_times()
		if times != '' {
			sections << times
		}
	}
	return sections.join('\n')
}

pub fn (messages Messages) display_caveats(force bool) string {
	if messages.package_count == 0
		|| (messages.caveats.len == 0 && messages.completions_and_elisp.len == 0) {
		return ''
	}
	mut lines := []string{}
	if messages.completions_and_elisp.len > 0 {
		lines << '==> Caveats'
		lines << messages.completions_and_elisp
	}
	if messages.package_count == 1 && !force {
		return lines.join('\n')
	}
	if messages.completions_and_elisp.len == 0 {
		lines << '==> Caveats'
	}
	for caveat in messages.caveats {
		lines << '==> ${caveat.package}'
		lines << caveat.caveats
	}
	return lines.join('\n')
}

pub fn (messages Messages) display_install_times() string {
	if messages.install_times.len == 0 {
		return ''
	}
	mut lines := ['==> Installation times']
	for install_time in messages.install_times {
		padding := if install_time.package.len < 20 {
			' '.repeat(20 - install_time.package.len)
		} else {
			''
		}
		lines << '${install_time.package}${padding} ${install_time.time:10.3f} s'
	}
	return lines.join('\n')
}

// Ruby attr_reader `attr_reader :caveats` at line 12.
pub fn ruby_messages_l12_d1_caveats(messages Messages) []CaveatMessage {
	return messages.caveats.clone()
}

// Ruby attr_reader `attr_reader :package_count` at line 15.
pub fn ruby_messages_l15_d2_package_count(messages Messages) int {
	return messages.package_count
}

// Ruby attr_reader `attr_reader :install_times` at line 18.
pub fn ruby_messages_l18_d3_install_times(messages Messages) []InstallTime {
	return messages.install_times.clone()
}

// Ruby method `initialize` at line 21.
pub fn ruby_messages_l21_d4_initialize() Messages {
	return new_messages()
}

// Ruby method `record_caveats(package, caveats)` at line 29.
pub fn ruby_messages_l29_d5_record_caveats(mut messages Messages, package string, caveats string) {
	messages.record_caveats(package, caveats)
}

// Ruby method `record_completions_and_elisp(completions_and_elisp)` at line 34.
pub fn ruby_messages_l34_d6_record_completions_and_elisp(mut messages Messages,
	completions_and_elisp []string) {
	messages.record_completions_and_elisp(completions_and_elisp)
}

// Ruby method `package_installed(package, elapsed_time)` at line 39.
pub fn ruby_messages_l39_d7_package_installed(mut messages Messages, package string,
	elapsed_time f64) {
	messages.package_installed(package, elapsed_time)
}

// Ruby method `display_messages(force_caveats: false, display_times: false)` at line 45.
pub fn ruby_messages_l45_d8_display_messages(messages Messages, force_caveats bool,
	display_times bool) string {
	return messages.display_messages(force_caveats, display_times)
}

// Ruby method `display_caveats(force: false)` at line 51.
pub fn ruby_messages_l51_d9_display_caveats(messages Messages, force bool) string {
	return messages.display_caveats(force)
}

// Ruby method `display_install_times` at line 64.
pub fn ruby_messages_l64_d10_display_install_times(messages Messages) string {
	return messages.display_install_times()
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/output"
// 5:
// 6: # A {Messages} object collects messages that may need to be displayed together
// 7: # at the end of a multi-step `brew` command run.
// 8: class Messages
// 9:   include ::Utils::Output::Mixin
// 10:
// 11:   sig { returns(T::Array[{ package: String, caveats: T.any(String, Caveats) }]) }
// 12:   attr_reader :caveats
// 13:
// 14:   sig { returns(Integer) }
// 15:   attr_reader :package_count
// 16:
// 17:   sig { returns(T::Array[{ package: String, time: Float }]) }
// 18:   attr_reader :install_times
// 19:
// 20:   sig { void }
// 21:   def initialize
// 22:     @caveats = T.let([], T::Array[{ package: String, caveats: T.any(String, Caveats) }])
// 23:     @completions_and_elisp = T.let(Set.new, T::Set[String])
// 24:     @package_count = T.let(0, Integer)
// 25:     @install_times = T.let([], T::Array[{ package: String, time: Float }])
// 26:   end
// 27:
// 28:   sig { params(package: String, caveats: T.any(String, Caveats)).void }
// 29:   def record_caveats(package, caveats)
// 30:     @caveats.push(package:, caveats:)
// 31:   end
// 32:
// 33:   sig { params(completions_and_elisp: T::Array[String]).void }
// 34:   def record_completions_and_elisp(completions_and_elisp)
// 35:     @completions_and_elisp.merge(completions_and_elisp)
// 36:   end
// 37:
// 38:   sig { params(package: String, elapsed_time: Float).void }
// 39:   def package_installed(package, elapsed_time)
// 40:     @package_count += 1
// 41:     @install_times.push(package:, time: elapsed_time)
// 42:   end
// 43:
// 44:   sig { params(force_caveats: T::Boolean, display_times: T::Boolean).void }
// 45:   def display_messages(force_caveats: false, display_times: false)
// 46:     display_caveats(force: force_caveats)
// 47:     display_install_times if display_times
// 48:   end
// 49:
// 50:   sig { params(force: T::Boolean).void }
// 51:   def display_caveats(force: false)
// 52:     return if @package_count.zero?
// 53:     return if @caveats.empty? && @completions_and_elisp.empty?
// 54:
// 55:     oh1 "Caveats" unless @completions_and_elisp.empty?
// 56:     @completions_and_elisp.each { |c| puts c }
// 57:     return if @package_count == 1 && !force
// 58:
// 59:     oh1 "Caveats" if @completions_and_elisp.empty?
// 60:     @caveats.each { |c| ohai c.fetch(:package), c.fetch(:caveats) }
// 61:   end
// 62:
// 63:   sig { void }
// 64:   def display_install_times
// 65:     return if install_times.empty?
// 66:
// 67:     oh1 "Installation times"
// 68:     install_times.each do |t|
// 69:       puts format("%<package>-20s %<time>10.3f s", t)
// 70:     end
// 71:   end
// 72: end
