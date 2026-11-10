import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../demo_state.dart';
import '../widgets/study_page.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key, required this.draft});
  final DemoDraft draft;

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  @override
  Widget build(BuildContext context) => StudyPage(
    title: 'onExit: bản nháp',
    children: [
      TextFormField(
        initialValue: widget.draft.text,
        decoration: const InputDecoration(labelText: 'Nhập nội dung chưa lưu'),
        onChanged: (value) {
          widget.draft.text = value;
          setState(() => widget.draft.dirty = true);
        },
      ),
      Text(widget.draft.dirty ? 'Có thay đổi chưa lưu' : 'Đã lưu'),
      DemoAction(
        'Lưu bản nháp',
        () => setState(() => widget.draft.dirty = false),
      ),
      // Callback onExit được đặt trong GoRoute, không chỉ trong nút này.
      // Vì thế cả go('/'), pop và Back hệ thống đều đi qua quyết định rời route.
      DemoAction('Rời bằng go', () => context.go('/')),
      const Text(
        'Thử Back hoặc nút Home khi còn bản nháp. Chọn Ở lại sẽ giữ nguyên route.',
      ),
    ],
  );
}

/// GoRoute.onExit có thể trả Future<bool>. true cho rời route, false giữ lại.
Future<bool> confirmExit(BuildContext context, DemoDraft draft) async {
  if (!draft.dirty) return true;
  final leave = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Bỏ thay đổi chưa lưu?'),
      actions: [
        // Pop dialog bằng context của dialog. Không pop màn Editor phía dưới.
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Ở lại'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Rời đi'),
        ),
      ],
    ),
  );
  if (leave == true) {
    draft.text = '';
    draft.dirty = false;
  }
  // Bấm ra ngoài dialog cũng được hiểu là chưa đồng ý rời màn hình.
  return leave ?? false;
}
