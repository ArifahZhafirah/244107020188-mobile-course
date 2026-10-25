class ValidateNote {
  const ValidateNote();

  String? call(String title) {
    if (title.trim().isEmpty) {
      return 'Judul catatan tidak boleh kosong.';
    }
    return null;
  }
}
