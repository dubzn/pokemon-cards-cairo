%lang starknet
from starkware.cairo.common.math import unsigned_div_rem
from src.utils.time_converter import convert_epoch_to_timestamp 

@external
func test_convert_coord_to_id_happy_path{range_check_ptr}() {
    let epoc = 1669580635;
    let (year, month, day, hour, minute, second) = convert_epoch_to_timestamp(1669580635);
    %{
        print(f"epoc {ids.epoc}: year {ids.year}, month {ids.month}, day {ids.day}, hour {ids.hour}, minutes {ids.minute}, seconds {ids.second}")
    %}


    return();
}