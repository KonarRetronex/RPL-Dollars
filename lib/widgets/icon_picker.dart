import 'package:flutter/material.dart';

class IconPicker extends StatelessWidget {
  const IconPicker({super.key});

  @override
  Widget build(BuildContext context) {
    // Daftar ikon yang bisa dipilih
    final List<IconData> icons = [
      Icons.shopping_cart, Icons.restaurant, Icons.local_gas_station, Icons.movie,
      Icons.receipt, Icons.home, Icons.phone_android, Icons.health_and_safety,
      Icons.school, Icons.flight, Icons.train, Icons.pets,
      Icons.wallet_travel, Icons.attach_money, Icons.card_giftcard, Icons.savings,
      Icons.lightbulb, Icons.build, Icons.sports_esports, Icons.music_note,
    ];

    return AlertDialog(
      title: const Text('Choose Icon'),
      backgroundColor: const Color(0xFF6750A4),
      content: SizedBox(
        width: double.maxFinite,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: icons.length,
          itemBuilder: (context, index) {
            return IconButton(
              icon: Icon(icons[index]),
              onPressed: () {
                // Kembalikan ikon yang dipilih saat ditekan
                Navigator.of(context).pop(icons[index]);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}