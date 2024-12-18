import 'package:flutter/material.dart';

class PromoPage extends StatelessWidget {
  final List<Map<String, dynamic>> _promoList = [
    {'code': 'DISKON15', 'discount': 15000, 'description': 'Diskon 15%'},
    {'code': 'DISKON20', 'discount': 20000, 'description': 'Diskon 20%'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diskon Spesial'),
      ),
      body: ListView.builder(
        itemCount: _promoList.length,
        itemBuilder: (context, index) {
          final promo = _promoList[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              leading: Icon(Icons.card_giftcard, color: Colors.blue),
              title: Text(promo['description']),
              subtitle: Text('Potongan: Rp${promo['discount']}'),
              onTap: () {
                Navigator.pop(context, {
                  'code': promo['code'],
                  'discount': promo['discount'],
                });
              },
            ),
          );
        },
      ),
    );
  }
}
