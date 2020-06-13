pragma solidity ^0.5.0;

contract Escrow {
    uint256 public productCount;
    mapping(uint256 => EscrowProduct) public products;

    struct EscrowProduct {
        uint256 id;
        address seller;
        address buyer;
        address judge; // Setting judge address by the system based on consensus
        uint256 amount;
        uint256 judge_fee;
        uint256 timestamp;
        uint256 dispute_time;
        bool judge_intervention;
        bool release_amount_seller;
        bool refund_amount_buyer;
        bool available;
    }

    function createProduct(uint256 _amount) public {
        productCount++;
        products[productCount] = EscrowProduct(
            productCount, // setting unique id for each product
            msg.sender, // seller becomes the one who initiated this function
            address(0), // buyer address set to default
            address(0), // judge address set to default
            _amount, // price of the product
            (_amount * 2) / 100, // 2% of price of the product set as judge fee
            now, // time of product creation
            0, // dispute time set as 0 as default
            false, // no judge intervention by default
            false, // no release initiated
            false, // no refund initiated
            true // product availability set as true
        );
    }

    function purchaseProduct()

}
