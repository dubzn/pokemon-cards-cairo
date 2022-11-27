%lang starknet
from starkware.cairo.common.math import unsigned_div_rem

func convert_epoch_to_timestamp{range_check_ptr}(epoch: felt) -> (year: felt, month: felt, day: felt, hour: felt, minutes: felt, seconds: felt) {
    let (year, month, day) = convert_epoch_to_date(epoch);

    let (_, r) = unsigned_div_rem(epoch, 86400);
    let (hour, rhour) = unsigned_div_rem(r, 3600);
    let (minute, seconds) = unsigned_div_rem(rhour, 60);

    return (year, month, day, hour, minute, seconds);
}

func convert_epoch_to_date{range_check_ptr}(epoch: felt) -> (year: felt, month: felt, day: felt) {
    let (year, ryear) = unsigned_div_rem(epoch, 31556926);
    let (month, rmonth) = unsigned_div_rem(ryear, 2629743);
    let (day, rday) = unsigned_div_rem(rmonth, 86400);
    
    return (year + 1970, month + 1, day + 1);
}