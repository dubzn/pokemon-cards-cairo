%lang starknet

from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero, assert_not_equal
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_add,
    uint256_sub,
    uint256_le,
    uint256_check,
)
from src.introspection.IERC165 import IERC165
from src.interfaces.IERC1155_Receiver import IERC1155_Receiver

const IERC1155_interface_id = 0xd9b67a26;
const IERC1155_MetadataURI_interface_id = 0x0e89341c;
const IERC165_interface_id = 0x01ffc9a7;

const IERC1155_RECEIVER_ID = 0x4e2312e0;
const ON_ERC1155_RECEIVED_SELECTOR = 0xf23a6e61;
const ON_BATCH_ERC1155_RECEIVED_SELECTOR = 0xbc197c81;
const IACCOUNT_ID = 0xf10dbd44;

//
// Events
//

@event
func TransferSingle(operator: felt, from_: felt, to: felt, id: Uint256, value: Uint256) {
}

@event
func TransferBatch(
    operator: felt,
    from_: felt,
    to: felt,
    ids_len: felt,
    ids: Uint256*,
    values_len: felt,
    values: Uint256*,
) {
}

@event
func ApprovalForAll(account: felt, operator: felt, approved: felt) {
}

@event
func URI(value_len: felt, value: felt*, id: Uint256) {
}

//
// Storage
//

@storage_var
func ERC1155_balances_(id: Uint256, account: felt) -> (balance: Uint256) {
}

@storage_var
func ERC1155_operator_approvals_(account: felt, operator: felt) -> (approved: felt) {
}

// TODO: decide URI format
@storage_var
func ERC1155_uri_() -> (uri: felt) {
}

//
// Constructor
//

func ERC1155_initializer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    uri_: felt
) {
    _setURI(uri_);
    return ();
}

//
// Getters
//

func ERC1155_supportsInterface(interface_id: felt) -> (is_supported: felt) {
    // Less expensive (presumably) than storage
    if (interface_id == IERC1155_interface_id) {
        return (1,);
    }
    if (interface_id == IERC1155_MetadataURI_interface_id) {
        return (1,);
    }
    if (interface_id == IERC165_interface_id) {
        return (1,);
    }
    return (0,);
}

func ERC1155_uri{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (uri: felt) {
    let (uri) = ERC1155_uri_.read();
    return (uri,);
}

func ERC1155_balanceOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    account: felt, id: Uint256
) -> (balance: Uint256) {
    with_attr error_message("ERC1155: balance query for the zero address") {
        assert_not_zero(account);
    }
    let (balance) = ERC1155_balances_.read(id=id, account=account);
    return (balance,);
}

func ERC1155_balanceOfBatch{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    accounts_len: felt, accounts: felt*, ids_len: felt, ids: Uint256*
) -> (batch_balances_len: felt, batch_balances: Uint256*) {
    alloc_locals;
    // Check args are equal length arrays
    with_attr error_message("ERC1155: accounts and ids length mismatch") {
        assert ids_len = accounts_len;
    }
    // Allocate memory
    let (local batch_balances: Uint256*) = alloc();
    let len = accounts_len;
    // Call iterator
    balance_of_batch_iter(len, accounts, ids, batch_balances);
    return (batch_balances_len=len, batch_balances=batch_balances);
}

func ERC1155_isApprovedForAll{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    account: felt, operator: felt
) -> (is_approved: felt) {
    let (is_approved) = ERC1155_operator_approvals_.read(account=account, operator=operator);
    return (is_approved,);
}

//
// Externals
//

func ERC1155_setApprovalForAll{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    operator: felt, approved: felt
) {
    let (caller) = get_caller_address();
    // Non-zero caller asserted in called function
    _set_approval_for_all(owner=caller, operator=operator, approved=approved);
    return ();
}

func ERC1155_safeTransferFrom{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    from_: felt, to: felt, id: Uint256, amount: Uint256
) {
    let (caller) = get_caller_address();
    with_attr error_message("ERC1155: called from zero address") {
        assert_not_zero(caller);
    }
    with_attr error_message("ERC1155: caller is not owner nor approved") {
        owner_or_approved(from_);
    }
    _safe_transfer_from(from_, to, id, amount);
    return ();
}

func ERC1155_safeBatchTransferFrom{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    from_: felt, to: felt, ids_len: felt, ids: Uint256*, amounts_len: felt, amounts: Uint256*
) {
    let (caller) = get_caller_address();
    with_attr error_message("ERC1155: called from zero address") {
        assert_not_zero(caller);
    }
    with_attr error_message("ERC1155: transfer caller is not owner nor approved") {
        owner_or_approved(from_);
    }
    return _safe_batch_transfer_from(from_, to, ids_len, ids, amounts_len, amounts);
}

//
// Internals
//

func _safe_transfer_from{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    from_: felt, to: felt, id: Uint256, amount: Uint256
) {
    alloc_locals;
    // Check args
    with_attr error_message("ERC1155: transfer to the zero address") {
        assert_not_zero(to);
    }
    with_attr error_message("ERC1155: invalid uint in calldata") {
        uint256_check(id);
        uint256_check(amount);
    }
    // Todo: beforeTokenTransfer

    // Check balance sufficient
    let (local from_balance) = ERC1155_balances_.read(id=id, account=from_);
    let (sufficient_balance) = uint256_le(amount, from_balance);
    with_attr error_message("ERC1155: insufficient balance for transfer") {
        assert_not_zero(sufficient_balance);
    }
    // Deduct from sender
    let (new_balance: Uint256) = uint256_sub(from_balance, amount);
    ERC1155_balances_.write(id=id, account=from_, value=new_balance);

    // Add to reciever
    let (to_balance: Uint256) = ERC1155_balances_.read(id=id, account=to);
    let (new_balance: Uint256, carry) = uint256_add(to_balance, amount);
    with_attr error_message("arithmetic overflow") {
        assert carry = 0;
    }
    ERC1155_balances_.write(id=id, account=to, value=new_balance);

    let (operator) = get_caller_address();

    TransferSingle.emit(operator, from_, to, id, amount);

    _do_safe_transfer_acceptance_check(operator, from_, to, id, amount);

    return ();
}

func _safe_batch_transfer_from{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    from_: felt, to: felt, ids_len: felt, ids: Uint256*, amounts_len: felt, amounts: Uint256*
) {
    alloc_locals;
    with_attr error_message("ERC1155: ids and amounts length mismatch") {
        assert_not_zero(to);
    }
    // Check args are equal length arrays
    with_attr error_message("ERC1155: transfer to the zero address") {
        assert ids_len = amounts_len;
    }
    // Recursive call
    let len = ids_len;
    safe_batch_transfer_from_iter(from_, to, len, ids, amounts);
    let (operator) = get_caller_address();
    TransferBatch.emit(operator, from_, to, ids_len, ids, amounts_len, amounts);
    // _do_safe_batch_transfer_acceptance_check(
    //     operator, from_, to, ids_len, ids, amounts_len, amounts
    // )
    return ();
}

func ERC1155_mint{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    to: felt, id: Uint256, amount: Uint256
) {
    let (caller) = get_caller_address();
    with_attr error_message("ERC1155: called from zero address") {
        assert_not_zero(caller);
    }
    // Cannot mint to zero address
    with_attr error_message("ERC1155: mint to the zero address") {
        assert_not_zero(to);
    }
    // Check uints valid
    with_attr error_message("ERC1155: invalid uint256 in calldata") {
        uint256_check(id);
        uint256_check(amount);
    }
    // beforeTokenTransfer
    // add to minter check for overflow
    let (to_balance: Uint256) = ERC1155_balances_.read(id=id, account=to);
    let (new_balance: Uint256, carry) = uint256_add(to_balance, amount);
    with_attr error_message("ERC1155: arithmetic overflow") {
        assert carry = 0;
    }
    ERC1155_balances_.write(id=id, account=to, value=new_balance);
    // doSafeTransferAcceptanceCheck
    let (operator) = get_caller_address();
    TransferSingle.emit(operator=operator, from_=0, to=to, id=id, value=amount);
    _do_safe_transfer_acceptance_check(operator, 0, to, id, amount);

    return ();
}

func ERC1155_mint_batch{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    to: felt, ids_len: felt, ids: Uint256*, amounts_len: felt, amounts: Uint256*
) {
    alloc_locals;
    let (caller) = get_caller_address();
    with_attr error_message("ERC1155: called from zero address") {
        assert_not_zero(caller);
    }
    // Cannot mint to zero address
    with_attr error_message("ERC1155: mint to the zero address") {
        assert_not_zero(to);
    }
    // Check args are equal length arrays
    with_attr error_message("ERC1155: ids and amounts length mismatch") {
        assert ids_len = amounts_len;
    }
    // Recursive call
    let len = ids_len;
    mint_batch_iter(to, len, ids, amounts);
    let (operator) = get_caller_address();
    TransferBatch.emit(
        operator=operator,
        from_=0,
        to=to,
        ids_len=ids_len,
        ids=ids,
        values_len=amounts_len,
        values=amounts,
    );
    // _do_safe_batch_transfer_acceptance_check(operator, 0, to, ids_len, ids, amounts_len, amounts)
    return ();
}

func ERC1155_burn{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    from_: felt, id: Uint256, amount: Uint256
) {
    alloc_locals;
    let (caller) = get_caller_address();
    with_attr error_message("ERC1155: called from zero address") {
        assert_not_zero(caller);
    }
    with_attr error_message("ERC1155: burn from the zero address") {
        assert_not_zero(from_);
    }
    // beforeTokenTransfer
    // Check balance sufficient
    let (local from_balance) = ERC1155_balances_.read(id=id, account=from_);
    let (sufficient_balance) = uint256_le(amount, from_balance);
    with_attr error_message("ERC1155: burn amount exceeds balance") {
        assert_not_zero(sufficient_balance);
    }
    // Deduct from burner
    let (new_balance: Uint256) = uint256_sub(from_balance, amount);
    ERC1155_balances_.write(id=id, account=from_, value=new_balance);
    let (operator) = get_caller_address();
    TransferSingle.emit(operator=operator, from_=from_, to=0, id=id, value=amount);
    return ();
}

func ERC1155_burn_batch{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    from_: felt, ids_len: felt, ids: Uint256*, amounts_len: felt, amounts: Uint256*
) {
    alloc_locals;
    let (caller) = get_caller_address();
    with_attr error_message("ERC1155: called from zero address") {
        assert_not_zero(caller);
    }
    with_attr error_message("ERC1155: burn from the zero address") {
        assert_not_zero(from_);
    }
    // Check args are equal length arrays
    with_attr error_message("ERC1155: ids and amounts length mismatch") {
        assert ids_len = amounts_len;
    }
    // Recursive call
    let len = ids_len;
    burn_batch_iter(from_, len, ids, amounts);
    let (operator) = get_caller_address();
    TransferBatch.emit(
        operator=operator,
        from_=from_,
        to=0,
        ids_len=ids_len,
        ids=ids,
        values_len=amounts_len,
        values=amounts,
    );
    return ();
}

//
// Internals
//

func _set_approval_for_all{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    owner: felt, operator: felt, approved: felt
) {
    // check approved is bool
    assert approved * (approved - 1) = 0;
    // since caller can now be 0
    with_attr error_message("ERC1155: setting approval status for zero address") {
        assert_not_zero(owner * operator);
    }
    with_attr error_message("ERC1155: setting approval status for self") {
        assert_not_equal(owner, operator);
    }
    ERC1155_operator_approvals_.write(owner, operator, approved);
    ApprovalForAll.emit(owner, operator, approved);
    return ();
}

func _setURI{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(newuri: felt) {
    ERC1155_uri_.write(newuri);
    return ();
}

func _do_safe_transfer_acceptance_check{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(operator: felt, from_: felt, to: felt, id: Uint256, amount: Uint256) {
    let (caller) = get_caller_address();
    // ERC1155_RECEIVER_ID = 0x4e2312e0
    let (is_supported) = IERC165.supportsInterface(to, IERC1155_RECEIVER_ID);
    if (is_supported == 1) {
        let (selector) = IERC1155_Receiver.onERC1155Received(to, operator, from_, id, amount);

        // onERC1155Recieved selector
        with_attr error_message("ERC1155: ERC1155Receiver rejected tokens") {
            assert selector = ON_ERC1155_RECEIVED_SELECTOR;
        }
        return ();
    }
    let (is_account) = IERC165.supportsInterface(to, IACCOUNT_ID);
    with_attr error_message("ERC1155: transfer to non ERC1155Receiver implementer") {
        assert_not_zero(is_account);
    }
    // IAccount_ID = 0x50b70dcb
    return ();
}

func _do_safe_batch_transfer_acceptance_check{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(
    operator: felt,
    from_: felt,
    to: felt,
    ids_len: felt,
    ids: Uint256*,
    amounts_len: felt,
    amounts: Uint256*,
) {
    let (caller) = get_caller_address();
    // Confirm supports IERC1155Reciever interface
    let (is_supported) = IERC165.supportsInterface(to, IERC1155_RECEIVER_ID);
    if (is_supported == 1) {
        let (selector) = IERC1155_Receiver.onERC1155BatchReceived(
            to, operator, from_, ids_len, ids, amounts_len, amounts
        );

        // Confirm onBatchERC1155Recieved selector returned
        with_attr error_message("ERC1155: ERC1155Receiver rejected tokens") {
            assert selector = ON_BATCH_ERC1155_RECEIVED_SELECTOR;
        }
        return ();
    }

    // Alternatively confirm EOA
    let (is_account) = IERC165.supportsInterface(to, IACCOUNT_ID);
    with_attr error_message("ERC1155: transfer to non ERC1155Receiver implementer") {
        assert_not_zero(is_account);
    }
    return ();
}

//
// Helpers
//

func balance_of_batch_iter{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    len: felt, accounts: felt*, ids: Uint256*, batch_balances: Uint256*
) {
    if (len == 0) {
        return ();
    }
    // may be unnecessary now
    // Read current entries, Todo: perform Uint256 checks
    let id: Uint256 = [ids];
    uint256_check(id);
    let account: felt = [accounts];

    let (balance: Uint256) = ERC1155_balanceOf(account, id);
    assert [batch_balances] = balance;
    return balance_of_batch_iter(
        len - 1, accounts + 1, ids + Uint256.SIZE, batch_balances + Uint256.SIZE
    );
}

func safe_batch_transfer_from_iter{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    from_: felt, to: felt, len: felt, ids: Uint256*, amounts: Uint256*
) {
    // Base case
    alloc_locals;
    if (len == 0) {
        return ();
    }

    // Read current entries,  perform Uint256 checks
    let id = [ids];
    with_attr error_message("ERC1155: invalid uint in calldata") {
        uint256_check(id);
    }
    let amount = [amounts];
    with_attr error_message("ERC1155: invalid uint in calldata") {
        uint256_check(amount);
    }

    // Check balance is sufficient
    let (from_balance) = ERC1155_balances_.read(id=id, account=from_);
    let (sufficient_balance) = uint256_le(amount, from_balance);
    with_attr error_message("ERC1155: insufficient balance for transfer") {
        assert_not_zero(sufficient_balance);
    }
    // deduct from
    let (new_balance: Uint256) = uint256_sub(from_balance, amount);
    ERC1155_balances_.write(id=id, account=from_, value=new_balance);

    // add to
    let (to_balance: Uint256) = ERC1155_balances_.read(id=id, account=to);
    let (new_balance: Uint256, carry) = uint256_add(to_balance, amount);
    with_attr error_message("arithmetic overflow") {
        assert carry = 0;  // overflow protection
    }
    ERC1155_balances_.write(id=id, account=to, value=new_balance);

    // Recursive call
    return safe_batch_transfer_from_iter(
        from_, to, len - 1, ids + Uint256.SIZE, amounts + Uint256.SIZE
    );
}

func mint_batch_iter{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    to: felt, len: felt, ids: Uint256*, amounts: Uint256*
) {
    // Base case
    alloc_locals;
    if (len == 0) {
        return ();
    }

    // Read current entries, Todo: perform Uint256 checks
    let id: Uint256 = [ids];
    let amount: Uint256 = [amounts];
    with_attr error_message("ERC1155: invalid uint256 in calldata") {
        uint256_check(id);
        uint256_check(amount);
    }
    // add to
    let (to_balance: Uint256) = ERC1155_balances_.read(id=id, account=to);
    let (new_balance: Uint256, carry) = uint256_add(to_balance, amount);
    with_attr error_message("ERC1155: arithmetic overflow") {
        assert carry = 0;  // overflow protection
    }
    ERC1155_balances_.write(id=id, account=to, value=new_balance);

    // Recursive call
    return mint_batch_iter(to, len - 1, ids + Uint256.SIZE, amounts + Uint256.SIZE);
}

func burn_batch_iter{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    from_: felt, len: felt, ids: Uint256*, amounts: Uint256*
) {
    // Base case
    alloc_locals;
    if (len == 0) {
        return ();
    }

    // Read current entries, Todo: perform Uint256 checks
    let id: Uint256 = [ids];
    with_attr error_message("ERC1155: invalid uint in calldata") {
        uint256_check(id);
    }
    let amount: Uint256 = [amounts];
    with_attr error_message("ERC1155: invalid uint in calldata") {
        uint256_check(amount);
    }

    // Check balance is sufficient
    let (from_balance) = ERC1155_balances_.read(id=id, account=from_);
    let (sufficient_balance) = uint256_le(amount, from_balance);
    with_attr error_message("ERC1155: burn amount exceeds balance") {
        assert_not_zero(sufficient_balance);
    }

    // deduct from
    let (new_balance: Uint256) = uint256_sub(from_balance, amount);
    ERC1155_balances_.write(id=id, account=from_, value=new_balance);

    // Recursive call
    return burn_batch_iter(from_, len - 1, ids + Uint256.SIZE, amounts + Uint256.SIZE);
}

func owner_or_approved{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(owner) {
    let (caller) = get_caller_address();
    if (caller == owner) {
        return ();
    }
    let (approved) = ERC1155_isApprovedForAll(owner, caller);
    assert approved = 1;
    return ();
}
