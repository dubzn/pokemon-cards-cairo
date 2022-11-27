%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_block_number, get_block_timestamp

from src.contracts.ownable import Ownable
from src.contracts.library import ERC1155_initializer, ERC1155_supportsInterface, ERC1155_uri, ERC1155_balanceOf, ERC1155_balanceOfBatch, ERC1155_isApprovedForAll, ERC1155_setApprovalForAll, ERC1155_safeTransferFrom, ERC1155_safeBatchTransferFrom, ERC1155_mint, ERC1155_mint_batch, ERC1155_burn, ERC1155_burn_batch, owner_or_approved

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(owner: felt, url: felt) {
    ERC1155_initializer(url);
    Ownable.initializer(owner);
    return ();
}


// @view
// func supportsInterface(interfaceId: felt) -> (is_supported: felt) {
//     return ERC1155_supportsInterface(interfaceId);
// }

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

@view
func block_and_time{syscall_ptr : felt*, range_check_ptr}() -> (time : felt, block : felt) {
    let (current_timestamp) = get_block_timestamp();
    let (current_block) = get_block_number();

    return (current_timestamp, current_block);
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

@external
func mintCardsBatch{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
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
