#!/usr/bin/env bats
# ============================================================================
# Shell Script Tests for verify_modules.sh
# Tests module verification and validation functionality
# ============================================================================

setup() {
    export TEST_DIR="$(mktemp -d)"
}

teardown() {
    if [[ -n "$TEST_DIR" && -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
    fi
}

# ============================================================================
# BASIC TESTS
# ============================================================================

@test "verify_modules.sh exists and is executable" {
    [[ -f "./verify_modules.sh" ]]
    [[ -x "./verify_modules.sh" ]]
}

@test "verify_modules.sh has bash shebang" {
    head -n 1 ./verify_modules.sh | grep -q "#!/bin/bash"
}

@test "verify_modules.sh uses error handling" {
    grep -q "set -e" ./verify_modules.sh
}

# ============================================================================
# STRUCTURE TESTS
# ============================================================================

@test "verify_modules.sh has header documentation" {
    head -n 10 ./verify_modules.sh | grep -qi "module\|verification"
}

@test "verify_modules.sh defines color variables" {
    grep -q "RED=" ./verify_modules.sh
    grep -q "GREEN=" ./verify_modules.sh
    grep -q "NC=" ./verify_modules.sh
}

# ============================================================================
# FUNCTIONALITY TESTS
# ============================================================================

@test "verify_modules.sh checks for modules" {
    grep -i "module" ./verify_modules.sh > /dev/null
}

@test "verify_modules.sh has verification logic" {
    grep -E "if.*then|test|\[\[" ./verify_modules.sh > /dev/null
}

# ============================================================================
# SYNTAX TESTS
# ============================================================================

@test "verify_modules.sh has valid bash syntax" {
    if command -v bash &> /dev/null; then
        bash -n ./verify_modules.sh
    else
        skip "bash not available"
    fi
}
