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

import java.io.Serializable;
import java.util.Collection;
import java.util.Comparator;
import java.util.List;

public class ComparableList<T extends Comparable<T>> implements Comparable<ComparableList<T>>, Serializable {
	private List<T> list = null;

	public ComparableList(){
		this.list = List.of();
	}

	public ComparableList(T... items) {
		this.list = List.of(items);
	}
	
	public ComparableList(List<T> newList) {
		this.list = newList;
	}
	
	public void setList(List<T> newList) {
		this.list = newList;
	}

	public List<T> getList(){
		return this.list;
	}
	
	@Override
	public int compareTo(ComparableList<T> other) {
		if (this.list == null && other.list == null) return 0;
		if (this.list == null) return -1;
		if (other.list == null) return 1;
		int sizeCompare = Integer.compare(this.list.size(), other.list.size());
		if (sizeCompare != 0) return sizeCompare;
		for (int i = 0; i < this.list.size(); i++) {
			int cmp = this.list.get(i).compareTo(other.list.get(i));
			if (cmp != 0) return cmp;
		}
		return 0;
	}

}
