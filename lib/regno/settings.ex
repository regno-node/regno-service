defmodule Regno.Setting do
  defstruct [:friendly_name, :env_var, :options]
end

defmodule Regno.SettingsMap do
  @regno_conf_list [
    %Regno.Setting{friendly_name: "Enable Tor", env_var: "REGNO_TOR_ENABLE", options: ["yes", "no"]},
    %Regno.Setting{friendly_name: "Enable Monerod", env_var: "REGNO_MONEROD_ENABLE", options: ["yes", "no"]},
    %Regno.Setting{friendly_name: "Enable P2Pool", env_var: "REGNO_P2POOL_ENABLE", options: ["yes", "no"]},
    %Regno.Setting{friendly_name: "Enable Block Explorer", env_var: "REGNO_EXPLORER_ENABLE", options: ["yes", "no"]},
    %Regno.Setting{friendly_name: "Enable Monerod blockchain pruning", env_var: "REGNO_MONEROD_PRUNE", options: ["yes", "no"]},
    %Regno.Setting{friendly_name: "Monero network", env_var: "REGNO_MONEROD_NETWORK", options: ["mainnet", "stagenet"]},
  ]

end

defmodule Regno.SettingsManager do

end
