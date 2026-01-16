import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:http/http.dart' as http;

class GoogleDriveService {
  final _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveAppdataScope, // access only to appDataFolder
    ],
  );

  GoogleSignInAccount? _currentUser;
  GoogleSignInAccount? get currentUser => _currentUser;

  // Sign In
  Future<GoogleSignInAccount?> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      return _currentUser;
    } catch (e) {
      debugPrint('Google Sign In Error: $e');
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
  }

  // Check if signed in silently
  Future<GoogleSignInAccount?> signInSilently() async {
     try {
       _currentUser = await _googleSignIn.signInSilently();
       return _currentUser;
     } catch (e) {
       debugPrint('Silent Sign In Error: $e');
       return null;
     }
  }

  // Get Drive API Client
  Future<drive.DriveApi?> _getDriveApi() async {
    if (_currentUser == null) return null;
    final httpClient = await _googleSignIn.authenticatedClient();
    if (httpClient == null) return null;
    return drive.DriveApi(httpClient);
  }

  // Upload Backup File
  Future<void> uploadBackup(File file) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) throw Exception("Not signed in");

    // Check if file exists in AppDataFolder
    final fileList = await driveApi.files.list(
      q: "name = 'good_day_backup.json' and 'appDataFolder' in parents and trashed = false",
      spaces: 'appDataFolder',
    );

    final media = drive.Media(file.openRead(), await file.length());
    
    if (fileList.files != null && fileList.files!.isNotEmpty) {
      // Update existing
      final fileId = fileList.files!.first.id!;
      final driveFile = drive.File(); // Metadata updates if any
      await driveApi.files.update(driveFile, fileId, uploadMedia: media);
      debugPrint("Updated existing backup: $fileId");
    } else {
      // Create new
      final driveFile = drive.File()
        ..name = 'good_day_backup.json'
        ..parents = ['appDataFolder'];
      
      await driveApi.files.create(driveFile, uploadMedia: media);
      debugPrint("Created new backup");
    }
  }

  // List Backups (To see timestamps)
  Future<drive.File?> getLatestBackupMetadata() async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) return null;

    final fileList = await driveApi.files.list(
      q: "name = 'good_day_backup.json' and 'appDataFolder' in parents and trashed = false",
      spaces: 'appDataFolder',
      $fields: 'files(id, name, modifiedTime, size)',
    );

    if (fileList.files != null && fileList.files!.isNotEmpty) {
      return fileList.files!.first;
    }
    return null;
  }

  // Download Backup
  Future<void> downloadBackup(String fileId, File targetFile) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) throw Exception("Not signed in");

    final media = await driveApi.files.get(fileId, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
    
    final sink = targetFile.openWrite();
    await media.stream.pipe(sink);
    await sink.flush();
    await sink.close();
  }
}
