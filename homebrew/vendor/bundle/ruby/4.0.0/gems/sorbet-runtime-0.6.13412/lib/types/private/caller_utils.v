module private

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/private/caller_utils.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct CallerLocation {
pub:
	path  string
	line  int
	label string
}

pub type CallerPredicate = fn(CallerLocation) bool

// find_caller implements the common behavior of Ruby's two caller iteration
// APIs. The modern API exposes the helper's own frame, so callers request that
// the first entry be skipped; caller_locations(2) has already done so.
pub fn find_caller(locations []CallerLocation, skip_first bool, predicate CallerPredicate) ?CallerLocation {
	start := if skip_first { 1 } else { 0 }
	if start >= locations.len {
		return none
	}
	for location in locations[start..] {
		if location.path.starts_with('<internal:') {
			continue
		}
		if predicate(location) {
			return location
		}
	}
	return none
}

fn caller_location_from_value(value ruby.Value) CallerLocation {
	line := value.attribute('lineno') or { '0' }.int()
	return CallerLocation{
		path: value.attribute('path') or { value.as_string() }
		line: line
		label: value.attribute('label') or { '' }
	}
}

fn caller_location_value(location CallerLocation) ruby.Value {
	return ruby.structured_value('Thread::Backtrace::Location', location.path, {
		'path':   location.path
		'lineno': location.line.str()
		'label':  location.label
	})
}

fn caller_boundary(args []ruby.Value, skip_first bool) ruby.Value {
	if args.len == 0 {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	values := args[0].as_array() or { return ruby.Value{ type_name: 'NilClass', repr: 'nil' } }
	mut matches := map[string]bool{}
	mut locations := []CallerLocation{cap: values.len}
	for value in values {
		location := caller_location_from_value(value)
		locations << location
		matches['${location.path}:${location.line}:${location.label}'] = value.attribute('matches') or { 'true' } != 'false'
	}
	result := find_caller(locations, skip_first, fn [matches] (location CallerLocation) bool {
		return matches['${location.path}:${location.line}:${location.label}'] or { true }
	}) or { return ruby.Value{ type_name: 'NilClass', repr: 'nil' } }
	return caller_location_value(result)
}

// Ruby method `self.find_caller` at line 6.
pub fn ruby_caller_utils_l6_d1_self_find_caller(args ...ruby.Value) ruby.Value {
	return caller_boundary(args, true)
}

// Ruby method `self.find_caller` at line 21.
pub fn ruby_caller_utils_l21_d2_self_find_caller(args ...ruby.Value) ruby.Value {
	return caller_boundary(args, false)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: false
// 3:
// 4: module T::Private::CallerUtils
// 5:   if Thread.respond_to?(:each_caller_location) # RUBY_VERSION >= "3.2"
// 6:     def self.find_caller
// 7:       skipped_first = false
// 8:       Thread.each_caller_location do |loc|
// 9:         unless skipped_first
// 10:           skipped_first = true
// 11:           next
// 12:         end
// 13:
// 14:         next if loc.path&.start_with?("<internal:")
// 15:
// 16:         return loc if yield(loc)
// 17:       end
// 18:       nil
// 19:     end
// 20:   else
// 21:     def self.find_caller
// 22:       caller_locations(2).find do |loc|
// 23:         !loc.path&.start_with?("<internal:") && yield(loc)
// 24:       end
// 25:     end
// 26:   end
// 27: end
