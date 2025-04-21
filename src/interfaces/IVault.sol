// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

/// @title IVault
/// @notice Interface for the vault.
interface IVault {
    /// @notice Returns the wrapped native token address.
    function wrappedNativeToken() external view returns (address);
}
