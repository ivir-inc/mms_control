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

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ui/data/model/qr_code/network_interface_info.dart';
import 'package:flutter_ui/data/repositories/qr_code/qr_code_preferences_repository.dart';
import 'package:flutter_ui/data/services/qr_code_service.dart';
import 'qr_code_event.dart';
import 'qr_code_state.dart';

class QrCodeBloc extends Bloc<QrCodeEvent, QrCodeState> {
  final QrCodePreferencesRepository repository;

  QrCodeBloc({required this.repository})
      : super(QrCodeState(showOnStartup: repository.loadShowOnStartup())) {
    on<LoadQrCodeData>(_onLoad);
    on<SelectInterface>(_onSelectInterface);
    on<SetShowOnStartup>(_onSetShowOnStartup);
  }

  Future<void> _onLoad(LoadQrCodeData event, Emitter<QrCodeState> emit) async {
    emit(state.copyWith(isLoading: true));

    final (rawInterfaces, selectedIp, qrBytes) = await (
      QrCodeService.fetchNetworkInterfaces(),
      QrCodeService.fetchEndpointMask(),
      QrCodeService.fetchQrCodeImageBytes(),
    ).wait;
    final interfaces = _sortInterfaces(rawInterfaces);

    emit(QrCodeState(
      interfaces: interfaces,
      selectedIp: selectedIp,
      qrImageBytes: qrBytes,
      qrNotFound: qrBytes == null,
      showOnStartup: state.showOnStartup,
      isLoading: false,
    ));
  }

  Future<void> _onSelectInterface(
      SelectInterface event, Emitter<QrCodeState> emit) async {
    emit(state.copyWith(isLoading: true, updateFailed: false));

    final success = await QrCodeService.updateEndpointMask(event.ip);
    if (!success) {
      // The PUT failed, but nothing on the backend changed — the previous
      // selection and its QR are still valid, so leave them as-is and only
      // signal the failure as a one-off error (see qr_code_screen.dart's
      // BlocConsumer), rather than replacing a working QR with a false
      // "not found" state.
      emit(state.copyWith(isLoading: false, updateFailed: true));
      return;
    }

    final qrBytes = await QrCodeService.fetchQrCodeImageBytes();

    emit(QrCodeState(
      interfaces: state.interfaces,
      selectedIp: event.ip,
      qrImageBytes: qrBytes,
      qrNotFound: qrBytes == null,
      showOnStartup: state.showOnStartup,
      isLoading: false,
    ));
  }

  void _onSetShowOnStartup(SetShowOnStartup event, Emitter<QrCodeState> emit) {
    repository.saveShowOnStartup(event.value);
    emit(state.copyWith(showOnStartup: event.value));
  }

  /// Interfaces whose only addresses are link-local (169.254.x.x, usually a
  /// NIC that failed DHCP) sort toward the bottom rather than being filtered
  /// out entirely — per COM-26 design decision, 2026-07-14.
  List<NetworkInterfaceInfo> _sortInterfaces(List<NetworkInterfaceInfo> list) {
    final sorted = List<NetworkInterfaceInfo>.from(list);
    sorted.sort((a, b) {
      if (a.isLinkLocalOnly == b.isLinkLocalOnly) return 0;
      return a.isLinkLocalOnly ? 1 : -1;
    });
    return sorted;
  }
}
