# IDollarAmoMinter
[Git Source](https://github.com/ubiquity/ubiquity-dollar/blob/447ec1d83d6aa0044c753bd31ba3571a47b64509/src/dollar/interfaces/IDollarAmoMinter.sol)

AMO minter interface

*AMO minter can borrow collateral from the Ubiquity Pool to make some yield*


## Functions
### collateralDollarBalance

Returns collateral Dollar balance


```solidity
function collateralDollarBalance() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Collateral Dollar balance|


### collateralIndex

Returns collateral index (from the Ubiquity Pool) for which AMO minter is responsible


```solidity
function collateralIndex() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Collateral token index|


