import 'package:flutter/material.dart';

void main() => runApp(const CartApp());

class CartApp extends StatelessWidget {
  const CartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping Cart ni JL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const CartScreen(),
    );
  }
}

class CartItem {
  final String name;
  final double price;
  int quantity;
  bool gotIt;

  CartItem({
    required this.name,
    required this.price,
    this.quantity = 1,
    this.gotIt = false,
  });
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<CartItem> _items = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _items.addAll([
      CartItem(name: 'Bread', price: 2.50, quantity: 1),
      CartItem(name: 'Milk', price: 3.25, quantity: 2),
      CartItem(name: 'Imbotido ni jl', price: 1.20, quantity: 4),
      CartItem(name: 'Apples', price: 1.20, quantity: 4),
      CartItem(name: 'Eggs', price: 2.00, quantity: 1),
    ]);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _increase(int index) {
    if (_items[index].quantity < 10) {
      setState(() => _items[index].quantity++);
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum quantity reached.')),
      );
    }
  }

  void _decrease(int index) {
    if (_items[index].quantity > 1) {
      setState(() => _items[index].quantity--);
    }
  }

  void _toggle(int index) {
    setState(() => _items[index].gotIt = !_items[index].gotIt);
  }

  void _addItem() {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim());

    if (name.isEmpty || price == null || !price.isFinite || price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter an item name and a valid price.')),
      );
      return;
    }

    setState(() {
      if (_items.any((item) => item.name.toLowerCase() == name.toLowerCase())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item already exists in the cart.')),
        );
        return;
      }else{
      _items.add(CartItem(name: name, price: price));
      _nameController.clear();
      _priceController.clear();
      }
    });
    FocusScope.of(context).unfocus();
  }

  void _clearChecked() {
    setState(() => _items.removeWhere((item) => item.gotIt));
  }

  double get _total =>
      _items.fold(0, (sum, item) => sum + item.price * item.quantity);

  @override
  Widget build(BuildContext context) {
    final checkedCount = _items.where((item) => item.gotIt).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          IconButton(
            tooltip: 'Clear checked items',
            onPressed: checkedCount == 0 ? null : _clearChecked,
            icon: const Icon(Icons.cleaning_services_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_basket_outlined, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${_items.length} ${_items.length == 1 ? 'item' : 'items'}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        '\$${_total.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Item name',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _addItem(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        prefixText: '\$',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _addItem(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Add item',
                    onPressed: _addItem,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _items.isEmpty
                  ? const Center(
                      child: Text(
                        'Your cart is empty. Add an item to get started.',
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                      itemCount: _items.length,
                      itemBuilder: (context, index) => CartItemTile(
                        item: _items[index],
                        onToggle: () => _toggle(index),
                        onIncrease: () => _increase(index),
                        onDecrease: () => _decrease(index),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onToggle;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    final itemStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      decoration: item.gotIt ? TextDecoration.lineThrough : null,
      color: item.gotIt ? Theme.of(context).colorScheme.outline : null,
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Checkbox(value: item.gotIt, onChanged: (_) => onToggle()),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: itemStyle),
                  Text('\$${item.price.toStringAsFixed(2)} each'),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Decrease quantity',
              onPressed: item.quantity > 1 ? onDecrease : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text(
              '${item.quantity}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            IconButton(
              tooltip: item.quantity >= 10 ? 'Maximum quantity reached' : 'Increase quantity',
              onPressed: item.quantity < 10 ? onIncrease : null,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ),
    );
  }
}
