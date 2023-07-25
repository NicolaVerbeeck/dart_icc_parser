import 'package:icc_parser/src/cmm/icc_pcs.dart';
import 'package:icc_parser/src/icc_parser_base.dart';
import 'package:icc_parser/src/types/icc_profile_header.dart';
import 'package:meta/meta.dart';

@immutable
abstract class IccTransform {
  final IccProfile profile;

  final bool doAdjustPCS;
  final bool isInput;
  final bool srcPCSConversion;
  final bool dstPCSConversion;
  final List<double> pcsScale;
  final List<double> pcsOffset;

  const IccTransform({
    required this.profile,
    required this.doAdjustPCS,
    required this.isInput,
    required this.srcPCSConversion,
    required this.dstPCSConversion,
    required this.pcsScale,
    required this.pcsOffset,
  });

  List<double> checkSourceAbsolute(List<double> source) {
    if (doAdjustPCS && !isInput && srcPCSConversion) {
      return adjustPCS(source);
    }
    return source;
  }

  List<double> checkDestinationAbsolute(List<double> source) {
    if (doAdjustPCS && isInput && dstPCSConversion) {
      return adjustPCS(source);
    }
    return source;
  }

  List<double> adjustPCS(List<double> source) {
    assert(source.length == 3);

    final space = intToColorSpaceSignature(profile.header.pcs);

    final dest = List.filled(3, 0.0);
    if (space == ColorSpaceSignature.icSigLabData) {
      if (useLegacyPCS) {
        IccPCS.lab2ToXyz(source: source, dest: dest, noClip: true);
      } else {
        IccPCS.labToXyz(source: source, dest: dest, noClip: true);
      }
    } else {
      dest[0] = source[0];
      dest[1] = source[1];
      dest[2] = source[2];
    }

    dest[0] = dest[0] * pcsScale[0] + pcsOffset[0];
    dest[1] = dest[1] * pcsScale[1] + pcsOffset[1];
    dest[2] = dest[2] * pcsScale[2] + pcsOffset[2];

    if (space == ColorSpaceSignature.icSigLabData) {
      if (useLegacyPCS) {
        IccPCS.xyzToLab2(source: dest, dest: dest, noClip: true);
      } else {
        IccPCS.xyzToLab(source: dest, dest: dest, noClip: true);
      }
    } else {
      dest[0] = dest[0].clamp(0, double.maxFinite);
      dest[1] = dest[1].clamp(0, double.maxFinite);
      dest[2] = dest[2].clamp(0, double.maxFinite);
    }
    return dest;
  }

  bool get useLegacyPCS => false;
}
