class WebFormLoginRequest {
  String formKey;
  String username;
  String password;

  WebFormLoginRequest({this.formKey, this.username, this.password});

  WebFormLoginRequest.fromJson(Map<String, dynamic> json) {
    formKey = json['form_key'];
    username = json['username'];
    password = json['password'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['form_key'] = this.formKey;
    data['username'] = this.username;
    data['password'] = this.password;
    return data;
  }
}