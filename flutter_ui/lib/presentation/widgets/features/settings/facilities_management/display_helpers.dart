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

String displayRoleOfCare(String code) {
  switch (code) {
    case 'ROLE1':
      return 'Role 1';
    case 'ROLE2':
      return 'Role 2';
    case 'ROLE3':
      return 'Role 3';
    case 'EN_ROUTE':
      return 'En Route';
    default:
      return code;
  }
}

String displayFacilityType(String code) {
  switch (code) {
    case 'FIXED':
      return 'Fixed';
    case 'GROUND':
      return 'Ground';
    case 'AIR':
      return 'Air';
    default:
      return code;
  }
}
