/*
 * Vencord, a Discord client mod
 * Copyright (c) 2025 Vendicated and contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import definePlugin from "@utils/types";

export default definePlugin({
    name: "BitrateVoice",
    description: "For Stereo Microphone users, increases the voice bitrate to 512kbps.",
    authors: [{ name: "just.farissss", id: 997016243741667379n }],
    enabledByDefault: true,
    hidden: true,
    isFecEnabled() {
        return false;
    },
    setVoiceBitratePatch(moduleContext: any) {
        moduleContext.setVoiceBitRate(512000 * 1000);
    },
    patches: [
        {
            find: "getCodecOptions",
            replacement: [
                {
                    match: /freq:\s*48e3\s*,\s*pacsize:\s*960\s*,\s*channels:\s*1\s*,\s*rate:\s*64e3/,
                    replace: 'freq:48e3,pacsize:960,channels:2,rate:512000e3,params:{stereo:"2"}'
                },
                {
                    match: /setBitRate\(\i\){this\.setVoiceBitRate\(\i\)}/,
                    replace: "setBitRate($1){$self.setVoiceBitratePatch(this, $1)}"
                },
                {
                    match: /fec:!0/,
                    replace: "fec:$self.isFecEnabled()"
                }
            ]
        }
    ],
});
