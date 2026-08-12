<?php

declare(strict_types=1);

namespace App\Enums;

/**
 * The kinds of spiritual content managed by super administrators and shown in
 * the app's "Vie & Foi" section.
 */
enum PrayerCategory: string
{
    case Priere = 'priere';
    case Chapelet = 'chapelet';
    case Neuvaine = 'neuvaine';
    case Litanie = 'litanie';

    /** Singular French label. */
    public function label(): string
    {
        return match ($this) {
            self::Priere => 'Prière',
            self::Chapelet => 'Chapelet',
            self::Neuvaine => 'Neuvaine',
            self::Litanie => 'Litanie',
        };
    }

    /** Plural French label (section headings). */
    public function pluralLabel(): string
    {
        return match ($this) {
            self::Priere => 'Prières',
            self::Chapelet => 'Chapelets',
            self::Neuvaine => 'Neuvaines',
            self::Litanie => 'Litanies',
        };
    }
}
