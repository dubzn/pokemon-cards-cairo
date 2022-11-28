%lang starknet
from starkware.cairo.common.math import unsigned_div_rem
from src.utils.time_converter import convert_epoch_to_timestamp 

@external
func test_convert_coord_to_id_happy_path{range_check_ptr}() {
    let epoc = 1669580635;
    let (year, month, day, hour, minute, second) = convert_epoch_to_timestamp(1669580635);
    // %{
    //     print(f"epoc {ids.epoc}: year {ids.year}, month {ids.month}, day {ids.day}, hour {ids.hour}, minutes {ids.minute}, seconds {ids.second}")
    // %}

    let account = "";
    let block_number = "";
    let time = "";

    let random = random_in_range(1669580635, 1, 69);
     %{
        print(f"random {ids.random}")
    %}


    return();
}

// generate a random number x where min <= x <= max
func random_in_range{range_check_ptr}(seed: felt, min: felt, max: felt) -> (
    random_value: felt
) {
    assert_lt(min, max);  // min < max

    let range = max - min + 1;
    let (_, value) = unsigned_div_rem(seed, range);  // random in [0, max-min]
    return (value + min,);  // random in [min, max]
}