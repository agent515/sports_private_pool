import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sports_private_pool/wallet/Payment_Screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MyWallet extends StatefulWidget {
  @override
  _MyWalletState createState() => _MyWalletState();
}

class _MyWalletState extends State<MyWallet> {
  TextEditingController _amountController = new TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Container(
                  child: SvgPicture.asset(
                    'images/icons/paytm.svg',
                    semanticsLabel: 'Paytm logo',
                    height: 100.0,
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextFormField(
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: '₹ ',
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                          hintText: "Enter Amount",
                          helperText: "Enter Amount To add",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(width: 2.0)),
                        ),
                        validator: (String amount) {
                          if (double.parse(amount) < 10)
                            return "Amount cannot be less than ₹10.";
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      ElevatedButton(
                        child: Text('Add Now'),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PaymentScreen(
                                  amount: _amountController.text,
                                ),
                              ),
                            );
                          }
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
