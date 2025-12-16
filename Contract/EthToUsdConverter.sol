// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library EthPriceFeed {

    function getEthPrice() internal view returns (int256) {
        // instance
        AggregatorV3Interface  ethUSDInstance = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
                );

        (, int256 price,,,) = ethUSDInstance.latestRoundData();
        return price;
    }

    function getConvertionRate(uint256 ethAmt)  internal view returns(uint){
        uint ethPrice = uint(getEthPrice()) * 1e10; // of total 18 decimals now
        uint rate = (ethPrice * ethAmt) / 1e18; // as ethAmt is 1e18 and ethPrice is 1e18 

        return rate;
    }
}
