%lang starknet

from starkware.cairo.common.math import unsigned_div_rem, split_felt
from src.utils.time_converter import epoch_to_date
from src.utils.random_generator import generate_blister_pack
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256

@external
func test_contains_point_happy_path{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    // 0x033948D15C214A141ECb27CdE676Ed990B1F554BD6C84dbAd12DE090f1F8f631
    // 0x053f44e0e4e4ed385e0e1a79f2c10371ca999bd5b04a24600d6f8fc1070647d6
    let account = 0x033948D15C214A141ECb27CdE676Ed990B1F554BD6C84dbAd12DE090f1F8f631;
    let account2 = 0x053f44e0e4e4ed385e0e1a79f2c10371ca999bd5b04a24600d6f8fc1070647d6;
    let timestamp = 1670696360;
    let block_number = 469929;
    let (high1, low1) = split_felt(account);

    let account_value = get_value_from_caller_account(account, timestamp);
    let account_value2 = get_value_from_caller_account(account2, timestamp);

    let (_,_, claimed_cards) = generate_blister_pack(account_value + timestamp + block_number, 1, 69);
    let (_,_, claimed_cards2) = generate_blister_pack(account_value2 + timestamp + block_number, 1, 69);

    %{
        print(f"{ids.claimed_cards}")
        print(f"{ids.claimed_cards2}")
    %}
 
    return();
}

func felt_to_uint256{range_check_ptr}(value) -> Uint256 {
    let (high, low) = split_felt(value);
    let value256 = Uint256(low, high);
    return value256;
}

func get_value_from_caller_account{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(address: felt, timestamp: felt) -> felt {
    let (high, low) = split_felt(address);
    let (_, h) = unsigned_div_rem(high, 9973);
    let (_, l) = unsigned_div_rem(low, 7549);
    let (_, rem) = unsigned_div_rem(timestamp, h + l);

    return rem; 
}