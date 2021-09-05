#!/usr/bin/env bash
# shellcheck disable=SC2034
true

function sf_ci_env_cirrus() {
    [[ "${CIRRUS_CI:-}" = "true" ]] || return 0

    [[ "${CIRRUS_REPO_CLONE_HOST:-}" = "github.com" ]]

    export CI=true
    SF_CI_NAME="Cirrus CI"
    SF_CI_PLATFORM=cirrus
    SF_CI_SERVER_HOST=cirrus-ci.com
    SF_CI_REPO_SLUG=${CIRRUS_REPO_FULL_NAME:-}
    SF_CI_ROOT=${CIRRUS_WORKING_DIR:-}

    SF_CI_IS_CRON=
    [[ -z "${CIRRUS_CRON:-}" ]] || SF_CI_IS_CRON=true
    SF_CI_IS_PR=
    [[ -z "${CIRRUS_PR:-}" ]] || SF_CI_IS_PR=true


    SF_CI_JOB_ID=${CIRRUS_TASK_ID:-}
    SF_CI_PIPELINE_ID=${CIRRUS_BUILD_ID:-}
    SF_CI_JOB_URL=https://cirrus-ci.com/task/${SF_CI_JOB_ID}
    SF_CI_PIPELINE_URL=https://cirrus-ci.com/build/${SF_CI_PIPELINE_ID}

    SF_CI_PR_NUMBER=
    SF_CI_PR_URL=
    SF_CI_PR_REPO_SLUG=
    SF_CI_PR_GIT_HASH=
    SF_CI_PR_GIT_BRANCH=
    [[ "${SF_CI_IS_PR}" != "true" ]] || {
        SF_CI_PR_NUMBER=${CIRRUS_PR:-}
        SF_CI_PR_URL=https://github.com/${SF_CI_REPO_SLUG}/pull/${SF_CI_PR_NUMBER}
        SF_CI_PR_REPO_SLUG= # TODO
        SF_CI_PR_GIT_HASH= # TODO
        SF_CI_PR_GIT_BRANCH=${CIRRUS_BRANCH:-}
    }

    SF_CI_GIT_HASH=${CIRRUS_CHANGE_IN_REPO:-}
    SF_CI_GIT_BRANCH=${CIRRUS_BRANCH:-}
    [[ "${SF_CI_IS_PR}" != "true" ]] || SF_CI_GIT_BRANCH=${CIRRUS_BASE_BRANCH:-}
    SF_CI_GIT_TAG=${CIRRUS_TAG:-}

    SF_CI_DEBUG_MODE=${SF_CI_DEBUG_MODE:-}
}

function sf_ci_printvars_cirrus() {
    printenv_all | sort -u | grep \
        -e "^CI[=_]" \
        -e "^CIRRUS[=_]" \
        -e "^CONTINUOUS_INTEGRATION$" \
        -e "^GITHUB_CHECK_SUITE_ID$"
}

function sf_ci_known_env_cirrus() {
    # see https://cirrus-ci.org/guide/writing-tasks/#environment-variables
    cat <<EOF
CI
CIRRUS_CI
CI_NODE_INDEX
CI_NODE_TOTAL
CONTINUOUS_INTEGRATION
CIRRUS_API_CREATED
CIRRUS_BASE_BRANCH
CIRRUS_BASE_SHA
CIRRUS_BRANCH
CIRRUS_BUILD_ID
CIRRUS_CHANGE_IN_REPO
CIRRUS_CHANGE_MESSAGE
CIRRUS_CHANGE_TITLE
CIRRUS_CRON
CIRRUS_DEFAULT_BRANCH
CIRRUS_LAST_GREEN_BUILD_ID
CIRRUS_LAST_GREEN_CHANGE
CIRRUS_PR
CIRRUS_PR_DRAFT
CIRRUS_TAG
CIRRUS_OS
CIRRUS_TASK_NAME
CIRRUS_TASK_ID
CIRRUS_RELEASE
CIRRUS_REPO_CLONE_TOKEN
CIRRUS_REPO_NAME
CIRRUS_REPO_OWNER
CIRRUS_REPO_FULL_NAME
CIRRUS_REPO_CLONE_URL
CIRRUS_USER_COLLABORATOR
CIRRUS_USER_PERMISSION
CIRRUS_HTTP_CACHE_HOST
GITHUB_CHECK_SUITE_ID
CIRRUS_ENV
CIRRUS_CLONE_DEPTH
CIRRUS_CLONE_SUBMODULES
CIRRUS_LOG_TIMESTAMP
CIRRUS_SHELL
CIRRUS_VOLUME
CIRRUS_WORKING_DIR
EOF
    # undocumented but observed
    cat <<EOF
CIRRUS_ARCH
CIRRUS_COMMIT_MESSAGE
CIRRUS_CPU
CIRRUS_REPO_CLONE_HOST
CIRRUS_REPO_ID
EOF
}
