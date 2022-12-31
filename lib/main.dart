import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('user_database');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Crud Hive Local DataBase',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const MyHomePage(title: 'Flutter Crud Hive Local DataBase'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _orderController = TextEditingController();
  final TextEditingController _paymentController = TextEditingController();

  var newRecord = Map<String, dynamic>;
  List<Map<String, dynamic>> _recordList = [];

  final _userDatabase = Hive.box('user_database');
  Future<void> _saveEntry(newRecord)async{
    await _userDatabase.add(newRecord);
    _refreshItems();
  }
  void _refreshItems(){
    final data = _userDatabase.keys.map((e) {
      final item = _userDatabase.get(e);
      return {"key": e, "name": item["name"],"order":item["order"], "payment" : item["payment"]};
    }).toList();
    setState(() {
      _recordList = data.reversed.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontSize: 18)),
        centerTitle: true,
      ),
      body: _recordList.isEmpty ?
      const SizedBox():
      ListView.builder(
        padding: const EdgeInsets.all(8),
          itemCount: _recordList.length,
          itemBuilder: (context, index){
        return ListTile(
          title: Text(_recordList[index]["name"]),
          subtitle:Column(
            children: [
              Text(_recordList[index]["order"]),
              Text(_recordList[index]["payment"]),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _showUserForm(context, null);
        },
        tooltip: 'add',
        child: const Icon(Icons.add),
      ),
    );
  }
  void _showUserForm(BuildContext ctx, int? itemkey) async {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15)),
        ),
        context: ctx, builder: (_){
      return Container(
        padding: EdgeInsets.only(
          top: 15,right: 15,left: 15,
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'User Name'),
            ),
            const SizedBox(height: 5,),
            TextField(
              controller: _orderController,
              decoration: const InputDecoration(hintText: 'Order'),
            ),
            const SizedBox(height: 5,),
            TextField(
              controller: _paymentController,
              decoration: const InputDecoration(hintText: 'Payment'),
            ),
            const SizedBox(height: 10,),
            ElevatedButton(
                onPressed: (){
                  _saveEntry({
                    "name" : _nameController.text,
                    "order" : _orderController.text,
                    "payment" : _paymentController.text,
                  });
                  _nameController.clear();
                  _orderController.clear();
                  _paymentController.clear();
                },
                child: const Text('Create Entry'))
          ],

        ),
      );
    });
  }
}

