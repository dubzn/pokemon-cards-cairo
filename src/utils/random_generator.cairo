
%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math import unsigned_div_rem, assert_lt
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.cairo_builtins import HashBuiltin

from src.utils.converter import felt_to_uint

// generate a random number x where min <= x <= max
func random_in_range{range_check_ptr}(seed: felt, min: felt, max: felt) -> (
    random_value: felt
) {
    alloc_locals;
    assert_lt(min, max);  // min < max

    let range = max - min + 1;
    let (_, value) = unsigned_div_rem(seed, range);  // random in [0, max-min]
    return (value + min,);  // random in [min, max]
}

func generate_blister_pack{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(original_seed: felt, min: felt, max: felt) -> (
    pack_len: felt, pack: Uint256*, claimed_cards: felt
) {
    let pack: Uint256* = alloc();

    // "random" :( 
    let (seed, rseed) = unsigned_div_rem(original_seed, 521); 
    let (seed1, rseed1) = unsigned_div_rem(original_seed, 3709); 
    let (seed2, rseed2) = unsigned_div_rem(original_seed, 70879); 
    let (seed3, rseed3) = unsigned_div_rem(original_seed, 104231); 
    let (seed4, rseed4) = unsigned_div_rem(original_seed, 1949); 

    let (random1) = random_in_range(seed + rseed3, min, max);
    let (random2) = random_in_range(seed1 + rseed1, min, max);
    let (random3) = random_in_range(seed2 + rseed, min, max);
    let (random4) = random_in_range(seed3 + rseed4, min, max);
    let (random5) = random_in_range(seed4 + rseed3, min, max);

    let card1 = felt_to_uint(random1);
    let card2 = felt_to_uint(random2);
    let card3 = felt_to_uint(random3);
    let card4 = felt_to_uint(random4);
    let card5 = felt_to_uint(random5);

    assert pack[0] = card1;
    assert pack[1] = card2; 
    assert pack[2] = card3;
    assert pack[3] = card4;
    assert pack[4] = card5;

    let card5_aux = random5;
    let card4_aux = random4 * 100;
    let card3_aux = random3 * 10000;
    let card2_aux = random2 * 1000000;
    let card1_aux = random1 * 100000000;

    let claimed_cards = card1_aux  + card2_aux + card3_aux  + card4_aux  + card5_aux ;
    return (5, pack, claimed_cards);
}