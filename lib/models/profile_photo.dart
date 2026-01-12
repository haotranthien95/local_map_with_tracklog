enum ProfilePhotoSource {
  photoLibrary,
}

class ProfilePhoto {
  final String localPath;
  final DateTime updatedAt;
  final ProfilePhotoSource source;

  const ProfilePhoto({
    required this.localPath,
    required this.updatedAt,
    required this.source,
  });
}
