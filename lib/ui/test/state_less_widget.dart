import 'package:flutter/material.dart';

class StatelessWidgetExample extends StatelessWidget {
  /// constructor
  const StatelessWidgetExample({this.data1, this.data2, Key key})
      : super(key: key);

  final int data1;
  final String data2;

  /// build method
  /// once it will be called
  @override
  Widget build(BuildContext context) {
    debugPrint('stateless widget build method call');
    return Column(
      children: [
        Text('$data1'),
        TextButton(onPressed: () {}, child: Text('on click'))
      ],
    );
  }
}

class StatefullWidgetExample extends StatefulWidget {
  /// default constructor
  const StatefullWidgetExample({this.data1, this.data2, Key key})
      : super(key: key);

  /// data from constructor
  final int data1;

  /// intial data = 10
  final String data2;

  /// state creation
  @override
  _StatefullWidgetExampleState createState() =>
      _StatefullWidgetExampleState(data1);
}

class _StatefullWidgetExampleState extends State<StatefullWidgetExample> {
  /// state constructor
  _StatefullWidgetExampleState(this.data1);

  /// data
  /// /// passed from screen =5
  int data1;

  bool apiCall = true;

  /// first method which will be called before build ,it will called only once;
  @override
  void initState() {
    super.initState();
    debugPrint('state full widget init method');
    Future.delayed(Duration(seconds: 10), () {
      apiCall = false;
      setState(() {});
    });
  }

  /// used to display ui
  @override
  Widget build(BuildContext context) {
    debugPrint('state full widget build method');
    return apiCall
        ? Center(
            child: Text('loading'),
          )
        : Column(
            children: [
              Text('$data1'),
              TextButton(
                  onPressed: () {
                    dataUpdate();
                  },
                  child: Text('on click'))
            ],
          );
  }

  /// when ever there is change in device configuration  ex: keyboard display, orienatation
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('state full widget didChangeDependencies method');
  }

  @override
  void didUpdateWidget(covariant StatefullWidgetExample oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('state full widget didUpdateWidget method');
  }

  /// removing widget form tree
  @override
  void deactivate() {
    super.deactivate();
    debugPrint('state full widget deactivate method');
  }

  /// final method
  @override
  void dispose() {
    super.dispose();
    debugPrint('state full widget dispose method');
  }

  void dataUpdate() {
    data1 = data1 + 10;

    /// updating data 1 , which will be 15
    setState(() {});
  }
}
