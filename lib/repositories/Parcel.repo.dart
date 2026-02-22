import 'package:firebase_auth/firebase_auth.dart';
import 'package:nova_post/models/ParcelTrackResult.model.dart';
import 'package:nova_post/services/Firebase.database.service.dart';

class ParcelRepository {
  final FirebaseDbService dbService;
  final FirebaseAuth auth;

  ParcelRepository(this.dbService, this.auth);

  Future<ParcelTrackResult?> trackParcel(String parcelNumber) async {
    final parcel = await dbService.getParcelByNumber(parcelNumber);

    if (parcel == null) return null;

    final traces = await dbService.getTracesForParcel(parcel.id);

    final user = auth.currentUser;

    bool canViewFullInfo = false;
    print(
        'Parcel senderId: ${parcel.senderId}, receiverId: ${parcel.receiverId}');
    print('senderId: "${parcel.senderId}"');
    print('user.uid: "${user?.uid ?? "null"}"');
    if (user != null) {
      if (user.uid == parcel.senderId || user.uid == parcel.receiverId) {
        canViewFullInfo = true;
      }
    }
    return ParcelTrackResult(
      parcel: canViewFullInfo ? parcel : null,
      traces: traces,
      canViewFullInfo: canViewFullInfo,
    );
  }
}
