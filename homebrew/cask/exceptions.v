module cask

import ruby

// Translated from Homebrew/brew `cask/exceptions.rb`.

// Ruby method `to_s` at line 167.
pub fn ruby_exceptions_l167_d23_to_s(args ...ruby.Value) ruby.Value {
	return ruby.string_value(cask_exception_message(cask_exception_from_args(args, .self_referencing)))
}

pub enum CaskExceptionKind {
	multiple
	not_installed
	cannot_install
	conflict
	unavailable
	unreadable
	tap_unavailable
	ambiguity
	already_created
	cyclic
	self_referencing
	unspecified
	invalid
	quarantine
	quarantine_propagation
	quarantine_release
}

pub struct CaskException {
pub:
	kind             CaskExceptionKind
	token            string
	reason           string
	detail           string
	conflicting_cask string
	tap              string
	tap_installed    bool
	loaders          []string
	errors           []string
	path             string
}

pub fn cask_exception_message(exception CaskException) string {
	return match exception.kind {
		.multiple { 'Problems with multiple casks:\n${exception.errors.join('\n')}\n' }
		.not_installed { "Cask '${exception.token}' is not installed." }
		.cannot_install { "Cask '${exception.token}' has been ${exception.detail}" }
		.conflict { "Cask '${exception.token}' conflicts with '${exception.conflicting_cask}'." }
		.unavailable {
			"Cask '${exception.token}' is unavailable${if exception.reason == '' {
				'.'
			} else {
				': ' + exception.reason
			}}"
		}
		.unreadable {
			"Cask '${exception.token}' is unreadable${if exception.reason == '' {
				'.'
			} else {
				': ' + exception.reason
			}}"
		}
		.tap_unavailable {
			mut message := "Cask '${exception.token}' is unavailable."
			if !exception.tap_installed {
				message += '\nThis command requires the tap ${exception.tap}.\nIf you trust this tap, tap it explicitly and then try again:\n  brew tap ${exception.tap}'
			}
			message
		}
		.ambiguity {
			mut casks := exception.loaders.map('${it}/${exception.token}')
			casks.sort()
			list := casks.map('\n       * ${it}').join('')
			example := casks[0] or { exception.token }
			'Cask ${exception.token} exists in multiple taps:${list}\n\nPlease use the fully-qualified name (e.g. ${example}) to refer to a specific Cask.\n'
		}
		.already_created {
			"Cask '${exception.token}' already exists. Run `brew edit --cask ${exception.token}` to edit it."
		}
		.cyclic {
			"Cask '${exception.token}' includes cyclic dependencies on other Casks${if exception.reason == '' {
				'.'
			} else {
				': ' + exception.reason
			}}"
		}
		.self_referencing { "Cask '${exception.token}' depends on itself." }
		.unspecified { 'This command requires a Cask token.' }
		.invalid {
			"Cask '${exception.token}' definition is invalid${if exception.reason == '' {
				'.'
			} else {
				': ' + exception.reason
			}}"
		}
		.quarantine {
			cask_quarantine_message('Failed to quarantine ${exception.path}.', exception.reason)
		}
		.quarantine_propagation {
			cask_quarantine_message('Failed to quarantine one or more files within ${exception.path}.', exception.reason)
		}
		.quarantine_release {
			cask_quarantine_message('Failed to release ${exception.path} from quarantine.', exception.reason)
		}
	}
}

fn cask_quarantine_message(prefix string, reason string) string {
	if reason == '' {
		return prefix
	}
	return "${prefix} Here's the reason:\n${reason}${if reason.ends_with('\n') { '' } else { '\n' }}"
}

fn cask_exception_from_args(args []ruby.Value, default_kind CaskExceptionKind) CaskException {
	value := args[0] or { return CaskException{ kind: default_kind } }
	if value.type_name != 'Hash' {
		return CaskException{ kind: default_kind, token: value.as_string() }
	}
	values := value.map_data.clone()
	return CaskException{
		kind: default_kind
		token: (values['token'] or { ruby.string_value('') }).as_string()
		reason: (values['reason'] or { ruby.string_value('') }).as_string()
		detail: (values['message'] or { ruby.string_value('') }).as_string()
		conflicting_cask: (values['conflicting_cask'] or { ruby.string_value('') }).as_string()
		tap: (values['tap'] or { ruby.string_value('') }).as_string()
		tap_installed: (values['tap_installed'] or { ruby.bool_value(false) }).bool_data
		loaders: (values['loaders'] or { ruby.string_array_value([]) }).as_string_array() or { []string{} }
		errors: (values['errors'] or { ruby.string_array_value([]) }).as_string_array() or { []string{} }
		path: (values['path'] or { ruby.string_value('') }).as_string()
	}
}

fn cask_exception_value(exception CaskException) ruby.Value {
	return ruby.map_value({
		'kind':             ruby.string_value(exception.kind.str())
		'token':            ruby.string_value(exception.token)
		'reason':           ruby.string_value(exception.reason)
		'message':          ruby.string_value(exception.detail)
		'conflicting_cask': ruby.string_value(exception.conflicting_cask)
		'tap':              ruby.string_value(exception.tap)
		'tap_installed':    ruby.bool_value(exception.tap_installed)
		'loaders':          ruby.string_array_value(exception.loaders)
		'errors':           ruby.string_array_value(exception.errors)
		'path':             ruby.string_value(exception.path)
	})
}

fn cask_exception_kind(name string, fallback CaskExceptionKind) CaskExceptionKind {
	return match name {
		'multiple' { .multiple }
		'not_installed' { .not_installed }
		'cannot_install' { .cannot_install }
		'conflict' { .conflict }
		'unavailable' { .unavailable }
		'unreadable' { .unreadable }
		'tap_unavailable' { .tap_unavailable }
		'ambiguity' { .ambiguity }
		'already_created' { .already_created }
		'cyclic' { .cyclic }
		'self_referencing' { .self_referencing }
		'unspecified' { .unspecified }
		'invalid' { .invalid }
		'quarantine' { .quarantine }
		'quarantine_propagation' { .quarantine_propagation }
		'quarantine_release' { .quarantine_release }
		else { fallback }
	}
}
