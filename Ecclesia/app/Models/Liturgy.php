<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Liturgy extends Model
{
    protected $fillable = [
        'date',
        'zone',
        'liturgical_day',
        'season',
        'color',
        'week',
        'readings',
        'source',
        'is_hidden',
        'synced_at',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'date' => 'date',
            'readings' => 'array',
            'is_hidden' => 'boolean',
            'synced_at' => 'datetime',
        ];
    }

    /**
     * The gospel reading, if present.
     *
     * @return array<string, mixed>|null
     */
    public function gospel(): ?array
    {
        foreach ($this->readings ?? [] as $reading) {
            if (($reading['type'] ?? null) === 'evangile') {
                return $reading;
            }
        }

        return null;
    }
}
