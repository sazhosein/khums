/// تولید آیکون‌های PNG لانچر اندروید برای خمس‌یار.
///
/// این اسکریپت یک تصویر PNG با اندازه مشخص می‌سازد: مربع سبز زمردی با
/// گنبد طلایی و هلال سفید — مطابق طراحی بصری اپ.
///
/// اجرا: dart run tool/generate_icons.dart
///
/// خروجی در android/app/src/main/res/mipmap-*/ic_launcher.png
library;

import 'dart:io';
import 'dart:typed_data';

/// کدگذار ساده PNG (RGBA، بدون فشرده‌سازی در سطح فیلتر)
class PngEncoder {
  static Uint8List encode(int width, int height, Uint8List rgba) {
    final out = BytesBuilder();
    // امضای PNG
    out.add([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);

    // IHDR
    final ihdr = BytesBuilder();
    ihdr.add(_u32(width));
    ihdr.add(_u32(height));
    ihdr.add([8, 6, 0, 0, 0]); // bitDepth=8, colorType=6 (RGBA)
    out.add(_chunk('IHDR', ihdr.toBytes()));

    // IDAT — هر سطر با فیلتر ۰ (None)
    final raw = BytesBuilder();
    for (var y = 0; y < height; y++) {
      raw.addByte(0);
      raw.add(Uint8List.sublistView(rgba, y * width * 4, (y + 1) * width * 4));
    }
    out.add(_chunk('IDAT', _zlibStored(raw.toBytes())));

    // IEND
    out.add(_chunk('IEND', Uint8List(0)));
    return out.toBytes();
  }

  /// zlib بدون فشرده‌سازی (stored blocks) — کافی برای آیکون
  static Uint8List _zlibStored(Uint8List data) {
    final out = BytesBuilder();
    out.addByte(0x78); // CMF
    out.addByte(0x01); // FLG
    var offset = 0;
    const maxBlock = 65535;
    while (offset < data.length) {
      final len = (data.length - offset) > maxBlock
          ? maxBlock
          : (data.length - offset);
      final isLast = offset + len >= data.length;
      out.addByte(isLast ? 1 : 0);
      out.add([len & 0xFF, (len >> 8) & 0xFF]);
      out.add([~len & 0xFF, (~len >> 8) & 0xFF]);
      out.add(Uint8List.sublistView(data, offset, offset + len));
      offset += len;
    }
    // Adler-32
    var a = 1, b = 0;
    for (final byte in data) {
      a = (a + byte) % 65521;
      b = (b + a) % 65521;
    }
    out.add(_u32((b << 16) | a));
    return out.toBytes();
  }

  static Uint8List _chunk(String type, Uint8List data) {
    final out = BytesBuilder();
    out.add(_u32(data.length));
    final typeBytes = type.codeUnits;
    final crcInput = BytesBuilder()
      ..add(typeBytes)
      ..add(data);
    out.add(typeBytes);
    out.add(data);
    out.add(_u32(_crc32(crcInput.toBytes())));
    return out.toBytes();
  }

  static Uint8List _u32(int v) =>
      Uint8List.fromList([(v >> 24) & 0xFF, (v >> 16) & 0xFF, (v >> 8) & 0xFF, v & 0xFF]);

  static int _crc32(Uint8List data) {
    var crc = 0xFFFFFFFF;
    for (final byte in data) {
      crc ^= byte;
      for (var i = 0; i < 8; i++) {
        crc = (crc & 1) != 0 ? (crc >> 1) ^ 0xEDB88320 : crc >> 1;
      }
    }
    return (crc ^ 0xFFFFFFFF) & 0xFFFFFFFF;
  }
}

/// رسم آیکون: زمینه سبز، گنبد طلایی، هلال سفید، پایه سفید
Uint8List renderIcon(int size) {
  final rgba = Uint8List(size * size * 4);
  const emerald = [0x04, 0x6A, 0x38];
  const gold = [0xC9, 0xA2, 0x27];
  const white = [0xFF, 0xFF, 0xFF];

  void setPixel(int x, int y, List<int> c) {
    if (x < 0 || y < 0 || x >= size || y >= size) return;
    final i = (y * size + x) * 4;
    rgba[i] = c[0];
    rgba[i + 1] = c[1];
    rgba[i + 2] = c[2];
    rgba[i + 3] = 255;
  }

  final cx = size / 2;
  final s = size / 108.0; // مقیاس نسبت به viewport 108

  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      // زمینه
      setPixel(x, y, emerald);

      // پایه گنبد (مستطیل سفید)
      if (x >= 30 * s && x <= 78 * s && y >= 66 * s && y <= 74 * s) {
        setPixel(x, y, white);
      }

      // گنبد (نیم‌دایره طلایی)
      final dx = (x - cx) / (20 * s);
      final dy = (y - 66 * s) / (32 * s);
      if (dx * dx + dy * dy <= 1 && y <= 66 * s) {
        setPixel(x, y, gold);
      }

      // هلال: دایره سفید منهای دایره جابه‌جاشده
      final hx = x - 54 * s, hy = y - 24 * s;
      final hx2 = x - 57.5 * s, hy2 = y - 23 * s;
      final inWhite = (hx * hx + hy * hy) <= (7 * s) * (7 * s);
      final inCut = (hx2 * hx2 + hy2 * hy2) <= (7 * s) * (7 * s);
      if (inWhite && !inCut) {
        setPixel(x, y, white);
      } else if (inCut && !inWhite) {
        setPixel(x, y, emerald);
      }
    }
  }
  return rgba;
}

void main() {
  const sizes = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
  };

  final base = 'android/app/src/main/res';
  for (final entry in sizes.entries) {
    final dir = Directory('$base/${entry.key}');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    final rgba = renderIcon(entry.value);
    final png = PngEncoder.encode(entry.value, entry.value, rgba);
    File('$base/${entry.key}/ic_launcher.png').writeAsBytesSync(png);
    stdout.writeln('wrote ${entry.key}/ic_launcher.png (${entry.value}px, ${png.length} bytes)');
  }
  stdout.writeln('done');
}
