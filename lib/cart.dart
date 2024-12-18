import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'promo_page.dart';

class CartPage extends StatefulWidget {
  final List<dynamic> cartItems;

  CartPage({required this.cartItems});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double _totalAmount = 0.0;
  double _discountAmount = 0.0;
  String _selectedPromo = '';

  @override
  void initState() {
    super.initState();
    _calculateTotal();
  }

  /// Calculate total amount of products
  void _calculateTotal() {
    double total = 0.0;
    for (var item in widget.cartItems) {
      total += double.parse(item['price'].toString());
    }
    setState(() {
      _totalAmount = total;
      _discountAmount = 0.0; // Reset discount when recalculating total
    });
  }

  /// Apply discount when promo is selected
  void _applyDiscount(String promoCode, double discountPercentage) {
    setState(() {
      _selectedPromo = promoCode;
      _discountAmount = (_totalAmount * discountPercentage) / 100;
    });
  }

  /// Handle promo screen selection
  void _showPromoScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PromoPage(),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      String promoCode = result['code'];
      double discount = promoCode == 'DISKON15' ? 15 : 20; // 15% or 20%
      _applyDiscount(promoCode, discount);
    }
  }

  /// Place order and save to database
  Future<void> _placeOrder() async {
    final url = Uri.parse('http://192.168.1.41/fromheart-database/place_order.php');
    final orderDetails = {
      'items': widget.cartItems,
      'subtotal': _totalAmount,
      'discount': _discountAmount,
      'final_total': _totalAmount - _discountAmount,
      'promo_code': _selectedPromo,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(orderDetails),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Order placed successfully!')),
          );
          Navigator.pop(context); // Return to the previous page
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to place order: ${responseData['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error, please try again later')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double finalAmount = _totalAmount - _discountAmount;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Pesanan'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Delivery Options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOption('Take Away', selected: true),
              ],
            ),
            Divider(),
            // Product List
            _buildProductList(),
            Divider(),
            // Payment Summary
            _buildPaymentSummary(finalAmount),
            SizedBox(height: 10),
            // Promo Section
            _buildPromoSection(),
            SizedBox(height: 10),
            // Payment Button
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: _placeOrder,
                child: Text('Place an Order', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String title, {bool selected = false}) {
    return TextButton(
      onPressed: () {},
      child: Text(
        title,
        style: TextStyle(
          color: selected ? Colors.red : Colors.black,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return Column(
      children: widget.cartItems.map((item) {
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              'http://192.168.1.41/fromheart-database/${item['image']}',
              height: 50,
              width: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 50,
                width: 50,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          title: Text(item['name']),
          subtitle: Text('Rp${item['price']}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle_outline),
                onPressed: () {},
              ),
              Text('1'),
              IconButton(
                icon: Icon(Icons.add_circle_outline),
                onPressed: () {},
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentSummary(double finalAmount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text('Subtotal'),
          trailing: Text('Rp${_totalAmount.toStringAsFixed(0)}'),
        ),
        if (_discountAmount > 0)
          ListTile(
            title: Text('Discount ($_selectedPromo)'),
            trailing: Text('-Rp${_discountAmount.toStringAsFixed(0)}'),
          ),
        ListTile(
          title: Text('Total Payment'),
          trailing: Text(
            'Rp${finalAmount.toStringAsFixed(0)}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildPromoSection() {
    return ListTile(
      title: Text('Discounts Voucher'),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: _showPromoScreen,
    );
  }
}
