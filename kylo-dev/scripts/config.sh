

# specify which remote git repository with kylo you want to clone
# eg: CLONE_URL=https://github.com/<whoami>/kylo.git
CLONE_URL=

# specify which branch you want to checkout
# eg: BRANCH=feature/new-awesome-feature
BRANCH=

# specify which modules to build/ignore
# modules are separated by ","
# if overridden, you might want to add ",!install" to skip rpms, tarballs, etc...
# eg: MODULES=( ui services nifi)
MODULES=( ui )

# specify which local kylo directory you want to use (instead of a repository)
# eg: KYLO_DIR=/<whoami>/repositories/kylo
KYLO_DIR=/Users/cs186081/repositories/kylo