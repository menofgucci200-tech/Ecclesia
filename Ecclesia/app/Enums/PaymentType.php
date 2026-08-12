<?php

declare(strict_types=1);

namespace App\Enums;

/**
 * The kinds of payments a faithful can make to a Catholic parish.
 */
enum PaymentType: string
{
    case MassRequest = 'mass_request';
    case Quete = 'quete';
    case Don = 'don';
    case Autre = 'autre';

    public function label(): string
    {
        return match ($this) {
            self::MassRequest => 'Demande de messe',
            self::Quete => 'Quête',
            self::Don => 'Don',
            self::Autre => 'Autre',
        };
    }

    public function description(): string
    {
        return match ($this) {
            self::MassRequest => 'Faire célébrer une messe à une intention',
            self::Quete => 'Participer à la quête',
            self::Don => 'Faire un don libre à la paroisse',
            self::Autre => 'Autre offrande ou paiement',
        };
    }

    /** Whether this type collects mass-intention details. */
    public function isMassRequest(): bool
    {
        return $this === self::MassRequest;
    }

    /** Whether this type collects a free title/motif instead of a fixed label. */
    public function isAutre(): bool
    {
        return $this === self::Autre;
    }

    /** Contextual label for the (optional) date field shown in the app. */
    public function dateLabel(): string
    {
        return match ($this) {
            self::MassRequest => 'Date souhaitée de la messe',
            self::Quete => 'Date de la quête (ex. dimanche)',
            default => 'Date concernée (optionnel)',
        };
    }

    /**
     * Suggested amounts (XOF) shown as quick chips in the app. Only "Don"
     * keeps default suggestions — every other type is either driven by a
     * parish-configured amount or left to free entry.
     */
    public function suggestedAmounts(): array
    {
        return match ($this) {
            self::Don => [1000, 5000, 10000, 25000],
            default => [],
        };
    }
}
