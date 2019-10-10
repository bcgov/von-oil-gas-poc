export PROJECT_NAMESPACE=${PROJECT_NAMESPACE:-devex-von-permitify}
export GIT_URI=${GIT_URI:-"https://github.com/bcgov/von-oil-gas-poc.git"}
export GIT_REF=${GIT_REF:-"master"}


# The project components
# - They are all contained under the main OpenShift folder.
export components="."

# The templates that should not have their GIT referances(uri and ref) over-ridden
# Templates NOT in this list will have they GIT referances over-ridden with the values of GIT_URI and GIT_REF
export -a skip_git_overrides="bc-oil-gas-agent-build.json"

# The builds to be triggered after buildconfigs created (not auto-triggered)
export builds=""

# The images to be tagged after build
export images="bc-oil-and-gas-agent bc-oil-and-gas-controller"

# The routes for the project
export routes="bc-oil-and-gas"
