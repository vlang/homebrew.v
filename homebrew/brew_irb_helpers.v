module homebrew

import ruby

// Translated from Homebrew/brew `brew_irb_helpers.rb`.

pub struct IrbFormula {
pub:
	name         string
	factory_args []int
}

pub struct IrbCask {
pub:
	token  string
	config map[string]string
}

pub fn irb_formula(name string, factory_args []int) IrbFormula {
	return IrbFormula{
		name: name
		factory_args: factory_args.clone()
	}
}

pub fn irb_cask(token string, config map[string]string) IrbCask {
	return IrbCask{
		token: token
		config: config.clone()
	}
}

pub fn irb_formula_value(formula IrbFormula) ruby.Value {
	return ruby.structured_value('Formula', formula.name, {
		'name':         formula.name
		'factory_args': formula.factory_args.map(it.str()).join(',')
	})
}

pub fn irb_cask_value(cask IrbCask) ruby.Value {
	mut attributes := cask.config.clone()
	attributes['token'] = cask.token
	return ruby.structured_value('Cask::Cask', cask.token, attributes)
}

pub fn irb_cask_config_from_value(value ruby.Value) map[string]string {
	values := value.as_map() or { return map[string]string{} }
	mut config := map[string]string{}
	for key, entry in values {
		config[key] = entry.as_string()
	}
	return config
}
