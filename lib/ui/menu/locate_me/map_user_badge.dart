import 'package:flutter/material.dart';
import 'package:thought_factory/utils/app_colors.dart';

class MapUserBadge extends StatelessWidget {
  bool isSelected;
  String address;

  MapUserBadge({this.isSelected, this.address});

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: true,
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset.zero)
                ]),
            child: Row(
              children: [
                // Container(
                //     width: 40,
                //     height: 40,
                //     decoration: BoxDecoration(
                //         borderRadius: BorderRadius.circular(50),
                //         border: Border.all(color: Colors.white, width: 1))),
                SizedBox(width: 10),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(address ?? '', style: TextStyle(color: Colors.black))
                  ],
                )),
                Icon(Icons.location_pin, color: colorPrimary, size: 40)
              ],
            )));
  }
}
