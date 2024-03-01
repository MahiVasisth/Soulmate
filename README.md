<p align="center">
<img src="https://res.cloudinary.com/droqoz7lg/image/upload/q_90/dpr_2.0/c_fill,g_auto,h_320,w_320/f_auto/v1/company/jlaqqfofafa01emq3nh8?_a=BATAUVAA0" width="400" alt="soulmate">
<br/>

# Contest Details

Our **FIRST EVER** Community Submitted First Flight Contest! A huge thank you to **n0kto** for this incredible contribution to the community.

### Prize Pool

- High - 100xp
- Medium - 20xp
- Low - 2xp

- Starts: February 08, 2024 Noon UTC
- Ends: February 15, 2024 Noon UTC

### Stats

- nSLOC: 233
- Complexity Score: 123

# Soulmate

# Disclaimer

_This code was created for Codehawks as the first flights for Valentine's day. It is made with bugs and flaws on purpose._
_Don't use any part of this code without reviewing it and audit it._

# About

Valentine's day is approaching, and with that, it's time to meet your soulmate!

We've created the Soulmate protocol, where you can mint your shared Soulbound NFT with an unknown person, and get `LoveToken` as a reward for staying with your soulmate.
A staking contract is available to collect more love. Because if you give love, you receive more love.

## Soulmate.sol

The Soulbound NFT shared by soulmates used in the protocol.
It is used by Airdrop.sol and Staking.sol to know how long the couple are in love.

The main functions are:

- `mintSoulmateToken`: Where you'll mint a soulbound NFT. You'll either be assigned to someone else who is waiting for a soulmate, or you'll be waiting for a soulmate to be assigned to you.
- `soulmateOf`: Where you can see the soulmate of an address. If it returns `address(0)` then a soulmate has not been assigned yet.
- `writeMessageInSharedSpace`: Where you can write messages to your soulmate.

Everyone should be able to be minted a soulmate.

And finally, sometimes, love can be hard, even if it is your soulmate... but there is always another solution : get divorced.

- `getDivorced`: Where you and your soulmate are separated and no longer soulmates. This will cancel the possibily for 2 lovers to collect LoveToken from the airdrop. There is and should be no way to undo this action.

## LoveToken.sol

A basic ERC20 Token given to soulmates. The initial supply is distributed to 2 instances of `Vault.sol` managed by:

- `Airdrop.sol`
- `Staking.sol`

This token represents how much love there is between two soulmates.

## Airdrop.sol

Once you have a soulmate, you can claim 1 LoveToken a day.

This contract has 1 main function:

- `claim`: Allows only those with a soulmate to collect 1 LoveToken per day. Both soulmates can collect 1 per day (aka, 2 per day per couple).

## Staking.sol

As you claim your LoveToken, you can stake it to claim even more!

This contract is dedicated to the staking functionality.
It has the following functions:

- `deposit`: Deposit LoveToken to the staking contract
- `withdraw`: Withdraw LoveToken from the staking contract
- `claimRewards`: Claim LoveToken rewards from the staking contract.

For every 1 token deposited and 1 week left in the contract, 1 LoveToken is rewarded.

Examples:

- 1 token deposited for 1 week = 1 LoveToken reward
- 7 tokens deposited for 2 weeks = 14 LoveToken reward

## Vault.sol

The vault contract is responsible for holding the love tokens, and approving the Staking and Airdrop contracts to pull funds from the Vaults. There will be 2 vaults:

- A vault to hold funds for the airdrop contract
- A vault to hold funds for the staking contract

# Getting Started

## Requirements

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - You'll know you did it right if you can run `git --version` and you see a response like `git version x.x.x`
- [foundry](https://getfoundry.sh/)
  - You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.2.0 (816e00b 2023-03-16T00:05:26.396218Z)`

# Usage

## Testing

```
forge test
```

### Test Coverage

```
forge coverage
```

and for coverage based testing:

```
forge coverage --report debug
```

# Audit Scope Details

- Commit Hash:
- In Scope:
  (For this contest, just use the main branch)

```
Hash:
```

## Compatibilities

- Solc Version: `0.8.23 < 0.9.0`
- Chain(s) to deploy contract to:
  - Ethereum

# Roles

None

# Known Issues

- Eventually, the counter used to give ids will reach the `type(uint256).max` and no more will be able to be minted. This is known and can be ignored.

### Title : There is a lack of check that either people have soulmate or not in Airdrop :: claim() so that any person which have not any soulmate can also claim love token.
## Summary
 In Airdrop :: claim() function both partner of a couple can claim their own token every days on the basis of their Soulmate NFT token.
  ## Vulnerability Details 
  But this function is only checked for the mapping is either couple divorced or not.It will not check that is the soulmate of the msg.sender exist or not. The result is this anyone who not mint an SoulmateToken can also claim love token from this function.
## Code Snippet
 function claim() public {
        // No LoveToken for people who don't love their soulmates anymore.
        // @audit-issue : Lack of check that either it have soulmate or not
        if (soulmateContract.isDivorced()) revert Airdrop__CoupleIsDivorced();
        // Calculating since how long soulmates are reunited
        uint256 numberOfDaysInCouple = (block.timestamp -
            soulmateContract.idToCreationTimestamp(0
                soulmateContract.ownerToId(msg.sender)
            )) / daysInSecond;

        uint256 amountAlreadyClaimed = _claimedBy[msg.sender];

        if (
            amountAlreadyClaimed >=
            numberOfDaysInCouple * 10 ** loveToken.decimals()
        ) revert Airdrop__PreviousTokenAlreadyClaimed();

        uint256 tokenAmountToDistribute = (numberOfDaysInCouple *
            10 ** loveToken.decimals()) - amountAlreadyClaimed;

        // Dust collector
        if (
            tokenAmountToDistribute >=
            loveToken.balanceOf(address(airdropVault))
        ) {
            tokenAmountToDistribute = loveToken.balanceOf(
                address(airdropVault)
            );
        }
        _claimedBy[msg.sender] += tokenAmountToDistribute;

        emit TokenClaimed(msg.sender, tokenAmountToDistribute);

        loveToken.transferFrom(
            address(airdropVault),
            msg.sender,
            tokenAmountToDistribute
        );
    }

## Impact
The impact is this the people who have not soulmates can claim love token.
##POC
    function test_singlescanClaim() public {
        vm.prank(attacker);
    
        vm.warp(block.timestamp + 200 days + 1 seconds);

        vm.prank(attacker);
        airdropContract.claim();
        assertTrue(loveToken.balanceOf(attacker) == 200 ether);
    }

## Tools Used
   Foundry
## Recommendations 
Its recommended to add an additional check in claim function which check for soulmate of msg.sender is exist or not.
  function claim() public {
        // No LoveToken for people who don't love their soulmates anymore.
        if (soulmateContract.isDivorced()) revert Airdrop__CoupleIsDivorced();
           // @audit - recommended
          address soulmate2 = soulmateContract.soulmateOf(msg.sender);
          require(soulmate2!=address(0));
        // Calculating since how long soulmates are reunited
        uint256 numberOfDaysInCouple = (block.timestamp -
            soulmateContract.idToCreationTimestamp(
                soulmateContract.ownerToId(msg.sender)
            )) / daysInSecond;

        uint256 amountAlreadyClaimed = _claimedBy[msg.sender];

        if (
            amountAlreadyClaimed >=
            numberOfDaysInCouple * 10 ** loveToken.decimals()
        ) revert Airdrop__PreviousTokenAlreadyClaimed();

        uint256 tokenAmountToDistribute = (numberOfDaysInCouple *
            10 ** loveToken.decimals()) - amountAlreadyClaimed;

        // Dust collector
        if (
            tokenAmountToDistribute >=
            loveToken.balanceOf(address(airdropVault))
        ) {
            tokenAmountToDistribute = loveToken.balanceOf(
                address(airdropVault)
            );
        }
        _claimedBy[msg.sender] += tokenAmountToDistribute;

        emit TokenClaimed(msg.sender, tokenAmountToDistribute);

        loveToken.transferFrom(
            address(airdropVault),
            msg.sender,
            tokenAmountToDistribute
        );
    }
  ## POC :
  Now its correct If the people have not soulmate then it can't claim love token.  
   function test_youcannotClaimlove_token_if_youaresingle() public {
        vm.prank(attacker);
     
        vm.warp(block.timestamp + 200 days + 1 seconds);

        vm.prank(attacker);
        vm.expectRevert();
        airdropContract.claim();
    }

     

 2.
### Title : Lack of check for either soulmate exist or not in Soulmate :: writeMessageInSharedSpace() function so that persons who have no NFT ID can take advantage.
## Summary
 Soulmate :: writeMessageInSharedSpace() function allows any soulmates with the same NFT ID to write in a shared space on blockchain.But there is possible that the persons who have no NFT ID can also write and read there.
## Vulnerability Details 
   In Soulmate :: writeMessageInSharedSpace() function we are checking for soulmate by ownerToId[msg.sender]. But what If the person who calls this function for writing message have no NFT ID can also write and read message there.
## Code Snippet
     function writeMessageInSharedSpace(string calldata message) external {
        // @audit : Lack of check that either soulmate exist or not.  
        uint256 id = ownerToId[msg.sender];
        sharedSpace[id] = message;
        emit MessageWrittenInSharedSpace(id, message);
    } 
## Impact
  The impact is this there is no control on only soulmates can add the touch of romantism according to documentation.
## POC
    function test_auditWriteAndReadSharedSpace() public {
        vm.prank(address(1));
        soulmateContract.writeMessageInSharedSpace("Buy some eggs");
        vm.prank(address(2));
       
        string memory message = soulmateContract.readMessageInSharedSpace();

        string[4] memory possibleText = [
            "Buy some eggs, sweetheart",
            "Buy some eggs, darling",
            "Buy some eggs, my dear",
            "Buy some eggs, honey"
        ];
        bool found;
        for (uint i; i < possibleText.length; i++) {
            if (compare(possibleText[i], message)) {
                found = true;
                break;
            }
        }
        console2.log(message);
        assertTrue(found);
    }
## Tools Used
 Foundry
## Recommendations 
Add a check that the person must have soulmate exist before it write message to shared space. 
   function writeMessageInSharedSpace(string calldata message) external {
        address soulmate2 = soulmateOf[msg.sender];
         require(soulmate2!=address(0));
        uint256 id = ownerToId[msg.sender];
        sharedSpace[id] = message;
        emit MessageWrittenInSharedSpace(id, message);
    }

  ## POC :
  Now only person have soulmates can write message.
   function test_writemessagerevertforsinglepeople() public {
        vm.prank(address(1));
        vm.expectRevert();
        soulmateContract.writeMessageInSharedSpace("Buy some eggs");
        }
   
  

     
3. 
### Title :
Lack of check for soulmate address in Soulmate :: readMessageInSharedSpace() function so that it will contain privacy issues for the person which have NFT ID is zero. 
## Summary
Soulmate :: readMessageInSharedSpace() function allows any soulmates with the same NFT ID to read in a shared space on blockchain but it will contain privacy issues for the address which have zero NFT ID.
## Vulnerability Details
   In Soulmate :: readMessageInSharedSpace() function we are checking for soulmate by ownerToId[msg.sender]. But what if any third person can read your message.Its possible when
   (a). You are the first person which call mint soulmate token before you anybody is not minted any token.So that your NFT ID contains zero value. (Here two soulmates are alice and charlie). It means any person which have zero value of NFT ID can read your message. 
   (b). If I am any third person bob which not call mint soulmate function. So that  NFT ID of bob is also zero.
   According to function working bob have the rights to read the message written by alice for charlie.
 
## Code Snippet
  /// @notice Allows any soulmates with the same NFT ID to read in a shared space on blockchain.
    function readMessageInSharedSpace() external view returns (string memory) {
        // Add a little touch of romantism
        return
            string.concat(
                sharedSpace[ownerToId[msg.sender]],
                ", ",
                niceWords[block.timestamp % niceWords.length]
            );
    }

## Impact
The impact is that the person with zero NFT ID have lack of privacy for their message.
## POC
function test_ThirdpersoncanReadSharedSpace() public {
        vm.prank(alice);
        
        soulmateContract.mintSoulmateToken();
        vm.prank(charlie);
       
        soulmateContract.mintSoulmateToken();
        vm.prank(alice);
       
        soulmateContract.writeMessageInSharedSpace("Buy some eggs");
        vm.prank(charlie);
       
        string memory message = soulmateContract.readMessageInSharedSpace();

        string[4] memory possibleText = [
            "Buy some eggs, sweetheart",
            "Buy some eggs, darling",
            "Buy some eggs, my dear",
            "Buy some eggs, honey"
        ];
        bool found;
        for (uint i; i < possibleText.length; i++) {
            if (compare(possibleText[i], message)) {
                found = true;
                break;
            }
        }
        console2.log(message);
        assertTrue(found);
        vm.prank(bob);
        
        string memory message1 = soulmateContract.readMessageInSharedSpace();

        string[4] memory possibleText1 = [
            "Buy some eggs, sweetheart",
            "Buy some eggs, darling",
            "Buy some eggs, my dear",
            "Buy some eggs, honey"
        ];
        bool found1;
        for (uint i; i < possibleText1.length; i++) {
            if (compare(possibleText1[i], message1)) {
                found1 = true;
                break;
            }
        }
        console2.log(message1);
        assertTrue(found1);
    
    }    

## Tools Used
 Foundry
## Recommendations 
Recommendation to check for soulmate address existence.

 /// @notice Allows any soulmates with the same NFT ID to read in a shared space on blockchain.
    function readMessageInSharedSpace() external view returns (string memory) {
        // Add a little touch of romantism
        address soulmate2 = soulmateOf[msg.sender];
        require(soulmate2!=address(0));
        return
            string.concat(
                sharedSpace[ownerToId[msg.sender]],
                ", ",
                niceWords[block.timestamp % niceWords.length]
            );
    }

  ## POC :
  function test_ThirdpersoncannotReadSharedSpace() public {
        vm.prank(alice);
        
        soulmateContract.mintSoulmateToken();
        vm.prank(charlie);
       
        soulmateContract.mintSoulmateToken();
        vm.prank(alice);
       
        soulmateContract.writeMessageInSharedSpace("Buy some eggs");
        vm.prank(charlie);
       
        string memory message = soulmateContract.readMessageInSharedSpace();

        string[4] memory possibleText = [
            "Buy some eggs, sweetheart",
            "Buy some eggs, darling",
            "Buy some eggs, my dear",
            "Buy some eggs, honey"
        ];
        bool found;
        for (uint i; i < possibleText.length; i++) {
            if (compare(possibleText[i], message)) {
                found = true;
                break;
            }
        }
        console2.log(message);
        assertTrue(found);
        vm.prank(bob);
        vm.expectRevert(); 
        string memory message1 = soulmateContract.readMessageInSharedSpace();
  }
    

4 . 
### Title :
 Lack of CEI in Vault :: InitVault() so that reentrancy issue is possible. 
## Summary
 Vault :: InitVault() is used approve its corresponding management contract to handle tokens. vaultInitialize protect against multiple initialization.
    
## Vulnerability Details
The  `InitVault()` function is not properly follows checks effects pattern . This allows an attacker to call `InitVault()` multiple times.
## Code Snippet
     function initVault(ILoveToken loveToken, address managerContract) public {
        if (vaultInitialize) revert Vault__AlreadyInitialized();
        @audit-issue : Lack of CEI.
        loveToken.initVault(managerContract);
        vaultInitialize = true;
      }

## Impact
The imact is that vault can initialize multiple times.
## Tools Used
 Manual check
## Recommendations 
Try to write this function like this.
  function initVault(ILoveToken loveToken, address managerContract) public {
        if (vaultInitialize) revert Vault__AlreadyInitialized();
        vaultInitialize = true;
        loveToken.initVault(managerContract);
      }


