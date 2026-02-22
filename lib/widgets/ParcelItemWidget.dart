import 'package:flutter/material.dart';
import 'package:nova_post/models/Parcel.model.dart';

class ParcelItemWidget extends StatelessWidget {
  final Parcel parcel;
  final VoidCallback onSearchPressed;

  const ParcelItemWidget({
    super.key,
    required this.parcel,
    required this.onSearchPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFFF8C0F), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Card(
              color: Color(0xFF1a1d1f),
              margin: const EdgeInsets.all(4),
              child: ListTile(
                title: Text('Parcel ${parcel.number}',
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text(parcel.description,
                    style: const TextStyle(color: Colors.white70)),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: onSearchPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF8C0F),
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Icon(Icons.search, color: Colors.black, size: 24),
          ),
          SizedBox(width: 8),
        ],
      ),
    );
  }
}
