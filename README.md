![image](https://user-images.githubusercontent.com/58611754/209554835-45acd93e-ed93-4dca-8b2c-dc83e2c420b7.png)
# [Poke-Cairo Cards](https://pokecairo-cards.com/)
This is a collection of NFTs (with no real value) based on the first pack of the original Pokemon sets. This is NOT intended for any kind of monetary benefit, it is simply for fun and to learn more about Blockchain/Starknet ecosystem. I do not own the art found on the cards, all rights reserved to their creators.

You can claim a pack per day (contains 5 cards), once the day has passed it cannot be minted. It is based on the ERC1155 standard, so cards can be transferred with other users (one trade per day is allowed).

In principle the base set contains 102 cards, but in this case we will remove the trainer and energy cards (a total of 69 cards remain).

## Implemented features

- ERC 1155 (based on Open Zeppelin contract)
- Pseudo-random generator based on time, wallet caller and block number.
- Daily mint restriction.
- Daily trade restriction (You can send and receive 1 card per day).
- Proxy contract implementation for regenesis. 
- ERC 1155 metadata is stored in IPFS.
