.  $(find . -name overrides.inc)
# ================================================================================================================
# Special deployment parameters needed for injecting a user supplied settings into the deployment configuration
# ----------------------------------------------------------------------------------------------------------------

if createOperation; then
  # Ask the user to supply the sensitive parameters ...
  readParameter "ADMIN_API_KEY - Please provide the key for the agent's Admin API.  If left blank, a 32 character long base64 encoded value will be randomly generated using openssl:" ADMIN_API_KEY $(generateKey 32) "false"
  readParameter "WALLET_KEY - Please provide the wallet encryption key for the environment.  If left blank, a 48 character long base64 encoded value will be randomly generated using openssl:" WALLET_KEY $(generateKey) "false"
  readParameter "AGENT_WALLET_SEED - Please provide the wallet seed for the agent environment.  If left blank, a seed will be randomly generated using openssl:" AGENT_WALLET_SEED $(generateSeed) "false"
  readParameter "WALLET_DID - Please provide the indy wallet did for the environment.  The default is an empty string:" WALLET_DID "" "false"
else
  # Secrets are removed from the configurations during update operations ...
  printStatusMsg "Update operation detected ...\nSkipping the prompts for ADMIN_API_KEY, WALLET_KEY, AGENT_WALLET_SEED, and WALLET_DID secrets ... \n"
  writeParameter "ADMIN_API_KEY" "prompt_skipped" "false"
  writeParameter "WALLET_KEY" "prompt_skipped" "false"
  writeParameter "AGENT_WALLET_SEED" "prompt_skipped" "false"
  writeParameter "WALLET_DID" "prompt_skipped" "false"
fi

SPECIALDEPLOYPARMS="--param-file=${_overrideParamFile}"
echo ${SPECIALDEPLOYPARMS}