#!/usr/bin/env bash
set -euo pipefail

SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source ${SUPPORT_FIRECLOUD_DIR}/sh/common.inc.sh

cat <<EOF
#!/usr/bin/env bash
# shellcheck disable=SC2034
set -euo pipefail

SUPPORT_FIRECLOUD_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")/.." && pwd)"
source \${SUPPORT_FIRECLOUD_DIR}/sh/common.inc.sh

#- ci-printvars 1.0
## Usage: ci-printvars
## Print CI_* environment variables in a platform-agnostic way.
##
##   -h, --help     Display this help and exit
##   -v, --version  Output version information and exit

EOF

SF_CI_ENV_INC_SH_PLATFORMS=
for SF_CI_ENV_INC_SH in "${SUPPORT_FIRECLOUD_DIR}"/ci/env/*; do
    SF_CI_ENV_INC_SH_PLATFORMS="${SF_CI_ENV_INC_SH_PLATFORMS} $(basename ${SF_CI_ENV_INC_SH} .inc.sh)"
    cat ${SF_CI_ENV_INC_SH}
done

cat <<EOF
for SF_CI_ENV_INC_SH_PLATFORM in ${SF_CI_ENV_INC_SH_PLATFORMS}; do
    eval "sf_ci_env_\${SF_CI_ENV_INC_SH_PLATFORM}"
done

if [[ -n "\${CI_PLATFORM:-}" ]]; then
    eval "sf_ci_printvars_\${CI_PLATFORM}"
else
    compgen -A variable | sort -u | grep -e "^CI\$" -e "^CI_"
fi

if [[ -n "\${CI_PLATFORM:-}" ]]; then
    echo "Unknown:"
    eval "sf_ci_printvars_\${CI_PLATFORM}" | sed "s/=.*//g" | grep -Fvxf <("sf_ci_known_env_\${CI_PLATFORM}")
fi
EOF
