module artifact

import brew_runtime

// Translated from Homebrew/brew `cask/artifact/stage_only.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct StageOnly {
pub:
	cask_token string
	value      bool
}

pub fn stage_only_from_args(cask_token string, arguments []string,
	has_keyword_arguments bool) !StageOnly {
	if arguments.len != 1 || arguments[0] != 'true' || has_keyword_arguments {
		return error('${cask_token}: `stage_only` takes only a single argument: true')
	}
	return StageOnly{
		cask_token: cask_token
		value:      true
	}
}

pub fn (stage StageOnly) to_array() []bool {
	return [true]
}

pub fn (stage StageOnly) summarize() string {
	return 'true'
}

// Ruby method `self.from_args(cask, *args, **kwargs)` at line 11.
pub fn ruby_stage_only_l11_d1_self_from_args(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('CaskInvalidError',
			'`stage_only` takes only a single argument: true')
	}
	arguments := args[1].as_string_array() or { [args[1].as_string()] }
	has_keywords := args.len > 2 && (args[2].as_bool() or { false })
	stage := stage_only_from_args(args[0].as_string(), arguments, has_keywords) or {
		return brew_runtime.object_value('CaskInvalidError', err.msg())
	}
	return brew_runtime.structured_value('StageOnly', stage.summarize(), {
		'cask_token': stage.cask_token
		'value':      stage.value.str()
	})
}

// Ruby method `to_a` at line 20.
pub fn ruby_stage_only_l20_d2_to_a(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.array_value([brew_runtime.bool_value(true)])
}

// Ruby method `summarize` at line 25.
pub fn ruby_stage_only_l25_d3_summarize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value('true')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/abstract_artifact"
// 5:
// 6: module Cask
// 7:   module Artifact
// 8:     # Artifact corresponding to the `stage_only` stanza.
// 9:     class StageOnly < AbstractArtifact
// 10:       sig { params(cask: Cask, args: T.anything, kwargs: T.anything).returns(StageOnly) }
// 11:       def self.from_args(cask, *args, **kwargs)
// 12:         if (args != [true] && args != ["true"]) || kwargs.present?
// 13:           raise CaskInvalidError.new(cask.token, "'stage_only' takes only a single argument: true")
// 14:         end
// 15:
// 16:         new(cask, true)
// 17:       end
// 18:
// 19:       sig { returns(T::Array[T::Boolean]) }
// 20:       def to_a
// 21:         [true]
// 22:       end
// 23:
// 24:       sig { override.returns(String) }
// 25:       def summarize
// 26:         "true"
// 27:       end
// 28:     end
// 29:   end
// 30: end
