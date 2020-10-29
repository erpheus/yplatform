#!/usr/bin/env bash
set -euo pipefail

SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source ${SUPPORT_FIRECLOUD_DIR}/sh/common.inc.sh

source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-util.inc.sh

function bootstrap_has_brew() {
    if which brew >/dev/null 2>&1; then
        # using tail or else broken pipe. see https://github.com/Homebrew/homebrew-cask/issues/36218
        # exe_and_grep_q "brew --version | head -1" "^Homebrew 2." || return 1
        exe_and_grep_q "brew --version | tail -n+1 | head -1" "^Homebrew 2\." || return 1
    else
        echo_info "brew: Executable brew not found."
        return 1
    fi
}

function bootstrap_brew() {
    local RAW_GUC_URL="https://raw.githubusercontent.com"
    [[ "${CI}" != "true" ]] || {
        if which brew >/dev/null 2>&1; then
            if [[ "${SF_SKIP_COMMON_BOOTSTRAP:-}" = "true" ]]; then
                echo_skip "brew: Uninstalling homebrew..."
            else
                echo_do "brew: Uninstalling homebrew..."
                </dev/null /bin/bash -c "$(curl -fqsS -L ${RAW_GUC_URL}/Homebrew/install/master/uninstall.sh)"
                echo_done
                hash -r
            fi
        fi
    }

    local HAS_BREW_2=true
    bootstrap_has_brew || HAS_BREW_2=false

    case ${HAS_BREW_2}-$(uname -s) in
        false-Darwin)
            echo_do "brew: Installing homebrew..."
            </dev/null /bin/bash -c "$(curl -fqsS -L ${RAW_GUC_URL}/Homebrew/install/master/install.sh)"
            echo_done
            ;;
        true-Darwin)
            brew_config
            if [[ "${SF_SKIP_COMMON_BOOTSTRAP:-}" = "true" ]]; then
                echo_info "brew: SF_SKIP_COMMON_BOOTSTRAP=${SF_SKIP_COMMON_BOOTSTRAP}"
                echo_skip "brew: Updating homebrew..."
            else
                echo_do "brew: Updating homebrew..."

                [[ ${GITHUB_ACTIONS:=} != "true" ]] || {
                    # see https://github.com/actions/virtual-environments/issues/1811#issuecomment-713862592
                    for BREW_TAP in $(brew tap | grep "^local/"); do
                        brew untap "${BREW_TAP}"
                    done
                }

                brew update >/dev/null
                echo_done
            fi
            ;;
        false-Linux)
            echo_do "brew: Installing linuxbrew..."
            if [[ "${SUDO}" = "" ]] || [[ "${SUDO}" = "sf_nosudo" ]]; then
                HOMEBREW_PREFIX=${HOME}/.linuxbrew
                echo_do "brew: Installing without sudo into ${HOMEBREW_PREFIX}..."
                mkdir -p ${HOMEBREW_PREFIX}
                curl -fqsS -L https://github.com/Homebrew/brew/tarball/master | \
                    tar xz --strip 1 -C ${HOMEBREW_PREFIX}
                echo_done
            else
                </dev/null /bin/bash -c "$(curl -fqsS -L ${RAW_GUC_URL}/Homebrew/install/master/install.sh)"
            fi
            echo_done
            ;;
        true-Linux)
            brew_config
            if [[ "${SF_SKIP_COMMON_BOOTSTRAP:-}" = "true" ]]; then
                echo_info "brew: SF_SKIP_COMMON_BOOTSTRAP=${SF_SKIP_COMMON_BOOTSTRAP}"
                echo_skip "brew: Updating homebrew..."
            else
                echo_do "brew: Updating linuxbrew..."
                brew update >/dev/null
                echo_done
            fi
            ;;
        *)
            echo_err "brew: $(uname -s) is an unsupported OS."
            return 1
            ;;
    esac
}

function bootstrap_brew_ci_cache() {
    local HOMEBREW_PREFIX=$(brew --prefix)
    local HOMEBREW_PREFIX_FULL=$(cd ${HOMEBREW_PREFIX} 2>/dev/null && pwd || true)
    case $(uname -s) in
        Darwin)
            local CI_CACHE_HOMEBREW_PREFIX=${HOME}/.homebrew
            ;;
        Linux)
            local CI_CACHE_HOMEBREW_PREFIX=${HOME}/.linuxbrew
            ;;
        *)
            echo_err "brew: $(uname -s) is an unsupported OS."
            return 1
            ;;
    esac
    local CI_CACHE_HOMEBREW_PREFIX_FULL=$(cd ${CI_CACHE_HOMEBREW_PREFIX} 2>/dev/null && pwd || true)

    [[ "${HOMEBREW_PREFIX_FULL}" != "${CI_CACHE_HOMEBREW_PREFIX_FULL}" ]] || return 0

    echo_do "brew: Restoring cache..."
    if [[ -d "${CI_CACHE_HOMEBREW_PREFIX}/Homebrew" ]]; then
        echo_do "brew: Restoring ${HOMEBREW_PREFIX}/Homebrew..."
        RSYNC_CMD="rsync -a --delete ${CI_CACHE_HOMEBREW_PREFIX}/Homebrew/ ${HOMEBREW_PREFIX}/Homebrew/"
        ${RSYNC_CMD} || {
            exe ls -la ${CI_CACHE_HOMEBREW_PREFIX}/Homebrew || true
            exe ls -la ${HOMEBREW_PREFIX}/Homebrew || true
            ${RSYNC_CMD} --verbose
        }
        unset RSYNC_CMD
        echo_done
    fi
    echo_done
}

bootstrap_brew
source ${SUPPORT_FIRECLOUD_DIR}/sh/exe-env.inc.sh

[[ "${CI}" != "true" ]] || {
    bootstrap_brew_ci_cache
    brew_config
    [[ "${SF_SKIP_COMMON_BOOTSTRAP:-}" = "true" ]] || brew_update
    source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-install-ci.inc.sh
}

source ${SUPPORT_FIRECLOUD_DIR}/sh/common.inc.sh
