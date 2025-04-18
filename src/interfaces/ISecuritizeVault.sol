/**
 * Copyright 2024 Securitize Inc. All rights reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
pragma solidity ^0.8.20;

interface ISecuritizeVault {
    // Events
    event LiquidationOpenToPublic(address indexed sender, bool open);
    event OperatorAdded(address indexed operator);
    event OperatorRevoked(address indexed operator);
    event LiquidatorAdded(address indexed liquidator);
    event LiquidatorRevoked(address indexed liquidator);
    event Liquidate(address indexed sender, uint256 assets, uint256 shares);
    event AdminChanged(address indexed admin);

    error LiquidationNotOpenToPublic();
    error NotEnoughShares();
    error InsufficientOutputAmount();

    /**
     * @dev Initializes the vault with necessary parameters and roles.
     * Sets up the ERC4626 and ERC20 tokens, access control, and initializes the base contract.
     * Grants the DEFAULT_ADMIN_ROLE to the message sender.
     *
     * @param _name Name of the ERC20 token.
     * @param _symbol Symbol of the ERC20 token.
     * @param _securitizeToken Address of the ERC20 token to be used as the asset.
     * @param _redemptionAddress Address of the redemption contract.
     * @param _liquidationToken Address of the token to be used for liquidation.
     * @param _navProvider Nav Provider Address.
     */
    function initialize(
        string memory _name,
        string memory _symbol,
        address _securitizeToken,
        address _redemptionAddress,
        address _liquidationToken,
        address _navProvider
    ) external;

    /**
     * @dev Changes the admin of the vault.
     * Can only be called by an account with the DEFAULT_ADMIN_ROLE.
     *
     * @param _newAdmin The address of the new admin.
     */
    function changeAdmin(address _newAdmin) external;

    /**
     * @dev Checks if an account has the admin role.
     *
     * @param _account The address to check for the admin role.
     * @return bool Returns true if the account has the admin role, false otherwise.
     */
    function isAdmin(address _account) external view returns (bool);

    /**
     * @dev Grants the Operator role to an account. Emits a OperatorAdded event.
     *
     * @param _account The address to which the Operator role will be granted.
     */
    function addOperator(address _account) external;

    /**
     * @dev Revokes the Operator role from an account. Emits a OperatorRevoked event.
     *
     * @param _account The address from which the Operator role will be revoked.
     */
    function revokeOperator(address _account) external;

    /**
     * @dev Checks if an account has the Operator role.
     *
     * @param _account The address to check for the Operator role.
     * @return bool Returns true if the account has the Operator role, false otherwise.
     */
    function isOperator(address _account) external view returns (bool);

    /**
     * @dev Grants the Liquidator role to an account. Emits a LiquidatorAdded event.
     *
     * @param _account The address to which the Liquidator role will be granted.
     */
    function addLiquidator(address _account) external;

    /**
     * @dev Revokes the Liquidator role from an account. Emits a LiquidatorRevoked event.
     *
     * @param _account The address from which the Liquidator role will be revoked.
     */
    function revokeLiquidator(address _account) external;

    /**
     * @dev Checks if an account has the Liquidator role.
     *
     * @param _account The address to check for the Liquidator role.
     * @return bool Returns true if the account has the Liquidator role, false otherwise.
     */
    function isLiquidator(address _account) external view returns (bool);

    /**
     * @dev Sets the liquidation process to be open to the public or not.
     * Can only be called by an account with the DEFAULT_ADMIN_ROLE.
     * Emits a LiquidationOpenToPublic event.
     *
     * @param _open Boolean indicating whether the liquidation is open to the public.
     */
    function setLiquidationOpenToPublic(bool _open) external;

    /**
     * @dev Deposits tokens into the vault.
     *
     * @param assets The amount of tokens to deposit.
     * @param receiver The address to receive the tokens, must be the same as the sender.
     * @return uint256 Returns the number of shares minted.
     */
    function deposit(uint256 assets, address receiver) external returns (uint256);

    /**
     * @dev redeem tokens from the vault.
     *
     * @param shares The amount of shares to redeem
     * @param receiver The address to receive the tokens must be same as sender
     * @param _owner The address of the owner of the shares must be the same as the sender
     * @return uint256 Returns the number of redeemed assets.
     */
    function redeem(uint256 shares, address receiver, address _owner) external returns (uint256);

    /**
     * @dev Liquidates shares from the vault by calling the redemption contract and burning the shares.
     * This function must be callable by accounts with the LIQUIDATOR_ROLE when liquidation is not open to the public.
     * It converts the shares to assets, burns the shares from the caller's balance, and transfers the equivalent assets.
     *
     * Emits a Liquidate event upon successful liquidation.
     *
     * Requirements:
     * - The contract must not be paused.
     * - Caller must have sufficient shares to liquidate.
     * - Liquidation must be open to the public or the caller must have the LIQUIDATOR_ROLE.
     *
     * @param shares The amount of shares to liquidate.
     */
    function liquidate(uint256 shares) external;

    /**
     * @dev same as liquidate(uint256 shares) but liquidator also sends a minimum
     * amount of assets that they are willing to receive (slippage protection)
     * It is important to notice that the amount is expressed in assets (not liquidity token)
     * If the Vault is configured to send stable coin instead of assets then the liquidator should calculate the amount
     *
     * @param shares The amount of shares to liquidate.
     * @param minOutputAmount Minimum amount of assets
     */
    function liquidate(uint256 shares, uint256 minOutputAmount) external;

    /**
     * @dev returns how much value per share can be liquidated
     * @return share value in $
     */
    function getShareValue() external view returns (uint256);
}
