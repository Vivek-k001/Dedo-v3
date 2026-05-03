import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 2)
class UserProfile extends HiveObject {
  @HiveField(0)
  late String username;

  @HiveField(1)
  DateTime? joinedAt;

  UserProfile({required this.username, this.joinedAt});
}
