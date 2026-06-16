import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SummaryCard extends StatelessWidget {
  final double subtotal;
  final double deliveryFee;
  final double grandTotal;
  final int itemCount;

  const SummaryCard({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    required this.grandTotal,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0', 'th_TH');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF388E3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('💰 สรุปยอด', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text('$itemCount รายการ', style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          const Divider(color: Colors.white24, height: 20),
          _Row(label: 'ยอดรวมอาหาร', value: '${fmt.format(subtotal)} บาท'),
          const SizedBox(height: 4),
          _Row(label: 'ค่าส่ง', value: '${fmt.format(deliveryFee)} บาท'),
          const Divider(color: Colors.white38, height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ยอดรวมทั้งหมด',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Text(
                '${fmt.format(grandTotal)} บาท',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }
}
