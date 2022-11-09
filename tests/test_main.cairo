%lang starknet
from src.contract import balance, increase_balance
from starkware.cairo.common.cairo_builtins import HashBuiltin
from src.models import Inventory

@storage_var
func inventory(owner_address: felt ) -> (inventory: Inventory) { }

@storage_var
func cards(owner_address: felt, card_address: felt) -> (owned: felt) { } 

@view
func get_inventory_by_address{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(owner_address: felt) -> Inventory {
    let (inventory) = inventory.read(owner_address);
    return (inventory,); 
}

@external
func claim_pack{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
   return ();
}

