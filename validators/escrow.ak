use aiken/collection/list
use cardano/address.{Address, VerificationKey}
use cardano/assets
use cardano/transaction.{Output, OutputReference, Transaction}

pub type EscrowDatum {
  student: Address,
  teacher: Address,
  amount: Int,
}

pub type EscrowRedeemer {
  Release
  Cancel
}

validator escrow {
  spend(
    datum: Option<EscrowDatum>,
    redeemer: EscrowRedeemer,
    _input: OutputReference,
    tx: Transaction,
  ) {
    expect Some(escrow_datum) = datum
    when redeemer is {
      Release -> {
        // Check if student signed
        let student_signed =
          when escrow_datum.student.payment_credential is {
            VerificationKey(student_hash) ->
              list.has(tx.extra_signatories, student_hash)
            _ -> False
          }
        // Check if teacher received funds
        let teacher_received_funds =
          list.any(
            tx.outputs,
            fn(output) {
              output.address == escrow_datum.teacher && assets.lovelace_of(
                output.value,
              ) >= escrow_datum.amount
            },
          )
        student_signed && teacher_received_funds
      }
      Cancel -> False
    }
  }

  else(_) {
    fail
  }
}
