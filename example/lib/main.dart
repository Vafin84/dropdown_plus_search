import 'package:dropdown_plus_search/dropdown_plus_search.dart';
import 'package:example/models/user_model.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter dropdown_plus_search package'),
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
  final users = <UserModel>[
    const UserModel(id: 0, name: "Ivan", age: 20),
    const UserModel(id: 1, name: "Oleg", age: 19),
    const UserModel(id: 2, name: "Robert", age: 20),
    const UserModel(id: 3, name: "Nikolay", age: 25),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            DropdownFormField<UserModel>(
              validator: ((UserModel? value) {
                if (value?.name == null) {
                  return "the text field is empty";
                }
                return null;
              }),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: DropdownEditingController(value: users[2]),
              borderRadius: BorderRadius.circular(10),
              elevation: 16,
              decoration: const InputDecoration(
                suffixIcon: Icon(Icons.arrow_drop_down),
                labelText: "Users",
                errorStyle: TextStyle(height: 0.5),
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                constraints: BoxConstraints(maxWidth: 680),
              ),
              onChanged: (UserModel? newValue) {
                setState(() {
                  // _setting.tarirovka = newValue!.id;
                });
              },
              displayItemFn: (UserModel? item) => Text(item?.name ?? ''),
              items: users,
              filterFn: (UserModel? item) => item?.name ?? "",
              dropdownItemFn: (UserModel item, int position, bool focused, bool selected, Function() onTap) => ListTile(
                dense: true,
                visualDensity: const VisualDensity(vertical: -4),
                title: Text(item.name),
                onTap: onTap,
              ),
            ),
            const SizedBox(height: 20),
            TextDropdownFormField(
              options: users.map((e) => e.name).toList(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.arrow_drop_down),
                labelText: "UserName",
                constraints: BoxConstraints(maxWidth: 680),
              ),
              dropdownHeight: 320,
            ),
          ],
        ),
      ),
    );
  }
}
