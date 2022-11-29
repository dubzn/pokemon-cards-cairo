%lang starknet

from src.utils.time_converter import epoch_to_date
from src.utils.random_generator import generate_blister_pack
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.cairo_builtins import HashBuiltin

@external
func test_contains_point_happy_path{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    let epoch = 1669846233;
    let (_, _, claimed_cards) = generate_blister_pack(epoch, 1, 69);
    %{
        print(f"claimed cards {ids.claimed_cards}")
    %}

    // let (year, month, day) = epoch_to_date(epoch);
    // let year_aux = year * 10000;
    // let month_aux = month * 100;
    // let date = year_aux + month_aux + day;

    // let (claim_hash) = hash2{hash_ptr=pedersen_ptr}(caller_address, date);

    // %{
    //     print(f"claim_hash {ids.claim_hash}: {ids.year}/{ids.month}/{ids.day} - {ids.date}")
    // %}
    // 1024670627075842192129310575254363281518441961233936237901975277425575244517
    // 1024670627075842192129310575254363281518441961233936237901975277425575244517
    // 1024670627075842192129310575254363281518441961233936237901975277425575244517
    // 1298651935554320578476075934656414594964567821570595834126272951530932119280
    // 671926550182669671171834328634626358601673759298333815981089228144147725261
    // 671926550182669671171834328634626358601673759298333815981089228144147725261
    return();
}