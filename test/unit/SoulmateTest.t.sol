// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {console2} from "forge-std/Test.sol";

import {BaseTest} from "./BaseTest.t.sol";
import {Soulmate} from "../../src/Soulmate.sol";

contract SoulmateTest is BaseTest {
    address soulmate3 = makeAddr("soulmate3");
    address soulmate4 = makeAddr("soulmate4");

    // address attacker = makeAddr("attacker");
    address attacker1 = makeAddr("attacker1");
    address alice = makeAddr("alice");
    address charlie = makeAddr("charlie");
    address bob = makeAddr("bob");

    function test_MintNewToken() public {
        uint tokenIdMinted = 0;

        vm.prank(soulmate1);
        soulmateContract.mintSoulmateToken();

        assertTrue(soulmateContract.totalSupply() == 0);

        vm.prank(soulmate2);
        soulmateContract.mintSoulmateToken();

        assertTrue(soulmateContract.totalSupply() == 1);
        assertTrue(soulmateContract.soulmateOf(soulmate1) == soulmate2);
        assertTrue(soulmateContract.soulmateOf(soulmate2) == soulmate1);
        assertTrue(soulmateContract.ownerToId(soulmate1) == tokenIdMinted);
        console2.log(tokenIdMinted);
        assertTrue(soulmateContract.ownerToId(soulmate2) == tokenIdMinted);
        console2.log(tokenIdMinted);
    }
    
  
    
    // @audit - test : soulmates are considered soulmate even after divorce
    function test_deboseNewToken() public {
        uint tokenIdMinted = 0;

        vm.prank(soulmate1);
        soulmateContract.mintSoulmateToken();

        assertTrue(soulmateContract.totalSupply() == 0);

        vm.prank(soulmate2);
        soulmateContract.mintSoulmateToken();

        assertTrue(soulmateContract.totalSupply() == 1);
        assertTrue(soulmateContract.soulmateOf(soulmate1) == soulmate2);
        assertTrue(soulmateContract.soulmateOf(soulmate2) == soulmate1);
        assertTrue(soulmateContract.ownerToId(soulmate1) == tokenIdMinted);
        assertTrue(soulmateContract.ownerToId(soulmate2) == tokenIdMinted);
        soulmateContract.getDivorced();
        assertTrue(soulmateContract.soulmateOf(soulmate1) == soulmate2);
        assertTrue(soulmateContract.soulmateOf(soulmate2) == soulmate1);
        assertTrue(soulmateContract.ownerToId(soulmate1) == tokenIdMinted);
        assertTrue(soulmateContract.ownerToId(soulmate2) == tokenIdMinted);
      
    }



    function test_NoTransferPossible() public {
        _mintOneTokenForBothSoulmates();

        vm.prank(soulmate1);
        vm.expectRevert();
        soulmateContract.transferFrom(soulmate1, soulmate2, 0);
    }

    function compare(
        string memory str1,
        string memory str2
    ) public pure returns (bool) {
        return
            keccak256(abi.encodePacked(str1)) ==
            keccak256(abi.encodePacked(str2));
    }

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
     
    // @audit-check // Here I am chceking that only same soulmate can read.This proves that only same soulmate can read .
    function test_checkfornftWriteAndReadSharedSpace() public {
        uint tokenIdMinted = 0;

        vm.prank(soulmate1);
        soulmateContract.mintSoulmateToken();

        assertTrue(soulmateContract.totalSupply() == 0);

        vm.prank(soulmate2);
        soulmateContract.mintSoulmateToken();

        assertTrue(soulmateContract.totalSupply() == 1);
        assertTrue(soulmateContract.soulmateOf(soulmate1) == soulmate2);
        assertTrue(soulmateContract.soulmateOf(soulmate2) == soulmate1);
        assertTrue(soulmateContract.ownerToId(soulmate1) == tokenIdMinted);
        console2.log(tokenIdMinted);
        assertTrue(soulmateContract.ownerToId(soulmate2) == tokenIdMinted);
        console2.log(tokenIdMinted);
        
        vm.prank(attacker);
        soulmateContract.mintSoulmateToken();

        // assertTrue(soulmateContract.totalSupply() == 0);

        vm.prank(attacker1);
        soulmateContract.mintSoulmateToken();

        // assertTrue(soulmateContract.totalSupply() == 1);
        // assertTrue(soulmateContract.soulmateOf(soulmate1) == soulmate2);
        // assertTrue(soulmateContract.soulmateOf(soulmate2) == soulmate1);
        assertTrue(soulmateContract.ownerToId(attacker) == 1);
        console2.log(tokenIdMinted);
        assertTrue(soulmateContract.ownerToId(attacker1) == 1);
        console2.log(tokenIdMinted);
        vm.prank(address(1));
        soulmateContract.mintSoulmateToken();

        // assertTrue(soulmateContract.totalSupply() == 0);

        vm.prank(address(2));
        soulmateContract.mintSoulmateToken();

        // assertTrue(soulmateContract.totalSupply() == 1);
        // assertTrue(soulmateContract.soulmateOf(soulmate1) == soulmate2);
        // assertTrue(soulmateContract.soulmateOf(soulmate2) == soulmate1);
        assertTrue(soulmateContract.ownerToId(address(1)) == 2);
        console2.log(tokenIdMinted);
        assertTrue(soulmateContract.ownerToId(address(2)) == 2);
        console2.log(tokenIdMinted);
    

        vm.prank(soulmate1);
        soulmateContract.writeMessageInSharedSpace("Buy some eggs");
        vm.prank(attacker);
       
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
    

    // @audit - POC // This is the test case which proves that anyone who have not soulmates can read and write  in shared space.
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
  
    //@audit-recommendation check for my recommendation//This is for my confirmation that my recommendation is right.
    function test_writemessagerevertforsinglepeople() public {
        vm.prank(address(1));
        vm.expectRevert();
        soulmateContract.writeMessageInSharedSpace("Buy some eggs");
        }
   
    // @audit - test 
    function test_afterdivorceWriteAndReadSharedSpace() public {
        vm.prank(attacker);
        soulmateContract.writeMessageInSharedSpace("Buy some eggs");
        // soulmateContract.getDivorced();      
        vm.prank(attacker1);
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

}
