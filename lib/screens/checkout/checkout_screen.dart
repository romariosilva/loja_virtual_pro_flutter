import 'package:flutter/material.dart';
import 'package:lojavirtualpro/common/price_card.dart';
import 'package:lojavirtualpro/models/cart_manager.dart';
import 'package:lojavirtualpro/models/checkout_manager.dart';
import 'package:lojavirtualpro/models/credit_card.dart';
import 'package:lojavirtualpro/models/page_manager.dart';
import 'package:provider/provider.dart';
import 'package:lojavirtualpro/screens/checkout/components/credit_card_widget.dart';

import 'components/cpf_field.dart';

class CheckoutScreen extends StatelessWidget {

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final CreditCard creditCard = CreditCard();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<CartManager, CheckoutManager>(
      create: (_) => CheckoutManager(),
      update: (_, cartManager, checkoutManager) => checkoutManager..updateCart(cartManager),
      lazy: false,
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: const Text('Pagamento'),
          centerTitle: true,
        ),
        body: GestureDetector(
          onTap: (){
            FocusScope.of(context).unfocus();
          },
          child: Consumer<CheckoutManager>(
            builder: (_, checkoutManager, __){
              if(checkoutManager.loading){
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Processando seu pagamento...',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Form(
                key: formKey,
                child: ListView(
                  children: <Widget>[
                    CreditCardWidget(creditCard),
                    CpfField(),
                    PriceCard(
                      buttonText: 'Finalizar Pedido',
                      onPressed: (){
                        if(formKey.currentState.validate()){
                          formKey.currentState.save();

                          checkoutManager.checkout(
                            creditCard: creditCard,
                            onStockFail: (e){
                              Navigator.of(context).popUntil((route) => route.settings.name == '/cart');
                            },
                            onSuccess: (order){
                              Navigator.of(context).popUntil((route) => route.settings.name == '/');
                              Navigator.of(context).pushNamed(
                                '/confirmation',
                                arguments: order
                              );
                            }
                          );
                        }                      
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}