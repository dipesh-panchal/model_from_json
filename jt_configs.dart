import 'package:equatable/equatable.dart';

class JtConfigs extends Equatable {
  final String jtHomeDeityImgUrl;
  final String jtAudioBaseUrl;
  final String jtAudioBaseUrlEn;
  final String jtAudioBaseUrlHi;

  const JtConfigs({
    required this.jtHomeDeityImgUrl,
    required this.jtAudioBaseUrl,
    required this.jtAudioBaseUrlEn,
    required this.jtAudioBaseUrlHi,
  });

  factory JtConfigs.fromJson(Map<String, dynamic> json) {
    return JtConfigs(
      jtHomeDeityImgUrl: json['jt_home_deity_img_url'] as String? ?? '',
      jtAudioBaseUrl: json['jt_audio_base_url'] as String? ?? '',
      jtAudioBaseUrlEn: json['jt_audio_base_url_en'] as String? ?? '',
      jtAudioBaseUrlHi: json['jt_audio_base_url_hi'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'jt_home_deity_img_url': jtHomeDeityImgUrl,
        'jt_audio_base_url': jtAudioBaseUrl,
        'jt_audio_base_url_en': jtAudioBaseUrlEn,
        'jt_audio_base_url_hi': jtAudioBaseUrlHi,
      };

  @override
  String toString() =>
      'JtConfigs(jtHomeDeityImgUrl: $jtHomeDeityImgUrl, jtAudioBaseUrl: $jtAudioBaseUrl, jtAudioBaseUrlEn: $jtAudioBaseUrlEn, jtAudioBaseUrlHi: $jtAudioBaseUrlHi)';

  @override
  List<Object> get props => [
        jtHomeDeityImgUrl,
        jtAudioBaseUrl,
        jtAudioBaseUrlEn,
        jtAudioBaseUrlHi,
      ];
}
