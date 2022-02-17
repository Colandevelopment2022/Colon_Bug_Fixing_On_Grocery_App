class UserRewardResponse {
  Rewards data;
  String message;
  int status;

  UserRewardResponse({this.data, this.message, this.status});

  UserRewardResponse.fromJson(Map<String,dynamic> jsonArray) {
    Map<String, dynamic> json = jsonArray[0];
    data = json['data'] != null ? new Rewards.fromJson(json['data']) : null;
    message = json['message'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    data['message'] = this.message;
    data['status'] = this.status;
    return data;
  }
}

class Rewards {
  int totalCredits;
  int totalDebits;
  int totalRemaining;
  List<Data> rewards;

  Rewards({this.totalCredits, this.totalDebits, this.totalRemaining});

  Rewards.fromJson(Map<String, dynamic> json) {
    totalCredits = json['total_credits'];
    totalDebits = json['total_debits'];
    totalRemaining = json['total_remaining'];
    if (json['credits'] != null) {
      rewards = <Data>[];
      json['credits'].forEach((v) {
        rewards.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_credits'] = this.totalCredits;
    data['total_debits'] = this.totalDebits;
    data['total_remaining'] = this.totalRemaining;
    data['credits'] = this.rewards;
    return data;
  }
}

class Data {
  String entityId;
  String customerId;
  String rewardPoint;
  String action;
  String transactionNote;
  String status;

  Data(
      {this.entityId,
      this.customerId,
      this.rewardPoint,
      this.action,
      this.transactionNote,
      this.status});

  Data.fromJson(Map<String, dynamic> json) {
    entityId = json['entity_id'];
    customerId = json['customer_id'];
    rewardPoint = json['reward_point'];
    action = json['action'];
    transactionNote = json['transaction_note'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['entity_id'] = this.entityId;
    data['customer_id'] = this.customerId;
    data['reward_point'] = this.rewardPoint;
    data['action'] = this.action;
    data['transaction_note'] = this.transactionNote;
    data['status'] = this.status;
    return data;
  }
}
