// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.9.0;

contract SupplyChain {

  // <owner>

  address public owner;

  // <skuCount>

  uint public skuCount;

  // <items mapping>

  mapping(uint => Item) private items;

  // <enum State: ForSale, Sold, Shipped, Received>

  enum State {
    ForSale,
    Sold,
    Shipped,
    Received
  }

  // <struct Item: name, sku, price, state, seller, and buyer>
  struct Item {
    string name;
    uint sku;
    uint price;
    State state;
    address payable seller;
    address payable buyer;
  }
  /*
   * Events
   */

  // <LogForSale event: sku arg>

  event LogForSale(uint sku);

  // <LogSold event: sku arg>

  event LogSold(uint sku, uint refund);

  // <LogShipped event: sku arg>

  event LogShipped(uint sku);

  // <LogReceived event: sku arg>

  event LogReceived(uint sku);


  /*
   * Modifiers
   */

  // Create a modifer, `isOwner` that checks if the msg.sender is the owner of the contract

  // <modifier: isOwner
  modifier isOwner() {
    require(msg.sender == owner);
    _;
  }

  modifier isSold(uint sku) {
    require(items[sku].state == State.Sold);
    _;
  }

  modifier isShipped(uint sku) {
    require(items[sku].state == State.Shipped);
    _;
  }

  modifier isSeller(uint sku) {
    require (items[sku].seller == msg.sender);
    _;
  }

  modifier isBuyer(uint sku) {
    require (items[sku].buyer == msg.sender);
    _;
  }

  modifier verifyCaller (address _address) {
    require (msg.sender == _address);
    _;
  }

  modifier paidEnough(uint sku) {
    require(msg.value >= items[sku].price);
    _;
  }

  modifier checkValue(uint _sku) {
    _;
    uint _price = items[_sku].price;
    uint amountToRefund = msg.value - _price;
    items[_sku].buyer.transfer(amountToRefund);
  }

  // For each of the following modifiers, use what you learned about modifiers
  // to give them functionality. For example, the forSale modifier should
  // require that the item with the given sku has the state ForSale. Note that
  // the uninitialized Item.State is 0, which is also the index of the ForSale
  // value, so checking that Item.State == ForSale is not sufficient to check
  // that an Item is for sale. Hint: What item properties will be non-zero when
  // an Item has been added?

  // modifier forSale
  // modifier sold(uint _sku)
  // modifier shipped(uint _sku)
  // modifier received(uint _sku)

  constructor() public {
    // 1. Set the owner to the transaction sender
    owner = msg.sender;
    // 2. Initialize the sku count to 0. Question, is this necessary? No. uint defaults to 0
  }

  function addItem(string memory _name, uint _price) public returns (bool) {
    // 1. Create a new item and put in array

    Item memory newItem = Item({
      name: _name,
      price: _price,
      sku: skuCount,
      state: State.ForSale,
      seller: msg.sender,
      buyer: address(0)
    });

    items[skuCount] = newItem;
    // 2. Increment the skuCount by one
    skuCount += 1;
    // 3. Emit the appropriate event
    emit LogForSale(newItem.sku);
    // 4. return true

    return true;

    // hint:
    // items[skuCount] = Item({
    //  name: _name,
    //  sku: skuCount,
    //  price: _price,
    //  state: State.ForSale,
    //  seller: msg.sender,
    //  buyer: address(0)
    //});
    //
    //skuCount = skuCount + 1;
    // emit LogForSale(skuCount);
    // return true;
  }

  // Implement this buyItem function.
  // 1. it should be payable in order to receive refunds
  // 2. this should transfer money to the seller,
  // 3. set the buyer as the person who called this transaction,
  // 4. set the state to Sold.
  // 5. this function should use 3 modifiers to check
  //    - if the item is for sale,
  //    - if the buyer paid enough,
  //    - check the value after the function is called to make
  //      sure the buyer is refunded any excess ether sent.
  // 6. call the event associated with this function!
  function buyItem(uint sku) paidEnough(sku) payable public {
    require(sku <= skuCount, "Sku does not exist");

    Item storage itemToBuy = items[sku];
    require(itemToBuy.state == State.ForSale);

    uint refund = msg.value - itemToBuy.price;

    itemToBuy.state = State.Sold;
    itemToBuy.buyer = msg.sender;

    // Send ETH to buyer
    (bool saleSuccess, ) = itemToBuy.seller.call.value(itemToBuy.price)("");

    require(saleSuccess, "Sale failed");

    // Send Refund
    (bool refundSuccess, ) = msg.sender.call.value(refund)("");

    require(refundSuccess, "Refund failed");

    emit LogSold(sku, refund);
  }

  // 1. Add modifiers to check:
  //    - the item is sold already
  //    - the person calling this function is the seller.
  // 2. Change the state of the item to shipped.
  // 3. call the event associated with this function!
  function shipItem(uint sku) isSeller(sku) isSold(sku) public {
    items[sku].state = State.Shipped;
    emit LogShipped(sku);
  }

  // 1. Add modifiers to check
  //    - the item is shipped already
  //    - the person calling this function is the buyer.
  // 2. Change the state of the item to received.
  // 3. Call the event associated with this function!
  function receiveItem(uint sku) isBuyer(sku) isShipped(sku) public {
    items[sku].state = State.Received;
    emit LogReceived(sku);
  }

  // Uncomment the following code block. it is needed to run tests
  function fetchItem(uint _sku) public view
    returns (
      string memory name,
      uint sku,
      uint price,
      uint state,
      address seller,
      address buyer
    ) {
      name = items[_sku].name;
      sku = items[_sku].sku;
      price = items[_sku].price;
      state = uint(items[_sku].state);
      seller = items[_sku].seller;
      buyer = items[_sku].buyer;

      return (name, sku, price, state, seller, buyer);
  }
}
