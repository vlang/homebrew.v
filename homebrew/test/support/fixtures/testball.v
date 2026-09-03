module fixtures

import brew_runtime

pub struct FixtureFormula {
pub:
	class_name         string
	name               string
	path               string
	spec               string
	alias_path         string
	tap                string
	force_bottle       bool
	url                string
	sha256             string
	deny_network_build bool
	bottle_root_url    string
	bottle_tag         string
	bottle_sha256      string
}

pub struct FixtureInstallPlan {
pub:
	commands       [][]string
	prefix_install []string
	chdir          string
	error_type     string
	error_message  string
}

// Translated from Homebrew/brew `test/support/fixtures/testball.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(name = "testball", path = Pathname.new(__FILE__).expand_path, spec = :stable,` at line 7.
pub fn ruby_testball_l7_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return fixture_formula_value(fixture_formula_from_args(args, 'Testball', 'testball', false, false))
}

// Ruby method `self.inherited(other)` at line 20.
pub fn ruby_testball_l20_d2_self_inherited(args ...brew_runtime.Value) brew_runtime.Value {
	other := if args.len > 0 {
		args[0]
	} else {
		brew_runtime.object_value('Class', 'TestballSubclass')
	}
	return fixture_inherited_value(other, fixture_formula_from_args([], 'Testball', 'testball', false, false))
}

// Ruby method `install` at line 25.
pub fn ruby_testball_l25_d3_install(args ...brew_runtime.Value) brew_runtime.Value {
	return fixture_install_value(fixture_install_plan('testball', false))
}

pub fn fixture_formula_from_args(args []brew_runtime.Value, class_name string, default_name string,
	deny_network_build bool, bottle bool) FixtureFormula {
	fixture_dir := if args.len > 6 { args[6].as_string() } else { 'test/support/fixtures' }
	return FixtureFormula{
		class_name: class_name
		name: if args.len > 0 { args[0].as_string() } else { default_name }
		path: if args.len > 1 { args[1].as_string() } else { '${default_name}.rb' }
		spec: if args.len > 2 { args[2].as_string() } else { 'stable' }
		alias_path: if args.len > 3 { args[3].as_string() } else { '' }
		tap: if args.len > 4 { args[4].as_string() } else { '' }
		force_bottle: args.len > 5 && args[5].bool_data
		url: 'file://${fixture_dir.trim_right('/')}/tarballs/testball-0.1.tbz'
		sha256: if args.len > 7 { args[7].as_string() } else { 'TESTBALL_SHA256' }
		deny_network_build: deny_network_build
		bottle_root_url: if bottle { 'file://${fixture_dir.trim_right('/')}/bottles' } else { '' }
		bottle_tag: if bottle && args.len > 8 {
			args[8].as_string()
		} else {
			if bottle { 'current' } else { '' }
		}
		bottle_sha256: if bottle {
			'd7b9f4e8bf83608b71fe958a99f19f2e5e68bb2582965d32e41759c24f1aef97'
		} else {
			''
		}
	}
}

pub fn fixture_install_plan(kind string, fail_build bool) FixtureInstallPlan {
	if kind == 'failball' {
		mut commands := [][]string{}
		if fail_build {
			commands << ['/usr/bin/false']
		}
		return FixtureInstallPlan{
			commands: commands
			prefix_install: ['bin', 'libexec']
			error_type: if fail_build { 'BuildError' } else { 'RuntimeError' }
			error_message: if fail_build {
				'/usr/bin/false failed'
			} else {
				"Something that isn't a build error happened!"
			}
		}
	}
	if kind == 'failball_offline_install' {
		mut commands := [][]string{}
		commands << ['curl', 'example.org']
		return FixtureInstallPlan{
			commands: commands
			prefix_install: ['bin', 'libexec']
			chdir: 'doc'
		}
	}
	if kind == 'testball' {
		return FixtureInstallPlan{
			prefix_install: ['bin', 'libexec']
			chdir: 'doc'
		}
	}
	return FixtureInstallPlan{ prefix_install: ['bin', 'libexec'] }
}

pub fn fixture_formula_value(formula FixtureFormula) brew_runtime.Value {
	return brew_runtime.structured_value(formula.class_name, formula.name, {
		'name':               formula.name
		'path':               formula.path
		'spec':               formula.spec
		'alias_path':         formula.alias_path
		'tap':                formula.tap
		'force_bottle':       formula.force_bottle.str()
		'url':                formula.url
		'sha256':             formula.sha256
		'deny_network_build': formula.deny_network_build.str()
		'bottle_root_url':    formula.bottle_root_url
		'bottle_tag':         formula.bottle_tag
		'bottle_sha256':      formula.bottle_sha256
	})
}

pub fn fixture_inherited_value(other brew_runtime.Value, formula FixtureFormula) brew_runtime.Value {
	return brew_runtime.structured_value(other.type_name, other.as_string(), {
		'url':                formula.url
		'sha256':             formula.sha256
		'deny_network_build': formula.deny_network_build.str()
		'bottle_root_url':    formula.bottle_root_url
		'bottle_tag':         formula.bottle_tag
		'bottle_sha256':      formula.bottle_sha256
	})
}

pub fn fixture_install_value(plan FixtureInstallPlan) brew_runtime.Value {
	if plan.error_type != '' {
		return brew_runtime.structured_value(plan.error_type, plan.error_message, {
			'commands':       plan.commands.map(it.join(' ')).join(',')
			'prefix_install': plan.prefix_install.join(',')
		})
	}
	return brew_runtime.map_value({
		'commands':       brew_runtime.array_value(plan.commands.map(brew_runtime.string_array_value(it)))
		'prefix_install': brew_runtime.string_array_value(plan.prefix_install)
		'chdir':          brew_runtime.string_value(plan.chdir)
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: class Testball < Formula
// 5:   Cache = type_template { { fixed: T::Hash[Symbol, T.untyped] } }
// 6:
// 7:   def initialize(name = "testball", path = Pathname.new(__FILE__).expand_path, spec = :stable,
// 8:                  alias_path: nil, tap: nil, force_bottle: false)
// 9:     super
// 10:   end
// 11:
// 12:   DSL_PROC = proc do
// 13:     url "file://#{TEST_FIXTURE_DIR}/tarballs/testball-0.1.tbz"
// 14:     sha256 TESTBALL_SHA256
// 15:   end.freeze
// 16:   private_constant :DSL_PROC
// 17:
// 18:   DSL_PROC.call
// 19:
// 20:   def self.inherited(other)
// 21:     super
// 22:     other.instance_eval(&DSL_PROC)
// 23:   end
// 24:
// 25:   def install
// 26:     prefix.install "bin"
// 27:     prefix.install "libexec"
// 28:     Dir.chdir "doc"
// 29:   end
// 30: end
