%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.math import unsigned_div_rem, split_felt
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_block_number, get_block_timestamp, get_caller_address


from src.utils.converter import felt_to_uint
from src.utils.time_converter import epoch_to_date
from src.utils.random_generator import generate_blister_pack
from src.contracts.ownable import Ownable
from src.contracts.library import ERC1155_initializer, ERC1155_uri, ERC1155_balanceOf, ERC1155_balanceOfBatch, ERC1155_safeTransferFrom, ERC1155_mint, ERC1155_mint_batch

const MIN_VALUE_CARD_ID = 1;
const MAX_VALUE_CARD_ID = 69;

@storage_var
func claimed_pack(hash_value: felt) -> (claimed: felt) {
}

@storage_var
func daily_trade(hash_value: felt) -> (claimed: felt) {
}

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(owner: felt) {
    ERC1155_initializer(152661009894058335206669104024417562691910569980719); // https://ipfs.io/ipfs/
    Ownable.initializer(owner);
    return ();
}

// its represented with a positional felt
// If it returns 10 it is because you have sent a card to another address, 
// if it returns 1 it is because you have received a card from another person. 
// If it is 11, then both conditions are met.
@view
func get_user_daily_trade{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(user_address: felt) -> (daily_trade: felt) {
    let (current_epoch) = get_block_timestamp();

    let (year, month, day) = epoch_to_date(current_epoch);
    let year_aux = year * 10000;
    let month_aux = month * 100;
    let date = year_aux + month_aux + day;

    let (user_plus_day_hash) = hash2{hash_ptr=pedersen_ptr}(user_address, date);
    let (trade_value) = daily_trade.read(user_plus_day_hash);

    return (daily_trade=trade_value);
}

@view
func get_user_claimed_pack{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(user_address: felt) -> (claimed: felt) {
    let (current_epoch) = get_block_timestamp();

    let (year, month, day) = epoch_to_date(current_epoch);
    let year_aux = year * 10000;
    let month_aux = month * 100;
    let date = year_aux + month_aux + day;

    let (user_plus_day_hash) = hash2{hash_ptr=pedersen_ptr}(user_address, date);
    let (claimed_pack_today) = claimed_pack.read(user_plus_day_hash);

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
func mint_daily_cards{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    let (current_epoch) = get_block_timestamp();
    let (current_block) = get_block_number();
    let (caller_address) = get_caller_address();

    let (year, month, day) = epoch_to_date(current_epoch);
    let year_aux = year * 10000;
    let month_aux = month * 100;
    let date = year_aux + month_aux + day;

    let (claim_hash) = hash2{hash_ptr=pedersen_ptr}(caller_address, date);
    let (claimed_pack_today) = claimed_pack.read(claim_hash);

    with_attr error_message("Already claimed a pack of cards today!") {
        assert claimed_pack_today = 0;
    }

    let account_value = get_value_from_caller_account(caller_address);
    let (pack_len, pack, claimed_cards) = generate_blister_pack(account_value + current_epoch + current_block, MIN_VALUE_CARD_ID, MAX_VALUE_CARD_ID);
    let array_amounts_filled_one = fill_array_with(pack_len, 1);

    ERC1155_mint_batch(caller_address, pack_len, pack, pack_len, array_amounts_filled_one);
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

    let (year, month, day) = epoch_to_date(current_epoch);
    let year_aux = year * 10000;
    let month_aux = month * 100;
    let date = year_aux + month_aux + day;

    // Validate that the person sending the letter has not used their daily delivery.
    let (caller_hash) = hash2{hash_ptr=pedersen_ptr}(caller_address, date);
    let (caller_trade_status) = daily_trade.read(caller_hash);
    let (caller_send_card_flag, caller_receiver_card_flag) = unsigned_div_rem(caller_trade_status, 10);

    with_attr error_message("The person trying to send has already sent a card today!") {
        assert caller_send_card_flag = 0;
    }

    // Validate that the person receiving the letter has not used their daily receipt.
    let (receiver_hash) = hash2{hash_ptr=pedersen_ptr}(to, date);
    let (receiver_trade_status) = daily_trade.read(receiver_hash);
    let (receiver_send_card_flag, receiver_receive_card_flag) = unsigned_div_rem(receiver_trade_status, 10);

    with_attr error_message("The person who is going to receive it has already received a card today!") {
        assert receiver_receive_card_flag = 0;
    }

    let one = 1;
    let amount = felt_to_uint(one);
    ERC1155_safeTransferFrom(caller_address, to, id, amount);

    // write sender and receiver variables
    daily_trade.write(caller_hash, caller_receiver_card_flag + 10);
    daily_trade.write(receiver_hash, (receiver_send_card_flag * 10) + 1);
    return ();
}

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

func get_value_from_caller_account{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(address: felt) -> felt {
    let (_, low) = split_felt(address);
    let (_, r) = unsigned_div_rem(low, 103307);
    return r; 
}