// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {OurToken} from "../src/OurToken.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";

interface MintableToken {
    function mint(address, uint256) external;
}

contract OurTokenTestTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        vm.prank(msg.sender);
        ourToken.transfer(bob, STARTING_BALANCE);
    }

    function testBobBalance() public {
        assertEq(STARTING_BALANCE, ourToken.balanceOf(bob));
    }

    function testAllowancesWorks() public {
        uint256 initialAllowance = 1000;

        // Bob approves alice to spend tokens on her behalf
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);

        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    function testInitialSupply() public {
        assertEq(ourToken.totalSupply(), deployer.INITIAL_SUPPLY());
    }

    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(ourToken)).mint(address(this), 1);
    }

    function testTransfer() public {
        uint256 transferAmount = 100;
        address receiver = address(0x1);
        uint256 initialBalance = ourToken.balanceOf(msg.sender);

        vm.prank(msg.sender);
        ourToken.transfer(receiver, transferAmount);

        assertEq(
            ourToken.balanceOf(msg.sender),
            initialBalance - transferAmount
        );
    }

    function testTransferFrom() public {
        // address owner = address(msg.sender);
        address spender = address(0x1);
        uint256 amount = 100;

        vm.prank(msg.sender);
        ourToken.approve(address(this), amount);

        ourToken.transferFrom(msg.sender, spender, amount);
        console.log(ourToken.balanceOf(spender));

        assertEq(ourToken.balanceOf(spender), amount);
    }

    function testIncreaseAllowance() public {
        address spender = address(0x1);
        uint256 initialApproval = ourToken.allowance(address(this), spender);
        uint256 increaseAmount = 50;

        ourToken.increaseAllowance(spender, increaseAmount);

        assertEq(
            ourToken.allowance(address(this), spender),
            initialApproval + increaseAmount
        );
    }

    function testDecreaseAllowance() public {
        address spender = address(0x1);
        uint256 initialApproval = ourToken.allowance(address(this), spender);
        uint256 decreaseAmount = 30;
        uint256 increaseAmount = 50;

        ourToken.increaseAllowance(spender, increaseAmount);
        ourToken.decreaseAllowance(spender, decreaseAmount);

        assertEq(
            ourToken.allowance(address(this), spender),
            initialApproval + increaseAmount - decreaseAmount
        );
    }
}
