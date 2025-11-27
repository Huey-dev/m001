use aiken/collection/list
use cardano/address.{Address, VerificationKey}
use cardano/assets
use cardano/transaction.{Output, Transaction}
use mocktail.{
  complete, mock_pub_key_address, mock_script_address, mock_tx_hash,
  mock_utxo_ref, mocktail_tx, set_fee, tx_in, tx_in_inline_datum, tx_out,
  tx_out_inline_datum,
}
use validators/escrow.{EscrowDatum, EscrowRedeemer, escrow}

fn mock_locking_tx(student: Address, teacher: Address, amt: Int) -> Transaction {
  mocktail_tx()
    |> tx_out(True, mock_script_address(0, None), from_lovelace(amt))
    |> tx_out_inline_datum(
        True,
        mock_script_address(0, None),
        EscrowDatum { student, teacher, amount: amt },
      )
    |> complete()
}

test release_works_for_signed_student_and_payment() {
  let student = mock_pub_key_address(0)
  let teacher = mock_pub_key_address(1)
  let datum = EscrowDatum { student, teacher, amount: 2_000_000 }

  let tx =
    mocktail_tx(
      inputs: [tx_in_inline_datum(mock_utxo_ref(0), datum)],
      outputs: [tx_out(teacher, assets.from_lovelace(2_000_000))],
      extra_signatories: [student.payment_credential.expect_verification_key],
    )
      |> set_fee(0)
      |> complete

  let result =
    escrow.spend(Some(datum), EscrowRedeemer.Release, mock_utxo_ref(0), tx)
  expect result == True
}

test cancel_fails_even_if_student_signed() {
  let student = mock_pub_key_address(0)
  let teacher = mock_pub_key_address(1)
  let datum = EscrowDatum { student, teacher, amount: 2_000_000 }

  let tx =
    mocktail_tx(
      inputs: [tx_in_inline_datum(mock_utxo_ref(1), datum)],
      outputs: [],
      extra_signatories: [student.payment_credential.expect_verification_key],
    )
      |> set_fee(0)
      |> complete

  let result =
    escrow.spend(Some(datum), EscrowRedeemer.Cancel, mock_utxo_ref(1), tx)
  expect result == False
}
