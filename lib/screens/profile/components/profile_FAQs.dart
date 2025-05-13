import 'package:flutter/material.dart';

import 'package:final_ecommerce/data/faqs_data.dart';
class FAQs extends StatefulWidget {
  const FAQs({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FAQScreen createState() => _FAQScreen();
}

class _FAQScreen extends State<FAQs> {
  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("FAQs", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        
        padding: const EdgeInsets.all(16),
        children: faqData.map((faq) => FAQItem(faq["question"]!, faq["answer"]!)).toList(),
      ),
    );
  }
}

class FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const FAQItem(this.question, this.answer, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(answer, style: const TextStyle(color: Colors.black54)),
          )
        ],
      ),
    );
  }
}
