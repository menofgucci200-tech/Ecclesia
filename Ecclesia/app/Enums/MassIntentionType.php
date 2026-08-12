<?php

declare(strict_types=1);

namespace App\Enums;

enum MassIntentionType: string
{
    case Repos = 'repos';
    case ActionGrace = 'action_grace';
    case Guerison = 'guerison';
    case Faveur = 'faveur';
    case Autre = 'autre';

    public function label(): string
    {
        return match ($this) {
            self::Repos => "Repos de l'âme (défunt)",
            self::ActionGrace => 'Action de grâce',
            self::Guerison => 'Guérison',
            self::Faveur => 'Demande de faveur',
            self::Autre => 'Autre intention',
        };
    }
}
