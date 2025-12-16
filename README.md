# FundMe Smart Contract

A decentralized crowdfunding application built on Ethereum.

![Contract Balance](path/to/your/image.png)
*(Above: Proof of contract holding 0.2 ETH on the testnet)*

## Overview

This project is a Solidity-based smart contract that allows users to fund the contract with ETH. It leverages Chainlink Data Feeds to enforce a minimum funding amount denominated in USD (e.g., $5 USD). Only the contract owner can withdraw the accumulated funds, and the contract employs security best practices to prevent vulnerabilities.

## Key Features

* **Real-time Price Conversion:** Uses Chainlink Oracles to convert ETH to USD dynamically.
* **Minimum Funding Threshold:** Enforces a minimum contribution of **$5 USD**.
* **Owner-Only Withdrawal:** Protected by a custom modifier ensuring only the deployer can withdraw funds.
* **Gas Optimizations:** Uses `immutable` variables and `constant` keywords to save gas.
* **Security Standard:** Follows the **Checks-Effects-Interactions (CEI)** pattern to prevent reentrancy attacks.
* **Fallback Support:** Automatically routes direct payments (without data) to the fund function.

## Tech Stack

* **Language:** Solidity `^0.8.26`
* **Oracle:** Chainlink Aggregator V3 Interface
* **Network:** Sepolia Testnet (Address used: `0x694...`)

---

## Contract Architecture

### 1. EthToUsdConverter.sol (Library)

This library handles the mathematical calculations.

* **getEthPrice():** Connects to the Chainlink Aggregator on the Sepolia network to fetch the current price of ETH in USD.
* **getConvertionRate(ethAmt):**
    * Fetches the price (which returns with 8 decimals).
    * Multiplies by `1e10` to match standard Wei precision (18 decimals).
    * Calculates the USD value of the sent ETH to check against the minimum requirement.

### 2. FundMe.sol (Main Contract)

The core logic for funding and withdrawing.

#### Funding Logic
When a user calls `fund()`:
1.  **Validation:** The contract checks if `msg.value` (in USD) is greater than the `MinValue` ($5).
2.  **Tracking:**
    * If the user is new, their address is pushed to the `arr` array.
    * The amount sent is added to their balance in the `AddressToFund` mapping.

#### Withdrawal Logic
When the owner calls `Withdraw()`:
1.  **Authentication:** The `IsOwner` modifier verifies the caller is the `i_Owner`.
2.  **Effects (State Reset):**
    * Iterates through the funder array and resets every mapping balance to 0.
    * Deletes the funder array to clear history.
3.  **Interaction:**
    * Uses the low-level `.call` function to transfer the entire contract balance to the owner.
    * This is the recommended method for sending Ether over `.transfer` or `.send`.

---

## Security and Error Handling

### Checks-Effects-Interactions (CEI) Pattern

The `Withdraw` function is designed to prevent Reentrancy Attacks.

1.  **Checks:** Verifies ownership.
2.  **Effects:** Resets the `AddressToFund` mapping and deletes the `arr` **before** transferring money.
3.  **Interactions:** Sends the ETH only after the internal state is updated.

```solidity
// Resetting state first (Effects)
for(uint i=0; i<arr.length; i++) {
    AddressToFund[arr[i]] = 0;
}
delete arr;

// Interaction comes last
(bool isSuccess, )= payable(msg.sender).call{value : address(this).balance}("");
```



## Custom Errors

Instead of expensive string requirement messages, this contract uses custom errors to save gas on deployment and reverts.

* `error NotOwner();` - Thrown if a stranger tries to withdraw funds.

---

## How to Run

### Prerequisites

* Metamask installed.
* Testnet ETH (Sepolia) for gas fees.
* Remix IDE or a local Hardhat setup.

### Deployment Steps

1.  Copy the code into **Remix IDE**.
2.  Compile `FundMe.sol` using compiler version `0.8.26` or higher.
3.  Select **Injected Provider - MetaMask** in the "Deploy & Run" tab.
4.  Deploy the contract.
5.  **Fund:** Enter an ETH amount (e.g., 0.1 ETH) in the Value box and click `fund`.
6.  **Withdraw:** Switch to the owner account in Metamask and click `Withdraw`.

---

## Testing Results

The contract has been manually tested on the Sepolia Testnet.

* **Funding:** Successfully rejects values under $5 USD.
* **Data Feeds:** Correctly pulls live ETH prices.
* **Withdrawal:** Only the specific owner address was able to drain the funds; others were reverted with `NotOwner`.
* **Balance:** As seen in the screenshot above, the contract successfully holds and tracks ETH balances.

## License

This project is licensed under the MIT License.
