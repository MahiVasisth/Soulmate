// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {BaseTest} from "./BaseTest.t.sol";
import {console2} from "forge-std/Test.sol";
import {Soulmate} from "../../src/Soulmate.sol";

contract StakingTest is BaseTest {
    function test_WellInitialized() public {
        assertTrue(
            loveToken.allowance(
                address(stakingVault),
                address(stakingContract)
            ) == 500_000_000 ether
        );
    }

    function test_Deposit() public {
        uint balance = 100 ether;
        _giveLoveTokenToSoulmates(balance);
        vm.startPrank(soulmate1);
        loveToken.approve(address(stakingContract), balance);
        stakingContract.deposit(balance);
        vm.stopPrank();

        assertTrue(stakingContract.userStakes(soulmate1) == balance);

        vm.startPrank(soulmate2);
        loveToken.approve(address(stakingContract), balance);
        stakingContract.deposit(balance);
        vm.stopPrank();

        assertTrue(stakingContract.userStakes(soulmate2) == balance);

        assertTrue(
            loveToken.balanceOf(address(stakingContract)) == balance * 2
        );
    }

    function test_Withdraw() public {
        uint balancePerSoulmates = 200 ether;
        _depositTokenToStake(balancePerSoulmates);

        // Withdraw twice to get back all the tokens
        vm.prank(soulmate1);
        stakingContract.withdraw(balancePerSoulmates / 2);
        assertTrue(
            loveToken.balanceOf(address(stakingContract)) ==
                balancePerSoulmates * 2 - (balancePerSoulmates / 2)
        );
        assertTrue(loveToken.balanceOf(soulmate1) == balancePerSoulmates / 2);

        vm.prank(soulmate1);
        stakingContract.withdraw(balancePerSoulmates / 2);
        assertTrue(
            loveToken.balanceOf(address(stakingContract)) == balancePerSoulmates
        );
        assertTrue(loveToken.balanceOf(soulmate1) == balancePerSoulmates);
    }

    function test_ClaimRewards() public {
        uint balancePerSoulmates = 5 ether;
        uint weekOfStaking = 5;
        _depositTokenToStake(balancePerSoulmates);

        vm.prank(soulmate1);
        vm.expectRevert();
        stakingContract.claimRewards();

        vm.warp(block.timestamp + weekOfStaking * 1 weeks + 1 seconds);

        vm.prank(soulmate1);
        stakingContract.claimRewards();

        assertTrue(
            loveToken.balanceOf(soulmate1) ==
                weekOfStaking * balancePerSoulmates
        );

        vm.prank(soulmate1);
        stakingContract.withdraw(balancePerSoulmates);
        assertTrue(
            loveToken.balanceOf(soulmate1) ==
                weekOfStaking * balancePerSoulmates + balancePerSoulmates
        );
    }

    
    // @audit - test
    function test_ClaimRewardsafterdivorced() public {
        uint tokenIdMinted = 0;

        vm.prank(soulmate1);
        soulmateContract.mintSoulmateToken();

        assertTrue(soulmateContract.totalSupply() == 0);

        // vm.prank(soulmate2);
        // soulmateContract.mintSoulmateToken();

        uint balancePerSoulmates = 5 ether;
        uint weekOfStaking = 5;
        _depositTokenToStake(balancePerSoulmates);

        soulmateContract.getDivorced();
 
        vm.warp(block.timestamp + weekOfStaking * 1 weeks + 1 seconds);

        vm.prank(soulmate1);
        stakingContract.claimRewards();

        assertTrue(
            loveToken.balanceOf(soulmate1) ==
                weekOfStaking * balancePerSoulmates
        );

        vm.prank(soulmate1);
        stakingContract.withdraw(balancePerSoulmates);
        assertTrue(
            loveToken.balanceOf(soulmate1) ==
                weekOfStaking * balancePerSoulmates + balancePerSoulmates
        );
    }

    // @audit - issue 
    function test_singlescanClaimRewards() public {
        uint tokenIdMinted = 0;
        uint balancePerSoulmates = 5 ether;
        
        uint numberDays = balancePerSoulmates / 1e18;
        vm.warp(block.timestamp + (numberDays * 1 days));

        vm.prank(attacker);
        airdropContract.claim();
        vm.prank(attacker);
        uint weekOfStaking = 5;
        // vm.startPrank(soulmate1);
        loveToken.approve(address(stakingContract), balancePerSoulmates);
        stakingContract.deposit(balancePerSoulmates);
        // vm.stopPrank();
        // _depositTokenToStake(balancePerSoulmates);

 
        vm.warp(block.timestamp + weekOfStaking * 1 weeks + 1 seconds);

        vm.prank(attacker);
        stakingContract.claimRewards();

        assertTrue(
            loveToken.balanceOf(attacker) ==
                weekOfStaking * balancePerSoulmates
        );

        vm.prank(attacker);
        stakingContract.withdraw(balancePerSoulmates);
        assertTrue(
            loveToken.balanceOf(attacker) ==
                weekOfStaking * balancePerSoulmates + balancePerSoulmates
        );
    }

}
