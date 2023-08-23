[![Version](https://img.shields.io/pub/v/icc_parser.svg)](https://pub.dev/packages/icc_parser) [![codecov](https://codecov.io/gh/NicolaVerbeeck/dart_icc_parser/graph/badge.svg?token=PRSHAXR5EM)](https://codecov.io/gh/NicolaVerbeeck/dart_icc_parser)

Pure dart implementation of (a subset of) ICC 4.4 color profiles and transformations.

## Features

- Parse ICC profiles (version 4.4 and lower)
- Create color transformations from ICC profiles (not all tags are supported yet) 

## Getting started

For publicly available color profiles, see [ICC's website](https://www.color.org/profiles2.xalter).

## Usage

```dart
final transformations = inputFiles.mapIndexed((index, e) {
  final bytes = ByteData.view(File(e).readAsBytesSync().buffer);
  final stream =
  DataStream(data: bytes, offset: 0, length: bytes.lengthInBytes);
  final profile = ColorProfile.fromBytes(stream);
  return ColorProfileTransform.create(
    profile: profile,
    isInput: index == 0,
    intent: ColorProfileRenderingIntent.perceptual,
    interpolation: ColorProfileInterpolation.tetrahedral,
    lutType: ColorProfileTransformLutType.color,
    useD2BTags: true,
  );
}).toList();
final cmm = ColorProfileCmm();

final finalTransformations = cmm.buildTransformations(transformations);

final color = cmm.apply(finalTransformations, Float64List.fromList([0, 0, 0, 0]));
```

## Additional information

This package is still under development and not all tags are supported yet. 
If you need a specific tag, please open an issue or a pull request.