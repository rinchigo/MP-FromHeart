import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'cart.dart';

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<dynamic> _menuItems = []; // Store products fetched from the database
  bool _isLoading = true; // Show loading state
  List<dynamic> _cartItems = []; // Store cart items

  @override
  void initState() {
    super.initState();
    _fetchMenuItems();
  }

  /// Fetch menu items from the backend
  Future<void> _fetchMenuItems() async {
    final url = Uri.parse('http://192.168.1.41/fromheart-database/fetch_menu.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          setState(() {
            _menuItems = responseData['data'];
            _isLoading = false;
          });
        } else {
          _showError(responseData['message'] ?? 'Failed to load data');
        }
      } else {
        _showError('Failed to fetch data. Server error.');
      }
    } catch (e) {
      _showError('Error: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Add item to cart
  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      _cartItems.add(product);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product['name']} added to cart!')),
    );
  }

  /// Navigate to Cart Page
  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(cartItems: _cartItems),
      ),
    );
  }

  /// Build product grid tile
  Widget _buildProductTile(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Image.network(
              'http://192.168.1.41/fromheart-database/${item['image']}',
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 100,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Product Name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              item['name'] ?? 'No Name',
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),
          // Product Price
          Text('Rp${item['price'] ?? '0'}'),
          const SizedBox(height: 4),
          // Add to Cart Button
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.green),
            onPressed: () => _addToCart(item),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: _navigateToCart,
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 columns
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 0.75,
              ),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final product = _menuItems[index];
                return _buildProductTile(product);
              },
            ),
    );
  }
}
