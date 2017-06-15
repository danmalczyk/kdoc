#!/bin/bash

# Specify which remote git repository with kylo you want to clone
# Default will not clone, but look existing folder containing KYLO_DIR (see below)
# eg: CLONE_URL=https://github.com/<whoami>/kylo.git
CLONE_URL=https://github.com/Teradata/kylo.git

# Specify which branch you want to checkout, if cloning from a repository
# Default is the default branch from the repository
# eg: BRANCH=feature/new-awesome-feature
BRANCH=release/0.8.1

# Specify which maven modules to copy Everything else is ignored
# only supported: ui, services, integrations
# eg: MODULES=( ui services )
MODULES=( ui services integrations )

# Specify which kylo directory you want to use (instead of a repository/ override default repository path)
# Path must be absolute
# eg: KYLO_DIR=/<whoami>/repositories/kylo
KYLO_DIR=~/repositories/kylo