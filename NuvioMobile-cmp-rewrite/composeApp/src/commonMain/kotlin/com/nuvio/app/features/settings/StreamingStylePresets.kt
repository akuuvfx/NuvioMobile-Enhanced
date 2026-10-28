package com.nuvio.app.features.settings

import com.nuvio.app.core.ui.AppTheme
import com.nuvio.app.core.ui.PosterCardStyleRepository

/**
 * One-tap looks inspired by popular streaming apps. They only combine existing settings
 * (theme + poster card style), so everything stays individually adjustable afterwards.
 */
internal enum class StreamingStylePreset {
    NETFLIX,
    CRUNCHYROLL,
}

internal fun applyStreamingStylePreset(preset: StreamingStylePreset) {
    when (preset) {
        StreamingStylePreset.NETFLIX -> {
            ThemeSettingsRepository.setTheme(AppTheme.NETFLIX)
            ThemeSettingsRepository.setAmoled(true)
            PosterCardStyleRepository.setWidthDp(112)
            PosterCardStyleRepository.setCornerRadiusDp(4)
            PosterCardStyleRepository.setCatalogLandscapeModeEnabled(false)
            PosterCardStyleRepository.setHideLabelsEnabled(true)
            PosterCardStyleRepository.setAlwaysShowLandscapeClearlogo(false)
        }

        StreamingStylePreset.CRUNCHYROLL -> {
            ThemeSettingsRepository.setTheme(AppTheme.CRUNCHYROLL)
            ThemeSettingsRepository.setAmoled(false)
            PosterCardStyleRepository.setWidthDp(126)
            PosterCardStyleRepository.setCornerRadiusDp(10)
            PosterCardStyleRepository.setCatalogLandscapeModeEnabled(true)
            PosterCardStyleRepository.setHideLabelsEnabled(false)
            PosterCardStyleRepository.setAlwaysShowLandscapeClearlogo(true)
        }
    }
}
