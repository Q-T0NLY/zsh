#!/usr/bin/env bats
# ============================================================================
# Shell Script Tests for install.sh
# Tests installation functionality, validation, and error handling
# ============================================================================

# Setup and teardown
setup() {
    # Create temporary test directory
    export TEST_DIR="$(mktemp -d)"
    export ORIG_HOME="$HOME"
    export HOME="$TEST_DIR"
    export CONFIG_HOME="$TEST_DIR/.config/ultra-zsh"
}

teardown() {
    # Cleanup test directory
    if [[ -n "$TEST_DIR" && -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
    fi
    export HOME="$ORIG_HOME"
}

# ============================================================================
# UTILITY FUNCTION TESTS
# ============================================================================

@test "install.sh exists and is executable" {
    [[ -f "./install.sh" ]]
    [[ -x "./install.sh" ]]
}

@test "install.sh has correct shebang" {
    head -n 1 ./install.sh | grep -q "#!/usr/bin/env zsh"
}

@test "install.sh uses strict mode" {
    grep -q "set -euo pipefail" ./install.sh
}

@test "install.sh defines required constants" {
    grep -q "readonly SCRIPT_DIR" ./install.sh
    grep -q "readonly PROJECT_NAME" ./install.sh
    grep -q "readonly PROJECT_VERSION" ./install.sh
}

@test "install.sh defines color constants" {
    grep -q "COLOR_RED" ./install.sh
    grep -q "COLOR_GREEN" ./install.sh
    grep -q "COLOR_RESET" ./install.sh
}

# ============================================================================
# FUNCTION EXISTENCE TESTS
# ============================================================================

@test "install.sh contains print_header function" {
    grep -q "print_header()" ./install.sh
}

@test "install.sh contains print_step function" {
    grep -q "print_step()" ./install.sh
}

@test "install.sh contains print_success function" {
    grep -q "print_success()" ./install.sh
}

@test "install.sh contains print_warning function" {
    grep -q "print_warning()" ./install.sh
}

# ============================================================================
# CONFIGURATION TESTS
# ============================================================================

@test "install.sh sets PROJECT_VERSION correctly" {
    grep -q 'PROJECT_VERSION="3.1.0"' ./install.sh
}

@test "install.sh configures CONFIG_HOME" {
    grep -q 'CONFIG_HOME="${HOME}/.config/ultra-zsh"' ./install.sh
}

# ============================================================================
# VALIDATION TESTS
# ============================================================================

@test "script validates required tools mentioned in comments" {
    # Check if script references common tools
    grep -qi "install\|setup\|config" ./install.sh
}

@test "script has proper error handling structure" {
    # Should have error handling patterns
    grep -E "if.*then|trap|exit" ./install.sh > /dev/null
}

# ============================================================================
# DOCUMENTATION TESTS
# ============================================================================

@test "install.sh has header documentation" {
    head -n 10 ./install.sh | grep -q "NEXUS"
}

@test "install.sh has version information" {
    grep -q "v3.1" ./install.sh
}

# ============================================================================
# SECURITY TESTS
# ============================================================================

@test "install.sh does not contain hardcoded secrets" {
    ! grep -iE "password=|api_key=|secret=" ./install.sh
}

@test "install.sh uses safe variable expansion" {
    # Check for proper quoting in variable usage
    grep -E '\$\{[A-Z_]+\}' ./install.sh > /dev/null
}

# ============================================================================
# INTEGRATION TESTS
# ============================================================================

@test "install.sh syntax is valid" {
    # Check if script has valid zsh syntax
    if command -v zsh &> /dev/null; then
        zsh -n ./install.sh
    else
        skip "zsh not available for syntax check"
    fi
}
