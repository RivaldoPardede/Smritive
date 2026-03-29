// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Smritive';

  @override
  String get login_title => 'Selamat Datang';

  @override
  String get login_subtitle => 'Masuk untuk melanjutkan perjalanan ceritamu';

  @override
  String get register_title => 'Buat Akun';

  @override
  String get register_subtitle => 'Mulai berbagi ceritamu dengan dunia';

  @override
  String get stories_title => 'Cerita';

  @override
  String get detail_title => 'Detail Cerita';

  @override
  String get add_story_title => 'Tambah Cerita';

  @override
  String get field_email => 'Alamat email';

  @override
  String get field_password => 'Kata sandi';

  @override
  String get field_name => 'Nama lengkap';

  @override
  String get field_description => 'Deskripsi';

  @override
  String get field_description_hint => 'Ceritakan kisahmu…';

  @override
  String get btn_login => 'Masuk';

  @override
  String get btn_register => 'Daftar';

  @override
  String get btn_share_story => 'Bagikan Cerita';

  @override
  String get error_photo_too_large =>
      'Foto harus lebih kecil dari 1 MB. Pilih gambar yang berbeda.';

  @override
  String get state_loading => 'Memuat…';

  @override
  String get state_empty => 'Belum ada cerita';

  @override
  String get state_error => 'Terjadi kesalahan';

  @override
  String get action_retry => 'Coba lagi';

  @override
  String get nav_home => 'Beranda';

  @override
  String get nav_search => 'Cari';

  @override
  String get nav_saved => 'Disimpan';

  @override
  String get nav_profile => 'Profil';

  @override
  String get section_popular => 'Cerita populer';

  @override
  String get section_you_may_like => 'Mungkin kamu suka';

  @override
  String get section_recent => 'Terbaru';

  @override
  String get link_view_all => 'Lihat semua';

  @override
  String get link_refresh => 'Perbarui daftar';

  @override
  String get auth_no_account => 'Belum punya akun? ';

  @override
  String get auth_have_account => 'Sudah punya akun? ';

  @override
  String get photo_select_label => 'Ketuk untuk memilih foto';

  @override
  String get photo_select_hint => 'Maks 1 MB · JPG, PNG';

  @override
  String get photo_source_gallery => 'Pilih dari galeri';

  @override
  String get photo_source_camera => 'Ambil foto';

  @override
  String get logout => 'Keluar';

  @override
  String get btn_close => 'Tutup';

  @override
  String get photo_required => 'Pilih foto terlebih dahulu.';

  @override
  String get story_section_label => 'Ceritanya';

  @override
  String get validation_required => 'Wajib diisi';

  @override
  String get validation_password_min => 'Kata sandi minimal 8 karakter';

  @override
  String get error_generic => 'Terjadi kesalahan tak terduga. Coba lagi.';

  @override
  String story_author_label(String name) {
    return 'oleh $name';
  }

  @override
  String get lang_switch_label => 'EN';

  @override
  String get lang_switch_label_inverse => 'ID';

  @override
  String get auth_tagline => 'Ubah momen singkat menjadi cerita abadi.';
}
