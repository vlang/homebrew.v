module install_steps

import ruby
import homebrew

fn formula_action_nil_value() ruby.Value {
	return ruby.Value{
		type_name: 'NilClass'
		repr: 'nil'
	}
}

fn formula_action_error_value(message string) ruby.Value {
	return ruby.structured_value('ArgumentError', message, {
		'message': message
	})
}

fn formula_action_run(kind string, args []ruby.Value) ruby.Value {
	if args.len == 0 {
		return formula_action_error_value('${kind} requires a Runner receiver')
	}
	mut fields := map[string]ruby.Value{}
	fields['type'] = ruby.string_value(kind)
	if kind == 'install_gzipped_executable' {
		if args.len < 2 {
			return formula_action_error_value('run_install_gzipped_executable requires a step')
		}
		fields = args[1].map_data.clone()
		fields['type'] = ruby.string_value(kind)
	} else if kind == 'bootstrap_pypy' {
		if args.len < 2 {
			return formula_action_error_value('run_bootstrap_pypy requires an ABI version')
		}
		fields['abi_version'] = ruby.string_value(args[1].repr)
	}
	return homebrew.ruby_install_steps_l954_d75_run_install_step(args[0], ruby.map_value(fields))
}

// Translated from Homebrew/brew `install_steps/formula_actions.rb`.
