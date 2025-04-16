import 'package:final_ecommerce/routes/route_constants.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  void onSearch(BuildContext context) {
    Navigator.pushNamed(context, productSearchRoute);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onSearch(context),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: iconColor),
            const SizedBox(width: 10),
            Text(
              "Search here ...",
              style: TextStyle(color: iconColor, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

// Dummy search screen
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search")),
      body: const Center(child: Text("Search Screen")),
    );
  }
}
