// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ERC1967Proxy} from "openzeppelin/proxy/ERC1967/ERC1967Proxy.sol";

import {ElixirOracle} from "src/ElixirOracle.sol";

contract ElixirOracleTest is Test {
    ElixirOracle elixirOracle;

    address public owner;
    address public vaultAddress;
    address public deusdAddress;
    address public mintingContract;

    function setUp() public {
        owner = vm.addr(0xA11CE);
        vaultAddress = vm.addr(0x0001);
        deusdAddress = vm.addr(0x0002);
        mintingContract = vm.addr(0x0003);

        elixirOracle = new ElixirOracle(vaultAddress, deusdAddress, mintingContract);
    }

    function testDefault() public {}
}
