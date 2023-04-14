// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


 
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ManagerFacet} from "../../../src/dollar/facets/ManagerFacet.sol";
import {UbiquityDollarToken} from "../../../src/dollar/core/UbiquityDollarToken.sol";
// import {CreditNftRedemptionCalculatorFacet} from "../../../src/dollar/facets/CreditNftRedemptionCalculatorFacet.sol";
import {TWAPOracleDollar3poolFacet} from "../../../src/dollar/facets/TWAPOracleDollar3poolFacet.sol";
// import {CreditNft} from "../../../src/dollar/core/CreditNft.sol";
// import {MockCreditNft} from "../../../src/dollar/mocks/MockCreditNft.sol";



import {CurveDollarIncentiveFacet} from "../../../src/dollar/facets/CurveDollarIncentiveFacet.sol";
import {IMetaPool} from "../../../src/dollar/interfaces/IMetaPool.sol";
import {MockMetaPool} from "../../../src/dollar/mocks/MockMetaPool.sol";
import "../DiamondTestSetup.sol";
import {IERC20Ubiquity} from "../../../src/dollar/interfaces/IERC20Ubiquity.sol";
import {ICurveFactory} from "../../../src/dollar/interfaces/ICurveFactory.sol";
import "forge-std/Test.sol";


contract CurveDollarIncentiveTest is DiamondSetup {
    address stableSwapMetaPoolAddress = address(0x123);
    address secondAccount = address(0x4);
    address thirdAccount = address(0x5);
    address mockReceiver = address(0x111);
    address mockSender = address(0x222);

    event ExemptAddressUpdate(address indexed _account, bool _isExempt);

    function setUp() public override {
        super.setUp();
    }

    function mockInternalFuncs(uint256 _twapPrice) public {
        address twapOracleAddress = IManager.twapOracleAddress();

        vm.mockCall(
            twapOracleAddress,
            abi.encodeWithSelector(TWAPOracleDollar3poolFacet.update.selector),
            abi.encode()
        );
        vm.mockCall(
            twapOracleAddress,
            abi.encodeWithSelector(TWAPOracleDollar3poolFacet.consult.selector),
            abi.encode(_twapPrice)
        );
    }

    function testIncentivizeShouldRevertWhenCallerNotUAD() public {
        vm.expectRevert("CurveIncentive: Caller is not Ubiquity Dollar");
        ICurveDollarIncentiveFacet.incentivize(
            address(0x111),
            address(0x112),
            secondAccount,
            100
        );
    }

    function testIncentivizeShouldRevertIfSenderEqualToReceiver() public {
        vm.startPrank(admin);
        vm.expectRevert("CurveIncentive: Caller is not Ubiquity Dollar");
        ICurveDollarIncentiveFacet.incentivize(
            address(0x111),
            address(0x111),
            admin,
            100
        );
    }

    function testIncentivizeBuy() public {
        vm.startPrank(admin);

        IAccessCtrl.grantRole(GOVERNANCE_TOKEN_MANAGER_ROLE, admin);
        address stableSwapPoolAddress =  IManager.stableSwapMetaPoolAddress();
        IERC20 governanceToken = IERC20(IManager.governanceTokenAddress());
        address dollarAddress = IManager.dollarTokenAddress();
        IAccessCtrl.grantRole(DOLLAR_MANAGER_ROLE, secondAccount);
        
        
        // 1. do nothing if the target address is included to exempt list
        uint256 init_balance = governanceToken.balanceOf(mockReceiver);

        ICurveDollarIncentiveFacet.setExemptAddress(
            mockReceiver,
            true
        );
        vm.stopPrank();

        // vm.prank(secondAccount);
        // ICurveDollarIncentiveFacet.incentivize(
        //     stableSwapPoolAddress,
        //     mockReceiver,
        //     address(0),
        //     100e18
        // );

        uint256 last_balance = governanceToken.balanceOf(mockReceiver);
        assertEq(last_balance, init_balance);

        // 2. do nothing if buyIncentive is off
        init_balance = governanceToken.balanceOf(mockReceiver);
        vm.startPrank(admin);
        ICurveDollarIncentiveFacet.setExemptAddress(
            mockReceiver,
            false
        );
        ICurveDollarIncentiveFacet.switchBuyIncentive();
        vm.stopPrank();

        // vm.prank(dollarAddress);
        // CurveDollarIncentive(curveIncentiveAddress).incentivize(
        //     stableSwapPoolAddress,
        //     mockReceiver,
        //     address(0),
        //     100e18
        // );

        // last_balance = governanceToken.balanceOf(mockReceiver);
        // assertEq(last_balance, init_balance);

        // // 3. do nothing if no incentive
        // mockInternalFuncs(1e18);
        // init_balance = governanceToken.balanceOf(mockReceiver);
        // vm.startPrank(admin);
        // CurveDollarIncentive(curveIncentiveAddress).setExemptAddress(
        //     mockReceiver,
        //     false
        // );
        // CurveDollarIncentive(curveIncentiveAddress).switchBuyIncentive();
        // vm.stopPrank();

        // vm.prank(dollarAddress);
        // CurveDollarIncentive(curveIncentiveAddress).incentivize(
        //     stableSwapPoolAddress,
        //     mockReceiver,
        //     address(0),
        //     100e18
        // );

        // last_balance = governanceToken.balanceOf(mockReceiver);
        // assertEq(last_balance, init_balance);

        // // 4. mint the incentive amount of tokens to the target address
        // init_balance = governanceToken.balanceOf(mockReceiver);
        // mockInternalFuncs(5e17);
        // vm.prank(admin);
        // manager.grantRole(
        //     keccak256("GOVERNANCE_TOKEN_MINTER_ROLE"),
        //     curveIncentiveAddress
        // );
        // vm.prank(dollarAddress);
        // CurveDollarIncentive(curveIncentiveAddress).incentivize(
        //     stableSwapPoolAddress,
        //     mockReceiver,
        //     address(0),
        //     100e18
        // );

        // last_balance = governanceToken.balanceOf(mockReceiver);
        // assertEq(last_balance - init_balance, 50e18);
    }

    function testIncentivizeSell() public {
        address stableSwapPoolAddress =  IManager.stableSwapMetaPoolAddress();
        IERC20 governanceToken = IERC20(IManager.governanceTokenAddress());
        address dollarAddress = IManager.dollarTokenAddress();
        IERC20 dollarToken = IERC20(dollarAddress);

        // 1. do nothing if the target address is included to exempt list
        uint256 init_balance = dollarToken.balanceOf(mockSender);
        vm.prank(admin);
        ICurveDollarIncentiveFacet.setExemptAddress(
            mockSender,
            true
        );

        vm.startPrank(admin);
        address dollarTokenAddress = address(
            new UbiquityDollarToken(address(diamond))
        );
        // address dollarAddress = IManager.dollarTokenAddress();
        IAccessCtrl.grantRole(DOLLAR_MANAGER_ROLE, dollarAddress);
        vm.stopPrank();

        vm.prank(dollarTokenAddress);
        // ICurveDollarIncentiveFacet.incentivize(
        //     mockSender,
        //     stableSwapPoolAddress,
        //     address(0),
        //     100e18
        // );

        uint256 last_balance = dollarToken.balanceOf(mockSender);
        assertEq(last_balance, init_balance);

        // 2. do nothing if buyIncentive is off
        init_balance = dollarToken.balanceOf(mockSender);
        vm.startPrank(admin);
        ICurveDollarIncentiveFacet.setExemptAddress(
            mockSender,
            false
        );
        ICurveDollarIncentiveFacet.switchSellPenalty();
        vm.stopPrank();

        vm.prank(dollarAddress);
        // ICurveDollarIncentiveFacet.incentivize(
        //     mockSender,
        //     stableSwapPoolAddress,
        //     address(0),
        //     100e18
        // );

        // last_balance = dollarToken.balanceOf(mockSender);
        // assertEq(last_balance, init_balance);

        // // 3. do nothing if no penalty
        // mockInternalFuncs(1e18);
        // init_balance = dollarToken.balanceOf(mockSender);
        // vm.startPrank(admin);
        // CurveDollarIncentive(curveIncentiveAddress).setExemptAddress(
        //     mockSender,
        //     false
        // );
        // CurveDollarIncentive(curveIncentiveAddress).switchSellPenalty();
        // vm.stopPrank();

        // vm.prank(dollarAddress);
        // CurveDollarIncentive(curveIncentiveAddress).incentivize(
        //     mockSender,
        //     stableSwapPoolAddress,
        //     address(0),
        //     100e18
        // );

        // last_balance = dollarToken.balanceOf(mockSender);
        // assertEq(last_balance, init_balance);

        // // 4. burn the penalty amount of tokens from the target address
        // vm.prank(admin);
        // UbiquityDollarToken(dollarAddress).mint(mockSender, 10000e18);
        // init_balance = dollarToken.balanceOf(mockSender);
        // assertEq(init_balance, 10000e18);
        // mockInternalFuncs(5e17);
        // vm.prank(dollarAddress);
        // CurveDollarIncentive(curveIncentiveAddress).incentivize(
        //     mockSender,
        //     stableSwapPoolAddress,
        //     address(0),
        //     100e18
        // );

        // last_balance = dollarToken.balanceOf(mockSender);
        // assertEq(init_balance - last_balance, 50e18);
    }

    function testSetExemptAddress_ShouldRevertOrSet_IfAdmin() public {
        address exemptAddress = address(0x123);
        vm.expectRevert("Manager: Caller is not admin");
        ICurveDollarIncentiveFacet.setExemptAddress(
            exemptAddress,
            true
        );

        assertEq(
            ICurveDollarIncentiveFacet.isExemptAddress(
                exemptAddress
            ),
            false
        );
        vm.prank(admin);
        vm.expectEmit(true, true, false, true);
        emit ExemptAddressUpdate(exemptAddress, true);
        ICurveDollarIncentiveFacet.setExemptAddress(
            exemptAddress,
            true
        );
        assertEq(
            ICurveDollarIncentiveFacet.isExemptAddress(
                exemptAddress
            ),
            true
        );
    }

    function testSwitchSellPenalty_ShouldRevertOrSwitch_IfAdmin() public {
        vm.expectRevert("Manager: Caller is not admin");
        ICurveDollarIncentiveFacet.switchSellPenalty();

        assertEq(
            ICurveDollarIncentiveFacet.isSellPenaltyOn(),
            false
        );
        vm.prank(admin);
        ICurveDollarIncentiveFacet.switchSellPenalty();
        assertEq(
            ICurveDollarIncentiveFacet.isSellPenaltyOn(),
            true
        );
    }

    function testSwitchBuyIncentive_ShouldRevertOrSwitch_IfAdmin() public {
        vm.expectRevert("Manager: Caller is not admin");
        ICurveDollarIncentiveFacet.switchBuyIncentive();

        assertEq(
            ICurveDollarIncentiveFacet.isBuyIncentiveOn(),
            false
        );
        vm.prank(admin);
        ICurveDollarIncentiveFacet.switchBuyIncentive();
        assertEq(
            ICurveDollarIncentiveFacet.isBuyIncentiveOn(),
            true
        );
    }
}