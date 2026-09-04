module bundle

import ruby
import homebrew.bundle.subcommand as production_exec

// Translated from Homebrew/brew `test/cmd/bundle/exec_subcommand_spec.rb`.
// The original source is retained below until every stub has a typed V body.

fn exec_subcommand_spec_context(argv []string) production_exec.BundleExecContext {
	return production_exec.BundleExecContext{
		argv: argv
		environment: {
			'PATH': '/usr/bin:/bin'
		}
		original_environment: {
			'PATH': '/usr/bin:/bin'
		}
		available_commands: {
			'bundle': '/usr/local/bin/bundle'
		}
		home_directory: '/Users/test'
	}
}

fn exec_subcommand_spec_error(context production_exec.BundleExecContext) ruby.Value {
	_ := production_exec.build_bundle_exec_plan(context) or {
		return ruby.structured_value('RuntimeError', err.msg(), {
			'message': err.msg()
		})
	}
	return ruby.bool_value(false)
}

fn exec_subcommand_spec_services(launchctl bool) []production_exec.BundleExecServiceInfo {
	suffix := if launchctl { '.plist' } else { '.service' }
	return [
		production_exec.BundleExecServiceInfo{
			entry_name: 'nginx'
			formula_name: 'nginx'
			service_file: '/opt/nginx/homebrew.mxcl.nginx${suffix}'
			loaded_file: '/old/nginx${suffix}'
			running: true
			loaded: true
			launchctl: launchctl
			conflicts: [production_exec.BundleExecConflictingService{
				name: 'httpd'
				running: true
			}]
		},
		production_exec.BundleExecServiceInfo{
			entry_name: 'redis'
			formula_name: 'redis'
			service_file: '/opt/redis/homebrew.mxcl.redis${suffix}'
			launchctl: launchctl
			conflicts: [production_exec.BundleExecConflictingService{
				name: 'redis@6.2'
				running: true
				registered: true
			}]
		},
	]
}

// Ruby it `it "raises an error" do` at line 12.
pub fn ruby_exec_subcommand_spec_l12_d1_raises(args ...ruby.Value) ruby.Value {
	_ = args
	return exec_subcommand_spec_error(exec_subcommand_spec_context([]))
}

// Ruby let `let(:brewfile_contents) { "brew 'openssl'" }` at line 18.
pub fn ruby_exec_subcommand_spec_l18_d2_brewfile_contents(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value("brew 'openssl'")
}

// Ruby it `it "does not raise an error" do` at line 45.
pub fn ruby_exec_subcommand_spec_l45_d3_does(args ...ruby.Value) ruby.Value {
	_ = args
	plan := production_exec.build_bundle_exec_plan(exec_subcommand_spec_context([
		'bundle',
		'install',
	])) or { return ruby.bool_value(false) }
	return ruby.bool_value(plan.argv == ['bundle', 'install'] && plan.execute)
}

// Ruby it `it "does not raise an error when HOMEBREW_BUNDLE_EXEC_ALL_KEG_ONLY_DEPS is set" do` at line 49.
pub fn ruby_exec_subcommand_spec_l49_d4_does(args ...ruby.Value) ruby.Value {
	_ = args
	base := exec_subcommand_spec_context(['bundle', 'install'])
	context := production_exec.BundleExecContext{
		...base
		all_dependencies_keg_only: true
		dependencies: [production_exec.BundleExecDependency{
			name: 'openssl'
			opt_prefix: '/opt/homebrew/opt/openssl'
		}]
	}
	plan := production_exec.build_bundle_exec_plan(context) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(plan.environment['PKG_CONFIG_PATH'].contains('openssl/lib/pkgconfig'))
}

// Ruby it `it "uses the formula version from the environment variable" do` at line 54.
pub fn ruby_exec_subcommand_spec_l54_d5_uses(args ...ruby.Value) ruby.Value {
	_ = args
	base := exec_subcommand_spec_context(['bundle', 'install'])
	context := production_exec.BundleExecContext{
		...base
		environment: {
			'PATH':    '/opt/homebrew/opt/openssl/bin:/usr/bin:/bin'
			'MANPATH': '/opt/homebrew/opt/openssl/man'
		}
		dependencies: [production_exec.BundleExecDependency{
			name: 'openssl'
			opt_prefix: '/opt/homebrew/opt/openssl'
			version: '1.1.1'
		}]
	}
	plan := production_exec.build_bundle_exec_plan(context) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(plan.environment['PATH'].contains('/Cellar/openssl/1.1.1/bin')
		&& plan.environment['MANPATH'].contains('/Cellar/openssl/1.1.1/man'))
}

// Ruby it `it "is able to run without bundle arguments" do` at line 64.
pub fn ruby_exec_subcommand_spec_l64_d6_is(args ...ruby.Value) ruby.Value {
	_ = args
	result := production_exec.build_bundle_exec_plan(exec_subcommand_spec_context([
		'bundle',
		'install',
	])) or { return ruby.bool_value(false) }
	return ruby.bool_value(result.argv == ['bundle', 'install'])
}

// Ruby it `it "runs commands in the requested sandbox" do` at line 69.
pub fn ruby_exec_subcommand_spec_l69_d7_runs(args ...ruby.Value) ruby.Value {
	_ = args
	base := exec_subcommand_spec_context(['/usr/bin/true'])
	context := production_exec.BundleExecContext{
		...base
		sandbox_path: '.'
		deny_network: true
	}
	plan := production_exec.build_bundle_exec_plan(context) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(plan.sandbox_path or { '' } == '.' && plan.deny_network)
}

// Ruby it `it "raises an exception if called without a command" do` at line 76.
pub fn ruby_exec_subcommand_spec_l76_d8_raises(args ...ruby.Value) ruby.Value {
	_ = args
	return exec_subcommand_spec_error(exec_subcommand_spec_context([]))
}

// Ruby it `it "removes sensitive environment variables when requested" do` at line 90.
pub fn ruby_exec_subcommand_spec_l90_d9_removes(args ...ruby.Value) ruby.Value {
	_ = args
	base := exec_subcommand_spec_context(['/usr/bin/true'])
	context := production_exec.BundleExecContext{
		...base
		options: production_exec.BundleExecSubcommandOptions{ no_secrets: true }
		environment: {
			'PATH':         '/usr/bin:/bin'
			'SECRET_TOKEN': 'password'
		}
	}
	plan := production_exec.build_bundle_exec_plan(context) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value('SECRET_TOKEN' !in plan.environment)
}

// Ruby it `it "preserves non-sensitive environment variables when removing secrets" do` at line 99.
pub fn ruby_exec_subcommand_spec_l99_d10_preserves(args ...ruby.Value) ruby.Value {
	_ = args
	base := exec_subcommand_spec_context(['/usr/bin/true'])
	context := production_exec.BundleExecContext{
		...base
		options: production_exec.BundleExecSubcommandOptions{ no_secrets: true }
		environment: {
			'PATH':       '/usr/bin:/bin'
			'NORMAL_VAR': 'value'
		}
	}
	plan := production_exec.build_bundle_exec_plan(context) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(plan.environment['NORMAL_VAR'] == 'value')
}

// Ruby it `it "outputs the environment variables" do` at line 111.
pub fn ruby_exec_subcommand_spec_l111_d11_outputs(args ...ruby.Value) ruby.Value {
	_ = args
	base := exec_subcommand_spec_context(['env'])
	context := production_exec.BundleExecContext{
		...base
		subcommand: 'env'
		dependencies: [production_exec.BundleExecDependency{
			name: 'openssl'
			opt_prefix: '/opt/homebrew/opt/openssl'
		}]
	}
	plan := production_exec.build_bundle_exec_plan(context) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(!plan.execute && plan.env_output.contains('export PATH="')
		&& plan.env_output.contains(rune(36).str() + '{PATH:-}'))
}

// Ruby it `it "raises if called with a command that's not on the PATH" do` at line 119.
pub fn ruby_exec_subcommand_spec_l119_d12_raises(args ...ruby.Value) ruby.Value {
	_ = args
	base := exec_subcommand_spec_context(['bundle', 'install'])
	return exec_subcommand_spec_error(production_exec.BundleExecContext{
		...base
		available_commands: {}
	})
}

// Ruby it `it "prepends the path of the requested command to PATH before running" do` at line 126.
pub fn ruby_exec_subcommand_spec_l126_d13_prepends(args ...ruby.Value) ruby.Value {
	_ = args
	plan := production_exec.build_bundle_exec_plan(exec_subcommand_spec_context([
		'bundle',
		'install',
	])) or { return ruby.bool_value(false) }
	return ruby.bool_value(plan.environment['PATH'].starts_with('/usr/local/bin:'))
}

// Ruby let `let(:brewfile_contents) { "brew 'zlib'" }` at line 137.
pub fn ruby_exec_subcommand_spec_l137_d14_brewfile_contents(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value("brew 'zlib'")
}

// Ruby it `it "does not raise" do` at line 147.
pub fn ruby_exec_subcommand_spec_l147_d15_does(args ...ruby.Value) ruby.Value {
	command := if args.len > 0 { args[0].as_string() } else { './configure' }
	plan := production_exec.build_bundle_exec_plan(exec_subcommand_spec_context([
		command,
	])) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(plan.argv == [command])
}

// Ruby let `let(:rbenv_root) { Pathname.new("/tmp/.rbenv") }` at line 160.
pub fn ruby_exec_subcommand_spec_l160_d16_rbenv_root(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Pathname', '/tmp/.rbenv')
}

// Ruby let `let(:brewfile_contents) { "brew 'rbenv'" }` at line 161.
pub fn ruby_exec_subcommand_spec_l161_d17_brewfile_contents(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value("brew 'rbenv'")
}

// Ruby it `it "prepends the path of the rbenv shims to PATH before running" do` at line 171.
pub fn ruby_exec_subcommand_spec_l171_d18_prepends(args ...ruby.Value) ruby.Value {
	_ = args
	base := exec_subcommand_spec_context(['/usr/bin/true'])
	context := production_exec.BundleExecContext{
		...base
		environment: {
			'PATH':                '/usr/bin:/bin'
			'HOMEBREW_RBENV_ROOT': '/tmp/.rbenv'
		}
		dependencies: [production_exec.BundleExecDependency{
			name: 'rbenv'
			opt_prefix: '/opt/homebrew/opt/rbenv'
		}]
	}
	plan := production_exec.build_bundle_exec_plan(context) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(plan.environment['PATH'].starts_with('/tmp/.rbenv/shims:'))
}

// Ruby let `let(:brewfile_contents) { "brew 'nginx'\nbrew 'redis'" }` at line 183.
pub fn ruby_exec_subcommand_spec_l183_d19_brewfile_contents(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value("brew 'nginx'\nbrew 'redis'")
}

// Ruby let `let(:nginx_formula) do` at line 185.
pub fn ruby_exec_subcommand_spec_l185_d20_nginx_formula(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.structured_value('Formula', 'nginx', {
		'name':         'nginx'
		'prefix':       '/opt/nginx'
		'plist_name':   'homebrew.mxcl.nginx'
		'service_name': 'nginx'
		'conflicts':    'httpd'
	})
}

// Ruby let `let(:redis_formula) do` at line 202.
pub fn ruby_exec_subcommand_spec_l202_d21_redis_formula(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.structured_value('Formula', 'redis', {
		'name':                     'redis'
		'prefix':                   '/opt/redis'
		'plist_name':               'homebrew.mxcl.redis'
		'service_name':             'redis'
		'versioned_formulae_names': 'redis@6.2'
	})
}

// Ruby let `let(:services_info_pre) do` at line 219.
pub fn ruby_exec_subcommand_spec_l219_d22_services_info_pre(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.array_value([
		ruby.structured_value('ServiceInfo', 'nginx', {
			'name':    'nginx'
			'running': 'true'
			'loaded':  'true'
		}),
		ruby.structured_value('ServiceInfo', 'httpd', {
			'name':    'httpd'
			'running': 'true'
			'loaded':  'true'
		}),
		ruby.structured_value('ServiceInfo', 'redis', {
			'name':    'redis'
			'running': 'false'
			'loaded':  'false'
		}),
		ruby.structured_value('ServiceInfo', 'redis@6.2', {
			'name':       'redis@6.2'
			'running':    'true'
			'loaded':     'true'
			'registered': 'true'
		}),
	])
}

// Ruby let `let(:services_info_post) do` at line 228.
pub fn ruby_exec_subcommand_spec_l228_d23_services_info_post(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.array_value([
		ruby.structured_value('ServiceInfo', 'nginx', {
			'name':    'nginx'
			'running': 'true'
			'loaded':  'true'
		}),
		ruby.structured_value('ServiceInfo', 'httpd', {
			'name':    'httpd'
			'running': 'false'
			'loaded':  'false'
		}),
		ruby.structured_value('ServiceInfo', 'redis', {
			'name':    'redis'
			'running': 'true'
			'loaded':  'true'
		}),
		ruby.structured_value('ServiceInfo', 'redis@6.2', {
			'name':       'redis@6.2'
			'running':    'false'
			'loaded':     'false'
			'registered': 'true'
		}),
	])
}

// Ruby it `it "handles service lifecycle correctly" do` at line 255.
pub fn ruby_exec_subcommand_spec_l255_d24_handles(args ...ruby.Value) ruby.Value {
	launchctl := if args.len > 0 { args[0].bool_data } else { true }
	base := exec_subcommand_spec_context(['/usr/bin/true'])
	context := production_exec.BundleExecContext{
		...base
		options: production_exec.BundleExecSubcommandOptions{ services: true }
		services: exec_subcommand_spec_services(launchctl)
	}
	mut runtime := production_exec.BundleExecRuntime{}
	_ := production_exec.execute_bundle_exec(context, mut runtime, production_exec.recording_bundle_exec_command, production_exec.recording_bundle_exec_service) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(runtime.service_operations.map('${it.kind}:${it.name}') == [
		'stop:nginx',
		'stop:httpd',
		'run:nginx',
		'stop:redis@6.2',
		'run:redis',
		'stop:nginx',
		'stop:redis',
		'restart:redis@6.2',
	])
}

// Ruby let `let(:nginx_service_file) { nginx_formula.any_installed_prefix/"#{nginx_formula.plist_name}.plist" }` at line 311.
pub fn ruby_exec_subcommand_spec_l311_d25_nginx_service_file(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Pathname', '/opt/nginx/homebrew.mxcl.nginx.plist')
}

// Ruby let `let(:redis_service_file) { redis_formula.any_installed_prefix/"#{redis_formula.plist_name}.plist" }` at line 312.
pub fn ruby_exec_subcommand_spec_l312_d26_redis_service_file(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Pathname', '/opt/redis/homebrew.mxcl.redis.plist')
}

// Ruby let `let(:nginx_service_file) { nginx_formula.any_installed_prefix/"#{nginx_formula.service_name}.service" }` at line 322.
pub fn ruby_exec_subcommand_spec_l322_d27_nginx_service_file(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Pathname', '/opt/nginx/nginx.service')
}

// Ruby let `let(:redis_service_file) { redis_formula.any_installed_prefix/"#{redis_formula.service_name}.service" }` at line 323.
pub fn ruby_exec_subcommand_spec_l323_d28_redis_service_file(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Pathname', '/opt/redis/redis.service')
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle"
// 5: require "bundle/subcommand/exec"
// 6: require "bundle/brewfile"
// 7: require "bundle/brew_services"
// 8: require "sandbox"
// 9:
// 10: RSpec.describe Homebrew::Cmd::Bundle::ExecSubcommand do
// 11:   context "when a Brewfile is not found" do
// 12:     it "raises an error" do
// 13:       expect { described_class.run_external_command }.to raise_error(RuntimeError)
// 14:     end
// 15:   end
// 16:
// 17:   context "when a Brewfile is found", :no_api do
// 18:     let(:brewfile_contents) { "brew 'openssl'" }
// 19:
// 20:     before do
// 21:       allow_any_instance_of(Pathname).to receive(:read)
// 22:         .and_return(brewfile_contents)
// 23:
// 24:       # don't try to load gcc/glibc
// 25:       allow(DevelopmentTools).to receive_messages(needs_libc_formula?: false, needs_compiler_formula?: false)
// 26:
// 27:       stub_formula_loader formula("openssl") {
// 28:         T.bind(self, T.class_of(Formula))
// 29:         url "openssl-1.0"
// 30:       }
// 31:       stub_formula_loader formula("pkgconf") {
// 32:         T.bind(self, T.class_of(Formula))
// 33:         url "pkgconf-1.0"
// 34:       }
// 35:       ENV.extend(Superenv)
// 36:       allow(ENV).to receive(:setup_build_environment)
// 37:     end
// 38:
// 39:     context "with valid command setup" do
// 40:       before do
// 41:         allow(described_class).to receive(:exec).and_return(nil)
// 42:         Homebrew::Bundle.reset!
// 43:       end
// 44:
// 45:       it "does not raise an error" do
// 46:         expect { described_class.run_external_command("bundle", "install") }.not_to raise_error
// 47:       end
// 48:
// 49:       it "does not raise an error when HOMEBREW_BUNDLE_EXEC_ALL_KEG_ONLY_DEPS is set" do
// 50:         ENV["HOMEBREW_BUNDLE_EXEC_ALL_KEG_ONLY_DEPS"] = "1"
// 51:         expect { described_class.run_external_command("bundle", "install") }.not_to raise_error
// 52:       end
// 53:
// 54:       it "uses the formula version from the environment variable" do
// 55:         openssl_version = "1.1.1"
// 56:         ENV["PATH"] = "/opt/homebrew/opt/openssl/bin:/usr/bin:/bin"
// 57:         ENV["MANPATH"] = "/opt/homebrew/opt/openssl/man"
// 58:         ENV["HOMEBREW_BUNDLE_FORMULA_VERSION_OPENSSL"] = openssl_version
// 59:         allow(described_class).to receive(:which).and_return(Pathname("/usr/bin/bundle"))
// 60:         described_class.run_external_command("bundle", "install")
// 61:         expect(ENV.fetch("PATH")).to include("/Cellar/openssl/1.1.1/bin")
// 62:       end
// 63:
// 64:       it "is able to run without bundle arguments" do
// 65:         allow(described_class).to receive(:exec).with("bundle", "install").and_return(nil)
// 66:         expect { described_class.run_external_command("bundle", "install") }.not_to raise_error
// 67:       end
// 68:
// 69:       it "runs commands in the requested sandbox" do
// 70:         expect(Sandbox).to receive(:run_command)
// 71:           .with("/usr/bin/true", writable_path: ".", deny_network: true)
// 72:
// 73:         described_class.run_external_command("/usr/bin/true", sandbox_path: ".", deny_network: true)
// 74:       end
// 75:
// 76:       it "raises an exception if called without a command" do
// 77:         expect { described_class.run_external_command }.to raise_error(RuntimeError)
// 78:       end
// 79:
// 80:       describe "--no-secrets" do
// 81:         around do |example|
// 82:           original_env = ENV.to_hash
// 83:           begin
// 84:             example.run
// 85:           ensure
// 86:             ENV.replace(original_env)
// 87:           end
// 88:         end
// 89:
// 90:         it "removes sensitive environment variables when requested" do
// 91:           ENV["SECRET_TOKEN"] = "password"
// 92:
// 93:           described_class.run_external_command("/usr/bin/true", subcommand: "exec",
// 94:                                                                 no_secrets: true)
// 95:
// 96:           expect(ENV).not_to have_key("SECRET_TOKEN")
// 97:         end
// 98:
// 99:         it "preserves non-sensitive environment variables when removing secrets" do
// 100:           ENV["NORMAL_VAR"] = "value"
// 101:
// 102:           described_class.run_external_command("/usr/bin/true", subcommand: "exec",
// 103:                                                                 no_secrets: true)
// 104:
// 105:           expect(ENV.fetch("NORMAL_VAR")).to eq("value")
// 106:         end
// 107:       end
// 108:     end
// 109:
// 110:     context "with env command" do
// 111:       it "outputs the environment variables" do
// 112:         allow(OS).to receive(:linux?).and_return(true)
// 113:
// 114:         expect { described_class.run_external_command("env", subcommand: "env") }.to \
// 115:           output(/export PATH=".+:\${PATH:-}"/).to_stdout
// 116:       end
// 117:     end
// 118:
// 119:     it "raises if called with a command that's not on the PATH" do
// 120:       allow(described_class).to receive_messages(exec: nil, which: nil)
// 121:       expect do
// 122:         described_class.run_external_command("bundle", "install")
// 123:       end.to raise_error(RuntimeError)
// 124:     end
// 125:
// 126:     it "prepends the path of the requested command to PATH before running" do
// 127:       expect(described_class).to receive(:exec).with("bundle", "install").and_return(nil)
// 128:       expect(
// 129:         described_class,
// 130:       ).to receive(:which).twice.and_return(Pathname("/usr/local/bin/bundle"))
// 131:       allow(ENV).to receive(:prepend_path).with(any_args).and_call_original
// 132:       expect(ENV).to receive(:prepend_path).with("PATH", "/usr/local/bin").once.and_call_original
// 133:       described_class.run_external_command("bundle", "install")
// 134:     end
// 135:
// 136:     describe "when running a command which exists but is not on the PATH" do
// 137:       let(:brewfile_contents) { "brew 'zlib'" }
// 138:
// 139:       before do
// 140:         stub_formula_loader formula("zlib") {
// 141:           T.bind(self, T.class_of(Formula))
// 142:           url "zlib-1.0"
// 143:         }
// 144:       end
// 145:
// 146:       shared_examples "allows command execution" do |command|
// 147:         it "does not raise" do
// 148:           allow(described_class).to receive(:exec).with(command).and_return(nil)
// 149:           expect(described_class).not_to receive(:which)
// 150:           expect { described_class.run_external_command(command) }.not_to raise_error
// 151:         end
// 152:       end
// 153:
// 154:       it_behaves_like "allows command execution", "./configure"
// 155:       it_behaves_like "allows command execution", "bin/install"
// 156:       it_behaves_like "allows command execution", "/Users/admin/Downloads/command"
// 157:     end
// 158:
// 159:     describe "when the Brewfile contains rbenv" do
// 160:       let(:rbenv_root) { Pathname.new("/tmp/.rbenv") }
// 161:       let(:brewfile_contents) { "brew 'rbenv'" }
// 162:
// 163:       before do
// 164:         stub_formula_loader formula("rbenv") {
// 165:           T.bind(self, T.class_of(Formula))
// 166:           url "rbenv-1.0"
// 167:         }
// 168:         ENV["HOMEBREW_RBENV_ROOT"] = rbenv_root.to_s
// 169:       end
// 170:
// 171:       it "prepends the path of the rbenv shims to PATH before running" do
// 172:         allow(described_class).to receive(:exec).with("/usr/bin/true").and_return(0)
// 173:         allow(ENV).to receive(:fetch).with(any_args).and_call_original
// 174:         allow(ENV).to receive(:prepend_path).with(any_args).once.and_call_original
// 175:
// 176:         expect(ENV).to receive(:fetch).with("HOMEBREW_RBENV_ROOT", "#{Dir.home}/.rbenv").once.and_call_original
// 177:         expect(ENV).to receive(:prepend_path).with("PATH", rbenv_root/"shims").once.and_call_original
// 178:         described_class.run_external_command("/usr/bin/true")
// 179:       end
// 180:     end
// 181:
// 182:     describe "--services" do
// 183:       let(:brewfile_contents) { "brew 'nginx'\nbrew 'redis'" }
// 184:
// 185:       let(:nginx_formula) do
// 186:         nginx = formula("nginx") do
// 187:           T.bind(self, T.class_of(Formula))
// 188:           url "nginx-1.0"
// 189:         end
// 190:         allow(nginx).to receive_messages(
// 191:           any_version_installed?:   true,
// 192:           any_installed_prefix:     HOMEBREW_PREFIX/"opt/nginx",
// 193:           plist_name:               "homebrew.mxcl.nginx",
// 194:           service_name:             "nginx",
// 195:           versioned_formulae_names: [],
// 196:           conflicts:                [instance_double(Formula::FormulaConflict, name: "httpd")],
// 197:           keg_only?:                false,
// 198:         )
// 199:         nginx
// 200:       end
// 201:
// 202:       let(:redis_formula) do
// 203:         redis = formula("redis") do
// 204:           T.bind(self, T.class_of(Formula))
// 205:           url "redis-1.0"
// 206:         end
// 207:         allow(redis).to receive_messages(
// 208:           any_version_installed?:   true,
// 209:           any_installed_prefix:     HOMEBREW_PREFIX/"opt/redis",
// 210:           plist_name:               "homebrew.mxcl.redis",
// 211:           service_name:             "redis",
// 212:           versioned_formulae_names: ["redis@6.2"],
// 213:           conflicts:                [],
// 214:           keg_only?:                false,
// 215:         )
// 216:         redis
// 217:       end
// 218:
// 219:       let(:services_info_pre) do
// 220:         [
// 221:           { "name" => "nginx", "running" => true, "loaded" => true },
// 222:           { "name" => "httpd", "running" => true, "loaded" => true },
// 223:           { "name" => "redis", "running" => false, "loaded" => false },
// 224:           { "name" => "redis@6.2", "running" => true, "loaded" => true, "registered" => true },
// 225:         ]
// 226:       end
// 227:
// 228:       let(:services_info_post) do
// 229:         [
// 230:           { "name" => "nginx", "running" => true, "loaded" => true },
// 231:           { "name" => "httpd", "running" => false, "loaded" => false },
// 232:           { "name" => "redis", "running" => true, "loaded" => true },
// 233:           { "name" => "redis@6.2", "running" => false, "loaded" => false, "registered" => true },
// 234:         ]
// 235:       end
// 236:
// 237:       before do
// 238:         stub_formula_loader(nginx_formula, "nginx")
// 239:         stub_formula_loader(redis_formula, "redis")
// 240:
// 241:         pkgconf = formula("pkgconf") do
// 242:           T.bind(self, T.class_of(Formula))
// 243:           url "pkgconf-1.0"
// 244:         end
// 245:         stub_formula_loader(pkgconf)
// 246:         allow(pkgconf).to receive(:any_version_installed?).and_return(false)
// 247:
// 248:         allow_any_instance_of(Pathname).to receive(:file?).and_return(true)
// 249:         allow_any_instance_of(Pathname).to receive(:realpath) { |path| path }
// 250:
// 251:         allow(described_class).to receive(:exit!).and_return(nil)
// 252:       end
// 253:
// 254:       shared_examples "handles service lifecycle correctly" do
// 255:         it "handles service lifecycle correctly" do
// 256:           # The order of operations is important. This unweildly looking test is so it tests that.
// 257:
// 258:           # Return original service state
// 259:           expect(Utils).to receive(:safe_popen_read)
// 260:             .with(HOMEBREW_BREW_FILE, "services", "info", "--json", "nginx", "httpd", "redis", "redis@6.2")
// 261:             .and_return(services_info_pre.to_json)
// 262:
// 263:           # Stop original nginx
// 264:           expect(Homebrew::Bundle::Brew::Services).to receive(:stop)
// 265:             .with("nginx", keep: true).and_return(true).ordered
// 266:
// 267:           # Stop nginx conflicts
// 268:           expect(Homebrew::Bundle::Brew::Services).to receive(:stop)
// 269:             .with("httpd", keep: true).and_return(true).ordered
// 270:
// 271:           # Start new nginx
// 272:           expect(Homebrew::Bundle::Brew::Services).to receive(:run)
// 273:             .with("nginx", file: nginx_service_file).and_return(true).ordered
// 274:
// 275:           # No need to stop original redis (not started)
// 276:
// 277:           # Stop redis conflicts
// 278:           expect(Homebrew::Bundle::Brew::Services).to receive(:stop)
// 279:             .with("redis@6.2", keep: true).and_return(true).ordered
// 280:
// 281:           # Start new redis
// 282:           expect(Homebrew::Bundle::Brew::Services).to receive(:run)
// 283:             .with("redis", file: redis_service_file).and_return(true).ordered
// 284:
// 285:           # Run exec commands
// 286:           expect(Kernel).to receive(:system).with("/usr/bin/true").and_return(true).ordered
// 287:
// 288:           # Return new service state
// 289:           expect(Utils).to receive(:safe_popen_read)
// 290:             .with(HOMEBREW_BREW_FILE, "services", "info", "--json", "nginx", "httpd", "redis", "redis@6.2")
// 291:             .and_return(services_info_post.to_json)
// 292:
// 293:           # Stop new services
// 294:           expect(Homebrew::Bundle::Brew::Services).to receive(:stop)
// 295:             .with("nginx", keep: true).and_return(true).ordered
// 296:           expect(Homebrew::Bundle::Brew::Services).to receive(:stop)
// 297:             .with("redis", keep: true).and_return(true).ordered
// 298:
// 299:           # Restart registered services we stopped due to conflicts (skip httpd as not registered)
// 300:           expect(Homebrew::Bundle::Brew::Services).to receive(:run).with("redis@6.2").and_return(true).ordered
// 301:
// 302:           described_class.run_external_command("/usr/bin/true", services: true)
// 303:         end
// 304:       end
// 305:
// 306:       context "with launchctl" do
// 307:         before do
// 308:           allow(Homebrew::Services::System).to receive(:launchctl?).and_return(true)
// 309:         end
// 310:
// 311:         let(:nginx_service_file) { nginx_formula.any_installed_prefix/"#{nginx_formula.plist_name}.plist" }
// 312:         let(:redis_service_file) { redis_formula.any_installed_prefix/"#{redis_formula.plist_name}.plist" }
// 313:
// 314:         include_examples "handles service lifecycle correctly"
// 315:       end
// 316:
// 317:       context "with systemd" do
// 318:         before do
// 319:           allow(Homebrew::Services::System).to receive(:launchctl?).and_return(false)
// 320:         end
// 321:
// 322:         let(:nginx_service_file) { nginx_formula.any_installed_prefix/"#{nginx_formula.service_name}.service" }
// 323:         let(:redis_service_file) { redis_formula.any_installed_prefix/"#{redis_formula.service_name}.service" }
// 324:
// 325:         include_examples "handles service lifecycle correctly"
// 326:       end
// 327:     end
// 328:   end
// 329: end
