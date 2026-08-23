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

package com.ivir.mpif.common.tree;

import java.util.function.Supplier;

public class PairTreeBuilder extends TreeBuilder<PairNode>{
    public PairTreeBuilder(String left, Object right) {
        super(new PairNode(left, right));
    }

    public PairTreeBuilder addChild(String left, Object right){
        addChild(new PairNode(left,right));
        return this;
    }

    public PairTreeBuilder addChildIfTrue(boolean condition, String left, Supplier<Object> rightSup){
        if(condition){
            Object right = rightSup.get();
            addChildIfTrue(true, ()->new PairNode(left, right));
        }
        return this;
    }

    public PairTreeBuilder addSibling(String left, Object right){
        addSibling(new PairNode(left, right));
        return this;
    }

    public PairTreeBuilder addSiblingIfTrue(boolean condition, String left, Supplier<Object> rightSup){
        if(condition){
            Object right = rightSup.get();
            addSiblingIfTrue(true, ()->new PairNode(left, right));
        }
        return this;
    }

}
