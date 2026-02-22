import 'package:nova_post/models/Parcel.model.dart';
import 'package:nova_post/models/Trace.model.dart';

class ParcelTrackResult {
  final Parcel? parcel;
  final List<Trace> traces;
  final bool canViewFullInfo;

  ParcelTrackResult({
    required this.parcel,
    required this.traces,
    required this.canViewFullInfo,
  });
}
