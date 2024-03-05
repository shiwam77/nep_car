import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class SortMenuEditDelete extends StatefulWidget {
  Function? onChange;
  SortMenuEditDelete({Key? key, this.onChange}) : super(key: key);

  @override
  State<SortMenuEditDelete> createState() => _CustomSortMenuTwo();
}

class _CustomSortMenuTwo extends State<SortMenuEditDelete> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        isExpanded: true,
        customButton: const Icon(
          Icons.more_vert,
          size: 20,
          color: Color(0xFF424242),
        ),
        items: [
          ...MenuItems.firstItems.map(
            (item) => DropdownMenuItem<MenuItemB>(
              value: item,
              child: MenuItems.buildItem(item),
            ),
          ),
        ],
        buttonStyleData: ButtonStyleData(
          height: 50,
          width: 160,
          padding: const EdgeInsets.only(left: 14, right: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.black26,
            ),
            color: Colors.transparent,
          ),
          elevation: 2,
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 200,
          width: 150,
          padding: null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Color(0xFF828282),
          ),
          elevation: 8,
          offset: const Offset(-20, 0),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(10),
            thickness: MaterialStateProperty.all<double>(6),
            thumbVisibility: MaterialStateProperty.all<bool>(true),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40,
          padding: EdgeInsets.only(left: 14, right: 14),
        ),
        onChanged: (value) {
          widget.onChange!(value);
        },
      ),
    );
  }
}

class MenuItemB {
  final String text;
  final IconData icon;

  const MenuItemB({
    required this.text,
    required this.icon,
  });
}

class MenuItems {
  static const List<MenuItemB> firstItems = [
    delete,
  ];

  static const delete = MenuItemB(text: 'delete', icon: Icons.delete);

  static Widget buildItem(MenuItemB item) {
    return Row(
      children: [
        Icon(item.icon, color: Colors.white, size: 22),
        const SizedBox(
          width: 10,
        ),
        Text(
          item.text,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  static onChanged(BuildContext context, MenuItemB item) {
    switch (item) {
      case MenuItems.delete:
        break;
    }
  }
}
