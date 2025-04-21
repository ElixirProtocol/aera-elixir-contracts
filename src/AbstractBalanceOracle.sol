// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {IVault} from "src/interfaces/IVault.sol";

abstract contract AbstractBalanceOracle {
    /// IMMUTABLES ///

    /// @dev Vault address.
    address internal immutable _vault;

    /// ERRORS ///

    /// @notice Thrown when the vault address is zero.
    error AeraPeriphery__VaultIsZeroAddress();
    /// @notice Thrown when the vault address is zero.
    error AeraPeriphery__InvalidAeraVaultAddress();
    /// @notice Thrown when a user tries to transfer tokens.
    error AeraPeriphery__TransfersAreNotAllowed();
    /// @notice Thrown when a user tries to approve.
    error AeraPeriphery__ApprovalsAreNotAllowed();

    /// FUNCTIONS ///

    /// @notice Constructor for the AbstractBalanceOracle contract.
    /// @param vaultAddress The address of the AeraVaultV2 contract.
    constructor(address vaultAddress) {
        // Requirements: check the vault address is not zero.
        if (vaultAddress == address(0)) {
            revert AeraPeriphery__VaultIsZeroAddress();
        }

        // Requirements: check the vault has a `wrappedNativeToken()` method
        //              that returns an address.
        address wrappedNativeToken = IVault(vaultAddress).wrappedNativeToken();
        if (wrappedNativeToken == address(0)) {
            revert AeraPeriphery__InvalidAeraVaultAddress();
        }

        // Effects: set the vault address.
        _vault = vaultAddress;
    }

    /// @notice Because this contract is oracle and ERC20 token at the same time,
    ///         this function represent decimals for oracle price and token decimals.
    /// @return decimals The number of decimals.
    function decimals() external view virtual returns (uint8);

    /// @notice Name of ERC20 token.
    function name() external pure virtual returns (string memory);

    /// @notice Symbol of ERC20 token.
    function symbol() external pure virtual returns (string memory);

    /// @dev Returns the amount of tokens in existence.
    function totalSupply() external view returns (uint256) {
        return _getBalance();
    }

    /// @dev Returns the amount of tokens owned by `account`.
    function balanceOf(address account) external view virtual returns (uint256) {
        return _getBalance();
    }

    /// @dev Returns the address of the vault this oracle was deployed for.
    function vault() external view returns (address) {
        return _vault;
    }

    /// @dev When called by the vault, this function burns
    ///      the token and makes this token unusable.
    function transfer(address, uint256) external returns (bool) {
        revert AeraPeriphery__TransfersAreNotAllowed();
    }

    /// @notice Transfers aren't allowed.
    function transferFrom(address, address, uint256) external pure returns (bool) {
        revert AeraPeriphery__TransfersAreNotAllowed();
    }

    /// @notice Approvals aren't allowed.
    function approve(address, uint256) external pure returns (bool) {
        revert AeraPeriphery__ApprovalsAreNotAllowed();
    }

    /// @dev Compute the total balance that this position represents.
    function _getBalance() internal view virtual returns (uint256 balance);
}
