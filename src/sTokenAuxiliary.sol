// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.25;

import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {IAeraV2Oracle} from "src/interfaces/IAeraV2Oracle.sol";
import {IDelegateSigner} from "src/interfaces/IDelegateSigner.sol";
import {SafeCast} from "openzeppelin/utils/math/SafeCast.sol";

import {ERC20Upgradeable} from "openzeppelin-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {ERC4626Upgradeable} from "openzeppelin-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol";
import {SingleAdminAccessControl} from "src/SingleAdminAccessControl.sol";

import {Initializable} from "openzeppelin-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "openzeppelin-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract sTokenAuxiliary is
    Initializable,
    UUPSUpgradeable,
    SingleAdminAccessControl,
    ERC20Upgradeable,
    ERC4626Upgradeable,
    IAeraV2Oracle
{
    using SafeERC20 for IERC20;
    using SafeCast for uint256;

    /*//////////////////////////////////////////////////////////////
                                CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /*//////////////////////////////////////////////////////////////
                                VARIABLES 
    //////////////////////////////////////////////////////////////*/
    address public mintingContract;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @notice Prevent the implementation contract from being initialized.
    /// @dev The proxy contract state will still be able to call this function because the constructor does not affect the proxy state.
    constructor() {
        _disableInitializers();
    }

    /*//////////////////////////////////////////////////////////////
                               INITIALIZER
    //////////////////////////////////////////////////////////////*/

    /// @notice No constructor in upgradable contracts, so initialized with this function.
    /// @param _asset The address of the asset token.
    /// @param _owner The address of the admin role.
    /// @param _mintingContract The address of the minting contract.
    /// @param _name The name of this token
    /// @param _symbol The symbol of this token
    function initialize(
        IERC20 _asset,
        address _owner,
        address _mintingContract,
        string memory _name,
        string memory _symbol
    ) public initializer {
        __UUPSUpgradeable_init();
        __AccessControl_init();

        __ERC20_init(_name, _symbol);
        __ERC4626_init(_asset);

        if (_owner == address(0) || address(_asset) == address(0)) {
            revert InvalidZeroAddress();
        }

        _grantRole(DEFAULT_ADMIN_ROLE, _owner);
        mintingContract = _mintingContract;
    }

    /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Returns the latest price.
    /// @return roundId Optional, doesn't apply to non-Chainlink oracles.
    /// @return answer The price.
    /// @return startedAt Optional, doesn't apply to non-Chainlink oracles.
    /// @return updatedAt The most recent timestamp the price was updated
    /// @return answeredInRound Optional, doesn't apply to non-Chainlink oracles.
    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        roundId = 0;
        answer = totalAssets().toInt256();

        // slither-disable-next-line incorrect-equality
        if (answer == 0) {
            answer = 1; // Avoid zero price, which would break AeraVaultAssetRegistry
        }
        startedAt = 0;
        updatedAt = block.timestamp;
        answeredInRound = 0;
    }

    /*//////////////////////////////////////////////////////////////
                            EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Approve asset to spend
    function approveAsset(uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        IERC20(asset()).approve(mintingContract, amount);
    }

    /// @notice Sets delegated signer on minting contract
    function setDelegatedSigner(address _delegateTo) external onlyRole(DEFAULT_ADMIN_ROLE) {
        IDelegateSigner(mintingContract).setDelegatedSigner(_delegateTo);
    }

    /// @notice Removes delegated signer on minting contract
    function removeDelegatedSigner(address _removedSigner) external onlyRole(DEFAULT_ADMIN_ROLE) {
        IDelegateSigner(mintingContract).removeDelegatedSigner(_removedSigner);
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function decimals() public pure override(ERC4626Upgradeable, ERC20Upgradeable, IAeraV2Oracle) returns (uint8) {
        return 18;
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @dev Upgrades the implementation of the proxy to new address.
    function _authorizeUpgrade(address) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    /// @notice Error emitted when the zero address is given
    error InvalidZeroAddress();
}
