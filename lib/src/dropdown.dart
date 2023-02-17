import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class DropdownEditingController<T> extends ChangeNotifier {
  T? _value;
  DropdownEditingController({T? value}) : _value = value;

  T? get value => _value;
  set value(T? newValue) {
    if (_value == newValue) return;
    _value = newValue;
    notifyListeners();
  }

  @override
  String toString() => '${describeIdentity(this)}($value)';
}

/// Create a dropdown form field
class DropdownFormField<T> extends StatefulWidget {
  final List<T> items;

  final double elevation;

  final BorderRadius? borderRadius;

  final Color cursorColor;

  final bool autoFocus;

  final AutovalidateMode? autovalidateMode;

  /// It will trigger on user search
  final String Function(T item)? filterFn;

  /// Check item is selectd
  final bool Function(T? item1, T? item2)? selectedFn;

  /// Build dropdown Items, it get called for all dropdown items
  ///  [item] = [dynamic value] List item to build dropdown Listtile
  /// [lasSelectedItem] = [null | dynamic value] last selected item, it gives user chance to highlight selected item
  /// [position] = [0,1,2...] Index of the list item
  /// [focused] = [true | false] is the item if focused, it gives user chance to highlight focused item
  /// [onTap] = [Function] *important! just assign this function to Listtile.onTap  = onTap, incase you missed this,
  /// the click event if the dropdown item will not work.
  ///
  final Widget Function(
    T item,
    int position,
    bool focused,
    bool selected,
    Function() onTap,
  ) dropdownItemFn;

  /// Build widget to display selected item inside Form Field
  final Widget Function(T? item) displayItemFn;

  final InputDecoration? decoration;
  final Color? dropdownColor;
  final DropdownEditingController<T>? controller;
  final ValueChanged<T?>? onChanged;
  final void Function(T?)? onSaved;
  final FormFieldValidator<T>? validator;

  /// height of the dropdown overlay, Default: 240
  final double? dropdownHeight;

  /// Style the search box text
  final TextStyle? searchTextStyle;

  /// Message to disloay if the search dows not match with any item, Default : "No matching found!"
  final String emptyText;

  /// Give action text if you want handle the empty search.
  final String emptyActionText;

  /// this functon triggers on click of emptyAction button
  final Future<void> Function()? onEmptyActionPressed;

  DropdownFormField({
    Key? key,
    required this.dropdownItemFn,
    required this.displayItemFn,
    required this.items,
    this.filterFn,
    this.autoFocus = false,
    this.controller,
    this.validator,
    this.decoration,
    this.dropdownColor,
    this.onChanged,
    this.onSaved,
    this.dropdownHeight,
    this.searchTextStyle = const TextStyle(fontSize: 14, color: Colors.black),
    this.emptyText = "No matching found!",
    this.emptyActionText = 'Create new',
    this.onEmptyActionPressed,
    this.selectedFn,
    this.cursorColor = Colors.black,
    this.elevation = 8.0,
    this.borderRadius,
    this.autovalidateMode = AutovalidateMode.disabled,
  }) : super(key: key);

  @override
  DropdownFormFieldState<T> createState() => DropdownFormFieldState<T>();
}

class DropdownFormFieldState<T> extends State<DropdownFormField<T>>
    with SingleTickerProviderStateMixin {
  final FocusNode _widgetFocusNode = FocusNode();
  final FocusNode _searchFocusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  final ValueNotifier<List<T>> _listItemsValueNotifier =
      ValueNotifier<List<T>>([]);
  final TextEditingController _searchTextController = TextEditingController();
  final DropdownEditingController<T>? _controller =
      DropdownEditingController<T>();

  final Function(T?, T?) _selectedFn =
      (dynamic item1, dynamic item2) => item1 == item2;

  bool get _isEmpty => _selectedItem == null;
  bool _isFocused = false;

  OverlayEntry? _overlayEntry;
  OverlayEntry? _overlayBackdropEntry;
  List<T>? _options;
  int _listItemFocusedPosition = 0;
  T? _selectedItem;
  Widget? _displayItem;
  Timer? _debounce;
  String? _lastSearchString;

  DropdownEditingController<dynamic>? get _effectiveController =>
      widget.controller ?? _controller;

  DropdownFormFieldState() : super();

  @override
  void initState() {
    if (widget.autoFocus) _widgetFocusNode.requestFocus();
    _selectedItem = _effectiveController!.value;

    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus && _overlayEntry != null) {
        _removeOverlay();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print("_overlayEntry : $_overlayEntry");

    _displayItem = widget.displayItemFn(_selectedItem);

    return CompositedTransformTarget(
      link: this._layerLink,
      child: GestureDetector(
        onTap: () {
          _widgetFocusNode.requestFocus();
          _toggleOverlay();
        },
        child: Focus(
          autofocus: widget.autoFocus,
          focusNode: _widgetFocusNode,
          onFocusChange: (focused) {
            setState(() {
              _isFocused = focused;
            });
          },
          child: FormField(
            validator: (str) {
              if (widget.validator != null) {
                return widget.validator!(_effectiveController!.value);
              }
              return null;
            },
            autovalidateMode: widget.autovalidateMode,
            onSaved: (str) {
              if (widget.onSaved != null) {
                widget.onSaved!(_effectiveController!.value);
              }
            },
            builder: (state) {
              return InputDecorator(
                decoration: widget.decoration?.copyWith(
                        errorText: state.isValid ? null : state.errorText) ??
                    InputDecoration(
                      border: const OutlineInputBorder(),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                      errorText: state.isValid ? null : state.errorText,
                    ),
                isEmpty: _isEmpty,
                isFocused: _isFocused,
                child: this._overlayEntry != null
                    ? EditableText(
                        style: widget.searchTextStyle!,
                        controller: _searchTextController,
                        cursorColor: widget.cursorColor,
                        focusNode: _searchFocusNode,
                        backgroundCursorColor: Colors.transparent,
                        onChanged: (str) {
                          if (_overlayEntry == null) {
                            _addOverlay();
                          }
                          _onTextChanged(str);
                        },
                        onSubmitted: (str) {
                          // _searchTextController.value =
                          //     TextEditingValue(text: "");
                          _setValue();
                          _overlayEntry!.remove();
                          _overlayEntry = null;
                          _widgetFocusNode.nextFocus();
                        },
                        onEditingComplete: () {},
                      )
                    : _displayItem ?? Container(),
              );
            },
          ),
        ),
      ),
    );
  }

  OverlayEntry _createOverlayEntry() {
    final renderObject = context.findRenderObject() as RenderBox;
    // print(renderObject);
    final Size size = renderObject.size;

    var overlay = OverlayEntry(builder: (context) {
      return Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: this._layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 3.0),
          child: Theme(
            data: ThemeData(),
            child: Material(
              borderRadius: widget.borderRadius,
              elevation: widget.elevation,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  height: widget.dropdownHeight ?? 240,
                  color: widget.dropdownColor ?? Colors.white70,
                  child: ValueListenableBuilder(
                      valueListenable: _listItemsValueNotifier,
                      builder: (context, List<T> items, child) {
                        return _options != null && _options!.length > 0
                            ? ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: _options!.length,
                                itemBuilder: (context, position) {
                                  T item = _options![position];
                                  Function() onTap = () {
                                    _listItemFocusedPosition = position;
                                    _searchTextController.value =
                                        TextEditingValue(text: "");
                                    _setValue();

                                    _overlayEntry!.remove();
                                    _overlayEntry = null;
                                  };
                                  Widget listTile = widget.dropdownItemFn(
                                    item,
                                    position,
                                    position == _listItemFocusedPosition,
                                    (widget.selectedFn ?? _selectedFn)(
                                        _selectedItem, item),
                                    onTap,
                                  );

                                  return listTile;
                                })
                            : Container(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      widget.emptyText,
                                      style: TextStyle(color: Colors.black45),
                                    ),
                                    if (widget.onEmptyActionPressed != null)
                                      TextButton(
                                        onPressed: () async {
                                          await widget.onEmptyActionPressed!();
                                          _search(
                                              _searchTextController.value.text);
                                        },
                                        child: Text(widget.emptyActionText),
                                      ),
                                  ],
                                ),
                              );
                      })),
            ),
          ),
        ),
      );
    });

    return overlay;
  }

  OverlayEntry _createBackdropOverlay() {
    return OverlayEntry(
        builder: (context) => Positioned(
            left: 0,
            top: 0,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: GestureDetector(
              onTap: () {
                _removeOverlay();
              },
            )));
  }

  void _addOverlay() {
    if (_overlayEntry == null) {
      _search("");
      _overlayBackdropEntry = _createBackdropOverlay();
      _overlayEntry = _createOverlayEntry();
      if (_overlayEntry != null) {
        Overlay.of(context).insertAll([_overlayBackdropEntry!, _overlayEntry!]);

        // Overlay.of(context).insert(_overlayEntry!);
        setState(() {
          _searchFocusNode.requestFocus();
        });
      }
    }
  }

  /// Dettach overlay from the dropdown widget
  void _removeOverlay() {
    Future.delayed(Duration(milliseconds: 200), () {
      if (_overlayEntry != null) {
        _overlayEntry!.remove();
        _overlayEntry = null;
      }
      if (_overlayBackdropEntry != null) {
        _overlayBackdropEntry!.remove();
        _overlayBackdropEntry = null;
      }
    }).whenComplete(() {
      _searchTextController.value = TextEditingValue.empty;
      setState(() {});
    });
  }

  void _toggleOverlay() {
    if (_overlayEntry == null) {
      _addOverlay();
    } else
      _removeOverlay();
  }

  void _onTextChanged(String? str) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (_lastSearchString != str) {
        _lastSearchString = str;
        _search(str ?? "");
      }
    });
  }

  void _search(String str) async {
    List<T> items = [...widget.items];
    if (str.isNotEmpty && widget.filterFn != null) {
      setState(() {
        _listItemFocusedPosition = 0;
      });
      items = items
          .where((item) =>
              widget.filterFn!(item).toLowerCase().contains(str.toLowerCase()))
          .toList();
    }
    _options = items;
    _listItemsValueNotifier.value = items;
  }

  void _setValue() {
    if (_options != null && _options!.isNotEmpty) {
      var item = _options![_listItemFocusedPosition];
      _selectedItem = item;

      _effectiveController!.value = _selectedItem;
    }

    if (widget.onChanged != null) {
      widget.onChanged!(_selectedItem);
    }
  }
}
