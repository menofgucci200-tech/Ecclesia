<?php

declare(strict_types=1);

namespace App\Enums;

enum UserRole: string
{
    /** A regular faithful using the mobile app. */
    case Member = 'member';

    /** A parish administrator, scoped to a single parish. */
    case Admin = 'admin';

    /** A movement leader, scoped to a single movement. */
    case MovementAdmin = 'movement_admin';

    /** A platform administrator with access to every parish. */
    case SuperAdmin = 'super_admin';

    public function label(): string
    {
        return match ($this) {
            self::Member => 'Fidèle',
            self::Admin => 'Administrateur de paroisse',
            self::MovementAdmin => 'Responsable de mouvement',
            self::SuperAdmin => 'Super administrateur',
        };
    }

    /**
     * Whether the role may access the parish administration dashboard.
     */
    public function isStaff(): bool
    {
        return $this === self::Admin || $this === self::SuperAdmin;
    }

    /**
     * @return list<string>
     */
    public static function values(): array
    {
        return array_map(static fn (self $case) => $case->value, self::cases());
    }
}
