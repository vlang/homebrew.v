module cask

import ruby
import homebrew.utils

// Translated from Homebrew/brew `cask/list.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct CaskListArtifact {
pub:
	class_name           string
	english_name         string
	display              string
	summary              string
	summarizes_installed bool
}

pub struct CaskListCask {
pub:
	token             string
	full_name         string
	installed         bool = true
	installed_version ?string
	artifacts         []CaskListArtifact
}

pub struct CaskListOptions {
pub:
	one           bool
	full_name     bool
	versions      bool
	console_width int = 80
	stream_is_tty bool
}

pub struct CaskListRequest {
pub:
	casks          []CaskListCask
	caskroom_casks []CaskListCask
	options        CaskListOptions
}

fn cask_list_bool(value ruby.Value, key string) bool {
	if item := value.map_data[key] {
		return item.as_bool() or { false }
	}
	return (value.attributes[key] or { 'false' }) == 'true'
}

fn cask_list_int(value ruby.Value, key string, fallback int) int {
	if item := value.map_data[key] {
		return int(item.as_int() or { i64(fallback) })
	}
	return (value.attributes[key] or { return fallback }).int()
}

fn cask_list_artifact_from_value(value ruby.Value) CaskListArtifact {
	class_name := value.attributes['class_name'] or { value.type_name }
	return CaskListArtifact{
		class_name: class_name
		english_name: value.attributes['english_name'] or { class_name.all_after_last('::') }
		display: value.attributes['display'] or { value.repr }
		summary: value.attributes['summary'] or { '' }
		summarizes_installed: cask_list_bool(value, 'summarizes_installed')
			|| 'summary' in value.attributes
	}
}

fn cask_list_cask_from_value(value ruby.Value) CaskListCask {
	artifact_values := (value.map_data['artifacts'] or { ruby.array_value([]) }).as_array() or {
		[]ruby.Value{}
	}
	installed_version := if raw := value.map_data['installed_version'] {
		if raw.type_name == 'NilClass' {
			?string(none)
		} else {
			?string(raw.as_string())
		}
	} else if raw := value.attributes['installed_version'] {
		?string(raw)
	} else {
		?string(none)
	}
	return CaskListCask{
		token: value.attributes['token'] or { value.repr.all_after_last('/') }
		full_name: value.attributes['full_name'] or { value.repr }
		installed: if 'installed' in value.attributes || 'installed' in value.map_data {
			cask_list_bool(value, 'installed')
		} else {
			true
		}
		installed_version: installed_version
		artifacts: artifact_values.map(cask_list_artifact_from_value(it))
	}
}

fn cask_list_artifact_value(artifact CaskListArtifact) ruby.Value {
	mut attributes := {
		'class_name':           artifact.class_name
		'english_name':         artifact.english_name
		'display':              artifact.display
		'summarizes_installed': artifact.summarizes_installed.str()
	}
	if artifact.summarizes_installed {
		attributes['summary'] = artifact.summary
	}
	return ruby.structured_value(artifact.class_name, artifact.display, attributes)
}

pub fn cask_list_cask_value(cask CaskListCask) ruby.Value {
	mut installed_version := ruby.object_value('NilClass', 'nil')
	mut attributes := {
		'token':     cask.token
		'full_name': cask.full_name
		'installed': cask.installed.str()
	}
	if version := cask.installed_version {
		installed_version = ruby.string_value(version)
		attributes['installed_version'] = version
	}
	return ruby.Value{
		type_name: 'Cask::Cask'
		repr: cask.token
		attributes: attributes
		map_data: {
			'installed_version': installed_version
			'artifacts':         ruby.array_value(cask.artifacts.map(cask_list_artifact_value(it)))
		}
	}
}

fn cask_list_options_value(options CaskListOptions) ruby.Value {
	return ruby.map_value({
		'one':           ruby.bool_value(options.one)
		'full_name':     ruby.bool_value(options.full_name)
		'versions':      ruby.bool_value(options.versions)
		'console_width': ruby.int_value(options.console_width)
		'stream_is_tty': ruby.bool_value(options.stream_is_tty)
	})
}

pub fn cask_list_request_value(request CaskListRequest) ruby.Value {
	return ruby.Value{
		type_name: 'Cask::ListRequest'
		map_data: {
			'casks':          ruby.array_value(request.casks.map(cask_list_cask_value(it)))
			'caskroom_casks': ruby.array_value(request.caskroom_casks.map(cask_list_cask_value(it)))
			'options':        cask_list_options_value(request.options)
		}
	}
}

fn cask_list_request_from_value(value ruby.Value) CaskListRequest {
	casks := (value.map_data['casks'] or { ruby.array_value([]) }).as_array() or {
		[]ruby.Value{}
	}
	caskroom_casks := (value.map_data['caskroom_casks'] or { ruby.array_value([]) }).as_array() or {
		[]ruby.Value{}
	}
	options_value := value.map_data['options'] or { value }
	return CaskListRequest{
		casks: casks.map(cask_list_cask_from_value(it))
		caskroom_casks: caskroom_casks.map(cask_list_cask_from_value(it))
		options: CaskListOptions{
			one: cask_list_bool(options_value, 'one')
			full_name: cask_list_bool(options_value, 'full_name')
			versions: cask_list_bool(options_value, 'versions')
			console_width: cask_list_int(options_value, 'console_width', 80)
			stream_is_tty: cask_list_bool(options_value, 'stream_is_tty')
		}
	}
}

fn cask_list_tap_and_name_compare(left &string, right &string) int {
	left_has_tap := left.contains('/')
	right_has_tap := right.contains('/')
	if left_has_tap && !right_has_tap {
		return 1
	}
	if !left_has_tap && right_has_tap {
		return -1
	}
	return left.compare(right)
}

pub fn cask_list_sort_tap_and_name(values []string) []string {
	mut sorted := values.clone()
	sorted.sort_with_compare(cask_list_tap_and_name_compare)
	return sorted
}

pub fn cask_list_format_versioned(cask CaskListCask) string {
	if version := cask.installed_version {
		return '${cask.token} ${version}'
	}
	return cask.token
}

pub fn cask_list_artifacts(cask CaskListCask) string {
	mut grouped := map[string][]CaskListArtifact{}
	mut english_names := map[string]string{}
	for artifact in cask.artifacts {
		if artifact.class_name in ['Uninstall', 'Zap', 'Cask::Artifact::Uninstall',
			'Cask::Artifact::Zap'] {
			continue
		}
		grouped[artifact.class_name] << artifact
		english_names[artifact.class_name] = artifact.english_name
	}
	mut classes := grouped.keys()
	classes.sort_with_compare(fn [english_names] (left &string, right &string) int {
		return (english_names[*left] or { *left }).compare(english_names[*right] or { *right })
	})
	mut output := ''
	for class_name in classes {
		output += '${utils.output_ohai_title(english_names[class_name] or { class_name }, utils.OutputOptions{})}\n'
		for artifact in grouped[class_name] {
			output += if artifact.summarizes_installed {
				'${artifact.summary}\n'
			} else {
				'${artifact.display}\n'
			}
		}
	}
	return output
}

pub fn cask_list_casks(request CaskListRequest) !string {
	explicit := request.casks.len > 0
	output := if explicit { request.casks } else { request.caskroom_casks }
	if explicit {
		for cask in output {
			if !cask.installed {
				return error('CaskNotInstalledError: ${cask.token}')
			}
		}
	}
	if output.len == 0 {
		return ''
	}
	if request.options.one {
		return '${output.map(it.token).join('\n')}\n'
	}
	if request.options.full_name {
		return '${cask_list_sort_tap_and_name(output.map(it.full_name)).join('\n')}\n'
	}
	if request.options.versions {
		return '${output.map(cask_list_format_versioned(it)).join('\n')}\n'
	}
	if explicit {
		return output.map(cask_list_artifacts(it)).join('')
	}
	return utils.formatter_columns(output.map(it.token), request.options.console_width, request.options.stream_is_tty, 2, 0)
}

// Ruby method `self.list_casks(*casks, one: false, full_name: false, versions: false)` at line 25.
pub fn ruby_list_l25_d1_self_list_casks(args ...ruby.Value) ruby.Value {
	request := if args.len == 1 && args[0].type_name == 'Cask::ListRequest' {
		cask_list_request_from_value(args[0])
	} else {
		CaskListRequest{
			casks: args.map(cask_list_cask_from_value(it))
		}
	}
	output := cask_list_casks(request) or {
		return ruby.object_value('CaskNotInstalledError', err.msg())
	}
	return ruby.string_value(output)
}

// Ruby method `self.list_artifacts(cask)` at line 48.
pub fn ruby_list_l48_d2_self_list_artifacts(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'cask is required')
	}
	return ruby.string_value(cask_list_artifacts(cask_list_cask_from_value(args[0])))
}

// Ruby method `self.format_versioned(cask)` at line 63.
pub fn ruby_list_l63_d3_self_format_versioned(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'cask is required')
	}
	return ruby.string_value(cask_list_format_versioned(cask_list_cask_from_value(args[0])))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/relocated"
// 5: require "utils/output"
// 6:
// 7: module Cask
// 8:   module List
// 9:     extend ::Utils::Output::Mixin
// 10:
// 11:     TAP_AND_NAME_COMPARISON = T.let(
// 12:       proc do |a, b|
// 13:         if a.include?("/") && b.exclude?("/")
// 14:           1
// 15:         elsif a.exclude?("/") && b.include?("/")
// 16:           -1
// 17:         else
// 18:           a <=> b
// 19:         end
// 20:       end.freeze,
// 21:       T.proc.params(a: String, b: String).returns(Integer),
// 22:     )
// 23:
// 24:     sig { params(casks: Cask, one: T::Boolean, full_name: T::Boolean, versions: T::Boolean).void }
// 25:     def self.list_casks(*casks, one: false, full_name: false, versions: false)
// 26:       output = if casks.any?
// 27:         casks.each do |cask|
// 28:           raise CaskNotInstalledError, cask unless cask.installed?
// 29:         end
// 30:       else
// 31:         Caskroom.casks
// 32:       end
// 33:
// 34:       if one
// 35:         puts output.map(&:to_s)
// 36:       elsif full_name
// 37:         puts output.map(&:full_name).sort(&TAP_AND_NAME_COMPARISON)
// 38:       elsif versions
// 39:         puts output.map { format_versioned(it) }
// 40:       elsif !output.empty? && casks.any?
// 41:         output.map { list_artifacts(it) }
// 42:       elsif !output.empty?
// 43:         puts Formatter.columns(output.map(&:to_s))
// 44:       end
// 45:     end
// 46:
// 47:     sig { params(cask: Cask).void }
// 48:     def self.list_artifacts(cask)
// 49:       cask.artifacts.group_by(&:class).sort_by { |klass, _| klass.english_name }.each do |klass, artifacts|
// 50:         next if [Artifact::Uninstall, Artifact::Zap].include? klass
// 51:
// 52:         ohai klass.english_name
// 53:         artifacts.each do |artifact|
// 54:           puts artifact.summarize_installed if artifact.respond_to?(:summarize_installed)
// 55:           next if artifact.respond_to?(:summarize_installed)
// 56:
// 57:           puts artifact
// 58:         end
// 59:       end
// 60:     end
// 61:
// 62:     sig { params(cask: Cask).returns(String) }
// 63:     def self.format_versioned(cask)
// 64:       "#{cask}#{cask.installed_version&.prepend(" ")}"
// 65:     end
// 66:   end
// 67: end
