pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SupplyChain.sol";

contract TestSupplyChain {
    SupplyChain myContract;
    uint value = 1000;

    function beforeEach () public {
      myContract = new SupplyChain();
      myContract.addItem('testItem', value);
    }

    // Test for failing conditions in this contracts:
    // https://truffleframework.com/tutorials/testing-for-throws-in-solidity-tests
    // buyItem

    function testBuyItem () public {
      bool success;
      string memory name;
      uint sku;
      uint price;
      uint state;
      address seller;
      address buyer;

      (name, sku, price, state, seller, buyer) = myContract.fetchItem(0);

      Assert.equal(sku, 0, "Expected Sku");
      Assert.equal(price, value, "Expected Price");
      Assert.equal(name,'testItem', "Expected item name");

      (success, ) = address(myContract).call.value(price + 1000)(
        abi.encodeWithSignature("buyItem(uint sku)", sku)
      );
      // // FIXME: False positive
      Assert.isFalse(success, "Not enough eth");
    // test for failure if user does not send enough funds

    // test for purchasing an item that is not for Sale
    }


    // shipItem

    // test for calls that are made by not the seller
    // test for trying to ship an item that is not marked Sold

    // receiveItem

    // test calling the function from an address that is not the buyer
    // test calling the function on an item not marked Shipped

}
