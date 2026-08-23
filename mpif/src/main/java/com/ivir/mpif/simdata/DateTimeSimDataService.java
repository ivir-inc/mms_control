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

package com.ivir.mpif.simdata;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.util.Collection;
import java.util.Optional;

@Component
public class DateTimeSimDataService extends ConcurrentDataStorage<DateTime, DateTime.Attributes>{
	Logger logger = LoggerFactory.getLogger(this.getClass());

	public DateTimeSimDataService() {
		super(DateTime.class);
	}

	public Optional<DateTime> getDateTime(ClockType clockType) {
		return Optional.ofNullable(super.get(clockType.toString()));
	}

	public Collection<DateTime> getAllDateTimes(){
		return super.getAll();
	}
	
}
