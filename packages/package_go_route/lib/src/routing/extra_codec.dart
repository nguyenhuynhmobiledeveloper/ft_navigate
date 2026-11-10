import 'dart:convert';

/// Ví dụ object truyền ngoài URL. Khi dùng deep link, object có thể không có.
class ProductPreview {
  const ProductPreview(this.id, this.title);
  final String id;
  final String title;
}

/// extraCodec giúp router tuần tự hóa object khi lưu route information.
/// Codec KHÔNG đưa object vào URL. Người khác mở cùng URL vẫn không nhận extra;
/// route phải tải được dữ liệu từ id hoặc có giá trị dự phòng.
class DemoExtraCodec extends Codec<Object?, Object?> {
  const DemoExtraCodec();

  @override
  Converter<Object?, Object?> get encoder => const _ExtraEncoder();

  @override
  Converter<Object?, Object?> get decoder => const _ExtraDecoder();
}

class _ExtraEncoder extends Converter<Object?, Object?> {
  const _ExtraEncoder();

  @override
  Object? convert(Object? input) {
    if (input == null) return null;
    if (input is ProductPreview) {
      // Chỉ dùng các giá trị có thể mã hóa JSON.
      return {'type': 'product-preview', 'id': input.id, 'title': input.title};
    }
    throw FormatException('DemoExtraCodec chưa hỗ trợ ${input.runtimeType}');
  }
}

class _ExtraDecoder extends Converter<Object?, Object?> {
  const _ExtraDecoder();

  @override
  Object? convert(Object? input) {
    if (input == null) return null;
    if (input is Map &&
        input['type'] == 'product-preview' &&
        input['id'] is String &&
        input['title'] is String) {
      return ProductPreview(input['id'] as String, input['title'] as String);
    }
    throw const FormatException('Dữ liệu extra không hợp lệ');
  }
}
