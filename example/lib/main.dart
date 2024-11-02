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
      theme: ThemeData.light().copyWith(
          colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.orange,
        brightness: Brightness.light,
      )),
      darkTheme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.orange,
        brightness: Brightness.dark,
      )),
      themeMode: ThemeMode.light,
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
  final _controller = DropdownEditingController<UserModel>();
  final users = <UserModel>[
    const UserModel(id: 0, name: "Ivan", age: 20),
    const UserModel(id: 1, name: "Oleg", age: 19),
    const UserModel(id: 2, name: "Robert", age: 20),
    const UserModel(id: 3, name: "Nikolay", age: 25),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownFormField<UserModel>(
              validator: ((UserModel? value) {
                if (value?.name == null) {
                  return "the text field is empty";
                }
                return null;
              }),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: _controller,
              borderRadius: BorderRadius.circular(10),
              elevation: 16,
              decoration: const InputDecoration(
                suffixIcon: Icon(Icons.arrow_drop_down),
                labelText: "Username",
                errorStyle: TextStyle(height: 0.5),
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                constraints: BoxConstraints(maxWidth: 680),
              ),
              onChanged: (UserModel? newValue) {
                setState(() {});
              },
              displayItemFn: (UserModel? item) => Text(item?.name ?? ''),
              items: users,
              filterFn: (UserModel? item) => item?.name ?? "",
              dropdownItemFn: (item, position, focused, selected, onTap) => ListTile(
                hoverColor: theme.colorScheme.outline,
                selectedColor: Theme.of(context).colorScheme.primary,
                selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
                selected: selected,
                dense: true,
                visualDensity: const VisualDensity(vertical: -4),
                title: Text(item.name),
                onTap: onTap,
              ),
            ),
            Expanded(
                child: Center(
              child: Text(
                _controller.value?.name ?? "",
                style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
