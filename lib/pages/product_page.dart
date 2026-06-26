import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/cart_model.dart';
import '../data/product_data.dart';
import '../widgets/product_card.dart';
import '../widgets/category_button.dart';
import 'cart_page.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  int selectedIndex = 0;
  int currentNavIndex = 0;

  Set<Product> favorites = {};
  List<CartItem> cartItems = [];

  List<Product> get filteredProducts {
    if (selectedIndex == 1) return products.where((p) => p.category == 'Smartphones').toList();
    if (selectedIndex == 2) return products.where((p) => p.category == 'Apparels').toList();
    if (selectedIndex == 3) return products.where((p) => p.category == 'Watches').toList();
    return products;
  }

  bool isInCart(Product product) =>
      cartItems.any((item) => item.product == product);

  void addToCart(Product product) {
    setState(() {
      final existing = cartItems.where((i) => i.product == product);
      if (existing.isNotEmpty) {
        existing.first.quantity++;
      } else {
        cartItems.add(CartItem(product: product));
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${product.name} added to cart!"),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("E-Commerce App"),
      ),
      body: currentNavIndex == 0
          ? buildHome()
          : currentNavIndex == 1
              ? buildFavorites()
              : CartPage(
                  cartItems: cartItems,
                  onCartChanged: () => setState(() {}),
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentNavIndex,
        onTap: (index) => setState(() => currentNavIndex = index),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favorites",
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (cartItems.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${cartItems.fold(0, (sum, i) => sum + i.quantity)}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
              ],
            ),
            label: "Cart",
          ),
        ],
      ),
    );
  }

  Widget buildHome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
          child: Text(
            "Our Products",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              CategoryButton(title: "All", isSelected: selectedIndex == 0, onTap: () => setState(() => selectedIndex = 0)),
              CategoryButton(title: "Smartphones", isSelected: selectedIndex == 1, onTap: () => setState(() => selectedIndex = 1)),
              CategoryButton(title: "Apparels", isSelected: selectedIndex == 2, onTap: () => setState(() => selectedIndex = 2)),
              CategoryButton(title: "Watches", isSelected: selectedIndex == 3, onTap: () => setState(() => selectedIndex = 3)),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: filteredProducts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.62,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemBuilder: (context, index) {
              Product product = filteredProducts[index];
              return ProductCard(
                product: product,
                isFavorite: favorites.contains(product),
                isInCart: isInCart(product),
                onFavorite: () => setState(() {
                  favorites.contains(product)
                      ? favorites.remove(product)
                      : favorites.add(product);
                }),
                onAddToCart: () => addToCart(product),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildFavorites() {
    if (favorites.isEmpty) {
      return const Center(
        child: Text(
          'No selected favorite available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: favorites.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemBuilder: (context, index) {
        Product product = favorites.elementAt(index);
        return ProductCard(
          product: product,
          isFavorite: true,
          isInCart: isInCart(product),
          onFavorite: () => setState(() => favorites.remove(product)),
          onAddToCart: () => addToCart(product),
        );
      },
    );
  }
}