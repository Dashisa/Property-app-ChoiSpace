import 'package:flutter/material.dart';

class SessionProvider extends ChangeNotifier {
  String? accessToken;
  String? refreshToken;
  // DateTime? accessTokenExpireDate;
  // DateTime? refreshTokenExpireDate;
  String? userRole;
  String? authEmployeeID;

  // User details
  String? userId;
  String? username;
  String? fullName;
  String? email;
  String? contactNumber;
  List<String>? complications;
  DateTime? createdAt;

  void updateSession({
    required String accessToken,
    required String refreshToken,
    // required DateTime accessTokenExpireDate,
    // required DateTime refreshTokenExpireDate,
    required String userRole,
    required String authEmployeeID,
    required String userId,
    required String username,
    required String fullName,
    required String email,
    required String contactNumber,
    required List<String> complications,
    required DateTime createdAt,
  }) {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    // this.accessTokenExpireDate = accessTokenExpireDate;
    // this.refreshTokenExpireDate = refreshTokenExpireDate;
    this.userRole = userRole;
    this.authEmployeeID = authEmployeeID;

    // Update user details
    this.userId = userId;
    this.username = username;
    this.fullName = fullName;
    this.email = email;
    this.contactNumber = contactNumber;
    this.complications = complications;
    this.createdAt = createdAt;

    notifyListeners();
  }

  void clearSession() {
    accessToken = null;
    refreshToken = null;
    // accessTokenExpireDate = null;
    // refreshTokenExpireDate = null;
    userRole = null;
    authEmployeeID = null;

    // Clear user details
    userId = null;
    username = null;
    fullName = null;
    email = null;
    contactNumber = null;
    complications = null;
    createdAt = null;

    notifyListeners();
  }
}
