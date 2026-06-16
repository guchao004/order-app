import 'package:flutter/material.dart';

class FormatScreen extends StatefulWidget {
  final String currentTemplate;
  final String sampleMessage;

  const FormatScreen({
    super.key,
    required this.currentTemplate,
    required this.sampleMessage,
  });

  @override
  State<FormatScreen> createState() => _FormatScreenState();
}

class _FormatScreenState extends State<FormatScreen> {
  late TextEditingController _ctrl;
  bool _showPreview = false;

  final _variables = [
    ('{ชื่อลูกค้า}', 'ชื่อลูกค้า'),
    ('{เบอร์โทร}', 'เบอร์โทรศัพท์'),
    ('{วันเวลา}', 'วัน/เวลาส่ง'),
    ('{สถานที่}', 'สถานที่ส่ง'),
    ('{รายการ}', 'รายการเมนูทั้งหมด'),
    ('{ยอดรวม}', 'ยอดรวมอาหาร'),
    ('{ค่าส่ง}', 'ค่าส่ง'),
    ('{ยอดทั้งหมด}', 'ยอดรวมทั้งหมด'),
    ('{หมายเหตุ}', 'หมายเหตุ'),
  ];

  static const _defaultTemplate = '''📦 ออเดอร์ใหม่
━━━━━━━━━━━━━━
👤 ลูกค้า: {ชื่อลูกค้า}
📞 เบอร์โทร: {เบอร์โทร}
📅 วัน/เวลา: {วันเวลา}
📍 สถานที่: {สถานที่}

🍱 รายการ:
{รายการ}

💰 ยอดอาหาร: {ยอดรวม} บาท
🚗 ค่าส่ง: {ค่าส่ง} บาท
✅ ยอดรวมทั้งหมด: {ยอดทั้งหมด} บาท
📝 หมายเหตุ: {หมายเหตุ}
━━━━━━━━━━━━━━''';

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.currentTemplate.isEmpty ? _defaultTemplate : widget.currentTemplate,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _insertVariable(String variable) {
    final pos = _ctrl.selection.baseOffset;
    final text = _ctrl.text;
    final newText = pos >= 0
        ? text.substring(0, pos) + variable + text.substring(pos)
        : text + variable;
    _ctrl.text = newText;
    _ctrl.selection = TextSelection.collapsed(offset: (pos >= 0 ? pos : text.length) + variable.length);
  }

  void _resetDefault() {
    setState(() => _ctrl.text = _defaultTemplate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ตั้งค่าฟอร์แมตข้อความ'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _resetDefault,
            child: const Text('รีเซ็ต', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _ctrl.text),
            child: const Text('บันทึก', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab preview/edit
          Container(
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _showPreview = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(
                          color: !_showPreview ? const Color(0xFF2E7D32) : Colors.transparent,
                          width: 2,
                        )),
                      ),
                      child: Text('แก้ไข Template',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: !_showPreview ? FontWeight.bold : FontWeight.normal,
                            color: !_showPreview ? const Color(0xFF2E7D32) : Colors.grey,
                          )),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _showPreview = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(
                          color: _showPreview ? const Color(0xFF2E7D32) : Colors.transparent,
                          width: 2,
                        )),
                      ),
                      child: Text('ตัวอย่าง',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: _showPreview ? FontWeight.bold : FontWeight.normal,
                            color: _showPreview ? const Color(0xFF2E7D32) : Colors.grey,
                          )),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (!_showPreview) ...[
            // ── แถบตัวแปร ──
            Container(
              color: Colors.grey.shade50,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('แตะเพื่อแทรกตัวแปร:',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _variables.map((v) => GestureDetector(
                      onTap: () => _insertVariable(v.$1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF4CAF50)),
                        ),
                        child: Text(v.$1,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF2E7D32))),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
            // ── Text Editor ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _ctrl,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 14, height: 1.6),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    hintText: 'พิมพ์ template ข้อความที่ต้องการ...',
                  ),
                ),
              ),
            ),
          ] else ...[
            // ── Preview ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: SelectableText(
                    widget.sampleMessage,
                    style: const TextStyle(fontSize: 14, height: 1.6),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
