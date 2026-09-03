module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `test/dev-cmd/formula-analytics_spec.rb`.
// The original source is retained below until every stub has a typed V body.

fn formula_analytics_spec_options(runner FormulaAnalyticsBridgeRunner) FormulaAnalyticsOptions {
	return FormulaAnalyticsOptions{
		library_path: '/brew/Library'
		home_directory: '/home/brew'
		python_version: '3.13'
		environment: {
			'HOMEBREW_INFLUXDB_TOKEN': 'token'
		}
		now_unix: 1_751_328_000
		bridge_runner: runner
	}
}

fn formula_analytics_spec_ranked_bridge(request FormulaAnalyticsBridgeRequest) !FormulaAnalyticsBridgeResponse {
	if !request.query.contains('FROM "command_run"') {
		return error('unexpected analytics bucket')
	}
	return FormulaAnalyticsBridgeResponse{
		stdout: [
			'{"env_config":"HOMEBREW_BAT","env_config_state":"non_default","count":2}',
			'{"env_config":"HOMEBREW_BAT","env_config_state":"default","count":3}',
			'{"env_config":"HOMEBREW_BAT","env_config_state":"unset","count":5}',
			'{"env_config":"HOMEBREW_NO_AUTO_UPDATE","env_config_state":"non_default","count":1}',
			'{"env_config":"HOMEBREW_NO_AUTO_UPDATE","env_config_state":"unset","count":1}',
			'{"env_config":"HOMEBREW_MAKE_JOBS","env_config_state":"default","count":4}',
			'{"env_config":"HOMEBREW_TOTALLY_MADE_UP","env_config_state":"non_default","count":100}',
			'{"env_config":"HOMEBREW_BAT","env_config_state":"borked","count":50}',
		].join('\n') + '\n'
	}
}

fn formula_analytics_spec_echo_bridge(request FormulaAnalyticsBridgeRequest) !FormulaAnalyticsBridgeResponse {
	return FormulaAnalyticsBridgeResponse{
		stdout: request.request_json + '\n'
	}
}

fn formula_analytics_spec_unauthenticated_bridge(_request FormulaAnalyticsBridgeRequest) !FormulaAnalyticsBridgeResponse {
	return FormulaAnalyticsBridgeResponse{
		exit_code: 1
		stderr: 'pyarrow.flight.FlightUnauthenticatedError: message: unauthenticated\n'
	}
}

fn formula_analytics_spec_failing_bridge(_request FormulaAnalyticsBridgeRequest) !FormulaAnalyticsBridgeResponse {
	return FormulaAnalyticsBridgeResponse{
		exit_code: 1
		stderr: 'Traceback: boom\n'
	}
}

// Ruby it `it "preserves WSL in formatted Linux versions" do` at line 13.
pub fn ruby_formula_analytics_spec_l13_d1_preserves(args ...brew_runtime.Value) brew_runtime.Value {
	formatted := format_os_version_dimension('Ubuntu 24.04.3 LTS${formula_analytics_wsl_suffix}') or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(formatted == 'Ubuntu 24.04 LTS${formula_analytics_wsl_suffix}')
}

// Ruby it `it "ranks sampled environment configurations by non-default use" do` at line 21.
pub fn ruby_formula_analytics_spec_l21_d2_ranks(args ...brew_runtime.Value) brew_runtime.Value {
	base := formula_analytics_spec_options(formula_analytics_spec_ranked_bridge)
	options := FormulaAnalyticsOptions{
		...base
		homebrew_env_config: true
	}
	reports, _ := run_formula_analytics_query(options) or {
		return brew_runtime.bool_value(false)
	}
	if reports.len != 1 {
		return brew_runtime.bool_value(false)
	}
	report := reports[0]
	valid := report.category == 'homebrew_env_config' && report.total_items == 3
		&& report.total_count == 16 && report.items.len == 3
		&& report.query.contains('FROM "command_run"')
		&& report.query.contains('env_config_state IS NOT NULL')
		&& report.query.contains('GROUP BY "env_config","env_config_state"')
		&& report.items[0].dimension == 'HOMEBREW_NO_AUTO_UPDATE'
		&& report.items[0].formatted_count == '2' && report.items[0].percent == '50'
		&& report.items[1].dimension == 'HOMEBREW_BAT'
		&& report.items[1].formatted_count == '10' && report.items[1].percent == '20'
		&& report.items[2].dimension == 'HOMEBREW_MAKE_JOBS'
		&& report.items[2].formatted_count == '4' && report.items[2].percent == '0'
		&& report.items[2].default_value == 'The number of available CPU cores.'
	return brew_runtime.bool_value(valid)
}

// Ruby it `it "streams the JSON request to the bridge script and parses JSON lines" do` at line 74.
pub fn ruby_formula_analytics_spec_l74_d3_streams(args ...brew_runtime.Value) brew_runtime.Value {
	options := formula_analytics_spec_options(formula_analytics_spec_echo_bridge)
	records := each_formula_analytics_influx_record('SELECT 1', options) or {
		return brew_runtime.bool_value(false)
	}
	if records.len != 1 {
		return brew_runtime.bool_value(false)
	}
	record := records[0]
	return brew_runtime.bool_value(formula_analytics_field(record, 'host') == formula_analytics_influx_host
		&& formula_analytics_field(record, 'org') == formula_analytics_influx_org
		&& formula_analytics_field(record, 'database') == formula_analytics_influx_bucket
		&& formula_analytics_field(record, 'query') == 'SELECT 1')
}

// Ruby it `it "reports unauthenticated bridge errors as a token problem" do` at line 92.
pub fn ruby_formula_analytics_spec_l92_d4_reports(args ...brew_runtime.Value) brew_runtime.Value {
	options := formula_analytics_spec_options(formula_analytics_spec_unauthenticated_bridge)
	each_formula_analytics_influx_record('SELECT 1', options) or {
		return brew_runtime.bool_value(err.msg().contains('Could not authenticate with InfluxDB'))
	}
	return brew_runtime.bool_value(false)
}

// Ruby it `it "reports other bridge failures with their standard error output" do` at line 109.
pub fn ruby_formula_analytics_spec_l109_d5_reports(args ...brew_runtime.Value) brew_runtime.Value {
	options := formula_analytics_spec_options(formula_analytics_spec_failing_bridge)
	each_formula_analytics_influx_record('SELECT 1', options) or {
		return brew_runtime.bool_value(err.msg().contains('InfluxDB query failed:\nTraceback: boom'))
	}
	return brew_runtime.bool_value(false)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "dev-cmd/formula-analytics"
// 6: require "json"
// 7: require "utils/analytics"
// 8:
// 9: RSpec.describe Homebrew::DevCmd::FormulaAnalytics do
// 10:   it_behaves_like "parseable arguments"
// 11:
// 12:   describe "#format_os_version_dimension" do
// 13:     it "preserves WSL in formatted Linux versions" do
// 14:       expect(described_class.new([]).format_os_version_dimension(
// 15:                "Ubuntu 24.04.3 LTS#{Utils::Analytics::WSL_SUFFIX}",
// 16:              )).to eq("Ubuntu 24.04 LTS#{Utils::Analytics::WSL_SUFFIX}")
// 17:     end
// 18:   end
// 19:
// 20:   describe "#influx_analytics" do
// 21:     it "ranks sampled environment configurations by non-default use" do
// 22:       ENV.delete("HOMEBREW_NO_ANALYTICS")
// 23:       ENV["HOMEBREW_INFLUXDB_TOKEN"] = "token"
// 24:       records = [
// 25:         { "env_config" => "HOMEBREW_BAT", "env_config_state" => "non_default", "count" => 2 },
// 26:         { "env_config" => "HOMEBREW_BAT", "env_config_state" => "default", "count" => 3 },
// 27:         { "env_config" => "HOMEBREW_BAT", "env_config_state" => "unset", "count" => 5 },
// 28:         { "env_config" => "HOMEBREW_NO_AUTO_UPDATE", "env_config_state" => "non_default", "count" => 1 },
// 29:         { "env_config" => "HOMEBREW_NO_AUTO_UPDATE", "env_config_state" => "unset", "count" => 1 },
// 30:         { "env_config" => "HOMEBREW_MAKE_JOBS", "env_config_state" => "default", "count" => 4 },
// 31:         { "env_config" => "HOMEBREW_TOTALLY_MADE_UP", "env_config_state" => "non_default", "count" => 100 },
// 32:         { "env_config" => "HOMEBREW_BAT", "env_config_state" => "borked", "count" => 50 },
// 33:       ]
// 34:       queries = []
// 35:       command = described_class.new(["--homebrew-env-config", "--json"])
// 36:       allow(command).to receive(:each_influx_record) do |query, &block|
// 37:         queries << query
// 38:         records.each(&block)
// 39:       end
// 40:       expected = {
// 41:         category:    :homebrew_env_config,
// 42:         total_items: 3,
// 43:         start_date:  Date.today - 30,
// 44:         end_date:    Date.today,
// 45:         total_count: 16,
// 46:         items:       [
// 47:           {
// 48:             number: 1, env_config: "HOMEBREW_NO_AUTO_UPDATE", count: "2", non_default_count: "1",
// 49:             set_default_count: "0", unset_count: "1", percent: "50", default_value: nil
// 50:           },
// 51:           {
// 52:             number: 2, env_config: "HOMEBREW_BAT", count: "10", non_default_count: "2",
// 53:             set_default_count: "3", unset_count: "5", percent: "20", default_value: nil
// 54:           },
// 55:           {
// 56:             number: 3, env_config: "HOMEBREW_MAKE_JOBS", count: "4", non_default_count: "0",
// 57:             set_default_count: "4", unset_count: "0", percent: "0",
// 58:             default_value: "The number of available CPU cores."
// 59:           },
// 60:         ],
// 61:       }
// 62:
// 63:       expect { command.influx_analytics(command.args) }
// 64:         .to output("#{JSON.pretty_generate(expected)}\n").to_stdout
// 65:       expect(queries).to contain_exactly(
// 66:         match(/FROM "command_run".*env_config_state IS NOT NULL GROUP BY/).and(
// 67:           include('GROUP BY "env_config","env_config_state"'),
// 68:         ),
// 69:       )
// 70:     end
// 71:   end
// 72:
// 73:   describe "#each_influx_record" do
// 74:     it "streams the JSON request to the bridge script and parses JSON lines" do
// 75:       command = described_class.new([])
// 76:       bridge = mktmpdir/"fake-python"
// 77:       bridge.write "#!/bin/sh\ncat\n"
// 78:       bridge.chmod 0755
// 79:       allow(command).to receive(:venv_python).and_return(bridge)
// 80:       records = []
// 81:
// 82:       command.each_influx_record("SELECT 1") { |record| records << record }
// 83:
// 84:       expect(records).to eq [{
// 85:         "host"     => "eu-central-1-1.aws.cloud2.influxdata.com",
// 86:         "org"      => Utils::Analytics::INFLUX_ORG,
// 87:         "database" => Utils::Analytics::INFLUX_BUCKET,
// 88:         "query"    => "SELECT 1",
// 89:       }]
// 90:     end
// 91:
// 92:     it "reports unauthenticated bridge errors as a token problem" do
// 93:       command = described_class.new([])
// 94:       bridge = mktmpdir/"fake-python"
// 95:       bridge.write <<~SH
// 96:         #!/bin/sh
// 97:         cat >/dev/null
// 98:         echo "pyarrow.flight.FlightUnauthenticatedError: message: unauthenticated" >&2
// 99:         exit 1
// 100:       SH
// 101:       bridge.chmod 0755
// 102:       allow(command).to receive(:venv_python).and_return(bridge)
// 103:
// 104:       expect { command.each_influx_record("SELECT 1") { nil } }
// 105:         .to raise_error(SystemExit)
// 106:         .and output(/Could not authenticate with InfluxDB/).to_stderr
// 107:     end
// 108:
// 109:     it "reports other bridge failures with their standard error output" do
// 110:       command = described_class.new([])
// 111:       bridge = mktmpdir/"fake-python"
// 112:       bridge.write <<~SH
// 113:         #!/bin/sh
// 114:         cat >/dev/null
// 115:         echo "Traceback: boom" >&2
// 116:         exit 1
// 117:       SH
// 118:       bridge.chmod 0755
// 119:       allow(command).to receive(:venv_python).and_return(bridge)
// 120:
// 121:       expect { command.each_influx_record("SELECT 1") { nil } }
// 122:         .to raise_error(SystemExit)
// 123:         .and output(/InfluxDB query failed:\nTraceback: boom/).to_stderr
// 124:     end
// 125:   end
// 126: end
