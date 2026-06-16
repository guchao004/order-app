import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/order_item.dart';
import '../widgets/order_item_card.dart';
import '../widgets/summary_card.dart';
import 'format_screen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  // Controllers สำหรับข้อมูลลูกค้า
  final _customerNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _deliveryFeeCtrl = TextEditingController(text: '0');
  final _noteCtrl = TextEditingController();

  // วัน/เวลา
  DateTime _selectedDateTime = DateTime.now();

  // รายการเมนู
  final List<OrderItem> _items = [];

  // ฟอร์แมตข้อความ (เก็บ template)
  String _messageTemplate = '';

  final _currencyFormat = NumberFormat('#,##0', 'th_TH');

  double get _subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);
  double get _deliveryFee => double.tryParse(_deliveryFeeCtrl.text) ?? 0;
  double get _grandTotal => _subtotal + _deliveryFee;

  @override
  void dispose() {
    _customerNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _deliveryFeeCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('th', 'TH'),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _addItem() {
    setState(() {
      _items.add(OrderItem(name: 'เมนูใหม่', quantity: 1, pricePerUnit: 0));
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _updateItem(int index, OrderItem updated) {
    setState(() {
      _items[index] = updated;
    });
  }

  String _buildMessage() {
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(_selectedDateTime);
    final itemLines = _items.map((item) {
      return '• ${item.name} x${item.quantity} = ${_currencyFormat.format(item.totalPrice)} บาท';
    }).join('\n');

    if (_messageTemplate.isNotEmpty) {
      // ใช้ template ที่ผู้ใช้กำหนด แทนที่ตัวแปร
      return _messageTemplate
          .replaceAll('{ชื่อลูกค้า}', _customerNameCtrl.text)
          .replaceAll('{เบอร์โทร}', _phoneCtrl.text)
          .replaceAll('{วันเวลา}', dateStr)
          .replaceAll('{สถานที่}', _addressCtrl.text)
          .replaceAll('{รายการ}', itemLines)
          .replaceAll('{ยอดรวม}', _currencyFormat.format(_subtotal))
          .replaceAll('{ค่าส่ง}', _currencyFormat.format(_deliveryFee))
          .replaceAll('{ยอดทั้งหมด}', _currencyFormat.format(_grandTotal))
          .replaceAll('{หมายเหตุ}', _noteCtrl.text);
    }

    // รูปแบบ default
    return '''📦 ออเดอร์ใหม่
━━━━━━━━━━━━━━
👤 ลูกค้า: ${_customerNameCtrl.text}
📞 เบอร์โทร: ${_phoneCtrl.text}
📅 วัน/เวลา: $dateStr
📍 สถานที่: ${_addressCtrl.text}

🍱 รายการ:
$itemLines

💰 ยอดอาหาร: ${_currencyFormat.format(_subtotal)} บาท
🚗 ค่าส่ง: ${_currencyFormat.format(_deliveryFee)} บาท
✅ ยอดรวมทั้งหมด: ${_currencyFormat.format(_grandTotal)} บาท${_noteCtrl.text.isNotEmpty ? '\n\n📝 หมายเหตุ: ${_noteCtrl.text}' : ''}
━━━━━━━━━━━━━━''';
  }

  void _copyMessage() {
    final msg = _buildMessage();
    Clipboard.setData(ClipboardData(text: msg));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('คัดลอกข้อความแล้ว! นำไปวางใน LINE ได้เลย'),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ล้างข้อมูล'),
        content: const Text('ต้องการล้างข้อมูลออเดอร์ทั้งหมดหรือไม่?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ยกเลิก')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _customerNameCtrl.clear();
                _phoneCtrl.clear();
                _addressCtrl.clear();
                _deliveryFeeCtrl.text = '0';
                _noteCtrl.clear();
                _items.clear();
                _selectedDateTime = DateTime.now();
              });
            },
            child: const Text('ล้างข้อมูล', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _openFormatScreen() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => FormatScreen(
          currentTemplate: _messageTemplate,
          sampleMessage: _buildMessage(),
        ),
      ),
    );
    if (result != null) {
      setState(() => _messageTemplate = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('📋 รับออเดอร์', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'ตั้งค่าฟอร์แมต',
            onPressed: _openFormatScreen,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'ล้างข้อมูล',
            onPressed: _clearAll,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── ส่วนข้อมูลลูกค้า ──
            _SectionCard(
              title: '👤 ข้อมูลลูกค้า',
              child: Column(
                children: [
                  TextField(
                    controller: _customerNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'ชื่อลูกค้า *',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneCtrl,
                    decoration: const InputDecoration(
                      labelText: 'เบอร์โทร *',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  // วัน/เวลา
                  GestureDetector(
                    onTap: _pickDateTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('วัน/เวลาส่ง *',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat('dd/MM/yyyy  HH:mm น.').format(_selectedDateTime),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.edit_outlined, color: Colors.grey, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _addressCtrl,
                    decoration: const InputDecoration(
                      labelText: 'สถานที่ส่ง *',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    maxLines: 2,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _deliveryFeeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'ค่าส่ง (บาท)',
                      prefixIcon: Icon(Icons.delivery_dining_outlined),
                      suffixText: 'บาท',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── รายการเมนู ──
            _SectionCard(
              title: '🍱 รายการเมนู/เบรค',
              trailing: TextButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('เพิ่มเมนู'),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF2E7D32)),
              ),
              child: Column(
                children: [
                  if (_items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          Icon(Icons.restaurant_menu, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text('ยังไม่มีรายการ', style: TextStyle(color: Colors.grey.shade500)),
                          const SizedBox(height: 4),
                          Text('กดปุ่ม "เพิ่มเมนู" เพื่อเริ่มต้น',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                        ],
                      ),
                    )
                  else
                    ...List.generate(_items.length, (i) => OrderItemCard(
                      item: _items[i],
                      index: i + 1,
                      onUpdate: (updated) => _updateItem(i, updated),
                      onDelete: () => _removeItem(i),
                    )),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── หมายเหตุ ──
            _SectionCard(
              title: '📝 หมายเหตุ',
              child: TextField(
                controller: _noteCtrl,
                decoration: const InputDecoration(
                  hintText: 'ระบุหมายเหตุเพิ่มเติม เช่น ไม่เผ็ด, แพ้ถั่ว...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ),

            const SizedBox(height: 16),

            // ── สรุปยอด ──
            SummaryCard(
              subtotal: _subtotal,
              deliveryFee: _deliveryFee,
              grandTotal: _grandTotal,
              itemCount: _items.length,
            ),

            const SizedBox(height: 20),

            // ── ปุ่มคัดลอก ──
            ElevatedButton.icon(
              onPressed: _items.isEmpty ? null : _copyMessage,
              icon: const Icon(Icons.copy),
              label: const Text('คัดลอกข้อความส่งลูกค้า', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                disabledBackgroundColor: Colors.grey.shade300,
              ),
            ),

            const SizedBox(height: 12),

            // ปุ่มดูตัวอย่าง
            OutlinedButton.icon(
              onPressed: _items.isEmpty ? null : () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) => _PreviewSheet(message: _buildMessage(), onCopy: _copyMessage),
                );
              },
              icon: const Icon(Icons.preview_outlined),
              label: const Text('ดูตัวอย่างข้อความ', style: TextStyle(fontSize: 16)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFF2E7D32)),
                foregroundColor: const Color(0xFF2E7D32),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Widget ส่วนกล่อง Section ──
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
            child: Row(
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}

// ── Bottom Sheet Preview ──
class _PreviewSheet extends StatelessWidget {
  final String message;
  final VoidCallback onCopy;

  const _PreviewSheet({required this.message, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (_, ctrl) => Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('ตัวอย่างข้อความ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () { onCopy(); Navigator.pop(context); },
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('คัดลอก'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              controller: ctrl,
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: SelectableText(message, style: const TextStyle(fontSize: 14, height: 1.6)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
