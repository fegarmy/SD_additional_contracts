# How to use it
1. Deploy it on Remix.ethereum.org
2. Change the address on the contract to your token on `_tokenAddress` or direct on the deployed contract using changeTokenAddress
3. Register either 1 user at a time or via bulk by creating an array format ["","","",""] e.g ["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4","0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2","0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB","0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db"]
4. If you are getting issues on the array make sure to split the array because otherwise you will run in gas issues.
5. Everyone will have to claim it manually after releaseAirdrop has been called
6. IF there are leftover's (reflection or other token) then you can claim them once 2 weeks passed by or if the airdrop has no registered users.

# Test performed on

* ✔️ claimAirdrop (should work)
* ✔️ Register multiple wallet (should work)
* ✔️ Claim if not registered in presale (should fail)
* ✔️ Enter a user after presale has closed (should fail)
* ✔️ Register 1 single user (should work)
* ✔️ see if is a participant (NO) => register multi only one => see if is participant (true)
* ✔️  send token to presale => getLeftOver =>  LeftOverAvaillable (0)
* ✔️ Rentrecy guard if trying to reenter the claimAirdrop (should fail)
* ✔️ Get reflections during Airdrop
* ✔️ Get reflections after Airdrop
* ✔️ Checks if can change address if people are in presale (should fail)
* ✔️ Checks if can change address if people are in presale and time passed (should pass)
* ✔️ Checks if can double claim airdrop (should fail)
* ✔️ Check changing of owner after launch
* ✔️ Check changing of address after launch and before  registering one
* ✔️ Check if user has been register and then containing in multiregister that it doesn't increase the counter
* ✔️ Single user that is already register should not incremented the counter.
