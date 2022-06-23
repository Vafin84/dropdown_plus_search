import 'package:dropdown_plus_search/dropdown_plus_search.dart';
import 'package:flutter/material.dart';

/// Simple dorpdown whith plain text as a dropdown items.
class TextDropdownFormField extends StatelessWidget {
  final List<String> options;
  final InputDecoration? decoration;
  final DropdownEditingController<String>? controller;
  final ValueChanged<String?>? onChanged;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final bool Function(String item, String str)? filterFn;
  final Future<List<String>> Function(String str)? findFn;
  final double? dropdownHeight;

  TextDropdownFormField({
    Key? key,
    required this.options,
    this.decoration,
    this.onSaved,
    this.controller,
    this.onChanged,
    this.validator,
    this.findFn,
    this.filterFn,
    this.dropdownHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownFormField<String>(
      decoration: decoration,
      onSaved: onSaved,
      controller: controller,
      onChanged: onChanged,
      validator: validator,
      dropdownHeight: dropdownHeight,
      displayItemFn: (dynamic str) => Text(
        str ?? '',
        style: TextStyle(fontSize: 16),
      ),
      items: options,
      filterFn: (dynamic item) => item,
      dropdownItemFn: (dynamic item, position, focused, selected, onTap) =>
          ListTile(
        title: Text(
          item,
          style: TextStyle(color: selected ? Colors.blue : Colors.black87),
        ),
        tileColor: focused ? Color.fromARGB(20, 0, 0, 0) : Colors.transparent,
        onTap: onTap,
      ),
    );
  }
}
