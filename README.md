 Token Faucet — A Decentralized STX Faucet Smart Contract on Stacks

 Overview
The **Token Faucet** smart contract allows users to claim a fixed amount of **STX tokens** once every 24 hours.  
It’s designed to simulate a simple and secure faucet system built with **Clarity** and **Clarinet** on the **Stacks blockchain**.

This project demonstrates how to:
- Manage contract ownership.
- Send and receive STX transfers programmatically.
- Limit user access based on time.
- Track on-chain balances and claim history.

---

 Features

-  **Daily STX Claim System** — Each user can claim tokens once every 24 hours.  
-  **Owner Controls** — The contract owner can:
  - Refill the faucet.
  - Adjust the daily reward amount.
  - Withdraw remaining balance.
  - Transfer contract ownership.
-  **Time Restriction** — Prevents users from claiming again within 24 hours.  
-  **Safe Transfers** — All STX movements are validated with error handling.  
-  **Clarinet Ready** — Works perfectly with `clarinet check` and `clarinet console`.

---

 Smart Contract Details

**Contract Name:** `token-faucet`  
**Language:** Clarity  
**Framework:** Clarinet  
**Network:** Stacks Blockchain  

---

 Core Functions

| Function | Type | Description |
|-----------|------|-------------|
| `refill (amount uint)` | Public | Owner deposits STX into the faucet. |
| `set-reward (new-amount uint)` | Public | Owner updates the daily claim reward. |
| `claim` | Public | Users claim STX (only once every 24 hours). |
| `withdraw (amount uint)` | Public | Owner withdraws remaining STX from faucet. |
| `transfer-ownership (new-owner principal)` | Public | Owner changes contract ownership. |
| `get-faucet-balance` | Read-only | Returns faucet’s current STX balance. |
| `get-reward-amount` | Read-only | Shows how much each claim rewards. |
| `get-last-claim (user principal)` | Read-only | Displays when a user last claimed tokens. |
| `get-owner` | Read-only | Returns the current owner principal. |

---

Getting Started

Clone the Repository
```bash
git clone https://github.com/your-username/token-faucet.git
cd token-faucet
