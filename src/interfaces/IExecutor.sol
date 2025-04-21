// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.25;

import {Operation} from "src/Types.sol";

interface IExecutor {
    /// EVENTS ///

    /// @notice Emitted when operations are executed.
    event Executed(address indexed caller, Operation operation);

    /// ERRORS ///

    /// @notice Error emitted when the execution of an operation fails.
    error AeraPeriphery__ExecutionFailed(bytes result);

    /// FUNCTIONS ///

    /// @notice Execute arbitrary actions.
    /// @param operations The operations to execute.
    function execute(Operation[] calldata operations) external;
}
