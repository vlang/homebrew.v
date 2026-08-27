module lib

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/sorbet-runtime.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: true
// 3:
// 4: # This file is hand-crafted to encode the dependencies. They load the whole type
// 5: # system since there is such a high chance of it being used, using an autoloader
// 6: # wouldn't buy us any startup time saving.
// 7:
// 8: # Namespaces without any implementation
// 9: module T; end
// 10: module T::Helpers; end
// 11: module T::Private; end
// 12: T::Private::IS_TYPECHECKING = false
// 13: module T::Private::Abstract; end
// 14: module T::Private::Types; end
// 15:
// 16: # Each section is a group that I believe need a fixed ordering. There is also
// 17: # an ordering between groups.
// 18:
// 19: # These are pre-reqs for almost everything in here.
// 20: require_relative 'types/configuration'
// 21: require_relative 'types/_types'
// 22: require_relative 'types/private/decl_state'
// 23: require_relative 'types/private/caller_utils'
// 24: require_relative 'types/private/class_utils'
// 25: require_relative 'types/private/runtime_levels'
// 26: require_relative 'types/private/methods/_methods'
// 27: require_relative 'types/sig'
// 28: require_relative 'types/def_mods'
// 29: require_relative 'types/helpers'
// 30: require_relative 'types/syntax'
// 31: require_relative 'types/private/final'
// 32: require_relative 'types/private/sealed'
// 33:
// 34: # The types themselves. First base classes
// 35: require_relative 'types/types/base'
// 36: require_relative 'types/types/typed_enumerable'
// 37: # Everything else
// 38: require_relative 'types/types/class_of'
// 39: require_relative 'types/types/enum'
// 40: require_relative 'types/types/fixed_array'
// 41: require_relative 'types/types/fixed_hash'
// 42: require_relative 'types/types/intersection'
// 43: require_relative 'types/types/noreturn'
// 44: require_relative 'types/types/anything'
// 45: require_relative 'types/types/proc'
// 46: require_relative 'types/types/attached_class'
// 47: require_relative 'types/types/self_type'
// 48: require_relative 'types/types/simple'
// 49: require_relative 'types/types/t_enum'
// 50: require_relative 'types/types/type_parameter'
// 51: require_relative 'types/types/typed_enumerator'
// 52: require_relative 'types/types/typed_enumerator_chain'
// 53: require_relative 'types/types/typed_enumerator_lazy'
// 54: require_relative 'types/types/typed_range'
// 55: require_relative 'types/types/typed_set'
// 56: require_relative 'types/types/union'
// 57: require_relative 'types/types/untyped'
// 58: require_relative 'types/private/types/not_typed'
// 59: require_relative 'types/private/types/void'
// 60: require_relative 'types/private/types/string_holder'
// 61: require_relative 'types/private/types/type_alias'
// 62: require_relative 'types/private/types/simple_pair_union'
// 63:
// 64: require_relative 'types/types/type_variable'
// 65: require_relative 'types/types/type_member'
// 66: require_relative 'types/types/type_template'
// 67:
// 68: # Call validation
// 69: require_relative 'types/private/methods/modes'
// 70: require_relative 'types/private/methods/call_validation'
// 71:
// 72: # Signature validation
// 73: require_relative 'types/private/methods/signature_validation'
// 74: require_relative 'types/abstract_utils'
// 75: require_relative 'types/private/abstract/validate'
// 76:
// 77: # Catch all. Sort of built by `cd extn; find types -type f | grep -v test | sort`
// 78: require_relative 'types/generic'
// 79: require_relative 'types/private/abstract/declare'
// 80: require_relative 'types/private/abstract/hooks'
// 81: require_relative 'types/private/casts'
// 82: require_relative 'types/private/methods/decl_builder'
// 83: require_relative 'types/private/methods/signature'
// 84: require_relative 'types/private/retry'
// 85: require_relative 'types/utils'
// 86: require_relative 'types/boolean'
// 87:
// 88: # Depends on types/utils
// 89: # typed_hash must load after untyped + utils so TypedHash::Untyped::Private::INSTANCE
// 90: # (a frozen, shared T::Hash[T.untyped, T.untyped]) can be built at load time, the same
// 91: # way TypedArray::Untyped::Private::INSTANCE is.
// 92: require_relative 'types/types/typed_hash'
// 93: require_relative 'types/types/typed_array'
// 94: require_relative 'types/types/typed_module'
// 95: require_relative 'types/types/typed_class'
// 96:
// 97: # Props dependencies
// 98: require_relative 'types/private/abstract/data'
// 99: require_relative 'types/private/mixins/mixins'
// 100: require_relative 'types/props/_props'
// 101: require_relative 'types/props/custom_type'
// 102: require_relative 'types/props/decorator'
// 103: require_relative 'types/props/errors'
// 104: require_relative 'types/props/plugin'
// 105: require_relative 'types/props/utils'
// 106: require_relative 'types/enum'
// 107: # Props that run sigs statically so have to be after all the others :(
// 108: require_relative 'types/props/private/setter_factory'
// 109: require_relative 'types/props/private/apply_default'
// 110: require_relative 'types/props/has_lazily_specialized_methods'
// 111: require_relative 'types/props/optional'
// 112: require_relative 'types/props/weak_constructor'
// 113: require_relative 'types/props/constructor'
// 114: require_relative 'types/props/pretty_printable'
// 115: require_relative 'types/props/private/serde_transform'
// 116: require_relative 'types/props/private/deserializer_generator'
// 117: require_relative 'types/props/private/serializer_generator'
// 118: require_relative 'types/props/serializable'
// 119: require_relative 'types/props/type_validation'
// 120: require_relative 'types/props/private/parser'
// 121: require_relative 'types/props/generated_code_validation'
// 122:
// 123: require_relative 'types/struct'
// 124:
// 125: require_relative 'types/compatibility_patches'
