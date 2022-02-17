import 'package:thought_factory/core/data/remote/request_response/product/detail/product_detail_response.dart';

class ProfileInfo {
  String firstName;
  String lastName;
  String mobileNumber;
  String mailID;
  String id;
  String imageUrl;
  String storeId;
  String websSiteid;
  List<CustomAttributes> customAttributes;

  ProfileInfo(
      {this.firstName,
      this.lastName,
      this.mobileNumber,
      this.mailID,
      this.id,
      this.storeId,
      this.websSiteid,
      this.imageUrl,
      this.customAttributes}) {
    for (final CustomAttributes c in customAttributes) {
      if (c.attributeCode == 'customer_mobile') {
        mobileNumber = c.value;
        return;
      }
    }
  }

  @override
  String toString() {
    return 'ProfileInfo{firstName: $firstName, lastName: $lastName, mobileNumber: $mobileNumber, mailID:$mailID, id:$id, storeId:$storeId,webSiteId:$websSiteid,imageUrl:$imageUrl, customAttribute: ${customAttributes}';
  }
}
