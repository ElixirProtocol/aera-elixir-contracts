// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.25;

/// @title IDelegateSigner
/// @notice Used to delegate signer to EOA or multisig
interface IDelegateSigner {
    /// @notice Enables smart contracts to delegate an address for signing
    function setDelegatedSigner(address _delegateTo) external;

    /// @notice The delegated address to confirm delegation
    function confirmDelegatedSigner(address _delegatedBy) external;

    /// @notice Enables smart contracts to undelegate an address for signing
    function removeDelegatedSigner(address _removedSigner) external;
}
