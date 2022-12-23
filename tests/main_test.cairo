%lang starknet

from starkware.cairo.common.math import unsigned_div_rem, split_felt
from src.utils.time_converter import epoch_to_date, epoch_to_timestamp
from src.utils.random_generator import generate_blister_pack
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256

@external
func test_contains_point_happy_path{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    %{
        print(f"{ids.user_plus_day_hash2}")
    %}
    return();
}