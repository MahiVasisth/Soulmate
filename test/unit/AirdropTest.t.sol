// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {BaseTest} from "./BaseTest.t.sol";

contract AirdropTest is BaseTest {
    function test_WellInitialized() public {
        assertTrue(
            loveToken.allowance(
                address(airdropVault),
                address(airdropContract)
            ) == 500_000_000 ether
        );
    }

    function test_Claim() public {
        _mintOneTokenForBothSoulmates();

        // Not enough day in relationship
        vm.prank(soulmate1);
        vm.expectRevert();
        airdropContract.claim();

        vm.warp(block.timestamp + 200 days + 1 seconds);

        vm.prank(soulmate1);
        airdropContract.claim();

        assertTrue(loveToken.balanceOf(soulmate1) == 200 ether);

        vm.prank(soulmate2);
        airdropContract.claim();

        assertTrue(loveToken.balanceOf(soulmate2) == 200 ether);
        
        assertTrue(loveToken.balanceOf(soulmate1) == 200 ether);

    }
    // @audit : check for singles can claim love token from airdrop 
    function test_singlescanClaim() public {
        vm.prank(attacker);

        vm.warp(block.timestamp + 200 days + 1 seconds);
         vm.expectRevert();
        airdropContract.claim();

        // assertTrue(loveToken.balanceOf(attacker) == 200 ether);

        
    }

}
