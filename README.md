# OTCMaker
An easy-to-use smart contract template that allows people to set on-chain over-the-counter (OTC) deals


## How-To-Use
#### 1. Import to remix
- Copy and paste the code into Remix editor (at http://remix.ethereum.org)

#### 2. Fill the contract details
- Replace the KEYWORDS with the corresponding values (between lines 31 and 49)

#### 3. Compile and Deploy
- Go to the compiler tab and click compile, or press Ctrls-S
- Go to the deploy tab, in the 'environment' menu, select 'Injected Provider'
- In the 'contract' section, select the OTCdealer contract
- Click on 'deploy' and confirm the transaction in the metamask popup (change the fees type, don't use the recommended fees)

#### 4. Use the Contract

You can use the following functions :

- defTokenAddress(address _tokenAddress): This function allows the seller and buyer to define the address of the token they want to trade. If the token address is not yet known, both parties must call this function with the same token address as an argument to set it.

- depositBuyerEscrow(): This function allows the buyer to deposit their escrow payment token into the contract. This payment token is held by the contract until the trade is concluded.

- depositSellerEscrow(): This function allows the seller to deposit their escrow payment token into the contract. This payment token is held by the contract until the trade is concluded.

- cancel(): This function allows either the seller or buyer to cancel the trade if only one of the two participants has deposited their escrow payment token. The participant who has deposited their payment token can redeem their payment token to avoid losing funds.

- concludeTrade(): This function allows the trade to proceed by transferring the traded token from the seller to the buyer and transferring the payment token from the buyer's escrow and seller's escrow to the seller's account. The allowances must be granted beforehand.

- claimExpired(): If the trade has expired, this function allows the buyer to redeem their escrowed payment token, and the seller's escrow.
