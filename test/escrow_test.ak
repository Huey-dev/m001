use aiken/collection/list
use cardano/address.{Address, VerificationKey}
use cardano/assets
use cardano/transaction.{Output, OutputReference, Transaction}
use mocktail.{
  complete, mock_pub_key_address, mock_utxo_ref, mocktail_tx, set_fee,
  tx_in_inline_datum, tx_out,
}
use validators/escrow.{EscrowDatum, EscrowRedeemer, escrow}

// Helper to show "debug" info
fn trace_label(label: ByteArray, value: ByteArray) {
  expect label == label
  // just to "print" the label
  expect value == value
  // print value
}

test release_works_for_signed_student_and_payment_trace() {
  let student = mock_pub_key_address(0)
  let teacher = mock_pub_key_address(1)
  let datum = EscrowDatum { student, teacher, amount: 2_000_000 }

  trace_label("TEST: release_works_for_signed_student_and_payment", "START")

  let tx =
    mocktail_tx(
      inputs: [tx_in_inline_datum(mock_utxo_ref(0), datum)],
      outputs: [tx_out(teacher, assets.from_lovelace(2_000_000))],
      extra_signatories: [student.payment_credential.expect_verification_key],
    )
      |> set_fee(0)
      |> complete

  trace_label("TX created", "inputs: 1, outputs: 1, extra_signatories: 1")

  // --- simulate validator logic locally ---
  let student_signed =
    when datum.student.payment_credential is {
      VerificationKey(student_hash) ->
        list.has(tx.extra_signatories, student_hash)
      _ -> False
    }
  trace_label(
    "student_signed",
    if student_signed {
      "True"
    } else {
      "False"
    },
  )

  let teacher_received_funds =
    list.any(
      tx.outputs,
      fn(output) {
        output.address == datum.teacher && assets.lovelace_of(output.value) >= datum.amount
      },
    )
  trace_label(
    "teacher_received_funds",
    if teacher_received_funds {
      "True"
    } else {
      "False"
    },
  )

  // --- final validator call ---
  let result =
    escrow.spend(Some(datum), EscrowRedeemer.Release, mock_utxo_ref(0), tx)
  trace_label(
    "Validator result",
    if result {
      "True"
    } else {
      "False"
    },
  )

  expect result == True
  trace_label("TEST END", "---------------------------")
}

test cancel_fails_even_if_student_signed_trace() {
  let student = mock_pub_key_address(0)
  let teacher = mock_pub_key_address(1)
  let datum = EscrowDatum { student, teacher, amount: 2_000_000 }

  trace_label("TEST: cancel_fails_even_if_student_signed", "START")

  let tx =
    mocktail_tx(
      inputs: [tx_in_inline_datum(mock_utxo_ref(1), datum)],
      outputs: [],
      extra_signatories: [student.payment_credential.expect_verification_key],
    )
      |> set_fee(0)
      |> complete

  trace_label("TX created", "inputs: 1, outputs: 0, extra_signatories: 1")

  let student_signed =
    when datum.student.payment_credential is {
      VerificationKey(student_hash) ->
        list.has(tx.extra_signatories, student_hash)
      _ -> False
    }
  trace_label(
    "student_signed",
    if student_signed {
      "True"
    } else {
      "False"
    },
  )

  let teacher_received_funds =
    list.any(
      tx.outputs,
      fn(output) {
        output.address == datum.teacher && assets.lovelace_of(output.value) >= datum.amount
      },
    )
  trace_label(
    "teacher_received_funds",
    if teacher_received_funds {
      "True"
    } else {
      "False"
    },
  )

  let result =
    escrow.spend(Some(datum), EscrowRedeemer.Cancel, mock_utxo_ref(1), tx)
  trace_label(
    "Validator result",
    if result {
      "True"
    } else {
      "False"
    },
  )

  expect result == False
  trace_label("TEST END", "---------------------------")
}
