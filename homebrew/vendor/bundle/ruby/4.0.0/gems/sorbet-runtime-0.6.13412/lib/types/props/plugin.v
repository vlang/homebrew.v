module props

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/props/plugin.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct PropsPlugin {
pub:
	name                  string
	has_class_methods     bool
	has_decorator_methods bool
}

pub struct PluginTarget {
pub:
	name string
pub mut:
	plugins              []string
	class_extensions     []string
	decorator_extensions []string
}

fn append_unique(mut values []string, value string) {
	if value !in values {
		values << value
	}
}

pub fn include_props_plugin(plugin PropsPlugin, mut child PluginTarget) {
	append_unique(mut child.plugins, plugin.name)
}

// These are standalone functions, as in the Ruby Private module, so applying
// them does not cause a decorator to be constructed prematurely.
pub fn apply_plugin_class_methods(plugin PropsPlugin, mut target PluginTarget) {
	if plugin.has_class_methods {
		append_unique(mut target.class_extensions, '${plugin.name}::ClassMethods')
	}
}

pub fn apply_plugin_decorator_methods(plugin PropsPlugin, mut target PluginTarget) {
	if plugin.has_decorator_methods {
		append_unique(mut target.decorator_extensions, '${plugin.name}::DecoratorMethods')
	}
}

fn props_plugin_from_value(value brew_runtime.Value) PropsPlugin {
	return PropsPlugin{
		name: value.attribute('name') or { value.as_string() }
		has_class_methods: value.attribute('has_class_methods') or { 'false' } == 'true'
		has_decorator_methods: value.attribute('has_decorator_methods') or { 'false' } == 'true'
	}
}

fn plugin_names(value brew_runtime.Value, attribute string) []string {
	raw := value.attribute(attribute) or { '' }
	return raw.split(',').filter(it.len > 0)
}

fn plugin_target_from_value(value brew_runtime.Value) PluginTarget {
	return PluginTarget{
		name: value.attribute('name') or { value.as_string() }
		plugins: plugin_names(value, 'plugins')
		class_extensions: plugin_names(value, 'class_extensions')
		decorator_extensions: plugin_names(value, 'decorator_extensions')
	}
}

fn plugin_target_value(target PluginTarget) brew_runtime.Value {
	return brew_runtime.structured_value('T::Props::PluginTarget', target.name, {
		'name':                 target.name
		'plugins':              target.plugins.join(',')
		'class_extensions':     target.class_extensions.join(',')
		'decorator_extensions': target.decorator_extensions.join(',')
	})
}

// Ruby method `included(child)` at line 9.
pub fn ruby_plugin_l9_d1_included(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Plugin#included requires a child')
	}
	mut child := plugin_target_from_value(args[1])
	include_props_plugin(props_plugin_from_value(args[0]), mut child)
	return plugin_target_value(child)
}

// Ruby method `self.apply_class_methods(plugin, target)` at line 21.
pub fn ruby_plugin_l21_d2_self_apply_class_methods(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Plugin.apply_class_methods requires plugin and target')
	}
	mut target := plugin_target_from_value(args[1])
	apply_plugin_class_methods(props_plugin_from_value(args[0]), mut target)
	return plugin_target_value(target)
}

// Ruby method `self.apply_decorator_methods(plugin, target)` at line 29.
pub fn ruby_plugin_l29_d3_self_apply_decorator_methods(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		panic('Plugin.apply_decorator_methods requires plugin and target')
	}
	mut target := plugin_target_from_value(args[1])
	apply_plugin_decorator_methods(props_plugin_from_value(args[0]), mut target)
	return plugin_target_value(target)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: false
// 3:
// 4: module T::Props::Plugin
// 5:   include T::Props
// 6:   extend T::Helpers
// 7:
// 8:   module ClassMethods
// 9:     def included(child)
// 10:       super
// 11:       child.plugin(self)
// 12:     end
// 13:   end
// 14:   mixes_in_class_methods(ClassMethods)
// 15:
// 16:   module Private
// 17:     # These need to be non-instance methods so we can use them without prematurely creating the
// 18:     # child decorator in `model_inherited` (see comments there for details).
// 19:     #
// 20:     # The dynamic constant access below forces this file to be `typed: false`
// 21:     def self.apply_class_methods(plugin, target)
// 22:       if plugin.const_defined?('ClassMethods')
// 23:         # FIXME: This will break preloading, selective test execution, etc if `mod::ClassMethods`
// 24:         # is ever defined in a separate file from `mod`.
// 25:         target.extend(plugin::ClassMethods)
// 26:       end
// 27:     end
// 28:
// 29:     def self.apply_decorator_methods(plugin, target)
// 30:       if plugin.const_defined?('DecoratorMethods')
// 31:         # FIXME: This will break preloading, selective test execution, etc if `mod::DecoratorMethods`
// 32:         # is ever defined in a separate file from `mod`.
// 33:         target.extend(plugin::DecoratorMethods)
// 34:       end
// 35:     end
// 36:   end
// 37: end
