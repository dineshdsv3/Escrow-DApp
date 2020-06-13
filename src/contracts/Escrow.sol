pragma solidity ^0.5.0;

contract Escrow {
    uint256 public productCount;
    mapping(uint256 => EscrowProduct) public products;

    struct EscrowProduct {
        uint256 id;
        address payable seller;
        address payable buyer;
        address payable judge; // Setting judge address by the system based on consensus
        uint256 amount;
        uint256 judge_fee;
        uint256 timestamp;
        uint256 dispute_time;
        bool judge_intervention;
        bool release_amount_seller;
        bool refund_amount_buyer;
        bool seller_response_within_time;
        bool disputeCleared;
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
            false, // Initially set to false
            false, // Initially set to false
            true // product availability set as true
        );
    }

    function purchaseProduct(uint _id) public payable {
        EscrowProduct memory productModel = products[_id];
        require(productModel.available = true,'Product must be available for sale');
        require(msg.value >= productModel.amount,'Smart contract value must  be greater or equal to the product amount');

        productModel.buyer = msg.sender; // Setting the buyer for the product

        productModel.available = false;  //As buyer initiated this transaction this is set to false temporarily

        productModel.dispute_time = now + 400; // Dispute time initiated upto 24 hours from now

        products[_id] = productModel; // changing the orginal product again by using memory
    }

    function withdrawBySeller(uint _id) public payable {
        EscrowProduct memory productModel = products[_id];
        require(now > productModel.dispute_time,'Seller cant be able to withdraw his funds before dispute time');
        address payable _seller = productModel.seller;
        require(msg.sender == _seller,'Only sender can be able to perform this function');
        if(now > productModel.dispute_time && !productModel.judge_intervention) {
            productModel.release_amount_seller = true;
        } else{
            productModel.release_amount_seller = false;
        }
        products[_id] = productModel;
        require(productModel.release_amount_seller = true,'Release amount must be true to withdraw the amount');

        productModel.seller.transfer(productModel.amount); // Transfer product amount to the seller of the product
    }

    function createDispute(uint _id) public payable {
        EscrowProduct memory productModel = products[_id];
        address payable _buyer = productModel.buyer;
        require(msg.sender == _buyer,'Only buyer can be able to rise the dispute');
        require(now < productModel.dispute_time,'Buyer can only be able to rise the dispute within the dispute time');
        require(msg.value == productModel.judge_fee,'Buyer needs to pay the judge fee to create a dispute');
        productModel.judge_intervention = true;
        products[_id] = productModel;
    }

    function participateInDisputeBySeller(uint _id) public payable {
        EscrowProduct memory productModel = products[_id];
        require(productModel.judge_intervention = true,'Buyer needs to add dispute before participating');
        require(msg.value == productModel.judge_fee,'Seller needs to pay the judge fee to create a dispute');
        address payable _seller = productModel.seller;
        require(msg.sender == _seller,'Only sender can be able to perform this function');
        productModel.seller_response_within_time = true;
        products[_id] = productModel;
    }

    function withdrawByBuyer(uint _id) public payable {
        EscrowProduct memory productModel = products[_id];
        address payable _buyer = productModel.buyer;
        require(msg.sender == _buyer,'Only buyer can be able to execute this function');
        require(productModel.release_amount_seller = true,'Release_amount must be true to withdraw the amount');
        uint256 withdrawablebuyerAmount = productModel.amount + productModel.judge_fee;
        productModel.buyer.transfer(withdrawablebuyerAmount); // Transfer product amount to the seller of the product
        products[_id] = productModel;
    }

    function clearDispute(uint _id) public { // In the function we'll take 0 and 1 as arguments from front end
        EscrowProduct memory productModel = products[_id];
        require(productModel.judge_intervention = true,'Buyer needs to add dispute before judge clearing the dispute');
        require(productModel.seller_response_within_time = true,'Seller also needs to be in dispute before judge clearing the dispute');
        productModel.judge = msg.sender; // Temporarily fixing the judge by the one who initiates this transaction
        if(_id == 0) {
            productModel.release_amount_seller = true; // In this condition seller can be able to withdraw his/her funds
        } else if(_id == 1) {
            productModel.refund_amount_buyer = true; // In this condition buyer can be able to withdraw his/her funds
        }
        productModel.disputeCleared = true;  // After the judgement dispute has been resolved
        products[_id] = productModel;
    }

    function withdrawByJudge(uint _id) public payable {
        EscrowProduct memory productModel = products[_id];
        require(productModel.disputeCleared = true,'Dispute must be resolved');
        require(productModel.judge == msg.sender,'Only judge of the current product can be able to execute this function');
        uint256 judgeFee = 2 * productModel.judge_fee;
        productModel.judge.transfer(judgeFee);
    }
}
