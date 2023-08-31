import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/expense.dart';
import '../../constants/icons.dart';
import './confirm_box.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpenseCard extends StatefulWidget {
  final Expense exp;
  const ExpenseCard(this.exp, {Key? key}) : super(key: key);

  @override
  _ExpenseCardState createState() => _ExpenseCardState();
}

class _ExpenseCardState extends State<ExpenseCard> {
  String _currencySymbol = '';

  @override
  void initState() {
    super.initState();
    _getCurrencySymbol();
  }

  Future<void> _getCurrencySymbol() async {
    final prefs = await SharedPreferences.getInstance();
    final symbol = prefs.getString('currency_symbol') ?? '₹';
    setState(() {
      _currencySymbol = symbol;
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, double> symtomul = {
      '₹' : 1,
      '\$': 0.012,
      '€' : 0.011,
      '£' : 0.0097,
      '¥' : 1.68,
    };
    return Dismissible(
      key: ValueKey(widget.exp.id),
      confirmDismiss: (_) async {
        showDialog(
          context: context,
          builder: (_) => ConfirmBox(exp: widget.exp),
        );
      },
      child: ListTile(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icons[widget.exp.category]),
        ),
        title: Text(widget.exp.title),
        subtitle: Text(DateFormat('MMMM dd, yyyy').format(widget.exp.date)),
        trailing: Text(
          _currencySymbol +
              NumberFormat.currency(
                locale: 'en_IN',
                symbol: '',
              ).format(widget.exp.amount*symtomul[_currencySymbol]!),
        ),
      ),
    );
  }
}



// class ExpenseCard extends StatelessWidget {
//   final Expense exp;
//   const ExpenseCard(this.exp, {super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Dismissible(
//       key: ValueKey(exp.id),
//       confirmDismiss: (_) async {
//         showDialog(
//           context: context,
//           builder: (_) => ConfirmBox(exp: exp),
//         );
//       },
//       child: ListTile(
//         leading: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Icon(icons[exp.category]),
//         ),
//         title: Text(exp.title),
//         subtitle: Text(DateFormat('MMMM dd, yyyy').format(exp.date)),
//         trailing: Text(NumberFormat.currency(locale: 'en_IN', symbol: '₹')
//             .format(exp.amount)),
//       ),
//     );
//   }
// }