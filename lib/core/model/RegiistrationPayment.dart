class PaymentRegistration {
  String currency;
  String returnPath;
  String transactionHint;
  String orderID;
  String store;
  String terminal;
  String channel;
  String amount;
  String customer;
  String orderName;
  String userName;
  String password;

  PaymentRegistration(
      {this.currency,
        this.returnPath,
        this.transactionHint,
        this.orderID,
        this.store,
        this.terminal,
        this.channel,
        this.amount,
        this.customer,
        this.orderName,
        this.userName,
        this.password});

  PaymentRegistration.fromJson(Map<String, dynamic> json) {
    currency = json['Currency'];
    returnPath = json['ReturnPath'];
    transactionHint = json['TransactionHint'];
    orderID = json['OrderID'];
    store = json['Store'];
    terminal = json['Terminal'];
    channel = json['Channel'];
    amount = json['Amount'];
    customer = json['Customer'];
    orderName = json['OrderName'];
    userName = json['UserName'];
    password = json['Password'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Currency'] = this.currency;
    data['ReturnPath'] = this.returnPath;
    data['TransactionHint'] = this.transactionHint;
    data['OrderID'] = this.orderID;
    data['Store'] = this.store;
    data['Terminal'] = this.terminal;
    data['Channel'] = this.channel;
    data['Amount'] = this.amount;
    data['Customer'] = this.customer;
    data['OrderName'] = this.orderName;
    data['UserName'] = this.userName;
    data['Password'] = this.password;
    return data;
  }
}
