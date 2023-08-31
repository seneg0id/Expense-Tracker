
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:jupiter_clone/screens/signin_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/database_provider.dart';
import '../widgets/budgetform.dart';
import '../widgets/category_screen/category_card.dart';
import '../widgets/expense_screen/expense_card.dart';
import 'budgetscreen.dart';
import 'dart:io';
import '../main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.red[400],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Account'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Add account settings action here
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AccountSettingsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.money),
            title: const Text('Currency'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CurrencyScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.monetization_on),
            title: const Text('Budget'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BudgetScreen(budgetCategories: BudgetCategories.categories)),
              );
            },
          ),
        ],
      ),
    );
  }
}



class CurrencyScreen extends StatelessWidget {
  const CurrencyScreen({Key? key}) : super(key: key);

  static const currencies = {
    'INR': ['₹', 1],
    'USD': ['\$', 0.012],
    'EUR': ['€', 0.011],
    'GBP': ['£', 0.0097],
    'JPY': ['¥', 1.68],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Currency'),
        backgroundColor: Colors.red[400],
      ),
      body: ListView.builder(
        itemCount: currencies.length,
        itemBuilder: (context, index) {
          final symbol = currencies.values.toList()[index][0].toString();
          final mul = currencies.values.toList()[index][1];
          final currencyCode = currencies.keys.toList()[index];
          double mul1 = double.parse(mul.toString());
          return ListTile(
            title: Text('$symbol $currencyCode'),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              prefs.setString('currency_symbol', symbol);
              Provider.of<CurrencyNotifier>(context, listen: false)
                  .setCurrencySymbol(symbol, mul1);
              Navigator.pop(context, currencyCode);
            },
          );
        },
      ),
    );
  }
}




class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    // final user;
    // final email;
    final email = user?.email ?? 'No email found';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        backgroundColor: Colors.red[400],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Email: $email',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final File file = await provider.exportToCsv();
                final user = FirebaseAuth.instance.currentUser;
                final storage = FirebaseStorage.instance;
                final ref = storage.ref().child('userdata/${user!.uid}.csv');
                final task = ref.putFile(file);
                final snapshot = await task;
                FirebaseAuth.instance.signOut();
                print("Signed Out");
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SignInScreen()));
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}



