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

import 'package:equatable/equatable.dart';
import 'package:flutter_ui/data/model/casualty_state/casualty_state.dart';

abstract class CasualtyStateEvent extends Equatable {
  const CasualtyStateEvent();
  @override
  List<Object?> get props => [];
}

class LoadCasualtyStates extends CasualtyStateEvent {
  const LoadCasualtyStates();
}

class CreateCasualtyState extends CasualtyStateEvent {
  final CasualtyState casualtyState;
  const CreateCasualtyState(this.casualtyState);
  @override
  List<Object?> get props => [casualtyState];
}

class UpdateCasualtyState extends CasualtyStateEvent {
  final CasualtyState casualtyState;
  const UpdateCasualtyState(this.casualtyState);
  @override
  List<Object?> get props => [casualtyState];
}

class StartWatchingCasualtyStates extends CasualtyStateEvent {
  final Duration? interval;
  const StartWatchingCasualtyStates({this.interval});
}

class StopWatchingCasualtyStates extends CasualtyStateEvent {
  const StopWatchingCasualtyStates();
}
