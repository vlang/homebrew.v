module homebrew

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
