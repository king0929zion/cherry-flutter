import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CherryIcons {
  CherryIcons._();

  static Widget assets({
    double size = 20,
    Color? color,
  }) =>
      _svg(
        _assetsIconSvg,
        size,
        color: color,
      );

  static Widget mcp({
    double size = 20,
    Color? color,
  }) =>
      _svg(
        _mcpIconSvg,
        size,
        color: color,
      );

  static Widget lightbulbOff({
    double size = 20,
    Color? color,
  }) =>
      _svg(
        _lightbulbOffSvg,
        size,
        color: color,
      );

  static Widget arrowUp({
    double size = 24,
  }) =>
      _svg(
        _arrowUpSvg,
        size,
        allowColorFilter: false,
      );

  static Widget _svg(
    String data,
    double size, {
    Color? color,
    bool allowColorFilter = true,
  }) {
    return SvgPicture.string(
      data,
      width: size,
      height: size,
      colorFilter: color != null && allowColorFilter
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }
}

const _assetsIconSvg = '''
<svg viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M1 5.0211C1 3.04085 2.69417 1.43555 4.78403 1.43555C6.87389 1.43555 8.56806 3.04085 8.56806 5.0211V7.41147C8.56806 7.68934 8.56806 7.82828 8.53583 7.94227C8.44835 8.25161 8.19336 8.49323 7.8669 8.57611C7.7466 8.60666 7.59997 8.60666 7.30672 8.60666H4.78403C2.69417 8.60666 1 7.00135 1 5.0211Z" stroke="currentColor" stroke-width="1.5"/>
  <path d="M11.4316 12.5887C11.4316 12.3109 11.4316 12.1719 11.4639 12.0579C11.5513 11.7486 11.8063 11.507 12.1328 11.4241C12.2531 11.3936 12.3997 11.3936 12.693 11.3936H15.2157C17.3055 11.3936 18.9997 12.9989 18.9997 14.9791C18.9997 16.9594 17.3055 18.5647 15.2157 18.5647C13.1258 18.5647 11.4316 16.9594 11.4316 14.9791V12.5887Z" stroke="currentColor" stroke-width="1.5"/>
  <path d="M1 14.9791C1 12.9989 2.69417 11.3936 4.78403 11.3936H7.05445C7.58426 11.3936 7.84917 11.3936 8.05153 11.4913C8.22954 11.5772 8.37426 11.7143 8.46495 11.883C8.56806 12.0747 8.56806 12.3258 8.56806 12.8278V14.9791C8.56806 16.9594 6.87389 18.5647 4.78403 18.5647C2.69417 18.5647 1 16.9594 1 14.9791Z" stroke="currentColor" stroke-width="1.5"/>
  <path d="M12.1816 5.23477H14.7816M14.7816 5.23477H17.3816M14.7816 5.23477V7.83477M14.7816 5.23477V2.63477" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
</svg>
''';

const _mcpIconSvg = '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path fill-rule="evenodd" clip-rule="evenodd" d="M15.688 2.343a2.588 2.588 0 00-3.61 0l-9.626 9.44a.863.863 0 01-1.203 0 .823.823 0 010-1.18l9.626-9.44a4.313 4.313 0 016.016 0 4.116 4.116 0 011.204 3.54 4.3 4.3 0 013.609 1.18l.05.05a4.115 4.115 0 010 5.9l-8.706 8.537a.274.274 0 000 .393l1.788 1.754a.823.823 0 010 1.18.863.863 0 01-1.203 0l-1.788-1.753a1.92 1.92 0 010-2.754l8.706-8.538a2.47 2.47 0 000-3.54l-.05-.049a2.588 2.588 0 00-3.607-.003l-7.172 7.034-.002.002-.098.097a.863.863 0 01-1.204 0 .823.823 0 010-1.18l7.273-7.133a2.47 2.47 0 00-.003-3.537z" fill="currentColor"/>
  <path fill-rule="evenodd" clip-rule="evenodd" d="M14.485 4.703a.823.823 0 000-1.18.863.863 0 00-1.204 0l-7.119 6.982a4.115 4.115 0 000 5.9 4.314 4.314 0 006.016 0l7.12-6.982a.823.823 0 000-1.18.863.863 0 00-1.204 0l-7.119 6.982a2.588 2.588 0 01-3.61 0 2.47 2.47 0 010-3.54l7.12-6.982z" fill="currentColor"/>
</svg>
''';

const _lightbulbOffSvg = '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path fill="currentColor" d="M12 2C9.76 2 7.78 3.05 6.5 4.68l1.43 1.43C8.84 4.84 10.32 4 12 4a5 5 0 0 1 5 5c0 1.68-.84 3.16-2.11 4.06l1.42 1.44C17.94 13.21 19 11.24 19 9a7 7 0 0 0-7-7M3.28 4L2 5.27L5.04 8.3C5 8.53 5 8.76 5 9c0 2.38 1.19 4.47 3 5.74V17a1 1 0 0 0 1 1h5.73l4 4L20 20.72zm3.95 6.5l5.5 5.5H10v-2.42a5 5 0 0 1-2.77-3.08M9 20v1a1 1 0 0 0 1 1h4a1 1 0 0 0 1-1v-1z"/>
</svg>
''';

const _arrowUpSvg = '''
<svg viewBox="0 0 12 13" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="paint0_linear" x1="5.80317" y1="4.6377" x2="5.80317" y2="12.1394" gradientUnits="userSpaceOnUse">
      <stop stop-color="#C0E58D"/>
      <stop offset="1" stop-color="#3BB554"/>
    </linearGradient>
    <linearGradient id="paint1_linear" x1="5.80317" y1="4.6377" x2="5.80317" y2="12.1394" gradientUnits="userSpaceOnUse">
      <stop stop-color="#C0E58D"/>
      <stop offset="1" stop-color="#3BB554"/>
    </linearGradient>
    <linearGradient id="paint2_linear" x1="6.47116" y1="0.860352" x2="6.47116" y2="6.21902" gradientUnits="userSpaceOnUse">
      <stop stop-color="#C0E58D"/>
      <stop offset="1" stop-color="#3BB554"/>
    </linearGradient>
    <linearGradient id="paint3_linear" x1="6.47116" y1="0.860352" x2="6.47116" y2="6.21902" gradientUnits="userSpaceOnUse">
      <stop stop-color="#C0E58D"/>
      <stop offset="1" stop-color="#3BB554"/>
    </linearGradient>
  </defs>
  <path d="M11.1465 9.42871C11.8281 10.7177 10.457 12.1252 9.14551 11.4717L7.11426 10.4561C6.40875 10.1071 5.58536 10.107 4.87988 10.4561L4.87793 10.457L2.84863 11.4727C1.54304 12.1255 0.166148 10.7175 0.847656 9.42871L0.848633 9.42773L3.07129 5.20508L3.07227 5.20312L3.10059 5.16797C3.13533 5.13857 3.18754 5.1274 3.2373 5.14941L3.23828 5.14844L10.6055 8.47168C10.6337 8.48452 10.6551 8.50657 10.667 8.5293L10.6689 8.53223L11.1465 9.42871Z" fill="url(#paint0_linear)" stroke="url(#paint1_linear)"/>
  <path d="M9.11523 5.60742C9.11179 5.62838 9.1001 5.65338 9.0791 5.67578C9.05811 5.69812 9.03397 5.71183 9.0127 5.7168C8.99496 5.72089 8.97035 5.72174 8.93555 5.70605V5.70508L4.10742 3.53027C4.03403 3.4968 4.01101 3.41979 4.04492 3.35547V3.35449L4.66895 2.16406V2.16504C5.23391 1.09233 6.76576 1.09172 7.33105 2.16406L7.33008 2.16504L9.09766 5.53027L9.09961 5.5332C9.11734 5.56645 9.11802 5.59013 9.11523 5.60742Z" fill="url(#paint2_linear)" stroke="url(#paint3_linear)"/>
</svg>
''';
