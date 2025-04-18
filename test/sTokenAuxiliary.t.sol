// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {sTokenAuxiliary} from "src/sTokenAuxiliary.sol";
import {ERC1967Proxy} from "openzeppelin/proxy/ERC1967/ERC1967Proxy.sol";

contract sTokenAuxiliaryTest is Test {
    sTokenAuxiliary auxiliary;

    address public owner;
    address public sToken;
    address public mintingContract;

    function setUp() public {
        owner = vm.addr(0xA11CE);
        sToken = vm.addr(0x0001);
        mintingContract = vm.addr(0x0002);

        auxiliary = sTokenAuxiliary(
            address(
                new ERC1967Proxy(
                    address(new sTokenAuxiliary()),
                    abi.encodeWithSignature(
                        "initialize(address,address,address,string,string)",
                        sToken,
                        owner,
                        mintingContract,
                        "wsTOKEN",
                        "wsTOKEN"
                    )
                )
            )
        );
    }

    function testDefault() public {}
}
