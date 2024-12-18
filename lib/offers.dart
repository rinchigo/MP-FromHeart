import 'package:flutter/material.dart';
import 'menu.dart';

class OffersPage extends StatelessWidget {
  const OffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> vouchers = [
      {
        'title': 'Discount 15%',
        'description':
            'Min. purchase 35 thousand, Max. 15 thousand discount. Not valid for Promo and Flash Sale menus.',
        'expiry': '31 Dec 2024',
        'image': 'assets/voucher15.png',
        'count': '4x'
      },
      {
        'title': 'Discount 20%',
        'description':
            'Min. purchase 70 thousand, Max. 20 thousand discount. Not valid for Promo and Flash Sale menus.',
        'expiry': '31 Dec 2024',
        'image': 'assets/voucher20.png',
        'count': '3x'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Special Discounts'),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          // Info Section
          Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Vouchers can only be used on the checkout page',
                    style: TextStyle(color: Colors.blue, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          // Voucher List
          ...vouchers.map((voucher) => GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            VoucherDetailPage(voucher: voucher)),
                  );
                },
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(voucher['image'],
                          width: double.infinity,
                          height: 120,
                          fit: BoxFit.cover),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              voucher['title'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              voucher['description'],
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              'Expire pada ${voucher['expiry']}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class VoucherDetailPage extends StatelessWidget {
  final Map<String, dynamic> voucher;

  const VoucherDetailPage({super.key, required this.voucher});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Special Discount'),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          Image.asset(voucher['image'],
              width: double.infinity, height: 150, fit: BoxFit.cover),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              voucher['title'],
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(voucher['description']),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Expire pada ${voucher['expiry']}',
                style: const TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Terms & Conditions'),
            onTap: () {
              _showFullScreen(context, 'Terms & Conditions', _termsContent());
            },
          ),
          ListTile(
            leading: const Icon(Icons.card_giftcard),
            title: const Text('How to Use Vouchers'),
            onTap: () {
              _showFullScreen(context, 'How to Use Vouchers', _howToUseContent());
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MenuPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Center(
                child: Text('Order Now',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show full-screen slider
  void _showFullScreen(BuildContext context, String title, Widget content) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text(title),
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: content,
          ),
        ),
      ),
    );
  }

  // Content for "Syarat dan Ketentuan"
  Widget _termsContent() {
    return const Text(
      '''1. Vouchers are valid at all outlets.
2. Minimum purchase of IDR 75,000.
3. Voucher discount of 25% maximum IDR 30,000*.
4. Vouchers are valid for all payment methods.
5. Vouchers are valid for Pick up & delivery methods.
6. Vouchers can be used 1 (one) time per transaction.
7. Vouchers are not valid for bundling promos.
8. Jiwa+ has the right to withhold and/or cancel promos if there is misuse.
9. Jiwa+ has the right to change the terms and conditions.''',
      style: TextStyle(fontSize: 16, height: 1.5),
    );
  }

  // Content for "Cara Pakai Voucher"
  Widget _howToUseContent() {
    return const Text(
      '''1. Go to the homepage.
2. Select the menu to be ordered, add to the basket/Cart.
3. Go to the "Order Details" page and press "Use Promo".
4. Select the voucher to be used.
5. The purchase fee will be automatically deducted.''',
      style: TextStyle(fontSize: 16, height: 1.5),
    );
  }
}
