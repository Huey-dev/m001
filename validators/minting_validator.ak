// // use cardano/assets.{PolicyId}
// // use cardano/transaction.{Transaction, placeholder}

// // /// A simple minting validator that always succeeds.
// // validator minting_policy {
// //   mint(_redeemer: Data, _policy_id: PolicyId, _tx: Transaction) {
// //     trace @"Minting validator called: minting_policy"
// //     True
// //   }

// //   else(_) {
// //     trace @"Minting validator called with wrong purpose: minting_policy"
// //     fail
// //   }
// // }

// // // ============================================================================
// // // TESTS for minting_policy
// // // ============================================================================

// // // Success Test 1: Basic success with Void redeemer
// // test success_test_1() {
// //   trace @"Test 4: Basic success for minting"
// //   minting_policy.mint(Void, #"", placeholder)
// // }

// // // Success Test 2: Success with a dummy redeemer
// // test success_test_2() {
// //   trace @"Test 5: Success with dummy redeemer"
// //   let dummy_data = 99
// //   minting_policy.mint(dummy_data, #"", placeholder)
// // }

// // // Success Test 3: With a bytearray redeemer
// // test success_test_3() {
// //   trace @"Test 6: Success with bytearray redeemer"
// //   minting_policy.mint(#"deadbeef", #"", placeholder)
// // }

// use cardano/assets.{from_lovelace} use mocktail.{ mocktail_tx, tx_in, tx_out, complete, set_fee, mock_pub_key_address, mock_tx_hash } fn mock_spending_tx() -> Transaction { mocktail_tx() |> tx_in(True, mock_tx_hash(0), 0, from_lovelace(10_000_000), // 10 ADA input mock_pub_key_address(0, None)) |> tx_out(True, mock_pub_key_address(1, None), from_lovelace(9_000_000)) // 9 ADA output |> complete() |> set_fee(True, 1_000_000) // 1 ADA fee } test test_balance() { let tx = mock_spending_tx() // 10 ADA in = 9 ADA out + 1 ADA fee ✓ }
