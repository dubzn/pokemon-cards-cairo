
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
    pack_len: felt, pack: Uint256*
) {
    let pack: Uint256* = alloc();

    let (seed, rseed) = unsigned_div_rem(original_seed, 14); 
    let (seed1, rseed1) = unsigned_div_rem(original_seed, 46); 
    let (seed2, rseed2) = unsigned_div_rem(original_seed, 52); 
    let (seed3, rseed3) = unsigned_div_rem(original_seed, 4256); 
    let (seed4, rseed4) = unsigned_div_rem(original_seed, 525); 
    let (seed5, rseed5) = unsigned_div_rem(original_seed, 2323); 
    let (seed6, rseed6) = unsigned_div_rem(original_seed, 753); 
    let (seed7, rseed7) = unsigned_div_rem(original_seed, 51254); 
    let (seed8, rseed8) = unsigned_div_rem(original_seed, 9378); 
    let (seed9, rseed9) = unsigned_div_rem(original_seed, 1020); 
    let (seed10, rseed10) = unsigned_div_rem(original_seed, 848); 

    // "random" :( 
    let (random1) = random_in_range(seed + rseed2, min, max);
    let (random2) = random_in_range(seed1 + rseed5, min, max);
    let (random3) = random_in_range(seed2 + rseed3, min, max);
    let (random4) = random_in_range(seed3 + rseed7, min, max);
    let (random5) = random_in_range(seed4 + rseed, min, max);
    let (random6) = random_in_range(seed5 + rseed9, min, max);
    let (random7) = random_in_range(seed6 + rseed10, min, max);
    let (random8) = random_in_range(seed7 + rseed4, min, max);
    let (random9) = random_in_range(seed8 + rseed1, min, max);
    let (random10) = random_in_range(seed9 + rseed8, min, max);
    let (random11) = random_in_range(seed10 + rseed6, min, max);

    let card1 = felt_to_uint(random1);
    let card2 = felt_to_uint(random2);
    let card3 = felt_to_uint(random3);
    let card4 = felt_to_uint(random4);
    let card5 = felt_to_uint(random5);
    let card6 = felt_to_uint(random6);
    let card7 = felt_to_uint(random7);
    let card8 = felt_to_uint(random8);
    let card9 = felt_to_uint(random9);
    let card10 = felt_to_uint(random10);
    let card11 = felt_to_uint(random11);

    assert pack[0] = card1;
    assert pack[1] = card2; 
    assert pack[2] = card3;
    assert pack[3] = card4;
    assert pack[4] = card5;
    assert pack[5] = card6;
    assert pack[6] = card7;
    assert pack[7] = card8;
    assert pack[8] = card9;
    assert pack[9] = card10;
    assert pack[10]= card11;

    return (11, pack);
}