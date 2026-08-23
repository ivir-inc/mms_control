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

package com.ivir.mpif.system;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.event.ApplicationStartedEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Service;

@Service
public class BrowserLaunchService {

    private static final Logger log = LogManager.getLogger(BrowserLaunchService.class);

    private final int port;
    private final boolean headless;

    public BrowserLaunchService(@Value("${server.port}") int port,
                                @Value("${headless:false}") boolean headless) {
        this.port = port;
        this.headless = headless;
    }

    @EventListener(ApplicationStartedEvent.class)
    public void onApplicationStarted() {
        if (headless) {
            log.info("Headless mode — skipping browser launch");
            return;
        }
        new Thread(() -> {
            try {
                String url = "https://localhost:" + port;
                String os = System.getProperty("os.name").toLowerCase();
                if (os.contains("win")) {
                    Runtime.getRuntime().exec(new String[]{"rundll32", "url.dll,FileProtocolHandler", url});
                } else if (os.contains("mac")) {
                    Runtime.getRuntime().exec(new String[]{"open", url});
                } else {
                    Runtime.getRuntime().exec(new String[]{"xdg-open", url});
                }
            } catch (Exception e) {
                log.warn("Failed to launch default browser", e);
            }
        }).start();
    }
}
