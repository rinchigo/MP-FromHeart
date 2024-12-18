import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<dynamic> _orderList = []; // Store fetched orders
  bool _isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  /// Fetch all orders from the database
  Future<void> _fetchOrders() async {
    final url = Uri.parse('http://192.168.1.41/fromheart-database/fetch_orders.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          setState(() {
            _orderList = responseData['data'];
            _isLoading = false;
          });
        } else {
          _showError(responseData['message'] ?? 'Failed to load orders');
        }
      } else {
        _showError('Failed to fetch orders. Server error.');
      }
    } catch (e) {
      _showError('Error: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History Orders'),
        backgroundColor: Colors.green,
        titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orderList.isEmpty
              ? const Center(child: Text('No orders found.'))
              : ListView.builder(
                  itemCount: _orderList.length,
                  itemBuilder: (context, index) {
                    final order = _orderList[index];
                    return _buildOrderCard(order);
                  },
                ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: const Text(
              'Order Completed',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          // Order Details
          ListTile(
            leading: const Icon(Icons.shopping_cart, color: Colors.green),
            title: Text(order['order_type'] ?? 'Take Away',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Text(
              'Rp${order['final_total']}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order ID: ${order['order_id']}'),
                Text(order['order_date']),
                Text(
                  'Items: ${_formatItems(order['items'])}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to format item names from the JSON list
  String _formatItems(dynamic items) {
    try {
      final List<dynamic> itemList = jsonDecode(items);
      final itemNames = itemList.map((item) => item['name']).join(', ');
      return itemNames;
    } catch (e) {
      return 'Invalid item data';
    }
  }
}
