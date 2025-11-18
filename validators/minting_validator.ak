use cardano/assets.{PolicyId}
use cardano/transaction.{Transaction, placeholder}

/// A simple minting validator that always succeeds.
validator minting_policy {
  mint(
    _redeemer: Data,
    _policy_id: PolicyId,
    _tx: Transaction,
  ) {
    trace @"Minting validator called: minting_policy"
    True
  }

  else(_) {
    trace @"Minting validator called with wrong purpose: minting_policy"
    fail
  }
}

// ============================================================================
// TESTS for minting_policy
// ============================================================================

// Success Test 1: Basic success with Void redeemer
test success_test_1() {
  trace @"Test 4: Basic success for minting"
  minting_policy.mint(Void, #"", placeholder)
}

// Success Test 2: Success with a dummy redeemer
test success_test_2() {
  trace @"Test 5: Success with dummy redeemer"
  let dummy_data = 99
  minting_policy.mint(dummy_data, #"", placeholder)
}

// Success Test 3: With a bytearray redeemer
test success_test_3() {
  trace @"Test 6: Success with bytearray redeemer"
  minting_policy.mint(#"deadbeef", #"", placeholder)
}