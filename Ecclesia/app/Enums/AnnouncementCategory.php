<?php

declare(strict_types=1);

namespace App\Enums;

enum AnnouncementCategory: string
{
    case Announcement = 'announcement';
    case Event = 'event';
    case Celebration = 'celebration';
    case Testimony = 'testimony';
    case Formation = 'formation';

    public function label(): string
    {
        return match ($this) {
            self::Announcement => 'Annonces',
            self::Event => 'Événements',
            self::Celebration => 'Célébration',
            self::Testimony => 'Témoignage',
            self::Formation => 'Formation',
        };
    }

    /**
     * @return list<string>
     */
    public static function values(): array
    {
        return array_map(static fn (self $case) => $case->value, self::cases());
    }
}
