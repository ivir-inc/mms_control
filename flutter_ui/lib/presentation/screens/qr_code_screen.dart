/*
 * Copyright 2026 IVIR Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ui/logic/qr_code/qr_code_bloc.dart';
import 'package:flutter_ui/logic/qr_code/qr_code_event.dart';
import 'package:flutter_ui/logic/qr_code/qr_code_state.dart';
import 'package:flutter_ui/presentation/theme/common_colors.dart';
import 'package:flutter_ui/presentation/widgets/general/text/text.dart';

class QrCodeScreen extends StatefulWidget {
  const QrCodeScreen({super.key});

  @override
  State<QrCodeScreen> createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends State<QrCodeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QrCodeBloc>().add(const LoadQrCodeData());
    });
  }

  // Same offset/padding constants federation_control_screen.dart uses to
  // derive a panel height from the viewport — both screens share the same
  // surrounding chrome (app bar, tab content area), so the same allowance
  // applies here.
  static const double _offsetFromTop = 63;
  static const double _outerPadding = 13;

  @override
  Widget build(BuildContext context) {
    final double viewportHeight = MediaQuery.of(context).size.height;
    final double availablePanelHeight =
        viewportHeight - _offsetFromTop - _outerPadding;

    return BlocConsumer<QrCodeBloc, QrCodeState>(
      listenWhen: (previous, current) => current.updateFailed,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: MmsText(
              "Couldn't switch interface — keeping the previous QR code.",
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      },
      builder: (context, state) {
        return Container(
          color: MmsColors.mainBodyBackgroundColor,
          padding: const EdgeInsets.all(_outerPadding),
          child: SizedBox(
            height: availablePanelHeight,
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTopRow(context, state),
                    Expanded(child: _buildQrArea(state)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopRow(BuildContext context, QrCodeState state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const MmsText("Select an interface:"),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: _buildInterfaceDropdown(context, state),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        _buildShowOnStartupCheckbox(context, state),
      ],
    );
  }

  Widget _buildInterfaceDropdown(BuildContext context, QrCodeState state) {
    final entries = <_InterfaceEntry>[
      for (final iface in state.interfaces)
        for (final ip in iface.ipv4) _InterfaceEntry(iface.displayName, ip),
    ];

    if (entries.isEmpty) {
      return const MmsText("<No network addresses available>");
    }

    final selectedValue = entries.any((e) => e.ip == state.selectedIp)
        ? state.selectedIp
        : entries.first.ip;

    return DropdownButton<String>(
      value: selectedValue,
      isExpanded: true,
      items: entries
          .map((e) => DropdownMenuItem<String>(
                value: e.ip,
                child: MmsText('${e.displayName} — ${e.ip}'),
              ))
          .toList(),
      onChanged: state.isLoading
          ? null
          : (newIp) {
              if (newIp != null) {
                context.read<QrCodeBloc>().add(SelectInterface(newIp));
              }
            },
    );
  }

  // Vertically centered in the space below the top row, with fixed 40px
  // top/bottom padding; the QR image itself scales to fill whatever square
  // fits in what remains, maximizing size for ease of scanning.
  Widget _buildQrArea(QrCodeState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.qrNotFound || state.qrImageBytes == null) {
      return const Center(
        child: SizedBox(
          height: 256,
          width: 256,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.fromBorderSide(
                  BorderSide(color: Colors.redAccent)),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: MmsText(
                "Unable to generate a QR code — no matching network address was found.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double side = constraints.maxHeight < constraints.maxWidth
                ? constraints.maxHeight
                : constraints.maxWidth;
            return Image.memory(
              state.qrImageBytes!,
              height: side,
              width: side,
              fit: BoxFit.contain,
            );
          },
        ),
      ),
    );
  }

  Widget _buildShowOnStartupCheckbox(BuildContext context, QrCodeState state) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: state.showOnStartup,
          onChanged: (value) {
            context.read<QrCodeBloc>().add(SetShowOnStartup(value ?? true));
          },
        ),
        const MmsText("Show this screen on startup"),
      ],
    );
  }
}

class _InterfaceEntry {
  final String displayName;
  final String ip;
  const _InterfaceEntry(this.displayName, this.ip);
}
