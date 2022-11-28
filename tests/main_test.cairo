%lang starknet

from src.utils.time_converter import epoch_to_date

@external
func test_contains_point_happy_path{range_check_ptr}() {
    let epoch = 1669672620;
    let (y, m, d) = epoch_to_date(1669672620);

    let year = y * 10000;
    let month = m * 100;

    let day = year + month + d;

    %{
        print(f"epoc {ids.epoch}: year {ids.year}, month {ids.month}, day {ids.day}")
    %}

    return();
}