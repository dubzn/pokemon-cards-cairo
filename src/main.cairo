%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_block_number, get_block_timestamp, get_caller_address

from src.utils.converter import felt_to_uint
from src.utils.time_converter import epoch_to_date
from src.utils.random_generator import generate_blister_pack
from src.contracts.ownable import Ownable
from src.contracts.library import ERC1155_initializer, ERC1155_supportsInterface, ERC1155_uri, ERC1155_balanceOf, ERC1155_balanceOfBatch, ERC1155_isApprovedForAll, ERC1155_setApprovalForAll, ERC1155_safeTransferFrom, ERC1155_safeBatchTransferFrom, ERC1155_mint, ERC1155_mint_batch, ERC1155_burn, ERC1155_burn_batch, owner_or_approved

const MIN_VALUE_CARD_ID = 1;
const MAX_VALUE_CARD_ID = 69;

@storage_var
func claimed_pack(hash_value: felt) -> (claimed: felt) {
}

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(owner: felt, url: felt) {
    ERC1155_initializer(url);
    Ownable.initializer(owner);
    return ();
}

@view
func user_claim_pack{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(user_address: felt) -> (claimed: felt) {
    let (current_epoch) = get_block_timestamp();

    let (year, month, day) = epoch_to_date(current_epoch);
    let year_aux = year * 10000;
    let month_aux = month * 100;
    let date = year_aux + month_aux + day;

    let (claim_hash) = hash2{hash_ptr=pedersen_ptr}(user_address, date);
    let (claimed_pack_today) = claimed_pack.read(claim_hash);

    return (claimed=claimed_pack_today);
}

@view
func uri{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (uri: felt) {
    return ERC1155_uri();
}

@view
func balanceOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    account: felt, id: Uint256
) -> (balance: Uint256) {
    return ERC1155_balanceOf(account, id);
}

@view
func balanceOfBatch{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    accounts_len: felt, accounts: felt*, ids_len: felt, ids: Uint256*
) -> (batch_balances_len: felt, batch_balances: Uint256*) {
    return ERC1155_balanceOfBatch(accounts_len, accounts, ids_len, ids);
}

@external
func mintCardsBatch{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    let (current_epoch) = get_block_timestamp();
    let (current_block) = get_block_number();
    let (caller_adress) = get_caller_address();

    let (year, month, day) = epoch_to_date(current_epoch);
    let year_aux = year * 10000;
    let month_aux = month * 100;
    let date = year_aux + month_aux + day;

    let (claim_hash) = hash2{hash_ptr=pedersen_ptr}(caller_adress, date);
    let (claimed_pack_today) = claimed_pack.read(claim_hash);

    with_attr error_message("Already claimed a pack of cards today!") {
        assert claimed_pack_today = 0;
    }

    let (pack_len, pack, claimed_cards) = generate_blister_pack(current_epoch + current_block, MIN_VALUE_CARD_ID, MAX_VALUE_CARD_ID);
    let array_amounts_filled_one = fill_array_with(pack_len, 1);

    ERC1155_mint_batch(caller_adress, pack_len, pack, pack_len, array_amounts_filled_one);
    claimed_pack.write(claim_hash, claimed_cards);
    return ();
}

// @view
// func isApprovedForAll{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
//     account: felt, operator: felt
// ) -> (is_approved: felt) {
//     return ERC1155_isApprovedForAll(account, operator);
// }

//
// Externals
//

// @external
// func setApprovalForAll{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
//     operator: felt, approved: felt
// ) {
//     ERC1155_setApprovalForAll(operator, approved);
//     return ();
// }

// @external
// func safeTransferFrom{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
//     _from: felt, to: felt, id: Uint256, amount: Uint256
// ) {
//     ERC1155_safeTransferFrom(_from, to, id, amount);
//     return ();
// }

// @external
// func safeBatchTransferFrom{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
//     _from: felt, to: felt, ids_len: felt, ids: Uint256*, amounts_len: felt, amounts: Uint256*
// ) {
//     ERC1155_safeBatchTransferFrom(_from, to, ids_len, ids, amounts_len, amounts);
//     return ();
// }

@external
func mint{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    to: felt, id: Uint256, amount: Uint256
) {
    Ownable.assert_only_owner();
    ERC1155_mint(to, id, amount);
    return ();
}

@external
func mintBatch{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    to: felt, ids_len: felt, ids: Uint256*, amounts_len: felt, amounts: Uint256*
) {
    Ownable.assert_only_owner();
    ERC1155_mint_batch(to, ids_len, ids, amounts_len, amounts);
    return ();
}


// @external
// func burn{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
//     _from: felt, id: Uint256, amount: Uint256
// ) {
//     owner_or_approved(owner=_from);
//     ERC1155_burn(_from, id, amount);
//     return ();
// }

// @external
// func burnBatch{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
//     _from: felt, ids_len: felt, ids: Uint256*, amounts_len: felt, amounts: Uint256*
// ) {
//     owner_or_approved(owner=_from);
//     ERC1155_burn_batch(_from, ids_len, ids, amounts_len, amounts);
//     return ();
// }

// AUX
func fill_array_with{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(len: felt, value_to_fill: felt) -> Uint256* {
    let array: Uint256* = alloc();
    return _fill_array_with(len, value_to_fill, array, 0);
}

func _fill_array_with{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(len: felt, value_to_fill: felt, array: Uint256*, i: felt) -> Uint256* {
    if (len == i) {
        return array;
    }
    let converted_value = felt_to_uint(value_to_fill);
    assert array[i] = converted_value;
    return _fill_array_with(len, value_to_fill, array, i + 1);
}