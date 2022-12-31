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

  Future<void> _updateEntry(int itemKey, Map<String, dynamic> item)async{
    await _userDatabase.put(itemKey, item);
    _refreshItems();
  }
  Future<void> _deleteEntry(int itemKey)async{
    await _userDatabase.delete(itemKey);
    _refreshItems();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            duration: Duration(seconds: 2),
            content: Text('User has been deleted'),
        ));
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
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshItems();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontSize: 18)),
        centerTitle: true,
      ),
      body: _recordList.isEmpty ?
      const Center(child: Text('No record found')):
      ListView.separated(
        separatorBuilder: (context, index)=> const SizedBox(height: 5,),
        padding: const EdgeInsets.all(8),
          itemCount: _recordList.length,
          itemBuilder: (context, index){
        return ListTile(
          // dense: true,
          tileColor: Colors.amber.withOpacity(0.2),
          contentPadding: const EdgeInsets.symmetric(vertical:0,horizontal: 5),
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1,color: Colors.teal.withOpacity(0.7)),
            borderRadius: BorderRadius.circular(12),
          ),
          leading: CircleAvatar(
            backgroundColor: Colors.teal.withOpacity(0.5),
            child: Text(
              '${index+1}',
              style: const TextStyle(color: Colors.black),
            ),
          ),
          title: Text(_recordList[index]["name"], textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),),
          subtitle:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text('Order No# '),
                  Text(_recordList[index]["order"], style: const TextStyle(fontWeight: FontWeight.w800),),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text('RS =/ '),
                  Text(_recordList[index]["payment"], style: const TextStyle(fontWeight: FontWeight.w800),),
                ],
              ),
            ],
          ),
          trailing:  Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(onPressed: (){
                _showUserForm(context, _recordList[index]['key']);
              }, icon: const Icon(Icons.edit, color: Colors.green, size: 16,)),
              IconButton(onPressed: (){
                _deleteEntry(_recordList[index]['key']);
              }, icon: const Icon(Icons.delete, color: Colors.red, size: 16,)),
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
    if(itemkey != null){
      final existingItem = _recordList.firstWhere((element) => element['key'] == itemkey);
      _nameController.text = existingItem['name'];
      _orderController.text = existingItem['order'];
      _paymentController.text = existingItem['payment'];

    }
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15)),
        ),
        context: ctx, builder: (_){
      return SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: 15,right: 25,left: 25,
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
                    if(itemkey == null){
                      _saveEntry({
                        "name" : _nameController.text,
                        "order" : _orderController.text,
                        "payment" : _paymentController.text,
                      });
                    }
                    if(itemkey != null){
                      _updateEntry(itemkey,{
                        "name" : _nameController.text,
                        "order" : _orderController.text,
                        "payment" : _paymentController.text,
                      });
                    }
                    _nameController.clear();
                    _orderController.clear();
                    _paymentController.clear();
                    Navigator.of(context).pop();
                  },
                  child: Text(itemkey == null ? 'Create Entry' : 'Update Entry'))
            ],

          ),
        ),
      );
    });
  }
}

