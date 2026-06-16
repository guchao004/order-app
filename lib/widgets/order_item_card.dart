import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/order_item.dart';

class OrderItemCard extends StatefulWidget {
  final OrderItem item;
  final int index;
  final ValueChanged<OrderItem> onUpdate;
  final VoidCallback onDelete;

  const OrderItemCard({
    super.key,
    required this.item,
    required this.index,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<OrderItemCard> createState() => _OrderItemCardState();
}

class _OrderItemCardState extends State<OrderItemCard> {
  late TextEditingController _nameCtrl;
  late TextEditingController _priceCtrl;
  final _fmt = NumberFormat('#,##0', 'th_TH');

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.item.name);
    _priceCtrl = TextEditingController(
      text: widget.item.pricePerUnit == 0 ? '' : widget.item.pricePerUnit.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _updateName(String v) => widget.onUpdate(widget.item.copyWith(name: v));
  void _updatePrice(String v) => widget.onUpdate(widget.item.copyWith(pricePerUnit: double.tryParse(v) ?? 0));
  void _updateQty(int delta) {
    final newQty = (widget.item.quantity + delta).clamp(1, 999);
    widget.onUpdate(widget.item.copyWith(quantity: newQty));
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.item.totalPrice;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text('${widget.index}',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    hintText: 'ชื่อเมนู/รายการ',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onChanged: _updateName,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: widget.onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // ราคาต่อชุด
              Expanded(
                child: TextField(
                  controller: _priceCtrl,
                  decoration: const InputDecoration(
                    labelText: 'ราคา/ชุด',
                    suffixText: '฿',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                  onChanged: _updatePrice,
                ),
              ),
              const SizedBox(width: 12),
              // จำนวน
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _QtyBtn(icon: Icons.remove, onTap: () => _updateQty(-1)),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '${widget.item.quantity}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    _QtyBtn(icon: Icons.add, onTap: () => _updateQty(1)),
                  ],
                ),
              ),
            ],
          ),
          if (total > 0) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'รวม: ${_fmt.format(total)} บาท',
                style: const TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 36,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF2E7D32)),
      ),
    );
  }
}
