// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.25;

/// @title IElixirOracle
interface IElixirOracle {
    /// @notice Transfers in deUSD from the vault and approves minting contract to spend
    /// @param amount Amount to transfer in and approve
    function transferAndApprove(uint256 amount) external;
}
