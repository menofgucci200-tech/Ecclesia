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
    case Caritas = 'caritas';
    case Casuel = 'casuel';
    case Denier = 'denier';
    case Cierge = 'cierge';
    case Autre = 'autre';

    public function label(): string
    {
        return match ($this) {
            self::MassRequest => 'Demande de messe',
            self::Quete => 'Quête',
            self::Don => 'Don',
            self::Caritas => 'Caritas',
            self::Casuel => 'Casuel',
            self::Denier => 'Denier du culte',
            self::Cierge => 'Cierges',
            self::Autre => 'Autre',
        };
    }

    public function description(): string
    {
        return match ($this) {
            self::MassRequest => 'Faire célébrer une messe à une intention',
            self::Quete => 'Participer à la quête',
            self::Don => 'Faire un don libre à la paroisse',
            self::Caritas => "Soutenir l'action caritative (Caritas)",
            self::Casuel => 'Baptême, mariage, funérailles…',
            self::Denier => 'Contribution au denier du culte',
            self::Cierge => 'Offrir un cierge / lumignon',
            self::Autre => 'Autre offrande ou paiement',
        };
    }

    /** Whether this type collects mass-intention details. */
    public function isMassRequest(): bool
    {
        return $this === self::MassRequest;
    }

    /** Contextual label for the (optional) date field shown in the app. */
    public function dateLabel(): string
    {
        return match ($this) {
            self::MassRequest => 'Date souhaitée de la messe',
            self::Quete => 'Date de la quête (ex. dimanche)',
            self::Casuel => 'Date de la célébration',
            default => 'Date concernée (optionnel)',
        };
    }

    /** Prefilled amount (XOF). Null means no default. */
    public function defaultAmount(): ?int
    {
        return match ($this) {
            self::MassRequest => 3000,
            default => null,
        };
    }

    /** Suggested amounts (XOF) shown as quick chips in the app. */
    public function suggestedAmounts(): array
    {
        return match ($this) {
            self::MassRequest => [3000, 5000, 10000],
            self::Quete => [500, 1000, 2000],
            self::Don => [1000, 5000, 10000, 25000],
            self::Caritas => [1000, 2000, 5000, 10000],
            self::Casuel => [5000, 10000, 25000, 50000],
            self::Denier => [5000, 10000, 25000],
            self::Cierge => [200, 500, 1000],
            self::Autre => [1000, 2000, 5000],
        };
    }
}
