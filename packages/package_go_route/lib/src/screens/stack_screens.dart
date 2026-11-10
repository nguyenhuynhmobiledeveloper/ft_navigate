import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/study_page.dart';

class StackScreen extends StatefulWidget {
  const StackScreen({super.key});

  @override
  State<StackScreen> createState() => _StackScreenState();
}

class _StackScreenState extends State<StackScreen> {
  String result = 'Chưa chọn';

  @override
  Widget build(BuildContext context) => StudyPage(
    title: 'Stack và kết quả trả về',
    children: [
      const Text(
        'go dựng stack từ cây route đích; push thêm trang phía trên stack hiện tại.',
      ),
      DemoAction('push trang chọn và chờ kết quả', () async {
        // T là kiểu dữ liệu mong nhận lại từ pop<T>(value).
        // Future hoàn tất khi trang được pop; Back không truyền kết quả → null.
        final value = await context.push<String>('/pick');
        if (!mounted) return;
        setState(() => result = value ?? 'Đã hủy');
      }),
      Text('Kết quả: $result'),
      DemoAction('push bước 1', () => context.push('/stack/step/1')),
      DemoAction('go bước 1', () => context.go('/stack/step/1')),
      DemoAction('Navigator.push màn tạm, không có URL', () {
        // GoRouter vẫn tương thích Navigator. Trang imperative này không nằm
        // trong bảng route nên không thể mở bằng deep link hoặc named route.
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (pageContext) => Scaffold(
              appBar: AppBar(title: const Text('Trang Navigator tạm')),
              body: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(pageContext).pop(),
                  child: const Text('Đóng trang tạm'),
                ),
              ),
            ),
          ),
        );
      }),
      Text('canPop hiện tại: ${context.canPop()}'),
      const RouteSnapshot(),
    ],
  );
}

class PickerScreen extends StatelessWidget {
  const PickerScreen({super.key});

  @override
  Widget build(BuildContext context) => StudyPage(
    title: 'Chọn kết quả',
    children: [
      // Trả về đúng String vì nơi gọi dùng push<String>.
      DemoAction('Chọn Flutter', () => context.pop<String>('Flutter')),
      DemoAction('Hủy lựa chọn', () => context.pop()),
    ],
  );
}

class StackStepScreen extends StatefulWidget {
  const StackStepScreen({super.key, required this.step});
  final String step;

  @override
  State<StackStepScreen> createState() => _StackStepScreenState();
}

class _StackStepScreenState extends State<StackStepScreen> {
  int count = 0;

  @override
  Widget build(BuildContext context) => StudyPage(
    title: 'Bước ${widget.step}',
    children: [
      Text('Bộ đếm của State: $count'),
      DemoAction('Tăng bộ đếm bước', () => setState(() => count++)),
      DemoAction('replace sang bước 2', () {
        // replace giữ pageKey của trang trên cùng. Khi Widget cùng kiểu,
        // Flutter có thể giữ State; bộ đếm vẫn còn dù URL/step thay đổi.
        context.replace('/stack/step/2');
      }),
      DemoAction('pushReplacement sang bước 3', () {
        // Thay trang trên cùng bằng Page mới có key mới. Không thêm một tầng
        // Back để quay lại trang vừa bị thay; State của bước trước bị bỏ.
        context.pushReplacement('/stack/step/3');
      }),
      DemoAction('go về mục lục', () => context.go('/')),
      const RouteSnapshot(),
    ],
  );
}

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key, required this.title, required this.message});
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) =>
      StudyPage(title: title, children: [Text(message), const RouteSnapshot()]);
}

class RestorationScreen extends StatefulWidget {
  const RestorationScreen({super.key});

  @override
  State<RestorationScreen> createState() => _RestorationScreenState();
}

class _RestorationScreenState extends State<RestorationScreen>
    with RestorationMixin {
  final RestorableInt _count = RestorableInt(0);

  @override
  String get restorationId => 'restoration-counter';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    // Router phục hồi stack, RestorableProperty phục hồi dữ liệu UI.
    // int thông thường chỉ sống trong bộ nhớ sẽ không tự được khôi phục.
    registerForRestoration(_count, 'count');
  }

  @override
  void dispose() {
    _count.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => StudyPage(
    title: 'State restoration',
    children: [
      Text('Giá trị khôi phục: ${_count.value}'),
      DemoAction(
        'Tăng giá trị khôi phục',
        () => setState(() => _count.value++),
      ),
      const Text(
        'Cần restorationScopeId ở MaterialApp.router và GoRouter; '
        'Page tự tạo cần restorationId. Có widget test restartAndRestore cho ví dụ này. '
        'Đây không phải cơ chế lưu lâu dài như database.',
      ),
    ],
  );
}
