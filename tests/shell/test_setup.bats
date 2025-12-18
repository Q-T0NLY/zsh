#!/usr/bin/env bats
# ============================================================================
# Shell Script Tests for setup.sh
# Tests setup functionality, system detection, and configuration
# ============================================================================

# Setup and teardown
setup() {
    export TEST_DIR="$(mktemp -d)"
    export ORIG_HOME="$HOME"
    export HOME="$TEST_DIR"
}

teardown() {
    if [[ -n "$TEST_DIR" && -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
    fi
    export HOME="$ORIG_HOME"
}

# ============================================================================
# BASIC TESTS
# ============================================================================

@test "setup.sh exists and is executable" {
    [[ -f "./setup.sh" ]]
    [[ -x "./setup.sh" ]]
}

@test "setup.sh has correct shebang" {
    head -n 1 ./setup.sh | grep -q "#!/bin/bash"
}

@test "setup.sh uses strict mode" {
    grep -q "set -euo pipefail" ./setup.sh
}

# ============================================================================
# CONFIGURATION TESTS
# ============================================================================

@test "setup.sh defines SCRIPT_DIR" {
    grep -q "readonly SCRIPT_DIR" ./setup.sh
}

@test "setup.sh defines SETUP_VERSION" {
    grep -q "SETUP_VERSION" ./setup.sh
}

@test "setup.sh defines PROJECT_NAME" {
    grep -q "PROJECT_NAME" ./setup.sh
}

@test "setup.sh defines color constants" {
    grep -q "C_RED" ./setup.sh
    grep -q "C_GREEN" ./setup.sh
    grep -q "C_CYAN" ./setup.sh
}

# ============================================================================
# FUNCTION TESTS
# ============================================================================

@test "setup.sh has utility functions" {
    # Check for common utility patterns
    grep -E "^[a-z_]+\(\)" ./setup.sh > /dev/null || \
    grep -E "function [a-z_]+" ./setup.sh > /dev/null
}

# ============================================================================
# VALIDATION TESTS
# ============================================================================

@test "setup.sh validates environment" {
    # Should have some form of validation
    grep -i "check\|validate\|verify" ./setup.sh > /dev/null
}

@test "setup.sh has proper structure" {
    # Should have sections or organized code
    grep -E "^#.*═" ./setup.sh > /dev/null
}

# ============================================================================
# SECURITY TESTS
# ============================================================================

@test "setup.sh does not contain hardcoded credentials" {
    ! grep -iE "password=|api_key=|token=" ./setup.sh
}

@test "setup.sh uses readonly for constants" {
    grep -q "readonly" ./setup.sh
}

# ============================================================================
# SYNTAX TESTS
# ============================================================================

@test "setup.sh syntax is valid" {
    if command -v bash &> /dev/null; then
        bash -n ./setup.sh
    else
        skip "bash not available for syntax check"
    fi
}

@test "setup.sh has no trailing whitespace on shebang" {
    head -n 1 ./setup.sh | grep -q "^#!/bin/bash$"
}
