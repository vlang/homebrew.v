module language

// Translated from Homebrew/brew `extend/os/mac/language/java.rb`.
pub type OpenJdkFormulaFinder = fn (string) ?string

pub fn mac_java_home(version string, finder OpenJdkFormulaFinder) ?string {
	opt_libexec := finder(version) or { return none }
	return '${opt_libexec.trim_right('/')}/openjdk.jdk/Contents/Home'
}
