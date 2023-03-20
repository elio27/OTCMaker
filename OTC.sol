// SPDX-License-Identifier: MIT

pragma solidity >=0.8.16;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}


contract OTCDealer {

    modifier _stillValid() {
        require(block.timestamp<=expiration, "Trade expired.");
        require(!isConcluded, "Trade is already concluded.");
        _;
    }


    /*------------
    Tool variables
    ------------*/
    address internal slot1;
    address internal slot2;


    /*-------------
    Deal modalities
    -------------*/

    bool tokenAddressIsKnown = true;                         // replace 'true' by 'false' if you don't already know the traded token's address

    address public tokenAddress = TOKEN_ADDRESSS;           // replace by 'address(0)' if you don't know it
    address public paymentToken = PAYMENT_TOKEN_ADDRESS;

    address public seller = SELLER_ADDRESS;                 // address of the seller of the tokens
    address public buyer = BUYER_ADDRESS;                   // address of the buyer of the tokens

    uint256 public tokenAmount = AMOUNT_OF_TOKEN * 1000000000000000000;   // amount of the traded token

    uint256 public buyerEscrow = BUYER_ESCROW * 1000000000000000000;      // is equal to the total paid by the buyer
    uint256 public sellerEscrow = SELLER_ESCROW * 1000000000000000000;    // escrow deposited by the seller to avoid fraud

    bool public buyerEscrowFilled;                          // records wether or not the buyer's escrow has been deposited
    bool public sellerEscrowFilled;                         // records wether or not the seller's escrow has been deposited

    uint128 public tradeTime = TRADE_TIMESTAMP;             // timestamp from which the trade can take place
    uint128 public tradeDelay = TRADE_DELAY;                // time window after the start of the trade (in seconds)
    uint256 public expiration = tradeTime + tradeDelay;     // timestamp of expiration


    bool isConcluded;                                       // records the state of the trade

    /*----------------
    Contract Functions
    ----------------*/


    // If the traded token's address has not been defined at deployment, or has changed since, both the seller and the buyer have to call this function with the same address as argument to set it
    function defTokenAddress(address _tokenAddress) external _stillValid returns (bool) {

        require(_tokenAddress != address(0), "Zero address is not allowed.");

        if (msg.sender == seller) {slot1 = _tokenAddress;}
        else if (msg.sender == buyer) {slot2 = _tokenAddress;}
        else { revert(); }

        if (slot1 == slot2) {tokenAddress=slot1;tokenAddressIsKnown=true;}
        else {tokenAddressIsKnown = false;}

        return true;
    }

    // Call this function to deposit the buyer's escrow.   this contract's address should have enough allowance of the payment token to operate
    function depositBuyerEscrow() external _stillValid returns (bool) {
        require(!buyerEscrowFilled, "Buyer escrow is already filled.");
        IERC20(paymentToken).transferFrom(msg.sender, address(this), buyerEscrow);
        buyerEscrowFilled = true;
        return true;
    }

    // Call this function to deposit the seller's escrow.   this contract's address should have enough allowance of the payment token to operate
    function depositSellerEscrow() external _stillValid returns (bool) {
        require(!sellerEscrowFilled, "Seller escrow is already filled.");
        IERC20(paymentToken).transferFrom(msg.sender, address(this), sellerEscrow);
        sellerEscrowFilled = true;
        return true;
    }

    // If only one of the two participants have deposited, they can redeem their part to avoid losing funds
    function cancel() external returns (bool) {

        require(!isConcluded, "The trade is already concluded.");

        if (msg.sender == buyer && buyerEscrowFilled && !sellerEscrowFilled) {
            IERC20(paymentToken).transfer(buyer, buyerEscrow);
            buyerEscrowFilled = false;
        }

        else if (msg.sender == seller && sellerEscrowFilled && !buyerEscrowFilled ) {
            IERC20(paymentToken).transfer(seller, sellerEscrow);
            sellerEscrowFilled = false;
        }

        else { revert(); }

    return true;
    }

    // Proceeds to the transfers.   correct allowances must be granted otherwise this may fail
    function concludeTrade() external _stillValid returns (bool) {

        require(block.timestamp>=tradeTime && tokenAddressIsKnown && buyerEscrowFilled && sellerEscrowFilled, "Conditions aren't met.");

        IERC20(tokenAddress).transferFrom(seller, buyer, tokenAmount);

        IERC20(paymentToken).transfer(seller, buyerEscrow);
        IERC20(paymentToken).transfer(seller, sellerEscrow);

        isConcluded = true;
        return true;

    }


    // If the contract has expired, the buyer can redeem his escrow and the buyer's one
    function claimExpired() external returns (bool) {
        require(msg.sender==buyer, "You are not allowed to do that.");
        require(!isConcluded, "The trade is already concluded.");
        require(block.timestamp>=expiration, "Contract is not expired yet.");
        require(buyerEscrowFilled && sellerEscrowFilled, "Escrows aren't filled, maybe you want to use cancel() ?");

        IERC20(paymentToken).transfer(buyer, buyerEscrow);
        IERC20(paymentToken).transfer(buyer, sellerEscrow);

        return true;
    }

}
