module cmd

import ruby

// Translated from Homebrew/brew `cmd/home.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum HomeItemKind {
	formula
	cask
}

pub struct HomeItem {
pub:
	kind             HomeItemKind
	name             string
	homepage         string
	inferred_as_cask bool
	source_path      string
}

pub struct HomeCommandPlan {
pub:
	messages  []string
	warnings  []string
	homepages []string
}

pub fn home_item_name(item HomeItem) string {
	return match item.kind {
		.formula { 'Formula ${item.name}' }
		.cask { 'Cask ${item.name}' }
	}
}

pub fn plan_home_command(homebrew_www string, items []HomeItem) HomeCommandPlan {
	if items.len == 0 {
		return HomeCommandPlan{
			homepages: [homebrew_www]
		}
	}
	mut messages := []string{}
	mut warnings := []string{}
	mut homepages := []string{}
	for item in items {
		messages << 'Opening homepage for ${home_item_name(item)}'
		if item.inferred_as_cask && item.source_path != '' {
			warnings << 'Treating ${item.source_path} as a cask'
		}
		homepages << item.homepage
	}
	return HomeCommandPlan{
		messages: messages
		warnings: warnings
		homepages: homepages
	}
}

pub fn home_item_value(item HomeItem) ruby.Value {
	return ruby.structured_value(if item.kind == .formula { 'Formula' } else { 'Cask' }, item.name, {
		'name':             item.name
		'homepage':         item.homepage
		'kind':             item.kind.str()
		'inferred_as_cask': item.inferred_as_cask.str()
		'source_path':      item.source_path
	})
}

fn home_item_from_value(value ruby.Value) HomeItem {
	kind := if (value.attribute('kind') or { value.type_name.to_lower() }) == 'cask' {
		HomeItemKind.cask
	} else {
		HomeItemKind.formula
	}
	return HomeItem{
		kind: kind
		name: value.attribute('name') or { value.as_string() }
		homepage: value.attribute('homepage') or { '' }
		inferred_as_cask: (value.attribute('inferred_as_cask') or { 'false' }) == 'true'
		source_path: value.attribute('source_path') or { '' }
	}
}

pub fn home_command_plan_value(plan HomeCommandPlan) ruby.Value {
	return ruby.Value{
		type_name: 'HomeCommandPlan'
		repr: plan.homepages.join(' ')
		map_data: {
			'messages':  ruby.string_array_value(plan.messages)
			'warnings':  ruby.string_array_value(plan.warnings)
			'homepages': ruby.string_array_value(plan.homepages)
		}
	}
}

// Ruby method `run` at line 26.
pub fn ruby_home_l26_d1_run(args ...ruby.Value) ruby.Value {
	www := if args.len > 0 { args[0].as_string() } else { 'https://brew.sh' }
	items := if args.len > 1 {
		args[1].as_array() or { []ruby.Value{} }
	} else {
		[]ruby.Value{}
	}
	return home_command_plan_value(plan_home_command(www, items.map(home_item_from_value(it))))
}

// Ruby method `name_of(formula_or_cask)` at line 45.
pub fn ruby_home_l45_d2_name_of(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'name_of requires a Formula or Cask')
	}
	return ruby.string_value(home_item_name(home_item_from_value(args[0])))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6:
// 7: module Homebrew
// 8:   module Cmd
// 9:     class Home < AbstractCommand
// 10:       cmd_args do
// 11:         description <<~EOS
// 12:           Open a <formula> or <cask>'s homepage in a browser, or open
// 13:           Homebrew's own homepage if no argument is provided.
// 14:         EOS
// 15:         switch "--formula", "--formulae",
// 16:                description: "Treat all named arguments as formulae."
// 17:         switch "--cask", "--casks",
// 18:                description: "Treat all named arguments as casks."
// 19:
// 20:         conflicts "--formula", "--cask"
// 21:
// 22:         named_args [:formula, :cask]
// 23:       end
// 24:
// 25:       sig { override.void }
// 26:       def run
// 27:         if args.no_named?
// 28:           exec_browser HOMEBREW_WWW
// 29:           return
// 30:         end
// 31:
// 32:         # to_formulae_and_casks is typed to possibly return Kegs (but won't without explicitly asking)
// 33:         formulae_or_casks = T.cast(args.named.to_formulae_and_casks, T::Array[T.any(Formula, Cask::Cask)])
// 34:         homepages = formulae_or_casks.map do |formula_or_cask|
// 35:           puts "Opening homepage for #{name_of(formula_or_cask)}"
// 36:           formula_or_cask.homepage
// 37:         end
// 38:
// 39:         exec_browser(*homepages)
// 40:       end
// 41:
// 42:       private
// 43:
// 44:       sig { params(formula_or_cask: T.any(Formula, Cask::Cask)).returns(String) }
// 45:       def name_of(formula_or_cask)
// 46:         if formula_or_cask.is_a? Formula
// 47:           "Formula #{formula_or_cask.name}"
// 48:         else
// 49:           "Cask #{formula_or_cask.token}"
// 50:         end
// 51:       end
// 52:     end
// 53:   end
// 54: end
