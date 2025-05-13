import 'package:final_ecommerce/data/faqs_data.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:flutter/material.dart';

class FAQs extends StatefulWidget {
  const FAQs({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FAQScreen createState() => _FAQScreen();
}

class _FAQScreen extends State<FAQs> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 900;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("FAQs", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        centerTitle: isLargeScreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isLargeScreen ? 800 : double.infinity,
          ),
          child: ListView(
            padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
            children: [
              if (isLargeScreen) ...[
                // Header for large screens
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    children: [
                      const Text(
                        "Frequently Asked Questions",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Find answers to common questions about our products and services",
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
              ...faqData
                  .map(
                    (faq) => FAQItem(
                      faq["question"]!,
                      faq["answer"]!,
                      isLargeScreen: isLargeScreen,
                    ),
                  )
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }
}

class FAQItem extends StatelessWidget {
  final String question;
  final String answer;
  final bool isLargeScreen;

  const FAQItem(
    this.question,
    this.answer, {
    super.key,
    this.isLargeScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: isLargeScreen ? 8 : 4),
      elevation: isLargeScreen ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isLargeScreen ? 12 : 10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(
            horizontal: isLargeScreen ? 24 : 16,
            vertical: isLargeScreen ? 8 : 4,
          ),
          title: Text(
            question,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isLargeScreen ? 18 : 16,
            ),
          ),
          iconColor: primaryColor,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: isLargeScreen ? 24 : 16,
                right: isLargeScreen ? 24 : 16,
                top: 0,
                bottom: isLargeScreen ? 24 : 16,
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  answer,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: isLargeScreen ? 16 : 14,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
