%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.math import assert_not_zero, unsigned_div_rem, split_felt
from starkware.starknet.common.syscalls import get_block_number, get_block_timestamp, get_caller_address

from src.access.ownable.library import Ownable
from src.introspection.erc165.library import ERC165
from src.token.tokenURI import ERC1155_setBaseTokenURI, ERC1155_tokenURI, ERC1155_setContractURI, ERC1155_contractURI
from src.token.erc1155.library import ERC1155
from src.utils.converter import felt_to_uint
from src.utils.time_converter import epoch_to_date
from src.utils.random_generator import generate_blister_pack
from src.upgrades.library import Proxy


const MIN_VALUE_CARD_ID = 1;
const MAX_VALUE_CARD_ID = 69;

//
// Proxy
//

@external
func initializer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr} (proxy_admin: felt, name: felt, symbol: felt, owner: felt, base_token_uri_len: felt, base_token_uri: felt*, contract_uri_len: felt, contract_uri: felt*) {
    ERC1155.initializer(name, symbol);
    Ownable.initializer(owner);
    ERC1155_setBaseTokenURI(base_token_uri_len, base_token_uri);
    ERC1155_setContractURI(contract_uri_len, contract_uri);
    Proxy.initializer(proxy_admin);
    return ();
}

@external
func upgrade{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr} (new_implementation: felt) -> () {
    Proxy.assert_only_admin();
    Proxy._set_implementation_hash(new_implementation);
    return ();
}

//
// Storage 
//

@storage_var
func claimed_pack(hash_value: felt) -> (claimed: felt) {
}

@storage_var
func daily_trade(hash_value: felt) -> (claimed: felt) {
}

//
// Getters
//

@view
func supportsInterface{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr} (interfaceId: felt) -> (success: felt) {
    return ERC165.supports_interface(interfaceId);
}

@view
func blockTimestamp{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (timestamp: felt) {
     let (current_epoch) = get_block_timestamp();
     return (current_epoch,);
}

@view
func name{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (name: felt) {
    return ERC1155.name();
}

@view
func symbol{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (symbol: felt) {
    return ERC1155.symbol();
}

@view
func uri{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(tokenId: Uint256) -> (tokenURI_len: felt, tokenURI: felt*) {
    alloc_locals;
    if (tokenId.low == 0) {
        let empty_uri: felt* = alloc();   
        return (tokenURI_len=0, tokenURI=empty_uri);
    }

    let (uri_len, uri) = ERC1155_tokenURI(tokenId);
    return (tokenURI_len=uri_len, tokenURI=uri);
}

@view
func tokenURI{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(tokenId: Uint256) -> (tokenURI_len: felt, tokenURI: felt*) {
    alloc_locals;
    if (tokenId.low == 0) {
        let empty_uri: felt* = alloc();   
        return (tokenURI_len=0, tokenURI=empty_uri);
    }

    let (uri_len, uri) = ERC1155_tokenURI(tokenId);
    return (tokenURI_len=uri_len, tokenURI=uri);
}

@view
func contractURI{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (contractURI_len: felt, contractURI: felt*) {
    alloc_locals;
    let (uri_len, uri) = ERC1155_contractURI();
    return (contractURI_len=uri_len, contractURI=uri);
}

// its represented with a positional felt
// If it returns 10 it is because you have sent a card to another address, 
// if it returns 1 it is because you have received a card from another person. 
// If it is 11, then both conditions are met.
@view
func get_user_daily_trade{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(user_address: felt) -> (daily_trade: felt) {
    let (current_epoch) = get_block_timestamp();
    let (day, _) = unsigned_div_rem(current_epoch, 86400);
    let (user_plus_day_hash) = hash2{hash_ptr=pedersen_ptr}(user_address, day);
    let (trade_value) = daily_trade.read(user_plus_day_hash);

    return (daily_trade=trade_value);
}

@view
func get_user_claimed_pack{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(user_address: felt) -> (claimed: felt) {
    let (current_epoch) = get_block_timestamp();
    let (day, _) = unsigned_div_rem(current_epoch, 86400);

    let (user_plus_day_hash) = hash2{hash_ptr=pedersen_ptr}(user_address, day);
    let (claimed_pack_today) = claimed_pack.read(user_plus_day_hash);

    return (claimed=claimed_pack_today);
}

@view
func balanceOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    account: felt, id: Uint256
) -> (balance: Uint256) {
    let (balance) = ERC1155.balance_of(account, id);
    return (balance,);
}

@view
func balanceOfBatch{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    accounts_len: felt, accounts: felt*, ids_len: felt, ids: Uint256*
) -> (balances_len: felt, balances: Uint256*) {
    let (balances_len, balances) = ERC1155.balance_of_batch(accounts_len, accounts, ids_len, ids);
    return (balances_len, balances);
}

@view
func isApprovedForAll{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    account: felt, operator: felt
) -> (isApproved: felt) {
    let (is_approved) = ERC1155.is_approved_for_all(account, operator);
    return (is_approved,);
}

@view
func owner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (owner: felt) {
    let (owner: felt) = Ownable.owner();
    return (owner,);
}

//
// Externals
//

@external
func mint_daily_cards{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    let (current_epoch) = get_block_timestamp();
    let (current_block) = get_block_number();
    let (caller_address) = get_caller_address();

    let (day, _) = unsigned_div_rem(current_epoch, 86400);
    let (claim_hash) = hash2{hash_ptr=pedersen_ptr}(caller_address, day);
    let (claimed_pack_today) = claimed_pack.read(claim_hash);

    with_attr error_message("Already claimed a pack of cards today!") {
        assert claimed_pack_today = 0;
    }

    let account_value = get_value_from_caller_account(caller_address, current_epoch);
    let (pack_len, pack, claimed_cards) = generate_blister_pack(account_value + current_epoch + current_block, MIN_VALUE_CARD_ID, MAX_VALUE_CARD_ID);
    let array_amounts_filled_one = fill_array_with(pack_len, 1);
    
    // TODO: check what data is, for now will send empty
    let data_len = 0;
    let data: felt* = alloc();

    ERC1155._mint_batch(caller_address, pack_len, pack, pack_len, array_amounts_filled_one, data_len, data);
    claimed_pack.write(claim_hash, claimed_cards);
    return ();
}


@external
func send_card{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    to: felt, id: Uint256
) {
    alloc_locals;
    let (current_epoch) = get_block_timestamp();
    let (caller_address) = get_caller_address();

    let (day, _) = unsigned_div_rem(current_epoch, 86400);

    // Validate that the person sending the letter has not used their daily delivery.
    let (caller_hash) = hash2{hash_ptr=pedersen_ptr}(caller_address, day);
    let (caller_trade_status) = daily_trade.read(caller_hash);
    let (caller_send_card_flag, caller_receiver_card_flag) = unsigned_div_rem(caller_trade_status, 10);

    with_attr error_message("The person trying to send has already sent a card today!") {
        assert caller_send_card_flag = 0;
    }

    // Validate that the person receiving the letter has not used their daily receipt.
    let (receiver_hash) = hash2{hash_ptr=pedersen_ptr}(to, day);
    let (receiver_trade_status) = daily_trade.read(receiver_hash);
    let (receiver_send_card_flag, receiver_receive_card_flag) = unsigned_div_rem(receiver_trade_status, 10);

    with_attr error_message("The person who is going to receive it has already received a card today!") {
        assert receiver_receive_card_flag = 0;
    }

    let one = 1;
    let amount = felt_to_uint(one);
    // TODO: check what data is, for now will send empty
    let data_len = 0;
    let data: felt* = alloc();

    ERC1155.safe_transfer_from(caller_address, to, id, amount, data_len, data);

    // write sender and receiver variables
    daily_trade.write(caller_hash, caller_receiver_card_flag + 10);
    daily_trade.write(receiver_hash, (receiver_send_card_flag * 10) + 1);
    return ();
}

@external
func setBaseTokenURI{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(base_token_uri_len: felt, base_token_uri: felt*) {
    Ownable.assert_only_owner();
    ERC1155_setBaseTokenURI(base_token_uri_len, base_token_uri);
    return ();
}

@external
func setContractURI{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(contract_uri_len: felt, contract_uri: felt*) {
    Ownable.assert_only_owner();
    ERC1155_setContractURI(contract_uri_len, contract_uri);
    return ();
}

@external
func mint{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    to: felt, id: Uint256, amount: Uint256, data_len: felt, data: felt*
) {
    Ownable.assert_only_owner();
    ERC1155._mint(to, id, amount, data_len, data);
    return ();
}

@external
func mintBatch{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    to: felt,
    ids_len: felt,
    ids: Uint256*,
    amounts_len: felt,
    amounts: Uint256*,
    data_len: felt,
    data: felt*,
) {
    Ownable.assert_only_owner();
    ERC1155._mint_batch(to, ids_len, ids, amounts_len, amounts, data_len, data);
    return ();
}

@external
func setApprovalForAll{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    operator: felt, approved: felt
) {
    ERC1155.set_approval_for_all(operator, approved);
    return ();
}

@external
func burn{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    from_: felt, id: Uint256, amount: Uint256
) {
    ERC1155.assert_owner_or_approved(owner=from_);
    ERC1155._burn(from_, id, amount);
    return ();
}

@external
func burnBatch{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    from_: felt, ids_len: felt, ids: Uint256*, amounts_len: felt, amounts: Uint256*
) {
    ERC1155.assert_owner_or_approved(owner=from_);
    ERC1155._burn_batch(from_, ids_len, ids, amounts_len, amounts);
    return ();
}

@external
func safeTransferFrom{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    from_: felt, to: felt, id: Uint256, amount: Uint256, data_len: felt, data: felt*
) {
    Ownable.assert_only_owner();
    ERC1155.safe_transfer_from(from_, to, id, amount, data_len, data);
    return ();
}

@external
func safeBatchTransferFrom{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    from_: felt,
    to: felt,
    ids_len: felt,
    ids: Uint256*,
    amounts_len: felt,
    amounts: Uint256*,
    data_len: felt,
    data: felt*,
) {
    Ownable.assert_only_owner();
    ERC1155.safe_batch_transfer_from(from_, to, ids_len, ids, amounts_len, amounts, data_len, data);
    return ();
}

@external
func transferOwnership{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    newOwner: felt
) {
    Ownable.transfer_ownership(newOwner);
    return ();
}

@external
func renounceOwnership{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    Ownable.renounce_ownership();
    return ();
}

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

func get_value_from_caller_account{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(address: felt, timestamp: felt) -> felt {
    let (high, low) = split_felt(address);
    let (_, h) = unsigned_div_rem(high, 9973);
    let (_, l) = unsigned_div_rem(low, 7549);
    let (_, rem) = unsigned_div_rem(timestamp, h + l);

    return rem; 
}