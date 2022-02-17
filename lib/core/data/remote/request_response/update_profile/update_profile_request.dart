class UpdateProfileRequest {
  Customer customer;

  UpdateProfileRequest({this.customer});

  UpdateProfileRequest.fromJson(Map<String, dynamic> json) {
    customer = json['customer'] != null
        ? new Customer.fromJson(json['customer'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.customer != null) {
      data['customer'] = this.customer.toJson();
    }
    return data;
  }
}

class Customer {
  String id;
  String email;
  String firstname;
  String lastname;
  String storeId;
  String websiteId;
  String phoneNumber;

  Customer(
      {this.id,
      this.email,
      this.firstname,
      this.lastname,
      this.storeId,
      this.websiteId,
      this.phoneNumber});

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    firstname = json['firstname'];
    lastname = json['lastname'];
    storeId = json['storeId'];
    websiteId = json['websiteId'];
    phoneNumber = json['customer_mobile'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['email'] = this.email;
    data['firstname'] = this.firstname;
    data['lastname'] = this.lastname;
    data['storeId'] = this.storeId;
    data['customer_mobile'] = this.phoneNumber;
    data['websiteId'] = this.websiteId;
    return data;
  }
}
