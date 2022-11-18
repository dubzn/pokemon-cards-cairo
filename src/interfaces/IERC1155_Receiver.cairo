%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IERC1155_Receiver {
    func onERC1155Received(operator: felt, from_: felt, id: Uint256, amount: Uint256) -> (selector: felt) {
    }

    func onERC1155BatchReceived(
        operator: felt,
        from_: felt,
        ids_len: felt,
        ids: Uint256*,
        amounts_len: felt,
        amounts: Uint256*,
    ) -> (selector: felt) {
    }

    func supportsInterface(interfaceId: felt) -> (success: felt) {
    }
}
