import '../models/user_model.dart';

bool isAdmin(UserModel user) {
  return user.role == 'admin';
}
