// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.25;

import {AbstractBalanceOracle} from "src/AbstractBalanceOracle.sol";
import {IElixirOracle} from "src/interfaces/IElixirOracle.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {Executor} from "src/Executor.sol";
import {Operation} from "src/Types.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";

/// @title ElixirOracle
/// @notice Oracle to wrap deUSD for minting and redeeming through API
contract ElixirOracle is IElixirOracle, AbstractBalanceOracle, Executor {
    /// ERRORS ///
    error AeraPeriphery__deusdAddressIsZeroAddress();
    error AeraPeriphery__deusdMintingContractAddressIsZeroAddress();
    error AeraPeriphery__CallerIsNotVault();
    error AeraPeriphery__CallerIsNotVaultOwner();

    /// @notice The name of the token.
    string private constant _NAME = "Elixir deUSD Oracle";

    /// @notice The symbol of the token.
    string private constant _SYMBOL = "AdeUSD";

    /// @notice The number of decimals of the token.
    uint8 private immutable _DECIMALS;

    /// @dev The deUSD Token.
    IERC20 internal immutable _deusd;

    /// @notice The address of the deUSD minting contract
    address internal immutable _mintingContract;

    /// @notice Constructor for the ElixirOracle contract.
    /// @param vaultAddress Address of the AeraVaultV2 contract.
    /// @param deusdAddress Address of deUSD token.
    /// @param mintingContractAddress Address of deUSD minting contract.
    constructor(address vaultAddress, address deusdAddress, address mintingContractAddress)
        AbstractBalanceOracle(vaultAddress)
    {
        // Requirements: check the market address is not zero.
        if (deusdAddress == address(0)) {
            revert AeraPeriphery__deusdAddressIsZeroAddress();
        }

        if (mintingContractAddress == address(0)) {
            revert AeraPeriphery__deusdMintingContractAddressIsZeroAddress();
        }

        _deusd = IERC20(deusdAddress);
        _mintingContract = mintingContractAddress;

        // Effects: set the decimals.
        _DECIMALS = 18;
    }

    /// MODIFIERS ///

    /// @notice Check that the caller is the vault.
    modifier onlyVault() {
        if (msg.sender != _vault) {
            revert AeraPeriphery__CallerIsNotVault();
        }
        _;
    }

    /// @notice Check that the caller is the Vault owner.
    modifier onlyVaultOwner() {
        // Requirements: check that the caller is the Vault owner.
        if (msg.sender != Ownable(_vault).owner()) {
            revert AeraPeriphery__CallerIsNotVaultOwner();
        }
        _;
    }

    /// FUNCTIONS ///

    /// @inheritdoc IElixirOracle
    function transferAndApprove(uint256 amount) external onlyVault {
        _deusd.transferFrom(_vault, address(this), amount);
        _deusd.approve(_mintingContract, amount);
    }

    /// @inheritdoc AbstractBalanceOracle
    function decimals() external view override returns (uint8) {
        return _DECIMALS;
    }

    /// @inheritdoc AbstractBalanceOracle
    function name() external pure override returns (string memory) {
        return _NAME;
    }

    /// @inheritdoc AbstractBalanceOracle
    function symbol() external pure override returns (string memory) {
        return _SYMBOL;
    }

    /// @notice Calculate the value of deUSD held by the vault.
    /// @return balance The amount of underlying tokens that could be received
    function _getBalance() internal view override returns (uint256 balance) {
        balance = _deusd.balanceOf(address(this));
    }

    /// INTERNAL FUNCTIONS ///

    /// @inheritdoc Executor
    function _checkOperations(Operation[] calldata operations) internal view override onlyVaultOwner {}

    /// @inheritdoc Executor
    function _checkOperation(Operation calldata operation) internal view override {}
}
